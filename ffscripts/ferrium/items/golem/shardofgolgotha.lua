local mod = FiendFolio
local game = Game()

function mod:shardOfGolgothaNewRoom()
	local room = game:GetRoom()
	if not room:IsClear() then
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i-1)
			if player:HasTrinket(FiendFolio.ITEM.ROCK.SHARD_OF_GOLGOTHA) then
				FiendFolio.scheduleForUpdate(function()
					local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHARD_OF_GOLGOTHA)
					local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SHARD_OF_GOLGOTHA)
					
					local health = 0
					local chosen = nil
					for _, enemy in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
						if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
							if enemy.HitPoints > health then
								chosen = enemy
								health = enemy.HitPoints
							end
						end
					end
					
					if chosen then
						local chain = Isaac.Spawn(1000, 193, 0, chosen.Position, Vector.Zero, player):ToEffect()
						chain:SetTimeout(math.floor(200*mult))
						chain.Parent = player
						chain.Target = chosen
					end
				end, 2)
			end
		end
	end
end