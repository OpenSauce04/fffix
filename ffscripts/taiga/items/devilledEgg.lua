-- Devilled Egg --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
	player:AddSoulHearts(-2)
	mod:AddImmoralHearts(player, 4)
end, nil, FiendFolio.ITEM.COLLECTIBLE.DEVILLED_EGG)

local function tearsUp(firedelay, val)
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.99)
end

function mod:updateDevilledEggFireDelay(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DEVILLED_EGG) then
		player.MaxFireDelay = tearsUp(player.MaxFireDelay, (0.3 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DEVILLED_EGG)))
	end
end
