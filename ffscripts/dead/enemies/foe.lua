local mod = FiendFolio

function mod:foeAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
	end

    local targpos = mod:confusePos(npc, target.Position)
    npc.Velocity = (npc.Velocity * 0.9) + (targpos - npc.Position):Resized(0.1)

    if not d.projectiles then
        d.projectiles = {}
    end

    if #d.projectiles < 6 and npc.StateFrame > 5 and d.state == "idle" then
        local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0, 0), npc):ToProjectile()
        proj.FallingSpeed = 0
        proj.FallingAccel = -0.1
        proj.Parent = npc
        proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.GHOST
        proj:GetData().projType = "foeorbital"
        proj:GetData().foeTarget = npc.Position

        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)

        d.projectiles[#d.projectiles + 1] = proj
    end

    npc.StateFrame = npc.StateFrame + 1

    local targetDist = target.Position:Distance(npc.Position)
    local fearConfuse = npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) or npc:HasEntityFlags(EntityFlag.FLAG_FEAR)
    if d.state == "rage" then
        if fearConfuse or npc.StateFrame > d.attackfortime then
            d.state = "sleep"
            sprite:Play("Sleep", true)
        end
    elseif d.state == "idle" and npc.StateFrame > 30 then
        local shouldTrigger = targetDist < 80
        if d.foehitpoints and npc.HitPoints < d.foehitpoints then
            shouldTrigger = true
        end

        if shouldTrigger and not fearConfuse then
            d.attackfortime = (r:Next() % 20) + 85
            d.state = "wake"
            d.ragetarget = npc.Position
            d.rageangle = npc.FrameCount
            sprite:Play("WakeUp", true)
        end
    end

    d.foehitpoints = npc.HitPoints

    local maxRageDist = 160
    local rageTarget, rageDist, rageAngle
    local orbitPercent = (math.sin(npc.FrameCount / 10) + 1) / 2
    local minOrbit, maxOrbit = 30, 50
    local orbit = mod:Lerp(minOrbit, maxOrbit, orbitPercent)
    local angle = npc.FrameCount

    if sprite:IsEventTriggered("attackstart") then
        d.recalcpositions = true
        npc.StateFrame = 0

        npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A,0.7,0,false,1.3)
    end

    if sprite:IsEventTriggered("attackend") then
        d.recalcpositions = true
        npc.StateFrame = 0
		npc:PlaySound(SoundEffect.SOUND_MOUTH_FULL,0.7,0,false,math.random(130,150)/100)
    end

    if d.state == "rage" or sprite:WasEventTriggered("attackstart") or (d.state == "sleep" and not sprite:WasEventTriggered("attackend")) then
        angle = d.rageangle
        d.ragetarget = mod:Lerp(d.ragetarget, target.Position, 0.05)
        rageDist = d.ragetarget:Distance(npc.Position)
        if rageDist > maxRageDist then
            local norm = (d.ragetarget - npc.Position) / rageDist
            rageDist = maxRageDist
            d.ragetarget = npc.Position + norm * rageDist
        end

        rageTarget = d.ragetarget
        rageAngle = (d.ragetarget - npc.Position):GetAngleDegrees()

        local targAngle = (target.Position - npc.Position):GetAngleDegrees()
        if mod:AngleDifference(rageAngle, targAngle) > 0 then
            d.rageangleadjust = mod:Lerp(d.rageangleadjust or 0, -1, 0.1)
        else
            d.rageangleadjust = mod:Lerp(d.rageangleadjust or 0, 1, 0.1)
        end

        d.rageangle = d.rageangle + d.rageangleadjust
    end

    for i = #d.projectiles, 1, -1 do
        if not d.projectiles[i]:Exists() then
            table.remove(d.projectiles, i)
        end
    end

    if #d.projectiles ~= d.projectilecount then
        d.projectilecount = #d.projectiles
        d.recalcpositions = true
    end

    local positions = {}
    for i = 1, #d.projectiles do
        local off = (360 / #d.projectiles) * i
        local projTarg = npc.Position + Vector.FromAngle(angle + off) * orbit

        if rageTarget then
            local width = orbit * 1.25
            projTarg = npc.Position + mod:PointOnEllipse(rageDist, width, angle + off, rageAngle) + Vector.FromAngle(rageAngle) * (rageDist / 2)
        end

        positions[i] = projTarg
    end

    local entPairs = d.positionpairs
    if not entPairs or d.recalcpositions then
        entPairs = mod:PairEntitiesToPositions(d.projectiles, positions)
        d.positionpairs = entPairs
        d.recalcpositions = nil
    end

    for _, pair in ipairs(entPairs) do
        local proj, projTarg = pair.ent, positions[pair.posind]
        local pdata = proj:GetData()
        pdata.foeTarget = mod:Lerp(pdata.foeTarget, projTarg, math.min(npc.StateFrame, 30) / 30)

        proj.Velocity = (pdata.foeTarget - proj.Position) / 2
        if proj.Velocity:Length() > 15 then
            proj.Velocity = proj.Velocity:Resized(15)
        end
    end

    sprite.FlipX = npc.Velocity.X > 0

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle01")
    elseif d.state == "sleep" then
        if not sprite:IsPlaying("Sleep") then
            d.state = "idle"
        end
    elseif d.state == "wake" then
        if not sprite:IsPlaying("WakeUp") then
            d.state = "rage"
        end
    elseif d.state == "rage" then
        mod:spritePlay(sprite, "Idle02")
	end
end
