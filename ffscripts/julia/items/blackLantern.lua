--ignore the bits about black candle synergies... that was from before i realized black candle is hardcoded to remove all curses, including these lol
local mod = FiendFolio
local game = Game()

local minimapToggle = minimapToggle or false
local tabCooldown = tabCooldown or 0

mod.IMPCURSE_MINION_CHANCE = 50      --% chance for a heart to turn into a minion

mod.SWINECURSE_DROP_CHANCE = 50      --% chance for enemies to drop coins

mod.SUNCURSE_BUFF_MULTIPLIER = 1.1
mod.SUNCURSE_DEBUFF_MULTIPLIER = 0.85
mod.SUNCURSE_RECHARGE_TIME = 2       --how many rooms it takes for the sun curse stat boost to come back

mod.SCYTHECURSE_RAGE_MAX = 50        --treshold where player enters rage mode
mod.SCYTHECURSE_RAGE_GAIN = 1
mod.SCYTHECURSE_RAGE_DECAY_RATE = 16 --rage decays by gain rate every nth frame
mod.SCYTHECURSE_FIREDELAY_MULTIPLIER = 0.5

mod.MASTERCURSE_STYLE_MAX = 100
mod.MASTERCURSE_STYLE_GAIN_MULTIPLIER = 0.1 --damage dealt to enemy is multiplied by this to determine style level gain
mod.MASTERCURSE_STYLE_LOSS_ON_HIT = 25

mod.RAINCURSE_PROJECTILE_DAMAGE = 6.66

mod.STONECURSE_SPEED_MODIFIER = 0.3

local function levelHasCurse(level, curse)
    if level == nil then return false end
    if curse == -1 then return false end
    return level:GetCurses() & (1 << curse - 1) >= (1 << curse - 1)
end

local function levelHasAnyBLCurse(level)
    if level == nil then return false end
    for _, c in pairs(FiendFolio.curses) do
        if levelHasCurse(level, c) then return true end
    end
    return false
end

local function getRandomLanternCurse(player)
    local rng = RNG()
    if not rng then        
        rng:SetSeed(game:GetSeeds():GetStartSeed(), 0)
    end

    local c = math.random(FiendFolio.curses.impCurse, FiendFolio.curses.masterCurse)

    --local c = math.random(FiendFolio.curses.ghostCurse, FiendFolio.curses.ghostCurse) FOR DEBUG
    if c == FiendFolio.curses.sunCurse then
        player:GetData().sunCurseCounter = 0
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    elseif c == FiendFolio.curses.masterCurse then
        player:GetData().ffsavedata.masterLevel = mod.MASTERCURSE_STYLE_MAX / 2
    elseif c == FiendFolio.curses.scytheCurse then
        player:GetData().ffsavedata.scytheRage = 0
    end
    return 1 << (c - 1)
end

local function getMinimapHeight(level)
    local height = 0

    local firstRow = -1
    local lastRow = -1

    for i = 0, 12 do
        for j = 0, 12 do
            local index = i * 13 + j

            local desc = level:GetRoomByIdx(index)
            if desc.DisplayFlags ~= 0 then
                if firstRow == -1 then
                    firstRow = i
                    lastRow = i
                else
                    lastRow = i
                end
                break
            end
        end
    end

    height = 1 + lastRow - firstRow

    return height
end

local function getMappingOffset(player)
    local c = 0

    if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPASS) then
        c = c + 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TREASURE_MAP) then
        c = c + 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLUE_MAP) then
        c = c + 1
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_MIND) then
        c = 1
    end

    return c
end

local function variableTintEntity(ent, var, max, r, g, b, multiplier)
    local intensity = var/max

    local c = Color(1,1,1,1,0,0,0)
    c:SetColorize(r, g, b, intensity * multiplier)
    --ent:GetSprite().Color = c
    ent:SetColor(c, 5, 1, true, false)
end

local function toggleRageMode(player)
    local sd = player:GetData().ffsavedata

    if not sd.scytheMode then
        SFXManager():Play(SoundEffect.SOUND_LARYNX_SCREAM_HI, 1, 0, false, 1)
        sd.scytheMode = true
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    else
        sd.scytheMode = false
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end

local function getQualityCollectible(pool, min, max)
    min = min or 0
    max = max or 4

    local itempool = game:GetItemPool()

    if pool == -1 then
        pool = itempool:GetLastPool()
    end
    local i = 0
    local c = itempool:GetCollectible(pool)
    --print(c)

    while Isaac.GetItemConfig():GetCollectible(c).Quality < min or Isaac.GetItemConfig():GetCollectible(c).Quality > max do
        c = itempool:GetCollectible(pool)
        --print(c)

        if i > 100 then break end --prevent infinite loops if itempool doesnt have any items with desired quality
        i = i + 1
    end

    return c
end

local function getRoomEnemies()
    local enemies = {}
    for _, e in pairs(Isaac.GetRoomEntities()) do
        if e:IsVulnerableEnemy() then
            table.insert(enemies, e)
        end
    end
    return enemies
end

local curseAnimNames = {}

curseAnimNames[FiendFolio.curses.impCurse] = "imp"
curseAnimNames[FiendFolio.curses.stoneCurse] = "stone"
curseAnimNames[FiendFolio.curses.sunCurse] = "sun"
curseAnimNames[FiendFolio.curses.swineCurse] = "swine"
curseAnimNames[FiendFolio.curses.scytheCurse] = "scythe"
curseAnimNames[FiendFolio.curses.ghostCurse] = "ghost"
curseAnimNames[FiendFolio.curses.masterCurse] = "master"

--replace normal curses
mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function(_, curses)
    local player = Isaac.GetPlayer(0)

    if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_LANTERN) then
        local curse = getRandomLanternCurse(player)
        return curse
    end
end)

if MinimapAPI then
    local icons = Sprite()
	icons:Load("gfx/ui/minimapapi/icons.anm2", true)

    local level = game:GetLevel()

    local function ImpCurse()
        return levelHasCurse(level, FiendFolio.curses.impCurse)
    end
    local function StoneCurse()
        return levelHasCurse(level, FiendFolio.curses.stoneCurse)
    end
    local function SunCurse()
        return levelHasCurse(level, FiendFolio.curses.sunCurse)
    end
    local function SwineCurse()
        return levelHasCurse(level, FiendFolio.curses.swineCurse)
    end
    local function ScytheCurse()
        return levelHasCurse(level, FiendFolio.curses.scytheCurse)
    end
    local function GhostCurse()
        return levelHasCurse(level, FiendFolio.curses.ghostCurse)
    end
    local function MasterCurse()
        return levelHasCurse(level, FiendFolio.curses.masterCurse)
    end

    MinimapAPI:AddMapFlag("ImpCurse", ImpCurse, icons, "ffcurseimp", 0)
    MinimapAPI:AddMapFlag("StoneCurse", StoneCurse, icons, "ffcursegolem", 0)
    MinimapAPI:AddMapFlag("SunCurse", SunCurse, icons, "ffcursesun", 0)
    MinimapAPI:AddMapFlag("SwineCurse", SwineCurse, icons, "ffcurseswine", 0)
    MinimapAPI:AddMapFlag("ScytheCurse", ScytheCurse, icons, "ffcursescythe", 0)
    MinimapAPI:AddMapFlag("GhostCurse", GhostCurse, icons, "ffcurseghost", 0)
    MinimapAPI:AddMapFlag("MasterCurse", MasterCurse, icons, "ffcursemaster", 0)
end

--wip-ish curse icon rendering
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not MinimapAPI then
        if (StageAPI and StageAPI.Loaded and StageAPI.IsHUDAnimationPlaying()) or game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) then
            return
        end

        local player = Isaac.GetPlayer(0)
        local level = game:GetLevel()

        --if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_LANTERN) then --dumb shitty safeguard
            if levelHasAnyBLCurse(level) then
                local hud_offset = Options.HUDOffset

                local s = Sprite()
                local c
                s:Load("gfx/ui/curseicons.anm2", true)

                for i=FiendFolio.curses.impCurse, FiendFolio.curses.masterCurse do
                    if levelHasCurse(level, i) then
                        c = i
                    end
                end
                s:Play(curseAnimNames[c], true)

                local x_offset = 0

                if StageAPI then --fix for weird renderscales/resolutions
                    local center = StageAPI.GetScreenCenterPosition()
                    local br = StageAPI.GetScreenBottomRight()

                    x_offset = br.X - 480
                end

                local y = 48 + hud_offset * 14
                local x = 460 - hud_offset * 24

                local height = getMinimapHeight(level)
                local multiplier = 15

                if minimapToggle then
                    y = 10 + height * multiplier + hud_offset * 14
                    x = 463 - hud_offset * 24
                    s:Play(curseAnimNames[c].."_trans", true)
                end

                if not game:IsPaused() then
                    if Input.IsActionTriggered(ButtonAction.ACTION_MAP, player.ControllerIndex) then
                        tabCooldown = 10
                        minimapToggle = not minimapToggle
                    elseif Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) and tabCooldown == 0 then
                        if minimapToggle then
                            minimapToggle = not minimapToggle
                        end
                        y = 10 + height * multiplier + hud_offset * 14
                        x = 463 - hud_offset * 24
                    end
                end

                x = x + x_offset

                local icon_offset = getMappingOffset(player)

                for i = 1, 7 do
                    if levelHasCurse(level, i) then
                        icon_offset = icon_offset + 1
                    end
                end

                x = x - 16 * icon_offset

                s:Render(Vector(x, y), nilvector, nilvector)
            elseif not game:IsPaused() then
                --this runs even when the player doesnt have black lantern to
                --fix the icons being misaligned when you pick up the item
                --while having an expanded
                if Input.IsActionTriggered(ButtonAction.ACTION_MAP, player.ControllerIndex) then
                    tabCooldown = 10
                    minimapToggle = not minimapToggle
                elseif Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) and tabCooldown == 0 then
                    if minimapToggle then
                        minimapToggle = not minimapToggle
                    end
                end
            end

            if levelHasCurse(level, FiendFolio.curses.masterCurse) and player:GetData().ffsavedata.masterLevel then
                local ml = player:GetData().ffsavedata.masterLevel
                local s = Sprite()
                local room = game:GetRoom()
                s:Load("gfx/mastercrown.anm2", true)

                local anim
                if ml <= 25 then
                    anim = "FloatNoGlow"
                elseif ml <= 50 then
                    anim = "FloatSlightGlow"
                elseif ml <= 75 then
                    anim = "FloatMoreGlow"
                else anim = "FloatGlow" end

                s:Play(anim, true)

                s:Render(room:WorldToScreenPosition(player.Position - Vector(0, 6)), nilvector, nilvector)
            end
        --end

        if tabCooldown > 0 then tabCooldown = tabCooldown - 1 end
    end
end)


--imp curse: spawn hollow minions instead of hearts that persist between a few rooms
--black candle synergy: minions spawn in addition to hearts instead of replacing them
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    local level = game:GetLevel()
    local player = Isaac.GetPlayer(0)

    if levelHasCurse(level, FiendFolio.curses.impCurse) then

        if math.random(0, 99) < mod.IMPCURSE_MINION_CHANCE and not pickup:IsShopItem() then --spawn hollow minion
            local head = math.random(170) - 1

            local minion = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, pickup.Position, Vector(0, 0), player)
            minion:GetData().canreroll = false
			minion.EntityCollisionClass = 4
			minion.Parent = player
            minion:GetData().hollow = true
            minion:GetData().persistent = true
            minion:GetData().remainingRooms = 3
            minion:GetData().headframe = head

            if not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                pickup:Remove()
            end

            local sdata = player:GetData().ffsavedata
            sdata.curseMinions = sdata.curseMinions or {}

            table.insert(sdata.curseMinions, {headFrame = head, remainingRooms = 3})

        end
    end
end, PickupVariant.PICKUP_HEART)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local player = Isaac.GetPlayer(0)
    local sdata = player:GetData().ffsavedata

    if sdata.curseMinions then
        for _, m in pairs(sdata.curseMinions) do
            --if player:GetData().persistentMinions[i] > 0 then
                local minion = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, player.Position, Vector(0, 0), player)
                minion:GetData().canreroll = false
                minion.EntityCollisionClass = 4
                minion.Parent = player
                minion:GetData().hollow = true
                minion:GetData().persistent = true
                minion:GetData().remainingRooms = m.remainingRooms
                minion:GetData().headframe = m.headFrame
                --m = minion
            --end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, pos)
    local player = Isaac.GetPlayer(0)
    local sdata = player:GetData().ffsavedata

    if sdata.curseMinions then
        for k, m in pairs(sdata.curseMinions) do
            m.remainingRooms = m.remainingRooms - 1
            if m.remainingRooms == 0 then
                table.remove(sdata.curseMinions, k)
            end
        end

        for _, mi in pairs(Isaac.FindByType(1000, EffectVariant.PICKUP_FIEND_MINION, 1)) do
            if mi:GetData().remainingRooms then
                mi:GetData().remainingRooms = mi:GetData().remainingRooms - 1
            end
        end
    end
end)


--swine curse: all pennies are timed out, enemies sometimes drop pennies
--black candle synergy: regular pennies dont have timeout, enemies still drop pennies
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.swineCurse) and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        pickup.Timeout = 50
    end
end, PickupVariant.PICKUP_COIN)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.swineCurse) then
        if (not npc:GetData().ranSpawnCoinCheck) and npc:HasMortalDamage() and npc:IsEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD) and npc.Type ~= EntityType.ENTITY_MOVABLE_TNT then
            if npc:GetData().SpawnedAtRoomStart then
                if math.random(0, 99) < mod.SWINECURSE_DROP_CHANCE then
                    local p = Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 0, npc.Position, npc.Velocity, npc):ToPickup()
                    p.Timeout = 50
                end
                npc:GetData().ranSpawnCoinCheck = true
            end
        end
    end
end)


--sun curse: stat boost until you get hit, which will give a negative stat multiplier, boost regenerates after 3 rooms
--black candle synergy: getting hit only drops you to base stats rather than giving a negative multiplier
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.sunCurse) then
        local player = Isaac.GetPlayer(0)

        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local sun = player:GetData().sunCurseCounter

    if sun ~= nil then
        local level = game:GetLevel()

        if levelHasCurse(level, FiendFolio.curses.sunCurse) then
            variableTintEntity(player, 3 - sun, 3, 1, 0.5, 0, 0.5)
        else
            --variableTintEntity(player, 0, 0, 1, 1, 1, 0)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.sunCurse) then
        local sc = player:GetData().sunCurseCounter
        if sc ~= nil then
            local multiplier = 1
            if sc == 0 then
                multiplier = mod.SUNCURSE_BUFF_MULTIPLIER
            elseif mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                multiplier = 1
            else
                multiplier = mod.SUNCURSE_DEBUFF_MULTIPLIER
            end
            if flag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * multiplier
            elseif flag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed * multiplier
            elseif flag == CacheFlag.CACHE_SHOTSPEED then
                player.ShotSpeed = player.ShotSpeed * multiplier
            elseif flag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = player.MaxFireDelay * (2 - multiplier)
            elseif flag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck * multiplier
            elseif flag == CacheFlag.CACHE_RANGE then
                player.TearHeight = player.TearHeight - (multiplier - 1)
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.sunCurse) then
        local player = ent:ToPlayer()

        player:GetData().sunCurseCounter = mod.SUNCURSE_RECHARGE_TIME
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end, 1)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, pos)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.sunCurse) then
        local player = Isaac.GetPlayer(0)

        if player:GetData().sunCurseCounter ~= nil then
            if player:GetData().sunCurseCounter > 0 then
                player:GetData().sunCurseCounter = player:GetData().sunCurseCounter - 1
                if player:GetData().sunCurseCounter == 0 then
                    player:AddCacheFlags(CacheFlag.CACHE_ALL)
                    player:EvaluateItems()
                end
            end
        end
    end
end)

--scythe curse: rage builds, reaching max rage will trigger rage mode with a high tear rate but apply bruised status effect, reducing i-frames
--black candle synergy: no longer applies bruised status
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
    local level = game:GetLevel()
    local buildRage = false

    if levelHasCurse(level, FiendFolio.curses.scytheCurse) then
        if ent:IsActiveEnemy() then
            if source.Type == 2 or source.Type == 1 then buildRage = true end
            if source.Entity ~= nil then
                if source.Entity.SpawnerType ~= nil then
                    if source.Entity.SpawnerType == 1 then buildRage = true end
                end
            end

            if buildRage then
                local player = Isaac.GetPlayer(0)
                local sd = player:GetData().ffsavedata

                if not sd.scytheMode then
                    if sd.scytheRage then
                        sd.scytheRage = sd.scytheRage + mod.SCYTHECURSE_RAGE_GAIN

                        if sd.scytheRage >= mod.SCYTHECURSE_RAGE_MAX then
                            toggleRageMode(player)
                        end
                    end
                end

                buildRage = false
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local level = game:GetLevel()
    player:GetData().ffsavedata.scytheRage = player:GetData().ffsavedata.scytheRage or 0

    if levelHasCurse(level, FiendFolio.curses.scytheCurse) then
        variableTintEntity(player, player:GetData().ffsavedata.scytheRage, mod.SCYTHECURSE_RAGE_MAX, 1, 0, 0, 1)

        if player:GetData().ffsavedata.scytheMode and game:GetFrameCount() % mod.SCYTHECURSE_RAGE_DECAY_RATE == 0 then
            player:GetData().ffsavedata.scytheRage = player:GetData().ffsavedata.scytheRage - mod.SCYTHECURSE_RAGE_GAIN

            if player:GetData().ffsavedata.scytheRage <= 0 then
                toggleRageMode(player)
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    local sd = player:GetData().ffsavedata
    if not sd then return end

    if flag == CacheFlag.CACHE_FIREDELAY then
        if sd.scytheMode then
            player.MaxFireDelay = player.MaxFireDelay * mod.SCYTHECURSE_FIREDELAY_MULTIPLIER
        else
            player.MaxFireDelay = player.MaxFireDelay
        end
    end
end)

--mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
--    local player = ent:ToPlayer()
--
--    local sd = player:GetData().ffsavedata
--
--    if sd.scytheMode and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
--        if player:GetData().tookDoubleDamage ~= nil and player:GetData().tookDoubleDamage then
--            player:GetData().tookDoubleDamage = false
--        else
--            local doubleDamage = damage * 2
--
--            player:GetData().tookDoubleDamage = true
--            player:TakeDamage(doubleDamage, flags, source, countdown)
--            return false
--        end
--    end
--end, 1)

--master curse: style system that affects item/pickup quality  TODO: should reset style level on new floor
--black candle synergy: pickups/items arent rerolled into worse ones at low style level
local function upgradePickup(variant, subtype) --returns new subtype
    if variant == 10 then --hearts
        if subtype == 1 then return 5
        elseif subtype == 2 then return 1
        elseif subtype == 3 then return 6
        elseif subtype == 8 then return 3
        else return subtype end
    elseif variant == 20 then --coins
        if subtype == 1 then return 4
        elseif subtype == 4 then return 2
        elseif subtype == 2 then return 3
        else return subtype end
    elseif variant == 30 then --keys
        if subtype == 1 then return 3
        elseif subtype == 3 then return 2
        else return subtype end
    elseif variant == 40 then --bombs
        if subtype == 1 then return 2
        elseif subtype == 2 then return 4
        elseif subtype == 3 then return 1
        elseif subtype == 5 then return 3
        elseif subtype == 6 then return 4
        else return subtype end
    elseif variant == 90 then --batteries
        if subtype == 2 then return 1
        elseif subtype == 1 then return 3
        elseif subtype == 3 then return 4
        else return subtype end
    else return subtype end
end

local function downgradePickup(variant, subtype)
    if variant == 10 then
        if subtype == 1 then return 2
        elseif subtype == 3 then return 8
        elseif subtype == 4 then return 8
        elseif subtype == 5 then return 1
        elseif subtype == 6 then return 3
        else return subtype end
    elseif variant == 20 then
        if subtype == 4 then return 1
        elseif subtype == 2 then return 4
        elseif subtype == 3 then return 2
        else return subtype end
    elseif variant == 30 then
        if subtype == 3 then return 1
        elseif subtype == 2 then return 3
        else return subtype end
    elseif variant == 40 then
        if subtype == 1 then return 3
        elseif subtype == 2 then return 1
        elseif subtype == 3 then return 5
        elseif subtype == 4 then return 2
        elseif subtype == 5 then return 6
        else return subtype end
    elseif variant == 90 then
        if subtype == 1 then return 2
        elseif subtype == 3 then return 1
        else return subtype end
    else return subtype end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.masterCurse) then
        player:GetData().ffsavedata.masterLevel = player:GetData().ffsavedata.masterLevel or mod.MASTERCURSE_STYLE_MAX / 2
        --print("master level: "..tostring(player:GetData().ffsavedata.masterLevel))
    end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.masterCurse) then
        if ent:IsActiveEnemy() then
            if source.Type == 2 or source.Type == 1 then
                local player = Isaac.GetPlayer(0)
                local sd = player:GetData().ffsavedata

                if sd.masterLevel then
                    sd.masterLevel = math.min(mod.MASTERCURSE_STYLE_MAX, sd.masterLevel + damage * mod.MASTERCURSE_STYLE_GAIN_MULTIPLIER)
                end
            end
            if source.Entity ~= nil then
                if source.Entity.SpawnerType ~= nil and source.Entity.SpawnerType == 1 then
                    local player = Isaac.GetPlayer(0)
                    local sd = player:GetData().ffsavedata

                    if sd.masterLevel then
                        sd.masterLevel = math.min(mod.MASTERCURSE_STYLE_MAX, sd.masterLevel + damage * mod.MASTERCURSE_STYLE_GAIN_MULTIPLIER)
                    end
                end
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
    local player = ent:ToPlayer()

    local sd = player:GetData().ffsavedata
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.masterCurse) then
        if sd.masterLevel then
            sd.masterLevel = math.max(0, sd.masterLevel - mod.MASTERCURSE_STYLE_LOSS_ON_HIT)
        end
    end
end, 1)

local masterRerollingPickup
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.masterCurse) and not pickup:ToPickup():GetData().rerolled and not masterRerollingPickup then
        local player = Isaac.GetPlayer(0)
        local mLevel = player:GetData().ffsavedata.masterLevel or mod.MASTERCURSE_STYLE_MAX / 2

        local v = pickup.Variant
        local s = pickup.SubType

        if upgradePickup(v, s) ~= s or downgradePickup(v, s) ~= s then
            masterRerollingPickup = true
            if mLevel >= mod.MASTERCURSE_STYLE_MAX * 0.9 then
                pickup:Morph(pickup.Type, v, upgradePickup(v, s), true, true)
                pickup:GetData().rerolled = true
            elseif mLevel >= mod.MASTERCURSE_STYLE_MAX * 0.7 then
                if math.random(0, 2) == 0 then
                    pickup:Morph(pickup.Type, v, upgradePickup(v, s), true, true)
                    pickup:GetData().rerolled = true
                end
            elseif mLevel <= mod.MASTERCURSE_STYLE_MAX * 0.3 and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                if math.random(0, 2) == 0 then
                    pickup:Morph(pickup.Type, v, downgradePickup(v, s), true, true)
                    pickup:GetData().rerolled = true
                end
            elseif mLevel <= mod.MASTERCURSE_STYLE_MAX * 0.1 and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                pickup:Morph(pickup.Type, v, downgradePickup(v, s), true, true)
                pickup:GetData().rerolled = true
            end

            masterRerollingPickup = false
        end

        --if v == 100 then
        --    local st = s
        --
        --    if mLevel >= 75 and Isaac.GetItemConfig():GetCollectible(s).Quality < 2 then
        --        st = getQualityCollectible(-1, 2, 4)
        --    elseif mLevel <= 25 and Isaac.GetItemConfig():GetCollectible(s).Quality > 2 then
        --        st = getQualityCollectible(-1, 0, 2)
        --    end
        --
        --    if st ~= s then
        --        local p = Isaac.Spawn(pickup.Type, v, st, pickup.Position, pickup.Velocity, pickup.SpawnerEntity)
        --        --pickup:Morph(5, v, st, true, true)
        --        p:GetData().rerolled = true
        --        pickup:Remove()
        --    end
        --end
    end
end)

--item quality stuff
local masterRerollingCollectible
mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, function(_, type, pool, decrease, seed)
    --i   hope   the items the game goes through while searching for a suitable quality item dont get removed from the pools if theyre not actually returned in the end? but how am i supposed to know

    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.masterCurse) and not masterRerollingCollectible then
    --if 0 == 1 then
        masterRerollingCollectible = true
        local player = Isaac.GetPlayer(0)
        local mLevel = player:GetData().ffsavedata.masterLevel or mod.MASTERCURSE_STYLE_MAX / 2
        local t = type

        if mLevel >= mod.MASTERCURSE_STYLE_MAX * 0.75 and Isaac.GetItemConfig():GetCollectible(t).Quality < 2 then
            t = getQualityCollectible(pool, 2, 4)
        elseif mLevel <= mod.MASTERCURSE_STYLE_MAX * 0.25 and Isaac.GetItemConfig():GetCollectible(t).Quality > 2 and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            t = getQualityCollectible(pool, 0, 2)
        end

        masterRerollingCollectible = false

        if t ~= type then return t end
    end
end)


--ghost curse: cursed evil ghost rain that hurts both player and enemies comes down; at a higher frequency when the player is at lower health
--TODO black candle synergy: rain doesnt hurt the player
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.ghostCurse) then
        if player:GetEffectiveMaxHearts() == 0 then
            player:GetData().ghostCurseHealth = player:GetSoulHearts() / 12 --uhhhhh idk this sucks
        else
            player:GetData().ghostCurseHealth = player:GetHearts() / player:GetEffectiveMaxHearts()
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.ghostCurse) then
        local player = Isaac.GetPlayer(0)
        local room = game:GetRoom()
        local targetFreq = 70

        if not room:IsClear() and player:GetData().ghostCurseHealth ~= nil then
            targetFreq = math.max(5, math.floor(player:GetData().ghostCurseHealth * 20))
        end

        local rainFrequency = player:GetData().ghostCurseRainFrequency or 70
        local dif = targetFreq - rainFrequency

        local step
        if dif < 0 then step = -0.5
        elseif dif > 0 then step = 0.5
        else step = 0 end

        if rainFrequency ~= targetFrequency then
            rainFrequency = rainFrequency + step
        end

        if rainFrequency < 70 and game:GetFrameCount() % math.floor(rainFrequency) == 0 then
            local pos = Isaac.GetRandomPosition()

            local enemies = getRoomEnemies()
            if #enemies ~= 0 and math.random(0, 1) == 0 then
                local e = enemies[math.random(1, #enemies)]
                pos = e.Position + Vector(math.random(-40, 40), math.random(-40, 40))
            end

            local target = Isaac.Spawn(1000, 7013, 2, pos, Vector(0,0), nil)
            target:Update()
        end

        player:GetData().ghostCurseRainFrequency = rainFrequency
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile) --ugh!
    if projectile:ToProjectile():GetData().projType == "cursed rain" and projectile:ToProjectile().Height >= -60 then
        local enemies = Isaac.FindInRadius(projectile.Position, 10, EntityPartition.ENEMY)
        if #enemies > 0 then
            for _, e in pairs(enemies) do
                if e:IsVulnerableEnemy() then
                    e:TakeDamage(mod.RAINCURSE_PROJECTILE_DAMAGE, 0, EntityRef(projectile), 0)
                    e:AddFear(EntityRef(projectile), 120)
                end
            end
            projectile:Remove()
        end
    end
end, 4)


--stone curse: carrying weight system, having no trinkets/pocket items gives a speed boost, having more gives a speed down
--black candle synergy: no negative effect for high weight
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.stoneCurse) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    local level = game:GetLevel()

    if levelHasCurse(level, FiendFolio.curses.stoneCurse) and flag == CacheFlag.CACHE_SPEED then
        local stuff = 0

        for i = 0, 1 do
            if player:GetTrinket(i) ~= 0 then stuff = stuff + 1 end
            if player:GetPill(i) ~= 0 or player:GetCard(i) ~= 0 then stuff = stuff + 1 end
        end

        if not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            player.MoveSpeed = player.MoveSpeed - (stuff - 1) * mod.STONECURSE_SPEED_MODIFIER
        end
        if stuff == 0 then player.MoveSpeed = player.MoveSpeed + 0.15 end --extra bonus
    end
end)

local persistBLCurseThisFloor = false
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	 persistBLCurseThisFloor = mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_LANTERN)
end)

--if noone has the lantern and for some reason they have the curses, nuke the curses
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local level = game:GetLevel()
    local player = Isaac.GetPlayer(0)

    if levelHasAnyBLCurse(level) and not persistBLCurseThisFloor and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_LANTERN) then
        for _, c in pairs(FiendFolio.curses) do
            level:RemoveCurses(1 << c)
        end

        --reset sun/stone curse boost
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
        player:GetData().sunCurseCounter = nil

        --reset scythe and master
        player:GetData().ffsavedata.scytheRage = nil
        player:GetData().ffsavedata.masterLevel = nil
    elseif player:GetData().ffsavedata.scytheRage ~= nil and player:GetData().ffsavedata.scytheRage > 0 and not levelHasCurse(level, FiendFolio.curses.scytheCurse) then
        player:GetData().ffsavedata.scytheRage = nil

        player:GetData().ffsavedata.scytheMode = false
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        --variableTintEntity(player, 0, mod.SCYTHECURSE_RAGE_MAX, 1, 0, 0, 1)
    end
end)

--replace curse upon item pickup
mod.AddItemPickupCallback(function(player, added)
    local level = game:GetLevel()
	
    if not levelHasAnyBLCurse(level) then
		local level = game:GetLevel()

		level:RemoveCurses(level:GetCurses())
		local curse = getRandomLanternCurse(player)
		level:AddCurse(curse, false)
	end
	
	persistBLCurseThisFloor = true
end, nil, CollectibleType.COLLECTIBLE_BLACK_LANTERN, true)
