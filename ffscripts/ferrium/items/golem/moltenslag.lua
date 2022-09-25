local mod = FiendFolio

function mod:moltenSlagUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.MOLTEN_SLAG) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MOLTEN_SLAG)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MOLTEN_SLAG)
		for _,entity in ipairs(Isaac.FindInRadius(player.Position, 40+math.min(60, 20*mult), EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				if rng:RandomInt(60-math.floor(math.min(50, 10*mult))) == 0 then
					entity:AddBurn(EntityRef(player), math.ceil(60*mult), player.Damage*mult)
				end
			end
		end
	end
end