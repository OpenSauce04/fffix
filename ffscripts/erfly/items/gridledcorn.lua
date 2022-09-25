local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
    Isaac.Spawn(5, 30, KeySubType.KEY_SPICY_PERM, pos, nilvector, nil)
    local vec = RandomVector() * 10
    for i = 120, 360, 120 do
        local spider = mod.spawnent(player, player.Position, vec:Rotated(i), 818, 2)
        spider:AddCharmed(EntityRef(player), -1)
        spider.CollisionDamage = spider.CollisionDamage * 0.2
        spider.MaxHitPoints = spider.MaxHitPoints * 0.2
        spider.HitPoints = spider.MaxHitPoints
    end
end, nil, mod.ITEM.COLLECTIBLE.GRIDDLED_CORN)