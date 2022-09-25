local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:squireAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local normspeed = 11
	d.lerpnonsense = 0.04
	local chargespeed = 7

	if not d.init then
		--npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		local club = Isaac.Spawn(1000, 7011, 0, npc.Position, nilvector, npc):ToEffect()
		club.Parent = npc
		--club:FollowParent(npc)
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	end

	if mod:isScare(npc) then
		normspeed = normspeed * -1
	end


	local targetvel = (target.Position - npc.Position):Resized(normspeed)
	if mod:isConfuse(npc) then
		targetvel = npc.Velocity:Resized(normspeed * 0.3):Rotated(math.random(5,35))
	end
	if game:GetRoom():CheckLine(npc.Position,target.Position - targetvel,0,1,false,false) then
		if npc.StateFrame > 120 then
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(normspeed), 0.04)
			if npc:CollidesWithGrid() then
				npc.StateFrame = 0
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,d.lerpnonsense)
		end
		npc.State = 10
	else
		npc.StateFrame = 0
		mod:CatheryPathFinding(npc, target.Position, {
            Speed = normspeed,
            Accel = d.lerpnonsense,
            GiveUp = true
        })
		npc.State = 4
	end


	if npc.State == 4 then
		d.lerpnonsense = mod:Lerp(d.lerpnonsense, 0.04, 0.05)
		if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
			mod:spriteOverlayPlay(sprite, "HeadHori")
		else
			if npc.Velocity.Y < 0 then
				mod:spriteOverlayPlay(sprite, "HeadUp")
			else
				mod:spriteOverlayPlay(sprite, "HeadDown")
			end
		end

	elseif npc.State == 10 then
		d.lerpnonsense = mod:Lerp(d.lerpnonsense, 0.01, 0.02)
		if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
			mod:spriteOverlayPlay(sprite, "ChaseHori")
		else
			if npc.Velocity.Y < 0 then
				mod:spriteOverlayPlay(sprite, "ChaseUp")
			else
				mod:spriteOverlayPlay(sprite, "ChaseDown")
			end
		end
		--[[npc.Velocity = mod:Lerp(npc.Velocity, d.targvel, 0.2)
		if npc:CollidesWithGrid() == true then
			npc.StateFrame = 0
			npc.State = 4
		end]]
	else
		npc.State = 4
		mod:spriteOverlayPlay(sprite, "HeadDown")
	end
end

--[[function mod:squireAIOLD(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local speed = 5

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		local club = Isaac.Spawn(1000, 7011, 0, npc.Position, nilvector, npc):ToEffect()
		club.Parent = npc
		--club:FollowParent(npc)
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.State == 4 then
		sprite:RemoveOverlay()
		if npc.StateFrame > 120 and target.Position:Distance(npc.Position) < 250 then
			local xvel = npc.Velocity.X
			local yvel = npc.Velocity.Y
			local targX = target.Position.X
			local targY = target.Position.Y
			--If they're walking horizontally
			if math.abs(xvel) > math.abs(yvel) then
				--If they're above or below
				if math.abs(math.abs(targX) - math.abs(npc.Position.X)) < 20 then
					if targY < npc.Position.Y then
						d.dir = {"Up", Vector(0,-speed)}
					else
						d.dir = {"Down", Vector(0,speed)}
					end
					npc.State = 10
				--If they're in front of him
				elseif math.abs(math.abs(targY) - math.abs(npc.Position.Y)) < 20 then
					if (npc.Velocity.X > 0 and targX > npc.Position.X) then
						d.dir = {"Hori", Vector(speed,0)}
						npc.State = 10
					elseif (npc.Velocity.X < 0 and targX < npc.Position.X) then
						d.dir = {"Hori", Vector(-speed,0)}
						npc.State = 10
					end
				end
			--If they're walking Vertically
			else
				--If they're at the sides
				if math.abs(math.abs(targY) - math.abs(npc.Position.Y)) < 20 then
					if targX < npc.Position.X then
						d.dir = {"Hori", Vector(-speed,0)}
					else
						d.dir = {"Hori", Vector(speed,0)}
					end
					npc.State = 10
				--If they're in front of him
				elseif math.abs(math.abs(targX) - math.abs(npc.Position.X)) < 20 then
					if (npc.Velocity.Y > 0 and targY > npc.Position.Y) then
						d.dir = {"Down", Vector(0,speed)}
						npc.State = 10
					elseif (npc.Velocity.Y < 0 and targX < npc.Position.Y) then
						d.dir = {"Up", Vector(0,-speed)}
						npc.State = 10
					end
				end
			end
		end

	elseif npc.State == 10 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
		mod:spriteOverlayPlay(sprite, "Chase" .. d.dir[1])
		local targvel = d.dir[2]
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.2)

		if npc:CollidesWithGrid() == true then
			npc.StateFrame = 0
			npc.State = 4
		end
	end
end]]

function mod:squireClubAI(e)
	local sprite = e:GetSprite()
	local d = e:GetData()
	d.swingstate = d.swingstate or 1
	e.RenderZOffset = 500
	e.SpriteOffset = Vector(0, -8)
	if e.Parent and not mod:isStatusCorpse(e.Parent) then
		local p = e.Parent:ToNPC()
		local pd = e.Parent:GetData()
		local lerpVal = 0.6
		e.Velocity = mod:Lerp(e.Velocity,(p.Position + p.Velocity:Resized(25))-e.Position, lerpVal)
		e.SpriteRotation = (p.Position-e.Position):Rotated(90):GetAngleDegrees()

		if not mod:isScareOrConfuse(p) then
			for _, entity in pairs(Isaac.FindByType(2, -1, -1, false, false)) do
				if entity.Position:Distance(e.Position) < 20 then
					--entity.Velocity = (entity.Velocity * -1):Rotated(-30 + math.random(60))
					if p.StateFrame < 121 then
						mod:spritePlay(sprite, "Swing" .. d.swingstate + 1)
						d.swingstate =((d.swingstate + 1) % 2)
						sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
					end
					entity:Die()
				end
			end
		end

		if p.StateFrame > 120 and not mod:isScareOrConfuse(p) then
			mod:spritePlay(sprite, "ContinuousSwing")
			if sprite:IsEventTriggered("State1") then
				d.swingstate = 0
				sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("State2") then
				d.swingstate = 1
				sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
			end
		elseif not (sprite:IsPlaying("Swing1") or sprite:IsPlaying("Swing2")) then
			mod:spritePlay(sprite, "Idle" .. d.swingstate + 1)
		end
	else
		e:Remove()
	end
end