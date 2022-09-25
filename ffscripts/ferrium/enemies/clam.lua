local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:clamAI(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.init then
        data.vulnerable = false
        data.state = "Idle"
        data.jumps = 0
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if data.state == "Idle" then
        sprite.FlipX = npc.Velocity.X < 0
        local doAttack
        if npc.StateFrame > 10 and rng:RandomInt(25) == 0 then
            doAttack = true
        elseif npc.StateFrame > 50 then
            doAttack = true
        end

        if doAttack then
            if room:CheckLine(npc.Position, target.Position, 3, 0, false, false) and (data.jumps >= 2 or rng:RandomInt(4) == 1) and not mod:isScareOrConfuse(npc) then
                data.state = "Shoot"
                data.jumps = 0
            else
                data.state = "Jump"
                data.jumps = data.jumps+1
            end
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
        mod:spritePlay(sprite, "Idle")
    elseif data.state == "Jump" then
        if sprite:IsFinished("Jump") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Jump") then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, math.random(8,12)/10)

            local targetPos = mod:FindRandomFreePos(npc, 120, true, nil)
            data.targVel = (targetPos-npc.Position):Resized(5)
            if mod:isScare(npc) then
                data.targVel = (target.Position-npc.Position):Resized(-5)
            end
            data.jumping = true
        elseif sprite:IsEventTriggered("NoColl") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, math.random(8, 12)/10)
            data.jumping = nil
        else
            mod:spritePlay(sprite, "Jump")
        end

        if data.jumping then
            npc.Velocity = mod:Lerp(npc.Velocity, data.targVel, 0.4)
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
        end
        sprite.FlipX = npc.Velocity.X < 0
    elseif data.state == "Shoot" then
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
        sprite.FlipX = (npc:GetPlayerTarget().Position.X - npc.Position.X) < 0

        if sprite:IsFinished("Shoot") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Open") then
            data.vulnerable = true
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, math.random(8, 12)/10)
        elseif sprite:IsEventTriggered("Shoot") then
            data.vulnerable = false
            npc.StateFrame = 0
            npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 0.6, 0, false, math.random(8, 12)/10)
            data.shooting = true
        elseif sprite:IsEventTriggered("End") then
            data.shooting = false
        else
            mod:spritePlay(sprite, "Shoot")
        end

        if data.shooting then
            if npc.StateFrame % 3 == 0 then
                local vectorFacing = Vector(16,8)
                local vectorFacingB = Vector(16,-8)
                if (npc:GetPlayerTarget().Position.X - npc.Position.X) < 0 then
                    vectorFacing = Vector(-16,8)
                    vectorFacingB = Vector(-16,-8)
                end

                local params = ProjectileParams()
                params.BulletFlags = params.BulletFlags | ProjectileFlags.WIGGLE | ProjectileFlags.ACCELERATE
                params.FallingAccelModifier = -0.15
                params.FallingSpeedModifier = 0
                params.Variant = 0
                mod:SetGatheredProjectiles()

                npc:FireProjectiles(npc.Position+vectorFacing, (target.Position-npc.Position):Resized(5), 0, params)

                for _, proj in pairs(mod:GetGatheredProjectiles()) do
                    local ps = proj:GetSprite()
                    ps:ReplaceSpritesheet(0, "gfx/projectiles/clam_projectile.png")
                    ps:LoadGraphics()
                    proj:GetData().customProjSplat = "gfx/projectiles/clamSplat.png"
                end

                npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, math.random(9, 11)/10)
                local c = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position + vectorFacingB, (target.Position - npc.Position):Resized(3), npc)
                c.Color = mod.ColorLessSolidWater
            end
        end
    end
end

function mod:clamHurt(npc, damage, flag, source)
    local data = npc:GetData()
    if damage > 0 and not data.vulnerable and flag ~= flag | DamageFlag.DAMAGE_CLONES then
        npc:TakeDamage(damage/3, flag | DamageFlag.DAMAGE_CLONES, source, 0)
        npc:ToNPC().StateFrame = npc:ToNPC().StateFrame+7
        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.3, 0, false, math.random(120,160)/100)
        npc:SetColor(Color(0.5, 0.5, 0.5, 1.0, 0.2, 0.2, 0.2), 5, 0, true, false)
        return false
    end
end