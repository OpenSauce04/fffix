local mod = FiendFolio

local game = Game()
local grng = RNG()
local sfx = SFXManager()

-- Pickup replacements, penny replacements, sack replacements, battery replacements, etc
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, var, subtype, pos, vel, spawner, seed)
	if id == EntityType.ENTITY_PICKUP then
        grng:SetSeed(seed, 0)
		if var == mod.PICKUP.VARIANT.RANDOM_OBJECT then
			if subtype == 1 then
				local disc = mod.GetRandomDisc(grng) or mod.ITEM.CARD.TREASURE_DISC
				return {5, 300, disc, seed}
			elseif subtype == 2 then
				local cardid = FiendFolio.EnergyCards[grng:RandomInt(#FiendFolio.EnergyCards) + 1]
				return {5, 300, cardid, seed}
			else
				return {5, 300, FiendFolio.GetRandomObject(grng), seed}
			end
		end
		if subtype == 0 and FiendFolio.IsReplaceablePickup({Type = id, Variant = var, SubType = subtype}) then
			local hasSackFossil = false
			local totalSackFossilChance = 0
			mod.AnyPlayerDo(function(player)
				if player:HasTrinket(FiendFolio.ITEM.ROCK.SACK_FOSSIL) then
					hasSackFossil = true
		
					local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SACK_FOSSIL)
					totalSackFossilChance = totalSackFossilChance + 10 * trinketPower
				end
			end)
			totalSackFossilChance = math.ceil(totalSackFossilChance)
		
			if hasSackFossil then
				if grng:RandomInt(100) < totalSackFossilChance then
					return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, seed}
					--pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0)
				end
			end
		end
        if var == PickupVariant.PICKUP_COIN and subtype == 0 then
            local hauntedPennyChance = 200
            local cursedPennyChance = 150
            for i = 1, game:GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                if player:GetPlayerType() == FiendFolio.PLAYER.FIEND or player:GetPlayerType() == FiendFolio.PLAYER.BIEND then
                    cursedPennyChance = math.min(20, cursedPennyChance)
                elseif player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
                    hauntedPennyChance = 100
                end
            end
            local evilSticker = mod.anyPlayerHas(CollectibleType.COLLECTIBLE_EVIL_STICKER, false)
            local foolsGold = mod.anyPlayerHas(TrinketType.TRINKET_FOOLS_GOLD, true)
            if foolsGold then cursedPennyChance = math.min(5, cursedPennyChance) end
            if evilSticker then cursedPennyChance = math.min(3, cursedPennyChance) end
            if mod.getTrinketMultiplierAcrossAllPlayers(TrinketType.TRINKET_FOOLS_GOLD) > 1 or (foolsGold and evilSticker) then cursedPennyChance = math.min(2, cursedPennyChance) end

            if grng:RandomInt(cursedPennyChance) == 0 then
                if grng:RandomInt(100) == 0 then
                    return {id, var, CoinSubType.COIN_GOLDENCURSEDPENNY, seed}
                else
                    return {id, var, CoinSubType.COIN_CURSEDPENNY, seed}
                end
            end

            if grng:RandomInt(hauntedPennyChance) == 0 then
                return {5, 20, CoinSubType.COIN_HAUNTEDPENNY, seed}
            end
        elseif var == PickupVariant.PICKUP_GRAB_BAG and subtype == 0 then
            if grng:RandomInt(4) == 0 then
                if grng:RandomInt(2) == 0 then
                    return {id, 666, 0, seed} -- Trash Bag
                else
                    return {id, 666, 10, seed} -- Blood Bag
                end
            end

            if grng:RandomInt(20) == 0 then
                return {id, 666, 11, seed} -- 52 Deck
            end
        elseif var == PickupVariant.PICKUP_LIL_BATTERY and subtype == 0 then
            if grng:RandomInt(10) == 0 then
                local kind = grng:RandomInt(4)
                if kind <= 1 then
                    return {id, PickupVariant.PICKUP_TAROTCARD, Card.STORAGE_BATTERY_2, seed}
                elseif kind == 2 then
                    return {id, PickupVariant.PICKUP_TAROTCARD, Card.STORAGE_BATTERY_1, seed}
                else
                    return {id, PickupVariant.PICKUP_TAROTCARD, Card.STORAGE_BATTERY_3, seed}
                end
            end
        elseif var == PickupVariant.PICKUP_HEART and subtype == 0 then
            local immoralchance = 0.005 -- About equivalent to black heart chance
			if mod:somePlayerHasImmoral() then
                immoralchance = 0.02
            end
			
            local morbidchance = 0.008 -- Little less than half of rotten heart chance
			if mod:somePlayerHasPostiche() then
                morbidchance = 0.03
            end

            if grng:RandomFloat() < immoralchance and mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() then
                return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_IMMORAL_HEART, 0, seed}
            elseif grng:RandomFloat() < morbidchance and mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() then
				return {EntityType.ENTITY_PICKUP, FiendFolio.PICKUP.VARIANT.MORBID_HEART, 0, seed}
			end

			if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_EVIL_STICKER) and mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() then
				local rand = grng:RandomInt(20)
				if rand == 0 then
					return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_IMMORAL_HEART, 0, seed}
				end
			end
        elseif var == PickupVariant.PICKUP_KEY and subtype == 0 then
            local wackeyness = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.TRINKET.WACKEY)
			local pickupChoice
			if wackeyness >= 3 then
				pickupChoice = "SpadesBest"
			elseif wackeyness >= 2 then
				pickupChoice = "SpadesBetter"
			elseif wackeyness > 0 then
				pickupChoice = "Spades"
			end
			if pickupChoice then
				local dynamicPool = {}
                for _, data in pairs(mod.UnbiasedPickups[pickupChoice]) do
                    if data.Unlocked() then
                        table.insert(dynamicPool, data.ID)
                    end
                end

                newSub = dynamicPool[grng:RandomInt(#dynamicPool) + 1]
				return {id, var, newSub}
			end
		elseif var == PickupVariant.PICKUP_TRINKET and subtype == FiendFolio.ITEM.ROCK.UNOBTAINIUM then
			return {id, var, FiendFolio.GetGolemTrinket()}
        elseif var == PickupVariant.PICKUP_BOMB and subtype == 0 then
            local chance = 0.01 -- About 1/10 the chance of a troll bomb
			local trinkyPower = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.TRINKET.FAULTY_FUSE)
			chance = chance + (0.4 * trinkyPower)
            if grng:RandomFloat() < chance then
                return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, FiendFolio.PICKUP.BOMB.COPPER, seed}
            end

			if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_EVIL_STICKER) then
				local rand = grng:RandomInt(10)
				if rand == 0 then
					return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, FiendFolio.PICKUP.BOMB.COPPER, seed}
				end
			end
		end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	local twinTuffsPower = 0
	local luck = 0
	local rng = grng
	mod.AnyPlayerDo(function(player)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.TWIN_TUFFS) then
			twinTuffsPower = twinTuffsPower + FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TWIN_TUFFS)
			luck = math.max(player.Luck, luck)
			rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TWIN_TUFFS)
			rng:SetSeed(pickup.InitSeed, 1)
		end
	end)

	if twinTuffsPower > 0 then
		local seedIndex = tostring(pickup.InitSeed)
		local TuffData = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'TwinTuffs', seedIndex, {})
		if not TuffData.TriedToRoll then
			--print(pickup.InitSeed)
			TuffData.TriedToRoll = true
			local baseChance = 0.25 * twinTuffsPower
			local luckChance = 0.025 * twinTuffsPower
			if rng:RandomFloat() < baseChance + luckChance * luck then
				local nvar, nsub = FiendFolio.GetTwinTuffsReplacement(pickup)
				if nvar then
					pickup:Morph(5, nvar, nsub, true, true)
				end
			end
		end
	end

	if pickup.Variant == 70 then
		local seedIndex = tostring(pickup.InitSeed)
		local CyanideData = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'CyanidePills', seedIndex, {})
		if mod.anyPlayerHas(FiendFolio.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE) and not pickup.SpawnerEntity then
			if not CyanideData.TriedToReplace then
				CyanideData.TriedToReplace = true
				if not mod.savedata.run.TryingToSpawnCyanide then
					if pickup.SubType == 14 or pickup.SubType == 961 then
						pickup:Morph(5, 70, 961, true, true)
					elseif pickup.SubType == 2062 or pickup.SubType == 3009 then
						pickup:Morph(5, 70, 3009, true, true)
					elseif pickup.SubType > 2048 then
						pickup:Morph(5, 70, 3008, true, true)
					else
						pickup:Morph(5, 70, 960, true, true)
					end
				end
			end
		else
			CyanideData.TriedToReplace = true
		end
	end
end)



--newage stop replacement
-- this function will be called anytime a room entity spawns
-- generally only do replacements here
-- because the ff persistence system depends on the callback being weird,
-- do persistence here too
local function PickupSpawnHelper(id, grindex, seed, randomIds, registry, variant)
    if id == 0 and randomIds then
        grng:SetSeed(seed + grindex, 0)
        id = randomIds[grng:RandomInt(#randomIds) + 1].softId
    end

    local item = registry[id]
    if item then
        return { EntityType.ENTITY_PICKUP, variant, item.id }
    end

    return {
        999,
        StageAPI.E.DeleteMeEffect.V,
        0
    }
end

function mod:roomInit(id, variant, subtype, gridindex, seed, stageAPIFirstLoad)
	local room = game:GetRoom()

	if mod.SetCurrentBackdrop and mod.SetCurrentBackdrop ~= game:GetLevel():GetCurrentRoomIndex() then
		mod.roomBackdrop = nil
		mod.roomBackdropFrom = nil
		mod.roomBackdropFromStageAPI = nil
		mod.roomBackdropFromLevel = nil
		mod.SetCurrentBackdrop = nil
	end

	if mod.ModeEnabled == 1 then
		--God help us all
		if id > 9 and id < 1000 then
			return {mod.FF.Mern.ID, mod.FF.Mern.Var, 0}
		end
	elseif mod.ModeEnabled == 2 then
		--Easy mode
		if id > 9 and id < 1000 then
			if game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then
				return {mod.FF.WoodburnerEasy.ID, mod.FF.WoodburnerEasy.Var, 0}
			end
		--[[elseif id == 1930 then
			return {1500, 0 ,0}]]
		elseif id == 9000 then
			return {5, 370, 0}
		elseif id > 999 then
			return {1494, 0, 0}
		end
	end

	if id == 15 and variant == mod.FF.Drumstick.Var then
		return mod.ENT("Drumstick")
	elseif id == 16 and variant == mod.FF.Facade.Var then
		return mod.ENT("Facade")
	elseif id == 21 then
		if variant == mod.FF.Nimbus.Var and subtype == 0 then
			return mod.ENT("Nimbus")
		elseif variant == mod.FF.RolyPoly.Var then
			return {mod.FF.RolyPoly.ID, mod.FF.RolyPoly.Var, subtype}
		end
		elseif id == mod.FF.Cistern.ID and variant == mod.FF.Cistern.Var and subtype == 0 then
		return mod.ENT("Cistern")

	elseif id == 25 then
        grng:SetSeed(seed, 0)
		local funvar = grng:RandomInt(5000)
        local odds = 1
        if mod.getField(FiendFolio.savedata, 'run', 'dadsdebt') == 99 then odds = odds * 2 end
        if mod.anyPlayerHas(TrinketType.TRINKET_SHINY_ROCK, true) then odds = odds * 2 end
		if funvar < odds then
			if variant == mod.FF.Mightfly.Var then
				return {mod.FF.GoldenMightfly.ID, mod.FF.GoldenMightfly.Var, 0}
			else
				return {mod.FF.GBF.ID, mod.FF.GBF.Var, 0}
			end
		elseif variant == 1 and grng:RandomInt(25) == 0 and mod.replacementsEnabled then
			return {mod.FF.Warhead.ID, mod.FF.Warhead.Var, 0}
		end

	elseif id == 27 then
		if variant < 2 and subtype == 0 then
			local level = game:GetLevel()
			local stage = level:GetStage()
			local stageType = level:GetStageType()
			grng:SetSeed(seed, 0)
			if grng:RandomInt(6) == 0 and mod.replacementsEnabled and (stage == 5 or stage == 6) and stageType == 2 then
				return mod.ENT("SludgeHost")
			end
			if variant == 1 or grng:RandomInt(10) == 0 then
				return {27, 1, 0}
			else
				return {27, 0, 0}
			end
		--Hostlet
		elseif variant == 0 and subtype == 250 then
			grng:SetSeed(seed, 0)
			if grng:RandomInt(10) == 0 and mod.legacyReplacementsEnabled then
				return {27, 1, 251}
			else
				return {27, 0, 250}
			end
		end

	elseif id == 29 and variant == 0 and not mod.legacyReplacementsEnabled then
		return {29, 0, subtype}
	elseif id == 29 and variant == 1 and not mod.legacyReplacementsEnabled then
		return {29, 1, subtype}
	elseif id == 29 and variant > 959 and variant < 970 then
		return {29, variant, subtype}

	--Boils
	elseif id == 30 and variant == 0 and not mod.legacyReplacementsEnabled then
		return {30, 0, 0}
	elseif id == 30 and variant == 1 and not mod.legacyReplacementsEnabled then
		return {30, 1, 0}
	elseif id == 30 and variant == 2 and not mod.legacyReplacementsEnabled then
		return {30, 2, 0}
	elseif id == 30 and variant == mod.FF.StickySack.Var then
		return mod.ENT("StickySack")

	elseif id == 31 and variant == 0 and not mod.legacyReplacementsEnabled then
		return {31, 0, 0}

	--Vis
	elseif id == 39 and variant == 0 and not mod.legacyReplacementsEnabled then
		return {39, 0, subtype}
	elseif id == 39 and variant == 1 and not mod.legacyReplacementsEnabled then
		return {39, 1, subtype}
	elseif id == 39 and variant == 2 and not mod.legacyReplacementsEnabled then
		return {39, 2, subtype}
	elseif id == 39 and variant == 3 and not mod.legacyReplacementsEnabled then
		return {39, 3, subtype}

	--The heck is this for?
	elseif id == 41 and variant == 0 and subtype == 7000 then
		return {41, 0, 7000}

	--Stone grimaces stay as stone grimaces
	elseif id == 42 and variant == 0 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {42, 0, 0}

	--Pokies don't become slides
	elseif id == 44 and variant == 0 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {44, 0, 0}

	--Dople
	elseif id == 53 and variant == 0 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {53, 0, 0}

	--Prevent spider entity FF variants from being replaced by striders
	elseif id == 85 and variant >= 960 and variant <= 965 then
		return {85, variant, subtype}

	--No keeper blisters
	elseif id == 86 and variant == 0 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {86, 0, 0}

	--Walking Sticky
	elseif id == mod.FF.WalkingStickySack.ID and (variant == mod.FF.WalkingStickySack.Var or variant == mod.FF.StumblingStickySack.Var) and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {mod.FF.WalkingStickySack.ID, variant, 0}

    elseif id == 90 and variant == 0 and subtype == 0 and mod.replacementsEnabled then
        grng:SetSeed(seed, 0)
        if grng:RandomInt(6) == 0 then
            return {610, 0, 0}
        end

	elseif id == 208 and variant == 0 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {208, 0, 0}
	elseif id == 208 and variant == 1 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {208, 1, 0}
	elseif id == 208 and variant == 2 and subtype == 0 and not mod.legacyReplacementsEnabled then
		return {208, 2, 0}

	elseif id == 208 and variant == 960 then
		return {208, 960, subtype}
	elseif id == 208 and variant == 961 then
		return {208, 961, subtype}
	elseif id == 208 and variant == 962 then
		return {208, 962, subtype}
	elseif id == 208 and variant == 963 then
		return {208, 963, subtype}
	--mr bones replacement test run
	elseif id == 227 and variant == 0 and stageType ~= 0 and grng:RandomInt(35) == 0 and mod.replacementsEnabled then
		return {227, 667, subtype}
	elseif id == 225 then
		grng:SetSeed(seed, 0)
		if grng:RandomInt(10) == 0 then
			return {225, 66, 0}
		end

	--Fuck the thing, fuck him bad, I hate him, if you like him, fuck you
	elseif id == 240 and not mod.legacyReplacementsEnabled then
		return {240, variant, subtype}
	elseif id == 241 and not mod.legacyReplacementsEnabled then
		return {241, variant, subtype}
	elseif id == 242 and not mod.legacyReplacementsEnabled then
		return {242, variant, subtype}

	--Ticking spiders no longer become blisters
	elseif id == 250 and not mod.legacyReplacementsEnabled then
        return {250, variant, subtype}

	elseif id == mod.FFID.Guwah then
		if variant == mod.FF.Dogrock.Var and grng:RandomInt(1000) == 0 and mod.replacementsEnabled then
			return {id, variant, 8521}
		end

	elseif id == 3001 and variant == 150 then
		mod.fuegoSpawners = mod.fuegoSpawners or {}
		table.insert(mod.fuegoSpawners, gridindex)
	elseif id == 825 and variant == 1000 then
		return {0,0,0}

    --Warble from morbus, commenting out since it might be borked
	--[[
    elseif id == 839 and variant == 22 then
        grng:SetSeed(seed, 0)
		local funvar = grng:RandomInt(5000)
		if funvar == 0 or (mod.anyPlayerHas(TrinketType.TRINKET_SHINY_ROCK, true) and funvar < 2) then
			return {mod.FF.GBF.ID, mod.FF.GBF.Var, 0}
        end
	]]

	elseif id == mod.FF.Fishface.ID and variant == mod.FF.Fishface.Var then
		grng:SetSeed(seed, 0)
		local funvar = grng:RandomInt(5000)
		if funvar == 0 or (mod.anyPlayerHas(TrinketType.TRINKET_SHINY_ROCK, true) and funvar < 2) then
			return mod.ENT("FishfaceShiny")
        end

    elseif id == 750 and variant == 118 then
        return PickupSpawnHelper(subtype, gridindex, seed,
                                 FiendFolio.Cards, FiendFolio.CardsBySoftID,
                                 PickupVariant.PICKUP_TAROTCARD)

    elseif id == 750 and variant == 119 then
        return PickupSpawnHelper(subtype, gridindex, seed,
                                 FiendFolio.GlassDice, FiendFolio.GlassDiceBySoftID,
                                 PickupVariant.PICKUP_TAROTCARD)

    -- PERSISTENT ENTITIES START HERE
    elseif id == mod.FF.Congression.ID and variant < 2 then
        table.insert(mod.persistentTable, {Type = id, Variant = variant, SubType = subtype, Position = room:GetGridPosition(gridindex)})

    elseif id == mod.FF.WombPillar.ID and variant == mod.FF.WombPillar.Var then
        table.insert(mod.persistentTable, {Type = id, Variant = variant, SubType = subtype, Position = room:GetGridPosition(gridindex)})

    elseif id == mod.FF.Onlooker.ID and variant == mod.FF.Onlooker.Var then -- Onlookers
        table.insert(mod.persistentTable, {Type = id, Variant = variant, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.DangerousDiscGuide.ID and variant == mod.FF.DangerousDiscGuide.Var then --Discy sawblades
		table.insert(mod.persistentTable, {Type = id, Variant = variant, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.Wailer.ID and variant == mod.FF.Wailer.Var then --Wailers
        table.insert(mod.persistentTable, {Type = id, Variant = variant, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.BackdropReplacer.ID and variant == mod.FF.BackdropReplacer.Var then
        mod.roomBackdrop = subtype
        mod.roomBackdropFrom = game:GetLevel():GetCurrentRoomDesc().ListIndex
		mod.roomBackdropFromStageAPI = StageAPI.GetCurrentRoom()
		mod.roomBackdropFromLevel = game:GetSeeds():GetStageSeed(game:GetLevel():GetStage())
		mod.SetCurrentBackdrop = game:GetLevel():GetCurrentRoomIndex()
	elseif id == mod.FF.RamblepointRed.ID and variant == mod.FF.RamblepointRed.Var then
        mod.ramblinPoints = mod.ramblinPoints or {}
		table.insert(mod.ramblinPoints, {point = subtype, colour = "red", pos = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.RamblepointBlue.ID and variant == mod.FF.RamblepointBlue.Var then
        mod.ramblinPoints = mod.ramblinPoints or {}
		table.insert(mod.ramblinPoints, {point = subtype, colour = "blue", pos = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.Smokin.ID and variant == mod.FF.Smokin.Var then	--Smokin
		table.insert(mod.persistentTable, {Type = mod.FF.Smokin.ID, Variant = mod.FF.Smokin.Var, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.Flamin.ID and variant == mod.FF.Flamin.Var then	--Flamin
		table.insert(mod.persistentTable, {Type = mod.FF.Flamin.ID, Variant = mod.FF.Flamin.Var, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.Grater.ID and variant == mod.FF.Grater.Var then	--Graters spawn grates when they're gone
		table.insert(mod.persistentTable, {Type = mod.FF.Graterhole.ID, Variant = mod.FF.Graterhole.Var, SubType = 0, Position = room:GetGridPosition(gridindex)})

	elseif id == mod.FF.Immural.ID and variant == mod.FF.Immural.Var then	--Dead immurals stay there
		table.insert(mod.persistentTable, {Type = mod.FF.Immural.ID, Variant = mod.FF.Immural.Var, SubType = mod.FF.ImmuralDead.Sub, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.SuperGrimace.ID and variant == mod.FF.SuperGrimace.Var then	--Super Grimaccce
		table.insert(mod.persistentTable, {Type = mod.FF.SuperGrimace.ID, Variant = mod.FF.SuperGrimace.Var, SubType = 0, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.PsionicPortal.ID and variant == mod.FF.PsionicPortal.Var and subtype == mod.FF.PsionicPortal.Sub then
		table.insert(mod.persistentTable, {Type = mod.FF.PsionicPortal.ID, Variant = mod.FF.PsionicPortal.Var, SubType = mod.FF.PsionicPortal.Sub, Position = room:GetGridPosition(gridindex)})
	elseif id == 1002 and variant == 0 then --Flipped Bucket replacement
		local grid = room:GetGridEntity(gridindex)
		if room:IsFirstVisit() then --Only do replacement if 1) The grid doesn't exist yet or 2) It does exist and isn't destroyed
			local backdrop = room:GetBackdropType()
			if backdrop == 31 or backdrop == 36 or backdrop == 45 then --Only replace on backdrops with Buckets
				grng:SetSeed(seed, 0)
				if grng:RandomFloat() <= 0.2 then
					FiendFolio.FlippedBucketGrid:Spawn(gridindex, true, false, nil) --"Replacement" is just spawning it directly
					return {1002,0,0}
				end
			end
		end
    elseif id == mod.FF.Thwammy.ID and variant == mod.FF.Thwammy.Var then --Thwammy
		table.insert(mod.persistentTable, {Type = mod.FF.Thwammy.ID, Variant = mod.FF.Thwammy.Var, SubType = 0, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.Grievance.ID and variant == mod.FF.Grievance.Var then --Grievance
		table.insert(mod.persistentTable, {Type = mod.FF.Grievance.ID, Variant = mod.FF.Grievance.Var, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.AmnioticSac.ID and variant == mod.FF.AmnioticSac.Var then --Amniotic Sacs
		table.insert(mod.persistentTable, {Type = mod.FF.AmnioticSac.ID, Variant = mod.FF.AmnioticSac.Var, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	elseif id == mod.FF.Miscarriage.ID and variant == mod.FF.Miscarriage.Var then --Miscarriage
		table.insert(mod.persistentTable, {Type = mod.FF.Miscarriage.ID, Variant = mod.FF.Miscarriage.Var, SubType = subtype, Position = room:GetGridPosition(gridindex)})
	end

	if (id == 1000 and subtype ~= 1) or (id == 1500 and subtype ~= 1) then
		local roomDesc = game:GetLevel():GetCurrentRoomDesc()
		local gridPos = room:GetGridPosition(gridindex)
		for slot = 0, 7 do
			if roomDesc.Data.Doors & StageAPI.DoorsBitwise[slot] ~= 0 then
				local doorPos = room:GetDoorSlotPosition(slot)
				local clampedPos = room:GetClampedPosition(doorPos, 20)
				local shouldBeNonReplaceable
				if clampedPos.X == doorPos.X then -- door is on bottom / top wall
					shouldBeNonReplaceable = math.abs(doorPos.X - gridPos.X) <= 40 and math.abs(doorPos.Y - gridPos.Y) <= 80
				else -- door is on left / right wall
					shouldBeNonReplaceable = math.abs(doorPos.Y - gridPos.Y) <= 40 and math.abs(doorPos.X - gridPos.X) <= 80
				end

				if shouldBeNonReplaceable then
					return {id, 0, 1}
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.roomInit)
if StageAPI then
    -- stageapi only calls pre spawn entity the first time a room is populated,
    -- vs pre_room_entity_spawn that may happen many times
    StageAPI.AddCallback("FiendFolio", "PRE_SPAWN_ENTITY", 100, function(entityInfo, list, gridIndex)
        local curRoom = StageAPI.GetCurrentRoom()
        return mod:roomInit(entityInfo.Data.Type, entityInfo.Data.Variant, entityInfo.Data.SubType, gridIndex, game:GetRoom():GetSpawnSeed(), curRoom and curRoom.FirstLoad)
    end)
end

function mod:preEntSpawn(etype, evar, esub, pos, vel, spawner, seed)
	local room = game:GetRoom()
	grng:SetSeed(seed, 0)
	if mod:entIs(spawner, mod.FF.FiendMom.ID, mod.FF.FiendMom.Var, mod.FF.FiendMom.Sub) then
		if etype == 10 then
			--Fiend mom gaper replacements
			local rand = grng:RandomInt(4)
			if rand == 0 then
				return mod.ENT("Woodburner", seed)	--Woodburner
			elseif rand == 1 then
				return mod.ENT("Haunted", seed)	--Haunted
			else
				return mod.ENT("Slammer", seed)	--Slammer
			end
		elseif etype == 11 then
			--Fiend mom pacer replacements
			if grng:RandomInt(2) == 0 then
				return {mod.FF.Spoop.ID, mod.FF.Spoop.Var, 3, seed}
			else
				return mod.ENT("Smidgen", seed)
			end
		elseif etype == 12 then
			--Fiend mom horf replacements
			if grng:RandomInt(2) == 0 then
				return mod.ENT("Spitum", seed)	--Spitum
			else
				return mod.ENT("Flare", seed)	--Mr. Flare
			end
		elseif etype == 14 then
			--Fiend mom pooter replacements
			local rand = grng:RandomInt(3)
			if rand == 0 then
				return mod.ENT("SuperSpooter", seed)	--Super Spooter
			else
				return mod.ENT("Spooter", seed)	--Spooter
			end
		elseif etype == 15 then
			--Fiend mom clot replacements
			local rand = grng:RandomInt(2)
			if rand == 0 then
				return mod.ENT("Dung", seed)	
			else
				return mod.ENT("Benign", seed)	
			end
		elseif etype == 16 then
			--Fiend mom mulligan replacements
			local rand = grng:RandomInt(2)
			if rand == 0 then
				return mod.ENT("Sackboy", seed)	--Sackboy
			else
				return mod.ENT("Pitcher", seed)	--Pitcher
			end

		elseif etype == 18 then
			--Fiend mom fly replacements
			local rand = grng:RandomInt(4)
			if rand == 0 then
				return mod.ENT("Beeter", seed)	--Beeter
			elseif rand == 1 then
				return mod.ENT("MilkTooth", seed)	--Milk Tooth
			else
				return mod.ENT("ShotFly", seed)	--Wimpy
			end
		elseif etype == 21 then
			--Fiend mom maggot replacements
			local rand = grng:RandomInt(3)
			if rand == 0 then
				return mod.ENT("Morsel3", seed)	--3 Morsels
			else
				return mod.ENT("Morsel2", seed)	--2 Morsels
			end
		elseif etype == 23 then
			--Fiend mom charger replacements
			return mod.ENT("RolyPoly", seed)
		elseif etype == 24 then
			--Fiend mom globin replacements
			local rand = grng:RandomInt(4)
			if rand == 0 then
				return mod.ENT("Mothman", seed) --Mothman	
			elseif rand == 1 then
				return mod.ENT("Dweller", seed)	--Dweller
			else
				return mod.ENT("Nimbus", seed)	--Nimbus
			end
		elseif etype == 26 then
			--Fiend mom maw replacements
			local rand = grng:RandomInt(2)
			if rand == 0 then
				return mod.ENT("Gunk", seed)	
			else
				return mod.ENT("Scoop", seed)	
			end
		end

	--other replacements
	elseif etype == 23 and evar == 0 then
		if mod:entIs(spawner, EntityType.ENTITY_FISTULA_SMALL, 0, 2) then  -- Beehive Fistula
			return {mod.FF.Stingler.ID, mod.FF.Stingler.Var, mod.FF.Stingler.Sub, seed}
		end
	elseif etype == 30 and evar == 2 then
		if mod:entIs(spawner, mod.FF.BabyWidowChampion.ID, mod.FF.BabyWidowChampion.Var, mod.FF.BabyWidowChampion.Sub) then
			return {mod.FF.StickySack.ID, mod.FF.StickySack.Var, 0, seed}
		end
	--[[elseif etype == 17 then
		local rand = grng:RandomInt(10)
		if rand == 0 then
			return {17, 700, 0, seed}	--Fiend Folio Shopkeepers
		end]]
	elseif etype == 85 and evar == 0 then
		if mod:entIs(spawner, mod.FF.BabyWidowChampion.ID, mod.FF.BabyWidowChampion.Var, mod.FF.BabyWidowChampion.Sub) then
			return mod.ENT("Spooter", seed)
		elseif mod:entIs(spawner, mod.FF.Sackboy.ID, mod.FF.Sackboy.Var) then
			local s = spawner
			for _, e in pairs(Isaac.FindByType(spawner.Type, spawner.Variant, spawner.SubType, false, false)) do
				if e.Index == spawner.Index then s = e end
			end
			if s:GetData().babyreplace then
				return mod.ENT("BabySpider", seed)
			end
		end
	--[[elseif etype == 208 then
		StageAPI.ChangeRoomGfx(mod.HiveBackdrop)]]
	--[[elseif etype == 1000 then
		if evar == 38 then
			if mod:entIs(spawner, 85, 962) then
				return {1000, 38, 7000, seed}
			end
		end]]
	--[[elseif etype == 1000 and evar == 1 then
		print("explosion spawning")
		for _, t in pairs(Isaac.FindInRadius(pos, 5, 0xffffffff)) do
			print("an entity is in range")
			if t.Type == 292 and t.Variant == 751 then
				print("entity is a water tnt")
				return {1000, 0, 0, seed}
			end
		end]]
	elseif mod:entIs(spawner, 19, 0, 3) then
		if etype == 1500 then
			return {9, 0, 0, seed}
		end
	elseif spawner and spawner.Type == 239 and spawner.Variant == 750 then
		if etype ~= 9 and etype ~= 239 and evar ~= 15 then
			return {1000, 88, 0, seed}
		end
	end

    -- Oh woah dude portal spawn replacements, doing it after everything else because it's probably best this way
    if etype ~= 1000 and spawner and spawner.Type == 306 and spawner.Variant == 0 then
	    local backdrop = game:GetRoom():GetBackdropType()
	    if game.Difficulty == Difficulty.DIFFICULTY_GREED or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
	    	local rand = grng:RandomInt(3)
	    	if (rand == 2 or rand == 1) then
	    		local lvl = mod.greedportalreplacement[game:GetLevel():GetStage()]
	    		local guy = lvl[math.random(#lvl)]
	    		return {guy[1] or 0, guy[2] or 0, guy[3] or 0, seed}
	    	end
	    elseif mod.portalreplacement[backdrop] and grng:RandomInt(3) == 1 and not (StageAPI and StageAPI.InNewStage()) then
	    	local floor = mod.portalreplacement[backdrop]
	    	if grng:RandomInt(750) == 1 then
	    		--fish rarity
	    		floor = mod.portalreplacement[666]
            elseif grng:RandomInt(1500) == 1 then
                local stage = game:GetLevel():GetStage()
                if stage >= 5 then
                    floor = mod.portalreplacement[667]
                    local _, portal = FiendFolio.findKey(Isaac.FindByType(306, -1, -1, false, false), function(val)
                        return val.Index == spawner.Index
                    end)
                    portal:Die()
                end
            end
	    	local ent = floor[math.random(#floor)]
	    	return {ent[1] or 0, ent[2] or 0, ent[3] or 0, seed}
        end
    elseif etype ~= 1000 and spawner and spawner.Type == 306 and spawner.Variant == 1 then
	    if grng:RandomInt(4) == 1 then
			local spawnType = mod.lilportalreplacement[1]
			if spawner.SubType == 1 then
				spawnType = mod.lilportalreplacement[2]
			end
			if grng:RandomInt(100) == 1 and spawner.SubType == 0 then -- Full Spider
				spawnType = mod.lilportalreplacement[3]
			end
			local ent = spawnType[grng:RandomInt(#spawnType)+1]
	    	return {ent[1] or 0, ent[2] or 0, ent[3] or 0, seed}
        end
    end

	if etype == 5 and evar == 100 and esub == CollectibleType.COLLECTIBLE_SMALL_ROCK then
		local grident = room:GetGridEntityFromPos(pos)
		if grident and grident.Desc.Type == 4 then
			local backdropType = room:GetBackdropType()
			if mod.WoodenBackdrops[backdropType] then
				return {5, 100, CollectibleType.COLLECTIBLE_SMALL_WOOD, seed}
			elseif mod.PipeBackdrops[backdropType] or (mod.roomBackdrop and mod.roomBackdrop == 3) then
				return {5, 100, CollectibleType.COLLECTIBLE_SMALL_PIPE, seed}
			end
		end
	end

	if GuwahGreatures then --Turn GG enemies into their FF versions
		if etype == 15 and evar == 51 then
			return {mod.FF.Drumstick.ID, mod.FF.Drumstick.Var, esub, seed}
		elseif etype == 240 and evar == 51 then
			return {mod.FF.ArcaneCreep.ID, mod.FF.ArcaneCreep.Var, esub, seed}
		elseif etype == 551 then
			if evar == 1 and esub <= 1 then
				return {mod.FF.Chunky.ID, mod.FF.Chunky.Var, esub, seed}
			elseif evar == 5 then
				return {mod.FF.Potluck.ID, mod.FF.Potluck.Var, esub, seed}
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN , mod.preEntSpawn)

-- Grid Random Replacements
local gridReplacementRNG = RNG()
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local room = game:GetRoom()
    local currentRoom = StageAPI.GetCurrentRoom()
    if room:IsFirstVisit() and (not currentRoom or currentRoom.VisitCount == 1) then
		gridReplacementRNG:SetSeed(room:GetSpawnSeed(), 0) -- grid rng is broken for reward plates, so lets just do this
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
			if grid and not StageAPI.IsCustomGrid(i) then
				if grid.Desc.Type == GridEntityType.GRID_POOP and grid.Desc.Variant == StageAPI.PoopVariant.Golden then
					if gridReplacementRNG:RandomFloat() <= 0.02 then
						FiendFolio.PlatinumPoopGrid:Spawn(i, false, true)
					end
				elseif grid.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE and grid.Desc.Variant == 1 and FiendFolio.ACHIEVEMENT.GOLDEN_REWARD_PLATE:IsUnlocked() then -- reward plate
					if gridReplacementRNG:RandomFloat() <= 0.01 then
						FiendFolio.GoldenRewardPlateGrid:Spawn(i, false, true)
					end
				end
			end
        end
    end
end)

-- CARDS!!!
mod.StupidRareCards = {
	[mod.ITEM.CARD.DOWNLOAD_FAILURE] = true,
	[mod.ITEM.CARD.BROKEN_DISC] = true,
}

mod.NoNaturalSpawnCards = {
	[mod.ITEM.CARD.REVERSE_KING_OF_CLUBS] = true,
	[mod.ITEM.CARD.SMALL_CONTRABAND] = true,
	[mod.ITEM.CARD.COOL_PHOTO] = true,
    [mod.ITEM.CARD.STORAGE_BATTERY_3] = true,
    [mod.ITEM.CARD.CORRODED_BATTERY_0] = true,
    [mod.ITEM.CARD.CORRODED_BATTERY_1] = true,
    [mod.ITEM.CARD.CORRODED_BATTERY_2] = true,
    [mod.ITEM.CARD.CORRODED_BATTERY_3] = true,
	[mod.ITEM.CARD.HORSE_PUSHPOP] = true,
	-- disabled for 2.1.2 release
    [mod.ITEM.CARD.TRAINER_CARD] = true,
}

mod.BumpedOddsCards = {
    [mod.ITEM.CARD.PLUS_3_FIREBALLS] 	= 15,		-- n = how many rolls are allowed to get this card
    [mod.ITEM.CARD.IMPLOSION] 			= 15,		-- The function will roll as many times as the greatest n
    [mod.ITEM.CARD.CALLING_CARD] 		= 15,
    [mod.ITEM.CARD.GROTTO_BEAST] 		= 15,
    [mod.ITEM.CARD.PLAGUE_OF_DECAY] 	= 15,
    [mod.ITEM.CARD.DEFUSE] 				= 15,
    [mod.ITEM.CARD.POT_OF_GREED] 		= 15,
    [mod.ITEM.CARD.SKIP_CARD] 			= 15,
    [mod.ITEM.CARD.CARDJITSU_SOCCER] 	= 15,
    [mod.ITEM.CARD.CARDJITSU_FLOORING_UPGRADE] = 15,
    [mod.ITEM.CARD.CARDJITSU_AC_3000] 	= 15,
    [mod.ITEM.CARD.GIFT_CARD] 	= 15,
}

local maxBumpAttempts = 0
for _, value in pairs(mod.BumpedOddsCards) do if value > maxBumpAttempts then maxBumpAttempts = value end end

mod.MinorArcanaKingCards = {
	[FiendFolio.ITEM.CARD.KING_OF_CUPS] = true,
	[FiendFolio.ITEM.CARD.KING_OF_PENTACLES] = true,
	[FiendFolio.ITEM.CARD.KING_OF_WANDS] = true,
	[FiendFolio.ITEM.CARD.KING_OF_SWORDS] = true,
}

mod.PlayingKingCards = {
	[FiendFolio.ITEM.CARD.KING_OF_DIAMONDS] = true,
	[FiendFolio.ITEM.CARD.KING_OF_SPADES] = true,
	[FiendFolio.ITEM.CARD.KING_OF_CLUBS] = true,
	[FiendFolio.ITEM.CARD.REVERSE_KING_OF_CLUBS] = true,
}

mod.MinorArcanaQueenCards = {}

mod.PlayingQueenCards = {
	[FiendFolio.ITEM.CARD.QUEEN_OF_CLUBS] = true,
	[FiendFolio.ITEM.CARD.QUEEN_OF_DIAMONDS] = true,
	[FiendFolio.ITEM.CARD.QUEEN_OF_SPADES] = true,
}

--These don't exist
mod.MinorArcanaJackCards = {}

mod.PlayingJackCards = {
	[FiendFolio.ITEM.CARD.JACK_OF_CLUBS] = true,
	[FiendFolio.ITEM.CARD.MISPRINTED_JACK_OF_CLUBS] = true,
	[FiendFolio.ITEM.CARD.JACK_OF_DIAMONDS] = true,
	[FiendFolio.ITEM.CARD.JACK_OF_SPADES] = true,
	[FiendFolio.ITEM.CARD.JACK_OF_HEARTS] = true,
}

mod.MinorArcanaTwoCards = {
	[FiendFolio.ITEM.CARD.TWO_OF_PENTACLES] = true,
	[FiendFolio.ITEM.CARD.TWO_OF_SWORDS] = true,
	[FiendFolio.ITEM.CARD.TWO_OF_WANDS] = true,
	[FiendFolio.ITEM.CARD.TWO_OF_CUPS] = true,
}

mod.MinorArcanaThreeCards = {
	[FiendFolio.ITEM.CARD.THREE_OF_CUPS] = true,
	[FiendFolio.ITEM.CARD.THREE_OF_PENTACLES] = true,
	[FiendFolio.ITEM.CARD.THREE_OF_SWORDS] = true,
	[FiendFolio.ITEM.CARD.THREE_OF_WANDS] = true,
}
mod.PlayingThreeCards = {
	[FiendFolio.ITEM.CARD.THREE_OF_CLUBS] = true,
	[FiendFolio.ITEM.CARD.THREE_OF_SPADES] = true,
	[FiendFolio.ITEM.CARD.THREE_OF_DIAMONDS] = true,
	[FiendFolio.ITEM.CARD.THREE_OF_HEARTS] = true,
}

function FiendFolio.NoCardNaturalSpawn(card, rng)
	if mod.NoNaturalSpawnCards[card] then
		return true
	end

	if not FiendFolio.CardsEnabled and mod.CardsByID[card] then
		return true
	end

	if FiendFolio.CardConfig.ArcanaKingCardsDisabled and mod.MinorArcanaKingCards[card] then
		return true
	end

	if FiendFolio.CardConfig.PlayingKingCardsDisabled and mod.PlayingKingCards[card] then
		return true
	end

	if FiendFolio.CardConfig.ArcanaQueenCardsDisabled and mod.MinorArcanaQueenCards[card] then
		return true
	end

	if FiendFolio.CardConfig.PlayingQueenCardsDisabled and mod.PlayingQueenCards[card] then
		return true
	end

	if FiendFolio.CardConfig.ArcanaJackCardsDisabled and mod.MinorArcanaJackCards[card] then
		return true
	end

	if FiendFolio.CardConfig.PlayingJackCardsDisabled and mod.PlayingJackCards[card] then
		return true
	end

	if FiendFolio.CardConfig.ArcanaTwoCardsDisabled and mod.MinorArcanaTwoCards[card] then
		return true
	end

	if FiendFolio.CardConfig.ArcanaThreeCardsDisabled and mod.MinorArcanaThreeCards[card] then
		return true
	end

	if FiendFolio.CardConfig.PlayingThreeCardsDisabled and mod.PlayingThreeCards[card] then
		return true
	end

	if card == mod.ITEM.CARD.SKIP_CARD and game.Challenge > 0 then
		return true
	end

	if card == mod.ITEM.CARD.TAINTED_TREASURE_DISC and not TaintedCollectibles then
		return true
	end

	if rng then
		if mod.StupidRareCards[card] and rng:RandomFloat() < 0.5 then
			return true
		end

		if card == mod.ITEM.CARD.RUNE_ANSUS and rng:RandomFloat() > 1/1000000 then
			return true
		end
	end

	return FiendFolio.IsCardLocked(card)
end

local skipGetCard
local getCardRNG
function mod:CardReplacement(_, card, canSuit, canRune, onlyRune)
	if not getCardRNG then
		mod.savedata.cardRngSeed = mod.savedata.cardRngSeed or game:GetSeeds():GetStartSeed()
		getCardRNG = RNG()
		getCardRNG:SetSeed(mod.savedata.cardRngSeed, 35)
	end

	if not skipGetCard then
		local returnValue = card
		local itempool = game:GetItemPool()
		skipGetCard = true

		local forceReroll = FiendFolio.NoCardNaturalSpawn(card, getCardRNG)

		if canRune and not onlyRune then -- Objects allowed to spawn
			local persistentData = mod.GetPersistentPlayerData(Isaac.GetPlayer())
			if persistentData.puzzleFortunes then -- Increase puzzle piece odds if one has already been used
				local pieceSpawn
				local spawnChance = 0
				local jigsawBoxMultiplier = mod.GetGlobalTrinketMultiplier(mod.ITEM.TRINKET.JIGSAW_PUZZLE_BOX)
				persistentData.puzzleSpawns = persistentData.puzzleSpawns or {}

				if persistentData.puzzleFortunes[2] and not persistentData.puzzleSpawns[2] then
					pieceSpawn = 2
					spawnChance = 0.85 + 0.05 * jigsawBoxMultiplier
				elseif persistentData.puzzleFortunes[1] and not persistentData.puzzleSpawns[1] then
					pieceSpawn = 1
					spawnChance = 0.40 + 0.20 * jigsawBoxMultiplier
				end

				if getCardRNG:RandomFloat() < spawnChance then
					persistentData.puzzleSpawns[pieceSpawn] = true
					returnValue = mod.ITEM.CARD.PUZZLE_PIECE
					goto getCardEnd
				end
			end

			if not mod.PocketObjects[card] then -- Increase drop rates of Object type cards
				for i = 1, 10 do
					local new = itempool:GetCard(getCardRNG:Next(), canSuit, canRune, onlyRune)
					if mod.PocketObjects[new] and not FiendFolio.NoCardNaturalSpawn(new, getCardRNG) then
						returnValue = new
						goto getCardEnd
					end
				end
			end
		end

		if canSuit and not mod.BumpedOddsCards[currentCard] then
			for i = 1, maxBumpAttempts do
				local new = itempool:GetCard(getCardRNG:Next(), canSuit, canRune, onlyRune)
				if mod.BumpedOddsCards[new] and i <= mod.BumpedOddsCards[new] and not FiendFolio.NoCardNaturalSpawn(new, getCardRNG) then
					returnValue = new
					goto getCardEnd
				end
			end
		end

		if forceReroll then
			local new
			local i = 0

			repeat
				new = itempool:GetCard(getCardRNG:Next(), canSuit, canRune, onlyRune)
				i = i + 1
			until not FiendFolio.NoCardNaturalSpawn(new, getCardRNG)

			returnValue = new
		end

		::getCardEnd::
		skipGetCard = false
		mod.savedata.cardRngSeed = getCardRNG:GetSeed()
		if returnValue == card then
			-- We didn't change the spawned card. Return nil to avoid stepping the toes of other mods trying to do card replacements.
			return nil
		end
		return returnValue
	end
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.CardReplacement)

-- Booster Pack doesn't trigger MC_GET_CARD, so we have to handle that seperately.

-- The last frame we detected a player obtaining a new copy of Booster Pack.
local boosterPackDetectedAt = 0

-- Detect when a player obtains a new copy of Booster Pack.
function mod:TrackBoosterPacks(player)
	local data = player:GetData()

	local prev = data.ffBoosterPackCount or 0
	local new = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BOOSTER_PACK, true)

	if new > prev then
		boosterPackDetectedAt = game:GetFrameCount()
	end

	data.ffBoosterPackCount = new
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.TrackBoosterPacks)

-- Anti-recursion bit.
local fixingBoosterPackSpawn = false

-- On pickup init, if any player was detected obtaining a new copy of Booster Pack within the last frame, check if the card should be replaced.
-- Normally replacements are done on MC_GET_CARD. Booster Pack is the only exception, because it doesn't trigger that callback for some reason.
function mod:CheckBoosterPackSpawn(pickup)
	if fixingBoosterPackSpawn then return end

	-- The card spawns from Booster Pack can occur prior to us detecting the Booster Pack in MC_POST_PEFFECT_UPDATE.
	-- So check all the players here, too.
	for i=0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(i)
		if player and player:Exists() then 
			mod:TrackBoosterPacks(player)
		end
	end

	if game:GetFrameCount() - boosterPackDetectedAt <= 1 then
		-- This is probably a Booster Pack spawn.
		local replacement = mod:CardReplacement(nil, pickup.SubType, true, false, false)
		if replacement then
			fixingBoosterPackSpawn = true
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, replacement, true, true, false)
			fixingBoosterPackSpawn = false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.CheckBoosterPackSpawn, PickupVariant.PICKUP_TAROTCARD)

-- Old MC_GET_CARD logic
--[[
local skipFFGetCard = false
mod:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, currentCard, playing, runes, onlyRunes)
    local pool = game:GetItemPool()

    local shouldReroll = mod.NoNaturalSpawnCards[currentCard]
    if mod.StupidRareCards[currentCard] then
        shouldReroll = shouldReroll or rng:RandomInt(2) == 0
    end

    if currentCard == mod.ITEM.CARD.RUNE_ANSUS then
        shouldReroll = shouldReroll or rng:RandomInt(100000) > 0
    end

    if shouldReroll then
        return pool:GetCard(rng:Next(), playing, runes, onlyRunes)
    end

	if skipFFGetCard then return end

    if runes and not onlyRunes then -- is a random object spawn, incl. non-card objects, but not exclusively runes

        -- Increase likelihood of puzzle piece spawning if player has already used one or two. Should probably be fixed up for multiplayer.
        local player = Isaac.GetPlayer(0)
    	local savedata = Isaac.GetPlayer():GetData().ffsavedata
    	savedata.puzzleSpawns = savedata.puzzleSpawns or {}
    	if savedata and savedata.puzzleFortunes then
            local pieceSpawn
            local chanceToSpawn
    		if savedata.puzzleFortunes[2] and not savedata.puzzleSpawns[2] then
    			pieceSpawn = 2
    			if player:HasTrinket(TrinketType.TRINKET_JIGSAW_PUZZLE_BOX) then
                    chanceToSpawn = 92
    			else
                    chanceToSpawn = 85
    			end
    		elseif savedata.puzzleFortunes[1] and not savedata.puzzleSpawns[1] then
                pieceSpawn = 1
                if player:HasTrinket(TrinketType.TRINKET_JIGSAW_PUZZLE_BOX) then
                    chanceToSpawn = 60
                else
                    chanceToSpawn = 40
                end
    		end

            if chanceToSpawn and rng:RandomInt(100) <= chanceToSpawn then
                savedata.puzzleSpawns[pieceSpawn] = true
                return Card.PUZZLE_PIECE
            end
    	end
    end

    if playing and not mod.BumpedOddsCards[currentCard] then
        local rerollCount = 4
        for i = 1, rerollCount do
            skipFFGetCard = true
            local newCard = pool:GetCard(rng:Next(), playing, runes, onlyRunes)
            skipFFGetCard = false
            if mod.BumpedOddsCards[newCard] then
                return newCard
            end
        end
    end
end)]]


--[[
mod:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, currentCard, playing, runes, onlyRunes)
	if mod.isTarot[currentCard] then
		local odds = rng:RandomInt(55 + #mod.FolioCards)
		if odds <= #mod.FolioCards then
			local friendlymonCardChance = 2 --Could probably be 1? Doesn't hurt tho
			local rand = rng:RandomInt(#mod.FolioCards + friendlymonCardChance)+1
			odds = rng:RandomInt(300) -- chance for download failure/stupid rare cards
			if odds <= 3 then
				local rand = rng:RandomInt(#mod.StupidRareCards) + 1
				return mod.StupidRareCards[rand]
			else
				if rand > #mod.FolioCards then
					--Spawn a pokemon card
					return Card.ENERGY_GRASS + rng:RandomInt(11)
				else
					return mod.FolioCards[rand]
				end
			end
		end
	--[[elseif mod.isPlayingCard[currentCard] or mod.isPlayingCardRare[currentCard] then
		local numPlayingCards = 10
		local odds = rng:RandomInt(numPlayingCards + #mod.ReplacePlayingCards)
		if odds > numPlayingCards then
			local rand = rng:RandomInt(#mod.ReplacePlayingCards) + 1
			return mod.ReplacePlayingCards[rand]
		end]]
	--[[elseif onlyRunes then
		print("check1")
		if mod.isRuneSoul[currentCard] then
			print("check2")
			local numDefaultSouls = 17
			local odds = rng:RandomInt(numDefaultSouls + #mod.FolioSouls) + 1
			if odds > numDefaultSouls then
				return mod.FolioSouls[odds - numDefaultSouls]
			end
		end
	elseif mod.isNotNatural[currentCard] then
		return mod.FolioCards[rng:RandomInt(#mod.FolioCards)+1]
	elseif onlyRunes then
		if currentCard == Card.RUNE_ANSUS then
			return Card.RUNE_SHARD
		else
			local odds = rng:RandomInt(3000)
			if odds == 1 then
				return Card.RUNE_ANSUS
			end
		end
    end
end)

-- puzzle piece Card Spawn
function mod:getCard(rng,current,playing,runes,onlyrunes)

end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.getCard);]]
