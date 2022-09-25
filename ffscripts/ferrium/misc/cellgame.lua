local mod = FiendFolio
local sfx = SFXManager()

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	local sprite = slot:GetSprite()
	local data = slot:GetData()
	
	if not data.init then
		slot.SizeMulti = Vector(3, 0.75)
		slot:GetData().sizeMulti = true
		data.state = "Idle"
		data.rand = RNG()
		data.rand:SetSeed(slot.InitSeed, 0)
		d.plays = 0
		
		function data.DropFunc()
			if not data.DidDropFunc then
				slot:BloodExplode()
				slot:BloodExplode()
				slot:BloodExplode()
				local bloodSplosion = Isaac.Spawn(1000, 2, 3, slot.Position+Vector(0,-20), Vector.Zero, slot)
				local dropTable = {
					{1, 1, 100}, --Coins, Guaranteed
					{1, 3, 50}, --Extra coins
					{1, 2, 50}, --Keys
					{1, 3, 60}, --Miscellaneous
					{1, 3, 60} --Miscellaneous #2
				}
				local results = mod:compoundRoll(dropTable, slot.InitSeed)
				for i=1,#results do
					if i < 2 then --Random Coins
						for j=1,results[i] do
							Isaac.Spawn(5, 20, 0, slot.Position, RandomVector()*math.random(45)/10, slot)
						end
					elseif i == 2 then --Keys
						for j=1,results[i] do
							Isaac.Spawn(5, 30, 0, slot.Position, RandomVector()*math.random(45)/10, slot)
						end
					elseif i > 3 then --Miscellaneous
						for j=1,results[i] do
							Isaac.Spawn(5, 0, 1, slot.Position, RandomVector()*math.random(45)/10, slot)
						end
					end
				end
				data.DidDropFunc = true
			end
		end
		data.init = true
	end
	
	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")
	elseif data.state == "Reveal" then
		if sprite:IsFinished("PayShuffle") then
			sprite:RemoveOverlay()
			data.state = "Shuffled"
		elseif sprite:IsEventTriggered("Shuffle") then
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "PayShuffle")
			mod:spriteOverlayPlay(sprite, "Prize" .. data.prize)
		end
	elseif data.state == "Prizes" then
		if sprite:IsFinished("Shell" .. data.shell .. "Prize") then
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Prize") then
			local shellPos = slot.Position+Vector((-2+data.shell)*25, 10)
			if data.win == true then
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false, 1)
				local commonPrize = data.rand:RandomInt(2)+3
				if data.prize == 0 then
					for i=1,commonPrize+2 do
						Isaac.Spawn(5, 20, 0, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
					end
				elseif data.prize == 1 then
					for i=1,commonPrize do
						Isaac.Spawn(5, 30, 0, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
					end
				elseif data.prize == 2 then
					for i=1,commonPrize do
						Isaac.Spawn(5, 10, 0, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
					end
				elseif data.prize == 3 then
					for i=1,commonPrize do
						Isaac.Spawn(5, 40, 0, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
					end
				elseif data.prize == 4 then
					Isaac.Spawn(5, 752, 0, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
				elseif data.prize == 5 or data.prize == 8 then
					Isaac.Spawn(5, 752, 1, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
				elseif data.prize == 6 then
					Isaac.Spawn(5, 752, 2, shellPos, Vector(0, math.random(25,50)/10):Rotated(math.random(-50,50)), slot)
				end
			else
				sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 1, 0, false, 1)
				local skuzz = Isaac.Spawn(666, 60, 0, shellPos, Vector.Zero, slot)
				skuzz.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				skuzz:GetData().jumpytimer = 0
				skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				skuzz:Update()
			end
		else
			mod:spritePlay(sprite, "Shell" .. data.shell .. "Prize")
		end
	elseif data.state == "Sayonara" then
		if sprite:IsFinished("Teleport") then
			slot:Remove()
		elseif sprite:IsEventTriggered("Disappear") then
			slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			local pos = Game():GetRoom():FindFreePickupSpawnPosition(slot.Position+Vector(0,40), 0, false, false)
			Isaac.Spawn(5, 100, 17, pos, Vector.Zero, slot)
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "Teleport")
		end
	end

	FiendFolio.OverrideExplosionHack(slot, false)
end, 1036)


FiendFolio.onMachineTouch(1036, function(player, slot)
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    local sprite = slot:GetSprite()
	local data = slot:GetData()
	if d.plays == nil then
		d.plays = 0
	end
	
	if data.state == "Idle" then
		--60% chance to get random consumables that decays with each play to 40%. 3% chance to get Skeleton Key.
		--The remaining 40-60% chance is colored keys, based on how many colored locks are in the room.
		if player:GetNumKeys() > 0 then
			player:AddKeys(-1)
			data.state = "Reveal"
			sfx:Play(SoundEffect.SOUND_KEY_DROP0, 1, 0, false, 1)
			local prize = mod:getRoll(1, 100, data.rand)
			if prize < math.max(40, 60-d.plays*3) then
				data.prize = data.rand:RandomInt(4)
			elseif prize > 97 then
				data.prize = 7
			else
				local blueCount = #StageAPI.GetCustomGrids(nil, "FFKeyBlockBlue")
				local greenCount = #StageAPI.GetCustomGrids(nil, "FFKeyBlockGreen")
				local redCount = #StageAPI.GetCustomGrids(nil, "FFKeyBlockRed")
				--[[for _,blue in ipairs(Isaac.FindByType(1000, 1013, -1, false, false)) do
					if blue:GetSprite():GetAnimation() == "Idle" then --why is IsPlaying not working
						blueCount = blueCount+1
					end
				end
				for _,green in ipairs(Isaac.FindByType(1000, 1014, -1, false, false)) do
					if green:GetSprite():GetAnimation() == "Idle" then
						greenCount = greenCount+1
					end
				end
				for _,red in ipairs(Isaac.FindByType(1000, 1015, -1, false, false)) do
					if red:GetSprite():GetAnimation() == "Idle" then
						redCount = redCount+1
					end
				end]]
				local totalKeys = blueCount+greenCount+redCount
				--print(totalKeys)
				if totalKeys > 0 then
					local prizeKey = data.rand:RandomInt(totalKeys)+1
					if prizeKey <= blueCount then
						data.prize = 4
					elseif prizeKey <= blueCount+greenCount then
						data.prize = 5
						if mod.ColourBlindMode then
							data.prize = 8
						end
					else
						data.prize = 6
					end
				else
					if prize > 95 then
						data.prize = 7
					else
						data.prize = data.rand:RandomInt(4)
					end
				end
			end
		end
	elseif data.state == "Shuffled" then
		d.plays = d.plays+1
		
		if math.abs(player.Position.X-slot.Position.X) < 25 then
			data.shell = 2
		elseif player.Position.X > slot.Position.X then
			data.shell = 3
		else
			data.shell = 1
		end
		local chance = data.rand:RandomInt(3)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then
			if chance > 0 then
				data.win = true
			else
				data.win = false
			end
		else
			if chance == 0 then
				data.win = true
			else
				data.win = false
			end
		end
		if data.win == true and data.prize == 7 then
			data.state = "Sayonara"
		else
			data.state = "Prizes"
		end
	end
end)