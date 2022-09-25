local mod = FiendFolio
local game = Game()

function mod:petrifiedSockOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FREEZE
			local color = Color(0.6, 0.6, 0.6, 1, 0.35, 0.35, 0.35)
			color:SetColorize(0.7,0.7,0.7,0.5)
			tear.Color = color
		end
	end
end

function mod:petrifiedSockOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			entity:AddFreeze(EntityRef(player), 180 * secondHandMultiplier, false)
		end
	end
end

function mod:petrifiedSockOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			bomb.Flags = bomb.Flags | TearFlags.TEAR_FREEZE
			local color = Color(0.6, 0.6, 0.6, 1, 0.35, 0.35, 0.35)
			color:SetColorize(0.7,0.7,0.7,0.5)
			bomb.Color = color
		end
	end
end

function mod:petrifiedSockOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			entity:AddFreeze(EntityRef(player), 180 * secondHandMultiplier, false)
		end
	end
end

function mod:petrifiedSockOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			data.AddPetrify = true
			data.ApplyPetrifyDuration = 180 * secondHandMultiplier
			local color = Color(0.6, 0.6, 0.6, 1, 0.35, 0.35, 0.35)
			color:SetColorize(0.7,0.7,0.7,0.5)
			creep.Color = color
		end
	end
end

function mod:petrifiedSockOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			local data = target:GetData()
			data.AddPetrify = true
			data.ApplyPetrifyDuration = 180 * secondHandMultiplier
			local color = Color(0.6, 0.6, 0.6, 1, 0.35, 0.35, 0.35)
			color:SetColorize(0.7,0.7,0.7,0.5)
			data.FFExplosionColor = color
		end
	end
end

function mod:petrifiedSockOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.PETRIFIED_SOCK)
		local chance = 5+5*mult+(2*player.Luck)
		
		if rng:RandomInt(100) < chance then
			entity:AddFreeze(EntityRef(player), 180 * secondHandMultiplier, false)
		end
	end
end

function mod:petrifyOnApply(entity, source, data)
	if data.AddPetrify then
		entity:AddFreeze(EntityRef(source.Entity.SpawnerEntity), data.ApplyShrinkDuration)
	end
end