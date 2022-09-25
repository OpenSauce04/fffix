local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local subwayRoomsList = StageAPI.RoomsList("FFSubwayRooms", require("resources.luarooms.golem_subway"))

--[[
Golem's Subway
"Where all of Golem's friends hang out!"

links to:
- treasure (both if XL)
- secret (not super)
- shop
- boss (first only if XL)
- starting room?

]]

local requiredSubwayDoorCount = -1

function FiendFolio.ShouldSpawnGolemSubway()
    return (FiendFolio.GolemExists() or Isaac.GetChallenge() == mod.challenges.brickByBrick) and (not game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) or game:GetLevel():GetStage() == LevelStage.STAGE8) and Isaac.GetChallenge() ~= mod.challenges.towerOffense
end

local function getConnectionForSlot(connections, slot)
    for _, connection in ipairs(connections) do
        if connection.Slot == slot then
            return connection
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if StageAPI.InTestMode then return end

    local room = game:GetRoom()
    local level = game:GetLevel()
    local defaultMap = StageAPI.GetDefaultLevelMap()

    -- New Level stuff:
    local inStartingRoom = level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
    if inStartingRoom and StageAPI.GetDimension() == 0 and room:IsFirstVisit() and FiendFolio.ShouldSpawnGolemSubway() then
        -- Determine which rooms the subway will link to, then set up the subway room.
        local subwayConnections = {}
        local roomDescs = level:GetRooms()
        for i = 0, roomDescs.Size - 1 do
            local desc = roomDescs:Get(i)
            if desc then
                local dimension = StageAPI.GetDimension(desc)
                if dimension == 0 then
                    local rtype = desc.Data.Type
                    local connect
                    if (rtype == RoomType.ROOM_TREASURE and not game:IsGreedMode()) or rtype == RoomType.ROOM_SECRET or rtype == RoomType.ROOM_SHOP then
                        connect = true
                    elseif rtype == RoomType.ROOM_BOSS then
                        if level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == 0 or level:GetLastBossRoomListIndex() ~= desc.ListIndex then
                            connect = true
                        end
                    elseif rtype == RoomType.ROOM_DEFAULT and level:GetStartingRoomIndex() == desc.GridIndex and not game:IsGreedMode() then
                        connect = true
                    end

                    if connect then
                        subwayConnections[#subwayConnections + 1] = desc
                    end
                end
            end
        end

        requiredSubwayDoorCount = #subwayConnections
        local subwayRoom = StageAPI.LevelRoom{
            RoomsList = subwayRoomsList,
            HasWaterPits = false,
            IgnoreDoors = true,
            IgnoreShape = true,
            RoomType = RoomType.ROOM_BARREN,
            IsExtraRoom = true,
        }
        requiredSubwayDoorCount = -1

        defaultMap:AddRoom(subwayRoom, {RoomID = "GolemSubway"}, true)

        local availableSlots = {}
        for _, door in ipairs(subwayRoom.Layout.Doors) do
            if door.Exists then
                availableSlots[#availableSlots + 1] = door.Slot
            end
        end

        subwayRoom.PersistentData.Connections = {}
        for _, connection in ipairs(subwayConnections) do
            local connectData = {Index = connection.SafeGridIndex}
            local slotNum = math.random(1, #availableSlots)
            connectData.Slot = availableSlots[slotNum]
            table.remove(availableSlots, slotNum)

            subwayRoom.PersistentData.Connections[#subwayRoom.PersistentData.Connections + 1] = connectData
        end
    end

    local subwayRoomData = defaultMap:GetRoomDataFromRoomID("GolemSubway")
    if subwayRoomData then
        local subwayRoom = defaultMap:GetRoom(subwayRoomData)
        local connections = subwayRoom.PersistentData.Connections

        if StageAPI.GetCurrentRoomID() == "GolemSubway" then
            StageAPI.ChangeRoomGfx(StageAPI.BaseRoomGfx.Mines)
            mod.scheduleForUpdate(function()
                local ms = MusicManager()
                if ms:GetCurrentMusicID() ~= mod.Music.BlackMarket then
                    ms:Play(mod.Music.BlackMarket, 0)
                    ms:UpdateVolume()
                end
            end, 1, ModCallbacks.MC_POST_RENDER)

            -- spawn doors to connections, make sure that they point to the right spots
            local golemDoors = StageAPI.GetCustomDoors("GolemSubwayDoor")
            if #golemDoors == 0 then
                for _, connection in ipairs(connections) do
                    local outPos = Vector.Zero
                    if connection.OutPos then
                        outPos = Vector(connection.OutPos.X, connection.OutPos.Y)
                    end

                    StageAPI.SpawnCustomDoor(connection.Slot, connection.Index, nil, "GolemSubwayDoor", nil, nil, nil, nil, outPos)
                end
            else
                for _, door in ipairs(golemDoors) do
                    local matchingConnection = getConnectionForSlot(connections, door.PersistentData.Slot)
                    local outPos = Vector.Zero
                    if matchingConnection.OutPos then
                        outPos = Vector(matchingConnection.OutPos.X, matchingConnection.OutPos.Y)
                    end

                    door.PersistentData.ExitPosition = outPos
                end
            end
        elseif StageAPI.GetDimension() == 0 then
            local currentRoomDesc = level:GetCurrentRoomDesc()
            local currentConnection
            for _, connection in ipairs(connections) do
                if connection.Index == currentRoomDesc.SafeGridIndex then
                    currentConnection = connection
                end
            end

            if currentConnection and room:IsFirstVisit() then
                local playerPos = Isaac.GetPlayer(0).Position
                local closestValidDoor, dist
                if inStartingRoom then
                    closestValidDoor = room:GetCenterPos()
                else
                    for i = 0, 7 do
                        if room:GetDoor(i) then
                            local pos = room:GetDoorSlotPosition(i)
                            local doorDist = pos:DistanceSquared(playerPos)
                            if not dist or doorDist < dist then
                                closestValidDoor = pos
                                dist = doorDist
                            end
                        end
                    end
                end

                if closestValidDoor then
                    local clamped = room:GetClampedPosition(closestValidDoor, 10)
                    local gridIndex = room:GetGridIndex(clamped)
                    local gridPos = room:GetGridPosition(gridIndex)

                    -- spawn trapdoor to subway
                    FiendFolio.SubwayTrapdoorGrid:Spawn(gridIndex, false, false, {ExitDoor = currentConnection.Slot})
                    currentConnection.OutPos = {X = gridPos.X, Y = gridPos.Y}
                end
            end
        end
    end
end)

function FiendFolio.IsUnfinishedGolemFloor()
    local level = game:GetLevel()
    local stage = level:GetStage()
    local stageType = level:GetStageType()
    local replace = false
    if stage <= 8 then
        if stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
            stage = stage + 1
        end

        if stage % 2 ~= 0 then
            replace = true
        end
    elseif stage == LevelStage.STAGE5 then
        replace = true
    end

    local canHaveSpecial = stage ~= 1

    return replace, canHaveSpecial
end

StageAPI.AddCallback("FiendFolio", "POST_CHECK_VALID_ROOM", 1, function(layout)
    if requiredSubwayDoorCount ~= -1 then
        local doorCount = 0
        for _, door in ipairs(layout.Doors) do
            if door.Exists then
                doorCount = doorCount + 1
            end
        end

        if requiredSubwayDoorCount <= 6 and doorCount > 6 then
            return false
        end

        if doorCount < requiredSubwayDoorCount then
            return false
        end

        local level = game:GetLevel()
        if level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 then
            if layout.SubType ~= 3 then -- XL Stage rooms are subtype 3
                return false
            end
        else
            local unfinishedGolemFloor = FiendFolio.IsUnfinishedGolemFloor()
            if layout.SubType == 1 then -- Unfinished Golem
                return unfinishedGolemFloor
            elseif layout.SubType == 2 then
                return not unfinishedGolemFloor
            elseif layout.SubType == 3 then
                return false
            end
        end
    end
end)

local geodeGolemChance = 0.2

-- convert sourpuss to unfinished golem on the first of every floor up to womb 1, and sheol + cathedral, in subways with subtype 0
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, sub, pos, vel, spawner, seed)
    if typ == EntityType.ENTITY_SLOT and var == 1022 then
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.Layout.SubType == 0 then
            local replace, canHaveSpecial = FiendFolio.IsUnfinishedGolemFloor()
            if replace then
                if math.random() <= geodeGolemChance and canHaveSpecial then
                    return {typ, 1024, sub, seed}
                else
                    return {typ, 1023, sub, seed}
                end
            end
        end
    elseif typ == EntityType.ENTITY_SLOT and var == 1023 then
        local _, canHaveSpecial = FiendFolio.IsUnfinishedGolemFloor()
        if canHaveSpecial then
            if math.random() <= geodeGolemChance then
                return {typ, 1024, sub, seed}
            end
        end
    end
end)

-- Subway Trapdoor
FiendFolio.SubwayTrapdoorGrid = StageAPI.CustomGrid("FFSubwayTrapdoor")

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
	local index = customGrid.GridIndex
	local persistData = customGrid.PersistentData
    local room = game:GetRoom()

    local trapdoor = StageAPI.SpawnFloorEffect(room:GetGridPosition(index), Vector.Zero, nil, "gfx/grid/golem_trapdoor.anm2", true)
    customGrid.Data.Trapdoor = trapdoor

    trapdoor:GetSprite():ReplaceSpritesheet(0, "gfx/grid/golem_trapdoor.png")
    trapdoor:GetSprite():LoadGraphics()

    trapdoor:GetSprite():Play("Pushed", true)
end, "FFSubwayTrapdoor")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    local trapdoor = customGrid.Data.Trapdoor

    if not game:GetRoom():IsClear() then
        return
    end

    local playerOnTrapdoor
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player.Position:DistanceSquared(trapdoor.Position) < (20 + player.Size) ^ 2 and player:IsExtraAnimationFinished() then
            playerOnTrapdoor = true
        end
    end

    if not customGrid.Data.LeftTrapdoor and not playerOnTrapdoor then
        trapdoor:GetSprite():Play("Unpush", true)
        customGrid.Data.LeftTrapdoor = true
    elseif customGrid.Data.LeftTrapdoor and not customGrid.Data.Open and not customGrid.Data.Tapped and playerOnTrapdoor then
        customGrid.Data.Tapped = true
        trapdoor:GetSprite():Play("Push", true)
        sfx:Play(SoundEffect.SOUND_BUTTON_PRESS, 1, 0, false, math.random(80,110)/100)
    elseif customGrid.Data.Tapped and not playerOnTrapdoor then
        trapdoor:GetSprite():Play("Open Animation", true)
        customGrid.Data.Tapped = false
        customGrid.Data.Open = true
        sfx:Play(mod.Sounds.GolemDoorOpen, 1, 0, false, 1)
    elseif customGrid.Data.Open then
        if playerOnTrapdoor then
            if not StageAPI.TransitioningToExtraRoom then
                local defaultMap = StageAPI.GetDefaultLevelMap()
                local subwayRoomData = defaultMap:GetRoomDataFromRoomID("GolemSubway")
                StageAPI.ExtraRoomTransition(subwayRoomData.MapID, nil, RoomTransitionAnim.PIXELATION, StageAPI.DefaultLevelMapID, nil, customGrid.PersistentData.ExitDoor)

                trapdoor:GetSprite():Play("Player Exit", true)
            end
        else
            customGrid.Data.OpenTimer = customGrid.Data.OpenTimer or 0
            customGrid.Data.OpenTimer = customGrid.Data.OpenTimer + 1
            if trapdoor:GetSprite():IsPlaying("Close Animation") and trapdoor:GetSprite():GetFrame() > 8 then
                customGrid.Data.OpenTimer = nil
                customGrid.Data.Open = false
                sfx:Play(SoundEffect.SOUND_BUTTON_PRESS, 1, 0, false, math.random(50,80)/100)
            elseif customGrid.Data.OpenTimer >= 30 and not trapdoor:GetSprite():IsPlaying("Close Animation") then
                trapdoor:GetSprite():Play("Close Animation", true)
                sfx:Play(mod.Sounds.GolemDoorClose, 1, 0, false, 1)
            end
        end
    end
end, "FFSubwayTrapdoor")

-- Subway State Doors
FiendFolio.GolemSubwayDoor = StageAPI.CustomDoor("GolemSubwayDoor", nil, nil, nil, nil, nil, true, nil, nil, nil, RoomTransitionAnim.PIXELATION)

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_DOOR", 1, function(door, data, sprite, doorData, customGrid)
    local defaultMap = StageAPI.GetDefaultLevelMap()
    local subwayRoomData = defaultMap:GetRoomDataFromRoomID("GolemSubway")
    local subwayRoom = defaultMap:GetRoom(subwayRoomData)
    local connections = subwayRoom.PersistentData.Connections
    local matchingConnection = getConnectionForSlot(connections, data.DoorGridData.Slot)

    local level = game:GetLevel()
    local roomDesc = level:GetRoomByIdx(matchingConnection.Index)

    local secretDoor
    if roomDesc.Data.Type == RoomType.ROOM_BOSS then
        sprite:Load("gfx/grid/door_10_bossroomdoor.anm2", true)
    elseif roomDesc.Data.Type == RoomType.ROOM_SECRET then
        secretDoor = true
        sprite:Load("gfx/grid/door_08_holeinwall.anm2", false)
        sprite:ReplaceSpritesheet(0, "gfx/grid/door_08_holeinwall_depths.png")
        sprite:LoadGraphics()
        door.PositionOffset = Vector.Zero
    else
        local doorSheet = "gfx/grid/door_01_minesdoor.png"
        if roomDesc.Data.Type == RoomType.ROOM_TREASURE then
            doorSheet = "gfx/grid/door_02_treasureroomdoor.png"
        elseif roomDesc.Data.Type == RoomType.ROOM_SHOP then
            doorSheet = "gfx/grid/door_00_shopdoor.png"
        end

        for i = 0, 4 do
            sprite:ReplaceSpritesheet(i, doorSheet)
        end

        sprite:LoadGraphics()
    end

    if roomDesc.VisitedCount > 0 then
        StageAPI.SetDoorOpen(true, door)
        data.Opened = true
        sprite:Play("Opened", true)
    else
        data.OverlaySprite = Sprite()
        data.OverlaySprite.Rotation = sprite.Rotation
        data.OverlaySprite.Offset = sprite.Offset + (StageAPI.DoorOffsetsByDirection[StageAPI.DoorToDirection[data.DoorGridData.Slot]] * 26 / 40)
        data.OverlaySprite:Load("gfx/grid/door_17_bardoor.anm2", true)
        data.OverlaySprite:Play("Idle", true)
        data.RenderOverlay = true

        StageAPI.SetDoorOpen(false, door)
        data.Opened = false
        if secretDoor then
            sprite:Play("Close", true)
            sprite:SetLastFrame()
        else
            sprite:Play("Closed", true)
        end
    end
end, "GolemSubwayDoor")


local textIDToAnim = {
    [0] = "grind",
    [1] = "crush",
    [2] = "smelt"
}

local noStageTwoText = {
    grind = true,
    crush = true
}

StageAPI.AddEntityPersistenceData({
    Type = EntityType.ENTITY_EFFECT,
    Variant = mod.FF.GolemSubwayHint.Var
})

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local level = game:GetLevel()
    local stage = level:GetStage()
    local absStage = stage
    if level:GetStageType() >= StageType.STAGETYPE_REPENTANCE then
        absStage = absStage + 1
    end

    if absStage > 2 then
        eff:Remove()
        return
    end

    local text = FiendFolio.GetBits(eff.SubType, 0, 4)
    local anim = textIDToAnim[text]

    if absStage == 2 and noStageTwoText[anim] then
        eff:Remove()
        return
    end

    if anim == "smelt" and #Isaac.FindByType(EntityType.ENTITY_SLOT, 1022) == 0 then
        eff:Remove()
        return
    end

    if anim then
        eff:GetSprite():SetFrame(anim, 0)

        local data = eff:GetData()
        if not data.Init then
            local xOffset = FiendFolio.GetBits(eff.SubType, 4, 4) - 8
            local yOffset = FiendFolio.GetBits(eff.SubType, 8, 4) - 8
            eff.Position = eff.Position + Vector(xOffset, yOffset) * 4
            data.Init = true
        end

        if eff.FrameCount > 0 then    
            eff:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
        end
    end
end, mod.FF.GolemSubwayHint.Var)