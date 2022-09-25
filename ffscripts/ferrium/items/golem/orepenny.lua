local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.ORE_PENNY) and pickup.SubType ~= 6 then
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ORE_PENNY)
			local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.ORE_PENNY)
			local chance = (1 - (0.5)^(pickup:GetCoinValue()))*100
			for i=1,mult do
				if rng:RandomInt(100) < chance then
					player:AddCoins(1)
					break
				end
			end
		end
	end
end, 20)

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_,t,v,s, index, seed)
	local room = game:GetRoom()
	if room:IsFirstVisit() then
		if t == 1000 and v == 0 and s == 0 then
			for i = 1, game:GetNumPlayers() do
				local p = Isaac.GetPlayer(i - 1)
				if p:HasTrinket(FiendFolio.ITEM.ROCK.ORE_PENNY) then
					if room:GetGridPosition(index):Distance(p.Position) > 100 then
						local rng = p:GetTrinketRNG(FiendFolio.ITEM.ROCK.ORE_PENNY)
						local mult = mod.GetGolemTrinketPower(p, FiendFolio.ITEM.ROCK.ORE_PENNY)
						local chance = 3*mult
						if rng:RandomInt(100) < chance then
							return {1011, 0, 0}
						end
					end
				end
			end
		end
	end
end)

--[[mod:AddCallback(ModCallbacks.MC_GET_TRINKET, function(_, trinket, rng)
    if trinket == TrinketType.TRINKET_COUNTERFEIT_PENNY then
        local isAnyGolem, isMixedGolem = FiendFolio.GolemExists()
        if isAnyGolem then
            return FiendFolio.ITEM.ROCK.ORE_PENNY
        end
    end
end)]]