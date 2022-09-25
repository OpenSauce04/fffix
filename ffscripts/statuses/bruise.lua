-- Bruise --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

function mod:handleBruise(entity, data, sprite)
	local numStacks = #data.FFBruiseInstances
	data.FFBruiseLastStacks = numStacks

	if numStacks > 0 then
		local bruiseColor = FiendFolio.StatusEffectColors.BruiseLvl5
		if numStacks == 4 then
			bruiseColor = FiendFolio.StatusEffectColors.BruiseLvl4
		elseif numStacks == 3 then
			bruiseColor = FiendFolio.StatusEffectColors.BruiseLvl3
		elseif numStacks == 2 then
			bruiseColor = FiendFolio.StatusEffectColors.BruiseLvl2
		elseif numStacks == 1 then
			bruiseColor = FiendFolio.StatusEffectColors.BruiseLvl1
		end
		entity:SetColor(bruiseColor, 1, statusColorPriority, false, false)
		
		data.FFHadBruiseThisFrame = true
	end

	for i = numStacks, 1, -1 do
		data.FFBruiseInstances[i].Duration = data.FFBruiseInstances[i].Duration - 1
		if data.FFBruiseInstances[i].Duration <= 0 then
			table.remove(data.FFBruiseInstances, i)
		end
	end
end

function FiendFolio.AddBruise(entity, source, duration, stacks, damagePerStack, isCloned, isSanguine)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddBruise(segment, source, duration, stacks, damagePerStack, true, isSanguine)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddBruise(segment, source, duration, stacks, damagePerStack, true, isSanguine)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC() and entity:ToNPC():IsBoss() and 
	   (mod:hasCustomStatus(entity, true) or (data.FFBossStatusResistance and not data.FFBossStatusResistanceFromBruise)) and 
	   not isSanguine 
	then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFBruiseInstances = data.FFBruiseInstances or {}

		for i = 1, stacks do
			table.insert(data.FFBruiseInstances, {Duration = duration, Damage = damagePerStack, Source = source})
		end
		
		if entity:ToNPC() and entity:ToNPC():IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
			data.FFBossStatusResistanceFromBruise = true
		end
	end
end

function FiendFolio.RemoveBruise(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveBruise(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveBruise(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFBruiseInstances = nil
end

function mod:bruiseOnDamage(data, newDamage, allowDamageEffects)
	local returndata = {}
	if data.FFBruiseInstances ~= nil and #data.FFBruiseInstances > 0 and allowDamageEffects then
		local highestDamages = {}
		for i = 1, #data.FFBruiseInstances do
			for j = 0, math.min(#highestDamages, 4) do
				if highestDamages[j+1] == nil or highestDamages[j+1] <= data.FFBruiseInstances[i].Damage then
					table.insert(highestDamages, j+1, data.FFBruiseInstances[i].Damage)
					break
				end
			end
		end

		local addedDamage = 0
		for i = 1, math.min(#highestDamages, 5) do
			addedDamage = addedDamage + highestDamages[i]
		end

		returndata.newDamage = newDamage + addedDamage
		returndata.sendNewDamage = true
	end
	return returndata
end

function mod:bruiseOnApply(entity, source, data)
	if data.AppliedBruiseToEnemy and data.AppliedBruiseToEnemy[entity.Index .. " " .. entity.InitSeed] then
		-- do nothing
	elseif data.ApplyBruise then
		FiendFolio.AddBruise(entity, source.Entity.SpawnerEntity, data.ApplyBruiseDuration, data.ApplyBruiseStacks, data.ApplyBruiseDamagePerStack)
		data.AppliedBruiseToEnemy = data.AppliedBruiseToEnemy or {}
		data.AppliedBruiseToEnemy[entity.Index .. " " .. entity.InitSeed] = true
	end
end

function mod:bruiseOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFBruiseInstances ~= nil and #data.FFBruiseInstances > 0 and not clearingStatus then
		mod:handleBruise(npc, data, sprite)
		data.hasFFStatusIcon = true
	else
		data.FFBruiseInstances = nil
		data.FFBruiseLastStacks = 0
	end
end

function mod:copyBruise(copyData, sourceData)
	if sourceData.FFBruiseInstances then
		copyData.FFBruiseInstances = {}
		for _, stack in ipairs(sourceData.FFBruiseInstances) do
			table.insert(copyData.FFBruiseInstances, {Duration = stack.Duration, Damage = stack.Damage, Source = stack.Source})
		end
	end
	copyData.FFBruiseLastStacks = sourceData.FFBruiseLastStacks
end
