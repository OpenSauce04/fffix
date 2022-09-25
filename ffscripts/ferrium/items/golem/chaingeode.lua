local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:chainGeodeUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CHAIN_GEODE) then
		local room = game:GetRoom()
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHAIN_GEODE)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHAIN_GEODE)
		local validTypes = {2, 4, 5, 6, 22, 25, 26, 27}
		
		local queuedItem = player.QueuedItem
		local data = player:GetData().ffsavedata

		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.CHAIN_GEODE then
			if not data.chainGeodeUpdate then
				mod.setRockTable()
				data.chainGeodeUpdate = true
			end
		else
			data.chainGeodeUpdate = nil
		end
		
		for _,grid in ipairs(mod.GetGridEntities()) do
			if mod.chainGeodeRocks[grid:GetGridIndex()] ~= nil then
				if grid:GetType() == 7 and mod.chainGeodeRocks[grid:GetGridIndex()] == 7 and grid.State == 1 then
					mod.chainGeodeRocks[grid:GetGridIndex()] = nil
					for i=90,360,90 do
						local chained = room:GetGridEntityFromPos(grid.Position+Vector(40,0):Rotated(i))
						if chained then
							for i=1, #validTypes do
								if chained:GetType() == validTypes[i] then
									if mod.HasTwoGeodes(player) then
										if rng:RandomInt(100) < 50+20*mult then
											mod.chainGeodeScheduled[chained:GetGridIndex()] = {["grid"] = chained, ["mode"] = 1, ["countdown"] = 2}
										end
									else
										if rng:RandomInt(100) < 20+20*mult then
											mod.chainGeodeScheduled[chained:GetGridIndex()] = {["grid"] = chained, ["mode"] = 1, ["countdown"] = 2}
										end
									end
								end
							end
							if chained:GetType() == 7 and mod.HasTwoGeodes(player) then
								if rng:RandomInt(100) < 10+10*mult then
									mod.chainGeodeScheduled[chained:GetGridIndex()] = {["grid"] = chained, ["mode"] = 2, ["countdown"] = 2}
								end
							end
						end
					end
				elseif grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
					mod.chainGeodeRocks[grid:GetGridIndex()] = nil
					for i=90,360,90 do
						local chained = room:GetGridEntityFromPos(grid.Position+Vector(40,0):Rotated(i))
						if chained then
							for i=1, #validTypes do
								if chained:GetType() == validTypes[i] then
									if mod.HasTwoGeodes(player) then
										if rng:RandomInt(100) < 50+20*mult then
											mod.chainGeodeScheduled[chained:GetGridIndex()] = {["grid"] = chained, ["mode"] = 1, ["countdown"] = 2}
										end
									else
										if rng:RandomInt(100) < 20+20*mult then
											mod.chainGeodeScheduled[chained:GetGridIndex()] = {["grid"] = chained, ["mode"] = 1, ["countdown"] = 2}
										end
									end
								end
							end
							if chained:GetType() == 7 and mod.HasTwoGeodes(player) then
								if rng:RandomInt(100) < 10+10*mult then
									mod.chainGeodeScheduled[chained:GetGridIndex()] = {["grid"] = chained, ["mode"] = 2, ["countdown"] = 2}
								end
							end
						end
					end
				end
			end
		end
	end
end

--[[function mod.setChainGeodeTable()
	mod.chainGeodeRocks = {}
	local validTypes = {2, 4, 5, 6, 22, 25, 26, 27}
	for _,grid in ipairs(mod.GetGridEntities()) do
		if grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
			for i=1,#validTypes do
				if grid:GetType() == validTypes[i] then
					mod.chainGeodeRocks[grid:GetGridIndex()] = 0
				end
			end
		end
		if grid:GetType() == 7 and grid.State == 0 then
			mod.chainGeodeRocks[grid:GetGridIndex()] = 1
		end
	end
end]]

function mod:chainGeodeDestroy(entry)
	if entry.countdown > 0 then
		entry.countdown = entry.countdown-1
	elseif entry.grid then
		if entry.mode == 1 then
			entry.grid:Destroy()
			Isaac.Spawn(1000,15,0, entry.grid.Position, Vector.Zero, nil)
		elseif entry.mode == 2 then
			entry.grid:ToPit():MakeBridge(entry.grid)
			Isaac.Spawn(1000,15,0, entry.grid.Position, Vector.Zero, nil)
		end
		sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.5, 0, false, 1)
		entry.grid = nil
		entry = nil
	end
end