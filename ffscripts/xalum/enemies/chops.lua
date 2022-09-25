local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local DEFAULT_FIRE_ANGLE_LEFT = 160
local DEFAULT_FIRE_ANGLE_RIGHT = -20

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, projectile)
	local data = projectile:GetData()
	local sprite = projectile:GetSprite()

	data.bounces = 0
	sprite:Play("Idle")

	projectile.FallingAccel = -0.1
	projectile.FallingSpeed = 0

	projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
end, mod.FF.ChopsRibProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile)
	projectile.SpriteOffset = Vector(0, 9)

	if projectile.FrameCount % 3 == 0 then
		local trail = Isaac.Spawn(1000, 111, 0, projectile.Position, projectile.Velocity:Rotated(math.random(-45, 45)) * math.random(-10, 20)/100, projectile)
		local trailSprite = trail:GetSprite()

		trailSprite.Offset = Vector(0, -14)
		trailSprite:SetFrame(math.random(3))
	end

	if projectile.FrameCount % 7 == 0 then
		local bloodProjectile = Isaac.Spawn(9, 0, 0, projectile.Position, projectile.Velocity * math.random(20, 45) / 100, projectile):ToProjectile()
		bloodProjectile.Scale = math.random(9, 16) / 10
	end

	local data = projectile:GetData()
	local room = game:GetRoom()
	local willCollideX = room:GetGridCollisionAtPos(projectile.Position + Vector(projectile.Velocity.X, 0):Resized(math.abs(projectile.Velocity.X) + projectile.Size)) >= GridCollisionClass.COLLISION_WALL
	local willCollideY = room:GetGridCollisionAtPos(projectile.Position + Vector(0, projectile.Velocity.Y):Resized(math.abs(projectile.Velocity.Y) + projectile.Size)) >= GridCollisionClass.COLLISION_WALL

	if willCollideX or willCollideY then
		data.bounces = data.bounces + 1

		if data.bounces < 6 then
			sfx:Play(SoundEffect.SOUND_BONE_BOUNCE, 1, 0, false, 1)
		end
	end

	if willCollideX then
		projectile.Velocity = Vector(-projectile.Velocity.X, projectile.Velocity.Y)
	end
	if willCollideY then
		projectile.Velocity = Vector(projectile.Velocity.X, -projectile.Velocity.Y)
	end

	if data.bounces >= 6 then
		projectile:Die()
		Isaac.Spawn(1000, 2, 5, projectile.Position, Vector.Zero, projectile).SpriteOffset = Vector(0, -10)
	end

	if projectile:IsDead() then
		sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, 1)
	end
end, mod.FF.ChopsRibProjectile.Var)

local function GetWalkDirectionFromVelocity(npc)
	local angle = npc.Velocity:GetAngleDegrees()
	
	if math.abs(angle) < 45 or math.abs(angle) > 135 then
		return "Hori"
	elseif angle > 0 then
		return "Down"
	else
		return "Up"
	end
end

local function ConstructAnimation(npc, partial)
	local data = npc:GetData()
	local sprite = npc:GetSprite()

	local animationStage = 5 - data.ribs
	local animationSuffix = ""

	if sprite.FlipX then
		if data.anim == "fire" then
			animationSuffix = "_flip"
		elseif data.anim == "walkHori" or data.anim == "idle" then
			animationStage = math.max(1, animationStage - 1)
		end
	end

	if data.anim == "fire" then
		animationStage = animationStage - 1
	end

	if partial then
		return "_" .. animationStage .. animationSuffix
	else
		return data.anim .. "_" .. animationStage .. animationSuffix
	end 
end

return {
	Init = function(npc)
		local data = npc:GetData()

		data.ribs = 4
		data.walkFrame = 0
		data.lastFireFrame = 0

		data.anim = "idle"
		data.state = "idle"

		mod.XalumInitNpcRNG(npc)
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)
		data.isWalking = false
		npc.Mass = 15

		if sprite:IsFinished("regen") then
			data.state = "idle"
			data.anim = "idle"
			data.ribs = 4
			data.walkFrame = 0
		elseif sprite:IsFinished("fire" .. ConstructAnimation(npc, true)) then
			data.state = "idle"
			data.anim = "idle"
			data.walkFrame = 0
		end

		if npc.FrameCount > 0 and data.state == "idle" then
			mod.XalumRandomPathfind(npc, 2)

			if npc.Velocity:Length() > 0.3 then
				local walkAnimation = GetWalkDirectionFromVelocity(npc)

				if walkAnimation ~= data.lastWalkAnim then
					data.anim = "walk" .. (data.lastWalkAnim or walkAnimation)
				else
					data.anim = "walk" .. walkAnimation
				end

				data.lastWalkAnim = walkAnimation
				data.isWalking = true
			else
				data.anim = "idle"
				data.walkFrame = 0
			end

			if data.anim == "walkHori" or data.anim == "idle" then
				sprite.FlipX = npc.Velocity.X < 0
			else
				sprite.FlipX = false
			end

			local projectileRatio = Isaac.CountEntities(nil, 9, mod.FF.ChopsRibProjectile.Var) / Isaac.CountEntities(nil, mod.FF.Chops.ID, mod.FF.Chops.Var)
			local canShoot = projectileRatio < 1.5 and npc.FrameCount - data.lastFireFrame > 45
			local forceShoot = npc.FrameCount - data.lastFireFrame > 105 or data.ribs == 0

			if npc.FrameCount % 15 == 0 and canShoot and (data.rng:RandomFloat() < 1/16 or forceShoot) then
				if data.anim == "idle" or data.anim == "walkUp" or data.anim == "walkDown" then
					sprite.FlipX = data.rng:RandomFloat() < 0.5
				end

				if data.ribs > 0 then
					data.ribs = data.ribs - 1

					data.state = "shoot"
					data.anim = "fire"
				else
					data.state = "regen"
					sprite:Play("regen")
				end

				data.lastFireFrame = npc.FrameCount
				data.isWalking = false
			end
		elseif data.state == "shoot" or data.state == "regen" then
			npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.2)
		end

		if sprite:IsEventTriggered("spawn") then
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)

			local fireLeft = data.ribs % 2 == 1
			local fireAngle = DEFAULT_FIRE_ANGLE_LEFT

			if not fireLeft then
				fireAngle = DEFAULT_FIRE_ANGLE_RIGHT
			end
			if data.rng:RandomFloat() < 0.5 then
				fireAngle = fireAngle + 40
			end

			local projectile = Isaac.Spawn(9, mod.FF.ChopsRibProjectile.Var, 0, npc.Position, Vector.FromAngle(fireAngle):Resized(8), npc)
			Isaac.Spawn(1000, 2, 5, npc.Position + Vector(0, -5), Vector.Zero, npc).SpriteOffset = Vector(0, -8)
		end

		if data.isWalking then
			local frame = sprite:GetFrame()
			if frame == 4 or frame == 16 then
				npc:PlaySound(mod.Sounds.BertranStep, 0.15, 0, false, 0.8 + math.random() * 0.3)
			end
		end

		if data.state ~= "regen" then
			local animation = ConstructAnimation(npc)
			if data.isWalking then
				sprite:SetFrame(animation, data.walkFrame)
				data.walkFrame = (data.walkFrame + 1) % 22
			else
				sprite:Play(animation)
			end
		end
	end,
}