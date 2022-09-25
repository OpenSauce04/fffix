FiendFolio.LoadScripts({
    "ffscripts.statuses.atrophy",
    "ffscripts.statuses.berserk",
    "ffscripts.statuses.blind",
    "ffscripts.statuses.bloated",
    "ffscripts.statuses.bruise",
    "ffscripts.statuses.doom",
    "ffscripts.statuses.drowsyAndSleep",
    "ffscripts.statuses.hemorrhaging",
    "ffscripts.statuses.martyr",
    "ffscripts.statuses.sewn",
    "ffscripts.statuses.sweaty",
    "ffscripts.statuses.multieuclidean",
})

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

-----------------------------------------------------------
-- Status Effects
-----------------------------------------------------------

function mod:isIceBlacklisted(entity)
	return entity:IsBoss() or
	       FiendFolio.IceBlacklist[entity.Type] or
	       FiendFolio.IceBlacklist[entity.Type .. " " .. entity.Variant] or
	       FiendFolio.IceBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:isIceWhitelisted(entity)
	return FiendFolio.IceWhitelist[entity.Type] or
	       FiendFolio.IceWhitelist[entity.Type .. " " .. entity.Variant] or
	       FiendFolio.IceWhitelist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:isStatusBlacklisted(entity)
	return mod.FFStatusBlacklist[entity.Type] or
	       mod.FFStatusBlacklist[entity.Type .. " " .. entity.Variant] or
	       mod.FFStatusBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:isLeavingStatusCorpse(entity)
	return entity:HasMortalDamage() and (entity:HasEntityFlags(EntityFlag.FLAG_ICE) or entity:GetData().FFApplyMartyrOnDeath == true)
end

function mod:isStatusCorpse(entity)
	return entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) or entity:GetData().FFMartyrDuration ~= nil
end

function mod:isDamagableByStatus(npc, target)
	return target:ToNPC() and (mod:isCharm(npc) or mod:isBerserk(npc) or mod:isBaited(target))
end

function mod:isCharmOrBerserk(npc)
	return mod:isCharm(npc) or mod:isBerserk(npc)
end

function mod:hasCustomStatus(npc, ignoreBruise)
	local data = npc:GetData()
	return (data.FFAtrophyDuration ~= nil and data.FFAtrophyDuration > 0) or 
	       (data.FFBerserkDuration ~= nil and data.FFBerserkDuration > 0) or
	       (data.FFBlindDuration ~= nil and data.FFBlindDuration > 0) or 
	       (data.FFBloatedDuration ~= nil and data.FFBloatedDuration > 0) or
	       (not ignoreBruise and data.FFBruiseInstances ~= nil and #data.FFBruiseInstances > 0) or 
	       (data.FFDoomDuration ~= nil and data.FFDoomDuration > 0) or 
	       (data.FFDrowsyDuration ~= nil and data.FFDrowsyDuration > 0) or 
	       (data.FFSleepDuration ~= nil and data.FFSleepDuration > 0) or 
	       (data.FFBleedDuration ~= nil and data.FFBleedDuration > 0) or 
	       (data.FFSewnDuration ~= nil and data.FFSewnDuration > 0) or 
	       (data.FFSweatyDuration ~= nil and data.FFSweatyDuration > 0) or
		   (data.FFMultiEuclideanDuration ~= nil and data.FFMultiEuclideanDuration > 0)
end

--Status Color Order
--
--Friendly
--Weakness
--BrimstoneMarked
--Burn
--Baited
--Magnetized
--Fear (i guess pacman color is a thing)
--Slow (stinky no consistent color status bad)
--Freeze
--Confusion
--Charm
--Poison
--Midas

--BleedOut (no color)
--Ice (no color)
--IceFrozen (color when dead; not necessary)
--Shrink (no color)

local BasegameStatusColors = {
	Friendly = Color(0.8, 0.8, 0.8, 1.0, 0.1, 0.1, 0.1),
	--Weakness = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--BrimstoneMarked = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--Burn = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--Baited = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--Magnetized = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	Fear = Color(0.5, 0.1, 0.5, 1.0, 0.0, 0.0, 0.0),
	--FearPacMan = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	Slow = Color(1.0, 1.0, 1.3, 1.0, 40/255, 40/255, 40/255),
	--SlowGish = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	Freeze = Color(0.22, 0.22, 0.22, 1.0, 40/255, 40/255, 40/255),
	Confusion = Color(0.5, 0.5, 0.5, 1.0, 40/255, 40/255, 40/255),
	Charm = Color(1.0, 0.0, 0.8, 1.0, 40/255, 40/255, 40/255),
	--Poison = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	Midas = Color(1.5, 1.5, 0.3, 1.0, 40/255, 40/255, 40/255),
	--BleedOut = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--Ice = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--IceFrozen = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
	--Shrink = Color(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
}

function mod:syncStatusEffects(segments)
	local syncShrink = false
	local syncMidas = false
	local syncCharm = false
	local syncConfusion = false
	local syncFreeze = false
	local syncSlow = false
	local syncFear = false
	local syncFriendly = false

	local color = segments[1]:GetSprite().Color
	local reducedColor = nil
	local priority = 0

	for _,segment in ipairs(segments) do
		local data = segment:GetData()

		if segment:HasEntityFlags(EntityFlag.FLAG_SHRINK) and not data.FFIgnoreShrinkFlag then
			syncShrink = true
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) and not data.FFIgnoreMidasFlag then
			syncMidas = true
			if priority < 1 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Midas
				priority = 1
			end
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_POISON) and priority < 2 then
			color = segment:GetSprite().Color
			priority = 2
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_CHARM) and not data.FFIgnoreCharmFlag then
			syncCharm = true
			if priority < 3 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Charm
				priority = 3
			end
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_CONFUSION) and not data.FFIgnoreConfuseFlag then
			syncConfusion = true
			if priority < 4 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Confusion
				priority = 4
			end
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_FREEZE) and not data.FFIgnoreFreezeFlag then
			syncFreeze = true
			if priority < 5 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Freeze
				priority = 5
			end
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_SLOW) and not data.FFIgnoreSlowFlag then
			syncSlow = true
			if priority < 6 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Slow
				priority = 6
			end
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_FEAR) and not data.FFIgnoreFearFlag then
			syncFear = true
			if priority < 7 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Fear
				priority = 7
			end
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) and priority < 8 then
			color = segment:GetSprite().Color
			priority = 8
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_BAITED) and priority < 9 then
			color = segment:GetSprite().Color
			priority = 9
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_BURN) and priority < 10 then
			color = segment:GetSprite().Color
			priority = 10
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED) and priority < 11 then
			color = segment:GetSprite().Color
			priority = 11
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) and priority < 12 then
			color = segment:GetSprite().Color
			priority = 12
		end

		if segment:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			syncFriendly = true
			if priority < 13 then
				color = segment:GetSprite().Color
				reducedColor = BasegameStatusColors.Friendly
				priority = 13
			end
		end

		if segment:GetData().eternalFlickerspirited and priority < 14 then
			color = segment:GetSprite().Color
			reducedColor = Color(1.5, 1.5, 1.5, 1.0, 50/255, 50/255, 50/255)
			priority = 14
		end
	end

	for _,segment in ipairs(segments) do
		local slowColor
		local data = segment:GetData()

		if not mod:isReducedSyncSegment(segment) then
			segment:SetColor(color, 1, statusColorPriority, false, false)
			slowColor = color
		elseif reducedColor ~= nil then
			segment:SetColor(reducedColor, 1, statusColorPriority, false, false)
			slowColor = reducedColor
		end

		if syncShrink and not segment:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_SHRINK)
				data.FFIgnoreShrinkFlag = true
			else
				segment:AddShrink(EntityRef(nil), 1)
			end
		elseif (not syncShrink) and segment:HasEntityFlags(EntityFlag.FLAG_SHRINK) and data.FFIgnoreShrinkFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_SHRINK)
			data.FFIgnoreShrinkFlag = false
		end

		if syncMidas and not segment:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)
				data.FFIgnoreMidasFlag = true
			else
				segment:AddMidasFreeze(EntityRef(nil), 1)
			end
		elseif (not syncMidas) and segment:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) and data.FFIgnoreMidasFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)
			data.FFIgnoreMidasFlag = false
		end

		if syncCharm and not segment:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_CHARM)
				data.FFIgnoreCharmFlag = true
			else
				segment:AddCharmed(EntityRef(nil), 1)
			end
		elseif (not syncCharm) and segment:HasEntityFlags(EntityFlag.FLAG_CHARM) and data.FFIgnoreCharmFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_CHARM)
			data.FFIgnoreCharmFlag = false
		end

		if syncConfusion and not segment:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
				data.FFIgnoreConfuseFlag = true
			else
				segment:AddConfusion(EntityRef(nil), 1, false)
			end
		elseif (not syncConfusion) and segment:HasEntityFlags(EntityFlag.FLAG_CONFUSION) and data.FFIgnoreConfuseFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_CONFUSION)
			data.FFIgnoreConfuseFlag = false
		end

		if syncFreeze and not segment:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_FREEZE)
				data.FFIgnoreFreezeFlag = true
			else
				segment:AddFreeze(EntityRef(nil), 1)
			end
		elseif (not syncFreeze) and segment:HasEntityFlags(EntityFlag.FLAG_FREEZE) and data.FFIgnoreFreezeFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
			data.FFIgnoreFreezeFlag = false
		end

		if syncSlow and not segment:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_SLOW)
				data.FFIgnoreSlowFlag = true
			else
				segment:AddSlowing(EntityRef(nil), 1, 0.5, slowColor)
			end
		elseif (not syncSlow) and segment:HasEntityFlags(EntityFlag.FLAG_SLOW) and data.FFIgnoreSlowFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_SLOW)
			data.FFIgnoreSlowFlag = false
		end

		if syncFear and not segment:HasEntityFlags(EntityFlag.FLAG_FEAR) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_FEAR)
				data.FFIgnoreFearFlag = true
			else
				segment:AddFear(EntityRef(nil), 1, false)
			end
		elseif (not syncFear) and segment:HasEntityFlags(EntityFlag.FLAG_FEAR) and data.FFIgnoreFearFlag then
			segment:ClearEntityFlags(EntityFlag.FLAG_FEAR)
			data.FFIgnoreFearFlag = false
		end

		if syncFriendly and not segment:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			if segment:IsBoss() then
				segment:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			else
				segment:AddCharmed(EntityRef(nil), -1, false)
			end
		end
	end
end

function mod:handleSegmentedIce(segments)
	local hasIce = false

	for _, segment in ipairs(segments) do
		if segment:HasEntityFlags(EntityFlag.FLAG_ICE) then
			hasIce = true
			segment:ClearEntityFlags(EntityFlag.FLAG_ICE)
		end
	end

	if hasIce then
		for _, segment in ipairs(segments) do
			if mod:isMainSegment(segment) then
				segment:AddEntityFlags(EntityFlag.FLAG_ICE)
			end
		end
	end
end

function mod:removeStatusEffects(entity, ignoreFriendly, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				mod:removeStatusEffects(entity, ignoreFriendly, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				mod:removeStatusEffects(entity, ignoreFriendly, true)
			end
		end
	end

	if ignoreFriendly then
		entity:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
	end

	-- WHY DOES THE BASEGAME REMOVESTATUSEFFECTS RESET COLOR WHY WHY WHY
	entity:ClearEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_POISON | EntityFlag.FLAG_SLOW |
	                        EntityFlag.FLAG_CHARM | EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_MIDAS_FREEZE |
	                        EntityFlag.FLAG_FEAR | EntityFlag.FLAG_BURN | EntityFlag.FLAG_SHRINK |
	                        EntityFlag.FLAG_BLEED_OUT | EntityFlag.FLAG_MAGNETIZED | EntityFlag.FLAG_BAITED |
	                        EntityFlag.FLAG_WEAKNESS | EntityFlag.FLAG_BRIMSTONE_MARKED)

	FiendFolio.RemoveAtrophy(entity)
	FiendFolio.RemoveBerserk(entity)
	FiendFolio.RemoveBleed(entity)
	FiendFolio.RemoveBlind(entity)
	FiendFolio.RemoveBloated(entity)
	FiendFolio.RemoveBruise(entity)
	FiendFolio.RemoveDoom(entity)
	FiendFolio.RemoveDrowsy(entity)
	FiendFolio.RemoveSewn(entity)
	FiendFolio.RemoveSleep(entity)
	FiendFolio.RemoveSweaty(entity)
	FiendFolio.RemoveMultiEuclidean(entity)
end

function mod:checkIfStatusLogicIsApplied(entity, flipKnights)
	if not (mod:isSegmented(entity) or mod:isBasegameSegmented(entity)) then
		return true
	elseif flipKnights and entity.Type == mod.FF.ToxicKnight.ID and entity.Variant == mod.FF.ToxicKnight.Var then
		return entity.SubType == mod.FF.ToxicKnightBrain.Sub
	elseif flipKnights and entity.Type == mod.FF.PsiKnight.ID and entity.Variant == mod.FF.PsiKnight.Var then
		return entity.SubType == mod.FF.PsiKnightBrain.Sub
	elseif mod:isMainSegment(entity) or mod:isBasegameMainSegment(entity) then
		return true
	elseif mod:isReducedSyncSegment(entity) or mod:isBasegameReducedSyncSegment(entity) then
		return true
	else
		return false
	end
end

function mod:getBasegameVelocityMultiplier(entity)
	local isSlowed = entity:HasEntityFlags(EntityFlag.FLAG_SLOW)
	local brokenWatchState = game:GetRoom():GetBrokenWatchState()
	local hasStopWatch = false
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_STOP_WATCH) then
			hasStopWatch = true
			break
		end
	end

	local slowValue = 1.0
	if isSlowed then
		slowValue = slowValue * 0.5
	end
	if brokenWatchState == 1 then
		slowValue = slowValue * 0.5
	elseif brokenWatchState == 2 then
		slowValue = slowValue * 1.43
	end
	if hasStopWatch then
		slowValue = slowValue * 0.8
	end

	return slowValue
end

function mod:isInMinecart(entity)
	local minecarts = Isaac.FindByType(EntityType.ENTITY_MINECART, -1, -1, true)
	for _, minecart in ipairs(minecarts) do
		if minecart.Child ~= nil and minecart.Child.Index == entity.Index and minecart.Child.InitSeed == entity.InitSeed then
			return true
		end
	end
	
	return false
end

function mod:isInAnimaSola(entity)
	local chains = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ANIMA_CHAIN, 0, true)
	for _, chain in ipairs(chains) do
		if chain.FrameCount > 5 and chain.Target ~= nil and chain.Target.Index == entity.Index and chain.Target.InitSeed == entity.InitSeed then
			return true
		end
	end
	
	return false
end

function mod:handleAnimAndMoveSpeedMultipliers(entity, data, sprite)
	local statusMultiplier = 1
	if data.FFDrowsyDuration ~= nil and data.FFDrowsyDuration >= 0 then
		statusMultiplier = statusMultiplier * data.FFDrowsyDuration / data.FFDrowsyDurationMax
	end
	if data.FFBerserkDuration ~= nil and data.FFBerserkDuration >= 0 then
		statusMultiplier = statusMultiplier * FiendFolio.StatusEffectVariables.BerserkAnimAndMoveSpeedMultiplier
	end
	data.FFStatusMultiplierThisFrame = statusMultiplier

	if not (mod:isInMinecart(entity) or mod:isInAnimaSola(entity)) then
		local basegameVelocityMultiplier = mod:getBasegameVelocityMultiplier(entity)

		entity.Position = entity.Position - entity.Velocity * basegameVelocityMultiplier * (1 - statusMultiplier)
		data.FFStatusOriginalVelocity = entity.Velocity
		entity.Velocity = entity.Velocity * statusMultiplier
	end

	sprite.PlaybackSpeed = statusMultiplier
	
	mod:riftWalkerSetAnimMulti(entity, data, statusMultiplier)
end

function mod:setTargetOfNPC(npc)
	local data = npc:GetData()

	local target
	if npc.Target and npc.Target:HasEntityFlags(EntityFlag.FLAG_BAITED) and not (mod:isSegmented(npc) and mod:isInSegmentsOf(npc.Target, npc)) then
		target = npc.Target
	elseif data.FFBerserkDuration ~= nil and data.FFBerserkDuration >= 0 then
		if data.FFBerserkPreviousTarget then
			target = data.FFBerserkPreviousTarget
		end

		if target == nil or not target:Exists() or target:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
			local ignoredTarget = data.FFBerserkIgnoredTarget
			local npcIsCharmed = npc:HasEntityFlags(EntityFlag.FLAG_CHARM)
			local npcIsFriendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

			local closestDist = 999999
			local closestEnt = nil
			local closestEntHasBait = false
			local closestEntShouldBeIgnored = false

			for _, entity in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
				local entityIsBaited = entity:HasEntityFlags(EntityFlag.FLAG_BAITED)
				local entityIsFriendly = entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
				local entityIsIgnored = ignoredTarget ~= nil and entity.Index == ignoredTarget.Index and entity.InitSeed == ignoredTarget.InitSeed
				local entityIsSelf = entity.Index == npc.Index and entity.InitSeed == npc.InitSeed

				if entityIsSelf then
					-- do nothing
				elseif entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
					-- do nothing
				elseif mod:isSegmented(entity) and mod:isInSegmentsOf(entity, npc) then
					-- do nothing
				elseif mod:isBasegameSegmented(entity) and mod:isInBasegameSegmentsOf(entity, npc) then
					-- do nothing
				elseif npcIsFriendly and entityIsFriendly then
					-- do nothing
				elseif mod:isStatusCorpse(entity) then
					-- do nothing
				elseif entityIsBaited then
					local dist = (entity.Position - npc.Position):Length()
					if dist < closestDist then
						closestEnt = entity
						closestDist = dist
						closestEntHasBait = entityHasBait
						closestEntShouldBeIgnored = false
					end
				elseif closestEntHasBait then
					-- do nothing
				elseif entityIsIgnored and not closestEntShouldBeIgnored then
					-- do nothing
				elseif mod:isBerserk(entity) and entity.HitPoints <= 0 and entity.MaxHitPoints ~= 0 then
					-- do nothing
				else
					local dist = (entity.Position - npc.Position):Length()
					if dist < closestDist then
						closestEnt = entity
						closestDist = dist
						closestEntHasBait = entityHasBait
						closestEntShouldBeIgnored = entityIsIgnored
					end
				end
			end

			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				local playerIsIgnored = ignoredTarget ~= nil and ignoredTarget.Type == EntityType.ENTITY_PLAYER

				if closestEntHasBait then
					-- do nothing
				elseif playerIsIgnored and closestEnt then
					-- do nothing
				elseif (npcIsCharmed or npcIsFriendly) and closestEnt then
					-- do nothing
				else
					local dist = (player.Position - npc.Position):Length()
					if dist < closestDist then
						closestEnt = player
						closestDist = dist
						closestEntHasBait = false
						closestEntShouldBeIgnored = playerIsIgnored
					end
				end
			end

			data.FFBerserkPreviousTarget = closestEnt
			target = closestEnt
			if ignoredTarget ~= nil and (ignoredTarget.Index ~= target.Index or ignoredTarget.InitSeed ~= target.InitSeed) then
				data.FFBerserkTicksWithCurrentTarget = nil
			end
		end
	else
		target = npc.Target
		if npc.Target == nil then
			target = npc:GetPlayerTarget()
		end

		if mod:isSegmented(npc) and mod:isInSegmentsOf(target, npc) then
			local npcIsCharmed = npc:HasEntityFlags(EntityFlag.FLAG_CHARM)
			local npcIsFriendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)

			local closestDist = 999999
			local closestEnt = nil
			local closestEntHasBait = false

			for _, entity in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
				local entityIsBaited = entity:HasEntityFlags(EntityFlag.FLAG_BAITED)
				local entityIsFriendly = entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
				local entityIsSelf = entity.Index == npc.Index and entity.InitSeed == npc.InitSeed

				if entityIsSelf then
					-- do nothing
				elseif entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
					-- do nothing
				elseif mod:isSegmented(entity) and mod:isInSegmentsOf(entity, npc) then
					-- do nothing
				elseif npcIsFriendly and entityIsFriendly then
					-- do nothing
				elseif mod:isStatusCorpse(entity) then
					-- do nothing
				elseif entityIsBaited then
					local dist = (entity.Position - npc.Position):Length()
					if dist < closestDist then
						closestEnt = entity
						closestDist = dist
						closestEntHasBait = entityHasBait
					end
				elseif closestEntHasBait then
					-- do nothing
				elseif not (npcIsFriendly or npcIsCharmed) then
					-- do nothing
				else
					local dist = (entity.Position - npc.Position):Length()
					if dist < closestDist then
						closestEnt = entity
						closestDist = dist
						closestEntHasBait = entityHasBait
					end
				end
			end

			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)

				if closestEntHasBait then
					-- do nothing
				elseif (npcIsCharmed or npcIsFriendly) and closestEnt then
					-- do nothing
				else
					local dist = (player.Position - npc.Position):Length()
					if dist < closestDist then
						closestEnt = player
						closestDist = dist
						closestEntHasBait = false
					end
				end
			end

			target = closestEnt
		end
	end

	if target ~= nil and target:ToNPC() then
		npc.Target = target
		data.FFForcedTarget = target
	elseif data.FFForcedTarget then
		if not npc.Target or (data.FFForcedTarget.Index == npc.Target.Index and data.FFForcedTarget.InitSeed == npc.Target.InitSeed) then
			npc.Target = nil
		end
		data.FFForcedTarget = nil
	end
	return target
end

mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
	local data = npc:GetData()
	npc.Velocity = data.FFStatusOriginalVelocity or npc.Velocity
	data.FFStatusOriginalVelocity = nil
	
	if npc.Type == EntityType.ENTITY_EVIS and npc.Variant == 10 then -- Evis Guts / Sewing Rope
		-- do nothing
	elseif npc.Type == EntityType.ENTITY_SIREN_HELPER then
		-- do nothing
	elseif not (npc.Type == mod.FF.Kingpin.ID and npc.Variant == mod.FF.Kingpin.Var) or mod:isMainSegment(npc) then
		mod:setTargetOfNPC(npc)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
	if Isaac.GetFrameCount() % 2 == 0 then
		local data = npc:GetData()
		npc.Velocity = data.FFStatusOriginalVelocity or npc.Velocity
		data.FFStatusOriginalVelocity = nil
	end
end)

function mod:shouldClearStatus(entity)
	if entity.Type == EntityType.ENTITY_FROZEN_ENEMY then
		return true
	elseif entity.Type == EntityType.ENTITY_CLICKETY_CLACK and entity.State == 16 then
		return true
	elseif entity.Type == EntityType.ENTITY_VISAGE and entity.Variant == 1 and entity.State == 109 then
		return true
	else
		return false
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	mod:resetOnlyDeadBerserkRemaining()

	local entities = Isaac.GetRoomEntities()
	local npcs = {}
	for _, entity in ipairs(entities) do
		if entity:ToNPC() then
			table.insert(npcs, entity:ToNPC())
		end
	end

	for _, npc in ipairs(npcs) do
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if data.FFStatusFlagsToRemove == nil then
			data.FFStatusFlagsToRemove = 0
		end
		npc:ClearEntityFlags(data.FFStatusFlagsToRemove)
		data.FFStatusFlagsToRemove = 0

		if mod:isIceBlacklisted(npc) and not mod:isIceWhitelisted(npc) then
			npc:ClearEntityFlags(EntityFlag.FLAG_ICE)
		end

		if mod:isMainSegment(npc) then
			local segments = mod:getSegments(npc)

			if not mod:isReducedSyncSegment(npc) then
				mod:handleSegmentedIce(segments)
			end

			mod:syncStatusEffects(segments)
		end
		
		mod:jevilBruseEnemies(npc)

		data.hasFFStatusIcon = false
		local clearingStatus = mod:shouldClearStatus(npc)
		
		mod:drowsySleepOnUpdate(npc, data, sprite, clearingStatus)
		--mod:atrophyOnUpdate(npc, data, sprite, clearingStatus)
		mod:hemorragingOnUpdate(npc, data, sprite, clearingStatus)
		--mod:blindOnUpdate(npc, data, sprite, clearingStatus)
		--mod:bloatedOnUpdate(npc, data, sprite, clearingStatus)
		mod:bruiseOnUpdate(npc, data, sprite, clearingStatus)
		mod:sewnOnUpdate(npc, data, sprite, clearingStatus)
		--mod:sweatyOnUpdate(npc, data, sprite, clearingStatus)
		mod:multiEuclideanOnUpdate(npc, data, sprite, clearingStatus)

		mod:InfectedConfuzzleUpdate(npc, data)
	end

	mod:handleSewnCurrentHealth(npcs)
	mod:handleSewnRopes(npcs)

	for _, npc in ipairs(npcs) do
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod:martyrOnUpdate(npc, data, sprite)

		local clearingStatus = mod:shouldClearStatus(npc)
		mod:berserkOnUpdate(npc, data, sprite, clearingStatus)
		mod:doomOnUpdate(npc, data, sprite, clearingStatus)

		if (data.FFBerserkDuration ~= nil and data.FFBerserkDuration >= 0) or 
		   (data.FFDrowsyDuration ~= nil and data.FFDrowsyDuration >= 0) or
		   (npc.Type == mod.FF.RiftWalker.ID and npc.Variant == mod.FF.RiftWalker.Var and npc.SubType ~= mod.FF.RiftWalkerGfx.Sub)
		then
			mod:handleAnimAndMoveSpeedMultipliers(npc, data, sprite)
			data.hadUpdatedAnimAndMoveSpeed = true
		elseif data.hadUpdatedAnimAndMoveSpeed then
			sprite.PlaybackSpeed = 1.0
			data.hadUpdatedAnimAndMoveSpeed = nil
		end

		if data.hasFFStatusIcon and not data.FFStatusIcon and mod:checkIfStatusLogicIsApplied(npc, false) and not data.NoCustomStatusIndicators then
			local icon = Isaac.Spawn(EntityType.ENTITY_EFFECT, 1748, 0, npc.Position, npc.Velocity, nil):ToEffect()
			icon.Parent = npc
			icon:FollowParent(npc)
			icon.DepthOffset = 1
			icon:Update()
			data.FFStatusIcon = icon
		elseif data.FFStatusIcon and not data.hasFFStatusIcon then
			data.FFStatusIcon:Remove()
			data.FFStatusIcon = nil
		end
		
		if data.FFStatusSentKillingBlow and npc.HitPoints > 0.0 then
			data.FFStatusSentKillingBlow = false
		end
		
		if mod:hasCustomStatus(npc) and npc:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
			data.FFBossStatusResistanceFromBruise = (data.FFBruiseInstances ~= nil and #data.FFBruiseInstances > 0) or data.FFHadBruiseThisFrame
		else
			data.FFBossStatusResistance = (data.FFBossStatusResistance or 1) - 1
			if data.FFBossStatusResistance <= 0 then
				data.FFBossStatusResistance = nil
				data.FFBossStatusResistanceFromBruise = nil
			end
		end
		
		data.FFHadBruiseThisFrame = nil
		
		mod:handleEnthralled(npc, sprite, data)
	end

	-- Cordify Marker + Uranus compatibility because effects are weird
	local markers = Isaac.FindByType(EntityType.ENTITY_EFFECT, 1731)
	for _,marker in ipairs(markers) do
		if marker.Parent and (mod:isLeavingStatusCorpse(marker.Parent) or mod:isStatusCorpse(marker.Parent)) then
			marker:Remove()
		end
	end
end)

function mod:statusIcons(effect)
	local parent = effect.Parent

	if not parent then
		effect:Remove()
	else
		local data = parent:GetData()
		local sprite = effect:GetSprite()

		local offset = 0

		if data.FFDoomDuration ~= nil then
			--[[local firstIcon = not (sprite:IsPlaying("Doom0") or sprite:IsFinished("Doom0") or
			                       sprite:IsPlaying("Doom1") or sprite:IsFinished("Doom1") or
			                       sprite:IsPlaying("Doom2") or sprite:IsFinished("Doom2") or
			                       sprite:IsPlaying("Doom3") or sprite:IsFinished("Doom3") or
			                       sprite:IsPlaying("Doom4") or sprite:IsFinished("Doom4") or
			                       sprite:IsPlaying("Doom5") or sprite:IsFinished("Doom5") or
			                       sprite:IsPlaying("Doom6") or sprite:IsFinished("Doom6") or
			                       sprite:IsPlaying("Doom7") or sprite:IsFinished("Doom7") or
			                       sprite:IsPlaying("Doom8") or sprite:IsFinished("Doom8") or
			                       sprite:IsPlaying("Doom9") or sprite:IsFinished("Doom9") or
			                       sprite:IsPlaying("Doom10+") or sprite:IsFinished("Doom10+"))]]--
			
			local anim = "Doom" .. data.FFDoomCountdown
			if data.FFDoomCountdown >= 10 then
				anim = "Doom10+"
			end
			
			--[[if not (sprite:IsPlaying(anim) or sprite:IsFinished(anim)) or data.FFDoomForceIconReaction then
				if firstIcon and not data.FFDoomForceIconReaction then
					sprite:SetFrame(anim, 3)
				else
					sprite:Play(anim, true)
				end
			end
			
			data.FFDoomForceIconReaction = nil]]--
			
			if not (sprite:IsPlaying(anim) or sprite:IsFinished(anim)) then
				sprite:Play(anim, true)
			end
		elseif data.FFBerserkDuration ~= nil then
			if not sprite:IsPlaying("Berserk") then
				sprite:Play("Berserk", true)
			end
		elseif data.FFSewnDuration ~= nil then
			offset = 0.5

			if not sprite:IsPlaying("Sewn") then
				sprite:Play("Sewn", true)
			end
		elseif (data.FFDrowsyDuration == nil or data.FFDrowsyDuration <= 0) and data.FFSleepDuration ~= nil then
			offset = 0.5

			if not sprite:IsPlaying("Sleep") then
				sprite:Play("Sleep", true)
			end
		elseif data.FFBruiseInstances ~= nil then
			offset = 0.5

			local frame = 0
			if sprite:IsPlaying("BruiseLvl1") or sprite:IsPlaying("BruiseLvl2") or sprite:IsPlaying("BruiseLvl3") or sprite:IsPlaying("BruiseLvl4") or sprite:IsPlaying("BruiseLvl5") then
				frame = sprite:GetFrame()
			end

			local stacks = data.FFBruiseLastStacks or 0
			if stacks == 1 and not sprite:IsPlaying("BruiseLvl1") then
				sprite:Play("BruiseLvl1", true)
				sprite:SetFrame(frame)
			elseif stacks == 2 and not sprite:IsPlaying("BruiseLvl2") then
				sprite:Play("BruiseLvl2", true)
				sprite:SetFrame(frame)
			elseif stacks == 3 and not sprite:IsPlaying("BruiseLvl3") then
				sprite:Play("BruiseLvl3", true)
				sprite:SetFrame(frame)
			elseif stacks == 4 and not sprite:IsPlaying("BruiseLvl4") then
				sprite:Play("BruiseLvl4", true)
				sprite:SetFrame(frame)
			elseif stacks >= 5 and not sprite:IsPlaying("BruiseLvl5") then
				sprite:Play("BruiseLvl5", true)
				sprite:SetFrame(frame)
			end
		elseif data.FFBleedDuration ~= nil then
			if not sprite:IsPlaying("Bleed") then
				sprite:Play("Bleed", true)
			end
		elseif data.HoneyPennyTimer ~= nil and not sprite:IsPlaying("HoneyRunOut") then --Honey Powerup
			if data.HoneyPennyTimer <= 60 and not sprite:IsPlaying("HoneyRunOut") then--Honey Powerup
				sprite:Play("HoneyRunOut", true)
			elseif not sprite:IsPlaying("Honey") then
				sprite:Play("Honey", true)
			end
		end

		effect.SpriteOffset = Vector(offset, -30 + parent.Size * -1.0)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.statusIcons, 1748)

function mod:copyFFStatusEffects(source, copy)
	local sourceData = source:GetData()
	local copyData = copy:GetData()

	if not (copy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(copy)) then
		mod:copyHemorraging(copyData, sourceData)
		mod:copyBruise(copyData, sourceData)
		mod:copyDrowsyAndSleep(copyData, sourceData)
		mod:copySewn(copy, copyData, sourceData)
		mod:copyBerserk(copyData, sourceData)
		mod:copyDoom(copyData, sourceData)
	end

	mod:copyMartyr(copy, copyData, sourceData)
end
