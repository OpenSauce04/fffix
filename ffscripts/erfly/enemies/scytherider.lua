local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:scytheRiderAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local isPitchy = (npc.Variant == mod.FF.PitchforkHitcher.Var)
	if not d.init then
		d.state = "idle"
		d.scythestate = 1
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		if not isPitchy then
			npc.SplatColor = Color(0,0,0,1,10 / 255,10 / 255,10 / 255)
		end
		npc.StateFrame = 15
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle0" .. d.scythestate)

		--PrimeMind movement
		if npc.Position:Distance(target.Position) < 120 or mod:isScare(npc) then
			d.targetvel = (target.Position - npc.Position):Resized(-10)
			d.running = true
		else
			if d.targetvel == nil or npc.StateFrame % 30 == 0 or d.running or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
				local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (gridtarget - npc.Position):Resized(5)
				d.running = false
			end
		end
		npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)

		if npc.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if npc.StateFrame > 30 and d.scythestate == 1 and math.random(30) == 1 and not mod:isScareOrConfuse(npc) then
			local check
			if isPitchy then
				check = (mod.GetEntityCount(mod.FF.HitcherPitchfork.ID, mod.FF.HitcherPitchfork.Var) < mod.GetEntityCount(mod.FF.PitchforkHitcher.ID, mod.FF.PitchforkHitcher.Var) * 2) 
			else
				check = (mod.GetEntityCount(mod.FF.RiderScythe.ID, mod.FF.RiderScythe.Var) < mod.GetEntityCount(mod.FF.ScytheRider.ID, mod.FF.ScytheRider.Var) * 2)
			end
			if check then
				d.state = "throwscythe"
			end
		elseif npc.StateFrame > 50 and d.scythestate == 2 and math.random(30) == 1 then
			d.state = "spawnnew"
		end
	elseif d.state == "throwscythe" then
		npc.Velocity = npc.Velocity * 0.95
		if npc.Position.X < target.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if sprite:IsFinished("ThrowScythe") then
			d.state = "idle"
			d.scythestate = 2
			npc.StateFrame = 0
		elseif sprite:IsPlaying("ThrowScythe") and sprite:GetFrame() == 10 and not isPitchy then
			npc:PlaySound(mod.Sounds.Archvile,0.3,0,false,math.random(90,110)/100)
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME,1,2,false,0.7)
			local playershoot = (target.Position - npc.Position):Resized(6)
			local scythevar = mod.FF.RiderScythe.Var
			if isPitchy then
				scythevar = mod.FF.HitcherPitchfork.Var
				playershoot = playershoot:Resized(12)
			end
			local scythe = Isaac.Spawn(mod.FF.RiderScythe.ID, scythevar, 0, npc.Position + playershoot:Resized(15), playershoot, v):ToNPC()
			scythe.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			scythe:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			scythe:Update()
		else
			mod:spritePlay(sprite, "ThrowScythe")
		end
	elseif d.state == "spawnnew" then
		npc.Velocity = npc.Velocity * 0.95
		if npc.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if sprite:IsFinished("NewScythe") then
			d.state = "idle"
			d.scythestate = 1
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Barf") then
			npc:PlaySound(mod.Sounds.FlashShakeyKidRoar,1.5,0,false,math.random(80,110)/100)
		else
			mod:spritePlay(sprite, "NewScythe")
		end
	end
	if isPitchy then
		if sprite:IsEventTriggered("Sound") then
			if sprite:IsPlaying("ThrowScythe") then
				npc:PlaySound(mod.Sounds.Archvile,0.3,0,false,math.random(90,110)/100)
			else
				npc:PlaySound(SoundEffect.SOUND_SCAMPER, 0.7, 0, false, 1)
			end
		elseif sprite:IsEventTriggered("Lift") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME,0.7,2,false,0.85)
		end
	end
end

function mod:pitchforkProjAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not data.Init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		sprite:Play("Move")
		data.Angle = npc.Velocity:GetAngleDegrees()
		data.Init = true
	end

	if sprite:IsPlaying("Move") then
		if npc:CollidesWithGrid() then
			sprite:Play("Stick")
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			local stickpos = mod:GetNearestPosOfCollisionClass(npc.Position + npc.Velocity, GridCollisionClass.COLLISION_WALL)
			npc.StateFrame = mod:RandomInt(120,180)
			local vec = stickpos - (npc.Position + npc.Velocity)
			sprite.Rotation = vec:GetAngleDegrees() + 180
			npc.Position = npc.Position + (vec:Resized(vec:Length()/2))
			npc.Velocity = Vector.Zero
			sfx:Play(mod.Sounds.PitchforkHit, 3, 0, false, mod:RandomInt(16,24) * 0.05)
		else
			if npc.FrameCount % 9 == 4 then
				for i = -90, 90, 180 do
					local projectile = Isaac.Spawn(9,0,0,npc.Position, npc.Velocity:Rotated(i):Resized(5), npc):ToProjectile()
					projectile.Color = mod.ColorGehennaFire2
					projectile:AddProjectileFlags(ProjectileFlags.ACCELERATE)
					projectile:GetData().punisher = true
					--projectile:GetData().isRed = true
				end
			end
			sprite.Rotation = npc.Velocity:GetAngleDegrees() + 180
		end
	else
		npc.Velocity = Vector.Zero
		if npc.StateFrame <= 0 then
			sprite:Play("Shoot")
			data.ShootVec = (target.Position - npc.Position):Resized(8)
			npc.StateFrame = mod:RandomInt(120,180)
		else
			npc.StateFrame = npc.StateFrame - 1
		end
		if sprite:IsEventTriggered("Shoot") then
			local projectile = Isaac.Spawn(9,0,0,npc.Position, data.ShootVec, npc):ToProjectile()
			projectile.Color = mod.ColorGehennaFire2
			projectile.Height = -20
			projectile.FallingAccel = -0.03
			projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.ACCELERATE)
			projectile:GetData().punisher = true
			--projectile:GetData().isRed = true
		end
		if game:GetRoom():IsClear() then
			npc:Kill()
		end
	end

	if sprite:IsFinished("Stick") or sprite:IsFinished("Shoot") then
		sprite:Play("Stuck")
	end

end

function mod:scytheRiderScytheAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		if subt == 10 or subt == 11 then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc.CanShutDoors = false
		else
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		end
		npc.SpriteOffset = Vector(0,-20)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		--npc.SplatColor = Color(0,0,0,1,10 / 255,10 / 255,10 / 255)
		d.init = true
	end

	if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
		sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.3, 0, true, 1.5)
	end

	mod:spritePlay(sprite, "spin")
	npc.StateFrame = npc.StateFrame + 1
	if subt == 10 then
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if npc.FrameCount > 1 then
			d.vec = d.vec or (target.Position - npc.Position):Resized(1)
			d.vec = d.vec:Resized(math.min(d.vec:Length() + 1, 20))
			npc.Velocity = d.vec
		end
		if game:GetRoom():GetCenterPos():Distance(npc.Position) > 1000 then
			npc:Remove()
		end
	elseif subt == 11 then
		d.targvel = d.targvel or RandomVector():Resized(5)
		d.targrot = d.targrot or 4.5
		if npc.FrameCount > 150 then
			d.targrot = d.targrot - 0.01
		end
		d.targvel = d.targvel:Rotated(d.targrot)
		d.targvel = d.targvel:Resized(math.min(d.targvel:Length() + 0.3, 50))
		npc.Velocity = d.targvel
		if npc.FrameCount > 350 then
			npc:Remove()
		end
	else
		--Handle sprite nonsense
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		--How it functions
		if npc.StateFrame < 15 then
			d.targvel = d.targvel or (target.Position - npc.Position):Resized(20)
			npc.Velocity = mod:Lerp(npc.Velocity, d.targvel, 0.15)
		else
			npc.Velocity = npc.Velocity * 0.9
			if npc.StateFrame > 45 then
				npc.StateFrame = 0
				d.targvel = nil
			end
		end

	end

	--FUCK LOOPING SOUNDS
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
	end
end

function mod:pitchforkhitcherhurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) and not mod:IsPlayerDamage(source) then
        return false
    end
end

function mod:reaperAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.init = true
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.SplatColor = Color(0,0,0,1,10 / 255,10 / 255,10 / 255)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.SpriteOffset = Vector(0, -10)

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle01")

		--PrimeMind movement
		if npc.Position:Distance(target.Position) < 120 or mod:isScare(npc) then
			d.targetvel = (target.Position - npc.Position):Resized(-10)
			d.running = true
		else
			if d.targetvel == nil or npc.StateFrame % 30 == 0 or d.running or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
				local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (gridtarget - npc.Position):Resized(5)
				d.running = false
			end
		end
		npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)

		if npc.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if (npc.StateFrame > 20 and math.random(30) == 1 or npc.StateFrame > 60) and not mod:isScareOrConfuse(npc) then
			d.state = "attack"
			d.attackChoice = math.random(2)
			d.counter = d.counter or {d.attackChoice, 0}
			d.counter[2] = d.counter[2] + 1
			if d.counter[1] ~= d.attackChoice then
				d.counter = nil
			elseif d.counter[2] >= 3 then
				d.attackChoice = ((d.attackChoice - 1) ~ 1) + 1
				d.counter = nil
			end
		end
	elseif d.state == "attack" then
		npc.Velocity = npc.Velocity * 0.7
		if sprite:IsFinished("Attack0" .. d.attackChoice) then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND,1,1,false,1)
			if d.attackChoice == 1 then
				local corners = mod:getCornerPositions()
				for i = 1, 4 do
					local scythe = Isaac.Spawn(mod.FF.RiderScythe.ID, mod.FF.RiderScythe.Var, 10, corners[i], nilvector, npc)
					scythe.SpawnerEntity = npc
					--scythe:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					scythe.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
					scythe:Update()
				end
			elseif d.attackChoice == 2 then
				local vecFunny = Vector(1, 0)
				for i = 90, 360, 90 do
					local vecReal = vecFunny:Rotated(i)
					local scythe = Isaac.Spawn(mod.FF.RiderScythe.ID, mod.FF.RiderScythe.Var, 11, npc.Position + vecReal:Resized(50), vecReal, npc)
					scythe.SpawnerEntity = npc
					scythe:GetData().targvel = vecReal
					--scythe:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					scythe.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
					scythe:Update()
				end
			end
		else
			mod:spritePlay(sprite, "Attack0" .. d.attackChoice)
		end
	end
end

function mod:getCornerPositions(index)
    local room = game:GetRoom()
	local pos1 = room:GetTopLeftPos()
	local pos2 = room:GetBottomRightPos()
	local arrayofem = {pos1, pos2, Vector(pos1.X, pos2.Y), Vector(pos2.X, pos1.Y)}
	if index then
		return arrayofem[index]
	else
		return arrayofem
	end
end