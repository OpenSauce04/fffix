local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:KukodemonAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        sprite:Play("Appear")
        data.Init = true
    end
    if sprite:IsFinished("Appear") then
        npc.StateFrame = mod:RandomInt(45,90)
        sprite:Play("Idle")
    elseif sprite:IsFinished("Shoot") then
        npc.StateFrame = mod:RandomInt(120,200)
        sprite:Play("Idle")
    end
    if sprite:IsPlaying("Idle") then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(1)), 0.3)
        mod:FlipSprite(sprite, targetpos, npc.Position)
        if npc.StateFrame <= 0 then
            sprite:Play("Shoot")
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    else
        npc.Velocity = npc.Velocity * 0.8
    end
    if sprite:IsEventTriggered("Flap") then
        mod:PlaySound(SoundEffect.SOUND_ANGEL_WING, npc, 1.5, 0.5)
    elseif sprite:IsEventTriggered("Shoot") then
        local vel = targetpos - npc.Position
        local projectile = Isaac.Spawn(9,0,0,npc.Position,vel:Resized(2),npc):ToProjectile()
        projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.BOUNCE)
        projectile.Color = mod.ColorDecentlyRed
        projectile.FallingAccel = -0.1
        projectile.Scale = 3
        projectile:GetData().projType = "Kukodemon"
        npc.Velocity = vel:Rotated(180):Resized(10)
        mod:PlaySound(SoundEffect.SOUND_SATAN_BLAST, npc, 2.5, 0.5)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 0.8, 1.5)
        mod:PlaySound(SoundEffect.SOUND_ANGEL_WING, npc, 3, 0.5)
        mod:FlipSprite(sprite, targetpos, npc.Position)
        local effect = Isaac.Spawn(1000,16,5,npc.Position,Vector.Zero,npc):ToEffect()
        effect.DepthOffset = npc.Position.Y * 1.25
        effect:GetSprite().Scale = effect:GetSprite().Scale * 0.6
        effect.Color = Color(1,1,1,0.5)
        effect.SpriteOffset = Vector(0,-25)
        effect:Update()
        for i = -60, 60, 15 do
            local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, Vector(0, -5):Rotated(i - 10 + math.random(20)), npc):ToEffect()
            smoke:GetData().longonly = true
            smoke.SpriteRotation = mod:RandomAngle()
            smoke.Color = Color(0,0,0,0.5,0.7,0,0)
            smoke.SpriteScale = smoke.SpriteScale * mod:RandomInt(70,100)/100
            smoke.DepthOffset = npc.Position.Y * 1.25
            smoke.SpriteOffset = Vector(0,-25)
            smoke:Update()
        end
    end
end

function mod:KukodemonProjectile(projectile, data)
    if projectile.FrameCount == 30 then
        for i = 0, 270, 90 do
            Isaac.Spawn(9,0,0,projectile.Position,Vector(10,0):Rotated(i),projectile)
        end
        local effect = Isaac.Spawn(1000,2,5,projectile.Position,projectile.Velocity,projectile):ToEffect()
        effect.SpriteOffset = Vector(0, -12)
        effect.DepthOffset = projectile.DepthOffset * 1.25
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, nil, 1, 1)
        --effect:FollowParent(projectile)
    elseif projectile.FrameCount == 60 then
        for i = 45, 315, 90 do
            Isaac.Spawn(9,0,0,projectile.Position,Vector(10,0):Rotated(i),projectile)
        end
        local effect = Isaac.Spawn(1000,2,5,projectile.Position,projectile.Velocity,projectile):ToEffect()
        effect.SpriteOffset = Vector(0, -12)
        effect.DepthOffset = projectile.DepthOffset * 1.25
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, nil, 1.5, 1)
        --effect:FollowParent(projectile)
    elseif projectile.FrameCount == 90 then
        for i = 0, 315, 45 do
            Isaac.Spawn(9,0,0,projectile.Position,Vector(10,0):Rotated(i),projectile)
        end
        local effect = Isaac.Spawn(1000,2,5,projectile.Position,Vector.Zero,projectile):ToEffect()
        effect.SpriteOffset = Vector(0, -12)
        effect.DepthOffset = projectile.DepthOffset * 1.25
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, nil, 2, 1)
        mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, nil, 2, 0.8)
        local creep = Isaac.Spawn(1000,22,0,projectile.Position,Vector.Zero,projectile):ToEffect()
        creep:SetTimeout(30)
        projectile:Die()
    end
end