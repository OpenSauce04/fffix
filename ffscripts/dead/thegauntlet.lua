local mod = FiendFolio
local game = Game()
local map = include("resources.luarooms.ff_bossrush_challenge")
local mapList = StageAPI.RoomsList("FFTheGauntlet", map)
local doOnFirstUpdate
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
    doOnFirstUpdate = nil
    if not continued and game.Challenge == FiendFolio.challenges.theGauntlet then
        doOnFirstUpdate = true
        local player = Isaac.GetPlayer()
        player:AddBombs(-1)
        player:AddCoins(3)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if doOnFirstUpdate then
        local map = StageAPI.CreateMapFromRoomsList(mapList)
        StageAPI.InitCustomLevel(map, true)
        doOnFirstUpdate = nil
    end

    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local room = game:GetRoom()
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid and (grid.Desc.Type == GridEntityType.GRID_TRAPDOOR or grid.Desc.Type == GridEntityType.GRID_STAIRS) then -- i hate you crawlspaces!!
                room:RemoveGridEntity(i, 0, false)
            end
        end

        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.Layout.Name == "Cacophobia Gateway" then
            game:Darken(1, 30)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for _, item in ipairs(items) do
            if item.FrameCount <= 1 then
                game:GetHUD():ShowItemText("Whoops", "Looks like you dropped something!")
                item:Remove()
            end
        end
    end
end, CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            local sadOnions = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_SAD_ONION)
            local setOnionItem
            if currentRoom.Layout.Name == "Secreter Shop" then
                setOnionItem = FiendFolio.ITEM.COLLECTIBLE.WHITE_PEPPER
            elseif currentRoom.Layout.Name == "How'd You Get Here?" then
                setOnionItem = FiendFolio.ITEM.COLLECTIBLE.FIEND_FOLIO
            end

            if setOnionItem then
                for _, onion in ipairs(sadOnions) do
                    local price = onion:ToPickup().Price
                    onion:ToPickup():Morph(onion.Type, onion.Variant, setOnionItem, true, true, true)
                    onion:ToPickup().AutoUpdatePrice = false
                    onion:ToPickup().Price = price
                end
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        return PillEffect.PILLEFFECT_POWER
    end
end)

-- No heart drops from bosses in this one!!
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, var, sub, pos, vel, spawner, seed)
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        if game:GetRoom():GetType() == RoomType.ROOM_BOSS
        and spawner
        and spawner.Type >= 10
        and id == EntityType.ENTITY_PICKUP
        and (var == PickupVariant.PICKUP_HEART
        or (var >= PickupVariant.PICKUP_IMMORAL_HEART and var <= PickupVariant.PICKUP_BLENDED_IMMORAL_HEART)) then
            return {
                1000,
                StageAPI.E.DeleteMeEffect.V,
                0,
                seed
            }
        end

        if id == EntityType.ENTITY_PICKUP
        and var == PickupVariant.PICKUP_TRINKET
        and sub ~= TrinketType.TRINKET_PERFECTION then
            return {
                1000,
                StageAPI.E.DeleteMeEffect.V,
                0,
                seed
            }
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        return 0
    end
end)

local badgesNeeded = {
    Ch2 = {FiendFolio.ITEM.COLLECTIBLE.SPATULA_BADGE, FiendFolio.ITEM.COLLECTIBLE.COMMISSIONED_BADGE, FiendFolio.ITEM.COLLECTIBLE.MYSTERY_BADGE},
    Ch3 = {FiendFolio.ITEM.COLLECTIBLE.BABY_BADGE, FiendFolio.ITEM.COLLECTIBLE.DRIPPING_BADGE},
    Ch4 = {FiendFolio.ITEM.COLLECTIBLE.HAUNTED_BADGE}
}

local function hasAllItems(player, list)
    for _, id in ipairs(list) do
        if not player:HasCollectible(id) then
            return false
        end
    end

    return true
end

local badgeDoorStates = {
    Default = "Hidden",
    Hidden = {
        Anim = "Hidden",
        Triggers = {
            EnteredThrough = {
                State = "Opened",
                Anim = "Opened"
            },
            DadsKey = {
                State = "Opened",
                ForcedOpen = true,
                Check = function(door, data, sprite, doorData, doorGridData)
                    local leadsToMap = doorGridData.LevelMapID
                    local leadsTo = doorGridData.LeadsTo
                    local levelMap = StageAPI.LevelMaps[leadsToMap]
                    local leadsToRoom = levelMap:GetRoom(leadsTo)

                    if leadsToRoom then
                        local player = Isaac.GetPlayer()
                        if leadsToRoom.Layout.Name == "How'd You Get Here?" then
                            return hasAllItems(player, badgesNeeded.Ch2)
                        elseif leadsToRoom.Layout.Name == "Take This, You'll Need It" then
                            return hasAllItems(player, badgesNeeded.Ch3)
                        elseif leadsToRoom.Layout.Name == "The Collector's Gambit" then
                            return hasAllItems(player, badgesNeeded.Ch4)
                        end
                    end

                    return true
                end
            }
        }
    },
    Closed = StageAPI.SecretDoorClosedState,
    Opened = StageAPI.SecretDoorOpenedState
}

local badgeDoor = StageAPI.CustomStateDoor("FFGauntletBadgeDoor", "gfx/grid/door_08_holeinwall.anm2", badgeDoorStates, nil, nil, StageAPI.SecretDoorOffsetsByDirection)

StageAPI.AddCallback("FiendFolio", "PRE_LEVELMAP_SPAWN_DOOR", 1, function(slot, doorData, levelRoom, targetLevelRoom, roomData, levelMap)
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        if targetLevelRoom.RoomType == RoomType.ROOM_SECRET then
            StageAPI.SpawnCustomDoor(slot, doorData.ExitRoom, levelMap, "FFGauntletBadgeDoor", nil, doorData.ExitSlot, "Secret")
            return true
        end
    end
end)