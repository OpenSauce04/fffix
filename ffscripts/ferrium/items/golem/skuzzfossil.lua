local mod = FiendFolio
local game = Game()

function mod:skuzzFossilNewRoom()
	local room = game:GetRoom()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SKUZZ_FOSSIL) then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SKUZZ_FOSSIL)
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SKUZZ_FOSSIL)
			
			if room:IsFirstVisit() and not room:IsClear() then
				local bonusFlea = rng:RandomInt(2)
				for i=1,1+bonusFlea+mult do
					local flea = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ATTACK_SKUZZ, 3, player.Position, Vector.Zero, player):ToFamiliar()
					flea.Player = player
					flea:Update()
				end
			end
		end
	end
end