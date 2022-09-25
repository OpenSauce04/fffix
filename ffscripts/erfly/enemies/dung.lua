local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--DUNGAI
function mod:clotterAI(npc)
    local sprite  = npc:GetSprite()
    local path = npc.Pathfinder
    local target = npc:GetPlayerTarget()
    local d = npc:GetData()
    local room = game:GetRoom()
    
    if not d.init then
        d.target = room:GetRandomPosition(1)
        npc.State = 4
        d.waitTime = math.random(50)
        npc.SplatColor = mod.ColorPoop
        d.init = true
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
    end

    if npc.State == 4 then
        if sprite:IsEventTriggered("newpos") then
            d.target = mod:runIfFear(npc, room:GetRandomPosition(1), nil, true)
            npc.Velocity = nilvector
            if d.target.X > npc.Position.X then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end
        elseif sprite:IsEventTriggered("scoot") then
            if room:CheckLine(npc.Position,d.target,0,1,false,false) and npc.Position:Distance(d.target) then
                npc.Velocity = (d.target - npc.Position):Resized(7)
            else
                path:FindGridPath(d.target, 3, 900, false)
            end

            if npc.Velocity.X > 0 then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end

        end

        if path:HasPathToPos(d.target, false) then
            mod:spritePlay(sprite, "Hop")
        else
            mod:spritePlay(sprite, "Idle")
        end

        npc.Velocity = npc.Velocity * 0.95

        if math.random(3) == 1 and npc.StateFrame > 25 + d.waitTime and not mod:isScare(npc) then
                if target.Position.X < npc.Position.X then
                    sprite.FlipX = true
                else
                    sprite.FlipX = false
                end
            npc.State = 8
        end
    elseif npc.State == 8 then
        npc.Velocity = nilvector
        if sprite:IsFinished("ShootFull") then
            d.keeploop = math.random(10) + 20
            npc.State = 9
        elseif sprite:IsEventTriggered("startattack") then
            npc.StateFrame = 0
            d.attacking = true
        elseif sprite:IsEventTriggered("shoot") then
            npc:PlaySound(SoundEffect.SOUND_PLOP,0.5,2,false,math.random(8,10)/10)
            d.targetPos = mod:randomConfuse(npc, target.Position)
            local shotspeed = RandomVector()*5
        --[[local projectile = Isaac.Spawn(9, 5, 0, npc.Position, shotspeed, npc):ToProjectile();
            projectile.FallingSpeed = -15;
            projectile.FallingAccel = 1.5;
            projectile.Scale = 2]]
            local params = ProjectileParams()
            params.Scale = math.random(11, 12) / 10
            params.FallingSpeedModifier = -15 - math.random(10)/10
            params.FallingAccelModifier = 1.4 + math.random(2)/10;
            params.Variant = 5
            params.HeightModifier = 20
            npc:FireProjectiles(npc.Position, shotspeed, 0, params)
        else
            mod:spritePlay(sprite, "ShootFull")
        end
    elseif npc.State == 9 then
        npc.Velocity = nilvector
        mod:spritePlay(sprite, "ShootLoop")
        if npc.StateFrame > d.keeploop or mod:isScare(npc) then
            npc.State = 10
            npc.StateFrame = 0
            d.attacking = false
        end
    elseif npc.State == 10 then
        npc.Velocity = nilvector
        if npc.StateFrame > 75 then
            d.target = mod:runIfFear(npc, room:GetRandomPosition(1), nil, true)
            d.waitTime = math.random(50)
            npc.StateFrame = 0
            npc.State = 4
        else
            mod:spritePlay(sprite, "Pant")
        end
    end

    if d.attacking and npc.StateFrame % 2 == 1 then
        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1.3)
        local params = ProjectileParams()
        local targetpos = mod:randomConfuse(npc, target.Position)
        local shotspeed = ((targetpos - npc.Position)*0.03):Rotated(-10+math.random(20))
        --[[local projectile = Isaac.Spawn(9, 0, 0, npc.Position, shotspeed, npc):ToProjectile();
        projectile.FallingSpeed = -50 + math.random(10);
        projectile.FallingAccel = 1.4 + math.random(2)/10;
        projectile.Scale = math.random(2, 12) / 10
        projectile.Va]]
        params.Scale = math.random(2, 10) / 10
        params.FallingSpeedModifier = -50 + math.random(10);
        params.FallingAccelModifier = 1.4 + math.random(2)/10;
        params.Variant = 3
        params.HeightModifier = 20
        npc:FireProjectiles(npc.Position, shotspeed, 0, params)
    end
end