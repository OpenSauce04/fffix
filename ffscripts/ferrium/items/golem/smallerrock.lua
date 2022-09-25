local mod = FiendFolio

function mod:smallerRockUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SMALLER_ROCK) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SMALLER_ROCK)
		local queuedItem = player.QueuedItem
		
		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.SMALLER_ROCK then
			if not data.smallerRockUpdate then
				mod.setRockTable()
				data.smallerRockUpdate = true
			end
		else
			data.smallerRockUpdate = nil
		end
		
		for _,grid in ipairs(mod.GetGridEntities()) do
			if mod.smallerRockRocks[grid:GetGridIndex()] ~= nil then
				if grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
					mod.smallerRockRocks[grid:GetGridIndex()] = nil
					data.ffsavedata.RunEffects.smallerRockCount = (data.ffsavedata.RunEffects.smallerRockCount or 0)+mult
                    player:AnimateHappy()
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED)
                    player:EvaluateItems()
				end
			end
		end
	end
end
