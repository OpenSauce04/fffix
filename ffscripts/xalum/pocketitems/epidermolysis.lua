local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect, player, flags)
	player:AnimateSad()

	local data = player:GetData()
	data.fiendfolio_epidermolysisStrength = data.fiendfolio_epidermolysisStrength or 0

	local targetLevel = mod.XalumIsPlayerUsingHorsePill(player, flags) and 2 or 1
	
	data.fiendfolio_epidermolysisStrength = math.max(targetLevel, data.fiendfolio_epidermolysisStrength)

	if targetLevel > 1 then
		mod:trySayAnnouncerLine(mod.Sounds.VAPillHorseEpidermolysis, flags, 20)
	else
		mod:trySayAnnouncerLine(mod.Sounds.VAPillEpidermolysis, flags, 20)
	end
end, mod.ITEM.PILL.EPIDERMOLYSIS)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, player in pairs(Isaac.FindByType(1)) do
		player:GetData().fiendfolio_epidermolysisStrength = 0
	end
end)