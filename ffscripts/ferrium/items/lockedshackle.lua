local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		if player:GetTrinket(0) == FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BELLY_BUTTON) then
				if player:GetTrinket(1) > 0 then
					return false
				end
			else
				return false
			end
		end
	end
end, 350)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE) then
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
			local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
			local chance = 25
			if rng:RandomInt(100) < chance then
				for i=1,mult do
					player:TryRemoveTrinket(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
				end
				sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1, 0, false, 1)
				for i=1,5 do
					local gib = Isaac.Spawn(1000, 163, 0, player.Position, Vector(0,math.random(2,6)):Rotated(math.random(360)), player):ToEffect()
				end
				player:AddCacheFlags(CacheFlag.CACHE_ALL)
				player:EvaluateItems()
				mod.scheduleForUpdate(function()
					player:AddKeys(-1)
				end, 0)
			else
				sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 1.2)
				for i=1,2 do
					local gib = Isaac.Spawn(1000, 163, 0, player.Position, Vector(0,math.random(2,6)):Rotated(math.random(360)), player):ToEffect()
				end
			end
		end
	end
end, 30)

mod.AddTrinketPickupCallback(nil, function(player)
	for _,trinket in ipairs(Isaac.FindByType(5,350,-1,false,false)) do
		if trinket.SubType == FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE % 32768 then
			trinket.Visible = false
			trinket:Remove()
			player:AddTrinket(trinket.SubType)
		end
	end
end, FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE, nil)