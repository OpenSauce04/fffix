local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.DaggerStats = {
    [1] = { --Level of the dagger
        Cooldown = 30, --How many frames must pass before another devil dagger can fire
        Speed = 12, --Velocity of the dagger, advances this many game units a frame.
        Accuracy = 25, --Spawned daggers will veer this many degrees in either direction
        Damage = 3, --Ammount of damage the dagger does when it hits an enemy
        Range = 150, --Distance before it hits the ground
    },
    [2] = {
        Cooldown = 24,
        Speed = 14,
        Accuracy = 15,
        Damage = 3,
        Range = 200,
    },
    [3] = {
        Cooldown = 18,
        Speed = 15,
        Accuracy = 10,
        Damage = 3.5,
        BurnDamage = 2, --Damage done per fire tick
        BurnLength = 30, --How long an enemy stays on fire in frames.
        Range = 250,
    },
    [4] = {
        Cooldown = 12,
        Speed = 16,
        Accuracy = 5,
        Damage = 3.5,
        BurnDamage = 2,
        BurnLength = 60,
        Range = 300,
    },
}

function mod:devilsDaggerPlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DEVILS_DAGGER) then
        local ForcedDaggerLevel = 0 --Can be set to 1-4 to force a level for testing.
        local GemLevelRequirement = 15 --How many gems are required for a level
        local GemLevelRequirementAdd = 5 --How many more gems than the previous are required for additional levels

        local GemDrainTimer = 1 --After this many frames, a gem is drained. Set to 1 to disable.
        local GemCountCap = 100 --Maximum amount of gems you can hold, only really useful if drain is enabled.

        local AdditionalDaggerOffset = 3 --When player has multiple devil daggers, this determines how long until the next dagger fires.

        --Code stuff
        local sdata = player:GetData().ffsavedata
        data.DevilDaggerCooldown = data.DevilDaggerCooldown or 0
        data.DevilDaggerCooldown = math.max(0, data.DevilDaggerCooldown - 1)
        data.DevilDaggerLevel = data.DevilDaggerLevel or 0
        sdata.DevilsDaggerGemsCollected = sdata.DevilsDaggerGemsCollected or 0
        sdata.DevilsDaggerGemsCollected = math.max(math.min(sdata.DevilsDaggerGemsCollected, 100), 0)
        --print(sdata.DevilsDaggerGemsCollected)
        --Gem draining system (probably gonna go unused)
        if player.FrameCount % GemDrainTimer == 1 then
            sdata.DevilsDaggerGemsCollected = sdata.DevilsDaggerGemsCollected - 0.5
        end

        --Determine level of the daggers
        data.DevilDaggerLevel = 1
        if sdata.DevilsDaggerGemsCollected >= (GemLevelRequirement * 3) + (GemLevelRequirementAdd * 3) then
            data.DevilDaggerLevel = 4
        elseif sdata.DevilsDaggerGemsCollected >= (GemLevelRequirement * 2) + (GemLevelRequirementAdd) then
            data.DevilDaggerLevel = 3
        elseif sdata.DevilsDaggerGemsCollected >= GemLevelRequirement then
            data.DevilDaggerLevel = 2
        end
        if ForcedDaggerLevel and ForcedDaggerLevel > 0 then
            data.DevilDaggerLevel = ForcedDaggerLevel
        end
        data.DevilDaggerLevel = math.min(math.max(data.DevilDaggerLevel, 1), 4)

        --Level up tracking
        sdata.RecordedDevilDaggerLevel = sdata.RecordedDevilDaggerLevel or 1
        if sdata.RecordedDevilDaggerLevel < data.DevilDaggerLevel then
            sdata.RecordedDevilDaggerLevel = data.DevilDaggerLevel
            if sdata.RecordedDevilDaggerLevel == 4 then
                sfx:Play(mod.Sounds.DevilDaggerLevelUp3, 0.3, 0, false, 1)
            elseif sdata.RecordedDevilDaggerLevel == 3 then
                sfx:Play(mod.Sounds.DevilDaggerLevelUp2, 0.3, 0, false, 1)
            else
                sfx:Play(mod.Sounds.DevilDaggerLevelUp1, 0.3, 0, false, 1)
            end
            --Level up
            --player:AnimateHappy()
            player:SetColor(Color(0.5,0.5,0.5,1,5,0,0), 25, 1, true, true)

            --Cool ring
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, player.Position, nilvector, player):ToEffect()
            eff.MinRadius = 1
            eff.MaxRadius = 15
            eff.LifeSpan = 10
            eff.Timeout = 10
            eff.SpriteOffset = Vector(0, -15)
            eff.Color = Color(1,1,1,1,1,0,0)
            eff.Visible = false
            eff:FollowParent(player)
            eff:Update()
            eff.Visible = true

            --Sparkles
            for i = 30, 360, 30 do
                local sparkle = Isaac.Spawn(1000, 7003, 0, player.Position, Vector(0, math.random(50,75)/10):Rotated(i-20+math.random(40)), player):ToEffect()
                sparkle:GetSprite().PlaybackSpeed = math.random(50,200)/100
                sparkle.Color = Color(1,0.7,0.7,1,1,0,0)
                sparkle.SpriteOffset = Vector(0, -20)
                sparkle:Update()
            end
        end

        --Biend specific stuff
        local canfire = true
        if data.MaliceMinion then
            local parentPlayer = player.Parent:ToPlayer()
            if parentPlayer then
                data.DevilDaggerLevel = parentPlayer:GetData().DevilDaggerLevel
            end
            local rand = math.random(math.floor(mod.DaggerStats[data.DevilDaggerLevel].Cooldown/2))
            if rand ~= 1 then
                canfire = false
            end
        end
        if data.DevilDaggerCooldown <= 0 and (not data.MaliceSplit) and canfire then
            local aim = player:GetAimDirection()
            local lockAngle
            if not (player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or data.firingSanguineHookShot) then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
                    lockAngle = 45
                else
                    lockAngle = 90
                end
            end
            if lockAngle then
                aim = mod:SnapVector(aim, lockAngle)
            end
            if aim:Length() > 0.5 then
                aim = aim:Normalized()
                vec = aim:Resized(mod.DaggerStats[data.DevilDaggerLevel].Speed)
                vec = vec:Rotated(-mod.DaggerStats[data.DevilDaggerLevel].Accuracy + math.random(mod.DaggerStats[data.DevilDaggerLevel].Accuracy * 2))
                sfx:Play(mod.Sounds.AxeThrow, 0.1, 0, false, math.random(150,170)/100)
                local dagger = Isaac.Spawn(mod.FF.DevilsDagger.ID, mod.FF.DevilsDagger.Var, mod.FF.DevilsDagger.Sub, player.Position - vec, vec, player)
                dagger:GetData().itemLevel = data.DevilDaggerLevel
                dagger:Update()
                data.DevilDaggerCooldown = mod.DaggerStats[data.DevilDaggerLevel].Cooldown
            end
        end
    end
end

function mod:devilsDaggerNewStage(player, d)
    local sdata = player:GetData().ffsavedata
    sdata.DevilsDaggerGemsCollected = 0
    sdata.RecordedDevilDaggerLevel = nil
end

local function DaggerGib(e, d)
    local poof = Isaac.Spawn(1000, 80, 0, e.Position, RandomVector():Resized(math.random(50)/10), nil)
    local poofCol = Color(1,1,1,1,0,0,0)
    if d.itemLevel >= 3 then
        poofCol:SetColorize(2,1,0.5,1)
    else
        poofCol:SetColorize(1,1,1,1)
    end
    poof.Color = poofCol
    poof.SpriteOffset = Vector(0, -15)
    for i = 1, 5 do
        local gib = Isaac.Spawn(1000, 86, 0, e.Position, RandomVector():Resized(math.random(50)/10), nil):ToEffect()
        if d.itemLevel >= 3 then
            gib.Color = Color(3,2,1,1)
        elseif d.itemLevel == 2 then
            gib.Color = Color(2,2,2,1)
        end
        gib.State = 2
        gib:Update()
    end
end

function mod:devilsDaggerUpdate(e)
    local d, sprite, player = e:GetData(), e:GetSprite(), e.SpawnerEntity or Isaac.GetPlayer()
    player = player:ToPlayer()

    if not d.init then
        d.init = true
        d.DamagedEntities = {}
        d.itemLevel = d.itemLevel or 1
    end
    mod:spritePlay(sprite, "Lvl" .. d.itemLevel)
    
    sprite.Rotation = e.Velocity:GetAngleDegrees()

    d.Lifespan = d.Lifespan or (mod.DaggerStats[d.itemLevel].Range / mod.DaggerStats[d.itemLevel].Speed)
    if e.FrameCount > d.Lifespan then
        e.SpriteOffset = e.SpriteOffset + Vector(0, 2)
        if e.SpriteOffset.Y >= 0 then
            DaggerGib(e, d)
            e:Remove()
        end
    else
        e.SpriteOffset = Vector(0, -10)
    end

    if d.itemLevel >= 3 then
        if not d.coolTrail then
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, e.Position, nilvector, e):ToEffect()
            if d.itemLevel == 4 then
                trail.MinRadius = 0.12
                trail.SpriteScale = Vector(1.5,1)
                trail.Color = Color(1,1,0.7,1)
            else
                trail.MinRadius = 0.2
                trail.SpriteScale = Vector(1.2,1)
                trail.Color = Color(0.7,0.1,0.1,1)
            end
            trail:FollowParent(e)
            d.coolTrail = trail
        end
        d.coolTrail.ParentOffset = e.SpriteOffset + Vector(0,-6)
    end

    if e.FrameCount % 2 == 0 then
        for _, enemy in pairs(Isaac.FindInRadius(e.Position, 120, EntityPartition.ENEMY)) do
            --Collides with player objects at least
            if enemy.EntityCollisionClass > 1 then
                if not mod:isFriend(enemy) then
                    if not d.DamagedEntities[enemy.InitSeed] then
                        if enemy.Position:Distance(e.Position) <= e.Size + enemy.Size then
                            local damage = mod.DaggerStats[d.itemLevel].Damage
                            enemy:TakeDamage(damage, 0, EntityRef(player), 0)
                            sfx:Play(mod.Sounds.CleaverHit,0.3,0,false, math.random(130,150)/100)
                            d.DamagedEntities[enemy.InitSeed] = true
                            if d.itemLevel >= 3 then
                                enemy:AddBurn(EntityRef(player), mod.DaggerStats[d.itemLevel].BurnLength, mod.DaggerStats[d.itemLevel].BurnDamage)
                            end
                            if d.itemLevel == 4 then
                                enemy:GetData().DevilsDaggerBurn = true
                                --[[FiendFolio.scheduleForUpdate(function()
                                    if enemy and enemy:Exists() and enemy:IsDead() then
                                        local fire = Isaac.Spawn(1000,51,960, enemy.Position, nilvector, Isaac.GetPlayer())
                                        fire:GetData().timer = 30
                                        fire:Update()
                                    end
                                end, 2)]]
                            end
                        end
                    end
                end
            end
        end
    end

    if room:GetGridCollisionAtPos(e.Position) > 1 then --Object,Solid,Wall
        DaggerGib(e, d)
        e:Remove()
    end
end

function mod:devilsDaggerGemUpdate(e)
    local d, sprite = e:GetData(), e:GetSprite()
    if not d.init then
        d.init = true
        d.anim = math.random(3)
        d.FallAccel = 1
        d.FallSpeed = -math.random(80,100)/10
        d.Falling = true
    end
    mod:spritePlay(sprite, "gem" .. d.anim)
    if d.Falling then
        d.FallOffset = d.FallOffset or 0
        if d.FallOffset + d.FallSpeed >=1 then
            if d.FallSpeed <= 2 then
                d.Falling = nil
            end
            sfx:Play(mod.Sounds.DevilDaggerGemTing,d.FallSpeed/40,0,false, math.random(80,120)/100 + d.FallSpeed/50)
            d.FallSpeed = d.FallSpeed * -0.5
        end
        d.FallOffset = d.FallOffset + d.FallSpeed
        d.FallSpeed = d.FallSpeed + d.FallAccel
    else
        d.FallOffset = 0
        --[[if not d.coolTrail then
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, e.Position, nilvector, e):ToEffect()
            trail.MinRadius = 0.1
            trail.SpriteScale = Vector(1.5 ,1)
            trail:FollowParent(e)
            trail.Color = Color(1,1,1,1)
            
            d.coolTrail = trail
        end
        d.coolTrail.ParentOffset = e.SpriteOffset + Vector(0,-10)]]
    end

    if not d.Collected then
        local maxdist = 120
        for _, p in pairs(Isaac.FindInRadius(e.Position, maxdist, EntityPartition.PLAYER)) do
            local dist = p.Position:Distance(e.Position)
            if e.SpriteOffset.Y > -20 and dist <= e.Size + p.Size and e.FrameCount > 3 then
                d.Falling = nil
                d.FallOffset = 0
                sfx:Play(mod.Sounds.DevilDaggerGemCollect,0.5,0,false, math.random(80,120)/100)
                d.Collected = true
                d.CollectFrame = 0
                local pd = p:GetData()
                if pd.MaliceMinion then
                    local parentPlayer = p.Parent:ToPlayer()
                    if parentPlayer then
                        pd = parentPlayer:GetData()
                    end
                end
                local sdata = p:GetData().ffsavedata
                sdata.DevilsDaggerGemsCollected = sdata.DevilsDaggerGemsCollected or 0
                sdata.DevilsDaggerGemsCollected = sdata.DevilsDaggerGemsCollected + 1
                break
            end
            local vec = (p.Position + p.Velocity) - e.Position
            vec = vec:Resized(maxdist - dist) / 20
            e.Velocity = mod:Lerp(e.Velocity, vec, 0.3)


        end
    end

    if d.Collected then
        e.Velocity = nilvector
        d.CollectFrame = d.CollectFrame + 1
        local CollectTime = 4
        if d.CollectFrame >= CollectTime then
            e:Remove()
        else
            e.Color = Color(1,1,1,1,d.CollectFrame/CollectTime,d.CollectFrame/CollectTime,d.CollectFrame/CollectTime)
            sprite.Scale = Vector(1 + ((d.CollectFrame/CollectTime) * 2), 1 - d.CollectFrame/CollectTime)
        end
    else
        if e.FrameCount > 90 then
            e:Remove()
        elseif e.FrameCount > 60 then
            if e.FrameCount % 4 >= 2 then
                e.Color = Color(1,1,1,0)
            else
                e.Color = mod.ColorNormal
            end
        end
    end

    e.SpriteOffset = Vector(0, -10 + d.FallOffset)

    e.Velocity = e.Velocity * 0.9
end

function mod:devilDaggerEnemyDeath(npc)
    if not npc.SpawnerEntity then
        if mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.DEVILS_DAGGER) then
            local room = game:GetRoom()
            if room:GetFrameCount() > 5 then
                if npc:IsBoss() and not npc.Parent then
                    for i = 1, 5 do
                        local gem = Isaac.Spawn(mod.FF.DevilsDaggerGem.ID, mod.FF.DevilsDaggerGem.Var, mod.FF.DevilsDaggerGem.Sub, npc.Position, RandomVector():Resized(math.random(50,150)/10), npc)
                        gem:Update()
                    end
                else
                    local gem = Isaac.Spawn(mod.FF.DevilsDaggerGem.ID, mod.FF.DevilsDaggerGem.Var, mod.FF.DevilsDaggerGem.Sub, npc.Position, RandomVector():Resized(math.random(30)/10), npc)
                    gem:Update()
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.devilDaggerEnemyDeath)