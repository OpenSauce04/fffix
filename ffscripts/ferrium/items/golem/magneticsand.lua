local mod = FiendFolio

function mod:magneticSandOnFireTear(player, tear, secondHand, ludo, ignore)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.MAGNETIC_SAND) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 20, 0.4)*100

        if rng:RandomInt(100) < chance and not ignore then
            --[[local data = tear:GetData()
            data.ApplyMagnetic = true
		    data.ApplyMagneticDuration = 100]]
            tear:AddTearFlags(TearFlags.TEAR_MAGNETIZE)
            local color = Color(0.3, 0.3, 0.45, 1, 0, 0, 0)
            color:SetColorize(1, 1, 1, 1)
            tear.Color = color
        end
	end
end

function mod:magneticSandOnFireBomb(player, bomb, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.MAGNETIC_SAND) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 20, 0.4)*100

        if rng:RandomInt(100) < chance then
            bomb:AddTearFlags(TearFlags.TEAR_MAGNETIZE)
            local color = Color(0.3, 0.3, 0.45, 1, 0, 0, 0)
            color:SetColorize(1, 1, 1, 1)
            bomb.Color = color
        end
	end
end

function mod:magneticSandOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.MAGNETIC_SAND) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 20, 0.4)*100

        if rng:RandomInt(100) < chance then
    		entity:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
		end
	end
end

function mod:magneticSandOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.MAGNETIC_SAND) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 20, 0.4)*100

        if rng:RandomInt(100) < chance then
    		entity:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
		end
	end
end

--I'm sorry but I just can't be assed to do it on Epic Fetus and Aquarius

function mod:magneticSandOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.MAGNETIC_SAND) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MAGNETIC_SAND)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 20, 0.4)*100

        if rng:RandomInt(100) < chance then
    		entity:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
		end
	end
end
