local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local angles = {
	{0, 90, 180, 270},
	{-30, 30, 150, -150},
}

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if effect.SubType == mod.FF.BonyProjectile.Sub then
		local data = effect:GetData()
		data.time = 45
		data.height = 40
		data.velocity = effect.Velocity

		effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end, mod.FF.BonyProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == mod.FF.BonyProjectile.Sub then
		local data = effect:GetData()
		local sprite = effect:GetSprite()

		sprite.FlipX = effect.Velocity.X < 0
		sprite.Offset = Vector(0, 4 * data.height / (data.time / 1.3093)^2 * effect.FrameCount * (effect.FrameCount - data.time / 1.28) - 60)
		
		if sprite.Offset.Y >= -10 and effect.FrameCount > data.time / 2 then
			local bony = Isaac.Spawn(227, 0, 0, effect.Position, Vector.Zero, effect)
			bony:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			bony.HitPoints = bony.MaxHitPoints * 0.65

			local bonySprite = bony:GetSprite()
			bonySprite:ReplaceSpritesheet(0, "gfx/bosses/mr_dead/boney_body.png")
			bonySprite:ReplaceSpritesheet(1, "gfx/bosses/mr_dead/boney_head.png")
			bonySprite:LoadGraphics()

			effect:Remove()
		end
	end
end, mod.FF.BonyProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if effect.SubType == mod.FF.DeadGeyser.Sub then
		local data = effect:GetData()

		data.params = ProjectileParams()
		data.params.FallingAccelModifier = 2

		data.rng = RNG()
		data.rng:SetSeed(effect.InitSeed, 42)
	end
end, mod.FF.DeadGeyser.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == mod.FF.DeadGeyser.Sub then
		local data = effect:GetData()
		local sprite = effect:GetSprite()

		if sprite:IsFinished("Start") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("Disappear") then
			effect:Remove()
		end

		effect.Velocity = Vector.Zero

		if sprite:IsEventTriggered("toma") then
			local chunk = Isaac.Spawn(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, effect.Position, Vector.Zero, effect.SpawnerEntity)
			chunk:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			chunk.HitPoints = chunk.MaxHitPoints * 0.75

			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
		end

		if sprite:WasEventTriggered("start") or sprite:IsPlaying("Idle") then
			if effect.FrameCount % 3 == 0 and effect.SpawnerEntity then
				data.params.FallingSpeedModifier = (data.rng:RandomInt(21) - 30) * 1.5
				effect.SpawnerEntity:ToNPC():FireProjectiles(effect.Position, RandomVector():Resized(4 - data.rng:RandomFloat() * 2), 0, data.params)

				sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
			end

			if effect.FrameCount % 12 == 3 and Isaac.CountEntities(nil, 853, 0, 0) < 16 then
				mod.ThrowMaggot(effect.Position, RandomVector():Resized(4 - data.rng:RandomFloat() * 2), 0, -10, effect.SpawnerEntity)
				sfx:Play(SoundEffect.SOUND_BOIL_HATCH)
			end
		end

		if Isaac.CountEntities(nil, mod.FF.MrDead.ID, mod.FF.MrDead.Var) < 1 then
			sprite:Play("Disappear")
		end
	end
end, mod.FF.DeadGeyser.Var)

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

		local data = npc:GetData()
		data.lastRoll = 3
		data.tomaChunks = {}
		data.totalChunks = 0
		data.lastAttack = -90

		data.homePosition = npc.Position

		data.vomitParams = ProjectileParams()
		data.vomitParams.HeightModifier = -75
		data.vomitParams.FallingAccelModifier = 1

		data.clusterParams = ProjectileParams()
		data.clusterParams.FallingAccelModifier = -0.1
		data.clusterParams.Color = mod.ColorWigglyMaggot

		mod.XalumInitNpcRNG(npc)

		local shiftRight = npc.SubType & 1 > 0
		local shiftDown = npc.SubType & 2 > 0

		if shiftRight then
			npc.Position = npc.Position + Vector(20, 0)
		end
		if shiftDown then
			npc.Position = npc.Position + Vector(0, 20)
		end
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		npc.Velocity = (data.homePosition - npc.Position)
		
		mod.NegateKnockoutDrops(npc)
		mod.QuickSetEntityGridPath(npc)

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("RegenEyes") then
			sprite:Play("Idle")
			data.lastAttack = npc.FrameCount - 45
		elseif sprite:IsFinished("Cord") or sprite:IsFinished("Vomit") or sprite:IsFinished("MouthClose") or sprite:IsFinished("Shoot") then
			sprite:Play("Idle")

			data.lastAttack = npc.FrameCount
			data.blowStart = nil
		elseif sprite:IsFinished("Eyes") then
			sprite:Play("RegenEyes")
		elseif sprite:IsFinished("MouthOpen") then
			sprite:Play("MouthIdle")
		end

		if sprite:IsPlaying("Idle") then
			if npc.HitPoints <= npc.MaxHitPoints * 2/3 and not data.spawnedTomaLoop1 then
				sprite:Play("MouthOpen")

				data.spawnedTomaLoop1 = true
				data.tomaChunks = {}
				data.totalChunks = 0
				data.lastRoll = 0
			elseif npc.HitPoints <= npc.MaxHitPoints * 1/3 and not data.spawnedTomaLoop2 then
				sprite:Play("MouthOpen")

				data.spawnedTomaLoop2 = true
				data.tomaChunks = {}
				data.totalChunks = 0
				data.lastRoll = 0
			elseif data.lastAttack + 120 <= npc.FrameCount and data.rng:RandomFloat() < 1/6 then
				local roll

				local numEyes = Isaac.CountEntities(nil, mod.FF.MrDeadsEye.ID, mod.FF.MrDeadsEye.Var)
				local numBonys = Isaac.CountEntities(nil, 227)
				local numMaggots = Isaac.CountEntities(nil, 853, 0, 0)
				local numTomaChunks = Isaac.CountEntities(nil, mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub)
				local numSpiders = Isaac.CountEntities(nil, 85)

				local numEnemies = numEyes + numBonys + numMaggots + numTomaChunks + numSpiders

				local canDropEyes = numEyes < 2
				local canVomit = numBonys < 2
				local canBlow = numTomaChunks < 5 and data.lastRoll ~= 5
				local canProjectile = numEnemies > 0

				if canDropEyes or canVomit or canBlow then
					local choices = {}
					if canDropEyes then table.insert(choices, 1) end
					if canVomit then table.insert(choices, 2) end
					if canBlow then table.insert(choices, 4) end
					if canProjectile then table.insert(choices, 3) end

					if data.lastRoll ~= 3 then table.insert(choices, 3) end

					local roll2 = data.rng:RandomInt(#choices) + 1
					roll = choices[roll2]
				else
					roll = 3
				end

				if numEnemies > 10 then
					roll = 3
				end

				if roll == 1 then
					sprite:Play("Eyes")
				elseif roll == 2 then
					sprite:Play("Vomit")
				elseif roll == 3 then
					sprite:Play("Shoot")
					data.attackVariant = data.rng:RandomInt(2) + 1
				elseif roll == 4 then
					sprite:Play("Cord")
				end

				data.lastRoll = roll
			end
		end

		if sprite:IsEventTriggered("BlowStart") then
			data.deadGeysers = {}

			local room = game:GetRoom()
			local i = 0

			repeat
				local position = npc.Position + RandomVector():Resized(60 + data.rng:RandomInt(80))
				if npc.Pathfinder:HasPathToPos(position, true) and room:GetGridCollisionAtPos(position) == GridCollisionClass.COLLISION_NONE then
					if #Isaac.FindInRadius(position, 60, EntityPartition.PLAYER) == 0 then
						local geyser = Isaac.Spawn(mod.FF.DeadGeyser.ID, mod.FF.DeadGeyser.Var, mod.FF.DeadGeyser.Sub, position, Vector.Zero, npc)
						geyser:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						geyser:GetSprite():Play("Start", true)

						table.insert(data.deadGeysers, geyser)
					end
				end

				i = i + 1
			until #data.deadGeysers == 3 or i >= 32
		end

		if sprite:IsEventTriggered("BlowEnd") then
			for _, geyser in pairs(data.deadGeysers) do
				geyser:GetSprite():Play("Disappear")
			end
		end

		if sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF, 1, 0, false, 1)
			npc:FireBossProjectiles(25 + data.rng:RandomInt(6), npc.Position + (npc:GetPlayerTarget().Position - npc.Position):Resized(30), 0, data.vomitParams)

			for _, projectile in pairs(Isaac.FindByType(9)) do
				if projectile.FrameCount == 0 and mod.XalumGetEntityEquality(projectile.SpawnerEntity, npc) then
					if math.random(3) == math.random(3) then
						local projectileSprite = projectile:GetSprite()
						projectileSprite:Load("gfx/009.001_bone projectile.anm2", true)
						projectileSprite:Play("Move")
					end
				end
			end

			for i = 1, 2 do
				local targetVelocity = (npc:GetPlayerTarget().Position - npc.Position):Resized(4 + data.rng:RandomInt(3)):Rotated(data.rng:RandomInt(31) - 15)
				local bonyProjectile = Isaac.Spawn(mod.FF.BonyProjectile.ID, mod.FF.BonyProjectile.Var, mod.FF.BonyProjectile.Sub, npc.Position, targetVelocity, npc)
				local bonyData = bonyProjectile:GetData()

				bonyData.height = 38 + data.rng:RandomInt(8)
				bonyData.time = 30 + data.rng:RandomInt(6)
			end
		end

		if sprite:IsEventTriggered("Shoot2") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF, 1, 0, false, 1)
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
			
			for i = 1, 6 do
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(6, 0):Rotated(i * 60), npc):ToProjectile()
				projectile:AddProjectileFlags(ProjectileFlags.CURVE_LEFT | ProjectileFlags.SINE_VELOCITY | ProjectileFlags.NO_WALL_COLLIDE)
				projectile.FallingAccel = -0.09
				projectile.Scale = projectile.Scale * 1.5

				projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(6, 0):Rotated(i * 60), npc):ToProjectile()
				projectile:AddProjectileFlags(ProjectileFlags.CURVE_RIGHT | ProjectileFlags.SINE_VELOCITY | ProjectileFlags.NO_WALL_COLLIDE)
				projectile.FallingAccel = -0.09
				projectile.Scale = projectile.Scale * 1.5
			end

			for i = 1, 4 do
				local angle = angles[data.attackVariant][i]
				mod.FireClusterProjectiles(npc, Vector(8, 0):Rotated(angle), 8, data.clusterParams)
			end
		end

		if sprite:IsEventTriggered("Spawn") then
			for i = 1, 2 do
				local firingAngle = Vector(i == 1 and -6 or 6, 0):Rotated(i == 1 and -20 or 20)
				local eye = Isaac.Spawn(mod.FF.MrDeadsEye.ID, mod.FF.MrDeadsEye.Var, 0, npc.Position + Vector(30, 0):Rotated(180 * i), firingAngle, npc)
				eye:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

				local eyeSprite = eye:GetSprite()
				eyeSprite:Play("Appear" .. i == 1 and "Left" or "Right")
			end

			npc:PlaySound(SoundEffect.SOUND_JELLY_BOUNCE, 1, 0, false, 1.5)
		end

		if sprite:IsPlaying("MouthIdle") then
			if sprite:GetFrame() % 8 == 0 then
				local chunk = Isaac.Spawn(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, npc.Position + Vector(0, 20), Vector(0, 6), npc)
				chunk:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				chunk:GetData().fiendfolio_chunkIsOrbiting = npc

				table.insert(data.tomaChunks, chunk)
				data.totalChunks = data.totalChunks + 1
			end

			local maxSpawn = data.spawnedTomaLoop2 and 10 or 5

			if data.totalChunks >= maxSpawn and sprite:GetFrame() >= 23 then
				sprite:Play("MouthClose")
			end
		end

		if #data.tomaChunks > 0 then
			local orbitalPositions = {}
			for i = 1, #data.tomaChunks do
				table.insert(orbitalPositions, npc.Position + Vector(50, 50):Rotated((i * 360 / #data.tomaChunks) + 2 * (npc.FrameCount % 360)))
			end

			for i = #data.tomaChunks, 1, -1 do
				local chunk = data.tomaChunks[i]
				if chunk:IsDead() then
					table.remove(data.tomaChunks, i)
				else
					local targetVelocity = orbitalPositions[i] - chunk.Position
					chunk.Velocity = mod.XalumLerp(chunk.Velocity, targetVelocity:Resized(math.min(targetVelocity:Length(), 8)), 0.1)
				end
			end
		end

		if sprite:IsEventTriggered("Inhale") then
			npc:PlaySound(SoundEffect.SOUND_LOW_INHALE, 1, 0, false, 1)
		end

		if sprite:IsEventTriggered("Gurgle") then
			npc:PlaySound(SoundEffect.SOUND_MOUTH_FULL, 1, 0, false, 1)
		end

		if sprite:IsEventTriggered("EyeNoise") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
		end

		if sprite:IsEventTriggered("MouthSounds") then
			npc:PlaySound(SoundEffect.SOUND_MEGA_PUKE, 1, 0, false, 1)
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
		end

		if sprite:IsEventTriggered("Tracers") then
			for i = 1, 4 do
				local angle = angles[data.attackVariant][i]
				local tracer = Isaac.Spawn(1000, 198, 0, npc.Position, Vector.Zero, npc):ToEffect()
		        tracer.TargetPosition = Vector.FromAngle(angle)
		        tracer.LifeSpan = 14
		        tracer.Timeout = 19
		        tracer.SpriteScale = Vector(3, 0.00001)
		        tracer.PositionOffset = Vector(0, 5)
		        tracer.Color = Color(205/255, 186/255, 186/255, 0.4, 0, 0, 0)
		        tracer:Update()
			end
		end
	end,
}