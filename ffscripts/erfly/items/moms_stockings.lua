local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.AddItemPickupCallback(function(player, added)
    sfx:Play(SoundEffect.SOUND_SKIN_PULL, 0.6, 0, false, 1.5)
    local spawnCount = 0
    for i = 1, 3 do
        spawnCount = spawnCount + math.random(3)
    end
    for i = 1, spawnCount do
        local vec = Vector(5,0):Rotated((360/spawnCount) * i)
        local skuzz = Isaac.Spawn(3, mod.ITEM.FAMILIAR.ATTACK_SKUZZ, 0, player.Position - vec, nilvector, player):ToFamiliar()
        skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        skuzz:Update()
    end
end, nil, mod.ITEM.COLLECTIBLE.MOMS_STOCKINGS)