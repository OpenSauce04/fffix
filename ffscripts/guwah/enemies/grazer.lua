local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:GrazerAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    mod.QuickSetEntityGridPath(npc)

    if not data.Init then
        data.State = "Idle"
        data.Speed = 3
        npc.StateFrame = mod:RandomInt(30,90,rng)
        data.Init = true
    end

    if data.State == "Idle" then
        mod:spriteOverlayPlay(sprite, "Head")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 350 then
                local chance = 0.2 + ((1 - (npc.HitPoints / npc.MaxHitPoints)) * 0.66) 
                if rng:RandomFloat() <= chance then
                    sprite:RemoveOverlay()
                    mod:spritePlay(sprite, "ShortCircuit")
                    data.State = "Error"
                    data.Speed =  nil
                else
                    data.State = "Shoot"
                    data.Speed = 1
                end
            end
        end
    elseif data.State == "Shoot" then
        if sprite:IsOverlayFinished("Shoot") then
            data.Sounded = false
            data.Shooted = false
            data.State = "Idle"
            data.Speed = 3
            npc.StateFrame = mod:RandomInt(90,150,rng)
        elseif sprite:GetOverlayFrame() == 9 and not data.Sounded then
            local ring = Isaac.Spawn(7, 2, 2, npc.Position, (targetpos - npc.Position):Resized(8):Rotated(-20,20,rng), npc):ToLaser()
            ring.CollisionDamage = 0
            ring.Mass = 0
            ring.Parent = npc
            ring.Radius = 20
            mod:PlaySound(mod.Sounds.GrazerShoot, npc, 1, 1.5)
            data.Sounded = true
        elseif sprite:GetOverlayFrame() == 12 and not data.Shooted then
            data.Shooted = true
        else
            mod:spriteOverlayPlay(sprite, "Shoot")
        end
    elseif data.State == "Error" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.GrazerDie, npc)
            mod:PlaySound(SoundEffect.SOUND_SLOTSPAWN, npc)
        elseif sprite:IsEventTriggered("Explode") then
            npc:FireProjectiles(npc.Position, Vector(10,0), 8, ProjectileParams())
            game:BombExplosionEffects(npc.Position, 20, 0, Color.Default, npc, 1, true, true, DamageFlag.DAMAGE_EXPLOSION)
            npc:Kill()
        else
            mod:spritePlay(sprite, "ShortCircuit")
        end
    end

    if data.Speed then
        if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(data.Speed)), 0.25)
        else
            npc.Pathfinder:FindGridPath(targetpos, (data.Speed * 0.1) + 0.2, 900, true)
        end

        if npc.Velocity:Length() < 0.1 then
            sprite:SetFrame("WalkVert", 0)
        else
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                if npc.Velocity.X < 0 then
                    mod:spritePlay(sprite, "WalkHori2")
                else
                    mod:spritePlay(sprite, "WalkHori")
                end
            else
                mod:spritePlay(sprite, "WalkVert")
            end
        end
    end
end