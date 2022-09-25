local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:ChunkyAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local isGrilled = (npc.SubType == mod.FF.GrilledChunky.Sub)
    if not data.Init then
        npc.StateFrame = mod:RandomInt(8,16,rng)
        npc.I1 = mod:RandomInt(1,2,rng)
        data.Params = ProjectileParams()
        data.Params.FallingAccelModifier = -0.1
        data.suffix = ""
        if npc.SubType == 100 then
            data.state = "plunger"
        else
            data.state = "idle"
        end
        data.Init = true
    end
    if not data.FormInit then
        if isGrilled then
            sprite.PlaybackSpeed = 1.5
            npc.SplatColor = mod.ColorGrilled
        else
            sprite.PlaybackSpeed = 1
            npc.SplatColor = Color.Default
        end
        data.FormInit = true
    end
    if data.state == "idle" then
        npc.Velocity = npc.Velocity * 0.75
        if npc.StateFrame <= 0 then
            local pos
            if npc.I1 <= 0 then
                pos = targetpos
                data.state = "attack"
            else
                local movespeed = 8
                if mod:isScare(npc) then
                    data.vel = (npc.Position - targetpos):Rotated(mod:RandomInt(-45,45)):Resized(movespeed)
                elseif rng:RandomFloat() <= 0.5 then
                    data.vel = (targetpos - npc.Position):Rotated(mod:RandomInt(-45,45)):Resized(movespeed)
                else
                    data.vel = RandomVector():Resized(movespeed)
                end
                pos = npc.Position + data.vel
                data.state = "move"
            end
            if pos.X > npc.Position.X then
                data.suffix = "Flip"
            else
                data.suffix = ""
            end
        end
        if not sprite:IsPlaying("Appear") then
            if isGrilled then
                npc.StateFrame = npc.StateFrame - 2
            else
                npc.StateFrame = npc.StateFrame - 1
            end
            mod:spritePlay(sprite, "Idle"..data.suffix)
        end
    elseif data.state == "move" then
        npc.Velocity = npc.Velocity * 0.85
        if sprite:IsFinished("Move"..data.suffix) then
            npc.StateFrame = mod:RandomInt(8,16,rng)
            npc.I1 = npc.I1 - 1
            data.state = "idle"
        elseif sprite:IsEventTriggered("Move") then
            npc.Velocity = data.vel
        else
            mod:spritePlay(sprite, "Move"..data.suffix)
        end
    elseif data.state == "attack" or data.state == "plunger" then
        npc.Velocity = npc.Velocity * 0.65
        if sprite:IsFinished("Attack"..data.suffix) then
            npc.StateFrame = mod:RandomInt(16,24,rng)
            npc.I1 = mod:RandomInt(2,3,rng)
            data.state = "idle"
        elseif sprite:IsEventTriggered("Jump") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
            data.NoTrail = true
        elseif sprite:IsEventTriggered("Shoot") then
            mod:SetGatheredProjectiles()
            local vel = 2
            if isGrilled then
                vel = 9
                --table.insert(mod.FireShockwaves, {["Spawner"] = npc, ["Position"] = npc.Position})
            end
            for i = -vel/2, vel, vel/2 do
                npc:FireProjectiles(npc.Position, Vector(i, vel), 0, data.Params)
                npc:FireProjectiles(npc.Position, Vector(i-(vel/2), -vel), 0, data.Params)
                npc:FireProjectiles(npc.Position, Vector(vel, i-(vel/2)), 0, data.Params)
                npc:FireProjectiles(npc.Position, Vector(-vel, i), 0, data.Params) 
            end
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                proj:GetData().projType = "Chunky"
            end
            local splat = Isaac.Spawn(1000, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc)
            splat.SpriteScale = Vector(0.7,0.7)
            splat.Color = npc.SplatColor
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
            npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.7, 0, false, 1)
            data.NoTrail = false
        else
            if data.state == "plunger" then
                mod:spritePlay(sprite, "Plunger"..data.suffix)
            else
                mod:spritePlay(sprite, "Attack"..data.suffix)
            end
        end
    end
    if npc.FrameCount % 2 == 1 and not data.NoTrail then
        local trail = Isaac.Spawn(1000, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc)
        trail.SpriteScale = Vector(1.1,1.1)
        trail.Color = npc.SplatColor
        trail:Update()
    end
    if isGrilled then
        if game:GetRoom():HasWater() then
            npc:Morph(mod.FF.Chunky.ID, mod.FF.Chunky.Var, 0, npc:GetChampionColorIdx())
            data.FormInit = false
        end
    end
end

function mod:ChunkyHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) and not game:GetRoom():HasWater() then
        if npc.SubType ~= mod.FF.GrilledChunky.Sub then
            npc:Morph(mod.FF.GrilledChunky.ID, mod.FF.GrilledChunky.Var, mod.FF.GrilledChunky.Sub, npc:GetChampionColorIdx())
            npc:GetData().FormInit = false
        end
        if not mod:IsPlayerDamage(source) then
            return false
        end
    end
end

function mod:ChunkyProjectile(projectile, data)
    if projectile.Velocity:Length() < 9 then
        projectile.Velocity = projectile.Velocity * 1.05
    end
end