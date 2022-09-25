local mod = FiendFolio
local game = Game()
local threeOfWands = mod.ITEM.CARD.THREE_OF_WANDS

mod.ThreeOfWandsDropTable = {
	{Variant = PickupVariant.PICKUP_LIL_BATTERY, 	SubType = BatterySubType.BATTERY_NORMAL, 	Unlocked = function() return true end},
	{Variant = PickupVariant.PICKUP_LIL_BATTERY, 	SubType = BatterySubType.BATTERY_MICRO, 	Unlocked = function() return true end},
	{Variant = PickupVariant.PICKUP_LIL_BATTERY, 	SubType = BatterySubType.BATTERY_MEGA, 		Unlocked = function() return true end},
	{Variant = PickupVariant.PICKUP_LIL_BATTERY, 	SubType = BatterySubType.BATTERY_GOLDEN, 	Unlocked = function() return mod.AchievementTrackers.GoldenBatteryUnlocked end},

	{Variant = PickupVariant.PICKUP_TAROTCARD,		SubType = mod.ITEM.CARD.STORAGE_BATTERY_3,	Unlocked = function() return true end},
	{Variant = PickupVariant.PICKUP_TAROTCARD, 		SubType = mod.ITEM.CARD.CORRODED_BATTERY_3, Unlocked = function() return true end},
}

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	local validList = {}
	for _, data in pairs(mod.ThreeOfWandsDropTable) do
		if data.Unlocked() then
			table.insert(validList, data)
		end
	end

	local room = game:GetRoom()
	local rng = player:GetCardRNG(threeOfWands)
	for i = 1, 3 do
		local data = validList[rng:RandomInt(#validList) + 1]
		local position = room:FindFreePickupSpawnPosition(player.Position, 40)
		local pickup = Isaac.Spawn(5, data.Variant, data.SubType, position, Vector.Zero, player):ToPickup()
		pickup.Timeout = 90
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeWands, flags, 40)
end, threeOfWands)