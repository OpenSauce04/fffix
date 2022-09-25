local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local cursedUrn = mod.ITEM.TRINKET.CURSED_URN
local urnShards	= mod.ITEM.TRINKET.SHATTERED_CURSED_URN

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:HasTrinket(cursedUrn) or player:HasTrinket(urnShards) then
		player.TearColor = mod.ColorChinaYellow
	end
end, CacheFlag.CACHE_TEARCOLOR)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	player.MaxFireDelay = player.MaxFireDelay * (0.75 ^ player:GetTrinketMultiplier(cursedUrn))
	player.MaxFireDelay = player.MaxFireDelay * (0.90 ^ player:GetTrinketMultiplier(urnShards))
end, CacheFlag.CACHE_FIREDELAY)

local function ShouldCursedUrnBreak(pickup)
	return (
		(pickup.SpawnerType == 1 and pickup:GetSprite():IsEventTriggered("DropSound")) or
		(mod.IsEntityInRangeOfExplosion(pickup))
	)
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if mod.PickupIsTrinket(pickup, cursedUrn) and ShouldCursedUrnBreak(pickup) then
		local sprite = pickup:GetSprite()
		local frameCache = sprite:GetFrame()
		local animCache = sprite:GetAnimation()

		if pickup.SubType & TrinketType.TRINKET_GOLDEN_FLAG > 0 then
			sfx:Play(SoundEffect.SOUND_GOLD_HEART_DROP)
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
			pickup:Morph(5, 350, cursedUrn)

			for i = 30, 360, 30 do
				local offset = Vector(0, 3):Rotated(i)
				local sparkle = Isaac.Spawn(1000, 1727, 0, pickup.Position + offset:Resized(20), offset, pickup)
				sparkle.SpriteOffset = Vector(1, -8)
			end
		else
			sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.8, 0, false, 1)
			pickup:Morph(5, 350, urnShards)

			local dust = Isaac.Spawn(1000, 59, 0, pickup.Position, Vector.Zero, pickup):ToEffect()
			dust:SetTimeout(60)
		end

		sprite:Play(animCache)
		sprite:SetFrame(frameCache)
	end
end, 350)

-- Priority:
--[[
	Held Golden Cursed Urn
	Held Cursed Urn
	Held Shattered Cursed Urn 	 -- Only if player has Mom's Box
	Smelted Golden Cursed Urn
	Smelted Cursed Urn
	Smelted Shattered Cursed Urn -- Only if player has Mom's Box
]]

function mod.CanPlayerReviveWithCursedUrn(player)
	return player:HasTrinket(cursedUrn) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and player:HasTrinket(urnShards))
end

function mod.DowngradeCursedUrn(player)
	mod.DowngradeTrinket(player, cursedUrn, urnShards, true)
end

function mod.DoCursedUrnRevive(player)
	local alreadyChina = player:GetPlayerType() == mod.PLAYER.CHINA

	mod.DowngradeCursedUrn(player)

	if alreadyChina then
		player:AddBrokenHearts(-12)
	else
		player:ChangePlayerType(mod.PLAYER.CHINA)
		player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/china_head.anm2"))
		player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/china_horns.anm2"))

		player:AddCacheFlags(CacheFlag.CACHE_TEARCOLOR | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SIZE)
	end

	player:AddMaxHearts(player:GetMaxHearts())
	player:AddBoneHearts(1-player:GetBoneHearts())
	player:AddSoulHearts(-player:GetSoulHearts())
	player:AddRottenHearts(-player:GetRottenHearts())
	player:AddHearts(-99) -- clearing out custom hp
	player:AddHearts(2)

	player:AddBrokenHearts(-6)

	mod:explodePlayer(player, true)

	mod.scheduleForUpdate(function()
		player:AddBrokenHearts(-1) -- Absorb the current hit without cancelling the damage
	end, 1)
end