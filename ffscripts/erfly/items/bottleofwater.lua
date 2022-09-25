local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(mod.Sounds.TheShittiestGulpSoundEver, 1, 0, false, 1)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false)

    local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
    Isaac.Spawn(5, 70, 0, pos, nilvector, nil)
end, nil, mod.ITEM.COLLECTIBLE.BOTTLE_OF_WATER)