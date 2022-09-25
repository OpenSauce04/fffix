local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(mod.Sounds.ZealotBoom, 1, 0, false, 1)
end, nil, CollectibleType.COLLECTIBLE_BOOM)

FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(SoundEffect.SOUND_DIMEPICKUP, 1, 0, false, 1)
end, nil, FiendFolio.ITEM.COLLECTIBLE.X10KACHING)

FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 0, false, 0.8)
end, nil, FiendFolio.ITEM.COLLECTIBLE.X10BATOOMKLING)

FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(SoundEffect.SOUND_VAMP_DOUBLE, 1, 0, false, 1)
end, nil, FiendFolio.ITEM.COLLECTIBLE.X10BADUMP)

function mod:addOneChargeToFirstAvailableItem(player)
    local itemconfig = Isaac.GetItemConfig()
    for j = 0, 3 do
        local item = player:GetActiveItem(j)
        if item > 0 then
            itemDesc = itemconfig:GetCollectible(item)
            if itemDesc.MaxCharges > 0 and itemDesc.ChargeType == 0 then
                local fullCharge = player:GetActiveCharge(j) + player:GetBatteryCharge(j)
                if fullCharge < itemDesc.MaxCharges * 2 then
                    player:SetActiveCharge(fullCharge + 1, j)
                    break
                end
            end
        end
    end
end
FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(SoundEffect.SOUND_BATTERYCHARGE,1,1,false,1.5)
    for i = 1, 10 do
        mod:addOneChargeToFirstAvailableItem(player)
    end
end, nil, FiendFolio.ITEM.COLLECTIBLE.X10BZZT)

FiendFolio.AddItemPickupCallback(function(player, added)
    sfx:Play(mod.Sounds.CartoonGulp, 1, 0, false, 1)
    for i = 1, 10 do
        player:AddCollectible(CollectibleType.COLLECTIBLE_GLIZZY)
    end
end, nil, FiendFolio.ITEM.COLLECTIBLE.X10CHOMPCHOMP)

function mod:batoomKlingOnLocustDamage(player, locust, entity, secondHandMultiplier)
    if math.random(10) == 1 then
        FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
    end
end