-- Doom --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

function mod:handleDoom(entity, data, sprite)
	data.FFDoomDuration = data.FFDoomDuration - 1

	if data.FFDoomDuration >= 0 then
		--entity:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		local color = Color.Lerp(sprite.Color, FiendFolio.StatusEffectColors.Doom, math.min(1.0, data.FFDoomDuration / 60))
		entity:SetColor(color, 1, statusColorPriority, false, false)

		if not data.FFDoomSource or not data.FFDoomSource:Exists() then
			data.FFDoomSource = Isaac.GetPlayer(0)
		end
		
		if data.FFDoomCountdown <= 0 then
			data.FFDoomTriggerCountdown = (data.FFDoomTriggerCountdown or 10) - 1
			data.FFDoomDuration = data.FFDoomDuration + 1
			
			if data.FFDoomTriggerCountdown <= 0 then
				data.FFDoomDuration = 0
				
				if mod:checkIfStatusLogicIsApplied(entity, true) then
					data.FFTakingDoomDamage = true
					entity:TakeDamage(data.FFDoomDamage, 0, EntityRef(data.FFDoomSource), 0)
					data.FFTakingDoomDamage = nil
					
					sfx:Play(mod.Sounds.DoomProc, 0.6, 0, false, math.random(85,115)/100)
					sfx:Play(mod.Sounds.ChainSnap, 1.6, 0, false, 1.0)
					--sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1.2, 0, false, 1.2)
					sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.9, 0, false, 1.0)
					--sfx:Play(SoundEffect.SOUND_DEMON_HIT, 0.7, 0, false, math.random(90,110)/100)
					
					local poofA = Isaac.Spawn(1000, 16, 1, entity.Position, nilvector, nil)
					poofA:GetSprite().Color = Color(0.2, 0.2, 0.2, 0.6, 0/255, 0/255, 0/255)
					
					local poofB = Isaac.Spawn(1000, 16, 2, entity.Position, nilvector, nil)
					poofB:GetSprite().Color = Color(0.2, 0.2, 0.2, 0.6, 0/255, 0/255, 0/255)
					
					local poofC = Isaac.Spawn(1000, 15, 0, entity.Position, nilvector, nil)
					poofC:GetSprite().Color = Color(0.2, 0.2, 0.2, 0.6, 0/255, 0/255, 0/255)
					--local c = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
					--c:SetColorize(1.0, 1.0, 1.0, 1.0)
					--poofC:GetSprite().Color = c
					--poofC:GetSprite():Load("gfx/1000.144_enemy ghost.anm2", true)
					--poofC:GetSprite():Play("Explosion", true)
					--poofC:GetData().FFDoomExplosion = true
					
					game:ShakeScreen(8)
				end
			end
		end
	end
end

--mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, doomExpl)
--	if doomExpl.FrameCount == 4 and doomExpl:GetData().FFDoomExplosion then
--		local poof = Isaac.Spawn(1000, 15, 0, doomExpl.Position, nilvector, nil)
--		local c = Color(0.2, 0.2, 0.2, 1.0, 0/255, 0/255, 0/255)
--		c:SetColorize(1.0, 1.0, 1.0, 1.0)
--		poof:GetSprite().Color = c
--		poof:GetSprite():Load("gfx/1000.034_Fart.anm2", true)
--		poof:GetSprite():Play("Explode", true)
--	end
--end)

local lastFramePiano3Happened = nil
local lastFramePiano2Happened = nil
local lastFramePiano1Happened = nil

function FiendFolio.AddDoom(entity, source, duration, countdown, damage, isCloned, muteSounds)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddDoom(segment, source, duration, countdown, damage, true, muteSounds)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddDoom(segment, source, duration, countdown, damage, true, muteSounds)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and (mod:hasCustomStatus(entity) or data.FFBossStatusResistance) then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		if data.FFDoomCountdown == nil or countdown < data.FFDoomCountdown then
			data.FFDoomCountdown = countdown
			data.FFDoomDamage = damage
			data.FFDoomSource = source
			data.FFDoomTriggerCountdown = nil
			data.FFDoomForceIconReaction = nil
			data.FFDoomPitch = math.random(75,125)/100
		end
			
		data.FFDoomDuration = math.max(data.FFDoomDuration or 0, duration)
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
		
		if not muteSounds then
			if data.FFDoomCountdown == 3 and (lastFramePiano3Happened == nil or lastFramePiano3Happened ~= Isaac.GetFrameCount()) then
				sfx:Play(mod.Sounds.Piano3, 0.7, 0, false, data.FFDoomPitch)
				lastFramePiano3Happened = Isaac.GetFrameCount()
			elseif data.FFDoomCountdown == 2 and (lastFramePiano2Happened == nil or lastFramePiano2Happened ~= Isaac.GetFrameCount()) then
				sfx:Play(mod.Sounds.Piano2, 0.7, 0, false, data.FFDoomPitch)
				lastFramePiano2Happened = Isaac.GetFrameCount()
			elseif data.FFDoomCountdown == 1 and (lastFramePiano1Happened == nil or lastFramePiano1Happened ~= Isaac.GetFrameCount()) then
				sfx:Play(mod.Sounds.Piano1, 0.7, 0, false, data.FFDoomPitch)
				lastFramePiano1Happened = Isaac.GetFrameCount()
			end
		end
	end
end

function FiendFolio.RemoveDoom(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveDoom(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveDoom(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFDoomDuration = nil
	data.FFDoomCountdown = nil
	data.FFDoomDamage = nil
	data.FFDoomSource = nil
	data.FFDoomTriggerCountdown = nil
	data.FFDoomForceIconReaction = nil
end

function FiendFolio.IncrementDoom(entity, value)
	local data = entity:GetData()
	if data.FFDoomDuration ~= nil and data.FFDoomDuration > 0 then
		data.FFDoomCountdown = math.max(data.FFDoomCountdown + value, 0)
		--if data.FFDoomCountdown <= 0 then
		--	data.FFDoomDuration = 0
		--	ent:TakeDamage(data.FFDoomDamage, 0, EntityRef(data.FFDoomSource), 1)
		--end
	end
end

function FiendFolio.DecrementDoom(entity, value)
	local data = entity:GetData()
	if data.FFDoomDuration ~= nil and data.FFDoomDuration > 0 then
		data.FFDoomCountdown = math.max(data.FFDoomCountdown - value, 0)
		--if data.FFDoomCountdown <= 0 then
		--	data.FFDoomDuration = 0
		--	ent:TakeDamage(data.FFDoomDamage, 0, EntityRef(data.FFDoomSource), 1)
		--end
	end
end

function mod:doomOnApply(entity, source, data)
	if data.ApplyDoom then
		if data.IsToyPiano then
			mod:toyPianoOnApply(entity, source, data)
		elseif data.IsPrankCookieDoom then
			mod:prankCookieDoomApply(entity, source, data)
		else
			FiendFolio.AddDoom(entity, source.Entity.SpawnerEntity, data.ApplyDoomDuration, data.ApplyDoomCountdown, data.ApplyDoomDamage)
		end
	end
end

function mod:doomOnDamage(entity, data, source)
	if data.FFDoomDuration ~= nil and data.FFDoomDuration > 0 and 
	   (data.FFLastDoomCountdown == nil or game:GetFrameCount() >= data.FFLastDoomCountdown + FiendFolio.StatusEffectVariables.DoomCountdownCooldown) 
	then
		if data.FFDoomCountdown == 4 and (lastFramePiano3Happened == nil or lastFramePiano3Happened ~= Isaac.GetFrameCount()) then
			sfx:Play(mod.Sounds.Piano3, 0.7, 0, false, data.FFDoomPitch)
			lastFramePiano3Happened = Isaac.GetFrameCount()
		elseif data.FFDoomCountdown == 3 and (lastFramePiano2Happened == nil or lastFramePiano2Happened ~= Isaac.GetFrameCount()) then
			sfx:Play(mod.Sounds.Piano2, 0.7, 0, false, data.FFDoomPitch)
			lastFramePiano2Happened = Isaac.GetFrameCount()
		elseif data.FFDoomCountdown == 2 and (lastFramePiano1Happened == nil or lastFramePiano1Happened ~= Isaac.GetFrameCount()) then
			sfx:Play(mod.Sounds.Piano1, 0.7, 0, false, data.FFDoomPitch)
			lastFramePiano1Happened = Isaac.GetFrameCount()
		end
			
		if mod:isSegmented(entity) and not mod:isReducedSyncSegment(entity) then
			local segments = mod:getSegments(entity)

			for _,segment in ipairs(segments) do
				segment:GetData().FFDoomForceIconReaction = segment:GetData().FFDoomCountdown > 0
				segment:GetData().FFDoomCountdown = math.max(segment:GetData().FFDoomCountdown - 1, 0)
				segment:GetData().FFLastDoomCountdown = game:GetFrameCount()
			end
		elseif mod:isBasegameSegmented(entity) and not mod:isBasegameReducedSyncSegment(entity)	then
			if not (source == nil or source.Entity == nil or mod:isInBasegameSegmentsOf(source.Entity, entity)) then
				local segments = mod:getBasegameSegments(entity)

				for _,segment in ipairs(segments) do
					segment:GetData().FFDoomForceIconReaction = segment:GetData().FFDoomCountdown > 0
					segment:GetData().FFDoomCountdown = math.max(segment:GetData().FFDoomCountdown - 1, 0)
					segment:GetData().FFLastDoomCountdown = game:GetFrameCount()
				end
			end
		else
			data.FFDoomForceIconReaction = data.FFDoomCountdown > 0
			data.FFDoomCountdown = math.max(data.FFDoomCountdown - 1, 0)
			data.FFLastDoomCountdown = game:GetFrameCount()
		end
	end
end

function mod:doomOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFDoomDuration ~= nil and data.FFDoomDuration > 0 and not clearingStatus then
		mod:handleDoom(npc, data, sprite)
		data.hasFFStatusIcon = true
	else
		data.FFDoomDuration = nil
		data.FFDoomCountdown = nil
		data.FFDoomDamage = nil
		data.FFDoomSource = nil
		data.FFDoomTriggerCountdown = nil
		data.FFDoomForceIconReaction = nil
	end
end

function mod:copyDoom(copyData, sourceData)
	copyData.FFDoomDuration = sourceData.FFDoomDuration
	copyData.FFDoomCountdown = sourceData.FFDoomCountdown
	copyData.FFDoomDamage = sourceData.FFDoomDamage
	copyData.FFDoomSource = sourceData.FFDoomSource
	copyData.FFDoomTriggerCountdown = sourceData.FFDoomTriggerCountdown
	copyData.FFDoomForceIconReaction = sourceData.FFDoomForceIconReaction
end
