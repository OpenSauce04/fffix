local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:GlorfAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        sprite:Play("Appear")
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        data.Init = true
    end
    
    if data.Regenating then
        if npc.StateFrame <= 0 and room:GetGridCollisionAtPos(npc.Position) < 3 and not mod:AmISoftlocked(npc) then
            sprite:Play("Regen")
            data.RegenBuffer = data.RegenBuffer + 30
            --npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            npc.Mass = npc.Mass / 4
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
            mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 1)
            data.Regenating = false
        else
            npc.StateFrame = npc.StateFrame - 1
        end
        --stolen from erfly, sowwy (hi minichibis)
        local speed = 2.5
        local xvel = speed
        local yvel = speed
        if npc.Velocity.X < 0 then 
            xvel = xvel * -1
        end
        if npc.Velocity.Y < 0 then 
            yvel = yvel * -1
        end
        local vect = Vector(xvel, yvel)
        npc.Velocity = vect:Resized(npc.Velocity:Length() * 1.2)
        if npc.Velocity:Length() > vect:Length() then 
            npc.Velocity = npc.Velocity:Resized(vect:Length()) 
        end
    else
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsPlaying("Idle") then
            if npc.StateFrame <= 0 then
                if room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 200 then
                    data.Vel = 8
                    data.Scale = 1
                    sprite:Play("Shoot1")
                end
            else 
                npc.StateFrame = npc.StateFrame - 1
            end
        end
    end

    if sprite:IsFinished("Appear") or sprite:IsFinished("Reset") or sprite:IsFinished("Regen") then
        sprite:Play("Idle")
        data.NoRegenate = false
        npc.StateFrame = mod:RandomInt(20,40)
    elseif sprite:IsFinished("Shoot1") then
        sprite:Play("Shoot2")
    elseif sprite:IsFinished("Shoot2") then
        sprite:Play("Shoot3")
    elseif sprite:IsFinished("Shoot3") then
        sprite:Play("Reset")
    end

    if sprite:IsEventTriggered("Shoot") then
        mod:FlipSprite(sprite, targetpos, npc.Position)
        mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 0.8)
        local params = ProjectileParams()
        params.Scale = data.Scale
        npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(data.Vel), 0, params)
        local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
        effect.SpriteOffset = Vector(0,-16)
        effect.Color = Color(1,1,1,0.8)
        effect.DepthOffset = npc.Position.Y * 1.25
        data.Vel = data.Vel + 2
        data.Scale = data.Scale + 0.4
    end
end

function mod:GlorfHurt(npc, amount, damageFlags, source)
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    if npc.HitPoints - amount <= 0 and not data.NoRegenate then
        sprite:Play("Gunk")
        npc.HitPoints = npc.MaxHitPoints / 2
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        --npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        npc.Mass = npc.Mass * 4
        data.RegenBuffer = data.RegenBuffer or 0
        npc.StateFrame = mod:RandomInt(80,100) + data.RegenBuffer
        data.Regenating = true
        data.NoRegenate = true
        npc:BloodExplode()
        return false
    end
end