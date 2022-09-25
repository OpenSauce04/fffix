local mod = FiendFolio
local game = Game()

local function RoomGridIdToVector(roomId)
	return Vector(roomId % 13, math.floor(roomId / 13))
end

local function VectorToRoomGridId(vector)
	local row = vector.Y
	local column = vector.X
	local index = row * 13 + column
	return math.floor(index + 0.5)
end

local function GetSlotVectorShift(slot)
	local pureSlot = slot % 4
	local angle = -180 + 90 * pureSlot
	return Vector.FromAngle(angle)
end

local function IsRoomGridVectorInBounds(vector)
	return (
		vector.X >= 0 and
		vector.X <= 12 and
		vector.Y >= 0 and
		vector.Y <= 12
	)
end

local function GetSlotRoomGridIndex(slot, roomIndex)
	local level = game:GetLevel()
	local roomDesc = level:GetRoomByIdx(roomIndex)

	if not roomDesc.Data then
		return roomIndex
	end

	local roomShape = roomDesc.Data.Shape
	local roomVector = RoomGridIdToVector(roomIndex)

	local x = 0
	local y = 0

	local Shape = {
		TriTopLeft 		= roomShape == RoomShape.ROOMSHAPE_LTL,
		TriBottomLeft	= roomShape == RoomShape.ROOMSHAPE_LBL,
		TriTopRight		= roomShape == RoomShape.ROOMSHAPE_LTR,
		TriBottomRight	= roomShape == RoomShape.ROOMSHAPE_LBR,

		IsWide			= roomShape >= RoomShape.ROOMSHAPE_2x1,
		IsTall			= roomShape >= RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_IIV,
	}

	if slot == DoorSlot.LEFT1 then
		y = y + 1

		if Shape.TriTopLeft then
			x = x - 1
		elseif Shape.TriBottomLeft then
			x = x + 1
		end
	elseif slot == DoorSlot.RIGHT0 then
		if Shape.IsWide and not (Shape.TriTopRight or Shape.TriTopLeft) then
			x = x + 1
		end
	elseif slot == DoorSlot.RIGHT1 then
		y = y + 1

		if Shape.IsWide and not (Shape.TriTopLeft or Shape.TriBottomRight) then
			x = x + 1
		end
	elseif slot == DoorSlot.UP0 then
		if Shape.TriTopLeft then
			y = y + 1
			x = x - 1
		end
	elseif slot == DoorSlot.UP1 then
		if Shape.TriTopRight then
			y = y + 1
		end

		if not Shape.TriTopLeft then
			x = x + 1
		end
	elseif slot == DoorSlot.DOWN0 then
		if Shape.IsTall and not Shape.TriBottomLeft then
			y = y + 1
		end

		if Shape.TriTopLeft then
			x = x - 1
		end
	elseif slot == DoorSlot.DOWN1 then
		if not Shape.TriTopLeft then
			x = x + 1
		end

		if Shape.IsTall then
			y = y + 1
		end
	end

	local returnVector = roomVector + Vector(x, y)
	return VectorToRoomGridId(returnVector)
end

local function CanRoomConnectToId(targetIndex, roomIndex)
	local level = game:GetLevel()
	local testRoom = level:GetRoomByIdx(roomIndex)

	for slot = 0, 7 do
		if testRoom.Data.Doors & (1 << slot) > 0 then
			local gridIndex = GetSlotRoomGridIndex(slot, roomIndex)
			local testRoomPosition = RoomGridIdToVector(gridIndex)
			local queryPosition = testRoomPosition + GetSlotVectorShift(slot)
			local queryIndex = VectorToRoomGridId(queryPosition)

			if queryIndex == targetIndex then
				return true
			end
		end
	end

	return false
end

local function CanRedRoomGenerateAtIndex(index)
	local level = game:GetLevel()

	for slot = 0, 3 do
		local testTargetIndex = mod.GetTargetRoomIndex(slot, index)
		local testTargetDesc = level:GetRoomByIdx(testTargetIndex)

		if testTargetDesc.Data and not CanRoomConnectToId(index, testTargetDesc.SafeGridIndex) then
			return false
		end
	end

	return true
end

-- These functions are exposed due to their utility
function mod.GetTargetRoomIndex(slot, roomIndex)
	local slotIndex = GetSlotRoomGridIndex(slot, roomIndex)
	local slotPosition = RoomGridIdToVector(slotIndex)
	local roomPosition = slotPosition + GetSlotVectorShift(slot)

	return VectorToRoomGridId(roomPosition)
end

function mod.WouldSlotLeadOutOfBounds(slot, roomIndex)
	local slotIndex = GetSlotRoomGridIndex(slot, roomIndex)
	local slotPosition = RoomGridIdToVector(slotIndex)
	local roomPosition = slotPosition + GetSlotVectorShift(slot)

	return not IsRoomGridVectorInBounds(roomPosition)
end

function mod.CanDoorSlotMakeRedRoom(slot, roomIndex)
	local level = game:GetLevel()
	roomIndex = roomIndex or level:GetCurrentRoomDesc().SafeGridIndex

	local roomDesc = level:GetRoomByIdx(roomIndex)
	local targetIndex = mod.GetTargetRoomIndex(slot, roomIndex)
	local targetDesc = level:GetRoomByIdx(targetIndex)

	return (
		not targetDesc.Data and
		roomDesc.Data.Doors & (1 << slot) > 0 and
		not mod.WouldSlotLeadOutOfBounds(slot, roomIndex) and
		CanRedRoomGenerateAtIndex(targetIndex)
	)
end

-- Testing
--[[mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomDesc = level:GetCurrentRoomDesc()

	local closest = 0
	local distance = 9e9

	for slot = 0, 7 do
		if roomDesc.Data.Doors & (1 << slot) > 0 then
			local doorDist = room:GetDoorSlotPosition(slot):Distance(player.Position)
			if doorDist < distance then
				closest = slot
				distance = doorDist
			end
		end
	end

	print(closest, mod.CanDoorSlotMakeRedRoom(closest))
end)]]