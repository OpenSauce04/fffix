local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Cake mostly handled the Queen o' Clubs
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	if not player:HasCollectible(52,false) then
	 savedata.playerThatUsedQueenClubs = player
	 player:AddItemWisp(52,Vector(1200,600),false)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingQueenClubs, flags)
end, Card.QUEEN_OF_CLUBS)

--Queen of Clubs Wisp
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
	 for _, wisp in ipairs(Isaac.FindByType(3, 237, 52, false, false)) do
		local savedata = Isaac.GetPlayer():GetData().ffsavedata
		if savedata.playerThatUsedQueenClubs ~= nil then
		 wisp.Visible = false
		 wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		 wisp.Position = Vector(1900,1900)
		 wisp:ToFamiliar():RemoveFromOrbit()
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	 for _, wisp in ipairs(Isaac.FindByType(3, 237, 52, false, false)) do
		local savedata = wisp:ToFamiliar().Player:GetData().ffsavedata
		if savedata.playerThatUsedQueenClubs ~= nil then
		 wisp:Remove()
		 wisp:Kill()
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local r = player:GetCardRNG(cardID)
	for i = 0, r:RandomInt(10) do
		mod.scheduleForUpdate(function()
			local room = Game():GetRoom()
			local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position)), 20)
			Isaac.Spawn(5, 30, 1, spawnpos + RandomVector()*math.random(20), nilvector, nil)
		end, i)
	end
end, Card.QUEEN_OF_SPADES)

mod.QueenOfDiamonds_SellableGrids = {
	Expensive = {
		[GridEntityType.GRID_ROCKT] = true,
		[GridEntityType.GRID_ROCK_SS] = true,
		[GridEntityType.GRID_ROCK_GOLD] = true,
	},
	Normal ={
		[GridEntityType.GRID_ROCK] = true,
		[GridEntityType.GRID_ROCKB] = true,
		[GridEntityType.GRID_ROCK_BOMB] = true,
		[GridEntityType.GRID_ROCK_ALT] = true,

		[GridEntityType.GRID_SPIDERWEB] = true,
		[GridEntityType.GRID_LOCK] = true,
		[GridEntityType.GRID_POOP] = true,

		[GridEntityType.GRID_PILLAR] = true,
		[GridEntityType.GRID_ROCK_SPIKED] = true,
	}
}

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
    local room = Game():GetRoom()

	local newGrids = {}
	for i=0, room:GetGridSize() do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local gridpos = room:GetGridPosition(i)
			local desc = gridEntity.Desc.Type
			local pickup
			if mod.QueenOfDiamonds_SellableGrids.Expensive[gridEntity.Desc.Type] then
				pickup = Isaac.Spawn(5, 20, 2, gridpos, nilvector, nil):ToPickup()
			elseif mod.QueenOfDiamonds_SellableGrids.Normal[gridEntity.Desc.Type] then
				pickup = Isaac.Spawn(5, 20, 1, gridpos, nilvector, nil):ToPickup()
			end
			if pickup then
				pickup.Timeout = 150
				room:RemoveGridEntity(i, 0, false)
				table.insert(newGrids, i)
			end
		end
	end

	if #newGrids > 0 then
		--print(#newGrids)
		sfx:Play(SoundEffect.SOUND_CASH_REGISTER,1,0,false,0.8)
		for i = 1, #newGrids do
			for k = 1, 3 do
				mod.scheduleForUpdate(function()
					room:SpawnGridEntity(newGrids[i], GridEntityType.GRID_DECORATION, 0, 0, 0)
				end, k)
			end
		end
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingQueenDiamonds, flags, 30)
end, Card.QUEEN_OF_DIAMONDS)