local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:mobileMushroomAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local rng = npc:GetDropRNG()
    local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)

	if not d.init then
        d.state = "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if npc.Velocity:Length() > 0.1 then
        npc:AnimWalkFrame("WalkHori","WalkVert",0)
    else
        sprite:SetFrame("WalkVert", 0)
    end

    if d.state == "idle" then
        mod:spriteOverlayPlay(sprite, "Blocking")
        if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-2)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvel = nilvector
            targetvel = (targetpos - npc.Position):Resized(2)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.2, 900, true)
		end
        if game:GetRoom():CheckLine(npc.Position,targetpos,3,1,false,false) then
            if not mod:isScareOrConfuse(npc) then
                if npc.StateFrame > 60 and math.random(10) == 1 then
                    d.state = "shoot"
                    npc.StateFrame = 0
                end
            end
        end
    elseif d.state == "shoot" then
        npc.Velocity = npc.Velocity * 0.75
        if sprite:IsOverlayPlaying("Blocking") then
            mod:spriteOverlayPlay(sprite, "Reveal")
        elseif sprite:IsOverlayFinished("Reveal") then
            mod:spriteOverlayPlay(sprite, "Revealed")
            npc.StateFrame = 0
        elseif sprite:IsOverlayPlaying("Reveal") then
            if sprite:GetOverlayFrame() >= 3 then
                if not d.vulnerable then
                    npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                    local rand = math.random(2)
                    for i = 90, 360, 90 do
                        local ang = i
                        if rand == 1 then
                            ang = i + 45
                        end
                        npc:FireProjectiles(npc.Position, Vector(0,7):Rotated(ang) + nilvector, 0, ProjectileParams())
                    end
                    d.vulnerable = true
                end
            end
        elseif sprite:IsOverlayFinished("Hide") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsOverlayPlaying("Hide") then
            if sprite:GetOverlayFrame() >= 3 then
                d.vulnerable = false
            end
        else
            if npc.StateFrame > 60 then
               mod:spriteOverlayPlay(sprite, "Hide")
            end
        end            
    end
end

function mod:mobileMushroomHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if flag ~= flag | DamageFlag.DAMAGE_CLONES then
        if not npc:GetData().vulnerable then
            npc:TakeDamage(damage/4, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            return false
        end
    end
end