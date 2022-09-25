-- Drowsy and Sleep --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

function mod:handleDrowsy(entity, data, sprite)
	data.FFDrowsyDuration = data.FFDrowsyDuration - 1

	if entity.HitPoints <= 0 and entity.MaxHitPoints ~= 0 then
		data.FFDrowsyDuration = nil
		data.FFSleepDuration = nil
	elseif data.FFDrowsyDuration >= 0 then
		local color = Color.Lerp(FiendFolio.StatusEffectColors.Sleep, sprite.Color, data.FFDrowsyDuration / data.FFDrowsyDurationMax)
		entity:SetColor(color, 1, statusColorPriority, false, false)
	end
end

function FiendFolio.AddDrowsy(entity, source, duration, sleepDuration, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddDrowsy(segment, source, duration, sleepDuration, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddDrowsy(segment, source, duration, sleepDuration, true)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and (mod:hasCustomStatus(entity) or data.FFBossStatusResistance) then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		if not (data.FFIsAsleep or data.FFDrowsyDuration ~= nil) then
			data.FFDrowsyDuration = duration
			data.FFDrowsyDurationMax = duration
		end

		data.FFSleepDuration = math.max(data.FFSleepDuration or 0, sleepDuration)
		data.FFDrowsySource = source
		data.FFSleepSource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveDrowsy(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveDrowsy(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveDrowsy(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFDrowsyDuration = nil
	data.FFSleepDuration = nil

	entity:GetSprite().PlaybackSpeed = 1.0
end

function mod:handleSleep(entity, data, sprite)
	data.FFSleepDuration = data.FFSleepDuration - 1

	if entity.HitPoints <= 0 and entity.MaxHitPoints ~= 0 then
		data.FFSleepDuration = nil
	elseif data.FFSleepDuration >= 0 then
		entity:SetColor(FiendFolio.StatusEffectColors.Sleep, 1, statusColorPriority, false, false)

		entity.Velocity = nilvector
		if not entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
			entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			data.FFStatusFlagsToRemove = EntityFlag.FLAG_FREEZE
		end
	end

	sprite.PlaybackSpeed = 1.0
end

function FiendFolio.AddSleep(entity, source, duration, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddSleep(segment, source, duration, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddSleep(segment, source, duration, true)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and (mod:hasCustomStatus(entity) or data.FFBossStatusResistance) then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFSleepDuration = math.max(data.FFSleepDuration or 0, duration)
		data.FFSleepSource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveSleep(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveSleep(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveSleep(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFDrowsyDuration = nil
	data.FFSleepDuration = nil

	entity:GetSprite().PlaybackSpeed = 1.0
end

function mod:sleepOnDamage(data, newDamage, ent)
	local returndata = {}
	if not (data.FFDrowsyDuration ~= nil and data.FFDrowsyDuration > 0) and data.FFSleepDuration ~= nil and data.FFSleepDuration > 0 then
		if mod:isSegmented(ent) then
			local segments = mod:getSegments(ent)

			for _,segment in ipairs(segments) do
				local segmentData = segment:GetData()
				segmentData.FFDrowsyDuration = 0
				segmentData.FFSleepDuration = 0
				segment:GetSprite().PlaybackSpeed = 1.0
			end
		elseif mod:isBasegameSegmented(ent) then
			local segments = mod:getBasegameSegments(ent)

			for _,segment in ipairs(segments) do
				local segmentData = segment:GetData()
				segmentData.FFDrowsyDuration = 0
				segmentData.FFSleepDuration = 0
				segment:GetSprite().PlaybackSpeed = 1.0
			end
		else
			data.FFDrowsyDuration = 0
			data.FFSleepDuration = 0
			ent:GetSprite().PlaybackSpeed = 1.0
		end

		returndata.newDamage = newDamage * FiendFolio.StatusEffectVariables.SleepAwakenDamageMultiplier
		returndata.sendNewDamage = true
		returndata.hasProccedSleep = true
	end
	return returndata
end

function mod:drowsyOnApply(entity, source, data, hasProccedSleep)
	if data.ApplyDrowsy and not hasProccedSleep then
		FiendFolio.AddDrowsy(entity, source.Entity.SpawnerEntity, data.ApplyDrowsyDuration, data.ApplyDrowsySleepDuration)
	end
end

function mod:drowsySleepOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFDrowsyDuration ~= nil and data.FFDrowsyDuration > 0 and not clearingStatus then
		mod:handleDrowsy(npc, data, sprite)
	elseif data.FFSleepDuration ~= nil and data.FFSleepDuration > 0 and not clearingStatus then
		if data.FFDrowsyDuration ~= nil then
			npc.Position = npc.Position - npc.Velocity
		end
		data.FFDrowsyDuration = nil
		data.FFIsAsleep = true
		mod:handleSleep(npc, data, sprite)
		data.hasFFStatusIcon = true
	else
		data.FFDrowsyDuration = nil
		data.FFSleepDuration = nil
		data.FFIsAsleep = false
	end
end

function mod:copyDrowsyAndSleep(copyData, sourceData)
	copyData.FFDrowsyDuration = sourceData.FFDrowsyDuration
	copyData.FFDrowsyDurationMax = sourceData.FFDrowsyDurationMax
	copyData.FFDrowsySource = sourceData.FFDrowsySource

	copyData.FFSleepDuration = sourceData.FFSleepDuration
	copyData.FFSleepSource = sourceData.FFSleepSource
end
