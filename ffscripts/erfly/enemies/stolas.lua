local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:stolasAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if not d.init then
		npc.TargetPosition = npc.Position
		d.state = "idle"
		d.init = true
		npc.StateFrame = mod:RandomInt(20,50)
	else
		npc.StateFrame = npc.StateFrame - 1
	end

	npc.SpriteOffset = Vector(0, -2)

	npc.Position = npc.TargetPosition
	npc.Velocity = npc.Velocity * 0.1

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame <= 0 then
			d.state = "shoot"
			d.targOff = 0
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = mod:RandomInt(150,200)
		elseif sprite:IsEventTriggered("Shoot") then
			if target.Position.X < npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			local star = Isaac.Spawn(mod.FF.OwlStar.ID, mod.FF.OwlStar.Var, mod.FF.OwlStar.Sub, npc.Position, (target.Position - npc.Position):Resized(5), npc)
			npc:PlaySound(FiendFolio.Sounds.StolasScreech, 5, 0, false, 0.8)
			star.Parent = npc
			star.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			star.SpriteOffset = Vector(0, -60)
			star:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			star:Update()
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end
end

function mod:owlStarProj(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if not d.init then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		d.init = true
	end
	if d.blownthefuckout then
		mod:spritePlay(sprite, "impact")
		npc.Velocity = Vector.Zero
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		if sprite:IsFinished("impact") then
			npc:Remove()
		end
	else
		mod:spritePlay(sprite, "spin")
		npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.1)
		--Reminder for me to pseudorandomize it
		--Every other turn make it more closely follow you (so it only does big 90 degree turns on off ones)
		--Naaaah
		if npc.FrameCount % 20 == 5 then
			npc.StateFrame = npc.StateFrame + 1
			d.vec = (target.Position - npc.Position):Rotated(-60 + math.random(120))
			local projectile = Isaac.Spawn(9,4,0,npc.Position - npc.Velocity:Resized(1),Vector.Zero,npc):ToProjectile()
			projectile.Color = Color(1,1,1,1,0.3,0.5,1)
			projectile.FallingAccel = -0.1
			projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
			projectile:GetData().projType = "stolas"
			d.pitch = d.pitch or 0.2
			npc:PlaySound(SoundEffect.SOUND_SOUL_PICKUP,0.5,0,false,d.pitch)
			d.pitch = d.pitch + 0.1
			if npc.Child and npc.Child:Exists() then
				local laser = npc.Child:ToLaser()
				laser.Parent = projectile
				local child = laser:GetData().Child
				local parent = laser.Parent
			end
			if npc.StateFrame >= 8 then
				d.blownthefuckout = true
			else
				local vec = npc.Position - projectile.Position
				local laser = EntityLaser.ShootAngle(10, npc.Position - Vector(0,1), vec:GetAngleDegrees(), 999999999, Vector(0, -30), npc)
				laser.MaxDistance = vec:Length()
				laser.SubType = 4
				laser.Parent = npc
				laser:GetData().Child = projectile
				laser:GetData().OwlTechZero = true
				laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				laser.CollisionDamage = 0
				npc.Child = laser
			end
			--[[if npc.Child and npc.Child:Exists() then
				local vec = projectile.Position - npc.Child.Position
				local laser = EntityLaser.ShootAngle(10, npc.Position, vec:GetAngleDegrees(), 999999999, Vector(0, -30), npc)
				laser.MaxDistance = vec:Length()
				laser.SubType = 4
				laser.Parent = npc.Child
				laser:GetData().Child = projectile
				laser:GetData().OwlTechZero = true
				laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				laser.CollisionDamage = 0
			end
			npc.Child = projectile]]
		end
		d.vec = d.vec or target.Position - npc.Position
		npc.Velocity = mod:Lerp(npc.Velocity, d.vec:Resized(4), 0.6)
	end
end

function mod:owlStarProjColl(npc)
	npc:GetData().blownthefuckout = true
end

function mod:StolasProjectile(projectile, data)
	if projectile.FrameCount > 90 then
		projectile.FallingAccel = 1
	end
end

function mod:UpdateTechZeroLaser(laser, data)
	if laser.Parent and laser.Parent:Exists() and data.Child and data.Child:Exists() and laser.FrameCount <= 90 then
		local child = data.Child
		local parent = laser.Parent
		laser.Velocity = parent.Position - laser.Position
		local vec = child.Position - laser.Position
		laser.Angle = vec:GetAngleDegrees()
		laser.MaxDistance = vec:Length()
		laser.Mass = 0
	else
		laser:Remove()
	end
end