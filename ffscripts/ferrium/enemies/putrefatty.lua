local mod = FiendFolio
local game = Game()

function mod:putrefattyAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local data = npc:GetData()
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.init then
        data.state = "Idle"
        data.forward = Vector(0,40)
        --data.findSpot = npc.Position
        data.stepVel = 0
        data.moveFrames = 0
        data.cooldown = 10
        data.prevDir = "Down"
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
        data.moveFrames = data.moveFrames+1
    end

    if data.state == "Idle" then
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            if npc.Velocity.X > 0 then
                sprite.FlipX = false
                data.forward = Vector(40,0)
                data.dir = "Right"
            else
                sprite.FlipX = true
                data.forward = Vector(-40,0)
                data.dir = "Left"
            end
            mod:spritePlay(sprite, "WalkHori")
        else
            if npc.Velocity.Y > 0 then
                data.forward = Vector(0,40)
                mod:spritePlay(sprite, "WalkDown")
                data.dir = "Down"
            else
                data.forward = Vector(0,-40)
                mod:spritePlay(sprite, "WalkUp")
                data.dir = "Up"
            end
        end

        if not data.findSpot then
            data.findSpot = mod:FindRandomValidPathPosition(npc, 3, nil, 100)
        end
        if npc.Position:Distance(data.findSpot) < 10 or data.moveFrames > 30 then
            local pos = npc.Position+data.forward
            if room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_NONE and rng:RandomInt(7) > 1 and data.moveFrames < 30 then
                data.findSpot = pos+mod:shuntedPosition(5, rng)
            else
                data.findSpot = mod:FindRandomValidPathPosition(npc, 3, nil, 100)
            end
            data.moveFrames = 0
        end
        if sprite:IsEventTriggered("Step") then
            data.stepVel = 6
            npc:PlaySound(SoundEffect.SOUND_MOTHER_ISAAC_HIT, 0.55, 0, false, math.random(90,110)/100)
        end

        if mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-target.Position):Resized(data.stepVel), 0.3)
        elseif room:CheckLine(npc.Position, data.findSpot, 0, 0, false, false) then
            npc.Velocity = mod:Lerp(npc.Velocity, (data.findSpot-npc.Position):Resized(data.stepVel), 0.3)
        else
            npc.Pathfinder:FindGridPath(data.findSpot, data.stepVel/5.3, 999, true)
        end
        if data.stepVel > 0 then
            data.stepVel = data.stepVel*0.8
        end

        if data.prevDir ~= data.dir then
            data.cooldown = 10
        end
        if data.cooldown > 0 then
            data.cooldown = data.cooldown-1
        end

        if data.cooldown <= 0 and npc.StateFrame > 75 and not mod:isScareOrConfuse(npc) then
            if data.dir == "Right" or data.dir == "Left" then
                if math.abs(target.Position.Y-npc.Position.Y) < 30 then
                    if data.dir == "Right" then
                        if target.Position.X > npc.Position.X then
                            data.state = "FireMaggot"
                        else
                            data.state = "FireGuts"
                        end
                    else
                        if npc.Position.X > target.Position.X then
                            data.state = "FireMaggot"
                        else
                            data.state = "FireGuts"
                        end
                    end
                    data.orient = "Hori"
                end
            else
                if math.abs(target.Position.X-npc.Position.X) < 30 then
                    if data.dir == "Down" then
                        if target.Position.Y > npc.Position.Y then
                            data.state = "FireMaggot"
                        else
                            data.state = "FireGuts"
                        end
                        data.orient = "Down"
                    else
                        if npc.Position.Y > target.Position.Y then
                            data.state = "FireMaggot"
                        else
                            data.state = "FireGuts"
                        end
                        data.orient = "Up"
                    end
                end
            end
        end
        data.prevDir = data.dir

        if npc.FrameCount % 5 == 0 and math.random(4) == 1 then
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
            splat.Color = Color(1,1,1,0.5,0,0,0)
            splat.SpriteScale = Vector(1.3,1.3)
        end
    elseif data.state == "FireMaggot" then
        if sprite:IsFinished("ShootWorm" .. data.orient) then
            data.state = "Idle"
            npc.StateFrame = 0
            data.findSpot = nil
            data.moveFrames = 0
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 0.6)
            data.rocket = data.forward:Resized(-20)

            local maggotToss = 1
            local bullets = 3
            if mod.GetEntityCount(23) < 3 then
                local charger = Isaac.Spawn(23, 0, 0, npc.Position, data.forward:Resized(5), npc):ToNPC()
                charger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                charger.State = 8
                charger.V1 = data.forward:Resized(2)
                charger:Update()
                npc:PlaySound(SoundEffect.SOUND_MAGGOTCHARGE, 1, 0, false, 1)
            else
                maggotToss = 2
                bullets = 6
            end
            if mod.GetEntityCount(853) > 5 then
                maggotToss = 0
            end

            local params = ProjectileParams()
            params.Color = mod.ColorWigglyMaggot
            params.FallingAccelModifier = 1.1
            for i=1,bullets do
                params.Scale = mod:getRoll(60,100,rng)/100
                params.FallingSpeedModifier = mod:getRoll(-15,-5,rng)
                npc:FireProjectiles(npc.Position, data.forward:Resized(mod:getRoll(7,10,rng)):Rotated(mod:getRoll(-20,20,rng)), 0, params)
            end

            for i=1,maggotToss do
                mod.ThrowMaggot(npc.Position, data.forward:Resized(mod:getRoll(5,8,rng)):Rotated(mod:getRoll(-30,30,rng)), -5, mod:getRoll(-14,-6,rng), npc)
                --[[local vel = data.forward:Resized(mod:getRoll(4,8,rng)):Rotated(mod:getRoll(-30,30,rng))
                local maggot = Isaac.Spawn(853, 0, 0, npc.Position, vel, npc):ToNPC()
                maggot.State = 16
                maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                maggot:GetData().launchedEnemyInfo = {zVel = -4, accel = 0, pos = true, height = -5, additional = function() maggot.Position = maggot.Position+vel maggot.State = 16 end}]]
            end
        else
            mod:spritePlay(sprite, "ShootWorm" .. data.orient)
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "FireGuts" then
        if sprite:IsFinished("ShootGuts" .. data.orient) then
            data.state = "Idle"
            npc.StateFrame = 0
            data.findSpot = nil
            data.moveFrames = 0
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_MOTHER_WRIST_EXPLODE, 1, 0, false, 1)
            data.rocket = data.forward:Resized(20)

            if mod.GetEntityCount(831, 20) < 3 then
                local guts = Isaac.Spawn(831, 20, 0, npc.Position, data.forward:Resized(-10), npc):ToNPC()
                guts:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                guts.State = 6
                guts.V1 = Vector(-6,-5)
                guts:Update()
                guts.Velocity = data.forward:Resized(-10)
            else
                local params = ProjectileParams()
                params.FallingAccelModifier = 1.1
                for i=1,10 do
                    params.Scale = mod:getRoll(60,100,rng)/100
                    params.FallingSpeedModifier = mod:getRoll(-15,-5,rng)
                    npc:FireProjectiles(npc.Position, data.forward:Resized(-mod:getRoll(7,10,rng)):Rotated(mod:getRoll(-20,20,rng)), 0, params)
                end
            end
        else
            mod:spritePlay(sprite, "ShootGuts" .. data.orient)
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    end

    if data.rocket then
        npc.Velocity = data.rocket
        data.rocket = data.rocket*0.8
        if data.rocket:Length() < 5 then
            data.rocket = nil
        end
    end
end

function mod:putrefattyColl(npc, coll)
    if (coll.Type == 23 or coll.Type == 831) and coll.FrameCount < 10 then
        return false
    end
end