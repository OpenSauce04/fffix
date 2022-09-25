local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:CherubAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc.StateFrame = mod:RandomInt(60,80)
        sprite:Play("Idle")
        data.Init = true
    end
    if sprite:IsPlaying("Idle") or sprite:IsPlaying("AttackLoop") then
        if npc.StateFrame <= 0 then
            if sprite:IsPlaying("Idle") then
                if npc.Position:Distance(target.Position) < 400 then
                    sprite:Play("Attack01")
                end
            else
                sprite:Play("Attack02")
            end
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    end
    if sprite:IsEventTriggered("Flap") or sprite:IsEventTriggered("LaserTarget") then
        sfx:Play(SoundEffect.SOUND_ANGEL_WING, 0.8)
        local vec = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(10))
        if sprite:IsEventTriggered("Flap") and sprite:IsPlaying("Idle") then
            vec = vec:Rotated(mod:RandomInt(-90,90))
        end
        npc.Velocity = vec
    else
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
    end
    if sprite:IsFinished("Attack01") then
        sprite:Play("AttackLoop")
        npc.StateFrame = 45
    elseif sprite:IsFinished("Attack02") then
        sprite:Play("Idle")
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc.StateFrame = mod:RandomInt(80,100)
    end
    if sprite:IsEventTriggered("LaserTarget") then
        npc.TargetPosition = target.Position
        sfx:Play(SoundEffect.SOUND_BATTERYCHARGE,1,0,false,1.5)
    elseif sprite:IsEventTriggered("LaserStart") then
        local laser = Isaac.Spawn(7,2,0,npc.Position, Vector.Zero, npc):ToLaser()
        local angle = (npc.TargetPosition - npc.Position):GetAngleDegrees()
        local difference = angle - (target.Position - npc.Position):GetAngleDegrees()
        laser.Parent = npc
        laser.ParentOffset = Vector(0,-34)
        local room = game:GetRoom()
        local laserOrigin = laser.Parent.Position + laser.ParentOffset
        local _, endPos = room:CheckLine(laserOrigin, laserOrigin + Vector(1000,0):Rotated(angle), 3)
        endPos = mod:FixLaserBug(laser.AngleDegrees, room, endPos)
        laser:SetMaxDistance(laser.Parent.Position:Distance(endPos))
        laser.CollisionDamage = 0
        laser.DepthOffset = npc.DepthOffset + 100
        laser.Color = mod.ColorPsy3ForMe
        laser.Angle = angle
        laser:SetTimeout(59)
        if difference < 0 then
            laser:GetData().CherubRotation = 0.7
        else
            laser:GetData().CherubRotation = -0.7
        end
        laser:Update()
        npc.Velocity = Vector.Zero
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
    elseif sprite:IsEventTriggered("Emerge") then
        sfx:Play(SoundEffect.SOUND_SKIN_PULL, 1, 0, false, 1.2)
    elseif sprite:IsEventTriggered("Shoot") then
        local params = ProjectileParams()
        local vel = (targetpos - npc.Position)
        --params.Color = Color(0.8,0,0.5)
        params.FallingAccelModifier = -0.1
        params.Variant = 0
        params.Scale = 1.5
        params.Color = Color(1,1,1)
        params.BulletFlags = ProjectileFlags.SMART + ProjectileFlags.BOUNCE + ProjectileFlags.NO_WALL_COLLIDE
        params.HomingStrength = 1
        npc:FireProjectiles(npc.Position, vel:Resized(10), 0, params)
        local effect = Isaac.Spawn(1000, 2, 5, npc.Position - Vector(0,10), Vector.Zero, npc)
        effect.Color = Color(1,1,10,0.5)
        effect.DepthOffset = npc.Position.Y * 1.25
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS)
        sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
    end
end

function mod:CherubLaser(laser, data)
    if not laser.Parent or mod:isStatusCorpse(laser.Parent) then
        laser:SetTimeout(1)
        return
    end
    laser.Angle = laser.Angle + data.CherubRotation
    local room = game:GetRoom()
    local laserOrigin = laser.Parent.Position + laser.ParentOffset
    local _, endPos = room:CheckLine(laserOrigin, laserOrigin + Vector(1000,0):Rotated(laser.AngleDegrees), 3)
    endPos = mod:FixLaserBug(laser.AngleDegrees, room, endPos)
    laser:SetMaxDistance(laser.Parent.Position:Distance(endPos))
end

--Fixes bug where lasers cut off short at the bottom wall of the room (can be seen with vanilla entities also lol)
function mod:FixLaserBug(angle, room, endPos)
    local isAtRoomEdge = not room:IsPositionInRoom(endPos + Vector(20,0):Rotated(angle), 0)
    if isAtRoomEdge then
        return endPos + Vector(40,0):Rotated(angle)
    else
        return endPos
    end
end