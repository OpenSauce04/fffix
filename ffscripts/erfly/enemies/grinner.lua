local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:GrinnerAI(npc)
    local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
    targetpos = targetpos + (npc.Position - targetpos):Resized(40)
	local r = npc:GetDropRNG()

    npc.StateFrame = npc.StateFrame + 1

    if d.Giggling then
        npc.Velocity = npc.Velocity * 0.2
        sprite:RemoveOverlay()
        mod:spritePlay(sprite, "Giggle")
        if npc.StateFrame > 30 and r:RandomInt(20) == 0 then
            d.Giggling = false
            npc.StateFrame = 0
        end
        if not sfx:IsPlaying(mod.Sounds.GrinnerGiggle) then
            npc:PlaySound(mod.Sounds.GrinnerGiggle, 1, 0, false, 1)
        end
    else
        if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end

		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-10)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvel = nilvector
            if targetpos:Distance(npc.Position) > 10 then
                targetvel = (targetpos - npc.Position):Resized(10)
                targetvel = targetvel:Resized(math.min(targetvel:Length(), 10))
            end
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.5, 900, true)
		end

		if npc.StateFrame > 50 and not mod:isScareOrConfuse(npc) then
			if r:RandomInt(20) == 0 then
                npc.StateFrame = 0
				d.Giggling = true
			end
		end
    end
end

function mod:GrinnerHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if not d.Giggling then
        return false
    end
end