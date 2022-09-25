local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local chinaShard = mod.ITEM.TRINKET.SHARD_OF_CHINA
local chinaHeart = mod.ITEM.COLLECTIBLE.HEART_OF_CHINA
local golemShard = mod.ITEM.ROCK.SHARD_OF_GOLEM

local chinaSprite = Sprite()
chinaSprite:Load("gfx/ui/shardofchina.anm2", true)

local function GetChinaHeartMeterLength(player)
	if player:HasCollectible(chinaHeart) then
		return math.max(6, player:GetEffectiveMaxHearts())
	elseif player:HasTrinket(golemShard) then
		return 8
	elseif player:HasTrinket(chinaShard) then
		return 6
	end
end

local function GetPlayerHudSkin(player)
	local playerType = player:GetPlayerType()
	if playerType == PlayerType.PLAYER_THEFORGOTTEN then
		return "Bone"
	elseif playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then
		return "Lost"
	else
		return "Red"
	end
end

local function CanPlayerShowChinaHud(player)
	return player:HasCollectible(chinaHeart) or mod.IsPlayerHoldingTrinket(player, chinaShard) or mod.IsPlayerHoldingTrinket(player, golemShard)
end

local function PickupIsRedHeart(pickup)
	return (
		pickup.SubType == HeartSubType.HEART_FULL or
		pickup.SubType == HeartSubType.HEART_HALF or
		pickup.SubType == HeartSubType.HEART_DOUBLEPACK or
		pickup.SubType == HeartSubType.HEART_SCARED
	)
end

local RedHeartValue = {
	[HeartSubType.HEART_FULL] = 2,
	[HeartSubType.HEART_HALF] = 1,
	[HeartSubType.HEART_DOUBLEPACK] = 4,
	[HeartSubType.HEART_SCARED] = 2,
}

local function GetRedHeartValue(pickup, player, blended)
	local multiplier = player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) and 2 or 1
	return (blended and 2 or (RedHeartValue[pickup.SubType] or 0)) * multiplier
end

local function GetHeartOverheal(pickup, player, blended)
	local healValue = GetRedHeartValue(pickup, player, blended)
	local leftToHeal = player:GetEffectiveMaxHearts() - player:GetHearts()

	return healValue - leftToHeal
end

local function ShouldPlayerShowChinaHud(player)
	local heartInRange
	local data = player:GetData()

	for _, pickup in pairs(Isaac.FindByType(5, 10)) do
		if pickup:ToPickup().Price <= player:GetNumCoins() then
			if pickup.Position:Distance(player.Position) < 80 then
				if PickupIsRedHeart(pickup) and GetHeartOverheal(pickup, player) > 0 then
					heartInRange = true
					break
				elseif pickup.SubType == HeartSubType.HEART_BLENDED and not player:CanPickSoulHearts() and GetHeartOverheal(pickup, player, true) > 0 then
					heartInRange = true
					break
				end
			end
		end
	end

	return CanPlayerShowChinaHud(player) and (
		Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) or
		data.lastUsedYumHeart + 60 >= player.FrameCount or
		heartInRange
	)
end

function mod.GetActiveShardOfChinaDamage(player)
	local damage = 0

	if mod.IsPlayerHoldingTrinket(player, golemShard) then
		local data = mod.GetPersistentPlayerData(player)
		local heartCap = math.floor(GetChinaHeartMeterLength(player) / 2)
		local fillLevel = math.floor((data.shardOfChinaHearts or 0) / 2)

		damage = damage + 1.8 * (fillLevel / heartCap)
	end

	if mod.IsPlayerHoldingTrinket(player, chinaShard) then
		local data = mod.GetPersistentPlayerData(player)
		local heartCap = math.floor(GetChinaHeartMeterLength(player) / 2)
		local fillLevel = math.floor((data.shardOfChinaHearts or 0) / 2)

		damage = damage + 1.5 * (fillLevel / heartCap)
	end

	return damage * (mod.GetHeldTrinketMultiplier(player, chinaShard) + mod.GetHeldTrinketMultiplier(player, golemShard))
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:HasTrinket(chinaShard) or player:HasCollectible(chinaHeart) or player:HasTrinket(golemShard) then
		local persistentData = mod.GetPersistentPlayerData(player)
		local data = player:GetData()

		persistentData.shardOfChinaDamage = persistentData.shardOfChinaDamage or 0
		persistentData.heartShardOfChinaDamage = persistentData.heartShardOfChinaDamage or 0
		persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts or 0
		data.lastUsedYumHeart = data.lastUsedYumHeart or -999

		if data.showShardOfChina then
			data.shardOfChinaFrame = data.shardOfChinaFrame + 1
		end

		data.didWantToShowShardOfChina = data.wantsToShowShardOfChina
		data.wantsToShowShardOfChina = ShouldPlayerShowChinaHud(player)
		data.lastShowedShardOfChina = data.wantsToShowShardOfChina and player.FrameCount or data.lastShowedShardOfChina or -15
		data.showShardOfChina = data.lastShowedShardOfChina + 5 >= player.FrameCount

		data.shardOfChinaFrame = data.shardOfChinaFrame or 0
		if (data.didWantToShowShardOfChina and not data.wantsToShowShardOfChina) or not data.showShardOfChina then
			data.shardOfChinaFrame = 0
		end

		local heartCap = GetChinaHeartMeterLength(player)

		if persistentData.shardOfChinaHearts >= heartCap then
			persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts - heartCap

			if player:HasCollectible(chinaHeart) then
				if mod.PlayerHasSmeltedTrinket(player, golemShard) then
					persistentData.heartShardOfChinaDamage = persistentData.heartShardOfChinaDamage + 0.18
				elseif mod.PlayerHasSmeltedTrinket(player, chinaShard) then
					persistentData.heartShardOfChinaDamage = persistentData.heartShardOfChinaDamage + 0.15
				end

				player:AnimateCollectible(chinaHeart, "UseItem")
				player:AddMaxHearts(2)
			end

			local trinketSlot = mod.IsPlayerHoldingTrinket(player, chinaShard)
			if trinketSlot then
				mod.SmeltHeldTrinket(player, trinketSlot)
				player:AnimateTrinket(chinaShard, "UseItem")
			end

			if mod.IsPlayerHoldingTrinket(player, golemShard) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER)
				player:AnimateTrinket(golemShard, "UseItem")
			end

			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
			sfx:Play(SoundEffect.SOUND_THUMBSUP)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
	if CanPlayerShowChinaHud(player) then
		local data = player:GetData()
		if data.showShardOfChina then
			local anim = GetPlayerHudSkin(player)
			if not data.wantsToShowShardOfChina then
				anim = anim .. "Out"
			end

			local persistentData = mod.GetPersistentPlayerData(player)
			local playerPosition = Isaac.WorldToScreen(player.Position)
			local cap = GetChinaHeartMeterLength(player) / 2
			local fill = persistentData.shardOfChinaHearts

			for i = 1, cap do
				chinaSprite:SetFrame(anim .. math.min(fill, 2), data.shardOfChinaFrame)
				chinaSprite:Render(playerPosition + Vector((i - cap / 2) * 8 - 3.5, -40), Vector.Zero, Vector.Zero)
				fill = math.max(0, fill - 2)
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	if player and CanPlayerShowChinaHud(player) and pickup.Price <= player:GetNumCoins() then
		local collect
		local recalculate
		local overheal = GetHeartOverheal(pickup, player)
		local heartDelta = player:GetEffectiveMaxHearts() - player:GetHearts()

		if PickupIsRedHeart(pickup) and overheal > 0 then
			local persistentData = mod.GetPersistentPlayerData(player)
			persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overheal

			collect = heartDelta == 0
			recalculate = true
		elseif pickup.SubType == HeartSubType.HEART_BLENDED and not player:CanPickSoulHearts() then
			local persistentData = mod.GetPersistentPlayerData(player)
			local multiplier = player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) and 2 or 1
			local overheal = 2 * multiplier - heartDelta

			persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + math.max(0, overheal)
			collect = heartDelta == 0 and overheal > 0
			recalculate = overheal > 0
		end

		if recalculate and (mod.IsPlayerHoldingTrinket(player, chinaShard) or mod.IsPlayerHoldingTrinket(player, golemShard)) then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end

		if collect then
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
			pickup.EntityCollisionClass = 0
			pickup:GetSprite():Play("Collect")
			pickup:Die()
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			
			return true
		end
	end
end, 10)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, item, rng, player)
	if CanPlayerShowChinaHud(player) then
		local amount = player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B and 4 or 2
		local heartDelta = player:GetEffectiveMaxHearts() - player:GetHearts()
		local overheal = amount - heartDelta

		if overheal > 0 then
			local persistentData = mod.GetPersistentPlayerData(player)
			persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overheal
			
			player:GetData().lastUsedYumHeart = player.FrameCount

			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
end, CollectibleType.COLLECTIBLE_YUM_HEART)