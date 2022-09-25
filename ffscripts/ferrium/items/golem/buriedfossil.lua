local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:buriedFossil(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BURIED_FOSSIL) then
		local room = game:GetRoom()
		local roomIndex = game:GetLevel():GetCurrentRoomIndex()
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.BURIED_FOSSIL)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BURIED_FOSSIL)
	end
end

FiendFolio.AddTrinketPickupCallback(function(player)
	local basedata = player:GetData()
	local data = basedata.ffsavedata.RunEffects
	local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.BURIED_FOSSIL)
	local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.BURIED_FOSSIL)
	if not data.buriedFossils then
		data.buriedFossils = mod:makeFossilRooms(mult, nil, rng)
	elseif #data.buriedFossils < mult then
		mod:makeFossilRooms(mult, data.buriedFossils, rng)
	end
end, nil, FiendFolio.ITEM.ROCK.BURIED_FOSSIL, nil)

function mod:buriedFossilNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.BURIED_FOSSIL)
		if player:GetData().ffsavedata.RunEffects.buriedFossils then
			player:GetData().ffsavedata.RunEffects.buriedFossils = {}
		end
		if player:HasTrinket(FiendFolio.ITEM.ROCK.BURIED_FOSSIL) then
			local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BURIED_FOSSIL))
			if mult > 0 then
				player:GetData().ffsavedata.RunEffects.buriedFossils = mod:makeFossilRooms(mult, nil, rng)
			end
		end
	end
end

function mod:makeFossilRooms(num, existing, rng)
	local level = game:GetLevel()
	local roomList = level:GetRooms()
	if existing then
		local blacklist = {}
		for _,entry in existing do
			table.insert(blacklist, entry[1])
		end
		local chosen = mod:getSeveralDifferentNumbers(num, roomList.Size, rng, blacklist)
		for i=1,#chosen do
			table.insert(existing, {chosen[i], true})
		end
	else
		local chosen = mod:getSeveralDifferentNumbers(num, roomList.Size, rng)
		local roomTable = {}
		for i=1,#chosen do
			table.insert(roomTable, {chosen[i], true})
		end
		return roomTable
	end
end

function mod:buriedFossilNewRoom()
	local level = game:GetLevel()
	local room = game:GetRoom()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		local data = player:GetData().ffsavedata.RunEffects
		if data.buriedFossils then
			for _,room in ipairs(data.buriedFossils) do
				if room[2] == true then
					if level:GetCurrentRoomDesc().ListIndex == room[1] then
						Isaac.Spawn(1000, 116, 114, mod:FindRandomFreePos(player), Vector.Zero, nil)
						room[2] = false
					end
				end
			end
		end
	end
	--print("current room: " .. level:GetCurrentRoomDesc().ListIndex)
end

-- https://www.geeksforgeeks.org/check-if-any-point-overlaps-the-given-circle-and-rectangle/
local function gridInRadius(grid, pos, radius)
	local x1 = grid.Position.X - 20
	local x2 = grid.Position.X + 20
	local y1 = grid.Position.Y - 20
	local y2 = grid.Position.Y + 20
	
    local xn = math.max(x1, math.min(pos.X, x2))
    local yn = math.max(y1, math.min(pos.Y, y2))
	
    local dx = xn - pos.X
    local dy = yn - pos.Y
	
    return (dx ^ 2 + dy ^ 2) <= radius ^ 2
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,e)
	if e.SubType == 114 then
		local data = e:GetData()
		if not data.spawnGraphic then
			local crack = Isaac.Spawn(114, 1006, 0, e.Position, Vector.Zero, e):ToNPC()
			crack.Parent = e
			crack.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			crack:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			crack:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_DEATH_TRIGGER)
			crack.DepthOffset = -500
			data.spawnGraphic = true
		end
		e.Visible = false
		if e.State == 1 then
			e:Remove()
		elseif e.State == 2 then
			e.State = 1
			e:Remove()
		end
	end
end, 116)

function mod:buriedFossilCrackUpdate(npc)
	local data = npc:GetData()
	if not npc.Parent then
		npc:Remove()
	end
end

function mod:playFossilSound(player, data)
	local queuedItem = player.QueuedItem
	if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() then
		if data.playFossilSound then
			sfx:Play(mod.Sounds.FossilObtain, 1, 0, false, 1)
			data.playFossilSound = nil
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if pickup:GetData().playFossilSound and not pickup.Touched then
		if opp:ToPlayer() then
			local player = opp:ToPlayer()
			if player:CanPickupItem() then
				player:GetData().playFossilSound = true
				pickup:GetData().playFossilSound = nil
			end
		end
	end
end, 350)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, flag, slot, var)
	if id == CollectibleType.COLLECTIBLE_MOMS_SHOVEL or id == CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER then
	else
		return
	end
	local room = game:GetRoom()
	local index = room:GetGridIndex(player.Position)
	for _,crack in ipairs(Isaac.FindByType(1000, 116, 114, false, false)) do
		if room:GetGridIndex(crack.Position) == index then
			crack:Remove()
			sfx:Play(SoundEffect.SOUND_SHOVEL_DIG, 1, 0, false, 1)
			for i=1,4 do
				Isaac.Spawn(1000, 4, 0, crack.Position, RandomVector()*math.random(10,50)/10, nil)
			end
			for i=1,2 do
				local cloud = Isaac.Spawn(1000, 59, 0, crack.Position, Vector(0,-math.random(10,20)/10):Rotated(math.random(-50,50)), crack):ToEffect()
				cloud:SetTimeout(12)
				cloud.SpriteScale = Vector(0.1,0.1)
				cloud:Update()
			end
			for _,pickup in ipairs(Isaac.FindByType(5, -1, -1, false, false)) do
				if pickup.FrameCount == 0 and pickup.Position:Distance(crack.Position) < 40 then
					pickup:Remove()
				end
			end
			local fossil = Isaac.Spawn(5, 350, mod.GetGolemTrinket(nil, "Fossil", true), crack.Position, RandomVector()*2.5, crack):ToPickup()
			fossil:GetData().playFossilSound = true
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	--Oh, turns out Ehwaz just activates the shovel, so this is useless.
	--[[if card == Card.RUNE_EHWAZ then
		local room = game:GetRoom()
		local index = room:GetGridIndex(player.Position)
		for _,crack in ipairs(Isaac.FindByType(1000, 116, 114, false, false)) do
			if room:GetGridIndex(crack.Position) == index then
				crack:ToEffect().State = 1
				crack:Remove()
				sfx:Play(SoundEffect.SOUND_SHOVEL_DIG, 1, 0, false, 1)
				for i=1,4 do
					Isaac.Spawn(1000, 4, 0, crack.Position, RandomVector()*math.random(10,50)/10, nil)
				end
			end
		end
	end]]
	
	if card > 26 and card < 31 then -- Ace cards
		--[[for _,crack in ipairs(Isaac.FindByType(114, 1006, -1, false, false)) do
			crack:Remove()
		end]]
		for _,crack in ipairs(Isaac.FindByType(1000, 116, 114, false, false)) do
			crack:ToEffect():GetData().spawnGraphic = nil
			for _,pickup in ipairs(Isaac.FindByType(5, -1, -1, false, false)) do
				if pickup.FrameCount == 0 and pickup.Position:Distance(crack.Position) < 1 then
					pickup:Remove()
				end
			end
			for _,cloud in ipairs(Isaac.FindByType(1000, 15, -1, false, false)) do
				if cloud.FrameCount == 0 and cloud.Position:Distance(crack.Position) < 1 then
					cloud:Remove()
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.BURIED_FOSSIL, true) then
		local room = game:GetRoom()
		local explosionRadius = 75
		if explosion.SpawnerEntity and explosion.SpawnerEntity:ToBomb() then
			local bomb = explosion.SpawnerEntity:ToBomb()
			explosionRadius = 75 * bomb.RadiusMultiplier
			if bomb.Variant == BombVariant.BOMB_GIGA or 
			   bomb.Variant == BombVariant.BOMB_ROCKET_GIGA or 
			   bomb.Flags & BitSet128(0,1<<(119 - 64)) == BitSet128(0,1<<(119 - 64)) 
			then
				explosionRadius = 130 * bomb.RadiusMultiplier
			elseif bomb.Variant == BombVariant.BOMB_BIG or explosion.SpawnerEntity:GetData().FFBridgeBombMega then
				explosionRadius = 105 * bomb.RadiusMultiplier
			end
		end
		
		for _,cracka in ipairs(Isaac.FindByType(1000, 116, -1, false, false)) do
			local crack = cracka:ToEffect()
			if gridInRadius(crack, explosion.Position, explosionRadius) then
				if crack:Exists() then
					if crack.SubType == 114 then
						crack:Remove()
						sfx:Play(SoundEffect.SOUND_SHOVEL_DIG, 1, 0, false, 1)
						for i=1,4 do
							Isaac.Spawn(1000, 4, 0, crack.Position, RandomVector()*math.random(10,50)/10, nil)
						end
						for i=1,2 do
							local cloud = Isaac.Spawn(1000, 59, 0, crack.Position, Vector(0,-math.random(10,20)/10):Rotated(math.random(-50,50)), crack):ToEffect()
							cloud:SetTimeout(12)
							cloud.SpriteScale = Vector(0.1,0.1)
							cloud:Update()
						end
						local fossil = Isaac.Spawn(5, 350, mod.GetGolemTrinket(nil, "Fossil", true), crack.Position, RandomVector()*2.5, crack):ToPickup()
						fossil:GetData().playFossilSound = true
					elseif crack.State == 0 then
						crack.State = 1
						local rng = crack:GetDropRNG()
						local chestNum = rng:RandomInt(2)
						if chestNum == 0 then
							Isaac.Spawn(5, 50, 1, crack.Position, Vector(0,15):Rotated(rng:RandomInt(360)), nil)
						elseif chestNum == 1 then
							Isaac.Spawn(5, 60, 0, crack.Position, Vector(0,15):Rotated(rng:RandomInt(360)), nil)
						--[[elseif chestnum == 2 then
							Isaac.Spawn(5, 360, 0, crack.Position, Vector(0,15):Rotated(rng:RandomInt(360)), nil)]]
						end
					end
				end
			end
		end
	end
end, EffectVariant.BOMB_EXPLOSION)