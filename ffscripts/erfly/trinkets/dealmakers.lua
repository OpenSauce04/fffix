local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero
local rng = RNG()

local devilPrices = {
    -1, --1 Red
    -2, --2 Red
    -3, --3 soul
    -4, --1 Red, 2 Soul
    -7, --1 Soul
    -8, --2 Souls
    -9, --1 Red, 1 Soul
}

local devilPricesRed = {
    -1, --1 Red
    -2, --2 Red
    -4, --1 Red, 2 Soul
    -9, --1 Red, 1 Soul
}

local devilPricesSoul = {
    -3, --3 soul
    -4, --1 Red, 2 Soul
    -7, --1 Soul
    -8, --2 Souls
    -9, --1 Red, 1 Soul
}

local devilPricesSoulOnly = {
    -3, --3 soul
    -7, --1 Soul
    -8, --2 Souls
}

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    if mod.anyPlayerHas(TrinketType.TRINKET_DEALMAKERS, true) and pickup:IsShopItem() then
        local d = pickup:GetData()
        rng:SetSeed(pickup.DropSeed, 0)
        pickup.AutoUpdatePrice = false
        local isCrazy
        if (mod.getTrinketMultiplierAcrossAllPlayers(TrinketType.TRINKET_DEALMAKERS)) >= 2 then
            isCrazy = true
        end
        local shufflespeed = 5
        if isCrazy then
            shufflespeed = 2
        end
        -- -6 is the soul, -5 is the pound of flesh spikes
        if pickup.Price == -6 or pickup.Price == -5 then
            return
        end
        if pickup.Price > 0 then
            if rng:RandomInt(5) == 1 or (rng:RandomInt(5) == 1 and isCrazy) then
                if pickup.FrameCount % shufflespeed == 1 then
                    local rando = math.random(3)
                    if rando == 1 then
                        pickup.Price = math.random(10)
                    elseif rando == 2 then
                        pickup.Price = math.random(20)
                    else
                        pickup.Price = math.random(99)
                    end
                end
            else
                local rando = rng:RandomInt(3)
                if rando == 1 then
                    pickup.Price = rng:RandomInt(10) + 1
                elseif rando == 2 then
                    pickup.Price = rng:RandomInt(20) + 1
                else
                    pickup.Price = rng:RandomInt(99) + 1
                end
            end
        elseif pickup.Price < 0 then
            if pickup.FrameCount % shufflespeed == 1 then
                if rng:RandomInt(5) == 1 or (rng:RandomInt(5) == 1 and isCrazy) then
                    pickup.Price = devilPrices[math.random(#devilPrices)]
                else
                    local rando = rng:RandomInt(7)
                    if rando <= 1 then
                        --price is 2
                        pickup.Price = -2
                    elseif rando <= 3 then
                        --price involves red
                        pickup.Price = devilPricesRed[rng:RandomInt(#devilPricesRed) + 1]
                    elseif rando == 4 then
                        --price involves soul
                        pickup.Price = devilPricesSoul[rng:RandomInt(#devilPricesSoul) + 1]
                    elseif rando == 5 then
                        --price is purely soul
                        pickup.Price = devilPricesSoulOnly[rng:RandomInt(#devilPricesSoulOnly) + 1]
                    else
                        --price is complete random
                        pickup.Price = devilPrices[rng:RandomInt(#devilPrices) + 1]
                    end
                end
            end
        end
    end
end)