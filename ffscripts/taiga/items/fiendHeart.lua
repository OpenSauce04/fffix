-- >3 --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
	player:AddSoulHearts(-2)
	mod:AddImmoralHearts(player, 6)
end, nil, FiendFolio.ITEM.COLLECTIBLE.FIEND_HEART)
