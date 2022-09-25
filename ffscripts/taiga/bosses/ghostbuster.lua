--                      Ghostbuster                      --

--      https://www.youtube.com/watch?v=ynQsDFxTSU4      --

--                       __---__                         --
--                    _-       _--______                 --
--               __--( /     \ )XXXXXXXXXXXXX_           --
--             --XXX(   O   O  )XXXXXXXXXXXXXXX-         --
--            /XXX(       U     )        XXXXXXX\        --
--          /XXXXX(              )--_  XXXXXXXXXXX\      --
--         /XXXXX/ (      O     )   XXXXXX   \XXXXX\     --
--         XXXXX/   /            XXXXXX   \__ \XXXXX---- --
--         XXXXXX__/          XXXXXX         \__----  -  --
-- ---___  XXX__/          XXXXXX      \__         ---   --
--   --  --__/   ___/\  XXXXXX            /  ___---=     --
--     -_    ___/    XXXXXX              '--- XXXXXX     --
--       --\/XXX\ XXXXXX                      /XXXXX     --
--         \XXXXXXXXX                        /XXXXX/     --
--          \XXXXXX                        _/XXXXX/      --
--            \XXXXX--__/              __-- XXXX/        --
--             --XXXXXXX---------------  XXXXX--         --
--                \XXXXXXXXXXXXXXXXXXXXXXXX-             --
--                  --XXXXXXXXXXXXXXXXXX-                --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function ghostbusterQueuePurgatoryPositions(npc, npcdata)
	local centerPos = game:GetRoom():GetCenterPos()
	local topLeft = game:GetRoom():GetTopLeftPos()
	local bottomRight = game:GetRoom():GetBottomRightPos()
	
	local target = npc:GetPlayerTarget()
	--npcdata.PurgatoryFirstPosition = game:GetRoom():GetGridPosition(game:GetRoom():GetGridIndex(target.Position))
	--local targetAngle = (npcdata.PurgatoryFirstPosition - centerPos):GetAngleDegrees()
	local targetPos = target.Position + target.Velocity
	
	local room = game:GetRoom()
	npcdata.PurgatoryFirstPosition = room:GetGridPosition(room:GetGridIndex(room:GetClampedPosition(targetPos, 10)))
	local targetAngle = (targetPos - centerPos):GetAngleDegrees()
	
	npcdata.PurgatoryQueuedPositions = {}
	--local totalEmmissions = npcdata.EmmissionsGuzzled - 1
	local totalEmmissions = math.max(FiendFolio.Ghostbuster.Balance.MinPurgatorySpreadProjectiles, npcdata.EmmissionsGuzzled)
	for i = 1, totalEmmissions - 1 do
		local minAngle = targetAngle + 360 / totalEmmissions * (i - 0.5)
		local maxAngle = targetAngle + 360 / totalEmmissions * (i + 0.5)
		
		local randTile, randPos, randCollision
		local attempts = 0
		repeat
			randTile = game:GetRoom():GetRandomTileIndex(math.random(1, 0xffffff))
			randPos = game:GetRoom():GetGridPosition(randTile)
			randCollision = game:GetRoom():GetGridCollision(randTile)
			
			local angle = (randPos - centerPos):GetAngleDegrees()
			local isInRange = (angle > minAngle and angle <= maxAngle) or
			                  (angle + 360 > minAngle and angle + 360 <= maxAngle) or
			                  (angle + 720 > minAngle and angle + 720 <= maxAngle)
			
			local isCenterTile = (randPos - centerPos):Length() < 90
			local isWallTile = randPos.X <= topLeft.X or
			                   randPos.X >= bottomRight.X or
			                   randPos.Y <= topLeft.Y or
			                   randPos.Y >= bottomRight.Y
			local isEmptyCollision = randCollision == GridCollisionClass.COLLISION_NONE
			
			attempts = attempts + 1
		until (isInRange and (isEmptyCollision or attempts > 1000) and (not isCenterTile or attempts > 500) and not isWallTile)
		
		table.insert(npcdata.PurgatoryQueuedPositions, randPos)
	end
end

FiendFolio.Ghostbuster = {
	Balance = {
		Attacks = {
			DejaVu = 1,
			Haunting = 1,
			ChaseDown = 1,
			Inhale = 1,
		},

		Mass = 400,
		BaseFriction = 0.9,
		Speed = 3,
		TrackingFrameDelay = 4,
		MaxTrackingFrames = 6,
		PathfindingPeriod = 6,
		EmmRoomOffset = 100,
		MaxOrbitEmmissions = 3,
		MaxEmmissions = 5,
		EmmissionWaitMin = 15,
		EmmissionWaitMax = 25,
		IdleWaitMin = 30,
		IdleWaitMax = 50,
		DriftInitialHoriChargeSpeed = 11,
		DriftVertChargeSpeed = 13.5,
		DriftFinalHoriChargeSpeed = 16,
		DriftInitialHoriTrigger = 80,
		DriftVertTrigger = 100,
		DriftFinalHoriTrigger = 200,
		DriftTopCornerStall = 22,
		DriftBottomCornerStall = 22,
		DriftBreak = 40,
		DriftFireAtBreakFrame = 15,
		ShriekSpeed = 12,
		ShriekNoCollideTime = 15,
		WanderMaxTime = 60,
        SpookyChargeSpeed = 15,
		SpookyChargeDistToWall = 48 + 15 * 6,
		SpookyChargeMaxTeleports = 2,
		SpookyChargeTeleportHoriWallDist = 20,
		SpookyChargeTeleportVertWallDist = 300,
		SpookyChargeTeleportVertRand = 40,
		SpookyChargeBreak = 40,
		SpookyChargeBreakTrigger = 120,
		SpookyChargeSlide = 35,
		ChaseJumpFrames = 16,
		ChaseEndTimer = 160,
		MaxTimesSpawnCongressing = 2,
		FollowSpeed = 4.5,
		FollowSpeedDivisor = 1500,
		SuckOtherSpeed = 0.66,
		PurgatoryCooldown = 1,
		PurgatoryInitialCooldown = 15,
		PurgatoryVolleyCooldown = 3,
		MinPurgatorySpreadProjectiles = 5,
		PostInhaleCooldown = 30,
	},

	ResetEmmissionTimer = function(npcdata)
		npcdata.EmissionWait = math.random(FiendFolio.Ghostbuster.Balance.EmmissionWaitMin, FiendFolio.Ghostbuster.Balance.EmmissionWaitMax)
	end,

	GoIdle = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			sprite:Play("Idle01", true)
		--	FiendFolio.Buster.Sfx.Flying(npc)
			npcdata.IdleWait = math.random(FiendFolio.Ghostbuster.Balance.IdleWaitMin, FiendFolio.Ghostbuster.Balance.IdleWaitMax)
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if npcdata.EmissionWait <= 0 and npcdata.WasOrbitOpen then
				if #Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var) < FiendFolio.Ghostbuster.Balance.MaxEmmissions then
					-- spawn in emmission on some cooldown outside room
					local room = game:GetRoom()
					local topLeft, bottomRight = room:GetTopLeftPos(), room:GetBottomRightPos()
					local pos = Vector(math.random(topLeft.X, bottomRight.X), math.random(topLeft.Y, bottomRight.Y))
					local dir = math.random(1, 4)
					if dir == 1 then
						pos.X = topLeft.X - FiendFolio.Ghostbuster.Balance.EmmRoomOffset
					elseif dir == 2 then
						pos.X = bottomRight.X + FiendFolio.Ghostbuster.Balance.EmmRoomOffset
					elseif dir == 3 then
						pos.Y = topLeft.Y - FiendFolio.Ghostbuster.Balance.EmmRoomOffset
					else
						pos.Y = bottomRight.Y + FiendFolio.Ghostbuster.Balance.EmmRoomOffset
					end

					local emm = Isaac.Spawn(mod.FF.Emmission.ID, mod.FF.Emmission.Var, 0, pos, nilvector, npc)
					emm:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					emm.Parent = npc
					emm:GetData().FadingIn = true
					table.insert(npcdata.Orbiters, emm)
					emm:Update()
				end

				FiendFolio.Ghostbuster.ResetEmmissionTimer(npcdata)
			end

			npcdata.IdleWait = npcdata.IdleWait - 1
			return npcdata.IdleWait <= 0
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if #npcdata.RecentAttacks >= 4 then
				table.remove(npcdata.RecentAttacks)
			end
			
			local emm = #Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var)
			local weights = {}
			local attacks = {}
			
			if emm == 0 then
				weights["DejaVu"] = 1.25
				weights["Haunting"] = -99999
				weights["ChaseDown"] = 1.25
				weights["Inhale"] = -99999
			elseif emm == 1 then
				weights["DejaVu"] = 1.25
				weights["Haunting"] = 0.75
				weights["ChaseDown"] = 1.25
				weights["Inhale"] = -99999
			elseif emm == 2 then
				weights["DejaVu"] = 1.25
				weights["Haunting"] = 0.75
				weights["ChaseDown"] = 1.25
				weights["Inhale"] = 0.75
			elseif emm == 3 then
				weights["DejaVu"] = 1
				weights["Haunting"] = 1
				weights["ChaseDown"] = 1
				weights["Inhale"] = 1
			elseif emm == 4 then
				weights["DejaVu"] = 0.75
				weights["Haunting"] = 1.25
				weights["ChaseDown"] = -99999
				weights["Inhale"] = 1.25
			elseif emm >= 5 then
				weights["DejaVu"] = 0.75
				weights["Haunting"] = 1.25
				weights["ChaseDown"] = -99999
				weights["Inhale"] = 1.25
			end
			
			table.insert(attacks, "DejaVu")
			table.insert(attacks, "Haunting")
			table.insert(attacks, "ChaseDown")
			table.insert(attacks, "Inhale")
			
			for i, attack in ipairs(npcdata.RecentAttacks) do
				local n = 2 ^ (3 - i)
				weights[attack] = weights[attack] * (0.66 ^ n)
			end
			
			if npcdata.RecentAttacks[1] == "Inhale" then
				weights["Inhale"] = -99999
			end

			-- select the attack
			local r = math.random(0, 10 * #attacks)
			local attackPicked
			repeat
				for attack, weight in pairs(weights) do
					weight = weight * 10
					if r < weight then
						attackPicked = attack
						break
					end
					if weight > 0 then
						r = r - weight
					end
				end
			until r < 0 or attackPicked

			attackPicked = attackPicked or attacks[1]
			
			if #npcdata.RecentAttacks == 0 then
				-- Always open with the Initial D...
				attackPicked = "DejaVu"
			elseif #npcdata.RecentAttacks == 1 then
				-- ...then the funni sin waves...
				attackPicked = "ChaseDown"
			elseif #npcdata.RecentAttacks == 2 and emm >= 2 then
				-- ...and finally the Kirbo or spoopy
				if math.random(1, 2) == 1 then
					attackPicked = "Inhale"
				else
					attackPicked = "Haunting"
				end
			end

			table.insert(npcdata.ActionQueue, FiendFolio.Ghostbuster['Go' .. attackPicked])
			table.insert(npcdata.RecentAttacks, 1, attackPicked)
		end)
	end,

	GoWanderSide = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.WasStopped = npcdata.Stopped
			npcdata.Stopped = true
			npcdata.WanderTimer = (npcdata.WanderTimer and npcdata.WanderTimer > 0)
			                    and npcdata.WanderTimer or FiendFolio.Ghostbuster.Balance.WanderMaxTime
		end)
		table.insert(npcdata.ActionQueue, function (npc, sprite, npcdata)
			npcdata.WanderTimer = npcdata.WanderTimer - 1
			if npcdata.WanderTimer < 0 then return true end

			local room = game:GetRoom()
			local direction = (npc.Position.X - room:GetCenterPos().X > 0) and 1 or -1
			direction = Vector(direction, 0)

			local wanderMove = direction * (FiendFolio.Ghostbuster.Balance.Speed * 0.8)
			npc.Velocity = (npc.Velocity + wanderMove):Resized(FiendFolio.Ghostbuster.Balance.Speed)

			-- if within two grids of wall, continue
			return not room:IsPositionInRoom(npc.Position + direction * 80, 0)
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.Stopped = npcdata.WasStopped
			npcdata.WasStopped = nil
			npcdata.WanderTimer = nil
			npc.Velocity = nilvector
		end)
	end,

	GoWanderTopCorner = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.WasStopped = npcdata.Stopped
			npcdata.Stopped = true
		end)
		table.insert(npcdata.ActionQueue, function (npc, sprite, npcdata)
			local room = game:GetRoom()
			local center = room:GetCenterPos()
			local goRight = (npc.Position.X - center.X > 0) and 1 or -1

			local topLeft = room:GetTopLeftPos()
			local bottomRight = room:GetBottomRightPos()
			
			local targetPos = Vector(topLeft.X + 20, topLeft.Y + 15)
			if goRight == 1 then
				targetPos = Vector(bottomRight.X - 20, topLeft.Y + 15)
			end
			
			npc.Velocity = (targetPos - npc.Position):Resized(FiendFolio.Ghostbuster.Balance.Speed)
			
			-- if in top corner grid, continue
			return math.abs(npc.Position.X - targetPos.X) <= 20 and math.abs(npc.Position.Y - targetPos.Y) <= 20
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.Stopped = npcdata.WasStopped
			npcdata.WasStopped = nil
			npc.Velocity = nilvector
		end)
	end,

	GoDrifting = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			npcdata.WasStopped = npcdata.Stopped
			npcdata.Stopped = true
			local target = game:GetRoom():GetCenterPos()
			npcdata.DashLeft = npc.Position.X - target.X > 0
			local anim = npcdata.DashLeft and "DashLeftStart" or "DashRightStart"
			sprite:Play(anim, true)
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsEventTriggered("Scream") then
				sfx:Play(mod.Sounds.BusterGhostDriftStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Dash") then
				npcdata.ChargeVel = Vector(FiendFolio.Ghostbuster.Balance.DriftInitialHoriChargeSpeed * (npcdata.DashLeft and -1 or 1), 0)
				npc.Velocity = npcdata.ChargeVel
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			local room = game:GetRoom()
			local center = room:GetCenterPos()
			
			if sprite:IsPlaying("DashLeftStart") then
				sprite:Play("DashLeft")
			elseif sprite:IsPlaying("DashRightStart") then
				sprite:Play("DashRight")
			elseif math.abs(npc.Position.X - center.X) <= FiendFolio.Ghostbuster.Balance.DriftInitialHoriTrigger and 
			       (sprite:IsPlaying("DashLeftStart") or
			        sprite:IsPlaying("DashLeft"))
			then
				sprite:Play("DriftLeftStart")
			elseif math.abs(npc.Position.X - center.X) <= FiendFolio.Ghostbuster.Balance.DriftInitialHoriTrigger and 
			       (sprite:IsPlaying("DashRightStart") or
			        sprite:IsPlaying("DashRight"))
			then
				sprite:Play("DriftRightStart")
			elseif sprite:IsFinished("DriftLeftStart") then
				sprite:Play("DriftA", true)
			elseif sprite:IsFinished("DriftRightStart") then
				sprite:Play("DriftB", true)
			elseif sprite:IsFinished("DriftA") then
				sprite:Play("DriftALoop01", true)
			elseif sprite:IsFinished("DriftB") then
				sprite:Play("DriftBLoop01", true) 
			elseif math.abs(npc.Position.Y - center.Y) <= FiendFolio.Ghostbuster.Balance.DriftVertTrigger and sprite:IsPlaying("DriftALoop01") then
				sprite:Play("TurnA", true)
			elseif math.abs(npc.Position.Y - center.Y) <= FiendFolio.Ghostbuster.Balance.DriftVertTrigger and sprite:IsPlaying("DriftBLoop01") then
				sprite:Play("TurnB", true)
			elseif sprite:IsFinished("TurnA") then
				sprite:Play("DriftALoop02", true)
			elseif sprite:IsFinished("TurnB") then
				sprite:Play("DriftBLoop02", true)
			elseif math.abs(npc.Position.X - center.X) <= FiendFolio.Ghostbuster.Balance.DriftFinalHoriTrigger and sprite:IsPlaying("DriftALoop02") then
				sprite:Play("FinalTurnA", true)
			elseif math.abs(npc.Position.X - center.X) <= FiendFolio.Ghostbuster.Balance.DriftFinalHoriTrigger and sprite:IsPlaying("DriftBLoop02") then
				sprite:Play("FinalTurnB", true)
			elseif sprite:IsFinished("FinalTurnA") then
				sprite:Play("DriftALoop03", true)
			elseif sprite:IsFinished("FinalTurnB") then
				sprite:Play("DriftBLoop03", true)
			end
			
			if sprite:IsEventTriggered("Drift") then
				sfx:Play(mod.Sounds.BusterGhostSkid1, 1, 0, false, 1)
				npcdata.DriftTopCorner = FiendFolio.Ghostbuster.Balance.DriftTopCornerStall
				npcdata.SplashingProjectiles = true
			elseif sprite:IsEventTriggered("Snicker") then
				sfx:Play(mod.Sounds.BusterGhostDriftPrep, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Screech") then
				sfx:Play(mod.Sounds.BusterGhostSkid2, 1, 0, false, 1)
				npcdata.DriftBottomCorner = FiendFolio.Ghostbuster.Balance.DriftBottomCornerStall - (npcdata.DriftTopCorner or 0)
				npcdata.DriftTopCorner = nil
			elseif sprite:IsEventTriggered("SlamTheBreaks") then
				npcdata.EndingDrift = FiendFolio.Ghostbuster.Balance.DriftBreak
				npcdata.DriftBottomCorner = nil
				npcdata.DriftTopCorner = nil
				
				npcdata.SplashingProjectiles = nil
				npcdata.KickingUpProjectiles = true
			end
			
			if npcdata.DriftTopCorner and npcdata.DriftTopCorner > 0 then
				npcdata.DriftTopCorner = npcdata.DriftTopCorner - 1
				
				local angle = (npcdata.DashLeft and 180) or 0
				local speed = FiendFolio.Ghostbuster.Balance.DriftInitialHoriChargeSpeed
				if npcdata.DriftTopCorner < (FiendFolio.Ghostbuster.Balance.DriftTopCornerStall / 2) then
					angle = 90
					speed = FiendFolio.Ghostbuster.Balance.DriftVertChargeSpeed
				end
				
				local slowingMulti = (math.cos(math.pi / (FiendFolio.Ghostbuster.Balance.DriftTopCornerStall / 2) * npcdata.DriftTopCorner) + 1) / 2
				npcdata.ChargeVel = Vector.FromAngle(angle):Resized(speed * slowingMulti)
				
				local add = (npcdata.DashLeft and Vector(-3, 3)) or Vector(3, 3)
				npcdata.ChargeVel = npcdata.ChargeVel + add * (1 - slowingMulti ^ 2)
				
				if npcdata.DriftTopCorner <= 0 then npcdata.DriftTopCorner = nil end
			elseif npcdata.DriftBottomCorner and npcdata.DriftBottomCorner > 0 then
				npcdata.DriftBottomCorner = npcdata.DriftBottomCorner - 1
				
				local angle = 90
				local speed = FiendFolio.Ghostbuster.Balance.DriftVertChargeSpeed
				if npcdata.DriftBottomCorner < (FiendFolio.Ghostbuster.Balance.DriftBottomCornerStall / 2) then
					angle = (not npcdata.DashLeft and 180) or 0
					speed = FiendFolio.Ghostbuster.Balance.DriftFinalHoriChargeSpeed
				end
				
				local slowingMulti = (math.cos(math.pi / (FiendFolio.Ghostbuster.Balance.DriftBottomCornerStall / 2) * npcdata.DriftBottomCorner) + 1) / 2
				npcdata.ChargeVel = Vector.FromAngle(angle):Resized(speed * slowingMulti)
				
				local add = (npcdata.DashLeft and Vector(3, 3)) or Vector(-3, 3)
				npcdata.ChargeVel = npcdata.ChargeVel + add * (1 - slowingMulti ^ 2)
				
				if npcdata.DriftBottomCorner <= 0 then npcdata.DriftBottomCorner = nil end
			elseif npcdata.EndingDrift and npcdata.EndingDrift > 0 then
				npcdata.EndingDrift = npcdata.EndingDrift - 1
				
				local vel = (npcdata.DashLeft and Vector(1, 0)) or Vector(-1, 0)
				vel = vel:Resized(FiendFolio.Ghostbuster.Balance.DriftFinalHoriChargeSpeed)
				vel = vel * npcdata.EndingDrift / FiendFolio.Ghostbuster.Balance.DriftBreak
				npcdata.ChargeVel = vel
				
				if npcdata.EndingDrift <= 0 then 
					npcdata.EndingDrift = nil 
				elseif npcdata.EndingDrift == FiendFolio.Ghostbuster.Balance.DriftFireAtBreakFrame then
					if sprite:IsPlaying("DriftALoop03") then
						sprite:Play("Shoot02", true)
					elseif sprite:IsPlaying("DriftBLoop03") then
						sprite:Play("Shoot01", true)
					end
					
					npcdata.KickingUpProjectiles = nil
				end
			end
			
			npc.Velocity = npcdata.ChargeVel
			
			if room:HasWater() and (npcdata.SplashingProjectiles or npcdata.KickingUpProjectiles) and npc.FrameCount % 4 == 0 then
				local ripple = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_RIPPLE, 0, npc.Position, nilvector, npc)
				local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 0, npc.Position, nilvector, npc)
				for i = 1, math.random(3,6) do
					local angle = math.random() * 360
					local vel = Vector.FromAngle(angle):Resized(math.random() * 5)
					local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc)
				end
			end
			
			if room:HasWater() and npcdata.SplashingProjectiles then
				if npc.FrameCount % 3 == 0 then
					for i = -1, 1, 2 do
						local vel = npc.Velocity * -0.4
						vel = vel:Rotated(50 * i)
						
						local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, 0, npc.Position, vel, npc):ToProjectile()
						proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						proj.Height = -11.01 + math.random() * 1.02
						proj.FallingSpeed = -14.1 + math.random() * 1.02
						proj.FallingAccel = 0.9
						proj:Update()
					end
				end
				
				for j = 1, math.random(1,2) do
					if math.random() < 0.75 then
						for i = -1, 1, 2 do
							local vel = npc.Velocity * math.random(3,6) / -10
							vel = vel:Rotated(math.random(30,70) * i)
							
							local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc):ToEffect()
							drop.m_Height = -11.01 + math.random() * 1.02
							drop.FallingSpeed = -14.1 + math.random() * 4.08 - 2.04
							drop.FallingAcceleration = 0.9
							drop:GetSprite().Scale = Vector(1.2, 1.2)
							drop:Update()
						end
					end
				end
			elseif room:HasWater() and npcdata.KickingUpProjectiles then
				if math.random() < 0.75 then
					local pos = npc.Position + ((npcdata.DashLeft and Vector(15, 0)) or Vector(-15, 0))
				
					local vel = npc.Velocity * 1.1
					if npcdata.DashLeft then
						vel = vel:Rotated((math.random() ^ 0.75) * -50 + 10)
					else
						vel = vel:Rotated((math.random() ^ 0.75) * 50 - 10)
					end
				
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, 0, pos, vel, npc):ToProjectile()
					proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
					proj.Height = -5.01
					proj.FallingSpeed = -14.1 + math.random() * 10.2
					proj.FallingAccel = 0.5
					proj:Update()
				end
				
				for j = 1, math.random(1,3) do
					if math.random() < 0.75 then
						local pos = npc.Position + ((npcdata.DashLeft and Vector(15, 0)) or Vector(-15, 0))
						
						local vel = npc.Velocity * (math.random(0, 2) * 0.1 + 1)
						if npcdata.DashLeft then
							vel = vel:Rotated((math.random() ^ 0.75) * -60 + 20)
						else
							vel = vel:Rotated((math.random() ^ 0.75) * 60 - 20)
						end
						
						local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, pos, vel, npc):ToEffect()
						drop.m_Height = -5.01
						drop.FallingSpeed = -14.1 + math.random() * 4.08 - 2.04
						drop.FallingAcceleration = 0.5
						drop:GetSprite().Scale = Vector(1.2, 1.2)
						drop:Update()
					end
				end
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(mod.Sounds.BusterGhostDriftShoot, 1, 0, false, 1)
				
				local target = npc:GetPlayerTarget()
				
				local params = ProjectileParams()
				params.Variant = ProjectileVariant.PROJECTILE_TEAR
				params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
				local angle = (target.Position - npc.Position):GetAngleDegrees()
				if npcdata.DashLeft then
					if -90 < angle and angle <= 45 then
						angle = -90
					elseif 45 < angle and angle <= 180 then
						angle = 180
					end
				else
					if -90 > angle and angle >= -180 then
						angle = -90
					elseif 180 >= angle and angle >= 135 then
						angle = -90
					elseif 135 > angle and angle >= 0 then
						angle = 0
					end
				end
				
				local vec = Vector.FromAngle(angle):Resized(8)
				if room:HasWater() then
					--Close
					for i = 1, 7 do
						params.FallingSpeedModifier = -10 - math.random(20)
						params.FallingAccelModifier = 1 + (math.random() * 0.5)
						params.Scale = mod.MoistroScales[math.random(3)]
						npc:FireProjectiles(npc.Position, vec + (RandomVector() * math.random() * 5.5), 0, params)
					end
					--Wide
					for i = 1, 8 do
						params.FallingSpeedModifier = -10 - math.random(20)
						params.FallingAccelModifier = 1 + (math.random() * 0.5)
						params.Scale = mod.MoistroWideScales[math.random(3)]
						npc:FireProjectiles(npc.Position, vec + (RandomVector() * (0.5 + (math.random() * 0.5)) * 6.5), 0, params)
					end
							
					--Close
					for i = 1, 14 do
						local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, 
												 npc.Position, vec + (RandomVector() * math.random() * 5.5), npc):ToEffect()
						drop.FallingSpeed = -10 - math.random(20)
						drop.FallingAcceleration = 1 + (math.random() * 0.5)
						drop:Update()
					end
							
					--Wide
					for i = 1, 16 do
						local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, 
												 npc.Position, vec + (RandomVector() * (0.5 + (math.random() * 0.5)) * 6.5), npc):ToEffect()
						drop.FallingSpeed = -10 - math.random(20)
						drop.FallingAcceleration = 1 + (math.random() * 0.5)
						drop:Update()
					end
				else
					--Close
					for i = 1, 7 do
						local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, 
						                          npc.Position, 
						                          vec * 1.5 + (RandomVector() * math.random() * 5.5), 
						                          npc)
						--smoke.SpriteScale = Vector(1,1)
						smoke.SpriteOffset = Vector(0, -30)
						smoke:Update()
					end
					--Wide
					for i = 1, 8 do
						local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, 
						                          npc.Position, 
						                          vec * 1.5 + (RandomVector() * (0.5 + (math.random() * 0.5)) * 6.5), 
						                          npc)
					end
				end
			end
			
			if sprite:IsFinished("Shoot01") or sprite:IsFinished("Shoot02") then
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				npcdata.Stopped = npcdata.WasStopped
				npcdata.WasStopped = nil
				npcdata.DashLeft = nil
				npcdata.DriftTopCorner = nil
				npcdata.DriftBottomCorner = nil
				npcdata.EndingDrift = nil
				npcdata.ChargeVel = nil
				npcdata.SplashingProjectiles = nil
				npcdata.KickingUpProjectiles = nil
				return true
			else
				return false
			end
		end)
	end,

	GoDejaVu = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.Stopped = true
		end)
		FiendFolio.Ghostbuster.GoWanderTopCorner(npc, sprite, npcdata)
		FiendFolio.Ghostbuster.GoDrifting(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			sprite:Play("Idle01", true)
	--		FiendFolio.Buster.Sfx.Flying(npc)
			npcdata.Stopped = false
		end)
	end,

	GoSpookyDashOld = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			sprite:Play("HauntStart01", true)
			npcdata.Stopped = true
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsEventTriggered("Snicker") then
				sfx:Play(mod.Sounds.BusterGhostDashStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("ReleaseEmmissions") then
				-- send out emmissions
				for _, orbiter in ipairs(npcdata.Orbiters) do
					orbiter.Parent = nil
				end
				npcdata.Orbiters = {}
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsFinished("HauntStart01") then
				sprite:Play("HauntStart02", true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsFinished("HauntStart02") then
				npcdata.WasStopped = npcdata.Stopped
				npcdata.Stopped = true
				local target = game:GetRoom():GetCenterPos()
				npcdata.DashLeft = npc.Position.X - target.X > 0
				npcdata.TimesTeleported = 0
				local anim = npcdata.DashLeft and "DashLeftStart" or "DashRightStart"
				sprite:Play(anim, true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = npc.Velocity * 0.97
			if sprite:IsEventTriggered("Scream") then
				sfx:Play(mod.Sounds.BusterGhostDriftStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Dash") then
				npcdata.ChargeVel = Vector(FiendFolio.Ghostbuster.Balance.SpookyChargeSpeed * (npcdata.DashLeft and -1 or 1), 0)
				npc.Velocity = npcdata.ChargeVel
				--sfx:Play(mod.Sounds.BusterChargeLoop, 1, 0, true, 1)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			
			if sprite:IsPlaying("DashLeftStart") then
				sprite:Play("DashLeft")
			elseif sprite:IsPlaying("DashRightStart") then
				sprite:Play("DashRight")
			end
			
			local room = game:GetRoom()
			local center = room:GetCenterPos()
			local topLeft = room:GetTopLeftPos()
			local bottomRight = room:GetBottomRightPos()
			local onLeftSide = npc.Position.X - center.X < 0
			local direction = (npcdata.DashLeft and Vector(-1, 0)) or Vector(1, 0)
			
			if npcdata.PreparingToBlink ~= nil then
				npcdata.PreparingToBlink = npcdata.PreparingToBlink - 1
			
				if npcdata.PreparingToBlink <= 0 then
					npcdata.PreparingToBlink = nil
					
					npcdata.TimesTeleported = npcdata.TimesTeleported + 1
					npcdata.DashLeft = not npcdata.DashLeft
					npcdata.ChargeVel = npcdata.ChargeVel * -1
					
					if room:HasWater() then
						npcdata.IsInReflection = npcdata.TimesTeleported % 2 == 1
					end
					
					local blink = Isaac.Spawn(1000, 1752, 0, npc.Position, nilvector, npc):ToEffect()
					blink:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					blink:GetSprite():Play("Blink", true)
					blink.PositionOffset = Vector(0,-20)
					blink.SpriteScale = Vector(1.5, 1.5)
					blink:GetSprite().Color = Color(1,1,1,0.5,0,0,0)
					sfx:Play(mod.Sounds.BusterGhostDashBlink, 1, 0, false, 0.9 + 0.2 * math.random())
					
					for i = 30, 360, 30 do
						local expvec = Vector(0,math.random(10,35)):Rotated(i)
						local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position + expvec * 0.1, expvec * 0.3, npc):ToEffect()
						sparkle.SpriteOffset = Vector(0,-25)
						sparkle:Update()
				
						local color = Color(1,1,1,1,0,0,0)
						color:SetColorize(1,1,2,1)
						sparkle:GetSprite().Color = color
					end
					
					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.GHOST
					params.Variant = ProjectileVariant.PROJECTILE_TEAR
					for i = 1, 4 do
						npc:FireProjectiles(npc.Position, Vector.FromAngle(35 + ((i % 2) * 20) + i * 90) * 14, 0, params)
					end
					
					local target = npc:GetPlayerTarget()
					
					local x = (npcdata.DashLeft and bottomRight.X + FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist) or
							  topLeft.X - FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist
					local y = target.Position.Y +
							  math.random(-1 * FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertRand,
										  FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertRand)
					
					y = math.max(y, topLeft.Y + FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportHoriWallDist)
					y = math.min(y, bottomRight.Y - FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportHoriWallDist)
					
					npc.Position = Vector(x, y)
					
					if sprite:IsPlaying("DashLeft") or sprite:IsPlaying("DashLeftStart") then
						sprite:Play("DashRight", true)
					elseif sprite:IsPlaying("DashRight") or sprite:IsPlaying("DashRightStart") then
						sprite:Play("DashLeft", true)
					end
				end
			elseif npcdata.DashLeft == onLeftSide and 
			   not room:IsPositionInRoom(npc.Position + direction * FiendFolio.Ghostbuster.Balance.SpookyChargeDistToWall, 0) and
			   npcdata.TimesTeleported < FiendFolio.Ghostbuster.Balance.SpookyChargeMaxTeleports
			then
				npcdata.PreparingToBlink = 6
			elseif math.abs(npc.Position.X - center.X) <= FiendFolio.Ghostbuster.Balance.SpookyChargeBreakTrigger and 
			       npcdata.TimesTeleported >= FiendFolio.Ghostbuster.Balance.SpookyChargeMaxTeleports 
			then
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npcdata.EndingHaunting = FiendFolio.Ghostbuster.Balance.SpookyChargeBreak
				npc.Velocity = npcdata.ChargeVel
				return true
			end
			
			--if npcdata.DashLeft then
			--	local volume = math.max(0, math.min(1, 1 - (npc.Position.X - bottomRight.X) / FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist))
				--sfx:AdjustVolume(mod.Sounds.BusterChargeLoop, volume)
			--else
			--	local volume = math.max(0, math.min(1, 1 - (topLeft.X - npc.Position.X) / FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist))
				--sfx:AdjustVolume(mod.Sounds.BusterChargeLoop, volume)
			--end
			
			if room:HasWater() and npcdata.IsInReflection and npc.FrameCount % 4 == 0 and room:IsPositionInRoom(npc.Position, 0) then
				local ripple = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_RIPPLE, 0, npc.Position, nilvector, npc)
				local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 0, npc.Position, nilvector, npc)
				for i = 1, math.random(3,6) do
					local angle = math.random() * 360
					local vel = Vector.FromAngle(angle):Resized(math.random() * 5)
					local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc)
				end
			end
			
			npc.Velocity = npcdata.ChargeVel
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if npcdata.EndingHaunting and npcdata.EndingHaunting > 0 then
				npcdata.EndingHaunting = npcdata.EndingHaunting - 1
				
				local vel = (npcdata.DashLeft and Vector(-1, 0)) or Vector(1, 0)
				vel = vel:Resized(FiendFolio.Ghostbuster.Balance.SpookyChargeSpeed)
				vel = vel * npcdata.EndingHaunting / FiendFolio.Ghostbuster.Balance.SpookyChargeBreak
				npc.Velocity = vel
				
				if npcdata.EndingHaunting <= 0 then 
					npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
					npcdata.Stopped = npcdata.WasStopped
					npcdata.WasStopped = nil
					npcdata.DashLeft = nil
					npcdata.TimesTeleported = nil
					npcdata.ChargeVel = nil
					npcdata.EndingHaunting = nil
					npcdata.PreparingToBlink = nil
					--sfx:Stop(mod.Sounds.BusterChargeLoop)
					return true
				end
			end
			return false
		end)
	end,

	GoSpookyDash = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			sprite:Play("HauntStart01", true)
			npcdata.Stopped = true
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsEventTriggered("Snicker") then
				sfx:Play(mod.Sounds.BusterGhostDashStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("ReleaseEmmissions") then
				-- send out emmissions
				for _, orbiter in ipairs(npcdata.Orbiters) do
					orbiter.Parent = nil
				end
				npcdata.Orbiters = {}
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsFinished("HauntStart01") then
				sprite:Play("HauntStart02", true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsFinished("HauntStart02") then
				npcdata.WasStopped = npcdata.Stopped
				npcdata.Stopped = true
				local target = game:GetRoom():GetCenterPos()
				npcdata.DashLeft = npc.Position.X - target.X > 0
				npcdata.TimesTeleported = 0
				local anim = npcdata.DashLeft and "DashLeftStart" or "DashRightStart"
				sprite:Play(anim, true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = npc.Velocity * 0.97
			if sprite:IsEventTriggered("Scream") then
				sfx:Play(mod.Sounds.BusterGhostDriftStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Dash") then
				npcdata.ChargeVel = Vector(FiendFolio.Ghostbuster.Balance.SpookyChargeSpeed * (npcdata.DashLeft and -1 or 1), 0)
				npc.Velocity = npcdata.ChargeVel
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			
			if sprite:IsPlaying("DashLeftStart") then
				sprite:Play("DashLeft")
			elseif sprite:IsPlaying("DashRightStart") then
				sprite:Play("DashRight")
			end
			
			local room = game:GetRoom()
			local center = room:GetCenterPos()
			local topLeft = room:GetTopLeftPos()
			local bottomRight = room:GetBottomRightPos()
			local onLeftSide = npc.Position.X - center.X < 0
			local direction = (npcdata.DashLeft and Vector(-1, 0)) or Vector(1, 0)
			
			if npcdata.PreparingToBlink ~= nil then
				npcdata.PreparingToBlink = npcdata.PreparingToBlink - 1
			
				if npcdata.PreparingToBlink <= 0 then
					npcdata.PreparingToBlink = nil
					
					npcdata.TimesTeleported = npcdata.TimesTeleported + 1
					npcdata.DashLeft = not npcdata.DashLeft
					npcdata.ChargeVel = npcdata.ChargeVel * -1
					
					if room:HasWater() then
						npcdata.IsInReflection = npcdata.TimesTeleported % 2 == 1
					end
					
					local blink = Isaac.Spawn(1000, 1752, 0, npc.Position, nilvector, npc):ToEffect()
					blink:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					blink:GetSprite():Play("Blink", true)
					blink.PositionOffset = Vector(0,-20)
					blink.SpriteScale = Vector(1.5, 1.5)
					blink:GetSprite().Color = Color(1,1,1,0.5,0,0,0)
					sfx:Play(mod.Sounds.BusterGhostDashBlink, 1, 0, false, 0.9 + 0.2 * math.random())
					
					for i = 30, 360, 30 do
						local expvec = Vector(0,math.random(10,35)):Rotated(i)
						local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position + expvec * 0.1, expvec * 0.3, npc):ToEffect()
						sparkle.SpriteOffset = Vector(0,-25)
						sparkle:Update()
				
						local color = Color(1,1,1,1,0,0,0)
						color:SetColorize(1,1,2,1)
						sparkle:GetSprite().Color = color
					end
					
					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.GHOST
					params.Variant = ProjectileVariant.PROJECTILE_TEAR
					for i = 1, 4 do
						npc:FireProjectiles(npc.Position, Vector.FromAngle(35 + ((i % 2) * 20) + i * 90) * 14, 0, params)
					end
					
					local target = npc:GetPlayerTarget()
					
					local x = (npcdata.DashLeft and bottomRight.X + FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist) or
							  topLeft.X - FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist
					local y = target.Position.Y +
							  math.random(-1 * FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertRand,
										  FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertRand)
					
					y = math.max(y, topLeft.Y + FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportHoriWallDist)
					y = math.min(y, bottomRight.Y - FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportHoriWallDist)
					
					npc.Position = Vector(x, y)
					
					if sprite:IsPlaying("DashLeft") or sprite:IsPlaying("DashLeftStart") then
						sprite:Play("DashRight", true)
					elseif sprite:IsPlaying("DashRight") or sprite:IsPlaying("DashRightStart") then
						sprite:Play("DashLeft", true)
					end
					
					local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var, -1, true)
					for _, emm in ipairs(emmissions) do
						if npcdata.TimesTeleported < FiendFolio.Ghostbuster.Balance.SpookyChargeMaxTeleports then
							emm:GetData().WanderTargetY = npc.Position.Y
						else 
							emm:GetData().WanderTargetX = center.X
							emm:GetData().WanderTargetY = center.Y
						end
					end
				end
			elseif npcdata.DashLeft == onLeftSide and 
			   not room:IsPositionInRoom(npc.Position + direction * FiendFolio.Ghostbuster.Balance.SpookyChargeDistToWall, 0) and
			   npcdata.TimesTeleported < FiendFolio.Ghostbuster.Balance.SpookyChargeMaxTeleports
			then
				npcdata.PreparingToBlink = 6
			end
			
			if npcdata.TimesTeleported >= FiendFolio.Ghostbuster.Balance.SpookyChargeMaxTeleports then
				--npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npc.Position = Vector(npc.Position.X, center.Y)
				npc.Velocity = npcdata.ChargeVel
				
				if npcdata.DashLeft then
					sprite:Play("DriftAPrep", true)
				else
					sprite:Play("DriftBPrep", true)
				end
				
				return true
			end
			
			--if npcdata.DashLeft then
			--	local volume = math.max(0, math.min(1, 1 - (npc.Position.X - bottomRight.X) / FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist))
				--sfx:AdjustVolume(mod.Sounds.BusterChargeLoop, volume)
			--else
			--	local volume = math.max(0, math.min(1, 1 - (topLeft.X - npc.Position.X) / FiendFolio.Ghostbuster.Balance.SpookyChargeTeleportVertWallDist))
				--sfx:AdjustVolume(mod.Sounds.BusterChargeLoop, volume)
			--end
			
			if npcdata.IsInReflection and room:IsPositionInRoom(npc.Position, 0) then
				if room:HasWater() then
					if npc.FrameCount % 4 == 0 then
						local ripple = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_RIPPLE, 0, npc.Position, nilvector, npc)
						local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 0, npc.Position, nilvector, npc)
						for i = 1, math.random(3,6) do
							local angle = math.random() * 360
							local vel = Vector.FromAngle(angle):Resized(math.random() * 5)
							local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc)
						end
					end
					
					for j = 1, math.random(1,2) do
						if math.random() < 0.75 then
							for i = -1, 1, 2 do
								local vel = npc.Velocity * math.random(3,6) / -10
								vel = vel:Rotated(math.random(30,70) * i)
								
								local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc):ToEffect()
								drop.m_Height = -11.01 + math.random() * 1.02
								drop.FallingSpeed = -7.05 + math.random() * 2.04 - 1.02
								drop.FallingAcceleration = 0.9
								drop:GetSprite().Scale = Vector(1.2, 1.2)
								drop:Update()
							end
						end
					end
				end
				
				local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var, -1, true)
				for _, emm in ipairs(emmissions) do
					if not emm:GetData().Bounced and (emm.Position - npc.Position):Length() <= npc.Size + emm.Size + 10 then
						emm:GetData().Bounced = true
						emm:GetData().FallingSpeed = -30
						emm:GetData().FallingAccel = 1.3
					end
				end
			end
			
			npc.Velocity = npcdata.ChargeVel
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = npcdata.ChargeVel
			
			local room = game:GetRoom()
			local center = room:GetCenterPos()
			
			if math.abs(center.X - npc.Position.X) < 160 then
				if sprite:IsPlaying("DriftAPrep") then
					sprite:Play("DriftA")
				elseif sprite:IsPlaying("DriftBPrep") then
					sprite:Play("DriftB")
				end
				--sfx:Play(mod.Sounds.BusterGhostDriftPrep, 1, 0, false, 1)
				
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			npc.Velocity = npcdata.ChargeVel
			
			if sprite:IsEventTriggered("Drift") then
				npcdata.EndingHaunting = FiendFolio.Ghostbuster.Balance.SpookyChargeSlide
				sfx:Play(mod.Sounds.BusterGhostSkid2, 1, 0, false, 1)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("DriftA") then
				sprite:Play("DriftALoop01", true)
			elseif sprite:IsFinished("DriftB") then
				sprite:Play("DriftBLoop01", true)
			end
			
			local room = game:GetRoom()
				
			if npcdata.EndingHaunting and npcdata.EndingHaunting > 0 then
				npcdata.EndingHaunting = npcdata.EndingHaunting - 1
				
				local vel = (npcdata.DashLeft and Vector(-1, 0)) or Vector(1, 0)
				vel = vel:Resized(FiendFolio.Ghostbuster.Balance.SpookyChargeSpeed)
				vel = vel * (npcdata.EndingHaunting / FiendFolio.Ghostbuster.Balance.SpookyChargeSlide) ^ 1.4
				npc.Velocity = vel
				
				if room:HasWater() and npc.Velocity:Length() > 3 then
					if math.random() < 0.8 then
						local pos = npc.Position + ((npcdata.DashLeft and Vector(-15, 0)) or Vector(15, 0))
					
						local rotmod = 1
						if npcdata.LastRotMod == 1 then
							rotmod = -1
						end
						npcdata.LastRotMod = rotmod
					
						local vel = npc.Velocity * 1.2
						local rot = math.random() * 45 * rotmod
						vel = vel:Rotated(rot)
					
						local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, 0, pos, vel, npc):ToProjectile()
						proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						proj.Height = -5.01
						proj.FallingSpeed = -14.1 + math.random() * 10.2
						proj.FallingAccel = 0.5
						proj:Update()
					end
					
					for j = 1, math.random(1,3) do
						if math.random() < 0.75 then
							local pos = npc.Position + ((npcdata.DashLeft and Vector(-15, 0)) or Vector(15, 0))
							
							local vel = npc.Velocity * (math.random(0, 2) * 0.1 + 1)
							if npcdata.DashLeft then
								vel = vel:Rotated(math.random() * -90 + 45)
							else
								vel = vel:Rotated(math.random() * 90 - 45)
							end
							
							local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, pos, vel, npc):ToEffect()
							drop.m_Height = -5.01
							drop.FallingSpeed = -14.1 + math.random() * 4.08 - 2.04
							drop.FallingAcceleration = 0.5
							drop:GetSprite().Scale = Vector(1.2, 1.2)
							drop:Update()
						end
					end
				
					local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var, -1, true)
					for _, emm in ipairs(emmissions) do
						if not emm:GetData().Bounced and (emm.Position - npc.Position):Length() <= npc.Size + emm.Size + 10 then
							emm:GetData().Bounced = true
							emm:GetData().FallingSpeed = -15
							emm:GetData().FallingAccel = 1
							
							local angle = (emm.Position - npc.Position):GetAngleDegrees()
							if npc:GetData().DashLeft then
								if angle >= -155 and angle <= 0 then
									angle = -155
								elseif angle >= 0 and angle <= 155 then
									angle = 155
								end
							else
								if angle >= 25 and angle <= 180 then
									angle = 25
								elseif angle >= -180 and angle <= -25 then
									angle = -25
								end
							end
							emm:GetData().BouncedVel = Vector.FromAngle(angle):Resized(npc.Velocity:Length() * 1.2)
						end
					end
				end
				
				if npc.Velocity:Length() <= 3 then
					if sprite:IsPlaying("DriftALoop01") then
						sprite:Play("HauntLeftEnd", true)
					elseif sprite:IsPlaying("DriftBLoop01") then
						sprite:Play("HauntRightEnd", true)
					end
				end
			end
			
			if sprite:IsFinished("HauntLeftEnd") or sprite:IsFinished("HauntRightEnd") then 
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				npcdata.Stopped = npcdata.WasStopped
				npcdata.WasStopped = nil
				npcdata.DashLeft = nil
				npcdata.TimesTeleported = nil
				npcdata.ChargeVel = nil
				npcdata.EndingHaunting = nil
				npcdata.PreparingToBlink = nil
				npcdata.LastRotMod = nil
				sprite:Play("Idle01", true)
				
				local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var, -1, true)
				for _, emm in ipairs(emmissions) do
					emm:GetData().WanderTargetX = nil
					emm:GetData().WanderTargetY = nil
				end
				
				return true
			end
			return false
		end)
	end,

	GoHaunting = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.Stopped = true
		end)
		FiendFolio.Ghostbuster.GoWanderSide(npc, sprite, npcdata)
		FiendFolio.Ghostbuster.GoSpookyDash(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if not sprite:IsPlaying("Idle01") then
				sprite:Play("Idle01", true)
			end
	--		FiendFolio.Buster.Sfx.Flying(npc)
			npcdata.Stopped = false
		end)
	end,

	GoChase = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.WasStopped = npcdata.Stopped
			npcdata.Stopped = true
			sprite:Play("CallEmissions", true)
			npc.Velocity = nilvector
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsEventTriggered("Snicker") then
				sfx:Play(mod.Sounds.BusterGhostChaseStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Scream") then
				sfx:Play(mod.Sounds.BusterGhostCallEmissionsScream, 1, 0, false, 1)
				
				-- send out commissions radially at semi-high speed and berserk them
				for _, orbiter in ipairs(npcdata.Orbiters) do
					local odata = orbiter:GetData()
					if odata.OrbitState == 'Orbiting' then
						orbiter.Velocity = (orbiter.Position - npc.Position):Resized(FiendFolio.Ghostbuster.Balance.ShriekSpeed)
						odata.NoCollideFrames = FiendFolio.Ghostbuster.Balance.ShriekNoCollideTime
					end
					orbiter.Parent = nil
				end
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			if sprite:IsFinished("CallEmissions") then
				sprite:Play("ChaseStart", true)
				npcdata.SpawningCongressing = 0
				npcdata.TimesSpawnedCongressing = 0
				npcdata.SpawningCongressingDir = math.random(1, 2)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsEventTriggered("ChaseJump") then
				sfx:Play(mod.Sounds.BusterGhostCallEmissionsStart, 1, 0, false, 1)
				npcdata.DoingABigJump = FiendFolio.Ghostbuster.Balance.ChaseJumpFrames
				npcdata.Stopped = false
				npcdata.FollowSpeed = 1
			end
			
			if npcdata.DoingABigJump ~= nil then
				npcdata.DoingABigJump = npcdata.DoingABigJump - 1
				npc.PositionOffset = Vector(0, math.sin(npcdata.DoingABigJump * math.pi / FiendFolio.Ghostbuster.Balance.ChaseJumpFrames) * -20)
				
				if npcdata.DoingABigJump <= 0 then
					npcdata.DoingABigJump = nil
				end
			end
			
			if sprite:IsEventTriggered("ChaseStart") then
				npcdata.FollowSpeed = FiendFolio.Ghostbuster.Balance.FollowSpeed
				npcdata.FollowSpeedDivisor = FiendFolio.Ghostbuster.Balance.FollowSpeedDivisor
			end
			
			if sprite:IsFinished("ChaseStart") then
				npcdata.AnimateChaseBegin = true
			elseif sprite:IsFinished("Chase01Begin") or sprite:IsFinished("Chase02Begin") then
				npcdata.AnimateChaseBegin = false
				npcdata.AnimateChase = true
			end
			
			if npcdata.AnimateChaseBegin then
				local target = npc:GetPlayerTarget()
				local targetpos = target.Position
				local targetvel = targetpos - npc.Position
				
				if targetvel.X < 0 then
					if sprite:IsPlaying("Chase02Begin") then
						local frame = sprite:GetFrame()
						sprite:Play("Chase01Begin", true)
						sprite:SetFrame(frame)
					elseif not sprite:IsPlaying("Chase01Begin") then
						sprite:Play("Chase01Begin", true)
					end
				else
					if sprite:IsPlaying("Chase01Begin") then
						local frame = sprite:GetFrame()
						sprite:Play("Chase02Begin", true)
						sprite:SetFrame(frame)
					elseif not sprite:IsPlaying("Chase02Begin") then
						sprite:Play("Chase02Begin", true)
					end
				end
			elseif npcdata.AnimateChase then
				local target = npc:GetPlayerTarget()
				local targetpos = target.Position
				local targetvel = targetpos - npc.Position
				
				if targetvel.X < 0 then
					if sprite:IsPlaying("Chase02") then
						local frame = sprite:GetFrame()
						sprite:Play("Chase01", true)
						sprite:SetFrame(frame)
					elseif not sprite:IsPlaying("Chase01") then
						sprite:Play("Chase01", true)
					end
				else
					if sprite:IsPlaying("Chase01") then
						local frame = sprite:GetFrame()
						sprite:Play("Chase02")
						sprite:SetFrame(frame)
					elseif not sprite:IsPlaying("Chase02") then
						sprite:Play("Chase02")
					end
				end
			end
			
			if npcdata.SpawningCongressing == nil then
				npcdata.ChaseEndTimer = (npcdata.ChaseEndTimer or FiendFolio.Ghostbuster.Balance.ChaseEndTimer) - 1
				if npcdata.ChaseEndTimer <= 0 then
					return true
				end
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			local target = npc:GetPlayerTarget()
			local targetpos = target.Position
			local targetvel = targetpos - npc.Position
			
			if sprite:IsPlaying("Chase01") then
				local frame = sprite:GetFrame()
				sprite:Play("Chase01NoLoop", true)
				sprite:SetFrame(frame)
			elseif sprite:IsPlaying("Chase02") then
				local frame = sprite:GetFrame()
				sprite:Play("Chase02NoLoop", true)
				sprite:SetFrame(frame)
			end
			
			if targetvel.X < 0 then
				if sprite:IsPlaying("Chase02NoLoop") then
					local frame = sprite:GetFrame()
					sprite:Play("Chase01NoLoop", true)
					sprite:SetFrame(frame)
				end
			else
				if sprite:IsPlaying("Chase01NoLoop") then
					local frame = sprite:GetFrame()
					sprite:Play("Chase02NoLoop")
					sprite:SetFrame(frame)
				end
			end
			
			if sprite:IsFinished("Chase01NoLoop") then
				if targetvel.X < 0 then
					sprite:Play("Chase01End", true)
				else
					sprite:Play("Chase02End", true)
				end
				return true
			elseif sprite:IsFinished("Chase02NoLoop") then
				if targetvel.X < 0 then
					sprite:Play("Chase01End", true)
				else
					sprite:Play("Chase02End", true)
				end
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			local target = npc:GetPlayerTarget()
			local targetpos = target.Position
			local targetvel = targetpos - npc.Position
			
			if sprite:IsFinished("Chase01End") or sprite:IsFinished("Chase02End") then
				npcdata.Stopped = false
				npcdata.WasStopped = nil
				npcdata.SpawningCongressing = nil
				npcdata.TimesSpawnedCongressing = nil
				npcdata.SpawningCongressingDir = nil
				npcdata.DoingABigJump = nil
				npcdata.FollowSpeed = nil
				npcdata.FollowSpeedDivisor = nil
				npcdata.AnimateChaseBegin = nil
				npcdata.AnimateChase = nil
				npcdata.ChaseEndTimer = nil
				
				npc.PositionOffset = nilvector
				sprite:Play("Idle01", true)
				return true
			end
				
			if targetvel.X < 0 then
				if sprite:IsPlaying("Chase02End") then
					local frame = sprite:GetFrame()
					sprite:Play("Chase01End", true)
					sprite:SetFrame(frame)
				end
			else
				if sprite:IsPlaying("Chase01End") then
					local frame = sprite:GetFrame()
					sprite:Play("Chase02End")
					sprite:SetFrame(frame)
				end
			end
			
			if sprite:IsEventTriggered("Snicker") then
				sfx:Play(mod.Sounds.BusterGhostSnicker1, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("SlamTheBreaks") then
				npcdata.FollowSpeed = nil
				npcdata.FollowSpeedDivisor = nil
			end
			
			return false
		end)
	end,

	GoChaseDown = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.Stopped = true
		end)
		FiendFolio.Ghostbuster.GoChase(npc, sprite, npcdata)
	end,

	GoSuck = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.WasStopped = npcdata.Stopped
			npcdata.Stopped = true
			sprite:Play("SuckStart", true)
			npc.Velocity = nilvector
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			
			if sprite:IsEventTriggered("Suck") then
				local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var)
				
				npcdata.Sucking = true
				npcdata.SuckingParticles = true
				npcdata.EmmissionsGuzzled = 0
				
				for _, emm in ipairs(emmissions) do
					if not (emm:GetData().Terrified or emm:GetData().Purgatorio) then
						emm:GetData().Terrified = true
						emm.Parent = npc
					end
				end
			
				sfx:Play(mod.Sounds.BusterGhostSuckStart, 1, 0, false, 1)
				
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npc.Velocity = nilvector
			
			if sprite:IsFinished("SuckStart") then
				sprite:Play("SuckLoop", true)
			end
		
			if npcdata.SuckingParticles then
				npcdata.SuckFrame = (npcdata.SuckFrame or 0) + 1
				if npcdata.SuckFrame % 6 == 1 then
					local ring = Isaac.Spawn(1000, 151, 0, npc.Position, nilvector, npc):ToEffect()
					ring:FollowParent(npc)
					ring.SpriteOffset = Vector(0, -35)
					ring.Scale = 0.6
					ring:Update()
				end
				if npcdata.SuckFrame % 3 == 1 then
					local trail = Isaac.Spawn(1000, 151, 1, npc.Position, nilvector, npc):ToEffect()
					trail:FollowParent(npc)
					trail.SpriteOffset = Vector(0, -35)
					trail:Update()
				end
				if npcdata.SuckFrame % 8 == 1 then
					local swirl = Isaac.Spawn(1000, 1753, 0, npc.Position, nilvector, nil):ToEffect()
					swirl:GetSprite().Rotation = math.random(360)
					swirl:GetSprite():Play("Idle" .. math.random(1,4))
					swirl.SpriteOffset = Vector(0, -35)
					swirl:FollowParent(npc)
					swirl.DepthOffset = 10
					swirl.SpriteScale = Vector(0.8, 0.8)
					swirl:Update()
				end
			end
		
			local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var)
			
			for _, emm in ipairs(emmissions) do
				if not (emm:GetData().Terrified or emm:GetData().Purgatorio) then
					emm:GetData().Terrified = true
					emm.Parent = npc
				end
			end
			
			local other = Isaac.FindInRadius(npc.Position, 2000, EntityPartition.BULLET | 
			                                                     EntityPartition.TEAR | 
			                                                     EntityPartition.ENEMY | 
			                                                     EntityPartition.PICKUP | 
			                                                     EntityPartition.PLAYER)
			for _, e in ipairs(other) do
				if not (e.Type == mod.FF.Emmission.ID and e.Variant == mod.FF.Emmission.Var) and
				   not (e.Type == mod.FF.CongressingEmmission.ID and e.Variant == mod.FF.CongressingEmmission.Var) and
				   not (e.Index == npc.Index and e.InitSeed == npc.InitSeed) and
				   (not e:ToNPC() or not (npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or npc:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)))
				then
					e.Velocity = e.Velocity + (npc.Position - e.Position):Resized(FiendFolio.Ghostbuster.Balance.SuckOtherSpeed)
				end
			end
			
			return #emmissions == 0
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			local other = Isaac.FindInRadius(npc.Position, 2000, EntityPartition.BULLET | 
			                                                     EntityPartition.TEAR | 
			                                                     EntityPartition.ENEMY | 
			                                                     EntityPartition.PICKUP | 
			                                                     EntityPartition.PLAYER)
			for _, e in ipairs(other) do
				if not (e.Type == mod.FF.CongressingEmmission.ID and e.Variant == mod.FF.CongressingEmmission.Var) and
				   not (e.Index == npc.Index and e.InitSeed == npc.InitSeed) and
				   (not e:ToNPC() or not (npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or npc:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)))
				then
					e.Velocity = e.Velocity + (npc.Position - e.Position):Resized(FiendFolio.Ghostbuster.Balance.SuckOtherSpeed)
				end
			end
		
			if npcdata.SuckingParticles then
				npcdata.SuckFrame = (npcdata.SuckFrame or 0) + 1
				if npcdata.SuckFrame % 6 == 1 then
					local ring = Isaac.Spawn(1000, 151, 0, npc.Position, nilvector, npc):ToEffect()
					ring:FollowParent(npc)
					ring.SpriteOffset = Vector(0, -35)
					ring.Scale = 0.6
					ring:Update()
				end
				if npcdata.SuckFrame % 3 == 1 then
					local trail = Isaac.Spawn(1000, 151, 1, npc.Position, nilvector, npc):ToEffect()
					trail:FollowParent(npc)
					trail.SpriteOffset = Vector(0, -35)
					trail:Update()
				end
				if npcdata.SuckFrame % 8 == 1 then
					local swirl = Isaac.Spawn(1000, 1753, 0, npc.Position, nilvector, nil):ToEffect()
					swirl:GetSprite().Rotation = math.random(360)
					swirl:GetSprite():Play("Idle" .. math.random(1,4))
					swirl.SpriteOffset = Vector(0, -35)
					swirl:FollowParent(npc)
					swirl.DepthOffset = 10
					swirl.SpriteScale = Vector(0.8, 0.8)
					swirl:Update()
				end
			end
			
			if sprite:IsFinished("SuckStart") or (sprite:IsPlaying("SuckLoop") and sprite:GetFrame() < (npcdata.LastLoopFrame or 0)) then
				if npcdata.EmmissionsGuzzled == 0 then
					sprite:Play("SuckEndToNormal", true)
				else
					sprite:Play("SuckEnd", true)
				end
				npcdata.SuckingParticles = nil
				npcdata.SuckFrame = nil
				npcdata.LastLoopFrame = nil
				return true
			end
			
			if sprite:IsPlaying("SuckLoop") then
				npcdata.LastLoopFrame = sprite:GetFrame()
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsEventTriggered("SuckStop") then
				npc:GetData().Sucking = nil
				sfx:Play(mod.Sounds.BusterGhostSuckEnd, 1, 0, false, 1)
				return true
			end
			
			local other = Isaac.FindInRadius(npc.Position, 2000, EntityPartition.BULLET | 
			                                                     EntityPartition.TEAR | 
			                                                     EntityPartition.ENEMY | 
			                                                     EntityPartition.PICKUP | 
			                                                     EntityPartition.PLAYER)
			for _, e in ipairs(other) do
				if not (e.Type == mod.FF.CongressingEmmission.ID and e.Variant == mod.FF.CongressingEmmission.Var) and
				   not (e.Index == npc.Index and e.InitSeed == npc.InitSeed) and
				   (not e:ToNPC() or not (npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or npc:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)))
				then
					e.Velocity = e.Velocity + (npc.Position - e.Position):Resized(FiendFolio.Ghostbuster.Balance.SuckOtherSpeed)
				end
			end
			
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("SuckEnd") then
				sprite:Play("Idle02", true)
				npcdata.Stopped = false
				FiendFolio.Ghostbuster.GoPurgatoryVolley(npc, sprite, npcdata)
				npcdata.PurgatoryCooldown = FiendFolio.Ghostbuster.Balance.PurgatoryInitialCooldown
				return true
			elseif sprite:IsFinished("SuckEndToNormal") then
				sprite:Play("Idle01", true)
				npcdata.WasStopped = nil
				npcdata.Sucking = nil
				npcdata.EmmissionsGuzzled = nil
				npcdata.Stopped = false
				return true
			end				
			return false
		end)
		table.insert(npcdata.ActionQueue, -1)
	end,

	GoPurgatoryLeadingStart = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PurgatoryCooldown = (npcdata.PurgatoryCooldown or FiendFolio.Ghostbuster.Balance.PurgatoryCooldown) - 1
			if npcdata.PurgatoryCooldown <= 0 then
				npcdata.PurgatoryCooldown = nil
				if npcdata.EmmissionsGuzzled > 1 then
					sprite:Play("Shoot04Start", true)
				else
					sprite:Play("ShootToNormal", true)
				end
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if not (sprite:IsPlaying("Shoot04Start") or sprite:IsFinished("Shoot04Start")) then
				FiendFolio.Ghostbuster.GoPurgatoryLeadingShoot(npc, sprite, npcdata)
				return true
			end
			
			if sprite:IsFinished("Shoot04Start") then
				sprite:Play("Shoot04")
				FiendFolio.Ghostbuster.GoPurgatoryLeadingShoot(npc, sprite, npcdata)
				return true
			end
			
			return false
		end)
		table.insert(npcdata.ActionQueue, -1)
	end,
	
	GoPurgatoryLeadingShoot = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsEventTriggered("Shoot") then
				npcdata.EmmissionsGuzzled = npcdata.EmmissionsGuzzled - 1
				
				--local target = npc:GetPlayerTarget()
				--local targetpos = game:GetRoom():GetClampedPosition((target.Position + target.Velocity * 60), 20)
				
				local proj = Isaac.Spawn(mod.FF.EmmissionProjectile.ID, mod.FF.EmmissionProjectile.Var, 0, npc.Position, nilvector, npc)
				proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				proj.PositionOffset = Vector(0, -55)
				--proj:GetData().FallingSpeed = -15
				--proj:GetData().FallingAccel = 0.75
				proj:GetData().FallingSpeed = -10
				proj:GetData().FallingAccel = 0.275
				--proj:GetData().TargetPosition = targetpos 
				proj:GetData().TargetLeading = true
				proj:Update()
				
				local effect = Isaac.Spawn(1000, 2, 5, npc.Position, nilvector, npc):ToEffect()
				effect.SpriteScale = Vector(1.25, 1.25)
				effect.SpriteOffset = Vector(0, -32.5)
				effect.Parent = npc
				effect:FollowParent(npc)
				effect.DepthOffset = 10

				local color = Color(5.0, 5.0, 5.0, 0.7, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				effect:GetSprite().Color = color
				
				effect:Update()
				
				sfx:Play(mod.Sounds.BusterGhostSuckShoot, 1, 0, false, 0.85 + 0.3 * math.random())
				
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("Shoot04") then
				if npcdata.EmmissionsGuzzled > 1 then
					sprite:Play("Shoot04", true)
				else
					sprite:Play("Shoot04ToNormal", true)
				end
				npcdata.Stopped = false
				npcdata.PurgatoryCooldown = nil
				if npcdata.EmmissionsGuzzled > 0 then
					FiendFolio.Ghostbuster.GoPurgatoryLeadingShoot(npc, sprite, npcdata)
				end
				return true
			elseif sprite:IsFinished("ShootToNormal") or sprite:IsFinished("Shoot04ToNormal") then
				sprite:Play("Idle01", true)
				npcdata.WasStopped = nil
				npcdata.Sucking = nil
				npcdata.EmmissionsGuzzled = nil
				npcdata.PurgatoryCooldown = nil
				npcdata.Stopped = false
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, -1)
	end,
	
	GoPurgatory = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PurgatoryCooldown = (npcdata.PurgatoryCooldown or FiendFolio.Ghostbuster.Balance.PurgatoryCooldown) - 1
			if npcdata.PurgatoryCooldown <= 0 then
				npcdata.PurgatoryCooldown = nil
				if npcdata.EmmissionsGuzzled > 1 then
					sprite:Play("Shoot03", true)
				else
					sprite:Play("ShootToNormal", true)
				end
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsEventTriggered("Shoot") then
				npcdata.EmmissionsGuzzled = npcdata.EmmissionsGuzzled - 1
				
				local proj = Isaac.Spawn(mod.FF.EmmissionProjectile.ID, mod.FF.EmmissionProjectile.Var, 0, npc.Position, nilvector, npc)
				proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				proj.PositionOffset = Vector(0, -55)
				proj:GetData().FallingSpeed = -10
				proj:GetData().FallingAccel = 0.275
				proj:Update()
				
				local effect = Isaac.Spawn(1000, 2, 5, npc.Position, nilvector, npc):ToEffect()
				effect.SpriteScale = Vector(1.25, 1.25)
				effect.SpriteOffset = Vector(0, -32.5)
				effect.Parent = npc
				effect:FollowParent(npc)
				effect.DepthOffset = 10

				local color = Color(5.0, 5.0, 5.0, 0.7, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				effect:GetSprite().Color = color
				
				effect:Update()
				
				sfx:Play(mod.Sounds.BusterGhostSuckShoot, 1, 0, false, 0.85 + 0.3 * math.random())
				
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("Shoot03") then
				sprite:Play("Idle02", true)
				npcdata.Stopped = false
				npcdata.PurgatoryCooldown = nil
				npcdata.PostInhaleCooldown = 1
				FiendFolio.Ghostbuster.GoPurgatory(npc, sprite, npcdata)
				return true
			elseif sprite:IsFinished("ShootToNormal") then
				sprite:Play("Idle01", true)
				npcdata.WasStopped = nil
				npcdata.Sucking = nil
				npcdata.EmmissionsGuzzled = nil
				npcdata.PurgatoryCooldown = nil
				npcdata.Stopped = false
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PostInhaleCooldown = (npcdata.PostInhaleCooldown or FiendFolio.Ghostbuster.Balance.PostInhaleCooldown) - 1
			if npcdata.PostInhaleCooldown <= 0 then
				npcdata.PostInhaleCooldown = nil
				return true
			end
			return false
		end)
	end,
	
	GoPurgatoryVolley = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PurgatoryCooldown = (npcdata.PurgatoryCooldown or FiendFolio.Ghostbuster.Balance.PurgatoryCooldown) - 1
			if npcdata.PurgatoryCooldown <= 0 then
				npcdata.PurgatoryCooldown = nil
				npcdata.EmmissionsGuzzled = math.max(FiendFolio.Ghostbuster.Balance.MinPurgatorySpreadProjectiles, npcdata.EmmissionsGuzzled)
				sprite:Play("ShootVolleyStart", true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsEventTriggered("Shoot") then
				sfx:Play(mod.Sounds.BusterGhostSuckShoot, 1, 0, false, 0.85 + 0.3 * math.random())
			end
			
			if sprite:WasEventTriggered("Shoot") then
				if npcdata.PurgatoryVolleyCooldown == nil then
					npcdata.PurgatoryVolleyCooldown = 0
				else
					npcdata.PurgatoryVolleyCooldown = npcdata.PurgatoryVolleyCooldown - 1
				end
				
				if npcdata.PurgatoryVolleyCooldown <= 0 and npcdata.EmmissionsGuzzled > 0 then
					if not npcdata.PurgatoryQueuedPositions then
						ghostbusterQueuePurgatoryPositions(npc, npcdata)
					end
				
					local proj = Isaac.Spawn(mod.FF.EmmissionProjectile.ID, mod.FF.EmmissionProjectile.Var, 0, npc.Position, nilvector, npc)
					proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.PositionOffset = Vector(0, -55)
					proj:GetData().FallingSpeed = -10
					proj:GetData().FallingAccel = 0.275
					if npcdata.PurgatoryFirstPosition then
						proj:GetData().TargetPosition = npcdata.PurgatoryFirstPosition
						npcdata.PurgatoryFirstPosition = nil
					else
						local randIndex = math.random(1, npcdata.EmmissionsGuzzled)
						proj:GetData().TargetPosition = npcdata.PurgatoryQueuedPositions[randIndex]
						table.remove(npcdata.PurgatoryQueuedPositions, randIndex)
					end
					proj:Update()
					
					local effect = Isaac.Spawn(1000, 2, 5, npc.Position, nilvector, npc):ToEffect()
					effect.SpriteScale = Vector(1.25, 1.25)
					effect.SpriteOffset = Vector(0, -32.5)
					effect.Parent = npc
					effect:FollowParent(npc)
					effect.DepthOffset = 10

					local color = Color(5.0, 5.0, 5.0, 0.7, 0, 0, 0)
					color:SetColorize(1, 1, 1.25, 1)
					effect:GetSprite().Color = color
					
					effect:Update()
					
					npcdata.EmmissionsGuzzled = npcdata.EmmissionsGuzzled - 1
					npcdata.PurgatoryVolleyCooldown = FiendFolio.Ghostbuster.Balance.PurgatoryVolleyCooldown
				end
			end
			
			if sprite:IsFinished("ShootVolleyStart") then
				sprite:Play("ShootVolleyLoop01", true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("ShootVolleyLoop01") then
				sprite:Play("ShootVolleyLoop02", true)
			elseif sprite:IsFinished("ShootVolleyLoop02") then
				sprite:Play("ShootVolleyLoop01", true)
			end
			
			if npcdata.PurgatoryVolleyCooldown == nil then
				npcdata.PurgatoryVolleyCooldown = 0
			else
				npcdata.PurgatoryVolleyCooldown = npcdata.PurgatoryVolleyCooldown - 1
			end
			
			if npcdata.PurgatoryVolleyCooldown <= 0 and npcdata.EmmissionsGuzzled > 0 then
				if not npcdata.PurgatoryQueuedPositions then
					ghostbusterQueuePurgatoryPositions(npc, npcdata)
				end
				
				local proj = Isaac.Spawn(mod.FF.EmmissionProjectile.ID, mod.FF.EmmissionProjectile.Var, 0, npc.Position, nilvector, npc)
				proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				proj.PositionOffset = Vector(0, -55)
				proj:GetData().FallingSpeed = -10
				proj:GetData().FallingAccel = 0.275
				if npcdata.PurgatoryFirstPosition then
					proj:GetData().TargetPosition = npcdata.PurgatoryFirstPosition
					npcdata.PurgatoryFirstPosition = nil
				else
					local randIndex = math.random(1, npcdata.EmmissionsGuzzled)
					proj:GetData().TargetPosition = npcdata.PurgatoryQueuedPositions[randIndex]
					table.remove(npcdata.PurgatoryQueuedPositions, randIndex)
				end
				proj:Update()
				
				--[[local effect = Isaac.Spawn(1000, 2, 5, npc.Position, nilvector, npc):ToEffect()
				effect.SpriteScale = Vector(1.25, 1.25)
				effect.SpriteOffset = Vector(0, -32.5)
				effect.Parent = npc
				effect:FollowParent(npc)
				effect.DepthOffset = 10

				local color = Color(5.0, 5.0, 5.0, 0.7, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				effect:GetSprite().Color = color
				
				effect:Update()]]--
				
				npcdata.EmmissionsGuzzled = npcdata.EmmissionsGuzzled - 1
				npcdata.PurgatoryVolleyCooldown = FiendFolio.Ghostbuster.Balance.PurgatoryVolleyCooldown
			end
			
			if npcdata.EmmissionsGuzzled <= 0 then 
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("ShootVolleyLoop01") then
				sprite:Play("ShootVolleyEnd", true)
				return true
			elseif sprite:IsFinished("ShootVolleyLoop02") then
				sprite:Play("ShootVolleyLoop01", true)
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("ShootVolleyEnd") then
				sprite:Play("Idle01", true)
				npcdata.WasStopped = nil
				npcdata.Sucking = nil
				npcdata.EmmissionsGuzzled = nil
				npcdata.PurgatoryCooldown = nil
				npcdata.PurgatoryVolleyCooldown = nil
				npcdata.PurgatoryQueuedPositions = nil
				npcdata.PurgatoryFirstPosition = nil
				npcdata.Stopped = false
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PostInhaleCooldown = (npcdata.PostInhaleCooldown or FiendFolio.Ghostbuster.Balance.PostInhaleCooldown) - 1
			if npcdata.PostInhaleCooldown <= 0 then
				npcdata.PostInhaleCooldown = nil
				return true
			end
			return false
		end)
	end,

	GoPurgatorySpread = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PurgatoryCooldown = (npcdata.PurgatoryCooldown or FiendFolio.Ghostbuster.Balance.PurgatoryCooldown) - 1
			if npcdata.PurgatoryCooldown <= 0 then
				npcdata.PurgatoryCooldown = nil
				sprite:Play("ShootToNormal", true)
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsEventTriggered("Shoot") then
				ghostbusterQueuePurgatoryPositions(npc, npcdata)
				
				for i = 1, math.max(FiendFolio.Ghostbuster.Balance.MinPurgatorySpreadProjectiles, npcdata.EmmissionsGuzzled) do
					local proj = Isaac.Spawn(mod.FF.EmmissionProjectile.ID, mod.FF.EmmissionProjectile.Var, 0, npc.Position, nilvector, npc)
					proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.PositionOffset = Vector(0, -55)
					proj:GetData().FallingSpeed = -10
					proj:GetData().FallingAccel = 0.275
					if npcdata.PurgatoryFirstPosition then
						proj:GetData().TargetPosition = npcdata.PurgatoryFirstPosition
						npcdata.PurgatoryFirstPosition = nil
					else
						proj:GetData().TargetPosition = npcdata.PurgatoryQueuedPositions[i - 1]
					end
					proj:Update()
					
					local effect = Isaac.Spawn(1000, 2, 5, npc.Position, nilvector, npc):ToEffect()
					effect.SpriteScale = Vector(1.25, 1.25)
					effect.SpriteOffset = Vector(0, -32.5)
					effect.Parent = npc
					effect:FollowParent(npc)
					effect.DepthOffset = 10

					local color = Color(5.0, 5.0, 5.0, 0.7, 0, 0, 0)
					color:SetColorize(1, 1, 1.25, 1)
					effect:GetSprite().Color = color
					
					effect:Update()
				end
				
				npcdata.PurgatoryQueuedPositions = nil
				npcdata.EmmissionsGuzzled = 0
				
				sfx:Play(mod.Sounds.BusterGhostSuckShoot, 1, 0, false, 0.85 + 0.3 * math.random())
				
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			if sprite:IsFinished("ShootToNormal") then
				sprite:Play("Idle01", true)
				npcdata.WasStopped = nil
				npcdata.Sucking = nil
				npcdata.EmmissionsGuzzled = nil
				npcdata.PurgatoryCooldown = nil
				npcdata.PurgatoryFirstPosition = nil
				npcdata.PurgatoryQueuedPositions = nil
				npcdata.Stopped = false
				return true
			end
			return false
		end)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.PostInhaleCooldown = (npcdata.PostInhaleCooldown or FiendFolio.Ghostbuster.Balance.PostInhaleCooldown) - 1
			if npcdata.PostInhaleCooldown <= 0 then
				npcdata.PostInhaleCooldown = nil
				return true
			end
			return false
		end)
	end,

	GoInhale = function(npc, sprite, npcdata)
		table.insert(npcdata.ActionQueue, function(npc, sprite, npcdata)
			npcdata.Stopped = true
		end)
		FiendFolio.Ghostbuster.GoSuck(npc, sprite, npcdata)
	end,
}

function mod:ghostbusterAI(npc, sprite, npcdata)
	if npcdata.init == nil then
		npcdata.Stopped = false
		npcdata.Orbiters = {}
		npcdata.ActionQueue = {}
		npcdata.RecentAttacks = {}
		npcdata.CurrentAction = nil

		npcdata.TargetPositions = {}
		npcdata.EmissionWait = 0
		npcdata.IsInReflection = false

		npc.Mass = FiendFolio.Ghostbuster.Balance.Mass
		npc.Friction = FiendFolio.Ghostbuster.Balance.BaseFriction
		-- no knockback from bombs
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
		npc.SplatColor = mod.ColorGhostly
		
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		sprite:Play("Appear", true)
		
		npcdata.init = true
	end
	
	if sprite:IsPlaying("Appear") and sprite:IsEventTriggered("SlamTheBreaks") then
		-- this ensures buster isn't pushed around by other entities
		-- thanks for not properly supporting high mass moving objects isaac!
		-- hi this also now applies for ghostbuster weeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		sfx:Play(mod.Sounds.BusterGhostSkid2, 1, 0, false, 1)
	elseif sprite:IsPlaying("Appear") and sprite:IsEventTriggered("Snicker") then
		sfx:Play(mod.Sounds.BusterGhostDriftStart, 1, 0, false, 1)
	end
	
	if sprite:IsPlaying("Appear") then
		npc.Velocity = nilvector
		return
	end

	local target = npc:GetPlayerTarget()

	table.insert(npcdata.TargetPositions, 1, target.Position)
	if #npcdata.TargetPositions >= FiendFolio.Ghostbuster.Balance.MaxTrackingFrames + 1 then
		table.remove(npcdata.TargetPositions, FiendFolio.Ghostbuster.Balance.MaxTrackingFrames + 1)
	end

	local pos = npc.Position

	local toTarget = npcdata.TargetPositions[math.min(#npcdata.TargetPositions, FiendFolio.Ghostbuster.Balance.TrackingFrameDelay)] - pos

	if not npcdata.Stopped and npc.FrameCount % FiendFolio.Ghostbuster.Balance.PathfindingPeriod == 0 then
		local targetspeed = npcdata.FollowSpeed or FiendFolio.Ghostbuster.Balance.Speed
		local targetdivisor = npcdata.FollowSpeedDivisor or 5000
		local vel = Vector(toTarget.X * math.abs(toTarget.X) * 0.7, toTarget.Y * math.abs(toTarget.Y) * 1.4) * (targetspeed / targetdivisor)
		local speed = vel:Length()
		if speed > targetspeed then
			vel = vel * (targetspeed / speed)
		end

		npc.Velocity = vel
	end

	for i = #npcdata.Orbiters, 1, -1 do
		local baby = npcdata.Orbiters[i]
		if not (baby:Exists() and baby.Parent and baby.Parent.InitSeed == npc.InitSeed and baby.Parent.Index == npc.Index) then
			table.remove(npcdata.Orbiters, i)
		end
	end

	local isOrbitOpen = #npcdata.Orbiters < FiendFolio.Ghostbuster.Balance.MaxOrbitEmmissions
	if isOrbitOpen and not npcdata.WasOrbitOpen then
		FiendFolio.Ghostbuster.ResetEmmissionTimer(npcdata)
	end
	npcdata.WasOrbitOpen = isOrbitOpen

	npcdata.EmissionWait = npcdata.EmissionWait - 1

	if npcdata.CurrentAction == nil then
		while #npcdata.ActionQueue > 0 do
			local action = table.remove(npcdata.ActionQueue, 1)
			if action ~= -1 then
				npcdata.CurrentAction = action
				break
			end
		end
	end
	
	if npcdata.CurrentAction == nil then
		npcdata.CurrentAction = FiendFolio.Ghostbuster.GoIdle
	end

	if npcdata.CurrentAction(npc, sprite, npcdata) ~= false then
		npcdata.CurrentAction = nil
	end
	
	if npcdata.SpawningCongressing ~= nil then
		if npcdata.SpawningCongressing % 120 == 0 then
			local room = game:GetRoom()
			local topLeft = room:GetTopLeftPos()
			local bottomRight = room:GetBottomRightPos()
			
			local emm1, emm2
			if npcdata.SpawningCongressingDir == 1 then
				emm1 = Isaac.Spawn(mod.FF.CongressingEmmission.ID,
				                   mod.FF.CongressingEmmission.Var,
				                   0,
				                   Vector(bottomRight.X, topLeft.Y) + Vector(20, 20),
				                   nilvector,
				                   npc)
				emm2 = Isaac.Spawn(mod.FF.CongressingEmmission.ID,
				                   mod.FF.CongressingEmmission.Var,
				                   1,
				                   Vector(topLeft.X, bottomRight.Y) + Vector(-20, -20),
				                   nilvector,
				                   npc)
			else
				emm1 = Isaac.Spawn(mod.FF.CongressingEmmission.ID,
				                   mod.FF.CongressingEmmission.Var,
				                   2,
				                   Vector(bottomRight.X, bottomRight.Y) + Vector(20, -20),
				                   nilvector,
				                   npc)
				emm2 = Isaac.Spawn(mod.FF.CongressingEmmission.ID,
				                   mod.FF.CongressingEmmission.Var,
				                   3,
				                   Vector(topLeft.X, topLeft.Y) + Vector(-20, 20),
				                   nilvector,
				                   npc)
			end
			emm1:Update()
			emm2:Update()
			
			npcdata.TimesSpawnedCongressing = npcdata.TimesSpawnedCongressing + 1
		end
		npcdata.SpawningCongressing = npcdata.SpawningCongressing + 1
		
		if npcdata.TimesSpawnedCongressing >= FiendFolio.Ghostbuster.Balance.MaxTimesSpawnCongressing then
			npcdata.SpawningCongressing = nil
			npcdata.SpawningCongressingDir = nil
			npcdata.TimesSpawnedCongressing = nil
		end
	end
end

function mod:handleGhostbusterReflectionAndDeath(npc, sprite, npcdata)
	npcdata.ActualColor = Color.Lerp(sprite.Color, Color(1,1,1,1,0,0,0), 0)
	npc:SetColor(Color(1,1,1,0,0,0,0), 1, 0, false, false)
	
	if sprite:IsPlaying("Death") and npcdata.IsDead == nil then
		sprite:Play("DeathStart", true)
		npcdata.Sucking = nil
		npcdata.SuckFrame = nil
		npcdata.SuckingParticles = nil
		npcdata.EmmissionsGuzzled = 0
		npcdata.IsDead = true
		npc.PositionOffset = nilvector
		
		local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var, -1, true)
		for _, emm in ipairs(emmissions) do
			emm:GetData().WanderTargetX = nil
			emm:GetData().WanderTargetY = nil
		end
		
		--sfx:Stop(mod.Sounds.BusterChargeLoop)
		
		if npcdata.IsInReflection then
			npcdata.PreparingToBlink = (npcdata.PreparingToBlink or 6) + 1
		end
	end
	
	if npcdata.IsDead then
		if npcdata.PreparingToBlink ~= nil then
			if npcdata.IsInReflection then
				npcdata.PreparingToBlink = npcdata.PreparingToBlink - 1
			else
				npcdata.PreparingToBlink = npcdata.PreparingToBlink + 1
			end
			
			if npcdata.IsInReflection and npcdata.PreparingToBlink <= 0 then
				npcdata.PreparingToBlink = 1
				npcdata.IsInReflection = nil
				
				for i = 30, 360, 30 do
					local expvec = Vector(0,math.random(10,35)):Rotated(i)
					local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position + expvec * 0.1, expvec * 0.3, npc):ToEffect()
					sparkle.SpriteOffset = Vector(0,-25)
					sparkle:Update()
				
					local color = Color(1,1,1,1,0,0,0)
					color:SetColorize(1,1,2,1)
					sparkle:GetSprite().Color = color
				end
			elseif not npcdata.IsInReflection and npcdata.PreparingToBlink >= 6 then
				npcdata.PreparingToBlink = nil
			end
		end
	
		if not npc.Child or not npc.Child:Exists() then
			local hitbox = Isaac.Spawn(mod.FF.EmmissionDeathHitbox.ID, mod.FF.EmmissionDeathHitbox.Var, 0, npc.Position, nilvector, npc)
			hitbox:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			hitbox.Parent = npc
			npc.Child = hitbox
			hitbox:Update()
		end
		local hitbox = npc.Child
		
		if sprite:IsEventTriggered("Suck") then
			npcdata.Sucking = true
			sfx:Play(mod.Sounds.BusterGhostSuckStart, 1, 0, false, 1)
			npcdata.SuckingParticles = true
			hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		elseif sprite:IsEventTriggered("SuckStop") then
			npcdata.Sucking = false
			sfx:Play(mod.Sounds.BusterGhostSuckEnd, 1, 0, false, 1)
			sfx:Play(mod.Sounds.BusterGhostDeath, 1, 0, false, 1)
			npcdata.SuckingParticles = false
			hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		elseif sprite:IsEventTriggered("Cavesparkles") then
			npcdata.Sparkling = true
		elseif sprite:IsEventTriggered("Explode") then
			npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.5, 0, false, 1)

			local poof = Isaac.Spawn(1000, 16, 1, npc.Position, Vector.Zero, npc)
			local poofSprite = poof:GetSprite()

			local color = Color(2.0, 2.0, 2.0, 0.4, 0, 0, 0)
			color:SetColorize(1, 1, 1.25, 1)
			poof.Color = color
			poof.SpriteScale = Vector(0.9, 0.9)

			mod.XalumDamageInArea(npc, 60)
			
			mod.scheduleForUpdate(function()
				local angy = Isaac.Spawn(1000, 15, 0, poof.Position, nilvector, nil)
				local angySprite = angy:GetSprite()

				local color = Color(2.0, 2.0, 2.0, 0.5, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				angy.Color = color
				angy.SpriteScale = Vector(1.2, 1.2)

				angySprite:Load("gfx/1000.034_Fart.anm2", true)
				angySprite:Play("Explode")
			end, 4)
			
			npcdata.Sparkling = nil
		end
		
		if sprite:IsFinished("DeathStart") then
			sprite:Play("SuckLoop", true)
			npcdata.LastLoopFrame = sprite:GetFrame()
		end
		
		if npcdata.SuckingParticles then
			npcdata.SuckFrame = (npcdata.SuckFrame or 0) + 1
			if npcdata.SuckFrame % 6 == 1 then
				local ring = Isaac.Spawn(1000, 151, 0, npc.Position, nilvector, npc):ToEffect()
				ring:FollowParent(npc)
				ring.SpriteOffset = Vector(0, -35)
				ring.Scale = 0.6
				ring:Update()
			end
			if npcdata.SuckFrame % 3 == 1 then
				local trail = Isaac.Spawn(1000, 151, 1, npc.Position, nilvector, npc):ToEffect()
				trail:FollowParent(npc)
				trail.SpriteOffset = Vector(0, -35)
				trail:Update()
			end
			if npcdata.SuckFrame % 8 == 1 then
				local swirl = Isaac.Spawn(1000, 1753, 0, npc.Position, nilvector, nil):ToEffect()
				swirl:GetSprite().Rotation = math.random(360)
				swirl:GetSprite():Play("Idle" .. math.random(1,4))
				swirl.SpriteOffset = Vector(0, -35)
				swirl:FollowParent(npc)
				swirl.DepthOffset = 10
				swirl.SpriteScale = Vector(0.8, 0.8)
				swirl:Update()
			end
		end
		
		if sprite:IsPlaying("Death") and sprite:GetFrame() >= 88 then
			npcdata.Sparkling = nil
		elseif npcdata.Sparkling then
			npcdata.SparklingFrame = (npcdata.SparklingFrame or 0) + 1
			if npcdata.SparklingFrame % 3 == 1 then
				local rand = math.random(360)
				local expvec = Vector(0,math.random(10,35)):Rotated(rand)
				local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position + expvec * 0.1, expvec * 0.3, npc):ToEffect()
				sparkle.SpriteOffset = Vector(0,-25)
				sparkle:Update()
				
				local color = Color(1,1,1,1,0,0,0)
				color:SetColorize(1,1,2,1)
				sparkle:GetSprite().Color = color
			end
		end
	
		if npcdata.Sucking then
			local emmissions = Isaac.FindByType(mod.FF.Emmission.ID, mod.FF.Emmission.Var)
			local congressors = Isaac.FindByType(mod.FF.CongressingEmmission.ID, mod.FF.CongressingEmmission.Var)
			
			for _, emm in ipairs(emmissions) do
				if not (emm:GetData().Terrified or emm:GetData().Purgatorio) then
					emm:GetData().Terrified = true
					emm:GetData().OhNoItsMurder = true
					emm.Parent = npc
				end
			end
			
			for _, con in ipairs(congressors) do
				if not (con:GetData().Terrified or con:GetData().Purgatorio) then
					con:GetData().Terrified = true
					con:GetData().OhNoItsMurder = true
					con.Parent = npc
				end
			end
			
			local other = Isaac.FindInRadius(npc.Position, 2000, EntityPartition.BULLET | 
			                                                     EntityPartition.TEAR | 
			                                                     EntityPartition.ENEMY | 
			                                                     EntityPartition.PICKUP | 
			                                                     EntityPartition.PLAYER)
			for _, e in ipairs(other) do
				if not (e.Type == mod.FF.Emmission.ID and e.Variant == mod.FF.Emmission.Var) and
				   not (e.Type == mod.FF.CongressingEmmission.ID and e.Variant == mod.FF.CongressingEmmission.Var) and
				   not (e.Index == npc.Index and e.InitSeed == npc.InitSeed) and
				   (not e:ToNPC() or not (npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or npc:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)))
				then
					e.Velocity = e.Velocity + (npc.Position - e.Position):Resized(FiendFolio.Ghostbuster.Balance.SuckOtherSpeed)
				end
			end
			
			if #emmissions + #congressors == 0 and sprite:GetFrame() < (npcdata.LastLoopFrame or 0) and (npcdata.SuckHasLooped or 0) >= 1 then
				npcdata.SuckingParticles = false
				npcdata.LastLoopFrame = nil
				sprite:Play("Death", true)
				return
			elseif sprite:GetFrame() < (npcdata.LastLoopFrame or 0) then
				npcdata.SuckHasLooped = (npcdata.SuckHasLooped or 0) + 1
			end
			
			if sprite:IsPlaying("SuckLoop") then
				npcdata.LastLoopFrame = sprite:GetFrame()
			end
		end
	end
end

function mod:ghostbusterRender(npc, offset)
	local sprite = npc:GetSprite()
	local npcdata = npc:GetData()
	local room = game:GetRoom()
	
	if npcdata.ActualColor then
		local rendermode = game:GetRoom():GetRenderMode()
		local isReflected = rendermode == RenderMode.RENDER_WATER_REFLECT
		
		if (npcdata.IsInReflection and isReflected) or ((not npcdata.IsInReflection) and (not isReflected)) then
			local originalScale = Vector(sprite.Scale.X, sprite.Scale.Y)
			
			local color = npcdata.ActualColor
			if npcdata.PreparingToBlink == 4 then
				color = Color.Lerp(color, Color(1,1,1,1,0,0,0), 0)
				color.A = 0.75
				color.RO = color.RO + 0.25
				color.GO = color.GO + 0.25
				color.BO = color.BO + 0.25
			elseif npcdata.PreparingToBlink == 3 then
				color = Color.Lerp(color, Color(1,1,1,1,0,0,0), 0)
				color.A = 0.5
				color.RO = color.RO + 0.75
				color.GO = color.GO + 0.75
				color.BO = color.BO + 0.75
			elseif npcdata.PreparingToBlink == 2 then
				color = Color.Lerp(color, Color(1,1,1,1,0,0,0), 0)
				color.A = 0.25
				color.RO = 1.25
				color.GO = 1.25
				color.BO = 1.25
			elseif npcdata.PreparingToBlink == 1 then
				color = Color.Lerp(color, Color(1,1,1,1,0,0,0), 0)
				color.A = 0.1
				color.RO = 1.5
				color.GO = 1.5
				color.BO = 1.5
			end
			
			npc:SetColor(color, 1, 0, false, false)
			if npcdata.PreparingToBlink == 6 then
				sprite.Scale = Vector(originalScale.X * 1.1, originalScale.Y * 0.9)
			elseif npcdata.PreparingToBlink == 5 then
				sprite.Scale = Vector(originalScale.X * 1.2, originalScale.Y * 0.8)
			elseif npcdata.PreparingToBlink == 4 then
				sprite.Scale = Vector(originalScale.X * 1.23, originalScale.Y * 0.77)
			elseif npcdata.PreparingToBlink == 3 then
				sprite.Scale = Vector(originalScale.X * 0.8, originalScale.Y * 1.2)
			elseif npcdata.PreparingToBlink == 2 then
				sprite.Scale = Vector(originalScale.X * 0.65, originalScale.Y * 1.35)
			elseif npcdata.PreparingToBlink == 1 then
				sprite.Scale = Vector(originalScale.X * 0.5, originalScale.Y * 1.5)
			end
			
			sprite:Render(Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset, nilvector, nilvector)
			
			sprite.Scale = originalScale
			npc:SetColor(Color(1,1,1,0,0,0,0), 1, 0, false, false)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_END, function(_, gameOver)
	if gameOver then
		if #Isaac.FindByType(mod.FF.Ghostbuster.ID, mod.FF.Ghostbuster.Var) > 0 then
			sfx:Play(mod.Sounds.BusterGhostVictory, 1, 0, false, 1)
		end
	end
end)

----------------------------------------------------------------------------------

-- please do not use these things outside of ghostbuster's fight please please please

FiendFolio.Emmission = {
	Balance = {
		Mass = 40,
		FadeInDuration = 20,
		Speed = 7.5,
		WalkFriction = 0.9,
		WalkPeriod = 25,
		OrbitPositioningSpeed = 5.5,
		OrbitSpeed = 5,
		OrbitDistance = 30,
		OrbitPeriod = 30,
		SuckStartTimer = 50,
		SuckStartSpeed = 0.5,
		InhaleSpeed = 13,
		InhaleLerp = 0.15,
		FadeInGraceDistance = 50,
		FadeInGracePeriod = 50,
	},
}

local function GetOrbitTargetPos(idx, numOrbiters, parent, period, dist)
	local angle = (idx * (math.pi * 2) / numOrbiters) + (parent.FrameCount / period)
	local targetOffset = Vector(math.cos(angle), math.sin(angle)) * (parent.Size + dist)
	-- parent position in 2 frames (update + render) at the target offset
	return (parent.Position + parent.Velocity * 2) + targetOffset
end

-- A dot B > 0 tells you B is in the general same direction as A
-- let A' = A rot 90 clockwise = -Ay, Ax (assuming y points down)
-- A' dot B > 0 tells you B is in the general same direction as A'
-- in other words, it's in the general *clockwise* direction from A
-- A' dot B = A'x * Bx + A'y * By = -Ay * Bx + Ax * By
-- -Ay * Bx + Ax * By > 0 ->
-- Ax * By > Ay * Bx means B is further clockwise than A
local function IsLessClockwise(a, b)
	-- returns whether a is less clockwise than b
	return a.X * b.Y > a.Y * b.X
end

function mod:emmissionAI(npc, sprite, npcdata)
	if npcdata.init == nil then
		npc.Mass = FiendFolio.Emmission.Balance.Mass
		npc.SplatColor = mod.ColorGhostly
		npc.PositionOffset = Vector(0,-20)

		npcdata.init = true
	end

	if npcdata.OrbitState == "MovingIntoOrbit" then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	elseif npcdata.OrbitState then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	else
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	end

    if npcdata.NoCollideFrames ~= nil and npcdata.NoCollideFrames > 0 then
        npcdata.NoCollideFrames = npcdata.NoCollideFrames - 1
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
	
	npcdata.StateFrame = (npcdata.StateFrame or 0) + 1
	
	if npcdata.Bounced and npcdata.Terrified then
		npcdata.Purgatorio = true
		npcdata.LastPurgatorioPosition = npc.Parent.Position
		npcdata.Terrified = nil
		npcdata.Bounced = nil
		npcdata.FallingSpeed = nil
		npcdata.FallingAccel = nil
		npcdata.OhNoItsMurder = nil
		npcdata.SuckStartTimer = nil
		sprite.FlipX = false
	end
	
	if npcdata.Bounced and not npcdata.Purgatorio then
		if not sprite:IsPlaying("Sucked") then
			sprite:Play("Sucked", true)
		end
		
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		
		if not npcdata.Fired then
			npcdata.Fired = true
			
			npcdata.LastPositions = {}
			for i = 1, 6 do
				table.insert(npcdata.LastPositions, 1, npc.Position)
			end
			
			npcdata.LastHeights = {}
			for i = 1, 12 do
				table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
			end
		end
		
		npc.Velocity = npcdata.BouncedVel or nilvector
		
		npcdata.LastPositions = npcdata.LastPositions or {}
		table.insert(npcdata.LastPositions, 1, npc.Position)
		if #npcdata.LastPositions > 6 then
			table.remove(npcdata.LastPositions, 7)
		end
		
		npcdata.FallingSpeed = 0.1 + npcdata.FallingAccel + 0.9 * npcdata.FallingSpeed
		npc.PositionOffset = Vector(0, npc.PositionOffset.Y + npcdata.FallingSpeed)
		npcdata.LerpedHeight = false
		
		npcdata.LastHeights = npcdata.LastHeights or {}
		table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
		table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0.1 + npcdata.FallingAccel + 0.9 * npcdata.FallingSpeed) / 2)
		if #npcdata.LastHeights > 12 then
			table.remove(npcdata.LastHeights, 13)
			table.remove(npcdata.LastHeights, 14)
		end

		if npc.PositionOffset.Y > -5 or not game:GetRoom():IsPositionInRoom(npc.Position, 0) then
			npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.5, 0, false, 1)

			local poof = Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
			local poofData = poof:GetData()
			local poofSprite = poof:GetSprite()

			local color = Color(1, 1, 1, 1, 0, 0, 0)
			color:SetColorize(1, 1, 1.5, 1)
			poof.Color = color

			poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
			poofSprite:Play("Explosion")
			
			mod.scheduleForUpdate(function()
				local angy = Isaac.Spawn(1000, 15, 0, poof.Position, nilvector, nil)
				local angySprite = angy:GetSprite()

				local color = Color(2.0, 2.0, 2.0, 0.7, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				angy.Color = color
				angy.SpriteScale = Vector(1.2, 1.2)

				angySprite:Load("gfx/1000.034_Fart.anm2", true)
				angySprite:Play("Explode")
			end, 4)

			mod.XalumDamageInArea(npc, 40)

			npc:Kill()
		end
		
		return
	end
	
	if npcdata.Terrified then
		if not (npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking) then
			npcdata.Terrified = nil
			npcdata.OhNoItsMurder = nil
			npcdata.SuckStartTimer = nil
			npc.Parent = nil
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		else
			npc.Velocity = nilvector
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			mod:removeStatusEffects(npc)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			
			npcdata.SuckStartTimer = (npcdata.SuckStartTimer or (FiendFolio.Emmission.Balance.SuckStartTimer + math.random(-5, 5))) - 1
			
			if npcdata.SuckStartTimer <= FiendFolio.Emmission.Balance.SuckStartTimer * 0.66 then
				if npcdata.OhNoItsMurder and not sprite:IsPlaying("UnadulteredHysteria") then
					local frame = sprite:GetFrame()
					sprite:Play("UnadulteredHysteria", true)
					sprite:SetFrame(frame)
					sprite.FlipX = npc.Parent.Position.X - npc.Position.X > 0
				elseif not npcdata.OhNoItsMurder and not sprite:IsPlaying("SuckedStart03") then
					local frame = sprite:GetFrame()
					sprite:Play("SuckedStart03", true)
					sprite:SetFrame(frame)
					sprite.FlipX = false
				end
				
				npcdata.FadingIn = nil
				
				npc.Velocity = npc.Parent.Position - npc.Position
				
				if npc.Velocity:Length() > FiendFolio.Emmission.Balance.SuckStartSpeed then
					npc.Velocity = npc.Velocity:Resized(FiendFolio.Emmission.Balance.SuckStartSpeed)
				end
			else
				if npcdata.OhNoItsMurder and not sprite:IsPlaying("UnadulteredHysteria") then
					sprite:Play("UnadulteredHysteria", true)
					sprite.FlipX = npc.Parent.Position.X - npc.Position.X > 0
				elseif not npcdata.OhNoItsMurder and not sprite:IsPlaying("SuckedStart01") then
					sprite:Play("SuckedStart01", true)
				end
			end
			
			if npcdata.SuckStartTimer <= 0 then
				npcdata.Purgatorio = true
				npcdata.LastPurgatorioPosition = npc.Parent.Position
				npcdata.Terrified = nil
				npcdata.OhNoItsMurder = nil
				npcdata.SuckStartTimer = nil
				sprite.FlipX = false
			else			
				return
			end
		end
	end
	
	if npcdata.Purgatorio then
		if not sprite:IsPlaying("Sucked") then
			sprite:Play("Sucked", true)
		end
		
		if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking then
			npcdata.LastPurgatorioPosition = npc.Parent.Position
		end
		local targetpos = npcdata.LastPurgatorioPosition + Vector(0, 10)
		
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		
		if npcdata.Fired then
			if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking then
				local targetVelocity = (targetpos - npc.Position):Resized(FiendFolio.Emmission.Balance.InhaleSpeed)
				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, FiendFolio.Emmission.Balance.InhaleLerp)
			end
		else
			local fireDirection = (npc.Position - targetpos):Rotated(120)
			npc.Velocity = fireDirection:Resized(FiendFolio.Emmission.Balance.InhaleSpeed)
			
			npcdata.Fired = true
			
			npcdata.LastPositions = {}
			for i = 1, 6 do
				table.insert(npcdata.LastPositions, 1, npc.Position)
			end
			
			npcdata.LastHeights = {}
			for i = 1, 12 do
				table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
			end
		end
		
		npcdata.LastPositions = npcdata.LastPositions or {}
		table.insert(npcdata.LastPositions, 1, npc.Position)
		if #npcdata.LastPositions > 6 then
			table.remove(npcdata.LastPositions, 7)
		end
		
		local lastPositionOffset = npc.PositionOffset + Vector(0, 0)
		if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking then
			npc.PositionOffset = Vector(0, math.max(npc.PositionOffset.Y - 2, -65))
		else
			npc.PositionOffset = Vector(0, npc.PositionOffset.Y + 2)
		end
		npcdata.LerpedHeight = false
		
		npcdata.LastHeights = npcdata.LastHeights or {}
		table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
		table.insert(npcdata.LastHeights, 1, lastPositionOffset)
		if #npcdata.LastHeights > 12 then
			table.remove(npcdata.LastHeights, 13)
			table.remove(npcdata.LastHeights, 14)
		end

		if npc.Position:Distance(targetpos) < 9.99 and 
		   npc.PositionOffset.Y <= -65 and 
		   npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking
		then
			local blink = Isaac.Spawn(1000, 1752, 0, npc.Position, nilvector, npc):ToEffect()
			blink:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			blink:GetSprite():Play("Blink", true)
			blink.PositionOffset = Vector(0,-65)
			
			npc:PlaySound(mod.Sounds.KirbyInhale, 0.5, 0, false, 2.0 + (npc.Parent:GetData().EmmissionsGuzzled or 0) * 0.2)
			npc.Parent:GetData().EmmissionsGuzzled = (npc.Parent:GetData().EmmissionsGuzzled or 0) + 1
			
			npc:Remove()
		elseif npc.PositionOffset.Y > -5 and 
		       not (npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking)
		then
			npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.5, 0, false, 1)

			local poof = Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
			local poofData = poof:GetData()
			local poofSprite = poof:GetSprite()

			local color = Color(1, 1, 1, 1, 0, 0, 0)
			color:SetColorize(1, 1, 1.5, 1)
			poof.Color = color

			poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
			poofSprite:Play("Explosion")
			
			mod.scheduleForUpdate(function()
				local angy = Isaac.Spawn(1000, 15, 0, poof.Position, nilvector, nil)
				local angySprite = angy:GetSprite()

				local color = Color(2.0, 2.0, 2.0, 0.7, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				angy.Color = color
				angy.SpriteScale = Vector(1.2, 1.2)

				angySprite:Load("gfx/1000.034_Fart.anm2", true)
				angySprite:Play("Explode")
			end, 4)

			mod.XalumDamageInArea(npc, 40)

			npc:Kill()
		end
		
		return
	end

	if not (npc.Parent and npc.Parent:Exists()) then
		npcdata.State = 'idle'
		npcdata.OrbitState = nil
	elseif not npcdata.OrbitState then
		-- when unorbiting, make sure to unparent
		npcdata.OrbitState = "MovingIntoOrbit"
	end

	if npcdata.State == 'idle' then
		if not sprite:IsPlaying("Idle01") then
			sprite:Play("Idle01", true)
		end
	
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.Friction = FiendFolio.Emmission.Balance.WalkFriction
		if npcdata.StateFrame % FiendFolio.Emmission.Balance.WalkPeriod == 0 then
			local movspeed = FiendFolio.Emmission.Balance.Speed
			if mod:isConfuse(npc) or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
				movspeed = movspeed * 0.6
			end

			npc.Velocity = mod:runIfFear(npc, (npc.Velocity * 0.8 + RandomVector() * 3)):Resized(movspeed)
			
			if npcdata.WanderTargetX then
				if (npcdata.WanderTargetX < npc.Position.X and npc.Velocity.X > 0) or
				   (npcdata.WanderTargetX > npc.Position.X and npc.Velocity.X < 0)
				then
					npc.Velocity = Vector(npc.Velocity.X * -1, npc.Velocity.Y)
				end
			end
			
			if npcdata.WanderTargetY then
				if (npcdata.WanderTargetY < npc.Position.Y and npc.Velocity.Y > 0) or
				   (npcdata.WanderTargetY > npc.Position.Y and npc.Velocity.Y < 0)
				then
					npc.Velocity = Vector(npc.Velocity.X, npc.Velocity.Y * -1)
				end
			end
		end
	elseif npcdata.OrbitState then
		if not sprite:IsPlaying("Idle01") then
			sprite:Play("Idle01", true)
		end
		
		local parent = npc.Parent
		local pdata = parent:GetData()

		local idx
		local activeOrbitIdx = 0
		local numOrbiters = 0
		for i, orbit in ipairs(pdata.Orbiters) do
			local odata = orbit:GetData()
			if odata.OrbitState == "Orbiting" then
				numOrbiters = numOrbiters + 1
			end
			if orbit.InitSeed == npc.InitSeed and orbit.Index == npc.Index then
				idx = i
				activeOrbitIdx = numOrbiters
			end
		end

		if npcdata.OrbitState == "MovingIntoOrbit" then
			local bet = parent.Position - npc.Position
			if bet:LengthSquared() < (parent.Size + FiendFolio.Emmission.Balance.OrbitDistance) ^ 2 then
				npc.Velocity = nilvector
				npcdata.OrbitState = "Orbiting"

				local closest = 100000
				local newIdx = numOrbiters + 1
				for i = 1, numOrbiters + 1 do
					local pos = GetOrbitTargetPos(i, numOrbiters, parent, FiendFolio.Emmission.Balance.OrbitPeriod, FiendFolio.Emmission.Balance.OrbitDistance)
					local dist = (pos - npc.Position):LengthSquared()
					if dist < closest then
						-- is the potential position clockwise of my position
						-- this way it won't look weird
						local betMe, betPos = npc.Position - parent.Position, pos - parent.Position
						if IsLessClockwise(betMe, betPos) then
							newIdx, closest = i, dist
						end
					end
				end

				table.remove(pdata.Orbiters, idx)
				table.insert(pdata.Orbiters, newIdx, npc)
			else
				npc.Velocity = (npc.Velocity + bet:Resized(FiendFolio.Emmission.Balance.Speed)):Resized(FiendFolio.Emmission.Balance.OrbitPositioningSpeed)
			end
		elseif npcdata.OrbitState == "Orbiting" then
			local projectedPosition = GetOrbitTargetPos(activeOrbitIdx, numOrbiters, parent, FiendFolio.Emmission.Balance.OrbitPeriod, FiendFolio.Emmission.Balance.OrbitDistance)
			npc.Velocity = npc.Velocity * 0.6 + (projectedPosition - npc.Position) * 0.2

			local sp = npc.Velocity:Length()
			if sp > FiendFolio.Emmission.Balance.OrbitSpeed then
				npc.Velocity = npc.Velocity * (FiendFolio.Emmission.Balance.OrbitSpeed / sp)
			end
		end
	end
end

function mod:handleEmmissionFade(npc, sprite, npcdata)
	if npcdata.Purgatorio or npcdata.Bounced then
		npcdata.ActualColor = Color.Lerp(sprite.Color, Color(1,1,1,1,0,0,0), 0)
		npc:SetColor(Color(1,1,1,0,0,0,0), 1, 0, false, false)
	elseif npcdata.OhNoItsMurder then
		--do nothing
	elseif npcdata.FadingIn then
		if npcdata.StateFrame < FiendFolio.Emmission.Balance.FadeInDuration then
			local alpha = (npcdata.StateFrame / FiendFolio.Emmission.Balance.FadeInDuration)
			local currentColor = sprite.Color
			local fadeColor = Color.Lerp(currentColor, Color(1,1,1,1,0,0,0), 0)
			fadeColor:SetTint(currentColor.R, currentColor.G, currentColor.B, alpha)
			npc:SetColor(fadeColor, 1, 0, false, false)
		else
			npcdata.FadingIn = nil
		end
	end
end

local trailDist = {}
trailDist[2] = 12.5
trailDist[3] = 10
trailDist[4] = 7.5
trailDist[5] = 5

local emmissionSprite = Sprite()
emmissionSprite:Load("gfx/bosses/ghostbuster/monster_emmission.anm2", true)
function mod:emmissionRender(npc, offset)
	local sprite = npc:GetSprite()
	local npcdata = npc:GetData()
	
	if npcdata.Purgatorio or npcdata.Bounced then
		local lastPositions = npcdata.LastPositions
		local lastHeights = npcdata.LastHeights
		
		if lastPositions == nil or lastHeights == nil then
			return
		end
		
		local height = lastHeights[2]
		if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then
			height = lastHeights[1]
		end
		if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
			height = height * -1
		end
		
		local segmentPositions = {}
		segmentPositions[1] = npc.Position + height
		
		local vectorsToPositions = {}
		local prevPosition = segmentPositions[1]
		local distance = 0
		for i = 2, 6 do
			local height = lastHeights[i * 2]
			if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then
				height = lastHeights[i * 2 - 1]
			end
			if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
				height = height * -1
			end
		
			vectorsToPositions[i - 1] = prevPosition - (lastPositions[i] + height)
			prevPosition = lastPositions[i] + height
		end
		
		local spareDistances = {}
		for s = 2, 5 do
			local startpos = segmentPositions[s - 1]
			local accumulatedLength = 0
			local accumulatedDistance = nilvector
			
			while #spareDistances > 0 do
				local dist = spareDistances[1]
				table.remove(spareDistances, 1)
				
				if accumulatedLength + dist:Length() > trailDist[s] then
					local distToTravel = dist:Resized(trailDist[s] - accumulatedLength)
					local remainingDist = dist - distToTravel
					table.insert(spareDistances, 1, remainingDist)
					
					accumulatedDistance = accumulatedDistance + distToTravel
					accumulatedLength = trailDist[s]
					break
				else
					accumulatedDistance = accumulatedDistance + dist
					accumulatedLength = accumulatedLength + dist:Length()
				end
			end
			
			local dist = vectorsToPositions[s - 1]
				
			if accumulatedLength + dist:Length() > trailDist[s] then
				local distToTravel = dist:Resized(trailDist[s] - accumulatedLength)
				local remainingDist = dist - distToTravel
				table.insert(spareDistances, remainingDist)
					
				accumulatedDistance = accumulatedDistance + distToTravel
				accumulatedLength = trailDist[s]
			else
				accumulatedDistance = accumulatedDistance + dist
				accumulatedLength = accumulatedLength + dist:Length()
			end
			
			segmentPositions[s] = startpos - accumulatedDistance
		end
		
		emmissionSprite.Color = npcdata.ActualColor
		emmissionSprite.FlipX = sprite.FlipX
		emmissionSprite.FlipY = sprite.FlipY
		emmissionSprite.Offset = sprite.Offset
		emmissionSprite.PlaybackSpeed = sprite.PlaybackSpeed
		emmissionSprite.Rotation = sprite.Rotation
		emmissionSprite.Scale = sprite.Scale
		
		for i = 5, 2, -1 do
			emmissionSprite:Play("TrailOutline", true)
			emmissionSprite:SetFrame(i * 2)
			emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[i]) + offset, nilvector, nilvector)
		end
		
		emmissionSprite:Play("SuckedOutline", true)
		emmissionSprite:SetFrame(sprite:GetFrame())
		emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[1]) + offset, nilvector, nilvector)
		
		local renderOrder = {}
		for i = 2, 5 do
			local position = segmentPositions[i]
			local inserted = false
			for j = 1, #renderOrder do
				if position.Y < segmentPositions[renderOrder[j]].Y then
					table.insert(renderOrder, j, i)
					inserted = true
					break
				end
			end
			if not inserted then
				table.insert(renderOrder, i)
			end
		end
		
		for j = 1, #renderOrder do
			local i = renderOrder[j]
			emmissionSprite:Play("Trail", true)
			emmissionSprite:SetFrame(i * 2)
			emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[i]) + offset, nilvector, nilvector)
		end
		
		npc:SetColor(npcdata.ActualColor, 1, 0, false, false)
		sprite:Render(Isaac.WorldToRenderPosition(segmentPositions[1]) + offset, nilvector, nilvector)
		npc:SetColor(Color(1,1,1,0,0,0,0), 1, 0, false, false)
	end
end

function mod:emmissionColl(npc, entity)
	if entity.Type == EntityType.ENTITY_PLAYER or (entity:ToNPC() and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
		local npcdata = npc:GetData()
		if npcdata.OrbitState == "MovingIntoOrbit" then
			local room = game:GetRoom()
			local topLeft = room:GetTopLeftPos()
			local bottomRight = room:GetBottomRightPos()
			
			local nearWall = npc.Position.X < topLeft.X + FiendFolio.Emmission.Balance.FadeInGraceDistance or
			                 npc.Position.X > bottomRight.X - FiendFolio.Emmission.Balance.FadeInGraceDistance or
			                 npc.Position.Y < topLeft.Y + FiendFolio.Emmission.Balance.FadeInGraceDistance or
			                 npc.Position.Y > bottomRight.Y - FiendFolio.Emmission.Balance.FadeInGraceDistance
			
			if nearWall and (npcdata.StateFrame or 0) < FiendFolio.Emmission.Balance.FadeInGracePeriod then
				return true
			end
		end
	end
end

--------------------------------------------------------------------------------------

FiendFolio.CongressingEmmission = {
	Balance = {
		Mass = 400,
		SinPeriod = 80,
		SinPeak = 4.5,
		FadeDuration = 40,
		FadeOutAt = 200,
		Speed = -560 / 240,
	},
}

function mod:congressingEmmissionAI(npc, sprite, npcdata)
	if npcdata.init == nil then
		npc.Mass = FiendFolio.CongressingEmmission.Balance.Mass
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.SplatColor = mod.ColorGhostly
		npc.PositionOffset = Vector(0,-20)
		
		sprite:Play("Idle02", true)
		if npc.SubType == 1 or npc.SubType == 3 then
			sprite.FlipX = true
		end

		npcdata.init = true
	end
	
	if npcdata.Terrified then
		if not (npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking) then
			npcdata.Terrified = nil
			npcdata.OhNoItsMurder = nil
			npcdata.SuckStartTimer = nil
			npc.Parent = nil
			npc.Mass = FiendFolio.CongressingEmmission.Balance.Mass
			npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			npcdata.StateFrame = npcdata.OriginalStateFrame
		else
			npc.Velocity = nilvector
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			npc.Mass = FiendFolio.Emmission.Balance.Mass
			mod:removeStatusEffects(npc)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			
			if npcdata.SuckStartTimer == nil then
				npcdata.OriginalStateFrame = npcdata.StateFrame
			end
			
			npcdata.SuckStartTimer = (npcdata.SuckStartTimer or (FiendFolio.Emmission.Balance.SuckStartTimer + math.random(-5, 5))) - 1
			
			if npcdata.SuckStartTimer <= FiendFolio.Emmission.Balance.SuckStartTimer * 0.66 then
				if npcdata.OhNoItsMurder and not sprite:IsPlaying("UnadulteredHysteria") then
					local frame = sprite:GetFrame()
					sprite:Play("UnadulteredHysteria", true)
					sprite:SetFrame(frame)
					sprite.FlipX = npc.Parent.Position.X - npc.Position.X > 0
				elseif not npcdata.OhNoItsMurder and not sprite:IsPlaying("SuckedStart03") then
					local frame = sprite:GetFrame()
					sprite:Play("SuckedStart03", true)
					sprite:SetFrame(frame)
					sprite.FlipX = false
				end
				
				npcdata.StateFrame = 96
				
				npc.Velocity = npc.Parent.Position - npc.Position
				
				if npc.Velocity:Length() > FiendFolio.Emmission.Balance.SuckStartSpeed then
					npc.Velocity = npc.Velocity:Resized(FiendFolio.Emmission.Balance.SuckStartSpeed)
				end
			else
				if npcdata.OhNoItsMurder and not sprite:IsPlaying("UnadulteredHysteria") then
					sprite:Play("UnadulteredHysteria", true)
					sprite.FlipX = npc.Parent.Position.X - npc.Position.X > 0
				elseif not npcdata.OhNoItsMurder and not sprite:IsPlaying("SuckedStart02") then
					sprite:Play("SuckedStart02", true)
				end
			end
			
			if npcdata.SuckStartTimer <= 0 then
				npcdata.Purgatorio = true
				npcdata.LastPurgatorioPosition = npc.Parent.Position
				npcdata.Terrified = nil
				npcdata.OhNoItsMurder = nil
				npcdata.SuckStartTimer = nil
				sprite.FlipX = false
			else			
				return
			end
		end
	end
	
	if npcdata.Purgatorio then
		if not sprite:IsPlaying("Sucked") then
			sprite:Play("Sucked", true)
		end
		
		if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking then
			npcdata.LastPurgatorioPosition = npc.Parent.Position
		end
		local targetpos = npcdata.LastPurgatorioPosition + Vector(0, 10)
		
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		
		if npcdata.Fired then
			if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking then
				local targetVelocity = (targetpos - npc.Position):Resized(FiendFolio.Emmission.Balance.InhaleSpeed)
				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, FiendFolio.Emmission.Balance.InhaleLerp)
			end
		else
			local fireDirection = (npc.Position - targetpos):Rotated(120)
			npc.Velocity = fireDirection:Resized(FiendFolio.Emmission.Balance.InhaleSpeed)
			
			npcdata.Fired = true
			
			npcdata.LastPositions = {}
			for i = 1, 6 do
				table.insert(npcdata.LastPositions, 1, npc.Position)
			end
			
			npcdata.LastHeights = {}
			for i = 1, 12 do
				table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
			end
		end
		
		npcdata.LastPositions = npcdata.LastPositions or {}
		table.insert(npcdata.LastPositions, 1, npc.Position)
		if #npcdata.LastPositions > 6 then
			table.remove(npcdata.LastPositions, 7)
		end
		
		local lastPositionOffset = npc.PositionOffset + Vector(0, 0)
		if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking then
			npc.PositionOffset = Vector(0, math.max(npc.PositionOffset.Y - 2, -65))
		else
			npc.PositionOffset = Vector(0, npc.PositionOffset.Y + 2)
		end
		npcdata.LerpedHeight = false
		
		npcdata.LastHeights = npcdata.LastHeights or {}
		table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
		table.insert(npcdata.LastHeights, 1, lastPositionOffset)
		if #npcdata.LastHeights > 12 then
			table.remove(npcdata.LastHeights, 13)
			table.remove(npcdata.LastHeights, 14)
		end

		if npc.Position:Distance(targetpos) < 9.99 and 
		   npc.PositionOffset.Y <= -65 and 
		   npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking
		then
			local blink = Isaac.Spawn(1000, 1752, 0, npc.Position, nilvector, npc):ToEffect()
			blink:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			blink:GetSprite():Play("Blink", true)
			blink.PositionOffset = Vector(0,-65)
			
			npc:PlaySound(mod.Sounds.KirbyInhale, 0.5, 0, false, 2.0 + (npc.Parent:GetData().EmmissionsGuzzled or 0) * 0.2)
			npc.Parent:GetData().EmmissionsGuzzled = (npc.Parent:GetData().EmmissionsGuzzled or 0) + 1
			
			npc:Remove()
		elseif npc.PositionOffset.Y > -5 and 
		       not (npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().Sucking)
		then
			npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.5, 0, false, 1)

			local poof = Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
			local poofData = poof:GetData()
			local poofSprite = poof:GetSprite()

			local color = Color(1, 1, 1, 1, 0, 0, 0)
			color:SetColorize(1, 1, 1.5, 1)
			poof.Color = color

			poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
			poofSprite:Play("Explosion")
			
			mod.scheduleForUpdate(function()
				local angy = Isaac.Spawn(1000, 15, 0, poof.Position, nilvector, nil)
				local angySprite = angy:GetSprite()

				local color = Color(2.0, 2.0, 2.0, 0.7, 0, 0, 0)
				color:SetColorize(1, 1, 1.25, 1)
				angy.Color = color
				angy.SpriteScale = Vector(1.2, 1.2)

				angySprite:Load("gfx/1000.034_Fart.anm2", true)
				angySprite:Play("Explode")
			end, 4)

			mod.XalumDamageInArea(npc, 40)

			npc:Kill()
		end
		
		return
	end
	
	if not sprite:IsPlaying("Idle02") then
		sprite:Play("Idle02", true)
		if npc.SubType == 1 or npc.SubType == 3 then
			sprite.FlipX = true
		end
	end
	
	npcdata.StateFrame = (npcdata.StateFrame or 0) + 1

	local x = FiendFolio.CongressingEmmission.Balance.Speed
	local y = math.sin(npcdata.StateFrame * 2 * math.pi / FiendFolio.CongressingEmmission.Balance.SinPeriod) * FiendFolio.CongressingEmmission.Balance.SinPeak
	if npc.SubType == 1 or npc.SubType == 3 then
		x = x * -1
	end
	if npc.SubType == 1 or npc.SubType == 2 then
		y = y * -1
	end
	npc.Velocity = Vector(x, y)
	
	if npcdata.StateFrame >= FiendFolio.CongressingEmmission.Balance.FadeOutAt + FiendFolio.CongressingEmmission.Balance.FadeDuration then
		npc:Remove()
	end
end

function mod:handleCongressingEmmissionFade(npc, sprite, npcdata)
	if npcdata.Purgatorio then
		npcdata.ActualColor = Color.Lerp(sprite.Color, Color(1,1,1,1,0,0,0), 0)
		npc:SetColor(Color(1,1,1,0,0,0,0), 1, 0, false, false)
	elseif npcdata.OhNoItsMurder then
		--do nothing
	elseif npcdata.StateFrame <= FiendFolio.CongressingEmmission.Balance.FadeDuration then
		local alpha = (npcdata.StateFrame / FiendFolio.CongressingEmmission.Balance.FadeDuration)
		local currentColor = sprite.Color
		local fadeColor = Color.Lerp(currentColor, Color(1,1,1,1,0,0,0), 0)
		fadeColor:SetTint(currentColor.R, currentColor.G, currentColor.B, alpha)
		npc:SetColor(fadeColor, 1, 0, false, false)
	elseif npcdata.StateFrame >= FiendFolio.CongressingEmmission.Balance.FadeOutAt then
		local frame = npcdata.StateFrame - FiendFolio.CongressingEmmission.Balance.FadeOutAt
		local alpha = 1 - (frame / FiendFolio.CongressingEmmission.Balance.FadeDuration)
		local currentColor = sprite.Color
		local fadeColor = Color.Lerp(currentColor, Color(1,1,1,1,0,0,0), 0)
		fadeColor:SetTint(currentColor.R, currentColor.G, currentColor.B, alpha)
		npc:SetColor(fadeColor, 1, 0, false, false)
	end
end

function mod:congressingEmmissionRender(npc, offset)
	local sprite = npc:GetSprite()
	local npcdata = npc:GetData()
	
	if npcdata.Purgatorio then
		local lastPositions = npcdata.LastPositions
		local lastHeights = npcdata.LastHeights
		
		if lastPositions == nil or lastHeights == nil then
			return
		end
		
		local height = lastHeights[2]
		if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then
			height = lastHeights[1]
		end
		if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
			height = height * -1
		end
		
		local segmentPositions = {}
		segmentPositions[1] = npc.Position + height
		
		local vectorsToPositions = {}
		local prevPosition = segmentPositions[1]
		local distance = 0
		for i = 2, 6 do
			local height = lastHeights[i * 2]
			if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then
				height = lastHeights[i * 2 - 1]
			end
			if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
				height = height * -1
			end
		
			vectorsToPositions[i - 1] = prevPosition - (lastPositions[i] + height)
			prevPosition = lastPositions[i] + height
		end
		
		local spareDistances = {}
		for s = 2, 5 do
			local startpos = segmentPositions[s - 1]
			local accumulatedLength = 0
			local accumulatedDistance = nilvector
			
			while #spareDistances > 0 do
				local dist = spareDistances[1]
				table.remove(spareDistances, 1)
				
				if accumulatedLength + dist:Length() > trailDist[s] then
					local distToTravel = dist:Resized(trailDist[s] - accumulatedLength)
					local remainingDist = dist - distToTravel
					table.insert(spareDistances, 1, remainingDist)
					
					accumulatedDistance = accumulatedDistance + distToTravel
					accumulatedLength = trailDist[s]
					break
				else
					accumulatedDistance = accumulatedDistance + dist
					accumulatedLength = accumulatedLength + dist:Length()
				end
			end
			
			local dist = vectorsToPositions[s - 1]
				
			if accumulatedLength + dist:Length() > trailDist[s] then
				local distToTravel = dist:Resized(trailDist[s] - accumulatedLength)
				local remainingDist = dist - distToTravel
				table.insert(spareDistances, remainingDist)
					
				accumulatedDistance = accumulatedDistance + distToTravel
				accumulatedLength = trailDist[s]
			else
				accumulatedDistance = accumulatedDistance + dist
				accumulatedLength = accumulatedLength + dist:Length()
			end
			
			segmentPositions[s] = startpos - accumulatedDistance
		end
		
		emmissionSprite.Color = npcdata.ActualColor
		emmissionSprite.FlipX = sprite.FlipX
		emmissionSprite.FlipY = sprite.FlipY
		emmissionSprite.Offset = sprite.Offset
		emmissionSprite.PlaybackSpeed = sprite.PlaybackSpeed
		emmissionSprite.Rotation = sprite.Rotation
		emmissionSprite.Scale = sprite.Scale
		
		for i = 5, 2, -1 do
			emmissionSprite:Play("TrailOutline", true)
			emmissionSprite:SetFrame(i * 2)
			emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[i]) + offset, nilvector, nilvector)
		end
		
		emmissionSprite:Play("SuckedOutline", true)
		emmissionSprite:SetFrame(sprite:GetFrame())
		emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[1]) + offset, nilvector, nilvector)
		
		local renderOrder = {}
		for i = 2, 5 do
			local position = segmentPositions[i]
			local inserted = false
			for j = 1, #renderOrder do
				if position.Y < segmentPositions[renderOrder[j]].Y then
					table.insert(renderOrder, j, i)
					inserted = true
					break
				end
			end
			if not inserted then
				table.insert(renderOrder, i)
			end
		end
		
		for j = 1, #renderOrder do
			local i = renderOrder[j]
			emmissionSprite:Play("Trail", true)
			emmissionSprite:SetFrame(i * 2)
			emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[i]) + offset, nilvector, nilvector)
		end
		
		npc:SetColor(npcdata.ActualColor, 1, 0, false, false)
		sprite:Render(Isaac.WorldToRenderPosition(segmentPositions[1]) + offset, nilvector, nilvector)
		npc:SetColor(Color(1,1,1,0,0,0,0), 1, 0, false, false)
	end
end

--------------------------------------------------------------------------------------

FiendFolio.EmmissionProjectile = {
	Balance = {
		Mass = 400,
		Speed = 15,
		TargetRendering = false,
		FadeInTargetStartingAtHeight = -50,
	},
}

function mod:emmissionProjectileAI(npc, sprite, npcdata)
	if npcdata.init == nil then
		npc.Mass = FiendFolio.EmmissionProjectile.Balance.Mass
		npc.SplatColor = mod.ColorGhostly
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		
		npcdata.FallingSpeed = npcdata.FallingSpeed or 0
		npcdata.FallingAccel = npcdata.FallingAccel or 0
		
		npcdata.init = true
	end
	
	sprite:Play("Invis", true)
	
	targetpos = npcdata.TargetPosition
	if targetpos == nil then
		local target = npc:GetPlayerTarget()
		if npcdata.TargetLeading then
			targetpos = game:GetRoom():GetClampedPosition(target.Position + target.Velocity * 10, 20)
		else
			targetpos = target.Position
		end
	elseif not npcdata.TargetEffect and FiendFolio.EmmissionProjectile.Balance.TargetRendering then
		local target = Isaac.Spawn(1000, 1754, 0, targetpos, nilvector, nil)
		target.DepthOffset = -9999
		target.Parent = npc
		npcdata.TargetEffect = target
	end
	
	if npcdata.Fired then
		local dist = targetpos - npc.Position
		local speed = FiendFolio.EmmissionProjectile.Balance.Speed * math.min(1, math.max(0.5, dist:Length() / 60))
		local targetVelocity = (dist):Resized(speed)
		npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.1)
	else
		local fireDirection = (npc.Position - targetpos):Rotated(60 - 120 * npc:GetDropRNG():RandomInt(2))
		npc.Velocity = fireDirection:Resized(FiendFolio.EmmissionProjectile.Balance.Speed)
		
		npcdata.Fired = true
		
		npcdata.LastPositions = {}
		for i = 1, 6 do
			table.insert(npcdata.LastPositions, 1, npc.Position)
		end
		
		npcdata.LastHeights = {}
		for i = 1, 12 do
			table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
		end
	end
	
	npcdata.LastPositions = npcdata.LastPositions or {}
	table.insert(npcdata.LastPositions, 1, npc.Position)
	if #npcdata.LastPositions > 6 then
		table.remove(npcdata.LastPositions, 7)
	end
	
	npcdata.FallingSpeed = 0.1 + npcdata.FallingAccel + 0.9 * npcdata.FallingSpeed
	npc.PositionOffset = Vector(0, npc.PositionOffset.Y + npcdata.FallingSpeed)
	npcdata.LerpedHeight = false
	
	npcdata.LastHeights = npcdata.LastHeights or {}
	table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0))
	table.insert(npcdata.LastHeights, 1, npc.PositionOffset + Vector(0, 0.1 + npcdata.FallingAccel + 0.9 * npcdata.FallingSpeed) / 2)
	if #npcdata.LastHeights > 12 then
		table.remove(npcdata.LastHeights, 13)
		table.remove(npcdata.LastHeights, 14)
	end
	
	--if npc.PositionOffset.Y < -50 then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	--else
	--	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	--end
	
	if npcdata.TargetEffect then
		local alpha = math.max(0, math.min(1, 1 - (npc.PositionOffset.Y + 5) / FiendFolio.EmmissionProjectile.Balance.FadeInTargetStartingAtHeight))
		npcdata.TargetEffect:GetSprite().Color = Color(1, 1, 1, alpha, 0, 0, 0)
	end
	
	if npc.PositionOffset.Y >= -5 then
		npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.5, 0, false, 1)

		local poof = Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		local poofData = poof:GetData()
		local poofSprite = poof:GetSprite()

		local color = Color(1, 1, 1, 1, 0, 0, 0)
		color:SetColorize(1, 1, 1.5, 1)
		poof.Color = color

		poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
		poofSprite:Play("Explosion")
		
		mod.scheduleForUpdate(function()
			local angy = Isaac.Spawn(1000, 15, 0, poof.Position, nilvector, nil)
			local angySprite = angy:GetSprite()

			local color = Color(2.0, 2.0, 2.0, 0.7, 0, 0, 0)
			color:SetColorize(1, 1, 1.25, 1)
			angy.Color = color
			angy.SpriteScale = Vector(1.2, 1.2)

			angySprite:Load("gfx/1000.034_Fart.anm2", true)
			angySprite:Play("Explode")
		end, 4)

		mod.XalumDamageInArea(npc, 40)

		if npc.TargetEffect then
			npc.TargetEffect:Remove()
			npc.TargetEffect = nil
		end
		npc:BloodExplode()
		npc:Remove()
	end
end

function mod:emmissionProjectileColl(npc, entity)
	if entity.Type == EntityType.ENTITY_PLAYER or (entity:ToNPC() and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
		npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.5, 0, false, 1)

		local poof = Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		local poofData = poof:GetData()
		local poofSprite = poof:GetSprite()

		local color = Color(1, 1, 1, 1, 0, 0, 0)
		color:SetColorize(1, 1, 1.5, 1)
		poof.Color = color

		poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
		poofSprite:Play("Explosion")
		
		mod.scheduleForUpdate(function()
			local angy = Isaac.Spawn(1000, 15, 0, poof.Position, nilvector, nil)
			local angySprite = angy:GetSprite()

			local color = Color(2.0, 2.0, 2.0, 0.7, 0, 0, 0)
			color:SetColorize(1, 1, 1.25, 1)
			angy.Color = color
			angy.SpriteScale = Vector(1.2, 1.2)

			angySprite:Load("gfx/1000.034_Fart.anm2", true)
			angySprite:Play("Explode")
		end, 4)

		mod.XalumDamageInArea(npc, 40)

		if npc.TargetEffect then
			npc.TargetEffect:Remove()
			npc.TargetEffect = nil
		end
		npc:BloodExplode()
		npc:Remove()
	end
	
	return true
end

function mod:emmissionProjectileRender(npc, offset)
	local sprite = npc:GetSprite()
	local npcdata = npc:GetData()
	
	local lastPositions = npcdata.LastPositions
	local lastHeights = npcdata.LastHeights
	
	if lastPositions == nil or lastHeights == nil then
		return
	end
	
	local height = lastHeights[2]
	if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then
		height = lastHeights[1]
	end
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		height = height * -1
	end
	
	local segmentPositions = {}
	segmentPositions[1] = npc.Position + height
	
	local vectorsToPositions = {}
	local prevPosition = segmentPositions[1]
	local distance = 0
	for i = 2, 6 do
		local height = lastHeights[i * 2]
		if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then
			height = lastHeights[i * 2 - 1]
		end
		if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
			height = height * -1
		end
	
		vectorsToPositions[i - 1] = prevPosition - (lastPositions[i] + height)
		prevPosition = lastPositions[i] + height
	end
	
	local spareDistances = {}
	for s = 2, 5 do
		local startpos = segmentPositions[s - 1]
		local accumulatedLength = 0
		local accumulatedDistance = nilvector
		
		while #spareDistances > 0 do
			local dist = spareDistances[1]
			table.remove(spareDistances, 1)
			
			if accumulatedLength + dist:Length() > trailDist[s] then
				local distToTravel = dist:Resized(trailDist[s] - accumulatedLength)
				local remainingDist = dist - distToTravel
				table.insert(spareDistances, 1, remainingDist)
				
				accumulatedDistance = accumulatedDistance + distToTravel
				accumulatedLength = trailDist[s]
				break
			else
				accumulatedDistance = accumulatedDistance + dist
				accumulatedLength = accumulatedLength + dist:Length()
			end
		end
		
		local dist = vectorsToPositions[s - 1]
			
		if accumulatedLength + dist:Length() > trailDist[s] then
			local distToTravel = dist:Resized(trailDist[s] - accumulatedLength)
			local remainingDist = dist - distToTravel
			table.insert(spareDistances, remainingDist)
				
			accumulatedDistance = accumulatedDistance + distToTravel
			accumulatedLength = trailDist[s]
		else
			accumulatedDistance = accumulatedDistance + dist
			accumulatedLength = accumulatedLength + dist:Length()
		end
		
		segmentPositions[s] = startpos - accumulatedDistance
	end
		
	emmissionSprite.Color = npc:GetSprite().Color
	emmissionSprite.FlipX = sprite.FlipX
	emmissionSprite.FlipY = sprite.FlipY
	emmissionSprite.Offset = sprite.Offset
	emmissionSprite.PlaybackSpeed = sprite.PlaybackSpeed
	emmissionSprite.Rotation = sprite.Rotation
	emmissionSprite.Scale = sprite.Scale
	
	for i = 1, 5 do
		emmissionSprite:Play("TrailOutline", true)
		emmissionSprite:SetFrame(i * 2)
		emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[i]) + offset, nilvector, nilvector)
	end
	
	local renderOrder = {}
	for i = 1, 5 do
		local position = segmentPositions[i]
		local inserted = false
		for j = 1, #renderOrder do
			if position.Y < segmentPositions[renderOrder[j]].Y then
				table.insert(renderOrder, j, i)
				inserted = true
				break
			end
		end
		if not inserted then
			table.insert(renderOrder, i)
		end
	end
	
	for j = 1, #renderOrder do
		local i = renderOrder[j]
		emmissionSprite:Play("Trail", true)
		emmissionSprite:SetFrame(i * 2)
		emmissionSprite:Render(Isaac.WorldToRenderPosition(segmentPositions[i]) + offset, nilvector, nilvector)
	end
end

--------------------------------------------------------------------------------------

function mod:emmissionDeathHitboxAI(npc, sprite, npcdata)
	npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
	npc.Visible = false
	npc.Mass = FiendFolio.Ghostbuster.Balance.Mass
	
	if npc.Parent then
		npc.Position = npc.Parent.Position
		npc.Velocity = nilvector
	else
		npc:Remove()
	end
end

--------------------------------------------------------------------------------------

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect:GetSprite():IsFinished("Blink") then
		effect:Remove()
	end
end, 1752)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	effect:GetSprite().Color = Color(1,1,1,0,0,0,0)
	
	if effect:GetSprite():IsFinished("Idle1") or
	   effect:GetSprite():IsFinished("Idle2") or
	   effect:GetSprite():IsFinished("Idle3") or
	   effect:GetSprite():IsFinished("Idle4")
	then
		effect:Remove()
	end
	
	effect:GetData().AlphaFrame = (effect:GetData().AlphaFrame or 0)
	if effect.Parent then
		local parentsprite = effect.Parent:GetSprite()
		if parentsprite:GetAnimation() ~= "SuckStart" and
		   parentsprite:GetAnimation() ~= "SuckLoop" and
		   (parentsprite:GetAnimation() ~= "DeathStart" or parentsprite:GetFrame() < 35)
		then
			effect:GetData().AlphaFrame = effect:GetData().AlphaFrame + 1
		end
	end
end, 1753)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.Parent == nil or not effect.Parent:Exists() then
		effect:Remove()
	end
end, 1754)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect, offset)
	local rendermode = game:GetRoom():GetRenderMode()
	local isReflected = rendermode == RenderMode.RENDER_WATER_REFLECT
	
	if not isReflected then
		local alpha = math.max(0, 1 - ((effect:GetData().AlphaFrame or 0) / 9))
		effect:GetSprite().Color = Color(1,1,1,alpha,0,0,0)
		effect:GetSprite():Render(Isaac.WorldToRenderPosition(effect.Position + effect.PositionOffset) + offset, nilvector, nilvector)
		effect:GetSprite().Color = Color(1,1,1,0,0,0,0)
	end
end, 1753)

local addedCallbacks = false
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not addedCallbacks then
		mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
			local bosses = Isaac.FindByType(mod.FFID.Boss)
			
			local numSucking = 0
			for _, b in ipairs(bosses) do
				if b.Variant == mod.FF.Ghostbuster.Var then
					mod:handleGhostbusterReflectionAndDeath(b:ToNPC(), b:GetSprite(), b:GetData())
					if b:GetData().Sucking then
						numSucking = numSucking + 1
					end
				elseif b.Variant == mod.FF.Emmission.Var then
					mod:handleEmmissionFade(b:ToNPC(), b:GetSprite(), b:GetData())
				elseif b.Variant == mod.FF.CongressingEmmission.Var then
					mod:handleCongressingEmmissionFade(b:ToNPC(), b:GetSprite(), b:GetData())
				end
			end
			
			if numSucking > 0 and not sfx:IsPlaying(mod.Sounds.BusterGhostSuckLoop) then
				sfx:Play(mod.Sounds.BusterGhostSuckLoop, 0.5, 0, true, 1)
			elseif numSucking <= 0 and sfx:IsPlaying(mod.Sounds.BusterGhostSuckLoop) then
				sfx:Stop(mod.Sounds.BusterGhostSuckLoop)
			end
		end)
		
		addedCallbacks = true
	end
end)
