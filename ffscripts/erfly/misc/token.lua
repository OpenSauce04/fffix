local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_PENNYDROP, 1, 0, false, 1.0)
	end
end, PickupVariant.PICKUP_TOKEN)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == 1 then
		collider = collider:ToPlayer()
		if pickup:IsShopItem() and pickup.Price > collider:GetNumCoins() then
			return true
        else
            if pickup:GetSprite():WasEventTriggered("DropSound") or pickup:GetSprite():IsPlaying("Idle") then
                local pickedUp
                if not mod.CurrentTokenValue then
                    sfx:Play(mod.Sounds.CursedPennyNeutral, 1, 0, false, 1)
                    pickup:GetSprite():Play("Collect")
                    pickedUp = true
                end
                if pickedUp then
                    pickup.EntityCollisionClass = 0
                    if pickup:IsShopItem() then
                        collider:AddCoins(-1 * pickup.Price)
                    end
                    if pickup.OptionsPickupIndex ~= 0 then
                        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
                        for _, entity in ipairs(pickups) do
                            if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
                               (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
                            then
                                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, nilvector, nil)
                                entity:Remove()
                            end
                        end
                    end
                end
            end
        end
    else
        return false
    end
end, PickupVariant.PICKUP_TOKEN)