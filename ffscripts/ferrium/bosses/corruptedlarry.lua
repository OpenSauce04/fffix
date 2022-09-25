local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function getNewTarget(npc)
	local position = npc.Position
	local room = game:GetRoom()
	local data = npc:GetData()
	local rng = npc:GetDropRNG()
	
	local i = 0
	repeat
		position = Isaac.GetFreeNearPosition(room:GetGridPosition(room:GetRandomTileIndex(rng:RandomInt(5000)+1)), 40)
		i = i + 1
	until i >= 32 or (npc.Pathfinder:HasPathToPos(position, false) and position:Distance(npc.Position) >= 80)

	local failed = i >= 32
	if failed then
		position = npc.Position
	end

	return position, failed
end

local function adjustLarryChildrenData(npc, tag, result)
	if npc.Child then
		local child = npc.Child:ToNPC()
		while child do
			local data = child:GetData()
			data[tag] = result
			
			if child.Child and child.Child:Exists() then
				child = child.Child:ToNPC()
			else
				child = nil
			end
		end
	end
end

local function checkGridCollision2(npc)
	local room = game:GetRoom()
	local grid = room:GetGridEntityFromPos(npc.Position+npc.Velocity:Resized(40))
	if grid then
		if npc.Size+20 > grid.Position:Distance(npc.Position) and (grid.CollisionClass > GridCollisionClass.COLLISION_NONE or grid:GetType() == GridEntityType.GRID_DOOR) then
			return true
		else
			return false
		end
	else 
		return false
	end
end

function mod:corruptedLarryAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local room = game:GetRoom()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		data.init = true
		if HPBars then
			HPBars:createNewBossBar(npc)
		end
		
		if data.warpzoneSpawned then
			data.state = "Jump"
			data.subState = "Jumping"
			data.launchedEnemyInfo = {zVel = -5, collision = -15, height = -10}
			data.movement = -1
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		else
			data.state = "Idle"
			data.movement = 0
		end
		if npc.SubType == 1 then
			data.void = true
		end
		data.chaseTimer = 0
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	else
		npc.StateFrame = npc.StateFrame+1
		if data.cardinalCooldown and data.cardinalCooldown > 0 then
			data.cardinalCooldown = data.cardinalCooldown-1
		else
			data.cardinalCooldown = nil
		end
		data.chaseTimer = data.chaseTimer+1
	end
	
	mod.NegateKnockoutDrops(npc)
		
	if npc.I1 == 0 then
		if sprite.FlipX then
			sprite.FlipX = false
		end
	
		--As with Unshornz, thank you Xalum for all the Ossularry stuff.
		if not npc.Child and not data.corruptedHead then
			data.corruptedHead = true
			
			local curr = npc
			while curr do
				local did
				local closest
				local dist = 60

				for _, ent in pairs (Isaac.FindByType(npc.Type, npc.Variant, -1)) do
					if ent.Position:Distance(curr.Position) < dist and not ent:GetData().corruptedHead and ent:ToNPC().I1 == 0 then
						closest = ent
						dist = ent.Position:Distance(curr.Position)
					end
				end

				if closest then
					did = true
					
					local cData = closest:GetData()
					curr.Child = closest
					closest.Parent = curr
					closest:ToNPC().I1 = curr:ToNPC().I1+1
					cData.ultraParent = npc
					if data.void then
						cData.void = true
					end
					curr.Position = npc.Position
					curr = closest
				end

				if not did then
					curr = nil 
				end
			end
		end
		
		if data.movement == 0 then
			local food
			for _,gush in ipairs(Isaac.FindByType(mod.FFID.Boss, mod.FF.PaleGusher.Var, -1, false, false)) do
				if gush.Position:Distance(npc.Position) < 140 and gush.FrameCount > 40 then
					food = gush
				end
			end
		
			data.targetpos = data.targetpos or getNewTarget(npc)
			if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
				data.targetpos = data.targetpos or getNewTarget(npc)
				if mod:isScare(npc) then
					if npc.Position:Distance(data.targetpos) < 10 or not npc.Pathfinder:HasPathToPos(data.targetpos, false) then
						data.targetpos = mod:FindClosestValidPosition(npc, target, 1, 500, 0)
					end
				--[[elseif data.chaseTimer > 85 and rng:RandomInt(10) == 0 and data.state == "Idle" then
					data.targetpos = target.Position
					data.currentFrame = 1
					data.state = "Jump"
					data.movement = 1
					data.subState = "Prepare"]]
				elseif (math.abs(npc.Position.X-target.Position.X) < 40 or math.abs(npc.Position.Y-target.Position.Y) < 40) and room:CheckLine(npc.Position, target.Position, 0, 0, false, false) and (not data.cardinalCooldown) and data.state ~= "Shoot" and not mod:isScareOrConfuse(npc) then
					local pointedAngle = mod:GetAngleDifference(target.Position-npc.Position, npc.Velocity)
					local angle = math.floor((mod:GetAngleDegreesButGood(target.Position-npc.Position)+45)/90)
					data.chargeDir = Vector(8,0):Rotated(90*angle)
					if data.state == "Held" and (pointedAngle < 15 or pointedAngle > 345) then
						if not data.chewing then
							data.state = "Shoot"
							data.currentFrame = 1
						end
					elseif data.state == "Idle" then
						data.state = "Charge"
						local angle = math.floor((mod:GetAngleDegreesButGood(target.Position-npc.Position)+45)/90)
						data.chargeDir = Vector(11,0):Rotated(90*angle)
						data.movement = -1
						npc:PlaySound(mod.Sounds.CLarryCharge, 0.55, 0, false, 1)
					end
				elseif food and data.state == "Idle" then
					data.targetpos = mod.XalumAlignPositionToGrid(food.Position)
					if food.Position:Distance(npc.Position) < 50 then
						food:Kill()
						data.chewing = true
						data.state = "Held"
						npc:PlaySound(mod.Sounds.CLarryGulp, 0.95, 0, false, 1)
						data.currentFrame = 1
						npc.StateFrame = 0
					end
				elseif npc.Position:Distance(data.targetpos) < 10 or not npc.Pathfinder:HasPathToPos(data.targetpos, false) then
					data.targetpos = getNewTarget(npc)
				end
				mod.XalumGridPathfind(npc, data.targetpos, 6.3)
			else
				local gridPosition = mod.XalumAlignPositionToGrid(npc.Position)
				local targetVelocity = (npc.Position - gridPosition):Resized(9)
				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.3)
			end
		elseif data.movement == 1 then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		end
	
		if data.state == "Idle" then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					mod:spritePlay(sprite, "WalkHeadRight")
				else
					mod:spritePlay(sprite, "WalkHeadLeft")
				end
			else
				if npc.Velocity.Y > 0 then
					mod:spritePlay(sprite, "WalkHeadDown")
				else
					mod:spritePlay(sprite, "WalkHeadUp")
				end
			end
		elseif data.state == "Jump" then
			if data.subState == "Prepare" then
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					if npc.Velocity.X > 0 then
						sprite:SetFrame("JumpRight", data.currentFrame)
					else
						sprite:SetFrame("JumpLeft", data.currentFrame)
					end
				else
					if npc.Velocity.Y > 0 then
						sprite:SetFrame("JumpDown", data.currentFrame)
					else
						sprite:SetFrame("JumpUp", data.currentFrame)
					end
				end
				data.currentFrame = data.currentFrame+1
			
				if sprite:IsEventTriggered("Sound") then
					npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_B, 1, 0, false, 1)
				elseif sprite:IsEventTriggered("Shoot") then
					data.subState = "Jumping"
					data.launchedEnemyInfo = {zVel = -5, collision = -15}
					data.movement = -1
					local distance = npc.Position:Distance(target.Position)
					data.jumpTarget = target.Position
					data.jumpVel = distance*0.075
					--adjustLarryChildrenData(npc, "launchedEnemyInfo", {zVel = -4.6, collision = -15, accel = 0.15})
				end
			elseif data.subState == "Jumping" then
				if data.jumpTarget then
					if npc.Position:Distance(data.jumpTarget) > 20 then
						local targVel = (data.jumpTarget-npc.Position):Resized((data.jumpVel or 0))
						npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.2)
					else
						npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
					end
				end
				if data.launchedEnemyLanded then
					npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 0.75)
					data.state = "Idle"
					data.movement = 0
					data.cardinalCooldown = 30
					data.chaseTimer = 0
					data.launchedEnemyLanded = nil
				end
				
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					if npc.Velocity.X > 0 then
						mod:spritePlay(sprite, "WalkHeadRight")
					else
						mod:spritePlay(sprite, "WalkHeadLeft")
					end
				else
					if npc.Velocity.Y > 0 then
						mod:spritePlay(sprite, "WalkHeadDown")
					else
						mod:spritePlay(sprite, "WalkHeadUp")
					end
				end
			end
		elseif data.state == "Held" then
			if data.chewing then
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					if npc.Velocity.X > 0 then
						sprite:SetFrame("ChompRight", data.currentFrame)
					else
						sprite:SetFrame("ChompLeft", data.currentFrame)
					end
				else
					if npc.Velocity.Y > 0 then
						sprite:SetFrame("ChompDown", data.currentFrame)
					else
						sprite:SetFrame("ChompUp", data.currentFrame)
					end
				end
				data.currentFrame = data.currentFrame+1
			
				if data.currentFrame > 11 then
					data.chewing = nil
				elseif sprite:IsEventTriggered("Sound") then
					npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
				end
			else
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					if npc.Velocity.X > 0 then
						mod:spritePlay(sprite, "HoldHeadRight")
					else
						mod:spritePlay(sprite, "HoldHeadLeft")
					end
				else
					if npc.Velocity.Y > 0 then
						mod:spritePlay(sprite, "HoldHeadDown")
					else
						mod:spritePlay(sprite, "HoldHeadUp")
					end
				end
			end
			
			if npc.FrameCount % 7 == 0 and npc.StateFrame < 30 then
				local creep
				if mod:isFriend(npc) then
					creep = Isaac.Spawn(1000, 46, 0, npc.Position+mod:shuntedPosition(5, rng), Vector.Zero, npc):ToEffect()
				else
					creep = Isaac.Spawn(1000, 22, 0, npc.Position+mod:shuntedPosition(5, rng), Vector.Zero, npc):ToEffect()
				end
				creep:SetTimeout(95)
				local size = (60+rng:RandomInt(40))/100
				creep.SpriteScale = Vector(size, size)
				creep:Update()
			end
		elseif data.state == "Charge" then
			npc.Velocity = mod:Lerp(npc.Velocity, data.chargeDir, 0.3)
			if checkGridCollision2(npc) then
				data.state = "Idle"
				data.cardinalCooldown = 75
				data.chaseTimer = 0
				data.movement = 0
			end
			
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					mod:spritePlay(sprite, "ChargeRight")
				else
					mod:spritePlay(sprite, "ChargeLeft")
				end
			else
				if npc.Velocity.Y > 0 then
					mod:spritePlay(sprite, "ChargeDown")
				else
					mod:spritePlay(sprite, "ChargeUp")
				end
			end
			
			for _,gush in ipairs(Isaac.FindByType(mod.FFID.Boss, mod.FF.PaleGusher.Var, -1, false, false)) do
				if gush.Position:Distance(npc.Position) < 50 then
					gush:Kill()
					local creep
					if mod:isFriend(npc) then
						creep = Isaac.Spawn(1000, 46, 0, gush.Position, Vector.Zero, npc):ToEffect()
					else
						creep = Isaac.Spawn(1000, 22, 0, gush.Position, Vector.Zero, npc):ToEffect()
					end
					creep:SetTimeout(120)
					creep.SpriteScale = Vector(1.4, 1.4)
					creep:Update()
					for i=90,270,180 do
						if data.void then
							for j=-30,30,30 do
								npc:FireProjectiles(npc.Position, data.chargeDir:Rotated(i+j):Resized(6), 0, ProjectileParams())
							end
						else
							for j=-10,10,30 do
								npc:FireProjectiles(npc.Position, data.chargeDir:Rotated(i+j):Resized(6), 0, ProjectileParams())
							end
						end
					end
				end
			end
		elseif data.state == "Shoot" then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					sprite:SetFrame("FireRight", data.currentFrame)
				else
					sprite:SetFrame("FireLeft", data.currentFrame)
				end
			else
				if npc.Velocity.Y > 0 then
					sprite:SetFrame("FireDown", data.currentFrame)
				else
					sprite:SetFrame("FireUp", data.currentFrame)
				end
			end
			data.currentFrame = data.currentFrame+1
		
			if data.currentFrame > 13 then
				data.state = "Idle"
				data.chaseTimer = 0
				if data.cardinalCooldown then
					if data.cardinalCooldown < 40 then
						data.cardinalCooldown = 60
					end
				else
					data.cardinalCooldown = 60
				end
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.CLarryBarf, 0.8, 0, false, 1.3)
				for i=1,9 do
					local params = ProjectileParams()
					params.FallingSpeedModifier = -(6+rng:RandomInt(12))
					params.FallingAccelModifier = (rng:RandomInt(5)+5)/8
					params.Scale = (rng:RandomInt(30)+80)/100
					if rng:RandomInt(2) == 0 then
						params.Variant = 1
					end
					npc:FireProjectiles(npc.Position, npc.Velocity*0.6+data.chargeDir:Resized(mod:getRoll(6, 10, rng)):Rotated(mod:getRoll(-10, 10, rng)), 0, params)
				end
				if data.void then
					for i=-90,90,15 do
						npc:FireProjectiles(npc.Position, npc.Velocity+data.chargeDir:Resized(8):Rotated(i), 0, ProjectileParams())
					end
				end
			end
		end
		
		if not npc.Child or not npc.Child:Exists() then
			npc:Die()
		end
	else
		if npc.Parent then
			if data.movement == 0 then
				if not data.followParentInfo then
					local customFunc = function(npc1, tab)
						local head = npc1:GetData().ultraParent
						local hData = head:GetData()
						if hData.state == "Charge" then
							if npc1.FrameCount % 2 == 0 then
								table.insert(tab.recordParent, {position = npc1.Parent.Position, velocity = npc1.Parent.Velocity})
								table.remove(tab.recordParent, 1)
							end
						elseif hData.state == "Jump" then
							if hData.subState == "Jumping" then
								table.insert(tab.recordParent, {position = npc1.Parent.Position, velocity = npc1.Parent.Velocity})
								table.remove(tab.recordParent, 1)
							end
						end
					end
				
					data.followParentInfo = {parent = npc.Parent, max = 11, min = 3, specialFunc = customFunc}
				end
			end
			
			if npc.Parent:GetData().launchedEnemyInfo and not data.launchedEnemyInfo then
				data.launchedEnemyInfo = {}
				for key,entry in pairs(npc.Parent:GetData().launchedEnemyInfo) do
					data.launchedEnemyInfo[key] = entry
				end
			end
			
			local butt
			if not npc.Child then
				butt = true
			end
			
			if butt == true then
				local gushSpawned
				if mod.GetEntityCount(mod.FF.PaleGusher.ID, mod.FF.PaleGusher.Var) < 3 then
					if npc.StateFrame > 150 and rng:RandomInt(60) == 0 then
						gushSpawned = true
					elseif npc.StateFrame > 300 then
						gushSpawned = true
					end
				end
				
				if gushSpawned == true then
					if data.void then
						for i=1,4 do
							local params = ProjectileParams()
							params.FallingSpeedModifier = -(6+rng:RandomInt(10))
							params.FallingAccelModifier = (rng:RandomInt(5)+5)/8
							params.Scale = (rng:RandomInt(30)+80)/100
							if rng:RandomInt(2) == 0 then
								params.Variant = 1
							end
							npc:FireProjectiles(npc.Position, -npc.Velocity:Resized(mod:getRoll(2, 5, rng)):Rotated(mod:getRoll(-30, 30, rng)), 0, params)
						end
					end
					local gusher = Isaac.Spawn(mod.FFID.Boss, mod.FF.PaleGusher.Var, 0, npc.Position-npc.Velocity:Resized(10), Vector.Zero, npc):ToNPC()
					gusher:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 0.6, 0, false, 1)
					local poof = Isaac.Spawn(1000, 16, 4, gusher.Position, Vector.Zero, npc):ToEffect()
					poof.SpriteScale = Vector(0.6,0.6)
					npc.StateFrame = -40
				end
			end
			
			if npc.Parent:IsDead() or FiendFolio:isStatusCorpse(npc.Parent) then
				npc.I1 = 0
				data.corruptedHead = true
				npc.Parent = nil
				data.followParentInfo = nil
				adjustLarryChildrenData(npc, "ultraParent", npc)
				data.cardinalCooldown = 30
				data.chaseTimer = 0
			end
			
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
				mod:spritePlay(sprite, "WalkBodyHori")
			else
				if npc.Velocity.Y > 0 then
					mod:spritePlay(sprite, "WalkBodyDown")
				else
					if npc.Child and npc.Child:Exists() then
						mod:spritePlay(sprite, "WalkBodyUp")
					else
						mod:spritePlay(sprite, "Butt")
					end
				end
			end
		else
			npc.I1 = 0
			data.corruptedHead = true
			npc.Parent = nil
			data.followParentInfo = nil
			adjustLarryChildrenData(npc, "ultraParent", npc)
			data.cardinalCooldown = 30
			data.chaseTimer = 0
		end
	end
end

function mod:paleGusherAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()
	local room = game:GetRoom()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		local gush = Isaac.Spawn(1000, 42, 0, npc.Position, Vector.Zero, npc):ToEffect()
		gush.Parent = npc
		gush:FollowParent(npc)
		gush.SpriteOffset = Vector(0,-6*npc.SpriteScale.Y)
		gush.DepthOffset = npc.DepthOffset+5
		
		data.targetPosition = mod:FindRandomValidPathPosition(npc, 3, nil, 90)
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end
	
	if npc.Position:Distance(target.Position) < 160 then
		data.targetPosition = target.Position
		data.wasFollowing = true
	elseif npc.Position:Distance(data.targetPosition) < 5 or npc.StateFrame > 60 or data.wasFollowing or npc:CollidesWithGrid() then
		data.targetPosition = mod:FindRandomValidPathPosition(npc, 3, nil, 90)+Vector(-10+rng:RandomInt(20),-10+rng:RandomInt(20))
		npc.StateFrame = 0
		data.wasFollowing = nil
	end
	
	if mod:isScare(npc) then
		local targetvel = (target.Position - npc.Position):Resized(-4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.2)
	elseif data.targetPosition then
		if room:CheckLine(npc.Position, data.targetPosition, 0, 1, false, false) then
			local targetvel = (data.targetPosition - npc.Position):Resized(2.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(data.targetPosition, 0.35, 900, true)
		end
	else
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
	end
		
	--[[if npc.FrameCount % 15 == 0 or npc.FrameCount % 21 == 0 then
		local params = ProjectileParams()
		params.FallingAccelModifier = 0.6
		params.FallingSpeedModifier = -10
		params.HeightModifier = 5
		npc:FireProjectiles(npc.Position, npc.Velocity:Resized(5), 0, params)
		npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
	end]]
	
	if npc.FrameCount % 12 == 0 then
		local params = ProjectileParams()
		params.FallingAccelModifier = 0.6
		params.FallingSpeedModifier = -10
		params.HeightModifier = 5
		npc:FireProjectiles(npc.Position, npc.Velocity:Resized(5), 0, params)
		npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
		
		
		--CIRCLE
		--npc:FireProjectiles(npc.Position, Vector(6, 10), 9, ProjectileParams())
		
		--TRIANGLE
		--[[local vel = 5
		local rangle = 0
		local dist = math.sqrt(5)*vel-vel/2
		for i=120,360,120 do
			for j=-dist,dist, (dist*2)/4 do
				local size = math.sqrt(j^2+vel^2)
				npc:FireProjectiles(npc.Position, Vector(j,vel):Rotated(i+rangle):Resized(size), 0, ProjectileParams())
			end
		end
		npc:FireProjectiles(npc.Position, Vector(0,4), 0, ProjectileParams())]]
		
		--heart <3
		--[[for i=-20,20,0.25 do
			local x = 16*math.sin(i)^3
			local y = 13*math.cos(i)-5*math.cos(2*i)-2*math.cos(3*i)-math.cos(4*i)
			local vel = math.sqrt(x^2+y^2)
			local dir = (Vector(x,y))
			npc:FireProjectiles(npc.Position, dir:Resized(vel):Rotated(180), 0, ProjectileParams())
		end]]
		
		--SQUARE
		--[[local vel = 5
		local rangle = 0
		for i=90,360,90 do
			for j=-vel,vel-1, (2*vel)/4 do
				local size = math.sqrt(j^2+vel^2)
				npc:FireProjectiles(npc.Position, Vector(j,vel):Rotated(i+rangle):Resized(size), 0, ProjectileParams())
			end
		end]]
	end
	
	if npc.FrameCount % 9 == 0 then
		local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
		splat.SpriteScale = Vector(0.2,0.2)
	end
end