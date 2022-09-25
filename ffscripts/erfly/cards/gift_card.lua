local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	for _, pedestal in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1)) do
		if pedestal.SubType > 0 then
            pedestal:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MYSTERY_GIFT, true, true, false)
            local poof = Isaac.Spawn(1000,15,0,pedestal.Position,nilvector,nil)
            poof:Update()
        end
    end
    FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardGiftCard, flags, 20)
end, mod.ITEM.CARD.GIFT_CARD)