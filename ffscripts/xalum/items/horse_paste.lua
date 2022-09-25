local mod = FiendFolio
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
	player:AddBrokenHearts(-1)
	sfx:Play(SoundEffect.SOUND_VAMP_GULP)
	return true
end, mod.ITEM.COLLECTIBLE.HORSE_PASTE)