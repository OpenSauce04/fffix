local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.peeplingdirs = {
    [0] = {0, "Up"},
    [1] = {1, "Right"},
    [2] = {2, "Down"},
    [3] = {3, "Left"}
}

function mod:peeplingAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position, 30)

    if not d.init then
        d.state = "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    local targdistance = targetpos - npc.Position
    local targrel
    if d.dir then
        targrel = mod.peeplingdirs[d.dir[1]][1]
    else
        if math.abs(targdistance.X) > math.abs(targdistance.Y) then
            if targdistance.X < 0 then
                targrel = 3 -- Left
            else
                targrel = 1 -- Right
            end
        else
            if targdistance.Y < 0 then
                targrel = 0 -- Up
            else
                targrel = 2 -- Down
            end
        end
    end

    local rangeval = targdistance:Length()
    if rangeval > 150 then
        rangeval = 150
    elseif rangeval < 100 then
        rangeval = 100
    end

    local tpa = targetpos + Vector(0, rangeval):Rotated(targrel * 90)
    local targvel
    local dist = npc.Position:Distance(tpa)

    if mod:isScare(npc) then
        targvel = (target.Position - npc.Position):Resized(-5)
    elseif dist > 70 then
        targvel = (tpa - npc.Position):Resized(7)
    else
        targvel = (tpa - npc.Position):Resized(dist / 10)
    end
    npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.2)

    if d.state == "idle" then
        mod:spritePlay(sprite, "Walk")

        --[[local readytofire
        if targrel % 2 == 0 then
            if math.abs(math.abs(npc.Position.X) - math.abs(target.Position.X)) < 50 then
                readytofire = true
            end
        else
            if math.abs(math.abs(npc.Position.Y) - math.abs(target.Position.Y)) < 50 then
                readytofire = true
            end
        end]]

        if npc.StateFrame > 10 and not mod:isScareOrConfuse(npc) then
            d.state = "shootstart"
        end
    elseif d.state == "shootstart" then
        if sprite:IsFinished("ShootStart") then
            d.state = "shoot"
            d.dir = mod.peeplingdirs[targrel]
            d.add = -2
            d.tears = {}
        else
            mod:spritePlay(sprite, "ShootStart")
        end
    elseif d.state == "shoot" then
        if sprite:IsFinished("Shoot" .. d.dir[2]) then
            d.state = "release"
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
            local vel = Vector(0, -10):Rotated((d.dir[1] * 90) - (d.add * 30))
            local p = Isaac.Spawn(9, 0, 0, npc.Position, vel, npc):ToProjectile()
            p.FallingSpeed = 0
            p.FallingAccel = -0.1
            p.Parent = npc
            p.ProjectileFlags = p.ProjectileFlags | ProjectileFlags.GHOST
            p.Color = mod.ColorNormal

            --[[local ps = p:GetSprite()
            ps:ReplaceSpritesheet(0, "gfx/projectiles/lost_contact_projectiles.png")
            ps:LoadGraphics()]]

            local pd = p:GetData()
            pd.projType = "peepling"
            pd.offset = {d.dir[1], d.add}
            pd.origVel = p.Velocity

            p:Update()

            d.add = d.add + 1
            table.insert(d.tears, p)
        else
            mod:spritePlay(sprite, "Shoot" .. d.dir[2])
        end
    elseif d.state == "release" then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished("Release") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Release") then
            npc:PlaySound(mod.Sounds.MonsterYellFlash,1.5,2,false,math.random(120,150)/100)
            d.dir = nil
            for i = 1, #d.tears do
                if d.tears[i] then
                    d.tears[i].Parent = nil
                    d.tears[i]:GetData().Fired = true
                end
            end
        else
            mod:spritePlay(sprite, "Release")
        end
    end
end

function mod.peeplingprojupdate(v,d)
    if d.projType == "peepling" then
        v.Color = mod.ColorNormal
        --[[for _, tear in pairs(Isaac.FindByType(2, -1, -1, false, false)) do
            if tear.Position:Distance(v.Position) < 20 then
                tear:Remove()
            end
        end]]
        if v.Parent and not mod:isStatusCorpse(v.Parent) then
            local p = v.Parent

            local offsetval = 55
            if v.FrameCount < 7 then
                offsetval = v.FrameCount * math.max(1, (10 - v.FrameCount/3))
                v.Velocity = p.Velocity + (d.origVel * (1 - (math.max(5, v.FrameCount))/10))
            else
                v.Velocity = p.Velocity
            end

            v.Position = p.Position + Vector(0, -offsetval):Rotated((d.offset[1] * 90) - (d.offset[2] * 30))

        else
            if d.Fired then
                v.Velocity = d.origVel
            else
                v.FallingSpeed = 1
                v.FallingAccel = 1
            end
            v.ProjectileFlags = v.ProjectileFlags ~ ProjectileFlags.GHOST
            d.projType = nil
        end
    end
end