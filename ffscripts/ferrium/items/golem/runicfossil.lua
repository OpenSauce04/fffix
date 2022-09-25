local mod = FiendFolio
local sfx = SFXManager()

mod.runicFossilTable = {Card.RUNE_ANSUS, Card.SOUL_OF_GOLEM, Card.SOUL_OF_FIEND, Card.SOUL_OF_RANDOM, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92, 93, 94, 95, 96, 97}
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.RUNIC_FOSSIL) then
		local mult = math.max(1,math.floor(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.RUNIC_FOSSIL)))
		
		for i=1,#mod.runicFossilTable do
			if card == mod.runicFossilTable[i] then
				sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.25, 0, false, 3)
				for i=1,mult do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.RUNE_SHARD, player.Position, RandomVector()*5, player)
				end
			end
		end
	end
end)