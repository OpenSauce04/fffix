local mod = FiendFolio

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    player:UsePill(PillEffect.PILLEFFECT_AMNESIA, 1, 1)
end, Card.RUNE_ANSUS)