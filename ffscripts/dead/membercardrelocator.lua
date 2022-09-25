local mod = FiendFolio
local game = Game()

function mod:memberCardRelocatorAI(npc)
	if not npc:Exists() then
		return
	end

	local room = game:GetRoom()
	local hasMemberCard
	local index = room:GetGridIndex(npc.Position)
	for i = 0, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		if grid and grid.Desc.Type == GridEntityType.GRID_STAIRS and grid.Desc.Variant == 2 and i ~= index then
			hasMemberCard = true
			room:RemoveGridEntity(i, 0, false)
		end
	end

	if hasMemberCard then
		Isaac.GridSpawn(GridEntityType.GRID_STAIRS, 2, npc.Position, true)
	end

    local ladders = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 0, false, false)
    for _, ladder in ipairs(ladders) do
        ladder.Position = npc.Position
    end

	npc:Remove()
end

function mod:memberCardRelocatorNewRoom()
    local room = game:GetRoom()
    if room:GetType() == RoomType.ROOM_SHOP then
        local desc = game:GetLevel():GetCurrentRoomDesc()

        local hasRelocator, relocatorPosition
        StageAPI.ForAllSpawnEntries(desc.Data, function(entry, spawn)
            if entry.Type == mod.FF.MemberCardRelocator.ID and entry.Variant == mod.FF.MemberCardRelocator.Var then
                hasRelocator = true
                relocatorPosition = StageAPI.VectorToGrid(spawn.X, spawn.Y)
                return true
            end
        end)

        if hasRelocator then
            local grid = room:GetGridEntity(25) -- default member card location
            if grid and grid.Desc.Type == GridEntityType.GRID_STAIRS and grid.Desc.Variant == 2 then
                room:RemoveGridEntity(25, 0, false)
            end

            local ladders = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 0, false, false)
            for _, ladder in ipairs(ladders) do
                ladder.Position = room:GetGridPosition(relocatorPosition)
            end

            if #ladders > 0 then
                for i = 0, game:GetNumPlayers() - 1 do
                    Isaac.GetPlayer(i).Position = ladders[1].Position
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.memberCardRelocatorNewRoom)