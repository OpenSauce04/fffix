local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	for i = 1, math.random(2,4) do
		local rand = math.random(4) * 90
		mod.scheduleForUpdate(function()
			local room = Game():GetRoom()
			local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position + Vector(0, -40) + Vector(40, 0):Rotated(rand + (i * 90)))), 20)
			Isaac.Spawn(5, 20, CoinSubType.COIN_CURSEDPENNY, spawnpos + RandomVector()*math.random(20), nilvector, nil)
		end, i)
	end
	for _, pickup in ipairs(Isaac.FindByType(5, 20, 1, false, false)) do
		pickup:ToPickup():Morph(5, 20, CoinSubType.COIN_CURSEDPENNY, true)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingJackDiamonds, flags, 50)
end, mod.ITEM.CARD.JACK_OF_DIAMONDS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local room = game:GetRoom()
	for i = 1, math.random(2,3) do
		local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position + Vector(0, -40))), 20)
		Isaac.Spawn(5, 40, FiendFolio.PICKUP.BOMB.COPPER, spawnpos, Vector.Zero, nil)
	end

	for _, pickup in ipairs(Isaac.FindByType(5, 40, -1, false, false)) do
		if pickup.SubType ~= BombSubType.BOMB_NORMAL then
			pickup:ToPickup():Morph(5, 40, FiendFolio.PICKUP.BOMB.COPPER, true)
		end
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingJackClubs, flags, 50)
end, mod.ITEM.CARD.JACK_OF_CLUBS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local room = game:GetRoom()
	local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position + Vector(0, -40))), 20)
	Isaac.Spawn(5, 40, BombSubType.BOMB_GOLDENTROLL, spawnpos, Vector.Zero, nil)

	for _, pickup in ipairs(Isaac.FindByType(5, 40, -1, false, false)) do
		if pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
			pickup:ToPickup():Morph(5, 40, BombSubType.BOMB_SUPERTROLL, true)
		elseif pickup.SubType == BombSubType.BOMB_GOLDEN then
			pickup:ToPickup():Morph(5, 40, BombSubType.BOMB_GOLDENTROLL, true)
		else
			if not (pickup.SubType == BombSubType.BOMB_TROLL or pickup.SubType == BombSubType.BOMB_SUPERTROLL or pickup.SubType == BombSubType.BOMB_GOLDENTROLL) then
				pickup:ToPickup():Morph(5, 40, BombSubType.BOMB_TROLL, true)
			end
		end
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingJackClubs, flags, 50)
end, mod.ITEM.CARD.MISPRINTED_JACK_OF_CLUBS)

--Taiga mostly did this one I believe
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local playertype = player:GetPlayerType()
	if playertype == PlayerType.PLAYER_THELOST or
	   playertype == PlayerType.PLAYER_THELOST_B or
	   playertype == PlayerType.PLAYER_KEEPER or
	   playertype == PlayerType.PLAYER_KEEPER_B or
	   playertype == PlayerType.PLAYER_BETHANY or
	   playertype == FiendFolio.PLAYER.BIEND
	then
		Isaac.Spawn(5, 1024, 0, Game():GetRoom():FindFreePickupSpawnPosition(player.Position+RandomVector():Resized(40)), Vector.Zero, nil)
	else
		local p = player
		if p:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			if p:GetOtherTwin() ~= nil then
				p = p:GetOtherTwin()
			end
		end
		
		if CustomHealthAPI.Helper.PlayerIsIgnored(p) then
			Isaac.Spawn(5, 1024, 0, Game():GetRoom():FindFreePickupSpawnPosition(player.Position+RandomVector():Resized(40)), Vector.Zero, nil)
			return
		end
		
		local hearts = CustomHealthAPI.Library.GetHealthInOrder(p)
		local hasConverted = false
		for i = #hearts, 1, -1 do
			local health = hearts[i]
			local key = health.Other.Key
			local typeOfKey = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
			
			if typeOfKey == CustomHealthAPI.Enums.HealthTypes.SOUL and key ~= "IMMORAL_HEART" then
				CustomHealthAPI.Library.TryConvertOtherKey(p, i, "IMMORAL_HEART", true)
				hasConverted = true
			end
		end
	
		if not hasConverted then
		 Isaac.Spawn(5, 1024, 0, Game():GetRoom():FindFreePickupSpawnPosition(player.Position+RandomVector():Resized(40)), Vector.Zero, nil)
		end
	end

	for _, pickup in ipairs(Isaac.FindByType(5, 10, 2, false, false)) do
		pickup:ToPickup():Morph(5, 1025, 0, true)
	end
	for _, pickup in ipairs(Isaac.FindByType(5, 10, 1, false, false)) do
		pickup:ToPickup():Morph(5, 1024, 0, true)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingJackHearts, flags, 50)
end, mod.ITEM.CARD.JACK_OF_HEARTS)

--Old jack of hearts, now a cool Cake card :)
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	--Isaac.Spawn(5, 10, 9, Game():GetRoom():FindFreePickupSpawnPosition(player.Position+RandomVector():Resized(40)), Vector.Zero, nil)
	--player:AddItemWisp(446, player.Position, false)
	local heartCount = player:GetHearts()
	player:AddRottenHearts(10)
	SFXManager():Play(SoundEffect.SOUND_POISON_HURT,1,1,false,1.2)
	--Special EFFECS
	local rottencolor = Color(1,1,1,1,0,0,0)
	rottencolor:SetColorize(0, 1, 0.5, 1)
	local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 17, 0, player.Position, Vector(0,0), player);
	eff:SetColor(rottencolor, 99999, 1, false, false)
	eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2, 3, player.Position, Vector(0,0), player);
	eff:SetColor(rottencolor, 99999, 1, false, false)
	for i = 1, 4 do
		eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 5, 0, player.Position, Vector(0,0), player);
		eff:SetColor(rottencolor, 99999, 1, false, false)
	end
	for i = 1, 4 do
		eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 7, 0, player.Position, Vector(0,0), player);
		eff:SetColor(rottencolor, 99999, 1, false, false)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlagueofDecay, flags, 20)
end, mod.ITEM.CARD.PLAGUE_OF_DECAY)


mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	for i = 1, math.random(1,2) do
		local rand = math.random(4) * 90
		mod.scheduleForUpdate(function()
			local room = Game():GetRoom()
			local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position + Vector(0, -40) + Vector(40, 0):Rotated(rand + (i * 90)))), 20)
			Isaac.Spawn(5, 30, KeySubType.KEY_SPICY_PERM, spawnpos + RandomVector()*math.random(20), nilvector, nil)
		end, i)
	end
	for _, pickup in ipairs(Isaac.FindByType(5, 30, KeySubType.KEY_NORMAL, false, false)) do
		pickup:ToPickup():Morph(5, 30, KeySubType.KEY_SPICY_PERM, true)
	end
	for _, pickup in ipairs(Isaac.FindByType(5, 30, KeySubType.KEY_DOUBLEPACK, false, false)) do
		pickup:ToPickup():Morph(5, 30, KeySubType.KEY_SUPERSPICY_PERM, true)
	end
	for _, pickup in ipairs(Isaac.FindByType(5, 30, KeySubType.KEY_CHARGED, false, false)) do
		pickup:ToPickup():Morph(5, 30, KeySubType.KEY_CHARGEDSPICY_PERM, true)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingJackSpades, flags, 50)
end, mod.ITEM.CARD.JACK_OF_SPADES)