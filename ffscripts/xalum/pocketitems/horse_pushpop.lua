local mod = FiendFolio
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player)
	player:AddBrokenHearts(-1)
	sfx:Play(SoundEffect.SOUND_VAMP_GULP)
end, mod.ITEM.CARD.HORSE_PUSHPOP)