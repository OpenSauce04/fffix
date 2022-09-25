local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:RufusAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        data.state = "appear"
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.StateFrame = 0
        data.Stage = 1
        data.IgnoreToxicShock = true
        data.Init = true
    end
    npc.Velocity = npc.Velocity * 0.5
    if data.state == "appear" then
        if sprite:IsFinished("Appear") then
            data.state = "idle"
        else
            mod:spritePlay("Appear")
        end
    elseif data.state == "idle" then
        local healthval = (npc.HitPoints / npc.MaxHitPoints)
        local healththresh = 60 * healthval
        if targetpos:Distance(npc.Position) < 100 then
            npc.StateFrame = npc.StateFrame + 1
        end
        if npc.StateFrame >= healththresh then
            data.state = "explode"
        elseif npc.StateFrame >= healththresh * 0.66 or healthval <= 0.33 then
            if data.Stage < 3 then
                data.Stage = 3
                data.SmokeInterval = 10
                mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 1)
            end
        elseif npc.StateFrame >= healththresh * 0.33 or healthval <= 0.66 then
            if data.Stage < 2 then
                data.Stage = 2
                data.SmokeInterval = 20
                mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 0.8)
            end
        end
        if data.SmokeInterval and npc.FrameCount % data.SmokeInterval == 0 then
            local smoke = Isaac.Spawn(1000, 88, 0, npc.Position - Vector(0, 35), Vector(mod:RandomInt(-5,5,rng), -10), npc):ToEffect()
            smoke.SpriteScale = smoke.SpriteScale * (mod:RandomInt(3,6,rng)/10)
            smoke.Color = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
            smoke.DepthOffset = -50
        end
        mod:spritePlay(sprite, "Idle0"..data.Stage)
    elseif data.state == "explode" then
        if not data.Sounded then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_3, npc, 1.2, 2)
            data.Sounded = true
        end
        if sprite:IsFinished("Death") then
            FiendFolio.RufusDeathEffect(npc)
            npc:Kill()
        else
            mod:spritePlay(sprite, "Death")
        end
    end
end

function mod:RufusHurt(npc, amount, damageFlags, source)
    if npc:GetData().state == "explode" then
        return false
    end
end

function FiendFolio.RufusDeathAnim(npc)
    if npc:GetData().state ~= "explode" then
        local onCustomDeath = function(npc, deathAnim)
            deathAnim:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
            deathAnim:GetData().state = "explode"
            deathAnim:GetData().Init = true
        end
        FiendFolio.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, true, false)
    end
end

function FiendFolio.RufusDeathEffect(npc)
    local rng = npc:GetDropRNG()
    game:ShakeScreen(20)
    game:BombExplosionEffects(npc.Position, 40, 0, Color(1, 1, 1, 1, 75 / 255, 25 / 255, 0), npc, 1.75, false, true)
    local params = ProjectileParams()
    params.Variant = 9
    table.insert(mod.RufusRings, {["Source"] = npc, ["Position"] = npc.Position, ["Params"] = params})
    params.FallingAccelModifier = 1.5
    mod:SetGatheredProjectiles()
    for i = 60, 360, 60 do
        params.FallingSpeedModifier = -30 + mod:RandomInt(0,10,rng)
        local rand = rng:RandomFloat()
        npc:FireProjectiles(npc.Position, Vector.One:Resized(mod:RandomInt(2,6,rng)):Rotated(i-40+rand*80), 0, params)
    end
    for _, proj in pairs(mod:GetGatheredProjectiles()) do
        local pSprite = proj:GetSprite()
        pSprite:ReplaceSpritesheet(0, "gfx/projectiles/charredrock_proj.png")
        pSprite:LoadGraphics()
        proj:GetData().toothParticles = Color(50/255, 30/255, 30/255, 1, 0, 0, 0)
        proj:GetData().customProjSplat = "gfx/projectiles/charredrock_splat.png"
    end
end

function mod:RufusRingUpdate(ring)
    ring.Timer = ring.Timer or 40
    ring.Count = ring.Count or 10
    ring.Distance = ring.Distance or 80
    if ring.Timer >= 0 then
        if ring.Timer % 20 == 0 then
            local rng = ring.Source:GetDropRNG()
            local params = ring.Params	
            params.FallingSpeedModifier = 40
            params.FallingAccelModifier = 2
            --mod:SetGatheredProjectiles()
            for i = 1, ring.Count do
                params.HeightModifier = mod:RandomInt(-1000, -800, rng)
                ring.Source:FireProjectiles(ring.Position + Vector.One:Resized(ring.Distance):Rotated((360/ring.Count) * i), RandomVector() * 0.5, 0, params)
            end
            --[[for _, proj in ipairs(mod:GetGatheredProjectiles()) do
                local sprite = proj:GetSprite()
                sprite:Load("gfx/projectiles/shadowless_rock.anm2", true)
                sprite:SetFrame("Rotate"..mod:RandomInt(2,3,rng), mod:RandomInt(0,47,rng))
                proj.SubType = mod.FF.ShadowlessRock.Sub
            end]]
            ring.Count = ring.Count + 10
            ring.Distance = ring.Distance + 80
        end
        ring.Timer = ring.Timer - 1
    else
        ring = nil
    end
end