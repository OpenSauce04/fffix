local mod = FiendFolio
local game = Game()

function mod:k3MikuAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()
	local room = game:GetRoom()
	local rand = npc:GetDropRNG()
	
	local rainbowColor = {
		"Red",
		"Orange",
		"Yellow",
		"Green",
		"Cyan",
		"Blue",
		"Pink",
	}
	
	if not data.init then
		data.init = true
		data.leftHand = npc.Position-Vector(110,200)
		data.centerScreen = Vector(580, 420)
		data.face = npc.Position-Vector(43, 410)
		data.rightHand = npc.Position-Vector(0, 185)
		data.state = "Start"
		--Too large to reasonably put in the mod and also stealing
		--npc:PlaySound(mod.Sounds.K3MikuSong, 1, 0, false, 1)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Start" then
		if npc.FrameCount == 40 then
			data.state = "Attack01"
			local proj = Isaac.Spawn(9, 0, 0, data.centerScreen, Vector.Zero, npc):ToProjectile()
			local pData = proj:GetData()
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			pData.projType = "K3Miku"
			pData.detail = "stayStill"
			pData.pos = data.centerScreen
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Red",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
		end
	elseif data.state == "Attack01" then
		if npc.FrameCount % 6 == 0 and npc.StateFrame < 370 then
			local proj = Isaac.Spawn(9, 0, 0, data.leftHand, (target.Position-data.leftHand):Resized(16), npc):ToProjectile()
			local pData = proj:GetData()
			pData.projType = "K3Miku"
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Yellow",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
		end
		if npc.StateFrame > 110 and npc.StateFrame < 380 and (npc.StateFrame-115) % 85 == 0 then
			for i=0,15 do
				local proj = Isaac.Spawn(9, 0, 0, data.centerScreen, Vector(0,10):Rotated(24*i), npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "K3Miku"
				pData.detail = "a1Explode"
				pData.target = target
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
				proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
				proj:GetSprite():Play("Red",true)
				proj.SpriteScale = Vector(0.8, 0.8)
				proj:Update()
			end
		end
		if npc.StateFrame >= 470 then
			data.attackVector = Vector(-8, 0)
			data.state = "Attack02"
			npc.StateFrame = 0
		end
	elseif data.state == "Attack02" then
		if npc.FrameCount % 2 == 0 then
			local xMult = -1
			local yMult = -1
			if data.attackVector.X < 0 then
				xMult = 1
			end
			if data.attackVector.Y < 0 then
				yMult = 1
			end
			local proj = Isaac.Spawn(9, 0, 0, data.centerScreen+(xMult*Vector(580,0))+Vector(0,-450+rand:RandomInt(900)), data.attackVector, npc):ToProjectile()
			local pData = proj:GetData()
			pData.projType = "K3Miku"
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Red",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
			
			local proj = Isaac.Spawn(9, 0, 0, data.centerScreen+(yMult*Vector(0,420))+Vector(-580+rand:RandomInt(1160),0), data.attackVector, npc):ToProjectile()
			local pData = proj:GetData()
			pData.projType = "K3Miku"
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Red",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
		end
		data.attackVector = data.attackVector:Rotated(-1)
		
		if npc.StateFrame > 300 then
			data.state = "Attack03"
			data.cherryCount = 0
			npc.StateFrame = 0
		end
	elseif data.state == "Attack03" then
		if npc.StateFrame > 24 and (npc.StateFrame-25) % 10 == 0 and data.cherryCount < 3 then
			local pPos = data.centerScreen-Vector(250,120)+data.cherryCount*Vector(250,0)
			local proj = Isaac.Spawn(9, 0, 0, pPos, Vector.Zero, npc):ToProjectile()
			local pData = proj:GetData()
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			pData.projType = "K3Miku"
			pData.detail = "a3StayStill"
			pData.pos = pPos
			pData.target = target
			pData.num = data.cherryCount
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Red",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
			data.cherryCount = data.cherryCount+1
		end
		if npc.StateFrame > 110 then
			data.state = "Attack04"
			data.cherryCount = 1
			npc.StateFrame = 0
		end
	elseif data.state == "Attack04" then
		if npc.FrameCount % 5 == 0 then
			if npc.StateFrame < 130 then
				for i=0,2 do
					local proj = Isaac.Spawn(9, 0, 0, data.centerScreen+Vector(580,0)+Vector(0,-450+rand:RandomInt(900)), Vector(-12,0):Rotated(-40+rand:RandomInt(80)), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Red",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
			elseif npc.StateFrame > 180 and npc.StateFrame < 310 then
				for i=0,2 do
					local proj = Isaac.Spawn(9, 0, 0, data.centerScreen-Vector(580,0)+Vector(0,-450+rand:RandomInt(900)), Vector(12,0):Rotated(-40+rand:RandomInt(80)), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Blue",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
			end
		end
		if npc.FrameCount % 9 == 0 then
			if npc.StateFrame < 130 then
				local proj = Isaac.Spawn(9, 0, 0, data.leftHand, RandomVector()*12, npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "K3Miku"
				pData.detail = "a4Bounce"
				pData.part = 1
				pData.colorCount = data.cherryCount
				pData.rainbowColor = rainbowColor
				pData.target = target
				proj.Parent = npc
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.BOUNCE
				proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
				proj:GetSprite():Play(rainbowColor[data.cherryCount],true)
				proj.SpriteScale = Vector(2.2, 2.2)
				proj.Size = 50
				proj:Update()
				data.cherryCount = data.cherryCount+1
				if data.cherryCount == 8 then
					data.cherryCount = 1
				end
			elseif npc.StateFrame > 180 and npc.StateFrame < 310 then
				local proj = Isaac.Spawn(9, 0, 0, data.leftHand, RandomVector()*12, npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "K3Miku"
				pData.detail = "a4Bounce"
				pData.part = 2
				pData.colorCount = data.cherryCount
				pData.rainbowColor = rainbowColor
				pData.target = target
				proj.Parent = npc
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.BOUNCE
				proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
				proj:GetSprite():Play(rainbowColor[data.cherryCount],true)
				proj.SpriteScale = Vector(2.2, 2.2)
				proj.Size = 50
				proj:Update()
				data.cherryCount = data.cherryCount+1
				if data.cherryCount == 8 then
					data.cherryCount = 1
				end
			elseif not data.freeze1 and npc.StateFrame > 155 then
				data.cherryCount = 1
				data.freeze1 = true
			elseif not data.freeze2 and npc.StateFrame > 325 then
				data.freeze2 = true
				data.popCount = 0
			end
			
			if npc.StateFrame > 430 then
				data.state = "Attack05"
				npc.StateFrame = 8
				data.attackVector = Vector(14,0):Rotated(-3)
				data.freeze1 = nil
				data.freeze2 = nil
			elseif npc.StateFrame > 345 and (npc.StateFrame-335) % 3 == 0 then
				data.popCount = data.popCount+1
			end
		end
	elseif data.state == "Attack05" then
		if npc.StateFrame % 9 == 0 then
			if npc.StateFrame < 145 then
				for i=0,15 do
					local proj = Isaac.Spawn(9, 0, 0, data.centerScreen, data.attackVector:Rotated(24*i), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					pData.detail = "a5Freeze"
					pData.smallerExpire = true
					pData.part = 1
					proj.Parent = npc
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Yellow",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
				data.attackVector = data.attackVector:Rotated(-8)
			elseif npc.StateFrame > 165 and npc.StateFrame < 290 then
				for i=0,15 do
					local proj = Isaac.Spawn(9, 0, 0, data.centerScreen, data.attackVector:Rotated(24*i), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					pData.detail = "a5Freeze"
					pData.smallerExpire = true
					pData.part = 2
					proj.Parent = npc
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Green",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
				data.attackVector = data.attackVector:Rotated(8)
			elseif not data.freeze1 and npc.StateFrame > 145 then
				data.freeze1 = true
				data.attackVector = Vector(14,0):Rotated(7)
			elseif not data.spin and npc.StateFrame > 290 then
				data.spin = true
			elseif not data.burst and npc.StateFrame > 315 then
				data.burst = true
			elseif npc.StateFrame > 350 then
				data.state = "Attack06"
				data.colorCount = "Red"
				npc.StateFrame = 0
			end
		end
	elseif data.state == "Attack06" then
		if npc.StateFrame < 294 then
			if npc.StateFrame % 2 == 0 then
				if npc.StateFrame > 196 then
					data.colorCount = "Yellow"
				elseif npc.StateFrame > 98 then
					data.colorCount = "Blue"
				end
				local proj = Isaac.Spawn(9, 0, 0, data.centerScreen+Vector(-580+rand:RandomInt(1160),380), Vector(0,-1), npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "K3Miku"
				pData.detail = "a6Rise"
				proj.Parent = npc
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
				proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
				proj:GetSprite():Play(data.colorCount,true)
				proj.SpriteScale = Vector(0.8, 0.8)
				proj:Update()
			end
		elseif data.burst == true then
			data.burst = false
		end
		
		if npc.StateFrame > 300 then
			data.state = "Attack07"
			npc.StateFrame = 0
			data.burstTimer = 0
		end
	elseif data.state == "Attack07" then
		if npc.StateFrame % 9 == 0 and npc.StateFrame < 620 then
			local proj = Isaac.Spawn(9, 0, 0, data.leftHand, Vector(-13,0):Rotated(-80+rand:RandomInt(140)), npc):ToProjectile()
			local pData = proj:GetData()
			pData.projType = "K3Miku"
			pData.detail = "a7Burst"
			pData.target = target
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Green",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
		end
		
		if npc.StateFrame == 120 or npc.StateFrame == 285 or npc.StateFrame == 450 or npc.StateFrame == 620 then
			if npc.StateFrame == 120 or npc.StateFrame == 450 then
				data.burstTimer = 80
			else
				data.burstTimer = 70
			end
		end
		
		if data.burstTimer > 0 then
			if data.burstTimer % 10 == 0 then
				for i=0,35 do
					local proj = Isaac.Spawn(9, 0, 0, data.face, (target.Position-data.face):Resized(21):Rotated(10*i), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Purple",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
			end
			data.burstTimer = data.burstTimer-1
		end
		
		if npc.StateFrame > 370 and npc.StateFrame < 620 then
			local proj = Isaac.Spawn(9, 0, 0, data.rightHand, Vector(-13,0):Rotated(-80+rand:RandomInt(140)), npc):ToProjectile()
			local pData = proj:GetData()
			pData.projType = "K3Miku"
			pData.curve = rand:RandomInt(2)
			pData.detail = "a7Curve"
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
			proj:GetSprite():Play("Cyan",true)
			proj.SpriteScale = Vector(0.8, 0.8)
			proj:Update()
		elseif npc.StateFrame > 700 then
			data.state = "Attack08"
			npc.StateFrame = 0
		end
	elseif data.state == "Attack08" then
		if npc.StateFrame < 280 then
			if npc.StateFrame % 3 == 0 then
				local proj = Isaac.Spawn(9, 0, 0, data.face, Vector(-10,0):Rotated(-70+rand:RandomInt(140)), npc):ToProjectile()
				local pData = proj:GetData()
				pData.projType = "K3Miku"
				pData.detail = "a8Bounce"
				pData.center = data.centerScreen
				proj.Parent = npc
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.BOUNCE
				proj.Size = 10
				proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
				proj:GetSprite():Play("Cyan",true)
				proj:Update()
			end
		elseif npc.StateFrame < 430 then
			data.center = true
		else
			npc:Remove()
		end
	end
end

function mod.k3MikuProj(v, d)
	if d.projType == "K3Miku" then
		v.CollisionDamage = 20
		local sprite = v:GetSprite()
		v.FallingSpeed = 0
		v.FallingAccel = -3
		
		if d.detail == "stayStill" then
			v.Position = d.pos
			if v.FrameCount > 325 then
				v:Remove()
			end
		elseif d.detail == "a1Explode" then
			if v.FrameCount > 14 then
				for i=0,15 do
					local proj = Isaac.Spawn(9, 0, 0, v.Position, (d.target.Position-v.Position):Resized(16):Rotated(24*i), v):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Red",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
				v:Remove()
			end
		elseif d.detail == "a3StayStill" then
			v.Position = d.pos
			
			if v.FrameCount+d.num*10 > 40 then
				sprite:Play("Blue")
			end
			
			if v.FrameCount > 50 then
				local offset = 3
				if d.num == 1 then
					offset = 0
				end
				for i=1,60 do
					local proj = Isaac.Spawn(9, 0, 0, v.Position, (d.target.Position-v.Position):Resized(28):Rotated(offset+6*i), v):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Blue",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
				v:Remove()
			end
		elseif d.detail == "a4Bounce" then
			if v.Parent then
				local parData = v.Parent:GetData()
				if d.part == 1 then
					if parData.freeze1 and not d.freezePos then
						d.freezePos = v.Position
						v.Velocity = Vector.Zero
						v.Position = d.freezePos
						sprite:Play("Grey")
					end
				else
					if parData.freeze2 and not d.freezePos then
						d.freezePos = v.Position
						v.Velocity = Vector.Zero
						v.Position = d.freezePos
						sprite:Play("Grey")
					end
				end
				if d.freezePos then
					v.Velocity = Vector.Zero
					v.Position = d.freezePos
					
					if parData.popCount and parData.popCount == d.colorCount then
						for i=0,6 do
							local proj = Isaac.Spawn(9, 0, 0, v.Position, (d.target.Position-v.Position):Resized(18):Rotated(51.5*i), v):ToProjectile()
							local pData = proj:GetData()
							pData.projType = "K3Miku"
							proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
							proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
							proj:GetSprite():Play(d.rainbowColor[d.colorCount],true)
							proj.SpriteScale = Vector(0.8, 0.8)
							proj:Update()
						end
						v:Remove()
					end
				end
			end
		elseif d.detail == "a5Freeze" then
			if v.Parent then
				local parData = v.Parent:GetData()
				if d.part == 1 then
					if parData.freeze1 and not d.freezePos then
						d.freezePos = v.Position
						v.Velocity = Vector.Zero
						v.Position = d.freezePos
						sprite:Play("Grey")
					end
				else
					if parData.spin and not d.init then
						d.freezePos = true
						sprite:Play("Grey")
						d.dist = (v.Position-Vector(580, 420)):Length()
						d.angle = (v.Position-Vector(580, 420)):GetAngleDegrees()
						d.init = true
					end
				end
				if d.freezePos then
					if not d.init then
						d.dist = (v.Position-Vector(580, 420)):Length()
						d.angle = (v.Position-Vector(580, 420)):GetAngleDegrees()
						d.init = true
					end
					if parData.burst then
						if not d.bVector then
							d.bVector = RandomVector()*13
						end
						v.Velocity = d.bVector
					elseif parData.spin then
						local targetPos = Vector(580, 420)+Vector.FromAngle(d.angle):Resized(d.dist)
						v.Velocity = mod:Lerp(v.Velocity, targetPos-v.Position, 0.8)
						v.Position = targetPos
						d.angle = d.angle+11
					else
						v.Velocity = Vector.Zero
						v.Position = d.freezePos
					end
				end
			end
		elseif d.detail == "a6Rise" then
			if v.Parent then
				if v.Parent:GetData().burst == false then
					if not d.bVector then
						d.bVector = RandomVector()*16
					end
					v.Velocity = d.bVector
				end
			end
		elseif d.detail == "a7Burst" then
			if v.FrameCount > 9 then
				for i=0,7 do
					local proj = Isaac.Spawn(9, 0, 0, v.Position, (d.target.Position-v.Position):Resized(14):Rotated(45*i), v):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "K3Miku"
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					proj:GetSprite():Load("gfx/enemies/miku/deliciousFruit.anm2",true)
					proj:GetSprite():Play("Green",true)
					proj.SpriteScale = Vector(0.8, 0.8)
					proj:Update()
				end
				v:Remove()
			end
		elseif d.detail == "a7Curve" then
			if d.curve == 1 then
				v.Velocity = v.Velocity:Rotated(-1)
			else
				v.Velocity = v.Velocity:Rotated(1)
			end
		elseif d.detail == "a8Bounce" then
			if v.Parent then
				if v.Parent:GetData().center then
					if not d.bVector then
						d.bVector = (d.center-v.Position):Resized(16)
						v:ClearProjectileFlags(ProjectileFlags.BOUNCE)
						v.ProjectileFlags = v.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
					end
				end
			end
			if d.bVector then
				v.Velocity = d.bVector
			end
		end
		if d.smallerExpire then
			if v.Position.X < 0 or v.Position.X > 1160 or v.Position.Y < 0 or v.Position.Y > 840 then
				v:Remove()
			end
		else
			if v.Position.X < -50 or v.Position.X > 1250 or v.Position.Y < -50 or v.Position.Y > 950 then
				v:Remove()
			end
		end
	end
end