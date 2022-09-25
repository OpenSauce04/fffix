local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:bunkerWormAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "emerge"
		d.init = true
		npc.TargetPosition = npc.Position
		npc.PositionOffset = Vector(0,10)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	else
		npc.StateFrame = npc.StateFrame + 1
	end
	npc.Velocity = nilvector
	if npc.TargetPosition then
		npc.Position = npc.TargetPosition
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 20 and (r:RandomInt(10) == 1 or not d.firstshot) then
			if not mod:isScareOrConfuse(npc) then
				d.state = "shoot"
				d.shoot = d.shoot or 1
				d.firstshot = true
				d.vec = target.Position - npc.Position
			else
				d.state = "submerge"
				npc.StateFrame = 0
			end
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished() then
			if d.shoot == 1 then
				d.state = "submerge"
				npc.StateFrame = 0
			else
				d.shoot = 1
				d.state = "idle"
				npc.StateFrame = 50
				--mod:spritePlay(sprite, "Shoot0" .. d.shoot)
			end
		elseif sprite:IsEventTriggered("Shoot") then
			if d.shoot == 2 then
				npc:PlaySound(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, math.random(115,125)/100)
				if d.Shotty and d.Shotty:Exists() then
					targetpos = mod:confusePos(npc, d.Shotty.Position)
				end
				local vel = (targetpos-npc.Position)/15
				mod:FlipSprite(sprite, npc.Position, targetpos)
				local projectile = Isaac.Spawn(9,0,0,npc.Position,vel,npc):ToProjectile()
				projectile.Height = -60
				projectile.FallingSpeed = -15
				projectile.FallingAccel = 2
				projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				projectile:GetData().projType = "LilBunkerShot"
				mod:ProjectileFriendCheck(npc, projectile)
				if d.Shotty and d.Shotty:Exists() then
					projectile:GetData().TargetShot = d.Shotty:ToProjectile()
				end
				local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc):ToEffect()
				effect.DepthOffset = npc.Position.Y * 1.25
				if sprite.FlipX then
					effect.SpriteOffset = Vector(0,-30)
				else
					effect.SpriteOffset = Vector(5,-30)
				end
			else
				npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR, 1, 0, false, math.random(90,110)/100)
				local shootvec = (targetpos - npc.Position):Resized(15)
				mod:FlipSprite(sprite, npc.Position, npc.Position + shootvec)
				local projectile = Isaac.Spawn(9,0,0,npc.Position,shootvec,npc):ToProjectile()
				projectile.Scale = 2.5
				projectile.FallingAccel = -0.092
				projectile:GetData().projType = "BigBunkerShot"
				projectile:AddProjectileFlags(ProjectileFlags.BOUNCE)
				projectile.Color = mod.ColorDecentlyRed
				mod:ProjectileFriendCheck(npc, projectile)
				d.Shotty = projectile
				local effect = Isaac.Spawn(1000,16,5,npc.Position,Vector.Zero,npc):ToEffect()
				effect.DepthOffset = npc.Position.Y * 1.25
				effect:GetSprite().Scale = effect:GetSprite().Scale * 0.4
				effect.Color = Color(1,1,1,0.3)
				effect.SpriteOffset = Vector(0,-10)
				effect:Update()
				for i = -60, 60, 15 do
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector(0, -5):Rotated(i - 10 + math.random(20)), npc):ToEffect()
					smoke.SpriteRotation = mod:RandomAngle()
					smoke.Color = Color(1,1,1,0.5,0.7,0,0)
					smoke.SpriteScale = smoke.SpriteScale * mod:RandomInt(70,100)/100
					smoke.DepthOffset = npc.Position.Y * 1.25
					smoke.SpriteOffset = Vector(0,-10)
					smoke:Update()
				end
			end
		elseif sprite:IsEventTriggered("PreShoot") then
			npc:PlaySound(SoundEffect.SOUND_FART, 1, 0, false, 2)
		else
			mod:spritePlay(sprite, "Shoot0" .. d.shoot)
		end
	elseif d.state == "submerge" then
		if sprite:IsFinished("Submerge") then
			if (npc.StateFrame > 40 and r:RandomInt(15) == 1) or npc.StateFrame > 80 then
				d.state = "emerge"
				npc.Position = mod:FindRandomFreePosOfFour(npc, 300, true, true)
				npc.TargetPosition = npc.Position
			end
		elseif sprite:IsEventTriggered("PreShoot") then
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT,0.6,0,false,math.random(65,75)/100)
		elseif sprite:IsEventTriggered("Submerge") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif d.state == "emerge" then
		if sprite:IsFinished("Emerge") then
			d.state = "idle"
			npc.StateFrame = 0
			if d.Shotty and d.Shotty:Exists() then
				d.shoot = 2
			else
				d.shoot = 1
			end
		elseif sprite:IsEventTriggered("Emerge") then
			npc:PlaySound(SoundEffect.SOUND_SHOVEL_DIG,0.6,0,false,math.random(150,170)/100)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.Size = 15
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT,0.7,0,false,math.random(120,130)/100)
			npc.Size = 25
		else
			mod:spritePlay(sprite, "Emerge")
			mod:FlipSprite(sprite, npc.Position, target.Position)
		end
	end
end

function mod:GetBunkerProjectileAngle(npc, targetpos) --Realized making them just bounce off walls is a far better solution
	local room = game:GetRoom()
	local vec = (targetpos - npc.Position):Resized(130)
	for i = 0, 180, 30 do
		local possiblepos = npc.Position + vec:Rotated(i)
		if room:CheckLine(npc.Position, possiblepos, 3, 0, false, false) and room:IsPositionInRoom(possiblepos, 0) then
			return i
		end
		possiblepos = npc.Position + vec:Rotated(-i)
		if room:CheckLine(npc.Position, possiblepos, 3, 0, false, false) and room:IsPositionInRoom(possiblepos, 0) then
			return i
		end
	end
	return 0
end

function mod:BigBunkerProjectile(projectile, data)
	projectile.Velocity = projectile.Velocity * 0.9
	if (projectile:IsDead() or data.DoKillMeSoonHeehee) and projectile.Height < -5 then
		for i = 0, 315, 45 do
			local split = Isaac.Spawn(9,0,0,projectile.Position,Vector(10,0):Rotated(i),projectile):ToProjectile()
			split.ProjectileFlags = projectile.ProjectileFlags - ProjectileFlags.BOUNCE
		end
		if data.DoKillMeSoonHeehee then
			projectile:Die()
		end
		sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1.5, 0, false, 1.5)
	end
end

function mod:LilBunkerProjectile(projectile, data)
	if data.TargetShot and data.TargetShot:Exists() then
		if data.TargetShot.Position:Distance(projectile.Position) < 20 and math.abs(data.TargetShot.Height - projectile.Height) < 50 then
			data.TargetShot:GetData().DoKillMeSoonHeehee = true
			projectile:Die()
		end
	end
end