local mod = FiendFolio

local positivePills = {0, 2, 5, 7, 10, 12, 14, 16, 18, 20, 23, 24, 26, 28, 33, 34, 35, 36, 38, 41, 48}
--Not including Gulp or Vurp for obvious reasons.

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, pill, player, flag)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.GMO_GEODE) then
        if (not player:GetData().ffsavedata.pillstotake or player:GetData().ffsavedata.pillstotake == 0) and not player:GetData().GMOGeode then
            local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.GMO_GEODE))
            FiendFolio.QueuePills(player, mult)
            
            if mod.HasTwoGeodes(player) then
                local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GMO_GEODE)
                local num = positivePills[rng:RandomInt(#positivePills)+1]
                player:GetData().queuedSpecificPills = {num}
            end
        end
    end
end)