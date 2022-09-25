local mod = FiendFolio
local game = Game()

local diceSelection = {
	Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6,
	Card.GLASS_D4, Card.GLASS_D4, Card.GLASS_D4,
	Card.GLASS_D8, Card.GLASS_D8, Card.GLASS_D8, Card.GLASS_D8,
	Card.GLASS_D100,
	Card.GLASS_D10, Card.GLASS_D10, Card.GLASS_D10, Card.GLASS_D10,
	Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20,
	Card.GLASS_D12, Card.GLASS_D12, Card.GLASS_D12, Card.GLASS_D12,
	Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN,
}

function mod:pocketDiceNewLevel(player)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.POCKET_DICE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.POCKET_DICE)
		for i=1,3 do
			mod.scheduleForUpdate(function()
				local room = game:GetRoom()
				if i == 1 then
					Isaac.Spawn(5, 20, 1, room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, nil)
				else
					Isaac.Spawn(5, 300, diceSelection[rng:RandomInt(#diceSelection)+1], room:FindFreePickupSpawnPosition(player.Position, 20)+mod:shuntedPosition(10, rng), Vector.Zero, nil)
				end
			end, i)
		end
	end
end