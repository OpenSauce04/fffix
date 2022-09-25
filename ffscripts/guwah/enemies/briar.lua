local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

function mod:BriarAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        data.State = "Idle"
        data.Speed = 2
        npc.StateFrame = mod:RandomInt(15,30,rng)

        local params = ProjectileParams()
        params.Variant = mod.FF.BriarThistle.Var
        params.FallingAccelModifier = -0.1
        params.BulletFlags = ProjectileFlags.BOUNCE
        data.Params = params

        data.Init = true
    end

    if data.State == "Idle" then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 250 then
                data.State = "Shoot"
                data.Speed = 1
            end
        end
        mod:spritePlay(sprite, "Fly")
    elseif data.State == "Shoot" then
        if sprite:IsFinished("Attack") then
            data.State = "Idle"
            npc.StateFrame = mod:RandomInt(60,90,rng)
            data.Speed = 2
        elseif sprite:IsEventTriggered("Shoot") then
            local vec = (targetpos - npc.Position):Resized(10):Rotated(-15,15,rng)
            npc:FireProjectiles(npc.Position, vec, 0, data.Params)
            npc.Velocity = vec:Rotated(180):Resized(6)
            mod:PlaySound(SoundEffect.SOUND_WORM_SPIT, npc, 0.6)
        else
            mod:spritePlay(sprite, "Attack")
        end
    end

    mod:FlipSprite(sprite, npc.Position, targetpos)
    npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(data.Speed)), 0.1)
end

function mod:BriarThistleProjectile(proj, sprite, data)
    if not data.Init then
        data.Rotation = mod:RandomAngle(rng)
        data.RotVal = 5
        data.CCSpin = (rng:RandomFloat() <= 0.5)
        data.Init = true
    end

    data.RotVal = data.RotVal - 0.05
    if data.CCSpin then
        sprite.Rotation = sprite.Rotation - data.RotVal
    else
        sprite.Rotation = sprite.Rotation + data.RotVal
    end
    proj.Velocity = proj.Velocity * 0.95


    if proj.FrameCount > 45 then
        proj:Die()
    elseif proj.FrameCount > 28 then
        mod:spritePlay(sprite, "Flash")
    else
        mod:spritePlay(sprite, "Idle")
    end
end

function mod:BriarThistleDeath(proj, sprite)
    sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.4, 0, false, 1.2)

    local splat = Isaac.Spawn(1000, 2, 2, proj.Position, Vector.Zero, proj)
    splat.Color = mod.ColorPoop
    splat.SpriteOffset = proj.PositionOffset
    splat:Update()
    local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, proj.Position, Vector(0, -1), proj)
    effect:GetData().longonly = true
    effect.Color = Color(0.5, 0.5, 0.5, 1)
    effect.SpriteOffset = proj.PositionOffset
    effect:Update()

    for i = 0, 240, 120 do
        local split = Isaac.Spawn(mod.FF.BriarStinger.ID, mod.FF.BriarStinger.Var, 0, proj.Position, Vector(8,0):Rotated(i + sprite.Rotation - 30), proj):ToProjectile()
        split.ProjectileFlags = proj.ProjectileFlags - ProjectileFlags.BOUNCE
        split.Scale = proj.Scale
    end
end

function mod:BriarStingerDeath(proj, sprite)
    local poof = Isaac.Spawn(mod.FF.BriarStingerPoof.ID, mod.FF.BriarStingerPoof.Var, mod.FF.BriarStingerPoof.Sub, proj.Position, Vector.Zero, proj)
    poof:GetSprite().Rotation = sprite.Rotation
    poof.SpriteOffset = proj.PositionOffset
end

function mod:BriarStingerPoof(effect, sprite, data)
    if sprite:IsFinished("Poof") then
        effect:Remove()
    else
        mod:spritePlay(sprite, "Poof")
    end
end