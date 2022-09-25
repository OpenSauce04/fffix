local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--[[
Alpha Coin
"Learn to use it!"
]]

local alphaCoinIgnoreUnexplored = {
	[RoomType.ROOM_BLACK_MARKET] = true,
	[RoomType.ROOM_BOSSRUSH] = true,
	[RoomType.ROOM_DUNGEON] = true,
	[RoomType.ROOM_SUPERSECRET] = true,
	[RoomType.ROOM_ERROR] = true,
	[RoomType.ROOM_DEVIL] = true,
	[RoomType.ROOM_ANGEL] = true
}

local function getAlphaCoinSpawnPos(player, room)
	return room:FindFreePickupSpawnPosition(player.Position, 40, true)
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, ID, rng, player)
	--local player = mod:GetPlayerUsingItem()
	local data = player:GetData()
	local savedata = data.ffsavedata

	savedata.alphacoinusedin = savedata.alphacoinusedin or {}

	--local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ALPHA_COIN)

	-- ??????? dunno what this does but leaving it just in case
	if #Isaac.FindByType(mod.FF.MotherOrb.ID, mod.FF.MotherOrb.Var, -1, false, false) > 0 then
		sfx:Play(mod.Sounds.gbf, 0.5, 0, false, 1)
		return true
	end

	local gbf = Isaac.FindByType(mod.FF.GBF.ID, mod.FF.GBF.Var, -1, false, false)
	if #gbf > 0 then
		for _, gbf in ipairs(gbf) do
			local npc = gbf:ToNPC()
			npc:Morph(mod.FF.Mern.ID, mod.FF.Mern.Var, 0, -1)
			npc.HitPoints = 1
		end

		return true
	end
	local WhiteFires = Isaac.FindByType(33, 4, -1, false, false)
	if #WhiteFires > 0 then
		for _, WhiteFire in ipairs(WhiteFires) do
			for i = 90, 360, 90 do
                local arrow = Isaac.Spawn(1000, mod.FF.AwesomePointingArrow.Var, mod.FF.AwesomePointingArrow.Sub, WhiteFire.Position, nilvector, nil)
                arrow:ToEffect():FollowParent(WhiteFire)
                arrow.SpriteRotation = i
                arrow:GetData().ForcedOffset = Vector(0, -10)
				arrow.DepthOffset = 50
                arrow:Update()
            end
		end
	end

	local didRandomEffect
	local room = game:GetRoom()
    
    local yellowButtonsHaveBeenPressed
    local savedPos = player.Position
	for i=0, room:GetGridSize() do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity and gridEntity:GetType() == GridEntityType.GRID_ROCK_ALT2 then
			local gridpos = room:GetGridPosition(i)
			gridEntity:Destroy(true)
        elseif gridEntity and gridEntity:GetType() == GridEntityType.GRID_PRESSURE_PLATE then
            local plate = gridEntity:ToPressurePlate()
            if plate:GetVariant() == 3 and plate.State == 0 then
                local gridpos = room:GetGridPosition(i)
                player.Position = gridpos
                plate:Update()
                yellowButtonsHaveBeenPressed = true
            end
        end
	end

    if yellowButtonsHaveBeenPressed then
        player.Position = savedPos
    end


	-- 25% chance to spawn a penny
	if StageAPI.Random(1, 4, rng) == 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
		didRandomEffect = true
	end

	-- 25% chance to spawn a card or pill
	if StageAPI.Random(1, 4, rng) == 1 then
		if StageAPI.Random(1, 2, rng) == 1 then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
		else
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
		end

		didRandomEffect = true
	end

	local level = game:GetLevel()
	local roomindex = level:GetCurrentRoomIndex()
	local usedHerePrior = savedata.alphacoinusedin[roomindex]

	local roomDesc = level:GetCurrentRoomDesc()
	local roomsub = roomDesc.Data.Subtype
	local stageNum = level:GetStage()

	local rtype = room:GetType()

	local isBeastFight = (stageNum == LevelStage.STAGE8 and rtype == RoomType.ROOM_DUNGEON)

	-- if in mega satan fight, do a completely useless funny thing
	if room:GetType() == RoomType.ROOM_BOSS and roomsub == 55 then
		if usedHerePrior == 1 then
			game:GetHUD():ShowFortuneText("Every step", "of the way!")
		elseif not usedHerePrior then
			game:GetHUD():ShowFortuneText("I'm with you!")
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_TICK, getAlphaCoinSpawnPos(player, room), nilvector, player)
		end
	end

	-- if in home, do one of three things
	if stageNum == LevelStage.STAGE8 and rtype ~= RoomType.ROOM_BOSS and rtype ~= RoomType.ROOM_DUNGEON then
		-- if used more than twice, spawn a random pickup
		if savedata.alphacoinhomecount and savedata.alphacoinhomecount >= 2 then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)

		-- otherwise, if used once, spawn a cracked key
		elseif savedata.alphacoinhomecount and savedata.alphacoinhomecount == 1 then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, getAlphaCoinSpawnPos(player, room), nilvector, player)

		-- otherwise, spawn a dad item
		else
			local itempool = game:GetItemPool()
			local itemconfig = Isaac:GetItemConfig()
			local itemchoice
			for i = 1, 1000 do
				itemchoice = itempool:GetCollectible(ItemPoolType.POOL_OLD_CHEST, false)
				local configname = itemconfig:GetCollectible(itemchoice)
				local name = string.sub(configname.Name, 1, 5)
				if name == "#DADS" or name == "Dad's" then
					break
				end
			end
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemchoice, getAlphaCoinSpawnPos(player, room), nilvector, player)
			itempool:RemoveCollectible(itemchoice)
		end
		-- increment this cos home is all the same outside of the fight
		savedata.alphacoinhomecount = savedata.alphacoinhomecount or 0
		savedata.alphacoinhomecount = savedata.alphacoinhomecount + 1

	-- if in the starting room and have not left it, grant a small stats up for the floor
	elseif roomindex == level:GetStartingRoomIndex() and room:IsFirstVisit() then
		if not savedata.alphacoinfloorstats then
			savedata.alphacoinfloorstats = 1
		else
			savedata.alphacoinfloorstats = savedata.alphacoinfloorstats + (.75 / savedata.alphacoinfloorstats)
		end

		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
	else
		local exploredAll = true
		local rooms = level:GetRooms()
		for i = 0, level:GetRoomCount() - 1 do
			local roomDesc = rooms:Get(i)
			if roomDesc.VisitedCount <= 0 then
				if not alphaCoinIgnoreUnexplored[roomDesc.Data.Type] and roomDesc.GridIndex >= 0 then
					exploredAll = false
					break
				end
			end
		end

		-- if all rooms but super secret are explored and this effect has not triggered this floor, spawn a half soul heart and the world
		if exploredAll and not savedata.alphacoinexploredeffect then
			savedata.alphacoinexploredeffect = true
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, getAlphaCoinSpawnPos(player, room), nilvector, player)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_WORLD, getAlphaCoinSpawnPos(player, room), nilvector, player)
		end

		-- if in a super secret room, do one of two things
		if rtype == RoomType.ROOM_SUPERSECRET then
			-- if used in this room already, poop and refund 2 charges
			if usedHerePrior then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_POOP, false, false, true, false)
				data.alphacoincharge = 2
			-- otherwise, spawn a golden cursed penny (used to be 3 cursed pennies)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 20, CoinSubType.COIN_GOLDENCURSEDPENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in a shop, do one of two things
		elseif rtype == RoomType.ROOM_SHOP then
			-- if used in this room already, spawn 1-4 coins
			if usedHerePrior then
				local coinCount = StageAPI.Random(1, 4, rng)
				for i = 1, coinCount do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			-- otherwise, spawn 2 shop items
			else
				for i = 1, 2 do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			end
		-- otherwise, if in a treasure room, do one of two things
		elseif rtype == RoomType.ROOM_TREASURE then
			-- if used in this room already, reroll all pickups (d20)
			if usedHerePrior then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_D20, false, false, true, false)
			-- otherwise, spawn a random glass die
			else
				local chances = {
					Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6,
					Card.GLASS_D4, Card.GLASS_D4, Card.GLASS_D4,
					Card.GLASS_D8, Card.GLASS_D8, Card.GLASS_D8, Card.GLASS_D8,
					Card.GLASS_D100,
					Card.GLASS_D10, Card.GLASS_D10, Card.GLASS_D10, Card.GLASS_D10,
					Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20,
					Card.GLASS_D12, Card.GLASS_D12, Card.GLASS_D12, Card.GLASS_D12,
					Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN, Card.GLASS_SPINDOWN,
				}
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, chances[StageAPI.Random(1, #chances, rng)], getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in an angel room, spawn an eternal heart
		elseif rtype == RoomType.ROOM_ANGEL then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, getAlphaCoinSpawnPos(player, room), nilvector, player)
		-- otherwise, if in an devil room, spawn an eternal heart
		elseif rtype == RoomType.ROOM_DEVIL then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, getAlphaCoinSpawnPos(player, room), nilvector, player)
		-- otherwise, if in an error room, spawn telepills
		elseif rtype == RoomType.ROOM_ERROR then
			local itempool = game:GetItemPool()
			local pillColor = itempool:ForceAddPillEffect(PillEffect.PILLEFFECT_TELEPILLS)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pillColor, getAlphaCoinSpawnPos(player, room), nilvector, player)
		-- otherwise, if in a bedroom, do one of two things
		elseif rtype == RoomType.ROOM_BARREN or rtype == RoomType.ROOM_ISAACS then
			-- if used in this room already, spawn a cursed penny if dirty, or a penny if clean
			if usedHerePrior then
				if rtype == RoomType.ROOM_BARREN then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_CURSEDPENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			-- otherwise, spawn one of each heart type
			else
				local heartsToSpawn = {
					HeartSubType.HEART_FULL,
					HeartSubType.HEART_SOUL,
					HeartSubType.HEART_BLACK,
					HeartSubType.HEART_ETERNAL,
					HeartSubType.HEART_BONE
				}

				for _, sub in ipairs(heartsToSpawn) do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, sub, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			end
		-- otherwise, if in a greed exit room, spawn a penny only once
		elseif rtype == RoomType.ROOM_GREED_EXIT then
			if usedHerePrior then
				game:ButterBeanFart(player.Position, 0, player, true)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in a crawlspace, spawn a sentry and refund 2 charges
		elseif rtype == RoomType.ROOM_DUNGEON and stageNum ~= LevelStage.STAGE8 then
			Isaac.Spawn(mod.FF.Sentry.ID, mod.FF.Sentry.Var, 0, player.Position, nilvector, nil)
			data.alphacoincharge = 2
		-- otherwise, if in a black market, do one of two things
		elseif rtype == RoomType.ROOM_BLACK_MARKET then
			-- if used in this room already, spawn a cursed penny
			if usedHerePrior then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_CURSEDPENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
			-- otherwise, grant a heart container
			else
				player:AddMaxHearts(2)
			end
		-- otherwise, if in a secret room, do one of two things
		elseif rtype == RoomType.ROOM_SECRET then
			-- if used in this room already, spawn a double pack penny
			if usedHerePrior then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, getAlphaCoinSpawnPos(player, room), nilvector, player)
			-- otherwise, spawn a double pack bomb
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK, getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in a curse room, do one of two things
		elseif rtype == RoomType.ROOM_CURSE then
			-- if used in this room already, deal half a heart of damage
			if usedHerePrior then
				savedata.alphacoinusedin[roomindex] = usedHerePrior + 1
				player:TakeDamage(1, DamageFlag.DAMAGE_CURSED_DOOR, EntityRef(player), 0)
				return
			-- otherwise, spawn a beggar and a troll bomb
			else
				Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_TROLL, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
				Isaac.Spawn(EntityType.ENTITY_SLOT, 4, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in an arcade, spawn a random slot and a penny
		elseif rtype == RoomType.ROOM_ARCADE then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
			Isaac.Spawn(EntityType.ENTITY_SLOT, StageAPI.Random(1, 10, rng), 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
		-- otherwise, if in a vault, do one of three things
		elseif rtype == RoomType.ROOM_CHEST then
			-- if used more than twice in this room already, fart and regain 2 charges
			if usedHerePrior and usedHerePrior >= 2 then
				game:ButterBeanFart(player.Position, 0, player, true)
				data.alphacoincharge = 2
			-- otherwise, if used in this room already, spawn a mimic chest
			elseif usedHerePrior then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_MIMICCHEST, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
			-- otherwise, spawn two keys
			else
				for i = 1, 2 do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			end
		-- otherwise, if in a challenge room, do one of two things
		elseif rtype == RoomType.ROOM_CHALLENGE then
			-- if the challenge room is complete, grant a damage up if not already granted
			if level:GetCurrentRoomDesc().ChallengeDone then
				if not savedata.alphacoinchallenge then
					savedata.alphacoinchallenge = true
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()
				else
					game:ButterBeanFart(player.Position, 0, player, true)
				end
			-- otherwise, spawn a random special chest variant
			else
				local chestVariants = {
					PickupVariant.PICKUP_LOCKEDCHEST,
					PickupVariant.PICKUP_BOMBCHEST,
					PickupVariant.PICKUP_MIMICCHEST,
					PickupVariant.PICKUP_ETERNALCHEST,
					PickupVariant.PICKUP_SPIKEDCHEST,
				}

				Isaac.Spawn(EntityType.ENTITY_PICKUP, chestVariants[StageAPI.Random(1, #chestVariants, rng)], 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in a library, spawn a trinket
		elseif rtype == RoomType.ROOM_LIBRARY then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
		-- otherwise, if in a sacrifice room, spawn a blood bag or a trash bag
		elseif rtype == RoomType.ROOM_SACRIFICE then
			if StageAPI.Random(1, 3, rng) == 1 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 666, 0, getAlphaCoinSpawnPos(player, room), nilvector, player)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 666, 10, getAlphaCoinSpawnPos(player, room), nilvector, player)
			end
		-- otherwise, if in a dice room, do one of two things
		elseif rtype == RoomType.ROOM_DICE then
			-- if used in this room already, fart and regain 2 charges
			if usedHerePrior then
				game:ButterBeanFart(player.Position, 0, player, true)
				data.alphacoincharge = 2
			-- otherwise, spawn every glass die
			else
				for _, die in ipairs(FiendFolio.GlassDice) do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, die.id, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			end
		-- otherwise, if in a planetarium, do one of two things
		elseif rtype == RoomType.ROOM_PLANETARIUM then
			-- if used in this room already, spawn 2-4 wisps
			if usedHerePrior then
				for i = 1, math.random(2,4) do
					player:AddWisp(0, player.Position)
				end
				sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
			-- otherwise, use the soul of isaac to turn it into a choice pedestal
			else
				player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			end
		-- otherwise, if in a red secret, do one of two things
		elseif rtype == RoomType.ROOM_ULTRASECRET then
			-- if used in this room already, fart and regain 2 charges
			if usedHerePrior then
				game:ButterBeanFart(player.Position, 0, player, true)
				data.alphacoincharge = 2
			-- otherwise, spawn 2-3 cracked keys
			else
				for i = 1, math.random(2,3) do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			end
		-- otherwise, if in an alt floor entrance, do one of two things
		elseif rtype == RoomType.ROOM_SECRET_EXIT then
			-- if used in this room already, fart and regain 2 charges
			if usedHerePrior then
				game:ButterBeanFart(player.Position, 0, player, true)
				data.alphacoincharge = 2
			-- otherwise, refund the entrance cost
			else
				-- if entering mausoleum, spawn two blended hearts
				if roomsub == 3 then
					for i = 1, 2 do
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, getAlphaCoinSpawnPos(player, room), nilvector, player)
					end
				-- if entering mines, spawn a double bomb
				elseif roomsub == 2 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK, getAlphaCoinSpawnPos(player, room), nilvector, player)
				-- if entering downpour, spawn a key
				elseif roomsub == 1 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, getAlphaCoinSpawnPos(player, room), nilvector, player)
				-- otherwise, where are you? what are you doing?
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, getAlphaCoinSpawnPos(player, room), nilvector, player)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, getAlphaCoinSpawnPos(player, room), nilvector, player)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_TROLL, getAlphaCoinSpawnPos(player, room), nilvector, player)
				end
			end
		-- otherwise, if in a mirror room, do one of two things
		elseif rtype == RoomType.ROOM_DEFAULT and (stageNum == LevelStage.STAGE1_1 or stageNum == LevelStage.STAGE1_2) and roomsub == 34 then
			-- if you're not lost, white firefy you (good for speedrunners)
			if not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
				player:UseCard(Card.CARD_SOUL_LOST, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			-- otherwise
			else
				-- if there's a mirror, destroy it
				local mirrorSpotted
				for i = 0, 7 do
					local door = room:GetDoor(i)
					if door and not door:IsBusted() then
						if door.TargetRoomIndex == -100 then
							door:TryBlowOpen(true, player)
							door:SpawnDust()
							mirrorSpotted = true
						end
					end
				end

				-- otherwise, fart and regain 2 charges
				if not mirrorSpotted then
					game:ButterBeanFart(player.Position, 0, player, true)
					data.alphacoincharge = 2
				end
			end
        -- otherwise, if in a mineshaft entrance room
        elseif rtype == RoomType.ROOM_DEFAULT and (stageNum == LevelStage.STAGE2_1 or stageNum == LevelStage.STAGE2_2) and roomsub == 10 then
            -- if there's a yellow button, don't do anything if it's unpressed
            if not yellowButtonsHaveBeenPressed then
                -- otherwise, spawn in the second knife piece
                if not FiendFolio.savedata.run.level.alphaCoinSpawnedKnife2 then
                    Isaac.Spawn(5, 100, 627, getAlphaCoinSpawnPos(player, room), nilvector, player)
                    FiendFolio.savedata.run.level.alphaCoinSpawnedKnife2 = true
                end
            end
        -- otherwise,
		else
			-- replenish the holy mantle in the beast fight
			if isBeastFight and not usedHerePrior then
				local tempEffects = player:GetEffects()
				tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
			-- if there are no enemies in the room, spawn a penny and recharge this item one pip
			elseif room:GetAliveEnemiesCount() == 0 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, getAlphaCoinSpawnPos(player, room), nilvector, player)
				data.alphacoincharge = 1
			-- if in an active boss room, grant a large tears up that rapidly decays
			elseif rtype == RoomType.ROOM_BOSS or rtype == RoomType.ROOM_MINIBOSS or rtype == RoomType.ROOM_BOSSRUSH or isBeastFight then
					data.alphacointemptearstime = 0
					if rtype == RoomType.ROOM_BOSSRUSH then
						data.alphacointemptearslength = 10
					else
						data.alphacointemptearslength = 4
					end
			-- otherwise, fire 3 tears that deal 2x damage at random enemies
			else
				local validEnts = {}
				local validEntsInRange = {}
				local rangeGuess = player.ShotSpeed * 10 * 30
				for _, ent in ipairs(Isaac.GetRoomEntities()) do
					if ent:IsActiveEnemy() and ent:IsVulnerableEnemy() and not ent:IsDead()
					and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and ent.Type ~= mod.FFID.Tech then
						local dist = ent.Position:DistanceSquared(player.Position)
						validEnts[#validEnts + 1] = ent
						if dist < rangeGuess ^ 2 then
							validEntsInRange[#validEntsInRange + 1] = ent
						end
					end
				end

				local useEnts = (#validEntsInRange > 0 and validEntsInRange) or validEnts
				if #useEnts > 0 then
					for i = 1, 3 do
						local ent = useEnts[StageAPI.Random(1, #useEnts, rng)]
						local dir = (ent.Position - player.Position):Resized(player.ShotSpeed * 10)
						local tear = player:FireTear(player.Position, dir, false, true, false)
						tear.CollisionDamage = tear.CollisionDamage * 2
						tear.Scale = math.max(tear.Scale, 2)
					end
				end

				data.alphacoincharge = 1
			end
		end
	end

	savedata.alphacoinusedin[roomindex] = (usedHerePrior or 0) + 1
	return true
end, CollectibleType.COLLECTIBLE_ALPHA_COIN)

function mod:alphaCoinNewRoom(player, savedata)
    if savedata and (savedata.alphacoinfloorstats or savedata.alphacoinusedin or savedata.alphacoinexploredeffect or savedata.alphacoinchallenge) then
        local level = game:GetLevel()
        local room = game:GetRoom()
        if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:IsFirstVisit() then
            if savedata.alphacoinfloorstats or savedata.alphacoinchallenge then
                savedata.alphacoinfloorstats = nil
                savedata.alphacoinchallenge = nil
                player = player:ToPlayer()
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end

            savedata.alphacoinexploredeffect = nil
            savedata.alphacoinusedin = nil
            savedata.alphacoinhomecount = nil
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local data = player:GetData()
	if data.alphacoincharge then
		player:SetActiveCharge(player:GetActiveCharge() + data.alphacoincharge)
		data.alphacoincharge = nil
	end

	if data.alphacointemptearstime then
		data.alphacointemptearstime = data.alphacointemptearstime + 1
		local alphaCoinLength = (data.alphacointemptearslength or .1) * 30
		local percent = data.alphacointemptearstime / alphaCoinLength
		local minusFireDelay, multiFireDelay = 2, 0.5
		minusFireDelay = mod:Lerp(minusFireDelay, 0, percent)
		multiFireDelay = mod:Lerp(multiFireDelay, 1, percent)

		data.alphacointearsup = minusFireDelay
		data.alphacointearsmulti = multiFireDelay
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()

		if data.alphacointemptearstime >= alphaCoinLength then
			data.alphacointemptearslength = nil
			data.alphacointemptearstime = nil
			data.alphacointearsup = nil
			data.alphacointearsmulti = nil
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end
end)