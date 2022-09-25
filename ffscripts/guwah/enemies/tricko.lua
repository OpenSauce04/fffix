local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:TrickoAI(npc, sprite, data)
    if not data.Init then
        data.state = "appear"
        npc.Target = game:GetPlayer(0)
        npc.SplatColor = mod.ColorMinMinFireJuicier
        local params = ProjectileParams()
        params.Variant = 4
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        params.Color = mod.ColorMinMinFire
        data.Params = params
        npc.StateFrame = mod:RandomInt(30,60) + (mod:RandomInt(0,15) * mod.GetEntityCount(mod.FF.Tricko.ID, mod.FF.Tricko.Var) - 1)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.Trail = Isaac.Spawn(1000,166,0,npc.Position,Vector.Zero,npc):ToEffect()
        data.Trail:FollowParent(npc)
        data.Trail.ParentOffset = Vector(0,-35)
        local color = Color(1,1,1,1,0.6,0.5,0.05)
        color:SetColorize(1, 0.8, 0.1, 3)
        data.Trail.Color = color
        sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
        data.Init = true
    end
    if data.state == "appear" then
        mod:SetTrickoPos(npc, data)
        if sprite:IsFinished("Appear") then
            data.state = "idle"
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "idle" then
        mod:SetTrickoPos(npc, data)
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.state = "shoot"
            sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
        else
            mod:spritePlay(sprite, "Idle01")
        end
    elseif data.state == "shoot" then
        mod:SetTrickoPos(npc, data)
        if sprite:IsFinished("Attack") then
            data.state = "dashstart"
        elseif sprite:IsEventTriggered("Warn") then
            mod:PlaySound(SoundEffect.SOUND_FIRE_RUSH, npc, 1.5, 0.8)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_BEAST_LAVABALL_RISE, npc, 1.2)
            npc:FireProjectiles(npc.Position, (npc.Target.Position - npc.Position):Resized(9), 0, data.Params)
            local effect = Isaac.Spawn(1000, 2, 1, npc.Position, Vector.Zero, npc):ToEffect()
            effect:FollowParent(npc)
            effect.ParentOffset = Vector(0,1)
            effect.SpriteOffset = Vector(0,-17)
            effect.Color = mod.ColorMinMinFireJuicier
        else
            mod:spritePlay(sprite, "Attack")
        end
    elseif data.state == "dashstart" then
        mod:SetTrickoPos(npc, data)
        if sprite:IsEventTriggered("Shoot") then
            sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            local angleshift = mod:RandomInt(60, 180)
            if mod:RandomInt(1,2) == 1 then
                angleshift = -angleshift
            end
            data.Angle = data.Angle + angleshift
            data.Trail = Isaac.Spawn(1000,166,0,npc.Position,Vector.Zero,npc):ToEffect()
            data.Trail:FollowParent(npc)
            data.Trail.ParentOffset = Vector(0,-35)
            local color = Color(1,1,1,1,0.6,0.5,0.05)
            color:SetColorize(1, 0.8, 0.1, 3)
            data.Trail.Color = color
            data.state = "dash"
        else
            mod:spritePlay(sprite, "Dash")
        end
    elseif data.state == "dash" then
        mod:SetTrickoPos(npc, data)
        if sprite:IsFinished("Dash") then
            npc.Visible = false
        end
        if npc.Position:Distance(npc.TargetPosition) <= 10 then
            npc.Visible = true
            data.state = "dashend"
        end
    elseif data.state == "dashend" then
        mod:SetTrickoPos(npc, data)
        if sprite:IsFinished("DashEnd") then
            npc.StateFrame = mod:RandomInt(30,60)
            data.state = "idle"
        else
            mod:spritePlay(sprite, "DashEnd")
        end
    elseif data.state == "extinguish" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished("Transition") then
            data.state = "run"
        else
            mod:spritePlay(sprite, "Transition")
        end
    elseif data.state == "run" then
        local targetpos = game:GetNearestPlayer(npc.Position).Position
        npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(8), 0.05)
        if npc.Position:Distance(targetpos) > 700 then
            npc:Remove()
        end
        mod:spritePlay(sprite, "Idle02")
    end
    if game:GetRoom():IsClear() and not (data.state == "dash" or data.neutered) then
        npc.Velocity = Vector.Zero
        mod:PlaySound(SoundEffect.SOUND_BEAST_FIRE_RING, npc, 1, 0.8)
        npc.MaxHitPoints = 10
        npc.HitPoints = math.min(npc.HitPoints, 10)
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        data.state = "extinguish"
        if data.Trail then
            data.Trail:Remove()
        end
        data.neutered = true
    end
end

function mod:SetTrickoPos(npc, data)
    if not data.AngleInit and npc.FrameCount > 0 then --This is purely for BR lol
        data.CurrentAngle = (npc.Position - npc.Target.Position):GetAngleDegrees()
        data.Angle = data.CurrentAngle + mod:RandomInt(-40,40)
        data.AngleInit = true
    end
    if data.AngleInit then
        local diff = data.CurrentAngle - data.Angle 
        if diff > 0 then
            data.CurrentAngle = data.CurrentAngle - math.min(30, diff)
        else
            data.CurrentAngle = data.CurrentAngle - math.max(-30, diff)
        end
        npc.TargetPosition = npc.Target.Position + Vector.One:Resized(150):Rotated(data.CurrentAngle)
        local length = math.min(50, npc.Position:Distance(npc.TargetPosition))
        npc.Velocity = (npc.TargetPosition - npc.Position):Resized(length)
        if data.Trail then
            if length > 10 then
                local targetpos = npc.TargetPosition + data.Trail.ParentOffset
                data.Trail.Velocity = npc.TargetPosition - data.Trail.Position
            else
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                data.RemoveTrailSoon = data.RemoveTrailSoon or 12
            end
            if data.RemoveTrailSoon then
                data.RemoveTrailSoon = data.RemoveTrailSoon - 1
                if data.RemoveTrailSoon <= 0 then
                    data.Trail:Remove()
                    data.Trail = nil
                    data.RemoveTrailSoon = nil
                end
            end
        end
    end
end

function mod:TrickoHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) then
        return false
    else
        if data.state == "idle" or data.state == "shoot" then
            data.state = "dashstart"
        end
    end
end