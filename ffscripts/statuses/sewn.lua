-- Sewn --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

function mod:doNotShareHP(entity)
	return FiendFolio.HPSharingBlacklist[entity.Type] or
	       FiendFolio.HPSharingBlacklist[entity.Type .. " " .. entity.Variant] or
	       FiendFolio.HPSharingBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity)
	if entity:ToNPC() then
		entity:GetData().FFSewnTookDamageThisFrame = game:GetFrameCount()
	end
end)

function mod:handleSewnCurrentHealth(npcs)
	local totalDamageToSpread = 0.0

	local someoneTookDamage = false
	local lastDamageWasFly = false
	for _,npc in ipairs(npcs) do
		local data = npc:GetData()
		data.FFSewnLastDamageDealt = nil

		if data.FFSewnDuration ~= nil and mod:checkIfStatusLogicIsApplied(npc) and (not data.IsCuffed or data.CuffsDesignatedMainSegment) then
			totalDamageToSpread = totalDamageToSpread + math.max(0, (data.FFSewnLastHP or npc.HitPoints) - npc.HitPoints)
			someoneTookDamage = someoneTookDamage or (data.FFSewnTookDamageThisFrame and game:GetFrameCount() - data.FFSewnTookDamageThisFrame <= 1)
			lastDamageWasFly = lastDamageWasFly or data.LastDamageWasFly
		end
	end

	if totalDamageToSpread > 0.0 then
		for _,npc in ipairs(npcs) do
			local data = npc:GetData()

			if data.FFSewnDuration ~= nil then
				if someoneTookDamage then
					mod:applyFakeDamageFlash(npc)
				end
				
				if (not mod:isBasegameSegmented(npc) or mod:isBasegameMainSegment(npc) or mod:isBasegameReducedSyncSegment(npc)) then
					local sewnDamage = totalDamageToSpread - math.max(0, (data.FFSewnLastHP or npc.HitPoints) - npc.HitPoints)
					npc.HitPoints = npc.HitPoints - sewnDamage
					data.FFSewnLastDamageDealt = sewnDamage
					
					if sewnDamage > 0.0 then 
						mod:doomOnDamage(npc, data, nil) 
						data.LastDamageWasFly = lastDamageWasFly
					end
					
					if npc.HitPoints <= 0.0 and npc.MaxHitPoints ~= 0.0 and (not mod:isStatusCorpse(npc)) and (not mod:isLeavingStatusCorpse(npc)) and not (npc.Type == EntityType.ENTITY_VISAGE and npc.Variant == 1) and not (data.FFBerserkDuration ~= nil and data.FFBerserkDuration >= 0) then
						if npc:IsBoss() then
							if not data.FFStatusSentKillingBlow then
								local source = Isaac.GetPlayer(0)
								if data.FFSewnSource and data.FFSewnSource:Exists() then
									source = data.FFSewnSource
								end
								
								npc:TakeDamage(0.0001, 0, EntityRef(source), 0)
							end
							data.FFStatusSentKillingBlow = true
						else
							npc:Kill()
						end
						data.FFSewnDuration = nil
					end
				end
			end
		end
	end

	for _,npc in ipairs(npcs) do
		local data = npc:GetData()
		data.FFSewnLastHP = npc.HitPoints
	end
end

function mod:handleSewnRopes(npcs)
	local ropes = Isaac.FindByType(EntityType.ENTITY_EVIS, 10, 22, false, false)
	for _,rope in ipairs(ropes) do
		local ropeData = rope:GetData()
		local removing = false

		if (not rope.Parent) or rope.Parent:IsDead() or mod:isStatusCorpse(rope.Parent) or rope.Parent:GetData().FFSewnDuration == nil then
			removing = true
		end

		if (not rope.Child) or rope.Child:IsDead() or mod:isStatusCorpse(rope.Child) or rope.Child:GetData().FFSewnDuration == nil then
			removing = true
		end

		if removing then
			if rope.Parent then
				rope.Parent:GetData().FFSewnRopeParent = nil
			end

			if rope.Child then
				rope.Child:GetData().FFSewnRopeChild = nil
			end

			if rope.Target then
				rope.Target:Remove()
			end

			rope:Remove()
		end
	end

	for i = 1, #npcs do
		local npc = npcs[i]
		local npcData = npc:GetData()

		if npcData.FFSewnDuration ~= nil and not npcData.FFSewnRopeParent and not (npc:IsDead() or mod:isStatusCorpse(npc)) and mod:checkIfStatusLogicIsApplied(npc) then
			for j = 1, #npcs do
				local otherNpc = npcs[j]
				local otherNpcData = otherNpc:GetData()

				if i ~= j and otherNpcData.FFSewnDuration ~= nil and not otherNpcData.FFSewnRopeChild and not (otherNpc:IsDead() or mod:isStatusCorpse(otherNpc)) and mod:checkIfStatusLogicIsApplied(otherNpc) then
					local npcChildRope = npcData.FFSewnRopeChild
					local otherNpcParentRope = otherNpcData.FFSewnRopeParent

					local alreadyConnected = false

					local nextChildRope = npcChildRope
					while nextChildRope ~= nil do
						if otherNpcParentRope and nextChildRope.Index == otherNpcParentRope.Index then
							alreadyConnected = true
							break
						end
						nextChildRope = nextChildRope.Parent:GetData().FFSewnRopeChild
					end

					local nextParentRope = otherNpcParentRope
					while nextParentRope ~= nil do
						if alreadyConnected then
							break
						end
						if npcChildRope and nextParentRope.Index == npcChildRope.Index then
							alreadyConnected = true
							break
						end
						nextParentRope = nextParentRope.Child:GetData().FFSewnRopeParent
					end

					if not alreadyConnected then
						local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 22, otherNpc.Position, nilvector, nil)
						local ropeData = rope:GetData()
						rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

						rope.Parent = npc
						npcData.FFSewnRopeParent = rope

						local handler = Isaac.Spawn(1000, 1749, 0, npc.Position + (otherNpc.Position - npc.Position):Normalized(), nilvector, nil)
						handler:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
						handler:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						handler.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						handler.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
						handler.CollisionDamage = 0
						handler.Visible = false
						handler:GetData().Rope = rope

						rope.Target = handler
						rope.Position = handler.Position

						rope.Child = otherNpc
						otherNpcData.FFSewnRopeChild = rope

						ropeData.FadeInDuration = 10
						ropeData.FadeInDurationMax = 10

						rope:GetSprite():SetFrame(100)
						rope:Update()

						break
					end
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == 0 and (effect:GetData().Rope == nil or not effect:GetData().Rope:Exists()) then
		effect:Remove()
	end
end, 1749)

function mod:sewingRopeRender(npc)
	if npc.Variant == 10 and npc.SubType == 22 then
		local data = npc:GetData()
		if not npc.Parent or not npc.Child or not npc.Target then
			-- do nothing
		elseif npc:Exists() then
			if data.FrameCount or npc.FrameCount ~= data.FrameCount then
				data.FrameCount = npc.FrameCount
				data.FadeInDuration = math.max(0, data.FadeInDuration - 1)
			end

			--npc:GetSprite():Play("FadeIn" .. data.FadeInDuration, true)
			npc:GetSprite():Play("FadeIn0", true)
			local location = npc.Child.Position - (npc.Child.Position - npc.Parent.Position) * ((data.FadeInDuration * 2) / (data.FadeInDurationMax * 2))
			npc.Target.Velocity = location - npc.Target.Position
			npc.Target.Visible = false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.sewingRopeRender, EntityType.ENTITY_EVIS)

function mod:sewingRopeUpdate(npc)
	if npc.Variant == 10 and npc.SubType == 22 then
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.sewingRopeUpdate, EntityType.ENTITY_EVIS)

function mod:handleSewn(entity, data, sprite)
	data.FFSewnDuration = data.FFSewnDuration - 1

	if data.FFSewnDuration >= 0 then
		entity:SetColor(FiendFolio.StatusEffectColors.Sewn, 1, statusColorPriority, false, false)
	end
end

function FiendFolio.AddSewn(entity, source, duration, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddSewn(segment, source, duration, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddSewn(segment, source, duration, true)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and (mod:hasCustomStatus(entity) or data.FFBossStatusResistance) then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity) or data.FFIsDeathAnimation or mod:doNotShareHP(entity) or data.eternalFlickerspirited) then
		data.FFSewnDuration = math.max(data.FFSewnDuration or 0, duration)
		data.FFSewnSource = source
		data.FFSewnLastHP = entity.HitPoints
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveSewn(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveSewn(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveSewn(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFSewnDuration = nil
end

function mod:sewnOnApply(entity, source, data)
	if data.ApplySewn then
		FiendFolio.AddSewn(entity, source.Entity.SpawnerEntity, data.ApplySewnDuration)
	end
end

function mod:sewnOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFSewnDuration ~= nil and data.FFSewnDuration > 0 and not clearingStatus then
		mod:handleSewn(npc, data, sprite)
		data.hasFFStatusIcon = true
	else
		data.FFSewnDuration = nil
	end
end

function mod:copySewn(copy, copyData, sourceData)
	if not (copyData.FFIsDeathAnimation or mod:doNotShareHP(copy) or copyData.eternalFlickerspirited) then
		copyData.FFSewnDuration = sourceData.FFSewnDuration
		copyData.FFSewnSource = sourceData.FFSewnSource
		copyData.FFSewnLastHP = copy.HitPoints
	end
end
