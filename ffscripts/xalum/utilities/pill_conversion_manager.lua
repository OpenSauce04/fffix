local mod = FiendFolio
local game = Game()

mod.GoodToBadPillConversion = {
	[mod.ITEM.PILL.HOLY_SHIT] 		= mod.ITEM.PILL.HAEMORRHOIDS,
	[mod.ITEM.PILL.CLAIRVOYANCE] 	= PillEffect.PILLEFFECT_AMNESIA,
	[mod.ITEM.PILL.MELATONIN] 		= PillEffect.PILLEFFECT_PARALYSIS,
	[mod.ITEM.PILL.FISH_OIL] 		= mod.ITEM.PILL.LEMON_JUICE,
}

mod.BadToGoodPillConversion = {
	[mod.ITEM.PILL.HAEMORRHOIDS] 	= mod.ITEM.PILL.HOLY_SHIT,
	[mod.ITEM.PILL.EPIDERMOLYSIS] 	= PillEffect.PILLEFFECT_PERCS,
	[mod.ITEM.PILL.LEMON_JUICE]		= mod.ITEM.PILL.FISH_OIL,
}

mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, function(_, effect, colour)
	if mod.XalumShouldPillEffectTurnPositive(effect) then
		return mod.BadToGoodPillConversion[effect]
	elseif mod.XalumShouldPillEffectTurnNegative(effect) then
		return mod.GoodToBadPillConversion[effect]
	end
end)