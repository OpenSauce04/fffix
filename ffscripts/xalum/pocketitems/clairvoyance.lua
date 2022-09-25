local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect, player, flags)
	player:AnimateHappy()

	local level = game:GetLevel()
	local removableCurses = level:GetCurses() & ~ LevelCurse.CURSE_OF_LABYRINTH

	level:RemoveCurses(removableCurses)

	if mod.XalumIsPlayerUsingHorsePill(player, flags) then
		mod:trySayAnnouncerLine(mod.Sounds.VAPillHorseClairvoyance, flags, 20)
	else
		mod:trySayAnnouncerLine(mod.Sounds.VAPillClairvoyance, flags, 20)
	end
end, mod.ITEM.PILL.CLAIRVOYANCE)