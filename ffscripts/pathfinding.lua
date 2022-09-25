FiendFolio.PathMaps = {}

local game = Game()

--[[

PathMaps (altered / simplified version of the system I wrote for rev)

FiendFolio.MyPathMap = FiendFolio.NewPathMapFromTable("MyPathMap", {
    GetTargetSets = function, -- Function must return a table of tables {{Targets = {index, index}}, {Targets = {index}}}
                                 These are used as the center point of the pathfinding map that all values will radiate from
                                 Separate sets allow for entities targeting different indices to use the same path map

                                 This function is called constantly, and Path Maps are re-evaluated once a second or when Targets change.

    GetCollisions = function, -- Function returns a table of index value pairs {[index] = number}
                                 When a path map is updated, the index is looked up in this table. If it exists,
                                 it counts as a collision.

                                 When the path map is evaluated, collisions will still be pathfound through,
                                 but will have their value increased by the number specified. This allows making entities
                                 get as close as possible, even when they can't fully reach the player, as well as
                                 increasing the cost of certain routes relative to others. GetPathToZero will avoid anything over 10000.

    GetValidPositions = function, -- Function returns a table of index value pairs {[index] = true}
                                     When a path map is updated, the index is looked up in this table. If not true,
                                     it cannot be pathfound through whatsoever.

    OnPathUpdate = function, -- Function passes (PathMap).
                                PathMap.TargetMapSets is a table of tables {{Targets = {index, index}, Map = map}}
                                In this function, you should locate the associated map for each entity
                                by comparing Targets, then use the Map as the second argument in FiendFolio.GetPathToZero.

                                PathMap also contains
                                PathMap.Collisions
                                PathMap.ValidPositions
                                PathMap.Collisions
                                equal to the return values of the above functions
})

FiendFolio.GetPathToZero(startIndex, map, width, collisionMap)
-- only startIndex and map are necessary, but collisionMap allows you to clarify exactly the path you want your entity to be able to take
-- collisionMap needs to be a table with any Collisions or ValidPositions table
-- width is automatically obtained from the room if not given
-- returns a path table of indices you should move through, in order start to end

FiendFolio.FollowPath(entity, speed, path, useDirect, friction)
-- Moves entity from index to index in path (entity.Velocity = entity.Velocity * friction + (nextIndexPos - currentPos):Resized(speed))
-- If useDirect is true, then the entity will move toward the index before the first index that it can't perform a line check toward
]]

function FiendFolio.NewPathMapFromTable(name, tbl)
    FiendFolio.PathMaps[name] = {
        TargetMapSets = {},
        Name = name,

        GetTargetSets = tbl.GetTargetSets,
        GetCollisions = tbl.GetCollisions,
        GetValidPositions = tbl.GetValidPositions,
        OnPathUpdate = tbl.OnPathUpdate,
        NoAutoUpdate = tbl.NoAutoUpdate,
        OnlyUpdateIf = tbl.OnlyUpdateIf,
        Width = tbl.Width
    }
    return FiendFolio.PathMaps[name]
end

function FiendFolio.RenderPathMap(map)
    if map.TargetMapSets[1] then
        for index, value in pairs(map.TargetMapSets[1].Map) do
            local pos = Isaac.WorldToScreen(game:GetRoom():GetGridPosition(index))
            local text = tostring(value)
            pos = Vector(pos.X - Isaac.GetTextWidth(text) / 2, pos.Y)
            Isaac.RenderText(text, pos.X, pos.Y, 1, 1, 1, 1)
        end
    end
end

function FiendFolio.RadiateMapGeneration(targets, collisions, validPositions, width)
    local map = {}
    local checkIndices = {}

    local farthestIndex = targets[1]
    for _, index in ipairs(targets) do
        if (not collisions or not collisions[index] or collisions[index] < 10000) and (not validPositions or validPositions[index]) then
            map[index] = 0
            checkIndices[#checkIndices + 1] = index
        end
    end

    while #checkIndices > 0 do
        for i = #checkIndices, 1, -1 do
            local index = checkIndices[i]
            table.remove(checkIndices, i)
            local adjacentIndices = {
                index + 1,
                index - 1,
                index + width,
                index - width
            }

            for _, adjacent in ipairs(adjacentIndices) do
                local isValid = not validPositions or validPositions[adjacent]
                if isValid then
                    local moveCost = (collisions and collisions[adjacent]) or 1
                    if moveCost == 0 then
                        moveCost = 1
                    end

                    if (not map[adjacent] or map[adjacent] > map[index] + moveCost) then
                        map[adjacent] = map[index] + moveCost

                        if not (map[adjacent] and map[farthestIndex]) then
                            error("pathfinding error, nil map indices: " .. (type(map[adjacent]) .. ";" .. type(map[farthestIndex])) .. (debug and "\n"..debug.traceback() or ""))
                        end

                        if not map[farthestIndex] or map[adjacent] > map[farthestIndex] then
                            farthestIndex = adjacent
                        end

                        checkIndices[#checkIndices + 1] = adjacent
                    end
                end
            end
        end
    end

    return map, farthestIndex
end

function FiendFolio.UpdatePathMap(map, force)
    local oldTargetSets = map.TargetMapSets

    local targetSets

    if map.GetTargetSets then
        targetSets = map.GetTargetSets()
    else
        targetSets = {}
    end

    if #targetSets < 1 then
        map.TargetMapSets = {}
        return
    end

    local setsNeedingUpdating = {}
    if not force then
        local verifiedA, verifiedB = {}, {}
        local matchingTables = 0
        for i, table in ipairs(targetSets) do
            if not verifiedA[i] then
                for i2, table2 in ipairs(oldTargetSets) do
                    if not verifiedB[i2] then
                        local matches = true
                        for _, v in ipairs(table.Targets) do
                            local hasV
                            for _, v2 in ipairs(table2.Targets) do
                                if v == v2 then
                                    hasV = true
                                    break
                                end
                            end

                            if not hasV then
                                matches = false
                                break
                            end
                        end

                        if matches then
                            verifiedA[i] = i2
                            verifiedB[i2] = i

                            matchingTables = matchingTables + 1
                        end
                    end
                end
            end

            if verifiedA[i] and table.Force then
                setsNeedingUpdating[#setsNeedingUpdating + 1] = table
            elseif verifiedA[i] then
                table.Map = oldTargetSets[verifiedA[i]].Map
            end
        end

        if matchingTables ~= #targetSets then
            for i, table in ipairs(targetSets) do
                if not verifiedA[i] then
                    setsNeedingUpdating[#setsNeedingUpdating + 1] = table
                end
            end
        end
    else
        setsNeedingUpdating = targetSets
    end

    if #setsNeedingUpdating > 0 or force then
        local width = map.Width or game:GetRoom():GetGridWidth()

        local collisions
        if map.GetCollisions then
            collisions = map.GetCollisions()
        end

        local validPositions
        if map.GetValidPositions then
            validPositions = map.GetValidPositions()
        end

        for _, set in ipairs(setsNeedingUpdating) do
            set.Map, set.FarthestIndex = FiendFolio.RadiateMapGeneration(set.Targets, collisions, validPositions, width)
        end

        map.Collisions = collisions
        map.ValidPositions = validPositions
        map.TargetMapSets = targetSets

        if map.OnPathUpdate then
            if map.GetTargetIndices and not map.GetTargetSets then
                map.OnPathUpdate(map)
            else
                map.OnPathUpdate(map)
            end
        end
    end
end

function FiendFolio.DoesMapIndexCollide(map, index)
    local collides = map.Collisions and map.Collisions[index] and map.Collisions[index] >= 10000
    local isInvalid = map.ValidPositions and not map.ValidPositions[index]
    return collides or isInvalid
end

function FiendFolio.GetPathToZero(start, map, width, collisionMap)
    width = width or game:GetRoom():GetGridWidth()
    local checkIndices = {
        start + 1,
        start - 1,
        start + width,
        start - width
    }

    local path = {}
    local minimum
    while #checkIndices > 0 do
        local nextIndex
        for _, ind in ipairs(checkIndices) do
            if map[ind] and (not minimum or map[ind] < minimum) and (not collisionMap or not FiendFolio.DoesMapIndexCollide(collisionMap, ind)) then
                minimum = map[ind]
                nextIndex = ind
            end
        end

        if nextIndex then
            path[#path + 1] = nextIndex
            if minimum == 0 then
                return path, true
            end

            checkIndices = {
                nextIndex + 1,
                nextIndex - 1,
                nextIndex + width,
                nextIndex - width
            }
        else
            if #path == 0 then
                return nil, false
            else
                return path, false
            end
        end
    end
end

FiendFolio:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for name, v in pairs(FiendFolio.PathMaps) do
        if not v.NoAutoUpdate or (v.OnlyUpdateIf and v.OnlyUpdateIf()) then
            FiendFolio.UpdatePathMap(v, game:GetFrameCount() % 30 == 0)
        end
    end
end)

function FiendFolio.GetMinimumTargetSets(entities)
    local sets = {}
    local individualTargets = {}
    for _, ent in ipairs(entities) do
        local data = ent:GetData()
        if data.TargetIndices then
            local shouldAdd = true
            for _, set in ipairs(sets) do
                if #set.Targets == #data.TargetIndices then
                    local matching = 0
                    for _, index in ipairs(data.TargetIndices) do
                        for _, index2 in ipairs(set.Targets) do
                            if index == index2 then
                                matching = matching + 1
                                break
                            end
                        end
                    end

                    if matching == #data.TargetIndices then
                        shouldAdd = false
                        break
                    end
                end
            end

            if shouldAdd then
                sets[#sets + 1] = {Targets = data.TargetIndices}
            end
        else
            local targetIndex = data.TargetIndex or game:GetRoom():GetGridIndex(ent:ToNPC():GetPlayerTarget().Position)
            if not individualTargets[targetIndex] then
                sets[#sets + 1] = {Targets = {targetIndex}}
                individualTargets[targetIndex] = true
            end
        end
    end

    return sets
end

function FiendFolio.GetTargetSetMatchingEntity(entity, sets, data)
    data = data or entity:GetData()

    local targetSet = data.TargetIndices
    if not targetSet then
        targetSet = {data.TargetIndex or game:GetRoom():GetGridIndex(entity:ToNPC():GetPlayerTarget().Position)}
    end

    local matchingSet
    for _, set in ipairs(sets) do
        if #set.Targets == #targetSet then
            local matching = 0
            for _, index in ipairs(set.Targets) do
                for _, index2 in ipairs(targetSet) do
                    if index == index2 then
                        matching = matching + 1
                        break
                    end
                end
            end

            if matching == #targetSet then
                matchingSet = set
                break
            end
        end
    end

    if matchingSet then
        return matchingSet
    end
end

function FiendFolio.GetInsideGrids()
    local insideGrids = {}
    local room = game:GetRoom()
    for i = 0, room:GetGridSize() do
        if room:IsPositionInRoom(room:GetGridPosition(i), 0) then
            insideGrids[i] = true
        end
    end

    return insideGrids
end

FiendFolio.GenericChaserPathMap = FiendFolio.NewPathMapFromTable("GenericChaserPathMap", { -- Manages generic chaser enemy movement
    GetTargetSets = function()
        local chaserEnemies = {}
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            local data = ent:GetData()
            if data.UseFFPlayerMap then
                chaserEnemies[#chaserEnemies + 1] = ent
            end
        end

        return FiendFolio.GetMinimumTargetSets(chaserEnemies)
    end,
    GetCollisions = function()
        local collisions = {}
        local room = game:GetRoom()
        for i = 0, room:GetGridSize() do
            local path = room:GetGridPath(i)
            local grid = room:GetGridEntity(i)
            if path >= 950 and
            (not grid or grid.Desc.Type ~= GridEntityType.GRID_TELEPORTER) then -- fire places 950, spikes & teleporters 999
                collisions[i] = 10000
            else
                collisions[i] = path
            end
        end

        return collisions
    end,
    GetValidPositions = function()
        return FiendFolio.GetInsideGrids()
    end,
    OnPathUpdate = function(map)
        local sets = map.TargetMapSets
        local room = game:GetRoom()
        local width = room:GetGridWidth()
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            local data = ent:GetData()
            if data.UseFFPlayerMap then
                local matchingSet = FiendFolio.GetTargetSetMatchingEntity(ent, sets, data)
                if matchingSet then
                    if data.OnPathUpdate then
                        data.OnPathUpdate(matchingSet, ent, map)
                    else
                        data.Path = nil
                        data.PathIndex = nil
                        local path, isComplete = FiendFolio.GetPathToZero(room:GetGridIndex(ent.Position), matchingSet.Map, width, map)
                        if isComplete or data.UseIncompleteMap then
                            data.Path = path
                        end
                    end
                end
            end
        end
    end
})

FiendFolio.GenericFlyingChaserPathMap = FiendFolio.NewPathMapFromTable("GenericFlyingChaserPathMap", { -- Flying chasers collide with walls, fires, spike rocks, and tall rocks, so they still need pathfinding
    GetTargetSets = function()
        local chaserEnemies = {}
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            local data = ent:GetData()
            if data.UseFFPlayerFlyingMap then
                chaserEnemies[#chaserEnemies + 1] = ent
            end
        end

        return FiendFolio.GetMinimumTargetSets(chaserEnemies)
    end,
    GetCollisions = function()
        local collisions = {}
        local room = game:GetRoom()
        for i = 0, room:GetGridSize() do
            local path = room:GetGridPath(i)
            local collision = room:GetGridCollision(i)
            local grid = room:GetGridEntity(i)
            if path == 950 or collision == GridCollisionClass.COLLISION_WALL or collision == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER or (grid and grid.Desc.Type == GridEntityType.GRID_ROCK_SPIKED) then
                collisions[i] = 10000
            elseif path <= 900 then
                collisions[i] = path
            end
        end

        return collisions
    end,
    GetValidPositions = function()
        return FiendFolio.GetInsideGrids()
    end,
    OnPathUpdate = function(map)
        local sets = map.TargetMapSets
        local room = game:GetRoom()
        local width = room:GetGridWidth()
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            local data = ent:GetData()
            if data.UseFFPlayerFlyingMap then
                local matchingSet = FiendFolio.GetTargetSetMatchingEntity(ent, sets, data)
                if matchingSet then
                    if data.OnPathUpdate then
                        data.OnPathUpdate(matchingSet, ent, map)
                    else
                        data.Path = nil
                        data.PathIndex = nil
                        local path, isComplete = FiendFolio.GetPathToZero(room:GetGridIndex(ent.Position), matchingSet.Map, width, map)
                        if isComplete or data.UseIncompleteMap then
                            data.Path = path
                        end
                    end
                end
            end
        end
    end
})

function FiendFolio.FollowPath(entity, speed, path, useDirect, friction, pathThreshold)
	local data = entity:GetData()
    local room = game:GetRoom()
    if not data.PathIndex then
        data.PathIndex = 1
    end

	if useDirect then
		local pathIndex
		for i = #path, data.PathIndex, -1 do
            local index = path[i]
            if room:CheckLine(entity.Position, room:GetGridPosition(index), 0, pathThreshold or 949) then
                pathIndex = i
                break
            end
		end

        if pathIndex then
    		data.PathIndex = pathIndex
        end
	end

	local index = path[data.PathIndex]
    local currentIndex = room:GetGridIndex(entity.Position)
    local hitNextPos
	if index == currentIndex then
        hitNextPos = true

		data.PathIndex = data.PathIndex + 1
		if data.PathIndex > #path then
            data.PathIndex = #path
            return hitNextPos
		end

		index = path[data.PathIndex]
	end

    if not index then
        error("Tried to follow nil index in path: pathIndex = " .. tostring(data.PathIndex) .. "\n" .. debug.traceback())
    end

    local pos = room:GetGridPosition(index)

    friction = friction or entity.Friction
	entity.Velocity = entity.Velocity * friction + (pos - entity.Position):Resized(speed)

    return hitNextPos
end
