local mod = FiendFolio

function mod:bombSackFossilPostFireBomb(player, bomb)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BOMB_SACK_FOSSIL) then
		bomb:GetData().bombSackFossil = true
		bomb:GetData().bombSackFossilPlayer = player
	end
end

function mod:bombSackFossilPostFireRocket(player, target)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BOMB_SACK_FOSSIL) then
		target:GetData().bombSackFossil = true
		target:GetData().bombSackFossilPlayer = player
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if explosion.SpawnerEntity and 
	   explosion.SpawnerEntity:GetData().bombSackFossil and
	   not explosion.SpawnerEntity:GetData().bombSackFossilHasExploded
	then
		local boomie = explosion.SpawnerEntity
		
		local player = boomie:GetData().bombSackFossilPlayer
		if not player or not player:Exists() then player = Isaac.GetPlayer(0) end
		
		local crack = Isaac.Spawn(1000, 61, 114, boomie.Position, Vector.Zero, player):ToEffect()
		crack.Parent = player
		
		boomie:GetData().bombSackFossilHasExploded = true
	end
end, EffectVariant.BOMB_EXPLOSION)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,e)
	if e.SubType == 114 then
		if e.FrameCount > 10 then
			e:Remove()
		end
	end
end, 61)