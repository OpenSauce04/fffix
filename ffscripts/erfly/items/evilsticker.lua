local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
	local r = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.EVIL_STICKER)
    for i = 0, 5 do
		mod.scheduleForUpdate(function()
			local room = Game():GetRoom()
			local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position)), 20)
			Isaac.Spawn(5, 20, CoinSubType.COIN_CURSEDPENNY, spawnpos + RandomVector()*math.random(20), nilvector, nil)
		end, i)
	end
end, nil, mod.ITEM.COLLECTIBLE.EVIL_STICKER)