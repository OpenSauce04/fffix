local mod = FiendFolio
local game = Game()

local catchMiniboss = false
local returnIndex

local gravediggerRooms = StageAPI.RoomsList("FFGravediggerRooms", include("resources.luarooms.miniboss_gravedigger"))
local psionRooms = StageAPI.RoomsList("FFPsionRooms", include("resources.luarooms.miniboss_psion"))

function mod.GetExpectedMinibossDisplayFlags()
	local level = game:GetLevel()
	local flags = RoomDescriptor.DISPLAY_NONE

	if level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT) then flags = RoomDescriptor.DISPLAY_BOX end
	if level:GetStateFlag(LevelStateFlag.STATE_COMPASS_EFFECT) then flags = RoomDescriptor.DISPLAY_ALL end
	if level:GetStateFlag(LevelStateFlag.STATE_FULL_MAP_EFFECT) then flags = RoomDescriptor.DISPLAY_ALL end

	return flags
end

local function IsRoomDeadEnd(index)
	local level = game:GetLevel()
	local connections = 0

	for _, shift in pairs({1, -1, 13, -13}) do
		local desc = level:GetRoomByIdx(index + shift)
		if desc.Data and desc.Data.Type ~= RoomType.ROOM_SECRET then
			connections = connections + 1
		end
	end

	return connections == 1
end

local function GetRoomToOverride(rng)
	local level = game:GetLevel()
	local roomsList = level:GetRooms()

	local minibossIndex
	local deadEndIndexes = {}

	for i = 0, #roomsList - 1 do
		local desc = roomsList:Get(i)
		if desc.Data.Type == RoomType.ROOM_MINIBOSS then
			minibossIndex = desc.SafeGridIndex
			break
		elseif desc.Data.Shape == RoomShape.ROOMSHAPE_1x1 and desc.Data.Type == RoomType.ROOM_DEFAULT then
			if IsRoomDeadEnd(desc.SafeGridIndex) then
				table.insert(deadEndIndexes, desc.SafeGridIndex)
			end
		end
	end

	if minibossIndex then
		return minibossIndex
	else
		return deadEndIndexes[rng:RandomInt(#deadEndIndexes) + 1]
	end
end

local function MakeChapter5Miniboss(roomsList, rng)
	local rng = rng or RNG()
	local level = game:GetLevel()
	local toOverride = GetRoomToOverride(rng)
	local overwriteDesc = level:GetRoomByIdx(toOverride)
	local newData = StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_MINIBOSS, RoomShape.ROOMSHAPE_1x1)

	overwriteDesc.Data = newData
	overwriteDesc.DisplayFlags = (overwriteDesc.DisplayFlags & ~ overwriteDesc.DisplayFlags) | mod.GetExpectedMinibossDisplayFlags() -- God don't you just love wonky mutability
	overwriteDesc.SurpriseMiniboss = overwriteDesc.SurpriseMiniboss or not overwriteDesc.SurpriseMiniboss
	overwriteDesc.Flags = overwriteDesc.Flags & ~ overwriteDesc.Flags

	local minibossRoom = StageAPI.LevelRoom{
		RoomType = RoomType.ROOM_DEFAULT,
		RequireRoomType = false,
		RoomsList = roomsList,
		RoomDescriptor = overwriteDesc
	}
	StageAPI.SetLevelRoom(minibossRoom, overwriteDesc.ListIndex)

	level:UpdateVisibility()
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	local level = game:GetLevel()
	mod.savedata.psionGravediggerPayedOut = false

	if level:GetStage() == LevelStage.STAGE5 and not BasementRenovator then
		local rng = RNG()
		rng:SetSeed(level:GetDungeonPlacementSeed(), 35)

		if level:GetStageType() == StageType.STAGETYPE_WOTL then
			MakeChapter5Miniboss(gravediggerRooms, rng)
		else
			MakeChapter5Miniboss(psionRooms, rng)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_MINIBOSS then
		if Isaac.CountEntities(nil, mod.FF.Gravedigger.ID, mod.FF.Gravedigger.Var) > 0 then
			local hud = game:GetHUD()
			hud:ShowItemText(Isaac.GetPlayer():GetName() .. " vs gravedigger", "", false)
		elseif Isaac.CountEntities(nil, mod.FF.Psion.ID, mod.FF.Psion.Var) > 0 then
			local hud = game:GetHUD()
			hud:ShowItemText(Isaac.GetPlayer():GetName() .. " vs psion", "", false)
		end
	end
end)

StageAPI.AddCallback("FiendFolio", "POST_ROOM_LOAD", 1, function(currentRoom)
	if game:GetRoom():GetType() == RoomType.ROOM_MINIBOSS and Isaac.CountEntities(nil, mod.FF.Psion.ID, mod.FF.Psion.Var) > 0 then
		currentRoom.Data.RoomGfx = mod.RiskRewardBackdrop
	end
end)

local function canMinibossPayout()
	local room = game:GetRoom()
	return (
		room:GetFrameCount() > 0 and
		room:GetType() == RoomType.ROOM_MINIBOSS and
		game.Challenge ~= mod.challenges.theGauntlet
	)
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, npc)
	if npc.Variant == mod.FF.Gravedigger.Var and canMinibossPayout() then
		local dropRNG = npc:GetDropRNG()
		local room = game:GetRoom()
		local position = room:FindFreePickupSpawnPosition(npc.Position)

		if not mod.ACHIEVEMENT.BLACK_LANTERN:IsUnlocked(true) then
			mod.ACHIEVEMENT.BLACK_LANTERN:Unlock()
		end

		if not mod.savedata.psionGravediggerPayedOut then
			if dropRNG:RandomFloat() < 0.5 then
				Isaac.Spawn(5, 10, 3, position, Vector.Zero, npc)
			else
				local itempool = game:GetItemPool()
				local item = itempool:GetCollectible(ItemPoolType.POOL_ANGEL, true, dropRNG:GetSeed())
				Isaac.Spawn(5, 100, item, position, Vector.Zero, npc)
			end
		end

		mod.savedata.psionGravediggerPayedOut = true
	end
end, mod.FF.Gravedigger.ID)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, npc)
	if npc.Variant == mod.FF.Psion.Var and canMinibossPayout() then
		local dropRNG = npc:GetDropRNG()
		local room = game:GetRoom()
		local position = room:FindFreePickupSpawnPosition(npc.Position)

		if not mod.ACHIEVEMENT.RISKS_REWARD:IsUnlocked(true) then
			mod.ACHIEVEMENT.RISKS_REWARD:Unlock()
		end
		
		if not mod.savedata.psionGravediggerPayedOut then
			if dropRNG:RandomFloat() < 0.5 then
				Isaac.Spawn(5, 10, 6, position, Vector.Zero, npc)
			else
				local itempool = game:GetItemPool()
				local item = itempool:GetCollectible(ItemPoolType.POOL_DEVIL, true, dropRNG:GetSeed())
				Isaac.Spawn(5, 100, item, position, Vector.Zero, npc)
			end
		end

		mod.savedata.psionGravediggerPayedOut = true
	end
end, mod.FF.Psion.ID)