local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:PufferAI(npc, sprite, data)
    if not data.init then
        if npc.SubType == 0 or npc.SubType > 4 then data.dir = mod:RandomInt(1,4) else data.dir = npc.SubType end

        if data.dir == 1 then
            data.dir = Vector(-1, 1)
        elseif data.dir == 2 then
            data.dir = Vector(1, 1)
        elseif data.dir == 3 then
            data.dir = Vector(-1, -1)
        elseif data.dir == 4 then
            data.dir = Vector(1, -1)
        end
        sprite:Play("Appear")
        data.init = true
    end
    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
        npc.Velocity = data.dir
        npc.StateFrame = mod:RandomInt(60,150)
    elseif sprite:IsFinished("PuffUp") then
        sprite:Play("Idle2")
        npc.StateFrame = mod:RandomInt(60,90)
    elseif sprite:IsFinished("Shoot") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(90,150)
    end

    if sprite:IsPlaying("Idle") or (sprite:IsPlaying("PuffUp") and not sprite:WasEventTriggered("Stop")) or (sprite:IsPlaying("Shoot") and sprite:WasEventTriggered("Move")) then
        local angle = npc.Velocity:GetAngleDegrees()
        npc.Velocity = npc.Velocity:Rotated((90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))):Resized(math.min(npc.Velocity:Length() * 1.2, 6))

        if sprite:IsPlaying("Idle") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                sprite:Play("PuffUp")
            end
        end
    else
        local angle = npc.Velocity:GetAngleDegrees()
        npc.Velocity = npc.Velocity:Rotated((90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))) * 0.8

        if sprite:IsPlaying("Idle2") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                sprite:Play("Shoot")
            end
        end
    end

    if sprite:IsEventTriggered("Move") then
        npc.Velocity = npc.Velocity:Resized(0.1)
    end

    if sprite:IsEventTriggered("Sound") then
        if sprite:IsPlaying("PuffUp") and sprite:WasEventTriggered("Stop") then
            npc.Size = npc.Size * 2
            data.Puffed = true
            mod:PlaySound(mod.Sounds.BaloonShort, npc, 1.5)
        elseif sprite:IsPlaying("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_MAGGOTCHARGE, npc, 0.8)
        else
            mod:PlaySound(SoundEffect.SOUND_MAGGOTCHARGE, npc)
        end
    end

    if sprite:IsEventTriggered("Shoot") then
        npc.Size = npc.Size / 2
        data.Puffed = false
        mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS_OLD, npc)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)	
        mod:PlaySound(mod.Sounds.SplashSmall, npc)
        local params = ProjectileParams()
        params.Variant = 4
        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position, Vector(8,9), 9, params)				
        for _, projectile in pairs(mod:GetGatheredProjectiles()) do
            local s = projectile:GetSprite()
            s:ReplaceSpritesheet(0, "gfx/projectiles/cupid_projectile.png")
            s:LoadGraphics()
            projectile:GetData().RotationUpdate = true
        end
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 16, 3, npc.Position, Vector.Zero, npc)
        effect.Color = mod.ColorSolidWater
        effect.SpriteScale = effect.SpriteScale * 0.7
    end

    if sprite:IsEventTriggered("Shoot2") then
        --[[sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, mod:RandomInt(9, 11)/10)

        for i = 225, 3375, 450 do
            local p = Isaac.Spawn(9, 4, 0, npc.Position, Vector(0, 9):Rotated(i/10), npc)
            local s = p:GetSprite()
            s:ReplaceSpritesheet(0, "gfx/projectiles/cupid_projectile.png")
            s:LoadGraphics()
            s.Rotation = p.Velocity:GetAngleDegrees()
        end]]
    end

    if npc:IsDead() and data.Puffed then
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)	
        mod:PlaySound(mod.Sounds.SplashLargePlonkless, npc)
        mod:PlaySound(SoundEffect.SOUND_ROCKET_BLAST_DEATH, npc, 1.5, 0.8)
        local params = ProjectileParams()
        params.Scale = 1.5
        params.Variant = 4
        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position, Vector(11,0), 8, params)				
        for _, projectile in pairs(mod:GetGatheredProjectiles()) do
            local s = projectile:GetSprite()
            s:ReplaceSpritesheet(0, "gfx/projectiles/cupid_projectile.png")
            s:LoadGraphics()
            projectile:GetData().RotationUpdate = true
        end
        for _ = 1, 8 do
            params.FallingAccelModifier = 0.6
            params.FallingSpeedModifier = mod:RandomInt(-8,-5)
            params.Scale = mod:RandomInt(16,30) * 0.05
            npc:FireProjectiles(npc.Position, RandomVector():Resized(mod:RandomInt(5,12)), 0, params)			
        end
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 16, 5, npc.Position, Vector.Zero, npc)
        effect.Color = mod.ColorLessSolidWater	
    end
end