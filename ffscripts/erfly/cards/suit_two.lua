local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	for i = 0, 3 do
		local baseCharge = player:GetActiveCharge(i)
		local overcharge = player:GetBatteryCharge(i)
		player:SetActiveCharge(math.max(baseCharge*2, 1),i)
	end
	sfx:Play(SoundEffect.SOUND_BATTERYCHARGE,1,1,false,1.5)
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingTwoWands, flags, 20)
end, Card.TWO_OF_WANDS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local Spawns = {}
	local t0 = player:GetTrinket(0)
	local t1 = player:GetTrinket(1)

	if t0 > 0 then
		table.insert(Spawns, t0)
	end
	if t1 > 0 then
		table.insert(Spawns, t1)
	end

	if #Spawns < 1 then
		table.insert(Spawns, 0)
	end

	local vec = RandomVector() * 3
	for i = 1, #Spawns do
		Isaac.Spawn(5, 350, Spawns[i], player.Position, vec:Rotated((i / #Spawns) * 360), player)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingTwoPentacles, flags, 40)
end, Card.TWO_OF_PENTACLES)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	for _, fam in ipairs(Isaac.FindByType(3, -1, -1, false, false)) do
		if fam.Variant == 43 or fam.Variant == 73 or fam.Variant == 201 or fam.Variant == 228 or fam.Variant == mod.ITEM.FAMILIAR.ATTACK_SKUZZ or fam.Variant == mod.ITEM.FAMILIAR.FRAGILE_BOBBY then
			Isaac.Spawn(fam.Type, fam.Variant, fam.SubType, fam.Position + RandomVector():Resized(math.random(5,15)), nilvector, player)
		end
	end
	player:UseActiveItem(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS, false, false, true, false)
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingTwoSwords, flags, 20)
end, Card.TWO_OF_SWORDS)