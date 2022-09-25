local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local data = player:GetData().ffsavedata

	local vec
	local enemy = mod.FindClosestEnemy(player.Position)
	if player:GetMovementVector():Length() > 0 then
		vec = player:GetMovementVector():Resized(30)
	elseif enemy then
		vec = (enemy.Position - player.Position):Resized(30)
	else
		vec = RandomVector():Resized(30)
	end
    for i = 120, 360, 120 do
		FiendFolio.LaunchFireball(player, vec:Rotated(i), "implosion")
	end

	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardImplosion, flags, 40)
end, Card.IMPLOSION)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local buddy = Isaac.Spawn(mod.FF.Psihunter.ID, mod.FF.Psihunter.Var, 10, player.Position, nilvector, player):ToNPC()
	buddy:AddCharmed(EntityRef(player), -1)
	buddy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
	buddy:Update()

	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardCallingCard, flags, 20)
end, Card.CALLING_CARD)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	mod.downloadFailureCarded = true
	sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, math.random(90,110)/100)
	for i = 1, math.random(20,35) do
		local particle = Isaac.Spawn(1000, 4, math.random(BackdropType.NUM_BACKDROPS), Isaac.GetRandomPosition(), RandomVector()*math.random(10, 350)/100, nil):ToEffect()
		particle.Color = Color(math.random() * 2,math.random() * 2,math.random() * 2,1, math.random() * 2, math.random() * 2, math.random() * 2)
		particle.m_Height = -300 - math.random(1200)
		mod.scheduleForUpdate(function()
			if particle then
				local sprite = particle:GetSprite()
				particle.Color = mod.ColorNormal
				sprite:ReplaceSpritesheet(0, "gfx/grid/rocks_error-1.png.png")
				sprite:LoadGraphics()
			end
		end, math.random(50,100))
		particle:Update()
	end
	Game():ShakeScreen(15)
	player:QueueExtraAnimation("Glitch")

	if math.random(3) == 1 then
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardDownloadFailureRare, flags, 40)
	else
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardDownloadFailure, flags, 40)
	end
end, Card.DOWNLOAD_FAILURE)
