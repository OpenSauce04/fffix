local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod.trySpawnPosticheSkuzz(player, fireVec, rng)
    if rng:RandomInt(10) == 0 then
        local maxSkuzz = 10
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
            maxSkuzz = maxSkuzz * 2
        end
        if mod.GetEntityCount(3, FamiliarVariant.ATTACK_SKUZZ) < maxSkuzz then
            sfx:Play(SoundEffect.SOUND_SKIN_PULL, 0.2, 0, false, math.random(160,200)/100)
            local randVec = fireVec:Resized(math.random(3,10)):Rotated(-45 + math.random(90))
            local skuzz = Isaac.Spawn(3, FamiliarVariant.ATTACK_SKUZZ, 0, player.Position - randVec, nilvector, player):ToFamiliar()
            skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            skuzz:Update()
        end
    end
end

function mod:dadsPostichePostPlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_POSTICHE) then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
            local aim = player:GetAimDirection()
            if aim:Length() > 0.2 and player.FrameCount % 30 == 1 then
                mod.trySpawnPosticheSkuzz(player, aim, player:GetDropRNG())
            end
        end
    end
end

function mod:dadsPostichePostFire(player, tear, rng, pdata, tdata)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_POSTICHE) then
        mod.trySpawnPosticheSkuzz(player, tear.Velocity, rng)
    end
end

function mod:dadsPostichePostFireBomb(player, bomb, rng)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_POSTICHE) then
        mod.trySpawnPosticheSkuzz(player, bomb.Velocity, rng)
    end
end

function mod:dadsPostichePostFireLaser(player, laser, rng)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_POSTICHE) then
        mod.trySpawnPosticheSkuzz(player, Vector(1,0):Rotated(laser.AngleDegrees), rng)
    end
end

function mod:dadsPostichePostFireKnife(player, knife, rng)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_POSTICHE) then
        mod.trySpawnPosticheSkuzz(player, Vector(1,0):Rotated(knife.Rotation), rng)
    end
end