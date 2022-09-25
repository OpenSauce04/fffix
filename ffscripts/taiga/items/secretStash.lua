-- Secret Stash --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
	local room = Game():GetRoom()

	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
	if player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.SECRET_STASH):RandomFloat() < 0.5 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
	else
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
	end
end, nil, FiendFolio.ITEM.COLLECTIBLE.SECRET_STASH)

function mod:handleSecretStash()
	local contents = {}

	contents.coins = 0
	contents.keys = 0
	contents.bombs = 0
	contents.cards = {}
	contents.pills = {}

	for i = 1, Game():GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)

		if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.SECRET_STASH) then
			contents.coins = math.min(5, math.max(math.floor(player:GetNumCoins() * 0.1), contents.coins))
			contents.keys = math.min(5, math.max(math.floor(player:GetNumKeys() * 0.1), contents.keys))
			contents.bombs = math.min(5, math.max(math.floor(player:GetNumBombs() * 0.1), contents.bombs))
			for i = 0, 3 do
				local card = player:GetCard(i)
				local pill = player:GetPill(i)
				if card ~= 0 then
					table.insert(contents.cards, card)
				end
				if pill ~= 0 then
					table.insert(contents.pills, Game():GetItemPool():GetPillEffect(pill))
				end
			end
		end
	end

	FiendFolio.savedata.SecretStashContents = contents
end

local secretStashContentsToSpawn = nil
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
	if not isContinued then
		secretStashContentsToSpawn = FiendFolio.savedata.SecretStashContents
	end
	FiendFolio.savedata.SecretStashContents = nil
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player.FrameCount >= 1 and secretStashContentsToSpawn ~= nil then
		local room = Game():GetRoom()
		local spawnedAnything = false
		while secretStashContentsToSpawn.coins > 0 do
			if secretStashContentsToSpawn.coins >= 5 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 2, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
				secretStashContentsToSpawn.coins = secretStashContentsToSpawn.coins - 5
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
				secretStashContentsToSpawn.coins = secretStashContentsToSpawn.coins - 1
			end
			spawnedAnything = true
		end
		while secretStashContentsToSpawn.bombs > 0 do
			if secretStashContentsToSpawn.bombs >= 2 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 2, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
				secretStashContentsToSpawn.bombs = secretStashContentsToSpawn.bombs - 2
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 1, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
				secretStashContentsToSpawn.bombs = secretStashContentsToSpawn.bombs - 1
			end
			spawnedAnything = true
		end
		while secretStashContentsToSpawn.keys > 0 do
			if secretStashContentsToSpawn.keys >= 2 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 3, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
				secretStashContentsToSpawn.keys = secretStashContentsToSpawn.keys - 2
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 1, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
				secretStashContentsToSpawn.keys = secretStashContentsToSpawn.keys - 1
			end
			spawnedAnything = true
		end
		while #(secretStashContentsToSpawn.cards) > 0 do
			if secretStashContentsToSpawn.cards[1] < #(Isaac.GetItemConfig():GetCards()) then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, secretStashContentsToSpawn.cards[1], room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
			end
			table.remove(secretStashContentsToSpawn.cards, 1)
			spawnedAnything = true
		end
		while #(secretStashContentsToSpawn.pills) > 0 do
			if secretStashContentsToSpawn.pills[1] < #(Isaac.GetItemConfig():GetPillEffects()) then
				local itempool = Game():GetItemPool()
				local pill = itempool:ForceAddPillEffect(secretStashContentsToSpawn.pills[1])
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pill, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), nilvector, nil)
			end
			table.remove(secretStashContentsToSpawn.pills, 1)
			spawnedAnything = true
		end

		if spawnedAnything then
			player:AnimateCollectible(FiendFolio.ITEM.COLLECTIBLE.SECRET_STASH)
		end

		secretStashContentsToSpawn = nil
	end
end)
