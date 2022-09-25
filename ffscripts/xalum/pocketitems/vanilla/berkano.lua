local mod = FiendFolio

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	for i = 1, 3 do
		mod.ThrowFriendlySkuzz(player, RandomVector() * 2)
	end
end, Card.RUNE_BERKANO)