local mod = FiendFolio
local game = Game()

function mod:ignisAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()

	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.SplatColor = mod.ColorGhostly
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.direction = "Down"
		if data.waited or npc.SubType == 0 then
			sprite:Play("AppearLeft")
			data.state = "FirstSpawn"
		else
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, 55)
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	npc.Velocity = npc.Velocity*0.7

	if data.state == "Disappear" then
		if sprite:IsFinished("Vanish" .. data.direction) then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			data.state = "Hiding"
			data.waitTimer = rand:RandomInt(30)
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Vanish" .. data.direction)
		end
	elseif data.state == "Appear" then
		if npc.StateFrame >= 40 then
			local targetAngle = (target.Position-npc.Position):GetAngleDegrees()
			if data.direction == "Down" then
				data.shootDir = Vector(0,3) --90
				if math.abs(targetAngle-90) < 50 then
					data.shootDir = (target.Position-npc.Position):Resized(3)
				end
			elseif data.direction == "Left" then
				data.shootDir = Vector(-3,0) --180
				if math.abs(targetAngle-180) < 50 or math.abs(targetAngle+180) < 60 then
					data.shootDir = (target.Position-npc.Position):Resized(3)
				end
			elseif data.direction == "Up" then
				data.shootDir = Vector(0,-3) -- -90
				if math.abs(targetAngle+90) < 50 then
					data.shootDir = (target.Position-npc.Position):Resized(3)
				end
			elseif data.direction == "Right" then
				data.shootDir = Vector(3, 0) --0
				if math.abs(targetAngle) < 50 then
					data.shootDir = (target.Position-npc.Position):Resized(3)
				end
			end
			--data.shootDir = (target.Position
			data.state = "Attack"
			npc.StateFrame = 0
			sprite:Play("Shoot" .. data.direction)
		end
	elseif data.state == "Attack" then
		if npc.StateFrame >= 80 then
			data.state = "Disappear"
		elseif sprite:IsFinished("Shoot" .. data.direction) then
			mod:spritePlay(sprite, "Idle" .. data.direction)
		elseif sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
			npc:PlaySound(SoundEffect.SOUND_WEIRD_WORM_SPIT, 0.5, 0, false, 1)
			npc:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, 1.2, 0, false, 1)
			local proj = Isaac.Spawn(9, 4, 0, npc.Position, data.shootDir, npc):ToProjectile()
			if mod:isFriend(npc) then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
				proj:GetData().friend = 0
			elseif mod:isCharm(npc) then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
				proj:GetData().friend = 1
			end
			proj:GetData().projType = "Ignis"
			proj:GetData().ignisProj = true
			proj:GetData().tTimer = 0
			proj.FallingAccel = -0.1
			proj.FallingSpeed = -2
			proj.Color = mod.ColorMinMinFire --Color(1.3,0.9,0.3,1,38/255,32/255,0)
			proj.Scale = 2
			proj:Update()
		end
	elseif data.state == "Hiding" then
		if npc.StateFrame >= data.waitTimer+15 then
			local newPos = mod:FindRandomFreePosAirNoGrids(npc.Position, 40)
			local proceed = true
			for _,ignis in ipairs(Isaac.FindByType(mod.FF.Ignis.ID, mod.FF.Ignis.Var, -1, false, false)) do
				if ignis.Position:Distance(newPos) < 20 then
					proceed = false
				end
			end
			if room:CheckLine(newPos, target.Position, 3, 1, false, false) == false or (target.Position + (target.Velocity * 3)):Distance(newPos) < 90 or proceed == false then
				--npc.Position = mod:FindRandomFreePosAirNoGrids(npc.Position, 40)
			else
				npc.Position = newPos
				if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
					if (target.Position.X - npc.Position.X) >= 0 then
						data.direction = "Right"
					else
						data.direction = "Left"
					end
				else
					if (target.Position.Y - npc.Position.Y) >= 0 then
						data.direction = "Down"
					else
						data.direction = "Up"
					end
				end
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				sprite:Play("Appear" .. data.direction)
				data.state = "Appear"
			end
		end
	elseif data.state == "FirstSpawn" then
		if sprite:IsFinished("AppearDown") then
			data.state = "Disappear"
		else
			mod:spritePlay(sprite, "AppearDown")
		end
	end
end

function mod.ignisProj(v, d)
	if d.ignisProj == true then
		local rand = v:GetDropRNG()
		d.tTimer = d.tTimer+1
		if rand:RandomInt(16) == 0 or d.tTimer % 18 == 0 then
			local proj = Isaac.Spawn(9, 4, 0, v.Position, Vector(0,0.2):Rotated(rand:RandomInt(360)), v):ToProjectile()
			if d.friend == 0 then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
			elseif d.friend == 1 then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
			end
			proj.Height = v.Height
			proj.FallingAccel = -0.052
			proj.Scale = 0.3+rand:RandomInt(12)/10
			proj.Color = mod.ColorMinMinFire --Color(1,0.7,0.2,1,25/255,20/255,0)
			proj:Update()
		end
	end
end