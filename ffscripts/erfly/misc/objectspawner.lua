local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, var, sub, pos, vel, spawner, seed)
    if type == 5 and var == 302 then
        local rng = RNG()
        rng:SetSeed(seed, 1)
        return{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, FiendFolio.GetRandomObject(rng)}
    end
end)