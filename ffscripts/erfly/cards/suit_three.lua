local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.CardNamePickups = {
    ["Clubs"] = 40,
    ["Diamonds"] = 20,
    ["Spades"] = 30,
    ["Hearts"] = 10,
    ["Pentacles"] = 350,
    ["Cups"] = 70,
    }
    mod.UnbiasedPickups = {
        ["Clubs"] = {
            {ID = BombSubType.BOMB_NORMAL,              Unlocked = function() return true end},
            {ID = BombSubType.BOMB_DOUBLEPACK,          Unlocked = function() return true end},
            {ID = BombSubType.BOMB_TROLL,               Unlocked = function() return true end},
            {ID = BombSubType.BOMB_GOLDEN,              Unlocked = function() return mod.AchievementTrackers.GoldenBombsUnlocked end},
            {ID = BombSubType.BOMB_SUPERTROLL,          Unlocked = function() return true end},
            {ID = BombSubType.BOMB_GOLDENTROLL,         Unlocked = function() return true end},
            {ID = FiendFolio.PICKUP.BOMB.COPPER,        Unlocked = function() return true end},
        },
        ["Diamonds"] = {
            {ID = CoinSubType.COIN_PENNY,               Unlocked = function() return true end},
            {ID = CoinSubType.COIN_NICKEL,              Unlocked = function() return true end},
            {ID = CoinSubType.COIN_DIME,                Unlocked = function() return true end},
            {ID = CoinSubType.COIN_DOUBLEPACK,          Unlocked = function() return true end},
            {ID = CoinSubType.COIN_LUCKYPENNY,          Unlocked = function() return mod.AchievementTrackers.LuckyPennyUnlocked end},
            {ID = CoinSubType.COIN_STICKYNICKEL,        Unlocked = function() return mod.AchievementTrackers.StickyNickelUnlocked end},
            {ID = CoinSubType.COIN_GOLDEN,              Unlocked = function() return mod.AchievementTrackers.GoldenPennyUnlocked end},
            {ID = mod.PICKUP.COIN.CURSED,               Unlocked = function() return true end},
            {ID = mod.PICKUP.COIN.HAUNTED,              Unlocked = function() return mod.ACHIEVEMENT.HAUNTED_PENNY:IsUnlocked() end},
            {ID = mod.PICKUP.COIN.HONEY,                Unlocked = function() return mod.AchievementTrackers.CellarUnlocked end},
            {ID = mod.PICKUP.COIN.GOLDENCURSED,         Unlocked = function() return mod.ACHIEVEMENT.GOLDEN_CURSED_PENNY:IsUnlocked() end},
            {ID = mod.PICKUP.COIN.LEGOSTUD,             Unlocked = function() return true end},
        },
        ["Spades"] = {
            {ID = KeySubType.KEY_NORMAL,                Unlocked = function() return true end},
            {ID = KeySubType.KEY_GOLDEN,                Unlocked = function() return true end},
            {ID = KeySubType.KEY_DOUBLEPACK,            Unlocked = function() return true end},
            {ID = KeySubType.KEY_CHARGED,               Unlocked = function() return mod.AchievementTrackers.ChargedKeyUnlocked end},
            {ID = mod.PICKUP.KEY.SPICY_PERM,            Unlocked = function() return true end},
            {ID = mod.PICKUP.KEY.SUPERSPICY_PERM,       Unlocked = function() return true end},
            {ID = mod.PICKUP.KEY.CHARGEDSPICY_PERM,     Unlocked = function() return mod.AchievementTrackers.ChargedKeyUnlocked end},
        },
        ["SpadesBetter"] = {
            {ID = KeySubType.KEY_GOLDEN,                Unlocked = function() return true end},
            {ID = KeySubType.KEY_DOUBLEPACK,            Unlocked = function() return true end},
            {ID = KeySubType.KEY_CHARGED,               Unlocked = function() return mod.AchievementTrackers.ChargedKeyUnlocked end},
            {ID = mod.PICKUP.KEY.SUPERSPICY_PERM,       Unlocked = function() return true end},
            {ID = mod.PICKUP.KEY.CHARGEDSPICY_PERM,     Unlocked = function() return mod.AchievementTrackers.ChargedKeyUnlocked end},
        },
        ["SpadesBest"] = {
            {ID = KeySubType.KEY_GOLDEN,                Unlocked = function() return true end},
            {ID = KeySubType.KEY_DOUBLEPACK,            Unlocked = function() return true end},
            {ID = KeySubType.KEY_CHARGED,               Unlocked = function() return mod.AchievementTrackers.ChargedKeyUnlocked end},
        },
        ["Hearts"] = {
            {ID = HeartSubType.HEART_FULL,              Unlocked = function() return true end},
            {ID = HeartSubType.HEART_HALF,              Unlocked = function() return true end},
            {ID = HeartSubType.HEART_SOUL,              Unlocked = function() return true end},
            {ID = HeartSubType.HEART_ETERNAL,           Unlocked = function() return true end},
            {ID = HeartSubType.HEART_DOUBLEPACK,        Unlocked = function() return true end},
            {ID = HeartSubType.HEART_BLACK,             Unlocked = function() return true end},
            {ID = HeartSubType.HEART_GOLDEN,            Unlocked = function() return mod.AchievementTrackers.GoldenHeartsUnlocked end},
            {ID = HeartSubType.HEART_HALF_SOUL,         Unlocked = function() return mod.AchievementTrackers.HalfSoulHeartsUnlocked end},
            {ID = HeartSubType.HEART_SCARED,            Unlocked = function() return mod.AchievementTrackers.ScaredHeartsUnlocked end},
            {ID = HeartSubType.HEART_BLENDED,           Unlocked = function() return true end},
            {ID = HeartSubType.HEART_BONE,              Unlocked = function() return mod.AchievementTrackers.BoneHeartsUnlocked end},
            {ID = HeartSubType.HEART_ROTTEN,            Unlocked = function() return mod.AchievementTrackers.RottenHeartsUnlocked end},
            {ID = {Var = mod.PICKUP.VARIANT.HALF_BLACK_HEART,       Sub = 0},   Unlocked = function() return true end},
            {ID = {Var = mod.PICKUP.VARIANT.BLENDED_BLACK_HEART,    Sub = 0},   Unlocked = function() return true end},
            {ID = {Var = mod.PICKUP.VARIANT.IMMORAL_HEART,          Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() end},
            {ID = {Var = mod.PICKUP.VARIANT.HALF_IMMORAL_HEART,     Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() end},
            {ID = {Var = mod.PICKUP.VARIANT.BLENDED_IMMORAL_HEART,  Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() end},
            {ID = {Var = mod.PICKUP.VARIANT.MORBID_HEART,           Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() end},
            {ID = {Var = mod.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART, Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() end},
            {ID = {Var = mod.PICKUP.VARIANT.THIRD_MORBID_HEART,     Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() end},
        },
    }
    
    function mod:useThreeCard(card, player, flags)
        local name = string.sub(Isaac.GetItemConfig():GetCard(card).Name, 10)
        local r = player:GetCardRNG(card)
        --print(player.FrameCount)
        local Vec = RandomVector():Resized(40)
        for i = 120, 360, 120 do
            local pickupChoice
            if mod.UnbiasedPickups[name] then
                local dynamicPool = {}
                for _, data in pairs(mod.UnbiasedPickups[name]) do
                    if data.Unlocked() then
                        table.insert(dynamicPool, data.ID)
                    end
                end
                pickupChoice = dynamicPool[r:RandomInt(#dynamicPool) + 1]
            elseif name == "Cups" then
                local coloursNum = mod.AchievementTrackers.GoldenPillsUnlocked and 14 or 13
                pickupChoice = r:RandomInt(coloursNum) + 1
                if r:RandomInt(2) == 1 and mod.AchievementTrackers.HorsePillsUnlocked then
                    pickupChoice = pickupChoice + 2048
                end
            elseif name == "Pentacles" then
                pickupChoice = 0
                FiendFolio.UsedPentacles = true
            end
            local pickup
            if tonumber(pickupChoice) then
                pickup = Isaac.Spawn(5, mod.CardNamePickups[name], pickupChoice, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vec:Rotated(i)), nilvector, player)
            else
                pickup = Isaac.Spawn(5, pickupChoice.Var, pickupChoice.Sub, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vec:Rotated(i)), nilvector, player)
            end
            if name == "Pentacles" and mod.AchievementTrackers.GoldenTrinketsUnlocked then
                pickup = pickup:ToPickup()
                if r:RandomInt(2) == 1 then
                    pickup:Morph(5, 350, pickup.SubType + 32768, false)
                end
            end
        end
        if name == "Clubs" then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeClubs, flags, 40)
        elseif name == "Cups" then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeCups, flags, 40)
        elseif name == "Diamonds" then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeDiamonds, flags, 40)
        elseif name == "Hearts" then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeHearts, flags, 40)
        elseif name == "Pentacles" then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreePentacles, flags, 40)
        elseif name == "Spades" then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeSpades, flags, 40)
        end
    end
    
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeCard, Card.THREE_OF_CLUBS)
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeCard, Card.THREE_OF_DIAMOND)
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeCard, Card.THREE_OF_SPADES)
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeCard, Card.THREE_OF_HEARTS)
    
    --For tomorrow you, maybe don't automate, not quite as simple
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeCard, Card.THREE_OF_PENTACLES)
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeCard, Card.THREE_OF_CUPS)
    
    mod.threeSwordsFams = {
        43, 73, 201, 228, mod.ITEM.FAMILIAR.ATTACK_SKUZZ, mod.ITEM.FAMILIAR.FRAGILE_BOBBY
    }
    mod.threeSwordsPoops = {
        0, 1, 2, 3, 4, 5, 6, 12, 13, 14, 20, 666, 667, 668, 669, 670, 671, 672
    }
    
    function mod:useThreeSwords(card, player, flags)
        local r = player:GetCardRNG(card)
        local Vec = RandomVector():Resized(40)
        for i = 120, 360, 120 do
            local choiceVar = mod.threeSwordsFams[r:RandomInt(#mod.threeSwordsFams) + 1]
            local choiceSub = 0
    
            if choiceVar == 43 then
                choiceSub = r:RandomInt(6)
            elseif choiceVar == 201 then
                choiceSub = mod.threeSwordsPoops[r:RandomInt(#mod.threeSwordsPoops) + 1]
            elseif choiceVar == 1026 then
                choiceSub = r:RandomInt(5)
            end
            local pickup = Isaac.Spawn(3, choiceVar, choiceSub, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vec:Rotated(i)), nilvector, player)
        end
        FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingThreeSwords, flags, 40)
    end
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useThreeSwords, Card.THREE_OF_SWORDS)
    