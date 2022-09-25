local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:peepisserAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Idle"
		data.movement = rand:RandomInt(30)+20
		npc.StateFrame = 20
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Idle" then
		if mod:isScare(npc) then
			if npc.Velocity.X > -0.3 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
			mod:spritePlay(sprite, "Idle")
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif data.movement > 0 then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			mod:spritePlay(sprite, "Idle")
			data.movement = data.movement-1
			
			if npc.StateFrame > 30 and rand:RandomInt(40) == 5 and not mod:isScareOrConfuse(npc) then
				if target.Position.X > npc.Position.X then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
				data.state = "Pissing Start"
			elseif npc.StateFrame > 70 and not mod:isScareOrConfuse(npc) then
				if target.Position.X > npc.Position.X then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
				data.state = "Pissing Start"
			end
		elseif not data.goHere then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			if npc.Position:Distance(target.Position) < 80 then
				data.goHere = mod:FindClosestValidPosition(npc, target, 60, 120, 1)
			elseif npc.Pathfinder:HasPathToPos(target.Position) then
				if npc.Position:Distance(target.Position) > 300 then
					data.goHere = mod:FindClosestValidPosition(npc, target, 60, 200, 0)
				else
					data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 120)
				end
			else
				data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 120)
			end
			data.movement = math.floor(-(npc.Position:Distance(data.goHere)*2))
		elseif data.movement < 0 then
			if npc.Velocity.X > -0.3 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
			mod:spritePlay(sprite, "Walk")
			data.movement = data.movement+1
			if npc.Position:Distance(data.goHere) < 25 then
				data.movement = 25+rand:RandomInt(30)
				data.goHere = nil
			elseif room:CheckLine(npc.Position, data.goHere, 0, 1, false, false) then
				local targetvel = (data.goHere - npc.Position):Resized(2)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
			else
				npc.Pathfinder:FindGridPath(data.goHere, 0.3, 900, true)
			end
		else
			data.movement = 10
			data.goHere = nil
		end
	elseif data.state == "Pissing" then
		if npc.FrameCount % 10 == 0 then
			local dir = Vector(math.random(3,6), -math.random(1,4))
			if sprite.FlipX == true then
				dir = Vector(-math.random(3,6), -math.random(1,4))
			end
			local droplet = Isaac.Spawn(1000, 1750, 4, npc.Position+Vector(0,-10), dir, npc):ToEffect()
			droplet.PositionOffset = Vector(dir.X, dir.Y)
			droplet:GetData().dir = dir
			droplet:SetColor(Color(0.72, 1, 1, 1, 0.305, 0.785, 0), 100, 5, true, false)
			droplet.DepthOffset = -10
			droplet:Update()
		end
		npc.Velocity = Vector.Zero
		if npc.Position:Distance(target.Position) < 135 and npc.StateFrame > 40 or data.interrupt > 1 then
			data.state = "Kick"
			data.movement = 5
			if data.sound ~= nil then
				sfx:Stop(data.sound)
			end
		elseif npc.StateFrame > 230 then
			data.state = "Kick"
			data.movement = 5
			if data.sound ~= nil then
				sfx:Stop(data.sound)
			end
		else
			mod:spritePlay(sprite, "PissLoop")
		end
		
		data.pissFullness = npc.StateFrame
	elseif data.state == "Pissing Start" then
		if sprite:IsFinished("PissStart") then
			data.sound = nil
			data.interrupt = 0
			if not sfx:IsPlaying(mod.Sounds.PeeLong1) then
				sfx:Play(mod.Sounds.PeeLong1, 0.6, 0, false, 1.2, 0)
				data.sound = mod.Sounds.PeeLong1
			elseif not sfx:IsPlaying(mod.Sounds.PeeLong2) then
				sfx:Play(mod.Sounds.PeeLong2, 0.6, 0, false, 1.2, 0)
				data.sound = mod.Sounds.PeeLong2
			end
			data.state = "Pissing"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR, 0.6, 0, false, 1.4)
		elseif sprite:IsEventTriggered("Bucket") then
			npc:PlaySound(mod.Sounds.BucketClang, 0.5, 0, false, 1)
		else
			mod:spritePlay(sprite, "PissStart")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "Kick" then
		if sprite:IsFinished("Kick") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Bucket") then
			local water = room:HasWater()
			if mod:isFriend(npc) then
				data.wasFriend = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
			elseif mod:isCharm(npc) then
				data.wasFriend = ProjectileFlags.HIT_ENEMIES
			else
				data.wasFriend = nil
			end
			npc:PlaySound(mod.Sounds.BucketKick, 1.4, 0, false, 1.2)
			if data.pissFullness > 100 then
				for i=0,math.floor(data.pissFullness/25) do
					local fallingSpeed = (30+rand:RandomInt(120))/5
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position-npc.Position):Resized(90/fallingSpeed):Rotated(-30+rand:RandomInt(60)), npc):ToProjectile()
					proj:GetData().projType = "Peepisser"
					proj:GetData().detail = "Pee"
					proj:GetData().wasFriend = data.wasFriend
					proj:GetData().creepTimeout = 90
					proj:GetData().water = water
					proj.FallingSpeed = -fallingSpeed
					proj.FallingAccel = (rand:RandomInt(10)+8)/10
					proj.Color = mod.ColorPeepPiss
					if data.wasFriend ~= nil then
						proj.ProjectileFlags = proj.ProjectileFlags | data.wasFriend
					end
					proj:Update()
					--[[local params = ProjectileParams()
					params.FallingSpeedModifier = -(30+rand:RandomInt(120))/5
					params.FallingAccelModifier = (rand:RandomInt(10)+8)/10
					params.Color = mod.ColorPeepPiss
					npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(90/(-1*params.FallingSpeedModifier)):Rotated(-30+rand:RandomInt(60)), 0, params)]]
				end
			end
			local bucket = nil
			local lobbed = true
			local dir = (target.Position-npc.Position)*0.043
			if room:CheckLine(npc.Position, target.Position, 3, 1, false, false) then
				bucket = Isaac.Spawn(mod.FFID.Ferrium, mod.FF.PeeBucket.Var, 0, npc.Position, (target.Position-npc.Position)*0.043, npc)
				lobbed = false
			else
				bucket = Isaac.Spawn(mod.FFID.Ferrium, mod.FF.PeeBucket.Var, 0, npc.Position, (target.Position-npc.Position)*0.025, npc)
				dir = (target.Position-npc.Position)*0.025
			end
			local bData = bucket:GetData()
			bData.pissFullness = data.pissFullness
			bData.dir = dir
			bucket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			if data.wasFriend ~= nil then
				bData.wasFriend = data.wasFriend
			end
			bData.water = water
			if lobbed == false then
				bData.zVel = -7
			else
				bData.zVel = -10
				bData.lobbed = true
			end
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_FAT_GRUNT, 0.5, 0, false, 1.5)
		else
			mod:spritePlay(sprite, "Kick")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	end
	
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		if data.sound ~= nil then
			sfx:Stop(data.sound)
		end
	end
end

function mod:peepisserHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.state == "Pissing" then
		if damage < 8 then
			data.interrupt = data.interrupt+1
		else
			data.interrupt = data.interrupt+2
		end
	end
end

function mod:peeBucketAI(npc)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	local sprite = npc:GetSprite()
	local room = game:GetRoom()
	
	if not data.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_TARGET)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		data.pissFullness = data.pissFullness or 0
		data.zVel = data.zVel or -5
		data.dir = data.dir or Vector.Zero
		data.init = true
	end
	mod:spritePlay(sprite, "Filled")
	
	if npc.PositionOffset.Y <= -60 or (data.lobbed == true and npc.FrameCount < 5) then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	else
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	end
	
	npc.Velocity = mod:Lerp(npc.Velocity, data.dir, 0.3)
	npc.PositionOffset = Vector(0, npc.PositionOffset.Y + data.zVel)
	data.zVel = data.zVel+0.5
	
	if data.pissFullness > 170 then
		local spinValue = math.floor(450/data.pissFullness)
		if npc.FrameCount % spinValue == 0 then
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector():Resized(rand:RandomInt(7)/5), npc):ToProjectile()
			proj:GetData().projType = "Peepisser"
			proj:GetData().detail = "Pee"
			proj:GetData().wasFriend = data.wasFriend
			proj:GetData().water = data.water
			local creepTimeout = 90
			if npc.FrameCount < 50 then
				creepTimeout = 140-npc.FrameCount
			end
			proj:GetData().creepTimeout = creepTimeout
			proj.Height = npc.PositionOffset.Y
			proj.Color = mod.ColorPeepPiss
			proj.FallingAccel = (rand:RandomInt(10)+8)/10
			proj.Scale = (3+rand:RandomInt(5))/12
			if data.wasFriend ~= nil then
				proj.ProjectileFlags = proj.ProjectileFlags | data.wasFriend
			end
			proj:Update()
		end
	end
	
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) or data.hitPlayer ~= nil or data.damaged == true then
		npc:PlaySound(SoundEffect.SOUND_POT_BREAK, 0.4, 0, false, 1)
		local pissAmount = math.floor(data.pissFullness/12)
		local offset = rand:RandomInt(360)
		for i=0,pissAmount do
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,6+rand:RandomInt(10)/10):Rotated(360/pissAmount*i+offset), npc):ToProjectile()
			proj:GetData().projType = "Peepisser"
			proj:GetData().detail = "Pee"
			proj:GetData().wasFriend = data.wasFriend
			proj:GetData().creepTimeout = math.max(90, math.floor(data.pissFullness * 1.5))
			proj:GetData().water = data.water
			proj.FallingAccel = 0.3
			proj.Color = mod.ColorPeepPiss
			proj.Height = npc.PositionOffset.Y
			if data.wasFriend ~= nil then
				proj.ProjectileFlags = proj.ProjectileFlags | data.wasFriend
			end
			proj:Update()
			local fallingSpeed = (30+rand:RandomInt(150))/5
			local proj2 = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector():Resized(70/(fallingSpeed)), npc):ToProjectile()
			proj2:GetData().projType = "Peepisser"
			proj2:GetData().detail = "Pee"
			proj2:GetData().wasFriend = data.wasFriend
			proj:GetData().water = data.water
			proj2:GetData().creepTimeout = math.max(90, math.floor(data.pissFullness * 1.5))
			proj2.Color = mod.ColorPeepPiss
			proj2.Height = npc.PositionOffset.Y
			proj2.FallingSpeed = -fallingSpeed
			proj2.FallingAccel = (rand:RandomInt(10)+8)/6
			if data.wasFriend ~= nil then
				proj2.ProjectileFlags = proj2.ProjectileFlags | data.wasFriend
			end
			proj2:Update()
			--[[local params = ProjectileParams()
			params.FallingSpeedModifier = -(30+rand:RandomInt(200))/5
			params.FallingAccelModifier = (rand:RandomInt(10)+8)/10
			params.Color = mod.ColorPeepPiss
			npc:FireProjectiles(npc.Position, RandomVector():Resized(70/(-1*params.FallingSpeedModifier)), 0, params)]]
		end
		--[[if data.hitPlayer ~= nil then
			data.hitPlayer.Color = mod.ColorPeepPiss
		end]]
		local bucket = Isaac.Spawn(9, 8, 0, npc.Position, RandomVector():Resized(rand:RandomInt(3)), npc):ToProjectile()
		local pSprite = bucket:GetSprite()
		pSprite:Load("gfx/projectiles/projectile_bucket.anm2", true)
		pSprite:Play("Empty", true)
		bucket:GetData().projType = "Peepisser"
		bucket:GetData().detail = "Bucket"
		bucket.FallingAccel = 0.9
		bucket.FallingSpeed = -(30+rand:RandomInt(50))/5
		bucket.Height = npc.PositionOffset.Y
		if data.wasFriend ~= nil then
			bucket.ProjectileFlags = bucket.ProjectileFlags | data.wasFriend
		end
		bucket:Update()
		npc:Remove()
	elseif npc:CollidesWithGrid() or npc.PositionOffset.Y >= 0 then
		npc:PlaySound(SoundEffect.SOUND_POT_BREAK, 0.4, 0, false, 1)
		local pissAmount = math.floor(data.pissFullness/16)
		local fallingSpeed = -(30+rand:RandomInt(120))/5
		local offset = rand:RandomInt(360)
		for i=0,pissAmount do
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,5):Rotated(360/pissAmount*i+offset), npc):ToProjectile()
			proj:GetData().projType = "Peepisser"
			proj:GetData().detail = "Pee"
			proj:GetData().wasFriend = data.wasFriend
			proj:GetData().water = data.water
			proj:GetData().creepTimeout = math.max(90, math.floor(data.pissFullness * 1.5))
			proj.FallingAccel = 1.3
			proj.FallingSpeed = fallingSpeed
			proj.Color = mod.ColorPeepPiss
			if data.wasFriend ~= nil then
				proj.ProjectileFlags = proj.ProjectileFlags | data.wasFriend
			end
			proj:Update()
			--[[local params = ProjectileParams()
			params.FallingSpeedModifier = -(30+rand:RandomInt(120))/5
			params.FallingAccelModifier = (rand:RandomInt(10)+8)/10
			params.Color = mod.ColorPeepPiss
			npc:FireProjectiles(npc.Position, RandomVector():Resized(40/(-1*params.FallingSpeedModifier)), 0, params)]]
		end
		local bucket = Isaac.Spawn(9, 8, 0, npc.Position, RandomVector():Resized(rand:RandomInt(3)), npc):ToProjectile()
		local pSprite = bucket:GetSprite()
		pSprite:Load("gfx/projectiles/projectile_bucket.anm2", true)
		pSprite:Play("Empty", true)
		bucket:GetData().projType = "Peepisser"
		bucket:GetData().detail = "Bucket"
		bucket.FallingAccel = 0.9
		bucket.FallingSpeed = -(30+rand:RandomInt(50))/5
		if data.wasFriend ~= nil then
			bucket.ProjectileFlags = bucket.ProjectileFlags | data.wasFriend
		end
		bucket:Update()
		if data.water == false and data.wasFriend == nil then
			local creep = Isaac.Spawn(1000, 24, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep:SetTimeout(math.max(90, math.floor(data.pissFullness * 1.5)))
			creep.SpriteScale = Vector(1+(data.pissFullness/80),1+(data.pissFullness/80))
			creep:Update()
		end
		npc:Remove()
	end
end

function mod:peeBucketCollision(npc, collider, mysteryBoolean)
	if collider.Type == 1 then
		npc:GetData().hitPlayer = collider:ToPlayer()
	end
end

function mod:peeBucketHurt(npc, damage, flag, source)
	npc:GetData().damaged = true
	return false
end

function mod.peepisserProj(v, d)
	local room = game:GetRoom()
	if d.projType == "Peepisser" then
		if d.detail == "Pee" then
			if v:IsDead() then
				if d.water == false and d.wasFriend == nil then
					local creep = Isaac.Spawn(1000, 24, 0, v.Position, Vector.Zero, v):ToEffect()
					creep.Scale = 0.8
					creep:SetTimeout(d.creepTimeout) 
					creep:Update()
				end
			end
		end
	end
	if d.detail == "Bucket" then
		if v:IsDead() then
			sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.4, 0, false, 1)
			for i=0,3 do
				local gibs = Isaac.Spawn(1000, 4, 0, v.Position, RandomVector()*(math.random(10,120)/30), v):ToEffect()
				local gSprite = gibs:GetSprite()
				gibs:Update()
				gSprite:SetFrame("rubble_alt", math.random(4))
				gSprite:ReplaceSpritesheet(0, "gfx/grid/rocks_dross.png")
				gSprite.Rotation = math.random(360)
				gSprite:LoadGraphics()
				gibs:Update()
			end
		end
	end
end

function mod.peepisserProjColl(v, d)
	if d.detail == "Bucket" then
		sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.4, 0, false, 1)
		for i=0,3 do
			local gibs = Isaac.Spawn(1000, 4, 0, v.Position, RandomVector()*(math.random(10,120)/30), v):ToEffect()
			local gSprite = gibs:GetSprite()
			gibs:Update()
			gSprite:SetFrame("rubble_alt", math.random(4))
			gSprite:ReplaceSpritesheet(0, "gfx/grid/rocks_dross.png")
			gSprite.Rotation = math.random(360)
			gSprite:LoadGraphics()
			gibs:Update()
		end
	end
end

function mod:pissDropletsEffect(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	if not data.init then
		data.randomOrient = math.random(2)
		data.init = true
	end
	
	if npc.PositionOffset.Y < 0 then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
		npc:SetColor(Color(0.72, 1, 1, 1, 0.305, 0.785, 0), 100, 5, true, false)
		mod:spritePlay(sprite, "Droplets")
		sprite.Rotation = data.dir:GetAngleDegrees()-90
		sprite.Scale = Vector(data.dir:Length()/9, 1)
		npc.PositionOffset = mod:Lerp(npc.PositionOffset, Vector(0, npc.PositionOffset.Y+data.dir.Y*2), 0.3)
		data.dir = data.dir+Vector(0,npc.FrameCount/5)
	else
		npc.Velocity = Vector.Zero
		sprite.Rotation = 0
		sprite.Scale = Vector(1, 1)
		if data.randomOrient == 1 then
			sprite.FlipX = true
		end
			
		if sprite:IsFinished("Splat") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Splat")
		end
	end
end