local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ArcaneCreepAI(npc, sprite, data)
    if not data.Init then 
        sprite:PlayOverlay("IdleFlame")
        sprite:SetOverlayRenderPriority(true)
        data.StateFrame = mod:RandomInt(10,30)
        data.Init = true
    end
    if not data.Attacking then
        data.StateFrame = data.StateFrame - 1
        if npc.State == 8 then
            if data.StateFrame >= 0 then
                npc.State = 4
            else
                sprite:RemoveOverlay()
                data.Attacking = true
            end
        end
    else
        if sprite:IsFinished("Attack") then
            sprite:PlayOverlay("IdleFlame")
            data.StateFrame = mod:RandomInt(50,70)
            data.Attacking = false
        end
        if sprite:IsEventTriggered("ArcaneShoot") then
            local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,5):Rotated(npc.SpriteRotation), npc):ToProjectile()
            mod:ProjectileFriendCheck(npc, projectile)
            projectile.Scale = 2.2
            projectile.FallingAccel = -0.1
            if mod:CheckStage("Gehenna", {47}) then
                projectile.Color = mod.ColorGehennaFire2
            else
                projectile.Color = mod.ColorArcanePink
            end
            local projectiledata = projectile:GetData()
            projectiledata.projType = "arcaneCreep"
            if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
                projectiledata.SplitTrajectory = Vector(5,0)
            else
                projectiledata.SplitTrajectory = Vector(0,5)
            end
            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            if mod:CheckStage("Gehenna", {47}) then
                effect.Color = mod.ColorGehennaFire2A
            else
                effect.Color = mod.ColorArcanePinkA
            end
            if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
                effect.SpriteOffset = Vector(-10,0):Rotated(npc.SpriteRotation + 90)
            else
                effect.SpriteOffset = Vector((-10 * npc.SpriteRotation) / -90, -18)
            end
            effect.SpriteRotation = npc.SpriteRotation
            effect.DepthOffset = npc.Position.Y * 1.25
            npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_HISS, 0.7, 0, false, 1)
        end
    end
end

function mod:ArcaneCreepProjectile(projectile, data)
    if projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER + ProjectileFlags.HIT_ENEMIES) then
        for _, enemy in pairs(Isaac.FindInRadius(projectile.Position, 500, EntityPartition.ENEMY)) do
            if enemy:IsEnemy() and not mod:isFriend(enemy) then
                if data.SplitTrajectory.Y == 0 and math.abs(enemy.Position.Y - projectile.Position.Y) < 10 then
                    mod:ArcaneShotSplit(projectile, projectile.Position)    
                elseif data.SplitTrajectory.X == 0 and math.abs(enemy.Position.X - projectile.Position.X) < 10 then
                    mod:ArcaneShotSplit(projectile, projectile.Position)
                end
            end
        end
    else
        for _, player in pairs(Isaac.FindByType(1, -1, -1, false, false)) do
            if data.SplitTrajectory.Y  == 0 and math.abs(player.Position.Y - projectile.Position.Y) < 10 then
                mod:ArcaneShotSplit(projectile, projectile.Position)    
            elseif data.SplitTrajectory.X == 0 and math.abs(player.Position.X - projectile.Position.X) < 10 then
                mod:ArcaneShotSplit(projectile, projectile.Position)
            end
        end
    end
    if projectile:CollidesWithGrid() then
        mod:ArcaneShotSplit(projectile, projectile.Position - projectile.Velocity:Resized(10))
    end
    if projectile.FrameCount % 3 == 0 then
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, projectile.Position, projectile.Velocity:Resized(-3), projectile):ToEffect()
        trail.SpriteScale = Vector(0.7,0.7)
        trail.SpriteOffset = Vector(0, projectile.Height+6)
        trail.DepthOffset = -15
        trail.Color = projectile.Color
        trail:Update()
    end
end

function mod:ArcaneShotSplit(projectile, spawnpos)
    local data = projectile:GetData()
    if not data.Split then
        for i = 0, 180, 180 do
            local split = Isaac.Spawn(9, 0, 0, spawnpos, data.SplitTrajectory:Rotated(i), projectile):ToProjectile()  
            split:AddProjectileFlags(projectile.ProjectileFlags + ProjectileFlags.ACCELERATE)
            split.Acceleration = 1.05
            split.Color = projectile.Color
        end
        projectile:Die() 
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
        data.Split = true
    end
end