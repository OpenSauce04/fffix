local mod = FiendFolio

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.RAI_STONE, true) then
		local mult = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.ROCK.RAI_STONE)
		if not (npc.Type == mod.FFID.Tech and npc.Variant > 999) and not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD) then
			local chance = math.min(75,mult*15)
			if npc:GetDropRNG():RandomInt(100) < chance then
				local coin = Isaac.Spawn(5, 20, 1, npc.Position, Vector.Zero, nil):ToPickup()
                local cSprite = coin:GetSprite()
                cSprite:Load("gfx/items/pick ups/stone_coin.anm2", true)
                cSprite:Play("Appear", true)
                coin.Timeout = 75
			end
		end
	end
end)