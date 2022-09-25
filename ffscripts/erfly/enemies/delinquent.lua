local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function makePiss(npc, sprite)
    local peePos = Vector(20, -10)
    if sprite.FlipX then
        peePos = Vector(-20, -10)
    end
    local splat = Isaac.Spawn(1000, 7, 0, npc.Position + peePos, nilvector, npc)
    splat.Color = mod.ColorPeepPiss
    splat:Update()
end

local function findValidPissPos(npc, preferClosest)
    local room = game:GetRoom()
    local size = room:GetGridSize()
    local pissPositions = {}
    local closestPos
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollisionAtPos(gridpos) > GridCollisionClass.COLLISION_NONE then
            local pissPos = gridpos + Vector(0, 40)
            if room:IsPositionInRoom(pissPos, 0) and room:GetGridCollisionAtPos(pissPos) == GridCollisionClass.COLLISION_NONE then
                if npc.Pathfinder:HasPathToPos(pissPos, false) then
                    table.insert(pissPositions, pissPos)
                    if closestPos then
                        if pissPos:Distance(npc.Position) < closestPos[2] then
                            closestPos = {pissPos, pissPos:Distance(npc.Position)}
                        end
                    else
                        closestPos = {pissPos, pissPos:Distance(npc.Position)}
                    end
                end
            end
        end
    end
    if preferClosest and closestPos then
        return closestPos[1]
    elseif #pissPositions > 0 then
        return pissPositions[math.random(#pissPositions)]
    end
end

local function wander(npc, path, d, speed)
    if npc.FrameCount % 160 == 0 or not d.walktarg then
        d.walktarg = mod:FindRandomValidPathPosition(npc)
        npc.StateFrame = 0
    end
    if npc.Position:Distance(d.walktarg) > 30 then
        local room = game:GetRoom()
        if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) then
            local targetvel = (d.walktarg - npc.Position):Resized(speed)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
        else
            path:FindGridPath(d.walktarg, speed/10, 900, true)
        end
    else
        npc.Velocity = npc.Velocity * 0.9
    end
end

function mod:delinquentAI(npc)
    local sprite, d, target, path = npc:GetSprite(), npc:GetData(), npc:GetPlayerTarget(), npc.Pathfinder
    local room = game:GetRoom()
    local creepTimer = 150
    local peeVol = 0.3
    local peePitch = 1

    if not d.init then
        d.init = true
        if math.random(2) == 1 then
            sprite.FlipX = true
        end
        if npc.SubType == 1 then
            d.state = "idle"
        else
            d.state = "pissing"
            d.PissPos = npc.Position
            d.pissing = true
            makePiss(npc, sprite)
        end
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        if not d.PissPos or mod:isConfuse(npc) then
            if npc.FrameCount % 10 == 0 and math.random(5) == 1 then
                if target.Position:Distance(npc.Position) > 100 or not room:CheckLine(npc.Position,target.Position,0,1,false,false) then
                    d.PissPos = findValidPissPos(npc, true)
                else
                    d.PissPos = findValidPissPos(npc)
                end
            end
            --Wander
            wander(npc, path, d, 2)
        elseif d.PissPos then
            d.walktarg = nil
            if d.PissPos:Distance(npc.Position) > 10 then
                npc.StateFrame = 0
                if game:GetRoom():CheckLine(npc.Position,d.PissPos,0,1,false,false) then
                    local targetvel = (d.PissPos - npc.Position):Resized(2)
                    targetvel = targetvel:Resized(math.min(targetvel:Length(), 2))
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.2)
                else
                    path:FindGridPath(d.PissPos, 0.2, 900, true)
                end
            else
                if target.Position:Distance(npc.Position) > 100 or not room:CheckLine(npc.Position,target.Position,0,1,false,false) then
                    d.state = "pissing"
                    mod:spritePlay(sprite, "Revert2Idle02")
                else
                    npc.Velocity = npc.Velocity * 0.6
                    if npc.StateFrame > 30 then
                        d.PissPos = nil
                    end
                end
            end
        end
        if not sprite:IsPlaying("Revert2Idle02") then
            if npc.Velocity:Length() > 0.1 then
                mod:spritePlay(sprite, "WalkIdle")
                if math.abs(npc.Velocity.X) > 0.1 then
                    if npc.Velocity.X < 0 then
                        sprite.FlipX = true
                    else
                        sprite.FlipX = false
                    end
                end
            else
                mod:spritePlay(sprite, "Idle")
            end
        end
    elseif d.state == "pissing" then
        npc.Velocity = npc.Velocity * 0.6
        if not sprite:IsPlaying("Revert2Idle02") then
            mod:spritePlay(sprite, "Idle02")
        elseif sprite:IsEventTriggered("Shoot") then
            d.pissing = true
            makePiss(npc, sprite)
        end
        if not mod:isConfuse(npc) then
            if npc.FrameCount > 1 and sprite:IsPlaying("Idle02") and ((target.Position:Distance(npc.Position) < 100 and room:CheckLine(npc.Position,target.Position,0,1,false,false)) or mod:isScare(npc)) then
                d.state = "pissover"
            end
            if d.PissPos and d.PissPos:Distance(npc.Position) > 50 then
                d.state = "interrupted"
            end
        end
    elseif d.state == "interrupted" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("EndPiss") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Stop(mod.Sounds.DelinquentPee)
            sfx:Play(mod.Sounds.DelinquentPeeEnd, peeVol, 0, false, peePitch)
            d.pissing = nil
        elseif sprite:IsEventTriggered("Shoot") then
            d.pissing = nil
        else 
            mod:spritePlay(sprite, "EndPiss")
        end
    elseif d.state == "pissover" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("Transition") then
            d.state = "fleeing"
            npc.StateFrame = 0
        elseif sprite:IsPlaying("Transition") and sprite:GetFrame() == 10 then
            npc:PlaySound(mod.Sounds.DelinquentHuh, peeVol, 0, false, 1)
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Stop(mod.Sounds.DelinquentPee)
            sfx:Play(mod.Sounds.DelinquentPeeEnd, peeVol, 0, false, peePitch)
            d.pissing = nil
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(mod.Sounds.DelinquentCry, 1, 0, false, math.random(110,120)/100)
            d.bedwetting = true
            local creep = Isaac.Spawn(1000, 24, 0, npc.Position + Vector(0, -10), Vector.Zero, npc):ToEffect()
            creep.Scale = 1
            creep:SetTimeout(creepTimer) 
            creep:Update()
        else 
            mod:spritePlay(sprite, "Transition")
        end
    elseif d.state == "fleeing" then
        --print(npc.StateFrame)
        if target.Position:Distance(npc.Position) > 100 or not room:CheckLine(npc.Position,target.Position,0,1,false,false) then
            wander(npc, path, d, 4)
            if npc.StateFrame > 120 then
                d.state = "calmdown"
                d.bedwetting = nil
            end
        else
            local targetvel = (target.Position - npc.Position):Resized(-4)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
            d.walktarg = nil
            npc.StateFrame = 0
        end
        if npc.Velocity:Length() > 0.1 then
            mod:spritePlay(sprite, "Walk")
            if math.abs(npc.Velocity.X) > 0.1 then
                if npc.Velocity.X < 0 then
                    sprite.FlipX = true
                else
                    sprite.FlipX = false
                end
            end
        else
            mod:spritePlay(sprite, "Idle03")
        end
    elseif d.state == "calmdown" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("CalmDown") then
            d.state = "idle"
            d.PissPos = nil
        else 
            mod:spritePlay(sprite, "CalmDown")
        end
    end

    if d.pissing and npc.FrameCount % 10 == 0 then
        makePiss(npc, sprite)
        if not sfx:IsPlaying(mod.Sounds.DelinquentPee) then
            sfx:Play(mod.Sounds.DelinquentPee, peeVol, 0, false, peePitch)
        end
    end
    if d.bedwetting and npc.FrameCount % 5 == 0 then
        local creep = Isaac.Spawn(1000, 24, 0, npc.Position + Vector(0, -10), Vector.Zero, npc):ToEffect()
        creep.Scale = 0.5
        creep:SetTimeout(creepTimer) 
        creep:Update()
        if math.random(50) == 1 and not sfx:IsPlaying(mod.Sounds.DelinquentCry) then
            npc:PlaySound(mod.Sounds.DelinquentCry, 1, 0, false, math.random(110,120)/100)
        end
    end
end

function mod:delinquentHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.state == "pissing" then
        if npc:GetSprite():IsPlaying("Idle02") then
            d.state = "pissover"
        end
    end
end

function mod:delinquentCollision(npc1, npc2)
    if npc2.Type == npc1.Type and npc2.Variant == npc1.Variant then
        local d = npc1:GetData()
        if d.state == "pissing" and npc1:GetSprite():IsPlaying("Idle02") and npc2:GetData().state ~= "pissing" then
            d.state = "interrupted"
            d.PissPos = nil          
        end
    end
end

function mod.delinquentDeath(npc)
    sfx:Stop(mod.Sounds.DelinquentPee)
end