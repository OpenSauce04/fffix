-- Hemorrhaging --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

function mod:handleBleed(entity, data, sprite)
	data.FFBleedDuration = data.FFBleedDuration - 1
	if data.FFBleedDuration >= 0 then
		--entity:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		entity:SetColor(FiendFolio.StatusEffectColors.Bleed, 1, statusColorPriority, false, false)

		if not data.FFBleedSource or not data.FFBleedSource:Exists() then
			data.FFBleedSource = Isaac.GetPlayer(0)
		end

		local frameCount = game:GetFrameCount()

		if mod:checkIfStatusLogicIsApplied(entity, true) then
			if frameCount % FiendFolio.StatusEffectVariables.BleedDamageTickRate == 0 then
				data.FFTakingBleedDamage = true
				entity:TakeDamage(data.FFBleedDamage * FiendFolio.StatusEffectVariables.BleedDamagePercentage, 0, EntityRef(data.FFBleedSource), 0)
				data.FFTakingBleedDamage = nil
			end
		end

		if frameCount % FiendFolio.StatusEffectVariables.BleedCreepTickRate == 0 then
			local size = entity.Size
			local hasCork = data.FFBleedHasCork

			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, entity.Position, nilvector, data.FFBleedSource):ToEffect()
			creep.Scale = size / 15 + 0.15
			if hasCork then creep.Scale = creep.Scale * 2 end

			creep.CollisionDamage = data.FFBleedDamage * FiendFolio.StatusEffectVariables.BleedCreepDamagePercentage
			creep:SetTimeout(FiendFolio.StatusEffectVariables.BleedCreepTimeout)
			creep:Update()

			if (hasCork and size >= 15) or size >= 30 then
				math.randomseed(creep.InitSeed)
				creep:GetSprite():SetFrame("BiggestBlood0"..math.random(6), 0)

				local creepScale = size / 48 + 0.15
				if hasCork then creepScale = creepScale * 2 end

				creep.Scale = creepScale
				creep.Size = creepScale
				creep.SpriteScale = Vector(creepScale, creepScale)
			elseif (hasCork and size >= 7.5) or size >= 15 then
				math.randomseed(creep.InitSeed)
				creep:GetSprite():SetFrame("BigBlood0"..math.random(6), 0)

				local creepScale = size / 25 + 0.15
				if hasCork then creepScale = creepScale * 2 end

				creep.Scale = creepScale
				creep.Size = creepScale
				creep.SpriteScale = Vector(creepScale, creepScale)
			end
		end
		
		if math.random() <= FiendFolio.StatusEffectVariables.BleedTearChance then
			if not (mod:isSegmented(entity) or mod:isBasegameSegmented(entity)) or
			   mod:isMainSegment(entity) or mod:isBasegameMainSegment(entity)
			then
				local angle = math.random() * 360.0
				local vel = Vector.FromAngle(angle):Resized(math.random() * FiendFolio.StatusEffectVariables.BleedTearVelocityScale + FiendFolio.StatusEffectVariables.BleedTearVelocityBase)
				vel = vel + entity.Velocity * FiendFolio.StatusEffectVariables.BleedTearEntityVelocityInheritance
				
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, entity.Position, vel, data.FFBleedSource):ToTear()
				local rand = math.random()
				tear.CollisionDamage = data.FFBleedDamage * (rand * 0.3375 + 0.675) * FiendFolio.StatusEffectVariables.BleedTearDamagePercentage
				tear.Scale = (0.55 + math.sqrt(data.FFBleedDamage) * 0.23 + data.FFBleedDamage / 100) * (rand * 0.5 + 0.75)
				tear.Height = -11.01 + math.random() * 1.02
				tear.FallingSpeed = -14.1 + math.random() * 10.2
				tear.FallingAcceleration = 0.5
				
				tear:GetData().FFHemorrhagingTear = true
				tear:GetData().FFHemorrhagingTearSpawner = entity
				tear:Update()
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, entity, mysteryBoolean)
	local data = tear:GetData()
	local spawnerEntity = data.FFHemorrhagingTearSpawner
	
	if data.FFHemorrhagingTear and spawnerEntity and spawnerEntity:Exists() then
		if spawnerEntity.Index == entity.Index and spawnerEntity.InitSeed == entity.InitSeed then
			return true
		elseif mod:isSegmented(spawnerEntity) and mod:isInSegmentsOf(entity, spawnerEntity) then
			return true
		elseif mod:isBasegameSegmented(spawnerEntity) and mod:isInBasegameSegmentsOf(entity, spawnerEntity) then
			return true
		end
	end
end)

function FiendFolio.AddBleed(entity, source, duration, damage, isCloned, isSanguine)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddBleed(segment, source, duration, damage, true, isSanguine)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddBleed(segment, source, duration, damage, true, isSanguine)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and 
	   (mod:hasCustomStatus(entity, isSanguine) or (data.FFBossStatusResistance and (not isSanguine or not data.FFBossStatusResistanceFromBruise))) 
	then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFBleedDuration = math.max(data.FFBleedDuration or 0, duration)
		data.FFBleedDamage = math.max(data.FFBleedDamage or 0, damage)
		data.FFBleedSource = source
		
		data.FFBleedHasCork = source and 
			                  source.Type == EntityType.ENTITY_PLAYER and 
			                  source:ToPlayer():HasTrinket(TrinketType.TRINKET_LOST_CORK)
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveBleed(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveBleed(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveBleed(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFBleedDuration = nil
end

function mod:hemorragingOnApply(entity, source, data)
	if data.ApplyBleed then
		FiendFolio.AddBleed(entity, source.Entity.SpawnerEntity, data.ApplyBleedDuration, data.ApplyBleedDamage)
	end
end

function mod:hemorragingOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFBleedDuration ~= nil and data.FFBleedDuration > 0 and not clearingStatus then
		mod:handleBleed(npc, data, sprite)
		data.hasFFStatusIcon = true
	else
		data.FFBleedDuration = nil
	end
end

function mod:copyHemorraging(copyData, sourceData)
	copyData.FFBleedDuration = sourceData.FFBleedDuration
	copyData.FFBleedDamage = sourceData.FFBleedDamage
	copyData.FFBleedSource = sourceData.FFBleedSource
	copyData.FFBleedHasCork = sourceData.FFBleedHasCork
end
