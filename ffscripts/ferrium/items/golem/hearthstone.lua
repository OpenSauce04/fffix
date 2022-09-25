local mod = FiendFolio
local sfx = SFXManager()

local hearthstoneRandomEffects = {
    [1] = function(player) --Flamestrike
        player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM, -1)
    end,
    [2] = function(player) --Radiance
        player:AddHearts(3)
        sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
        local poof = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, player):ToEffect()
		poof.SpriteOffset = Vector(0,-45)
		poof:FollowParent(player)
		poof:Update()
    end,
    [3] = function(player) --Fiendish Circle
        for i = 1, 4 do
            local egg = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, player.Position + RandomVector() * math.random(5, 40), Vector.Zero, player)
            egg:GetData().canreroll = false
            egg.EntityCollisionClass = 4
            egg.Parent = player
            egg:GetData().hollow = true
    
            if not mod.IsActiveRoom() then
                egg:GetData().mixPersistent = true
                egg:GetData().mixRemainingRooms = 1
                egg:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
            end
        end
    end,
    [4] = function(player) --Minefield
        player:UseActiveItem(CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK, UseFlag.USE_NOANIM, -1)
    end,
    [5] = function(player) --Hunter's Pack
        for i=1,3 do
            player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, UseFlag.USE_NOANIM, -1)
        end
    end,
    [6] = function(player) --the DRUG card that makes you HIGH
        FiendFolio.QueuePills(player, 3)
    end,
    [7] = function(player) --Maybe I'll do cooler effects later but this is surprisingly boring
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN, UseFlag.USE_NOANIM, -1)
    end,
    [8] = function(player)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM, -1)
    end,
}

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.HEARTHSTONE) and flag == flag | UseFlag.USE_OWNED then
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.HEARTHSTONE)
        hearthstoneRandomEffects[rng:RandomInt(#hearthstoneRandomEffects)+1](player)
    end
end)