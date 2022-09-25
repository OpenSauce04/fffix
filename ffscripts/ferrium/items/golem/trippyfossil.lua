local mod = FiendFolio
local game = Game()

function mod:trippyFossilOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)

		if rng:RandomInt(100) < chance then
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_GODS_FLESH
			
			tear.Color = Color(math.random(255)/255,math.random(255)/255,math.random(255)/255,1,0,0,0)
		end
	end
end

function mod:trippyFossilOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			entity:AddShrink(EntityRef(player), 200 * secondHandMultiplier, false)
		end
	end
end

function mod:trippyFossilOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			bomb.Flags = bomb.Flags | TearFlags.TEAR_GODS_FLESH
		end
	end
end

function mod:trippyFossilOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			entity:AddShrink(EntityRef(player), 200 * secondHandMultiplier, false)
		end
	end
end

function mod:trippyFossilOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			data.AddShrink = true
			data.ApplyShrinkDuration = 200 * secondHandMultiplier
		end
	end
end

function mod:trippyFossilOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = target:GetData()
			data.AddShrink = true
			data.ApplyShrinkDuration = 200 * secondHandMultiplier
		end
	end
end

function mod:trippyFossilOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TRIPPY_FOSSIL)
		local chance = 7+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			entity:AddShrink(EntityRef(player), 200 * secondHandMultiplier, false)
		end
	end
end

function mod:shrinkOnApply(entity, source, data)
	if data.ApplyShrink then
		entity:AddShrink(EntityRef(source.Entity.SpawnerEntity), data.ApplyShrinkDuration)
	end
end