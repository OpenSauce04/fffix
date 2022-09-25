local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ButtFlyAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        if npc.SubType == 0 or npc.SubType > 4 then 
            data.dir = mod:RandomInt(1,4,rng) 
        else 
            data.dir = npc.SubType 
        end
        if data.dir == 1 then
            data.dir = Vector(-1, 1)
        elseif data.dir == 2 then
            data.dir = Vector(1, 1)
        elseif data.dir == 3 then
            data.dir = Vector(-1, -1)
        elseif data.dir == 4 then
            data.dir = Vector(1, -1)
        end
        npc.StateFrame = mod:RandomInt(15,30,rng)
        data.state = "idle"
        data.Init = true
    end
    if data.state == "idle" then
        if sprite:IsFinished("Appear") then
            npc.Velocity = data.dir
            mod:AddSoundmakerFly(npc)
            mod:spritePlay(sprite, "Fly")
        elseif not sprite:IsPlaying("Appear") then
            local angle = mod:SnapToDiagonal(npc.Velocity:GetAngleDegrees())
            if npc.Velocity:Length() <= 0.01 then
                npc.Velocity = data.dir
            else
                local vel = npc.Velocity:Rotated(angle):Resized(4)
                npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.1)
            end
            mod:spritePlay(sprite, "Fly")
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 and npc.Position:Distance(targetpos) < 130 then
                local shootangle 
                for i = -90, 90, 90 do
                    if mod:GetAbsoluteAngleDifference(npc.Velocity:Rotated(i), targetpos - npc.Position) < 15 then
                        shootangle = angle + i
                        break
                    end
                end
                if shootangle then
                    data.shootangle = shootangle
                    data.state = "attack"
                end
            end
        end
    elseif data.state == "attack" then
        if sprite:IsFinished("Shoot") then
            data.state = "idle"
            npc.StateFrame = mod:RandomInt(30,45,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            game:ButterBeanFart(npc.Position, 60, npc, true, false)
            npc.Velocity = npc.Velocity:Rotated(data.shootangle):Resized(8)
        else
            mod:spritePlay(sprite, "Shoot")
        end
        if not sprite:WasEventTriggered("Shoot") then
            npc.Velocity = npc.Velocity * 0.85
        end
    end
    if npc:IsDead() then
        game:ButterBeanFart(npc.Position, 100, npc, true, false)
    end
end

function mod:SnapToDiagonal(angle)
    return (90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))
end