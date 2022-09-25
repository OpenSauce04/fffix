local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
    Isaac.Spawn(5, 300, mod.ITEM.CARD.PUZZLE_PIECE, pos, nilvector, nil)
end, nil, mod.ITEM.COLLECTIBLE.BOX_TOP)