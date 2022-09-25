local mod = FiendFolio
local nilvector = Vector.Zero

function mod:WatcherUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)

	if not d.Init then
		-- frame counter
		d.StateFrame = 0
		-- tracks how many teleports its done in a row
		d.Teleports = 0

		-- shoot eyeball on spawn
		d.State = "shoot"
		d.Init = true
	end

	if d.State == "flying" then
		mod:spritePlay(sprite, "Fly")

		-- chase player
		local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(1.8))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.25)

		-- teleport after 30 frames
		if npc.StateFrame > 30 then
			d.State = "teleport"
			mod:spritePlay(sprite, "TeleportOut")

			npc.StateFrame = 0
		else
			npc.StateFrame = npc.StateFrame + 1
		end

	elseif d.State == "teleport" then

		npc.Velocity = nilvector

		-- disable collisions during parts of the teleport animation sequence
		if (sprite:IsPlaying("TeleportIn")) or (sprite:IsPlaying("TeleportOut") and sprite:GetFrame() > 22) then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end

		if sprite:IsPlaying("TeleportOut") and sprite:GetFrame() == 20 then
			npc:PlaySound(mod.Sounds.WatcherTeliOutStart, 1, 0, false, 1)
		end
		if sprite:IsPlaying("TeleportOut") and sprite:GetFrame() == 48 then
			npc:PlaySound(mod.Sounds.WatcherTeliOutEnd, 1, 0, false, 1)
		end
		if sprite:IsPlaying("TeleportIn") and sprite:GetFrame() == 14 then
			npc:PlaySound(mod.Sounds.WatcherTeliInEnd, 1, 0, false, 1)
		end

		if sprite:IsFinished("TeleportOut") then
			-- attempt at ensuring that it doesnt teleport too close to the player
			-- i have no idea if this works lol
			local randpos = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 40)
			while randpos:Distance(target.Position) < 98 do
				randpos = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 40)
			end

			npc.Position = randpos

			mod:spritePlay(sprite, "TeleportIn")
			npc:PlaySound(mod.Sounds.WatcherTeliInStart, 1, 0, false, 1)
		end
		if sprite:IsFinished("TeleportIn") then
			-- count watcher eyes
			local eyes = mod.GetEntityCount(mod.FF.WatcherEye.ID, mod.FF.WatcherEye.Var) - 1

			-- chance to shoot another eyeball decreases with how many watcher eyes are in the room atm
			-- also doesnt let it teleport as long as its able to shoot and its teleported too many times in a row
			local maxEyes = 7
			local maxTeleports = 2
			if mod:isScareOrConfuse(npc) or ((math.random() < eyes * 0.1 and d.Teleports < maxTeleports) or eyes > maxEyes) and eyes > 0 then
				d.Teleports = d.Teleports + 1
				d.State = "flying"
			else
				d.Teleports = 0
				d.State = "shoot"
			end

			-- re enable collision
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end

	elseif d.State == "shoot" then
		mod:spritePlay(sprite, "Shoot")

		if sprite:IsEventTriggered("Spawn") then
			npc:PlaySound(mod.Sounds.WatcherShootEnd, 1, 0, false, 1)
			-- spawn watcher eye and set watcher as parent
			local eye = Isaac.Spawn(mod.FF.WatcherEye.ID, mod.FF.WatcherEye.Var, 0, npc.Position + Vector(0, 40), nilvector, npc)
			eye.Parent = npc
			eye:GetData().ChangedHP = true
			eye:GetData().HPIncrease = 0.1
		end
		if sprite:IsPlaying("Shoot") and sprite:GetFrame() == 1 then
			npc:PlaySound(mod.Sounds.WatcherShootStart, 1, 0, false, 1)
		end
		if sprite:IsFinished("Shoot") then
			d.State = "flying"
		end
	end
end

function mod:WatcherEyeUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	if not d.Init then
		-- no appear smoke
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		-- frame counter
		d.StateFrame = 0

		-- spin is idle state
		d.State = "spin"
		-- watcher eye lightly chases player for a short while
		d.Chase = true
		d.Init = true
	else
		d.StateFrame = d.StateFrame + 1
	end


	if d.State == "spin" then
		mod:spritePlay(sprite, "Rotate")

		-- chase player (for a little while upon spawn)
		if d.Chase then
			local targetvel = (targetpos - npc.Position):Resized(0.8)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.20)
		else -- if the parent watcher gets too close, drift away from it a little (idk why i added this)
			if (not npc.Parent == nil) and npc.Position:Distance(npc.Parent.Position) < 98 then
				local driftvel = -(npc.Parent.Position - npc.Position):Resized(0.4)
				npc.Velocity = mod:Lerp(npc.Velocity, driftvel, 0.15)
			else
				npc.Velocity = npc.Velocity * 0.8
			end
		end

		if d.StateFrame > 30 then
			local angle = (targetpos - npc.Position):GetAngleDegrees() - 90
			if angle < 0 then
				angle = angle + 360
			end

			-- gets angle from eye to the player in degrees, and then gets nearest cardinal direction
			local dir = math.floor(((angle + 45 / 2) % 360) / 45) + 1

			-- if the eye is currently facing towards that cardinal in the rotate animation
			if math.floor(sprite:GetFrame() / 3) == (dir - 1) and not mod:isScareOrConfuse(npc) then
				d.StateFrame = 0
				d.Chase = false

				d.State = "shoot"

				-- get correct shoot animation for that direction
				mod:spritePlay(sprite, "Shoot0" .. tostring(dir))
			end
		end
	elseif d.State == "shoot" then
		npc.Velocity = npc.Velocity * 0.95

		if sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.WatcherEyeShoot, 1, 0, false, 1)
			-- shoot homing projectile at player
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
			params.HomingStrength = 0.3

			npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(8), 0, params)

			d.State = "spin"
		end
	end
end
