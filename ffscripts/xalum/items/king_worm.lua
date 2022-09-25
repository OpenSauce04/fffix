local mod = FiendFolio
local kingWorm = mod.ITEM.COLLECTIBLE.KING_WORM

local kingWormCacheFlags = CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FIREDELAY

local kingWormData = {
	{TrinketType.TRINKET_PULSE_WORM,	"pulseWormNum"},
	{TrinketType.TRINKET_WIGGLE_WORM,	"wiggleWormNum"},
	{TrinketType.TRINKET_RING_WORM,		"ringWormNum"},
	{TrinketType.TRINKET_FLAT_WORM,		"flatWormNum"},
	{TrinketType.TRINKET_HOOK_WORM,		"hookWormNum"},
	{TrinketType.TRINKET_WHIP_WORM,		"whipWormNum"},
	{TrinketType.TRINKET_TAPE_WORM,		"tapeWormNum"},
	{TrinketType.TRINKET_LAZY_WORM,		"lazyWormNum"},
	{TrinketType.TRINKET_OUROBOROS_WORM,"ouroborosWormNum"},
	{TrinketType.TRINKET_BRAIN_WORM,	"brainWormNum"},

	-- FF Worms
	-- {TrinketType.TRINKET_FORTUNE_WORM,	"fortuneWormNum"}, -- Excluded
	{TrinketType.TRINKET_TRINITY_WORM,	"trinityWormNum"},
}

-- player.MaxFireDelay = tearsUp(player.MaxFireDelay, (0.4 * mod.GetTrinityWormMultiplier(player)))

local function TearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

function mod.HasTrinityWorm(player)
	local data = player:GetData()
	local persistentData = mod.GetPersistentPlayerData(player)
	local kingData = data.kingWorm
	local rockData = persistentData.rockWorm

	return player:HasTrinket(TrinketType.TRINKET_TRINITY_WORM) or (kingData and kingData.trinityWormNum > 0) or (rockData and player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_WORM) and rockData.trinityWormNum > 0)
end

function mod.GetTrinityWormMultiplier(player)
	local data = player:GetData()
	local persistentData = mod.GetPersistentPlayerData(player)
	local kingData = data.kingWorm
	local rockData = persistentData.rockWorm

	local num = player:GetTrinketMultiplier(TrinketType.TRINKET_TRINITY_WORM)

	if kingData then num = num + kingData.trinityWormNum end
	if rockData and player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_WORM) then num = num + rockData.trinityWormNum end
	return num
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
	local wormData = kingWormData[rng:RandomInt(#kingWormData) + 1]
	local data = player:GetData().kingWorm

	data[wormData[2]] = data[wormData[2]] + 1

	player:AnimateTrinket(wormData[1], "UseItem")
	player:AddCacheFlags(kingWormCacheFlags)
	player:EvaluateItems()

	return {Discharge = true, ShowAnim = false}
end, kingWorm)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = player:GetData().kingWorm
	if data then
		if data.pulseWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_PULSE
		end

		if data.wiggleWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPECTRAL
		end

		if data.ringWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SPIRAL | TearFlags.TEAR_SPECTRAL
		end

		if data.flatWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_FLAT
		end

		if data.hookWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SQUARE | TearFlags.TEAR_SPECTRAL
		end

		if data.ouroborosWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_BIG_SPIRAL | TearFlags.TEAR_SPECTRAL
		end

		if data.brainWormNum > 0 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_TURN_HORIZONTAL
		end
	end
end, CacheFlag.CACHE_TEARFLAG)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = player:GetData().kingWorm
	if data then
		local tearsBonus = 0.4 * (data.wiggleWormNum + data.ringWormNum + data.hookWormNum + data.ouroborosWormNum)

		if tearsBonus > 0 then
			player.MaxFireDelay = TearsUp(player.MaxFireDelay, tearsBonus)
		end
	end
end, CacheFlag.CACHE_FIREDELAY)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = player:GetData().kingWorm
	if data then
		player.ShotSpeed = player.ShotSpeed + 0.5 * data.whipWormNum
		player.ShotSpeed = player.ShotSpeed - 0.5 * data.lazyWormNum
	end
end, CacheFlag.CACHE_SHOTSPEED)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = player:GetData().kingWorm
	if data then
		player.TearRange = player.TearRange + 60 * data.hookWormNum
		player.TearRange = player.TearRange + 120 * data.tapeWormNum
		player.TearRange = player.TearRange + 60 * data.ouroborosWormNum
	end
end, CacheFlag.CACHE_RANGE)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	mod.AnyPlayerDo(function(player)
		local data = player:GetData()
		data.kingWorm = {}

		for _, key in pairs(kingWormData) do
			data.kingWorm[key[2]] = 0
		end

		player:AddCacheFlags(kingWormCacheFlags)
		player:EvaluateItems()
	end)
end)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = tear.Parent:ToPlayer()
	if player and not tear:HasTearFlags(TearFlags.TEAR_HOMING) then
		local data = player:GetData().kingWorm
		if data then
			local luck = player.Luck + 3 * player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM)
			local rng = RNG()
			rng:SetSeed(tear.InitSeed + kingWorm, 42)

			for i = 1, data.ouroborosWormNum do
				if rng:RandomFloat() < 1 / (10 - luck) then
					tear:AddTearFlags(TearFlags.TEAR_HOMING)
					return
				end
			end
		end
	end
end)