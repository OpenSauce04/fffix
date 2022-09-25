local mod = FiendFolio
local game = Game()

local poopCache = {}

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_, typ, var, sub, index, seed)
	if typ == 1500 and game:GetRoom():IsFirstVisit() then
		local petrifiedGelMultiplier = mod.GetGlobalTrinketMultiplier(TrinketType.TRINKET_PETRIFIED_GEL)
		if petrifiedGelMultiplier > 0 then
			local rng = Isaac.GetPlayer():GetTrinketRNG(TrinketType.TRINKET_PETRIFIED_GEL)
			local chance = 0.2 * petrifiedGelMultiplier -- Base: 20%, Golden/Box = 40%, Golden+Box = 60% 

			if rng:RandomFloat() < chance then
				mod.ShampooGrid:Spawn(index, true, false, nil)
				return {1500, 0, 0}
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
	local room = game:GetRoom()
	for i = 0, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		if grid and grid:ToPoop() then
			poopCache[i] = true
		end
	end
end, CollectibleType.COLLECTIBLE_THE_POOP)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
	local room = game:GetRoom()
	for i = 0, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		if grid and grid:ToPoop() and not poopCache[i] then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_PETRIFIED_GEL)
			local multiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_PETRIFIED_GEL)
			local chance = 0.3 * multiplier -- Base: 30%, Golden/Box = 60%, Golden+Box = 90% 

			if rng:RandomFloat() < chance then
				local shampoo = mod.ShampooGrid:Spawn(i, true, false, nil)
				local sprite = shampoo.GridEntity:GetSprite()
				sprite:Play("Appear")
			end
		end
	end
end, CollectibleType.COLLECTIBLE_THE_POOP)