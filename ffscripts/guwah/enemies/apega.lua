local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ApegaAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        data.state = "idle"
        npc.StateFrame = mod:RandomInt(15,30)
        data.HopCount = mod:RandomInt(3,6)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.Params = ProjectileParams()
        data.Params.Scale = 1.5
        data.Params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        data.Params.FallingAccelModifier = -0.1
        data.Init = true
    end
    if data.state == "idle" then
        mod:spritePlay(sprite, "Idle")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if data.HopCount <= 0 or (targetpos:Distance(npc.Position) < 120 and data.HopCount <= 2) then
                data.HopCount = mod:RandomInt(3,6)
                data.state = "open"
            else
                data.state = "hop"
                data.HopCount = data.HopCount - 1
            end
        end
    elseif data.state == "hop" then
        if sprite:IsFinished("Hop") then
            data.state = "idle"
            npc.StateFrame = 5
        elseif sprite:IsEventTriggered("Jump") then
            if npc.Pathfinder:HasPathToPos(targetpos) then
                npc.Pathfinder:FindGridPath(targetpos, 5, 900, true)
            else
                npc.Velocity = RandomVector() * 6
            end
            data.hoppin = true
        elseif sprite:IsEventTriggered("Land") then
            data.hoppin = false
            mod:PlaySound(mod.Sounds.MetalStepHeavy, npc, 0.8)
        else
            mod:spritePlay(sprite, "Hop")
        end
    elseif data.state == "open" then
        if sprite:IsFinished("Open") then
            data.state = "idleopened"
            npc.StateFrame = 120
        elseif sprite:IsEventTriggered("Open") then
            data.opened = true
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
            mod:PlaySound(mod.Sounds.SussyOpen, npc, 0.5, 5)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position, Vector(14,10), 9, data.Params)				
            for _, projectile in pairs(mod:GetGatheredProjectiles()) do
                local s = projectile:GetSprite()
                s:ReplaceSpritesheet(0, "gfx/projectiles/cupid_projectile.png")
                s:LoadGraphics()
                projectile:GetData().RotationUpdate = true
                projectile:GetData().projType = "Apega"
                projectile.TargetPosition = npc.Position
                projectile.Parent = npc
            end
            local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect.SpriteOffset = Vector(1,-20)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
        else
            mod:spritePlay(sprite, "Open")
        end
    elseif data.state == "idleopened" then
        mod:spritePlay(sprite, "Idle02")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.state = close
        end
    elseif data.state == "close" then
        if sprite:IsFinished("Close") then
            data.state = "idle"
            npc.StateFrame = mod:RandomInt(15,30)
            data.HopCount = mod:RandomInt(3,6)
        elseif sprite:IsEventTriggered("StopShoot") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
        elseif sprite:IsEventTriggered("Close") then
            data.opened = false
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
            mod:PlaySound(mod.Sounds.SussyClose, npc, 0.5, 5)
        else
            mod:spritePlay(sprite, "Close")
        end
    end
    mod.QuickSetEntityGridPath(npc, 900)
    mod.NegateKnockoutDrops(npc)
    if data.hoppin then
        npc.Velocity = npc.Velocity * 0.8
    else
        npc.Velocity = npc.Velocity * 0.5
    end
end

function mod:ApegaHurt(npc, amount, damageFlags, source)
    if not npc:GetData().opened then
        return false
    end
end

function mod:ApegaDeath(npc)
    for _ = 1, 8 do
        Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(mod:RandomInt(1,4)), npc)
    end
    npc:PlaySound(SoundEffect.SOUND_POT_BREAK, 1, 0, false, 0.8)    
end

function mod:ApegaProjectile(projectile, data)
    projectile.Velocity = mod:Lerp(projectile.Velocity, (projectile.TargetPosition - projectile.Position):Resized(14), 0.02)
    if projectile.FrameCount > 10 then
        local dist = projectile.Position:Distance(projectile.TargetPosition)
        if dist < 15 or projectile.FrameCount > 120 then
            projectile:Die()
        elseif dist < 70 then
            if projectile.Parent and not mod:IsReallyDead(projectile.Parent) then
                if projectile.Parent:GetData().state == "idleopened" then
                    projectile.Parent:GetData().state = "close"
                end
            end
        end
    end
end