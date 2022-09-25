local mod = FiendFolio
local game = Game()

local customPoolConstituents = {}
mod.CustomPool = {}

mod.CustomItemPoolType = {
	COLLECTIBLE = 0,
	TRINKET = 1,
	MIXED = 2,

	-- To-do:
	--[[
		COLLECTIBLE_WEIGHTED
		TRINKET_WEIGHTED
		MIXED_WEIGHTED
	]]
}

function mod.IsVanillaCollectibleUnlocked(id)
	local itemConfig = Isaac.GetItemConfig()
	local configItem = itemConfig:GetCollectible(id)
	local hasAchievement = configItem.AchievementID >= 0

	if not hasAchievement then return true end

	-- Oh BOY here we FUCKING go (Credit to Wofsauge)
	local numItems = itemConfig:GetCollectibles().Size - 1
	local itempool = game:GetItemPool()

	for i = 1, numItems do
		if ItemConfig.Config.IsValidCollectible(i) and i ~= id then
			itempool:AddRoomBlacklist(i)
		end
	end

	local foundItem = false
	for pool = ItemPoolType.POOL_TREASURE, ItemPoolType.POOL_ROTTEN_BEGGAR do
		for i = 1, 10 do
			local item = itempool:GetCollectible(pool, false)
			if item == id then
				foundItem = true
				break
			end
		end

		if foundItem then break end
	end

	itempool:ResetRoomBlacklist()
	return foundItem
end

local function GameHasPlayerType(playerType)
	for _, player in pairs(Isaac.FindByType(1)) do
		if player:ToPlayer():GetPlayerType() == playerType then
			return true
		end
	end
end

function mod.DoesCollectibleViolateTagRules(id)
	local itemConfig = Isaac.GetItemConfig()
	local configItem = itemConfig:GetCollectible(id)

	if GameHasPlayerType(PlayerType.PLAYER_THELOST_B) and not configItem:HasTags(ItemConfig.TAG_OFFENSIVE) then
		return true
	end

	local gameHasLostWithBirthright = false
	for _, player in pairs(Isaac.FindByType(1)) do
		local player = player:ToPlayer()
		if player:GetPlayerType() == PlayerType.PLAYER_THELOST and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			gameHasLostWithBirthright = true
		end
	end

	local illegalTags = 0
	if game.Difficulty >= Difficulty.DIFFICULTY_GREED then illegalTags = illegalTags | ItemConfig.TAG_NO_GREED end
	if GameHasPlayerType(PlayerType.PLAYER_KEEPER) or GameHasPlayerType(PlayerType.PLAYER_KEEPER_B) then illegalTags = illegalTags | ItemConfig.TAG_NO_KEEPER end
	if gameHasLostWithBirthright then illegalTags = illegalTags | ItemConfig.TAG_NO_LOST_BR end
	if game.Challenge == Challenge.CHALLENGE_CANTRIPPED then illegalTags = illegalTags | ItemConfig.TAG_NO_CANTRIP end
	if game.Challenge ~= 0 then illegalTags = illegalTags | ItemConfig.TAG_NO_CHALLENGE end

	return illegalTags & configItem.Tags > 0
end

function mod.RegisterCustomItemPool(identifier, poolType, poolConstituents)
	local activeKey = "Active" .. identifier

	mod.CustomPool[identifier] = {activeKey, poolType}
	mod[activeKey] = mod[activeKey] or {}
	customPoolConstituents[activeKey] = poolConstituents
end

function mod.ResetEmptiedCustomItemPool(activePoolName, poolType, firstBuild)
	mod[activePoolName] = {}

	if poolType == mod.CustomItemPoolType.MIXED then
		for _, part in pairs(customPoolConstituents[activePoolName].Collectibles) do
			for _, item in pairs(mod[part]) do
				if not mod.IsCollectibleLocked(item) then
					table.insert(mod[activePoolName], {PickupVariant.PICKUP_COLLECTIBLE, item})
				end
			end
		end

		for _, part in pairs(customPoolConstituents[activePoolName].Trinkets) do
			for _, item in pairs(mod[part]) do
				if not mod.IsTrinketLocked(item) then
					table.insert(mod[activePoolName], {PickupVariant.PICKUP_TRINKET, item})
				end
			end
		end
	else
		for _, part in pairs(customPoolConstituents[activePoolName]) do
			for _, item in pairs(mod[part]) do
				local pass = true
				if poolType == mod.CustomItemPoolType.COLLECTIBLE then
					if mod.IsCollectibleLocked(item) then
						pass = false
					end
				elseif poolType == mod.CustomItemPoolType.TRINKET then
					if mod.IsTrinketLocked(item) then
						pass = false
					end
				end

				if pass then
					table.insert(mod[activePoolName], item)
				end
			end
		end
	end

	mod.savedata[activePoolName .. "Recycled"] = not firstBuild
end

function mod.BuildCustomItemPools()
	for _, data in pairs(mod.CustomPool) do
		local activePoolName = data[1]
		local poolType = data[2]

		mod.ResetEmptiedCustomItemPool(activePoolName, poolType, true)
		if #mod[activePoolName] == 0 then
			mod.ResetEmptiedCustomItemPool(activePoolName, poolType, false)
		end
	end
end

function mod.RemoveItemFromCustomItemPools(item)
	for _, data in pairs(mod.CustomPool) do
		local activePoolName = data[1]
		local poolType = data[2]

		if poolType == mod.CustomItemPoolType.COLLECTIBLE then
			for i = #mod[activePoolName], 1, -1 do
				if mod[activePoolName][i] == item then
					table.remove(mod[activePoolName], i)
				end
			end
		elseif poolType == mod.CustomItemPoolType.MIXED then
			for i = #mod[activePoolName], 1, -1 do
				if mod[activePoolName][i][1] == PickupVariant.PICKUP_COLLECTIBLE and mod[activePoolName][i][2] == item then
					table.remove(mod[activePoolName], i)
				end
			end
		end

		if #mod[activePoolName] == 0 then
			mod.ResetEmptiedCustomItemPool(activePoolName, poolType, false)
		end
	end
end

function mod.RemoveTrinketFromCustomItemPools(trinket)
	for _, data in pairs(mod.CustomPool) do
		local activePoolName = data[1]
		local poolType = data[2]

		if poolType == mod.CustomItemPoolType.TRINKET then
			for i = #mod[activePoolName], 1, -1 do
				if mod[activePoolName][i] == trinket then
					table.remove(mod[activePoolName], i)
				end
			end
		elseif poolType == mod.CustomItemPoolType.MIXED then
			for i = #mod[activePoolName], 1, -1 do
				if mod[activePoolName][i][1] == PickupVariant.PICKUP_TRINKET and mod[activePoolName][i][2] == trinket then
					table.remove(mod[activePoolName], i)
				end
			end
		end

		if #mod[activePoolName] == 0 then
			mod.ResetEmptiedCustomItemPool(activePoolName, poolType, false)
		end
	end
end

local function isCollectibleValid(id, ignoreModifiers, someoneHasNo, poolRecycled)
	local itempool = game:GetItemPool()
	local itemConfig = Isaac.GetItemConfig()

	if ignoreModifiers or (not someoneHasNo or itemConfig:GetCollectible(id).Type ~= ItemType.ITEM_ACTIVE) then
		local itemIsUnlocked = mod.IsVanillaCollectibleUnlocked(id)
		local itemWasInRealPools = itempool:RemoveCollectible(id)
		local itemHasIllegalTags = mod.DoesCollectibleViolateTagRules(id)
		mod.RemoveItemFromCustomItemPools(id)

		if itemIsUnlocked and not itemHasIllegalTags and (itemWasInRealPools or poolRecycled) then
			return true
		end
	end

	return false
end

local function isTrinketValid(id, poolRecycled)
	local itempool = game:GetItemPool()
	local trinketWasInRealPools = itempool:RemoveTrinket(id)
	mod.RemoveTrinketFromCustomItemPools(id)

	if trinketWasInRealPools or poolRecycled then
		return true
	end

	return false
end

local function tryGildTrinket(id, rng)
	if FiendFolio.AchievementTrackers.GoldenTrinketsUnlocked and rng:RandomFloat() < 0.02 then
		return id | TrinketType.TRINKET_GOLDEN_FLAG
	end

	return id
end

function mod.GetItemFromCustomItemPool(pool, rng, ignoreModifiers)
	local someoneHasNo = false
	local someoneHasChaos = false
	local activePoolName = pool[1]
	local poolType = pool[2]
	local returnValue = 0
	local itempool = game:GetItemPool()
	local itemConfig = Isaac.GetItemConfig()
	local poolRecycled = mod.savedata[activePoolName .. "Recycled"]

	if not rng then
		rng = RNG()
		rng:SetSeed(game:GetSeeds():GetStartSeed(), 35)
	end

	mod.AnyPlayerDo(function(player)
		if player:HasTrinket(TrinketType.TRINKET_NO) then someoneHasNo = true end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then someoneHasChaos = true end
	end)

	if someoneHasChaos and not ignoreModifiers then
		if poolType == mod.CustomItemPoolType.MIXED then
			return {PickupVariant.PICKUP_COLLECTIBLE, 0}
		else
			return 0
		end
	end

	if poolType == mod.CustomItemPoolType.COLLECTIBLE then
		for i = 1, 32 do
			local roll = rng:RandomInt(#mod[activePoolName]) + 1
			local item = mod[activePoolName][roll]

			if isCollectibleValid(item, ignoreModifiers, someoneHasNo, poolRecycled) then
				returnValue = item
				break
			end
		end
	elseif poolType == mod.CustomItemPoolType.TRINKET then
		for i = 1, 32 do
			local roll = rng:RandomInt(#mod[activePoolName]) + 1
			local trinket = mod[activePoolName][roll]

			if isTrinketValid(trinket, poolRecycled) then
				returnValue = tryGildTrinket(trinket, rng)
				break
			end
		end
	elseif poolType == mod.CustomItemPoolType.MIXED then
		for i = 1, 32 do
			local roll = rng:RandomInt(#mod[activePoolName]) + 1
			local chosenData = mod[activePoolName][roll]
			returnValue = chosenData

			if chosenData[1] == PickupVariant.PICKUP_COLLECTIBLE then -- Collectible
				if isCollectibleValid(chosenData[2], ignoreModifiers, someoneHasNo, poolRecycled) then
					break
				end
			elseif chosenData[1] == PickupVariant.PICKUP_TRINKET then -- Trinket
				if isTrinketValid(chosenData[2], poolRecycled) then
					returnValue = {chosenData[1], tryGildTrinket(chosenData[2], rng)}
					break
				end
			end
		end
	end

	return returnValue
end

function mod.ShowcaseAllCustomPoolItems(pool)
	local i = 0
	local room = game:GetRoom()

	local activePoolName = pool[1]
	local poolType = pool[2]

	if poolType == mod.CustomItemPoolType.MIXED then
		for _, data in pairs(mod[activePoolName]) do
			while room:GetGridCollision(i) ~= 0 do
				i = i + 1
			end

			Isaac.Spawn(5, data[1], data[2], room:GetGridPosition(i), Vector.Zero, nil)
			i = i + 1
		end
	else
		for _, item in pairs(mod[activePoolName]) do
			while room:GetGridCollision(i) ~= 0 do
				i = i + 1
			end

			Isaac.Spawn(5, poolType == mod.CustomItemPoolType.COLLECTIBLE and PickupVariant.PICKUP_COLLECTIBLE or PickupVariant.PICKUP_TRINKET, item, room:GetGridPosition(i), Vector.Zero, nil)
			i = i + 1
		end
	end
end