local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:corruptedSutureAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()
	local room = game:GetRoom()
	local rng = npc:GetDropRNG()

	if not data.init then
		if HPBars then
			HPBars:createNewBossBar(npc)
		end
		data.attackList = {
			{"Shoot2", 0},
			{"Bodyslam", 0},
			{"Rockslam", 0},
			{"TeleportAttack", 0},
		}
		
		data.phase1 = true
		if data.warpZoneSpawned then
			data.state = "Idle"
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.movement = 0
		elseif data.dead then
			data.state = "Dying"
			data.movement = 1
		else
			data.state = "Idle"
			data.movement = 0
		end
		if npc.SubType == 1 then
			data.void = true
		end
		data.attackLoop = 0
		data.gridSpawnCooldown = 20
		data.contusionThrowCooldown = 0
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		
		if data.contusionThrowCooldown > 0 then
			data.contusionThrowCooldown = data.contusionThrowCooldown-1
		end
		if data.teleportCooldown then
			if data.teleportCooldown > 0 then
				data.teleportCooldown = data.teleportCooldown-1
			else
				data.teleportCooldown = nil
			end
		end
	end
	
	--Checks for Contusions in the room to pick up. If there are zero alive Contusions, goes to phase 2.
	local phase1 = false
	local suckEm = {}
	local ignoreCooldown = {}
	for _,contusion in ipairs(Isaac.FindByType(180, 233, -1, EntityPartition.ENEMY, false)) do
		local cData = contusion:GetData()
		if cData.dead == nil or contusion:GetSprite():IsPlaying("DeadAnim") then
			phase1 = true
		end
		if (cData.state == "Chilling" or cData.dead == true) and not (cData.pullingSuture or cData.held) and not cData.justThrown and not contusion:GetSprite():IsPlaying("DeadAnim") then
			table.insert(suckEm, contusion)
		end
		if data.phase1 == false then
			if (cData.state == "Chilling" or cData.dead == true) and not (cData.pullingSuture or cData.held) and not contusion:GetSprite():IsPlaying("DeadAnim") then
				table.insert(ignoreCooldown, contusion)
			end
		end
	end
	if data.phase1 == true and phase1 == false then
		npc:PlaySound(mod.Sounds.CSutureGrunt, 0.8, 0, false, 1)
		data.phase1 = false
		npc.StateFrame = 0
	end
	
	if data.movement == 0 then
		--Standard movement. Slow sweeping movements.
		if npc.StateFrame % 40 == 1 then
			data.movement0Speed = 4.5
			data.movement0Pos = targetpos
			if npc.Position:Distance(targetpos) < 160 then
				data.movement0Pos = npc.Position+(targetpos-npc.Position):Resized(160)
			end
		end
		if not data.movement0Pos then
			data.movement0Speed = 4.5
			data.movement0Pos = targetpos
			if npc.Position:Distance(targetpos) < 160 then
				data.movement0Pos = npc.Position+(targetpos-npc.Position):Resized(160)
			end
		end
		if npc.Position:Distance(data.movement0Pos) > 10 then
			npc.Velocity = mod:Lerp(npc.Velocity, (data.movement0Pos-npc.Position):Resized(data.movement0Speed), 0.2)
			if data.movement0Speed > 1 then
				data.movement0Speed = data.movement0Speed*0.97
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
		end
	elseif data.movement == 1 then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.movement == 2 then
		--Chasing the player.
		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(-8), 0.05)
		else
			local speed = 11
			if data.state == "PickingCont" then
				speed = 14
			end
			npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(speed), 0.05)
		end
	elseif data.movement == 3 then
		local vel = (target.Position-npc.Position):Resized((data.moveSpeed or 4))
		npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.3)
	elseif data.movement == 4 then
		if mod:isScare(npc) or npc.Position:Distance(targetpos) < 100 then
			npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(-6), 0.1)
		else
			if npc.StateFrame % 20 == 1 or not data.movement4Pos then
				data.movement4Speed = 4.5
				data.movement4Pos = mod:FindRandomFreePos(npc, 100, true)
			end
			if npc.Position:Distance(data.movement4Pos) > 10 then
				npc.Velocity = mod:Lerp(npc.Velocity, (data.movement4Pos-npc.Position):Resized(data.movement4Speed), 0.2)
				if data.movement4Speed > 1 then
					data.movement4Speed = data.movement4Speed*0.97
				end
			else
				data.movement4Speed = 4.5
				data.movement4Pos = mod:FindRandomFreePos(npc, 100, true)
			end
		end
	end
	
	if npc.Velocity:Length() > 0.1 then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
	end
	
	
	--Checks amount of grids in the room. If there are zero grids, spawns 6 random tiles.
	local gridCount = 0
	for _,grid in ipairs(mod.GetGridEntities()) do
		if mod.gridToProjectile[grid:GetType()] and grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
			gridCount = gridCount+1
		end
	end
	if data.gridSpawnCooldown > 0 then
		data.gridSpawnCooldown = data.gridSpawnCooldown-1
	else
		if gridCount < 2 then
			for i=1,6 do
				local pos = mod:FindRandomFreePosNoDoors(npc)
				if pos then
					local index = room:GetGridIndex(pos)
					
					if mod.sutureRockSpawns[index] == nil then
						local glowEffect = Isaac.Spawn(1000, 175, 114, pos, Vector.Zero, npc):ToEffect()
						glowEffect.Parent = npc
						glowEffect:GetSprite():Play("Appear", true)
						mod.sutureRockSpawns[index] = {["glow"] = glowEffect, ["index"] = index, ["timer"] = 30, ["npc"] = npc, ["pos"] = pos, ["spawner"] = nil, ["state"] = 0}
					end
				end
			end
			sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 2)
			data.gridSpawnCooldown = 200
		end
	end
	
	if data.state == "Idle" then
		local roomgfx = mod:getCurrentRoomGfx()
		if data.contusion then
			if data.pullTimer > 0 then
				data.pullTimer = data.pullTimer-1
			else
				data.pullTimer = nil
				data.beam:GetData().initialized = true
				data.state = "PullingCont"
				data.contusion.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				data.contusion:GetData().movement = -1
				data.contusion:GetData().pullPrepared = true
				data.contusion.CollisionDamage = 1
				data.movement = 1
			end
			
			if not data.contusion:Exists() then
				data.contusion = nil
			end
		elseif #suckEm > 0 and data.contusionThrowCooldown <= 0 then
			if data.phase1 or data.contusionThrowCooldown <= 0 then
				data.contusion = suckEm[rng:RandomInt(#suckEm)+1]
				local cData = data.contusion:GetData()
				cData.state = "Claimed"
				cData.movement = 1
				cData.pullingSuture = npc
				sprite:Play("TeleStart", true)
				data.pullTimer = 15
				
				local beam = Isaac.Spawn(1000, 175, 0, data.contusion.Position, Vector.Zero, npc):ToEffect()
				beam.Parent = npc
				beam.Target = data.contusion
				beam.Color = Color(0.5, 0, 1, 1, 0, 0, 0)
				beam.DepthOffset = 500
				data.beam = beam
				beam:GetData().sutureBeam = true
			end
		elseif data.teleport then
			if rng:RandomInt(4) == 0 then
				data.state = "Teleport"
				data.subState = "Out"
				data.movement = 1
				data.teleport = nil
			else
				data.teleport = nil
			end
		else
			if data.phase1 then
				data.movement = 0
				mod:spritePlay(sprite, "Idle")
			else
				data.movement = 2
				mod:spritePlay(sprite, "Idle2")
			end
			if (data.phase1 and npc.StateFrame > 120) or (not data.phase1 and npc.StateFrame > 80) then
				if data.phase1 then
					if data.attackLoop == 1 then
						local angle1 = (target.Position-npc.Position):GetAngleDegrees()
						if angle1 < 0 then
							angle1 = angle1+360
						end
					
						local validRocks = {}
						local voidPriority = {}
						for _,grid in ipairs(mod.GetGridEntities()) do
							if mod.gridToProjectile[grid:GetType()] and grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
								local vec = (npc.Position-grid.Position):Resized(40)
								if room:CheckLine(grid.Position+vec, npc.Position, 3) then
									table.insert(validRocks, grid)
									if data.void then
										local angle2 = (grid.Position-npc.Position):GetAngleDegrees()
										if angle2 < 0 then
											angle2 = angle2+360
										end
										local difference = math.abs(angle1 - angle2)
										if difference < 30 or difference > 330 then
											table.insert(voidPriority, grid)
										end
									end
								end
							end
						end
						
						if data.void and #voidPriority > 0 then
							data.chosenRocks = {}
							table.insert(data.chosenRocks, {grid = voidPriority[rng:RandomInt(#voidPriority)+1]})
							data.state = "GrabRock"
							data.movement = 1
							data.subState = "Init"
							data.rockAttack = "Single"
						elseif #validRocks > 0 then
							data.chosenRocks = {}
							table.insert(data.chosenRocks, {grid = validRocks[rng:RandomInt(#validRocks)+1]})
							data.state = "GrabRock"
							data.movement = 1
							data.subState = "Init"
							data.rockAttack = "Single"
						else
							data.attackLoop = 0
						end
					end
					if data.attackLoop == 0 then
						data.state = "Shoot1"
						data.movement = 3
						data.moveSpeed = 3
						data.attackLoop = 1
					end
				elseif data.phase1 == false then
					local state = mod.ChooseNextAttack(data.attackList, rng)
					
					if state == "Bodyslam" then
						data.subState = "Init"
						if #ignoreCooldown == 0 then
							state = mod.ChooseNextAttack(data.attackList, rng)
						end
					end
					if state == "Rockslam" then
						local validRocks = {}
						for _,grid in ipairs(mod.GetGridEntities()) do
							if mod.gridToProjectile[grid:GetType()] and grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
								local vec = (npc.Position-grid.Position):Resized(40)
								table.insert(validRocks, grid)
							end
						end
						
						if #validRocks > 0 then
							data.chosenRocks = {}
							if #validRocks > 3 then
								local numbs = mod:getSeveralDifferentNumbers(3, #validRocks, rng)
								for _,num in ipairs(numbs) do
									table.insert(data.chosenRocks, {grid = validRocks[num]})
								end
							else
								for _,grid in ipairs(validRocks) do
									table.insert(data.chosenRocks, {grid = grid})
								end
							end
							data.state = "GrabRock"
							data.movement = 4
							data.subState = "Init"
							data.rockAttack = "Rockslam"
						else
							state = "TeleportAttack"
						end
					end
					if state == "TeleportAttack" then
						data.subState = "Init"
						data.movement = 1
						sprite:Play("TeleStart", true)
						npc.StateFrame = 0
					end
					
					if state ~= "Rockslam" then
						data.state = state
					end
				end
			end
		end
	elseif data.state == "PullingCont" then
		if sprite:IsFinished("TeleStart") then
			sprite:Play("TeleLoop")
		end
		if not data.contusion or not data.contusion:Exists() then
			data.contusion = nil
			data.state = "Idle"
			data.beam:Remove()
			data.beam = nil
			sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
		else
		
			data.contusion:GetData().movement = -1
			
			if data.contusion.Position:Distance(npc.Position) > 20 then
				if data.contusion.SpriteOffset.Y > -20 and data.contusion.dead then
					data.contusion.SpriteOffset = Vector(0, data.contusion.SpriteOffset.Y-2)
				end
				data.contusion.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				data.contusion.Velocity = mod:Lerp(data.contusion.Velocity, (npc.Position-data.contusion.Position):Resized(20), 0.1)
			else
				data.state = "PickingCont"
				sprite:Play("Pickup", true)
				data.beam:Remove()
				data.beam = nil
				data.contusion:GetData().held = true
				data.bringUp = 1
				npc.StateFrame = 0
				data.movement = 2
				sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
			end
		end
	elseif data.state == "PickingCont" then
		if sprite:IsFinished("Pickup") then
			sprite:Play("PickupIdle")
		end
		if not data.contusion or not data.contusion:Exists() then
			data.contusion = nil
			data.state = "Idle"
		else
			mod:updateToNPCPosition(npc, data.contusion)
			data.contusion.SpriteOffset = Vector(0,0-data.bringUp*12)
			if data.bringUp < 3 then
				data.bringUp = data.bringUp+1
			end
			data.contusion.DepthOffset = 30
			
			if npc.Position:Distance(target.Position) < 220 and not mod:isScareOrConfuse(npc) and npc.StateFrame > 10 then
				data.state = "ThrowCont"
			end
		end
	elseif data.state == "ThrowCont" then
		if sprite:IsFinished("Throw") then
			data.state = "Idle"
			data.movement = 0
			npc.StateFrame = 0
			if not data.phase1 then
				data.contusionThrowCooldown = 140
			end
		elseif sprite:IsEventTriggered("Shoot") then
			local cData = data.contusion:GetData()
			cData.pullingSuture = nil
			cData.held = nil
			cData.state = "Launched"
			--cData.zVel = -1
			cData.launchedEnemyInfo = {zVel = -1, height = -5, accel = 0.1}
			cData.landingInfo = {"LandAnim", "ButIGetKnockedDownAgain", 1, 25, "Chilling", 1}
			cData.justThrown = 160
			cData.targetPos = nil
			cData.movement = -1
			cData.pullPrepared = nil
			data.contusion.Velocity = (target.Position-npc.Position):Resized(18)
			data.contusion = nil
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
		else
			if data.contusion then
				mod:updateToNPCPosition(npc, data.contusion)
			end
			mod:spritePlay(sprite, "Throw")
		end
	elseif data.state == "GrabRock" then
		if data.subState == "Init" then
			for _,entry in pairs(data.chosenRocks) do
				if entry.grid and entry.grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
					local beam = Isaac.Spawn(1000, 175, 0, entry.grid.Position, Vector.Zero, npc):ToEffect()
					beam.Parent = npc
					beam.Color = Color(0.5, 0, 1, 1, 0, 0, 0)
					beam.DepthOffset = 500
					entry.beam = beam
					beam:GetData().sutureBeam = true
				end
			end
			data.pullTimer = 15
			data.subState = "Wait"
		elseif data.subState == "Wait" then
			if (data.pullTimer or 0) > 0 then
				data.pullTimer = data.pullTimer-1
			else
				data.pullTimer = nil
				local targets = false
				for key,entry in pairs(data.chosenRocks) do
					if entry.grid then
						targets = true
						if entry.beam then
							entry.beam:GetData().intialized = true
						end
						local index = entry.grid:GetGridIndex()
						local proj = mod:turnGridtoProjectile(npc, index, Vector.Zero, true)
						if proj then
							proj.FallingSpeed = 0
							proj.FallingAccel = 0
							proj.Height = -25
							entry.proj = proj
							proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
							--proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
							--proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
							entry.beam.Target = proj
						else
							data.state = "Idle"
							data.movement = 0
							npc.StateFrame = 0
						end
					else
						if entry.beam and entry.beam:Exists() then
							entry.beam:Remove()
							sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
						end
					end
				end
				data.subState = data.rockAttack
				if not targets then
					data.state = "Idle"
					data.movement = 0
					npc.StateFrame = 0
				end
			end
		elseif data.subState == "Single" then
			for key,entry in pairs(data.chosenRocks) do
				if not entry.proj or not entry.proj:Exists() then
					if entry.beam then
						entry.beam:Remove()
						sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
					end
					data.chosenRocks[key] = nil
					data.state = "Idle"
					data.movement = 0
					npc.StateFrame = 0
				else
					entry.proj.FallingSpeed = 0
					entry.proj.FallingAccel = -0.05
					if entry.proj.Position:Distance(npc.Position) > 20 then
						entry.proj.Velocity = mod:Lerp(entry.proj.Velocity, (npc.Position-entry.proj.Position):Resized(18), 0.1)
					else
						data.subState = "PickUp"
						sprite:Play("Pickup", true)
						entry.beam:Remove()
						entry.proj:GetData().held = true
						data.bringUp = 1
						npc.StateFrame = 0
						data.movement = 2
						entry.proj.Velocity = Vector.Zero
						entry.proj.Position = npc.Position
						data.proj = entry.proj
						sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
						npc:PlaySound(mod.Sounds.CSutureGrunt, 0.7, 0, false, 1)
					end
				end
			end
			data.attackLoop = 0
		elseif data.subState == "PickUp" then
			if sprite:IsFinished("Pickup") then
				sprite:Play("PickupIdle")
			end
			if not data.proj or not data.proj:Exists() then
				data.proj = nil
				data.state = "Idle"
				npc.StateFrame = 0
			else
				mod:updateToNPCPosition(npc, data.proj)
				data.proj.SpriteOffset = Vector(0,0-data.bringUp*9)
				if data.bringUp < 3 then
					data.bringUp = data.bringUp+1
				end
				data.proj.DepthOffset = 30
				data.proj.FallingSpeed = 0
				data.proj.FallingAccel = 0
				
				if npc.Position:Distance(target.Position) < 300 and not mod:isScareOrConfuse(npc) and npc.StateFrame > 10 then
					data.subState  = "ThrowRock"
				end
			end
		elseif data.subState == "ThrowRock" then
			if sprite:IsFinished("Throw") then
				data.state = "Idle"
				data.movement = 0
				npc.StateFrame = 0
				if not data.contusionThrowCooldown then
					data.contusionThrowCooldown = 20
				end
			elseif sprite:IsEventTriggered("Shoot") then
				if data.proj:HasProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE) then
					data.proj:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				end
				data.proj.Velocity = (target.Position-npc.Position):Resized(11)+npc.Velocity*1.5
				data.proj.FallingAccel = 0.45
				data.proj.FallingSpeed = 6
				data.proj.Height = -60
				data.proj.SpriteOffset = Vector.Zero
				data.proj = nil
				sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
			else
				if data.proj then
					data.proj.FallingSpeed = 0
					data.proj.FallingAccel = 0
					mod:updateToNPCPosition(npc, data.proj)
				end
				mod:spritePlay(sprite, "Throw")
			end
		elseif data.subState == "Rockslam" then
			data.movement = 4
			local rocks = false
			for key,entry in pairs(data.chosenRocks) do
				if not entry.proj or not entry.proj:Exists() then
					if entry.beam then
						entry.beam:Remove()
						sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
					end
					data.chosenRocks[key] = nil
				else
					rocks = true
					entry.proj.FallingSpeed = -20-rng:RandomInt(20)
					entry.proj.FallingAccel = 1.3
					entry.proj.Velocity = (target.Position-entry.proj.Position)*0.04
					entry.proj:GetData().projType = "sutureShrapnel"
					entry.proj:GetData().rng = rng
					data.chosenRocks[key] = nil
				end
			end
			if rocks == false then
				data.state = "Idle"
				data.movement = 2
				npc.StateFrame = 0
				if not data.contusionThrowCooldown then
					data.contusionThrowCooldown = 20
				end
			end
		--[[elseif data.subState == "RockSlamming" then
			if not data.proj or not data.proj:Exists() then
				if data.beam then
					data.beam:Remove()
				end
				data.state = "Idle"
				npc.StateFrame = 0
				data.movement = 2
			else
				data.proj.FallingSpeed = -30
				data.proj.FallingAccel = 1.3
				--data.proj.Height = -300*math.sin(math.rad(9*npc.StateFrame))
				data.proj.Velocity = (data.targetPos-data.proj.Position)*0.04
				data.proj = nil
				data.beam = nil
				data.state = "Idle"
			end]]
		end
	elseif data.state == "Bodyslam" then
		if data.subState == "Init" then
			if #ignoreCooldown > 0 then
				data.contusion = ignoreCooldown[rng:RandomInt(#ignoreCooldown)+1]
				local cData = data.contusion:GetData()
				cData.state = "Claimed"
				cData.movement = 1
				cData.pullingSuture = npc
				sprite:Play("TeleStart", true)
				data.pullTimer = 15
				
				local beam = Isaac.Spawn(1000, 175, 0, data.contusion.Position, Vector.Zero, npc):ToEffect()
				beam.Parent = npc
				beam.Target = data.contusion
				beam.Color = Color(0.5, 0, 1, 1, 0, 0, 0)
				beam.DepthOffset = 500
				data.beam = beam
				beam:GetData().sutureBeam = true
				
				data.subState = "Wait"
			else
				data.state = "Idle"
			end
		elseif data.subState == "Wait" then
			if data.pullTimer > 0 then
				data.pullTimer = data.pullTimer-1
			else
				data.pullTimer = nil
				data.beam:GetData().initialized = true
				data.contusion.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				data.contusion:GetData().movement = -1
				data.contusion:GetData().pullPrepared = true
				data.contusion.CollisionDamage = 1
				data.movement = 4
				data.subState = "Preparing"
				npc.StateFrame = 0
				local customFunc = function(cont, tab)
					if npc.StateFrame < data.riseTimer then
						if cont.PositionOffset.Y > -100 then
							cont.PositionOffset = Vector(0, cont.PositionOffset.Y-data.riseUp)
							tab.height = cont.PositionOffset.Y
						end
					elseif data.slamDown then
						if cont.PositionOffset.Y > -40 then
							cont.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						end
						if cont.PositionOffset.Y < 0 then
							tab.height = tab.height or npc.PositionOffset.Y
							local offset = tab.height+tab.zVel+tab.accel/2
							cont.PositionOffset = Vector(0, offset)
							tab.height = offset
							tab.zVel = tab.zVel + tab.accel
						else
							sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
							local poof = Isaac.Spawn(1000, 16, 3, cont.Position, Vector.Zero, npc):ToEffect()
							local final = false
							if data.void then
								if data.slamCount == 0 then --Circle
									npc:FireProjectiles(cont.Position, Vector(6, 10), 9, ProjectileParams())
									data.slamDown = nil
									npc.StateFrame = 0
								elseif data.slamCount == 1 then --Triangle
									local vel = 5
									local rangle = rng:RandomInt(360)
									local dist = math.sqrt(5)*vel-vel/2
									for i=120,360,120 do
										for j=-dist,dist, (dist*2)/4 do
											local size = math.sqrt(j^2+vel^2)
											npc:FireProjectiles(cont.Position, Vector(j,vel):Rotated(i+rangle):Resized(size), 0, ProjectileParams())
										end
									end
									data.slamDown = nil
									npc.StateFrame = 0
								elseif data.slamCount == 2 then --Square
									local vel = 5
									local rangle = rng:RandomInt(360)
									for i=90,360,90 do
										for j=-vel,vel-1, vel/2 do
											local size = math.sqrt(j^2+vel^2)
											npc:FireProjectiles(cont.Position, Vector(j,vel):Rotated(i+rangle):Resized(size), 0, ProjectileParams())
										end
									end
									final = true
								end
							else
								if data.slamCount < 2 then
									data.slamDown = nil
									npc.StateFrame = 0
									npc:FireProjectiles(cont.Position, Vector(7, 0), 8, ProjectileParams())
								else
									npc:FireProjectiles(cont.Position, Vector(7, 0), 8, ProjectileParams())
									final = true
								end
							end
							data.slamCount = data.slamCount+1
							if final == true then
								data.subState = "Finalize"
								mod:spritePlay(sprite, "GenericFire")
								if data.beam then
									data.beam:Remove()
									sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
								end
								cont:GetSprite():Play("ButIGetKnockedDownAgain", true)
								local cData = cont:GetData()
								cData.pullingSuture = nil
								cData.held = nil
								cData.targetPos = nil
								cData.movement = 1
								cData.state = "Dead"
								cont.PositionOffset = Vector.Zero
								cont.SpriteOffset = Vector.Zero
								cont:GetData().launchedEnemyInfo = nil
								cData.pullPrepared = nil
								data.contusion = nil
							else
								cont:GetSprite():Play("ButIGetKnockedDownAgain", true)
								cont.PositionOffset = Vector.Zero
								tab.zVel = -10+data.riseUp
								tab.accel = tab.accel+0.5
								if data.riseTimer == 40 then
									data.riseTimer = 10
								else
									data.riseTimer = 8
								end
								data.riseUp = data.riseUp+3
								--tab.height = -data.riseTimer*data.riseUp
							end
						end
					end
				end
				data.contusion:GetData().launchedEnemyInfo = {zVel = -10, accel = 1, height = -100, custom = customFunc, pos = true}
				data.slamCount = 0
				data.riseTimer = 40
				data.riseUp = 2
			end
			
			if not data.contusion:Exists() then
				data.contusion = nil
				data.state = "Idle"
			end
		elseif data.subState == "Preparing" then
			if sprite:IsFinished("TeleStart") then
				sprite:Play("TeleLoop")
			end
			if not data.contusion or not data.contusion:Exists() then
				data.contusion = nil
				data.state = "Idle"
				data.beam:Remove()
				data.beam = nil
				sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
			else
				data.contusion:GetData().movement = -1
				
				if npc.StateFrame < data.riseTimer then
					data.contusion.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					data.contusion.Velocity = mod:Lerp(data.contusion.Velocity, (target.Position-data.contusion.Position):Resized(9.5), 0.2)
				elseif not data.slamDown then
					data.contusion.Velocity = mod:Lerp(data.contusion.Velocity, Vector.Zero, 0.22)
					data.slamDown = true
				end
			end
		elseif data.subState == "Finalize" then
			if sprite:IsFinished("GenericFire") then
				data.state = "Idle"
				mod:spritePlay(sprite, "Idle")
				npc.StateFrame = 0
				data.movement = 0
				if not data.contusionThrowCooldown then
					data.contusionThrowCooldown = 20
				end
			end
		end
	elseif data.state == "Shoot1" then
		if sprite:IsFinished("Shoot") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.movement = 0
			if not data.contusionThrowCooldown then
				data.contusionThrowCooldown = 20
			end
		elseif sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
			params.Scale = 1.8
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(12)+npc.Velocity, 0, params)
			params.Scale = 0.75
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(7)+npc.Velocity, 0, params)
			npc:PlaySound(mod.Sounds.CSutureShoot, 1, 0, false, 1)
			local poof = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc):ToEffect()
			local offset = 15
			if sprite.FlipX then
				offset = -15
			end
			poof.SpriteOffset = Vector(offset,-18)
			poof.DepthOffset = 33
			poof.SpriteScale = Vector(0.75,0.75)
			poof.Color = mod.ColorMausPurple
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif data.state == "Shoot2" then
		if sprite:IsFinished("Shoot") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.movement = 0
			if not data.contusionThrowCooldown then
				data.contusionThrowCooldown = 20
			end
		elseif sprite:IsEventTriggered("Shoot") then
			--[[local params = ProjectileParams()
			for i=-30,30,60 do
				params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
				params.Scale = 1.8
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(8):Rotated(i)+npc.Velocity, 0, params)
				params.Scale = 0.75
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(4):Rotated(i)+npc.Velocity, 0, params)
			end]]
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
			for i=12,6,-2 do
				params.Scale = i/7
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(i):Rotated(rng:RandomInt(4)-2)+npc.Velocity*0.5, 0, params)
			end
			npc:PlaySound(mod.Sounds.CSutureShoot, 1, 0, false, 1)
			local poof = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc):ToEffect()
			local offset = 15
			if sprite.FlipX then
				offset = -15
			end
			poof.SpriteOffset = Vector(offset,-18)
			poof.DepthOffset = 33
			poof.SpriteScale = Vector(0.75,0.75)
			poof.Color = mod.ColorMausPurple
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif data.state == "Teleport" then
		data.movement = 1
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		if data.subState == "In" then
			if sprite:IsFinished("WarpIn") then
				data.state = "Idle"
				data.teleportCooldown = 80
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			else
				mod:spritePlay(sprite, "WarpIn")
			end
		elseif data.subState == "Out" then
			if sprite:IsFinished("WarpOut") then
				npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL2, 0.8, 0, false, 1.25)
				npc.Position = mod:FindRandomFreePos(npc, 200, false, true)
				data.subState = "In"
			else
				mod:spritePlay(sprite, "WarpOut")
			end
		end
	elseif data.state == "TeleportAttack" then
		data.movement = 1
		if data.subState == "Init" then
			if sprite:IsFinished("TeleStart") then
				sprite:Play("TeleLoop", true)
			elseif npc.StateFrame > 10 then
				data.subState = "Out"
				npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL2, 0.8, 0, false, 1.25)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		elseif data.subState == "In" then
			if sprite:IsFinished("WarpIn") then
				data.state = "Idle"
				npc.StateFrame = 0
				npc.Visible = true
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			elseif sprite:IsEventTriggered("WarpIn") then
				local explosion = Isaac.Spawn(1000, 1, 0, npc.Position, Vector.Zero, npc):ToEffect()
				explosion.Color = mod.ColorMausPurple
				npc:PlaySound(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 1, 0, false, 1)
				local params = ProjectileParams()
				params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
				npc:FireProjectiles(npc.Position, Vector(8, 0), 6, params)
				for _,grid in ipairs(mod.GetGridEntities()) do
					if grid.Position:Distance(npc.Position) < 65 then
						grid:Destroy()
					end
				end
				data.fireRing = {dist = 20, count = 0, angle = rng:RandomInt(360), pos = npc.Position}
			else
				mod:spritePlay(sprite, "WarpIn")
			end
		elseif data.subState == "Out" then
			if sprite:IsFinished("WarpOut") then
				data.subState = "Waiting"
				npc.Visible = false
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "WarpOut")
			end
		elseif data.subState == "Waiting" then
			if npc.StateFrame > 35 then
				npc.Position = data.marker.Position
				data.subState = "In"
				data.marker:Remove()
				data.marker = nil
				npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL2, 0.8, 0, false, 1)
				npc:PlaySound(SoundEffect.SOUND_FLAME_BURST, 0.65, 0, false, 0.7)
			elseif npc.StateFrame > 10 and not data.marker then
				local pos = mod:FindClosestValidPosition(npc, target, 60, 1000, 0)
				local glowEffect = Isaac.Spawn(1000, 175, 114, pos, Vector.Zero, npc):ToEffect()
				glowEffect.Parent = glowEffect
				glowEffect:GetSprite():Play("Appear", true)
				data.marker = glowEffect
				npc:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 2)
			else
				if data.marker then
					if data.marker:GetSprite():IsFinished("Appear") then
						data.marker:GetSprite():Play("Idle", true)
					end
				end
			end
		end
	elseif data.state == "Dying" then
		for key, entry in pairs(mod.sutureRockSpawns) do
			if entry.glow then
				entry.glow:Remove()
			end
			if entry.spawner then
				entry.spawner:Remove()
			end
			mod.sutureRockSpawns[key] = nil
		end
	
		local room = game:GetRoom()
		if sprite:IsEventTriggered("BloodStart") and not data.madethedeaththings then
			for _,grid in ipairs(mod.GetGridEntities()) do
				if mod.gridToProjectile[grid:GetType()] then
					if grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
						local beam = Isaac.Spawn(1000, 175, 0, grid.Position, Vector.Zero, npc):ToEffect()
						beam.Parent = npc
						beam.Color = Color(0.5, 0, 1, 1, 0, 0, 0)
						beam:GetData().sutureBeam = true
					end
				end
			end
			data.madethedeaththings = true
		elseif sprite:IsEventTriggered("Explosion") and not npc:GetData().wipedGrids then
			local rng = npc:GetDropRNG()
			local target = npc:GetPlayerTarget()
			npc:GetData().wipedGrids = true
			for _,grid in ipairs(mod.GetGridEntities()) do
				if mod.gridToProjectile[grid:GetType()] then
					if grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
						local index = grid:GetGridIndex()
						mod.scheduleForUpdate(function()
							local proj = mod:turnGridtoProjectile(npc, index, (target.Position-room:GetGridPosition(index)):Resized(2), true)
							if proj then
								proj.FallingSpeed = -15
								proj.FallingAccel = 0.8
							end
						end, rng:RandomInt(5))
					end
				end
			end
			npc:Kill()
		else
			mod:spritePlay(sprite, "DeathAnim")
		end
		
		if sprite:IsEventTriggered("Explosion") then
			npc:BloodExplode()
		end
		if sprite:IsEventTriggered("BloodStart") then
			data.bleeding = true
		end
		if sprite:IsEventTriggered("BloodEnd") then
			data.bleeding = false
		end
		if data.bleeding then
			if npc.FrameCount % 4 == 0 then
				local blood = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				blood.Color = npc.SplatColor
				blood.SplatColor = npc.SplatColor
				blood:Update()

				local bloo2 = Isaac.Spawn(1000, 2, 160, npc.Position, RandomVector()*3, npc):ToEffect();
				bloo2.Color = npc.SplatColor
				bloo2.SplatColor = npc.SplatColor
				bloo2.SpriteScale = Vector(1,1)
				bloo2.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
				bloo2:Update()

				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			end
		end
	end
	
	if data.fireRing then
		local count = 120
		if data.void then
			count = 200
		end
		if data.fireRing.count < count then
			data.fireRing.angle = data.fireRing.angle+5
			data.fireRing.count = data.fireRing.count+1
			if npc.FrameCount % 3 == 0 then
				if data.void then
					for i=90,360,90 do
						local jet = Isaac.Spawn(1000, EffectVariant.FIRE_JET, 1, data.fireRing.pos+Vector(data.fireRing.dist, 0):Rotated(data.fireRing.angle+i), Vector.Zero, npc):ToEffect()
						jet.Parent = npc
						jet:GetData().corruptedSutureJet = true
						jet:GetData().keepQuiet = true
					end
				else
					for i=90,360,120 do
						local jet = Isaac.Spawn(1000, EffectVariant.FIRE_JET, 1, data.fireRing.pos+Vector(data.fireRing.dist, 0):Rotated(data.fireRing.angle+i), Vector.Zero, npc):ToEffect()
						jet.Parent = npc
						jet:GetData().corruptedSutureJet = true
						jet:GetData().keepQuiet = true
					end
				end
			end
			data.fireRing.dist = data.fireRing.dist+3
		else
			data.fireRing = nil
		end
	end
	
	data.teleport = false
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,e)
	local data = e:GetData()
	if data.keepQuiet then
		sfx:Stop(SoundEffect.SOUND_CANDLE_LIGHT)
	end
end, EffectVariant.FIRE_JET)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,e)
	local data = e:GetData()
	if data.sutureBeam then
		if e.SubType == 0 then
			sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0.2, 1)
		end
		if data.initialized then
			if (not e.Target or not e.Target:Exists()) or (not e.Parent or not e.Parent:Exists()) then
				sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
				e:Remove()
			end
		else
			if not e.Parent or not e.Parent:Exists() or e.FrameCount > 50 then
				sfx:SetAmbientSound(mod.Sounds.CSutureTel, 0, 1)
				e:Remove()
			end
		end
	end
end, 175)

function mod:sutureRockSpawn(entry)
	if entry.state == 0 then
		if entry.timer > 0 then
			entry.timer = entry.timer-1
			if entry.glow:GetSprite():IsFinished("Appear") then
				entry.glow:GetSprite():Play("Idle", true)
			end
		else
			local rockSpawner = Isaac.Spawn(1000, 177, 1, entry.pos, Vector.Zero, nil):ToEffect()
			rockSpawner.Color = Color(1,1,1,1,0.35,0,0.35)
			entry.spawner = rockSpawner
			entry.state = 1
			if not sfx:IsPlaying(SoundEffect.SOUND_REVERSE_EXPLOSION) then
				sfx:Play(SoundEffect.SOUND_REVERSE_EXPLOSION)
			end
		end
	elseif entry.state == 1 then
		if not entry.spawner:Exists() then
			local grid = game:GetRoom():GetGridEntity(entry.index)
			if grid and (grid:GetType() == GridEntityType.GRID_ROCKT or grid:GetType() == GridEntityType.GRID_ROCK_ALT) then
				grid:SetType(GridEntityType.GRID_ROCK)
				grid:Init(game:GetRoom():GetSpawnSeed())
			end
			
			if grid then
				entry.state = 2
				entry.glow:GetSprite():Play("Disappear", true)
				mod:makeRockForRoomOnly(entry.index)
			else
				entry.glow:Remove()
				mod.sutureRockSpawns[entry.index] = nil
			end
			entry.timer = 20
		end
	elseif entry.state == 2 then
		local grid = game:GetRoom():GetGridEntity(entry.index)
		if not grid then
			entry.glow:Remove()
			mod.sutureRockSpawns[entry.index] = nil
		elseif entry.timer > 0 then
			local sprite = grid:GetSprite()
			sprite.Color = Color(1,1,1,1,entry.timer*12/255,0,entry.timer*12/255)
			entry.timer = entry.timer-1
		else
			grid:GetSprite().Color = Color(1,1,1,1,0,0,0)
			entry.glow:Remove()
			mod.sutureRockSpawns[entry.index] = nil
		end
	end
	if not entry.npc or not entry.npc:Exists() then
		if entry.glow then
			entry.glow:Remove()
		end
		if entry.spawner then
			entry.spawner:Remove()
		end
		mod.sutureRockSpawns[entry.index] = nil
	end
end

--I can't believe I'm bringing this over from the penny mod
mod.availableDoors = {
	[1] = {0,1,2,3},
	[2] = {0,2},
	[3] = {1,3},
	[4] = {0,1,2,3,4,6},
	[5] = {0, 2},
	[6] = {0,1,2,3,5,7},
	[7] = {1,3},
	[8] = {0,1,2,3,4,5,6,7},
	[9] = {0,1,2,3,4,5,6,7},
	[10] = {0,1,2,3,4,5,6,7},
	[11] = {0,1,2,3,4,5,6,7},
	[12] = {0,1,2,3,4,5,6,7},
}

function mod:FindRandomFreePosNoDoors(npc)
local radius = 0
local validPositions = {}
local validPositionsFar = {}
local validPositionsNear = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollisionAtPos(gridpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(gridpos, 0) then
			local door = false
			local doors = mod.availableDoors[room:GetRoomShape()]
			local nilDoors = {}
			for _,checkDoor in ipairs(doors) do
				local checkedDoor = room:GetDoorSlotPosition(checkDoor)
				if checkedDoor:Distance(gridpos) < 50 then
					door = true
				end
			end
			if door == false then
				table.insert(validPositions, gridpos)
			end
		end
	end
	if #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return nil
	end
end

function mod.sutureShrapnelProj(v, d)
	if v:IsDead() then
		if d.projType == "sutureShrapnel" then
			if v:HasProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE) then
				v:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
			end
			
			local rng = d.rng
			local rangle = rng:RandomInt(360)
			for i=90,360,120 do
				local rock = Isaac.Spawn(9, 9, 0, v.Position, Vector(0, 6):Rotated(i+rangle), v):ToProjectile()
				rock.FallingSpeed = -20
				rock.FallingAccel = 1.1
				rock:GetData().projType = "sutureShrapnelShrapnel"
				rock.ProjectileFlags = v.ProjectileFlags
			end
		elseif d.projType == "sutureShrapnelShrapnel" then
			for i=-45,45,90 do
				local rock = Isaac.Spawn(9, 9, 0, v.Position, v.Velocity:Rotated(i), v):ToProjectile()
				rock.FallingSpeed = -12
				rock.FallingAccel = 1.1
				rock.Scale = 0.75
				rock.ProjectileFlags = v.ProjectileFlags
			end
		elseif d.projType == "monstroShrapnel" then
			if d.detail == "falling" then
				for i=90,360,90 do
					local rock = Isaac.Spawn(9, 8, 0, v.Position, Vector(8,0):Rotated(i), v):ToProjectile()
					local pSprite = rock:GetSprite()
					pSprite:Load("gfx/009.009_rock projectile.anm2", true)
					pSprite:Play("Rotate2", true)
					pSprite:LoadGraphics()
					rock:GetData().makeSplat = 145
					rock:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.1, math.random(8,12)/10}
					rock:GetData().toothParticles = mod.ColorRockGibs
				end
			elseif d.detail == "random" then
				local rng = v:GetDropRNG()
				for i=1,8 do
					local rock = Isaac.Spawn(9, 8, 0, v.Position, v.Velocity:Resized(mod:getRoll(60, 120, rng)/10):Rotated(mod:getRoll(-10, 10, rng)), v):ToProjectile()
					rock.FallingSpeed = -mod:getRoll(100, 200, rng)/10
					rock.FallingAccel = mod:getRoll(100, 125, rng)/100
					rock.Scale = mod:getRoll(50, 80, rng)/100
					rock.ProjectileFlags = v.ProjectileFlags
					local pSprite = rock:GetSprite()
					pSprite:Load("gfx/009.009_rock projectile.anm2", true)
					pSprite:Play("Rotate2", true)
					pSprite:LoadGraphics()
					rock:GetData().makeSplat = 145
					rock:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.1, math.random(8,12)/10}
					rock:GetData().toothParticles = mod.ColorRockGibs
				end
			end
			local cloud = Isaac.Spawn(1000, 59, 0, v.Position, RandomVector(), v):ToEffect()
			cloud.Parent = cloud
			cloud:SetTimeout(20)
			cloud.SpriteOffset = Vector(0, v.Height)
		end
	end
end

function mod.corruptedSutureDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().dead = true
	end
	mod.genericCustomDeathAnim(npc, "DeadAnim", true, onCustomDeath, false, false)
end