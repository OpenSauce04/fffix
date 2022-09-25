local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
	local r = player:GetCardRNG(cardID)
	for _, pedestal in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1)) do
		if pedestal.SubType > 0 then
			local itemChoice = 0
			local outcome
			if r:RandomInt(5) == 1 then
				local pickupVar = 0
				local pickupSub = 0
				if r:RandomInt(3) == 1 then
					if r:RandomInt(3) == 1 then
						pickupVar = PickupVariant.PICKUP_ETERNALCHEST
						outcome = "Holy"
					else
						pickupVar = PickupVariant.PICKUP_REDCHEST
						outcome = "Devilish"
					end
				else
					pickupVar = PickupVariant.PICKUP_HEART
					local rand = r:RandomInt(10)
					if rand < 4 then
						pickupSub = HeartSubType.HEART_SOUL
						outcome = "Holy"
					elseif rand < 7 then
						pickupSub = HeartSubType.HEART_BLACK
						outcome = "Devilish"
					elseif rand < 8 then
						pickupSub = HeartSubType.HEART_ETERNAL
						outcome = "Holy"
					elseif rand < 9 then
						pickupSub = HeartSubType.HEART_HALF_SOUL
						outcome = "Holy"
					elseif rand < 10 then
						pickupSub = HeartSubType.HEART_BONE
						outcome = "Devilish"
					end
				end

				pedestal:ToPickup():Morph(EntityType.ENTITY_PICKUP, pickupVar, pickupSub, false, true, false)
			else
				local ItemPool = game:GetItemPool()
				if r:RandomInt(2) == 1 then
					itemChoice = ItemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, pedestal.InitSeed)
					outcome = "Devilish"
				else
					itemChoice = ItemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, pedestal.InitSeed)
					outcome = "Holy"
				end
				pedestal:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemChoice, true, true, false)
			end
			if outcome == "Holy" then
				local light = Isaac.Spawn(1000, 19, 0, pedestal.Position, nilvector, nil)
				light:Update()
				local blast = Isaac.Spawn(1000, 16, 1, pedestal.Position, nilvector, nil)
				blast:Update()
			elseif outcome == "Devilish" then
				local laser = Isaac.Spawn(7, 1, 0, pedestal.Position, nilvector, nil):ToLaser()
				laser:SetTimeout(10)
				laser.Angle = -90
				laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				laser.SpawnerType = 1
				laser:Update()
				local blast = Isaac.Spawn(1000, 16, 1, pedestal.Position, nilvector, nil)
				blast.Color = Color(0.2,0.2,0.2,1,5)
				blast:Update()
			end
			pedestal:Update()
		end
	end

end, Card.MISPRINTED_JOKER)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local r = player:GetCardRNG(cardID)
	local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
	if math.random(888) == 1 then
		local item = Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_PERFECTLY_GENERIC_OBJECT_4, pos, nilvector, nil)
		item:SetColor(Color(math.random() * 2,math.random() * 2,math.random() * 2,1, math.random() * 2, math.random() * 2, math.random() * 2),15,1,true,false)
		item:Update()
	else
		player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
		local item = Isaac.Spawn(5, 100, 0, pos, nilvector, nil)
		item:SetColor(Color(math.random() * 2,math.random() * 2,math.random() * 2,1, math.random() * 2, math.random() * 2, math.random() * 2),15,1,true,false)
		item:Update()
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	end

	sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, math.random(90,110)/100)
	for i = 1, math.random(5,10) do
		local particle = Isaac.Spawn(1000, 4, math.random(BackdropType.NUM_BACKDROPS), pos, RandomVector()*math.random(200, 350)/100, nil):ToEffect()
		particle.Color = Color(math.random() * 2,math.random() * 2,math.random() * 2,1, math.random() * 2, math.random() * 2, math.random() * 2)
		mod.scheduleForUpdate(function()
			if particle then
				local sprite = particle:GetSprite()
				particle.Color = mod.ColorNormal
				sprite:ReplaceSpritesheet(0, "gfx/grid/rocks_error-1.png.png")
				sprite:LoadGraphics()
			end
		end, math.random(5,30))
		particle:Update()
	end
	for i = 1, math.random(20,35) do
		local particle = Isaac.Spawn(1000, 4, math.random(BackdropType.NUM_BACKDROPS), Isaac.GetRandomPosition(), RandomVector()*math.random(10, 350)/100, nil):ToEffect()
		particle.Color = Color(math.random() * 2,math.random() * 2,math.random() * 2,1, math.random() * 2, math.random() * 2, math.random() * 2)
		particle.m_Height = -300 - math.random(1200)
		mod.scheduleForUpdate(function()
			if particle then
				local sprite = particle:GetSprite()
				particle.Color = mod.ColorNormal
				sprite:ReplaceSpritesheet(0, "gfx/grid/rocks_error-1.png.png")
				sprite:LoadGraphics()
			end
		end, math.random(50,100))
		particle:Update()
	end
	Game():ShakeScreen(15)
	player:QueueExtraAnimation("Glitch")
	mod.scheduleForUpdate(function()
		local player = Isaac.GetPlayer()
		if player then
			player:QueueExtraAnimation("Glitch")
		end
	end, math.random(50,100))
	if math.random(3) == 1 then
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThirteenStarsRare, flags, 20)
	else
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThirteenStars, flags, 20)
	end
end, Card.THIRTEEN_OF_STARS)