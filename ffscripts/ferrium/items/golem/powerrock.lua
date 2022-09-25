local mod = FiendFolio

function mod:powerRockUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.POWER_ROCK) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.POWER_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.POWER_ROCK)
		local chance = math.min(25, 2.5+2.5*mult+player.Luck)
		local queuedItem = player.QueuedItem
		
		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.POWER_ROCK then
			if not data.powerRockUpdate then
				mod.setRockTable()
				data.powerRockUpdate = true
			end
		else
			data.powerRockUpdate = nil
		end
		
		for _,grid in ipairs(mod.GetGridEntities()) do
			if mod.powerRockRocks[grid:GetGridIndex()] ~= nil then
				if grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
					mod.powerRockRocks[grid:GetGridIndex()] = nil
					if rng:RandomInt(100) < chance then
						if player:NeedsCharge(ActiveSlot.SLOT_PRIMARY) then
                            player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)+1, ActiveSlot.SLOT_PRIMARY)
                        elseif player:NeedsCharge(ActiveSlot.SLOT_POCKET) then
                            player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_POCKET)+1, ActiveSlot.SLOT_POCKET)
                        elseif player:NeedsCharge(ActiveSlot.SLOT_SECONDARY) then
                            player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY)+1, ActiveSlot.SLOT_SECONDARY)
                        end
					end
				end
			end
		end
	end
end
