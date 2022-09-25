-- Cuffs --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:cuffsAI(npc, sprite, npcdata)
	if npcdata.init == nil then
		npcdata.Chains = {}

		local targets = mod:getNearestCuffsTargets(npc.Position, (npc.SubType >> 11 & 31) + 2)
		if #targets >= 2 then
			npcdata.ConnectedEntities = targets

			for i = 1, #targets do
				local target = targets[i]
				local targetData = target:GetData()

				targetData.IsCuffed = true
				targetData.OriginalMaxHitPoints = targetData.OriginalMaxHitPoints or target.MaxHitPoints

				targetData.ConnectedCuffs = targetData.ConnectedCuffs or {}
				table.insert(targetData.ConnectedCuffs, npc)

				local targetChains = {}
				local lastChain = nil
				for i = 1, math.max(1, math.ceil((npc.SubType & 2047) / 40)) do
					local chain = Isaac.Spawn(1000, 1746, i, npc.Position, nilvector, npc)
					chain.Parent = lastChain or npc
					if lastChain then lastChain.Child = chain end
					table.insert(targetChains, chain)
					lastChain = chain
					chain:GetData().Cuffs = npc
				end
				lastChain.Child = target
				table.insert(npcdata.Chains, targetChains)
			end

			mod:syncCuffsMaxHealth(targets)
		else
			sprite:Play("Death")
			npc:PlaySound(SoundEffect.SOUND_FLOATY_BABY_ROAR, 0.7, 0, false, 1.875 + 0.125 * math.random() - 0.0625)
			npc:PlaySound(SoundEffect.SOUND_CHAIN_BREAK, 1.5, 0, false, 1.3 + 0.1 * math.random() - 0.05)
			npcdata.PlayedDeathSounds = true
		end

		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		npcdata.init = true
	end

	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	elseif sprite:IsFinished("Death") then
		npc:Remove()
	elseif not sprite:IsPlaying("Death") then
		local shouldDie = false
		for _,entity in ipairs(npcdata.ConnectedEntities) do
			if (not entity) or (not entity:Exists()) or entity:IsDead() or mod:isStatusCorpse(entity) or mod:fireplaceIsDead(entity) then
				shouldDie = true
				break
			end
		end

		if shouldDie then
			sprite:Play("Death")
			if not npcdata.PlayedDeathSounds then
				npc:PlaySound(SoundEffect.SOUND_FLOATY_BABY_ROAR, 0.7, 0, false, 1.875 + 0.125 * math.random() - 0.0625)
				npc:PlaySound(SoundEffect.SOUND_CHAIN_BREAK, 1.5, 0, false, 1.3 + 0.1 * math.random() - 0.05)
				npcdata.PlayedDeathSounds = true
			end
		end
	end

	if sprite:IsPlaying("Death") then
		npc.Velocity = nilvector

		if npcdata.Chains ~= nil then
			for _, chains in ipairs(npcdata.Chains) do
				for _, chain in ipairs(chains) do
					chain:Remove()
				end
			end
			npcdata.Chains = nil
		end

		--[[if npc.Parent and (not npc.Parent:IsDead())
		   and not (mod:isStatusCorpse(npc.Parent) or mod:isLeavingStatusCorpse(npc.Parent) or mod:doNotShareHP(npc.Parent)) then
			npc.Parent:Kill()
		end
		npc.Parent = nil]]--

		--[[if npc.Child and (not npc.Child:IsDead())
		   and not (mod:isStatusCorpse(npc.Child) or mod:isLeavingStatusCorpse(npc.Child) or mod:doNotShareHP(npc.Child)) then
			npc.Child:Kill()
		end
		npc.Child = nil]]--

		return
	end

	--[[if math.random() < 0.01 then
		npc:PlaySound(SoundEffect.SOUND_METAL_DOOR_OPEN, 1, 0, false, 4.0 + 0.5 * math.random() - 0.25)
	end]]--

	for _, entity in ipairs(npcdata.ConnectedEntities) do
		if entity:Exists() then
			local data = entity:GetData()
			data.CuffsAdjustedThisFrame = nil
			data.CuffsStartingPosition = nil
			data.CuffsStartingVelocity = nil
		end
	end
end

function mod:isCuffsBlacklisted(entity)
	return mod.CuffsBlacklist[entity.Type] or
	       mod.CuffsBlacklist[entity.Type .. " " .. entity.Variant] or
	       mod.CuffsBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:fireplaceIsDead(entity)
	return entity.Type == EntityType.ENTITY_FIREPLACE and entity:ToNPC().State == NpcState.STATE_IDLE
end

function mod:getNearestCuffsTargets(position, numTargets)
	local targets = {}
	local targetDists = {}

	local entities = Isaac.GetRoomEntities()
	for _, entity in ipairs(entities) do
		local dist = position:Distance(entity.Position)
		if entity.Type < 10 or entity.Type >= 999 or (not entity:Exists()) or mod:isCuffsBlacklisted(entity) or mod:isFriend(entity) then
			--do nothing
		else
			for i = 1, numTargets do
				if not targets[i] or dist <= targetDists[i] then
					table.insert(targets, i, entity)
					table.insert(targetDists, i, dist)
					break
				end
			end
		end
	end

	while #targets > numTargets do
		table.remove(targets)
	end

	return targets
end

function mod:syncCuffsMaxHealth(targets)
	local targetsAnalyzing = {}
	local maxHitPoints = 0

	local targetsToBeAnalyzed = {}
	local targetsToBeAnalyzedKeys = {}
	for _,entity in ipairs(targets) do
		table.insert(targetsToBeAnalyzed, entity)
		targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] = true
	end

	while #targetsToBeAnalyzed > 0 do
		local targetToBeAnalyzed = table.remove(targetsToBeAnalyzed)
		local data = targetToBeAnalyzed:GetData()

		for _,cuffs in ipairs(data.ConnectedCuffs) do
			local cuffsData = cuffs:GetData()
			for _,entity in ipairs(cuffsData.ConnectedEntities) do
				if entity ~= nil and not targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] then
					table.insert(targetsToBeAnalyzed, entity)
					targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] = true
				end
			end
		end

		if not mod:doNotShareHP(targetToBeAnalyzed) then
			maxHitPoints = maxHitPoints + data.OriginalMaxHitPoints
		end
		table.insert(targetsAnalyzing, targetToBeAnalyzed)
	end

	for _,enemy in ipairs(targetsAnalyzing) do
		if not mod:doNotShareHP(enemy) then
			enemy.MaxHitPoints = maxHitPoints
			enemy.HitPoints = maxHitPoints
		end
		enemy:GetData().CuffsLastHealth = enemy.HitPoints
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity)
	if entity:ToNPC() then
		entity:GetData().CuffedTookDamageThisFrame = game:GetFrameCount()
	end
end)

function mod:cuffsTakeDmg(entity, damage, flags, source, countdown)
	return false
end

function mod:syncCuffsCurrentHealth(targets)
	local targetsAnalyzing = {}
	local diffHitPoints = 0

	local targetsToBeAnalyzed = {}
	local targetsToBeAnalyzedKeys = {}
	for _,entity in ipairs(targets) do
		table.insert(targetsToBeAnalyzed, entity)
		targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] = true
	end

	local sewnLastDamageDealt = 0
	local someoneTookDamage = false
	local lastDamageWasFly = false
	while #targetsToBeAnalyzed > 0 do
		local targetToBeAnalyzed = table.remove(targetsToBeAnalyzed)
		if targetToBeAnalyzed:Exists() then
			local data = targetToBeAnalyzed:GetData()

			for _,cuffs in ipairs(data.ConnectedCuffs) do
				if cuffs:Exists() then
					local cuffsData = cuffs:GetData()
					for _,entity in ipairs(cuffsData.ConnectedEntities) do
						if entity ~= nil and not targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] then
							table.insert(targetsToBeAnalyzed, entity)
							targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] = true
						end
					end
				end
			end

			data.CuffsDiffHealth = data.CuffsLastHealth - targetToBeAnalyzed.HitPoints
			if data.FFSewnLastDamageDealt then
				if sewnLastDamageDealt ~= 0 and sewnLastDamageDealt ~= data.FFSewnLastDamageDealt then
					print("ERROR: Sewn and cuffs damage not synced properly.")
				end
				
				data.CuffsDiffHealth = math.max(data.CuffsDiffHealth - data.FFSewnLastDamageDealt, 0)
				sewnLastDamageDealt = data.FFSewnLastDamageDealt
			end
			someoneTookDamage = someoneTookDamage or (data.CuffedTookDamageThisFrame and game:GetFrameCount() - data.CuffedTookDamageThisFrame <= 1)
			lastDamageWasFly = lastDamageWasFly or data.LastDamageWasFly
		end
		table.insert(targetsAnalyzing, targetToBeAnalyzed)
	end

	for _, enemy in ipairs(targetsAnalyzing) do
		if not mod:doNotShareHP(enemy) and enemy:Exists() then
			local data = enemy:GetData()
			for _, other in ipairs(targetsAnalyzing) do
				if other:Exists() and (other.InitSeed ~= enemy.InitSeed or other.Index ~= enemy.Index) and not mod:doNotShareHP(other) then
					if other.HitPoints ~= other.HitPoints - data.CuffsDiffHealth then
						if someoneTookDamage then
							mod:applyFakeDamageFlash(other)
						end
						mod:doomOnDamage(other, other:GetData(), nil)
						data.LastDamageWasFly = lastDamageWasFly
					end
					other.HitPoints = other.HitPoints - data.CuffsDiffHealth
				end
			end
			
			if data.FFSewnLastDamageDealt == nil then
				if enemy.HitPoints ~= enemy.HitPoints - sewnLastDamageDealt then
					if someoneTookDamage then
						mod:applyFakeDamageFlash(enemy)
					end
					mod:doomOnDamage(enemy, enemy:GetData(), nil)
					data.LastDamageWasFly = lastDamageWasFly
				end
				enemy.HitPoints = enemy.HitPoints - sewnLastDamageDealt
			end
		end
	end

	local timeToKill = false
	for _, enemy in ipairs(targetsAnalyzing) do
		if enemy:Exists() then
			local data = enemy:GetData()
			data.CuffsLastHealth = enemy.HitPoints

			if mod:doNotShareHP(enemy) then
				--do nothing
			elseif enemy.HitPoints <= 0.0 and enemy.MaxHitPoints ~= 0.0 then
				timeToKill = true
			elseif enemy:IsDead() then
				timeToKill = true
			elseif enemy.Type == mod.FF.Deathany.ID and enemy.Variant == mod.FF.Deathany.Var and data.state == "death" then
				timeToKill = true
			end
		else
			timeToKill = true
		end
	end

	if timeToKill then
		for _, enemy in ipairs(targetsAnalyzing) do
			if not enemy:Exists() then
				--do nothing
			elseif enemy.Type == mod.FF.Deathany.ID and enemy.Variant == mod.FF.Deathany.Var then
				enemy:GetData().state = "death"
			elseif (not mod:doNotShareHP(enemy)) and (not mod:isStatusCorpse(enemy)) and (not mod:isLeavingStatusCorpse(enemy)) then
				enemy:Kill()
			end
		end
	end
end

function mod:setCuffedMovement(npc)
	if not npc:Exists() then
		return
	end

	local npcdata = npc:GetData()
	if npcdata.CuffsAdjustedThisFrame then
		return
	end

	npcdata.CuffsStartingPosition = npcdata.CuffsStartingPosition or npc.Position
	npcdata.CuffsStartingVelocity = npcdata.CuffsStartingVelocity or npc.Velocity

	local npcMass = math.max(1, npc.Mass)
	local npcPosition = npcdata.CuffsStartingPosition
	local npcVelocity = npcdata.CuffsStartingVelocity

	local velocityDiff = nilvector
	local numDiffs = 0

	local connectedEntities = {}
	local connectedChainLength = {}
	for _, cuffs in ipairs(npcdata.ConnectedCuffs) do
		if cuffs:Exists() then
			local chainLength = math.max(40, cuffs.SubType & 2047)
			local cuffsData = cuffs:GetData()
			for _,entity in ipairs(cuffsData.ConnectedEntities) do
				if entity ~= nil and entity:Exists() and (entity.InitSeed ~= npc.InitSeed or entity.Index ~= npc.Index) then
					local key = entity.InitSeed .. " " .. entity.Index
					connectedEntities[key] = entity

					if not connectedChainLength[key] or chainLength < connectedChainLength[key] then
						connectedChainLength[key] = chainLength
					end
				end
			end
		end
	end

	for key, connected in pairs(connectedEntities) do
		local connectedData = connected:GetData()
		local connectedMass = math.max(1, connected.Mass)
		local connectedPosition = connectedData.CuffsStartingPosition or connected.Position
		local connectedVelocity = connectedData.CuffsStartingVelocity or connected.Velocity

		local chainLength = connectedChainLength[key]
		local dist = connectedPosition - npcPosition
		if dist:Length() > chainLength then
			local distToClose = dist - dist:Resized(chainLength)
			velocityDiff = velocityDiff + distToClose * (connectedMass / (connectedMass + npcMass))
			numDiffs = numDiffs + 1
		end
	end

	if numDiffs ~= 0 then
		npc.Position = npc.Position + velocityDiff / numDiffs
		npc.Velocity = npc.Velocity + velocityDiff / numDiffs
	end
	npcdata.CuffsAdjustedThisFrame = true
end

function mod:setCuffsMovement(npc)
	local npcPosition = npc.Position

	local velocityDiff = nilvector
	local numDiffs = 0

	local npcdata = npc:GetData()
	for _, connected in ipairs(npcdata.ConnectedEntities) do
		if (not connected) or (not connected:Exists()) or connected:IsDead() or mod:isStatusCorpse(connected) then
			return
		end

		local connectedPosition = connected.Position

		local chainLength = math.max(20, (npc.SubType & 2047) / 2)
		local dist = connectedPosition - npcPosition
		if dist:Length() > chainLength then
			local distToClose = dist - dist:Resized(chainLength)
			velocityDiff = velocityDiff + distToClose
			numDiffs = numDiffs + 1
		end
	end

	if numDiffs ~= 0 then
		npc.Position = npc.Position + velocityDiff / numDiffs
		npc.Velocity = npc.Velocity + velocityDiff / numDiffs
	end
end

function mod:setCuffsChainsMovement(npc)
	local npcdata = npc:GetData()
	if npcdata.Chains == nil then
		return
	end

	local numChainsPerLink = math.max(1, math.ceil((npc.SubType & 2047) / 40))
	local maxChainLength = math.max(20, (npc.SubType & 2047) / 2)

	for _,entity in ipairs(npcdata.ConnectedEntities) do
		if (not entity) or (not entity:Exists()) or entity:IsDead() or mod:isStatusCorpse(entity) then
			return
		end
	end

	for j, entity in ipairs(npcdata.ConnectedEntities) do
		local chainLength = (npc.Position - entity.Position):Length()
		for i, chain in ipairs(npcdata.Chains[j]) do
			local targetPosition = (entity.Position - npc.Position):Resized(chainLength / (numChainsPerLink + 1) * i) + npc.Position
			chain.Velocity = targetPosition - chain.Position
			local saggingIndex = math.sin(math.pi * (i - 0.5) / numChainsPerLink)
			local saggingAmount = 7.5 * (1 - math.min(1, (chainLength ^ 2) / (maxChainLength ^ 2))) * saggingIndex
			chain.SpriteOffset = Vector(0, -10 + saggingAmount)
		end
	end
end

function mod:setCuffsDesignatedMainSegment(npc)
	local targetsAnalyzing = {}

	local targetsToBeAnalyzed = {}
	local targetsToBeAnalyzedKeys = {}
	
	table.insert(targetsToBeAnalyzed, npc)
	targetsToBeAnalyzedKeys[npc.InitSeed .. " " .. npc.Index] = true

	while #targetsToBeAnalyzed > 0 do
		local targetToBeAnalyzed = table.remove(targetsToBeAnalyzed)
		if targetToBeAnalyzed:Exists() then
			local data = targetToBeAnalyzed:GetData()

			for _,cuffs in ipairs(data.ConnectedCuffs) do
				if cuffs:Exists() then
					local cuffsData = cuffs:GetData()
					for _,entity in ipairs(cuffsData.ConnectedEntities) do
						if entity ~= nil and not targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] then
							table.insert(targetsToBeAnalyzed, entity)
							targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] = true
						end
					end
				end
			end
		end
		table.insert(targetsAnalyzing, targetToBeAnalyzed)
	end

	local mainSegmentSet = false
	for _, enemy in ipairs(targetsAnalyzing) do
		local data = enemy:GetData()
		
		if not mainSegmentSet and not mod:doNotShareHP(enemy) and enemy:Exists() then
			data.CuffsDesignatedMainSegment = true
			mainSegmentSet = true
		else
			data.CuffsDesignatedMainSegment = false
		end
	end
end

-- Here so enemy health is already set so I don't have to try and do takedmg/uranus wizardry
function mod:cuffsHealthAndMovement()
	local cuffs = Isaac.FindByType(mod.FF.Cuffs.ID, mod.FF.Cuffs.Var)
	for _, npc in ipairs(cuffs) do
		local npcdata = npc:GetData()
		if npcdata.ConnectedEntities then
			mod:syncCuffsCurrentHealth(npcdata.ConnectedEntities)

			for _, entity in ipairs(npcdata.ConnectedEntities) do
				mod:setCuffedMovement(entity)
				
				if entity:GetData().CuffsDesignatedMainSegment == nil then
					mod:setCuffsDesignatedMainSegment(entity)
				end
			end
		end

		npc.Position = npc.Position - npc.Velocity
		npc.Velocity = npc.Velocity * 0.90
		npc.Position = npc.Position + npc.Velocity

		mod:setCuffsMovement(npc)
		mod:setCuffsChainsMovement(npc)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.cuffsHealthAndMovement)

-- >:(
function mod:cuffsDeathFailsafe(entity)
	local targetsAnalyzing = {}

	local targetsToBeAnalyzed = {entity}
	local targetsToBeAnalyzedKeys = {}
	targetsToBeAnalyzedKeys[entity.InitSeed .. " " .. entity.Index] = true

	while #targetsToBeAnalyzed > 0 do
		local targetToBeAnalyzed = table.remove(targetsToBeAnalyzed)
		local data = targetToBeAnalyzed:GetData()

		for _,cuffs in ipairs(data.ConnectedCuffs) do
			local parent = cuffs.Parent
			local child = cuffs.Child

			if parent and not targetsToBeAnalyzedKeys[parent.InitSeed .. " " .. parent.Index] then
				table.insert(targetsToBeAnalyzed, parent)
				targetsToBeAnalyzedKeys[parent.InitSeed .. " " .. parent.Index] = true
			end

			if child and not targetsToBeAnalyzedKeys[child.InitSeed .. " " .. child.Index] then
				table.insert(targetsToBeAnalyzed, child)
				targetsToBeAnalyzedKeys[child.InitSeed .. " " .. child.Index] = true
			end
		end

		table.insert(targetsAnalyzing, targetToBeAnalyzed)
	end

	for _, enemy in ipairs(targetsAnalyzing) do
		if enemy.Type == mod.FF.Deathany.ID and enemy.Variant == mod.FF.Deathany.Var then
			enemy:GetData().state = "death"
		elseif (not mod:doNotShareHP(enemy)) and (not mod:isStatusCorpse(enemy)) and (not mod:isLeavingStatusCorpse(enemy)) then
			enemy:Kill()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
	local data = entity:GetData()
	if data.IsCuffed and mod:isLeavingStatusCorpse(entity) then
		mod:cuffsDeathFailsafe(entity)
	end
end)

-- ace cards whyyyyyyyy
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if not effect:GetData().Cuffs or not effect:GetData().Cuffs:Exists() then
		effect:Remove()
	end
end, 1746)
