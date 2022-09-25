local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

--look I know this is super messy but I don't care

mod.grimaceRocks = {
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK1] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK2] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK3] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK4] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK5] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK6] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK7] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK8] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK9] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK10] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK11] = true,
	[FiendFolio.ITEM.ROCK.GRIMACE_ROCK12] = true
}

mod.grimaceRocks2 = {
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK1,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK2,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK3,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK4,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK5,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK6,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK7,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK8,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK9,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK10,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK11,
	FiendFolio.ITEM.ROCK.GRIMACE_ROCK12,
}

function mod.isGrimaceRock(trinketId)
    if trinketId > TrinketType.TRINKET_GOLDEN_FLAG then
        trinketId = trinketId - TrinketType.TRINKET_GOLDEN_FLAG
    end

    return not not mod.grimaceRocks[trinketId]
end

function mod.getTotalGrimaceRockPower(player)
	local power = 0
	for i=1,#mod.grimaceRocks2 do
		power = power+mod.GetGolemTrinketPower(player, mod.grimaceRocks2[i])
	end
	return power
end

function mod:grimaceRockUpdate(player, basedata)
	local data = basedata.ffsavedata.RunEffects
	data.grimaceRockMult = mod.getTotalGrimaceRockPower(player)
	if data.grimaceRockMult > 0 then
		if not data.grimaceRockPositions then
			data.grimaceRockPositions = {}
		end
	else
		return
	end
	
	local queuedItem = player.QueuedItem
	if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() then
		data.refreshGrimaceRocks1 = true
	end
	
	if #data.grimaceRockPositions > 0 then
		local wevegottrouble = nil
		for i=1,#data.grimaceRockPositions do
			if data.grimaceRockPositions[i][3] == true then
				wevegottrouble = i
				break
			end
			if game:GetRoom():GetFrameCount() > 1 and (not data.grimaceRockPositions[i][1] or not data.grimaceRockPositions[i][1]:Exists()) then
				wevegottrouble = i
				break
			end
		end
		if wevegottrouble ~= nil then
			for i=wevegottrouble,#data.grimaceRockPositions-1 do
				data.grimaceRockPositions[i] = data.grimaceRockPositions[i+1]
				if i == #data.grimaceRockPositions-1 then
					data.grimaceRockPositions[i+1] = nil
				end
			end
			if wevegottrouble == #data.grimaceRockPositions then
				data.grimaceRockPositions[wevegottrouble] = nil
			end
		end
	end
	
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK1) then -- Grimace
		if data.refreshGrimaceRocks1 and data.grimaceRock1 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK1 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock1:Remove()
			data.grimaceRock1 = nil
		end
		if not data.grimaceRock1 or (not data.grimaceRock1:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 0, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock1 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK1, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK2) then -- Vomit Grimace
		if data.refreshGrimaceRocks1 and data.grimaceRock2 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK2 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock2:Remove()
			data.grimaceRock2 = nil
		end
		if not data.grimaceRock2 or (not data.grimaceRock2:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 1, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock2 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK2, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK3) then -- Wetstone
		if data.refreshGrimaceRocks1 and data.grimaceRock3 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK3 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock3:Remove()
			data.grimaceRock3 = nil
		end
		if not data.grimaceRock3 or (not data.grimaceRock3:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 2, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock3 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK3, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK4) then -- Constant Stone Shooter
		if data.refreshGrimaceRocks1 and data.grimaceRock4 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK4 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock4:Remove()
			data.grimaceRock4 = nil
		end
		if not data.grimaceRock4 or (not data.grimaceRock4:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 3, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock4 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK4, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK5) then -- Broken Gaping Maw
		if data.refreshGrimaceRocks1 and data.grimaceRock5 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK5 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock5:Remove()
			data.grimaceRock5 = nil
		end
		if not data.grimaceRock5 or (not data.grimaceRock5:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 4, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock5 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK5, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK6) then -- Brimstone Head
		if data.refreshGrimaceRocks1 and data.grimaceRock6 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK6 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock6:Remove()
			data.grimaceRock6 = nil
		end
		if not data.grimaceRock6 or (not data.grimaceRock6:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 5, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock6 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK6, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK7) then -- Cross Stone Shooter
		if data.refreshGrimaceRocks1 and data.grimaceRock7 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK7 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock7:Remove()
			data.grimaceRock7 = nil
		end
		if not data.grimaceRock7 or (not data.grimaceRock7:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 6, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock7 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK7, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK8) then -- Stone Eye
		if data.refreshGrimaceRocks1 and data.grimaceRock8 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK8 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock8:Remove()
			data.grimaceRock8 = nil
		end
		if not data.grimaceRock8 or (not data.grimaceRock8:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 7, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock8 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK8, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK9) then -- Cauldron
		if data.refreshGrimaceRocks1 and data.grimaceRock9 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK9 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock9:Remove()
			data.grimaceRock9 = nil
		end
		if not data.grimaceRock9 or (not data.grimaceRock9:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 8, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock9 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK9, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK10) then -- Gaping Maw
		if data.refreshGrimaceRocks1 and data.grimaceRock10 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK10 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock10:Remove()
			data.grimaceRock10 = nil
		end
		if not data.grimaceRock10 or (not data.grimaceRock10:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 9, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock10 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK10, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK11) then -- Triple Grimace
		if data.refreshGrimaceRocks1 and data.grimaceRock11 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK11 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock11:Remove()
			data.grimaceRock11 = nil
		end
		if not data.grimaceRock11 or (not data.grimaceRock11:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 10, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock11 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK11, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK12) then -- Sensory Grimace
		if data.refreshGrimaceRocks1 and data.grimaceRock12 then
			if #data.grimaceRockPositions > 0 then
				for i=1,#data.grimaceRockPositions do
					if data.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK12 % 32768 then
						data.refreshGrimaceRocks = i-1
						break
					end
				end
			end
			data.grimaceRock12:Remove()
			data.grimaceRock12 = nil
		end
		if not data.grimaceRock12 or (not data.grimaceRock12:Exists()) then
			local grimace = Isaac.Spawn(1000, 1751, 11, player.Position, Vector.Zero, player):ToEffect()
			data.grimaceRock12 = grimace
			grimace.Parent = player
			grimace:FollowParent(player)
			grimace.SpriteScale = player.SpriteScale
			if data.refreshGrimaceRocks ~= nil then
				grimace.DepthOffset = 10+data.refreshGrimaceRocks
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(data.refreshGrimaceRocks*10))
				data.grimaceRockPositions[data.refreshGrimaceRocks+1][1] = grimace
			else
				grimace.DepthOffset = 10+#data.grimaceRockPositions
				grimace.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(#data.grimaceRockPositions*10))
				table.insert(data.grimaceRockPositions, {grimace, FiendFolio.ITEM.ROCK.GRIMACE_ROCK12, false})
			end
		end
	end
	data.refreshGrimaceRocks = nil
	data.refreshGrimaceRocks1 = nil
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i = 1, game:GetNumPlayers() do
        local p = Isaac.GetPlayer(i - 1)
        local data = p:GetData().ffsavedata.RunEffects
		if data.grimaceRockPositions then
			data.refreshGrimaceRocks1 = true
		end
		
		if Isaac.GetChallenge() == mod.challenges.towerOffense then
			for _,trinket in ipairs(Isaac.FindByType(5, 350, -1, false, false)) do
				trinket:Remove()
			end
			local numPurses = p:GetCollectibleNum(CollectibleType.COLLECTIBLE_MOMS_PURSE, true)
			if numPurses < 1 then
				p:AddCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE, 0, false)
			end
			for j=1,#mod.grimaceRocks2 do
				p:TryRemoveTrinket(mod.grimaceRocks2[j])
			end
			data.grimaceRockPositions = {}
			if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
				mod.scheduleForUpdate(function()
					local nums = mod:getSeveralDifferentNumbers(6, 12)
					p:AddTrinket(mod.grimaceRocks2[nums[1]])
					p:AddTrinket(mod.grimaceRocks2[nums[2]])
					p:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM, -1)
					p:AddTrinket(mod.grimaceRocks2[nums[3]])
					p:AddTrinket(mod.grimaceRocks2[nums[4]])
					p:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM, -1)
					p:AddTrinket(mod.grimaceRocks2[nums[5]])
					p:AddTrinket(mod.grimaceRocks2[nums[6]])
				end, 1)
			else
				local nums = mod:getSeveralDifferentNumbers(6, 12)
				p:AddTrinket(mod.grimaceRocks2[nums[1]])
				p:AddTrinket(mod.grimaceRocks2[nums[2]])
				p:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM, -1)
				p:AddTrinket(mod.grimaceRocks2[nums[3]])
				p:AddTrinket(mod.grimaceRocks2[nums[4]])
				p:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM, -1)
				p:AddTrinket(mod.grimaceRocks2[nums[5]] + 32768)
				p:AddTrinket(mod.grimaceRocks2[nums[6]] + 32768)
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
	if e.Parent then
		local player = e.Parent:ToPlayer()
		local pData = player:GetData().ffsavedata.RunEffects
		local mult = pData.grimaceRockMult
		
		if mult == 0 then
			pData.grimaceRockPositions = {}
			e:Remove()
		end
		
		if Isaac.GetChallenge() == mod.challenges.towerOffense then
			mult = 1.5
		end
		
		local sprite = e:GetSprite()
		local data = e:GetData()
		
		if e.SubType == 0 then -- Grimace
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK1 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK1) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock1 = nil
				e:Remove()
			end
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				data.target = nil
				local radius = 1000
				for _,entity in ipairs(Isaac.FindInRadius(e.Position, 150, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
						if entity.Position:Distance(e.Position) < radius then
							radius = entity.Position:Distance(e.Position)
							data.target = entity
						end
					end
				end
				if data.StateFrame > 20 and data.target then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				if not data.target or data.target:IsDead() or mod:isStatusCorpse(data.target) then
					local radius = 1000
					for _,entity in ipairs(Isaac.FindInRadius(e.Position, 1000, EntityPartition.ENEMY)) do
						if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
							if entity.Position:Distance(e.Position) < radius then
								radius = entity.Position:Distance(e.Position)
								data.target = entity
							end
						end
					end
				end
			
				if sprite:IsFinished("Shoot") then
					data.state = "Idle"
					data.StateFrame = 0
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
					local tear = Isaac.Spawn(2, 1, 0, e.Position, (data.target.Position-e.Position):Resized(8), e):ToTear()
					tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
					tear.FallingAcceleration = 0.5
					tear.FallingSpeed = -7
					tear.CollisionDamage = player.Damage*mult
					tear:ResetSpriteScale()
				else
					mod:spritePlay(sprite, "Shoot")
				end
			end
		elseif e.SubType == 1 then -- Vomit Grimace
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK2 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK2) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock2 = nil
				e:Remove()
			end
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
		
			if data.state == "Idle" then
				data.target = nil
				local radius = 1000
				for _,entity in ipairs(Isaac.FindInRadius(e.Position, 200, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
						if entity.Position:Distance(e.Position) < radius then
							radius = entity.Position:Distance(e.Position)
							data.target = entity
						end
					end
				end
				if data.StateFrame > 40 and data.target then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				local finding = false
				if not data.target or data.target:IsDead() or mod:isStatusCorpse(data.target) then
					local finding = true
					local radius = 0
					for _,entity in ipairs(Isaac.FindInRadius(e.Position, 200, EntityPartition.ENEMY)) do
						if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
							if entity.Position:Distance(e.Position) > radius then
								radius = entity.Position:Distance(e.Position)
								data.target = entity
								local finding = false
							end
						end
					end
				end
				if finding == true then
					data.state = "Idle"
					data.StateFrame = 0
				end
			
				if sprite:IsFinished("Shoot") then
					data.state = "Idle"
					data.StateFrame = 0
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
					local tear = Isaac.Spawn(2, 1, 0, e.Position, (data.target.Position-e.Position):Resized(8), e):ToTear()
					tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
					tear.FallingAcceleration = 1.1
					tear.FallingSpeed = -20
					tear.CollisionDamage = (player.Damage+10)*mult
					tear:AddTearFlags(TearFlags.TEAR_EXPLOSIVE)
					tear.Color = mod.ColorIpecacProper
					tear:GetData().dontHurtPlayerExplosive = true
					tear:ResetSpriteScale()
				else
					mod:spritePlay(sprite, "Shoot")
				end
			end
		elseif e.SubType == 2 then -- Wetstone
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK3 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK3) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock3 = nil
				e:Remove()
			end
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			local room = game:GetRoom()
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GRIMACE_ROCK3)
		
			if data.state == "Idle" then
				if mod.IsActiveRoom() then
					data.state = "Bubbling"
				end
				mod:spritePlay(sprite, "Idle")
			elseif data.state == "Bubbling" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				else
					mod:spritePlay(sprite, "Bubble")
				end
				
				if data.StateFrame % 30-math.min(15,math.floor(5*mult)) == 0 then
					local velocity = Vector(0,math.max(0.2, rng:RandomInt(8)/3)):Rotated(rng:RandomInt(360))
					velocity = velocity + player:GetTearMovementInheritance(velocity)
					local bubble = Isaac.Spawn(150, 1, 0, player.Position, velocity, player)
					bubble:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
					bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					bubble:Update()
					bubble:GetSprite():Load("gfx/projectiles/bubble/bubble_tiny_friendly.anm2", true)
					bubble:GetSprite():Play("Idle", true)
					bubble:GetSprite():LoadGraphics()
					bubble.SpriteOffset = e.SpriteOffset+Vector(0,10)
					--bubble.CollisionDamage = 3
				end
			end
		elseif e.SubType == 3 then -- Constant Stone Shooter
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK4 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK4) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock4 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GRIMACE_ROCK4)
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
				local choice = rng:RandomInt(4)
				data.numberDirection = choice
				if choice == 0 then
					data.csdirection = "Down"
				elseif choice == 1 then
					data.csdirection = "Left"
				elseif choice == 2 then
					data.csdirection = "Up"
				else
					data.csdirection = "Right"
				end
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				if mod.IsActiveRoom() then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
					local velocity = Vector(0,8):Rotated(90*data.numberDirection)
					velocity = velocity + player:GetTearMovementInheritance(velocity)
					local tear = Isaac.Spawn(2, 1, 0, player.Position, velocity, player):ToTear()
					tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
					tear.FallingAcceleration = 0.5
					tear.FallingSpeed = -7
					tear.CollisionDamage = player.Damage*mult
					tear:ResetSpriteScale()
				else
					mod:spritePlay(sprite, data.csdirection)
				end
			end
		elseif e.SubType == 4 then -- Broken Gaping Maw
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK5 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK5) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock5 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				if data.StateFrame > 60 and mod.IsActiveRoom() then
					data.state = "Suck"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Suck" then
				if sprite:IsFinished("Suck") then
					data.state = "Idle"
					data.StateFrame = 0
				elseif sprite:IsEventTriggered("StartSuck") then
					sfx:Play(SoundEffect.SOUND_LOW_INHALE, 0.4, 0, false, math.random(20,30)/10)
					data.sucking = true
				elseif sprite:IsEventTriggered("StopSuck") then
					data.sucking = false
				else
					mod:spritePlay(sprite, "Suck")
				end
			end
			
			if data.sucking then
				for _,entity in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)) then
						entity.Velocity = mod:Lerp(entity.Velocity, (player.Position-entity.Position):Resized(5), 0.1)
					end
				end
			end
		elseif e.SubType == 5 then -- Brimstone Head
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK6 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK6) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock4 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GRIMACE_ROCK6)
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
				local choice = rng:RandomInt(4)
				data.numberDirection = choice
				if choice == 0 then
					data.csdirection = "Down"
				elseif choice == 1 then
					data.csdirection = "Left"
				elseif choice == 2 then
					data.csdirection = "Up"
				else
					data.csdirection = "Right"
				end
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				if data.StateFrame > 40 and mod.IsActiveRoom() then
					data.state = "Shoot"
					sprite:Play("Idle", true)
					sprite:Play(data.csdirection, true)
				elseif mod.IsActiveRoom() then
					sprite:SetFrame(data.csdirection, 0)
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				elseif sprite:IsFinished(data.csdirection) then
					data.state = "Idle"
					data.StateFrame = 0
				elseif sprite:IsEventTriggered("BrimStart") then
					local laser = EntityLaser.ShootAngle(1, player.Position, (data.numberDirection+1)*90, 12, Vector(0, -34*player.SpriteScale.Y-(entry+1)*15), player)
					--local laser = Isaac.Spawn(7, 1, 0, player.Position, Vector.Zero, player):ToLaser()
					--laser.Angle = (data.numberDirection+1)*90
					--laser:SetTimeout(12)
					if data.numberDirection == 0 then
						laser.DepthOffset = 500
					end
					laser.CollisionDamage = (player.Damage*0.66)*mult
					laser:GetData().thinLaser = true
					laser.Parent = player
					laser.Size = 8
					laser:Update()
					laser.SpriteScale = Vector(0.5, 0.5)
					sfx:Stop(SoundEffect.SOUND_BLOOD_LASER)
					sfx:Play(SoundEffect.SOUND_BLOOD_LASER_SMALL, 0.8, 0, false, 1.1)
				else
					mod:spritePlay(sprite, data.csdirection)
				end
			end
		elseif e.SubType == 6 then -- Cross Stone Shooter
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK7 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK7) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock7 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				if mod.IsActiveRoom() then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				elseif sprite:IsEventTriggered("Plus") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.45, 0, false, 2)
					for i=90,360,90 do
						local tear = Isaac.Spawn(2, 1, 0, player.Position, Vector(0,8):Rotated(i)+player.Velocity, player):ToTear()
						tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
						tear.FallingAcceleration = 0.2
						tear.FallingSpeed = -2
						tear.CollisionDamage = player.Damage*mult
						tear:ResetSpriteScale()
					end
				elseif sprite:IsEventTriggered("Cross") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.45, 0, false, 2)
					for i=45,315,90 do
						local tear = Isaac.Spawn(2, 1, 0, player.Position, Vector(0,8):Rotated(i)+player.Velocity, player):ToTear()
						tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
						tear.FallingAcceleration = 0.2
						tear.FallingSpeed = -2
						tear.CollisionDamage = player.Damage*mult
						tear:ResetSpriteScale()
					end
				else
					mod:spritePlay(sprite, "Shoot")
				end
			end
		elseif e.SubType == 7 then -- Stone Eye
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK8 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK8) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock8 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				if mod.IsActiveRoom() then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				else
					if not data.laser or (not data.laser:Exists()) then
						data.laser = EntityLaser.ShootAngle(2, player.Position, 90, 999, Vector(0, -34*player.SpriteScale.Y-(entry+1)*15), player)
						data.laser.CollisionDamage = (player.Damage*0.66)*mult
						data.laser.Parent = player
						data.laser.DepthOffset = player.DepthOffset - 10
						data.laser.Mass = 0
						data.laser.IsActiveRotating = true
						data.laser.RotationSpd = 6.9
						data.laser:Update()
					else
						data.laser:SetTimeout(5)
						data.laser.RotationDegrees = 10
						data.laser.IsActiveRotating = true
					end
					mod:spritePlay(sprite, "Eye")
				end
			end
		elseif e.SubType == 8 then -- Cauldron
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK9 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK9) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock9 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GRIMACE_ROCK9)
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
				data.spawnCount = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				if mod.IsActiveRoom() and data.spawnCount < 10 and data.StateFrame > 40+30*data.spawnCount then
					data.state = "Search"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Search" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				else
					local clones = {}
					for _,entity in ipairs(Isaac.FindInRadius(player.Position, 400, EntityPartition.ENEMY)) do
						if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) and not entity:IsBoss() then
							local cloneable = true
							for _,k in ipairs(mod.Cloneless) do
								if k[3] then
									if entity.Type == k[1] and entity.Variant == k[2] and entity.SubType == k[3] then
										cloneable = false
									end
								elseif k[2] then
									if entity.Type == k[1] and entity.Variant == k[2] then
										cloneable = false
									end
								else
									if entity.Type == k[1] then
										cloneable = false
									end
								end
							end
							if cloneable then
								table.insert(clones, entity)
							end
						end
					end
					
					if #clones == 0 then
						data.state = "Idle"
					else
						data.targetClone = clones[rng:RandomInt(#clones)+1]
						data.state = "Cloning"
						data.StateFrame = 0
						mod:spritePlay(sprite, "StartTarget")
					end
				end
			elseif data.state == "Cloning" then
				if data.StateFrame > 35 then
					data.state = "RealClone" --man shut up
				elseif sprite:IsFinished("StartTarget") then
					sprite:Play("Target")
				end
			elseif data.state == "RealClone" then
				if sprite:IsFinished("Duplicate") then
					data.state = "Idle"
					data.StateFrame = 0
				elseif sprite:IsEventTriggered("DropSound") then
					if data.targetClone then
						if not data.targetClone:IsDead() and not mod:isStatusCorpse(data.targetClone) then
							sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.5, 1, false, 2)
							local beam = Isaac.Spawn(1000, 7010, 1, player.Position, Vector.Zero, nil)
							local poof = Isaac.Spawn(1000, 15, 0, player.Position, Vector.Zero, nil):ToEffect()
							poof.Color = Color(2,1,2,1,0,0,0)
							poof:Update()
							local creature = Isaac.Spawn(data.targetClone.Type, data.targetClone.Variant, data.targetClone.SubType, player.Position, Vector.Zero, player):ToNPC()
							creature:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
							creature:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
							creature.HitPoints = creature.HitPoints*0.66*mult
							data.spawnCount = data.spawnCount+1
						end
					end
					data.targetClone = nil
				else
					mod:spritePlay(sprite, "Duplicate")
				end
			end
		elseif e.SubType == 9 then -- Gaping Maw
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK10 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK10) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock10 = nil
				e:Remove()
			end
			
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") or sprite:IsFinished("Appear") then
				sprite:Play("Suck", true)
			end
			
			for _,pickup in ipairs(Isaac.FindByType(5,-1,-1, false, false)) do
				pickup:GetData().grimaceSucked = true
				pickup.Velocity = mod:Lerp(pickup.Velocity, (player.Position-pickup.Position):Resized(4), 0.1)
			end
		elseif e.SubType == 10 then -- Triple Grimace
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK11 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK11) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock11 = nil
				e:Remove()
			end
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
			else
				data.StateFrame = data.StateFrame+1
			end
			
			if data.state == "Idle" then
				data.target = nil
				local radius = 1000
				for _,entity in ipairs(Isaac.FindInRadius(e.Position, 150, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
						if entity.Position:Distance(e.Position) < radius then
							radius = entity.Position:Distance(e.Position)
							data.target = entity
						end
					end
				end
				if data.StateFrame > 20 and data.target then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, "Idle")
				end
			elseif data.state == "Shoot" then
				if not data.target or data.target:IsDead() or mod:isStatusCorpse(data.target) then
					local radius = 1000
					for _,entity in ipairs(Isaac.FindInRadius(e.Position, 1000, EntityPartition.ENEMY)) do
						if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
							if entity.Position:Distance(e.Position) < radius then
								radius = entity.Position:Distance(e.Position)
								data.target = entity
							end
						end
					end
				end
			
				if sprite:IsFinished("Shoot") then
					data.state = "Idle"
					data.StateFrame = 0
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
					for i=-30,30,30 do
						local tear = Isaac.Spawn(2, 1, 0, e.Position, (data.target.Position-e.Position):Resized(8):Rotated(i), e):ToTear()
						tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
						tear.FallingAcceleration = 0.5
						tear.FallingSpeed = -7
						tear.CollisionDamage = player.Damage*mult
						tear:ResetSpriteScale()
					end
				else
					mod:spritePlay(sprite, "Shoot")
				end
			end
		elseif e.SubType == 11 then -- Sensory Grimace
			local entry = 0
			for i=1,#pData.grimaceRockPositions do
				if pData.grimaceRockPositions[i][2] == FiendFolio.ITEM.ROCK.GRIMACE_ROCK12 % 32768 then
					entry = i-1
					e.DepthOffset = 10+entry
					e.SpriteOffset = Vector(0,-28*player.SpriteScale.Y-(entry*10))
					e.SpriteScale = player.SpriteScale
					break
				end
			end
			if not player:HasTrinket(FiendFolio.ITEM.ROCK.GRIMACE_ROCK12) then
				if entry ~= 0 then
					pData.grimaceRockPositions[entry+1][3] = true
				end
				pData.grimaceRock12 = nil
				e:Remove()
			end
			
			local room = game:GetRoom()
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GRIMACE_ROCK12)
			
			if not data.state then
				data.state = "Idle"
				data.StateFrame = 0
				local choice = rng:RandomInt(4)
				data.numberDirection = choice
				if choice == 0 then
					data.csdirection = "Down"
				elseif choice == 1 then
					data.csdirection = "Left"
				elseif choice == 2 then
					data.csdirection = "Up"
				else
					data.csdirection = "Right"
				end
			else
				data.StateFrame = data.StateFrame+1
			end
			
			local reacting = false
			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				local movement = player:GetMovementVector()
					
				if movement.X ~= 0.0 or movement.Y ~= 0.0 then
					local movementAngle = movement:GetAngleDegrees()
				
					local checkingForAngle
					if data.numberDirection == 0 then
						checkingForAngle = 90
					elseif data.numberDirection == 1 then
						checkingForAngle = 180
					elseif data.numberDirection == 2 then
						checkingForAngle = 270
					elseif data.numberDirection == 3 then
						checkingForAngle = 0
					end
						
					if math.abs(movementAngle - checkingForAngle) <= 45.0 or 
					   math.abs((movementAngle + 360) - checkingForAngle) <= 45.0 or
					   math.abs((movementAngle - 360) - checkingForAngle) <= 45.0
					then
						reacting = true
						break
					end
				end
			end
			
			if data.state == "Idle" then
				if mod.IsActiveRoom() and reacting then
					data.state = "Shoot"
				else
					mod:spritePlay(sprite, data.csdirection .. "Idle")
				end
			elseif data.state == "Shoot" then
				if not mod.IsActiveRoom() then
					data.state = "Idle"
				elseif sprite:IsFinished(data.csdirection .. "Fire") then
					if reacting then
						sprite:Play("Idle", true)
						sprite:Play(data.csdirection .. "Fire")
					else
						data.state = "Idle"
					end
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.4, 0, false, 2)
					local velocity = Vector(0,8):Rotated(90*data.numberDirection)
					velocity = velocity + player:GetTearMovementInheritance(velocity)
					local tear = Isaac.Spawn(2, 1, 0, player.Position, velocity, player):ToTear()
					tear.Height = -28*player.SpriteScale.Y-(entry+1)*15
					tear.FallingAcceleration = 0.5
					tear.FallingSpeed = -7
					tear.CollisionDamage = player.Damage*mult
					tear:ResetSpriteScale()
				else
					mod:spritePlay(sprite, data.csdirection .. "Fire")
				end
			end
		end
	else
		e:Remove()
	end
end, 1751)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, trinket)
	local gold = 1
	if trinket.SubType > 32768 then
		gold = 2
	end
	if Isaac.GetChallenge() == mod.challenges.towerOffense then
		gold = 4
	end
	if trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK1 then -- Grimace
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/grimace.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			data.target = nil
			local radius = 1000
			for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 100+50*gold, EntityPartition.ENEMY)) do
				if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
					if entity.Position:Distance(trinket.Position) < radius then
						radius = entity.Position:Distance(trinket.Position)
						data.target = entity
					end
				end
			end
			if data.StateFrame > 20 and data.target then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			if not data.target or data.target:IsDead() or mod:isStatusCorpse(data.target) then
				local radius = 1000
				for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 1000, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
						if entity.Position:Distance(trinket.Position) < radius then
							radius = entity.Position:Distance(trinket.Position)
							data.target = entity
						end
					end
				end
			end
		
			if sprite:IsFinished("Shoot") then
				data.state = "Idle"
				data.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
				local tear = Isaac.Spawn(2, 1, 0, trinket.Position, (data.target.Position-trinket.Position):Resized(6+2*gold), trinket):ToTear()
				tear.Height = -5
				tear.FallingAcceleration = 0.5
				tear.FallingSpeed = -7
				tear.CollisionDamage = 3.5*gold
				tear:ResetSpriteScale()
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK2 then -- Vomit Grimace
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/ipecac.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			data.target = nil
			local radius = 1000
			for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 150+50*gold, EntityPartition.ENEMY)) do
				if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
					if entity.Position:Distance(trinket.Position) < radius then
						radius = entity.Position:Distance(trinket.Position)
						data.target = entity
					end
				end
			end
			if data.StateFrame > 40 and data.target then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			local finding = false
			if not data.target or data.target:IsDead() or mod:isStatusCorpse(data.target) then
				local finding = true
				local radius = 0
				for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 500, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
						if entity.Position:Distance(trinket.Position) > radius then
							radius = entity.Position:Distance(trinket.Position)
							data.target = entity
							local finding = false
						end
					end
				end
			end
			if finding == true then
				data.state = "Idle"
				data.StateFrame = 0
			end
		
			if sprite:IsFinished("Shoot") then
				data.state = "Idle"
				data.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
				local tear = Isaac.Spawn(2, 1, 0, trinket.Position, (data.target.Position-trinket.Position):Resized(6+2*gold), trinket):ToTear()
				tear.Height = -5
				tear.FallingAcceleration = 1.1
				tear.FallingSpeed = -20
				tear.CollisionDamage = 15*gold
				tear:AddTearFlags(TearFlags.TEAR_EXPLOSIVE)
				tear.Color = mod.ColorIpecacProper
				tear:GetData().dontHurtPlayerExplosive = true
				tear:ResetSpriteScale()
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK3 then -- Wetstone
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local room = game:GetRoom()
		local rng = trinket:GetDropRNG()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/wetstone.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			if mod.IsActiveRoom() then
				data.state = "Bubbling"
			end
			mod:spritePlay(sprite, "Idle")
		elseif data.state == "Bubbling" then
			if not mod.IsActiveRoom() then
				data.state = "Idle"
			else
				mod:spritePlay(sprite, "Bubble")
			end
			
			if data.StateFrame % 30-10*gold == 0 then
				local bubble = Isaac.Spawn(150, 1, 0, trinket.Position, Vector(0,math.max(0.2, rng:RandomInt(8)/3)):Rotated(rng:RandomInt(360)), trinket)
				bubble:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
				bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				bubble:Update()
				bubble:GetSprite():Load("gfx/projectiles/bubble/bubble_tiny_friendly.anm2", true)
				bubble:GetSprite():Play("Idle", true)
				bubble:GetSprite():LoadGraphics()
				bubble.SpriteOffset = Vector(0,10)
				--bubble.CollisionDamage = 3
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK4 then -- Constant Stone Shooter
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		
		if not data.csdirection then
			local choice = rng:RandomInt(4)
			data.numberDirection = choice
			if choice == 0 then
				data.csdirection = "Down"
			elseif choice == 1 then
				data.csdirection = "Left"
			elseif choice == 2 then
				data.csdirection = "Up"
			else
				data.csdirection = "Right"
			end
		end
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/constant.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			if mod.IsActiveRoom() then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			if not mod.IsActiveRoom() then
				data.state = "Idle"
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
				local tear = Isaac.Spawn(2, 1, 0, trinket.Position, Vector(0,6+2*gold):Rotated(90*data.numberDirection), trinket):ToTear()
				tear.Height = -5
				tear.FallingAcceleration = 0.5
				tear.FallingSpeed = -7
				tear.CollisionDamage = 3.5*gold
				tear:ResetSpriteScale()
			else
				mod:spritePlay(sprite, data.csdirection)
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK5 then -- Broken Gaping Maw
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/gapingbroken.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
			
		if data.state == "Idle" then
			if data.StateFrame > 30 and mod.IsActiveRoom() then
				data.state = "Suck"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Suck" then
			if sprite:IsFinished("Suck") then
				data.state = "Idle"
				data.StateFrame = 0
			elseif sprite:IsEventTriggered("StartSuck") then
				sfx:Play(SoundEffect.SOUND_LOW_INHALE, 0.4, 0, false, math.random(20,30)/10)
				data.sucking = true
			elseif sprite:IsEventTriggered("StopSuck") then
				data.sucking = false
			else
				mod:spritePlay(sprite, "Suck")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
			
		if data.sucking then
			for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 200, EntityPartition.ENEMY)) do
				if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)) then
					entity.Velocity = mod:Lerp(entity.Velocity, (trinket.Position-entity.Position):Resized(5+4*gold), 0.1)
				end
			end
			for _,proj in ipairs(Isaac.FindByType(9,-1,-1,false,false)) do
				if proj.Position:Distance(trinket.Position) < 180 then
					proj.Velocity = mod:Lerp(proj.Velocity, (trinket.Position-proj.Position):Resized(3+3*gold), 0.1)
				end
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK6 then -- Brimstone Head
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		if not data.csdirection then
			local choice = rng:RandomInt(4)
			data.numberDirection = choice
			if choice == 0 then
				data.csdirection = "Down"
			elseif choice == 1 then
				data.csdirection = "Left"
			elseif choice == 2 then
				data.csdirection = "Up"
			else
				data.csdirection = "Right"
			end
		end
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/brimstone.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			if data.StateFrame > 40 and mod.IsActiveRoom() then
				data.state = "Shoot"
				sprite:Play("Idle", true)
				sprite:Play(data.csdirection, true)
			elseif mod.IsActiveRoom() then
				sprite:SetFrame(data.csdirection, 0)
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			if not mod.IsActiveRoom() then
				data.state = "Idle"
			elseif sprite:IsFinished(data.csdirection) then
				data.state = "Idle"
				data.StateFrame = 0
			elseif sprite:IsEventTriggered("BrimStart") then
				local laser = EntityLaser.ShootAngle(1, trinket.Position, (data.numberDirection+1)*90, 12, Vector(0, -3)+Vector(0,10):Rotated(data.numberDirection*90), Isaac.GetPlayer(0))
				if data.numberDirection == 0 then
					laser.DepthOffset = 500
				end
				laser.CollisionDamage = 3.5*gold
				laser.Parent = trinket
				laser.Size = 8
				laser:Update()
				laser.SpriteScale = Vector(0.5, 0.5)
				sfx:Stop(SoundEffect.SOUND_BLOOD_LASER)
				sfx:Play(SoundEffect.SOUND_BLOOD_LASER_SMALL, 0.8, 0, false, 1.1)
			else
				mod:spritePlay(sprite, data.csdirection)
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK7 then -- Cross Stone Shooter
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/cross.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			if mod.IsActiveRoom() then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			if sprite:IsEventTriggered("Plus") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.45, 0, false, 2)
				for i=90,360,90 do
					local tear = Isaac.Spawn(2, 1, 0, trinket.Position, Vector(0,8):Rotated(i), trinket):ToTear()
					tear.Height = -5
					tear.FallingAcceleration = 0.5
					tear.FallingSpeed = -7
					tear.CollisionDamage = 3.5*gold
					tear:ResetSpriteScale()
				end
			elseif sprite:IsEventTriggered("Cross") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.45, 0, false, 2)
				for i=45,315,90 do
					local tear = Isaac.Spawn(2, 1, 0, trinket.Position, Vector(0,8):Rotated(i), trinket):ToTear()
					tear.Height = -5
					tear.FallingAcceleration = 0.5
					tear.FallingSpeed = -7
					tear.CollisionDamage = 3.5*gold
					tear:ResetSpriteScale()
				end
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK8 then -- Stone Eye
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/eye.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			if mod.IsActiveRoom() then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			if not mod.IsActiveRoom() then
				data.state = "Idle"
			else
				if not data.laser or (not data.laser:Exists()) then
					data.laser = EntityLaser.ShootAngle(2, trinket.Position, 90, 999, Vector(0, -3), Isaac.GetPlayer(0))
					data.laser.CollisionDamage = 3.5*gold
					data.laser.Parent = trinket
					data.laser.Mass = 0
					data.laser.IsActiveRotating = true
					data.laser.RotationSpd = 6.9
					data.laser:Update()
				else
					data.laser:SetTimeout(5)
					data.laser.RotationDegrees = 10
					data.laser.IsActiveRotating = true
				end
				mod:spritePlay(sprite, "Eye")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK9 then -- Cauldron
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/cauldron.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("TrueIdle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
			data.spawnCount = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			if mod.IsActiveRoom() and data.StateFrame > 40+30*data.spawnCount then
				data.state = "Search"
			else
				mod:spritePlay(sprite, "TrueIdle")
			end
		elseif data.state == "Search" then
			if not mod.IsActiveRoom() then
				data.state = "Idle"
			else
				local clones = {}
				for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 400, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) and not entity:IsBoss() then
						local cloneable = true
						for _,k in ipairs(mod.Cloneless) do
							if k[3] then
								if entity.Type == k[1] and entity.Variant == k[2] and entity.SubType == k[3] then
									cloneable = false
								end
							elseif k[2] then
								if entity.Type == k[1] and entity.Variant == k[2] then
									cloneable = false
								end
							else
								if entity.Type == k[1] then
									cloneable = false
								end
							end
						end
						if cloneable then
							table.insert(clones, entity)
						end
					end
				end
					
				if #clones == 0 then
					data.state = "Idle"
				else
					data.targetClone = clones[rng:RandomInt(#clones)+1]
					data.state = "Cloning"
					data.StateFrame = 0
					mod:spritePlay(sprite, "StartTarget")
				end
			end
		elseif data.state == "Cloning" then
			if data.StateFrame > 35 then
				data.state = "RealClone" --man shut up
			elseif sprite:IsFinished("StartTarget") then
				sprite:Play("Target")
			end
		elseif data.state == "RealClone" then
			if sprite:IsFinished("Duplicate") then
				data.state = "Idle"
				data.StateFrame = 0
			elseif sprite:IsEventTriggered("DropSound") then
				if data.targetClone then
					if not data.targetClone:IsDead() and not mod:isStatusCorpse(data.targetClone) then
						sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.5, 1, false, 2)
						local beam = Isaac.Spawn(1000, 7010, 1, trinket.Position, Vector.Zero, nil)
						local poof = Isaac.Spawn(1000, 15, 0, trinket.Position, Vector.Zero, nil):ToEffect()
						poof.Color = Color(2,1,2,1,0,0,0)
						poof:Update()
						local creature = Isaac.Spawn(data.targetClone.Type, data.targetClone.Variant, data.targetClone.SubType, trinket.Position, Vector.Zero, trinket):ToNPC()
						creature:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
						creature:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						creature.HitPoints = creature.HitPoints*0.66*gold
						data.spawnCount = data.spawnCount+1
					end
				end
				data.targetClone = nil
			else
				mod:spritePlay(sprite, "Duplicate")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK10 then -- Gaping Maw
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/gaping.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
			else
				sprite:Play("Suck", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
		end
		
		if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") or sprite:IsFinished("Appear") then
			sprite:Play("Suck", true)
		end
		
		if trinket.Touched then
			for _,pickup in ipairs(Isaac.FindByType(5,-1,-1, false, false)) do
				if pickup.Type == 5 and pickup.Variant == 350 and pickup.SubType == FiendFolio.ITEM.ROCK.GRIMACE_ROCK10 then
				else
					pickup:GetData().grimaceSucked = true
				end
				if pickup.Position:Distance(trinket.Position) > 30 then
					pickup.Velocity = mod:Lerp(pickup.Velocity, (trinket.Position-pickup.Position):Resized(4), 0.1)
				end
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK11 then -- Triple Grimace
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/trimace.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
		
		if data.state == "Idle" then
			data.target = nil
			local radius = 1000
			for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 100+50*gold, EntityPartition.ENEMY)) do
				if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
					if entity.Position:Distance(trinket.Position) < radius then
						radius = entity.Position:Distance(trinket.Position)
						data.target = entity
					end
				end
			end
			if data.StateFrame > 20 and data.target then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif data.state == "Shoot" then
			if not data.target or data.target:IsDead() or mod:isStatusCorpse(data.target) then
				local radius = 1000
				for _,entity in ipairs(Isaac.FindInRadius(trinket.Position, 1000, EntityPartition.ENEMY)) do
					if entity:IsVulnerableEnemy() and (not mod:isFriend(entity)) then
						if entity.Position:Distance(trinket.Position) < radius then
							radius = entity.Position:Distance(trinket.Position)
							data.target = entity
						end
					end
				end
			end
		
			if sprite:IsFinished("Shoot") then
				data.state = "Idle"
				data.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.6, 0, false, 2)
				for i=-30,30,30 do
					local tear = Isaac.Spawn(2, 1, 0, trinket.Position, (data.target.Position-trinket.Position):Resized(6+2*gold):Rotated(i), trinket):ToTear()
					tear.Height = -5
					tear.FallingAcceleration = 0.5
					tear.FallingSpeed = -7
					tear.CollisionDamage = 3.5*gold
					tear:ResetSpriteScale()
				end
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.StateFrame = 0
			end
		end
	elseif trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.GRIMACE_ROCK12 then -- Sensory Grimace
		local sprite = trinket:GetSprite()
		local data = trinket:GetData()
		local rng = trinket:GetDropRNG()
		local room = game:GetRoom()
		local gold = 1
		if trinket.SubType > 32768 then
			gold = 2
		end
		if not data.csdirection then
			local choice = rng:RandomInt(4)
			data.numberDirection = choice
			if choice == 0 then
				data.csdirection = "Down"
			elseif choice == 1 then
				data.csdirection = "Left"
			elseif choice == 2 then
				data.csdirection = "Up"
			else
				data.csdirection = "Right"
			end
		end
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/grimace/sensoryTEMP.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
			end
			sprite:LoadGraphics()
			sprite:Update()
			data.StateFrame = 0
		else
			data.StateFrame = data.StateFrame+1
		end
	
		local reacting = false
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			local movement = player:GetMovementVector()
				
			if movement.X ~= 0.0 or movement.Y ~= 0.0 then
				local movementAngle = movement:GetAngleDegrees()
				
				local checkingForAngle
				if data.numberDirection == 0 then
					checkingForAngle = 90
				elseif data.numberDirection == 1 then
					checkingForAngle = 180
				elseif data.numberDirection == 2 then
					checkingForAngle = 270
				elseif data.numberDirection == 3 then
					checkingForAngle = 0
				end
						
				if math.abs(movementAngle - checkingForAngle) <= 45.0 or 
				   math.abs((movementAngle + 360) - checkingForAngle) <= 45.0 or
				   math.abs((movementAngle - 360) - checkingForAngle) <= 45.0
				then
					reacting = true
					break
				end
			end
		end
			
		if data.state == "Idle" then
			if mod.IsActiveRoom() and reacting then
				data.state = "Shoot"
			else
				mod:spritePlay(sprite, data.csdirection .. "Idle")
			end
		elseif data.state == "Shoot" then
			if not mod.IsActiveRoom() then
				data.state = "Idle"
			elseif sprite:IsFinished(data.csdirection .. "Fire") then
				if reacting then
					sprite:Play("Idle", true)
					sprite:Play(data.csdirection .. "Fire")
				else
					data.state = "Idle"
				end
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 0.4, 0, false, 2)
				local velocity = Vector(0,6+2*gold):Rotated(90*data.numberDirection)
				local tear = Isaac.Spawn(2, 1, 0, trinket.Position, velocity, trinket):ToTear()
				tear.Height = -5
				tear.FallingAcceleration = 0.5
				tear.FallingSpeed = -7
				tear.CollisionDamage = 3.5*gold
				tear:ResetSpriteScale()
			else
				mod:spritePlay(sprite, data.csdirection .. "Fire")
			end
		end
	end
	
	if Isaac.GetChallenge() == mod.challenges.towerOffense then
		if not mod.isGrimaceRock(trinket.SubType) then
			trinket:Morph(5, 0, 2, true, true, false)
		end
	end
end, PickupVariant.PICKUP_TRINKET)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup) --why is the grid collision so weird
	local data = pickup:GetData()
	if data.grimaceSucked then
		pickup.GridCollisionClass = 3
		--[[local notDropped = false
		for _,grim in ipairs(Isaac.FindByType(1000,1751,-1,false,false)) do
			if grim.SubType == 4 or grim.SubType == 9 then
				notDropped = true
			end
		end
		for _,grim in ipairs(Isaac.FindByType(5,350,-1,false,false)) do
			if grim.SubType == FiendFolio.ITEM.ROCK.GRIMACE_ROCK5 % 32768 or grim.SubType == FiendFolio.ITEM.ROCK.GRIMACE_ROCK10 % 32768 then
				notDropped = true
			end
		end
		if notDropped == false then
			pickup.GridCollisionClass = 5
			data.grimaceSucked = nil
		end]]
	end
end)

function mod:blockExplosiveTearDamage(player, damage, flag, source)
	if source and source.Type == 2 then
		if source.Entity:GetData().dontHurtPlayerExplosive == true then
			return false
		end
	end
end