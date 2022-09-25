local mod = FiendFolio
local game = Game()
local twoOfCups = mod.ITEM.CARD.TWO_OF_CUPS

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	local room = game:GetRoom()
	
	local numPills = Isaac.CountEntities(nil, 5, 70)
	local playerPills = {}
	local hasPill = false

	for i = 0, 3 do
		local pill = player:GetPill(i)
		if pill > 0 then
			table.insert(playerPills, pill)
			hasPill = true
		end
	end

	if hasPill or numPills > 0 then
		for _, pill in pairs(Isaac.FindByType(5, 70)) do
			Isaac.Spawn(5, 70, pill.SubType, room:FindFreePickupSpawnPosition(pill.Position), Vector.Zero, player)
		end

		for _, pillColour in pairs(playerPills) do
			Isaac.Spawn(5, 70, pillColour, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
		end
	else
		for i = 1, 2 do
			Isaac.Spawn(5, 70, 0, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
		end
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingTwoCups, flags, 40)
end, twoOfCups)