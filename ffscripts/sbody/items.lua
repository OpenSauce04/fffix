local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

function mod:getNextAzuriteID(id)
    local extraCheck = ffAzuriteSpindownList[id]
    id = id-1
    while ffAzuriteSpindownList[id] do
        id = id-1
    end
    if extraCheck and type(extraCheck) == "table" then
        while extraCheck[id] do
            id = id-1
        end
    end
    while FiendFolio.IsTrinketLocked(id) do
        id = id-1
    end
    return id
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, useflags, activeslot, customvardata)
    local trinkets = Isaac.FindByType(5, 350, -1, false, false)
    for _, t in ipairs(trinkets) do
        t = t:ToPickup()
        
        if not t:GetData().AzuriteSpin then t:GetData().AzuriteSpin = 0 end     --Car battery stinky
        t:GetData().AzuriteSpin = t:GetData().AzuriteSpin + 1

        if t:GetData().AzuriteSpin == 1 then            --Car battery check
            local sprite = t:GetSprite()
            sprite:Load("gfx/effects/trinket_destroy.anm2", false)
            sprite:Play("Destroy", true)
            local sPath = Isaac.GetItemConfig():GetTrinket(t.SubType).GfxFileName
            for i=0, 62 do
                sprite:ReplaceSpritesheet(i, sPath)
            end
            sprite:LoadGraphics()
            sfx:Play(496, 0.25, 0, false, 0.8, 0)
            local fadeT = 8
            if t.SubType > 32768 then
                for i=1, fadeT do
                    mod.scheduleForUpdate(function()
                        if t:Exists() then
                            local bColor = Color(24/255*1.5, 34/255*1.5, 109/255*1.5, 1, 24/255, 34/255, 109/255)
                            local color = Color.Lerp(Color(1,1,1,1,0,0,0), bColor, i/fadeT)
                            local sprite = t:GetSprite()
                            sprite.Color = color
                        end
                    end, i)
                end
            else
                for i=1, fadeT do
                    mod.scheduleForUpdate(function()
                        if t:Exists() then
                            local bColor = Color(24/255, 34/255, 109/255, 1, 24/255*0.75, 34/255*0.75, 109/255*0.75)
                            local color = Color.Lerp(Color(1,1,1,1,0,0,0), bColor, i/fadeT)
                            color:SetColorize(24/255*15, 34/255*15, 109/255*15, i/fadeT)
                            local sprite = t:GetSprite()
                            sprite.Color = color
                        end
                    end, i)
                end
            end

            mod.scheduleForUpdate(function()
                if t:Exists() then
                    local id = (t.SubType % 32768)
                    for i=1, t:GetData().AzuriteSpin do
                        id = mod:getNextAzuriteID(id)
                    end
                    if id == FiendFolio.ITEM.ROCK.UNOBTAINIUM then id=id-1 end
                    if id <= 0 then                                                         --vanish
                        local p = Isaac.Spawn(1000, 15, 0, t.Position, Vector(0,0), t)
                        p:GetSprite():Play("Poof_Small", true)
                        t:Remove()
                    else                                                                    --reroll
                        local price = t.Price
                        t:Morph(5, 350, math.floor(t.SubType/32768)*32768+id, false)
                        t:GetData().fromAzurite = true
                        local vel = t.Velocity
                        t.Velocity = Vector(0,0)
                        for i=1, 24 do
                            t:Update()
                        end
                        t.Velocity = vel
                        t.Price = price
                    end
                    
                    local pColor = Color(24/255*1.5, 34/255*1.5, 109/255*1.5, 0.8, 24/255, 34/255, 109/255)         --particles
                    for i=1, 6 do
                        local vel = RandomVector()*math.random()*2
                        vel.Y = vel.Y/2
                        local p = Isaac.Spawn(1000, 35, 0, t.Position, vel, t):ToEffect()
                        local sprite = p:GetSprite()
                        sprite.Color = pColor
                    end
                    for i=1, 3 do                                           --sparks
                        local vel = RandomVector()*(math.random()+0.5)
                        vel.X = vel.X*1.5
                        local p = Isaac.Spawn(1000, 1727, 0, t.Position+vel*5, vel+Vector(0,-1.5), t):ToEffect()
                        --p:GetSprite().Scale = Vector(0.75,0.75)
                        p:SetColor(Color(1,1,1,1,1,1,1), 0, 0, false, false)
                        p.PositionOffset = Vector(0, -16)
                    end
                    sfx:Play(498, 1, 0, false, 1.1, 0)
                end
            end, fadeT+2)

            mod.scheduleForUpdate(function()
                if sfx:IsPlaying(249) then sfx:Stop(249) end
            end, fadeT+4)
        end
    end
    return true
end, Isaac.GetItemIdByName("Azurite Spindown"))

function ffBlacklistAzurite(t)
    --for _, id in ipairs(t) do
    --  ffAzuriteSpindownList[id] = true        
    for k, n in pairs(t) do
        ffAzuriteSpindownList[k] = n
    end
end

local AzuriteSpidownId = FiendFolio.ITEM.COLLECTIBLE.AZURITE_SPINDOWN
local GlassAzuriteId = FiendFolio.ITEM.CARD.GLASS_AZURITE_SPINDOWN

local function hasPerfectlyGenericObject(playerId)
    local itemIds = {
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8,
        FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12,
    }
    local player = Isaac.GetPlayer(playerId)
    for i=1, #itemIds do
        if player:HasCollectible(itemIds[i]) or (EID.absorbedItems[tostring(playerId)] and EID.absorbedItems[tostring(playerId)][tostring(itemIds[i])]) then
            return true
        end
    end
    return false
end

FiendFolio.AddItemPickupCallback(function(player, added)
    local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
    if player:GetPlayerType() == PlayerType.PLAYER_GOLEM then
        local trinket = FiendFolio.GetMostRecentTrinket(player)
        Isaac.Spawn(5, 350, FiendFolio.GetNextMiningMachineTrinket(trinket, player), player.Position, Vector(0,0), player)
    else
        Isaac.Spawn(5, 350, 0, pos, Vector(0,0), player)
    end
end, nil, AzuriteSpidownId)

-- EID - TRINKET TAB PREVIEW

local function TrinketTabCallback(descObj)
	if EID.TabPreviewID == 0 then return descObj end
	EID.TabDescThisFrame = true
	
	EID.inModifierPreview = true
	local descEntry = EID:getDescriptionObj(5, 350, EID.TabPreviewID)
	EID.inModifierPreview = false
	descEntry.Entity = descObj.Entity
	EID.TabPreviewID = 0
	return descEntry
end

local function TrinketTabConditions(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 350 and EID:PlayersActionPressed(EID.Config["BagOfCraftingToggleKey"]) and not EID.inModifierPreview then
        local numPlayers = game:GetNumPlayers()
        for i = 0, numPlayers - 1 do
            if Isaac.GetPlayer(i):HasCollectible(AzuriteSpidownId) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(AzuriteSpidownId)]) or Isaac.GetPlayer(i):GetCard(0) == GlassAzuriteId then
                return true
            end
        end
    end
	EID.TabPreviewID = 0
	return false
end

-- EID - AZURITE SPINDOWN

local function azuriteSpindownModifierCondition(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 350 then
        local numPlayers = game:GetNumPlayers()
        for i = 0, numPlayers - 1 do
            if Isaac.GetPlayer(i):HasCollectible(AzuriteSpidownId) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(AzuriteSpidownId)]) or Isaac.GetPlayer(i):GetCard(0) == GlassAzuriteId then
                return true
            end
        end
    end
end

local function azuriteSpindownModifierCallback(descObj)
    local playerID, icon, hasCarBattery
    local numPlayers = game:GetNumPlayers()

    -- items check
    for i = 0, numPlayers - 1 do
        if Isaac.GetPlayer(i):HasCollectible(AzuriteSpidownId) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(AzuriteSpidownId)]) then
            playerID = i
            icon = "#{{Collectible" .. AzuriteSpidownId .. "}} :"
            break
        end
        if hasPerfectlyGenericObject(i) and Isaac.GetPlayer(i):GetCard(0) == GlassAzuriteId then
            playerID = i
            icon = "#{{Collectible" .. FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1 .. "}} :"
            break
        end
    end
    if playerID then
        EID:appendToDescription(descObj, icon)
        local refID = descObj.ObjSubType
        hasCarBattery = Isaac.GetPlayer(playerID):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
        local firstID = 0
        for i = 1,EID.Config["SpindownDiceResults"] do
            local spinnedID = mod:getNextAzuriteID(refID)
            if hasCarBattery then
                refID = spinnedID
                spinnedID = mod:getNextAzuriteID(refID)
            end
            refID = spinnedID
            if refID > 0 and refID < 4294960000 then
                if i == 1 then firstID = refID end
                EID:appendToDescription(descObj, "{{Trinket"..refID.."}}")
                --if EID.itemUnlockStates[refID] == false then EID:appendToDescription(descObj, "?") end
                if EID.Config["SpindownDiceDisplayID"] then
                    EID:appendToDescription(descObj, "/".. refID)
                end
                if EID.Config["SpindownDiceDisplayName"] then
                    EID:appendToDescription(descObj, "/".. EID:getObjectName(5, 350, refID))
                    if i ~= EID.Config["SpindownDiceResults"] then
                        EID:appendToDescription(descObj, "#{{Blank}}")
                    end
                end

                if i ~= EID.Config["SpindownDiceResults"] then
                    EID:appendToDescription(descObj, " ->")
                end
            else
                --todo
                --local errorMsg = EID:getDescriptionEntry("spindownError") or ""
                local errorMsg = "Trinket disappears"
                EID:appendToDescription(descObj, errorMsg)
                break
            end
        end
        if hasCarBattery then
            EID:appendToDescription(descObj, " (Results with {{Collectible356}})")
        end
        if firstID ~= 0 and EID.TabPreviewID == 0 then
            EID.TabPreviewID = firstID
            if not EID.inModifierPreview then EID:appendToDescription(descObj, "#{{Blank}} " .. EID:getDescriptionEntry("FlipItemToggleInfo")) end
        end
    end
    
    -- glass check
    if playerID and not hasCarBattery then return descObj end
    playerID = nil
    for i = 0, numPlayers - 1 do
        if Isaac.GetPlayer(i):GetCard(0) == GlassAzuriteId then
            playerID = i
            break
        end
    end
    if not playerID then return descObj end

    EID:appendToDescription(descObj, "#{{Card" .. GlassAzuriteId .. "}} :")
    local refID = descObj.ObjSubType
    local firstID = 0
    EID.TabPreviewID = 0
    for i = 1,EID.Config["SpindownDiceResults"] do
        local spinnedID = mod:getNextAzuriteID(refID)
        refID = spinnedID
        if refID > 0 and refID < 4294960000 then
            if i == 1 then firstID = refID end
            EID:appendToDescription(descObj, "{{Trinket"..refID.."}}")
            --if EID.itemUnlockStates[refID] == false then EID:appendToDescription(descObj, "?") end
            if EID.Config["SpindownDiceDisplayID"] then
                EID:appendToDescription(descObj, "/".. refID)
            end
            if EID.Config["SpindownDiceDisplayName"] then
                EID:appendToDescription(descObj, "/".. EID:getObjectName(5, 350, refID))
                if i ~= EID.Config["SpindownDiceResults"] then
                    EID:appendToDescription(descObj, "#{{Blank}}")
                end
            end

            if i ~= EID.Config["SpindownDiceResults"] then
                EID:appendToDescription(descObj, " ->")
            end
        else
            --todo
            --local errorMsg = EID:getDescriptionEntry("spindownError") or ""
            local errorMsg = "Trinket disappears"
            EID:appendToDescription(descObj, errorMsg)
            break
        end
    end
    if firstID ~= 0 and EID.TabPreviewID == 0 then
        EID.TabPreviewID = firstID
        if not EID.inModifierPreview then EID:appendToDescription(descObj, "#{{Blank}} " .. EID:getDescriptionEntry("FlipItemToggleInfo")) end
    end
    return descObj
end

-- EID - GLASS SPINDOWN

local function TabCallback(descObj)
	if EID.TabPreviewID == 0 then return descObj end
	EID.TabDescThisFrame = true
	
	EID.inModifierPreview = true
	local descEntry = EID:getDescriptionObj(5, 100, EID.TabPreviewID)
	EID.inModifierPreview = false
	descEntry.Entity = descObj.Entity
	EID.TabPreviewID = 0
	return descEntry
end

local function TabConditions(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 and EID:PlayersActionPressed(EID.Config["BagOfCraftingToggleKey"]) and not EID.inModifierPreview then
        local numPlayers = game:GetNumPlayers()
        for i = 0, numPlayers - 1 do
            if Isaac.GetPlayer(i):GetCard(0) == FiendFolio.ITEM.CARD.GLASS_SPINDOWN
            and not ((Isaac.GetPlayer(i):HasCollectible(723) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(723)])))
            --and Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) 
            then
                return true
            end
        end
    end
	EID.TabPreviewID = 0
	return false
end

local function glassSpindownModifierCondition(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 then
        local numPlayers = game:GetNumPlayers()
        for i = 0, numPlayers - 1 do
            if Isaac.GetPlayer(i):GetCard(0) == FiendFolio.ITEM.CARD.GLASS_SPINDOWN then
                return true
            end
        end
    end
end

local function glassSpindownModifierCallback(descObj)
    if descObj.ObjSubType == 668 then return descObj end
    local numPlayers = game:GetNumPlayers()

    for i = 0, numPlayers - 1 do
        if (Isaac.GetPlayer(i):HasCollectible(723) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(723)])) then
            if EID.inModifierPreview and Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)  then
                return descObj
            elseif not Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)  then
                return descObj
            end
        end
    end
    EID:appendToDescription(descObj, "#{{Card" .. FiendFolio.ITEM.CARD.GLASS_SPINDOWN .. "}} :")
    local refID = descObj.ObjSubType
    --local hasCarBattery = Isaac.GetPlayer(playerID):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and sourceFromItem
    local firstID = 0
    for i = 1,EID.Config["SpindownDiceResults"] do
        local spinnedID = EID:getSpindownResult(refID)
        --if hasCarBattery then
        --    refID = spinnedID
        --    spinnedID = mod:getNextAzuriteID(refID)
        --end
        refID = spinnedID
        if refID > 0 and refID < 4294960000 then
            if i == 1 then firstID = refID end
            EID:appendToDescription(descObj, "{{Collectible"..refID.."}}")
            if EID.itemUnlockStates[refID] == false then EID:appendToDescription(descObj, "?") end
            if EID.Config["SpindownDiceDisplayID"] then
                EID:appendToDescription(descObj, "/".. refID)
            end
            if EID.Config["SpindownDiceDisplayName"] then
                EID:appendToDescription(descObj, "/".. EID:getObjectName(5, 100, refID))
                if refID == 668 then break end
                if i ~= EID.Config["SpindownDiceResults"] then
                    EID:appendToDescription(descObj, "#{{Blank}}")
                end
            end

            if refID == 668 then break end -- Dad's Note is not affected by Spindown Dice
            if i ~= EID.Config["SpindownDiceResults"] then
                EID:appendToDescription(descObj, " ->")
            end
        else
            local errorMsg = EID:getDescriptionEntry("spindownError") or ""
            EID:appendToDescription(descObj, errorMsg)
            break
        end
    end
    if firstID ~= 0 and EID.TabPreviewID == 0 then
        EID.TabPreviewID = firstID
        if not EID.inModifierPreview then EID:appendToDescription(descObj, "#{{Blank}} ".. EID:getDescriptionEntry("FlipItemToggleInfo")) end
    end
    return descObj
end

if EID and EID.Config["SpindownDiceResults"] > 0 then
    EID:addDescriptionModifier("Azurite Spindown Modifier", azuriteSpindownModifierCondition, azuriteSpindownModifierCallback)
    EID:addDescriptionModifier("Azurite Trinket Tab Previews", TrinketTabConditions, TrinketTabCallback)

    EID:addDescriptionModifier("Glass Spindown Modifier", glassSpindownModifierCondition, glassSpindownModifierCallback)
    EID:addDescriptionModifier("Glass Spindown Tab Previews", TabConditions, TabCallback)
end