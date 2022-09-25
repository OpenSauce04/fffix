local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect, player, flags)
	local doHorseEffect = mod.XalumIsPlayerUsingHorsePill(player, flags)
	local strength = doHorseEffect and 2 or 1
	local data = mod.GetPersistentPlayerData(player)
	data.ffFishOilTracker = data.ffFishOilTracker and data.ffFishOilTracker + strength or strength

	player:AnimateHappy()
	if doHorseEffect then
		mod:trySayAnnouncerLine(mod.Sounds.VAPillHorseFishOil, flags, 20)
	else
		mod:trySayAnnouncerLine(mod.Sounds.VAPillFishOil, flags, 20)
	end
end, mod.ITEM.PILL.FISH_OIL)

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect, player, flags)
	local doHorseEffect = mod.XalumIsPlayerUsingHorsePill(player, flags)
	local strength = doHorseEffect and 2 or 1
	local data = mod.GetPersistentPlayerData(player)
	data.ffLemonJuiceTracker = data.ffLemonJuiceTracker and data.ffLemonJuiceTracker + strength or strength

	player:AnimateSad()
	if doHorseEffect then
		mod:trySayAnnouncerLine(mod.Sounds.VAPillHorseLemonJuice, flags, 30)
	else
		mod:trySayAnnouncerLine(mod.Sounds.VAPillLemonJuice, flags, 20)
	end
end, mod.ITEM.PILL.LEMON_JUICE)

local OilVal = 1.8 --Loosely how much it scales by, previously 2.25

local function doFishOil(tear, player)
	local data = mod.GetPersistentPlayerData(player)
	if data.ffFishOilTracker and data.ffFishOilTracker > 0 then
		local multiplier = 1.5 * math.log(data.ffFishOilTracker / 3, 10) + OilVal
		tear.Scale = tear.Scale * multiplier
	end
end

local function doLemonJuice(tear, player)
	local data = mod.GetPersistentPlayerData(player)
	if data.ffLemonJuiceTracker and data.ffLemonJuiceTracker > 0 then
		local multiplier = 1.5 * math.log(data.ffLemonJuiceTracker / 3, 10) + OilVal
		tear.Scale = tear.Scale / multiplier
	end
end

-- I stole this from Retribution lmao, get fucked me
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if tear.FrameCount < 1 and tear.Parent and not tear:GetData().dowsing then
		if tear.Parent.Type == 1 or (tear.Parent.Type == 3 and (tear.Parent.Variant == 80 or tear.Parent.Variant == 235 or tear.Parent.Variant == 240)) then
			local query = tear.Parent:ToFamiliar()
			local player = (query and query.Player or tear.Parent):ToPlayer()

			doFishOil(tear, player)
			doLemonJuice(tear, player)
		end
	elseif tear.FrameCount == 1 and tear.Parent then
		if tear.Parent.Type == 3 and tear.Parent.Variant == 81 then
			local player = tear.Parent:ToFamiliar().Player

			doFishOil(tear, player)
			doLemonJuice(tear, player)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
	local player = knife.Parent and knife.Parent:ToPlayer()

	if player then
		local data = mod.GetPersistentPlayerData(player)
		if (data.ffFishOilTracker or 0) + (data.ffLemonJuiceTracker or 0) > 0 then

			local fishOilScale = 1 
			local lemonJuiceScale = 1

			if (data.ffFishOilTracker or 0) > 0 then
				fishOilScale = 1.5 * math.log(data.ffFishOilTracker / 3, 10) + OilVal
			end
			if (data.ffLemonJuiceTracker or 0) > 0 then
				lemonJuiceScale = 1.5 * math.log(data.ffLemonJuiceTracker / 3, 10) + OilVal
			end

			knife.SpriteScale = Vector.One * fishOilScale / lemonJuiceScale
			if not mod.IsKnifeSwingable(knife) then
				knife.SizeMulti = knife.SpriteScale
			end
		end 
	end
end)