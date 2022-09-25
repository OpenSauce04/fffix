local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.JevilText = {
    {Main = "Noisy!",                   Sub = "It's just foley!"},
    {Main = "Your FOEs felt at ease.",  Sub = "Their defense dropped!"},
    {Main = "Awkward!",                 Sub = "Your FOEs will hurt you rapidly!"},
    {Main = "Tranquil!",                Sub = "Your defense raised!"},
    {Main = "What!",                    Sub = "It's just a useless fly!"},
    {Main = "Warm!",                    Sub = "It felt comforting!"},
    {Main = "Dizzy!",                   Sub = "Your HP got jumbled up!"},
    {Main = "Careful!",                 Sub = "Your FOEs got powered up!"},
    {Main = "Fiendish!",                Sub = "A perfect 10!"},
}

function mod:jevilstailNewRoom()
    mod.activeJevilEffects = {}
end

function mod:jevilstailPlayerNewRoom(player, d, savedata)
    local room = game:GetRoom()
    if not room:IsClear() then
        if player:HasTrinket(TrinketType.TRINKET_JEVILSTAIL) then
            if not savedata.jevilsTail then
                savedata.jevilsTail = 0
            end
            for i = 1, math.floor(player:GetTrinketMultiplier(TrinketType.TRINKET_JEVILSTAIL)) do
                mod.activeJevilEffects[(savedata.jevilsTail - 1 + i) % 9] = true
            end
        else
            d.jevilActive = nil
        end
        if savedata and savedata.jevilsTail then
            savedata.jevilsTail = ((savedata.jevilsTail + math.max(1,math.floor(player:GetTrinketMultiplier(TrinketType.TRINKET_JEVILSTAIL)))) % 9)
            --print(savedata.jevilsTail)
        end
    end
end

function mod:jevilstailHandleActiveEffects()
    if mod.activeJevilEffects then
        --Now do the effects
        if mod.activeJevilEffects[0] then
            --Funny random noises
            sfx:Play(mod.Sounds.SlideWhistle, 1, 0, false, math.random(80,120)/100)
        end
        if mod.activeJevilEffects[4] then
            --Useless fly
            local room = game:GetRoom()
            local fly = Isaac.Spawn(13, 0, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0) + RandomVector(), nilvector, nil)
            sfx:Play(mod.Sounds.CrowdCheer, 2, 0, false, 1)
            for i = 90, 360, 90 do
                local arrow = Isaac.Spawn(1000, mod.FF.AwesomePointingArrow.Var, mod.FF.AwesomePointingArrow.Sub, fly.Position, nilvector, nil)
                arrow:ToEffect():FollowParent(fly)
                arrow.SpriteRotation = i
                arrow:Update()
            end
        end

        --Player Related Effects
        local players = Isaac.FindByType(1, 0, -1, false, false)
        for _, player in ipairs(players) do
            player = player:ToPlayer()
            if mod.activeJevilEffects[1] then
                player:AnimateHappy()
            end
            if mod.activeJevilEffects[2] then
                player:AnimateSad()
            end
            if mod.activeJevilEffects[3] then
                --Wafer
                player:UsePill(PillEffect.PILLEFFECT_PERCS, 1, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
            if mod.activeJevilEffects[5] then
                --Restore half heart
                player:AddHearts(1)
                local heart = Isaac.Spawn(1000,49,0,player.Position,nilvector,nil):ToEffect()
                heart.SpriteOffset = Vector(0, -20)
                heart:Update()
                sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
            end
            if mod.activeJevilEffects[6] then
                --Scramble health
                mod:scramblePlayerHealth(player)
            end
            if mod.activeJevilEffects[7] then
                --Addicted pill
                player:UsePill(PillEffect.PILLEFFECT_ADDICTED, 1, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
            if mod.activeJevilEffects[8] then
                --Free immoral heart
                Isaac.Spawn(5, PickupVariant.PICKUP_IMMORAL_HEART, 0, player.Position, RandomVector()*10, nil)
            end
        end

        --Display effect on HUD
        local activeEffect
        local numActiveEffects = 0
        for i = 0, 8 do
            if mod.activeJevilEffects[i] then
                activeEffect = i
                numActiveEffects = numActiveEffects + 1
            end
        end
        local HUD = game:GetHUD()
        if numActiveEffects > 1 then
            HUD:ShowItemText("Chaos! Chaos!", "There are multiple effects!")
        elseif activeEffect then
            if mod.JevilText[activeEffect + 1].Sub then
                HUD:ShowItemText(mod.JevilText[activeEffect + 1].Main, mod.JevilText[activeEffect + 1].Sub)
            else
                HUD:ShowItemText(mod.JevilText[activeEffect + 1].Main)
            end
        end
    end
end

function mod:scramblePlayerHealth(player)
    --Not done yet
    --Shits more complex than I expected :(
end

function mod:getPlayerBruiseStrength(player)
    local playerData = player:GetData()
    local strength = 0

    if mod.activeJevilEffects and mod.activeJevilEffects[2] then
        strength = strength + 1
    end

    if playerData.fiendfolio_epidermolysisStrength then
        strength = strength + playerData.fiendfolio_epidermolysisStrength
    end

    if playerData.ffsavedata.scytheMode and playerData.ffsavedata.scytheMode == true then
        strength = strength + 2
    end
	
	-- this should always come last
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EVIL_CHARM) then
		strength = 0
	end

    return strength
end

function mod:jevilstailPlayerUpdate(player, data)
    local bruiseStrength = mod:getPlayerBruiseStrength(player)
    local morbidModifierActive = player:GetData().TookMorbidHeartDamage

    local baseIFrames = 60 * (player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE) + 1)
    local multiplier = 1

    if bruiseStrength > 0 then
        --Reduce iframes
        multiplier = math.max(0, 1 - ((15 * math.log(bruiseStrength) + 40) / 60))

        --Fake bruise
        player:SetColor(FiendFolio.StatusEffectColors.BruiseLvl1, 1, 1, false, false)
        if not data.HasFakeBruiseVisual then
            local iconEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT, 1748, 0, player.Position, player.Velocity, nil)
            iconEnt:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
            local icon = iconEnt:ToEffect()
            icon.Parent = player
            icon:FollowParent(player)
            icon.DepthOffset = 1
            icon:Update()
            data.HasFakeBruiseVisual = iconEnt
        end
    elseif data.HasFakeBruiseVisual then
        if data.HasFakeBruiseVisual:Exists() then
            data.HasFakeBruiseVisual:Remove()
        end
        data.HasFakeBruiseVisual = nil
    end

    if morbidModifierActive then
        multiplier = multiplier * 2/3
    end
	
	if multiplier ~= 1 then
        local frameLimit = math.ceil(baseIFrames - baseIFrames * multiplier)

        if player:GetDamageCooldown() < frameLimit then
            player:ResetDamageCooldown()
			
            if morbidModifierActive then
                player:GetData().TookMorbidHeartDamage = nil
            end
        end
    end

    -- safeguard
    if morbidModifierActive and player:GetDamageCooldown() <= 0 then
        player:GetData().TookMorbidHeartDamage = nil
    end
end

function mod:jevilBruseEnemies(npc)
    if mod.activeJevilEffects and mod.activeJevilEffects[1] then
        local player = mod:getClosestPlayer(npc.Position, 99999999)
        FiendFolio.AddBruise(npc, player, 1, 1, player.Damage * 0.2, false, true)
    end
end

local jevilFoleys = {
    {Sound = mod.Sounds.SlideWhistle,      Vol = 0.5},
    {Sound = mod.Sounds.WhipCrack,      Vol = 0.5},
    {Sound = mod.Sounds.Monch,          Vol = 1},
    {Sound = mod.Sounds.FunnyBonk,      Vol = 1},
    {Sound = mod.Sounds.FartFrog3,      Vol = 0.6},
    {Sound = mod.Sounds.CartoonGulp,    Vol = 1},
    {Sound = mod.Sounds.Crow,           Vol = 1},
    {Sound = mod.Sounds.BingBingWahoo,  Vol = 0.3},
    {Sound = mod.Sounds.EpicTwinkle,    Vol = 1},
    {Sound = mod.Sounds.LezEffectGet,   Vol = 1},
    {Sound = mod.Sounds.BabyGasp,       Vol = 1},
    {Sound = mod.Sounds.CatSqueal,      Vol = 1},
    {Sound = mod.Sounds.MamaDoll,       Vol = 1},
    {Sound = mod.Sounds.MonkeyScream,   Vol = 1},
    {Sound = mod.Sounds.Orangutan,      Vol = 1},
}

function mod:playJevilFoley()
    local choice = math.random(#jevilFoleys)
    sfx:Play(jevilFoleys[choice].Sound, jevilFoleys[choice].Vol, 0, false, math.random(80,120)/100)
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function()
	if mod.activeJevilEffects then
		if mod.activeJevilEffects[0] then
            if sfx:IsPlaying(SoundEffect.SOUND_TEARS_FIRE) then
                sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
                sfx:Play(mod.Sounds.Boink, 2, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_TEARIMPACTS) then
                sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)
                sfx:Play(SoundEffect.SOUND_FART, 0.2, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_SPLATTER) then
                sfx:Stop(SoundEffect.SOUND_SPLATTER)
                sfx:Play(SoundEffect.SOUND_FART, 0.2, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_SUMMONSOUND) then
                sfx:Stop(SoundEffect.SOUND_SUMMONSOUND)
                sfx:Play(mod.Sounds.FunnyHello, 1, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_BOSS1_EXPLOSIONS) then
                sfx:Stop(SoundEffect.SOUND_BOSS1_EXPLOSIONS)
                sfx:Play(mod.Sounds.FunnyFart, 1, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_EXPLOSION_WEAK) then
                sfx:Stop(SoundEffect.SOUND_EXPLOSION_WEAK)
                sfx:Play(SoundEffect.SOUND_FART, 0.4, 0, false,  math.random(100,150)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_EXPLOSION_STRONG) then
                sfx:Stop(SoundEffect.SOUND_EXPLOSION_STRONG)
                sfx:Play(mod.Sounds.FartFrog4, 1, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND) then
                sfx:Stop(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
                sfx:Play(mod.Sounds.Subaluwa, 1, 0, false,  math.random(80,120)/100)
            end
            if sfx:IsPlaying(SoundEffect.SOUND_MONSTER_YELL_A) then
                sfx:Stop(SoundEffect.SOUND_MONSTER_YELL_A)
                if math.random(2) == 1 then
                    sfx:Play(mod.Sounds.EpicHorn, 1, 0, false,  math.random(80,120)/100)
                else
                    sfx:Play(mod.Sounds.YodelGoofy, 1, 0, false,  math.random(80,120)/100)
                end
            end
        end
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, damage, flags, source, countdown)
	if mod.activeJevilEffects then
        if mod.activeJevilEffects[0] then
            if entity.Type >= 10 and source.Type == 2 then
                sfx:Play(mod.Sounds.EpicPunch, 1, 0, false,  math.random(80,120)/100)
            elseif entity.Type == 1 then
                sfx:Play(mod.Sounds.Hoot6, 1, 0, false,  math.random(80,120)/100)
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
    local level = game:GetLevel()

    if mod.activeJevilEffects and mod.activeJevilEffects[0] then
        if npc:IsEnemy() then
            mod:playJevilFoley()
        end
    end
end)

function mod:AwesomePointingArrowAI(e)
    local sprite = e:GetSprite()
    if sprite:IsFinished("Appear") then
        mod:spritePlay(sprite, "Idle")
    end
    e.SpriteRotation = e.SpriteRotation + 1
    e.SpriteOffset = e:GetData().ForcedOffset or Vector(0, -18)
    if not e.Parent then
        e:Remove()
    end
end