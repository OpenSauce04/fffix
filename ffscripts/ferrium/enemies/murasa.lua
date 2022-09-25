local mod = FiendFolio
local game = Game()

function mod:murasaAI(npc) --This is so fucking messy, but I don't care it's just a joke teaser
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.DepthOffset = 9999
		data.state = "Appear"
		sprite:Play("FlyIdle")
		npc.Visible = false
		data.phaseChange = false
		data.wait = false
		data.effectTimer = 0
		data.movement = "No"
		data.originalPos = npc.Position
		data.init = true
	else
		if data.phaseChange == true and data.state ~= "Die" then
			data.phaseChange = false
		end
		
		npc.StateFrame = npc.StateFrame+1
		data.effectTimer = data.effectTimer+1
		
		if data.attack == "Ghost 'Sinker Ghost'" then
			if npc.FrameCount % 12 == 0 then
				npc.HitPoints = npc.HitPoints-1
				if npc.HitPoints < 1 then
					data.state = "Die"
					data.attack = "Die"
					data.phaseChange = true
					data.effects = "Die"
					npc.StateFrame = 0
					data.moveTarget = npc.Position+Vector(math.random(-60,60), math.random(-60,60))
					data.movement = "MoveThere"
					npc:PlaySound(mod.Sounds.MurasaDeath, 0.4, 0, false, 1)
					npc.DepthOffset = 1
				end
			end
			if npc.HitPoints < 25 then
				if npc.FrameCount % 30 == 0 then 
					npc:PlaySound(mod.Sounds.MurasaTimeout, 0.6, 0, false, 1)
				end
			end
		end
	end
	
	if data.movement == "MoveThere" then
		if npc.Position:Distance(data.moveTarget) > 40 then
			mod:spritePlay(sprite, "FlyIdle")
		elseif npc.Position:Distance(data.moveTarget) < 40 and data.state ~= "Die" then
			mod:spritePlay(sprite, "FlyFinish")
		elseif data.state == "Die" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			mod:spritePlay(sprite, "FlyIdle")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, (data.moveTarget-npc.Position)*0.2, 0.05)
		
		if npc.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end 
		
		if sprite:IsFinished("FlyFinish") then
			data.movement = "No"
			sprite.FlipX = false
		end
	elseif data.movement == "FindTarget" then
		local goodTarget = "true"
		local targetPos = npc.Position+Vector(math.random(-100,100), math.random(-60,60))
		if math.abs(targetPos.X-data.originalPos.X) > 200 or math.abs(targetPos.Y-data.originalPos.Y) > 50 or targetPos:Distance(npc.Position) < 50 then
			goodTarget = "false"
		end
		if goodTarget == "true" then
			data.movement = "MoveThere"
			data.moveTarget = targetPos
		end
	elseif data.movement == "Return" then
		if npc.Position:Distance(data.originalPos) > 40 then
			mod:spritePlay(sprite, "FlyIdle")
			npc.Velocity = mod:Lerp(npc.Velocity, (data.originalPos-npc.Position)*0.2, 0.05)
		elseif npc.Position:Distance(data.originalPos) < 50 then
			mod:spritePlay(sprite, "FlyFinish")
			npc.Position = mod:Lerp(npc.Position, data.originalPos, 0.2)
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
		end
		
		if npc.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end 
		
		if sprite:IsFinished("FlyFinish") then
			data.movement = "No"
			sprite.FlipX = false
		end
	else
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
	end
	
	-- Pattern Behavior
	if data.state == "Idle" then
		if npc.StateFrame % 110 == 0 and data.attack == "Capsize 'Dragging Anchor'" then
			sprite:Play("Attack")
			local anchor = Isaac.Spawn(114, 1002, 0, npc.Position, Vector.Zero, npc)
			anchor.Parent = npc
			anchor:GetData().targetDir = (target.Position-npc.Position)
			anchor.SpriteRotation = (target.Position-npc.Position):GetAngleDegrees()
			anchor.DepthOffset = 999
			anchor:Update()
			data.movement = "FindTarget"
		elseif npc.StateFrame % 160 == 0 and data.attack == "Drowning Sign 'Deep Vortex'" then
			data.effects = "drowning sign"
			data.effectTimer = 0
			data.fallingDir = Vector(0,0.5):Rotated(math.random(-40,40))
			data.rotation = math.random(360)
			data.movement = "FindTarget"
		elseif npc.StateFrame % 130 == 0 and data.attack == "Harbor Sign 'Phantom Ship Harbor'" then
			data.effects = "harbor"
			data.effectTimer = 0
			data.targetDir = (target.Position-npc.Position):Rotated(-144)
		elseif data.attack == "Ghost 'Sinker Ghost'" then
			if data.movement == "No" then
				data.state = "WarpOut"
				npc:PlaySound(mod.Sounds.MurasaWarp, 0.6, 0, false, 1)
			end
		end
		--[[if npc.StateFrame % 120 == 0 then
			if data.movement == "No" then
				data.movement = "FindTarget"
			end
		elseif npc.StateFrame % 700 == 0 then
			data.movement = "Return"
			npc:PlaySound(mod.Sounds.MurasaWarp, 0.6, 0, false, 1)
		end]]
		if data.movement == "No" then
			mod:spritePlay(sprite, "Idle")
		end
		
		if npc.HitPoints < 500 and data.attack == "Capsize 'Dragging Anchor'" then
			data.phaseChange = true
			data.color = "teal"
			data.attack = "Drowning Sign 'Deep Vortex'"
			npc.StateFrame = 120
			data.movement = "Return"
			npc:PlaySound(mod.Sounds.MurasaFire, 0.7, 0, false, 1)
		elseif npc.HitPoints < 325 and data.attack == "Drowning Sign 'Deep Vortex'" then
			data.attack = "Harbor Sign 'Phantom Ship Harbor'"
			data.phaseChange = true
			data.movement = "Return"
			npc:PlaySound(mod.Sounds.MurasaFire, 0.7, 0, false, 1)
		elseif npc.HitPoints < 120 and data.attack == "Harbor Sign 'Phantom Ship Harbor'" then
			data.phaseChange = true
			data.events = "No"
			npc.StateFrame = 0
			npc:PlaySound(mod.Sounds.MurasaFire, 0.7, 0, false, 1)
			data.attack = "Ghost 'Sinker Ghost'" 
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:PlaySound(mod.Sounds.MurasaSpell, 0.6, 0, false, 1)
		end
	elseif data.state == "WarpOut" then
		if sprite:IsFinished("GhostOut") then
			npc.Position = target.Position
			data.state = "WarpIn"
			npc:PlaySound(mod.Sounds.MurasaWarp, 0.6, 0, false, 1)
		else
			mod:spritePlay(sprite, "GhostOut")
		end
	elseif data.state == "WarpIn" then
		if sprite:IsFinished("GhostIn") then
			if npc.StateFrame < 300 then
				data.Wait = npc.HitPoints/2
			else
				data.Wait = 0
			end
			data.effects = "ring"
			data.targetDir = RandomVector()
			data.ringState = 0
			npc.StateFrame = 0
			data.state = "GhostAttack"
		else
			mod:spritePlay(sprite, "GhostIn")
		end
	elseif data.state == "GhostAttack" then
		if data.Wait > 0 then
			data.Wait = data.Wait-1
		else
			data.state = "WarpOut"
			npc:PlaySound(mod.Sounds.MurasaWarp, 0.6, 0, false, 1)
		end
		mod:spritePlay(sprite, "GhostAttack")
	elseif data.state == "Appear" then
		if sprite:IsFinished("Appear") then
			data.attack = "Capsize 'Dragging Anchor'"
			npc:PlaySound(mod.Sounds.MurasaSpell, 0.6, 0, false, 1)
			data.effects = "LeavesIn"
			data.effectTimer = 0
			data.state = "Idle"
			npc.StateFrame = 70
		end
		
		if npc.Visible == false and npc.StateFrame > 40 then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			mod:spritePlay(sprite, "Appear")
			npc.Visible = true
		end
	end
	
	if data.effects == "Die" then
		if data.attack == "Die" then
			if npc.StateFrame == 1 then
				local deathPulse = Isaac.Spawn(1000, 1750, 3, npc.Position+Vector(0,-60), Vector.Zero, npc):ToEffect()
				deathPulse:GetSprite():Play("deathPulse")
				deathPulse:Update()
			end
			for i=0,1 do
				local leaf = Isaac.Spawn(1000, 1750, 3, npc.Position+Vector(0,-60), RandomVector()*math.random(10), npc):ToEffect()
				leaf.Parent = npc
				local scaleValue = (math.random(100)/100)
				leaf.SpriteScale = Vector(1+scaleValue, 1+scaleValue)
				leaf.DepthOffset = 500
				if i==1 then
					leaf:GetData().state = "LeafExplosion"
				else
					leaf:GetData().state = "LeavesOut"
				end
				leaf:GetSprite():Play("deathLeaf")
				leaf:Update()
			end
			if npc.StateFrame > 55 then
				data.attack = "Die2" 
				Game():ShakeScreen(25)
				npc:PlaySound(mod.Sounds.MurasaDeath, 0.6, 0, false, 1)
				local deathPulse = Isaac.Spawn(1000, 1750, 3, npc.Position+Vector(0,-60), Vector.Zero, npc):ToEffect()
				deathPulse:GetSprite():Play("deathPulse")
				deathPulse:Update()
				for i=0,16 do
					local leaf = Isaac.Spawn(1000, 1750, 3, npc.Position, RandomVector()*math.random(6,14), npc):ToEffect()
					leaf.Parent = npc
					local scaleValue = (math.random(100)/100)
					leaf.SpriteScale = Vector(1+scaleValue, 1+scaleValue)
					leaf.DepthOffset = 500
					leaf:GetData().state = "LeavesOut"
					leaf:GetSprite():Play("deathLeaf")
					leaf:Update()
				end
				npc:Remove()
			end
		end
	elseif data.effects == "LeavesIn" then
		if data.effectTimer == 6 then
			local spawnEffect = Isaac.Spawn(1000, 1750, 3, npc.Position+Vector(0,-80), Vector.Zero, npc):ToEffect()
			spawnEffect:GetSprite():Play("appearCircle")
			spawnEffect:GetData().state = "appearCircle"
			spawnEffect:Update()
		end
		if data.effectTimer % 2 == 0 and data.effectTimer < 10 then
			for i=0,4 do
				local leafSpawn = npc.Position+RandomVector():Resized(200+math.random(100))
				local leaf = Isaac.Spawn(1000, 1750, 3, leafSpawn, (npc.Position+Vector(0,-80)-leafSpawn):Resized(10), npc):ToEffect()
				leaf.Parent = npc
				leaf:SetColor(Color(1,1,1,0,0,0,0), 999, 1, false, false)
				local scaleValue = (math.random(120)/100)
				leaf.SpriteScale = Vector(1+scaleValue, 1+scaleValue)
				leaf.DepthOffset = 500
				leaf:GetData().state = "LeavesIn"
				leaf:GetSprite():Play("deathLeaf")
				leaf:Update()
			end
		elseif data.effectTimer > 15 then
			data.effects = "No"
		elseif data.effectTimer % 2 == 0 then
			local leafSpawn = npc.Position+RandomVector():Resized(200+math.random(50))
			local leaf = Isaac.Spawn(1000, 1750, 3, leafSpawn, (npc.Position+Vector(0,-80)-leafSpawn):Resized(10), npc):ToEffect()
			leaf.Parent = npc
			leaf:SetColor(Color(1,1,1,0,0,0,0), 999, 1, false, false)
			local scaleValue = (math.random(120)/100)
			leaf.SpriteScale = Vector(1+scaleValue, 1+scaleValue)
			leaf.DepthOffset = 500
			leaf:GetData().state = "LeavesIn"
			leaf:GetSprite():Play("deathLeaf")
			leaf:Update()
		end
	elseif data.effects == "drowning sign" then
		for j=0,3 do
			for i=0,11 do
				npc:PlaySound(mod.Sounds.MurasaFire, 0.3, 0, false, 1)
				local dir = data.fallingDir:Rotated(math.random(-15,15))
				local proj = Isaac.Spawn(9, 0, 0, target.Position+Vector(0,100+data.effectTimer*15):Rotated(30*i+data.rotation)+Vector(math.random(-15,15),math.random(-15,15)), dir, npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "Murasa"
				pData.detail = "drowning"
				proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
				if data.color == "teal" then
					pData.visual = "teal"
					proj:GetSprite():Play("tealProj",true)
				else
					pData.visual = "blue"
					proj:GetSprite():Play("navyProj",true)
				end
				pData.target = dir:Resized(2+math.random(20)/4)
				proj.Parent = npc
				proj.SpriteRotation = dir:GetAngleDegrees()+90
				proj:Update()
			end
			data.effectTimer = data.effectTimer+1
		end
		
		if data.effectTimer > 40 then
			data.effects = "No"
			if data.color == "teal" then
				data.color = "navy"
			else
				data.color = "teal"
			end
		end
	elseif data.effects == "harbor" then
		data.movement = "kinda"
		mod:spritePlay(sprite, "Attack")
		if data.effectTimer % 3 == 0 then
			local anchor = Isaac.Spawn(114, 1002, 0, npc.Position+data.targetDir:Rotated(36*data.effectTimer/3):Resized(50), Vector.Zero, npc)
			anchor.Parent = npc
			anchor:GetData().targetDir = data.targetDir:Rotated(36*data.effectTimer/3)
			anchor:GetData().mode = "harbor"
			anchor.SpriteRotation = data.targetDir:Rotated(36*data.effectTimer/3):GetAngleDegrees()
			anchor.DepthOffset = 999
			anchor:Update()
		end
		
		if data.effectTimer > 30 then
			data.movement = "FindTarget"
			data.effects = "No"
		end
	elseif data.effects == "ring" then
		for i=0,2 do
			for j=0,1 do
				for k=0,1 do
					npc:PlaySound(mod.Sounds.MurasaFire, 0.3, 0, false, 1)
					local dir = data.targetDir:Rotated(10*data.ringState)
					local proj = Isaac.Spawn(9, 0, 0, npc.Position+Vector(0,-50)+dir:Resized(30+20*k), Vector.Zero, npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "Murasa"
					pData.detail = "ghost"
					pData.visual = "teal"
					pData.timer = npc.StateFrame
					pData.targetDir = dir:Rotated(180*j):Resized(3+6*j+2*k)
					proj.Parent = npc
					proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
					proj:GetSprite():Play("tealProj",true)
					proj.SpriteRotation = dir:GetAngleDegrees()+90
					proj:Update()
				end
			end
			data.ringState = data.ringState+1
		end
		if npc.StateFrame > 12 then
			data.effects = "No"
		end
	end
end

function mod.murasaProj(v, d) -- Oh boy
	if d.projType == "Murasa" then
		local sprite = v:GetSprite()
		v.FallingSpeed = 0
		v.FallingAccel = -0.05
		if d.detail == "Wave" then
			if v.FrameCount == 50 then
				sprite:Play("tealBall")
			elseif v.FrameCount > 10 then
				v.Velocity = mod:Lerp(v.Velocity, Vector.Zero, 0.1)
			end
		elseif d.detail == "Anchor1" then
			if v.Velocity:Length() < d.target:Length() then
				v.Velocity = mod:Lerp(v.Velocity, d.target, 0.01)
			end
			v.FallingAccel = -0.05
		elseif d.detail == "Anchor2" then
			if v.Velocity:Length() < d.target:Length() then
				v.Velocity = mod:Lerp(v.Velocity, d.target, 0.01)
			end
			if v.FrameCount > 50 and not d.accel then
				d.target = d.target*4
				d.accel = true
			end
		elseif d.detail == "drowning" then
			if v.Velocity:Length() < d.target:Length() then
				v.Velocity = mod:Lerp(v.Velocity, d.target, 0.005)
			end
			if v.Position.Y > 800 or math.abs(v.Position.X-320) > 250 then
				v:Remove()
			end
		elseif d.detail == "ghost" then
			if not d.accel then
				if v.Parent:GetData().effects == "No" then
					d.accel = true
				end
			end
			if d.accel == true then
				if v.Velocity:Length() < d.targetDir:Length() then
					v.Velocity = mod:Lerp(v.Velocity, d.targetDir, 0.005)
				end
			end
		end
		
		if d.visual == "teal" then
			if v:IsDead() or (v.Parent and v.Parent:GetData().phaseChange == true) or not v.Parent then
				local tearpoof = Isaac.Spawn(1000, 1750, 3, v.Position, Vector.Zero, v):ToEffect()
				tearpoof:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
				tearpoof:GetSprite():Play("tealDeath", true)
				tearpoof.SpriteOffset = Vector(0, v.Height)
				tearpoof:Update()
				v:Remove()
			end
		elseif d.visual == "blue" then
			if v:IsDead() or (v.Parent and v.Parent:GetData().phaseChange == true) or not v.Parent then
				local tearpoof = Isaac.Spawn(1000, 1750, 3, v.Position, Vector.Zero, v):ToEffect()
				tearpoof:GetSprite():Play("blueDeath", true)
				tearpoof.SpriteOffset = Vector(0, v.Height)
				tearpoof:Update()
				v:Remove()
			end
		elseif d.visual == "blueAnimate" then
			if sprite:IsFinished("blueAnimateAppear") then
				sprite:Play("blueAnimate")
			end
			if v:IsDead() or (v.Parent and v.Parent:GetData().phaseChange == true) or not v.Parent then
				local tearpoof = Isaac.Spawn(1000, 1750, 3, v.Position, Vector.Zero, v):ToEffect()
				tearpoof:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
				tearpoof:GetSprite():Play("blueAnimateDeath", true)
				tearpoof.SpriteOffset = Vector(0, v.Height)
				tearpoof:Update()
				v:Remove()
			end
		end
	end
end

function mod.murasaProjColl(proj, d)
	if d.projType and d.projType == "Murasa" then
		if d.visual == "teal" then
			local tearpoof = Isaac.Spawn(1000, 1750, 3, proj.Position, Vector.Zero, proj):ToEffect()
			tearpoof:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
			tearpoof:GetSprite():Play("tealDeath", true)
			tearpoof.SpriteOffset = Vector(0, proj.Height)
			tearpoof:Update()
			proj:Remove()
		elseif d.visual == "blue" then
			local tearpoof = Isaac.Spawn(1000, 1750, 3, proj.Position, Vector.Zero, proj):ToEffect()
			tearpoof:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
			tearpoof:GetSprite():Play("blueDeath", true)
			tearpoof.SpriteOffset = Vector(0, proj.Height)
			tearpoof:Update()
			proj:Remove()
		elseif d.visual == "blueAnimate" then
			local tearpoof = Isaac.Spawn(1000, 1750, 3, proj.Position, Vector.Zero, proj):ToEffect()
			tearpoof:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
			tearpoof:GetSprite():Play("blueAnimateDeath", true)
			tearpoof.SpriteOffset = Vector(0, proj.Height)
			tearpoof:Update()
			proj:Remove()
		end
	end
end

function mod:murasaAnchorAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()
	
	if not data.init then
		if not data.targetDir then
			data.targetDir = (target.Position-npc.Position)
			npc.SpriteRotation = data.targetDir:GetAngleDegrees()
			npc:Update()
		end
	
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

		data.state = "Appear"
		data.wall = false
		data.wallSpawn = 0
		npc:PlaySound(mod.Sounds.AnchorSpawn, 0.6, 0, false, 1)
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.wall then
		data.wallSpawn = data.wallSpawn+1
		if data.wall[2] % 2 == 0 then
			if data.wall[2] == 4 then
				for i=-1, 1, 2 do
					for j=0,3 do 
						if room:GetGridEntityFromPos(data.wall[1]+Vector(i*data.wallSpawn*3,0)) then
							if room:GetGridEntityFromPos(data.wall[1]+Vector(i*data.wallSpawn*3,0)).Desc.Type == GridEntityType.GRID_WALL or room:GetGridEntityFromPos(data.wall[1]+Vector(i*data.wallSpawn*3,0)).Desc.Type == GridEntityType.GRID_DOOR then
								if room:GetGridCollisionAtPos(data.wall[1]+Vector(i*data.wallSpawn*3,-40)) ~= GridCollisionClass.COLLISION_WALL then
									if math.random(25) == 1 or data.wallSpawn % 8 == 0 then
										local dir = Vector(0,-50):Rotated(math.random(-20,20)):Resized(math.random(1,10))
										local wave = Isaac.Spawn(9,0,0,data.wall[1]+Vector(i*data.wallSpawn*3,-5),dir,npc):ToProjectile()
										local wData = wave:GetData()
										wData.projType = "Murasa"
										wData.detail = "Wave"
										wData.visual = "teal"
										wave.Parent = npc.Parent
										wave:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
										wave:GetSprite():Play("tealProj",true)
										wave.SpriteRotation = dir:GetAngleDegrees()+90
										wave:Update()
										npc:PlaySound(mod.Sounds.MurasaSparkle, 0.6, 0, false, 1)
									end
									data.wallSpawn = data.wallSpawn+1
								end
							end
						end
					end
				end
			else
				for i=-1, 1, 2 do
					for j=0,3 do 
						if room:GetGridEntityFromPos(data.wall[1]+Vector(i*data.wallSpawn*3,0)) then
							if room:GetGridEntityFromPos(data.wall[1]+Vector(i*data.wallSpawn*3,0)).Desc.Type == GridEntityType.GRID_WALL or room:GetGridEntityFromPos(data.wall[1]+Vector(i*data.wallSpawn*3,0)).Desc.Type == GridEntityType.GRID_DOOR then
								if room:GetGridCollisionAtPos(data.wall[1]+Vector(i*data.wallSpawn*3,40)) ~= GridCollisionClass.COLLISION_WALL then
									if math.random(25) == 1 or data.wallSpawn % 8 == 0 then
										local dir = Vector(0,50):Rotated(math.random(-20,20)):Resized(math.random(1,10))
										local wave = Isaac.Spawn(9,0,0,data.wall[1]+Vector(i*data.wallSpawn*3,10),dir,npc)
										local wData = wave:GetData()
										wData.projType = "Murasa"
										wData.detail = "Wave"
										wData.visual = "teal"
										wave.Parent = npc.Parent
										wave:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
										wave:GetSprite():Play("tealProj",true)
										wave.SpriteRotation = dir:GetAngleDegrees()+90
										wave:Update()
										npc:PlaySound(mod.Sounds.MurasaSparkle, 0.6, 0, false, 1)
									end
									data.wallSpawn = data.wallSpawn+1
								end
							end
						end
					end
				end
			end
		else
			if data.wall[2] == 3 then
				for i=-1, 1, 2 do
					for j=0,3 do 
						if room:GetGridEntityFromPos(data.wall[1]+Vector(0,i*data.wallSpawn*3)) then
							if room:GetGridEntityFromPos(data.wall[1]+Vector(0,i*data.wallSpawn*3)).Desc.Type == GridEntityType.GRID_WALL or room:GetGridEntityFromPos(data.wall[1]+Vector(0,i*data.wallSpawn*3)).Desc.Type == GridEntityType.GRID_DOOR then
								if room:GetGridCollisionAtPos(data.wall[1]+Vector(-40,i*data.wallSpawn*3)) ~= GridCollisionClass.COLLISION_WALL then
									if math.random(25) == 1 or data.wallSpawn % 8 == 0 then
										local dir = Vector(-50,0):Rotated(math.random(-20,20)):Resized(math.random(1,10))
										local wave = Isaac.Spawn(9,0,0,data.wall[1]+Vector(-5,i*data.wallSpawn*3),dir,npc)
										local wData = wave:GetData()
										wData.projType = "Murasa"
										wData.detail = "Wave"
										wData.visual = "teal"
										wave.Parent = npc.Parent
										wave:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
										wave:GetSprite():Play("tealProj",true)
										wave.SpriteRotation = dir:GetAngleDegrees()+90
										wave:Update()
										npc:PlaySound(mod.Sounds.MurasaSparkle, 0.6, 0, false, 1)
									end
									data.wallSpawn = data.wallSpawn+1
								end
							end
						end
					end
				end
			else
				for i=-1, 1, 2 do
					for j=0,3 do 
						if room:GetGridEntityFromPos(data.wall[1]+Vector(0,i*data.wallSpawn*3)) then
							if room:GetGridEntityFromPos(data.wall[1]+Vector(0,i*data.wallSpawn*3)).Desc.Type == GridEntityType.GRID_WALL or room:GetGridEntityFromPos(data.wall[1]+Vector(0,i*data.wallSpawn*3)).Desc.Type == GridEntityType.GRID_DOOR then
								if room:GetGridCollisionAtPos(data.wall[1]+Vector(40,i*data.wallSpawn*3)) ~= GridCollisionClass.COLLISION_WALL then
									if math.random(25) == 1 or data.wallSpawn % 8 == 0 then
										local dir = Vector(50,0):Rotated(math.random(-20,20)):Resized(math.random(1,10))
										local wave = Isaac.Spawn(9,0,0,data.wall[1]+Vector(5,i*data.wallSpawn*3),dir,npc)
										local wData = wave:GetData()
										wData.projType = "Murasa"
										wData.detail = "Wave"
										wData.visual = "teal"
										wave.Parent = npc.Parent
										wave:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
										wave:GetSprite():Play("tealProj",true)
										wave.SpriteRotation = dir:GetAngleDegrees()+90
										wave:Update()
										npc:PlaySound(mod.Sounds.MurasaSparkle, 0.6, 0, false, 1)
									end
									data.wallSpawn = data.wallSpawn+1
								end
							end
						end
					end
				end
			end
		end
		if npc.StateFrame > 100 then
			data.wall = nil
		end
	end
	
	if data.state == "Fly" then
		if data.mode == "harbor" then
			if npc.StateFrame >= 6 then
				if npc.StateFrame % 4 == 0 then
					for i=-1,1,2 do
						if npc.StateFrame == 12 then
							for i=0,7 do
								local dir2 = data.targetDir:Rotated(i*40+20)
								local proj2 = Isaac.Spawn(9, 0, 0, npc.Position+dir2:Resized(20), dir2:Resized(3+(1/npc.StateFrame)), npc):ToProjectile()
								local pData2 = proj2:GetData()
								pData2.projType = "Murasa"
								pData2.visual = "blueAnimate"
								proj2.Parent = npc.Parent
								proj2:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
								proj2:GetSprite():Play("blueAnimateAppear",true)
								proj2.SpriteRotation = dir2:GetAngleDegrees()+90
								proj2:Update()
							end
						end
						local dir = data.targetDir:Rotated(i*80)
						local proj = Isaac.Spawn(9, 0, 0, npc.Position+dir:Resized(20), dir:Resized(4+(1/npc.StateFrame)), npc):ToProjectile()
						local pData = proj:GetData()
						pData.projType = "Murasa"
						pData.visual = "blueAnimate"
						proj.Parent = npc.Parent
						proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
						proj:GetSprite():Play("blueAnimateAppear",true)
						proj.SpriteRotation = dir:GetAngleDegrees()+90
						proj:Update()
					end
				end
			end
		else
			--[[if npc.FrameCount % 5 == 0 then
				for i=-1,1,2 do
					local proj = Isaac.Spawn(9, 0, 0, npc.Position+data.targetDir:Resized(40):Rotated(40*i),data.targetDir:Resized(0.1+npc.StateFrame/20):Rotated(40*i), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "Murasa"
					pData.detail = "Anchor1"
					pData.visual = "blueAnimate"
					pData.target = data.targetDir:Resized(6):Rotated(40*i)
					proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
					proj:GetSprite():Play("blueAnimateAppear",true)
					proj.SpriteRotation = data.targetDir:Rotated(40*i):GetAngleDegrees()+90
					proj:Update()
				end
			end]]
			if npc.StateFrame < 11 then
				for k=0,1 do
					for i=-1,1,2 do
						local dir = data.targetDir:Rotated(180-(13*i*(npc.StateFrame-1)))
						local proj = Isaac.Spawn(9, 0, 0, npc.Position, dir:Resized(0.1+(1/npc.StateFrame)), npc):ToProjectile()
						local pData = proj:GetData()
						pData.projType = "Murasa"
						if k == 0 then
							pData.detail = "Anchor1"
						else
							pData.detail = "Anchor2"
						end
						pData.visual = "blueAnimate"
						pData.target = dir:Resized(6)
						proj.Parent = npc.Parent
						proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
						proj:GetSprite():Play("blueAnimateAppear",true)
						proj.SpriteRotation = dir:GetAngleDegrees()+90
						proj:Update()
					end
					
					--[[if k == 0 then
						for i=-1,1,2 do
							local dir = data.targetDir:Rotated(180-(13*i*(npc.StateFrame-1)))
							local proj = Isaac.Spawn(9, 0, 0, npc.Position+dir:Resized(10), dir:Resized(0.1+(1/npc.StateFrame)), npc):ToProjectile()
							local pData = proj:GetData()
							pData.projType = "Murasa"
							pData.detail = "Anchor1"
							pData.visual = "blueAnimate"
							pData.target = dir:Resized(8)
							proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
							proj:GetSprite():Play("blueAnimateAppear",true)
							proj.SpriteRotation = dir:GetAngleDegrees()+90
							proj:Update()
						end
					end]]
				end
			end
			if npc.StateFrame >= 12 then
				if npc.StateFrame % 4 == 0 then
					for k=0,1 do
						for i=-1,1,2 do
							local help = Vector.Zero
							if npc.StateFrame == 12 then
								help = data.targetDir:Rotated(180):Resized(30)
							end
							local dir = data.targetDir:Rotated(i*50)
							local proj = Isaac.Spawn(9, 0, 0, npc.Position+dir:Resized(20)+help, dir:Resized(0.1+(1/npc.StateFrame)), npc):ToProjectile()
							local pData = proj:GetData()
							pData.projType = "Murasa"
							if k == 0 then
								pData.detail = "Anchor1"
							else
								pData.detail = "Anchor2"
							end
							pData.visual = "blueAnimate"
							pData.target = dir:Resized(6)
							proj.Parent = npc.Parent
							proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
							proj:GetSprite():Play("blueAnimateAppear",true)
							proj.SpriteRotation = dir:GetAngleDegrees()+90
							proj:Update()
						end
						--[[if k == 0 then
							for i=-1,1,2 do
								local help = Vector.Zero
								if npc.StateFrame == 12 then
									help = data.targetDir:Rotated(180):Resized(30)
								end
								local dir = data.targetDir:Rotated(i*50)
								local proj = Isaac.Spawn(9, 0, 0, npc.Position+dir:Resized(10)+dir:Resized(20)+help, dir:Resized(0.1+(1/npc.StateFrame)), npc):ToProjectile()
								local pData = proj:GetData()
								pData.projType = "Murasa"
								pData.detail = "Anchor1"
								pData.visual = "blueAnimate"
								pData.target = dir:Resized(8)
								proj:GetSprite():Load("gfx/enemies/murasa/variousEffects.anm2",true)
								proj:GetSprite():Play("blueAnimateAppear",true)
								proj.SpriteRotation = dir:GetAngleDegrees()+90
								proj:Update()
							end
						end]]
					end
				end
			end
		end
	
		npc.Velocity = mod:Lerp(npc.Velocity, data.targetDir:Resized(20)*(npc.StateFrame/20), 0.1)
		if npc:CollidesWithGrid() == true then
			npc:PlaySound(mod.Sounds.AnchorCrash, 0.8, 0, false, 1)
			data.state = "Crash"
			npc.StateFrame = 0
			Game():ShakeScreen(17)
			npc.Velocity = Vector.Zero
			if not data.mode then
				data.wall = mod:GetClosestWall(npc.Position, true)
			end
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		end
		local afterimage = Isaac.Spawn(1000, 1750, 2, npc.Position, Vector.Zero, npc):ToEffect()
		afterimage.SpriteRotation = npc.SpriteRotation
		afterimage:Update()
	elseif data.state == "Crash" then
		if npc.StateFrame > 30 then
			data.state = "Return"
		end
		npc.Velocity = Vector.Zero
	elseif data.state == "Return" then
		npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position-npc.Position):Resized(20)*(npc.StateFrame/20), 0.1)
		
		if npc.SpriteRotation > (npc.Position-npc.Parent.Position):GetAngleDegrees() then
			npc.SpriteRotation = npc.SpriteRotation-1
		elseif npc.SpriteRotation ~= (npc.Position-npc.Parent.Position-npc.Position):GetAngleDegrees() then
			npc.SpriteRotation = npc.SpriteRotation+1
		end
		
		if npc.Position:Distance(npc.Parent.Position) < 40 then
			npc:PlaySound(mod.Sounds.AnchorSpawn, 0.5, 0, false, 1)
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.6)
			data.state = "Disappear"
		end
	elseif data.state == "Appear" then
		if sprite:IsFinished("Appear") then
			data.state = "Fly"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Appear")
		end
	elseif data.state == "Disappear" then
		if sprite:IsFinished("Disappear") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Disappear")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.6)
	end
	if not npc.Parent or npc.Parent:GetData().phaseChange == true then
		data.state = "Disappear"
		data.wall = nil
		npc:PlaySound(mod.Sounds.AnchorSpawn, 0.5, 0, false, 1)
	end
end

function mod:anchorAfterimageAI(npc)
	npc:SetColor(Color((255-npc.FrameCount*30)/255, (255-npc.FrameCount*30)/255, (255-npc.FrameCount*10)/255, (180-(npc.FrameCount*30))/255, 0, 0, npc.FrameCount*3), 999, 0, false, false)
	if npc.FrameCount > 10 then
		npc:Remove()
	end
end

function mod:murasaEffects(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	if data.state == "LeavesIn" then
		mod:spritePlay(sprite, "deathLeaf")
		npc:SetColor(Color(1,1,1, ((npc.FrameCount*4)+50)/255,0,0,0), 999, 1, false, false)
		if not data.rotation then
			data.rotation = math.random(-2,2)
		end
		npc.SpriteRotation = npc.SpriteRotation+(data.rotation)
		
		if not npc.Parent or npc.Position:Distance(npc.Parent.Position+Vector(0,-80)) < 10 or npc.FrameCount > 100 then
			npc:Remove()
		elseif npc.Position:Distance(npc.Parent.Position+Vector(0,-80)) < 150 then
			npc.SpriteScale = npc.SpriteScale*0.95
			npc:SetColor(Color(1,1,1, npc.Position:Distance(npc.Parent.Position+Vector(0,-80))/100,0,0,0), 999, 1, false, false)
		end
	elseif data.state == "appearCircle" then
		if sprite:IsFinished("appearCircle") then
			npc:Remove()
		end
	elseif data.state == "deathPulse" then
		if sprite:IsFinished("deathPulse") then
			npc:Remove()
		end
	elseif data.state == "LeavesOut" then
		if not data.rotation then
			data.rotation = math.random(-2,2)
		end
		npc.SpriteRotation = npc.SpriteRotation+(data.rotation)
		npc:SetColor(Color(1,1,1, 1-(npc.FrameCount*4/255),0,0,0), 999, 1, false, false)
	elseif data.state == "LeafExplosion" then
		if not data.rotation then
			data.rotation = math.random(-2,2)
			data.dir = RandomVector()*10
			data.trueScale = npc.SpriteScale
		end
		npc.SpriteRotation = npc.SpriteRotation+(data.rotation)
		if npc.Parent then
			npc.Velocity = mod:Lerp(npc.Velocity, data.dir*0.01, 0.3)
			npc.SpriteScale = Vector(0.5, 0.5)
		else
			npc.Velocity = mod:Lerp(npc.Velocity, data.dir, 0.4)
			npc:SetColor(Color(1,1,1, 1-(npc.FrameCount*4/255),0,0,0), 999, 1, false, false)
			npc.SpriteScale = data.trueScale
		end
	end
	
	if sprite:IsFinished("blueDeath") or sprite:IsFinished("tealDeath") or sprite:IsFinished("blueAnimateDeath") then
		npc:Remove()
	end
end

function mod:murasaHurt(npc, damage, flag, source)
	npc:ToNPC():PlaySound(mod.Sounds.MurasaDamaged, 0.4, 0, false, 1)
end