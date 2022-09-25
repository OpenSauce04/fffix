local mod = FiendFolio

function mod:deathCapFossilReset(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.DEATH_CAP_FOSSIL) then
		local queuedItem = player.QueuedItem

		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.DEATH_CAP_FOSSIL then
			player:GetData().ffsavedata.RunEffects.DeathCapFossilCount = 0
		end
	end
end