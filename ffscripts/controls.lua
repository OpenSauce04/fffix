local FF = FiendFolio
local game = Game()

function FF.SafeKeyboardTriggered(key, controllerIndex)
    return Input.IsButtonTriggered(key, controllerIndex) and not Input.IsButtonTriggered(key % 32, controllerIndex)
end

function FF.AnyKeyboardTriggered(key, controllerIndex)
    if FF.SafeKeyboardTriggered(key, controllerIndex) then
        return true
    end

    for i = 0, 4 do
        if FF.SafeKeyboardTriggered(key, i) then
            return true
        end
    end

    return false
end

function FF.resetDoubleTap(player, isDropping)
    local inputFrames = 7

    local data = player:GetData()

    local frame = player.FrameCount
    local dropFrame = data.LastResetPress

    data.LastResetPress = frame

    if dropFrame and frame - dropFrame <= inputFrames then
        data.LastResetPress = nil
        Isaac.ExecuteCommand('restart')
        return
    end
end

function FF:resetLogic(player, ci)
    --[[if FF.SafeKeyboardTriggered(Keyboard.KEY_R, ci) then
        FF.resetDoubleTap(player)
    end]]
end

function FiendFolio.TrinketInputExtender(player, isDropping)
    --if not isDropping then return end

    local inputFrames = 7

    local data = player:GetData()

    local frame = player.FrameCount
    local dropFrame = data.LastDropPress

    data.LastDropPress = frame

    -- force drop action on double tap
        if dropFrame and frame - dropFrame <= inputFrames then
            data.LastDropPress = nil

            local room = game:GetRoom()
            player:DropTrinket(room:FindFreePickupSpawnPosition(player.Position, 0, false), false)
            player:DropTrinket(room:FindFreePickupSpawnPosition(player.Position, 0, false), false)
            player:DropPoketItem(0, room:FindFreePickupSpawnPosition(player.Position, 0, false))
            player:DropPoketItem(1, room:FindFreePickupSpawnPosition(player.Position, 0, false))

            return
        end


    -- swap held trinkets
    local t0, t1 = player:GetTrinket(0), player:GetTrinket(1)
    if t0 > 0 and t1 > 0 then
        player:TryRemoveTrinket(t0)
        player:AddTrinket(t0)
    end
end

FF.doubleTapCTRLBlacklist = {
    [PlayerType.PLAYER_THEFORGOTTEN] = true,
    [PlayerType.PLAYER_THESOUL] = true,
    [PlayerType.PLAYER_ISAAC_B] = true,
    [PlayerType.PLAYER_CAIN_B] = true,
}

FF:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, buttonAction)
    --[[if buttonAction ~= ButtonAction.ACTION_DROP then return end

    if hook ~= InputHook.IS_ACTION_TRIGGERED or game:IsPaused() then return end

    local player = entity and entity:ToPlayer()
    if not player then return end

    -- interferes with forgotten's trinket swap
    local ptype = player:GetPlayerType()
    if FF.doubleTapCTRLBlacklist[ptype] then
        return
    end

    local controllerIndex = player.ControllerIndex
    local isDropping = Input.IsActionTriggered(buttonAction, controllerIndex)]]

    --FiendFolio.TrinketInputExtender(player, isDropping)
end)

function FiendFolio.DetectDoubleTapFire(player, isFiring, action, throughMouse)
    if not isFiring then return end
    if throughMouse then
        action = 160160
    end

    local inputFrames = 7

    local data = player:GetData()

    local frame = player.FrameCount
    local fireFrame = data.LastFirePress
    local fireAction = data.LastFireAction

    data.LastFirePress = frame
    data.LastFireAction = action

    -- activate double tap fire
    if action == fireAction
    and fireFrame and frame - fireFrame <= inputFrames then
        data.LastFirePress = nil
        data.LastFireAction = nil

        FiendFolio.HandleDoubleTapFire(player, action)
    end
end

local shootInputs = {
    ButtonAction.ACTION_SHOOTLEFT,
    ButtonAction.ACTION_SHOOTRIGHT,
    ButtonAction.ACTION_SHOOTUP,
    ButtonAction.ACTION_SHOOTDOWN
}
FF:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if game:IsPaused() then return end

    for i = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
        local controllerIndex = player.ControllerIndex

        for _, buttonAction in pairs(shootInputs) do
            local isFiring
            local throughMouse
            if player.ControllerIndex == 0 and Options.MouseControl then
                if Input.IsMouseBtnPressed(0) then
                    if not FF.Player0IsClickingMouse then
                        isFiring = true
                        throughMouse = true
                        FF.Player0IsClickingMouse = true
                    end
                else
                    FF.Player0IsClickingMouse = nil
                end
            end
            if not throughMouse then
                isFiring = Input.IsActionTriggered(buttonAction, controllerIndex)
            end
            FiendFolio.DetectDoubleTapFire(player, isFiring, buttonAction, throughMouse)
        end

        --if FF.SafeKeyboardTriggered(Keyboard.KEY_R, controllerIndex) then
        if Input.IsActionTriggered(ButtonAction.ACTION_RESTART, controllerIndex) then
            FF.resetDoubleTap(player)
        end
        if Input.IsActionTriggered(ButtonAction.ACTION_DROP, controllerIndex) then
            local ptype = player:GetPlayerType()
            if not FiendFolio.CheckedModsForCTRL then
                if StarFall then
                    FF.doubleTapCTRLBlacklist[PlayerType.PLAYER_GAIL] = true
                end
                FiendFolio.CheckedModsForCTRL = true
            end
            if not FF.doubleTapCTRLBlacklist[ptype] then
                FiendFolio.TrinketInputExtender(player)
            end
        end
    end
end)