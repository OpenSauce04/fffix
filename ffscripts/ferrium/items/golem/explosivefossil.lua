local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_,t,v,s, index, seed, seed)
	local room = game:GetRoom()
	if room:IsFirstVisit() then
		if t == 1000 and v == 0 and s == 0 then
			for i = 1, game:GetNumPlayers() do
				local p = Isaac.GetPlayer(i - 1)
				if p:HasTrinket(FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL) then
					if room:GetGridPosition(index):Distance(p.Position) > 100 then
						local rng = p:GetTrinketRNG(FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL)
						local mult = mod.GetGolemTrinketPower(p, FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL)
						local chance = 10+10*mult
						
						if rng:RandomInt(100) < chance then
							return {1001, 0, 0}
						end
					end
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	--[[local room = game:GetRoom()
	if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL, true) then
		for _,grid in ipairs(mod.GetGridEntities()) do
			if grid:GetType() == GridEntityType.GRID_ROCK then
				local safe = true
				for _,player in ipairs(Isaac.FindByType(1,-1,-1, false, false)) do
					if grid.Position:Distance(player.Position) < 100 then
						safe = false
					end
				end
				if safe == true then
					grid:SetType(GridEntityType.GRID_ROCK_BOMB)
					grid:ToRock():UpdateAnimFrame()
					grid:Update()
					grid:Update()
				end
			end
		end
		for _,grid in ipairs(mod.GetGridEntities()) do
			if grid:GetType() == GridEntityType.GRID_ROCK then
				grid:ToRock():UpdateAnimFrame()
				grid:Update()
			end
		end
	end]]
	for i = 1, game:GetNumPlayers() do
        local p = Isaac.GetPlayer(i - 1)
		local data = p:GetData()
		local room = game:GetRoom()
		
		if data.ffsavedata.RunEffects.MamaMegaBlasts and data.ffsavedata.RunEffects.MamaMegaBlasts > 0 and not room:IsClear() then
			data.ffsavedata.RunEffects.MamaMegaBlasts = data.ffsavedata.RunEffects.MamaMegaBlasts-1
			local BOOM = Isaac.Spawn(1000, 127, 0, p.Position, Vector.Zero, p):ToEffect()
			BOOM.Parent = p
			BOOM.TargetPosition = p.Position
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, dropRNG, spawnPos)
	local room = game:GetRoom()
	spawnPos = room:FindFreePickupSpawnPosition(spawnPos, 10, true)
	
	local roomtype = room:GetType()
	if roomtype == RoomType.ROOM_DEFAULT then
		for i=1, game:GetNumPlayers() do
			local p = Isaac.GetPlayer(i - 1)
			
			if p:HasTrinket(FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL) then
				local rng = p:GetTrinketRNG(FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL)
				local mult = mod.GetGolemTrinketPower(p, FiendFolio.ITEM.ROCK.EXPLOSIVE_FOSSIL)
				local chance = 8+5*mult
				
				if rng:RandomInt(100) < chance then
					Isaac.Spawn(5, 40, 0, spawnPos, Vector.Zero, nil)
				end
			end
		end
	end
end)