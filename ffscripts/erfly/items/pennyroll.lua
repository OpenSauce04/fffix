local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.PennyRollSpawns = {
    Pennies = {
        --Default
        {ID = CoinSubType.COIN_PENNY,        Unlocked = function() return true end},
        {ID = CoinSubType.COIN_LUCKYPENNY,   Unlocked = function() return mod.AchievementTrackers.LuckyPennyUnlocked end},
        
        --FF
        {ID = mod.PICKUP.COIN.CURSED,        Unlocked = function() return true end},
        {ID = mod.PICKUP.COIN.HAUNTED,       Unlocked = function() return mod.ACHIEVEMENT.HAUNTED_PENNY:IsUnlocked() end},
        {ID = mod.PICKUP.COIN.HONEY,         Unlocked = function() return mod.AchievementTrackers.CellarUnlocked end},
        
    },
    GoldenPennies = {
        {ID = CoinSubType.COIN_GOLDEN,       Unlocked = function() return mod.AchievementTrackers.GoldenPennyUnlocked end},
        {ID = mod.PICKUP.COIN.GOLDENCURSED,  Unlocked = function() return mod.ACHIEVEMENT.GOLDEN_CURSED_PENNY:IsUnlocked() end},
    }
}

local function getPennyDropPool(golden)
    local returnVar = {}
    local loopTable = golden and mod.PennyRollSpawns.GoldenPennies or mod.PennyRollSpawns.Pennies
    for _, data in pairs(loopTable) do
        if data.Unlocked() then
            table.insert(returnVar, data.ID)
        end
    end
    return returnVar
end

FiendFolio.AddItemPickupCallback(function(player, added)
	local r = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.PENNY_ROLL)
    local room = Game():GetRoom()
    local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position + RandomVector() * 20)), 20)
    local trinket = mod.ITEM.ROCK.ORE_PENNY
    if not mod.GolemExists() then
        trinket = mod.GetItemFromCustomItemPool(mod.CustomPool.PENNY_TRINKETS, r)
    end
    Isaac.Spawn(5, 350, trinket, spawnpos + RandomVector()*math.random(20), nilvector, nil)
	local pennyChoiceTable = getPennyDropPool()
    local goldenChoiceTable = getPennyDropPool(true)
    for i = 1, 5 do
		mod.scheduleForUpdate(function()
			local room = Game():GetRoom()
			local spawnpos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(player.Position + RandomVector() * 50)), 20)
			
            
            if i == 1 and #goldenChoiceTable > 0 then
                local choice = goldenChoiceTable[r:RandomInt(#goldenChoiceTable) + 1]
                Isaac.Spawn(5, 20, choice, spawnpos + RandomVector()*math.random(20), nilvector, nil)
            else
                local rand = r:RandomInt(#pennyChoiceTable) + 1
                local choice = pennyChoiceTable[rand]
                Isaac.Spawn(5, 20, choice, spawnpos + RandomVector()*math.random(20), nilvector, nil)
                table.remove(pennyChoiceTable, rand)
                if #pennyChoiceTable == 0 then
                    pennyChoiceTable = getPennyDropPool()
                end
            end
		end, i)
	end
end, nil, mod.ITEM.COLLECTIBLE.PENNY_ROLL)