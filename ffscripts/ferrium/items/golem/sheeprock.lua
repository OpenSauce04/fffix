local mod = FiendFolio

function mod:sheepRockOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)

		if rng:RandomInt(100) < chance then
			local data = tear:GetData()

			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
			
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_POP
			local color = Color(0.5, 0.5, 0.5, 1.0, 0, 0, 0)
			color:SetColorize(2.5, 2.5, 2.5, 1)
			tear.Color = color
		end
	end
end

function mod:sheepRockOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end

function mod:sheepRockOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = bomb:GetData()
			
			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(0.5, 0.5, 0.5, 1.0, 0, 0, 0)
			color:SetColorize(2.5, 2.5, 2.5, 1)
			bomb.Color = color
		end
	end
end

function mod:sheepRockOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end

function mod:sheepRockOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = creep:GetData()

			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(0.5, 0.5, 0.5, 1.0, 0, 0, 0)
			color:SetColorize(2.5, 2.5, 2.5, 1)
			data.FFAquariusColor = color
		end
	end
end

function mod:sheepRockOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = target:GetData()

			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(0.5, 0.5, 0.5, 1.0, 0, 0, 0)
			color:SetColorize(2.5, 2.5, 2.5, 1)
			data.FFExplosionColor = color
		end
	end
end

function mod:sheepRockOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEEP_ROCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHEEP_ROCK)
		local chance = 7*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end