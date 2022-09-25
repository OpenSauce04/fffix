local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--spinny + dizzy (tainted spinny)
function mod:spinnyAI(npc, sprite, npcdata)
	local r = npc:GetDropRNG()
	--local topLeft = room:GetTopLeftPos()
	--local bottomRight = room:GetBottomRightPos()

	if npcdata.state == "init" then
		--npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npcdata.rotation = 0
		npcdata.state = "idle"
		npcdata.frame_count = 0
		npcdata.base_velocity = 4.24
	--npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		sprite:Play("Idle",0)
		npcdata.prev_frame = 0
		npc.Velocity = Vector(3,-3)

	elseif npcdata.state == "idle" then
		local frame = 0
		if npc.Velocity:Length() > 0 then
			npcdata.storedVel = npc.Velocity
		end
		if npc.Velocity:Length() < npcdata.base_velocity then
			if npc.Velocity:Length() > 0 then
				local difference = npcdata.base_velocity / npc.Velocity:Length()
				npc.Velocity = npc.Velocity * difference
			else
				npc.Velocity = npcdata.storedVel
			end
		end
		if mod:isScare(npc) then
			mod:runIfFearNearby(npc)
		end

		--if npc:CollidesWithGrid() == true then
		--npc.Position.X < topLeft.X or npc.Position.X > bottomRight.X or npc.Position.Y < topLeft.Y or npc.Position > topLeft.Y or
			--npcdata.TargetVelocity = mod.bounceOffWall(npc.Position, npc.Velocity)
			--npcdata.TargetVelocity = npcdata.TargetVelocity * 50
		--end

		if npc:CollidesWithGrid() and not mod:isScare(npc) then
			npc:PlaySound(SoundEffect.SOUND_SCAMPER,1,2,false,math.random(130,170)/100)
		end
		if npc.Variant == mod.FF.Dizzy.Var then
			if npcdata.rotation < 18 then
				frame = 0
			elseif npcdata.rotation < 44 then
				frame = 2
			elseif npcdata.rotation < 70 then
				frame = 4
			elseif npcdata.rotation < 96 then
				frame = 6
			elseif npcdata.rotation < 122 then
				frame = 8
			elseif npcdata.rotation < 148 then
				frame = 10
			elseif npcdata.rotation < 174 then
				frame = 12
			elseif npcdata.rotation < 210 then
				frame = 14
			elseif npcdata.rotation < 236 then
				frame = 16
			elseif npcdata.rotation < 262 then
				frame = 18
			elseif npcdata.rotation < 288 then
				frame = 20
			elseif npcdata.rotation < 312 then
				frame = 22
			elseif npcdata.rotation < 336 then
				frame = 24
			elseif npcdata.rotation < 360 then
				frame = 26
			else
				npcdata.rotation = 0
			end
		else
			if npcdata.rotation < 40 then
				frame = 0
			elseif npcdata.rotation < 80 then
				frame = 2
			elseif npcdata.rotation < 120 then
				frame = 4
			elseif npcdata.rotation < 160 then
				frame = 6
			elseif npcdata.rotation < 200 then
				frame = 8
			elseif npcdata.rotation < 240 then
				frame = 10
			elseif npcdata.rotation < 280 then
				frame = 12
			elseif npcdata.rotation < 320 then
				frame = 14
			elseif npcdata.rotation < 360 then
				frame = 16
			else
				npcdata.rotation = 0
			end
		end

		if(frame ~= npcdata.prev_frame and frame ~= 0) and not mod:isScareOrConfuse(npc) then
			if not npcdata.Dizzywait then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 0.3, 0, false, 0.9)
				local rand = r:RandomFloat()
				local params = ProjectileParams()
				local angle = -npcdata.rotation
				params.HeightModifier = -10
				if npc.Variant == mod.FF.Dizzy.Var then
					npcdata.Dizzywait = true
					params.Scale = 1.5
					params.BulletFlags = ProjectileFlags.BOUNCE
					angle = angle - 30
				else
					params.FallingSpeedModifier = 3
				end
				npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(angle), 0, params)
			else
				npcdata.Dizzywait = false
			end
		end
	npcdata.prev_frame = frame
	sprite:SetFrame(sprite:GetDefaultAnimation(), frame)
	if npc.Variant == mod.FF.Dizzy.Var then
		npcdata.rotation = math.floor(npcdata.rotation + npc.Velocity:Length() * 1.5)
	else
		npcdata.rotation = math.floor(npcdata.rotation + npc.Velocity:Length() * 2.5)
	end
	npcdata.frame_count = npcdata.frame_count + 1
	else npcdata.state = "init"
	end
end

function mod:spinnyCollide(npc, npc2, mysteryBoolean)
	if npc.Variant == 0 then
		npc.Velocity = (npc.Velocity * 0.3) + (npc2.Velocity * 0.7) * 0.7
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION , mod.spinnyCollide, 708)