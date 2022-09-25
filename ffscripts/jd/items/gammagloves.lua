local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player)
	game:ShakeScreen(5)
	SFXManager():Play(mod.Sounds.ForeseerClap, 0.3, 2, false, (math.random(140,160)/100))
	game:UpdateStrangeAttractor(player.Position, -150, 9999999999)
	mod.scheduleForUpdate(function()
		Isaac.Spawn(20, 0, 150, player.Position, Vector.Zero, nil)
		SFXManager():Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
	end, 0)
end, mod.ITEM.COLLECTIBLE.GAMMA_GLOVES)