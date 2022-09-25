local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local sprite = pickup:GetSprite()
    local data = pickup:GetData()
    if sprite:IsFinished("Appear") then
        sprite:Play("Idle", false)
    end
    if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
        pickup.Visible = false
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
    if sprite:IsEventTriggered("DropSound") then
        sfx:Play(SoundEffect.SOUND_KEY_DROP0, 1, 0, false, 1.25)
    end

    if not data.checkcolour then
        if pickup.SubType == 1 and mod.ColourBlindMode then
            local s = pickup:GetSprite()
            s:ReplaceSpritesheet(0, "gfx/items/pick ups/consumable_yellowkey.png")
            s:LoadGraphics()
        end
        data.checkcolour = true
    end
end, PickupVariant.PICKUP_PUZZLE_KEY)

function mod.CollectPuzzleKey(player, pickup)
    local sprite = pickup:GetSprite()
    if sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
        --pickup:Die()
        pickup.Touched = true
        sprite:Play("Collect")
        sfx:Play(SoundEffect.SOUND_KEYPICKUP_GAUNTLET, 1, 0, false, math.random(147,153)/100)

        local data = player:GetData()
        table.insert(data.KeyGhostData[FiendFolio.KeyToGhostMap[pickup.SubType]], { Key = pickup })

        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
    if collider.Type == 1 and collider.Variant == 0 then
        collider = collider:ToPlayer()
        mod.CollectPuzzleKey(collider, pickup)
        return true
    else
        return true
    end
end, PickupVariant.PICKUP_PUZZLE_KEY)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local player = mod.GetBoneSwingPickupPlayer(pickup)
    if player then
        mod.CollectPuzzleKey(player, pickup)
    end
end, PickupVariant.PICKUP_PUZZLE_KEY)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function()
    for _, p in pairs(Isaac.FindByType(5, PickupVariant.PICKUP_PUZZLE_KEY, -1, false, false)) do
        if p:GetSprite():IsPlaying("Appear") then
            p:Remove()
        end
    end
end, Card.RUNE_JERA)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    familiar.IsFollower = true
end, FamiliarVariant.BLUE_KEYGHOST)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    familiar.IsFollower = true

    if mod.ColourBlindMode then
        local s = familiar:GetSprite()
        s:ReplaceSpritesheet(0, "gfx/familiar/keyghosts/familiar_keyghostyellow.png")
        s:ReplaceSpritesheet(1, "gfx/familiar/keyghosts/familiar_keyghostyellow.png")
        s:LoadGraphics()
    end
end, FamiliarVariant.GREEN_KEYGHOST)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    familiar.IsFollower = true
end, FamiliarVariant.RED_KEYGHOST)

-- note these do not use anm2s as grid sprites are very funky
local blockColors = {{"Blue", 1013, 1017}, {"Green", 1014, 1018}, {"Red", 1015, 1019}, {"Gray", 1034, 1035}}

FiendFolio.KeyBlockGrid = {}
FiendFolio.ChainBlockGrid = {}

for _, color in ipairs(blockColors) do
    FiendFolio.KeyBlockGrid[color[1]] = StageAPI.CustomGrid("FFKeyBlock" .. color[1], {
        BaseType = GridEntityType.GRID_WALL,
        Anm2 = "gfx/grid/" .. string.lower(color[1]) .. "_lock.anm2",
        Animation = "Idle",
        SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = color[2]}
    })

    FiendFolio.ChainBlockGrid[color[1]] = StageAPI.CustomGrid("FFChainBlock" .. color[1], {
        BaseType = GridEntityType.GRID_WALL,
        Anm2 = "gfx/grid/" .. string.lower(color[1]) .. "_blank_lock.anm2",
        Animation = "Idle",
        SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = color[3]}
    })
end

function mod.IsKeyBlock(grid)
	local gridIndex = grid:GetGridIndex()
	
	for _, color in ipairs(blockColors) do
		if StageAPI.IsCustomGrid(gridIndex, "FFKeyBlock" .. color[1]) or StageAPI.IsCustomGrid(gridIndex, "FFChainBlock" .. color[1]) then
			return true
		end
	end
	return false
end

FiendFolio.BlockGridToEffect = {
    FFKeyBlockBlue  = 1013,
    FFKeyBlockGreen = 1014,
    FFKeyBlockRed   = 1015,
    FFKeyBlockGray  = 1034,
    FFChainBlockBlue  = 1017,
    FFChainBlockGreen = 1018,
    FFChainBlockRed   = 1019,
    FFChainBlockGray = 1035,
}

for _, variant in pairs(FiendFolio.BlockGridToEffect) do
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
        local sprite = eff:GetSprite()
        if sprite:IsFinished() then
            eff:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
        end
    end, variant)
end

FiendFolio.ColorBlindBlocks = {
    FFKeyBlockGreen = "gfx/grid/yellow_lock.png",
    FFChainBlockGreen = "gfx/grid/yellow_blank_lock.png",
}

FiendFolio.KeyToGhostMap = {
    [PuzzleKeySubType.BLUE] = FamiliarVariant.BLUE_KEYGHOST,
    [PuzzleKeySubType.GREEN] = FamiliarVariant.GREEN_KEYGHOST,
    [PuzzleKeySubType.RED] = FamiliarVariant.RED_KEYGHOST
}

FiendFolio.KeyBlockToGhostMap = {
    FFKeyBlockBlue  = FamiliarVariant.BLUE_KEYGHOST,
    FFKeyBlockGreen = FamiliarVariant.GREEN_KEYGHOST,
    FFKeyBlockRed   = FamiliarVariant.RED_KEYGHOST
}

FiendFolio.KeyBlockToEvilGhostMap = {
    FFKeyBlockBlue = mod.FF.BlueKeyFiend.Sub,
    FFKeyBlockGreen = mod.FF.GreenKeyFiend.Sub,
    FFKeyBlockRed = mod.FF.RedKeyFiend.Sub
}

FiendFolio.ChaintoKeyBlock = {
    FFChainBlockBlue  = 'FFKeyBlockBlue',
    FFChainBlockGreen = 'FFKeyBlockGreen',
    FFChainBlockRed   = 'FFKeyBlockRed',
    FFChainBlockGray  = 'FFKeyBlockGray',
}

FiendFolio.KeytoChainBlock = {
    FFKeyBlockBlue  = 'FFChainBlockBlue',
    FFKeyBlockGreen = 'FFChainBlockGreen',
    FFKeyBlockRed   = 'FFChainBlockRed',
    FFKeyBlockGray  = 'FFChainBlockGray'
}

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then -- key ghosts persist in this challenge
        return
    end

    for i = 1, game:GetNumPlayers() do
        local data = Isaac.GetPlayer(i - 1):GetData()
        for variant, entry in pairs(data.KeyGhostData) do
            data.KeyGhostData[variant] = {}
            for num, keys in ipairs(entry) do
                if keys.Ghost then
                    keys.Ghost:Remove()
                end
            end
        end
    end
    for _, puzzleKey in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PUZZLE_KEY)) do
        puzzleKey:ToPickup().Touched = false
    end
end)

function mod:KeyGhostUpdate(familiar)
    local data = familiar:GetData()
    local sprite = familiar:GetSprite()

    if not data.key then
        local keys = familiar.Player:GetData().KeyGhostData[familiar.Variant]
        for i, entry in ipairs(keys) do
            if not entry.Ghost then
                entry.Ghost = familiar
                data.key = entry.Key
                break
            end
        end
    end

    if sprite:IsFinished("Appear") then
        sprite:Play("Move")
    elseif sprite:IsFinished("Poof") then
        familiar:Remove()
    end
    sprite.Offset = Vector(0, -10)
    sprite.FlipX = familiar.Velocity.X <= 0

    if sprite:IsEventTriggered("UseKey") then
        data.target:GetData().Unlock = true

        -- kill the key right now to avoid waiting for the rest of the animation
        -- because the lock part of the code runs in post_update this is fine
        local keys = familiar.Player:GetData().KeyGhostData[familiar.Variant]
        for i, entry in ipairs(keys) do
            if entry.Ghost and GetPtrHash(entry.Ghost) == GetPtrHash(familiar) then
                entry.Key:Remove()
                table.remove(keys, i)
                break
            end
        end
    end
    if data.target then
        familiar.Velocity = (data.target.Position - familiar.Position) * 0.2
        if familiar.Position:DistanceSquared(data.target.Position) <= (familiar.Size + data.target.Size) ^ 2 then
            sprite:Play("Poof", false)
        end
    else
        familiar:FollowParent()
    end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.KeyGhostUpdate, FamiliarVariant.BLUE_KEYGHOST)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.KeyGhostUpdate, FamiliarVariant.RED_KEYGHOST)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.KeyGhostUpdate, FamiliarVariant.GREEN_KEYGHOST)

function mod.commonBlockAI(customGrid)
    local persistData = customGrid.PersistentData
    persistData.FrameCount = persistData.FrameCount + 1

    local sprite = customGrid.GridEntity:GetSprite()
    if persistData.BreakStarted then
        if not persistData.BreakTriggered and persistData.FrameCount > persistData.BreakStarted then
            persistData.BreakTriggered = true
            sprite:Play("Breaking", true)
        end

        if sprite:IsEventTriggered('SndPlay') then
            sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 0.9, 0, false, math.random(125,135)/100)
        end
        
        if sprite:IsEventTriggered('Unlock') then
            sfx:Play(SoundEffect.SOUND_UNLOCK00, 1.2, 0, false, math.random(120,140)/100)
            local eff = Isaac.Spawn(1000, FiendFolio.BlockGridToEffect[customGrid.GridConfig.Name], 0, customGrid.GridEntity.Position, Vector.Zero, nil)
            eff:GetSprite():Play(sprite:GetAnimation(), true)
            eff:GetSprite():SetFrame(sprite:GetFrame())
            customGrid:Remove()
        end
    end

    sprite:Update() -- walls don't update their sprites by default, so we have to do it
end

function mod.lockAI(customGrid)
    mod.commonBlockAI(customGrid)

    local persistData = customGrid.PersistentData
    local customGridTypeName = customGrid.GridConfig.Name
    local spawnIndex = customGrid.GridIndex
    if not persistData.friend then
        local position = customGrid.GridEntity.Position
        local ghostVariant = FiendFolio.KeyBlockToGhostMap[customGridTypeName]
        if ghostVariant then
            for _, p in pairs(Isaac.FindByType(1, -1, -1, false, false)) do
                local radius = p.Size + 26
                if p:ToPlayer():GetPlayerType() == mod.PLAYER.CHINA then radius = radius + 20 end

                if (p.Position + p.Velocity):Distance(position) <= radius then
                    local d = p:GetData()
                    for _, entry in pairs(d.KeyGhostData[ghostVariant]) do
                        local f = entry.Ghost
                        if f and not f:GetData().target then
                            f:GetData().target = {
                                Position = position,
                                Size = 26,
                                GetData = function() return persistData end
                            } -- fake npc
                            persistData.friend = f
                            break
                        end
                    end

                    if persistData.friend then
                        break
                    end
                end
            end
        end
        --Dungeon Master stuff
        for _, keyfiend in pairs(Isaac.FindByType(mod.FF.KeyFiend.ID, mod.FF.KeyFiend.Var, -1, false, false)) do
            if keyfiend.Position:Distance(customGrid.GridEntity.Position) < 40 then
                keyfiend = keyfiend:ToNPC()
                if keyfiend:GetSprite():IsPlaying("Fly") then
                    local subtypewanted = FiendFolio.KeyBlockToEvilGhostMap[customGridTypeName]
                    if subtypewanted == keyfiend.SubType then
                        persistData.Unlock = true
                        persistData.friend = keyfiend
                        keyfiend:GetSprite():Play("Poof")
                    end
                end
            end
        end
        if customGridTypeName == "FFKeyBlockGray" then
            for _, dungeonmaster in pairs(Isaac.FindByType(mod.FF.DungeonMaster.ID, mod.FF.DungeonMaster.Var, -1, false, false)) do
                if dungeonmaster:ToNPC().I1 == 1 and dungeonmaster.Position:Distance(customGrid.GridEntity.Position) < 75 then
                    if dungeonmaster:GetSprite():IsEventTriggered("Shoot") then
                        persistData.Unlock = true
                        persistData.friend = dungeonmaster
                        sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)
                    end
                end
            end
        end
    elseif persistData.Unlock then
        persistData.Unlock = nil
        persistData.BreakStarted = persistData.FrameCount

        local function addNeighbors(queue, frameOffset, idx, width)
            table.insert(queue, { frameOffset, idx - 1,        })
            table.insert(queue, { frameOffset, idx + 1,        })
            table.insert(queue, { frameOffset, idx - width,    })
            table.insert(queue, { frameOffset, idx + width,    })
        end

        local room = game:GetRoom()
        local width = room:GetGridWidth()

        -- do a BFS over neighbors to trigger breaks
        local queue = {}
        addNeighbors(queue, 0, spawnIndex, width)
        local visited = {}

        repeat
            local breakFrameOffset, idx = table.unpack(table.remove(queue, 1))
            if not visited[idx] then
                visited[idx] = true
                local grid = StageAPI.GetCustomGrid(idx, FiendFolio.KeytoChainBlock[customGridTypeName])
                if grid then
                    local breakFrameDelay = breakFrameOffset + grid.PersistentData.BreakDelay
                    grid.PersistentData.BreakStarted = math.min(grid.PersistentData.FrameCount + breakFrameDelay,
                                                             grid.PersistentData.BreakStarted or math.maxinteger)
                    addNeighbors(queue, grid.PersistentData.BreakStarted - grid.PersistentData.FrameCount, idx, width)
                end
            end
        until #queue == 0
    end
end

function mod.lockSpawn(customGrid)
    local persistData = customGrid.PersistentData
    if persistData.BreakStarted then
        customGrid:Remove()
        return
    end

    persistData.FrameCount = 0
    persistData.BreakDelay = (persistData.SpawnerEntity and persistData.SpawnerEntity.SubType) or 20

    if mod.ColourBlindMode then
        local repl = FiendFolio.ColorBlindBlocks[customGrid.GridConfig.Name]
        if repl then
            local s = customGrid.GridEntity:GetSprite()
            s:ReplaceSpritesheet(0, repl)
            s:LoadGraphics()
        end
    end
end

for _, grid in pairs(FiendFolio.KeyBlockGrid) do
    StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.lockAI, grid.Name)
    StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.lockSpawn, grid.Name)
end

for _, grid in pairs(FiendFolio.ChainBlockGrid) do
    StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.commonBlockAI, grid.Name)
    StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.lockSpawn, grid.Name)
end

local puzzleKeyRNG = RNG()
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local room = game:GetRoom()
    local level = game:GetLevel()
    if room:IsFirstVisit() and level:GetStage() <= 2 and level:GetStageType() >= StageType.STAGETYPE_REPENTANCE and StageAPI.GetDimension() == 1 then
        local matchingSpawns = {}
        local spawnList = {}
        StageAPI.ForAllSpawnEntries(level:GetCurrentRoomDesc().Data, function(entry, spawn)
            if entry.Type == EntityType.ENTITY_PICKUP and entry.Variant == PickupVariant.PICKUP_PUZZLE_KEY then
                matchingSpawns[spawn.X] = matchingSpawns[spawn.X] or {}
                if not matchingSpawns[spawn.X][spawn.Y] then
                    matchingSpawns[spawn.X][spawn.Y] = spawn
                    spawnList[#spawnList + 1] = spawn
                end
            end
        end)

        if #spawnList > 0 then
            puzzleKeyRNG:SetSeed(room:GetSpawnSeed(), 35)
            local width = StageAPI.RoomShapeToWidthHeight[room:GetRoomShape()].Width
            for _, spawn in ipairs(spawnList) do
                local entry = spawn:PickEntry(puzzleKeyRNG:RandomFloat())
                if entry.Type == EntityType.ENTITY_PICKUP and entry.Variant == PickupVariant.PICKUP_PUZZLE_KEY then
                    local index = StageAPI.VectorToGrid(spawn.X, spawn.Y, width)
                    Isaac.Spawn(entry.Type, entry.Variant, entry.Subtype, room:GetGridPosition(index), Vector.Zero, nil)
                end
            end
        end
    end
end)

local rerollingPuzzleKeys = {}
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    for _, puzzleKey in ipairs(rerollingPuzzleKeys) do
        puzzleKey[1]:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PUZZLE_KEY, puzzleKey[2])
        puzzleKey[1]:GetSprite():SetLastFrame()
        if puzzleKey[1]:ToPickup().Touched then
            puzzleKey[1]:Update()
            puzzleKey[1].Visible = false
            puzzleKey[1].EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end

    rerollingPuzzleKeys = {}
end, CollectibleType.COLLECTIBLE_D20)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    rerollingPuzzleKeys = {}
    for _, puzzleKey in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PUZZLE_KEY)) do
        rerollingPuzzleKeys[#rerollingPuzzleKeys + 1] = {puzzleKey, puzzleKey.SubType}
    end
end, CollectibleType.COLLECTIBLE_D20)

local puzzleKeyBadCards = {
    Card.CARD_ACE_OF_CLUBS,
    Card.CARD_ACE_OF_HEARTS,
    Card.CARD_ACE_OF_SPADES,
    Card.CARD_ACE_OF_DIAMONDS,
    Card.RUNE_BLACK
}

local function fixRerolledPuzzleKeys()
    for _, puzzleKey in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PUZZLE_KEY)) do
        for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            if pickup.Variant ~= puzzleKey.Variant
            and pickup.Position.X == puzzleKey.Position.X and pickup.Position.Y == puzzleKey.Position.Y then
                pickup:Remove()
            end
        end

        for _, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
            if familiar.Variant == FamiliarVariant.BLUE_FLY
            or familiar.Variant == FamiliarVariant.BLUE_SPIDER
            and (familiar.Position.X == puzzleKey.Position.X and familiar.Position.Y == puzzleKey.Position.Y) then
                familiar:Remove()
            end
        end

        local new = Isaac.Spawn(puzzleKey.Type, puzzleKey.Variant, puzzleKey.SubType, puzzleKey.Position, puzzleKey.Velocity, puzzleKey.SpawnerEntity)
        new.Parent = puzzleKey.Parent
        new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        new:GetSprite():SetLastFrame()
        if puzzleKey:ToPickup().Touched then
            new:Update()
            new.Visible = false
            new.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end
end

for _, card in ipairs(puzzleKeyBadCards) do
    mod:AddCallback(ModCallbacks.MC_USE_CARD, fixRerolledPuzzleKeys, card)
end
