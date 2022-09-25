local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	local someoneHasFiendsHorn
	mod.AnyPlayerDo(function(player)
		if player:HasCollectible(mod.ITEM.COLLECTIBLE.FIENDS_HORN) then
			someoneHasFiendsHorn = player
		end 
	end)

	if someoneHasFiendsHorn then
		local player = someoneHasFiendsHorn
		local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.FIENDS_HORN)

		local immoralityBonus = 0.025 * mod.GetImmoralHeartsNum(player)
		local chance = 0.2 + mod.XalumLuckBonus(player.Luck, 14, 0.15) + immoralityBonus

		if rng:RandomFloat() < chance then
			local minion = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, npc.Position, Vector.Zero, player)
			minion.EntityCollisionClass = 4
			minion.Parent = player

			local data = minion:GetData()
			data.hollow = true
			data.canreroll = false
		end
	end
end)