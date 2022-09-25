local mod = FiendFolio
local game = Game()

function mod:fragmentedOnyxOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end

		if rng:RandomInt(100) < chance then
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FEAR | TearFlags.TEAR_DARK_MATTER
			tear.Color = Color(0.3, 0.3, 0.3, 1, 0, 0, 0)
			tear:Update()
		end
	end
end

function mod:fragmentedOnyxOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end
		
		if rng:RandomInt(100) < chance then
			entity:AddFear(EntityRef(player), 180 * secondHandMultiplier)
		end
	end
end

function mod:fragmentedOnyxOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end
		
		if rng:RandomInt(100) < chance then
			bomb.Flags = bomb.Flags | TearFlags.TEAR_FEAR
			
			local color = Color(0.3, 0.3, 0.3, 1, 0, 0, 0)
			bomb.Color = color
		end
	end
end

function mod:fragmentedOnyxOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end
		
		if rng:RandomInt(100) < chance then
			entity:AddFear(EntityRef(player), 180 * secondHandMultiplier)
		end
	end
end

function mod:fragmentedOnyxOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end
		
		if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			data.ApplyFear = true
			data.ApplyFearDuration = 180 * secondHandMultiplier

			data.FFAquariusColor = Color(0, 0, 0, 1, 0.1896, 0.1896, 0.1896)
		end
	end
end

function mod:fragmentedOnyxOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end
		
		if rng:RandomInt(100) < chance then
			local data = target:GetData()
			data.ApplyFear = true
			data.ApplyFearDuration = 180 * secondHandMultiplier

			data.FFExplosionColor = Color(0, 0, 0, 1, 0.1896, 0.1896, 0.1896)
		end
	end
end

function mod:fragmentedOnyxOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
		local chance = math.floor(5+5*mult+(3.5*player.Luck))
		if mod.HasTwoGeodes(player) then
			chance = chance+5
		end
		
		if rng:RandomInt(100) < chance then
			entity:AddFear(EntityRef(player), 180 * secondHandMultiplier)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
	if ent:ToNPC() then
		local npc = ent:ToNPC()
		if mod:isScare(npc) and flags ~= flags | DamageFlag.DAMAGE_CLONES then
			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				if player:HasTrinket(FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE) then
					if mod.HasTwoGeodes(player) then
						local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRAGMENTED_ONYX_GEODE)
						local chance = math.min(1, game:GetRoom():GetDevilRoomChance())
						npc:TakeDamage(damage*(1+chance), flags | DamageFlag.DAMAGE_CLONES, source, 0)
						return false
					end
				end
			end
		end
	end
end)

function mod:fearOnApply(entity, source, data)
	if data.ApplyFear then
		entity:AddFear(EntityRef(source.Entity.SpawnerEntity), data.ApplyFearDuration)
	end
end