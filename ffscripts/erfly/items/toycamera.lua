local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, useflags, activeslot)
    if useflags == useflags | UseFlag.USE_CARBATTERY then
        return {Discharge = false, Remove = false, ShowAnim = false}
    else
        local d = player:GetData()
        if d.holdingFFItem then
            d.holdingFFItem = nil
            d.holdingFFItemSlot = nil
            player:AnimateCollectible(mod.ITEM.COLLECTIBLE.TOY_CAMERA, "HideItem", "PlayerPickup")
        else
            d.holdingFFItem = mod.ITEM.COLLECTIBLE.TOY_CAMERA
            d.holdingFFItemSlot = activeslot
            player:AnimateCollectible(mod.ITEM.COLLECTIBLE.TOY_CAMERA, "LiftItem", "PlayerPickup")
        end
        return {Discharge = false}
    end
end, mod.ITEM.COLLECTIBLE.TOY_CAMERA)

function mod:useHeldItemToyCamera(player, d, aim)
    if d.holdingFFItemSlot then
        sfx:Play(mod.Sounds.CameraPrime,0.2,0,false, 1)
        local count = 1
        local speed = 35
        if player:HasTrinket(mod.ITEM.TRINKET.ETERNAL_CAR_BATTERY) then
            count = math.random(3,5)
            speed = 39
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            count = 2
            speed = 39
        end
        for i = 1, count do
            local flash = Isaac.Spawn(1000, mod.FF.CameraFlash.Var, mod.FF.CameraFlash.Sub, player.Position, aim:Resized(speed * i), player)
            flash.SpawnerEntity = player
            flash:GetSprite().Rotation = aim:GetAngleDegrees() - 90
            if mod:playerIsBelialMode(player) then
                flash.Color = Color(1,0,0,1)
            end
            flash:Update()
        end
        player:DischargeActiveItem(d.holdingFFItemSlot)
    end
end

mod.EffectsToyCameraCanDelete = {
    [22] = true,
    [23] = true,
    [24] = true,
    [25] = true,
    [26] = true,
    [7005] = true,
}
mod.TechnicalEntsToyCameraCanDelete = {
    [0] = true,
    [1] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [13] = true,
    [19] = true,
    [21] = true,
    [22] = true,
    [27] = true,
    [29] = true,
    [34] = true,
}

function mod:toyCameraFlashUpdate(e)
    local sprite, d = e:GetSprite(), e:GetData()
    e.Velocity = e.Velocity * 0.6
    e.DepthOffset = 1000
    e.SpriteOffset = Vector(0, -10)
    if e.FrameCount >= 5 then
        if sprite:IsFinished("flash") then
            e:Remove()
        elseif sprite:IsEventTriggered("AddToCringeCollection") then
            sfx:Play(mod.Sounds.CameraFlash, 1.5, 0, false, math.random(90,110)/100)
            --Isaac.Spawn(1000, 16, 0, e.Position + Vector(48, 32), nilvector, nil)
            --Isaac.Spawn(1000, 16, 0, e.Position - Vector(48, 32), nilvector, nil)
            local belialMode
            game:Darken(0, 5)
            if mod:playerIsBelialMode(e.SpawnerEntity:ToPlayer()) then
                belialMode = true
            end
            local insideEntities = {}
            for _, entity in pairs(Isaac.GetRoomEntities()) do
                if entity and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                    local vec = entity.Position - e.Position
                    vec = vec:Rotated(-sprite.Rotation)
                    local testPos = e.Position + vec
                    local entityColl = (entity.Size * 2)
                    if (testPos.X <= e.Position.X + 48 + entityColl) and (testPos.X >= e.Position.X - 48 - entityColl) and (testPos.Y <= e.Position.Y + 32 + entityColl) and (testPos.Y >= e.Position.Y - 32 - entityColl) then
                        if entity:ToNPC() then
                            if entity.Type == 33 then
                                entity:Die()
                            elseif FiendFolio.SegmentedEnemies[entity.Type .. " " .. entity.Variant] or FiendFolio.SegmentedEnemies[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType] then
                                if FiendFolio.MainSegment[entity.Type .. " " .. entity.Variant] or FiendFolio.MainSegment[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType] then
                                    table.insert(insideEntities, entity)
                                end
                            else
                                table.insert(insideEntities, entity)
                            end
                            if not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                                entity:AddConfusion(EntityRef(e.SpawnerEntity), 120, false)
                            end
                        elseif entity:ToPlayer() then
                            entity:GetData().alphacointemptearstime = 0
                            entity:GetData().alphacointemptearslength = 4
                        end
                    end
                    --Isaac.Spawn(1000, 15, 0, testPos, nilvector, nil)
                
                end
            end
            if belialMode then
                for i = 1, #insideEntities do
                    insideEntities[i]:TakeDamage(e.SpawnerEntity:ToPlayer().Damage * #insideEntities, 0, EntityRef(e.SpawnerEntity:ToPlayer()), 0)
                    insideEntities[i]:BloodExplode()
                end
            end
            if (not mod.alreadyPayedOutToyCameraInRoom) and #insideEntities >= 4 then
                local room = game:GetRoom()
                local pos = room:FindFreePickupSpawnPosition(e.Position, 40, true)    
                Isaac.Spawn(5, 300, Card.COOL_PHOTO, pos, nilvector, e.SpawnerEntity)
                mod.alreadyPayedOutToyCameraInRoom = true
            elseif insideCount == 0 and math.random(100000) == 0 then
                sfx:Play(mod.Sounds.CameraMiss, 1, 0, false, 1)
            end

            for i = 1, 5 do
                mod.scheduleForUpdate(function()
                    for _, entity in pairs(Isaac.GetRoomEntities()) do
                        if entity.Type == EntityType.ENTITY_PROJECTILE or (entity.Type == 1000 and mod.EffectsToyCameraCanDelete[entity.Variant]) or (EntityType == 150 and TechnicalEntsToyCameraCanDelete[Entity.Variant]) then
                            local vec = entity.Position - e.Position
                            vec = vec:Rotated(-sprite.Rotation)
                            local testPos = e.Position + vec
                            local entityColl = (entity.Size * 2)
                            if (testPos.X <= e.Position.X + 48 + entityColl) and (testPos.X >= e.Position.X - 48 - entityColl) and (testPos.Y <= e.Position.Y + 32 + entityColl) and (testPos.Y >= e.Position.Y - 32 - entityColl) then
                                entity:Remove()
                            end
                        end
                    end
                end, i * 2)
            end
        else
            mod:spritePlay(sprite, "flash")
        end
    else
        sprite:Play("aim")
    end
end

function mod.toyCameraNewRoomReset()
    mod.alreadyPayedOutToyCameraInRoom = false
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
	local r = player:GetCardRNG(Card.COOL_PHOTO)
    local coinCount = 1 + r:RandomInt(2)
    for i = 1, coinCount do
        FiendFolio.scheduleForUpdate(function()
            local room = game:GetRoom()
            local pos = room:FindFreePickupSpawnPosition(player.Position + RandomVector() * 10, 40, true)    
            Isaac.Spawn(5, 20, 1, pos, nilvector, player)
        end, i * 2)
    end
end, Card.COOL_PHOTO)