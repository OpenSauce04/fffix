local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
    Isaac.Spawn(5, 300, FiendFolio.GetRandomObject(player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.KINDA_EGG)), pos, nilvector, nil)
    sfx:Play(mod.Sounds.Monch, 1, 0, false, 1)
    --player:SetColor(Color(0,0,0,1,0,0,0), 90, 90, true, false)
end, nil, mod.ITEM.COLLECTIBLE.KINDA_EGG)