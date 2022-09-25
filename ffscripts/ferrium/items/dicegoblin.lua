local mod = FiendFolio
local game = Game()

mod.AddItemPickupCallback(function(player)
	local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.DICE_GOBLIN)
	for i=1,3 do
		local pickupType = FiendFolio.GetRandomObject(rng)
		mod.scheduleForUpdate(function()
			local room = game:GetRoom()
			local pickup = Isaac.Spawn(5, 300, pickupType, room:FindFreePickupSpawnPosition(player.Position, 20)+mod:shuntedPosition(10, rng), Vector.Zero, nil)
		end, i)
	end
end, nil, FiendFolio.ITEM.COLLECTIBLE.DICE_GOBLIN)

function mod:diceGoblinNewLevel(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DICE_GOBLIN) then
		local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.DICE_GOBLIN)
		local room = game:GetRoom()
		local pickupType = FiendFolio.GetRandomObject(rng)
		mod.scheduleForUpdate(function()
			Isaac.Spawn(5, 300, pickupType, room:FindFreePickupSpawnPosition(player.Position, 20)+mod:shuntedPosition(10, rng), Vector.Zero, nil)
		end, 1)
	end
end