local mod = FiendFolio
local sfx = SFXManager()

local hopInfo = {
	[1] = {name = "Standard", price = 1, sprite = "Hop1",
		startFunc = function(npc)
			npc:PlaySound(mod.Sounds.CMonstroRoar, 1, 0, false, 1)
		end,
		launch = {zVel = -8, pos = true, accel = 0.45, height = -23, collision = -30,
			landFunc = function(npc)
				npc:PlaySound(mod.Sounds.CMonstroStomp, 0.5, 0, false, 1.1)
				local params = ProjectileParams()
				params.Variant = 4
				if npc:GetData().cardinalHop then
					params.Color = Color(0.6,0.2,0.6, 1, 0, 0, 0) -- ripePlum
					npc:FireProjectiles(npc.Position, Vector(10,0), 6, params)
					npc:GetData().cardinalHop = false
				else
					params.Color = Color(0.84,0.36,0.78, 1, 0, 0, 0) -- lightLavendery2
					npc:FireProjectiles(npc.Position, Vector(10,0), 7, params)
					npc:GetData().cardinalHop = true
				end
			end},
		},
	[2] = {name = "Prepare", price = 2, sprite = "Hop2",
		startFunc = function(npc)
			npc:PlaySound(mod.Sounds.CMonstroGrunt, 1, 0, false, 1)
		end,
		launch = {zVel = -4, pos = true, accel = 0.3, height = -23, collision = -30,
			landFunc = function(npc) 
				npc:PlaySound(mod.Sounds.CMonstroStomp, 0.5, 0, false, 1.1)
			end},
		},
	[3] = {name = "Big", price = 2, sprite = "Hop4",
		startFunc = function(npc)
			npc.StateFrame = 0
			npc:PlaySound(mod.Sounds.CMonstroRoar, 1, 0, false, 1)
		end,
		launch = {zVel = -7, pos = true, accel = 0.22, height = -23, collision = -30,
			landFunc = function(npc)
				npc:PlaySound(mod.Sounds.CMonstroStomp, 0.8, 0, false, 1.1)
				for i=90,360,90 do
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,4):Rotated(i), npc):ToProjectile()
					local pData = proj:GetData()
					mod:makeBrisketProjSprite(proj)
					mod:makeCharmProj(npc, proj)
					pData.projType = "WarpZone"
					pData.detail = "MonstroSplit"
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.12
					proj.Scale = 2
					proj.Color = Color(0.75, 0.56, 1.08, 1, 0, 0, 0) -- wiltedLilac
				end
			end},
		},
	[50] = {name = "None", price = 0, sprite = "HopStart"},
	[51] = {name = "Leap", price = 3, sprite = "HopToBig",
		startFunc = function(npc)
		end,},
	[52] = {name = "Stop", price = 0, sprite = "HopEnd"},
	[53] = {name = "Fire", price = 0, sprite = "Hop3",
		startFunc = function(npc)
			local rng = npc:GetDropRNG()
			local data = npc:GetData()
			local bonusVel = (data.targetPos-npc.Position):Resized(4)
			for i=1,9 do
				local params = ProjectileParams()
				params.FallingSpeedModifier = -(6+rng:RandomInt(10))
				params.FallingAccelModifier = (rng:RandomInt(5)+5)/8
				params.Scale = (rng:RandomInt(30)+80)/100
				npc:FireProjectiles(npc.Position, bonusVel+(npc:GetPlayerTarget().Position-npc.Position):Resized(mod:getRoll(8, 12, rng)):Rotated(mod:getRoll(-20, 20, rng)), 0, params)
			end
			npc:PlaySound(mod.Sounds.CMonstroBarf, 0.9, 0, false, 1)
			local poof = Isaac.Spawn(1000, 16, 5, npc.Position+Vector(0,-30), Vector.Zero, npc):ToEffect()
			poof.DepthOffset = 30
			poof.SpriteScale = Vector(0.5,0.5)
			poof:FollowParent(npc)
		end,
		launch = {zVel = -9, pos = true, accel = 0.45, height = -23, collision = -30,
			landFunc = function(npc)
				npc:PlaySound(mod.Sounds.CMonstroStomp, 0.5, 0, false, 1.1)
				local rangle = npc:GetDropRNG():RandomInt(360)
				local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = Color(0.3, 0.55, 1, 1, 0, 0.1, 0.4) -- grapeSmoothie
				poof.SpriteOffset = Vector(0,-10)
				poof.DepthOffset = 20
				for i=1,8 do
					local params = ProjectileParams()
					params.FallingSpeedModifier = 0
					params.FallingAccelModifier = -0.185
					params.Variant = 4
					if i % 2 == 0 then
						params.Color = Color(0.28, 0.11, 0.32, 1, 0, 0, 0) -- darkBlurple2
					else
						params.Color = Color(0.35, 0.18, 0.5, 1, 0, 0, 0) -- concordGrape2
					end
					npc:FireProjectiles(npc.Position, Vector(2,0):Rotated(i*45+rangle), 0, params)
				end
			end},
		},
}

local nameToHop = {
	["Standard"] = hopInfo[1],
	["Prepare"] = hopInfo[2],
	["Big"] = hopInfo[3],
	["None"] = hopInfo[50],
	["Leap"] = hopInfo[51],
	["Stop"] = hopInfo[52],
	["Fire"] = hopInfo[53],
}

local function getNextHop(npc, rng)
	local data = npc:GetData()
	
	if data.chosenHop.name == "Prepare" then
		data.chosenHop = nameToHop["Fire"]
	else
		local hopData = nameToHop["Stop"]
		if data.hopAmount == 0 then
		elseif data.hopAmount == 1 then
			hopData = nameToHop["Standard"]
		elseif data.hopAmount == 3 then
			hopData = nameToHop["Leap"]
		else
			hopData = hopInfo[rng:RandomInt(3)+1]
		end
		
		data.chosenHop = hopData
		data.hopAmount = data.hopAmount-hopData.price
	end
end

function mod:corruptedMonstroAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rng = npc:GetDropRNG()
	
	if npc.Velocity:Length() > 1 then
		if npc.Velocity.X > 0.1 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
	end
	
	if not data.init then
		if HPBars then
			HPBars:createNewBossBar(npc)
		end
		if data.dead then
			data.state = "Dying"
		elseif data.warpzoneSpawned then
			data.state = "warpzoneSpawn"
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.subState = "Standard"
			data.launchedEnemyInfo = {vel = Vector(0,9), zVel = -3, collision = -30, landFunc = function(npc)
				npc:PlaySound(mod.Sounds.CMonstroStomp, 0.5, 0, false, 1.1)
			end, height = -30, pos = true}
		else
			data.state = "Idle"
		end
		data.chosenHop = nameToHop["None"]
		data.init = true
		data.attackLoop = 0
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Idle" then
		if npc.StateFrame > 10 and data.attackLoop == 0 then
			data.state = "Hop"
			data.hopAmount = mod:getRoll(3, 8, rng)
			getNextHop(npc, rng)
			data.subState = "Start"
			data.cardinalHop = true
		elseif data.attackLoop == 1 then
			data.state = "BigHop"
			data.attackLoop = 2
		elseif data.attackLoop == 2 then
			local attack = rng:RandomInt(2)
			if attack == 0 then
				data.state = "Squish"
			else
				data.state = "Barf"
			end
			data.attackLoop = 3
		elseif data.attackLoop == 3 then
			data.state = "Leap"
			data.attackLoop = 4
		elseif data.attackLoop == 4 and npc.StateFrame > 20 then
			data.state = "Barf"
			data.attackLoop = 0
		end
		
		mod:spritePlay(sprite, "Idle")
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "InAir" then
		mod:spritePlay(sprite, "JumpIdle")
		
		local vel = Vector.Zero
		local dist = (npc.Position - data.targetPos):Length()
		if dist < 40 or npc.StateFrame > 30 then
			vel = Vector.Zero
			data.state = "JumpDown"
		elseif dist < 70 then
			vel = (data.targetPos - npc.Position):Resized(2)
		else
			vel = vel + (data.targetPos-npc.Position):Resized(dist / 75)
			if vel:Length() >= dist then
				vel = vel:Resized(dist)
			end
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity+vel, 0.3)
	elseif data.state == "Leap" then
		if sprite:IsFinished("JumpUp") then
			data.state = "InAir"
			data.targetPos = targetpos
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			npc:PlaySound(mod.Sounds.CMonstroRoar, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "JumpUp")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "JumpDown" then
		if sprite:IsFinished("JumpDown") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.attackLoop = 4
		elseif sprite:IsEventTriggered("Land") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
			mod.scheduleForUpdate(function()
				Isaac.Spawn(20, 0, 150, npc.Position, Vector.Zero, nil)
				sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			end, 0)
			
			for i=120,360,120 do
				local proj = Isaac.Spawn(9, 8, 0, npc.Position, (target.Position-npc.Position):Resized(6):Rotated(i+mod:getRoll(-40,40,rng)), npc):ToProjectile()
				proj:GetData().projType = "monstroShrapnel"
				proj:GetData().detail = "random"
				proj.FallingSpeed = -19
				proj.FallingAccel = 1.1
				--proj.Scale = 1
				mod:makeCharmProj(npc, proj)
				
				local pSprite = proj:GetSprite()
				pSprite:Load("gfx/009.009_rock projectile.anm2", true)
				pSprite:Play("Rotate4", true)
				pSprite:LoadGraphics()
				proj:GetData().makeSplat = 145
				proj:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.2, math.random(8,12)/10}
				proj:GetData().toothParticles = mod.ColorRockGibs
				proj:Update()
			end
			for i=1,3 do
				local proj = Isaac.Spawn(9, 8, mod.FF.ShadowlessGridProjectile.Sub, mod:FindRandomFreePos(npc), Vector(0,0.3):Rotated(rng:RandomInt(360)), npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "monstroShrapnel"
				pData.detail = "falling"
				proj.FallingSpeed = -30*i
				proj.FallingAccel = 1.3
				proj.Height = -400
				--proj.Scale = 1.6
				
				local pSprite = proj:GetSprite()
				pSprite:Load("gfx/009.009_rock projectile.anm2", true)
				pSprite:Play("Rotate4", true)
				pSprite:LoadGraphics()
				proj:GetData().makeSplat = 145
				proj:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.2, math.random(8,12)/10}
				proj:GetData().toothParticles = mod.ColorRockGibs
				proj:Update()
			end
			
			local params = ProjectileParams()
			params.FallingAccelModifier = 1.2
			params.FallingSpeedModifier = -12
			npc:FireProjectiles(npc.Position, Vector(8,6), 9, params)
			params.FallingSpeedModifier = -16
			npc:FireProjectiles(npc.Position, Vector(4,3), 9, params)
			
			for i=1,8 do
				local params = ProjectileParams()
				params.FallingAccelModifier = mod:getRoll(100,130, rng)/100
				params.FallingSpeedModifier = -mod:getRoll(100,200, rng)/10
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(mod:getRoll(8,12,rng)):Rotated(mod:getRoll(-25,25,rng)), 0, params)
			end
			
			local poof = Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc):ToEffect()
			poof.DepthOffset = 5
			local poof2 = Isaac.Spawn(1000, 16, 3, npc.Position, Vector.Zero, npc):ToEffect()
			poof2.DepthOffset = 5
		else
			mod:spritePlay(sprite, "JumpDown")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "Barf" then
		if sprite:IsFinished("Barf") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.CMonstroBarf, 0.9, 0, false, 1)
			
			for i=1,10 do
				local params = ProjectileParams()
				params.FallingAccelModifier = mod:getRoll(100,130, rng)/100
				params.FallingSpeedModifier = -mod:getRoll(100,200, rng)/10
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(mod:getRoll(90,130,rng)/10):Rotated(mod:getRoll(-25,25,rng)), 0, params)
			end
		else
			mod:spritePlay(sprite, "Barf")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Squish" then
		if sprite:IsFinished("Squish") then
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			local params = ProjectileParams()
			local rangle = rng:RandomInt(360)
			for i=30,330,60 do
				for j=60,360,60 do
					npc:FireProjectiles(npc.Position+Vector(0,10):Rotated(j+i), Vector(0,10):Rotated(i), 0, params)
				end
			end
			params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
			params.HomingStrength = 0.7
			for i=60,360,60 do
				npc:FireProjectiles(npc.Position, Vector(0, 6):Rotated(i), 0, params)
			end
		else
			mod:spritePlay(sprite, "Squish")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Hop" then
		if data.subState == "Start" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			if sprite:IsFinished("HopStart") then
				data.subState = data.chosenHop.name
				if data.chosenHop.launch then
					data.launchedEnemyInfo = nil
					data.launchedEnemyInfo = mod:makeCopiedTable(data.chosenHop.launch)
					data.genericHop = true
					
					local pos = targetpos
					if npc.Position:Distance(pos) < 80 then
						pos = npc.Position+(pos-npc.Position):Resized(80)
					elseif npc.Position:Distance(pos) > 240 then
						pos = npc.Position+(pos-npc.Position):Resized(240)
					end
					data.targetPos = pos
				else
					data.launchedEnemyInfo = nil
				end
				data.launchedEnemyLanded = nil
				if data.chosenHop.startFunc then
					data.chosenHop.startFunc(npc)
				end
			else
				mod:spritePlay(sprite, "HopStart")
			end
		elseif data.subState == "Continue" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			if sprite:IsFinished("HopContinue") then
				data.subState = data.chosenHop.name
				if data.chosenHop.launch then
					data.launchedEnemyInfo = nil
					data.launchedEnemyInfo = mod:makeCopiedTable(data.chosenHop.launch)
					data.genericHop = true
					
					local pos = targetpos
					if npc.Position:Distance(pos) < 80 then
						pos = npc.Position+(pos-npc.Position):Resized(80)
					elseif npc.Position:Distance(pos) > 240 then
						pos = npc.Position+(pos-npc.Position):Resized(240)
					end
					data.targetPos = pos
				else
					data.launchedEnemyInfo = nil
				end
				data.launchedEnemyLanded = nil
				if data.chosenHop.startFunc then
					data.chosenHop.startFunc(npc)
				end
			else
				mod:spritePlay(sprite, "HopContinue")
			end
		elseif data.subState == "Stop" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			if sprite:IsFinished("HopEnd") then
				npc.StateFrame = 0
				data.attackLoop = 1
				data.state = "Idle"
			else
				mod:spritePlay(sprite, "HopEnd")
			end
		elseif data.subState == "Standard" then
			if data.launchedEnemyLanded then
				data.launchedEnemyLanded = nil
				getNextHop(npc, rng)
				if data.chosenHop.name == "Stop" then
					data.subState = "Stop"
				elseif data.chosenHop.name == "Leap" then
					data.subState = "Leap"
				else
					data.subState = "Continue"
				end
			end
			
			local dist = npc.Position:Distance(data.targetPos)
			if dist > 30 then
				npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position):Resized(dist*0.07), 0.2)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
			end
		
			mod:spritePlay(sprite, "Hop1")
		elseif data.subState == "Prepare" then
			if data.launchedEnemyLanded then
				data.launchedEnemyLanded = nil
				getNextHop(npc, rng)
				data.subState = "BeginFire"
			end
			
			local dist = npc.Position:Distance(data.targetPos)
			if dist > 30 then
				npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position):Resized(dist*0.07), 0.2)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
			end
		
			mod:spritePlay(sprite, "Hop2")
		elseif data.subState == "Fire" then
			if data.launchedEnemyLanded then
				data.launchedEnemyLanded = nil
				getNextHop(npc, rng)
				if data.chosenHop.name == "Stop" then
					data.subState = "Stop"
				elseif data.chosenHop.name == "Leap" then
					data.subState = "Leap"
				else
					data.subState = "Continue"
				end
			end
			
			local dist = npc.Position:Distance(data.targetPos)
			if dist > 30 then
				npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position):Resized(dist*0.07), 0.2)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
			end
		
			mod:spritePlay(sprite, "Hop3")
		elseif data.subState == "Leap" then
			if sprite:IsFinished("HopToBig") then
				data.state = "InAir"
				data.targetPos = targetpos
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Jump") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npc:PlaySound(mod.Sounds.CMonstroRoar, 1, 0, false, 1)
			else
				mod:spritePlay(sprite, "HopToBig")
			end
		
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		elseif data.subState == "Big" then
			if npc.StateFrame > 15 and data.launchedEnemyInfo then
				data.launchedEnemyInfo.zVel = data.launchedEnemyInfo.zVel+0.3
			end
			
			local dist = npc.Position:Distance(targetpos)
			if dist > 30 then
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(10), 0.05)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
			end
			
			if data.launchedEnemyLanded then
				data.launchedEnemyLanded = nil
				data.slamDown = nil
				getNextHop(npc, rng)
				if data.chosenHop.name == "Stop" then
					data.subState = "Stop"
				elseif data.chosenHop.name == "Leap" then
					data.subState = "Leap"
				else
					data.subState = "Continue"
				end
			end
		
			mod:spritePlay(sprite, "Hop4")
		elseif data.subState == "BeginFire" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			if sprite:IsFinished("HopToBarf") then
				data.subState = data.chosenHop.name
				if data.chosenHop.launch then
					data.launchedEnemyInfo = nil
					data.launchedEnemyInfo = mod:makeCopiedTable(data.chosenHop.launch)
					data.genericHop = true
					
					local pos = targetpos
					if npc.Position:Distance(pos) < 80 then
						pos = npc.Position+(pos-npc.Position):Resized(80)
					elseif npc.Position:Distance(pos) > 240 then
						pos = npc.Position+(pos-npc.Position):Resized(240)
					end
					data.targetPos = pos
				else
					data.launchedEnemyInfo = nil
				end
				data.launchedEnemyLanded = nil
				if data.chosenHop.startFunc then
					data.chosenHop.startFunc(npc)
				end
			else
				mod:spritePlay(sprite, "HopToBarf")
			end
		end
	elseif data.state == "BigHop" then
		if sprite:IsFinished("BigHop") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			
			data.subState = "Jumped"
			data.targetPos = targetpos
		elseif sprite:IsEventTriggered("Land") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:PlaySound(mod.Sounds.CMonstroStomp, 0.75, 0, false, 1.1)
			data.subState = nil
		elseif sprite:IsEventTriggered("Shoot") then
			for i=1,10 do
				local params = ProjectileParams()
				params.FallingAccelModifier = mod:getRoll(100,130, rng)/100
				params.FallingSpeedModifier = mod:getRoll(-50,10, rng)/10
				params.HeightModifier = -80
				npc:FireProjectiles(npc.Position, npc.Velocity*0.5+(target.Position-npc.Position):Resized(mod:getRoll(30,80,rng)/10):Rotated(mod:getRoll(-25,25,rng)), 0, params)
			end
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
			poof:GetData().launchedEnemyInfo = {height = -60, zVel = -1, accel = 0.4, extraFunc = function(npc1, tab) if tab.height > -20 then npc1:GetData().launchedEnemyInfo = nil end end}
			poof.SpriteOffset = Vector(0,-60)
			poof:FollowParent(npc)
			poof.DepthOffset = 200
			npc:PlaySound(mod.Sounds.CMonstroShoot, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(mod.Sounds.CMonstroRoar, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "BigHop")
		end
		
		if data.subState == "Jumped" then
			local dist = npc.Position:Distance(data.targetPos)
			if dist > 30 then
				npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position):Resized(dist*0.045), 0.2)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		end
	elseif data.state == "warpzoneSpawn" then
		if data.subState == "Standard" then
			if data.launchedEnemyLanded then
				data.launchedEnemyLanded = nil
				data.subState = "Stop"
			end
		
			mod:spritePlay(sprite, "Hop1")
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			if sprite:IsFinished("HopEnd") then
				npc.StateFrame = 0
				data.attackLoop = 0
				data.state = "Idle"
			else
				mod:spritePlay(sprite, "HopEnd")
			end
		end
	elseif data.state == "Dying" then
		if sprite:IsFinished("Death") then
			npc:Kill()
		else
			mod:spritePlay(sprite, "Death")
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
	
	if npc:IsDead() and data.launchedEnemyInfo then
		data.launchedEnemyInfo.landFunc = nil
	end
end

function mod.corruptedMonstroDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().dead = true
	end
	mod.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, false, false)
end