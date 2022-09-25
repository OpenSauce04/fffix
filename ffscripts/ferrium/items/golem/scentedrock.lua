local mod = FiendFolio

function mod:scentedRockUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SCENTED_ROCK) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SCENTED_ROCK)
		for _,entity in ipairs(Isaac.FindInRadius(player.Position, 45+math.min(10*mult, 50), EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				entity:AddCharmed(EntityRef(player), math.max(30, math.floor(40*mult)))
			end
		end
	end
end