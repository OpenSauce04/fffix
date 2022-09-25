local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:reorientCaca(sprite, vec)
	if vec.X > 0 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end
end

mod.CacamancerDeathSplorts = {
	[1] = {60, 360, 60},
	[2] = {45, 360, 45},
	[3] = {30, 330, 60},
	[4] = {22.5, 337.5, 45},
}

function mod:cacamancerRenderAI(npc)
	local sprite = npc:GetSprite()
	if sprite:IsPlaying("Death") then
		local d = npc:GetData()
		d.deathShots = d.deathShots or 0
		if sprite:IsEventTriggered("BloodStart") and not d.hasStartedDying then
			npc:PlaySound(mod.Sounds.CacaDeath, 1, 0, false, 1)
			d.hasStartedDying = true
		end
		if sprite:IsEventTriggered("Sound") and not d.hasShot then
			d.hasShot = true
			d.deathShots = d.deathShots + 1
			d.deathShots = math.min(d.deathShots, 4)
			npc:PlaySound(SoundEffect.SOUND_FART, 1, 0, false, math.random(70,80)/100)
			npc:PlaySound(SoundEffect.SOUND_FART_GURG, 1, 0, false, math.random(90,110)/100)
			local vec = Vector(12, 0)
			local params = ProjectileParams()
			params.FallingAccelModifier = -0.085
			params.Variant = 3
			if npc:GetDropRNG():RandomFloat() <= 0.5 then
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_RIGHT | ProjectileFlags.NO_WALL_COLLIDE
			else
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_LEFT | ProjectileFlags.NO_WALL_COLLIDE
			end
			params.CurvingStrength = 0.01
			for i = mod.CacamancerDeathSplorts[d.deathShots][1], mod.CacamancerDeathSplorts[d.deathShots][2], mod.CacamancerDeathSplorts[d.deathShots][3] do
				npc:FireProjectiles(npc.Position + vec:Rotated(i):Resized(20), vec:Rotated(i), 0, params)
			end
			for _, drip in pairs(Isaac.FindByType(mod.FF.CacaSplurt.ID, mod.FF.CacaSplurt.Var, -1, false, false)) do
				drip:Kill()
			end
			for _, drip in pairs(Isaac.FindByType(EntityType.ENTITY_DRIP, -1, -1, false, false)) do
				drip:Kill()
			end
		elseif sprite:IsEventTriggered("Shoot") and d.hasShot then
			d.hasShot = false
		elseif sprite:IsEventTriggered("Explosion") and not d.hasShot then
			d.hasShot = true
			for i = 60, 360, 60 do
				local cloud = Isaac.Spawn(1000, 141, 1, npc.Position + Vector(50,0):Rotated(i), nilvector, npc):ToEffect()
				cloud:SetTimeout(90)
				cloud:Update()
			end
			local drip = Isaac.Spawn(EntityType.ENTITY_DRIP, 0, 0, npc.Position, nilvector, npc)
			local params = ProjectileParams()
			params.FallingSpeedModifier = -20
			params.HeightModifier = -50
			params.FallingAccelModifier = 1
			params.Color = FiendFolio.ColorIpecacDross
			params.BulletFlags = params.BulletFlags | ProjectileFlags.EXPLODE
			npc:FireProjectiles(npc.Position, nilvector, 0, params)
		end
	elseif sprite:IsPlaying("Appear") then
		local d = npc:GetData()
		if sprite:IsEventTriggered("Splash") and not d.appearTrigger1 then
			d.appearTrigger1 = true
			npc:PlaySound(mod.Sounds.Caca6, 1, 0, false, math.random(90,110)/100)
		elseif sprite:IsEventTriggered("Sound") and not d.appearTrigger2 then
			d.appearTrigger2 = true
			npc:PlaySound(mod.Sounds.Caca2, 1, 0, false, math.random(90,110)/100)
			npc:PlaySound(SoundEffect.SOUND_FART_GURG, 1, 0, false, math.random(90,110)/100)
		elseif sprite:IsEventTriggered("Shoot") and not d.appearTrigger3 then
			d.appearTrigger3 = true
			npc:PlaySound(mod.Sounds.Caca5, 1, 0, false, math.random(90,110)/100)
		end
	end
end

function mod:cacamancerAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	npc.SpriteOffset = Vector(0, 0)

	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

	if not d.init then
		npc.SplatColor = FiendFolio.ColorPoop
		d.init = true
		d.justDidRelocate = true
		d.state = "idle"
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.preventGas then
		d.preventGas = d.preventGas - 1
		if d.preventGas <= 0 then
			d.preventGas = nil
		end
	end

	if npc.Visible and (not d.preventGas)
	and ((npc.Velocity:Length() > 5 and npc.StateFrame % 5 == 1)
	or (npc.Velocity:Length() > 15 and npc.StateFrame % 3 == 1))
	then
		local cloud = Isaac.Spawn(1000, 141, 1, npc.Position + RandomVector():Resized(math.random(10,20)), nilvector, npc):ToEffect()
		cloud:SetTimeout(180)
		cloud:Update()
	end

	if d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.9
		mod:spritePlay(sprite, "Walk")
		if npc.StateFrame > 20 then
			d.sState = nil
			--local closeCloud = mod.FindClosestEntity(target.Position, 200, 1000, 141, 1)
			if (mod.GetEntityCount(EntityType.ENTITY_DRIP) + (mod.GetEntityCount(mod.FF.CacaSplurt.ID, mod.FF.CacaSplurt.Var))*2) >= 3 then
				d.state = "whirlpool"
			--[[elseif closeCloud and target.Position:Distance(closeCloud.Position) < 80 and not d.justDidRelocate then
				d.state = "relocate"]]
			else
				d.state = "charge"
			end
			npc.StateFrame = 0
		end
	elseif d.state == "charge" then
		if not d.sState then
			if npc.StateFrame < 1 then
				mod:reorientCaca(sprite, target.Position - npc.Position)
			end
			if sprite:IsFinished("ChargeStart") then
				mod:spritePlay(sprite, "ChargeLoop")
			elseif sprite:IsEventTriggered("Sound") then
				d.trackedPos = target.Position
				npc:PlaySound(mod.Sounds.Caca7, 1, 0, false, math.random(90,110)/100)
			elseif sprite:IsEventTriggered("Charge") then
				npc:PlaySound(mod.Sounds.Caca1, 1, 0, false, math.random(90,110)/100)
				d.charging = true
				npc.StateFrame = 0
				d.trackedPos = target.Position
				npc.Velocity = ((d.trackedPos or target.Position) - npc.Position):Resized(25)
				mod:reorientCaca(sprite, npc.Velocity)
			else
				if not sprite:IsPlaying("ChargeLoop") then
					mod:spritePlay(sprite, "ChargeStart")
				end
			end
		elseif d.sState == "end" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("ChargeEnd") then
				d.shootCount = d.shootCount or 1
				d.summonCount = d.summonCount or 0
				local rand 
				local closeCloud = mod.FindClosestEntity(target.Position, 200, 1000, 141, 1)
				if closeCloud and target.Position:Distance(closeCloud.Position) < 200 and not d.justDidRelocate then
					rand = mod:RandomInt(0,2)
				else
					rand = mod:RandomInt(0,1)
				end
				if rand > 1 then
					d.state = "relocate"
				elseif (rand == 0 or d.summonCount >= d.shootCount + 2) and not (d.shootCount >= d.summonCount + 2) then
					d.state = "shoot"
					d.shootCount = d.shootCount + 1
					d.justDidRelocate = false
				elseif rand == 1 or d.shootCount >= d.summonCount + 2 then
					d.state = "summon"
					d.summonCount = d.summonCount + 0.5
					d.justDidRelocate = false
				else
					d.state = "shoot"
				end
				d.sState = nil
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Sound") then
				sprite.FlipX = false
			else
				mod:spritePlay(sprite, "ChargeEnd")
			end
		end
		if d.charging then
			local speed = math.max(25 - (npc.StateFrame * 0.5), 15)
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(speed), 0.5)
			mod:reorientCaca(sprite, npc.Velocity)
			if npc.StateFrame > 15 then
				d.charging = false
				d.sState = "end"
			end
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_FART, 1, 0, false, math.random(70,80)/100)
			npc:PlaySound(SoundEffect.SOUND_FART_GURG, 1, 0, false, math.random(90,110)/100)
			local vec = (target.Position - npc.Position):Resized(12)
			local params = ProjectileParams()
			params.FallingAccelModifier = -0.085
			params.Variant = 3
			if r:RandomFloat() <= 0.5 then
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_RIGHT | ProjectileFlags.NO_WALL_COLLIDE
			else
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_LEFT | ProjectileFlags.NO_WALL_COLLIDE
			end
			params.CurvingStrength = 0.01
			for i = 60, 360, 60 do
				npc:FireProjectiles(npc.Position + vec:Rotated(i):Resized(20), vec:Rotated(i), 0, params)
			end

			params.FallingAccelModifier = 0
			params.CurvingStrength = 0.02
			for _, enemy in ipairs(Isaac.FindByType(mod.FF.CacaSplurt.ID, mod.FF.CacaSplurt.Var, -1, false, false)) do
				local vec = RandomVector() * 7
				for i = 120, 360, 120 do
					npc:FireProjectiles(enemy.Position + vec:Rotated(i):Resized(10), vec:Rotated(i), 0, params)
				end
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "summon" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("Summon") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(mod.Sounds.CacaIDKLOL, 1, 0, false, math.random(90,110)/100)
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.Caca4, 1, 0, false, math.random(90,110)/100)
			local vec = Vector(0, 6)
			if target.Position.X < npc.Position.X then
				vec = vec:Rotated(45)
			else
				vec = vec:Rotated(-45)
			end
			local splurt = Isaac.Spawn(mod.FF.CacaSplurt.ID, mod.FF.CacaSplurt.Var, 0, npc.Position, vec, npc)
			splurt:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			splurt:Update()
			splurt.Parent = npc
			npc:BloodExplode()

		else
			mod:spritePlay(sprite, "Summon")
		end
	elseif d.state == "relocate" then
		d.justDidRelocate = true
		npc.Velocity = npc.Velocity * 0.8
		if not d.sState then
			if sprite:IsFinished("Submerge") then
				d.sState = "wait"
				npc.Visible = false
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc.StateFrame = 0
				d.waitMerge = 30 + r:RandomInt(10)
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.Caca5, 1, 0, false, math.random(90,110)/100)
				local params = ProjectileParams()
				params.FallingSpeedModifier = -20
				params.HeightModifier = -50
				params.FallingAccelModifier = 1
				params.Color = FiendFolio.ColorIpecacDross
				params.BulletFlags = params.BulletFlags | ProjectileFlags.EXPLODE
				npc:FireProjectiles(npc.Position, nilvector, 0, params)
				local whirlpool = Isaac.Spawn(1000, mod.FF.CacaWhirlpool.Var, mod.FF.CacaWhirlpool.Sub, npc.Position, nilvector, nil)
				whirlpool.SpriteScale = Vector(0.5,0.5)
				whirlpool.Parent = npc
				npc.Child = whirlpool
				whirlpool:Update()
			elseif sprite:IsEventTriggered("Splash") then

			else
				mod:spritePlay(sprite, "Submerge")
			end
		elseif d.sState == "wait" then
			if npc.StateFrame > d.waitMerge then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.Visible = true
				d.sState = "reemerge"
				if npc.Child and npc.Child:Exists() then
					npc.Child:GetSprite():Play("Disappear")
					npc.Child = nil
				end
			elseif npc.StateFrame == d.waitMerge - 20 then
				if npc.Child and npc.Child:Exists() then
					npc.Child:GetSprite():Play("Disappear")
					npc.Child = nil
				end

				npc.Position = mod:FindRandomFreePos(npc, 120, false, true)
				local whirlpool = Isaac.Spawn(1000, mod.FF.CacaWhirlpool.Var, mod.FF.CacaWhirlpool.Sub, npc.Position, nilvector, nil)
				whirlpool.Parent = npc
				whirlpool.SpriteScale = Vector(0.5,0.5)
				whirlpool:GetSprite().FlipX = true
				npc.Child = whirlpool
				whirlpool:Update()
			end
		elseif d.sState == "reemerge" then
			if sprite:IsFinished("Emerge") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Splash") then
				npc:PlaySound(mod.Sounds.Caca6, 1, 0, false, math.random(90,110)/100)
			elseif sprite:IsEventTriggered("Sound") then
				npc:PlaySound(mod.Sounds.Caca2, 1, 0, false, math.random(90,110)/100)
				npc:PlaySound(SoundEffect.SOUND_FART_GURG, 1, 0, false, math.random(90,110)/100)
			else
				mod:spritePlay(sprite, "Emerge")
			end
		end
	elseif d.state == "whirlpool" then
		npc.Velocity = npc.Velocity * 0.8
		if npc.Child then
			local targvec = npc.Child.Position - npc.Position
			npc.Velocity = mod:Lerp(npc.Velocity, targvec / 5, 0.2)
		end

		if not d.sState then
			if sprite:IsFinished("WhirlPool") then
				npc.Visible = false
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				d.sState = "waiting"
			elseif sprite:IsEventTriggered("Leap") then
				local whirlpool = Isaac.Spawn(1000, mod.FF.CacaWhirlpool.Var, mod.FF.CacaWhirlpool.Sub, npc.Position, nilvector, nil)
				whirlpool.Parent = npc
				npc.Child = whirlpool
				whirlpool.SpriteScale = Vector(0.5,0.5)
				whirlpool:Update()
				npc:PlaySound(mod.Sounds.Caca3, 1, 0, false, math.random(90,110)/100)
			elseif sprite:IsEventTriggered("Splash") then
				d.whirlMega = true
				npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 1, 0, false, math.random(90,100)/100)
			else
				mod:spritePlay(sprite, "WhirlPool")
			end
		elseif d.sState == "waiting" then
			if (mod.GetEntityCount(EntityType.ENTITY_DRIP) + mod.GetEntityCount(mod.FF.CacaSplurt.ID, mod.FF.CacaSplurt.Var)) < 1 then
				if npc.StateFrame > 10 then
					d.sState = "emerge"
					d.whirlMega = nil
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
					npc.Visible = true
					d.dripsKilled = nil
					if npc.Child and npc.Child:Exists() then
						npc.Child:GetSprite():Play("Disappear")
						npc.Child = nil
					end
				end
			else
				npc.StateFrame = 0
			end
		elseif d.sState == "emerge" then
			if sprite:IsFinished("Emerge") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Splash") then
				npc:PlaySound(mod.Sounds.Caca6, 1, 0, false, math.random(90,110)/100)
			elseif sprite:IsEventTriggered("Sound") then
				npc:PlaySound(mod.Sounds.Caca2, 1, 0, false, math.random(90,110)/100)
				npc:PlaySound(SoundEffect.SOUND_FART_GURG, 1, 0, false, math.random(90,110)/100)
			else
				mod:spritePlay(sprite, "Emerge")
			end
		end

		if d.whirlMega then
			d.dripsKilled = d.dripsKilled or 0
			if npc.Child then
				npc.Child.SpriteScale = mod:Lerp(npc.Child.SpriteScale, Vector.One, 0.2)
				for _, drip in pairs(Isaac.FindByType(EntityType.ENTITY_DRIP, -1, -1, false, false)) do
					local targvec = npc.Child.Position - drip.Position
					targvec = targvec:Resized(math.min(targvec:Length() / 5, 15))
					drip.Velocity = mod:Lerp(drip.Velocity, targvec, 0.3)
					if drip.Position:Distance(npc.Child.Position) < 20 then
						drip:Kill()
						d.dripsKilled = d.dripsKilled + 1
						local params = ProjectileParams()
						params.FallingAccelModifier = -0.07
						params.Variant = 3
						local dripFire = math.min(d.dripsKilled, 11) - 1
						if dripFire > 0 then
							local maxang = 20 * dripFire
							for i = -10 * dripFire, 10 * dripFire, maxang / dripFire do
							   npc:FireProjectiles(npc.Position, (target.Position - npc.Child.Position):Resized(11):Rotated(i), 0, params)
							end
						else
							npc:FireProjectiles(npc.Position, (target.Position - npc.Child.Position):Resized(11), 0, params)
						end
					end
				end
			end
		end
	end
end

function mod:cacaSplurtAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	mod:spritePlay(sprite, "Idle")

	npc.SplatColor = FiendFolio.ColorPoop

	npc.SpriteOffset = Vector(0, -20)

	local shouldMove = true
	local stopSlow
	local dying

	if npc.Parent and npc.Parent:Exists() then
		local p = npc.Parent
		local pd = p:GetData()

		if pd.whirlMega then
			dying = true
		elseif pd.state == "charge" or pd.state == "shoot" then
			shouldMove = false
			if pd.sState or pd.charging then
				stopSlow = true
			end
		end
	end

	npc.StateFrame = npc.StateFrame + 1
	if dying then
		d.dieMax = d.dieMax or math.random(30,60)
		d.dieCount = d.dieCount or 0
		d.dieCount = d.dieCount + 1
		npc.Velocity = npc.Velocity * 0.9
		npc.SpriteOffset = npc.SpriteOffset + RandomVector():Resized(math.random(20)/10)
		if d.dieCount > d.dieMax then
			npc:TakeDamage(npc.MaxHitPoints + 1, 0, EntityRef(npc), 0)
		end
	elseif shouldMove then
		local vec = mod:diagonalMove(npc, 4, true)
		npc.Velocity = mod:Lerp(npc.Velocity, vec, math.min(npc.StateFrame / 30, 1))
	else
		if npc.Velocity:Length() > 15 then
			npc.Velocity = npc.Velocity:Resized(15)
		end
		if stopSlow then
			npc.Velocity = npc.Velocity * 0.97
		else
			npc.Velocity = npc.Velocity * 0.9
		end
		npc.StateFrame = 0
	end

	if d.collCool then
		d.collCool = d.collCool - 1
		if d.collCool < 0 then
			d.collCool = nil
		end
	end

	if npc:IsDead() then
		local rotMax = 3 --math.random(2,3)
		local vec = RandomVector():Resized(15)
		for i = 1, rotMax do
			local drip = Isaac.Spawn(EntityType.ENTITY_DRIP, 0, 0, npc.Position + vec:Rotated((i) * (360/rotMax)), nilvector, npc)
			if dying then
				drip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
	end
end

function mod:cacawhirlpoolAI(e)
	local sprite = e:GetSprite()
	e.DepthOffset = -150
	if sprite:IsFinished("Appear") then
		mod:spritePlay(sprite, "Idle")
	elseif sprite:IsFinished("Disappear") then
		e:Remove()
	end
	if e.Parent and e.Parent:Exists() and (e.Parent:GetSprite():IsPlaying("Death") or e.Parent:IsDead()) then
		mod:spritePlay(sprite, "Disappear")
	end
	e.Color = Color(0.8,0.8,0.8,1)
end