-- Bloated --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

-- NOTE: Unfinished

function mod:findBloatedHomingTarget(position, radius, ignoreIndex)
	local possibleTargets = Isaac.FindInRadius(position, radius, EntityPartition.ENEMY)

	local closestDistance = radius
	local closestEntity = nil

	for i = 1, #possibleTargets do
		local entity = possibleTargets[i]

		if entity.Index ~= ignoreIndex and
		   entity:IsVulnerableEnemy() and
		   entity:IsActiveEnemy(false) and
		   (not entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)) then
			local distance = (entity.Position - position):Length()

			if distance <= closestDistance then
				closestDistance = distance
				closestEntity = entity
			end
		end
	end

	return closestEntity
end

function mod:bloatedDamageInRadiusTable(t, position, damage, radius, flags, source, ignoreIndex)
	for i = 1, #t do
		local entity = t[i]
		local distance = (entity.Position - position):Length()

		if distance <= radius then
			if entity.Index ~= ignoreIndex then
				local damageflags = 0

				--if flags & TearFlags.TEAR_EXPLOSIVE then
				--	damageflags = DamageFlag.DAMAGE_EXPLOSION
				--	entity.Velocity = entity.Velocity + (entity.Position - position):Resized(10)
				--end

				entity:TakeDamage(damage, damageflags, source, 0)
			end
		end
	end
end

function mod:bloatedDamageInRadius(position, damage, radius, flags, source, hurtPlayers, ignoreIndex)
	local possibleEnemies = Isaac.FindInRadius(position, radius, EntityPartition.ENEMY)
	mod:bloatedDamageInRadiusTable(possibleEnemies, position, damage, radius, flags, source, ignoreIndex)

	if hurtPlayers then
		local possiblePlayers = Isaac.FindInRadius(position, radius, EntityPartition.PLAYER)
		mod:bloatedDamageInRadiusTable(possiblePlayers, position, 1, radius, flags, source, ignoreIndex)
	end
end

function mod:handleBloated(entity, data, sprite)
	data.FFBloatedDuration = data.FFBloatedDuration - 1

	if data.FFBloatedDuration >= 0 then
		local statusSourceEntity = data.FFBloatedSource
		local frameCount = game:GetFrameCount()
		--entity:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		if data.FFBloatedColor == nil then
			entity:SetColor(FiendFolio.StatusEffectColors.Bloated, 1, statusColorPriority, false, false)
		else
			entity:SetColor(data.FFBloatedColor, 1, statusColorPriority, false, false)
		end

		data.FFBloatedTickRate = data.FFBloatedTickRate - 1
		if data.FFBloatedTickRate <= 0 then
			data.FFBloatedTickRate = data.FFBloatedMaxTickRate

			local damageflags = 0

			if data.FFBloatedFlags & TearFlags.TEAR_EXPLOSIVE ~= TearFlags.TEAR_NORMAL then
				-- ENTITYREF WHY DO YOU RETURN A CONST ENTITY AAAAAAAAAAA
				game:BombExplosionEffects(entity.Position, data.FFBloatedDamage, data.FFBloatedFlags, data.FFBloatedColor, nil, entity.Size / 40 + 0.5, true, true)
			else
				entity:TakeDamage(data.FFBloatedDamage, damageflags, EntityRef(data.FFBloatedSource), 0)
			end

			if data.FFBloatedFlags & TearFlags.TEAR_MIGAN ~= TearFlags.TEAR_NORMAL then
				local blueFly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, statusSourceEntity.Position, nilvector, statusSourceEntity):ToFamiliar()
				blueFly.Target = entity
				blueFly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				blueFly:Update()
			end
		end

		if data.FFBloatedFlags & TearFlags.TEAR_POP ~= TearFlags.TEAR_NORMAL or data.FFBloatedFlags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_NORMAL then
			local multiplier = 1 - math.min(data.FFBloatedDurationMax - 15, (data.FFBloatedDurationMax - data.FFBloatedDuration)) / (data.FFBloatedDurationMax - 15)
			entity.Position = entity.Position - entity.Velocity
			entity.Velocity = entity.Velocity * multiplier
			entity.Position = entity.Position + entity.Velocity
		end

		if data.FFBloatedFlags & TearFlags.TEAR_WAIT ~= TearFlags.TEAR_NORMAL and statusSourceEntity.Type == EntityType.ENTITY_PLAYER then
			local player = Isaac.GetPlayer(0)
			local shootingInputLength = player:GetShootingInput():Length()
			local shootingJoystickLength = player:GetShootingJoystick():Length()

			if shootingInputLength ~= 0.0 or shootingJoystickLength ~= 0.0 then
				entity.Velocity = nilvector

				if not entity:HasEntityFlags(EntityType.FLAG_FREEZE) then
					entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
					data.FFStatusFlagsToRemove = EntityFlag.FLAG_FREEZE
				end
			end
		end

		if data.FFBloatedFlags & TearFlags.TEAR_HOMING ~= TearFlags.TEAR_NORMAL or data.FFBloatedFlags & TearFlags.TEAR_BELIAL ~= TearFlags.TEAR_NORMAL then
			if data.FFBloatedAffectedEntity == nil or data.FFBloatedAffectedEntity:IsDead() == true or data.FFBloatedAffectedEntity:Exists() == false then
				data.FFBloatedAffectedEntity = mod:findBloatedHomingTarget(entity.Position, FiendFolio.StatusEffectVariables.BloatedHomingRadius, entity.Index)
			end

			if data.FFBloatedAffectedEntity ~= nil then
				data.FFBloatedHomingTargetVelocity = data.FFBloatedHomingTargetVelocity * FiendFolio.StatusEffectVariables.BloatedHomingTargetFriction + (data.FFBloatedAffectedEntity.Position - entity.Position) * FiendFolio.StatusEffectVariables.BloatedHomingStrength
				entity.Velocity = entity.Velocity * FiendFolio.StatusEffectVariables.BloatedHomingFriction + data.FFBloatedHomingTargetVelocity
			end
		end

		if data.FFBloatedFlags & TearFlags.TEAR_BOMBERANG ~= TearFlags.TEAR_NORMAL then
			data.FFBloatedBoomerangTargetVelocity = data.FFBloatedBoomerangTargetVelocity * FiendFolio.StatusEffectVariables.BloatedBoomerangTargetFriction + (statusSourceEntity.Position - entity.Position) * FiendFolio.StatusEffectVariables.BloatedBoomerangStrength
			entity.Velocity = entity.Velocity * FiendFolio.StatusEffectVariables.BloatedBoomerangFriction + data.FFBloatedBoomerangTargetVelocity
		end

		if entity.HitPoints <= 0 then
			data.FFBloatedDuration = 0
		end

		if data.FFBloatedDuration == 0 then
			for i = 0, 7 do
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, entity.Position, Vector(data.FFBloatedShotSpeed, 0):Rotated(i/8 * 360), statusSourceEntity):ToTear()
				local tearData = tear:GetData()

				tear.CollisionDamage = data.FFBloatedDamage
				tear.Height = data.FFBloatedHeight
				tear.FallingSpeed = data.FFBloatedFallingSpeed
				tear.FallingAcceleration = data.FFBloatedFallingAcceleration
				if data.FFBloatedColor ~= nil then
					tear:SetColor(data.FFBloatedColor, 999999, 0, false, false)
				end

				tear.TearFlags = data.FFBloatedFlags

				if tear.TearFlags & TearFlags.TEAR_HOMING ~= TearFlags.TEAR_NORMAL then
					tear.TearFlags = tear.TearFlags & ~TearFlags.TEAR_HOMING
					tearData.FFBloatedHoming = data.FFBloatedFlags & TearFlags.TEAR_HOMING ~= TearFlags.TEAR_NORMAL
				end

				if tear.TearFlags & TearFlags.TEAR_BOMBERANG ~= TearFlags.TEAR_NORMAL then
					tear.TearFlags = tear.TearFlags & ~TearFlags.TEAR_BOMBERANG
					tearData.FFBloatedBoomerang = data.FFBloatedFlags & TearFlags.TEAR_BOMBERANG ~= TearFlags.TEAR_NORMAL
					tearData.FFBloatedBoomerangTarget = entity
					tear.FallingAcceleration = tear.FallingAcceleration - 0.045
				end

				tear.TearFlags = tear.TearFlags & ~TearFlags.TEAR_WAIT

				tearData.FFBloatedIgnoreIndex = entity.Index
				tear.CanTriggerStreakEnd = false
				tearData.FFBloatedSpawnerEntity = data.FFBloatedSource

				tear:ResetSpriteScale()
				tear:Update()
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	local data = tear:GetData()

	if data.FFBloatedHoming and tear.FrameCount > 1 then
		if data.FFBloatedAffectedEntity == nil or data.FFBloatedAffectedEntity:IsDead() == true or data.FFBloatedAffectedEntity:Exists() == false then
			data.FFBloatedAffectedEntity = mod:findBloatedHomingTarget(tear.Position, FiendFolio.StatusEffectVariables.BloatedHomingRadius, data.FFBloatedIgnoreIndex)
		end

		if data.FFBloatedAffectedEntity ~= nil then
			local homingTargetVelocity = (data.FFBloatedAffectedEntity.Position - tear.Position) * FiendFolio.StatusEffectVariables.BloatedHomingTearStrength
			tear.Velocity = tear.Velocity * FiendFolio.StatusEffectVariables.BloatedHomingTearFriction + homingTargetVelocity
		end
	end

	if data.FFBloatedBoomerang then
		if data.FFBloatedBoomerangTarget ~= nil and (data.FFBloatedBoomerangTarget:IsDead() == true or data.FFBloatedBoomerangTarget:Exists() == false) then
			data.FFBloatedBoomerangTarget = nil
		end

		if data.FFBloatedBoomerangTarget ~= nil then
			local boomerangTargetVelocity = (data.FFBloatedBoomerangTarget.Position - tear.Position) * FiendFolio.StatusEffectVariables.BloatedBoomerangTearStrength
			tear.Velocity = tear.Velocity * FiendFolio.StatusEffectVariables.BloatedBoomerangTearFriction + boomerangTargetVelocity
		elseif data.FFBloatedSpawnerEntity ~= nil then
			local boomerangTargetVelocity = (data.FFBloatedSpawnerEntity.Entity.Position - tear.Position) * FiendFolio.StatusEffectVariables.BloatedBoomerangTearStrength
			tear.Velocity = tear.Velocity * FiendFolio.StatusEffectVariables.BloatedBoomerangTearFriction + boomerangTargetVelocity
		end
	end

	if data.FFBloatedAttemptedCollisionThisFrame then
		data.FFBloatedAttemptedCollisionThisFrame = false
	elseif tear.FrameCount > 1 then
		data.FFBloatedForceCollide = true
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider, low)
	local data = tear:GetData()
	if data.FFBloatedIgnoreIndex ~= nil and data.FFBloatedIgnoreIndex == collider.Index then
		if not data.FFBloatedForceCollide == true then
			data.FFBloatedAttemptedCollisionThisFrame = true
			return true
		end
	end
end)

function mod:isNormalColor(color)
	return color.R == FiendFolio.ColorNormal.R and
	       color.G == FiendFolio.ColorNormal.G and
	       color.B == FiendFolio.ColorNormal.B and
	       color.A == FiendFolio.ColorNormal.A and
	       color.RO == FiendFolio.ColorNormal.RO and
	       color.GO == FiendFolio.ColorNormal.GO and
	       color.BO == FiendFolio.ColorNormal.BO
end

function FiendFolio.AddBloated(entity, source, duration, damage, tickrate, shotspeed, height, fallingSpeed, fallingAcceleration, flags, color, isCloned)
	local data = entity:GetData()
	if not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity) or data.FFBossStatusResistance) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then

		data.FFBloatedDamage = damage
		data.FFBloatedMaxTickRate = tickrate
		data.FFBloatedShotSpeed = shotspeed
		data.FFBloatedHeight = height
		data.FFBloatedFallingSpeed = fallingSpeed
		data.FFBloatedFallingAcceleration = fallingAcceleration

		data.FFBloatedFlags = flags
		data.FFBloatedAffectedEntity = nil

		if data.FFBloatedDuration == nil or data.FFBloatedDuration == 0 then
			data.FFBloatedTickRate = tickrate

			data.FFBloatedHomingTargetVelocity = Vector(0,0)
			data.FFBloatedBoomerangTargetVelocity = Vector(0,0)
		else
			data.FFBloatedTickRate = math.min(data.FFBloatedTickRate, tickrate)

			if data.FFBloatedHomingTargetVelocity == nil or flags & TearFlags.TEAR_HOMING == TearFlags.TEAR_NORMAL then
				data.FFBloatedHomingTargetVelocity = Vector(0,0)
			end

			if data.FFBloatedBoomerangTargetVelocity == nil or flags & TearFlags.TEAR_BOMBERANG == TearFlags.TEAR_NORMAL then
				data.FFBloatedBoomerangTargetVelocity = Vector(0,0)
			end
		end

		if mod:isNormalColor(color) then
			data.FFBloatedColor = nil
		else
			data.FFBloatedColor = color
		end

		data.FFBloatedDuration = duration
		data.FFBloatedDurationMax = duration
		data.FFBloatedSource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveBloated(entity)
	local data = entity:GetData()
	data.FFBloatedDuration = nil
end

function mod:bloatedOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFBloatedDuration ~= nil and data.FFBloatedDuration > 0 and not clearingStatus then
		mod:handleBloated(npc, data, sprite)
	else
		data.FFBloatedDuration = nil
	end
end
