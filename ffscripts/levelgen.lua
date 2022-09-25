local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    if StageAPI.InNewStage() then return end

    local level = game:GetLevel()
    if level:GetStageType() == StageType.STAGETYPE_AFTERBIRTH and level:GetStage() >= 3 and level:GetStage() <= 4 then
        for i = 0, level:GetRooms().Size - 1 do
            local roomDesc = level:GetRooms():Get(i)
            if roomDesc.Data.Type == RoomType.ROOM_CHALLENGE then
                local dimension = StageAPI.GetDimension(roomDesc)
                local overwritableRoomDesc = level:GetRoomByIdx(roomDesc.SafeGridIndex, dimension)
                overwritableRoomDesc.Flags = overwritableRoomDesc.Flags | RoomDescriptor.FLAG_FLOODED
            end
        end
    end
end)
