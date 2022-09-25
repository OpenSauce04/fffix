local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--FiendFolio.KillBindsEnabled = true

local isSkeleton = {
    [PlayerType.PLAYER_THEFORGOTTEN] = true,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
}

local isStone = {
    [PlayerType.PLAYER_APOLLYON] = true,
    [PlayerType.PLAYER_APOLLYON_B] = true,
    [FiendFolio.PLAYER.GOLEM] = true,
    [FiendFolio.PLAYER.BOLEM] = true,
}

local isBlue = {
    [PlayerType.PLAYER_THESOUL] = true,
    [PlayerType.PLAYER_THESOUL_B] = true,
}

local isBlueBaby = {
    [PlayerType.PLAYER_XXX] = true,
    [PlayerType.PLAYER_XXX_B] = true,
}

local isKeeper = {
    [PlayerType.PLAYER_KEEPER] = true,
    [PlayerType.PLAYER_KEEPER_B] = true,
}

local CuteLilBugs = {{33, 0},{63, 0},{63, 1},{64, 0}}

function mod:explodePlayer(player, dontActuallyKill)
    if (not dontActuallyKill) and player:GetData().alreadyDidFunnyDeathKillbind then return end
    local d = player:GetData()
    if not dontActuallyKill then
        d.alreadyDidFunnyDeathKillbind = true
    end

    local playerType = player:GetPlayerType()
    game:ShakeScreen(20)

    if not dontActuallyKill then
        player.Visible = false
        player:Update()
        player:Kill()

        mod.scheduleForUpdate(function()
            player.Visible = false
            player.ControlsEnabled = false
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            player:GetData().alreadyDidFunnyDeathKillbind = true
        end, 1)

        d.stopDieSound = true
        mod.scheduleForUpdate(function()
            d.stopDieSound = false
        end, 10)
    end

    --For modders to add compatability to this useless function
    --dontActuallyKill is true when this is just for effect
    if d.overrideKillBindFunny then 
        d.overrideKillBindFunny(player, d, dontActuallyKill)
        return
    end

    --This is the format :)
    --[[
    player:GetData().overrideKillBindFunny = function() 
        print("hi") 
    end
    ]]

    if isStone[playerType] then
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1, 0, false, 1)
        sfx:Play(SoundEffect.SOUND_POT_BREAK, 1, 0, false, 0.6)
        sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF, 1, 0, false, 1)
    elseif isSkeleton[playerType] then
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_BONE, 1, 0, false, 1)
        sfx:Play(mod.Sounds.MadnessSplash, 1, 0, false, 0.7)
        --sfx:Play(mod.Sounds.MeatySquish, 0.2, 0, false, 0.7)
    else
        sfx:Play(mod.Sounds.MadnessSplash, 1, 0, false, 0.7)
        sfx:Play(mod.Sounds.Valvo, 1, 0, false, 0.7)
        sfx:Play(mod.Sounds.MeatySquish, 0.2, 0, false, 0.7)
    end

    --Gib
    if not (isSkeleton[playerType] or isStone[playerType] or isBlueBaby[playerType] or isKeeper[playerType]) then
        for i = 1, 2 do
            --Eyes
            local gib = Isaac.Spawn(1000, 5, 3, player.Position, RandomVector()*math.random(5,50)/10, player)
            gib:Update()
        end
    end

    local gibCount = 30
    for i = 1, gibCount do
        local overrideGib = 5
        local chosenGib = math.random(3) - 1
        if isBlueBaby[playerType] and math.random(2) == 1 then
            overrideGib = 58
            chosenGib = 0
        elseif isStone[playerType] and math.random(3) == 1 then
            overrideGib = 4
            chosenGib = 1
        elseif isSkeleton[playerType] and chosenGib == 2 then
            overrideGib = 35
            chosenGib = 0
        end
        local gib = Isaac.Spawn(1000, overrideGib, chosenGib, player.Position, RandomVector()*math.random(5,150)/10, player):ToEffect()
        if isKeeper[playerType] or (isBlueBaby[playerType] and overrideGib == 5) then
            local WeirdColor = Color(1,1,1)
            WeirdColor:SetColorize(math.random(50,100)/100,math.random(50,100)/100,math.random(50,70)/100,1)
            gib.Color = WeirdColor
        end
        gib:Update()
    end

    
    if isBlueBaby[playerType] or isKeeper[playerType] then
        for i = 1, 20 do
            local choice = math.random(#CuteLilBugs)
            local bug = Isaac.Spawn(1000, CuteLilBugs[choice][1], CuteLilBugs[choice][2], player.Position, nilvector, player)
        end
    end

    --Cool smoke
    if isSkeleton[playerType] or isStone[playerType] then
        local bloodCloud = Isaac.Spawn(1000, 16, 1, player.Position, nilvector, player)
        bloodCloud.Color = Color(0.5,0.5,0.5,0.7)
        bloodCloud:Update() 
        local bloodCloud2 = Isaac.Spawn(1000, 16, 2, player.Position, nilvector, player)
        bloodCloud2.SpriteOffset = Vector(0, -10)
        bloodCloud2.Color = Color(0.5,0.5,0.5,0.7)
        bloodCloud2:Update() 
    elseif isBlueBaby[playerType] then
        local fart = Isaac.Spawn(1000, 34, 0, player.Position, nilvector, player)
        fart:Update()
        local bloodCloud = Isaac.Spawn(1000, 16, 3, player.Position, nilvector, player)
        bloodCloud.Color = mod.ColorNastyFunny
        bloodCloud:Update()
    else
        local bloodSplat = Isaac.Spawn(1000, 2, 0, player.Position, nilvector, player)
        if isBlueBaby[playerType] then
            bloodSplat.Color = Color(0.5,0.5,0.5)
        end
        bloodSplat:Update()
        local bloodCloud = Isaac.Spawn(1000, 16, 3, player.Position, nilvector, player)
        if isKeeper[playerType] then
            bloodCloud.Color = mod.DarkerWeird
        end
        bloodCloud:Update()
        local bloodCloud2 = Isaac.Spawn(1000, 16, 4, player.Position, nilvector, player)
        if isKeeper[playerType] then
            bloodCloud2.Color = mod.DarkerWeird
        end
        bloodCloud2:Update()
    end
end

function mod:removeAllHearts(player)
    player:AddHearts(-player:GetHearts())
    player:AddEternalHearts(-player:GetEternalHearts())
    player:AddSoulHearts(-player:GetSoulHearts())
    player:AddBoneHearts(-player:GetBoneHearts())
end

function mod:erflyPressButtonLogic(player, ci)
    if FiendFolio.HotkeyConfig.Killbinds then
        if mod.AnyKeyboardTriggered(Keyboard.KEY_END, ci) then
            mod:removeAllHearts(player)
            player:Kill()
        end
        if mod.AnyKeyboardTriggered(Keyboard.KEY_DELETE, ci) or mod.AnyKeyboardTriggered(Keyboard.KEY_KP_DECIMAL, ci) then
            mod:removeAllHearts(player)
            mod:explodePlayer(player)
            local twin = player:GetOtherTwin()
            if twin then
                mod.scheduleForUpdate(function()
                    mod:explodePlayer(twin)
                end, 10)
            end
        end
    end
    if FiendFolio.HotkeyConfig.Taunts then
        if player:IsExtraAnimationFinished() or player:GetSprite():GetAnimation() == "Happy" or player:GetSprite():GetAnimation() == "Sad" then
            if mod.AnyKeyboardTriggered(Keyboard.KEY_EQUAL, ci) or mod.AnyKeyboardTriggered(Keyboard.KEY_KP_ADD, ci) then
                player:AnimateHappy()
            end
            if mod.AnyKeyboardTriggered(Keyboard.KEY_MINUS, ci) or mod.AnyKeyboardTriggered(Keyboard.KEY_KP_SUBTRACT, ci) then
                player:AnimateSad()
            end
        end
    end
end

function mod:funnyBindsPlayerData(player, data)
    if data.alreadyDidFunnyDeathKillbind then
        if not player:IsDead() then
            data.alreadyDidFunnyDeathKillbind = false
        end
    end
end