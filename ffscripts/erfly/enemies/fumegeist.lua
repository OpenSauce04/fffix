local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:fumegeistAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    local targetpos = target.Position

    if not d.init then
        d.state = "idle"
        local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
        d.targetvel = (gridtarget - npc.Position):Resized(5)
        d.snaps = 0
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if not d.flaming then
        npc.SplatColor = mod.ColorCharred
        if npc.FrameCount % 3 == 0 then
            local extravel = RandomVector() * math.random(1, 4)
            local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, extravel, npc)
            smoke:GetSprite().PlaybackSpeed = math.random() * 0.4 + 0.4
            smoke.SpriteScale = Vector(1.5,1.5)
            smoke.SpriteOffset = Vector(0, -25)
            smoke:Update()
        end
    else
        npc.SplatColor = mod.ColorFireJuicy
        if npc.StateFrame % 15 == 0 then
            local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
            fire.Parent = npc
            fire:Update()
        end
    end

    if d.state == "idle" then
        mod:spritePlay(sprite, "Idle")
        d.finishedShoot = false
        if not mod:isScareOrConfuse(npc) and math.abs(math.abs(npc.Position.X) - math.abs(target.Position.X)) > 20 then
            if targetpos.X > npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        end
        if npc.Position:Distance(targetpos) < 80 or mod:isScare(npc) then
            d.targetvel = (targetpos - npc.Position):Resized(-2)
            if mod:isScare(npc) then
                if d.targetvel.X > 0 then
                    sprite.FlipX = true
                else
                    sprite.FlipX = false
                end
            end
            d.running = true
        else
            if npc.StateFrame % 90 == 0 or d.running or (mod:isConfuse(npc) and npc.StateFrame % 5 == 1) then
                local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
                d.targetvel = (gridtarget - npc.Position):Resized(1.5)
                d.running = false
            end
        end
        npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.1)
        d.numbaubles = d.numbaubles or mod.GetEntityCount(mod.FF.Mote.ID,mod.FF.Mote.Var)
        if not mod:isScareOrConfuse(npc) then
            if npc.StateFrame > 70 and math.random(20) == 1 then
                d.snaps = 0
                if (d.numbaubles > 1 and math.random(3) == 1) or d.numbaubles >= 3 or mod.GetEntityCount(mod.FF.Mote.ID,mod.FF.Mote.Var) >= 3 then
                    d.state = "BecomeFire"
                    d.numbaubles = 0
                else
                    d.state = "shoot"
                    d.numbaubles = d.numbaubles + 1
                    if targetpos.X > npc.Position.X then
                        sprite.FlipX = true
                    else
                        sprite.FlipX = false
                    end
                end
            --[[elseif npc.StateFrame > 40 and math.random(30) == 1 and d.snaps < 4 then
                d.state = "SetCloud"
                d.snaps = d.snaps + 1]]
            end
        end
    elseif d.state == "shoot" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("Shoot") then
            d.state = "idle"
            npc.StateFrame = 0
            d.running = true
        elseif sprite:IsEventTriggered("Cough") then
            d.finishedShoot = true
            npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH,1,0,false,0.6)
            local dist = (targetpos - npc.Position):Resized(4)
            local bol = mod.spawnent(npc, npc.Position + dist, dist, mod.FF.Mote.ID, mod.FF.Mote.Var)
            bol.Parent = npc
            bol:Update()
            if targetpos.X > npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif d.state == "SetCloud" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("SetCloud") then
            d.state = "idle"
            npc.StateFrame = 30
            d.running = true
        elseif sprite:IsEventTriggered("SetCloud") then
            --[[local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, target.Position, nilvector, npc)
            smoke.SpriteScale = Vector(3.5,3.5)
            smoke.SpriteOffset = Vector(0, -50)
            smoke:Update()
            local vec = (RandomVector()*20)
            for i = 120, 360, 120 do
                mod.SpawnGunpowder(npc,targetpos + vec:Rotated(i), 500, 200)
            end]]

            local numKilled = 0
            local motes = Isaac.FindByType(mod.FF.Mote.ID, mod.FF.Mote.Var, -1, false, false)
            for _, ent in pairs(motes) do
                --if ent.Parent and ent.Parent.InitSeed == npc.InitSeed then
                    if not ent:GetData().flaming then
                        local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, ent.Position, nilvector, npc)
                        smoke.SpriteScale = Vector(3.5,3.5)
                        smoke.SpriteOffset = Vector(0, -50)
                        smoke:Update()
                        local vec = (RandomVector()*20)
                        for i = 120, 360, 120 do
                            mod.SpawnGunpowder(npc, ent.Position + vec:Rotated(i), 500, 200)
                        end
                        numKilled = numKilled + 1
                        ent:Kill()
                    end
                --end
            end
            if numKilled > 0 then
                npc:PlaySound(mod.Sounds.ForeseerClap,1,0,false,0.5)
            end
        else
            mod:spritePlay(sprite, "SetCloud")
        end
    elseif d.state == "BecomeFire" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("BecomeFire") then
            npc.StateFrame = 0
            d.state = "Fire"
        elseif sprite:IsEventTriggered("DMG") then
            --[[for _, entity in pairs(Isaac.FindByType(960, 351, 0, false, false)) do
                entity:GetData().flaming = true
            end]]	--He used to set motes on fire -- this was cut and now we've brought it back again
            d.flaming = true
            mod:SetRoomAlight(npc)
            npc:PlaySound(mod.Sounds.FireLight, 0.8, 0, false, 0.8)
        else
            mod:spritePlay(sprite, "BecomeFire")
        end
    elseif d.state == "Fire" then
        if (npc.StateFrame > 140 and math.random(20) == 1) or npc.StateFrame > 180 then
            d.state = "BecomeNormal"
        end
        local firetarg = mod.FindClosestUnlitPowder(npc.Position, npc)
        firetarg = firetarg or target
        local targetvel = (firetarg.Position - npc.Position):Resized(7)
        npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
        mod:spritePlay(sprite, "Fire")

        if npc.Velocity.X > 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
    elseif d.state == "BecomeNormal" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("BecomeNormal") then
            npc.StateFrame = 0
            d.state = "idle"
        elseif sprite:IsEventTriggered("NoDMG") then
            sprite.FlipX = false
            d.flaming = nil
            npc:PlaySound(mod.Sounds.FireFizzle, 0.8, 0, false, 0.8)
        else
            mod:spritePlay(sprite, "BecomeNormal")
        end
    end
end

function mod:fumegeistHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        --npc:GetData().flaming = true
        return false
    end
end

function mod:moteAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()

    if not d.init then
        d.init = true
        npc.SpriteOffset = Vector(0, -15)
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    local speed = 3.5
    local extrastring = ""
    local lerpspeed = 0.1
    if d.flaming then
        npc.SplatColor = mod.ColorFireJuicy
        if not d.fwoomed then
            npc:PlaySound(mod.Sounds.FireLight, 0.6, 0, false, 1.2)
            d.fwoomed = true
        end
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        speed = 6
        extrastring = "Fire"
        lerpspeed = 0.08
        if npc.StateFrame % 22 == 0 and not mod:isScareOrConfuse(npc) then
            local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
            fire.Parent = npc
            fire:Update()
            if mod:isFriend(npc) then
                d.count = d.count or 0
                d.count = d.count + 1
                if d.count >= 15 then
                    npc:Kill()
                end
            end
        end
    else
        npc.SplatColor = mod.ColorCharred
    end

    if mod:isConfuse(npc) then
        speed = speed * 0.7
    end

    if npc.Velocity.Y < 0 then
        mod:spritePlay(sprite, "MoveUp" .. extrastring)
    else
        mod:spritePlay(sprite, "MoveDown" .. extrastring)
    end

    if npc.Velocity.X > 0 then
        sprite.FlipX = true
    else
        sprite.FlipX = false
    end

    --local targvel = (target.Position - npc.Position):Resized(speed)
    local targvel = mod:diagonalMove(npc, speed, 1)
    if mod:isScare(npc) and target.Position:Distance(npc.Position) < 100 then
        targvel = (npc.Position - target.Position):Resized(speed)
    end
    npc.Velocity = mod:Lerp(npc.Velocity, targvel, lerpspeed)

    if not d.flaming then
        d.fwoomed = nil
        npc.SplatColor = mod.ColorCharred
        local extravel = (npc.Velocity * -1):Rotated(-20 + math.random(40))
        local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + npc.Velocity:Resized(10), extravel, npc)
        --smoke.SpriteScale = Vector(1.3,1.3)
        smoke.SpriteOffset = Vector(0, -20)
        smoke.SpriteRotation = math.random(360)
        smoke:Update()
    end
end

function mod:moteColl(npc1, npc2)
    if npc2.Type == 1 then
        --if npc1.Parent then
            if not (npc1:GetData().flaming or npc1:GetData().youAlreadyDidThisBro) then
                local p
                if npc1.Parent then
                    p = npc1.Parent
                else
                    local fumegeists = Isaac.FindByType(mod.FF.Fumegeist.ID, mod.FF.Fumegeist.Var, -1, false, false)
                    if #fumegeists > 0 then
                        p = fumegeists[math.random(#fumegeists)]
                    end
                end
                if p then
                    p = p:ToNPC()
                    if p:GetData().state == "idle" or (p:GetData().state == "shoot" and p:GetData().finishedShoot) then
                        p:GetData().state = "SetCloud"
                        npc1:GetData().youAlreadyDidThisBro = true
                    end
                end
            end
        --end
    end
end

function mod:moteHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        npc:GetData().flaming = true
        return false
    end
end