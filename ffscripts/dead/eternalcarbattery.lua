local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local specialCases = {
    [CollectibleType.COLLECTIBLE_ESAU_JR] = false,
    [CollectibleType.COLLECTIBLE_GENESIS] = false,
    [CollectibleType.COLLECTIBLE_DAMOCLES] = false,
    [CollectibleType.COLLECTIBLE_MAMA_MEGA] = false,
    [CollectibleType.COLLECTIBLE_MYSTERY_GIFT] = false,
    [FiendFolio.ITEM.COLLECTIBLE.EMPTY_BOOK] = false,
    [CollectibleType.COLLECTIBLE_ERASER] = function(player, rng, useFlags, activeSlot)
        local validEnemies = {}
        for _, entity in ipairs(Isaac.FindInRadius(room:GetCenterPos(), 9999, EntityPartition.ENEMY)) do
            if (not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET))
            and entity:IsVulnerableEnemy()
            and (not entity:IsBoss())
            and (entity.HitPoints > 0)
            and entity.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            and (not mod.BlackListedFlowerCrowns[entity.Type])
            and (not mod.BlackListedFlowerCrowns[entity.Type .. " " .. entity.Variant])
            and (not mod:isFriend(entity))
            then
                table.insert(validEnemies, entity)
            end
        end

        for _, enemy in ipairs(validEnemies) do
            local tear = Isaac.Spawn(2, 45, 0, enemy.Position, Vector.Zero, nil):ToTear()
            tear.Visible = false
            tear:Update()
            enemy:Update()
            sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            mod.scheduleForUpdate(function()
                sfx:Stop(SoundEffect.SOUND_PLOP)
            end, 1)
        end
    end
}

local blacklistedFlags = UseFlag.USE_CARBATTERY | UseFlag.USE_VOID
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, useFlags, activeSlot, varData)
    if player:HasTrinket(TrinketType.TRINKET_ETERNAL_CAR_BATTERY) and useFlags & blacklistedFlags == 0 and activeSlot > -1 and activeSlot ~= ActiveSlot.SLOT_POCKET then
        local guaranteeRemove
        if specialCases[collectible] then
            guaranteeRemove = specialCases[collectible](player, rng, useFlags, activeSlot, varData)
        elseif specialCases[collectible] ~= false then
            local originalPos = player.Position
            for i = 1, math.random(3, 5) do
                player.Position = originalPos + RandomVector() * math.random(20, 60)
                player:UseActiveItem(collectible, UseFlag.USE_CARBATTERY, activeSlot)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                    player:TriggerBookOfVirtues(collectible)
                end
            end

            player.Position = originalPos
        end

        if specialCases[collectible] ~= false then
            if rng:RandomFloat() < 0.5 or guaranteeRemove then
                player:RemoveCollectible(collectible, false, activeSlot, false)
            end

            game:ShakeScreen(15)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, collectible, rng, player, useFlags, activeSlot, varData)
    if player:HasTrinket(TrinketType.TRINKET_ETERNAL_CAR_BATTERY) and useFlags & blacklistedFlags == 0 and activeSlot > -1 then
        if collectible == CollectibleType.COLLECTIBLE_FORGET_ME_NOW then
            player:RemoveCollectible(collectible, false, activeSlot, false)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_R_KEY, UseFlag.USE_NOANIM)
            return true
        end
    end
end)
