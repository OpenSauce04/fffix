local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
	local wackyLimiter = true
	for i=0,3 do
		if player:GetActiveItem(i) == FiendFolio.ITEM.COLLECTIBLE.ETERNAL_CLICKER then
			wackyLimiter = false
		end
	end
	
	if rng:RandomInt(2) == 1 or wackyLimiter == true then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER, UseFlag.USE_NOANIM, -1)
	else
		Isaac.Spawn(1000,15,0,player.Position, Vector.Zero, nil)
		local data = player:GetData().ffsavedata
		for i=1,player:GetCollectibleCount()+5 do
			player:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER, UseFlag.USE_NOANIM, -1)
		end
		player:RemoveCollectible(FiendFolio.ITEM.COLLECTIBLE.ETERNAL_CLICKER)
		data.eternalClickeredBozo = true
		player:ChangePlayerType(PlayerType.PLAYER_ISAAC)
		player:AddMaxHearts(40, false)
		player:AddMaxHearts(-40, false)
		for _,fly in ipairs(Isaac.FindByType(3, 43, -1, false, false)) do
			fly:Remove()
		end
	end
end, FiendFolio.ITEM.COLLECTIBLE.ETERNAL_CLICKER)

function mod:eternalClickerUpdate(player)
	local data = player:GetData().ffsavedata
	if data.eternalClickeredBozo == true then
		player.Visible = false
		player.ControlsEnabled = false
		player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, save)
	for i = 1, game:GetNumPlayers() do
		local p = Isaac.GetPlayer(i - 1)
		local data = p:GetData().ffsavedata
		if data.eternalClickeredBozo == true then
			p:ChangePlayerType(PlayerType.PLAYER_EDEN_B)
			p:AddMaxHearts(40, true)
			p:AddHearts(10)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
	if continued then
		for i = 1, game:GetNumPlayers() do
			local p = Isaac.GetPlayer(i - 1)
			local data = p:GetData().ffsavedata
			if data.eternalClickeredBozo == true then
				p:ChangePlayerType(PlayerType.PLAYER_ISAAC)
				p:AddMaxHearts(-40, true)
				p.Visible = false
				p.ControlsEnabled = false
				p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		end
	end
end)