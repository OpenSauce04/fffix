local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local direChestFortunes = include("ffscripts.erfly.misc.fortunes_direchest")
local direChestFortuneRNG = RNG()
direChestFortuneRNG:SetSeed(Isaac.GetTime(), 35)

local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
end

local function fortuneArray(array)
    game:GetHUD():ShowFortuneText(
        array[1], 
        array[2] or nil, 
        array[3] or nil, 
        array[4] or nil, 
        array[5] or nil, 
        array[6] or nil, 
        array[7] or nil, 
        array[8] or nil, 
        array[9] or nil, 
        array[10] or nil
    )
end

function mod:ShowFortune(forcedtune, noDireChest)
    if forcedtune then
        local fortune = split(forcedtune, "\n")
        fortuneArray(fortune)
    else
        if not mod.ACHIEVEMENT.DIRE_CHEST:IsUnlocked() and not noDireChest and direChestFortuneRNG:RandomFloat() < 1/5 then
            fortuneArray(direChestFortunes[direChestFortuneRNG:RandomInt(#direChestFortunes) + 1])
        else
            if FiendFolio.CustomFortunesEnabled then
                mod.FortuneTable = mod.FortuneTable or {}
                if #mod.FortuneTable <= 1 then
                    local fortunelist = mod.FFFortunes
                    local fortunetablesetup = split(mod.FFFortunes, "\n\n")
                    for i = 1, #fortunetablesetup do
                        table.insert(mod.FortuneTable, split(fortunetablesetup[i], "\n"))
                    end
                    --print("Fiend Folio has exactly " .. #mod.FortuneTable .. " fortunes at your disposal")
                end
                local choice = math.random(#mod.FortuneTable)
                local fortune = mod.FortuneTable[choice]
                fortuneArray(fortune)
            else
                game:ShowFortune()
            end
        end
    end
end

local specialSeeds = {
    "BOOB TOOB",
    "BRWN SNKE",
    "B911 TCZL",
    "CAMO K1DD",
    "CAMO DROP",
    "CHAM P1ON",
    "CLST RPHO",
    "COCK FGHT",
    "COME BACK",
    "CONF ETTI",
    "DONT STOP",
    "DRAW KCAB",
    "DYSL EX1A",
    "FACE DOWN",
    "FART SNDS",
    "FREE 2PAY",
    "IMNO BODY",
    "GGGG GGGG",
    "HART BEAT",
    "ISAA AACE",
    "KEEP AWAY",
    "NICA LISY",
    "PAC1 F1SM",
    "SLOW 4ME2",
    "TARO TARJ",
    "THEG HOST",
    "XXXX XXZX",
    "8AJJ AASE",
    "BLCK CNDL",
    "M0DE SEVN",
}

function mod:ShowRule()
    if math.random(25) == 1 then
        mod:ShowFortune(specialSeeds[math.random(#specialSeeds)])
    else
        mod.FortuneTableRules = mod.FortuneTableRules or {}
        if #mod.FortuneTableRules <= 1 then
            local fortunelist = mod.FFFortunesRules
            local fortunetablesetup = split(mod.FFFortunesRules, "\n\n")
            for i = 1, #fortunetablesetup do
                table.insert(mod.FortuneTableRules, split(fortunetablesetup[i], "\n"))
            end
            --print("Fiend Folio has exactly " .. #mod.FortuneTable .. " rules at your disposal")
        end
        local choice = math.random(#mod.FortuneTableRules)
        local fortune = mod.FortuneTableRules[choice]
        fortuneArray(fortune)
    end
end

function mod:fortuneCommand(cmd, params)
    if #params > 0 then
        mod:ShowFortune(params, true)
    else
        --I'm really sorry for the formatting
        local string = 
[======[

]======]
        string = nil
        mod:ShowFortune(string, true)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, player)
    local pickupFound
    for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
        if pickup and pickup.Type == 5 and pickup.FrameCount <= 0 then
            pickupFound = true
        end
    end
    if not pickupFound then
        mod:ShowFortune()
    end
end, CollectibleType.COLLECTIBLE_FORTUNE_COOKIE)

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
    if sprite:IsPlaying("Prize") then
        if sprite:GetFrame() == 4 then
            local pickupFound
            for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
                if pickup and pickup.Type == 5 and pickup.FrameCount <= 0 then
                    pickupFound = true
                end
            end
            if not pickupFound then
                mod:ShowFortune()
            end
        end
    end
end, 3)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, player)
    mod:ShowRule()
end, Card.CARD_RULES)