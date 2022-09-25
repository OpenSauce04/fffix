local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:RetchAI(npc, sprite, data) --Barely changed this code bc there is no point in doing so
    local rng = npc:GetDropRNG()
    if not data.init then
        data.lastattack = npc.FrameCount
        data.loops = 0
        data.params = ProjectileParams()
        data.params.FallingAccelModifier = 2
        data.params.Color = mod.ColorGurdyOrange
        data.params.BulletFlags = ProjectileFlags.CREEP_BROWN
        data.init = true
    end

    if sprite:IsPlaying("Move Hori") then
        data.dir = "Hori"
    elseif sprite:IsPlaying("Move Up") then
        data.dir = "Up"
    elseif sprite:IsPlaying("Move Down") then
        data.dir = "Down"
    end

    if data.spew then
        npc.State = 0
        npc.Velocity = npc.Velocity * 0.7
        data.animframe = data.animframe and data.animframe + 1 or sprite:GetFrame()
        if not data.loop then
            sprite:SetFrame("StartShoot"..data.dir, data.animframe)
            if data.animframe >= 13 then
                data.loop = true
                data.animframe = 0
                npc:PlaySound(SoundEffect.SOUND_GOODEATH,1,0,false,1.2)
            end
        else
            if not data.finish then
                sprite:SetFrame("Shooting", data.animframe)
                if data.animframe >= 7 then
                    data.animframe = 0
                    data.loops = data.loops + 1
                    if data.loops >= mod:RandomInt(5, 7, rng) then
                        data.finish = true
                        data.animframe = 0
                        data.loops = 0
                    end
                end
            else
                sprite:SetFrame("StopShoot"..data.dir, data.animframe)
                if data.animframe >= 13 then
                    data.loop = false
                    data.finish = false
                    data.spew = false
                    data.animframe = 0
                    data.lastattack = npc.FrameCount
                end
            end
        end
    end

    if data.lastattack + 90 <= npc.FrameCount and mod:RandomInt(0,9,rng) == mod:RandomInt(0,9,rng) and not data.spew then
        data.spew = true
        sprite:SetFrame("StartShoot"..data.dir, 0)
    end

    if sprite:IsFinished("Shooting") and sprite:GetFrame() >= 2 and sprite:GetFrame() <= 5 then
        data.params.FallingSpeedModifier = mod:RandomInt(-30, -10, rng) * 1.5
        npc:FireProjectiles(npc.Position, Vector(30, 0):Rotated(mod:RandomAngle(rng)):Resized(4 - mod:RandomInt(0,1,rng)*2), 0, data.params)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, mod:RandomInt(9, 11, rng) * 0.1, 0.7)
        --[[if data.effected then
            data.effected = false
        else
            local effect = Isaac.Spawn(1000,2,2,npc.Position + RandomVector() * mod:RandomInt(1,3,rng),Vector.Zero,npc)
            effect.Color = mod.ColorGurdyOrange
            effect.SpriteOffset = Vector(0,-25)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect:GetSprite().Scale = Vector(0.5,0.5)
            data.effected = true
        end]]
    end

    if npc:IsDead() then
        local puddle = Isaac.Spawn(1000,56,0,npc.Position,Vector.Zero,npc):ToEffect()
        puddle.SpriteScale = puddle.SpriteScale * 3
        puddle.Scale = 0.75
        puddle:Update()
    end
end