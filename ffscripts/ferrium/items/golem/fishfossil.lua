local mod = FiendFolio

function mod:fishFossilDamage(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FISH_FOSSIL) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FISH_FOSSIL)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FISH_FOSSIL)
		local flyNum = rng:RandomInt(3+math.floor(mult))+1
		for i=1,flyNum do
			player:AddBlueFlies(1, player.Position+RandomVector()*5, nil)
		end
	end
end