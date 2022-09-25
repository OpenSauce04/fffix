local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local PRIMARY_ANM2 = "gfx/bosses/tsar/boss_tsar.anm2"
local GRATED_ANM2 = "gfx/bosses/tsar/boss_tsargrate.anm2"

mod.doTsarCreep = { -- mod.doTsarCreep[data.form](npc)
	[0] = function(tsar) -- Tar
		local creep = Isaac.Spawn(1000, 26, 0, tsar.Position, Vector.Zero, tsar):ToEffect()
		creep.SpriteScale = Vector(1.4, 1.4)
		creep.Timeout = 210

		creep:Update()
		return creep
	end,
	[1] = function(tsar) -- Septic
		local creep = Isaac.Spawn(1000, 23, 0, tsar.Position, Vector.Zero, tsar):ToEffect()
		local scale = (tsar.FrameCount % 80) / 160 + 0.9

		creep.SpriteScale = Vector(scale, scale)
		creep.Timeout = 120

		creep:Update()
		return creep
	end,
	[2] = function(tsar) -- Pee
		local creep = Isaac.Spawn(1000, 24, 0, tsar.Position, Vector.Zero, tsar):ToEffect()
		creep.SpriteScale = Vector(0.7, 0.7)
		creep.Timeout = 180

		creep:Update()
		return creep
	end,
	[3] = function(tsar) -- Poop
		local creep = Isaac.Spawn(1000, 94, 0, tsar.Position, Vector.Zero, tsar):ToEffect()
		creep.Timeout = 150

		creep:Update()
		return creep
	end,
}

mod.doTsarProj = {
	[0] = function(projectile) -- Tar
		projectile:ToProjectile().Scale = 2
		projectile:GetData().projType = "dank slime"
	end,

	[1] = function(projectile) -- Septic
		projectile:ToProjectile().Scale = 2
		projectile:GetData().projType = "septic slime"
	end,

	[2] = function(projectile) -- Pee
		projectile:ToProjectile().Scale = 2
		projectile:GetData().projType = "pee slime"
	end,

	[3] = function(projectile) -- Poop
		projectile:ToProjectile().Scale = 2
		projectile:GetData().projType = "poop slime"
	end,
}

mod.doGratedTsarScattershot = {
	[0] = function(npc, data, dir)
		npc:FireProjectiles(npc.Position, dir:Resized(10), 4, data.params)
		npc:FireProjectiles(npc.Position, dir:Resized(8), 2, data.params)
	end,

	[1] = function(npc, data, dir)
		local projectile = Isaac.Spawn(9, 0, 0, npc.Position, dir:Resized(8), npc):ToProjectile()
		projectile.Scale = 2
		projectile:GetData().projType = "septic trail"
	end,

	[2] = function(npc, data, dir)
		npc:FireProjectiles(npc.Position, dir:Resized(14), 3, data.params)
	end,

	[3] = function(npc, data, dir)
		data.params.VelocityMulti = 1.25
		npc:FireBossProjectiles(10 + data.rng:RandomInt(5), npc:GetPlayerTarget().Position, 10, data.params)
	end,
}

mod.doGratedTsarRadial = {
	[0] = function(npc, data)
		npc:FireProjectiles(npc.Position, Vector(9, 0), 8, data.params)
		npc:FireProjectiles(npc.Position, Vector(7, 0), 8, data.params)

		for _, proj in pairs(Isaac.FindByType(9, -1, -1)) do
			local pdat = proj:GetData()
			if proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant and not pdat.tsarred then
				pdat.tsarred = true
				proj.Color = mod.tsarColors[1]

				if proj.Velocity:Length() < 8 then
					proj.Velocity = proj.Velocity:Rotated(22.5)
				end
			end
		end

		local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
		splash.SpriteScale = Vector(2, 2)
		splash.Color = mod.ColorDankBlackReal
	end,

	[1] = function(npc, data)
		for i = 0, 360, 60 do
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0, -9):Rotated(i), npc):ToProjectile()
			local pdat = proj:GetData()
			pdat.tsarred = true

			proj.Color = mod.tsarColors[2]
			pdat.projType = "quick septic trail"
		end

		local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
		splash.SpriteScale = Vector(2, 2)
		splash.Color = mod.ColorMysteriousLiquid
	end,

	[2] = function(npc, data)
		npc:FireProjectiles(npc.Position, Vector(11, 0), 8, data.params)
		local offset = data.rng:RandomInt(45)

		for _, proj in pairs(Isaac.FindByType(9, -1, -1)) do
			local pdat = proj:GetData()
			if proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant and not pdat.tsarred then
				pdat.tsarred = true
				proj.Color = mod.tsarColors[3]

				proj.Velocity = proj.Velocity:Rotated(offset)
			end
		end

		local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
		splash.SpriteScale = Vector(2, 2)
		splash.Color = mod.ColorPeepPiss
	end,

	[3] = function(npc, data)
		data.params.VelocityMulti = 1.25
		data.params.Variant = 3
		npc:FireBossProjectiles(20 + data.rng:RandomInt(10), npc.Position + RandomVector():Resized(80), 10, data.params)

		for _, proj in pairs(Isaac.FindByType(9, -1, -1)) do
			local pdat = proj:GetData()
			if proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant and not pdat.tsarred then
				pdat.tsarred = true

				proj.Velocity = proj.Velocity:Rotated(data.rng:RandomInt(360))
			end
		end

		local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
		splash.SpriteScale = Vector(2, 2)
		splash.Color = mod.ColorPoop
	end,
}

mod.doTsarPipeShoot = {
	[0] = function(npc, tsar, noball) -- Septic
		local data = npc:GetData()

		if not noball then
			local tsarball = Isaac.Spawn(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, 0, npc.Position, data.facing:Resized(30), tsar)
			local tsarballData = tsarball:GetData()

			tsarballData.tsar = tsar
			tsarballData.variant = math.random(3)
			tsarballData.form = 1

			mod.tsarChangeForm(tsarball, 1, true, true)

			tsarball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			tsarball.SpriteOffset = Vector(0, -14)
			tsarball:GetSprite():Play("GlobAppear0" .. tsarballData.variant)

			tsar:GetData().numballs = tsar:GetData().numballs + 1
		end

		for i = 1, 5 do
			mod.XalumSchedule(i - 1, function(typ, var, sub, pos, vel, spawner, scale)
				local creep = Isaac.Spawn(typ, var, sub, pos, vel, spawner)
				creep.SpriteScale = creep.SpriteScale * scale
			end, {1000, 23, 0, npc.Position + data.facing:Resized(30 * i), Vector.Zero, tsar, math.max(1, math.log(i)^2)})
		end

		local splash = Isaac.Spawn(1000, 2, 4, npc.Position + data.facing:Resized(30), Vector.Zero, tsar)
		splash.Color = mod.ColorMysteriousLiquid
		splash.RenderZOffset = 1000
	end,

	[1] = function(npc, tsar, noball) -- Piss
		local data = npc:GetData()

		if not noball then
			local tsarball = Isaac.Spawn(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, 0, npc.Position, data.facing:Resized(30), tsar)
			local tsarballData = tsarball:GetData()

			tsarballData.tsar = tsar
			tsarballData.variant = math.random(3)
			tsarballData.form = 2

			mod.tsarChangeForm(tsarball, 2, true, true)

			tsarball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			tsarball.SpriteOffset = Vector(0, -14)
			tsarball:GetSprite():Play("GlobAppear0" .. tsarballData.variant)

			tsar:GetData().numballs = tsar:GetData().numballs + 1
		end

		for i = 1, 10 do
			mod.XalumSchedule(i - 1, Isaac.Spawn, {1000, 24, 0, npc.Position + data.facing:Resized(30 * i), Vector.Zero, tsar})
		end

		local splash = Isaac.Spawn(1000, 2, 4, npc.Position + data.facing:Resized(30), Vector.Zero, tsar)
		splash.Color = mod.ColorPeepPiss
		splash.RenderZOffset = 1000
	end,

	[2] = function(npc, tsar, noball) -- Poop
		local data = npc:GetData()

		if not noball then
			local tsarball = Isaac.Spawn(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, 0, npc.Position, data.facing:Resized(30), tsar)
			local tsarballData = tsarball:GetData()

			tsarballData.tsar = tsar
			tsarballData.variant = math.random(3)
			tsarballData.form = 3

			mod.tsarChangeForm(tsarball, 3, true, true)

			tsarball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			tsarball.SpriteOffset = Vector(0, -14)
			tsarball:GetSprite():Play("GlobAppear0" .. tsarballData.variant)

			tsar:GetData().numballs = tsar:GetData().numballs + 1
		end

		local params = ProjectileParams()
		params.Variant = 3

		npc.Position = npc.Position + data.facing:Resized(25)
		npc:FireBossProjectiles(16 + tsar:GetData().rng:RandomInt(8), npc.Position + data.facing:Resized(360), 10, params)
		npc.Position = npc.Position - data.facing:Resized(25)

		for _, projectile in pairs(Isaac.FindByType(9, 3)) do
			if projectile.FrameCount == 0 and mod.XalumGetEntityEquality(projectile.SpawnerEntity, npc) then
				projectile:ToProjectile().Scale = math.random(10, 15) / 10
			end
		end

		for i = 1, 2 do
			mod.XalumSchedule(i - 1, function(...)
				local creep = Isaac.Spawn(...):ToEffect()
				creep.SpriteScale = creep.SpriteScale * 3
				creep.Timeout = 200
				creep:Update()
			end, {1000, 94, 0, npc.Position + data.facing:Resized(65 * i), Vector.Zero, tsar})
		end

		local splash = Isaac.Spawn(1000, 2, 4, npc.Position + data.facing:Resized(30), Vector.Zero, tsar)
		splash.Color = mod.ColorPoop
		splash.RenderZOffset = 1000
	end,

	[3] = function(npc, tsar, noball) -- Dank
		local data = npc:GetData()

		if not noball then
			local tsarball = Isaac.Spawn(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, 0, npc.Position, data.facing:Resized(30), tsar)
			local tsarballData = tsarball:GetData()

			tsarballData.tsar = tsar
			tsarballData.variant = math.random(3)
			tsarballData.form = 0

			mod.tsarChangeForm(tsarball, 0, true, true)

			tsarball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			tsarball.SpriteOffset = Vector(0, -14)
			tsarball:GetSprite():Play("GlobAppear0" .. tsarballData.variant)

			tsar:GetData().numballs = tsar:GetData().numballs + 1
		end

		-- Code stole from melty to fire blots
		for i = 1, 3 + tsar:GetData().rng:RandomInt(3) do
			local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, npc.Position, data.facing:Resized(4):Rotated(tsar:GetData().rng:RandomInt(31) - 15), tsar):ToNPC()
			local blotdata = blot:GetData()
			blotdata.downvelocity = -20 + math.random(10);
			blotdata.downaccel = 2.5
			blot.Velocity = blot.Velocity * (math.random(12, 20)/7.5)
			blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			blot.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			blot:GetSprite().Offset = Vector(0, -1)
			blotdata.state = "air"
			blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end

		local splash = Isaac.Spawn(1000, 2, 4, npc.Position + data.facing:Resized(30), Vector.Zero, tsar)
		splash.Color = mod.ColorDankBlackReal
		splash.RenderZOffset = 1000
	end,
}

function mod.tsarChangeForm(tsar, form, force, isTsarball)
	local data = tsar:GetData()

	if not form then form = (data.form or 0) + 1 end
	form = form % 4
	if form == data.form and not force then return end

	local sprite = tsar:GetSprite()
	local spritesheet = "gfx/bosses/tsar/boss_tsar"

	if form and mod.tsarColors[form + 1] then
		tsar.SplatColor = mod.tsarColors[form + 1]
	end

	local infix = ""
	if form == 1 then
		infix = "green"
	elseif form == 2 then
		infix =  "pee"
	elseif form == 3 then
		infix = "poop"
	end
	spritesheet = spritesheet .. infix .. ".png"

	for i = 0, isTsarball and 0 or 3 do
		sprite:ReplaceSpritesheet(i, spritesheet)
	end
	if isTsarball then
		sprite:ReplaceSpritesheet(1, "gfx/bosses/tsar/poof" .. infix .. ".png")
	end

	sprite:LoadGraphics()

	data.form = form
	return form
end

function mod.tsarChangeGrate(npc)
	local data = npc:GetData()
	data.grate.Visible = true

	local grates = Isaac.FindByType(mod.FF.BigGrate.ID, mod.FF.BigGrate.Var, -1)
	data.grate = grates[data.rng:RandomInt(#grates) + 1]
	data.grate.Visible = false

	npc.Position = data.grate.Position
end

mod.tsarCreeps = {23, 24, 26, 94}
mod.tsarColors = {mod.ColorDankBlackReal, mod.ColorMysteriousLiquid, mod.ColorPeepPiss, mod.ColorPoop}

return {
	Init = function(npc)
		npc.SplatColor = mod.ColorDankBlackReal

		local spawnGrate = npc.SubType & 1 > 0
		local startingForm = (npc.SubType & ~ 1) >> 1

		if spawnGrate then
			Isaac.Spawn(mod.FF.BigGrate.ID, mod.FF.BigGrate.Var, 0, npc.Position, Vector.Zero, nil)
		end

		local data = npc:GetData()
		data.form = startingForm
		data.creepy = false
		data.consecutiveSpits = 0
		data.lastGridCollision = -40

		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 42)
		data.gratelast = {nil, nil}

		data.params = ProjectileParams()

		mod.tsarChangeForm(npc, data.form, true, false)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)
		mod.NegateKnockoutDrops(npc)

		if sprite:IsFinished("Appear") then
			sprite:Play("Intro")
		elseif sprite:IsFinished("Intro") or sprite:IsFinished("Shoot01") or sprite:IsFinished("Land") or sprite:IsFinished("Recover01") or sprite:IsFinished("Recover02") then
			sprite:Play("Idle01")
			data.state = "idle"
			data.creepy = true
		elseif sprite:IsFinished("GoDownGrate") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			data.creepy = false
			data.delay = npc.FrameCount + 20
			data.numballs = 0

			sprite.FlipX = false
			sprite:Load(GRATED_ANM2, true)
			mod.tsarChangeForm(npc, data.form, true)

			sprite:Play("Grate")
			data.grate.Visible = false
			npc.RenderZOffset = -5000
		elseif sprite:IsFinished("Emerge") then
			sprite:Play("Shoot02")
			sfx:Play(mod.Sounds.TsarEmerge, 1, 0, false, 1)
		elseif sprite:IsFinished("Shoot02") then
			sprite:Play("Submerge")
		elseif sprite:IsFinished("Submerge") or sprite:IsFinished("GrateShoot") then
			if data.numballs >= 6 or (npc.HitPoints <= npc.MaxHitPoints * 0.2 and data.numballs >= 1) then
				local balls = Isaac.FindByType(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, -1)
				if #balls == 1 then
					local ball = balls[1]
					local bspr = ball:GetSprite()

					if bspr:IsPlaying("BlobIdle0" .. ball.SubType) or ball.SubType == 0 then
						sprite:Load(PRIMARY_ANM2, true)
						mod.tsarChangeForm(npc, data.form, true)

						if bspr:IsPlaying("BlobIdle05") then
							sprite:Play("Recover01")
						elseif ball.SubType == 0 then
							sprite:Play("BlobCombine01")
						else
							sprite:Play("BlobUp0" .. ball.SubType)
						end

						npc.Position = ball.Position
						npc.Velocity = ball.Velocity

						data.form = ball:GetData().form or data.form

						mod.tsarChangeForm(npc, data.form, true)

						npc.RenderZOffset = 0
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

						if data.grate then
							data.grate.Visible = true
							data.grate = nil
						end

						data.inGrate = false

						data.state = "still"
						ball:Remove()
					end
				elseif #balls == 0 then
					data.numballs = data.numballs - 1
				end
			else
				sprite:Play("Grate")

				if data.rng:RandomFloat() < 1/3 then
					data.state = nil

					local pipes = Isaac.FindByType(44, mod.FF.BigPipe.Var)
					local p = pipes[data.rng:RandomInt(#pipes) + 1]
					p:GetSprite():Play("Shoot")
					p:GetData().orbtime = true
				else
					data.state = "grated"
					data.delay = npc.FrameCount + 10

					mod.tsarChangeGrate(npc)
				end
			end
		elseif sprite:IsFinished("BlobCombine01") then
			sprite:Play("BlobUp01")
		elseif sprite:IsFinished("BlobUp01") or sprite:IsFinished("BlobUp02") or sprite:IsFinished("BlobUp03") or sprite:IsFinished("BlobUp04") or sprite:IsFinished("BlobUp05") then
			sprite:Play("Recover02")
		elseif sprite:IsFinished("JumpStart") or sprite:IsFinished("LandToJump") then
			sprite:Play("JumpLoop")
		elseif sprite:IsFinished("ApexStart") then
			data.state = "hover"
			data.hoverstart = npc.FrameCount

			sprite:Play("ApexLoop")
		elseif sprite:IsFinished("FallStart") then
			sprite:Play("FallLoop")
		end

		if npc:HasMortalDamage() then
			sprite:Play("Death")
			npc:Die()
		end

		if data.inGrate and data.grate then
			npc.Velocity = data.grate.Position - npc.Position
		end

		if data.creepy then
			if npc.FrameCount % 8 == 0 then mod.doTsarCreep[data.form](npc) end
			if npc.FrameCount % 3 == 0 then
				local creep = mod.doTsarCreep[data.form](npc)
				creep.SpriteScale = Vector(1.4, 1.4)
				creep.Timeout = 20

				creep:Update()
			end
		end

		if data.state == "idle" then
			local room = game:GetRoom()
			local targetPosition = npc:GetPlayerTarget().Position
			local targetVelocity = (targetPosition - npc.Position):Resized(1.5)
			local hasLineOfSight = room:CheckLine(npc.Position, targetPosition, 1)

			if npc:CollidesWithGrid() then
				data.lastGridCollision = npc.FrameCount
			end

			if hasLineOfSight and data.lastGridCollision + 24 < npc.FrameCount then
				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.1)
			else
				npc.Pathfinder:FindGridPath(targetPosition, 0.2, 0, true) -- Why is this so fucking fast ??????
			end

			sprite.FlipX = npc.Velocity.X < 0

			if npc.FrameCount % 5 == 0 and data.rng:RandomFloat() < 1/6 then
				local roll

				local canGrate 	= npc.HitPoints > npc.MaxHitPoints * 0.2 and data.lastRoll ~= 2
				local canThwomp = data.lastRoll ~= 3
				local canSpit 	= data.consecutiveSpits < 3

				local i = 0
				repeat
					roll = data.rng:RandomInt(4)

					if roll <= 1 and data.consecutiveSpits == 2 then
						roll = data.rng:RandomInt(4)
					end

					local validThwomp = roll ~= 3 or canThwomp
					local validGrate = roll ~= 2 or canGrate
					local validSpit = roll > 1 or canSpit

					i = i + 1
				until (validThwomp and validGrate and validSpit) or i >= 32

				if i >= 32 and roll == 2 then
					roll = 3
				end

				-- roll = 3

				if roll <= 1 then
					data.state = "still"
					sprite:Play("Shoot01")
				elseif roll == 2 then
					data.state = "track grate"
					data.grateLerpStrength = 0.1

					local grates = Isaac.FindByType(44, mod.FF.BigGrate.Var, -1)
					local closest = grates[1]
					local dist = 99999
					for _, grate in pairs(grates) do
						local dist2 = grate.Position:Distance(npc.Position)
						if dist2 < dist then
							closest = grate
							dist = dist2
						end
					end

					data.grate = closest
					data.counter = 0
				elseif roll == 3 then
					data.state = "still"
					sprite:Play("JumpStart")
				end

				data.lastRoll = roll
				if roll > 1 then
					data.consecutiveSpits = 0
				else
					data.consecutiveSpits = data.consecutiveSpits + 1
				end
			end
		elseif data.state == "still" then
			npc.Velocity = npc.Velocity * 0.9
		elseif data.state == "track grate" then
			local room = game:GetRoom()
			local targetPosition = data.grate.Position
			local targetVelocity = (targetPosition - npc.Position)
			targetVelocity:Resize(math.min(2, targetVelocity:Length()))

			local hasLineOfSight, collisionPosition = room:CheckLine(npc.Position, targetPosition, 1)
			if collisionPosition:Distance(targetPosition) < 40 then
				hasLineOfSight = true
			end

			if npc:CollidesWithGrid() and npc.Position:Distance(targetPosition) > 60 then
				data.lastGridCollision = npc.FrameCount
			end

			if hasLineOfSight and data.lastGridCollision + 24 < npc.FrameCount then
				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, data.grateLerpStrength)
				data.grateLerpStrength = mod.XalumLerp(data.grateLerpStrength, 0.5, 0.05)
			else
				data.grateLerpStrength = 0.1
				npc.Pathfinder:FindGridPath(targetPosition, 0.2, 0, true) -- Why is this so fucking fast ??????
			end

			sprite.FlipX = npc.Velocity.X < 0

			if npc.Position:Distance(data.grate.Position) <= 3 then
				sprite:Play("GoDownGrate")
				data.state = "grated"
				data.inGrate = true

				npc.Position = data.grate.Position
				npc.Velocity = Vector.Zero
			end
		elseif data.state == "grated" then
			if sprite:IsFinished("Grate") and npc.FrameCount >= data.delay then
				if data.numballs >= 6 or (npc.HitPoints <= npc.MaxHitPoints * 0.2 and data.numballs >= 1) then
					local balls = Isaac.FindByType(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, -1)
					if #balls == 1 then
						local ball = balls[1]
						local bspr = ball:GetSprite()

						if bspr:IsPlaying("BlobIdle0" .. ball.SubType) or ball.SubType == 0 then
							sprite:Load(PRIMARY_ANM2, true)
							mod.tsarChangeForm(npc, data.form, true)

							if bspr:IsPlaying("BlobIdle05") then
								sprite:Play("Recover01")
							elseif ball.SubType == 0 then
								sprite:Play("BlobCombine01")
							else
								sprite:Play("BlobUp0" .. ball.SubType)
							end

							npc.Position = ball.Position
							npc.Velocity = ball.Velocity

							data.form = ball:GetData().form or data.form

							mod.tsarChangeForm(npc, data.form, true)

							npc.RenderZOffset = 0
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

							if data.grate then
								data.grate.Visible = true
								data.grate = nil
							end

							data.inGrate = false

							data.state = "still"
							ball:Remove()
						end
					elseif #balls == 0 then
						data.numballs = data.numballs - 1
					end
				else
					sprite:Play("GrateShake")

					sfx:Play(mod.Sounds.GraterShake, 1, 0, true, 0.7)

					local r = data.rng:RandomInt(2)
					if data.gratelast[2] and data.gratelast[1] == data.gratelast[2] then r = (data.gratelast[1] + 1) % 2 end

					if r == 0 and (not data.numballs or data.numballs < 6) then
						data.state = "grateshoot"
						data.delay = npc.FrameCount + 40
					else
						data.state = "grating"
						data.delay = npc.FrameCount + 20

						mod.tsarChangeForm(npc, data.rng:RandomInt(4))
					end

					data.gratelast[2] = data.gratelast[1]
					data.gratelast[1] = r
				end
			end
		elseif data.state == "grating" then
			if npc.FrameCount + 4 >= data.delay and not sfx:IsPlaying(mod.Sounds.GraterEmege) then
				sfx:Play(mod.Sounds.GraterEmege, 1, 0, false, 0.8)
			end

			if npc.FrameCount >= data.delay then
				sprite:Play("Emerge")
				sfx:Stop(mod.Sounds.GraterShake)
				data.state = nil
			end
		elseif data.state == "grateshoot" then
			if npc.FrameCount == data.delay - 12 then
				sfx:Play(mod.Sounds.GraterEmege, 0.7, 0, false, 0.6)
			end

			if npc.FrameCount == data.delay - 2 then
				sfx:Play(mod.Sounds.GraterBurrow, 1, 0, false, 1)
			end

			if npc.FrameCount >= data.delay then
				sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 1, 0, false, 1)

				sprite:Play("GrateShoot")
				sfx:Stop(mod.Sounds.GraterShake)
				sfx:Play(mod.Sounds.ShotgunBlast, 0.4, 0, false, 1.7)
				data.state = nil
			end
		elseif data.state == "ascend" then
			data.ascendaccel = data.ascendaccel * 0.7

			local targetVelocity = npc:GetPlayerTarget().Position - npc.Position
			targetVelocity:Resize(math.min(targetVelocity:Length(), 5))

			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.2)

			if data.ascendaccel <= 5 then
				sprite:Play("ApexStart")
			end

			npc.SpriteOffset = npc.SpriteOffset + Vector(0, -data.ascendaccel)
		elseif data.state == "hover" then
			local targetVelocity = npc:GetPlayerTarget().Position - npc.Position
			targetVelocity:Resize(math.min(targetVelocity:Length(), 5))

			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.2)

			if data.hoverstart + 24 <= npc.FrameCount and game:GetRoom():GetGridCollisionAtPos(npc:GetPlayerTarget().Position) ~= GridCollisionClass.COLLISION_PIT then
				data.state = "descend"
				data.fallen = data.fallen or 0

				sprite:Play("FallStart")
				npc.SpriteOffset = npc.SpriteOffset + Vector(0, data.ascendaccel)
			end
		elseif data.state == "descend" then
			data.ascendaccel = data.ascendaccel / 0.7

			local targetVelocity = npc:GetPlayerTarget().Position - npc.Position
			targetVelocity:Resize(math.min(targetVelocity:Length(), 5))

			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.2)

			if npc.SpriteOffset.Y + data.ascendaccel >= 0 then
				npc.SpriteOffset = Vector.Zero
				data.state = "still"

				if data.fallen < 2 then
					data.fallen = data.fallen + 1

					sprite:Play("LandToJump")
				else
					data.fallen = nil

					sprite:Play("Land")
				end
			else
				npc.SpriteOffset = npc.SpriteOffset + Vector(0, data.ascendaccel)
			end
		end

		if npc:IsDead() and data.grate then
			data.grate.Visible = true
			data.grate = nil
			data.inGrate = false
		end

		if sprite:IsPlaying("Shoot01") then
			if sprite:GetFrame() == 10 then
				sfx:Play(mod.Sounds.TsarBurp, 0.8, 0, false, 1)
			end
		end

		if sprite:IsPlaying("Shoot02") then
			if sprite:GetFrame() == 36 then
				sfx:Play(mod.Sounds.GraterBurrow, 1, 0, false, 0.8)
			end
		end

		if sprite:IsPlaying("GoDownGrate") then
			local frame = sprite:GetFrame()

			if frame == 4 then
				sfx:Play(mod.Sounds.TsarKalu, 1, 0, false, 1)
			elseif frame == 45 then
				sfx:Play(mod.Sounds.TsarGrateEnter, 1, 0, false, 1)
			elseif frame == 53 then
				local splash = Isaac.Spawn(1000, 16, 5, npc.Position, Vector.Zero, npc)
				splash.Color = mod.tsarColors[data.form + 1]
				splash.SpriteScale = Vector(0.75, 0.75)
				splash.RenderZOffset = -7500
			end
		end

		if sprite:IsPlaying("GrateShoot") then
			if sprite:GetFrame() == 12 then
				sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
			end
		end

		if sprite:IsEventTriggered("Shoot") then
			if sprite:IsPlaying("Shoot01") then
				sfx:Play(mod.Sounds.TsarYouOkayThereBuddyCanWeGetYouSomethingToDrink, 1, 0, false, math.random(10, 12)/10)

				local target = npc:GetPlayerTarget()
				local targetPosition = target.Position + target.Velocity * 15
				local positionModifier = (target.Position - targetPosition):Resized(5)

				local room = game:GetRoom()
				while not room:IsPositionInRoom(targetPosition, 0) do
					targetPosition = targetPosition + positionModifier
				end

				local attackVector = targetPosition - npc.Position
				sprite.FlipX = attackVector.X < 0

				data.params.VelocityMulti = 1.25
				data.params.Variant = data.form == 3 and 3 or 0

				local offset = sprite.FlipX and Vector(-10, 0) or Vector(10, 0)
				local splash = Isaac.Spawn(1000, 2, 5, npc.Position + offset, Vector.Zero, npc)
				splash.SpriteOffset = Vector(0, -40)
				splash.SpriteScale = Vector(1.75, 1.75)
				splash.Color = mod.tsarColors[data.form + 1]
				splash.RenderZOffset = 500

				npc:FireBossProjectiles(10 + data.rng:RandomInt(5), targetPosition, 10, data.params)
				local all = {}

				for _, projectile in pairs(Isaac.FindByType(9)) do
					if projectile.FrameCount == 0 and mod.XalumGetEntityEquality(projectile.SpawnerEntity, npc) then
						projectile = projectile:ToProjectile()

						projectile.Scale = projectile.Scale * (1 + 0.5 * math.random())
						if data.form ~= 3 then projectile.Color = mod.tsarColors[data.form + 1] end

						table.insert(all, projectile)
					end
				end

				if Isaac.CountEntities(nil, mod.FF.TarBubble.ID, mod.FF.TarBubble.Var) < 5 then
					for i = 1, #all > 6 and 3 or 2 do
						local r = data.rng:RandomInt(#all) + 1

						mod.doTsarProj[data.form](all[r])
						table.remove(all, r)
					end
				end
			elseif sprite:IsPlaying("Shoot02") then
				sfx:Play(mod.Sounds.TsarCough, 1, 0, false, 1)

				local dir = npc:GetPlayerTarget().Position - npc.Position
				data.params.VelocityMulti = 1
				data.params.Variant = data.form == 3 and 3 or 0

				mod.doGratedTsarScattershot[data.form](npc, data, dir)

				for _, projectile in pairs(Isaac.FindByType(9)) do
					if projectile.FrameCount == 0 and mod.XalumGetEntityEquality(projectile.SpawnerEntity, npc) then
						if data.form ~= 3 then projectile.Color = mod.tsarColors[data.form + 1] end
					end
				end

				local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
				splash.SpriteOffset = Vector(0, -5)
				splash.SpriteScale = Vector(1.25, 1.25)
				splash.Color = mod.tsarColors[data.form + 1]
				splash.RenderZOffset = 500
			elseif sprite:IsPlaying("GrateShoot") then
				data.params.VelocityMulti = 1
				data.params.Variant = data.form == 3 and 3 or 0

				mod.doGratedTsarRadial[data.form](npc, data)

				local tsarball = Isaac.Spawn(mod.FF.Tsarball.ID, mod.FF.Tsarball.Var, 0, npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(15), npc)
				local tsarballData = tsarball:GetData()

				tsarballData.tsar = npc
				tsarballData.variant = math.random(3)
				tsarballData.form = data.form

				mod.tsarChangeForm(tsarball, data.form, true, true)

				tsarball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				tsarball.SpriteOffset = Vector(0, -14)
				tsarball:GetSprite():Play("GlobAppear0" .. tsarballData.variant)

				data.numballs = data.numballs + 1
			end
		end

		if sprite:IsEventTriggered("JumpStart") or sprite:IsEventTriggered("Appear") then
			sfx:Play(mod.Sounds.TsarJump)
		end

		if sprite:IsEventTriggered("Reveal") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.RenderZOffset = 0
		end

		if sprite:IsEventTriggered("Hide") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.RenderZOffset = -5000
		end

		if sprite:IsEventTriggered("Jump") then
			data.state = "ascend"
			data.ascendaccel = 30

			data.creepy = false

			npc.SpriteOffset = npc.SpriteOffset + Vector(0, -data.ascendaccel)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

			npc:PlaySound(mod.Sounds.Tsar, 1, 0, false, 1.2)
		end

		if sprite:IsEventTriggered("Land") then
			data.creepy = true

			game:ShakeScreen(10)
			npc:PlaySound(mod.Sounds.Tsar, 1, 0, false, 0.85)
			npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 0.6, 0, false, 1)

			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

			for i = 3, 4 do
				local splash = Isaac.Spawn(1000, 16, i, npc.Position, Vector.Zero, npc)
				splash.Color = mod.tsarColors[data.form + 1]
			end

			if not sprite:IsPlaying("Intro") then
				data.state = "still"
				mod.XalumBreakGridsInRadius(npc.Position, npc.Size)

				local pipes = Isaac.FindInRadius(npc.Position, 200, EntityPartition.ENEMY)
				for _, pipe in pairs(pipes) do
					if pipe.Type == mod.FF.BigPipe.ID and pipe.Variant == mod.FF.BigPipe.Var then
						pipe:GetSprite():Play("Shoot")
					end
				end

				for _, bubble in pairs(Isaac.FindByType(mod.FF.TarBubble.ID, mod.FF.TarBubble.Var)) do
					for i = 30, 360, 30 do
						local rand = data.rng:RandomFloat()
						local projectile = Isaac.Spawn(9, bubble.SubType == 10 and 3 or 0, 0, bubble.Position, Vector(0,2):Rotated(i-40+rand*80), bubble):ToProjectile()
						projectile.FallingSpeed = -50 + math.random(10)
						projectile.FallingAccel = 2
						projectile.Velocity = projectile.Velocity * (math.random(12, 20)/10)
						projectile.Scale = math.random(8, 12)/10
						projectile.Color = (projectile.Variant == 3) and projectile.Color or (bubble.SplatColor or mod.ColorDankBlackReal)
					end

					bubble:Kill()
				end
			end
		end

		if npc:HasMortalDamage() then
			sfx:Play(mod.Sounds.Tsar, 1.5, 0, false, 1)
			sfx:Play(mod.Sounds.TsarDie, 2, 0, false, 0.8)
		end
	end,
}