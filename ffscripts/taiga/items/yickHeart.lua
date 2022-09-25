-- Yick Heart --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, useflags, activeslot, customvardata)
	local player = mod:GetPlayerUsingItem()
	FiendFolio:AddMorbidHearts(player, 3)
	SFXManager():Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1.0)
	return useflags ~= useflags | UseFlag.USE_NOANIM
end, FiendFolio.ITEM.COLLECTIBLE.YICK_HEART)
