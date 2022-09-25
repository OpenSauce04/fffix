local mod = FiendFolio

function mod:umbilicalGeodeNewRoom(player)
    if player:HasTrinket(mod.ITEM.ROCK.UMBILICAL_GEODE) then
        local mult, gB = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.UMBILICAL_GEODE)
        mult = math.ceil(mult)
        local heartCheck = 2
        if gB then
            heartCheck = 3
        end
        if player:GetHearts() < heartCheck then
            local tempEffs = player:GetEffects()
            tempEffs:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LITTLE_STEVEN, false, mult)
        end
    end
end

function mod:umbilicalGeodeHurt(player)
    if player:HasTrinket(mod.ITEM.ROCK.UMBILICAL_GEODE) then
        local rng = player:GetTrinketRNG(mod.ITEM.ROCK.UMBILICAL_GEODE)
        local mult, gB = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.UMBILICAL_GEODE)
        local chance = 20*mult
        if gB then
            chance = chance+10
        end
        if rng:RandomInt(100) > chance then
            local tempEffs = player:GetEffects()
            tempEffs:AddCollectibleEffect(CollectibleType.COLLECTIBLE_GEMINI, false, 1)
        end
    end
end