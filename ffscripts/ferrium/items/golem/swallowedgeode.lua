local mod = FiendFolio

function mod:swallowedGeodeHurt(player)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SWALLOWED_GEODE) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SWALLOWED_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SWALLOWED_GEODE)
        local chance = 25*(mult-1)
        if mod.HasTwoGeodes(player) then
            chance = chance+33
        end
        if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
            local chance = 50
            if mod.HasTwoGeodes(player) then
                chance = chance+25
            end
            if rng:RandomInt(100) < chance then
                Isaac.Spawn(5, 20, 1, player.Position, Vector(0,6):Rotated(rng:RandomInt(360)), player)
            end
        else
            if rng:RandomInt(100) < chance then
                Isaac.Spawn(5, 20, 4, player.Position, Vector(0,6):Rotated(rng:RandomInt(360)), player)
            else
                Isaac.Spawn(5, 20, 1, player.Position, Vector(0,6):Rotated(rng:RandomInt(360)), player)
            end
        end
    end
end