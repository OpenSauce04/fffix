local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:DrumstickAI(npc, sprite, data)
    if not data.Init then
        data.Params1 = ProjectileParams()
        data.Params1.Scale = 0.5
        data.Params1.HeightModifier = 10
        data.Params2 = ProjectileParams()
        data.Params2.Variant = 1
        data.Params2.FallingSpeedModifier = -20
        data.Params2.FallingAccelModifier = 1.5
        data.Cooldown = mod:RandomInt(15,45)
        data.Init = true
    end
    if npc.State == 8 and not mod:isCharm(npc) then
        if data.Cooldown > 0 then
            npc.State = 4
        end
    else
        data.Cooldown = data.Cooldown - 1
    end
    if sprite:IsEventTriggered("TinyShoot") then
        npc:FireProjectiles(npc.Position, Vector(6,0), 6, data.Params1)
        local effect = Isaac.Spawn(1000, 2, 1, npc.Position - Vector(0,10), Vector.Zero, npc)
        effect.DepthOffset = npc.Position.Y * 1.25
        npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1.5)
    elseif sprite:IsFinished("Attack") then
        data.Cooldown = mod:RandomInt(15,45)
    end
    if npc:IsDead() then
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(5), 0, data.Params2)
        for _, bone in pairs(mod:GetGatheredProjectiles()) do
            local bs = bone:GetSprite()
            bs:Load("gfx/enemies/drumstick/projectile_tinybone.anm2", true)
            bs:Play("Move")
            if data.Burnt then
                bs:ReplaceSpritesheet(0, "gfx/enemies/drumstick/projectile_tinybone_grilled.png")
                bs:LoadGraphics()
                bone:GetData().projType = "drumstickBone"
            end
        end
        npc:PlaySound(SoundEffect.SOUND_PLOP, 0.7, 0, false, 1.5)
    end
end

function mod:DrumstickHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) and not game:GetRoom():HasWater() then
        npc:GetData().Burnt = true
        npc:Kill()
    end
end

function mod:DrumstickBoneProjectile(projectile, data)
    if projectile.FrameCount % 3 == 0 then
        local trail = Isaac.Spawn(1000, 111, 0, projectile.Position, Vector.Zero, projectile):ToEffect()
        trail.Color = Color(0.95,1,0.2,1,0.3,0.5,0)
        trail.SpriteScale = Vector(0.3,0.3)
        trail.SpriteOffset = Vector(0, projectile.Height * 0.75)
        trail.DepthOffset = -80
        trail:Update()
    end
end

function mod:DrumstickBoneDeath(projectile, data)
    local fire = Isaac.Spawn(33, 10, 0, projectile.Position, Vector.Zero, projectile)
    fire.HitPoints = fire.HitPoints / 2
    fire:Update()
end