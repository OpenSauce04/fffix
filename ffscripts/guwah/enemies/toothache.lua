local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:ToothacheAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local room = game:GetRoom()
    if not data.Init then
        data.state = "appear"
        data.suffix = ""
        data.movespeed = 5
        npc.StateFrame = 60
        data.Init = true
    end
    if data.state == "appear" then
        if sprite:IsFinished("Appear") then
            data.state = "idle"
            sprite:Play("Idle"..data.suffix)
        else
            mod:spritePlay(sprite, "Appear")
        end
        npc.Velocity = Vector.Zero
    elseif data.state == "idle" then
        if mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(data.movespeed), 0.05)
        else
            mod:CatheryPathFinding(npc, targetpos, {
                Speed = data.movespeed,
                Accel = 0.1,
                GiveUp = true
            })
        end
        if npc.Velocity:Length() > 0.1 then
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                if npc.Velocity.X > 0 then
                    sprite:SetAnimation("WalkRight"..data.suffix, false)
                else
                    sprite:SetAnimation("WalkLeft"..data.suffix, false)
                end
            else
                sprite:SetAnimation("WalkVerti"..data.suffix, false)
            end
        else
            mod:spritePlay(sprite, "Idle"..data.suffix)
        end
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and mod:RandomInt(0,40,rng) == 0 and npc.Velocity:Length() > 3.5 then
            if npc.Velocity.X > 0 then
                sprite.FlipX = true
            end
            data.state = "trip"
        end
    elseif data.state == "trip" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("Trip"..data.suffix) then
            data.suffix = 2
            npc.StateFrame = 60
            sprite.FlipX = false
            data.toothless = true
            data.movespeed = 7
            data.state = "idle"
            sprite:Play("Idle"..data.suffix)
        elseif sprite:IsEventTriggered("Land") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc)
            local spawnoffset = Vector(-30,0)
            if sprite.FlipX then
                spawnoffset = -spawnoffset
            end
            local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position + spawnoffset, Vector.Zero, npc)
            local backdrop = room:GetBackdropType()
            if backdrop == BackdropType.WOMB or backdrop == BackdropType.UTERO then --Make creep color more visible
                creep.Color = mod.ColorSortaRed
            end
            if data.toothless then
                local params = ProjectileParams()
                params.FallingAccelModifier = 1.5
                local shootvec = Vector(-8,0)
                if sprite.FlipX then
                    shootvec = -shootvec
                end
                for i = 1, mod:RandomInt(5,7) do
                    params.Scale = mod:RandomInt(8,12,rng) * 0.1
                    params.FallingSpeedModifier = mod:RandomInt(-5,-10,rng)
                    npc:FireProjectiles(npc.Position + spawnoffset, shootvec:Rotated(mod:RandomInt(-45,45,rng)), 0, params)
                end
                mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
            else
                for _ = 0, 3 do
                    local vec = Vector(-1,0):Resized(mod:RandomInt(5,10,rng)):Rotated(mod:RandomInt(-30,30,rng))
                    if sprite.FlipX then
                        vec = -vec
                    end
                    Isaac.Spawn(1000, 5, 0, npc.Position, vec, npc)
                end
                npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
            end
        elseif sprite:IsEventTriggered("Tooth") then
            local spawnoffset = Vector(-30,0)
            if sprite.FlipX then
                spawnoffset = -spawnoffset
            end
            while room:GetGridCollisionAtPos(npc.Position + spawnoffset) > GridCollisionClass.COLLISION_NONE and npc.Position:Distance(npc.Position + spawnoffset) > 1 do --Keep the tooth inside the room!
                spawnoffset = spawnoffset:Resized(spawnoffset:Length() - 10)
            end
            local tooth = Isaac.Spawn(mod.FF.SlingerTooth.ID,mod.FF.SlingerTooth.Var,0,npc.Position + spawnoffset, Vector.Zero, npc)
            tooth:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            local params = ProjectileParams()
            params.Variant = 1
            params.FallingAccelModifier = 1.5
            mod:SetGatheredProjectiles()
            for i = -20, 20, 40 do
                local shootvec = Vector(-1,0):Resized(mod:RandomInt(3,6,rng)):Rotated(mod:RandomInt(-8,8,rng) + i)
                if sprite.FlipX then
                    shootvec = -shootvec
                end
                params.Scale = mod:RandomInt(8,12,rng) * 0.1
                params.FallingSpeedModifier = mod:RandomInt(-10,-25,rng)
                npc:FireProjectiles(npc.Position + spawnoffset, shootvec, 0, params)
            end
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                local sprite = proj:GetSprite()
                sprite:Load("gfx/002.030_black tooth tear.anm2", true)
                sprite:ReplaceSpritesheet(0, "gfx/projectiles/toothache_tooth.png")
                sprite:LoadGraphics()
                sprite:Play("Tooth2Move", false)
                proj:GetData().tooth = true
            end
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 2, 0.8)
        else
            mod:spritePlay(sprite, "Trip"..data.suffix)
        end
    end
end