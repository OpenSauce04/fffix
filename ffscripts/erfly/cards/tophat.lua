local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
	local r = player:GetCardRNG(mod.ITEM.CARD.TOP_HAT)
	local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP,711,1,Isaac.GetFreeNearPosition(player.Position,40), nilvector, player):ToPickup()
		chest:GetData().funny = true
	local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 15, chest.Position, nilvector, nil)
	sfx:Play(mod.Sounds.NitroActive, 1, 0, false, 1.2)
end, mod.ITEM.CARD.TOP_HAT)