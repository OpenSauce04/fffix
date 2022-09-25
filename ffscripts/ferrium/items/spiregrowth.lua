local mod = FiendFolio

mod.spireGrowthSpecials = { --Face cards might not be used, remember that fool starts at 1.
	[23] = 3,
	[24] = 3,
	[25] = 3,
	[26] = 3,
	[27] = 2,
	[28] = 2,
	[29] = 2,
	[30] = 2,
	[46] = 13,
	[79] = 12,
	[108] = 4,
	[109] = 12,
	[110] = 13,
	[111] = 14,
	[112] = 4,
	[113] = 12,
	[114] = 13,
	[115] = 14,
	[116] = 4,
	[117] = 12,
	[118] = 13,
	[119] = 4,
	[120] = 12,
	[122] = 14,
	[123] = 2,
	[124] = 2,
	[125] = 2,
	[126] = 2,
	[127] = 3,
	[128] = 3,
	[129] = 3,
	[130] = 4,
	[131] = 4,
	[133] = 15,
	[134] = 14,
}

function mod:spireGrowthUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH) then
		local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH)-1
		if data.spireGrowth then
			if data.spireGrowth > 0 then
				data.spireGrowth = data.spireGrowth-0.002
			else
				data.spireGrowth = 0
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	
	if data.spireGrowth and not player:HasTrinket(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH) then
		data.spireGrowth = nil
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	local data = player:GetData()
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH) then
		local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH)-1
		data.spireGrowth = 0
		local bonus = 0
		--print("1: " .. player:GetCard(0) .. ", 2: " .. player:GetCard(1) .. ", 3: " .. player:GetCard(2))
		if card > 55 and card < 78 then
			card = card-55
		end
		if mod.spireGrowthSpecials[card] ~= nil then
			card = mod.spireGrowthSpecials[card]
		end
		if card > 0 and card < 23 then
			if card > bonus then
				bonus = card
				data.spireGrowth = 0.2*card ^ (5*0.1752)*(1+mult)
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end)