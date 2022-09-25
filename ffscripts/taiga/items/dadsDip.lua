-- Dad's Dip --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
	player:AddMaxHearts(2)
	mod:AddMorbidHearts(player, 3)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DIRTY_MIND) then
		local dip = player:ThrowFriendlyDip(672, player.Position, player.Position + Vector(0,30))
	end
end, nil, FiendFolio.ITEM.COLLECTIBLE.DADS_DIP)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, dip)
	if dip.Variant == FamiliarVariant.DIP and dip.SubType == 672 then
		mod.scheduleForUpdate(function()
			sfx:Play(mod.Sounds.DadsDipDeath, 0.2, 0, false, 1.5)
		end, 15)
	end
end, 3)