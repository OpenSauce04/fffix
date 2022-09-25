local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local conjoinedCard = mod.ITEM.TRINKET.CONJOINED_CARD

local catchMiniboss
local returnIndex

local normalSinsIndexes = { -- Trimmed to remove blocked doors & irregular shapes
	2000, 2001, 2002, 		-- Wrath
	2010, 2011, 2012, 2013, -- Gluttony
	2020, 2021, 2022, 2023,	-- Lust
	2030, 2031, 2032,		-- Sloth
	2040, 2041, 2042, 2043,	-- Greed
	2050, 2051, 2052,		-- Envy
	2060, 2061, 2062,		-- Pride
}

local superSinsIndexes = {
	2100, 2101, 2102, 2104,			-- Super Wrath
	2110, 2111, 2112, 2113,			-- Super Gluttony
	2120, 2121, 2122, 2123, 2124,	-- Super Lust
	2130, 2131, 2132, 2133, 2134,	-- Super Sloth
	2140, 2141, 2142, 2144,			-- Super Greed
	2150, 2151, 2152, 2154,			-- Super Envy (Super Envy doesn't even HAVE a 2153 room????)
	2160, 2161, 2162, 2163, 2164,	-- Super Pride

	2260, 2261, 2262,				-- Ultra Pride
}

local allSinsIndexes = {}
for _, index in pairs(normalSinsIndexes) do table.insert(allSinsIndexes, index) end
for _, index in pairs(superSinsIndexes) do table.insert(allSinsIndexes, index) end

local function CanConjoinedCardTrigger()
	local level = game:GetLevel()
	local levelStage = level:GetStage()

	return (
		game.Difficulty < Difficulty.DIFFICULTY_GREED and
		levelStage ~= LevelStage.STAGE4_3 and
		levelStage < LevelStage.STAGE7 and
		not game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) and
		not BasementRenovator
	)
end

function mod.DoesRoomIdBorderUltraSecretRoom(roomGridIndex)
	local level = game:GetLevel()
	for _, offset in pairs({1, -1, 13, -13}) do
		local roomDesc = level:GetRoomByIdx(roomGridIndex + offset)
		if roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_ULTRASECRET then
			return true
		end
	end

	return false
end

local function GetSinIndex(rng)
	local level = game:GetLevel()
	local sinSet = level:GetStage() >= LevelStage.STAGE2_1 and superSinsIndexes or normalSinsIndexes
	return sinSet[rng:RandomInt(#sinSet) + 1]
end

local function GetIdealSeeders()
	local output = {}
	local level = game:GetLevel()
	local roomsList = level:GetRooms()

	for i = 0, #roomsList - 1 do
		local room = roomsList:Get(i)
		if room.Data.Type == RoomType.ROOM_DEFAULT then
			table.insert(output, room)
		end
	end

	return output
end

local function GetSpecialSeeders()
	local output = {}
	local level = game:GetLevel()
	local roomsList = level:GetRooms()

	for i = 0, #roomsList - 1 do
		local room = roomsList:Get(i)
		if room.Data.Type ~= RoomType.ROOM_BOSS and room.Data.Type ~= RoomType.ROOM_SUPERSECRET and room.Data.Type ~= RoomType.ROOM_ULTRASECRET then
			table.insert(output, room)
		end
	end

	return output
end

local function GetNumRoomConnections(index, ignoreSpecialRooms)
	local level = game:GetLevel()
	local connections = 0

	for _, shift in pairs({1, -1, 13, -13}) do
		local desc = level:GetRoomByIdx(index + shift)
		if desc.Data then
			if desc.Data.Type == RoomType.ROOM_ULTRASECRET then
				connections = connections + 999
			else
				if desc.Data.Type == RoomType.ROOM_DEFAULT then
					connections = connections + 1
				elseif desc.Data.Type ~= RoomType.ROOM_SECRET and not ignoreSpecialRooms then
					connections = connections + 999
				end
			end
		end
	end

	return connections
end

-- Ideal Spawning Conditions
--[[
	- Adjacent to Default roomtype
	- Adjacent to only 1 room (excluding secret rooms)
]]

local function GetIndexSlotPairs(maxConnections, permitSpecialRooms, useExpandedRoomSet, useUnlimitedRoomSet)
	local rooms = useExpandedRoomSet and (useUnlimitedRoomSet and game:GetLevel():GetRooms() or GetSpecialSeeders()) or GetIdealSeeders()
	local output = {}

	for _, roomDesc in pairs(rooms) do
		for slot = 0, 7 do
			if roomDesc.Data.Doors & (1 << slot) > 0 and mod.CanDoorSlotMakeRedRoom(slot, roomDesc.SafeGridIndex) then
				local targetIndex = mod.GetTargetRoomIndex(slot, roomDesc.SafeGridIndex)

				if GetNumRoomConnections(targetIndex, permitSpecialRooms) <= maxConnections then
					table.insert(output, {roomDesc.SafeGridIndex, slot})
				end
			end
		end
	end

	return output
end

local searchConditions = {
	{1},						-- Adjacent to only 1 Default room, ignores Secret rooms
	{4},						-- Adjacent to n Default rooms, ignores Secret rooms
	{4, true},					-- Adjacent at least one Default room & n Special rooms, excludes SS/US Rooms & Boss Rooms, ignores Secret rooms
	{4, true, true},			-- Adjacent to n Special rooms, excludes SS/US Rooms & Boss Rooms, ignores Secret rooms
	{9e9, true, true, true},	-- Adjacent to any room
}

local function MakeNewMinibossRoom(rng)
	local rng = rng or Isaac.GetPlayer():GetTrinketRNG(conjoinedCard)
	local level = game:GetLevel()
	local numRooms = #level:GetRooms()
	local usedData

	for i = 1, #searchConditions do
		local roomSet = GetIndexSlotPairs(table.unpack(searchConditions[i]))
		while #roomSet > 0 do
			local roll = rng:RandomInt(#roomSet) + 1
			local chosen = roomSet[roll]
			local passed = level:MakeRedRoomDoor(chosen[1], chosen[2])

			if passed then
				usedData = chosen
				goto exit
			else
				table.remove(roomSet, roll)
			end
		end
	end

	::exit::

	if not usedData then -- Failed to make a room
		return
	end

	local roomsList = level:GetRooms()
	local newRoom = roomsList:Get(#roomsList - 1)
	newRoom = level:GetRoomByIdx(newRoom.SafeGridIndex)

	returnIndex = returnIndex or level:GetCurrentRoomIndex()
	catchMiniboss = true

	local donorIndex = GetSinIndex(rng)
	Isaac.ExecuteCommand("goto s.miniboss." .. donorIndex)
	local gotoDesc = level:GetRoomByIdx(-3)

	newRoom.Data = gotoDesc.Data
	newRoom.Flags = gotoDesc.Flags
	newRoom.SurpriseMiniboss = gotoDesc.SurpriseMiniboss
	newRoom.DisplayFlags = (gotoDesc.DisplayFlags & ~ gotoDesc.DisplayFlags) | mod.GetExpectedMinibossDisplayFlags() -- God don't you just love wonky mutability

	level:UpdateVisibility()
	sfx:Stop(SoundEffect.SOUND_UNLOCK00)
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	local multiplier = mod.GetGlobalTrinketMultiplier(conjoinedCard)
	returnIndex = nil

	if multiplier > 0 and CanConjoinedCardTrigger() then
		for i = 1, multiplier do
			MakeNewMinibossRoom(Isaac.GetPlayer():GetTrinketRNG(conjoinedCard))
		end

		-- Isaac.GetPlayer():AddCollectible(CollectibleType.COLLECTIBLE_MIND) -- Testing Guff
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if catchMiniboss then -- This is unnecesssary for normal gameplay, but is needed if you enter a new floor through the console or call reseed
		catchMiniboss = false
		local level = game:GetLevel()
		local roomDesc = level:GetCurrentRoomDesc()

		if roomDesc.GridIndex == -3 then
			game:ChangeRoom(returnIndex)
		end
	end
end)