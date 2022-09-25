local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, itemRNG, player, useFlags, useSlot, varData)
    local queueItemData = player.QueuedItem
    if queueItemData.Item ~= nil then
        queueItemData.Item = nil
        player.QueuedItem = queueItemData
        mod:RecycleItem(player, nil, itemRNG) 
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            mod:RecycleItem(player, nil, itemRNG)
        end
    end

    local optionIndexes = {}
    for _, collectible in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, 100, -1)) do
        collectible = collectible:ToPickup()
        if not collectible:IsShopItem() then
            if collectible.OptionsPickupIndex ~= 0 then
                if optionIndexes[collectible.OptionsPickupIndex] then
                    collectible:Remove()
                else
                    optionIndexes[collectible.OptionsPickupIndex] = true
                    mod:RecycleItem(player, collectible, itemRNG)
                end
            else
                mod:RecycleItem(player, collectible, itemRNG)
            end
        end
    end
    return true
end, FiendFolio.ITEM.COLLECTIBLE.SHREDDER)

function mod:RecycleItem(player, collectible, rng)
    local spawnpos
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
    if collectible then
        spawnpos = collectible.Position
    else
        spawnpos = player.Position
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, spawnpos, Vector.Zero, player)
    mod:RecyclerLoot(spawnpos, Game():GetRoom():GetType(), player, rng)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:AddWisp(FiendFolio.ITEM.COLLECTIBLE.SHREDDER, spawnpos, false, false)
    end

    if collectible then
        collectible:Remove()
    end
end

--God i left so many comments when i originally coded this but they are sort of helpful i guess


function mod:RecyclerLoot(position, roomtype, player, rng)
    --Starting number of random pickups is 3-5
    local pickups = rng:RandomInt(3) + 3
    --Add +1 bonus pickup, determined by room type
    --Eternal Heart in Angel Rooms
    if roomtype == RoomType.ROOM_ANGEL then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 4, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --Black Heart in Devil Rooms
    elseif roomtype == RoomType.ROOM_DEVIL then 
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 6, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --Rotten Heart in Curse Rooms
    elseif roomtype == RoomType.ROOM_CURSE then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 12, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --Bone Heart in Secret Rooms
    elseif roomtype == RoomType.ROOM_SECRET or roomtype == RoomType.ROOM_SUPERSECRET or roomtype == RoomType.ROOM_ULTRASECRET then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 11, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --Otherwise, a random pickup
    else
        pickups = pickups + 1
    end
    --Spawn the random pickups
    for i = 1, pickups do
        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 1, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player):ToPickup()
    end
    --Spawn the card(s)
    mod:RandomCardSpawn(position, roomtype, rng)
    --Spawn the trinket
    if FiendFolio.GolemExists() then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 350, FiendFolio.GetGolemTrinket(), position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)  
    else
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 350, 0, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)  
    end
end

function mod:RandomCardSpawn(position, roomtype, rng)
    --Holy Card in Angel Rooms
    if roomtype == RoomType.ROOM_ANGEL then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 300, Card.CARD_HOLY, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --Joker Card in Devil Rooms
    elseif roomtype == RoomType.ROOM_DEVIL then 
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 300, Card.CARD_JOKER, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --2 Pills in Curse Rooms
    elseif roomtype == RoomType.ROOM_CURSE then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 70, 0, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 70, 0, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    --2 Runes in Planetariums
    elseif roomtype == RoomType.ROOM_PLANETARIUM then
        for i = 1, 2 do
            local runeID = game:GetItemPool():GetCard(rng:GetSeed(), false, true, true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, 300, runeID, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
        end
    --2 Cracked Keys in Ultra Secret Rooms
    elseif roomtype == RoomType.ROOM_ULTRASECRET then
        for i = 1, 2 do
            Isaac.Spawn(EntityType.ENTITY_PICKUP, 300, Card.CARD_CRACKED_KEY, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
        end
    --Otherwise, a random Card
    else
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 300, 0, position, RandomVector() * (2 + (2 * rng:RandomFloat())), player)
    end
end