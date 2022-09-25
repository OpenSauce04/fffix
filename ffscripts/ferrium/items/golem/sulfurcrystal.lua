local mod = FiendFolio

function mod:sulfurCrystalNewRoom(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SULFUR_CRYSTAL) then
        local room = Game():GetRoom()
        if not room:IsClear() then
            local savedata = data.ffsavedata.RunEffects
            local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SULFUR_CRYSTAL))

            savedata.sulfurCrystalCount = (savedata.sulfurCrystalCount or 0)+1
            --print(savedata.sulfurCrystalCount)
            if savedata.sulfurCrystalCount >= 5-mult then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_SULFUR, UseFlag.USE_NOANIM, -1)
                savedata.sulfurCrystalCount = 0
            end
        end
    end
end