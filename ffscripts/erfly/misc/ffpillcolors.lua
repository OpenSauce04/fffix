local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--ONLY REGULAR COLOURS
--This is not for specil pills like cyanide
mod.FFPillColours = {
    --Normal
    101,102,103,104,105,106,107,108,109,110,
    111,112,113,114,115,116,117,118,119,120,
    --Horse
    2149,2150,2151,2152,2153,2154,2155,2156,2157,2158,
    2159,2160,2161,2162,2163,2164,2165,2166,2167,2168
}
--Just lets you pass isFFPill[101] or somethin to test it
local isFFPill = {}
do
    for i = 1, #mod.FFPillColours do
        isFFPill[mod.FFPillColours[i]] = true
    end
end

mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, function(_, pillEffect, pillColor)
    --print("ya")
    if isFFPill[pillColor] then
        local pillRegulise = pillColor % 2048

        local pillreplaced = 1
        if FiendFolio.savedata.run.PillCopies and FiendFolio.savedata.run.PillCopies[tostring(pillRegulise)] then
            pillreplaced = FiendFolio.savedata.run.PillCopies[tostring(pillRegulise)]
            --print(pillreplaced)
        end
        --[[local string = ""
        for i = 1, #mod.FFPillColours do
            if FiendFolio.savedata.run.PillCopies[tostring(mod.FFPillColours[i])] then
                string = string .. "{" .. mod.FFPillColours[i] .. ":" .. FiendFolio.savedata.run.PillCopies[tostring(mod.FFPillColours[i])] .. "}, "
            end
        end
        print(string)]]

        FiendFolio.savedata.run.IdentifiedRunPills = FiendFolio.savedata.run.IdentifiedRunPills or {}
        local itempool = game:GetItemPool()

        if itempool:IsPillIdentified(pillreplaced) then
            if not FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)] then
                FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)] = true
            end
        end

        local phdp = mod.phdPlayer()
        local fphdp = mod.falsephdPlayer()
        local gpp = mod.goodPillPlayer()
        if (phdp or (gpp and FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)])) and fphdp then
            FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)] = true
            if not itempool:IsPillIdentified(pillreplaced) then
                itempool:IdentifyPill(pillreplaced)
            end
            local effect = itempool:GetPillEffect(pillreplaced, Isaac.GetPlayer())
            if effect == mod.ITEM.PILL.FF_UNIDENTIFIED then
                effect = PillEffect.PILLEFFECT_SPIDER_UNBOXING
            end
            return effect
        elseif phdp or fphdp or (gpp and FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)]) then
            FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)] = true
            if not itempool:IsPillIdentified(pillreplaced) then
                itempool:IdentifyPill(pillreplaced)
            end
            local effect = itempool:GetPillEffect(pillreplaced, phdp or gpp or fphdp)
            if effect == mod.ITEM.PILL.FF_UNIDENTIFIED then
                effect = PillEffect.PILLEFFECT_SPIDER_UNBOXING
            end
            return effect
        else
            if FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillRegulise)] then
                local effect = itempool:GetPillEffect(pillreplaced, Isaac.GetPlayer())
                if effect == mod.ITEM.PILL.FF_UNIDENTIFIED then
                    effect = PillEffect.PILLEFFECT_SPIDER_UNBOXING
                end
                return effect
            else
                return mod.ITEM.PILL.FF_UNIDENTIFIED
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, function(_, pillEffect, pillColor)
    if pillColor % 2048 < 100 and pillEffect == mod.ITEM.PILL.FF_UNIDENTIFIED then
        return PillEffect.PILLEFFECT_I_FOUND_PILLS
    end
end)

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, pillEffect, player, flags)
    --Freaking safety checks man, still breaks with echo chamber ig BUT OH FREAKING WELL
    Isaac.DebugString("INITIAL PILL IDENTIFICATION FAILED, USING BACKUP")
    local pill = player:GetPill(0)
    pill = pill % 2048
    FiendFolio.savedata.run.IdentifiedRunPills = FiendFolio.savedata.run.IdentifiedRunPills or {}
    if not FiendFolio.savedata.run.IdentifiedRunPills[tostring(pill)] then
        FiendFolio.savedata.run.IdentifiedRunPills[tostring(pill)] = true
    end

    local pillreplaced = 1
    if FiendFolio.savedata.run.PillCopies and FiendFolio.savedata.run.PillCopies[tostring(pill)] then
        pillreplaced = FiendFolio.savedata.run.PillCopies[tostring(pill)]
    end

    local itempool = Game():GetItemPool()
    local usedEffect = itempool:GetPillEffect(pillreplaced, player)
    player:UsePill(usedEffect, pill)
end, mod.ITEM.PILL.FF_UNIDENTIFIED)

--[[local pillEID = {
    {"en_us", "Unidentified Pill"},

    {"cs_cz", "Neznámá Pilulka"},
    {"de", "Unidentifizierte Pille"},
    {"en_us_detailed", "Unidentified Pill"},
    {"fr", "Pilule non identifiée"},
    {"it", "Pillola non identificata"},
    {"ja_jp", "未識別のピル"},
    {"ko_kr", "확인되지 않은 알약"},
    {"pl", "Nieznana Pigułka"},
    {"pt", "Comprimido não identificado"},
    {"pt_br", "Pílula não identificada"},
    {"ru", "Неизвестная пилюля"},
    {"spa", "Píldora sin identificar"},
    {"tr_tr", "Tanımlanmamış Hap"},
    {"zh_cn", "不明胶囊"},
}]]

--Sorry wofsauge
--if EID then
--    for k = 1, #pillEID do
--        for i = 1, #EID.descriptions[pillEID[k][1]].pills do
--            if EID.descriptions[pillEID[k][1]].pills[i][1] == "31" then
--                EID.descriptions[pillEID[k][1]].pills[i] = {"31", pillEID[k][2], ""}
--            end
--        end
--    end
--end

if EID then
    if tonumber(EID.ModVersion) then
        local ver = tonumber(EID.ModVersion)
        if ver >= 4.35 then
            EID:SetPillEffectUnidentifyable(mod.ITEM.PILL.FF_UNIDENTIFIED, true)
        end
    end
end

function mod:pillShitPlayer(player, data)
    if data.FFPillShitWaitedOneFrame then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_PHD) or player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
            if not data.donePillFullIdentification then
                for i = 1, #mod.FFPillColours do
                    FiendFolio.savedata.run.IdentifiedRunPills = FiendFolio.savedata.run.IdentifiedRunPills or {}
                    FiendFolio.savedata.run.IdentifiedRunPills[tostring(mod.FFPillColours[i])] = true
                end
                data.donePillFullIdentification = true
            end
        end
        if FiendFolio.savedata and FiendFolio.savedata.run and FiendFolio.savedata.run.PillBeingReplaced then
            for i = 0, 1 do
                local pill = player:GetPill(i)
                if FiendFolio.savedata.run.PillBeingReplaced[tostring(pill % 2048)] then
                    if pill >= 2048 then
                        player:SetPill(i, FiendFolio.savedata.run.PillBeingReplaced[tostring(pill % 2048)] + 2048)
                    else
                        player:SetPill(i, FiendFolio.savedata.run.PillBeingReplaced[tostring(pill)])
                    end
                end
                mod:cyanidePillSet(player, pill, i, data)
            end
        end
    else
        data.FFPillShitWaitedOneFrame = true
    end
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, ent, hook, action)
    if hook == InputHook.IS_ACTION_TRIGGERED and (action == ButtonAction.ACTION_ITEM or action == ButtonAction.ACTION_PILLCARD) then
        if ent and action then
            local player = ent:ToPlayer()
            if player and player:GetPill(0) > 0 then
                if player.ControlsEnabled and player.ControlsCooldown == 0 and (not player:IsHoldingItem()) then
                    --print("yes")
                    local usingPill = false
                    if (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_PLACEBO) then
                        usingPill = true
                    elseif player:GetPlayerType() == PlayerType.PLAYER_JACOB then
                        if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
                            usingPill = true
                        end
                    elseif player:GetPlayerType() == PlayerType.PLAYER_ESAU then
                        if Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
                            usingPill = true
                        end
                    else
                        if Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) then
                            usingPill = true
                        end
                    end

                    if usingPill then
                        --print("identify")
                        local pill = player:GetPill(0)
                        pill = pill % 2048
                        FiendFolio.savedata.run.IdentifiedRunPills = FiendFolio.savedata.run.IdentifiedRunPills or {}
                        if not FiendFolio.savedata.run.IdentifiedRunPills[tostring(pill)] then
                            FiendFolio.savedata.run.IdentifiedRunPills[tostring(pill)] = true
                        end
                    end
                else
                    --print("no")
                end
            end
        end
    end
end)

function mod:newGamePillShit(continuing)
    game = Game()
    if not continuing then
        --local itempool = game:GetItemPool()
        --for i = 1, #mod.FFPillColours do
            --Unidentify them
            --There is literally no function for this wtf
            --See FiendFolio.savedata.run.IdentifiedRunPills
        --end
        local doDebug = false

        --Choose pills for a run
        local PillChoices = {
            --Vanilla pills
            1,2,3,4,5,6,7,8,9,10,11,12,13,
        }
        --Sub in the FF Pills using the table at the top of this file
        --Naturally ignores horse pills
        for i = 1, #mod.FFPillColours do
            if mod.FFPillColours[i] < 2048 then
                table.insert(PillChoices, mod.FFPillColours[i])
            end
        end
        --This is for helping determining which pills the fake colours will replace
        local PillsAvailableToReplace = {
            1,2,3,4,5,6,7,8,9,10,11,12,13
        }
        FiendFolio.savedata.run.RunPills = {}
        FiendFolio.savedata.run.IdentifiedRunPills = {}
        local rng = RNG()
        rng:SetSeed(game:GetSeeds():GetStartSeed(),0)
        --print("seeds")
        for i = 1, 13 do
            local rand = rng:RandomInt(#PillChoices) + 1
            local choice = PillChoices[rand]
            table.remove(PillChoices, rand)
            for j = 1, #PillsAvailableToReplace do
                if PillsAvailableToReplace[j] == choice then
                    table.remove(PillsAvailableToReplace, j)
                    break
                end
            end
            if doDebug then
                print(choice)
            end
            table.insert(FiendFolio.savedata.run.RunPills, choice)
        end
        if doDebug then
            --Testing if this works alright
            local string = ""
            for i = 1, #PillsAvailableToReplace do
                string = string .. PillsAvailableToReplace[i] .. ", "
            end
            print(string)
        end
        FiendFolio.savedata.run.PillCopies = {}
        FiendFolio.savedata.run.PillBeingReplaced = {}
        for i = 1, #FiendFolio.savedata.run.RunPills do
            if isFFPill[FiendFolio.savedata.run.RunPills[i]] then
                local pillReplacement = rng:RandomInt(#PillsAvailableToReplace) + 1
                FiendFolio.savedata.run.PillCopies[tostring(FiendFolio.savedata.run.RunPills[i])] = PillsAvailableToReplace[pillReplacement]
                FiendFolio.savedata.run.PillBeingReplaced[tostring(PillsAvailableToReplace[pillReplacement])] = FiendFolio.savedata.run.RunPills[i]
                table.remove(PillsAvailableToReplace, pillReplacement)
            end
        end
        if doDebug then
            local string = ""
            for i = 1, #FiendFolio.savedata.run.RunPills do
                string = string .. FiendFolio.savedata.run.RunPills[i] .. ", "
            end
            print(string)
        end
        local itempool = game:GetItemPool()
        for i = 1, #mod.FFPillColours do
            if not itempool:IsPillIdentified(mod.FFPillColours[i]) then
                itempool:IdentifyPill(mod.FFPillColours[i])
            end
        end
        FiendFolio.SaveSaveData()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    local pickupIsHorse
    local pillColor = pickup.SubType
    if FiendFolio.savedata.run.PillBeingReplaced[tostring(pillColor % 2048)] then
        if pillColor > 2048 then
            pickup:Morph(5,70,FiendFolio.savedata.run.PillBeingReplaced[tostring(pillColor % 2048)] + 2048, true, true)
        else
            pickup:Morph(5,70,FiendFolio.savedata.run.PillBeingReplaced[tostring(pillColor % 2048)], true, true)
        end
    end
end, PickupVariant.PICKUP_PILL)