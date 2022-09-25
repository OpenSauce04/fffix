local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:piperAI(npc, subt)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		if npc.SubType == 1 then
			d.attack = 2
		else
			d.attack = 1
		end
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if subt == 69 and npc.StateFrame % 5 == 0 then
		local colortime = Color(1,1,1,1,0,0,0)
		colortime:SetColorize(math.random(4)-1, math.random(4)-1, math.random(4)-1, 1)
		sprite.Color = colortime
	end

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if d.state == "idle" then
		d.walking = true
		if (npc.StateFrame > 50 and not mod:isScareOrConfuse(npc)) or subt == 20 then
			d.state = "attack"
			mod:spriteOverlayPlay(sprite, "Shoot0" .. d.attack)
		else
			mod:spriteOverlayPlay(sprite, "Idle0" .. d.attack)
		end
	elseif d.state == "attack" then
		d.walking = false
		if sprite:IsOverlayFinished("Shoot0" .. d.attack) then
			d.state = "turn"
			mod:spriteOverlayPlay(sprite, "Turn0" .. d.attack)
		elseif sprite:GetOverlayFrame() == 21 then
			d.creepsplooting = npc.Position
			d.count = -1
			d.splashcaps = {}
			npc:PlaySound(mod.Sounds.PiperAttack,1,0,false,math.random(90,110)/100)
		else
			mod:spriteOverlayPlay(sprite, "Shoot0" .. d.attack)
		end
	elseif d.state == "turn" then
		d.walking = true
		if sprite:IsOverlayFinished("Turn0" .. d.attack) then
			d.state = "idle"
			if d.attack == 1 then
				d.attack = 2
			else
				d.attack = 1
			end
			npc.StateFrame = 0
		else
			mod:spriteOverlayPlay(sprite, "Turn0" .. d.attack)
		end
	end

	if mod:isScare(npc) and d.walking then
		npc.Velocity = (target.Position - npc.Position):Resized(-3)
	elseif d.walking or subt == 69 then
		local path = npc.Pathfinder
		d.gopos = d.gopos or mod:FindRandomValidPathPosition(npc, 3)
		if npc.Position:Distance(d.gopos) < 50 or (mod:isConfuse(npc) and npc.FrameCount % 10 == 0) then
			d.gopos = nil
		else
			local speedtime = 0.4
			if subt == 69 then
				speedtime = 2
			end
			path:FindGridPath(d.gopos, speedtime, 900, true)
		end
	else
		d.gopos = nil
		npc.Velocity = npc.Velocity * 0.8
	end

	if d.creepsplooting then
		d.count = d.count + 1
		if d.count % 4 == 0 then
			local shootdist = 40 + (5 * d.count)
			local vec = Vector(shootdist, 0)
			if d.attack == 2 then
				vec = vec:Rotated(45)
			end
			--local scalenum = (1.5 - d.count/30)
			local creepnum = 23
			local bloodcol = Color(1,1,1,1,-150 / 255,100 / 255,0)
			if subt == 69 then
			creepnum = 25
			bloodcol = Color(1,1,1,1,0,0,0)
			bloodcol:SetColorize(10, 10, 10, 1)
			end
			for i = 90, 360, 90 do
				if not d.splashcaps[i] then
					if game:GetRoom():GetGridCollisionAtPos(d.creepsplooting + vec:Rotated(i)) ~= GridCollisionClass.COLLISION_NONE then
						d.splashcaps[i] = true
					else
						local creep = Isaac.Spawn(1000, creepnum, 0, d.creepsplooting + vec:Rotated(i), nilvector, npc):ToEffect()
						creep:SetTimeout(50)
						if d.count > 10 then
						creep.Scale = 1 - d.count/50
						end
						creep:Update()

						local blood = Isaac.Spawn(1000, 2, 960, d.creepsplooting + vec:Rotated(i), nilvector, npc):ToEffect()
						blood.Scale = 0.5
						blood.Color = bloodcol
						blood:Update()

						for _, grate in pairs(Isaac.FindByType(mod.FF.Graterhole.ID, mod.FF.Graterhole.Var, -1, false, false)) do
						local distgrate = grate.Position:Distance(d.creepsplooting + vec:Rotated(i))
						if distgrate < 30 then
							d.splashcaps[i] = true
						end
				end

					end
				end
			end
			if d.count > 15 then
				d.creepsplooting = nil
			end
		end
	end
end