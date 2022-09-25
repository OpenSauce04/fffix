local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:ObserverAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local room = game:GetRoom()
    mod.NegateKnockoutDrops(npc)
    npc.Velocity = Vector.Zero
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.state = "appear"
        data.angle = 22.5 * (npc.SubType >> 2 & 15)
        npc.StateFrame = 0
        --[[local tracer = Isaac.Spawn(1000, 198, 0, npc.Position + Vector(0,15), Vector(0.001,0), npc):ToEffect()
        tracer:SetTimeout(50)
        tracer.LifeSpan = 999
        tracer:GetData().Observer = 0.05]]
        local tracer = Isaac.Spawn(mod.FF.CustomTracer.ID, mod.FF.CustomTracer.Var, mod.FF.CustomTracer.Sub, npc.Position, Vector.Zero, npc):ToEffect()
        tracer.Color = Color(1,0.7,0.5,0.1)
        local _, endPos = room:CheckLine(tracer.Position, tracer.Position + Vector(1000,0):Rotated(data.angle), 3)
        endPos = mod:FixLaserBug(data.angle, room, endPos)
        tracer.TargetPosition = endPos
        tracer:Update()
        data.tracer = tracer
        data.angleshift = 2.5
        if (npc.SubType & 1) == 1 then
            data.angleshift = -data.angleshift
		end
        if (npc.SubType >> 1 & 1) == 1 then
            data.lilwimp = true
        else
            npc.CanShutDoors = true
        end
        if room:GetFrameCount() <= 1 then
            room:SpawnGridEntity(room:GetGridIndex(npc.Position), GridEntityType.GRID_PIT, 0, 0, 0)
            mod:UpdatePits()
        end
        data.Params = ProjectileParams()
        data.Params.Variant = 4
        data.Params.Color = mod.ColorKickDrumsAndRedWine
        data.Init = true
    end
    if data.state == "appear" then
        if sprite:IsFinished("Appear") and npc.FrameCount > 1 then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            sprite:Play("Scan0")
            data.state = "idle"
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "idle" then
        data.angle = (data.angle + data.angleshift) % 360
        local vec = Vector(1,0):Rotated(data.angle)
        local targvec = (targetpos - npc.Position)
        local _, endPos = room:CheckLine(data.tracer.Position, data.tracer.Position + Vector(1000,0):Rotated(data.angle), 3)
        data.tracer.TargetPosition = endPos
        local val = (math.floor((((data.angle - 90)% 360) + 22.5)/45))
        if val > 7 then
            val = 0
        end
        sprite:SetAnimation("Scan"..val, false)
        local anglediff = mod:GetAbsoluteAngleDifference(vec, targvec)
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if math.abs(anglediff) < 5 and room:CheckLine(npc.Position, targetpos, 3, 0, false, false) then
                data.state = "spotted"
                npc:PlaySound(mod.Sounds.EpicTwinkle,1,1,false,0.8)
                data.tracer.Color = Color(1,0.2,0.6,0.3)
            else
                data.tracer.Color = Color(1,0.7,0.5,0.3)
            end
        end
        if data.lilwimp and game:GetRoom():IsClear() then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.tracer:Remove()
            data.state = "flee"
        end
    elseif data.state == "spotted" then
        if sprite:IsFinished("LaserStart") then
            data.state = "lasering"
            mod:spritePlay(sprite, "LaserLoop")
        elseif sprite:IsEventTriggered("Shoot") then
            local laser = EntityLaser.ShootAngle(2, npc.Position + Vector(0,1), data.angle, 90, Vector.Zero, npc)
            laser.Color = mod.ColorPsy
            laser.Parent = npc
            laser.PositionOffset = Vector(0,-25)
            local _, OGendPos = room:CheckLine(laser.Position, laser.Position + Vector(1000,0):Rotated(data.angle), 3)
            local endPos = mod:FixLaserBug(laser.AngleDegrees, room, OGendPos)
            laser:SetMaxDistance(laser.Parent.Position:Distance(endPos))
            laser.CollisionDamage = 0
            data.laser = laser
            data.tracer.Color = mod.ColorInvisible
            npc:FireProjectiles(endPos, Vector(10,0), 8, data.Params)
            local effect = Isaac.Spawn(1000, 2, 5, OGendPos, Vector.Zero, npc)
            effect.Color = mod.ColorPsy
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
        else
            mod:spritePlay(sprite, "LaserStart")
        end
    elseif data.state == "lasering" then
        if data.lilwimp and game:GetRoom():IsClear() then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.tracer:Remove()
            data.laser:Remove()
            data.state = "flee"
        else
            if data.laser.Timeout <= 0 then
                data.state = "stoplaser"
                data.laser = nil
            else
                mod:spritePlay(sprite, "LaserLoop")
            end
        end
    elseif data.state == "stoplaser" then
        if sprite:IsFinished("LaserEnd") then
            data.state = "idle"
            sprite:Play("Scan0")
            npc.StateFrame = 30
            data.tracer.Color = Color(1,0.7,0.5,0.1)
        else
            mod:spritePlay(sprite, "LaserEnd")
        end
    elseif data.state == "flee" then
        if sprite:IsFinished("Hide") then
            npc:Remove()
        else
            mod:spritePlay(sprite, "Hide")
        end
    end
    if data.laser then
        local _, endPos = room:CheckLine(data.laser.Position, data.laser.Position + Vector(1000,0):Rotated(data.angle), 3)
        endPos = mod:FixLaserBug(data.laser.AngleDegrees, room, endPos)
        data.laser:SetMaxDistance(data.laser.Position:Distance(endPos))
    end
end

function mod:ObserverHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if data.state == "idle" then
        data.angle = data.angle + (data.angleshift * 5)
    end
end

function mod:ObserverRemove(npc, sprite, data)
    if npc:GetData().tracer then
        npc:GetData().tracer:Remove()
    end
end

local tracerbeam = Sprite()
tracerbeam:Load("gfx/enemies/pitsentry/custom_tracer.anm2", true)
tracerbeam:Play("Beam", true)

function mod:CustomTracerUpdate(effect, sprite, data)
    mod:spritePlay(sprite, "Start")
    effect.SpriteScale = Vector(0.7,0.7)
    data.BeamLength = effect.Position:Distance(effect.TargetPosition)
end

function mod:CustomTracerRender(effect, sprite, data, isPaused, isReflected)
    if not isReflected then
        local angle = mod:GetAngleDegreesButGood(effect.Position - effect.TargetPosition)
        tracerbeam.Rotation = 90 + angle
        tracerbeam.Scale = Vector(effect.SpriteScale.X, data.BeamLength / 24.5)
        tracerbeam.Color = effect.Color
        tracerbeam:Render(Isaac.WorldToScreen(effect.Position))
        sprite:Render(Isaac.WorldToScreen(effect.TargetPosition))
    end
end