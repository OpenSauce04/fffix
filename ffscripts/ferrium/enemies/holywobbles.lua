local mod = FiendFolio
local sfx = SFXManager()

function mod:holyWobblesAI(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local rng = npc:GetDropRNG()
    
    if not data.init then
        data.state = "Idle"
        data.paddleCount = 1
        data.movement = 0
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if data.state == "Idle" then
        if npc.StateFrame > 60 then
            if data.paddleCount > 2 or (rng:RandomInt(4) == 0 and data.paddleCount > 0) then
                data.state = "Inflate"
                data.paddleCount = 0
            else
                data.state = "Move"
            end
        end
        mod:spritePlay(sprite, "idle")
    elseif data.state == "Inflated" then
        if npc.StateFrame > 60 then
            data.state = "Deflate"
        end

        mod:spritePlay(sprite, "inflatedidle")
    elseif data.state == "Move" then
        if sprite:IsFinished("paddle") then
            data.state = "Idle"
            data.paddleCount = data.paddleCount+1
            npc.StateFrame = mod:getRoll(10,40,rng)
        elseif sprite:IsEventTriggered("paddle") then
            npc:PlaySound(SoundEffect.SOUND_BLOBBY_WIGGLE, 0.5, 0, false, math.random(15, 20)/10)
            data.movement = 1
            local vel = (targetpos-npc.Position):Resized(mod:getRoll(10,15,rng))
            if mod:isScare(npc) then
                vel = vel:Resized(-mod:getRoll(10,15,rng))
            end
            npc.Velocity = vel
        elseif sprite:IsEventTriggered("paddleend") then
            data.movement = 0
        else
            mod:spritePlay(sprite, "paddle")
        end
    elseif data.state == "Inflate" then
        if sprite:IsFinished("inflatepaddle") then
            data.state = "Inflated"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("inflate") then
            npc:PlaySound(SoundEffect.SOUND_URN_CLOSE, 1.2, 0, false, 1.2)
            npc:PlaySound(SoundEffect.SOUND_UNHOLY, 0.7, 0, false, math.random(15,20)/10)
            data.gassing = true
            data.movement = 2
            local vel = (targetpos-npc.Position):Resized(mod:getRoll(10,15,rng))
            if mod:isScare(npc) then
                vel = vel:Resized(-mod:getRoll(10,15,rng))
            end
            npc.Velocity = vel
        elseif sprite:IsEventTriggered("collision32") then
            npc:SetSize(32, Vector(1, 0.5), 15)
        else
            mod:spritePlay(sprite, "inflatepaddle")
        end
    elseif data.state == "Deflate" then
        if sprite:IsFinished("deflate") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("deflate") then
            data.gassing = nil
            data.movement = 0
            npc:PlaySound(mod.Sounds.BaloonBounce, 1, 0, false, 1.5)
            npc:PlaySound(SoundEffect.SOUND_URN_CLOSE, 1, 0, false, 0.8)
            for i=1,10 do
                local randVel = RandomVector()*math.random(10,30)/20
                local cloud = Isaac.Spawn(1000, 59, 0, npc.Position+mod:shuntedPosition(20,rng), Vector.Zero, nil):ToEffect()
                cloud:SetTimeout(math.random(30,60))
                local color = Color(1,0.8,0.3,0,0.3,0.3,0.3)
                cloud.Color = color
                local randScale = math.random(50,100)/100
                cloud.SpriteScale = Vector(0.5, 0.5)
                cloud.SpriteOffset = Vector(0,-25)
                cloud:GetData().holyWobblesDust = {scale = randScale, vel = randVel, lifespan = math.random(60,200), npc = npc}
            end
        elseif sprite:IsEventTriggered("collision26") then
            npc:SetSize(13, Vector(1, 1), 12)
        else
            mod:spritePlay(sprite, "deflate")
        end
    end

    if data.movement == 0 then
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.15)
    elseif data.movement == 1 then
        --[[npc.Velocity = mod:Lerp(npc.Velocity, data.paddleVec, 0.3)
        data.paddleVec = data.paddleVec*0.96]]
        npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(0.25), 0.075)
    elseif data.movement == 2 then
        --[[npc.Velocity = mod:Lerp(npc.Velocity, data.paddleVec, 0.1)
        data.paddleVec = data.paddleVec*0.92]]
        npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(0.5), 0.05)
    end

    if npc.Velocity.X > 0 then
        sprite.FlipX = true
    else
        sprite.FlipX = false
    end

    if data.gassing then
        if npc.StateFrame % 2 == 0 and npc.Velocity:Length() > 1.5 then
            --[[local beam = Isaac.Spawn(1000, 19, 0, npc.Position+mod:shuntedPosition(40,rng), Vector.Zero, npc):ToEffect()
            beam.SpriteScale = Vector(0.2,1)
            beam.SpriteOffset = Vector(0, -5)
            beam.Scale = 0.3
            beam.Size = 0.3
            beam.Parent = npc]]
            local randVel = Vector(0, mod:getRoll(10,25)/20):Rotated(rng:RandomInt(360))
            local cloud = Isaac.Spawn(1000, 59, 0, npc.Position+mod:shuntedPosition(20,rng), Vector.Zero, nil):ToEffect()
            local timeout = mod:getRoll(50, 150, rng)
            cloud:SetTimeout(timeout)
            local color = Color(1,0.8,0.3,0,0.3,0.3,0.3)
            cloud.Color = color
            local randScale = mod:getRoll(50,150,rng)/100
            cloud.SpriteScale = Vector(0.5, 0.5)
            cloud.SpriteOffset = Vector(0,-55)
            cloud:GetData().holyWobblesDust = {scale = randScale, vel = randVel, lifespan = 200+npc.StateFrame, npc = npc, beam = true, timeout = timeout}
        end
    end
end

--[[mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, e)
    if e.SpawnerType and (e.SpawnerType == mod.FF.HolyWobbles.ID and e.SpawnerVariant == mod.FF.HolyWobbles.Var) then
        mod.scheduleForUpdate(function()
            sfx:Stop(SoundEffect.SOUND_LIGHTBOLT)
        end, 4)
        mod.scheduleForUpdate(function()
            sfx:Stop(SoundEffect.SOUND_LIGHTBOLT)
            sfx:Play(SoundEffect.SOUND_LIGHTBOLT, 0.3, 0, false, 2)
        end, 5)
    end
end, 19)]]

function mod:holyWobblesBeamEffect(e)
    local sprite = e:GetSprite()
    if sprite:IsFinished("Spotlight") then
        e:Remove()
    elseif sprite:IsEventTriggered("Hit") then
        sfx:Play(SoundEffect.SOUND_LIGHTBOLT, 0.3, 0, false, 2)

        if e.SpawnerEntity and e.SpawnerEntity:ToNPC() then
            local npc = e.SpawnerEntity:ToNPC()
            if mod:isCharm(npc) then
                for _, enemy in ipairs(Isaac.FindInRadius(e.Position, 30, EntityPartition.ENEMY)) do
                    if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                        enemy:TakeDamage(15, 0, EntityRef(npc), 0)
                    end
                end
            else
                for _, enemy in ipairs(Isaac.FindByType(1, -1, -1, false, false)) do
                    if enemy.Position:Distance(e.Position) < 30 then
                        enemy:TakeDamage(1, 0, EntityRef(npc), 0)
                    end
                end
            end
        else
        end
    else
        mod:spritePlay(sprite, "Spotlight")
    end
end

--Go to Astropulvis for the beam/cloud code.