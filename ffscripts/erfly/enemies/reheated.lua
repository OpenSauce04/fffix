local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:reheatedChargerAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()

	if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.6,0.6)
		blood:Update()
	end

	if npc.State == 8 then
		if npc.FrameCount % (#mod.creepSpawnerCount/2) == 0 then
			if d.lastcreepleft then
				if d.lastcreepleft:Distance(npc.Position) > 15 then
					local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
					creep.Scale = (0.7)
					creep:SetTimeout(30)
					creep:Update();
					d.lastcreepleft = npc.Position
				end
			else
				local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
				creep.Scale = (0.7)
				creep:SetTimeout(30)
				creep:Update()
				d.lastcreepleft = npc.Position
			end
		end
	end

	if npc:IsDead() then
		local params = ProjectileParams()
		for i = 30, 360, 30 do
			local rand = r:RandomFloat()
			params.FallingSpeedModifier = -50 + math.random(10);
			params.FallingAccelModifier = 2
			params.VelocityMulti = math.random(13,19) / 10
			npc:FireProjectiles(npc.Position, Vector(0,2):Rotated(i-40+rand*80) + nilvector, 0, params)
		end
		local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
		creep.SpriteScale = creep.SpriteScale * 3
		creep.Scale = 0.7
		creep:SetTimeout(100)
		creep:Update()
	end
end

function mod:reheatedIckyAI(npc)
	npc.SplatColor = mod.ColorSpittyGreen
	if npc:IsDead() then
		local target = npc:GetPlayerTarget()
		local params = ProjectileParams()
		params.BulletFlags = params.BulletFlags | ProjectileFlags.EXPLODE
		params.FallingAccelModifier = 1
		params.FallingSpeedModifier = -20
		params.Scale = 2
		params.Color = mod.ColorIpecac
		npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized()*7, 0, params)
	end
end

function mod:reheatedTickingAI(npc)
	if npc:IsDead() then
		local bombshot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, RandomVector()*3, npc):ToProjectile()
		local bombd = bombshot:GetData()
		bombd.projType = "thrownbomb"
		bombshot.FallingSpeed = -10
		bombshot.FallingAccel = 1.2
		bombshot.Scale = 1
	end
end

function mod:reheatedsSpiderSackAI(npc)
	if npc:IsDead() then
		for i = 1, math.random(1,3) do
			local aaaaaaa = mod:FindRandomValidPathPosition(npc, 3)
			local happyhead = aaaaaaa - npc.Position
			EntityNPC.ThrowSpider(npc.Position,npc,npc.Position + happyhead,false,0)
		end

	end
end

function mod:reheatedFlyAI(npc)
	local d = npc:GetData()
	if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.6,0.6)
		blood:Update()
	end
	if npc.FrameCount % (#mod.creepSpawnerCount/2) == 0 then
		if d.lastcreepleft then
			if d.lastcreepleft:Distance(npc.Position) > 15 then
				local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
				creep.Scale = (0.7)
				creep:SetTimeout(30)
				creep:Update();
				d.lastcreepleft = npc.Position
			end
		else
			local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Scale = (0.7)
			creep:SetTimeout(30)
			creep:Update()
			d.lastcreepleft = npc.Position
		end
	end
end

function mod:reheatedFlyScarsAI(npc)
	local r = npc:GetDropRNG()
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()

	if d.attacking then
		sprite:SetFrame("Idle3", npc.FrameCount % 6)

		local params = ProjectileParams()
		local rand = r:RandomFloat()
		params.FallingSpeedModifier = -50 + math.random(10);
		params.FallingAccelModifier = 2
		params.VelocityMulti = math.random(13,19) / 10
		--params.HeightModifier = 30
		params.Scale = 0.3
		npc:FireProjectiles(npc.Position, RandomVector() * 2, 0, params)

		d.count = d.count + 1
		if d.count == 75 then
			d.attacking = false
			d.count = 1
		end
	else
		if npc.Position:Distance(target.Position) < 150 then
			sprite:SetFrame("Idle2", npc.FrameCount % 2)
			if d.count then
				d.count = d.count + 1
			else
				d.count = 1
			end
			if d.count > 50 or npc.Position:Distance(target.Position) < 50 then
				d.attacking = true
				d.count = 0
			end
		else
			mod:spritePlay(sprite, "Idle")
			if d.count then
				if d.count > 1 then
					d.count = d.count - 1
				else
					d.count = 1
				end
			else
				d.count = 1
			end
		end
	end
end

function mod:nonCanonReheatedFlyTickingRealsAI(npc)
	if npc:IsDead() then
		Isaac.Explode(npc.Position, npc, 40)
	end
end

function mod:reheatedSpiderFullAI(npc)
	if npc:IsDead() then
		local vec = RandomVector():Resized(8)
		for i = 60, 360, 60 do
			npc:FireProjectiles(npc.Position, vec:Rotated(i) + nilvector, 0, ProjectileParams())
		end
	end
end

function mod:reheatedSpiderAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()

	if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.6,0.6)
		blood:Update()
	end

	if npc.State == 4 then
		if npc.FrameCount % (#mod.creepSpawnerCount/2) == 0 then
			if d.lastcreepleft then
				if d.lastcreepleft:Distance(npc.Position) > 15 then
					local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
					creep.Scale = (0.7)
					creep:SetTimeout(30)
					creep:Update();
					d.lastcreepleft = npc.Position
				end
			else
				local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
				creep.Scale = (0.7)
				creep:SetTimeout(30)
				creep:Update()
				d.lastcreepleft = npc.Position
			end
		end
	end

	if sprite:IsEventTriggered("Land") then
		local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
		creep.SpriteScale = creep.SpriteScale * 3
		creep.Scale = 0.5
		creep:SetTimeout(100)
		creep:Update()
	end
end

function mod:reheatedSpiderScarsAI(npc)
	local r = npc:GetDropRNG()
	local d = npc:GetData()
	local sprite = npc:GetSprite()

	if d.count then
		d.count = d.count + 1
	else
		d.count = 0
	end

	if npc.State == 4 then
		if npc.StateFrame < 10 and d.count > 50 then
			if r:RandomInt(20) == 0 then
				npc.State = 7
				d.state = "AttackStart"
			end
		end
	elseif npc.State == 7 then
		--npc.Velocity = npc.Velocity * 0.9
		if d.state == "AttackStart" then
			if sprite:IsFinished("AttackStart") then
				d.state = "AttackLoop"
				d.count = 0
			else
				mod:spritePlay(sprite, "AttackStart")
			end
		elseif d.state == "AttackLoop" then
			mod:spritePlay(sprite, "AttackLoop")

			local params = ProjectileParams()
			local rand = r:RandomFloat()
			params.FallingSpeedModifier = -50 + math.random(10);
			params.FallingAccelModifier = 2
			params.VelocityMulti = math.random(13,19) / 10
			params.HeightModifier = 30
			params.Scale = 0.3
			npc:FireProjectiles(npc.Position, RandomVector() * 2, 0, params)

			if d.count > 100 then
				d.state = "AttackEnd"
			end
		elseif d.state == "AttackEnd" then
			if sprite:IsFinished("AttackStop") then
				npc.StateFrame = 0
				npc.State = 4
				d.count = 0
			else
				mod:spritePlay(sprite, "AttackStop")
			end
		else
			d.state = "AttackStart"
		end
	end
end

function mod:reheatedBeserkerAI(npc)
	local r = npc:GetDropRNG()
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()

	if npc.Position:Distance(target.Position) < 150 then
		mod:spritePlay(sprite, "Attack")
		npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(1), 0.01)
		if npc.FrameCount % 3 == 1 then
			local params = ProjectileParams()
			params.Scale = 0.3
			params.HeightModifier = 10
			npc:FireProjectiles(npc.Position, ((target.Position - npc.Position):Normalized()*7):Rotated(-10 + math.random()*20), 0, params)
		end
	else
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(3), 0.01)
	end
end

function mod:boiReheatedAI(npc)
	local r = npc:GetDropRNG()
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()

	--sprite.Scale = Vector(0.1, 0.1)

	if not d.init then
		d.init = true
		d.state = "idle"
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if npc.StateFrame % 50 == 49 then
			npc:PlaySound(mod.Sounds.teleport,1,0,false,1)
			d.state = "teleport"
			mod:spritePlay(sprite, "teleport")

			local rand = math.random(#mod.reheatedEnemies)
			local en = mod.reheatedEnemies[rand]
			local friend = Isaac.Spawn(en[1], en[2], 0, npc.Position, nilvector, npc)

		elseif npc.StateFrame % 50 == 25 then
			d.npcpos = target.Position
		elseif npc.StateFrame % 50 == 30 then
			d.npcpos = d.npcpos or target.Position
			local brim = Isaac.Spawn(7,1,0,npc.Position, nilvector, npc):ToLaser()
			brim.Angle = (d.npcpos - npc.Position):GetAngleDegrees()
			brim.PositionOffset = Vector(0, -47)
			brim.SpawnerEntity = npc
			brim.Parent = npc
			brim:SetTimeout(10)
			game:ShakeScreen(10)
			brim:Update()
		end

		npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(3), 0.3)

		if npc.FrameCount % 2 == 1 then
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,0,false,2)
			local params = ProjectileParams()
			params.Scale = 0.3
			params.HeightModifier = 0
			npc:FireProjectiles(npc.Position, RandomVector()*8, 0, params)
		end

	elseif d.state == "teleport" then
		if sprite:IsFinished("Teleport") then
			d.state = "idle"
		elseif sprite:GetFrame() == 2 then
			npc.Position = game:GetRoom():GetRandomPosition(1)
		else
			mod:spritePlay(sprite, "Teleport")
		end
	end
end

function mod:reheatedHost1AI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	if sprite:IsEventTriggered("Shoot2") then

		local vel = (target.Position-npc.Position)*0.05
		local proj = Isaac.Spawn(9, 4, 0, npc.Position, vel, npc):ToProjectile()
		proj.FallingSpeed = -20
		proj.FallingAccel = 1.2
		proj:GetData().projType = "reheatedHostSludge"
		proj:GetData().target = target
		local color = Color(0.35, 1, 0.25, 1, 0, 0, 0)
		color:SetColorize(0.6, 1, 0.6, 1)
		proj.Color = color
		mod:makeCharmProj(npc, proj)
		proj.Scale = 1.7

		sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
		local splat = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc)
		local color2 = Color(0.3, 1, 0.8, 1, 0, 0.5, 0)
		color2:SetColorize(0.6, 1, 0.6, 1)
		splat.Color = color2
		splat.SpriteOffset = Vector(0,-12)
		splat.DepthOffset = 20
	end
end

function mod.reheatedHostProj(v, d)
	if d.projType == "reheatedHostSludge" and d.target then
		for i=-30,30,30 do
			local proj = Isaac.Spawn(9, 4, 0, v.Position, (d.target.Position-v.Position):Resized(10):Rotated(i), v):ToProjectile()
			proj.Color = v.Color
			proj.ProjectileFlags = v.ProjectileFlags
		end
		if v:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local creep = Isaac.Spawn(1000, 46, 0, v.Position, Vector.Zero, v):ToEffect()
			creep.Color = Color(0,1,1,1,0,math.random(18,30)/100,0)
			creep.SpriteScale = Vector(2,2)
			creep:Update()
		else
			local creep = Isaac.Spawn(1000, 23, 0, v.Position, Vector.Zero, v):ToEffect()
			creep.SpriteScale = Vector(2,2)
			creep:Update()
		end
	end
end

function mod:reheatedHost2AI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	if sprite:IsEventTriggered("Shoot2") then

		for i = 1, 10 do
			local pos = (target.Position-npc.Position):Rotated(math.random(-30,30))
			pos = pos:Resized(math.random(100,300))
			npc:PlaySound(mod.Sounds.Plorp, 0.9, 0, false, math.random(95,105)/100)
			EntityNPC.ThrowSpider(npc.Position,npc,npc.Position + pos,false,0)
		end
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			if entity.Type == 85 and entity.Variant == 0 and entity.SpawnerType == 27 and entity.SpawnerEntity.SubType == mod.FF.ReheatedHost2.Sub then
				if not entity:GetData().CheekySpawned then
					entity:ToNPC():Morph(85,962,0,-1)
					entity:ToNPC().HitPoints = entity:ToNPC().MaxHitPoints
					entity:GetData().CheekySpawned = true
				end
			end
		end

		sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
		local splat = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc)
		local color2 = Color(1, 1, 1, 1, 1, 1, 1)
		color2:SetColorize(1, 1, 1, 1)
		splat.Color = color2
		splat.SpriteOffset = Vector(0,-12)
		splat.DepthOffset = 20
	end
end

function mod:reheatedHost3AI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	if sprite:IsEventTriggered("Shoot2") then
		local dir = 180
		local offset = Vector(-8,-20)
		if target.Position.X > npc.Position.X then
			dir = 0
			offset = Vector(8,-20)
		end

		local laser = EntityLaser.ShootAngle(1, npc.Position, dir, 20, offset, npc)
		laser.DepthOffset = 30
	end
end

function mod:reheatedGurgleAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	if sprite:IsEventTriggered("Shoot2") then
		npc:PlaySound(FiendFolio.Sounds.SpitumShoot,1,0,false,math.random(95,105)/100)
		for i = 1, 6 do
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(math.random(5,8)):Rotated(-20+math.random(40)), npc):ToProjectile()
			proj.Scale = math.random(8,10)/10
			proj.Color = mod.ColorSpittyGreen
			proj.FallingSpeed = -15 - math.random(20)/10
			proj.FallingAccel = 0.9 + math.random(10)/10
			local pd = proj:GetData()
			pd.projType = "acidic splot"
			if npc.SpawnerEntity and npc.SpawnerEntity.Type == 20 then
				pd.creepTimer = 30
			end
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.EXPLODE
		end
	end
end

function mod:reheatedCyclopiaAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	if sprite:IsOverlayPlaying("Attack") and sprite:GetOverlayFrame() == 3 then
		npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
		for i = 1, 6 do
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(math.random(5,8)):Rotated(-20+math.random(40)), npc):ToProjectile()
			proj.Scale = math.random(8,10)/10
			proj.FallingSpeed = -15 - math.random(20)/10
			proj.FallingAccel = 0.9 + math.random(10)/10
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.RED_CREEP
		end
	end
end