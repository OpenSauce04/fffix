local mod = FiendFolio

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.VALUE_FOSSIL, true) and pickup:IsShopItem() and pickup.Price > 0 then
		if not FiendFolio.savedata.run.level.valueFossilPickups then
			FiendFolio.savedata.run.level.valueFossilPickups = {}
		end
		local sales = FiendFolio.savedata.run.level.valueFossilPickups
		local mult = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.ROCK.VALUE_FOSSIL)
		pickup.AutoUpdatePrice = false
		if not sales["" .. pickup.InitSeed] then
			pickup.Price = pickup.Price-math.ceil(mult)
			sales["" .. pickup.InitSeed] = true
		end
	end
end)