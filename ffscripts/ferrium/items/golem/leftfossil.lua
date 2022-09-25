local mod = FiendFolio

local NonRedChestVariants = {
    [50] = true,
    [51] = true,
    [52] = true,
    [53] = true,
    [54] = true,
    [55] = true,
    [56] = true,
    [57] = true,
    [58] = true,
    [60] = true,
    [710] = true,
    [711] = true,
    [712] = true,
    [713] = true,
}

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.LEFT_FOSSIL, true) then
        local var = pickup.Variant
        if NonRedChestVariants[var] then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0, true)
        end
    end
end)