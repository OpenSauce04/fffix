local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect, player, flags)
	sfx:Play(SoundEffect.SOUND_BOIL_HATCH)
	player:AnimateHappy()

	local doHorseEffect = mod.XalumIsPlayerUsingHorsePill(player, flags)
	local room = game:GetRoom()

	for i = 1, doHorseEffect and 18 or 10 do
		local spider = Isaac.Spawn(mod.FF.BabySpider.ID, mod.FF.BabySpider.Var, 0, player.Position, RandomVector():Resized(math.random(10, 20)), player)
		spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		spider:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
	end

	for i = 2, 3 do
		local spider = Isaac.Spawn(85, 0, 0, player.Position, RandomVector():Resized(math.random(10, 20)), player)
		spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		spider:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
	end

	if doHorseEffect then
		for i = 1, 4 do
			local spider = Isaac.Spawn(i <= 2 and 85 or 215, 0, 0, player.Position, RandomVector():Resized(math.random(10, 20)), player)
			spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			spider:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
		end
		mod:trySayAnnouncerLine(mod.Sounds.VAPillHorseSpiderUnboxing, flags, 20)
	else
		mod:trySayAnnouncerLine(mod.Sounds.VAPillSpiderUnboxing, flags, 20)
	end

	local position = room:FindFreeTilePosition(player.Position, 180)
	local index = room:GetGridIndex(position)
	room:SpawnGridEntity(index, GridEntityType.GRID_SPIDERWEB, 6, Random(), 1)
end, mod.ITEM.PILL.SPIDER_UNBOXING)