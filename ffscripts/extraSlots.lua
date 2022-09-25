local mod = FiendFolio

local game = Game()
local level = game:GetLevel()
local stage = level:GetStage()
local sfx = SFXManager()
local ItemConfig = Isaac.GetItemConfig()
local ItemPool = game:GetItemPool()
local grng = RNG()

local contraband = CollectibleType.COLLECTIBLE_CONTRABAND


function mod.ThrowRockSpider(pos, vel, z_init, z_vel, spawner)
	local rockSpider = Isaac.Spawn(818, 0, 0, pos, vel, spawner):ToNPC()
	rockSpider.State = 16
	rockSpider.PositionOffset = Vector(0, z_init)
	rockSpider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

	local data = rockSpider:GetData()
	data.isthrown = true
	data.z_vel = z_vel
	data.forcevel = vel

	return rockSpider
end

--Blacksmith (Anims)
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    if sprite:IsPlaying('Idle') then  -- luacheck: ignore 542
        -- pass
    elseif sprite:IsPlaying('PayPrize') then
        if sprite:IsEventTriggered('Prize') then
            --FiendFolio.CrushRockTrinket(data.CrushingPlayer, data.CrushingTrinket, slot)
        end
    elseif sprite:IsFinished('PayPrize') or sprite:IsFinished('PayNothing') then
		if d.trinketsRecieved == 2 then
        	sprite:Play('Prize', true)
		else
			sprite:Play('Idle', true)
		end
	elseif sprite:IsFinished('Teleport') then
		slot:Remove()
    elseif sprite:IsPlaying('Prize') then
        if sprite:IsEventTriggered('Prize') then
			if FiendFolio.GolemExists() then
            	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, FiendFolio.GetNextMiningMachineTrinket(0, Isaac.GetPlayer()), slot.Position, Vector.FromAngle(math.random(30, 150)) * 4, slot)
			else
            	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, slot.Position, Vector.FromAngle(math.random(30, 150)) * 4, slot)
			end
			d.trinketInSack = nil
			d.trinketsRecieved = nil
            sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false, 1)
        end
		if sprite:IsEventTriggered('Sound') then
			sfx:Play(mod.Sounds.Anvil, 1.3, 0, false, 1)
        end
		if sprite:IsEventTriggered('Donk') then
			sfx:Play(SoundEffect.SOUND_PUNCH, 0.6, 0, false, 1.2)
        end
    elseif sprite:IsFinished('Prize') then
		if d.tradesDone == 3 then
			sprite:Play('Teleport', true)
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.BLACKSMITH, slot:GetDropRNG()), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 60)), Vector.Zero, slot)
		else
			sprite:Play('Idle', true)
		end
    end
	
	if not data.DropFunc then
		function data.DropFunc()
			if not data.DidDropFunc then
				sprite:Play('Destroyed', true)
				slot:BloodExplode()
				slot:BloodExplode()
				slot:BloodExplode()
				slot:BloodExplode()
				
				local r = math.random(1, 2)
				for i = 1, r do
					local p = slot.Position + RandomVector() * math.random(15, 35)
					mod.ThrowRockSpider(slot.Position, RandomVector():Resized(math.random(2, 3)), -14, math.random(-15, -10), slot)
					
				end
				
				if d.trinketInSack then
					 local trinket = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET, d.trinketInSack,
					 slot.Position, Vector.FromAngle(math.random(30, 150)) * 4, slot):ToPickup()
					 d.trinketInSack = nil
					 trinket:GetData().DontRemoveRecentReward = true
					 trinket.Touched = true
				end
				data.DidDropFunc = true
			end
		end
	end

    FiendFolio.OverrideExplosionHack(slot, true)
end, 1030)


--React to touch
FiendFolio.onMachineTouch(1030, function(player, slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
    if sprite:IsPlaying('Idle') then
        local trinket = FiendFolio.GetMostRecentTrinket(player)
        if trinket > 0 then
			d.trinketInSack = trinket
            player:TryRemoveTrinket(trinket)
			if d.trinketsRecieved == nil then
				d.trinketsRecieved = 0
			end
			if d.tradesDone == nil then
				d.tradesDone = 0
			end
			d.trinketsRecieved = d.trinketsRecieved +1
            sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)

            sprite:ReplaceSpritesheet(2, ItemConfig:GetTrinket(trinket).GfxFileName)
            sprite:LoadGraphics()
			if d.trinketsRecieved == 1 then
            sprite:Play('PayNothing', true)
			elseif d.trinketsRecieved == 2 then
			d.tradesDone = d.tradesDone +1
            sprite:Play('PayPrize', true)
			end
        end
    end
end)

mod.HoroscopeBeggarPools = {
	ZodiacPrizes = {
		CollectibleType.COLLECTIBLE_ZODIAC,
		CollectibleType.COLLECTIBLE_TAURUS,
		CollectibleType.COLLECTIBLE_ARIES,
		CollectibleType.COLLECTIBLE_CANCER,
		CollectibleType.COLLECTIBLE_LEO,
		CollectibleType.COLLECTIBLE_VIRGO,
		CollectibleType.COLLECTIBLE_LIBRA,
		CollectibleType.COLLECTIBLE_SCORPIO,
		CollectibleType.COLLECTIBLE_SAGITTARIUS,
		CollectibleType.COLLECTIBLE_CAPRICORN,
		CollectibleType.COLLECTIBLE_AQUARIUS,
		CollectibleType.COLLECTIBLE_PISCES,
		CollectibleType.COLLECTIBLE_GEMINI,
		CollectibleType.COLLECTIBLE_OPHIUCHUS,
		CollectibleType.COLLECTIBLE_MUSCA,
	},
	Planetarium = {	--Used solely for wisps
		CollectibleType.COLLECTIBLE_SOL,
		CollectibleType.COLLECTIBLE_LUNA,
		CollectibleType.COLLECTIBLE_MERCURIUS,
		CollectibleType.COLLECTIBLE_VENUS,
		CollectibleType.COLLECTIBLE_TERRA,
		CollectibleType.COLLECTIBLE_MARS,
		CollectibleType.COLLECTIBLE_JUPITER,
		CollectibleType.COLLECTIBLE_SATURNUS,
		CollectibleType.COLLECTIBLE_URANUS,
		CollectibleType.COLLECTIBLE_NEPTUNUS,
		CollectibleType.COLLECTIBLE_PLUTO,
		CollectibleType.COLLECTIBLE_DEIMOS,
	},
	Trinkets = { -- Not converting this into a proper pool yet because of the insane weight disparity
		TrinketType.TRINKET_TELESCOPE_LENS,
		TrinketType.TRINKET_TELESCOPE_LENS,
		TrinketType.TRINKET_TELESCOPE_LENS,
		TrinketType.TRINKET_TELESCOPE_LENS,
		TrinketType.TRINKET_TELESCOPE_LENS,
		TrinketType.TRINKET_MOMS_PEARL,
		TrinketType.TRINKET_MOMS_PEARL,
		TrinketType.TRINKET_MOMS_PEARL,
		TrinketType.TRINKET_MOMS_PEARL,
		TrinketType.TRINKET_MOMS_PEARL,
		TrinketType.TRINKET_CANCER,
	},
	Runes = {
		Card.RUNE_HAGALAZ,
		Card.RUNE_JERA,
		Card.RUNE_EHWAZ,
		Card.RUNE_ANSUZ,
		Card.RUNE_PERTHRO,
		Card.RUNE_BERKANO,
		Card.RUNE_ALGIZ,
		Card.RUNE_BLANK,
		Card.RUNE_BLACK,
	}
}

function mod:payoutZodiacBeggar(slot, data, d)
	local r = slot:GetDropRNG()
	local rand = r:RandomInt(25)
	
	if rand < 3 then
		--Souw heawt
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)
	elseif rand < 5 then
		--Twimket
		local rand2 = r:RandomInt(#mod.HoroscopeBeggarPools.Trinkets) + 1
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.HoroscopeBeggarPools.Trinkets[rand2], slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)
	elseif rand < 7 then
		--Wune uwu
		local rand2 = r:RandomInt(#mod.HoroscopeBeggarPools.Runes) + 1
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, mod.HoroscopeBeggarPools.Runes[rand2], slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)
	--elseif rand < 12 then
		--Pwanetawiums up
		--Game():GetHUD():ShowFortuneText ("The stars align", "(doesn't work atm sorry)")
		--if data.lastCollider and data.lastCollider:ToPlayer() then
	--		data.lastCollider:AnimateHappy()
		--end
		--showingFortune = true
	else
		--Wisp
		if data.lastCollider and data.lastCollider:ToPlayer() then
			local p = data.lastCollider
			local wispType = 0
			d.wispPity = d.wispPity or 0
			d.wispPity = d.wispPity + 1
			if r:RandomInt(5) == 0 or d.wispPity == 3 then
				if r:RandomInt(2) == 0 then
					wispType = mod.HoroscopeBeggarPools.ZodiacPrizes[r:RandomInt(#mod.HoroscopeBeggarPools.ZodiacPrizes) + 1]
				else
					wispType = mod.HoroscopeBeggarPools.Planetarium[r:RandomInt(#mod.HoroscopeBeggarPools.Planetarium) + 1]
				end
				d.wispPity = 0
			end
			if wispType == 0 then
				p:AddWisp(0, slot.Position)
			else
				p:AddItemWisp(wispType, slot.Position)
			end
		end
	end
end

--Horoscope Beggar (Anims)
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	slot.SplatColor = mod.ColorInvisible
	if not data.DropFunc then
		function data.DropFunc()
--spawn rune shard
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 55, slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)

			--Cosmetic Nonsense
			sfx:Play(SoundEffect.SOUND_DEMON_HIT, 1, 0, false, 1.5)
			local poof = Isaac.Spawn(1000, 15, 0, slot.Position, Vector.Zero, slot)
			local poofData = poof:GetData()
			local poofSprite = poof:GetSprite()
			local color = Color(1, 1, 1, 1, 0, 0, 0)
			color:SetColorize(1.5, 1.5, 1.5, 1)
			poof.Color = color
			poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
			poofSprite:Play("Explosion")

			for i = 1, math.random(9,12) do
				local wisp = Isaac.Spawn(1000, 65, 0, slot.Position, RandomVector():Resized(math.random(250,750)/100), slot)
				wisp:Update()
			end
		end
	end

    if sprite:IsPlaying('Idle') then  -- luacheck: ignore 542
        mod:spriteOverlayPlay(sprite, "Idle")
		mod:spritePlay(sprite, "Halo Idle")
    elseif sprite:IsOverlayFinished('PayPrize') then
            sprite:PlayOverlay('Prize')
    elseif sprite:IsOverlayFinished('PayNothing') then
		 sprite:PlayOverlay('Idle', true)
			if data.lastCollider and data.lastCollider:ToPlayer() then
				if data.lastCollider:HasTrinket(TrinketType.TRINKET_FORTUNE_GRUB) then
					--game:ShowFortune()
					mod:ShowFortune()
				end
			end
	elseif (sprite:IsOverlayPlaying("PayPrize") or sprite:IsOverlayPlaying("PayNothing")) and sprite:GetOverlayFrame() == 13 then
		sfx:Play(SoundEffect.SOUND_SOUL_PICKUP, 1, 0, false, math.random(7,10)/10)
	elseif sprite:IsOverlayFinished('Teleport') then
		slot:Remove()
    elseif sprite:IsOverlayPlaying('Prize') then
        if (sprite:IsEventTriggered('Prize') or sprite:GetOverlayFrame() == 27) then
			local showingFortune = false
			if d.coinsRecieved >= 100 then
				local r = slot:GetDropRNG()
				local poolChoice = r:RandomInt(5)
				local itemChoice = 0
				if poolChoice == 0 then
					itemChoice = ItemPool:GetCollectible(ItemPoolType.POOL_PLANETARIUM, true, slot.InitSeed)
				else
					if data.lastCollider and data.lastCollider:ToPlayer() then
						if data.lastCollider:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_GIFT) then
							itemChoice = CollectibleType.COLLECTIBLE_MYSTERY_GIFT
						else
							itemChoice = mod.GetItemFromCustomItemPool(mod.CustomPool.ZODIAC_BEGGAR, r)
						end
					end

				end
				Isaac.Spawn(5, 100, itemChoice, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
				sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)

				local payouts = 0
				if data.lastCollider and data.lastCollider:ToPlayer() then
					payouts = payouts + math.ceil(FiendFolio.GetGolemTrinketPower(data.lastCollider:ToPlayer(), FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
				end
				for i = 1, payouts do
					mod:payoutZodiacBeggar(slot, data, d)
				end
			else
				local payouts = 1
				if data.lastCollider and data.lastCollider:ToPlayer() then
					payouts = payouts + math.ceil(FiendFolio.GetGolemTrinketPower(data.lastCollider:ToPlayer(), FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
				end
				for i = 1, payouts do
					mod:payoutZodiacBeggar(slot, data, d)
				end
				d.pity = 0
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false, 1)
			end
			if not showingFortune then
				if data.lastCollider and data.lastCollider:ToPlayer() then
					if data.lastCollider:HasTrinket(TrinketType.TRINKET_FORTUNE_GRUB) then
						--game:ShowFortune()
						mod:ShowFortune()
					end
				end
			end
        end
    elseif sprite:IsOverlayFinished('Prize') then
		if d.coinsRecieved >= 100 then
			sprite:PlayOverlay('Teleport', true)
			mod:spritePlay(sprite, "Halo Teleport")
		else
			sprite:PlayOverlay('Idle', true)
		end
    end

    FiendFolio.OverrideExplosionHack(slot)
end, 1031)


--React to touch
FiendFolio.onMachineTouch(1031, function(player, slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
		if sprite:IsOverlayPlaying('Idle') and player:GetNumCoins() >= 1 then
			if d.coinsRecieved == nil then
				d.coinsRecieved = 0
			end
			data.lastCollider = player
			d.pity = d.pity or 0
			player:AddCoins(-1)
			d.coinsRecieved = d.coinsRecieved + 1
			d.pity = d.pity + 1
            sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
            sprite:LoadGraphics()
			local r = slot:GetDropRNG()
			local randoChance = r:RandomInt(2)
			if randoChance == 0 or d.pity >= 3 then
				if d.coinsRecieved >= 50 then
					local i = r:RandomInt(3)
					if i == 0 then
						d.coinsRecieved = 100
					end
				elseif d.coinsRecieved >= 20 then
					local i = r:RandomInt(6)
					if i == 0 then
						d.coinsRecieved = 100
					end
				elseif d.coinsRecieved >= 3 then
					local i = r:RandomInt(30)
					if i == 0 then
						d.coinsRecieved = 100
					end
				end
				sprite:PlayOverlay('PayPrize', true)
			else
				if d.coinsRecieved == 100 or d.pity == 6 then
					sprite:PlayOverlay('PayPrize', true)
				else
					sprite:PlayOverlay('PayNothing', true)
				end
			end
        end
end)

local function repeatRevealCheck(roomToCheck, roomName, slot, sprite)
		local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
		local roomQuery = level:QueryRoomTypeIndex(roomToCheck, false, grng)
		if roomQuery and roomQuery >= 0 then
			local desc = level:GetRoomByIdx(roomQuery)
			if desc.DisplayFlags <= 0 and d.robotFinished ~= true then --Reveal Room if unrevealed	
				desc.DisplayFlags = desc.DisplayFlags | 5
				level:UpdateVisibility()
				d.robotRoomName = roomName
				d.robotFinished = true
			end
		end
end

--Robot Teller Card List
mod.robCardList = {
		Card.CARD_FOOL,
		Card.CARD_MAGICIAN,
		Card.CARD_HIGH_PRIESTESS,
		Card.CARD_EMPRESS,
		Card.CARD_EMPEROR,
		Card.CARD_HIEROPHANT,
		Card.CARD_LOVERS,
		Card.CARD_CHARIOT,
		Card.CARD_JUSTICE,
		Card.CARD_HERMIT,
		Card.CARD_WHEEL_OF_FORTUNE,
		Card.CARD_STRENGTH,
		Card.CARD_HANGED_MAN,
		Card.CARD_DEATH,
		Card.CARD_TEMPERANCE,
		Card.CARD_DEVIL,
		Card.CARD_TOWER,
		Card.CARD_STARS,
		Card.CARD_MOON,
		Card.CARD_SUN,
		Card.CARD_JUDGEMENT,
		Card.CARD_WORLD
	}

--Robot Teller Reverse Card List
mod.robReverseList = {
		Card.CARD_REVERSE_FOOL,
		Card.CARD_REVERSE_MAGICIAN,
		Card.CARD_REVERSE_HIGH_PRIESTESS,
		Card.CARD_REVERSE_EMPRESS,
		Card.CARD_REVERSE_EMPEROR,
		Card.CARD_REVERSE_HIEROPHANT,
		Card.CARD_REVERSE_LOVERS,
		Card.CARD_REVERSE_CHARIOT,
		Card.CARD_REVERSE_JUSTICE,
		Card.CARD_REVERSE_HERMIT,
		Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
		Card.CARD_REVERSE_STRENGTH,
		Card.CARD_REVERSE_HANGED_MAN,
		Card.CARD_REVERSE_DEATH,
		Card.CARD_REVERSE_TEMPERANCE,
		Card.CARD_REVERSE_DEVIL,
		Card.CARD_REVERSE_TOWER,
		Card.CARD_REVERSE_STARS,
		Card.CARD_REVERSE_MOON,
		Card.CARD_REVERSE_SUN,
		Card.CARD_REVERSE_JUDGEMENT,
		Card.CARD_REVERSE_WORLD
	}


--Robot Teller (Anims)
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	local player = d.bumpedTeller
	local level = game:GetLevel()
    local stage = level:GetStage()
    if sprite:IsPlaying('Idle') then  -- luacheck: ignore 542
        -- pass
	elseif sprite:IsFinished('Initiate') or sprite:IsFinished('InitiateCard') then
		sprite:Play('Wiggle')
	elseif sprite:IsFinished('Wiggle') then
			d.robotPayout = math.random(100)
			d.blowUp = math.random(27)
			--d.robotPayout = 100
			--d.blowUp = 1
			if d.robotPayout <= 60 then -- Chance for Show Card Payout
				d.robotPayout = math.random(5)
				local reverseReplace = math.random(15)
				if reverseReplace == 1 then
					d.robCard = math.random(#mod.robCardList)+56
				else
					d.robCard = math.random(#mod.robCardList)
				end
				sprite:ReplaceSpritesheet(2, "gfx/items/slots/robot_teller/"..d.robCard..".png")
				sprite:LoadGraphics()
				if d.robotPayout == 1 and reverseReplace ~= 1 then
					sprite:Play('Malfunction')
				else
					sprite:Play('PrizeCard', true)
				end
			elseif d.blowUp == 1 then
				--sprite:Play('Death')
				Isaac.Spawn(1000, 1, 0, slot.Position, Vector(0,0), nil)
				d.spawnItem = true
				slot:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(slot), 1)
			else
				d.robotPayout = math.random(9)
				--print(d.robotPayout)
				if d.robotPayout >= 1 and d.robotPayout <= 2 then --Clears Curse. Gives Half a soul heart if no curse present.
					sprite:Play('PrizeDefault', true)
					local curseToClear = level:GetCurses()
					if curseToClear == 0 or curseToClear == 2 then
						d.prizeQueue = "Soul Heart"
					else
						d.prizeQueue = "Clear Curse"
						Game():GetLevel():RemoveCurses(curseToClear) --Bug: Hey curse how about you get removed?? what is happening
					end
				elseif d.robotPayout >= 3 and d.robotPayout <= 8 then --Maps Rooms
					d.prizeQueue = "Mapping"
					repeatRevealCheck(RoomType.ROOM_SECRET, "Secret", slot, sprite)
					if d.robotRoomName == "Secret" then
						sprite:Play('PrizeSecret', true)
					end
					repeatRevealCheck(RoomType.ROOM_SUPERSECRET, "SuperSecret", slot, sprite)
					if d.robotRoomName == "SuperSecret" then
						sprite:Play('PrizeSuperSecret', true)
					end
					if d.robotFinished ~= true then--Apply Compass Effect if both are revealed
					 	if savedata.robotMapLevel == nil then
							level:ApplyMapEffect()
							sprite:Play('PrizeMap', true)
							savedata.robotMapLevel = 1
						elseif savedata.robotMapLevel == 1 then
							level:ApplyCompassEffect()
							sprite:Play('PrizeCompass', true)
							savedata.robotMapLevel = 2
						elseif savedata.robotMapLevel == 2 then
							player:AnimateHappy()
							player:UsePill(PillEffect.PILLEFFECT_SEE_FOREVER,1,0)
							sprite:Play('PrizeDefault', true)
							savedata.robotMapLevel = 3
						else
							sprite:Play('PrizeDefault', true)
							d.prizeQueue = "Soul Heart"
						end
					end
					d.robotFinished = nil
				elseif d.robotPayout == 11 then --Raises Plan. Chance Doesnt work atm so its disabled with 11 wich it cant reach
					sprite:LoadGraphics()
					sprite:Play('PrizePlanetarium', true)	
					--print("Planetarium Up")
					Game():GetHUD():ShowFortuneText ("The stars align", "(doesn't work atm sorry)")
				elseif d.robotPayout == 9 then --Spawn Portal
					sprite:Play('PrizeDefault', true)
					d.prizeQueue = "Portal"
				end
			end
    elseif sprite:IsFinished('PrizeDefault') or sprite:IsFinished('Malfunction') or sprite:IsFinished('PrizeSecret') or sprite:IsFinished('PrizeCompass') or sprite:IsFinished('PrizeMap') or sprite:IsFinished('PrizeSuperSecret') or sprite:IsFinished('PrizePlanetarium') then
		 sprite:Play('Idle', true)
	elseif sprite:IsFinished('PrizeCard') then
		 sprite:Play('IdleCard', true)
    end
	d.prizeQueue = "Portal"
	--Prize Queue
	if sprite:IsEventTriggered('Prize') then
		if d.prizeQueue == "Soul Heart" then
			sfx:Play(SoundEffect.SOUND_SOUL_PICKUP, 1, 0, false, 1)
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 0.75, 0, false, 1)
			local chance = math.random(1,2)
			if chance == 1 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)
			end
		elseif d.prizeQueue == "Portal" then
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 0, false, 1)
			local f = 0
			if stage > 6 then
				f = math.random(2)+1
				--print("summon")
				--print(f)
			else
				f = math.random(3)
			end
			local portalsFromBefore = Isaac.FindByType(1000, 161, -1, true)
			for _, portal in ipairs(portalsFromBefore) do
				portal:Remove()
			end
			--portalsFromBefore:ToEffect():SetTimeout(1)
			Isaac.Spawn(1000, 161, f-1, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(80, 40)), Vector(0,0), nil)
		elseif d.prizeQueue == "Clear Curse" then
			sfx:Play(SoundEffect.SOUND_SOUL_PICKUP, 1, 0, false, 1)
			player:AnimateHappy()
		elseif d.prizeQueue == "Mapping" then
			sfx:Play(SoundEffect.SOUND_SOUL_PICKUP, 1, 0, false, 1)
		end
	end
	
	
	--SFX Stuff for Robot Teller
	if sprite:IsEventTriggered('Card') then
		sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
	end
	if sprite:IsEventTriggered('Glitching') then
		sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
	end
	if sprite:IsEventTriggered('Glitching2') then
		sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1)
	end
	if sprite:IsEventTriggered('CardZoom') then
		sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
	end
	if sprite:IsEventTriggered('Activate') then
		player:UseCard(d.robCard,1)
		sfx:Play(SoundEffect.SOUND_1UP, 1, 0, false, 1)
	end

	if not data.DropFunc then
		function data.DropFunc()
			if not data.DidDropFunc and not sprite:IsPlaying('Broken') then
				sprite:Play('Death', true)
				if d.robCard ~= nil then
				 Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, d.robCard, slot.Position, Vector(0, 4):Rotated(-30 + math.random(60)), slot)
				end
				local chanceDrop = math.random(5)
				if chanceDrop == 1 or chanceDrop == 2 or chanceDrop == 3 then
					Isaac.Spawn(5, 300, mod.robCardList[math.random(1, #mod.robCardList)], slot.Position, Vector(math.random(4, 7), 0):Rotated(math.random(180)), slot):ToPickup()
				end
				if chanceDrop == 3 then
					Isaac.Spawn(5, 300, mod.robCardList[math.random(1, #mod.robCardList)], slot.Position, Vector(math.random(4, 7), 0):Rotated(math.random(180)), slot):ToPickup()
				end	
				for i = 1, chanceDrop do
					Isaac.Spawn(5, 20, 1, slot.Position, Vector(math.random(4, 7), 0):Rotated(math.random(180)), slot):ToPickup()
				end
				data.DidDropFunc = true
			end
		end
	end
    FiendFolio.OverrideExplosionHack(slot, true)
	if d.spawnItem then
		local rewardData = mod.GetItemFromCustomItemPool(mod.CustomPool.ROBO_TELLER, slot:GetDropRNG())
		local pickup = Isaac.Spawn(5, rewardData[1], rewardData[2], slot.Position + Vector(0, -4), Vector.Zero, slot):ToPickup()

		--[[pickup:GetSprite():ReplaceSpritesheet(5, "gfx/items/slots/ff_chest_pedestals.png")
		pickup:GetSprite():LoadGraphics()
		pickup:GetSprite():SetOverlayFrame("Alternates", 1)]]

		pickup.SpawnerType = 6
		pickup.SpawnerVariant = 1032
		pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		pickup:Update()
		pickup:Update()
		pickup:Update()
		pickup:Update()
		slot:Remove()
	end
end, 1032)

--React to touch (Robot Teller)
FiendFolio.onMachineTouch(1032, function(player, slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
    if (sprite:IsPlaying('Idle') or sprite:IsPlaying('IdleCard')) and player:GetNumCoins() >= 1 then
			d.bumpedTeller = player
			player:AddCoins(-1)
            sfx:Play(SoundEffect.SOUND_COIN_SLOT, 0.8, 0, false, 1)
			if sprite:IsPlaying('Idle') then
            sprite:Play('Initiate', true)	
			elseif sprite:IsPlaying('IdleCard') then
            sprite:Play('InitiateCard', true)	
			end
			d.prizeQueue = "None"
    end
end)

function mod:FFRobotPedestal(pickup)
	if pickup.Variant == 100 then
		local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'PedestalData', tostring(pickup.InitSeed), {})
		if d.replaceMeRobot or pickup.SpawnerEntity then
			if d.replaceMeRobot or (pickup.SpawnerEntity.Type == 6 and pickup.SpawnerEntity.Variant == 1032) then
				pickup:GetSprite():ReplaceSpritesheet(5, "gfx/items/slots/ff_chest_pedestals.png")
				pickup:GetSprite():LoadGraphics()
				pickup:GetSprite():SetOverlayFrame("Alternates", 1)
				d.replaceMeRobot = true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.FFRobotPedestal)

--Evil Beggar (Anims)
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

	if not data.DropFunc then
		function data.DropFunc()
			if not data.DidDropFunc then
				sprite:Play('Bombed', true)
				data.DidDropFunc = true
				slot.Velocity = slot.Velocity * 0.3
			end
		end
	end
	
	if not data.init then
		data.init = true
		if mod:anyPlayerIsEitherKeeper() then
			sprite:ReplaceSpritesheet(0, "gfx/items/slots/evilBeggar_keeper.png")
			sprite:LoadGraphics()
		end
		if d.evilBeggarPayout and d.chanceBonus then
			if d.evilBeggarPayout <= 40+d.chanceBonus or d.chanceBonus == 32 then
				local itemChoice = 0
				itemChoice = ItemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, slot.InitSeed)
				Isaac.Spawn(5, 100, itemChoice, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
				slot:Remove()
			end
		end
	end
	

	
    if sprite:IsPlaying('Idle') then  -- luacheck: ignore 542
		if d.leaveOnInit == true then
		slot:Remove()
		end
    elseif sprite:IsFinished('PayNothing') then
		sprite:Play('Idle', true)
	elseif sprite:IsFinished('PayRedHeart') or sprite:IsFinished('PaySoulHeart') or sprite:IsFinished('PayCoin') then
		d.evilBeggarPayout = math.random(100)
		--print(d.evilBeggarPayout, 40+d.chanceBonus)
		if d.evilBeggarPayout <= 40+d.chanceBonus or d.chanceBonus == 32 then
		sprite:Play('Prize', true)
		else
		sprite:Play('Idle', true)
		end
	elseif sprite:IsPlaying('Prize') then
		if sprite:IsEventTriggered('Prize') then
			local payouts = 1
			if data.lastCollider and data.lastCollider:ToPlayer() then
				payouts = payouts + math.ceil(FiendFolio.GetGolemTrinketPower(data.lastCollider:ToPlayer(), FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
			end
			for i = 1, payouts do
				local itemChoice = 0
				itemChoice = ItemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, slot.InitSeed)
				Isaac.Spawn(5, 100, itemChoice, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
			end
			sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)
			d.leaveOnInit = true
        end
	elseif sprite:IsPlaying('Bombed') then
		if sprite:IsEventTriggered('Disappear') then
			Isaac.Spawn(4,3,0,slot.Position, Vector.FromAngle(math.random(30, 150)) * 4, slot)
        end
	elseif sprite:IsFinished('Prize') then
		sprite:Play('Teleport', true)
	elseif sprite:IsFinished('Teleport') or sprite:IsFinished('Bombed') then
		slot:Remove()
    end

    FiendFolio.OverrideExplosionHack(slot, true)
end, 1033)

--Evil Beggar Accepted function
local function evilBeggarAcceptPayment(d,player)
			player:UseActiveItem(486, false, false, true, false)
			sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
			d.chanceBonus = d.chanceBonus +16
end

--Evil Beggar (Touch)
FiendFolio.onMachineTouch(1033, function(player, slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
	if sprite:IsPlaying('Idle') and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B then
		if not d.chanceBonus then
			d.chanceBonus = -16
		end
		data.lastCollider = player
        sprite:LoadGraphics()
		if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
			if player:GetNumCoins() >= 15 then
			player:AddCoins(-15)
			sprite:Play('PayCoin', true)
			sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
			d.chanceBonus = d.chanceBonus +16
			else
			--print("Go get some coins")
			end
		elseif player:GetBoneHearts() ~= 0 then
		player:AddBoneHearts(-1)
		sprite:Play('PayRedHeart', true)
		evilBeggarAcceptPayment(d,player)
		elseif player:GetMaxHearts() ~= 0 then
		player:AddMaxHearts(-2)
		sprite:Play('PayRedHeart', true)
		evilBeggarAcceptPayment(d,player)
		elseif player:GetMaxHearts() == 0 and player:GetSoulHearts() >= 4 then
		player:AddSoulHearts(-4)
		sprite:Play('PaySoulHeart', true)
		evilBeggarAcceptPayment(d,player)
		end
		if player:GetMaxHearts() == 0 and player:GetBoneHearts() == 0 and player:GetSoulHearts() == 0 and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B and player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER_B and player:GetPlayerType() ~= PlayerType.PLAYER_LAZARUS then
		player:Die()
		end
	end
end)

local function Any(var, ...)
	for _, v in pairs({...}) do
		if v == var then return true end
	end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function()
	for _, slot in ipairs(Isaac.FindByType(6, -1, -1, false, false)) do
		if Any(slot.Variant, 1, 3) and slot.FrameCount == 0 then
			local r = slot:GetDropRNG()
			if r:RandomInt(10) == 0 then
				local newslot = Isaac.Spawn(6, mod.FF.RobotTeller.Var, 0, slot.Position, Vector.Zero, nil)
				slot:Remove()
				local effect = Isaac.Spawn(1000, 15, 0, newslot.Position, Vector.Zero, nil)
				effect.SpriteScale = effect.SpriteScale * 1.5
			end
		end
	end
end, 11)

local judgementSpawns = {
	mod.FF.ZodiacBeggar.Var,
	mod.FF.EvilBeggar.Var,
	mod.FF.HugBeggar.Var,
}

mod:AddCallback(ModCallbacks.MC_USE_CARD, function()
	sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 0, false, 1)
	for _, slot in ipairs(Isaac.FindByType(6, -1, -1, false, false)) do
		if Any(slot.Variant, 4, 5, 7, 9, 13, 18) and slot.FrameCount == 0 then
			local r = slot:GetDropRNG()

			if r:RandomInt(100) == 0 then
				local spawnBeggar
				repeat

					spawnBeggar = judgementSpawns[r:RandomInt(#judgementSpawns) + 1]
				until spawnBeggar ~= mod.FF.ZodiacBeggar.Var or FiendFolio.ACHIEVEMENT.ZODIAC_BEGGAR:IsUnlocked()

				if spawnBeggar == mod.FF.EvilBeggar.Var and not FiendFolio.ACHIEVEMENT.BEAST_BEGGAR:IsUnlocked() then
					spawnBeggar = 5 -- Normal devil beggar
				end

				if r:RandomInt(1000) == 0 then
					spawnBeggar = mod.FF.CosplayBeggar.Var
				end

				local newslot = Isaac.Spawn(6, spawnBeggar, 0, slot.Position, Vector.Zero, nil)
				slot:Remove()
				local effect = Isaac.Spawn(1000, 15, 0, newslot.Position, Vector.Zero, nil)
			end
		end
	end
end, 21)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, sub, pos, vel, spawner, seed)
	if typ == 6 and Any(var, 4, 5, 7, 9, 13, 18) then -- Default Beggar
		local back = game:GetRoom():GetBackdropType()
		local roomtype = game:GetRoom():GetType()

		local rng = RNG()
		rng:SetSeed(seed, 46)

		if back == 35 and FiendFolio.ACHIEVEMENT.ZODIAC_BEGGAR:IsUnlocked() then -- Planetarium
			if rng:RandomInt(100) < 66 then
				return {6, mod.FF.ZodiacBeggar.Var, 0, seed}
			end
		else
			local savedata = Isaac.GetPlayer():GetData().ffsavedata
			savedata.contrabandProgress = savedata.contrabandProgress
			if rng:RandomInt(100) < 18 and (savedata.contrabandProgress == nil or savedata.contrabandProgress == 0) and var == 4 then
				savedata.contrabandProgress = 1
				return {6, FiendFolio.FF.FakeBeggar.Var, 0, seed}
			end
		end

		-- Not sure about this yet, may enable later

		-- Curse rooms aint got their own background type, the bastards
		--[[if roomtype == RoomType.ROOM_CURSE then
			if rng:RandomInt(100) < 33 then
				return {6, FiendFolio.FF.EvilBeggar.Var, 0, seed}
			end
		end]]
	end
	if typ == 6 and Any(var, 1, 3) then -- Wheel of fortune override spawn
		--nothing
	end
end)

--Contraband (Anims)
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

	if not data.DropFunc then
		function data.DropFunc()
			if not data.DidDropFunc then
				Isaac.Spawn(5, 100, contraband, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 0)), Vector.Zero, nil)
				data.DidDropFunc = true
				local savedata = Isaac.GetPlayer():GetData().ffsavedata
				savedata.contrabandProgress = savedata.contrabandProgress
				savedata.contrabandProgress = 2
			end
		end
	end

    if sprite:IsPlaying('Idle') then  -- luacheck: ignore 542
	--pass
	elseif sprite:IsFinished('TransferDaGoods') then
		slot:Remove()
	elseif sprite:IsPlaying('TransferDaGoods') then
		if sprite:IsEventTriggered('Give') then
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false, 1)
			local r = math.random(2)
			if r == 1 then
			 Isaac.Spawn(5, 100, contraband, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
			elseif r == 2 then
			 local small = Isaac.Spawn(5, 300, Card.SMALL_CONTRABAND, slot.Position, Vector(0,3), nil):ToPickup()
			end
		end
    end
    FiendFolio.OverrideExplosionHack(slot)
end, 1034)

--Contraband Sidequest
FiendFolio.onMachineTouch(1034, function(player, slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	if sprite:IsPlaying('Idle') then
		data.lastCollider = player
        sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
        sprite:LoadGraphics()
		sprite:Play('TransferDaGoods', true)
		local savedata = Isaac.GetPlayer():GetData().ffsavedata
		savedata.contrabandProgress = savedata.contrabandProgress
		savedata.contrabandProgress = 2
    end
end)

--Spawn Dealer on next floor
function mod:onNewFloorDealer()
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	savedata.contrabandProgress = savedata.contrabandProgress
	--print(savedata.contrabandProgress)
	if savedata.contrabandProgress == 2 then
		Isaac.Spawn(6, 1035, 0, Game():GetRoom():FindFreePickupSpawnPosition(Vector(0, 40)), Vector.Zero, nil)
		savedata.contrabandProgress = 3
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloorDealer)

--Touch Dealer
FiendFolio.onMachineTouch(1035, function(player, slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	if sprite:IsPlaying('Idle') or sprite:IsPlaying('IdleLook')then
		data.lastCollider = player
		if player:HasCollectible(contraband) == true then
		 player:RemoveCollectible(contraband)
		 player:AnimateHappy()
		 sprite:Play('Deal', true)
		elseif player:GetCard(0) == Card.SMALL_CONTRABAND then
		 player:SetCard(0,0)
		 player:AnimateHappy()
		 sprite:Play('DealSmall', true)
		elseif player:GetCard(1) == Card.SMALL_CONTRABAND then
		 player:SetCard(1,0)
		 player:AnimateHappy()
		 sprite:Play('DealSmall', true)
		else
		 player:AnimateSad()
		 sprite:Play('Fuckup', true)
		end
		local savedata = Isaac.GetPlayer():GetData().ffsavedata
		savedata.contrabandProgress = savedata.contrabandProgress
		savedata.contrabandProgress = nil
    end
end)

--lil anim for him
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

	if not data.DropFunc then
		function data.DropFunc()
			if not data.DidDropFunc then
				data.DidDropFunc = true
			end
		end
	end

	if sprite:IsPlaying('Idle') then  -- luacheck: ignore 542
		sprite:Play('IdleLook', true)
	elseif sprite:IsFinished('IdleLook') then
		sprite:Play('Idle', true)
	elseif sprite:IsFinished('Fuckup') or sprite:IsFinished('Deal') or sprite:IsFinished('DealSmall') then
		slot:Remove()
    end
	if sprite:IsEventTriggered("Crack") then
		local r = math.random(2, 3)
		local rng = RNG()
		rng:SetSeed(slot.InitSeed, 42)

		if r == 2 then
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(40, 40)), Vector.Zero, slot)
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, slot)
		else
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(-40, 40)), Vector.Zero, slot)
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, slot)
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(40, 40)), Vector.Zero, slot)
		end
		local payouts = 0
		if data.lastCollider and data.lastCollider:ToPlayer() then
			payouts = payouts + math.ceil(FiendFolio.GetGolemTrinketPower(data.lastCollider:ToPlayer(), FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
		end
		for i = 1, payouts do
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, slot)
		end
	end
	
	if sprite:IsEventTriggered("Small") then
		local rng = RNG()
		rng:SetSeed(slot.InitSeed, 42)
		local payouts = 1
		if data.lastCollider and data.lastCollider:ToPlayer() then
			payouts = payouts + math.ceil(FiendFolio.GetGolemTrinketPower(data.lastCollider:ToPlayer(), FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
		end
		for i = 1, payouts do
			Isaac.Spawn(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.CONTRABAND, rng), Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, slot)
		end
	end
	
    FiendFolio.OverrideExplosionHack(slot, true)
end, 1035)

function mod:getHighAsFuck(type, rng, player)
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	savedata.highIdiot = savedata.highIdiot
	savedata.highIdiot = 1	
	for i=1, 8 do
		player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, false, true, true, false) --Triggers on contraband use
	end
	player:UsePill(42, 0)
	Game():GetHUD():ShowItemText("Oh No...")
	local dust = Isaac.Spawn(1000, 18, 0, player.Position, Vector.Zero, player):ToEffect()
	dust.Color = Color(1,1,1,1,1,1,1)
	sfx:Play(80, 1, 0, false, 3)
return {Discharge = false, Remove = true, ShowAnim = true};
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.getHighAsFuck, contraband)

--Clear Drugs next floor
--[[
function mod:onNewRoomDrugs()
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	savedata.highIdiot = savedata.highIdiot
	if savedata.highIdiot == 1 then
		Isaac.GetPlayer():UsePill(42, 0, UseFlag.USE_NOANIM)
		Game():GetHUD():ShowItemText("Oh No...")
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoomDrugs)]]

--its stupid but i do it because i have to
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	if savedata.highIdiot == 1 then
		SFXManager():Stop(453)
	end
end)

--Clear Drugs next floor
function mod:onNewFloorDrugs()
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	savedata.highIdiot = savedata.highIdiot
	savedata.highIdiot = nil
	savedata.robotMapLevel = nil
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloorDrugs)

--Dying Battery
FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, data = slot:GetSprite(), slot:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
	
	if not data.DropFunc then
		function data.DropFunc()
			if not data.DidDropFunc then
				data.DidDropFunc = true
			end
		end
	end

	if sprite:IsFinished('Destroy') then
		Isaac.Explode(slot.Position,slot,0)
		slot:Remove()
    elseif not sprite:IsPlaying('Appear')and not sprite:IsPlaying('Destroy') then  -- luacheck: ignore 542
		sprite:Play('Destroy', true)
    end
	
	if sprite:IsEventTriggered('Glitch') then
		sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
	end
    FiendFolio.OverrideExplosionHack(slot)
end, 666)