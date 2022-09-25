local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

FiendFolio.GuwahDirections = {"Left", "Right", "Up", "Down"} --Strings isn't probably the "right" way of doing things but it makes things alot more readable and easier to grasp
FiendFolio.WallStickerOffset = Vector(-20,-20) --Standardized offset for traveling along the "grid-edges", sets you to the top left corner of a grid
local wallStickOffset = FiendFolio.WallStickerOffset

function mod:GetAdjacentIndex(index, direction) --Gets a bordering index using directional input, the bread and butter of this entire system
    local room = game:GetRoom()
    if index then --Lots of safety measures to make sure you arent getting an index outside of the room boundries (one that doesn't exist lol)
        if index <= room:GetGridSize() - 1 then
            if direction == "Left" then
                if index % room:GetGridWidth() == 0 then
                    return index
                else
                    return index - 1
                end
            elseif direction == "Right" then
                if index % room:GetGridWidth() == room:GetGridWidth() - 1 then
                    return index
                else
                    return index + 1
                end
            elseif direction == "Up" then
                if index < room:GetGridWidth() then
                    return index
                else
                    return index - room:GetGridWidth()
                end
            elseif direction == "Down" then
                if index > room:GetGridSize() - room:GetGridWidth() then
                    return index
                else
                    return index + room:GetGridWidth()
                end
            else
                error("Invalid direction input in GetAdjacentIndex")
            end
        else
            return index --You fucked up i guess? lol?
        end
    end
end

function mod:GetGridDirection(length, direction) --Returns a Vector based on direction input, probably useful for something
    if direction == "Left" then
        return Vector(-1,0):Resized(length)
    elseif direction == "Right" then
        return Vector(1,0):Resized(length)
    elseif direction == "Up" then
        return Vector(0,-1):Resized(length)
    elseif direction == "Down" then
        return Vector(0,1):Resized(length)
    else
        error("Invalid direction input in GetGridDirection")
    end
end

function mod:RotateDirection(direction, isCounterclockwise) --Rotate a direction clockwise or counterclockwise, very important
    if isCounterclockwise then
        if direction == "Left" then
            return "Down"
        elseif direction == "Right" then
            return "Up"
        elseif direction == "Up" then
            return "Left"
        elseif direction == "Down" then
            return "Right"
        else
            error("Invalid direction input in RotateDirection")
        end
    else
        if direction == "Left" then
            return "Up"
        elseif direction == "Right" then
            return "Down"
        elseif direction == "Up" then
            return "Right"
        elseif direction == "Down" then
            return "Left"
        else
            error("Invalid direction input in RotateDirection")
        end
    end
end

function mod:ReverseDirection(direction) --Less typing compared to using RotateDirection() twice
    if direction == "Left" then
        return "Right"
    elseif direction == "Right" then
        return "Left"
    elseif direction == "Up" then
        return "Down"
    elseif direction == "Down" then
        return "Up"
    else
        error("Invalid direction input in ReverseDirection")
    end
end

function mod:GetOrientationFromVector(vec) --Ideal for translating standard vector into WallMovement initialization params (Discy's discs use this)
    local dir
    local cc
    if math.abs(vec.X) > math.abs(vec.Y) then
        if vec.X < 0 then
            dir = "Left"
            cc = (vec.Y > 0)
        else
            dir = "Right"
            cc = (vec.Y < 0)
        end
    else
        if vec.Y < 0 then
            dir = "Up"
            cc = (vec.X < 0)
        else
            dir = "Down"
            cc = (vec.X > 0)
        end
    end
    return dir, cc --Returns a direction string and clockwise/counter-clockwise boolean, pass these as arguments into one of the Init functions
end

--[[Arguments:
    npc - duh
    startDirection - directional string for the.... starting direction
    isCounterclockwise - which way do you want to rotate?
    gridthreshold - what GridCollisionClass do you want to count as a solid tile to traverse around?
    snapspeed - the speed at which the npc will "snap onto" the axis, since stuff needs to be grid aligned but isnt garunteed to start off that way
]]

function mod:WallHuggerInit(npc, startDirection, isCounterclockwise, gridthreshold, snapspeed)
    npc:GetData().WallHuggerData = {}
    local data = npc:GetData().WallHuggerData
    local room = game:GetRoom()
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    data.Index = room:GetGridIndex(npc.Position)
    data.Dir = startDirection
    data.CC = isCounterclockwise
    data.GridThreshold = gridthreshold
    data.StartPos = npc.Position
    data.TargetPos = room:GetGridPosition(data.Index)
    data.Timestep = math.floor((data.TargetPos - data.StartPos):Length()/snapspeed)
    data.Vec = (data.TargetPos - data.StartPos)/data.Timestep
    data.Timer = data.Timestep
    data.WallHuggerInit = true
end

-- timestep = how many frames to move between each index/grid?
function mod:WallHuggerMovement(npc, timestep)
    local data = npc:GetData().WallHuggerData
    if timestep then
        data.Timestep = timestep
    end
    if data.WallHuggerInit then
        local room = game:GetRoom()
        local gridthreshold = data.GridThreshold
        if data.Timer <= 0 then
            if data.TargetIndex then
                data.Index = data.TargetIndex
            end
            local imStuck = false
            local tryTurn = false
            local indextable, colltable = mod:GetWallHuggerIndexes(data.Index, gridthreshold) --indextable is for debugging, colltable is what we actually need for making movement choices
            local B,C,D,F,H,I = mod:AssignIndexesFromDir(data.Dir, "WallHugger") --Sorry if these variable names arent useful, I referenced them off a paint.net sketch I made lol
            if colltable[B] and colltable[D] and colltable[H] and colltable[F] then --If all 4 tiles are filled, get stuck idiot
                imStuck = true
            elseif colltable[D] then --Running into a wall, gotta turn somewhere else
                if colltable[H] and colltable[B] then --If you cant turn, double back!
                    data.Dir = mod:ReverseDirection(data.Dir)
                elseif colltable[B] then --Pick this way?
                    data.Dir = mod:RotateDirection(data.Dir, true) 
                elseif colltable[H] then --Or the other?
                    data.Dir = mod:RotateDirection(data.Dir, false) 
                else --Otherwise, pick your preference of left or right
                    tryTurn = true
                end
            end
            if tryTurn or not colltable[D] then --If not tile infront of you, try going forward
                if colltable[C] and data.CC and not colltable[B] then --Check for outside turn
                    data.Dir = mod:RotateDirection(data.Dir, false)
                    tryTurn = false
                elseif colltable[I] and not data.CC and not colltable[H] then --Check for outside turn again, otherwise maintain direction
                    data.Dir = mod:RotateDirection(data.Dir, true)
                    tryTurn = false
                end
            end
            if tryTurn then --Outside turns have a certain priority and can override a previous selective turn
                data.Dir = mod:RotateDirection(data.Dir, data.CC)
            end
            data.StartPos = npc.Position
            if imStuck then
                data.TargetIndex = data.Index
                data.Vec = Vector.Zero
                data.Timer = 5 --If trapped in one tile, try checking for an escape every 5 frames
            else
                data.TargetIndex = mod:GetAdjacentIndex(data.Index, data.Dir)
                data.Vec = (data.TargetPos - data.StartPos)/data.Timestep
                data.Timer = data.Timestep
            end
            data.TargetPos = room:GetGridPosition(data.TargetIndex)
        end
        npc.Velocity = data.Vec
        mod.NegateKnockoutDrops(npc)
        data.Timer = data.Timer - 1
    else
        error("WallHuggerInit needed to use WallHuggerMovement")
    end
end

function mod:GetWallHuggerIndexes(index, gridthreshold) --Get 3*3 grid of indexes for WallHugging movement
    local room = game:GetRoom()
    local upindex = mod:GetAdjacentIndex(index, "Up")
    local downindex = mod:GetAdjacentIndex(index, "Down")
    local indextable = {[1] = mod:GetAdjacentIndex(upindex, "Left"), 
                        [2] = upindex, 
                        [3] = mod:GetAdjacentIndex(upindex, "Right"), 
                        [4] = mod:GetAdjacentIndex(index, "Left"), 
                        [5] = index, 
                        [6] = mod:GetAdjacentIndex(index, "Right"), 
                        [7] = mod:GetAdjacentIndex(downindex, "Left"), 
                        [8] = downindex, 
                        [9] = mod:GetAdjacentIndex(downindex, "Right"), 
                        }
    local colltable = {}
    for i, iudex in pairs(indextable) do
        local isSolid = room:GetGridCollision(iudex) > gridthreshold 
        if not isSolid then
            local gridpath = mod:GetGridPath(iudex)
            if gridpath >= 0 and gridthreshold <= GridCollisionClass.COLLISION_SOLID then --Agony
                if gridthreshold == GridCollisionClass.COLLISION_NONE then
                    isSolid = (gridpath >= 1000)
                else
                    isSolid = (gridpath >= 1000 and gridpath ~= 3000) --Pits use GridPath 3000 so i have to check for them manually yayyyy
                end
            end
        end
        colltable[i] = isSolid
    end
    return indextable, colltable
end

function mod:AssignIndexesFromDir(dir, mode) --"Rotate" grid of indexes depending on the direction traveled, this allows logic to be shared regardless of direction
    if mode == "WallHugger" then --Manually = easy
        if dir == "Right" then
            return 8,7,6,4,2,1
        elseif dir == "Down" then
            return 4,1,8,2,6,3
        elseif dir == "Left" then
            return 2,3,4,6,8,9
        else --Up
            return 6,9,2,8,4,7 --Five never even gets used lol!
        end
    elseif mode == "WallSticker" then
        if dir == "Right" then
            return 1,2,3,4
        elseif dir == "Down" then
            return 2,4,1,3
        elseif dir == "Left" then
            return 4,3,2,1
        else --Up
            return 3,1,4,2
        end
    end
end

--extra argument: forceIndex, lets you brute-force your starting grid selection. not sure why you would use this, you probably shouldn't

function mod:WallStickerInit(npc, startDirection, isCounterclockwise, gridthreshold, snapspeed, forceindex)
    npc:GetData().WallStickerData = {}
    local data = npc:GetData().WallStickerData
    local room = game:GetRoom()
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    if forceindex then
        data.Index = mod:GetClosestWallStickIndex(npc.Position, gridthreshold)
    else
        data.Index = room:GetGridIndex(npc.Position)
    end
    data.Dir = startDirection
    data.CC = isCounterclockwise
    data.GridThreshold = gridthreshold
    data.StartPos = npc.Position
    data.TargetPos = room:GetGridPosition(data.Index) + wallStickOffset
    data.Timestep = math.floor((data.TargetPos - data.StartPos):Length()/snapspeed)
    data.Vec = (data.TargetPos - data.StartPos)/data.Timestep
    data.Timer = data.Timestep
    data.WallStickerInit = true
end

function mod:WallStickerMovement(npc, timestep) --Not going to give a play-by-play here since its just a simpler version of WallHugger logic-wise (2*2 vs 3*3)
    local data = npc:GetData().WallStickerData
    if timestep then
        data.Timestep = timestep
    end
    if data.WallStickerInit then
        local room = game:GetRoom()
        local gridthreshold = data.GridThreshold
        if data.Timer <= 0 then
            if data.TargetIndex then
                data.Index = data.TargetIndex
            end
            local indextable, colltable = mod:GetWallStickerIndexes(data.Index, gridthreshold) 
            local A,B,C,D = mod:AssignIndexesFromDir(data.Dir, "WallSticker") --Letters so magic they would make Zamiel cry
            if colltable[B] and colltable[D] then
                if colltable[A] then
                    data.Dir = mod:RotateDirection(data.Dir, false)
                elseif colltable[C]then
                    data.Dir = mod:RotateDirection(data.Dir, true)
                else
                    data.Dir = mod:RotateDirection(data.Dir, data.CC)
                end
            elseif colltable[B] or colltable[D] then
                if colltable[A] and colltable[D] then
                    data.Dir = mod:RotateDirection(data.Dir, false)
                elseif colltable[B] and colltable[C] then
                    data.Dir = mod:RotateDirection(data.Dir, true)
                end
            else
                if colltable[A] then
                    data.Dir = mod:RotateDirection(data.Dir, true)
                elseif colltable[C] then
                    data.Dir = mod:RotateDirection(data.Dir, false)
                end
            end
            data.TargetIndex = mod:GetAdjacentIndex(data.Index, data.Dir)
            data.StartPos = npc.Position
            data.TargetPos = room:GetGridPosition(data.TargetIndex) + wallStickOffset
            data.Vec = (data.TargetPos - data.StartPos)/data.Timestep
            data.Timer = data.Timestep
        end
        npc.Velocity = data.Vec
        mod.NegateKnockoutDrops(npc)
        data.Timer = data.Timer - 1
    else
        error("WallStickerInit needed to use WallStickerMovement")
    end
end

function mod:GetClosestWallStickIndex(position, gridthreshold) --Get closest point centered between four grids for starting WallStick movement
    local room = game:GetRoom()
    local index = room:GetGridIndex(position)
    local downindex = mod:GetAdjacentIndex(index, "Down")
    local indextable = {[1] = index, [2] = mod:GetAdjacentIndex(index, "Right"), [3] = downindex, [4] = mod:GetAdjacentIndex(downindex, "Right")}
    local postable = {}
    for _, iudex in pairs(indextable) do
        local pos = room:GetGridPosition(iudex) + wallStickOffset
        table.insert(postable, pos)
    end
    local targetpos = mod:GetClosestPos(position, postable)
    return room:GetGridIndex(targetpos)
end

function mod:GetWallStickerIndexes(index, gridthreshold) --Get 2*2 grid of indexes for WallStick movement
    local room = game:GetRoom()
    local upindex = mod:GetAdjacentIndex(index, "Up")
    local indextable = {[1] = mod:GetAdjacentIndex(upindex, "Left"), [2] = upindex, [3] = mod:GetAdjacentIndex(index, "Left"), [4] = index}
    local colltable = {}
    for i, iudex in pairs(indextable) do
        local isSolid = room:GetGridCollision(iudex) > gridthreshold 
        if not isSolid then
            local gridpath = mod:GetGridPath(iudex)
            if gridpath >= 0 and gridthreshold <= GridCollisionClass.COLLISION_SOLID then --Agony
                if gridthreshold == GridCollisionClass.COLLISION_NONE then
                    isSolid = (gridpath >= 1000)
                else
                    isSolid = (gridpath >= 1000 and gridpath ~= 3000) --Pits use GridPath 3000 so i have to check for them manually yayyyy
                end
            end
        end
        colltable[i] = isSolid
    end
    return indextable, colltable
end

function mod:GatherGridPaths()
    local room = game:GetRoom()
    for i = 0, room:GetGridSize() - 1 do 
        mod.GridPaths[i] = room:GetGridPath(i)
    end
end

function mod:GetGridPath(index)
    local room = game:GetRoom()
    return mod.GridPaths[index] or room:GetGridPath(index)
end

function mod:GetGridPathFromPos(pos)
    local room = game:GetRoom()
    local index = room:GetGridIndex(pos)
    return mod.GridPaths[index] or room:GetGridPath(index)
end

--Applying it to Flies for testing
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc.SubType == 169 or npc.SubType == 170 then --13.0.169 and 13.0.170 
        local data = npc:GetData()
        if not data.Init then
            mod:WallHuggerInit(npc, "Down", (npc.SubType == 169), GridCollisionClass.COLLISION_NONE, 10)
            npc.Color = Color(1,1,1,1,0.8,0.8,0.8)
            data.Init = true
        end
        npc:GetSprite():Play("Fly")
        mod:WallHuggerMovement(npc, 10)
        return true
    end
end, 13)