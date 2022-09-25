--birthday gift ^u^
local mod = FiendFolio
local game = Game()

local perthrod = perthrod or false
local actived = actived or false
local mysteryActived = mysteryActived or false

local bedenHit = bedenHit or false

--actives that stop rerolling when used
local blockActives = {
    {CollectibleType.COLLECTIBLE_D6, 6},
    {CollectibleType.COLLECTIBLE_ETERNAL_D6, 2},
    {CollectibleType.COLLECTIBLE_D100, 6},
    {CollectibleType.COLLECTIBLE_LEMEGETON, 6}
}

--pocket items that stop rerolling when used
local blockPockets = {
    Card.RUNE_PERTHRO,
    Card.CARD_DICE_SHARD,
    Card.GLASS_D6,
    Card.GLASS_D100
}

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, ent, hook, action)
    if ent and ent:ToPlayer() then
        local player = ent:ToPlayer()

        if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
            actived = false

            for i = 1, #blockActives, 1 do
                if player:GetActiveItem() == blockActives[i][1] and (player:GetActiveCharge() == blockActives[i][2] or player:GetBloodCharge() >= blockActives[i][2] or player:GetSoulCharge() >= blockActives[i][2]) then
                    actived = true
                end
            end

            if player:GetActiveItem() == CollectibleType.COLLECTIBLE_MYSTERY_GIFT then
                mysteryActived = true
            else
                mysteryActived = false
            end
        else
            actived = false
        end

        if Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) then
            perthrod = false

            for i = 1, #blockPockets, 1 do
                if player:GetCard(0) == blockPockets[i] then
                    perthrod = true
                end
            end

            for i = 1, #blockActives, 1 do
                if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == blockActives[i][1] and (player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == blockActives[i][2] or player:GetBloodCharge() >= blockActives[i][2] or player:GetSoulCharge() >= blockActives[i][2]) then
                    actived = true
                end
            end
        else
            perthrod = false
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, function(_, c, pt, d, s)
	for i = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1):ToPlayer()
        
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_GIFT) then
            --Keep this as mystery gift, can be replaced for funnies
            local replacedItem = CollectibleType.COLLECTIBLE_MYSTERY_GIFT
            --replacedItem = 628
            if mysteryActived or actived or perthrod or bedenHit then
                --the way this works: if the players active item is currently mystery gift  OR  it is d6 and also d6 is fully charged
                --																				AND the player is pressing the space bar (which is basically like checking if the player is using the d6 and its actually rerolling things)
                --																				THEN do not turn item into gift
                return c
            end

            return replacedItem
        end
    end
end)

--damocles fix, items spawned by mystery gift aren't duplicated
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, p)
    if mysteryActived and p:HasEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE) then
        p:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
    end
end, 100)

--fix for coop with tainted eden
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, tookDamage, amount, flags, source, countdown)
    local player = tookDamage:ToPlayer()

    if player and player:GetPlayerType() == PlayerType.PLAYER_EDEN_B then
        bedenHit = true
    end
end, 1)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if bedenHit then bedenHit = false end
end)