local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ShockCollarAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        if npc.SubType == 0 or npc.SubType > 4 then 
            data.dir = mod:RandomInt(1,4)
        else 
            data.dir = npc.SubType 
        end
        if data.dir == 1 then
            data.dir = Vector(0.5, -0.5)
        elseif data.dir == 2 then
            data.dir = Vector(-0.5, -0.5)
        elseif data.dir == 3 then
            data.dir = Vector(0.5, 0.5)
        elseif data.dir == 4 then
            data.dir = Vector(-0.5, 0.5)
        end
        sprite:Play("Idle")
        data.Init = true
    end
    if sprite:IsFinished("AttackStart") then
        sprite:Play("AttackLoop")
    elseif sprite:IsFinished("AttackWinddown") then
        sprite:Play("Idle")
    end
    if sprite:IsPlaying("Idle") then
        data.StartedMovin = data.StartedMovin or 0
        if (npc.Velocity.X == 0 and npc.Velocity.Y == 0) or data.StartedMovin < 2 then
            if npc.Velocity.X == 0 then
                data.dir = Vector(data.dir.X * -1, data.dir.Y)
            end
            if npc.Velocity.Y == 0 then
                data.dir = Vector(data.dir.X, data.dir.Y * -1)
            end
            npc.Velocity = data.dir
            data.StartedMovin = data.StartedMovin + 1
        end
        local angle = npc.Velocity:GetAngleDegrees()
        local regularVel = npc.Velocity:Rotated((90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))):Resized(6)
        local actualVel = mod:Lerp(npc.Velocity, regularVel, 0.1)
        npc.Velocity = actualVel
        data.dir = actualVel
        if npc.FrameCount > 10 and targetpos:Distance(npc.Position) < 100 and not mod:isScare(npc) then
            sprite:Play("AttackStart")
        end
    else
        if targetpos:Distance(npc.Position) > 150 then
            sprite:Play("AttackWinddown")
        end
        npc.Velocity = npc.Velocity * 0.8
    end
    if sprite:IsEventTriggered("Shoot") and not npc:IsDead() then
        local ring = Isaac.Spawn(7, 2, 2, npc.Position, Vector.Zero, npc):ToLaser()
        ring:GetData().ShockCollar = true
        ring:SetColor(Color(1,1,1,1,1), 3, 1, false, false)
        ring.Parent = npc
        npc.Child = ring
        ring.Radius = 5
        data.Growing = true
    elseif sprite:IsEventTriggered("OkStop") then
        data.Growing = false
    end
    if npc.Child and npc.Child:Exists() then
        local ring = npc.Child:ToLaser()
        ring.Velocity = npc.Position - ring.Position
        if data.Growing and ring.Radius < 100 then
            ring.Radius = ring.Radius + 2
        else
            ring.Radius = ring.Radius - 6
        end
    end
end

function mod:ShockCollarTechRing(laser, data)
    if not data.StupidAssJankyHack then
        laser:AddTearFlags(TearFlags.TEAR_CONTINUUM)
        data.StupidAssJankyHack = true
    end
    laser:SetColor(Color(1,1,1,1,1), 3, 1, false, false)
    if laser.Parent and laser.Parent:Exists() then
        --Hi doggie
    else
        laser.Radius = laser.Radius - 12
    end
    if laser.Radius < 5 then
        laser:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, damageFlags, source, iFrames)
    if source.Entity and entity:ToNPC() and source.Type == mod.FF.ShockCollar.ID and source.Variant == mod.FF.ShockCollar.Var and not mod:isFriend(source.Entity) then
        return false
    end
end)