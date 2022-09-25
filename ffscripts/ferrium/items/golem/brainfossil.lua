local mod = FiendFolio

function mod:brainFossilOnFireTear(player, tear)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BRAIN_FOSSIL) then
		if not tear:HasTearFlags(TearFlags.TEAR_HOMING) then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BRAIN_FOSSIL)
			tear:GetData().brainFossilHoming = player.TearRange/20*mult
			tear:AddTearFlags(TearFlags.TEAR_HOMING)
			tear.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	local data = tear:GetData()
	if data.brainFossilHoming then
		if data.brainFossilHoming > 0 then
			data.brainFossilHoming = data.brainFossilHoming-1
		else
			data.brainFossilHoming = nil
			tear:ClearTearFlags(TearFlags.TEAR_HOMING)
			tear.Color = Color(1,1,1,1,0,0,0)
		end
	end
end)