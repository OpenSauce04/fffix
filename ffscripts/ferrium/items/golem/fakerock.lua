local mod = FiendFolio
local game = Game()

function mod:fakeRockUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FAKE_ROCK) then
		local room = game:GetRoom()
		local roomIndex = game:GetLevel():GetCurrentRoomIndex()
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FAKE_ROCK)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FAKE_ROCK)
		local validTypes = {2, 4, 5, 6, 22, 25, 26, 27}
		
		local queuedItem = player.QueuedItem
		local data = player:GetData().ffsavedata

		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.FAKE_ROCK then
			if not data.fakeRockUpdate then
				mod.setRockTable()
				data.fakeRockUpdate = true
				if not queuedItem.Touched then
					Isaac.Spawn(5, 30, 1, room:FindFreePickupSpawnPosition(player.Position, 0, true, false), Vector.Zero, player)
				end
			end
		else
			data.fakeRockUpdate = nil
		end
		if data.fakeRockRooms == nil then
			data.fakeRockRooms = {}
		end
		
		local doors = {}
		for i = 0, 8 do
			local d = room:GetDoor(i)
			if d then
				if d:GetVariant() == 1 then
					table.insert(doors, 1)
				elseif d:GetVariant() == 2 then
					if d.State == 3 then
						table.insert(doors, 1)
					else
						table.insert(doors, 3)
					end
				end
			end
		end
		
		if #doors > 0 and data.fakeRockRooms[roomIndex] ~= nil then
			local rockRoom = data.fakeRockRooms[roomIndex]
			if rockRoom[1] > 0 then
				for _,grid in ipairs(mod.GetGridEntities()) do
					if mod.fakeRockRocks[grid:GetGridIndex()] ~= nil then
						if grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
							local rockTable = rockRoom[2]
							Isaac.Spawn(5, 30, rockTable[1], grid.Position, Vector.Zero, player)
							table.remove(data.fakeRockRooms[roomIndex][2], 1)
							if #rockTable == 0 then
								data.fakeRockRooms[roomIndex] = {0, {}}
								mod.fakeRockRocks = {}
							end
						end
					end
				end
			end
		elseif #doors > 0 and data.fakeRockRooms[roomIndex] == nil then
			for _,grid in ipairs(mod.GetGridEntities()) do
				if mod.fakeRockRocks[grid:GetGridIndex()] ~= nil then
					if grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
						Isaac.Spawn(5, 30, #doors, grid.Position, Vector.Zero, player)
						table.remove(#doors, 1)
					end
				end
			end
			data.fakeRockRooms[roomIndex] = {1, doors}
		else
			data.fakeRockRooms[roomIndex] = {0, {}}
			mod.fakeRockRocks = {}
		end
	end
end

function mod:fakeRockNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		local data = player:GetData().ffsavedata
		
		data.fakeRockRooms = {}
	end
end