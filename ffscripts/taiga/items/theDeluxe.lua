-- The Deluxe --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    player:AddBoneHearts(1)
    mod:AddMorbidHearts(player, 3)
    player:AddGoldenHearts(1)
    player:AddEternalHearts(1)
end, nil, FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE)

FiendFolio.AddItemPickupCallback(function(player, added)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE) then
		player:AddMaxHearts(2)
		player:AddHearts(2)
	end
end, nil, CollectibleType.COLLECTIBLE_MIDNIGHT_SNACK)

--function mod:updateTheDeluxeDamage(player)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE) and player:HasCollectible(CollectibleType.COLLECTIBLE_MEAT) then
--		player.Damage = player.Damage * 1.05
--	end
--end

local function tearsUp(firedelay, val)
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.99)
end

function mod:updateTheDeluxeFireDelay(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE) and player:HasCollectible(CollectibleType.COLLECTIBLE_SAD_ONION) then
		player.MaxFireDelay = math.max(1, math.floor(player.MaxFireDelay * 0.9))
	end
end

function mod:theDeluxeOnFireTear(player, tear)
	--Rotten Tomato + The Deluxe
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) and player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE) then
		if math.random() < 1 / math.max(1, 6 - player.Luck) then
			tear:AddTearFlags(TearFlags.TEAR_BAIT)
			tear.Color = Color(0.7, 0.14, 0.1, 1.0, 0.3, 0/255, 0/255)
		end
	end
end

function mod:theDeluxeOnFireBomb(player, bomb)
	--Rotten Tomato + The Deluxe
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) and player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE) then
		if math.random() < 1 / math.max(1, 6 - player.Luck) then
			bomb:AddTearFlags(TearFlags.TEAR_BAIT)
			bomb.Color = Color(0.7, 0.14, 0.1, 1.0, 0.3, 0/255, 0/255)
		end
	end
end
