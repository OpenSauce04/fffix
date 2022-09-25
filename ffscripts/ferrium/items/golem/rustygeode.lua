local mod = FiendFolio

function mod:rustyGeodeUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.RUSTY_GEODE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.RUSTY_GEODE)
		
		local queuedItem = player.QueuedItem
		local data = player:GetData().ffsavedata
		local runData = data.RunEffects
		
		if queuedItem.Item ~= nil and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.RUSTY_GEODE and not queuedItem.Touched then
			if not data.rustyGeodeUpdate then
				data.rustyGeodeUpdate = true
				if mult > 1 then
					runData.rustyGeodeBonus = 8*mult
				else
					runData.rustyGeodeBonus = 8
				end
			end
		else
			data.rustyGeodeUpdate = nil
		end
		
		if not runData.rustyGeodeBonus then
			runData.rustyGeodeBonus = 0
		end
		
		local decay = 0.002
		if mod.HasTwoGeodes(player) then
			decay = 0.0008
		end
		
		if runData.rustyGeodeBonus > 0 then
			runData.rustyGeodeBonus = runData.rustyGeodeBonus-decay
			if runData.rustyGeodeBonus < 0 then
				runData.rustyGeodeBonus = 0
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end