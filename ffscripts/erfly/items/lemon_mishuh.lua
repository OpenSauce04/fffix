local mod = FiendFolio
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player, useflags, activeslot)
    if useflags == useflags | UseFlag.USE_CARBATTERY then
        return {Discharge = false, Remove = false, ShowAnim = false}
    else
        local useOnReuse = false
        local d = player:GetData()
        if d.holdingFFItem then
            d.holdingFFItem = nil
            d.HoldingFFItemBlankVisual =nil
            player:AnimateCollectible(mod.ITEM.COLLECTIBLE.LEMON_MISHUH, "HideItem", "PlayerPickup")
            if useOnReuse then
                local pool = Isaac.Spawn(1000, 32, 0, player.Position, nilvector, player)
                pool:Update()
                sfx:Play(SoundEffect.SOUND_GASCAN_POUR, 1, 0, false, 1)
                return {Discharge = true, Remove = false, ShowAnim = false}
            end
        else
            d.holdingFFItem = mod.ITEM.COLLECTIBLE.LEMON_MISHUH
            d.holdingFFItemSlot = activeslot
            d.HoldingFFItemBlankVisual = true
            player:AnimateCollectible(mod.ITEM.COLLECTIBLE.LEMON_MISHUH, "LiftItem", "PlayerPickup")
        end

        return {Discharge = false, Remove = false, ShowAnim = false}
    end
end, mod.ITEM.COLLECTIBLE.LEMON_MISHUH)

function mod:throwLemonMishuh(player, data, aim)
    if player:HasTrinket(mod.ITEM.TRINKET.ETERNAL_CAR_BATTERY) then
        for i = 1, math.random(3,5) do
            local tear = Isaac.Spawn(2, TearVariant.LEMON_MISHAP, 0, player.Position, aim:Resized(15):Rotated(-15 + math.random(30)) + player:GetTearMovementInheritance(aim), player)
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        for i = -5, 5, 10 do
            local tear = Isaac.Spawn(2, TearVariant.LEMON_MISHAP, 0, player.Position, aim:Resized(15):Rotated(i) + player:GetTearMovementInheritance(aim), player)
        end
    else
        local tear = Isaac.Spawn(2, TearVariant.LEMON_MISHAP, 0, player.Position, aim:Resized(15) + player:GetTearMovementInheritance(aim), player)
    end
    if data.holdingFFItemSlot then
        player:DischargeActiveItem(data.holdingFFItemSlot)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    local d = tear:GetData()
    d.RotVal = d.RotVal or 0
    if tear.Velocity.X > 0 then
        d.RotVal = d.RotVal + tear.Velocity:Length()
    else
        d.RotVal = d.RotVal - tear.Velocity:Length()
    end
    tear.SpriteRotation = d.RotVal
end, TearVariant.LEMON_MISHAP)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, coll)
    if tear.SpawnerEntity then
        coll:AddConfusion(EntityRef(tear.SpawnerEntity), 120, false)
    end
end, TearVariant.LEMON_MISHAP)

function mod:lemonMishuhTearDeath(tear, data)
    if tear.Variant == TearVariant.LEMON_MISHAP then
        local pool = Isaac.Spawn(1000, 32, 0, tear.Position, nilvector, tear)
        pool:Update()
        sfx:Play(SoundEffect.SOUND_GASCAN_POUR, 1, 0, false, 1)
        local splat = Isaac.Spawn(1000, 1960, 33, tear.Position, nilvector, tear):ToEffect()
        splat.Color = Color(1, 1, 0, 1)
        splat:Update()
    end
end