-- Perfectly Generic Object --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:isPocketObject(pocketitem)
	return mod.PocketObjectMimicCharges[pocketitem] ~= nil
end

function mod:getPocketObjectMimicCharge(pocketitem)
	return mod.PocketObjectMimicCharges[pocketitem]
end

function mod:isGenericObjectActive(id)
	return id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8 or
	       id == FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12
end

function mod:useGenericObject(id, rng, player, useflags, activeslot, customvardata)
	local player = mod:GetPlayerUsingItem()
	local pocketitem = player:GetCard(0)
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and
	   pocketitem ~= FiendFolio.ITEM.CARD.STORAGE_BATTERY_0 and 
	   pocketitem ~= FiendFolio.ITEM.CARD.STORAGE_BATTERY_1 and 
	   pocketitem ~= FiendFolio.ITEM.CARD.STORAGE_BATTERY_2 and 
	   pocketitem ~= FiendFolio.ITEM.CARD.STORAGE_BATTERY_3 
	then
		player:AddWisp(FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4, player.Position)
		sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
	end

	if mod:isPocketObject(pocketitem) then
		local chargeAfter = 0 + player:GetBatteryCharge(activeslot)
		if pocketitem == FiendFolio.ITEM.CARD.STORAGE_BATTERY_0 then
			player:SetCard(Card.CARD_NULL, 0)
			chargeAfter = 0 + player:GetBatteryCharge(activeslot)
		elseif pocketitem == FiendFolio.ITEM.CARD.STORAGE_BATTERY_1 then
			player:SetCard(Card.CARD_NULL, 0)
			chargeAfter = 1 + player:GetBatteryCharge(activeslot)
		elseif pocketitem == FiendFolio.ITEM.CARD.STORAGE_BATTERY_2 then
			player:SetCard(Card.CARD_NULL, 0)
			chargeAfter = 2 + player:GetBatteryCharge(activeslot)
		elseif pocketitem == FiendFolio.ITEM.CARD.STORAGE_BATTERY_3 then
			player:SetCard(Card.CARD_NULL, 0)
			chargeAfter = 3 + player:GetBatteryCharge(activeslot)
		end
		player:UseCard(pocketitem, UseFlag.USE_NOANIM | UseFlag.USE_OWNED | UseFlag.USE_MIMIC)

		if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) and chargeAfter == 0 and mod:getPocketObjectMimicCharge(pocketitem) ~= 1 then
			chargeAfter = 1
		end

		if activeslot and activeslot >= 0 then
			player:RemoveCollectible(id, true, activeslot)
			player:AddCollectible(CollectibleType["COLLECTIBLE_PERFECTLY_GENERIC_OBJECT_" .. mod:getPocketObjectMimicCharge(pocketitem)], 0, false, activeslot)
			player:SetActiveCharge(chargeAfter, activeslot)
		end
	end

	return {Remove = false, ShowAnim = useflags ~= useflags | UseFlag.USE_NOANIM}
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGenericObject, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12)

function mod.pgoSpawnRandomObject(player)
	local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, 
	            PickupVariant.PICKUP_TAROTCARD, 
	            FiendFolio.GetRandomObject(rng), 
	            game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 
	            nilvector, 
	            player)
end

FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8)
FiendFolio.AddItemPickupCallback(mod.pgoSpawnRandomObject, nil, FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, e)
	if e.Variant == FamiliarVariant.WISP and mod:isGenericObjectActive(e.SubType) then
		local rng = Isaac.GetPlayer(0):GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 
		            PickupVariant.PICKUP_TAROTCARD, 
		            FiendFolio.GetRandomObject(rng), 
		            game:GetRoom():FindFreePickupSpawnPosition(e.Position, 40, true), 
		            nilvector, 
		            e)
	end
end, EntityType.ENTITY_FAMILIAR)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity then
		local spawner = tear.SpawnerEntity
		if spawner.Type == EntityType.ENTITY_FAMILIAR and
		   spawner.Variant == FamiliarVariant.WISP and
		   mod:isGenericObjectActive(spawner.SubType)
		then
			local rng = Isaac.GetPlayer(0):GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3)
			if rng:RandomFloat() < 0.15 then
				local tdata = tear:GetData()
				tdata.FFSpawnRandomObjectOnKill = true
			end
		end
	end
end)

function mod:pgoOnTearDamage(sourcedata, data)
	if sourcedata.FFSpawnRandomObjectOnKill then
		data.FFTrySpawnRandomObjectOnKill = game:GetFrameCount()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, e)
	if e:GetData().FFTrySpawnRandomObjectOnKill ~= nil and 
	   math.abs(e:GetData().FFTrySpawnRandomObjectOnKill - game:GetFrameCount()) <= 1 
	then
		local rng = Isaac.GetPlayer(0):GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 
		            PickupVariant.PICKUP_TAROTCARD, 
		            FiendFolio.GetRandomObject(rng), 
		            e.Position, 
		            nilvector, 
		            e)
	end
end)
