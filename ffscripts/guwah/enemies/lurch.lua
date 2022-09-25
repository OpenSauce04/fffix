local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:LurchAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(80,120)
        data.Init = true
    end
    if sprite:IsPlaying("Idle") then
        local vel = math.min(100,npc.Position:Distance(targetpos)) / 100
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(vel)), 0.3)
        mod:FlipSprite(sprite, targetpos, npc.Position)
        if npc.StateFrame <= 0 then
            sprite:Play("Attack")
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    else
        npc.Velocity = Vector.Zero
    end
    if sprite:IsEventTriggered("Warn") then
        mod:PlaySound(SoundEffect.SOUND_SATAN_CHARGE_UP, npc, 1.2)
    elseif sprite:IsEventTriggered("Shoot") then
        mod:FlipSprite(sprite, targetpos, npc.Position)
        data.Trajectory = targetpos - npc.Position
        npc.V1 = npc.Position + data.Trajectory:Rotated(-45):Resized(20)
        npc.V2 = npc.Position + data.Trajectory:Rotated(45):Resized(20)
        local effect = Isaac.Spawn(1000, 16, 5, npc.Position, Vector.Zero, npc):ToEffect()
        effect.DepthOffset = npc.Position.Y * 1.25
        effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
        effect.SpriteOffset = Vector(0,-20)
        sfx:Play(SoundEffect.SOUND_HEARTIN)
        sfx:Play(SoundEffect.SOUND_HEARTOUT)
        mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 0.8)
        data.Creeping = 15
    elseif sprite:IsEventTriggered("Lash") then
        local vel = (targetpos - npc.Position):Resized(50)
        local tip = Isaac.Spawn(mod.FF.LurchGutTip.ID, mod.FF.LurchGutTip.Var, 0, npc.Position, vel, npc)
        tip.SpriteRotation = mod:GetAngleDegreesButGood(vel) - 90
        local cord = Isaac.Spawn(mod.FF.LurchGuts.ID, mod.FF.LurchGuts.Var, mod.FF.LurchGuts.Sub, npc.Position, Vector.Zero, npc)
		cord:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if mod:isFriend(npc) then
            tip.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
        else
            tip.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end
		cord.Parent = npc
        cord.Target = tip
        cord.TargetPosition = Vector.One
        tip.Child = cord
        tip.Parent = npc
        cord:Update()
        tip.SpriteOffset = Vector(0,-12)
        tip.DepthOffset = npc.Position.Y * 1.25
        cord.DepthOffset = npc.Position.Y * 1.25
        local effect = Isaac.Spawn(1000,2,4,npc.Position,Vector.Zero,npc)
        effect.DepthOffset = npc.Position.Y * 1.25
        effect.SpriteOffset = Vector(0,-20)
        sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
        sfx:Play(SoundEffect.SOUND_WHIP)
    elseif sprite:IsEventTriggered("Shut") then
        --mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 0.8)
    end
    if data.Creeping then
        local params = ProjectileParams()
        params.FallingAccelModifier = 1
        local creep = Isaac.Spawn(1000, 22, 0, npc.V1, Vector.Zero, npc):ToEffect()
        creep:SetTimeout(40)
        params.FallingSpeedModifier = mod:RandomInt(-10,-5)
        npc:FireProjectiles(npc.V1, data.Trajectory:Resized(8):Rotated(-45 + mod:RandomInt(-30,30)), 0, params)
        if rng:RandomFloat() <= 0.5 then
            Isaac.Spawn(1000, 2, 0, npc.V1, Vector.Zero, npc)
        else
            Isaac.Spawn(1000, 2, 2, npc.V1, Vector.Zero, npc)
        end
        creep = Isaac.Spawn(1000, 22, 0, npc.V2, Vector.Zero, npc):ToEffect()
        creep:SetTimeout(40)
        params.FallingSpeedModifier = mod:RandomInt(-10,-5)
        npc:FireProjectiles(npc.V2, data.Trajectory:Resized(8):Rotated(45 + mod:RandomInt(-30,30)), 0, params)      
        if rng:RandomFloat() <= 0.5 then
            Isaac.Spawn(1000, 2, 0, npc.V2, Vector.Zero, npc)
        else
            Isaac.Spawn(1000, 2, 2, npc.V2, Vector.Zero, npc)
        end
        npc.V1 = npc.V1 + data.Trajectory:Rotated(-45):Resized(20)
        npc.V2 = npc.V2 + data.Trajectory:Rotated(45):Resized(20)
        data.Creeping = data.Creeping - 1
        if data.Creeping <= 0 then
            data.Creeping = nil
        end
    end
    if sprite:IsFinished("Attack") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(140,180)
    end
end

function mod:LurchGutsAI(npc, sprite, data)
    npc.SplatColor = Color(1,1,1,1,0,0,0)
    --[[if npc.Target then
        if not data.Hitted then
            npc.Target:TakeDamage(1, 0, EntityRef(npc.Parent), 30)
            npc.Target.Velocity = (npc.Parent.Position - npc.Target.Position):Resized(10)
            sfx:Play(SoundEffect.SOUND_WHIP_HIT)
            data.Hitted = true
            npc:Kill() 
        end
        sfx:Stop(SoundEffect.SOUND_MEATY_DEATHS)
        npc.Target = nil
    end]]
end

function mod:LurchGutTipAI(npc, sprite, data)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:Play("Tip")
        data.Init = true
    end
    npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position - npc.Position):Resized(120), 0.03)
    if npc.Parent and npc.Parent:Exists() then
        if data.ReelItIn and npc.Position:Distance(npc.Parent.Position) < 30 then
            if npc.Child and npc.Child:Exists() then
                npc.Child:Remove()
            end
            npc.Visible = false
            npc:Remove()
        elseif npc.FrameCount > 10 then
            data.ReelItIn = true
        end
    else
        npc:Kill()
    end
end

function mod:LurchGutTipColl(npc, collider)
    local data = npc:GetData()
    if collider:ToPlayer() and collider:ToPlayer():GetDamageCooldown() <= 0 then
        collider:TakeDamage(1, 0, EntityRef(npc), 0)
        collider.Velocity = (npc.Parent.Position - collider.Position):Resized(12)
        npc.Velocity = (npc.Parent.Position - npc.Position):Resized(12)
        sfx:Play(SoundEffect.SOUND_WHIP_HIT)
        data.ReelItIn = true
    elseif collider:ToNPC() and not mod:isFriend(collider) then
        collider:TakeDamage(10, 0, EntityRef(npc), 0)
        collider.Velocity = (npc.Parent.Position - collider.Position):Resized(12)
        npc.Velocity = (npc.Parent.Position - npc.Position):Resized(12)
        if not sfx:IsPlaying(SoundEffect.SOUND_WHIP_HIT) then
            sfx:Play(SoundEffect.SOUND_WHIP_HIT)
        end
        data.ReelItIn = true
    end
    return true
end