local mod = FiendFolio
local kingOfSwords = mod.ITEM.CARD.KING_OF_SWORDS

local function getKingOfSwordsWisp(seed)
	for _, wisp in pairs(Isaac.FindByType(3, 237, CollectibleType.COLLECTIBLE_BFFS)) do
		if wisp.InitSeed == seed then
			return wisp:ToFamiliar()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	local data = mod.GetPersistentPlayerData(player)
	if not data.kingOfSwordsWisp then
		local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_BFFS, Vector(-1000, -1000)):ToFamiliar()
		wisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
		wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		wisp.Visible = false

		data.kingOfSwordsWisp = wisp.InitSeed
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingSwords, flags, 20)
end, kingOfSwords)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local data = mod.GetPersistentPlayerData(player)
	if data.kingOfSwordsWisp then
		local wisp = getKingOfSwordsWisp(data.kingOfSwordsWisp)
		wisp.Position = Vector(-1000, -1000)
		wisp.Velocity = Vector.Zero
		wisp.Visible = false
		wisp:RemoveFromOrbit()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	mod.AnyPlayerDo(function(player)
		local data = mod.GetPersistentPlayerData(player)
		if data.kingOfSwordsWisp then
			local wisp = getKingOfSwordsWisp(data.kingOfSwordsWisp)
			wisp:Remove()
			wisp:Kill()
			data.kingOfSwordsWisp = nil
		end
	end)
end)