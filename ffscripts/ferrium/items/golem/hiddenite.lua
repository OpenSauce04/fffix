local mod = FiendFolio

function mod:hiddeniteUpdate(player)
    if player:HasTrinket(mod.ITEM.ROCK.HIDDENITE) then
        local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HIDDENITE)
        local room = Game():GetRoom()
        for _,entity in ipairs(Isaac.FindInRadius(player.Position, 500, EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				local data = entity:GetData()
                if not data.hiddeniteTriggered then
                    local check = room:CheckLine(player.Position, entity.Position, 3, 0, false, false)
                    if not data.hiddeniteSetup then
                        if check then
                            data.hiddeniteSetup = true
                        end
                    else
                        if not check then
                            data.hiddeniteTriggered = true
                            entity:AddConfusion(EntityRef(player), math.max(60, math.floor(80*mult)), false)
                        end
                    end
                end
			end
		end
    end
end