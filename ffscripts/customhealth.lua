local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

----------------------------
-- Registration
----------------------------

local immoralSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00)
immoralSplatColor:SetColorize(1.75, 1.25, 2.0, 1.0)
local immoralTrailColor = Color(0.80, 0.30, 1.00, 0.40, 0.00, 0.00, 0.00)

local morbidSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00)
morbidSplatColor:SetColorize(0.75, 0.75, 0.5, 1.0)
local morbidTrailColor = Color(0.50, 0.55, 0.20, 0.40, 0.00, 0.00, 0.00)

CustomHealthAPI.Library.RegisterSoulHealth("IMMORAL_HEART", 
                                   {AnimationFilename = "gfx/ui/immoral_hearts.anm2",
                                    AnimationName = {"ImmoralHeartHalf", "ImmoralHeartFull"},
                                    SortOrder = 100, 
                                    AddPriority = 125,
                                    HealFlashRO = 80/255, 
                                    HealFlashGO = 30/255,
                                    HealFlashBO = 50/255,
                                    MaxHP = 2,
								    PrioritizeHealing = false,
                                    PickupEntities = {{ID = EntityType.ENTITY_PICKUP, Var = FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART, Sub = 0}, 
                                                      {ID = EntityType.ENTITY_PICKUP, Var = FiendFolio.PICKUP.VARIANT.IMMORAL_HEART, Sub = 0}},
                                    SumptoriumSubType = 920,
                                    SumptoriumSplatColor = immoralSplatColor,
                                    SumptoriumTrailColor = immoralTrailColor,
                                    SumptoriumCollectSoundSettings = {ID = FiendFolio.Sounds.FiendHeartPickup,
                                                                      Volume = 1.0,
                                                                      FrameDelay = 0,
                                                                      Loop = false,
                                                                      Pitch = 1.0,
                                                                      Pan = 0}})

CustomHealthAPI.Library.RegisterRedHealth("MORBID_HEART", 
                                  {MaxHP = 3,
                                   AnimationFilenames = {EMPTY_HEART = "gfx/ui/morbid_hearts.anm2",
                                                         BONE_HEART = "gfx/ui/morbid_hearts.anm2",
                                                         LEAKY_HEART = "gfx/ui/morbid_hearts.anm2"},								  
                                   AnimationNames = {EMPTY_HEART = {"MorbidHeartThird", "MorbidHeartHalf", "MorbidHeartFull"},
                                                     BONE_HEART = {"MorbidBoneHeartThird", "MorbidBoneHeartHalf", "MorbidBoneHeartFull"},
                                                     LEAKY_HEART = {"MorbidLeakyHeartThird", "MorbidLeakyHeartHalf", "MorbidLeakyHeartFull"}},
                                   SortOrder = 200, 
                                   AddPriority = 200,
                                   HealFlashRO = 26/255, 
                                   HealFlashGO = 80/255, 
                                   HealFlashBO = 26/255,
                                   ProtectsDealChance = false,
                                   PrioritizeHealing = false,
                                   PickupEntities = {{ID = EntityType.ENTITY_PICKUP, Var = FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART, Sub = 0}, 
                                                     {ID = EntityType.ENTITY_PICKUP, Var = FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART, Sub = 0}, 
                                                     {ID = EntityType.ENTITY_PICKUP, Var = FiendFolio.PICKUP.VARIANT.MORBID_HEART, Sub = 0}},
                                   SumptoriumSubType = 921,
                                   SumptoriumSplatColor = morbidSplatColor,
                                   SumptoriumTrailColor = morbidTrailColor,
                                   SumptoriumCollectSoundSettings = {ID = SoundEffect.SOUND_ROTTEN_HEART,
                                                                     Volume = 1.0,
                                                                     FrameDelay = 0,
                                                                     Loop = false,
                                                                     Pitch = 1.0,
                                                                     Pan = 0}})

--[[CustomHealthAPI.Library.RegisterHealthContainer("LEAKY_HEART", 
                                        {MaxHP = 0, 
                                         AnimationFilename = "gfx/ui/leaky_hearts.anm2",
                                         AnimationName = "LeakyHeartEmpty",
                                         SortOrder = 200, 
                                         AddPriority = 200, 
                                         RemovePriority = 200, 
                                         ProtectsDealChance = true, 
                                         CanHaveHalfCapacity = false,
                                         ForceBleedingIfFilled = true})

CustomHealthAPI.Library.DefineContainerForRedHealth("RED_HEART", 
                                      "LEAKY_HEART", 
                                      "gfx/ui/leaky_hearts.anm2",
                                      {"LeakyHeartHalf", "LeakyHeartFull"})

CustomHealthAPI.Library.DefineContainerForRedHealth("ROTTEN_HEART",
                                      "LEAKY_HEART",
                                      "gfx/ui/leaky_hearts.anm2",
                                      {"RottenLeakyHeartFull"})]]--

--[[CustomHealthAPI.Library.RegisterRedHealth("TEST_HEART_1", CustomHealthAPI.Enums.HealthKinds.HEART,
                                  {EMPTY_HEART = "gfx/ui/test_heart_1.anm2",
                                   BONE_HEART = "gfx/ui/test_heart_1.anm2"},								  
                                  {EMPTY_HEART = {"Full"},
                                   BONE_HEART = {"Full"}},
                                  3, 3,
                                  128/255, 0/255, 0/255,
                                  1,
                                  false,
                                  false)]]--

--[[CustomHealthAPI.Library.RegisterRedHealth("TEST_HEART_2", CustomHealthAPI.Enums.HealthKinds.HEART,
                                  {EMPTY_HEART = "gfx/ui/test_heart_2.anm2",
                                   BONE_HEART = "gfx/ui/test_heart_2.anm2"},								  
                                  {EMPTY_HEART = {"Half", "Full"},
                                   BONE_HEART = {"Half", "Full"}},
                                  3, 4,
                                  128/255, 0/255, 0/255,
                                  2,
                                  false,
                                  false)]]--

--[[CustomHealthAPI.Library.RegisterRedHealth("TEST_HEART_3", CustomHealthAPI.Enums.HealthKinds.HEART,
                                  {EMPTY_HEART = "gfx/ui/test_heart_3.anm2",
                                   BONE_HEART = "gfx/ui/test_heart_3.anm2"},								  
                                  {EMPTY_HEART = {"Third", "Half", "Full"},
                                   BONE_HEART = {"Third", "Half", "Full"}},
                                  3, 5,
                                  128/255, 0/255, 0/255,
                                  3,
                                  false,
                                  false)]]--

--[[CustomHealthAPI.Library.RegisterRedHealth("TEST_HEART_4", CustomHealthAPI.Enums.HealthKinds.HEART,
                                  {EMPTY_HEART = "gfx/ui/test_heart_4.anm2",
                                   BONE_HEART = "gfx/ui/test_heart_4.anm2"},								  							  
                                  {EMPTY_HEART = {"Fourth", "Third", "Half", "Full"},
                                   BONE_HEART = {"Fourth", "Third", "Half", "Full"}},
                                  3, 6,
                                  128/255, 0/255, 0/255,
                                  4,
                                  false,
                                  false)]]--

----------------------------
-- Pickups
----------------------------

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:keeperFlyCheck(pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(mod.Sounds.FiendHeartDrop, 0.8, 0, false, 1.0)
	end
end, FiendFolio.PICKUP.VARIANT.IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local collider = collider:ToPlayer()
		local sprite = pickup:GetSprite()
		
		if pickup:IsShopItem() and (pickup.Price > collider:GetNumCoins() or not collider:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not sprite:IsPlaying("Idle")
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			if CustomHealthAPI.Library.CanPickKey(collider, "IMMORAL_HEART") then
				CustomHealthAPI.Library.AddHealth(collider, "IMMORAL_HEART", 2, true)
				if math.random(1000) == 1 then
					sfx:Play(mod.Sounds.FiendHeartPickupRare, 1, 0, false, 1.0)
				else
					sfx:Play(mod.Sounds.FiendHeartPickup, 1, 0, false, 1)
				end
			else
				return pickup:IsShopItem()
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
				local pickupSprite = pickup:GetSprite()
				local holdSprite = Sprite()
				
				holdSprite:Load(pickupSprite:GetFilename(), true)
				holdSprite:Play(pickupSprite:GetAnimation(), true)
				holdSprite:SetFrame(pickupSprite:GetFrame())
				collider:AnimatePickup(holdSprite)
				
				if pickup.Price > 0 then
					collider:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(collider)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		else
			return false
		end
	end
end, FiendFolio.PICKUP.VARIANT.IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:keeperFlyCheck(pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(mod.Sounds.FiendHeartDrop, 0.8, 0, false, 1.0)
	end
end, FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local collider = collider:ToPlayer()
		local sprite = pickup:GetSprite()
		
		if pickup:IsShopItem() and (pickup.Price > collider:GetNumCoins() or not collider:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not sprite:IsPlaying("Idle")
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			if CustomHealthAPI.Library.CanPickKey(collider, "IMMORAL_HEART") then
				CustomHealthAPI.Library.AddHealth(collider, "IMMORAL_HEART", 1, true)
				if math.random(1000) == 1 then
					sfx:Play(mod.Sounds.FiendHeartPickupRare, 1, 0, false, 1.0)
				else
					sfx:Play(mod.Sounds.FiendHeartPickup, 1, 0, false, 1)
				end
			else
				return pickup:IsShopItem()
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
				local pickupSprite = pickup:GetSprite()
				local holdSprite = Sprite()
				
				holdSprite:Load(pickupSprite:GetFilename(), true)
				holdSprite:Play(pickupSprite:GetAnimation(), true)
				holdSprite:SetFrame(pickupSprite:GetFrame())
				collider:AnimatePickup(holdSprite)
				
				if pickup.Price > 0 then
					collider:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(collider)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		else
			return false
		end
	end
end, FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:keeperFlyCheck(pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(mod.Sounds.FiendHeartDrop, 0.8, 0, false, 1.0)
	end
end, FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local collider = collider:ToPlayer()
		local sprite = pickup:GetSprite()
		
		if pickup:IsShopItem() and (pickup.Price > collider:GetNumCoins() or not collider:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not sprite:IsPlaying("Idle")
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
			local redIsDoubled = collider:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)
			
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			if CustomHealthAPI.Helper.CanPickKey(collider, "RED_HEART") or 
			   CustomHealthAPI.Helper.CanPickKey(collider, "IMMORAL_HEART")
			then
				for i = 1, 2 do
					if CustomHealthAPI.Helper.CanPickKey(collider, "RED_HEART") then
						local hp = 1
						if redIsDoubled then
							hp = hp * 2
						end
						CustomHealthAPI.Library.AddHealth(collider, "RED_HEART", hp, true)
						SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, 1.0)
					elseif CustomHealthAPI.Helper.CanPickKey(collider, "IMMORAL_HEART") then
						CustomHealthAPI.Library.AddHealth(collider, "IMMORAL_HEART", 1, true)
						sfx:Play(mod.Sounds.FiendHeartPickup, 1, 0, false, 1)
					end
				end
			else
				return pickup:IsShopItem()
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
				local pickupSprite = pickup:GetSprite()
				local holdSprite = Sprite()
				
				holdSprite:Load(pickupSprite:GetFilename(), true)
				holdSprite:Play(pickupSprite:GetAnimation(), true)
				holdSprite:SetFrame(pickupSprite:GetFrame())
				collider:AnimatePickup(holdSprite)
				
				if pickup.Price > 0 then
					collider:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(collider)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		else
			return false
		end
	end
end, FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:keeperFlyCheck(pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_MEAT_FEET_SLOW0, 1.0, 0, false, 1.0)
	end
end, FiendFolio.PICKUP.VARIANT.MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local collider = collider:ToPlayer()
		local sprite = pickup:GetSprite()
		
		if pickup:IsShopItem() and (pickup.Price > collider:GetNumCoins() or not collider:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not sprite:IsPlaying("Idle")
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			if CustomHealthAPI.Library.CanPickKey(collider, "MORBID_HEART") then
				CustomHealthAPI.Library.AddHealth(collider, "MORBID_HEART", 3, true)
				SFXManager():Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1.0)
			else
				return pickup:IsShopItem()
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
				local pickupSprite = pickup:GetSprite()
				local holdSprite = Sprite()
				
				holdSprite:Load(pickupSprite:GetFilename(), true)
				holdSprite:Play(pickupSprite:GetAnimation(), true)
				holdSprite:SetFrame(pickupSprite:GetFrame())
				collider:AnimatePickup(holdSprite)
				
				if pickup.Price > 0 then
					collider:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(collider)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		else
			return false
		end
	end
end, FiendFolio.PICKUP.VARIANT.MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:keeperFlyCheck(pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_MEAT_FEET_SLOW0, 1.0, 0, false, 1.0)
	end
end, FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local collider = collider:ToPlayer()
		local sprite = pickup:GetSprite()
		
		if pickup:IsShopItem() and (pickup.Price > collider:GetNumCoins() or not collider:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not sprite:IsPlaying("Idle")
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			if CustomHealthAPI.Library.CanPickKey(collider, "MORBID_HEART") then
				CustomHealthAPI.Library.AddHealth(collider, "MORBID_HEART", 2, true)
				SFXManager():Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1.0)
			else
				return pickup:IsShopItem()
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
				local pickupSprite = pickup:GetSprite()
				local holdSprite = Sprite()
				
				holdSprite:Load(pickupSprite:GetFilename(), true)
				holdSprite:Play(pickupSprite:GetAnimation(), true)
				holdSprite:SetFrame(pickupSprite:GetFrame())
				collider:AnimatePickup(holdSprite)
				
				if pickup.Price > 0 then
					collider:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(collider)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		else
			return false
		end
	end
end, FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:keeperFlyCheck(pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_MEAT_FEET_SLOW0, 1.0, 0, false, 1.0)
	end
end, FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local collider = collider:ToPlayer()
		local sprite = pickup:GetSprite()
		
		if pickup:IsShopItem() and (pickup.Price > collider:GetNumCoins() or not collider:IsExtraAnimationFinished()) then
			return true
		elseif sprite:IsPlaying("Collect") then
			return true
		elseif pickup.Wait > 0 then
			return not sprite:IsPlaying("Idle")
		elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
			if pickup.Price == PickupPrice.PRICE_SPIKES then
				local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			
			if CustomHealthAPI.Library.CanPickKey(collider, "MORBID_HEART") then
				CustomHealthAPI.Library.AddHealth(collider, "MORBID_HEART", 1, true)
				SFXManager():Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1.0)
			else
				return pickup:IsShopItem()
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
				local pickupSprite = pickup:GetSprite()
				local holdSprite = Sprite()
				
				holdSprite:Load(pickupSprite:GetFilename(), true)
				holdSprite:Play(pickupSprite:GetAnimation(), true)
				holdSprite:SetFrame(pickupSprite:GetFrame())
				collider:AnimatePickup(holdSprite)
				
				if pickup.Price > 0 then
					collider:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(collider)
				
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
			else
				sprite:Play("Collect", true)
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Die()
			end
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		else
			return false
		end
	end
end, FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART)

----------------------------
-- Sumptorium
----------------------------

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		local familiars = Isaac.FindInRadius(tear.Position - tear.Velocity, 0.000001, EntityPartition.FAMILIAR)
		for _,familiar in ipairs(familiars) do
			if familiar.Variant == FamiliarVariant.BLOOD_BABY then
				if familiar.SubType == 920 then
					tear:GetData().SpawnedByImmoralClot = true
				elseif familiar.SubType == 921 then
					tear:GetData().SpawnedByMorbidClot = true
				
					local player = familiar:ToFamiliar().Player
					if player then
						tear:GetData().MorbidClotPlayerHasToughLove = player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE)
					end
				end
			end
		end
	elseif tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR then
		local familiar = tear.SpawnerEntity:ToFamiliar()
		if familiar.Variant == FamiliarVariant.BLOOD_BABY then
			if familiar.SubType == 920 then
				tear:GetData().SpawnedByImmoralClot = true
			elseif familiar.SubType == 921 then
				tear:GetData().SpawnedByMorbidClot = true
				
				local player = familiar:ToFamiliar().Player
				if player then
					tear:GetData().MorbidClotPlayerHasToughLove = player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE)
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
	if bomb.SpawnerEntity and bomb.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		local familiars = Isaac.FindInRadius(bomb.Position, 0.000001, EntityPartition.FAMILIAR)
		for _,familiar in ipairs(familiars) do
			if familiar.Variant == FamiliarVariant.BLOOD_BABY then
				if familiar.SubType == 920 then
					bomb:GetData().SpawnedByImmoralClot = true
				elseif familiar.SubType == 921 then
					bomb:GetData().SpawnedByMorbidClot = true
					
					local player = familiar:ToFamiliar().Player
					if player then
						bomb:GetData().MorbidClotPlayerHasToughLove = player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE)
					end
				end
			end
		end
	end
end)

function mod:immoralClotOnFireTear(tear)
	if tear:GetData().SpawnedByImmoralClot and not tear:GetData().isImpSodaTear then
		if FiendFolio.FiendConfig.ClassicTears then
    		tear.Color = Color(1.0, 1.0, 0.5, 1.0, 200 / 255, 0, 0)
		else
			tear.Color = Color(1.1,1.1,1.1,1,50/255,-75/255,50/255)
		end
		if math.random(25) == 1 then
			tear:GetData().isImpSodaTear = true
			if not tear:GetData().critLightning or not tear:GetData().critLightning:Exists() then
				sfx:Play(mod.Sounds.CritShoot, 0.3, 0, false, math.random(80,120)/100)
				local critLightning = Isaac.Spawn(1000, 1737, 1, tear.Position, nilvector, tear):ToEffect()
				critLightning.Parent = tear
				critLightning.Color = Color(1,1,1,0,0,0,1)
				critLightning:Update()
				tear:GetData().critLightning = critLightning
			end
			tear.CollisionDamage = tear.CollisionDamage * 5
			tear.Color = Color(1.3,1.3,1.3,1,100/255,-150/255,100/255)
		end
	end
end

function mod:immoralClotOnFireBomb(bomb)
	if bomb:GetData().SpawnedByImmoralClot and not bomb:GetData().isImpSodaTear and math.random(25) == 1 then
		--sfx:Play(mod.Sounds.CritShoot, 0.3, 0, false, math.random(80,120)/100)
		bomb:GetData().isImpSodaTear = true
		--local critLightning = Isaac.Spawn(1000, 1737, 1, bomb.Position, nilvector, bomb):ToEffect()
		--critLightning.Parent = bomb
		--critLightning.Color = Color(1,1,1,0,0,0,1)
		--critLightning:Update()
		bomb.ExplosionDamage = bomb.ExplosionDamage * 5
		bomb.Color = Color(1.3,1.3,1.3,1,100/255,-150/255,100/255)
		--bomb.SplatColor = Color(1.3,1.3,1.3,1,100 / 255,-150 / 255,100 / 255)
	end
end

function mod:immoralClotOnKnifeDamage(ent, knife, currDamage, hasImpSodaProcced)
	local returndata = {}
	if knife.SpawnerEntity and knife.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and
	   knife.SpawnerEntity.Variant == FamiliarVariant.BLOOD_BABY 
	then
		if knife.SpawnerEntity.SubType == 920 then
			if not hasImpSodaProcced then
				if math.random(25) == 1 then
					returndata.newDamage = currDamage * 5
					returndata.sendNewDamage = true

					sfx:Play(mod.Sounds.ImpSodaCrit,0.8,0,false,math.random(80,120)/100)
					local crit = Isaac.Spawn(1000, 1734, 0, ent.Position + Vector(0,1), nilvector, knife):ToEffect()
					crit.SpriteOffset = Vector(0, -15)
					crit:Update()
					ent:BloodExplode()
					game:ShakeScreen(6)
					returndata.hasImpSodaProcced = true
				end
			end
		end
	end
	return returndata
end

function mod:immoralClotOnFireLaser(laser)
	if laser.SpawnerEntity and laser.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and
	   laser.SpawnerEntity.Variant == FamiliarVariant.BLOOD_BABY 
	then
		if laser.SpawnerEntity.SubType == 920 then
			laser:GetData().ImpSodaLaser = true
			laser:GetData().ImpSodaLaserForceColor = true
		end
	end
end

function mod:immoralClotOnFireBrimball(brimball)
	if brimball.SpawnerEntity and brimball.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		local knives = Isaac.FindByType(EntityType.ENTITY_KNIFE)
		for _,knife in ipairs(knives) do
			if knife.SpawnerEntity and knife.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and
			   knife.SpawnerEntity.Variant == FamiliarVariant.BLOOD_BABY 
			then
				local potentialSpawnerPosition = brimball.Position - brimball.Velocity:Resized(30)
				local spawnerPosition = knife.SpawnerEntity.Position

				if math.abs(spawnerPosition.X - potentialSpawnerPosition.X) <= 0.0001 and 
				   math.abs(spawnerPosition.Y - potentialSpawnerPosition.Y) <= 0.0001 
				then
					if knife.SpawnerEntity.SubType == 920 then
						brimball:GetData().ImpSodaLaser = true
						brimball:GetData().ImpSodaLaserForceColor = true
					end
				end
			end
		end
	end
end

function mod:immoralClotOnFireRocket(target)
	if target.SpawnerEntity and target.SpawnerType == EntityType.ENTITY_FAMILIAR and target.SpawnerVariant == FamiliarVariant.BLOOD_BABY then
		local spawner = target.SpawnerEntity
		if spawner.SubType == 920 and not target:GetData().isImpSodaTear and math.random(25) == 1 then
			--sfx:Play(mod.Sounds.CritShoot, 0.3, 0, false, math.random(80,120)/100)
			target:GetData().isImpSodaTear = true
			--local critLightning = Isaac.Spawn(1000, 1737, 1, target.Position, nilvector, target):ToEffect()
			--critLightning.Parent = target
			--critLightning.Color = Color(1,1,1,0,0,0,1)
			--critLightning:Update()
			--target.ExplosionDamage = target.ExplosionDamage * 5
			target:GetData().FFExplosionColor = Color(1.3,1.3,1.3,1,100/255,-150/255,100/255)
			--bomb.SplatColor = Color(1.3,1.3,1.3,1,100 / 255,-150 / 255,100 / 255)
		end
	end
end

function mod:morbidClotOnFireTear(tear)
	if tear:GetData().SpawnedByMorbidClot then
		mod:changeTearVariant(tear, TearVariant.BLOOD)
		
		if not tear:GetData().MorbidClotPlayerHasToughLove and math.random(10) == 1 then
			mod:changeTearVariant(tear, TearVariant.TOOTH)
			tear.CollisionDamage = tear.CollisionDamage * 3.2
		end
	end
end

function mod:morbidClotOnFireBomb(bomb)
	if bomb:GetData().SpawnedByMorbidClot then
		if not bomb:GetData().MorbidClotPlayerHasToughLove and math.random(10) == 1 then
			bomb.ExplosionDamage = bomb.ExplosionDamage * 3.2
		end
	end
end

function mod:morbidClotOnKnifeDamage(ent, knife, currDamage)
	local returndata = {}
	if knife.SpawnerEntity and knife.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and
	   knife.SpawnerEntity.Variant == FamiliarVariant.BLOOD_BABY 
	then
		if knife.SpawnerEntity.SubType == 921 then
			local player = knife.SpawnerEntity:ToFamiliar().Player
			
			if player and not player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) and math.random(10) == 1 then
				returndata.newDamage = currDamage * 3.2
				returndata.sendNewDamage = true
			end
		end
	end
	return returndata
end

function mod:morbidClotOnFireRocket(target)
	if target.SpawnerEntity and target.SpawnerType == EntityType.ENTITY_FAMILIAR and target.SpawnerVariant == FamiliarVariant.BLOOD_BABY then
		local spawner = target.SpawnerEntity
		if spawner.SubType == 921 then
			local player = spawner:ToFamiliar().Player
			if player and not player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) and math.random(10) == 1 then
				target:GetData().isMorbidClotToothTear = true
			end
		end
	end
end

----------------------------
-- Immoral Hearts
----------------------------

function mod.GetImmoralHeartsNum(player)
	return CustomHealthAPI.Library.GetHPOfKey(player, "IMMORAL_HEART")
end

function mod:AddImmoralHearts(player, hp)
	CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", hp)
end

function mod:CanPickImmoralHearts(player)
	return CustomHealthAPI.Library.CanPickKey(collider, "IMMORAL_HEART")
end

function mod:somePlayerHasImmoral()
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(0)
		if CustomHealthAPI.Library.GetHPOfKey(player, "IMMORAL_HEART") > 0 then
			return true
		end
	end

	return false
end

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
	if mod.IsActiveRoom() and flags & DamageFlag.DAMAGE_FAKE == 0 and flags & DamageFlag.DAMAGE_DEVIL == 0 then
		if key == "IMMORAL_HEART" and wasLastDamaged then
			local hearts = CustomHealthAPI.Library.GetHealthInOrder(player, true)
			local maskIndexOfImmoral = CustomHealthAPI.Library.GetInfoOfKey("IMMORAL_HEART", "MaskIndex")
			
			local numMinions = 0
			for i = #hearts, 1, -1 do
				local health = hearts[i]
				local key = health.Other.Key
				local maskIndexOfHealth = CustomHealthAPI.Library.GetInfoOfKey(key, "MaskIndex")
				
				if maskIndexOfHealth == maskIndexOfImmoral then
					if key == "IMMORAL_HEART" then
						numMinions = numMinions + health.Other.HP
						CustomHealthAPI.Library.RemoveOtherKey(player, i, true)
					else
						break
					end
				end
			end
			
			if CustomHealthAPI.Helper.GetTotalHP(player) <= 0 and numMinions > 0 then
				CustomHealthAPI.Helper.UpdateHealthMasks(player, "IMMORAL_HEART", 1, true, false, true)
				numMinions = numMinions - 1
			end
			
			while numMinions > 0 do
				local egg
				
				if numMinions >= 2 then
					egg = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 2, player.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player):ToPickup()
				else
					egg = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 3, player.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player):ToPickup()
					egg:GetData().hollowimmoral = true
				end

				egg:GetSprite():Play("Drop", true)
				if math.random(2) == 1 then
					egg:GetSprite().FlipX = true
				end

				egg.Parent = player
				egg:Update()

				numMinions = numMinions - 2
			end
		elseif player:GetPlayerType() == FiendFolio.PLAYER.FIEND and key == "BLACK_HEART" and wasLastDamaged then
			local hearts = CustomHealthAPI.Library.GetHealthInOrder(player, true)
			local maskIndexOfBlack = CustomHealthAPI.Library.GetInfoOfKey("BLACK_HEART", "MaskIndex")
			
			local numMinions = 0
			for i = #hearts, 1, -1 do
				local health = hearts[i]
				local key = health.Other.Key
				local maskIndexOfHealth = CustomHealthAPI.Library.GetInfoOfKey(key, "MaskIndex")
				
				if maskIndexOfHealth == maskIndexOfBlack then
					if key == "BLACK_HEART" then
						numMinions = numMinions + health.Other.HP
						CustomHealthAPI.Library.RemoveOtherKey(player, i, true)
					else
						break
					end
				end
			end
			
			if CustomHealthAPI.Helper.GetTotalHP(player) <= 0 and numMinions > 0 then
				CustomHealthAPI.Helper.UpdateHealthMasks(player, "BLACK_HEART", 1, true, false, true)
				numMinions = numMinions - 1
			end
			
			while numMinions > 0 do
				local egg

				if numMinions >= 2 then
					egg = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 1, player.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player):ToPickup()
				else
					egg = Isaac.Spawn(1000, FiendFolio.PICKUP.VARIANT.FIEND_MINION_EFFECT, 1, player.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player):ToEffect()
					egg:GetData().hollow = true
					egg:GetData().canreroll = false
				end

				if player:GetPlayerType() == FiendFolio.PLAYER.FIEND then
					egg:GetData().fiendBonus = true
				end

				egg:GetSprite():Play("Drop", true)
				if math.random(2) == 1 then
					egg:GetSprite().FlipX = true
				end

				egg.Parent = player
				egg:Update()

				numMinions = numMinions - 2
			end
		end
	end
end)

----------------------------
-- Morbid Hearts
----------------------------

function mod.GetMorbidHeartsNum(player)
	return CustomHealthAPI.Library.GetHPOfKey(player, "MORBID_HEART")
end

function mod:AddMorbidHearts(player, hp)
	CustomHealthAPI.Library.AddHealth(player, "MORBID_HEART", hp)
end

function mod:CanPickMorbidHearts(player)
	return CustomHealthAPI.Library.CanPickKey(collider, "MORBID_HEART")
end

function mod:somePlayerHasPostiche()
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(0)
		if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DADS_POSTICHE) then
			return true
		end
	end

	return false
end

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
	if key == "MORBID_HEART" then
		player:GetData().TookMorbidHeartDamage = true
		
		if wasDepleted then
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
			player:BloodExplode()
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, player.Position, nilvector, player)
			
			local basedata = player:GetData()
			local data = basedata.ffsavedata
			
			if data then
				data.MorbidChunks = math.min(3, (data.MorbidChunks or 0) + 1)
				player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
				player:EvaluateItems()
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local sprite = familiar:GetSprite()
	local data = familiar:GetData()
	
	if not data.init then
		local rng = RNG()
		rng:SetSeed(familiar.InitSeed, 0)
		
		data.anim = "Float" .. (rng:RandomInt(4) + 1)
		data.init = true
		
		familiar:AddToOrbit(5)
		familiar.Position = familiar:GetOrbitPosition(familiar.Player.Position - familiar.Player.Velocity)
	end
	
	if not sprite:IsPlaying(data.anim) then
		sprite:Play(data.anim, true)
	end
	
	familiar.Velocity = familiar:GetOrbitPosition(familiar.Player.Position - familiar.Player.Velocity) - familiar.Position
end, FiendFolio.ITEM.FAMILIAR.MORBID_CHUNK)

function mod:AddMorbidChunkCallbacks()
	mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, source, countdown)
		if flags & DamageFlag.DAMAGE_CLONES == 0 and
		   source.Entity and 
		   source.Entity.Type == EntityType.ENTITY_FAMILIAR and 
		   source.Entity.Variant == FiendFolio.ITEM.FAMILIAR.MORBID_CHUNK 
		then
			local familiar = source.Entity:ToFamiliar()
			
			familiar.SubType = familiar.SubType + 1
			if familiar.SubType >= 30 then
				familiar:BloodExplode()
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, familiar.Position, nilvector, familiar)
				
				if familiar.Player then
					local basedata = familiar.Player:GetData()
					local data = basedata.ffsavedata
					
					if data then
						data.MorbidChunks = math.max(0, (data.MorbidChunks or 0) - 1)
					end
				end
				
				familiar:Remove()
			end
		end
	end)
end

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
    if collider.Type == EntityType.ENTITY_PROJECTILE then
        collider:Die()
		
		familiar.SubType = familiar.SubType + 10
		if familiar.SubType >= 30 then
			familiar:BloodExplode()
			Isaac.Spawn(1000, 2, 1, familiar.Position, nilvector, familiar)
			
			if familiar.Player then
				local basedata = familiar.Player:GetData()
				local data = basedata.ffsavedata
				
				if data then
					data.MorbidChunks = math.max(0, (data.MorbidChunks or 0) - 1)
				end
			end
			
			familiar:Remove()
		end
    end
end, FiendFolio.ITEM.FAMILIAR.MORBID_CHUNK)
