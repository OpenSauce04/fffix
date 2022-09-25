local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local SPIN_PROJ_FREQUENCY = 6
local SPIN_PROJ_SPEED = 7.5

local function DoSlingerSpinAttack(npc, heightOffset)
	local data = npc:GetData()

	if (npc.FrameCount - data.spinstart) % SPIN_PROJ_FREQUENCY == 0 then
		if npc.SubType == mod.FF.Slinger.Sub then
			for i = 1, 4 do
				local rotation = i * 90 + (npc.FrameCount - data.spinstart) * 6
				local direction = Vector(SPIN_PROJ_SPEED, 0):Rotated(rotation)
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, direction, npc):ToProjectile()
				projectile:AddHeight(heightOffset)
			end

			local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
			splash.SpriteOffset = Vector(0, -8)

			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, math.random(9, 11) / 10)
		elseif npc.SubType == mod.FF.SlingerBlack.Sub then
			for i = 1, 2 do
				local rotation = i * 180 + (npc.FrameCount - data.spinstart) * 5
				local direction = Vector(SPIN_PROJ_SPEED, 0):Rotated(rotation)
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, direction, npc):ToProjectile()
				projectile:AddHeight(heightOffset)

				direction = Vector(SPIN_PROJ_SPEED, 0):Rotated(-rotation)
				projectile = Isaac.Spawn(9, 0, 0, npc.Position, direction, npc):ToProjectile()
				projectile:AddHeight(heightOffset)
			end

			local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
			splash.SpriteOffset = Vector(0, -8 + heightOffset)

			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, math.random(9, 11) / 10)
		end
	end
end

local function GetNumSkuzzSpiders()
	local spiders 		= Isaac.CountEntities(nil, 85, 0)
	local skuzz 		= Isaac.CountEntities(nil, mod.FF.Skuzz.ID, mod.FF.Skuzz.Var)
	local skuzzballs 	= 2 * Isaac.CountEntities(nil, mod.FF.SkuzzballSmall.ID, mod.FF.SkuzzballSmall.Var) -- Double Weight

	return spiders + skuzz + skuzzballs
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile)
	local data = projectile:GetData()
	if data.slinger_breakaway and not projectile:IsDead() then
		local roomProjectiles = Isaac.FindByType(9, ProjectileVariant.PROJECTILE_ROCK)

		for _, proj in pairs(roomProjectiles) do
			if not mod.XalumGetEntityEquality(projectile, proj) then
				if projectile.Position:Distance(proj.Position) < proj.Size + projectile.Size then

					for i = 1, 3 do
						Isaac.Spawn(9, ProjectileVariant.PROJECTILE_ROCK, 0, projectile.Position, projectile.Velocity:Rotated(60 - i * 30), projectile.SpawnerEntity)
						Isaac.Spawn(9, ProjectileVariant.PROJECTILE_ROCK, 0, proj.Position, proj.Velocity:Rotated(60 - i * 30), proj.SpawnerEntity)
					end

					projectile:Die()
					proj:Die()
				end
			end
		end
	end
end, ProjectileVariant.PROJECTILE_ROCK)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if npc.Variant == mod.FF.ThrownOralid.Var and npc.State ~= NpcState.STATE_JUMP then
		local new = Isaac.Spawn(mod.FF.Oralid.ID, mod.FF.Oralid.Var, 0, npc.Position, Vector.Zero, npc.SpawnerEntity)
		new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		new:GetData().init = true
		new.HitPoints = new.MaxHitPoints * 0.5

		local newSprite = new:GetSprite()
		newSprite:Play("Idle")
		if npc:GetData().slingerspawned then
			newSprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/slinger_oralid.png")
			newSprite:LoadGraphics()
		end

		npc:Remove()
	end
end, mod.FF.ThrownOralid.ID)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	if entity.Variant == mod.FF.Slinger.Var and game:GetRoom():GetFrameCount() > 0 then
		mod.savedata.hasBeatenSlinger = true
	end
end, mod.FF.Slinger.ID)

return {
	Init = function(npc)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		local sprite = npc:GetSprite()
		sprite:Play("Appear")

		if mod.savedata.hasBeatenSlinger and npc.SubType == mod.FF.Slinger.Sub and game.Challenge ~= mod.challenges.theGauntlet and game:GetRoom():GetType() == RoomType.ROOM_BOSS then
			local rng = npc:GetDropRNG()
			if rng:RandomFloat() < 1/3 then
				npc.SubType = mod.FF.SlingerBlack.Sub
			end
		end

		if npc.SubType == mod.FF.SlingerBlack.Sub then
			for i = 0, 2 do
				sprite:ReplaceSpritesheet(i, "gfx/bosses/slinger/slinger_black.png")
			end
			sprite:LoadGraphics()
		end

		local data = npc:GetData()

		data.lastroll = 0
		data.lastspin = 0
		data.anglelim = 5
		data.swingspeed = 0.5
		data.slowmode = false
		data.lastGridCollision = -40

		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 42)

		data.shadow = Isaac.Spawn(mod.FF.DetatchedShadow.ID, mod.FF.DetatchedShadow.Var, mod.FF.DetatchedShadow.Sub, npc.Position, Vector.Zero, npc)

		data.chunksParams = ProjectileParams()
		data.chunksParams.FallingAccelModifier = 2
		data.chunksParams.Variant = ProjectileVariant.PROJECTILE_ROCK
		data.chunksParams.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

		data.splatParams = ProjectileParams()
		data.splatParams.FallingAccelModifier = 2
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		
		mod.QuickSetEntityGridPath(npc)

		if sprite:IsFinished("Appear") then
			sprite:Play("Intro")
		elseif sprite:IsFinished("Intro") or sprite:IsFinished("StopSpin") or sprite:IsFinished("WrapFall") or sprite:IsFinished("PullFoetu") or sprite:IsFinished("PullChunks") or sprite:IsFinished("HeadRegrow") then
			sprite:Play("Idle")
			data.last = npc.FrameCount
		elseif sprite:IsFinished("StartSpin") then
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.6, 0)

			local roll = data.rng:RandomInt(2) + 1
			if roll == data.lastspin then roll = data.rng:RandomInt(2) + 1 end

			data.spinstart = npc.FrameCount

			if roll == 1 then
				sprite:Play("ContSpin")
			elseif roll == 2 then
				sprite:Play("WrapSpin")
			end
		elseif sprite:IsFinished("WrapSpin") then
			sprite:Play("WrapContSpin")
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		elseif sprite:IsFinished("WrapStopSpin") then
			local canEnterPtoo = GetNumSkuzzSpiders() < 4
			local roll = data.rng:RandomInt(2)
			if npc.HitPoints <= npc.MaxHitPoints / 2 then
				roll = 1
			end

			if roll == 0 or not canEnterPtoo then
				sprite:Play("WrapFall")
			else
				sprite:Play("Wrapped")

				data.last = npc.FrameCount
				data.wrapstart = npc.FrameCount

				data.anglelim = 5
				data.swingspeed = 0.5
				data.slowmode = false

				sprite.Offset = Vector(0, -334)
			end
		elseif sprite:IsFinished("WrapPtoo") then
			sprite:Play("Wrapped")
			data.last = npc.FrameCount
		elseif sprite:IsFinished("PullFoetuStart") then
			sprite:Play("PullFoetu")
		elseif sprite:IsFinished("ThrowHead") or sprite:IsFinished("ThrowHeadLeft") then
			sprite:Play("HeadRegrow")
		end

		data.shadow.Velocity = npc.Position + npc.Velocity + Vector(Vector(0, 400):Rotated(sprite.Rotation + data.swingspeed).X, 0) - data.shadow.Position

		local animation = sprite:GetAnimation()

		if animation == "Idle" or animation == "BodyWalk" or animation == "BodyWalkHorz" then
			if data.last + 25 <= npc.FrameCount then
				local room = game:GetRoom()
				local targetPosition = npc:GetPlayerTarget().Position
				local targetVelocity = (targetPosition - npc.Position):Resized(2.5)
				local hasLineOfSight = room:CheckLine(npc.Position, targetPosition, 1)

				if npc:CollidesWithGrid() then
					data.lastGridCollision = npc.FrameCount
				end

				if hasLineOfSight and data.lastGridCollision + 24 < npc.FrameCount then
					npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.15)
				else
					npc.Pathfinder:FindGridPath(targetPosition, 0.3, 0, true) -- Why is this so fucking fast ??????
				end

				npc:AnimWalkFrame("BodyWalkHorz", "BodyWalk", 0.3)
				animation = sprite:GetAnimation()
				sprite.FlipX = npc.Velocity.X < 0 and animation == "BodyWalkHorz"
			else
				npc.Velocity = npc.Velocity * 0.8
				sprite.FlipX = false
			end

			if data.last + 75 <= npc.FrameCount and data.rng:RandomFloat() < 1/6 then
				local roll = 0

				local canPullChunks = Isaac.CountEntities(nil, 21, 750) + Isaac.CountEntities(nil, 23, 0) == 0
				local canThrowHead = GetNumSkuzzSpiders() < 4

				repeat
					roll = data.rng:RandomInt(4) + 1

					local validPullChunks = roll ~= 3 or canPullChunks
					local validThrowHead = roll ~= 4 or canThrowHead
				until validPullChunks and validThrowHead and roll ~= data.lastroll

				if roll == 1 then
					sprite:Play("StartSpin")
				elseif roll == 2 then
					sprite:Play("PullFoetuStart")
				elseif roll == 3 then
					sprite:Play("PullChunks")
				elseif roll == 4 then
					sprite:Play("ThrowHead")
				end

				data.lastroll = roll
				sprite.FlipX = false
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end

		if animation == "BodyWalk" or animation == "BodyWalkHorz" then
			local overlay = sprite.FlipX and "HeadOverlayWalkFlip" or "HeadOverlayWalk"
			sprite:PlayOverlay(overlay)
		else
			sprite:RemoveOverlay()
		end

		if sprite:IsPlaying("Wrapped") or sprite:IsPlaying("WrapPtoo") then
			if data.last + 24 <= npc.FrameCount and sprite:IsPlaying("Wrapped") then
				sprite:Play("WrapPtoo")
			end

			sprite.Rotation = sprite.Rotation + data.swingspeed

			if data.slowmode then
				if sprite.Rotation >= 0 then
					if data.swingspeed > 0.05 then
						data.swingspeed = data.swingspeed * 0.8
					else
						data.swingspeed = -math.abs(data.swingspeed) * 1.15
					end
				else
					if data.swingspeed < -0.05 then
						data.swingspeed = data.swingspeed * 0.8
					else
						data.swingspeed = math.abs(data.swingspeed) * 1.15
					end
				end
			else
				if sprite.Rotation >= 0 then
					if data.swingspeed > 0.05 then
						data.swingspeed = data.swingspeed * 0.9
					else
						data.swingspeed = -math.abs(data.swingspeed) * 1.15
					end
				else
					if data.swingspeed < -0.05 then
						data.swingspeed = data.swingspeed * 0.9
					else
						data.swingspeed = math.abs(data.swingspeed) * 1.15
					end
				end
			end

			if data.wrapstart + 180 <= npc.FrameCount and not data.slowmode then
				data.slowmode = true
			end

			if data.wrapstart + 300 <= npc.FrameCount and sprite:IsPlaying("Wrapped") and math.abs(sprite.Rotation) < 0.5 and math.abs(data.swingspeed) < 0.5 then
				sprite:Play("WrapFall")
				sprite.Rotation = 0
				sprite.Offset = Vector.Zero
			end
		end

		if sprite:IsPlaying("ContSpin") then
			if data.spinstart + 90 <= npc.FrameCount then
				sprite:Play("StopSpin")
			end

			DoSlingerSpinAttack(npc, 0)
		end

		if sprite:IsPlaying("WrapSpin") then
			local heightEstimate = (data.spinstart - npc.FrameCount) * 2
			DoSlingerSpinAttack(npc, heightEstimate)
		end

		if sprite:IsPlaying("WrapContSpin") then
			if data.spinstart + 60 <= npc.FrameCount then
				sprite:Play("WrapStopSpin")
			end
			DoSlingerSpinAttack(npc, -32)
		end

		if sprite:IsPlaying("WrapFall") and sprite:GetFrame() == 28 then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end

		if (sprite:IsPlaying("ThrowHead") or sprite:IsPlaying("ThrowHeadLeft")) and sprite:GetFrame() < 18 then
			local targetPosition = npc:GetPlayerTarget().Position
			local anim = npc.Position.X < targetPosition.X and "ThrowHead" or "ThrowHeadLeft"

			if not sprite:IsPlaying(anim) then
				local frame = sprite:GetFrame()
				sprite:Play(anim)
				sprite:SetFrame(frame)
			end
		end

		if (sprite:IsPlaying("StopSpin") or sprite:IsPlaying("WrapStopSpin")) and sprite:GetFrame() == 10 then
			sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
		end

		if sprite:IsEventTriggered("ShootString") then
			npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, math.random(9, 10) / 10)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			npc.Velocity = Vector.Zero

			if sprite:IsPlaying("PullFoetuStart") then
				local pos1
				local pos2

				for i = 1, 2 do
					local position = mod.XalumFindWall(npc.Position, Vector(1, 0):Rotated(i * 180)).Position
					local spawnPosition = Vector(position.X, npc.Position.Y)
					local stringshot = Isaac.Spawn(1000, mod.FF.Stringshot.Var, mod.FF.Stringshot.Sub, spawnPosition, Vector.Zero, npc)
					stringshot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					stringshot.SpriteRotation = 180 * (i - 1)
					stringshot.SpriteOffset = Vector(0, -10)

					if npc.SubType == mod.FF.SlingerBlack.Sub then
						local sprite = stringshot:GetSprite()
						sprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/slinger_black.png")
						sprite:ReplaceSpritesheet(2, "gfx/bosses/slinger/slinger_black.png")
						sprite:LoadGraphics()
					end

					if pos1 then
						pos2 = spawnPosition
					else
						pos1 = spawnPosition
					end
				end

				local stringshot = Isaac.Spawn(1000, mod.FF.Stringshot.Var, mod.FF.Stringshot.Sub, (pos1 + pos2) / 2, Vector.Zero, npc)
				stringshot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				stringshot.SpriteOffset = Vector(0, -10)

				local sprite = stringshot:GetSprite()
				sprite:Play("Middle")

				if npc.SubType == mod.FF.SlingerBlack.Sub then
					sprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/slinger_black.png")
					sprite:LoadGraphics()
				end
			end
		end

		if sprite:IsEventTriggered("Pull") then
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, math.random(9, 10) / 10)
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

			if sprite:IsPlaying("PullChunks") then
				for i = 1, 2 do
					local offset = Vector(20, 0):Rotated(i * 180)

					if npc.SubType == mod.FF.Slinger.Sub then
						mod:shootMaggot(npc, npc.Position + offset:Rotated(data.rng:RandomInt(31) - 15) * 2, 0, mod.FF.FlyingMaggotCreepy.Sub)
					elseif npc.SubType == mod.FF.SlingerBlack.Sub then
						mod:shootMaggot(npc, npc.Position + offset:Rotated(data.rng:RandomInt(31) - 15) * 2, 0, mod.FF.FlyingMaggotCharger.Sub)
					end

					for j = 1, 3 + data.rng:RandomInt(2) do
						data.chunksParams.FallingSpeedModifier = (data.rng:RandomInt(20) - 30) * 1.5
						npc:FireProjectiles(npc.Position + offset, RandomVector():Resized(4 - data.rng:RandomFloat() * 2), 0, data.chunksParams)
					end
				end
			elseif sprite:IsPlaying("PullFoetu") then
				for i = 1, 2 do
					local position = mod.XalumFindWall(npc.Position, Vector(1, 0):Rotated(i * 180)).Position
					local spawnPosition = position + Vector(-22, 0):Rotated(180 * i)

					local projectile = Isaac.Spawn(9, ProjectileVariant.PROJECTILE_ROCK, 0, spawnPosition, Vector(-12, 0):Rotated(180 * i), npc):ToProjectile()
					projectile.Scale = 2
					projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)

					projectile:GetData().slinger_breakaway = true

					for j = 1, 3 + data.rng:RandomInt(2) do
						data.chunksParams.FallingSpeedModifier = (data.rng:RandomInt(15) - 20) * 1.5
						local fireDirection = Vector(-1, 0):Rotated(180 * i + (data.rng:RandomInt(61) - 30)):Resized(8 - data.rng:RandomFloat() * 2)

						npc:FireProjectiles(spawnPosition, fireDirection, 0, data.chunksParams)
					end
				end

				for _, stringshot in pairs(Isaac.FindByType(1000, mod.FF.Stringshot.Var, mod.FF.Stringshot.Sub)) do
					if mod.XalumGetEntityEquality(stringshot.SpawnerEntity, npc) then
						stringshot:Remove()
					end
				end
			end
		end

		if sprite:IsEventTriggered("FallSplat") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			game:ShakeScreen(5)

			local offset = Vector(25, 0)

			if sprite:IsPlaying("WrapFall") then
				npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
			elseif sprite:IsPlaying("Intro") then
				offset = Vector(-25, 0)
				Isaac.Spawn(mod.FF.SlingerTooth.ID, mod.FF.SlingerTooth.Var, 1, npc.Position + offset, Vector.Zero, npc)
			end

			Isaac.Spawn(1000, 16, 3, npc.Position + offset, Vector.Zero, npc)
			Isaac.Spawn(1000, 16, 4, npc.Position + offset, Vector.Zero, npc)

			local creep = Isaac.Spawn(1000, 22, 0, npc.Position + offset, Vector.Zero, npc):ToEffect()
			creep.SpriteScale = creep.SpriteScale * 2
			creep:Update()

			for i = 1, 3 + data.rng:RandomInt(4) do
				data.splatParams.FallingSpeedModifier = (data.rng:RandomInt(20) - 30) * 1.5
				data.splatParams.Scale = math.random(12, 18) / 10

				npc:FireProjectiles(npc.Position + offset, RandomVector():Resized(4 - data.rng:RandomFloat() * 2), 0, data.splatParams)
			end
		end

		if sprite:IsEventTriggered("Ptoo") then
			local targetPosition = npc:GetPlayerTarget().Position
			local firingPosition = data.shadow.Position

			if firingPosition:Distance(targetPosition) > 240 then
				targetPosition = targetPosition + (firingPosition - targetPosition):Resized(firingPosition:Distance(targetPosition) - 240)
			end

			local makeOralid = data.rng:RandomFloat() < 0.3

			if npc.SubType == mod.FF.SlingerBlack.Sub and not makeOralid then
				mod.ThrowSkuzz(firingPosition, targetPosition, npc, Vector(0, 270):Rotated(sprite.Rotation).Y - 334)
			else
				EntityNPC.ThrowSpider(firingPosition, npc, targetPosition, false, Vector(0, 270):Rotated(sprite.Rotation).Y - 334)
				if makeOralid then
					local spider
					for _, entity in pairs(Isaac.FindByType(85)) do
						if entity.FrameCount <= 1 and mod.XalumGetEntityEquality(entity.SpawnerEntity, npc) then
							spider = entity:ToNPC()
							break
						end
					end

					spider:Morph(mod.FF.ThrownOralid.ID, mod.FF.ThrownOralid.Var, 0, spider:GetChampionColorIdx())

					local spiderSprite = spider:GetSprite()
					spiderSprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/slinger_oralid.png")
					spiderSprite:LoadGraphics()
					spider:GetData().slingerspawned = true
				end
			end

			npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
		end

		if sprite:IsEventTriggered("Throw") then
			local direction = (npc:GetPlayerTarget().Position - npc.Position):Resized(11)
			local head = Isaac.Spawn(mod.FF.SlingerHead.ID, mod.FF.SlingerHead.Var, npc.SubType, npc.Position, direction, npc)
			npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, math.random(7, 9)/10)
		end

		if npc:IsDead() then
			sprite:RemoveOverlay()
			data.shadow:Remove()
		end
	end,
}