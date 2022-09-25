local mod = FiendFolio
local sfx = SFXManager()

function mod:seaCucumberAI(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if data.anim then
        npc.State = 0
        if sprite:GetFrame() >= 88 then
            npc.State = 4
            data.anim = nil
        else
            sprite:SetFrame(data.anim, sprite:GetFrame() + 1)
            if sprite:IsFinished("ShootHori") then
                sprite.FlipX = data.vect.X > 0
            end
        end

        if sprite:IsEventTriggered("Sound") then
            sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
        end

        if sprite:IsEventTriggered("Shoot") then
            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1)
            npc.Velocity = data.vect * -50
            for i = 1, 5 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOP_EXPLOSION, 2, npc.Position + data.vect * npc.Size * data.offset, data.vect:Rotated(math.random(-25, 25)) * math.random(5,20), npc)
                local p = Isaac.Spawn(9, 3, 0, npc.Position + data.vect * npc.Size * data.offset, data.vect:Rotated(mod:getRoll(-25,25,rng)) * mod:getRoll(10,20,rng), npc):ToProjectile()

                p.Height = -8
                p.FallingSpeed = -5 - rng:RandomInt(4)
                p.FallingAccel = 0.3
            end
        end

        if sprite:GetFrame() > 24 and sprite:GetFrame() < 72 then
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, math.random(9, 11)/10)
            local p = Isaac.Spawn(9, 3, 0, npc.Position + data.vect * npc.Size * data.offset, data.vect:Rotated(mod:getRoll(-3,3,rng)) * 15, npc):ToProjectile()

            p.Height = -8
            p.FallingSpeed = -5 - rng:RandomInt(4)
            p.FallingAccel = 0.3
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.22)
    else
        if sprite:IsPlaying("Move Hori") then
            if sprite.FlipX then
                data.vect = Vector(1, 0)
            else
                data.vect = Vector(-1, 0)
            end
        elseif sprite:IsPlaying("Move Down") then
            data.vect = Vector(0, -1)
        elseif sprite:IsPlaying("Move Up") then
            data.vect = Vector(0, 1)
        end

        if sprite:IsPlaying("Move Hori") or sprite:IsPlaying("Move Down") or sprite:IsPlaying("Move Up") then
            if sprite:IsEventTriggered("Sound") then
                npc.Velocity = npc.Velocity:Resized(15)
                sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.4, 0, false, math.random(9, 11)/10)
            else
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.45)
            end
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
        end
    end
end