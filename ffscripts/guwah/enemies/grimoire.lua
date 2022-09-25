local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:GrimoireAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    local index = room:GetGridIndex(npc.Position)

    mod.QuickSetEntityGridPathFlying(npc, 900)

    if not data.Init then
        sprite:Play("Idle")
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.StateFrame = mod:RandomInt(30,60)
        data.GrimoireFilter = function(position, candidate)
            if (candidate:GetData().GrimoireEnchanted 
                or mod:CheckIDInTable(candidate, FiendFolio.GrimoireBlacklist) 
                or mod:isFriend(candidate) ~= mod:isFriend(npc) 
                or candidate.InitSeed == npc.InitSeed) then
                return false
            else
                return true
            end
        end
        data.Init = true
    end
    if sprite:IsPlaying("Idle") then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if data.DidEnchant then
                sprite:Play("Attack2")
                data.DidEnchant = false
            else
                if mod:GetAnyEnemy(data.GrimoireFilter) then
                    sprite:Play("Attack1")
                else
                    sprite:Play("Attack2")
                end
            end
        end
        data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position, true)
        if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
            data.newhome = mod:GetNewPosAligned(npc.Position, true)
        end
        local targvel = (data.newhome - npc.Position):Resized(2.5)
        if mod:isScare(npc) then
            targvel = (targetpos - npc.Position):Resized(-4)
        end
        npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
    else
        --[[if sprite:IsPlaying("Attack1") and npc.Child and mod:IsReallyDead(npc.Child) and not sprite:WasEventTriggered("Shoot") then
            local enchantee = mod:GetGrimoireTarget(npc, targetpos)
            if enchantee then
                npc.Child = enchantee
            end
        end]]
        npc.Velocity = npc.Velocity * 0.9
    end
    if sprite:IsFinished("Attack1") or sprite:IsFinished("Attack2") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(90,120)
    end
    if sprite:IsEventTriggered("Shoot") then
        if sprite:IsPlaying("Attack1") then
            local enchantee = mod:GetGrimoireTarget(npc, targetpos)
            if enchantee then
                --print(enchantee.Type)
                mod:AddGrimoireFlame(enchantee)
                data.DidEnchant = true
            end
            sfx:Play(SoundEffect.SOUND_SUMMONSOUND)  
        else
            local params = ProjectileParams()
            params.Color = mod.ColorMausPurple
            params.Scale = 2.5
            params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
            params.FallingAccelModifier = -0.2
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 0, params)
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                proj:GetData().projType = "Grimoire"
                proj:GetData().grimVel = 10
            end
            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(0,-15)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect.Color = mod.ColorMausPurple
            npc:PlaySound(mod.Sounds.WateryBarf,1.2,0,false,0.8)
        end
    elseif sprite:IsEventTriggered("Opening") then
        mod:PlaySound(mod.Sounds.PageTurning, npc, 1, 2)
    elseif sprite:IsEventTriggered("Stretch1") then
        mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 1, 0.5)
    elseif sprite:IsEventTriggered("Stretch2") then
        mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 1.2, 0.5)
    elseif sprite:IsEventTriggered("Close") then
        mod:PlaySound(mod.Sounds.BookShut, npc, 0.8, 1)
    end
end

function mod:GrimoireDeath(npc)
    sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
    sfx:Play(mod.Sounds.PaperDeath, 3)
    sfx:Play(SoundEffect.SOUND_THREAD_SNAP, 3)
    for i = 1, mod:RandomInt(2,3) do
        local page = Isaac.Spawn(mod.FF.PaperGib.ID, mod.FF.PaperGib.Var, mod.FF.PaperGib.Sub, npc.Position + RandomVector():Resized(mod:RandomInt(0,30)), Vector.Zero, npc)
        --mod:FlipSprite(page:GetSprite(), npc.Position, page.Position)
    end
end

function mod:GetGrimoireTarget(npc, targetpos)
    --return mod:GetNearestEnemy(targetpos, nil, npc:GetData().GrimoireFilter)
    local enchantees = mod:GetAllEnemies(npc:GetData().GrimoireFilter)
    if enchantees and #enchantees > 0 then
        local prefs = {}
        for _, entity in pairs(enchantees) do
            if not mod:CheckIDInTable(entity, FiendFolio.GrimoireLowPriority) then
                --print(entity.Type)
                table.insert(prefs, entity)
            end
        end
        local enchantee = mod:GetClosestEntityFromTable(targetpos, prefs)
        if enchantee then
            return enchantee
        else
            return mod:GetClosestEntityFromTable(targetpos, enchantees)
        end
    end
end

function mod:GetClosestEntityFromTable(pos, table)
    if table and #table > 0 then
        local nearest = nil
        local nearDist = 10000
        for _, entity in pairs(table) do
            nearest, nearDist = mod:DistanceCompare(nearDist, nearest, entity, pos)
        end
        return nearest
    end
end

function mod:GrimoireProjectile(projectile, data)
    if data.ImFallinBitch then
        projectile.Velocity = projectile.Velocity * 0.98
    else
        local targetpos = game:GetNearestPlayer(projectile.Position).Position
        projectile.Velocity = mod:Lerp(projectile.Velocity, (targetpos - projectile.Position):Resized(data.grimVel), 0.05)
        data.grimVel = data.grimVel - 0.05
        if data.grimVel <= 5 then
            data.ImFallinBitch = true
            projectile.FallingAccel = 1
        end
    end
    if projectile.FrameCount % 4 == 0 then
        local trail = Isaac.Spawn(1000, 111, 0, projectile.Position, projectile.Velocity:Rotated(mod:RandomInt(160,200)):Resized(3), projectile):ToEffect()
        trail.Color = mod.ColorMausPurple 
        trail.SpriteOffset = Vector(0, projectile.Height+20)
        trail.DepthOffset = -15
        trail:Update()
    end
end

function mod:PurpleFlameCrossProjDeath(projectile, data)
    mod:MakeFireWaveCross(projectile.Position, true, projectile)
end

function mod:GrimoireProjDeath(projectile, data)
    mod:MakeFireWaveCross(projectile.Position, true, projectile)
    game:BombExplosionEffects(projectile.Position, 10, 0, mod.ColorMausPurple, projectile, 1, true, true, DamageFlag.DAMAGE_EXPLOSION)
end

function mod:AddGrimoireFlame(npc)
    if npc:GetData().GrimoireEnchanted then
        local projectile = Isaac.Spawn(9,0,0,npc.Position,Vector.Zero,npc):ToProjectile()
        projectile.Color = mod.ColorMausPurple
        projectile.Scale = 2
        projectile.Height = -45
        projectile.FallingAccel = 1
        projectile:GetData().projType = "purpleFlameCross"
    else
        npc:GetData().GrimoireEnchanted = true
        npc:GetData().SkulltistHighPriority = true
        local flame = Isaac.Spawn(1000, mod.FF.GrimoireFlame.Var, mod.FF.GrimoireFlame.Sub, npc.Position, Vector.Zero, npc):ToEffect()
        flame.SpriteOffset = Vector(0, -30 + npc.Size * -1.0)
        flame:FollowParent(npc)
        flame.Parent = npc
        flame:Update()
    end
    local beam = Isaac.Spawn(1000,7010,0,npc.Position,Vector.Zero,npc):ToEffect()
    beam:GetSprite().Color = mod.ColorMausPurple
    beam:FollowParent(npc)
    beam.SpriteScale = Vector(0.5,1)
end

function mod:GrimoireFlameAI(effect, sprite, data)
    if not data.Init then
        sprite:Play("Idle")
        data.Init = true
    end
    if effect.Parent and not mod:IsReallyDead(effect.Parent) then
        --hi
    else
        local projectile = Isaac.Spawn(9,0,0,effect.Position,Vector.Zero,effect):ToProjectile()
        projectile.Color = mod.ColorMausPurple
        projectile.Scale = 2
        projectile.Height = -45
        projectile.FallingAccel = 1
        projectile:GetData().projType = "purpleFlameCross"
        effect:Remove()
    end
end

function mod:MakeFireWaveCross(pos, isPurple, spawner)
    local sub = 0
    if isPurple then
        sub = 1
    end
    for i = 0, 270, 90 do
        local wave = Isaac.Spawn(1000,148,sub,pos,Vector.Zero,spawner):ToEffect()
        wave.Rotation = i
    end
end

function mod:PaperGibAI(effect, sprite, data)
    if not data.Init then
        sprite.FlipX = (mod:RandomInt(1,2) == 1)
        sprite:SetFrame(mod:RandomInt(0,5))
        sprite.PlaybackSpeed = mod:RandomInt(12,28) * 0.05
        sprite:SetAnimation("Paper", false)
        data.Init = true
    end
    effect.Velocity = effect.Velocity * 0.9
    if sprite:IsFinished("Paper") then
        effect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
    end
end