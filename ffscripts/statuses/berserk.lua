-- Berserk --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
	if proj.FrameCount <= 1 and proj.SpawnerEntity ~= nil then
		local spawnerData = proj.SpawnerEntity:GetData()
		if spawnerData.FFBerserkDuration ~= nil and spawnerData.FFBerserkDuration >= 0 then
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
			proj:GetData().FFBerserkProjectile = true
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, function(_, proj, entity, mysteryBoolean)
	local data = proj:GetData()
	local spawnerEntity = proj.SpawnerEntity

	if data.FFBerserkProjectile and spawnerEntity then
		if spawnerEntity.Index == entity.Index and spawnerEntity.InitSeed == entity.InitSeed then
			return true
		elseif mod:isSegmented(spawnerEntity) and mod:isInSegmentsOf(entity, spawnerEntity) then
			return true
		elseif mod:isBasegameSegmented(spawnerEntity) and mod:isInBasegameSegmentsOf(entity, spawnerEntity) then
			return true
		end
	end

end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, entity, mysteryBoolean)
	if mod:isBerserk(npc) and entity:ToNPC() then
		if mod:isSegmented(npc) and mod:isInSegmentsOf(entity, npc) then
			return true
		elseif mod:isBasegameSegmented(npc) and mod:isInBasegameSegmentsOf(entity, npc) then
			return true
		elseif mod:isCharm(npc) or mod:isCharm(entity) or mod:isBaited(entity) then
			-- do nothing
		elseif npc.Target and npc.Target.Index == entity.Index and npc.Target.InitSeed == entity.InitSeed then
			-- do nothing
		else
			entity:TakeDamage((math.log((npc.MaxHitPoints / 100) + 1.1) / math.log(10)) * 75.9853, 0, EntityRef(npc), 0) -- Matches npc.Target damage
		end
	end
end)

local onlyDeadBerserkRemaining = nil
function mod:checkIfOnlyDeadBerserkRemaining()
	if onlyDeadBerserkRemaining ~= nil then
		return onlyDeadBerserkRemaining
	end
	
	local room = game:GetRoom()

	--Cancel out if buttons aren't pressed
	if room:HasTriggerPressurePlates() then
		local size = room:GetGridSize()
		for i=0, size do
			local gridEntity = room:GetGridEntity(i)
			if gridEntity then
				local desc = gridEntity.Desc.Type
				if gridEntity.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
					if gridEntity:GetVariant() == 0 then
						if gridEntity.State ~= 3 then
							onlyDeadBerserkRemaining = false
							return false
						end
					end
				end
			end
		end
	end

	--real check real
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() and entity:CanShutDoors() then
			if not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				if not mod.waitingEnemiesTriggered then
					for k = 1, #mod.ComeOutTables do
						for i = 1, #mod.ComeOutTables[k] do
							if mod.ComeOutTables[k][i][3] then
								if entity.Type == mod.ComeOutTables[k][i][1] and entity.Variant == mod.ComeOutTables[k][i][2] and entity.SubType == mod.ComeOutTables[k][i][3] then
									goto berserkcontinue
								end
							elseif mod.ComeOutTables[k][i][2] then
								if entity.Type == mod.ComeOutTables[k][i][1] and entity.Variant == mod.ComeOutTables[k][i][2] then
									goto berserkcontinue
								end
							else
								if entity.Type == mod.ComeOutTables[k][i][1] then
									goto berserkcontinue
								end
							end
						end
					end
				end

				if entity:ToNPC():GetChampionColorIdx() == 6 then
					goto berserkcontinue
				end
				if entity:GetData().eternalFlickerspirited then
					goto berserkcontinue
				end
				if entity.Type == mod.FF.Centipede.ID and entity.Variant == mod.FF.Centipede.Var then
					if entity.SubType > 0 and entity.SubType < 100 then
						goto berserkcontinue
					end
				end
				--[[if REVEL.ENT.PENANCE_ORB then
					if entity.Type == REVEL.ENT.PENANCE_ORB.Type and entity.Variant == REVEL.ENT.PENANCE_ORB.Variant then
						badent = true
					end
				end
				if REVEL.ENT.PENANCE_SIN then
					if entity.Type == REVEL.ENT.PENANCE_SIN.Type and entity.Variant == REVEL.ENT.PENANCE_SIN.Variant then
						badent = true
					end
				end]]
				if mod:isBerserk(entity) and entity.HitPoints <= 0 and entity.MaxHitPoints ~= 0 then
					goto berserkcontinue
				end

				onlyDeadBerserkRemaining = false
				return false
			end
		end

		::berserkcontinue::
	end


	onlyDeadBerserkRemaining = true
	return true
end

function mod:resetOnlyDeadBerserkRemaining()
	onlyDeadBerserkRemaining = nil
end

function mod:handleBerserk(entity, data, sprite)
	data.FFBerserkDuration = data.FFBerserkDuration - 1

	if data.FFBerserkPlayedIntro == nil then
		sfx:Play(SoundEffect.SOUND_BERSERK_START, 0.5, 0, false, 1.0)
		data.FFBerserkPlayedIntro = true
	end

	if data.FFBerserkDuration >= 0 then
		data.FFBerserkCurrentTicks = data.FFBerserkCurrentTicks or 0
		local color = Color.Lerp(FiendFolio.StatusEffectColors.Berserk, FiendFolio.StatusEffectColors.BerserkFlash, math.abs(math.sin(math.pi / 4 * data.FFBerserkCurrentTicks)))
		entity:SetColor(color, 1, statusColorPriority, false, false)
		data.FFBerserkCurrentTicks = data.FFBerserkCurrentTicks + 1
	end

	if entity.Target or (data.FFBerserkPreviousTarget and data.FFBerserkPreviousTarget:Exists() and not data.FFBerserkPreviousTarget:ToNPC()) then
		local target = entity.Target or data.FFBerserkPreviousTarget
		data.FFBerserkTicksWithCurrentTarget = (data.FFBerserkTicksWithCurrentTarget or 0) + 1
		if data.FFBerserkTicksWithCurrentTarget > FiendFolio.StatusEffectVariables.BerserkTargetTime or mod:isStatusCorpse(target) or
		   (mod:isBerserk(target) and target.HitPoints <= 0 and target.MaxHitPoints ~= 0) then
			data.FFBerserkIgnoredTarget = target
			data.FFBerserkPreviousTarget = nil
			entity.Target = nil
		end
	else
		data.FFBerserkTicksWithCurrentTarget = nil
	end
	
	if entity:IsBoss() and (entity.HitPoints <= 0 and entity.MaxHitPoints ~= 0) then
		data.FFBerserkBossTimeout = (data.FFBerserkBossTimeout or 0) + 1
	end
	
	if not sfx:IsPlaying(mod.Sounds.CustomBerserkTick) and (data.FFBerserkBossTimeout == 1 or data.FFBerserkDuration == 60) then
		sfx:Play(mod.Sounds.CustomBerserkTick, 0.5, 0, false, 1.0)
	end

	if data.FFBerserkDuration == 0 or (entity.HitPoints <= 0 and entity.MaxHitPoints ~= 0 and (mod:checkIfOnlyDeadBerserkRemaining() or (data.FFBerserkBossTimeout or 0) >= FiendFolio.StatusEffectVariables.BerserkBossTimeout)) then
		entity.Target = nil
		data.FFBerserkDuration = nil
		data.FFBerserkPlayedIntro = nil
		data.FFBerserkCurrentTicks = nil
		data.FFBerserkPreviousTarget = nil
		data.FFBerserkIgnoredTarget = nil
		data.FFBerserkBossTimeout = nil

		sfx:Play(SoundEffect.SOUND_BERSERK_END, 0.5, 0, false, 1.0)
		--[[if not sfx:IsPlaying(SoundEffect.SOUND_BERSERK_TICK) then
			sfx:Play(SoundEffect.SOUND_BERSERK_TICK, 0.7, 0, false, 1.0)
		end]]--

		if entity.HitPoints <= 0.0 and entity.MaxHitPoints ~= 0.0 and not mod:isStatusCorpse(entity) then
			local addedExtraGoreFlag = false
			if not entity:HasEntityFlags(EntityFlag.FLAG_EXTRA_GORE) then
				entity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
				addedExtraGoreFlag = true
			end

			data.FFBerserkKilled = true
			if entity:IsBoss() then
				if not data.FFStatusSentKillingBlow then
					entity:TakeDamage(0.0001, 0, EntityRef(data.FFSewnSource), 0)
				end
				data.FFStatusSentKillingBlow = true
				data.FFBerserkKickOutLilMinx = true
			else
				entity:Kill()
			end

			if addedExtraGoreFlag then
				entity:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
			end

			for i = 1, 11 - math.random(5) do
				local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, entity.Position, Vector.FromAngle(math.random() * 360) * math.random() * 10, nil):ToEffect()
				smoke.Color = Color(158/255, 11/255, 15/255, 67/255, 0, 0, 0)
				smoke:SetTimeout(10 + math.random(15))
				smoke:Update()
			end
		end
	end
end

function mod:isBerserkBlacklisted(entity)
	return mod.BerserkBlacklist[entity.Type] or
	       mod.BerserkBlacklist[entity.Type .. " " .. entity.Variant] or
	       mod.BerserkBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function FiendFolio.AddBerserk(entity, source, duration, isCloned, isMinx)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddBerserk(segment, source, duration, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddBerserk(segment, source, duration, true)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and (mod:hasCustomStatus(entity) or data.FFBossStatusResistance) and not isMinx then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity) or mod:isBerserkBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFBerserkDuration = math.max(duration, data.FFBerserkDuration or 0)
		data.FFBerserkSource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
		
		if isMinx and entity:ToNPC():IsBoss() then
			FiendFolio.RemoveAtrophy(entity)
			FiendFolio.RemoveBlind(entity)
			FiendFolio.RemoveBloated(entity)
			FiendFolio.RemoveBruise(entity, true)
			FiendFolio.RemoveDoom(entity, true)
			FiendFolio.RemoveBleed(entity, true)
			FiendFolio.RemoveSewn(entity, true)
			FiendFolio.RemoveSweaty(entity, true)
			
			data.FFDrowsyDuration = nil
			data.FFSleepDuration = nil
		end
	end
end

function FiendFolio.RemoveBerserk(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveBerserk(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveBerserk(segment, true)
			end
		end
	end

	local data = entity:GetData()

	if data.FFBerserkDuration ~= nil then
		entity.Target = nil
		entity:GetSprite().PlaybackSpeed = 1.0
		sfx:Play(SoundEffect.SOUND_BERSERK_END, 0.5, 0, false, 1.0)

		if entity.HitPoints <= 0.0 and entity.MaxHitPoints ~= 0.0 and not mod:isStatusCorpse(entity) then
			local addedExtraGoreFlag = false
			if not entity:HasEntityFlags(EntityFlag.FLAG_EXTRA_GORE) then
				entity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
				addedExtraGoreFlag = true
			end

			entity:Kill()

			if addedExtraGoreFlag then
				entity:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
			end

			for i = 1, 11 - math.random(5) do
				local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, entity.Position, Vector.FromAngle(math.random() * 360) * math.random() * 10, nil):ToEffect()
				smoke.Color = Color(158/255, 11/255, 15/255, 67/255, 0, 0, 0)
				smoke:SetTimeout(10 + math.random(15))
				smoke:Update()
			end
		end
	end

	data.FFBerserkDuration = nil
	data.FFBerserkPlayedIntro = nil
	data.FFBerserkCurrentTicks = nil
	data.FFBerserkPreviousTarget = nil
	data.FFBerserkIgnoredTarget = nil
	data.FFBerserkBossTimeout = nil
end

function mod:isBerserk(entity)
	local data = entity:GetData()
	return data.FFBerserkDuration ~= nil and data.FFBerserkDuration >= 0
end

function mod:berserkOnDamage(data, newDamage, allowDamageEffects)
	local returndata = {}
	if data.FFBerserkDuration ~= nil and data.FFBerserkDuration > 0 and allowDamageEffects then
		returndata.newDamage = newDamage * FiendFolio.StatusEffectVariables.BerserkDamageReceivedMultiplier
		returndata.sendNewDamage = true
		returndata.hasProccedBerserk = true
	end
	return returndata
end

function mod:berserkOnCheckKill(data, newFlags)
	local returndata = {}
	if data.FFBerserkDuration ~= nil and data.FFBerserkDuration > 0 then
		returndata.newFlags = newFlags | DamageFlag.DAMAGE_NOKILL
		returndata.sendNewDamage = true
	end
	return returndata
end

function mod:damagedByBerserk(ent, damage, flags, source, countdown, data)
	if source ~= nil and source.Entity ~= nil and data.FFBerserkIgnoreDamageCallback ~= true and flags & DamageFlag.DAMAGE_CLONES == 0 then
		local sourceData = source.Entity:GetData()
		if (sourceData.FFBerserkDuration ~= nil and sourceData.FFBerserkDuration > 0) or sourceData.FFBerserkProjectile then
			data.FFBerserkIgnoreDamageCallback = true
			if ent.Type == EntityType.ENTITY_PLAYER then
				ent:TakeDamage(damage + FiendFolio.StatusEffectVariables.BerserkDamageAgainstPlayer, flags, source, countdown)
			else
				ent:TakeDamage(damage * FiendFolio.StatusEffectVariables.BerserkDamageGivenMultiplier, flags, source, countdown)
			end
			data.FFBerserkIgnoreDamageCallback = false
			return false
		end
	end
end

function mod:berserkOnApply(entity, source, data)
	if data.ApplyBerserk then
		FiendFolio.AddBerserk(entity, source.Entity.SpawnerEntity, data.ApplyBerserkDuration)
	end
end

function mod:berserkOnUpdate(npc, data, sprite, clearingStatus)
	data.FFBerserkKilled = nil
	if data.FFBerserkDuration ~= nil and data.FFBerserkDuration > 0 and not clearingStatus then
		mod:handleBerserk(npc, data, sprite)
		data.hasFFStatusIcon = data.FFBerserkDuration ~= nil
	else
		data.FFBerserkDuration = nil
		data.FFBerserkCurrentTicks = nil
		data.FFBerserkPlayedIntro = nil
		data.FFBerserkPreviousTarget = nil
		data.FFBerserkIgnoredTarget = nil
		data.FFBerserkKickOutLilMinx = nil
		data.FFBerserkBossTimeout = nil
	end
end

function mod:copyBerserk(copyData, sourceData)
	copyData.FFBerserkDuration = sourceData.FFBerserkDuration
	copyData.FFBerserkSource = sourceData.FFBerserkSource
	copyData.FFBerserkPlayedIntro = sourceData.FFBerserkPlayedIntro
	copyData.FFBerserkCurrentTicks = sourceData.FFBerserkCurrentTicks
	copyData.FFBerserkPreviousTarget = sourceData.FFBerserkPreviousTarget
	copyData.FFBerserkIgnoredTarget = sourceData.FFBerserkIgnoredTarget
	copyData.FFBerserkBossTimeout = sourceData.FFBerserkBossTimeout
end
