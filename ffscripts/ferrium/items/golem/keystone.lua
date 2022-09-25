local mod = FiendFolio
local game = Game()

function mod:keystoneUpdate(player, basedata)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.KEYSTONE) then
		local room = game:GetRoom()
		local queuedItem = player.QueuedItem
		local data = player:GetData().ffsavedata.RunEffects

		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.KEYSTONE and not queuedItem.Touched then
			if not data.keyStoneTouched then
				Isaac.Spawn(5, 30, 1, room:FindFreePickupSpawnPosition(player.Position, 0, true, false), Vector.Zero, player)
				data.keyStoneTouched = true
			end
		else
			data.keyStoneTouched = nil
		end
	
		local data = basedata.ffsavedata.RunEffects
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.KEYSTONE)
		if not data.keystoneCount then
			data.keystoneCount = 0
			data.keystoneNumber = player:GetNumKeys()
		end
		if player:GetNumKeys() < data.keystoneNumber then
			data.keystoneCount = data.keystoneCount + (data.keystoneNumber-player:GetNumKeys())
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
		end
		data.keystoneNumber = player:GetNumKeys()
	end
end

function mod:keystoneNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:GetData().ffsavedata.RunEffects.keystoneCount then
			player:GetData().ffsavedata.RunEffects.keystoneCount = 0
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
		end
	end
end