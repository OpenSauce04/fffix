local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    player:GetData().BrickSeperatorBuff = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_MEAT_CLEAVER, false, false, true, false, -1)
    player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
    player:EvaluateItems()
end, Card.BRICK_SEPERATOR)