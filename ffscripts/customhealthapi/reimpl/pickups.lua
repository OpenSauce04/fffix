function CustomHealthAPI.Helper.AddHeartCollisionCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_PRE_PICKUP_COLLISION, CustomHealthAPI.Mod.HeartCollisionCallback, PickupVariant.PICKUP_HEART)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_PICKUP_COLLISION] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_PICKUP_COLLISION] or {}
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_PICKUP_COLLISION][PickupVariant.PICKUP_HEART] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_PICKUP_COLLISION][PickupVariant.PICKUP_HEART] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_PICKUP_COLLISION][PickupVariant.PICKUP_HEART], CustomHealthAPI.Helper.AddHeartCollisionCallback)

function CustomHealthAPI.Helper.RemoveHeartCollisionCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CustomHealthAPI.Mod.HeartCollisionCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_PICKUP_COLLISION] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_PICKUP_COLLISION] or {}
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_PICKUP_COLLISION][PickupVariant.PICKUP_HEART] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_PICKUP_COLLISION][PickupVariant.PICKUP_HEART] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_PICKUP_COLLISION][PickupVariant.PICKUP_HEART], CustomHealthAPI.Helper.RemoveHeartCollisionCallback)

function CustomHealthAPI.Mod:HeartCollisionCallback(pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		local hearttype = pickup.SubType
		local sprite = pickup:GetSprite()
		
		local redIsDoubled = player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)
		local canJarRedHearts = player:HasCollectible(CollectibleType.COLLECTIBLE_THE_JAR) and player:GetJarHearts() < 8
		local hasSodomApple = player:HasTrinket(TrinketType.TRINKET_APPLE_OF_SODOM)
		
		if hearttype < 1 or 
		   hearttype > 12 or 
		   player:GetPlayerType() == PlayerType.PLAYER_THELOST or 
		   player:GetPlayerType() == PlayerType.PLAYER_THELOST_B 
		then
			return
		elseif pickup:IsShopItem() and (pickup.Price > player:GetNumCoins() or not player:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not (sprite:IsPlaying("Idle") or sprite:IsPlaying("IdlePanic"))
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") or sprite:IsPlaying("IdlePanic") then
			local redHealthBefore = player:GetHearts()
			local soulHealthBefore = player:GetSoulHearts()
			
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			local shouldApple = false
			if hasSodomApple then
				local applerng = RNG()
				applerng:SetSeed(pickup.InitSeed, 1)
				shouldApple = applerng:RandomInt(2) == 1
			end
			
			local removeWithNoAnim = false
			local shouldSetHeartPicked = true
			if hearttype == HeartSubType.HEART_FULL and shouldApple then
				local mod = 3
				if redIsDoubled then
					mod = mod * 2
				end
				CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
				removeWithNoAnim = true
				shouldSetHeartPicked = false
			elseif hearttype == HeartSubType.HEART_HALF and shouldApple then
				local mod = 1
				if redIsDoubled then
					mod = mod * 2
				end
				CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
				removeWithNoAnim = true
				shouldSetHeartPicked = false
			elseif hearttype == HeartSubType.HEART_DOUBLEPACK and shouldApple then
				local mod = 6
				if redIsDoubled then
					mod = mod * 2
				end
				CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
				removeWithNoAnim = true
				shouldSetHeartPicked = false
			elseif hearttype == HeartSubType.HEART_FULL and CustomHealthAPI.Helper.CanPickKey(player, "RED_HEART") then
				local hp = 2
				if redIsDoubled then
					hp = hp * 2
				end
				CustomHealthAPI.Library.AddHealth(player, "RED_HEART", hp, true)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_HALF and CustomHealthAPI.Helper.CanPickKey(player, "RED_HEART") then
				local hp = 1
				if redIsDoubled then
					hp = hp * 2
				end
				CustomHealthAPI.Library.AddHealth(player, "RED_HEART", hp, true)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_SOUL and CustomHealthAPI.Helper.CanPickKey(player, "SOUL_HEART") then
				CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", 2, true)
				SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_ETERNAL then
				CustomHealthAPI.Library.AddHealth(player, "ETERNAL_HEART", 1, true)
				SFXManager():Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_DOUBLEPACK and CustomHealthAPI.Helper.CanPickKey(player, "RED_HEART") then
				local hp = 4
				if redIsDoubled then
					hp = hp * 2
				end
				CustomHealthAPI.Library.AddHealth(player, "RED_HEART", hp, true)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_BLACK and CustomHealthAPI.Helper.CanPickKey(player, "BLACK_HEART") then
				CustomHealthAPI.Library.AddHealth(player, "BLACK_HEART", 2, true)
				SFXManager():Play(SoundEffect.SOUND_UNHOLY, 1, 0, false, 1.0)
				
				if player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_REDEMPTION) == 1 and 
				   Game():GetRoom():GetType() == RoomType.ROOM_DEVIL 
				then
					for _, redemption in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.REDEMPTION)) do
						if redemption.Parent.Index == player.Index and redemption.Parent.InitSeed == redemption.Parent.InitSeed then
							redemption:GetSprite():Play("Fail", true)
							redemption:ToEffect().State = 3
						end
					end
					player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_REDEMPTION)
					SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 1.0)
				end
			elseif hearttype == HeartSubType.HEART_GOLDEN and CustomHealthAPI.Helper.CanPickKey(player, "GOLDEN_HEART") then
				CustomHealthAPI.Library.AddHealth(player, "GOLDEN_HEART", 1, true)
				SFXManager():Play(SoundEffect.SOUND_GOLD_HEART, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_HALF_SOUL and CustomHealthAPI.Helper.CanPickKey(player, "SOUL_HEART") then
				CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", 1, true)
				SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_SCARED and CustomHealthAPI.Helper.CanPickKey(player, "RED_HEART") then
				local hp = 2
				if redIsDoubled then
					hp = hp * 2
				end
				CustomHealthAPI.Library.AddHealth(player, "RED_HEART", hp, true)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_BLENDED and 
			       (CustomHealthAPI.Helper.CanPickKey(player, "RED_HEART") or CustomHealthAPI.Helper.CanPickKey(player, "SOUL_HEART"))
			then
				for i = 1, 2 do
					if CustomHealthAPI.Helper.CanPickKey(player, "RED_HEART") then
					local hp = 1
						if redIsDoubled then
							hp = hp * 2
						end
						CustomHealthAPI.Library.AddHealth(player, "RED_HEART", hp, true)
						SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
					elseif CustomHealthAPI.Helper.CanPickKey(player, "SOUL_HEART") then
						CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", 1, true)
						SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1.0)
					end
				end
			elseif hearttype == HeartSubType.HEART_BONE and CustomHealthAPI.Helper.CanPickKey(player, "BONE_HEART") then
				CustomHealthAPI.Library.AddHealth(player, "BONE_HEART", 1, true)
				SFXManager():Play(SoundEffect.SOUND_BONE_HEART, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_ROTTEN and CustomHealthAPI.Helper.CanPickKey(player, "ROTTEN_HEART") then
				CustomHealthAPI.Library.AddHealth(player, "ROTTEN_HEART", 2, true)
				SFXManager():Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_FULL and canJarRedHearts then
				local hp = 2
				if redIsDoubled then
					hp = hp * 2
				end
				player:AddJarHearts(hp)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_HALF and canJarRedHearts then
				local hp = 1
				if redIsDoubled then
					hp = hp * 2
				end
				player:AddJarHearts(hp)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_DOUBLEPACK and canJarRedHearts then
				local hp = 4
				if redIsDoubled then
					hp = hp * 2
				end
				player:AddJarHearts(hp)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_SCARED and canJarRedHearts then
				local hp = 2
				if redIsDoubled then
					hp = hp * 2
				end
				player:AddJarHearts(hp)
				SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
			elseif hearttype == HeartSubType.HEART_FULL and hasSodomApple then
				local mod = 3
				if redIsDoubled then
					mod = mod * 2
				end
				CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
				removeWithNoAnim = true
				shouldSetHeartPicked = false
			elseif hearttype == HeartSubType.HEART_HALF and hasSodomApple then
				local mod = 1
				if redIsDoubled then
					mod = mod * 2
				end
				CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
				removeWithNoAnim = true
				shouldSetHeartPicked = false
			elseif hearttype == HeartSubType.HEART_DOUBLEPACK and hasSodomApple then
				local mod = 6
				if redIsDoubled then
					mod = mod * 2
				end
				CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
				removeWithNoAnim = true
				shouldSetHeartPicked = false
			else
				return pickup:IsShopItem()
			end
			
			local redHealthAfter = player:GetHearts()
			local soulHealthAfter = player:GetSoulHearts()
			
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CANDY_HEART) and redHealthAfter > redHealthBefore then
				local candiesToAdd = redHealthAfter - redHealthBefore
				
				local rng = RNG()
				rng:SetSeed(pickup.InitSeed, 35)
				
				local p = player
				player:GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
				local pdata = player:GetData().CustomHealthAPIPersistent
				
				if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
					if player:GetOtherTwin() ~= nil then
						local p = player:GetOtherTwin()
						player:GetOtherTwin():GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
						pdata = player:GetOtherTwin():GetData().CustomHealthAPIPersistent
					end
				end
				
				for i = 1, candiesToAdd do
					local rand = math.random(1, 6)
					if rand == 1 then
						pdata.FakeCandyHeartDamage = (pdata.FakeCandyHeartDamage or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					elseif rand == 2 then
						pdata.FakeCandyHeartTears = (pdata.FakeCandyHeartTears or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
					elseif rand == 3 then
						pdata.FakeCandyHeartSpeed = (pdata.FakeCandyHeartSpeed or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_SPEED)
					elseif rand == 4 then
						pdata.FakeCandyHeartShotSpeed = (pdata.FakeCandyHeartShotSpeed or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
					elseif rand == 5 then
						pdata.FakeCandyHeartRange = (pdata.FakeCandyHeartRange or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_RANGE)
					else
						pdata.FakeCandyHeartLuck = (pdata.FakeCandyHeartLuck or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_LUCK)
					end
				end
	
				p:EvaluateItems()
			end
			
			if player:HasCollectible(CollectibleType.COLLECTIBLE_SOUL_LOCKET) and soulHealthAfter > soulHealthBefore then
				local locketsToAdd = soulHealthAfter - soulHealthBefore
				
				local rng = RNG()
				rng:SetSeed(pickup.InitSeed, 40)
				
				local p = player
				player:GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
				local pdata = player:GetData().CustomHealthAPIPersistent
				
				if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
					if player:GetOtherTwin() ~= nil then
						local p = player:GetOtherTwin()
						player:GetOtherTwin():GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
						pdata = player:GetOtherTwin():GetData().CustomHealthAPIPersistent
					end
				end
				
				for i = 1, locketsToAdd do
					local rand = math.random(1, 6)
					if rand == 1 then
						pdata.FakeSoulLocketDamage = (pdata.FakeSoulLocketDamage or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					elseif rand == 2 then
						pdata.FakeSoulLocketTears = (pdata.FakeSoulLocketTears or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
					elseif rand == 3 then
						pdata.FakeSoulLocketSpeed = (pdata.FakeSoulLocketSpeed or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_SPEED)
					elseif rand == 4 then
						pdata.FakeSoulLocketShotSpeed = (pdata.FakeSoulLocketShotSpeed or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
					elseif rand == 5 then
						pdata.FakeSoulLocketRange = (pdata.FakeSoulLocketRange or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_RANGE)
					else
						pdata.FakeSoulLocketLuck = (pdata.FakeSoulLocketLuck or 0) + 1
						p:AddCacheFlags(CacheFlag.CACHE_LUCK)
					end
				end
	
				p:EvaluateItems()
			end

			if pickup.OptionsPickupIndex ~= 0 then
				local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
				for _, entity in ipairs(pickups) do
					if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
					   (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
					then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
						entity:Remove()
					end
				end
			end

			if pickup:IsShopItem() then
				if not removeWithNoAnim then
					local pickupSprite = pickup:GetSprite()
					local holdSprite = Sprite()
					
					holdSprite:Load(pickupSprite:GetFilename(), true)
					holdSprite:Play(pickupSprite:GetAnimation(), true)
					holdSprite:SetFrame(pickupSprite:GetFrame())
					player:AnimatePickup(holdSprite)
				end
				
				if pickup.Price > 0 then
					player:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(player)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			elseif removeWithNoAnim then
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			if shouldSetHeartPicked then
				Game():GetLevel():SetHeartPicked()
				Game():ClearStagesWithoutHeartsPicked()
				Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			end
			
			return true
		else
			return false
		end
	end
end

function CustomHealthAPI.Helper.HandleSodomAppleEffects(player, pickup, mod)
    -- thank you decomp
	SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
    
	local rng = RNG()
	rng:SetSeed(pickup.InitSeed, 45)
	
	local explo = Isaac.Spawn(1000, 2, 3, pickup.Position, Vector.Zero, nil)
	explo:Update()
	
	local splat = Isaac.Spawn(1000, 7, 0, pickup.Position, Vector.Zero, nil)
	splat:Update()
	
    local numGibs = rng:RandomInt(3) + mod
    for i = 1, numGibs do
		local gibpos = pickup.Position + Vector.FromAngle(rng:RandomFloat() * 360) * 0.5 * pickup.Size
		local gibvel = Vector.FromAngle(rng:RandomFloat() * 360) * (rng:RandomFloat() * 4.0 + 2.0)
		
		local gib = Isaac.Spawn(1000, 5, 0, gibpos, gibvel, nil)
		gib:Update()
    end
	
    local numSpiders = rng:RandomInt(3) + mod
    for i = 1, numSpiders do
		local targetoffset = Vector.FromAngle(rng:RandomFloat() * 360) * (rng:RandomFloat() / 2 + 0.5) * 15
		player:ThrowBlueSpider(pickup.Position, pickup.Position + Vector(0, 60) + targetoffset)
    end
	
	Game():ButterBeanFart(pickup.Position, 100.0, player, true, false)
end

local function tearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

function CustomHealthAPI.Helper.AddCandiesAndLocketsCacheCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_EVALUATE_CACHE, CustomHealthAPI.Mod.CandiesAndLocketsCacheCallback, -1)
end
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE] or {}
table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE], CustomHealthAPI.Helper.AddCandiesAndLocketsCacheCallback)

function CustomHealthAPI.Helper.RemoveCandiesAndLocketsCacheCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, CustomHealthAPI.Mod.CandiesAndLocketsCacheCallback)
end
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE] or {}
table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE], CustomHealthAPI.Helper.RemoveCandiesAndLocketsCacheCallback)

function CustomHealthAPI.Mod:CandiesAndLocketsCacheCallback(player, flag)
	player:GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
	local pdata = player:GetData().CustomHealthAPIPersistent
	
	if flag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.02 * (pdata.FakeCandyHeartSpeed or 0)
		player.MoveSpeed = player.MoveSpeed + 0.04 * (pdata.FakeSoulLocketSpeed or 0)
	elseif flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.1 * (pdata.FakeCandyHeartDamage or 0)
		player.Damage = player.Damage + 0.2 * (pdata.FakeSoulLocketDamage or 0)
	elseif flag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = tearsUp(player.MaxFireDelay, 0.05 * (pdata.FakeCandyHeartTears or 0))
		player.MaxFireDelay = tearsUp(player.MaxFireDelay, 0.1 * (pdata.FakeSoulLocketTears or 0))
	elseif flag == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + 6 * (pdata.FakeCandyHeartRange or 0)
		player.TearRange = player.TearRange + 12 * (pdata.FakeSoulLocketRange or 0)
	elseif flag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + 0.02 * (pdata.FakeCandyHeartShotSpeed or 0)
		player.ShotSpeed = player.ShotSpeed + 0.04 * (pdata.FakeSoulLocketShotSpeed or 0)
	elseif flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + 0.1 * (pdata.FakeCandyHeartLuck or 0)
		player.Luck = player.Luck + 0.2 * (pdata.FakeSoulLocketLuck or 0)
	end
end

function CustomHealthAPI.Helper.AddClearCandiesAndLocketsCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_PRE_USE_ITEM, CustomHealthAPI.Mod.ClearCandiesAndLocketsCallback, CollectibleType.COLLECTIBLE_D4)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM] or {}
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_D4] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_D4] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_D4], CustomHealthAPI.Helper.AddClearCandiesAndLocketsCallback)

function CustomHealthAPI.Helper.RemoveClearCandiesAndLocketsCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_PRE_USE_ITEM, CustomHealthAPI.Mod.ClearCandiesAndLocketsCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM] or {}
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_D4] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_D4] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_D4], CustomHealthAPI.Helper.RemoveClearCandiesAndLocketsCallback)

function CustomHealthAPI.Mod:ClearCandiesAndLocketsCallback(id, rng, player)
	CustomHealthAPI.Helper.ClearCandiesAndLockets(player)
end

function CustomHealthAPI.Helper.ClearCandiesAndLockets(player)
	local p = player
	player:GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
	local pdata = player:GetData().CustomHealthAPIPersistent
	
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			local p = player:GetOtherTwin()
			player:GetOtherTwin():GetData().CustomHealthAPIPersistent = player:GetData().CustomHealthAPIPersistent or {}
			pdata = player:GetOtherTwin():GetData().CustomHealthAPIPersistent
		end
	end
	
	pdata.FakeCandyHeartDamage = nil
	pdata.FakeCandyHeartTears = nil
	pdata.FakeCandyHeartSpeed = nil
	pdata.FakeCandyHeartShotSpeed = nil
	pdata.FakeCandyHeartRange = nil
	pdata.FakeCandyHeartLuck = nil
	
	pdata.FakeSoulLocketDamage = nil
	pdata.FakeSoulLocketTears = nil
	pdata.FakeSoulLocketSpeed = nil
	pdata.FakeSoulLocketShotSpeed = nil
	pdata.FakeSoulLocketRange = nil
	pdata.FakeSoulLocketLuck = nil
	
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | 
	                     CacheFlag.CACHE_FIREDELAY | 
	                     CacheFlag.CACHE_SPEED | 
	                     CacheFlag.CACHE_SHOTSPEED | 
	                     CacheFlag.CACHE_RANGE | 
	                     CacheFlag.CACHE_LUCK)
	
	player:EvaluateItems()
end