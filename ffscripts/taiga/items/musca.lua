-- Musca --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:muscaPostFireBomb(player, bomb)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MUSCA) then
		bomb:GetData().FFLocustBomb = true
		bomb:GetData().FFLocustPlayer = player
	end
end

function mod:muscaBombsPostFireRocket(player, rocket)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MUSCA) then
		rocket:GetData().FFLocustBomb = true
		rocket:GetData().FFLocustPlayer = player
	end
end

-- https://www.geeksforgeeks.org/check-if-any-point-overlaps-the-given-circle-and-rectangle/
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if explosion.SpawnerEntity and 
	   explosion.SpawnerEntity:GetData().FFLocustBomb and
	   not explosion.SpawnerEntity:GetData().FFLocustHasExploded
	then
		local boomie = explosion.SpawnerEntity
			
		if (boomie:ToBomb() and not boomie:ToBomb().IsFetus) or #(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)) < 6 then 
			local player = boomie:GetData().FFLocustPlayer
			if not player or not player:Exists() then player = Isaac.GetPlayer(0) end
			
			local randAngle = math.random(360)
			local angles = {Vector.FromAngle(randAngle)}
			if boomie:ToBomb() and not boomie:ToBomb().IsFetus and boomie:ToBomb().RadiusMultiplier > 0.65 then 
				angles = {Vector.FromAngle(randAngle), Vector.FromAngle(randAngle + 120), Vector.FromAngle(randAngle + 240)} 
			end
		
			for _, angle in ipairs(angles) do
				local subt = boomie:GetDropRNG():RandomInt(5) + 1
				local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subt, boomie.Position, angle:Resized(10), player):ToFamiliar()
				locust.Player = player
				locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				locust:Update()
			end
		end
		
		boomie:GetData().FFLocustHasExploded = true
	end
end, EffectVariant.BOMB_EXPLOSION)

FiendFolio.AddItemPickupCallback(function(player, added)
	player:AddBombs(3)
end, nil, FiendFolio.ITEM.COLLECTIBLE.MUSCA)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, source, countdown)
	ent:GetData().LastDamageWasFly = source.Entity and source.Entity.Type == EntityType.ENTITY_FAMILIAR and source.Entity.Variant == FamiliarVariant.BLUE_FLY
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MUSCA) then
    	local luck = player.Luck
    	luck = luck < 0 and 0 or luck
    	luck = luck > 20 and 20 or luck
    	for _, n in pairs(Isaac.GetRoomEntities()) do
    		if n:IsEnemy() and 
			   n:IsDead() and 
			   not (n:GetData().CheckedMusca or 
			        n:GetData().LastDamageWasFly or 
			        (n.Type == mod.FFID.Tech and n.Variant > 999)) 
			then
    			if math.random(100) <= 100/6 + (luck * (100/3 - 100/6)/20) then
					local subt = n:GetDropRNG():RandomInt(5) + 1
					local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subt, n.Position, nilvector, player):ToFamiliar()
					locust.Player = player
					locust:Update()
    			end
    			n:GetData().CheckedMusca = true
    		end
    	end
    end
end)
