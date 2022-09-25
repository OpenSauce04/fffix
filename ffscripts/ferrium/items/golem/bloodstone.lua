local mod = FiendFolio

function mod:bloodstoneUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOODSTONE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOODSTONE)
		local bonus = 0
		for _, n in pairs(Isaac.GetRoomEntities()) do
    		if n:IsActiveEnemy(true) and 
			   n:IsDead() and 
			   not (n:GetData().CheckedBloodstone or 
			        (n.Type == mod.FFID.Tech and n.Variant > 999)) 
			then
				bonus = bonus+0.2*mult
    			n:GetData().CheckedBloodstone = true
    		end
    	end
		if not data.bloodstoneBonus then data.bloodstoneBonus = 0 end
		data.bloodstoneBonus = data.bloodstoneBonus+bonus
		if data.bloodstoneBonus > 0 then
			data.bloodstoneBonus = data.bloodstoneBonus-0.0025
			if data.bloodstoneBonus < 0 then
				data.bloodstoneBonus = 0
			elseif data.bloodstoneBonus > 8*mult then
				data.bloodstoneBonus = 8*mult
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

function mod:bloodstoneDamage(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOODSTONE) then
		local data = player:GetData()
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOODSTONE)
		if not data.bloodstoneBonus then data.bloodstoneBonus = 0 end
		data.bloodstoneBonus = data.bloodstoneBonus+1*mult
	end
end