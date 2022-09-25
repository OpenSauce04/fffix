local mod = FiendFolio
local rockWorm = FiendFolio.ITEM.ROCK.ROCK_WORM

local rockWormCacheFlags = CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FIREDELAY
local rockWormData = {
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
	{TrinketType.TRINKET_TRINITY_WORM,	"trinityWormNum"},
}

local function TearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = mod.GetPersistentPlayerData(player).rockWorm
	if data and player:HasTrinket(rockWorm) then
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
	local data = mod.GetPersistentPlayerData(player).rockWorm
	if data and player:HasTrinket(rockWorm) then
		local tearsBonus = 0.4 * (data.wiggleWormNum + data.ringWormNum + data.hookWormNum + data.ouroborosWormNum + mod.GetGolemTrinketPower(player, rockWorm))

		if tearsBonus > 0 then
			player.MaxFireDelay = TearsUp(player.MaxFireDelay, tearsBonus)
		end
	end
end, CacheFlag.CACHE_FIREDELAY)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = mod.GetPersistentPlayerData(player).rockWorm
	if data and player:HasTrinket(rockWorm) then
		player.ShotSpeed = player.ShotSpeed + 0.5 * data.whipWormNum
		player.ShotSpeed = player.ShotSpeed - 0.5 * data.lazyWormNum
	end
end, CacheFlag.CACHE_SHOTSPEED)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	local data = mod.GetPersistentPlayerData(player).rockWorm
	if data and player:HasTrinket(rockWorm) then
		player.TearRange = player.TearRange + 60 * data.hookWormNum
		player.TearRange = player.TearRange + 120 * data.tapeWormNum
		player.TearRange = player.TearRange + 60 * data.ouroborosWormNum
	end
end, CacheFlag.CACHE_RANGE)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	mod.AnyPlayerDo(function(player)
		local data = mod.GetPersistentPlayerData(player)
		data.rockWorm = {}

		for _, key in pairs(rockWormData) do
			data.rockWorm[key[2]] = 0
		end

		player:AddCacheFlags(rockWormCacheFlags)
		player:EvaluateItems()
	end)
end)

local rockWormPause
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:HasTrinket(rockWorm) then
		local data = mod.GetPersistentPlayerData(player)

		if data.rockWorm then
			local hasWormEffect
			for _, key in pairs(rockWormData) do
				data.rockWorm[key] = data.rockWorm[key] or 0

				if data.rockWorm[key[2]] > 0 then
					hasWormEffect = true
				end
			end

			if rockWormPause and rockWormPause + 30 < player.FrameCount then
				rockWormPause = nil
			end

			if not hasWormEffect and not rockWormPause then
				rockWormPause = player.FrameCount

				for i = 1, player:GetTrinketMultiplier(rockWorm) do
					mod.XalumSchedule(i * 15, function()
						local rng = player:GetTrinketRNG(rockWorm)
						local wormData = rockWormData[rng:RandomInt(#rockWormData) + 1]

						data.rockWorm[wormData[2]] = data.rockWorm[wormData[2]] + 1

						player:AnimateTrinket(wormData[1], "UseItem")
						player:AddCacheFlags(rockWormCacheFlags)
						player:EvaluateItems()
					end)
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = tear.Parent:ToPlayer()
	if player and not tear:HasTearFlags(TearFlags.TEAR_HOMING) then
		local data = mod.GetPersistentPlayerData(player).rockWorm
		if data and player:HasTrinket(rockWorm) then
			local luck = player.Luck + 3 * player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM)
			local rng = RNG()
			rng:SetSeed(tear.InitSeed + rockWorm, 42)

			for i = 1, data.ouroborosWormNum do
				if rng:RandomFloat() < 1 / (10 - luck) then
					tear:AddTearFlags(TearFlags.TEAR_HOMING)
					return
				end
			end
		end
	end
end)