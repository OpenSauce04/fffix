local mod = FiendFolio

function mod:charcoalOnFireTear(player, tear)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CHARCOAL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHARCOAL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHARCOAL)
		local chance = math.min(50, 10+5*mult+(2*player.Luck))
		
		if rng:RandomInt(100) < chance then
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_GROW
			local data = tear:GetData()
			data.charcoalRockTear = true
			tear.Color = Color(0.2, 0.09, 0.06, 1, 0, 0, 0)
			tear.FallingAcceleration = -0.092
			tear.Velocity = tear.Velocity:Resized(2)
			tear.FallingSpeed = 0
		end
	end
end