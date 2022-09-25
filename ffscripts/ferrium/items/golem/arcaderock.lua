local mod = FiendFolio
local sfx = SFXManager()

mod.arcadeCoinMachines = { 
	{1, 1}, --Slot
	{3, 1}, --Fortune
	{8, 1}, --Donation
	{10, 1}, --Restock
	{11, 1}, --Greed Donation
	{16, 5}, --Crane
	{1020, 3}, --Mining Machine
	{1032, 1}, --Robot Teller
}

FiendFolio.onMachineTouch(-1, function(player, slot)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ARCADE_ROCK) and not slot:GetSprite():IsPlaying("Broken") then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ARCADE_ROCK)
		for i=1,#mod.arcadeCoinMachines do
			if slot.Variant == mod.arcadeCoinMachines[i][1] then
				local data = slot:GetData()
				if not data.arcadeRocked and player:GetNumCoins() >= mod.arcadeCoinMachines[i][2] then
					data.arcadeRocked = true
					local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ARCADE_ROCK)
					if not data.arcadeRockRand then 
						data.arcadeRockRand = RNG()
						data.arcadeRockRand:SetSeed(slot.InitSeed, 0)
					end
					local roll = data.arcadeRockRand:RandomInt(100)
					if roll < math.min(25*mult, 35)+math.max(0, 2.5*player.Luck) then
						sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.5, 0, false, 1)
						player:AddCoins(mod.arcadeCoinMachines[i][2])
						
						for i = 30, 360, 60 do
							local expvec = Vector(0,math.random(10,35)):Rotated(i)
							local sparkle = Isaac.Spawn(1000, 1727, 0, slot.Position + expvec * 0.1, expvec * 0.3, slot):ToEffect()
							sparkle.SpriteOffset = Vector(0,-15)
							sparkle:Update()
						end
					end
				end
			end
		end
	end
end)

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
	local sprite = slot:GetSprite()
	local data = slot:GetData()
	
	if data.arcadeRocked then
		if slot.Variant == 1 then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("WiggleEnd") then
				data.arcadeRocked = nil
			end
		elseif slot.Variant == 3 then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Prize") then
				data.arcadeRocked = nil
			end
		elseif slot.Variant == 8 then
			if (sprite:IsOverlayPlaying("CoinInsert") and sprite:GetOverlayFrame() == 7) or (sprite:IsOverlayPlaying("CoinInsert2") and sprite:GetOverlayFrame() == 5) or (sprite:IsOverlayPlaying("CoinInsert3") and sprite:GetOverlayFrame() == 2) then
				data.arcadeRocked = nil
			end
		elseif slot.Variant == 11 then
			if (sprite:IsOverlayPlaying("CoinInsert") and sprite:GetOverlayFrame() == 6) or (sprite:IsOverlayPlaying("CoinInsert2") and sprite:GetOverlayFrame() == 5) or (sprite:IsOverlayPlaying("CoinInsert3") and sprite:GetOverlayFrame() == 2) then
				data.arcadeRocked = nil
			end
		elseif slot.Variant == 16 then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("NoPrize") then
				data.arcadeRocked = nil
			end
		elseif slot.Variant == 1020 then
			if sprite:IsPlaying("Idle") then
				data.arcadeRocked = nil
			end
		elseif slot.Variant == 1032 then
			if sprite:IsPlaying("Idle") then
				data.arcadeRocked = nil
			end
		end
	end
end, -1)