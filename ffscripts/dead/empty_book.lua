local fiendfoliodirectory = FiendFolio.DSS_DIRECTORY
local dssmod = FiendFolio.DSS_MOD
local mod = FiendFolio
local game = Game()

local bookModifiers = {
    Length = {
        {
            Name = "short story",
            EffectMultiplier = 1,
            Item = FiendFolio.ITEM.COLLECTIBLE.MY_STORY_2
        },
        {
            Name = "average story",
            An = true,
            EffectMultiplier = 2,
            Item = FiendFolio.ITEM.COLLECTIBLE.MY_STORY_4
        },
        {
            Name = "long story",
            EffectMultiplier = 3,
            Item = FiendFolio.ITEM.COLLECTIBLE.MY_STORY_6
        }
    },
    Effects = {
        {
            Name = "sad",
            Description = "that makes me sad",
            TwistPrefix = "and has a"
        },
        {
            Name = "shocking",
            Description = "that's shocking",
            TwistPrefix = "and has a"
        },
        {
            Name = "mischievous",
            Description = "full of mischief",
            TwistPrefix = "with a"
        },
        {
            Name = "festering",
            Description = "about festering",
            TwistPrefix = "with a"
        },
        {
            Name = "love",
            Description = "about love",
            TwistPrefix = "with a",
            TwistName = "loving"
        },
        {
            Name = "profitable",
            Description = "that's profitable",
            TwistPrefix = "with a"
        },
        {
            Name = "religious",
            Description = "that's religious",
            TwistPrefix = "with a"
        },
        {
            Name = "frightening",
            Description = "that's frightening",
            TwistPrefix = "and has a"
        },
        {
            Name = "violent",
            Description = "that's violent",
            TwistPrefix = "and has a"
        },
        {
            Name = "funny",
            Description = "full of jokes",
            TwistPrefix = "with a"
        },
        {
            Name = "wild",
            Description = "that's totally wild",
            TwistPrefix = "and has a"
        }
    }
}

local itemToLength = {}
for _, length in ipairs(bookModifiers.Length) do
    itemToLength[length.Item] = length
end

local numLengthChoices = 3
local numEffectChoices = 3

fiendfoliodirectory.emptybookactivate = {
    title = "empty book",
    fsize = 2,
    noscroll = true,
    format = {
        Panels = {
            {
                Panel = dssmod.panels.main,
                Offset = Vector(0, 0),
                Color = 1
            },
        }
    },
    buttons = {
        {str = "i want to read a", nosel = true},
        {str = "", fsize = 1, nosel = true},
        {variable = "EmptyBookLength", setting = 1, choices = {"null"}, inline = true},
        {str = "", fsize = 1, nosel = true},
        {variable = "EmptyBookEffect1", setting = 1, choices = {"null"}, inline = true},
        {str = "", fsize = 1, nosel = true},
        {str = "with a", nosel = true},
        {str = "", fsize = 1, nosel = true},
        {variable = "EmptyBookEffect2", setting = 1, choices = {"null"}, inline = true},
        {str = "", fsize = 1, nosel = true},
        {str = "twist!", nosel = true},
        {str = "", fsize = 1, nosel = true},
        {
            str = "write!",
            fsize = 3,
            action = "resume",
            func = function(button, item, tbl)
                local chosenLength = item.lengthchoices[item.buttons[3].setting]
                local chosenEffect1 = item.effect1choices[item.buttons[5].setting]
                local chosenEffect2 = item.effect2choices[item.buttons[9].setting]

                local addItem = chosenLength.Item
                local collectibleConfig = Isaac.GetItemConfig():GetCollectible(addItem)
                item.player:AnimateCollectible(addItem)
                item.player:AddCollectible(addItem, collectibleConfig.MaxCharges, true, item.slot, 0)

                FiendFolio.scheduleForUpdate(function()
                    -- there are really messed up visuals if you run this in get shader params for some reason
                    game:GetHUD():ShowItemText(item.player, collectibleConfig)
                end, 1)

                if not FiendFolio.savedata.run.emptybookeffects then
                    FiendFolio.savedata.run.emptybookeffects = {}
                end

                FiendFolio.savedata.run.emptybookeffects[chosenLength.Name] = {
                    chosenEffect1.Name,
                    chosenEffect2.Name
                }

                DeadSeaScrollsMenu.CloseMenu(true)
            end
        }
    },
    update = function(item)
        if item.lengthchoices then
            local selectedLength = item.lengthchoices[item.buttons[3].setting]
            if selectedLength.An then -- grammar is important :)
                item.buttons[1].str = "i want to read an"
            else
                item.buttons[1].str = "i want to read a"
            end
        end

        if item.effect1choices then
            local selectedEffect1 = item.effect1choices[item.buttons[5].setting]
            item.buttons[7].str = selectedEffect1.TwistPrefix
        end
    end,
    generate = function(item)
        item.lengthchoices = {}
        item.effect1choices = {}
        item.effect2choices = {}

        local lengths = StageAPI.Copy(bookModifiers.Length)
        local effects = StageAPI.Copy(bookModifiers.Effects)
        mod:Shuffle(effects)

        local existingEffects = FiendFolio.savedata.run.emptybookeffects
        local allExisting = not not existingEffects
        if existingEffects then
            for _, choice in ipairs(bookModifiers.Length) do
                if not existingEffects[choice.Name] then
                    allExisting = false
                end
            end
        end

        local lengthChoiceStrs = {}
        for i = 1, numLengthChoices do
            if not existingEffects or not existingEffects[lengths[i].Name] or allExisting then
                item.lengthchoices[#item.lengthchoices + 1] = lengths[i]
                lengthChoiceStrs[#lengthChoiceStrs + 1] = lengths[i].Name
            end
        end

        local effect1Strs = {}
        local effect2Strs = {}
        for i = 1, numEffectChoices * 2 do
            if i > numEffectChoices then
                item.effect2choices[#item.effect2choices + 1] = effects[i]
                effect2Strs[#effect2Strs + 1] = effects[i].TwistName or effects[i].Name

            else
                item.effect1choices[#item.effect1choices + 1] = effects[i]
                effect1Strs[#effect1Strs + 1] = effects[i].Description
            end
        end

        item.buttons[3].choices = lengthChoiceStrs
        item.buttons[3].setting = 1
        item.buttons[5].choices = effect1Strs
        item.buttons[5].setting = 1
        item.buttons[9].choices = effect2Strs
        item.buttons[9].setting = 1
        item.bsel = 3

    end,
}

function mod:UseEmptyBook(item, rng, player, useFlags, slot, varData)
    if item == FiendFolio.ITEM.COLLECTIBLE.EMPTY_BOOK and useFlags & UseFlag.USE_VOID == 0 then
        if useFlags & UseFlag.USE_CARBATTERY == 0 then
            fiendfoliodirectory.emptybookactivate.player = player
            fiendfoliodirectory.emptybookactivate.slot = slot
            DeadSeaScrollsMenu.OpenMenuToPath("Fiend Folio", 'emptybookactivate', nil, true)

            return {
                Remove = true,
                ShowAnim = true
            }
        end
    else
        local effects
        local multiplier
        if item ~= FiendFolio.ITEM.COLLECTIBLE.EMPTY_BOOK then
            local length = itemToLength[item]
            local existingEffects = FiendFolio.savedata.run.emptybookeffects
            if existingEffects and existingEffects[length.Name] then
                effects = existingEffects[length.Name]
                multiplier = length.EffectMultiplier
            end
        else
            effects = {"wild", "wild"}
            multiplier = 2
        end
        
        if effects and multiplier then
            for _, effect in ipairs(effects) do
                while effect == "wild" do
                    local randEffect = rng:RandomInt(#bookModifiers.Effects) + 1
                    effect = bookModifiers.Effects[randEffect].Name
                end

                if effect == "sad" then
                    player:GetEffects():AddCollectibleEffect(FiendFolio.ITEM.COLLECTIBLE.MY_STORY_NULL_TEARS, false, multiplier)
                elseif effect == "frightening" or effect == "shocking" or effect == "violent" then
                    if multiplier == 3 then
                        game:ShakeScreen(25)
                    else
                        game:ShakeScreen(10)
                    end

                    local range
                    if multiplier == 1 then
                        range = 140
                    end

                    local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
                    local duration = 240
                    local stage = game:GetLevel():GetStage()
                    local damage = 30 + stage * 4
                    if multiplier == 1 then -- shorter length book lasts longer but fears / bruises less enemies
                        duration = 210
                        damage = 15 + stage * 3
                    elseif multiplier == 2 then
                        duration = 150
                        damage = 20 + stage * 3
                    end

                    duration = duration * secondHandMultiplier

                    if effect == "shocking" then
                        duration = math.ceil(duration * 1.5)
                    end

                    for i, v in ipairs(Isaac.GetRoomEntities()) do
                        if v:IsVulnerableEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                            if not range or v.Position:DistanceSquared(player.Position) <= range ^ 2 then
                                if effect == "frightening" then
                                    v:AddFear(EntityRef(player), duration)
                                elseif effect == "shocking" then
                                    mod.AddBruise(v, player, duration, multiplier, (player.Damage / 2) * multiplier)
                                elseif effect == "violent" then
                                    v:TakeDamage(damage, 0, EntityRef(player), 0)
                                end
                            end
                        end
                    end
                elseif effect == "profitable" then
                    if multiplier == 1 then -- 2 pennies
                        for i = 1, 2 do
                            local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player)
                        end
                    elseif multiplier == 2 then -- a penny and a random coin
                        for i = 1, 2 do
                            local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
                            if i == 1 then
                                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player)
                            else
                                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, player)
                            end
                        end
                    elseif multiplier == 3 then -- a penny, a random coin, and a random pickup (it could be ANYTHING!)
                        for i = 1, 3 do
                            local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
                            if i == 3 then
                                Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, pos, Vector.Zero, player)
                            elseif i == 2 then
                                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, player)
                            else
                                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player)
                            end
                        end
                    end
                elseif effect == "religious" then
                    for i = 1, multiplier do
                        player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, player.Position, true, false)
                    end
					SFXManager():Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
                elseif effect == "love" then
                    local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
                    if multiplier == 1 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, pos, Vector.Zero, player)
                    elseif multiplier == 2 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, pos, Vector.Zero, player)
                    elseif multiplier == 3 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector.Zero, player)
                    end
                elseif effect == "funny" then
                    if multiplier == 1 then
                        game:ShakeScreen(5)
                        game:ButterBeanFart(player.Position, 280, player, true, true)
                    elseif multiplier == 2 then
                        game:ShakeScreen(10)
                        game:ButterBeanFart(player.Position, 280, player, false, true)
                        game:Fart(player.Position, 80, player, 1, 0)
                    elseif multiplier == 3 then
                        game:ShakeScreen(50)
                        for i = 45, 360, 45 do
                            game:Fart(player.Position + Vector(40, 0):Rotated(i), 80, player, 1, 0)
                        end
                    end
                elseif effect == "mischievous" then
                    for i = 1, multiplier do
                        local minion = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 0, player.Position, Vector.Zero, player)
                        minion:GetData().canreroll = false
                        minion.EntityCollisionClass = 4
                        minion.Parent = player
                        minion:GetData().hollow = true
                    end
                elseif effect == "festering" then
                    for i = 1, multiplier * 2 do
                        local skuzz = Isaac.Spawn(3, FiendFolio.ITEM.FAMILIAR.ATTACK_SKUZZ, 0, player.Position, Vector.Zero, player)
                        skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        skuzz:Update()
                    end
                end
            end
        end

        return true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseEmptyBook, FiendFolio.ITEM.COLLECTIBLE.EMPTY_BOOK)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseEmptyBook, FiendFolio.ITEM.COLLECTIBLE.MY_STORY_2)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseEmptyBook, FiendFolio.ITEM.COLLECTIBLE.MY_STORY_4)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseEmptyBook, FiendFolio.ITEM.COLLECTIBLE.MY_STORY_6)

local function tearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    if flag == CacheFlag.CACHE_FIREDELAY then
        local myStoryTears = player:GetEffects():GetCollectibleEffect(FiendFolio.ITEM.COLLECTIBLE.MY_STORY_NULL_TEARS)
        if myStoryTears and myStoryTears.Count > 0 then
            player.MaxFireDelay = tearsUp(player.MaxFireDelay, 0.25 * myStoryTears.Count)
        end
    end
end)