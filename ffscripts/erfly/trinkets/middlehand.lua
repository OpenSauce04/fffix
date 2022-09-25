local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:middleHandPlayerUpdate(player, data)
    if player:HasTrinket(TrinketType.TRINKET_LEFT_HAND) and player:HasTrinket(mod.ITEM.TRINKET.RIGHT_HAND) then
        if player:IsExtraAnimationFinished() then
            local eitherGulped
            local makeGolden
            local t0 = player:GetTrinket(0)
            local t1 = player:GetTrinket(1)
            if player:GetTrinketMultiplier(TrinketType.TRINKET_LEFT_HAND) > 1 or player:GetTrinketMultiplier(mod.ITEM.TRINKET.RIGHT_HAND) > 1 then
                makeGolden = true
            end
            --This code fuckin sucks dude
            if (t1 % 32768) == TrinketType.TRINKET_LEFT_HAND and (t0 % 32768) ~= mod.ITEM.TRINKET.RIGHT_HAND
            or (t0 % 32768) == TrinketType.TRINKET_LEFT_HAND and (t1 % 32768) ~= mod.ITEM.TRINKET.RIGHT_HAND 
            or (t1 % 32768) == mod.ITEM.TRINKET.RIGHT_HAND and (t0 % 32768) ~= TrinketType.TRINKET_LEFT_HAND 
            or (t0 % 32768) == mod.ITEM.TRINKET.RIGHT_HAND and (t1 % 32768) ~= TrinketType.TRINKET_LEFT_HAND 
            then
                eitherGulped = true
            end
            if makeGolden then
                if not player:TryRemoveTrinket(TrinketType.TRINKET_LEFT_HAND + TrinketType.TRINKET_GOLDEN_FLAG) then
                    player:TryRemoveTrinket(TrinketType.TRINKET_LEFT_HAND)
                end
                if not player:TryRemoveTrinket(mod.ITEM.TRINKET.RIGHT_HAND + TrinketType.TRINKET_GOLDEN_FLAG) then
                    player:TryRemoveTrinket(mod.ITEM.TRINKET.RIGHT_HAND)
                end
            else
                if not player:TryRemoveTrinket(TrinketType.TRINKET_LEFT_HAND) then
                    player:TryRemoveTrinket(TrinketType.TRINKET_LEFT_HAND + TrinketType.TRINKET_GOLDEN_FLAG)
                end
                if not player:TryRemoveTrinket(mod.ITEM.TRINKET.RIGHT_HAND) then
                    player:TryRemoveTrinket(mod.ITEM.TRINKET.RIGHT_HAND + TrinketType.TRINKET_GOLDEN_FLAG)
                end
            end

            local addedTrinket = mod.ITEM.TRINKET.MIDDLE_HAND
            if makeGolden then
                addedTrinket = addedTrinket + 32768
            end
            if eitherGulped then
                mod:gulpTrinket(player, addedTrinket)
            else
                player:AddTrinket(addedTrinket)
            end
            sfx:Play(mod.Sounds.FiendHeartPickupRare, 1, 10, false, 1)
            player:AnimateTrinket(addedTrinket)
            if not mod.ACHIEVEMENT.DIRE_CHEST:IsUnlocked(true) then
                mod.ACHIEVEMENT.DIRE_CHEST:Unlock()
            end
            --shrug
            local config = Isaac.GetItemConfig():GetTrinket(mod.ITEM.TRINKET.MIDDLE_HAND)
            game:GetHUD():ShowItemText(config.Name, config.Description)
            mod.scheduleForUpdate(function()
                for i = 30, 360, 30 do
                    local vec = Vector(0,3):Rotated(i)
                    local sparkle = Isaac.Spawn(1000, 1727, 0, player.Position + vec:Resized(20), vec, nil):ToEffect()
                    sparkle.SpriteOffset = Vector(0,-27)
                    sparkle:Update()
                end
            end, 8)
        end
    end
end

function mod:getClosetSpecificTrinket(pos, trinket)
    local closet
    local maxdist = 999999
    for _, v in pairs(Isaac.FindByType(5,350,-1, false, false)) do
        if v.SubType % 32768 == trinket then
            local dist = v.Position:Distance(pos)
            if dist < maxdist then
                closest = v
                maxdist = dist
            end
        end
    end
    return closest
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    if pickup.SubType % 32768 == TrinketType.TRINKET_LEFT_HAND then
        local RightHand = mod:getClosetSpecificTrinket(pickup.Position, mod.ITEM.TRINKET.RIGHT_HAND)
        if RightHand and RightHand:Exists() then
            local vec = (RightHand.Position - pickup.Position)
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            pickup.Velocity = mod:Lerp(pickup.Velocity, vec, 0.1)
        end
    elseif pickup.SubType % 32768 == mod.ITEM.TRINKET.RIGHT_HAND then
        local LeftHand = mod:getClosetSpecificTrinket(pickup.Position, TrinketType.TRINKET_LEFT_HAND)
        if LeftHand and LeftHand:Exists() then
            local vec = (LeftHand.Position - pickup.Position)
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            pickup.Velocity = mod:Lerp(pickup.Velocity, vec, 0.1)
        end
    end
end, 350)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
    if collider.Type == 5 and collider.Variant == 350 then
        if pickup.SubType % 32768 == TrinketType.TRINKET_LEFT_HAND and collider.SubType % 32768 == mod.ITEM.TRINKET.RIGHT_HAND then
            local pos = mod:Lerp(pickup.Position, collider.Position, 0.5)
            pickup:Remove()
            collider:Remove()
            sfx:Play(mod.Sounds.FiendHeartPickupRare, 1, 10, false, 1)
            local flash = Isaac.Spawn(1000,1726, 0, pos, nilvector, nil)
            flash:Update()
            local addedTrinket = mod.ITEM.TRINKET.MIDDLE_HAND
            if pickup.SubType > 32768 or collider.SubType > 32768 then
                addedTrinket = addedTrinket + 32768
            end
            local middle = Isaac.Spawn(5, 350, addedTrinket, pos, nilvector, nil)
            if not mod.ACHIEVEMENT.DIRE_CHEST:IsUnlocked(true) then
                mod.ACHIEVEMENT.DIRE_CHEST:Unlock()
            end
            mod.scheduleForUpdate(function()
                for i = 30, 360, 30 do
                    local vec = Vector(0,3):Rotated(i)
                    local sparkle = Isaac.Spawn(1000, 1727, 0, middle.Position + vec:Resized(20), vec, nil):ToEffect()
                    sparkle.SpriteOffset = Vector(0,-27)
                    sparkle:Update()
                end
            end, 8)
        end
    end
end, 350)
 