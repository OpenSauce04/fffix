--Made by Sanio (Sanio#5230)

local mod = FiendFolio
local game = Game()
local itemconfig = Isaac.GetItemConfig()

local excelsiorSparkle = Sprite()
excelsiorSparkle:Load("gfx/effects/effect_excelsior_sparkles.anm2", true)
excelsiorSparkle:Play("Sparkle", true)
local myItem = CollectibleType.COLLECTIBLE_EXCELSIOR

local function GetBottomRightNoOffset()
    return game:GetRoom():GetRenderSurfaceTopLeft() * 2 + Vector(442, 286)
end

local function GetBottomLeftNoOffset()
    return Vector(0, GetBottomRightNoOffset().Y)
end

local function GetTopRightNoOffset()
    return Vector(GetBottomRightNoOffset().X, 0)
end

local function GetTopLeftNoOffset()
    return Vector.Zero
end

local function GetScreenBottomRight()
    local hudOffset = Options.HUDOffset
    local offset = Vector(-hudOffset * 16, -hudOffset * 6)

    return GetBottomRightNoOffset() + offset
end

local function GetScreenBottomLeft()
    local hudOffset = Options.HUDOffset
    local offset = Vector(hudOffset * 20, -hudOffset * 12)

    return GetBottomLeftNoOffset() + offset
end

local function GetScreenTopRight()
    local hudOffset = Options.HUDOffset
    local offset = Vector(-hudOffset * 20, hudOffset * 12)

    return GetTopRightNoOffset() + offset
end

local function GetScreenTopLeft()
    local hudOffset = Options.HUDOffset
    local offset = Vector(hudOffset * 20, hudOffset * 12)

    return GetTopLeftNoOffset() + offset
end

local function GetActiveSlots(player, itemID)
    local slots = {}
    if player:HasCollectible(itemID) then
        for i = 0, 3 do
            local item = player:GetActiveItem(i)
            if item > 0 then
                local configitem = itemconfig:GetCollectible(item)
                local charges = configitem.MaxCharges
                if player:GetActiveCharge(i) >= charges then
                    table.insert(slots, i)
                end
            end
        end
    end
    return slots
end

local function GetAllMainPlayers()
    local players = {}
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetMainTwin():GetPlayerType() == player:GetPlayerType() --Is the main twin of 2 players
            and (not player.Parent or player.Parent.Type ~= EntityType.ENTITY_PLAYER) --Not an item-related spawned-in player.
        then
            table.insert(players, player)
        end
    end
    return players
end

local ActivePlayers = {
    [1] = {
        Player = nil,
        Offset = Vector(20, 15),
        ScreenPos = GetScreenTopLeft(),
    },
    [2] = {
        Player = nil,
        Offset = Vector(-159, 0),
        ScreenPos = GetScreenTopRight(),
    },
    [3] = {
        Player = nil,
        Offset = Vector(16, -33),
        ScreenPos = GetScreenBottomLeft(),
    },
    [4] = {
        Player = nil,
        Offset = Vector(-20, -16),
        ScreenPos = GetScreenBottomRight(),
    }
}

local function AddActivePlayers(i, player)
    ActivePlayers[i].Player = player

    --Funny Esau takes up p4 spot if they're from p1
    if i == 1
        and player:GetOtherTwin() ~= nil
        and player:GetOtherTwin():GetPlayerType() == PlayerType.PLAYER_ESAU
        and ActivePlayers[4].Player == nil then
        ActivePlayers[4].Player = player
    end
end

local numHUDPlayers = 1

function mod:UpdatePlayerActivePoses()
    local players = GetAllMainPlayers()

    if #players ~= numHUDPlayers then
        numHUDPlayers = #players
        for i = 1, 4 do
            ActivePlayers[i].Player = nil
        end
    end

    for i = 1, #players do
        if i > 4 then break end

        local player = players[i]

        if player:HasCollectible(myItem)
            and ActivePlayers[i].Player == nil
        then
            AddActivePlayers(i, player)
        elseif not player:HasCollectible(myItem)
            and ActivePlayers[i].Player ~= nil then
            ActivePlayers[i].Player = nil
        end
    end
end

local function HasBook(player)
    local hasVirtues = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
    local hasBelial = player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    local hasBook = hasVirtues or hasBelial

    return hasBook
end

function mod:ExcelsiorRender(sprite)
    
    for i = 1, #ActivePlayers do
        local activePlayer = ActivePlayers[i]

        if sprite:IsLoaded()
            and activePlayer
            and activePlayer.Player ~= nil
            and game:GetHUD():IsVisible()
        then
            ActivePlayers[1].ScreenPos = GetScreenTopLeft()
            ActivePlayers[2].ScreenPos = GetScreenTopRight()
            ActivePlayers[3].ScreenPos = GetScreenBottomLeft()
            ActivePlayers[4].ScreenPos = GetScreenBottomRight()
            local slots = GetActiveSlots(activePlayer.Player, myItem)
            for j = 1, #slots do
                local slotOffset = Vector.Zero
                local pos = activePlayer.ScreenPos + activePlayer.Offset
                local size = 1
                if i == 1 and (slots[j] == ActiveSlot.SLOT_POCKET or slots[j] == ActiveSlot.SLOT_POCKET2) then
                    pos = GetScreenBottomRight() +ActivePlayers[4].Offset
                    local found
                    for s = 0, 3 do
                        local card = activePlayer.Player:GetCard(s)
                        local pill = activePlayer.Player:GetPill(s)
                        if card == 0 and pill == 0 and not found then
                            if s > 0 then
                                size = 0.5
                                slotOffset = Vector(8,-12 * s)
                            end
                            found = true
                        end
                    end
                elseif slots[j] == ActiveSlot.SLOT_SECONDARY then
                    slotOffset = Vector(-16,-8)
                    size = 0.5
                end
                sprite.Scale = Vector(size, size)
                local renderpos = pos + slotOffset
                sprite:Render(renderpos, Vector.Zero, Vector.Zero)
            end
        end
    end
end

StageAPI.AddCallback("FiendFolio", "POST_HUD_RENDER", 1, function(isPauseMenuOpen, pauseMenuDarkPct)
    if not isPauseMenuOpen then
        mod:UpdatePlayerActivePoses()
        mod:ExcelsiorRender(excelsiorSparkle)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
    excelsiorSparkle:Update()
end)

function mod:ResetOnGameStart()
    for i = 1, 4 do
        ActivePlayers[i].Player = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ResetOnGameStart)
