local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local goldenPools = {
    Normal = {
        {ID = {Type = 5, Var = 30, Sub = 2},    Unlocked = function() return true end},
        {ID = {Type = 5, Var = 40, Sub = 4},    Unlocked = function() return mod.AchievementTrackers.GoldenBombsUnlocked    end},
        {ID = {Type = 5, Var = 10, Sub = 7},    Unlocked = function() return mod.AchievementTrackers.GoldenHeartsUnlocked   end},
        {ID = {Type = 5, Var = 20, Sub = 7},    Unlocked = function() return mod.AchievementTrackers.GoldenPennyUnlocked    end},
        {ID = {Type = 5, Var = 70, Sub = 14},   Unlocked = function() return mod.AchievementTrackers.GoldenPillsUnlocked    end},
        {ID = {Type = 5, Var = 90, Sub = 4},    Unlocked = function() return mod.AchievementTrackers.GoldenBatteryUnlocked  end},
    },
    Rare = {
        {ID = {Type = 4, Var = 18, Sub = 0},    Unlocked = function() return true end},
        {ID = {Type = 5, Var = 350, Sub = 0},   Unlocked = function() return mod.AchievementTrackers.GoldenTrinketsUnlocked end}
    },
}

mod.AddItemPickupCallback(function(player, added)
    local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
    local typ, var, sub = 5, 30, 2

    local r = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.GOLDEN_POPSICLE)

    local goldenPool = {}
    local poolCheck = "Normal"
    if r:RandomInt(100) == 0 then
        poolCheck = "Rare"
    end

    for _, data in pairs(goldenPools[poolCheck]) do
        if data.Unlocked() then
            table.insert(goldenPool, data.ID)
        end
    end

    local choice = goldenPool[math.floor(r:RandomInt(#goldenPool)) + 1]
    typ, var, sub = choice.Type, choice.Var, choice.Sub

    if var == 350 then  --Fucking trinkets dude
        if FiendFolio.GolemExists() then --Bastard
            sub = mod.GetGolemTrinket() % 32768
            --I mean I had to make sure it worked properly
            --without this little check it could reroll into a golden penny lol
            --not an actual golden penny, but a regular penny with the shader
        end
    end

    local pickup = Isaac.Spawn(typ, var, sub, pos, nilvector, player):ToPickup()
    if var == 350 then --Fuuuuuuuuuuuuuuucking trinkets DUDE
        pickup:Morph(5, 350, pickup.SubType + 32768, false)
    end
end, nil, mod.ITEM.COLLECTIBLE.GOLDEN_POPSICLE)