local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:SquidAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc.SplatColor = mod.ColorDankBlackReal
        npc.StateFrame = mod:RandomInt(20,40)
        data.AttackCount = mod:RandomInt(1,2)
        data.Init = true
    end
    if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") or sprite:IsFinished("Move") then
        sprite:Play("Idle")
    end
    local vel
    local lerpval = 0.05
    if sprite:IsEventTriggered("Move") then
        vel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(12))
        lerpval = 0.5
        npc:PlaySound(mod.Sounds.WaterSwish,1,0,false,0.8)
    elseif sprite:IsEventTriggered("Shoot") then
        mod:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, npc, 0.8)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1, 2)
        vel = (npc.Position - targetpos):Resized(18) 
        lerpval = 0.5
        data.Shootvel = (targetpos - npc.Position):Resized(8) 
        npc.I1 = 8
        for i = -40, 40, 80 do
            local projectile = Isaac.Spawn(9,0,0,npc.Position,data.Shootvel:Rotated(i),npc):ToProjectile()
            projectile.Color = mod.ColorDankBlackReal
            projectile:GetData().creeptype = "black"
            mod:ProjectileFriendCheck(npc, projectile)
        end
        local bigink = Isaac.Spawn(9,0,0,npc.Position,data.Shootvel:Resized(10),npc):ToProjectile()
        bigink.Color = mod.ColorDankBlackReal
        bigink.Scale = 2
        bigink.FallingSpeed = 10
        bigink.FallingAccel = 2
        bigink:GetData().projType = "skipInk"
        mod:ProjectileFriendCheck(npc, bigink)
        local effect = Isaac.Spawn(1000, 2, 2, npc.Position, Vector.Zero, npc)
        effect.Color = mod.ColorDankBlackReal
        effect.SpriteOffset = Vector(0,-20)
        effect.DepthOffset = npc.Position.Y * 1.25
    elseif sprite:IsPlaying("Idle") then
        vel = (targetpos - npc.Position):Resized(1) 
    else
        vel = Vector.Zero
    end
    vel = mod:reverseIfFear(npc, vel)
    npc.Velocity = mod:Lerp(npc.Velocity, vel, lerpval)
    if npc.StateFrame <= 0 then
        if data.AttackCount <= 0 then
            sprite:Play("Shoot")
            npc.StateFrame = mod:RandomInt(40,60)
            data.AttackCount = mod:RandomInt(1,2)
        else
            sprite:Play("Move")
            npc.StateFrame = mod:RandomInt(20,40)
            data.AttackCount = data.AttackCount - 1
        end
    elseif sprite:IsPlaying("Idle") then
        npc.StateFrame = npc.StateFrame - 1
    end
    if npc.I1 > 0 then
        npc.I1 = npc.I1 - 1
        if npc.I1 == 4 then
            local bigink = Isaac.Spawn(9,0,0,npc.Position,data.Shootvel:Resized(10),npc):ToProjectile()
            bigink.Color = mod.ColorDankBlackReal
            bigink.Scale = 1.5
            bigink.FallingSpeed = -15
            bigink.FallingAccel = 2
            bigink:GetData().projType = "skipInk"
            mod:ProjectileFriendCheck(npc, bigink)
        elseif npc.I1 == 1 then
            local bigink = Isaac.Spawn(9,0,0,npc.Position,data.Shootvel:Resized(10),npc):ToProjectile()
            bigink.Color = mod.ColorDankBlackReal
            bigink.Scale = 1
            bigink.FallingSpeed = -15
            bigink.FallingAccel = 2
            bigink:GetData().projType = "skipInk"
            mod:ProjectileFriendCheck(npc, bigink)
        end
    end
end

function mod:SkippingInkProjectile(projectile, data)
    if projectile.Height >= -10 then
        local sprite = projectile:GetSprite()
        local ink = Isaac.Spawn(1000, 26, 0, projectile.Position, Vector.Zero, projectile):ToEffect()
        ink.Scale = 1 - ((2 - projectile.Scale)/0.6)
        ink:SetTimeout(300)
        ink:Update()
        local effect = Isaac.Spawn(mod.FF.LargeWaterRipple.ID, mod.FF.LargeWaterRipple.Var, mod.FF.LargeWaterRipple.Sub, projectile.Position, Vector.Zero, projectile)
        effect:GetSprite().Scale = (effect:GetSprite().Scale * projectile.Scale) / 2
        effect.Color = Color(0.1,0.1,0.1)
        mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, nil, 1.5, 0.5)
        local new = Isaac.Spawn(9, 0, 0, projectile.Position, projectile.Velocity, projectile.SpawnerEntity):ToProjectile()
        new.Color = projectile.Color
        new.Scale = projectile.Scale
        new.FallingSpeed = -15
        new.FallingAccel = 2
        new.Height = projectile.Height
        new:GetSprite():SetFrame(sprite:GetFrame()) 
        new:GetSprite():Play(sprite:GetAnimation())
        new:GetData().projType = data.projType
        new.ProjectileFlags = projectile.ProjectileFlags
        projectile:Remove()
    end
end