local mod = FiendFolio
local game = Game()

local HORSE_PUSHPOP_CHANCE = 0.15

local chinasHorns = Isaac.GetCostumeIdByPath("gfx/characters/china_horns.anm2")
local chinaHead = Isaac.GetCostumeIdByPath("gfx/characters/china_head.anm2")
local chinaRedamaging

if StageAPI and StageAPI.Loaded then
    StageAPI.AddPlayerGraphicsInfo(FiendFolio.PLAYER.CHINA, {
        Name = "gfx/ui/boss/playername_china.png",
        Portrait = "gfx/ui/stage/playerportrait_china.png",
        NoShake = false
    })
end

local function gameHasChina()
	for _, player in pairs(Isaac.FindByType(1)) do
		if player:ToPlayer():GetPlayerType() == mod.PLAYER.CHINA then
			return true
		end
	end
end

local function getNumChinas()
	local amount = 0

	for _, player in pairs(Isaac.FindByType(1)) do
		if player:ToPlayer():GetPlayerType() == mod.PLAYER.CHINA then
			amount = amount + 1
		end
	end

	return amount
end

local function getFreePositionNearRandomDoor(rng)
	local validDoors = {}
	local room = game:GetRoom()

	for i = 0, 7 do
		local door = room:GetDoor(i)
		if door then table.insert(validDoors, door) end
	end

	local door = validDoors[rng:RandomInt(#validDoors) + 1]
	return room:FindFreePickupSpawnPosition(door.Position, 40, true, false)
end

local function playerHasUnchargedAlabasterBox(player)
	for slot = 0, 2 do
		if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX and player:GetActiveCharge(slot) ~= 12 then
			return true
		end
	end
end

local function playerHasUnchargedSpiritShackles(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES) and player:GetEffects():HasNullEffect(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
end

local function canPickupChargeAlabasterBox(player, pickup)
	if playerHasUnchargedAlabasterBox(player) then
		return pickup.Variant == PickupVariant.PICKUP_HEART and (
			pickup.SubType == HeartSubType.HEART_SOUL or
			pickup.SubType == HeartSubType.HEART_HALF_SOUL or
			pickup.SubType == HeartSubType.HEART_BLENDED or
			pickup.SubType == HeartSubType.HEART_BLACK
		) or
		pickup.Variant == mod.PICKUP.VARIANT.HALF_BLACK_HEART or
		pickup.Variant == mod.PICKUP.VARIANT.BLENDED_BLACK_HEART or
		pickup.Variant == mod.PICKUP.VARIANT.IMMORAL_HEART or
		pickup.Variant == mod.PICKUP.VARIANT.HALF_IMMORAL_HEART or
		pickup.Variant == mod.PICKUP.VARIANT.BLENDED_IMMORAL_HEART
	end

	return false
end

local function canChinaPickSoulHeart(player)
	return (
		playerHasUnchargedAlabasterBox(player) or
		playerHasUnchargedSpiritShackles(player)
	)
end

local function canChinaFallIntoPits(player)
	local data = player:GetData()
	local sprite = player:GetSprite()

	return (
		not player.CanFly and
		not player:IsDead() and
		not player:IsCoopGhost() and
		not (data.myVeryOwnGrapplingHook and data.myVeryOwnGrapplingHook:Exists() and data.myVeryOwnGrapplingHook:GetData().state == "reelin") and
		sprite:GetAnimation() ~= "Jump"
	)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		player:AddNullCostume(chinaHead)
		player:AddNullCostume(chinasHorns)
	end
end, 0)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:CollidesWithGrid() and game:GetRoom():GetFrameCount() >= 30 then
		player:TakeDamage(1, 0, EntityRef(player), 30)
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not player:HasCollectible(mod.ITEM.COLLECTIBLE.HORSE_PASTE) then
		player:SetPocketActiveItem(mod.ITEM.COLLECTIBLE.HORSE_PASTE, ActiveSlot.SLOT_POCKET, false)
	end

	if room:IsClear() and (player:GetNumKeys() > 0 or player:HasGoldenKey()) then
		for i = 0, 7 do
			local door = room:GetDoor(i)
			if door and door:IsLocked() and door.Position:Distance(player.Position) < 60 then
				door:TryUnlock(player, false)
			end
		end
	end

	player:GetData().chinaWasJustDamaged = false
end, mod.PLAYER.CHINA)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		local data = player:GetData()
		local sprite = player:GetSprite()
		local room = game:GetRoom()
		local grid = room:GetGridEntityFromPos(player.Position)

		if canChinaFallIntoPits(player) then
			player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

			if grid and grid:GetType() == GridEntityType.GRID_PIT and grid.CollisionClass == GridCollisionClass.COLLISION_PIT then
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				if sprite:GetAnimation() ~= "FallIn" and room:GetFrameCount() >= 2 then
					player:ResetItemState()
					player:AnimatePitfallIn()
					data.isInPitDamageCooldown = true
				end
			else
				local closestGrid = mod.GetClosestGridEntity(player.Position)
				if closestGrid and closestGrid:GetType() == GridEntityType.GRID_PIT then
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				end
			end
		end

		if data.isInPitDamageCooldown then
			player.Velocity = player.Velocity * 0.9

			if player:IsExtraAnimationFinished() then
				data.isInPitDamageCooldown = false
				player:ResetDamageCooldown()
				player:SetMinDamageCooldown(30)
				player.Position = getFreePositionNearRandomDoor(player:GetDropRNG())
			end
		end
		
		if player:GetBrokenHearts() < 12 then
			player:AddRottenHearts(-player:GetRottenHearts())
			player:AddMaxHearts(-player:GetMaxHearts())
			player:AddSoulHearts(-player:GetSoulHearts())
			player:AddGoldenHearts(-player:GetGoldenHearts())
			player:AddEternalHearts(-player:GetEternalHearts())

			player:AddBoneHearts(1 - player:GetBoneHearts())
			player:AddHearts(2 - player:GetHearts())
		else
			if not mod.ACHIEVEMENT.SHARD_OF_CHINA:IsUnlocked(true) then
	            mod.ACHIEVEMENT.SHARD_OF_CHINA:Unlock()
	        end
		end
	end
end)

--[[mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	if player and player:GetPlayerType() == mod.PLAYER.CHINA and not canPickupChargeAlabasterBox(player, pickup) then
		return false
	end
end, 10)]]

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	local player = entity:ToPlayer()
	local data = player:GetData()

	if player:GetPlayerType() == mod.PLAYER.CHINA and flags & DamageFlag.DAMAGE_FAKE == 0 then
		if data.chinaWasJustDamaged then
			player:AddHearts(99)
		else
			data.chinaWasJustDamaged = true
			mod.scheduleForUpdate(function()
				player:AddBrokenHearts(1)
			end, 1)
		end
	end
end, 1)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		player.TearColor = mod.ColorChinaYellow
	end
end, CacheFlag.CACHE_TEARCOLOR)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		player.MaxFireDelay = player.MaxFireDelay * 0.75
	end
end, CacheFlag.CACHE_FIREDELAY)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		player.SizeMulti = player.SizeMulti * 0.8
	end
end, CacheFlag.CACHE_SIZE)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, position)
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_DEFAULT and gameHasChina() then
		if rng:RandomFloat() < HORSE_PUSHPOP_CHANCE * getNumChinas() then
			Isaac.Spawn(5, 300, mod.ITEM.CARD.HORSE_PUSHPOP, room:FindFreePickupSpawnPosition(position), Vector.Zero, nil)
			return true
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_DEVIL and gameHasChina() then
		local index = Random()
		for _, pickup in pairs(Isaac.FindByType(5, 100)) do
			local pickup = pickup:ToPickup()
			if pickup.Price < 0 and pickup.OptionsPickupIndex == 0 then
				pickup.OptionsPickupIndex = index
			end
		end
	end
end)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HEART, 0, function(player, index, health, redHealth)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		if redHealth ~= nil or health.Key ~= "BROKEN_HEART" then
			return {Prevent = true}
		else
			if player:GetBrokenHearts() < 12 then
				return {Index = index - 1}
			end
		end
	end
end)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HOLY_MANTLE, 0, function(player, index)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		if player:GetBrokenHearts() < 11 then
			return {Index = index - 1, Offset = Vector(0, 0)}
		elseif player:GetBrokenHearts() == 11 then
			return {Index = 11, Offset = Vector(0, 0)}
		end
	end
end)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH, 0, function(player, key)
	if player:GetPlayerType() == mod.PLAYER.CHINA then
		if (key == "SOUL_HEART" or key == "BLACK_HEART" or key == "IMMORAL_HEART") and canChinaPickSoulHeart(player) then
			return true
		else
			return false
		end
	end
end)