local mod = FiendFolio

function mod:hailstoneUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.HAILSTONE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.HAILSTONE)
		for _,entity in ipairs(Isaac.FindInRadius(player.Position, 70+math.min(30*mult, 70), EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				local slowMult = math.max(0.2, entity.Position:Distance(player.Position)/(150+math.min(20*mult, 50)))
				entity:AddSlowing(EntityRef(player), 1, slowMult, Color(1.2,1.2,1.2,1,0,0,0.1))
				if slowMult < 0.45 then
					entity:AddEntityFlags(EntityFlag.FLAG_ICE)
					entity:GetData().PeppermintSlowed = true
				end
			end
		end
	end
end