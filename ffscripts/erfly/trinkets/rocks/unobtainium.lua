local mod = FiendFolio
function mod:unobtainiumPlayerUpdate(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.UNOBTAINIUM) then
        while player:HasTrinket(FiendFolio.ITEM.ROCK.UNOBTAINIUM) do
            player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.UNOBTAINIUM)
        end
    end
end