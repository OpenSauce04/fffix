local mod = FiendFolio
local kingOfSpades = mod.ITEM.CARD.KING_OF_SPADES

local bannedTearReplacers = {
	[TearVariant.ERASER] 	= true,
	[TearVariant.FIRE] 		= true,
	[TearVariant.GRIDENT] 	= true,
}

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	player:GetData().kingOfSpadesActive = true
	player:AddKeys(1)
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingSpades, flags)
end, kingOfSpades)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	mod.AnyPlayerDo(function(player)
		player:GetData().kingOfSpadesActive = false
	end)
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity and tear.SpawnerType == 1 and tear.Variant <= TearVariant.TECH_SWORD_BEAM and not bannedTearReplacers[tear.TearVariant] then
		local player = tear.SpawnerEntity:ToPlayer()
		if player:GetData().kingOfSpadesActive and player:GetNumKeys() > 0 then
			player:AddKeys(-1)
			tear:GetData().kingOfSpadesTear = true

			if tear.Variant ~= TearVariant.KEY_BLOOD then
				tear:ChangeVariant(TearVariant.KEY_BLOOD)
			end

			mod.scheduleForUpdate(function()
				tear:AddTearFlags(TearFlags.TEAR_PIERCING)
			end, 0)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	if entity:GetData().kingOfSpadesTear then
		Isaac.Spawn(5, 30, 1, entity.Position, RandomVector(), entity.SpawnerEntity)
	end
end, EntityType.ENTITY_TEAR)