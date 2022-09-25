local mod = FiendFolio

--The name Achilles' Steel was thought of after it was sprited.
function mod:achillesRockUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ACHILLES_ROCK) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ACHILLES_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ACHILLES_ROCK)
		for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 1000, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
				local data = enemy:GetData()
				if not data.achillesRockDir then
					data.achillesRockDir = rng:RandomInt(360)
				end
				data.achillesRock = mult
			end
		end
	end
end

mod.AddTrinketPickupCallback(nil, 
function(player)
	for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 1000, EntityPartition.ENEMY)) do
		if enemy:GetData() then
			enemy:GetData().achillesRock = nil
		end
	end
end, FiendFolio.ITEM.ROCK.ACHILLES_ROCK, nil)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flag, source)
	if source and flag ~= flag | DamageFlag.DAMAGE_CLONES then
		local data = ent:GetData()
		if data.achillesRock then
			if ent.Position:Distance(source.Position) > 1 then
				local angle = (source.Position-ent.Position):GetAngleDegrees()
				if angle < 0 then
					angle = angle+360
				end
				local difference = math.abs(data.achillesRockDir - angle)
				if difference < 60 or difference > 300 then
					ent:TakeDamage(damage * (1+data.achillesRock/2), flag | DamageFlag.DAMAGE_CLONES, EntityRef(ent), 0)
					if ent.Type ~= 951 then
						ent:BloodExplode()
					end
					return false
				end
			end
		end
	end	
end)