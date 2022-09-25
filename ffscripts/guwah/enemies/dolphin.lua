local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:DolphinAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        if npc.SubType > 0 then
            data.Index = room:GetGridIndex(npc.Position)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            if npc.SubType == 2 then
                mod.makeWaitFerr(npc, npc.Type, npc.Variant, 1, 30)
            else
                if data.waited then
                    npc.Visible = true
                    mod.OccupiedGrids[data.Index] = "Closed"
                end
                mod:PlaySound(mod.Sounds.SplashLargePlonkless, npc)
                Isaac.Spawn(1000,132,0,npc.Position,Vector.Zero,npc)
                sprite:Play("Water Appear")
            end
            if room:GetFrameCount() <= 1 then
                room:SpawnGridEntity(data.Index, GridEntityType.GRID_PIT, 0, 0, 0)
            end
        else
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        end
        data.Init = true
    end
    if sprite:IsFinished("Appear") or sprite:IsFinished("Water Jump") then
        npc.StateFrame = mod:RandomInt(25,50)
        sprite:Play("Idle")
    elseif sprite:IsFinished("Shoot") or sprite:IsFinished("Shoot 2") then
        npc.Velocity = Vector.Zero
        npc.Visible = false
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.Index = mod:GetUnoccupiedPit(data.Index or room:GetGridIndex(npc.Position)) 
            mod.OccupiedGrids[data.Index] = "Closed"
            npc.Position = room:GetGridPosition(data.Index)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.Visible = true
            mod:PlaySound(mod.Sounds.SplashLargePlonkless, npc)
            Isaac.Spawn(1000,132,0,npc.Position,Vector.Zero,npc)
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
            sprite:Play("Water Appear")
            mod:FlipSprite(sprite, targetpos, npc.Position)
        end
    elseif sprite:IsFinished("Shoot_Jumpless") or sprite:IsFinished("Shoot 2_Jumpless") then
        npc.StateFrame = mod:RandomInt(40,60)
        sprite:Play("Idle")
    elseif sprite:IsFinished("Water Appear") then
        npc.StateFrame = mod:RandomInt(20,40)
        sprite:Play("Water Idle")
    end

    if sprite:IsPlaying("Idle") then
        npc.Velocity = npc.Velocity * 0.7
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            local anim = "Shoot 2"
            if mod:RandomInt(1,5) == 1 then
                anim = "Shoot"
            end
            local pit = mod:GetNearestGridIndexOfType(GridEntityType.GRID_PIT, GridCollisionClass.COLLISION_PIT, npc.Position)
            if pit then
                npc.TargetPosition = room:GetGridPosition(pit)
            else
                anim = anim .. "_Jumpless"
            end
            sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
            sprite:Play(anim)
            npc.StateFrame = mod:RandomInt(20,40)
        end
    end

    if sprite:IsPlaying("Water Idle") then
        mod.NegateKnockoutDrops(npc)
        npc.Velocity = Vector.Zero
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            sprite:Play("Water Jump")
        end
    end

    if sprite:IsEventTriggered("Shoot") then
        local params = ProjectileParams()
        params.Scale = 2
        params.FallingAccelModifier = -0.2
        params.BulletFlags = ProjectileFlags.BOUNCE
        params.Variant = 4
        local vec = (targetpos - npc.Position)
        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position, vec:Resized(12), 0, params)
        for _, projectile in pairs(mod:GetGatheredProjectiles()) do
            projectile:GetData().projType = "Dolphin"
        end
        npc.Velocity = npc.Velocity + vec:Resized(-5)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
        effect.DepthOffset = npc.Position.Y * 1.25
        effect.SpriteOffset = Vector(0,-22)
        effect.Color = mod.ColorSolidWater
        mod:FlipSprite(sprite, targetpos, npc.Position)
        sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, math.random(8, 11)/10)
    end

    if sprite:IsEventTriggered("Jump") then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        if sprite:IsPlaying("Water Jump") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.TargetPosition = mod:GetNearestPosOfCollisionClass(npc.Position, GridCollisionClass.COLLISION_NONE)
            mod.OccupiedGrids[data.Index] = "Open"
        end
        npc.Velocity = (npc.TargetPosition - npc.Position) / 18
        mod:FlipSprite(sprite, npc.TargetPosition, npc.Position)
    end

    if not sprite:WasEventTriggered("Jump") then
        npc.Velocity = npc.Velocity * 0.8
    elseif sprite:WasEventTriggered("Land") then
        npc.Velocity = npc.Velocity * 0.8
    end

    if sprite:IsEventTriggered("Land") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS_OLD, 1, 0, false, math.random(8, 11)/10)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 16, 3, npc.Position, Vector.Zero, npc)
        effect.Color = mod.ColorSolidWater
        effect.SpriteScale = effect.SpriteScale * 0.7
    end

    if sprite:IsEventTriggered("Laugh") then
        mod:PlaySound(mod.Sounds.DolphinLaugh, npc, 1, 1.5)
    end

    if sprite:IsEventTriggered("Splash") then
        Isaac.Spawn(1000,132,0,npc.Position,Vector.Zero,npc)
        mod:PlaySound(mod.Sounds.SplashLarge, npc)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
    end
end

function mod:DolphinProjectile(projectile, data)
    if data.Fallen then
        projectile.Velocity = projectile.Velocity * 0.9
    else
        projectile.Velocity = projectile.Velocity * 0.985
        if projectile.FrameCount % 3 == 0 then
            local trail = Isaac.Spawn(1000, 111, 0, projectile.Position, projectile.Velocity:Rotated(math.random(-45, 45)) * math.random(-10, 20)/100, projectile)
            trail.Color = mod.ColorLessSolidWater
            trail.SpriteScale = Vector(0.7,0.7)
            trail.SpriteOffset = Vector(0, projectile.Height + 23)
            trail.DepthOffset = -15
            trail:Update()
        end
        if projectile.FrameCount % 12 == 0 then
            local proj = Isaac.Spawn(9, 4, 0, projectile.Position, projectile.Velocity:Rotated(math.random(-45, 45)) * math.random(-10, 20)/100, projectile):ToProjectile()
            proj.FallingAccel = 0.05
            proj.Height = projectile.Height
            proj:Update()
        end
        if projectile.Velocity:Length() < 3 then
            data.Fallen = true
            projectile.FallingAccel = 1
        end
    end
end