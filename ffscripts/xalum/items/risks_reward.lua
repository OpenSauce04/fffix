local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local risksReward = CollectibleType.COLLECTIBLE_RISKS_REWARD
local costumeID = Isaac.GetCostumeIdByPath("gfx/characters/risks_reward.anm2")

local startingIndexes = {0, 12, 156, 168}
local generationDoors = {
	[0] = {0, DoorSlot.RIGHT0, 1, DoorSlot.DOWN0, 14},
	[12] = {12, DoorSlot.DOWN0, 25, DoorSlot.LEFT0, 24},
	[156] = {156, DoorSlot.UP0, 143, DoorSlot.RIGHT0, 144},
	[168] = {168, DoorSlot.LEFT0, 167, DoorSlot.UP0, 154},
}
local testIndexes = {
	[0] = {2, 15, 26, 27},
	[12] = {10, 23, 37, 38},
	[156] = {130, 131, 145, 158},
	[168] = {141, 142, 153, 166},
}

local psionicClusterRooms = StageAPI.RoomsList("FFRiskRewardRooms", include("resources.luarooms.risksreward"))
local teleportingThroughPsionicPortal

function mod.IsRoomIndexInPsionicCluster(index)
	return mod.savedata and mod.savedata.risksRewardIndexData[tostring(index)]
end

function mod.IsInPsionicCluster()
	return mod.IsRoomIndexInPsionicCluster(game:GetLevel():GetCurrentRoomDesc().GridIndex)
end

local function ShouldRisksRewardBeCharged(player)
	local room = game:GetRoom()

	return (
		room:GetType() == RoomType.ROOM_TREASURE and
		not room:IsMirrorWorld() and
		Isaac.CountEntities(nil, 5, 100) > 0 and
		Isaac.CountEntities(nil, 5, 100, 0) == 0 and
		Isaac.CountEntities(nil, mod.FF.PsionicPortal.ID, mod.FF.PsionicPortal.Var, mod.FF.PsionicPortal.Sub) == 0 and
		not mod.IsInPsionicCluster()
	)
end

local function GetPsionicClusterStartPosition(rng)
	local level = game:GetLevel()
	local valids = {0, 12, 156, 168}
	local choice

	repeat
		local roll = rng:RandomInt(#valids) + 1
		local index = valids[roll]
		local pass = true

		for i = 1, 4 do
			local desc = level:GetRoomByIdx(testIndexes[index][i])
			if desc.SafeGridIndex ~= -1 then
				-- print(testIndexes[index][i] .. " AKA " .. desc.SafeGridIndex .. " has failed")

				pass = false
				break
			end
		end

		if pass then
			choice = index
		end

		table.remove(valids, roll)
	until choice or #valids == 0

	-- print(choice)

	return choice
end

local function GeneratePsionicCluster(rng)
	local generationStartIndex = GetPsionicClusterStartPosition(rng)

	local level = game:GetLevel()
	local initRoomMade = level:MakeRedRoomDoor(generationDoors[generationStartIndex][3], (generationDoors[generationStartIndex][2] + 2) % 4)

	if not initRoomMade then
		return
	end

	local psionicIndexes = mod.savedata.risksRewardIndexData
	for i = 1, 5, 2 do
		psionicIndexes[tostring(generationDoors[generationStartIndex][i])] = true -- Stringify index to avoid huge json tables with empty entries that fucking hate reloading correctly back into lua
	end
	psionicIndexes.Treasure = level:GetCurrentRoomIndex()
	psionicIndexes.Entrance = generationDoors[generationStartIndex][1]
	psionicIndexes.Goal = generationDoors[generationStartIndex][5]
	mod.savedata.risksRewardIndexData = psionicIndexes

	local emptyData = StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_DEFAULT, RoomShape.ROOMSHAPE_1x1)
	local desc = level:GetRoomByIdx(generationStartIndex)
	desc.Data = emptyData
	desc.Flags = desc.Flags & ~ desc.Flags

	local entranceRoom = StageAPI.LevelRoom{
		RoomType = RoomType.ROOM_MINIBOSS,
		RequireRoomType = true,
		RoomsList = psionicClusterRooms,
		RoomDescriptor = desc
	}
	StageAPI.SetLevelRoom(entranceRoom, desc.ListIndex)

	local newDesc
	for i = 2, 4, 2 do
		level:MakeRedRoomDoor(generationDoors[generationStartIndex][i - 1], generationDoors[generationStartIndex][i])
		newDesc = level:GetRoomByIdx(generationDoors[generationStartIndex][i + 1])
		newDesc.Data = emptyData
		newDesc.Flags = newDesc.Flags & ~ newDesc.Flags
		newDesc.Clear = newDesc.Clear and not newDesc.Clear

		local roomType = RoomType.ROOM_DEFAULT
		if psionicIndexes.Goal == newDesc.GridIndex then
			roomType = RoomType.ROOM_TREASURE
		end

		local newRoom = StageAPI.LevelRoom{
			RoomType = roomType,
			RequireRoomType = true,
			RoomsList = psionicClusterRooms,
			RoomDescriptor = newDesc
		}
		StageAPI.SetLevelRoom(newRoom, newDesc.ListIndex)
	end

	local treasureData = StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_TREASURE, RoomShape.ROOMSHAPE_1x1)
	newDesc.Data = treasureData

	return true
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:HasCollectible(risksReward) then
		local itemSlot = ActiveSlot.SLOT_PRIMARY
		for i = 1, 3 do
			if player:GetActiveItem(i) == risksReward then
				itemSlot = i
				break
			end
		end

		if ShouldRisksRewardBeCharged(player) then
			player:FullCharge(itemSlot, true)
		else
			player:SetActiveCharge(0, itemSlot)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, flags)
	if flags & UseFlag.USE_CARBATTERY == 0 and ShouldRisksRewardBeCharged(player) then
		local highestItemQuality = 0
		local madeCluster = GeneratePsionicCluster(rng)

		if madeCluster then
			for _, pickup in pairs(Isaac.FindByType(5, 100)) do
				if pickup.SubType > 0 then
					local portal = Isaac.Spawn(1000, mod.FF.PsionicPortal.Var, mod.FF.PsionicPortal.Sub, pickup.Position, Vector.Zero, nil)
					mod.MakeEntityPersistent(portal, true)
					pickup:Remove()

					sfx:Play(SoundEffect.SOUND_POT_BREAK)

					local itemConfig = Isaac.GetItemConfig()
					local configItem = itemConfig:GetCollectible(pickup.SubType)
					highestItemQuality = math.max(highestItemQuality, configItem.Quality)

					local itemEffect = Isaac.Spawn(1000, mod.FF.PortalCollectible.Var, mod.FF.PortalCollectible.Sub, pickup.Position, RandomVector() * 30, portal)
					local sprite = itemEffect:GetSprite()
					sprite:ReplaceSpritesheet(0, configItem.GfxFileName)
					sprite:LoadGraphics()

					local data = itemEffect:GetData()
					data.offsetVelocity = Vector(0, -10)
					itemEffect.SpriteOffset = Vector(0, -16)

					for i = 1, 4 do
						Isaac.Spawn(1000, 4, 1, pickup.Position, RandomVector() * 3, nil)
					end
				end
			end

			mod.savedata.risksRewardItemRollQuality = math.min(4, highestItemQuality + 1)
		else
			game:GetHUD():ShowFortuneText("no valid cluster", "generation site.", "sorry!")
		end
			
		player:AddNullCostume(costumeID)
		return true
	end
end, risksReward)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == mod.FF.PsionicPortal.Sub then
		local psionicIndexes = mod.savedata.risksRewardIndexData
		local sprite = effect:GetSprite()
		local data = effect:GetData()

		if sprite:IsFinished("Appear") then
			sprite:Play("Opened")
		end

		if psionicIndexes.Treasure and psionicIndexes.Entrance then
			if sprite:IsPlaying("Opened") and not data.trappedPlayer then
				local closeEnough
				mod.AnyPlayerDo(function(player)
					if effect.Position:Distance(player.Position) <= player.Size + 20 then
						closeEnough = player
						return true
					end
				end)

				if closeEnough then
					data.trappedPlayer = closeEnough
					closeEnough:AnimateTrapdoor()
					closeEnough.ControlsEnabled = false
					closeEnough.EntityCollisionClass = 0
				end
			end

			if data.trappedPlayer then
				local player = data.trappedPlayer
				local targetVelocity = (effect.Position - player.Position)
				player.Velocity = mod.XalumLerp(player.Velocity, targetVelocity, 0.1)

				if player:GetSprite():GetFrame() >= 14 then
					player.ControlsEnabled = true
					player:StopExtraAnimation()

					
					if mod.IsInPsionicCluster() then
						game:StartRoomTransition(psionicIndexes.Treasure or game:GetLevel():GetStartingRoomIndex(), -1, RoomTransitionAnim.PORTAL_TELEPORT)
						teleportingThroughPsionicPortal = true
					else
						game:StartRoomTransition(psionicIndexes.Entrance, -1, RoomTransitionAnim.PORTAL_TELEPORT)
						teleportingThroughPsionicPortal = true
					end

					player.EntityCollisionClass = 4
				end
			end
		end
	end
end, mod.FF.PsionicPortal.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	if effect.SubType == mod.FF.PortalCollectible.Sub and effect:Exists() then
		if not effect.SpawnerEntity then
			effect:Remove()
			return
		end

		effect.SpriteRotation = effect.FrameCount * 30

		local data = effect:GetData()
		effect.SpriteOffset = effect.SpriteOffset + data.offsetVelocity

		local targetVelocity = effect.SpawnerEntity.Position - effect.Position
		local targetOffsetVelocity = Vector.Zero - effect.SpriteOffset

		effect.Velocity = mod.XalumLerp(effect.Velocity, targetVelocity, 0.05)
		data.offsetVelocity = mod.XalumLerp(data.offsetVelocity, targetOffsetVelocity, 0.05)

		if effect.Position:Distance(effect.SpawnerEntity.Position) < 2.5 and effect.SpriteOffset:Length() < 2.5 then
			effect:Remove()
		end
	end
end, mod.FF.PortalCollectible.Var)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if teleportingThroughPsionicPortal then
		teleportingThroughPsionicPortal = false
		local room = game:GetRoom()
		local targetPosition = room:GetCenterPos()

		local portals = Isaac.FindByType(1000, mod.FF.PsionicPortal.Var, mod.FF.PsionicPortal.Sub)
		if #portals > 0 then targetPosition = portals[1].Position end

		for _, player in pairs(Isaac.FindByType(1)) do
			local player = player:ToPlayer()
			player.Position = room:FindFreePickupSpawnPosition(targetPosition, 40, true, false)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if mod.IsInPsionicCluster() then
		local room = game:GetRoom()
		for i = 0, 3 do
			local door = room:GetDoor(i)
			if door then
				local sprite = door:GetSprite()
				if sprite:GetFilename() == "gfx/grid/risksreward_door.anm2" then
					if sprite:IsFinished("Open") then
						sprite:Play("Opened")
					end

					if door:IsLocked() then
						door:SetLocked(false)
						sprite:Play("Open")
					end
				end
			end
		end
	end
end)

StageAPI.AddCallback("FiendFolio", "POST_ROOM_LOAD", 1, function(currentRoom)
	if mod.IsInPsionicCluster() then
		currentRoom.Data.RoomGfx = mod.RiskRewardBackdrop
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	if mod.savedata then
		mod.savedata.risksRewardIndexData = {}
	end

	mod.AnyPlayerDo(function(player)
		player:TryRemoveNullCostume(costumeID)
	end)
end)