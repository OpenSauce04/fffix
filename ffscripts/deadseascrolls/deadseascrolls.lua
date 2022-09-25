local DSSModName = "Dead Sea Scrolls (Fiend Folio)"
local DSSCoreVersion = 6
local MenuProvider = {}
local game = Game()

-- Fiend Folio's menu code starts here!
function MenuProvider.SaveSaveData()
    FiendFolio.SaveSaveData()
end

function MenuProvider.GetPaletteSetting()
    return FiendFolio.savedata.MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    FiendFolio.savedata.MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
    return FiendFolio.savedata.MenuControllerToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    FiendFolio.savedata.MenuControllerToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return FiendFolio.savedata.MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    FiendFolio.savedata.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return FiendFolio.savedata.MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    FiendFolio.savedata.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return FiendFolio.savedata.MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    FiendFolio.savedata.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return FiendFolio.savedata.MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    FiendFolio.savedata.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return FiendFolio.savedata.MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    FiendFolio.savedata.MenusPoppedUp = var
end

local DSSInitializerFunction = include("ffscripts.deadseascrolls.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local NOTE1_RENDER_OFFSET = Vector(-116, -27)
local NOTE2_RENDER_OFFSET = Vector(-32, -27)
local NOTE3_RENDER_OFFSET = Vector(-74, -27)

local completionNoteSprite = Sprite()
completionNoteSprite:Load("gfx/ui/completion_widget.anm2")
completionNoteSprite:SetFrame("Idle", 0)
--completionNoteSprite.Scale = Vector.One / 2

local completionHead = Sprite()
completionHead:Load("gfx/ui/completion_heads_ff.anm2")
completionHead:SetFrame("Fiend", 0)

local completionDoor = Sprite()
completionDoor:Load("gfx/ui/completion_doors_ff.anm2")
completionDoor:SetFrame("Fiend", 0)

local completionCharacterSets = {
    {
        {HeadName = "Fiend", PlayerID = FiendFolio.PLAYER.FIEND, IsUnlocked = function() return true end},
        {HeadName = "Biend", PlayerID = FiendFolio.PLAYER.BIEND, IsUnlocked = function() return FiendFolio.ACHIEVEMENT.BIEND:IsUnlocked() end},
    },
    {
        {HeadName = "Golem", PlayerID = FiendFolio.PLAYER.GOLEM, IsUnlocked = function() return true end},
        {HeadName = "Bolem", PlayerID = FiendFolio.PLAYER.BOLEM, IsUnlocked = function() return false end},
    }
}

-- Sorry I need these here too for the note rendering!
local function getScreenBottomRight()
    return game:GetRoom():GetRenderSurfaceTopLeft() * 2 + Vector(442,286)
end

local function getScreenCenterPosition()
    return getScreenBottomRight() / 2
end

local completionNoteTip = {strset = {"press confirm", "to edit your", "completion", "note"}}
local areYouSureUnlockTag
local isUnlockingAll

local fiendfoliodirectory = {
    main = {
        title = 'fiend folio',
        buttons = {
            {str = 'resume game', action = 'resume'},
            {str = 'settings', dest = 'settings'},
            {str = "unlocks", dest = "unlocks", cursoroff = Vector(6, 0)},
			{str = 'credits', dest = 'awesomecredits'},
            dssmod.changelogsButton,
            {str = '', fsize = 2, nosel = true},
            {str = 'fiend folio is extra', fsize = 2, nosel = true},
            {str = 'compatible with the', fsize = 2, nosel = true},
            {str = 'retribution, bertran,', fsize = 2, nosel = true},
            {str = 'and tainted treasure', fsize = 2, nosel = true},
            {str = 'mods. check them out!', fsize = 2, nosel = true},
            {str = '', fsize = 2, nosel = true}
        },
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            {
                str = 'item toggles',
                dest = 'items',
            },
            {str = 'modify what can appear', fsize = 2, nosel = true},
            {str = '', fsize = 2, nosel = true},
            {
                str = 'random enemies',
                choices = {'folio replacements', 'all replacements', 'vanilla only', 'all disabled'},
                variable = 'FolioReplacements',
                setting = 1,
                load = function()
                    if FiendFolio.replacementsEnabled and not FiendFolio.legacyReplacementsEnabled then
                        return 1
                    elseif FiendFolio.replacementsEnabled and FiendFolio.legacyReplacementsEnabled then
                        return 2
                    elseif FiendFolio.legacyReplacementsEnabled then
                        return 3
                    else
                        return 4
                    end
                end,
                store = function(var)
                    FiendFolio.replacementsEnabled = (var == 1 or var == 2)
                    FiendFolio.legacyReplacementsEnabled = (var == 2 or var == 3)
                end,
                tooltip = {strset = {'configure', 'random enemy', 'replacement', ' ', 'folio mode', 'is default'}}
            },
            --[[{
                str = 'colour blind fix',
                choices = {'enabled', 'disabled'},
                variable = "ColourBlindMode",
                setting = 2,
                load = function()
                    if FiendFolio.ColourBlindMode then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.ColourBlindMode = (var == 1)
                end,
                tooltip = {strset = {'if enabled', 'green puzzle', 'blocks', 'become', 'yellow', 'with higher', 'brightness'}}
            },]]
			{
                str = 'vanilla ai changes',
                choices = {'enabled', 'disabled'},
                variable = "ChangeAi",
                cursoroff = Vector(6, 0),
                setting = 1,
                load = function()
                    if FiendFolio.ChangeAi then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.ChangeAi = (var == 1)
                end,
                tooltip = {strset = {'if enabled', 'some basegame', "enemies will", 'be modified', ' ', 'enabled by', 'default'}}
            },
			{
                str = 'custom fortunes',
                choices = {'enabled', 'disabled'},
                variable = "CustomFortunes",
                setting = 1,
                load = function()
                    if FiendFolio.CustomFortunesEnabled then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.CustomFortunesEnabled = (var == 1)
                end,
                tooltip = {strset = {'if enabled', 'there will be', 'increased', 'fortune', 'variety', '', 'enabled by', 'default'}}
            },
			{
                str = 'taunt hotkeys',
                choices = {'enabled', 'disabled'},
                variable = "HotkeyConfig.Taunts",
                setting = 1,
                load = function()
                    if FiendFolio.HotkeyConfig.Taunts then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.HotkeyConfig.Taunts = (var == 1)
                end,
                tooltip = {strset = {'if enabled', 'you can press ', '+ and -', 'to taunt!', '',  'enabled by', 'default'}}
            },
			{
                str = 'killbind hotkeys',
                choices = {'enabled', 'disabled'},
                variable = "HotkeyConfig.Killbinds",
                setting = 1,
                load = function()
                    if FiendFolio.HotkeyConfig.Killbinds then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.HotkeyConfig.Killbinds = (var == 1)
                end,
                tooltip = {strset = {'if enabled', 'you can press ', 'end and del', 'to die!', '',  'disabled by', 'default'}}
            },
			{
                str = 'new poop spells',
                choices = {'enabled', 'disabled'},
                variable = "WackyPoops",
                setting = 1,
                load = function()
                    if FiendFolio.WackyPoopsEnabled then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.WackyPoopsEnabled = (var == 1)
                end,
                tooltip = {strset = {'custom poops','for tainted', 'blue baby', '(changes', 'applied', 'on relaunch)', '', 'enabled by', 'default'}}
            },
            {
                str = 'boss pool rework',
                choices = {'enabled', 'disabled'},
                variable = "BossPoolOverhaul",
                cursoroff = Vector(6, 0),
                load = function()
                    if FiendFolio.BossPoolOverhaulEnabled then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.BossPoolOverhaulEnabled = (var == 1)
                end,
                tooltip = {strset = {'reworks', 'boss pools', 'for some', 'floors to', 'be more', 'unique', '', 'enabled by', 'default'}}
            },
            dssmod.paletteButton,
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            {
                str = '- hud -',
                nosel = true
            },
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            --[[ Name tags disabled for now, the tables haven't been updated!!
            {
                str = 'name tags',
                choices = {'disabled', 'always', 'toggle'},
                variable = "NameTags",
                setting = 3,
                load = function()
                    return FiendFolio.NameTags + 1
                end,
                store = function(var)
                    FiendFolio.NameTags = var - 1
                end,
                tooltip = {strset = {'if enabled', 'fiend folio', 'enemies will', 'have', 'name tags'}}
            },]]
            {
                str = 'name tag keybind',
                tooltip = {strset = {'sets', 'which key', 'will toggle', 'name tags'}},
                variable = "NameTagKeybind",
                setting = -1,
                keybind = true,
                load = function()
                    return FiendFolio.NameTagKeybind or -1
                end,
                store = function(var)
                    FiendFolio.NameTagKeybind = var
                end,
                displayif = function(_, item)
                    if item and item.buttons then
                        for _, button in ipairs(item.buttons) do
                            if button.str == 'name tags' then
                                return button.setting == 3
                            end
                        end
                    end

                    return false
                end,
            },
            {
                str = 'show room names',
                choices = {'always', 'temporary', 'disabled', 'with map'},
                variable = "ShowRoomNames",
                setting = 1,
                load = function()
                    return FiendFolio.ShowRoomNames
                end,
                store = function(var)
                    FiendFolio.ShowRoomNames = var
                end,
                tooltip = {strset = {'enable to', 'know', 'who to blame', 'for that', 'unfair room'}}
            },
            {
                str = 'room name alpha',
                increment = 1, max = 9,
                variable = "RoomNameOpacity",
                slider = true,
                setting = 1,
                load = function()
                    return FiendFolio.RoomNameOpacity
                end,
                store = function(var)
                    FiendFolio.RoomNameOpacity = var
                end,
                displayif = function(_, item)
                    if item and item.buttons then
                        for _, button in ipairs(item.buttons) do
                            if button.str == 'show room names' then
                                return button.setting ~= 3
                            end
                        end
                    end

                    return false
                end
            },
            {
                str = 'room name scale',
                choices = {'big', 'small', 'force small'},
                variable = "RoomNameScale",
                setting = 1,
                load = function()
                    return FiendFolio.RoomNameScale
                end,
                store = function(var)
                    FiendFolio.RoomNameScale = var
                end,
                displayif = function(_, item)
                    if item and item.buttons then
                        for _, button in ipairs(item.buttons) do
                            if button.str == 'show room names' then
                                return button.setting ~= 3
                            end
                        end
                    end

                    return false
                end
            },
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            {
                str = '- wackies -',
                nosel = true
            },
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            {
                str = 'great fortune',
                choices = {'enabled', 'disabled'},
                variable = "GreatFortune",
                setting = 2,
                load = function()
                    if FiendFolio.GreatFortune then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.GreatFortune = (var == 1)
                end,
                tooltip = {strset = {'enable to', 'learn', 'your fortune', 'when firing', 'tears'}}
            },
            {
                str = 'folio mode',
                choices = {'classic', 'mern', 'super easy', 'stable', 'popo modo'},
                variable = "FolioMode",
                setting = 1,
                load = function()
                    return FiendFolio.ModeEnabled + 1
                end,
                store = function(var)
                    FiendFolio.ModeEnabled = var - 1
                end,
                tooltip = {strset = {'change', 'to enable', 'wacky new', 'modes of', 'play', "", "classic", "by default"}}
            },
            {
                str = 'waterstro name',
                choices = {'monsoon', 'moistro', 'jack the dripper', 'j.m. the dripper', 'j.m. the m.d.', 'random'},
                variable = "MonsoonName",
                setting = 1,
                load = function()
                    return FiendFolio.MonsoonName or 1
                end,
                store = function(var)
                    FiendFolio.MonsoonName = var
                end,
                changefunc = function(button)
                    FiendFolio.MonsoonName = button.setting
                    local monsoonData = StageAPI.GetBossData("Moistro")

                    if FiendFolio.MonsoonName == 6 then
                        monsoonData.Bossname = FiendFolio.MonsoonNames[math.random(1, 5)]
                    else
                        monsoonData.Bossname = FiendFolio.MonsoonNames[FiendFolio.MonsoonName]
                    end
                end
            },
            {
                str = 'warp zone name',
                choices = {'warp zone', 'warp zooooone', 'mega portal', 'random'},
                variable = "WarpZoneName",
                setting = 1,
                load = function()
                    return FiendFolio.WarpZoneName or 1
                end,
                store = function(var)
                    FiendFolio.WarpZoneName = var
                end,
                changefunc = function(button)
                    FiendFolio.WarpZoneName = button.setting
                    local warpzoneData = StageAPI.GetBossData("Warp Zone")

                    if FiendFolio.WarpZoneName == 4 then
                        warpzoneData.BossName = FiendFolio.WarpZoneNames[math.random(1, 3)]
                    else
                        warpzoneData.BossName = FiendFolio.WarpZoneNames[FiendFolio.WarpZoneName]
                    end
                end
            },
            {
                str = 'community decision',
                choices = {'all enemies appear', 'vote them out!'},
                variable = "TrueVoteOutcome",
                setting = 1,
                cursoroff = Vector(6, 0),
                load = function()
					if FiendFolio.TrueVoteOutcome then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.TrueVoteOutcome = (var == 2)
                end,
                tooltip = {strset = {'remove', 'dogmeat and', 'calzone like', 'the community', 'wanted'}}
            },
            {
                str = 'classic fiend',
                choices = {'enabled', 'disabled'},
                variable = 'FiendClassicTears',
                setting = 2,
                load = function()
                    if FiendFolio.FiendConfig.ClassicTears then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.FiendConfig.ClassicTears = (var == 1)
                end,
                tooltip = {strset = {'if enabled', "fiend's tears", 'become', 'more faithful', "to devil's", "harvest"}}
            },
            {
                str = 'imp baby mode',
                choices = {'enabled', 'disabled'},
                variable = "ImpBabyMode",
                setting = 2,
                load = function()
                    if FiendFolio.FiendConfig.ImpBabyMode then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.FiendConfig.ImpBabyMode = (var == 1)
                end,
                tooltip = {strset = {'please', 'do not', 'enable', 'this setting'}}
            },
            {str = '', fsize = 2, nosel = true},
            {
                str = 'data harvesting',
                dest = 'dataharvesting',
            },
            {str = 'choose how your data', fsize = 2, nosel = true},
            {str = 'gets processed', fsize = 2, nosel = true},
            {str = '', fsize = 2, nosel = true},
        },
        tooltip = dssmod.menuOpenToolTip
    },
    items = {
        title = 'item toggles',
        buttons = {
            {str = "please don't disable", fsize = 2, nosel = true},
            {str = 'our epic items :(', fsize = 2, nosel = true},
            {str = '', fsize = 1, nosel = true},
            {
                str = 'fiend folio items',
                choices = {'enabled', 'disabled'},
                variable = "FolioItems",
                setting = 1,
                load = function()
                    if FiendFolio.ItemsEnabled then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.ItemsEnabled = (var == 1)
                end,
                tooltip = {strset = {'can be used', 'to disable', "fiend folio's", 'new items'}}
            },
            {
                str = 'fiend folio cards',
                choices = {'enabled', 'disabled'},
                variable = "FolioCards",
                setting = 1,
                load = function()
                    if FiendFolio.CardsEnabled then
                        return 1
                    else
                        return 2
                    end
                end,
                store = function(var)
                    FiendFolio.CardsEnabled = (var == 1)
                end,
                tooltip = {strset = {'can be used', 'to disable', "fiend folio's", 'new pocket', 'items'}}
            },
            {
                str = '',
                fsize = 1,
                nosel = true
            },
            {str = "mods with matching names", fsize = 2, nosel = true},
            {str = "should be compatible, but", fsize = 2, nosel = true},
            {str = "you can disable ours", fsize = 2, nosel = true},
            {str = "here to reduce confusion", fsize = 2, nosel = true},
            {str = '', fsize = 1, nosel = true},
            {
                str = '- items -',
                nosel = true
            },
            {str = '', fsize = 2, nosel = true},
            {
                str = 'opihuchus',
                choices = {'enabled', 'disabled'},
                variable = "OpihuchusEnabled",
                setting = 1,
                load = function()
                    return (FiendFolio.ItemConfig.OpihuchusDisabled and 2) or 1
                end,
                store = function(var)
                    FiendFolio.ItemConfig.OpihuchusDisabled = var == 2
                end,
                tooltip = {strset = {'disables', "fiend folio's", 'opihuchus', '', 'enabled by', 'default'}}
            },
            {
                str = 'cetus',
                choices = {'enabled', 'disabled'},
                variable = "CetusEnabled",
                setting = 1,
                load = function()
                    return (FiendFolio.ItemConfig.CetusDisabled and 2) or 1
                end,
                store = function(var)
                    FiendFolio.ItemConfig.CetusDisabled = var == 2
                end,
                tooltip = {strset = {'disables', "fiend folio's", 'cetus', '', 'enabled by', 'default'}}
            },
            {str = '', fsize = 2, nosel = true},
            {
                str = '- cards -',
                nosel = true
            },
            {str = '', fsize = 2, nosel = true},
            {
                str = 'kings',
                choices = {'all enabled', 'playing cards disabled', 'minor arcana disabled', 'all disabled'},
                variable = 'KingCardsEnabled',
                setting = 1,
                load = function()
                    if FiendFolio.CardConfig.ArcanaKingCardsDisabled and FiendFolio.CardConfig.PlayingKingCardsDisabled then
                        return 4
                    elseif FiendFolio.CardConfig.ArcanaKingCardsDisabled then
                        return 3
                    elseif FiendFolio.CardConfig.PlayingKingCardsDisabled then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.CardConfig.ArcanaKingCardsDisabled = (var == 3 or var == 4)
                    FiendFolio.CardConfig.PlayingKingCardsDisabled = (var == 2 or var == 4)
                end,
                tooltip = {strset = {'disables', 'custom', 'fiend folio', 'king cards', '', 'enabled by', 'default'}}
            },
            {
                str = 'queens',
                choices = {'all enabled', --[[ 'playing cards disabled', 'minor arcana disabled',]] 'all disabled'}, -- for now, there aren't any minor arcana queens, so just disabling playing queens should be fine
                variable = 'QueenCardsEnabled',
                setting = 1,
                load = function()
                    if FiendFolio.CardConfig.ArcanaQueenCardsDisabled and FiendFolio.CardConfig.PlayingQueenCardsDisabled then
                        return 4
                    elseif FiendFolio.CardConfig.ArcanaQueenCardsDisabled then
                        return 3
                    elseif FiendFolio.CardConfig.PlayingQueenCardsDisabled then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.CardConfig.ArcanaQueenCardsDisabled = (var == 3 or var == 4)
                    FiendFolio.CardConfig.PlayingQueenCardsDisabled = (var == 2 or var == 4)
                end,
                tooltip = {strset = {'disables', 'custom', 'fiend folio', 'queen cards', '', 'enabled by', 'default'}}
            },
            {
                str = 'jacks',
                choices = {'all enabled', --[[ 'playing cards disabled', 'minor arcana disabled',]] 'all disabled'},
                variable = 'JackCardsEnabled',
                setting = 1,
                load = function()
                    if FiendFolio.CardConfig.ArcanaJackCardsDisabled and FiendFolio.CardConfig.PlayingJackCardsDisabled then
                        return 4
                    elseif FiendFolio.CardConfig.ArcanaJackCardsDisabled then
                        return 3
                    elseif FiendFolio.CardConfig.PlayingJackCardsDisabled then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.CardConfig.ArcanaJackCardsDisabled = (var == 3 or var == 4)
                    FiendFolio.CardConfig.PlayingJackCardsDisabled = (var == 2 or var == 4)
                end,
                tooltip = {strset = {'disables', 'custom', 'fiend folio', 'jack cards', '', 'enabled by', 'default'}}
            },
            {
                str = 'twos',
                choices = {'all enabled', 'all disabled'},
                variable = 'MinorTwoCardsEnabled',
                setting = 1,
                load = function()
                    if FiendFolio.CardConfig.ArcanaTwoCardsDisabled then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.CardConfig.ArcanaTwoCardsDisabled = var == 2
                end,
                tooltip = {strset = {'disables', 'custom', 'fiend folio', 'two cards', '', 'enabled by', 'default'}}
            },
            {
                str = 'threes',
                choices = {'all enabled', 'playing cards disabled', 'minor arcana disabled', 'all disabled'},
                variable = 'ThreeCardsEnabled',
                setting = 1,
                load = function()
                    if FiendFolio.CardConfig.ArcanaThreeCardsDisabled and FiendFolio.CardConfig.PlayingThreeCardsDisabled then
                        return 4
                    elseif FiendFolio.CardConfig.ArcanaThreeCardsDisabled then
                        return 3
                    elseif FiendFolio.CardConfig.PlayingThreeCardsDisabled then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.CardConfig.ArcanaThreeCardsDisabled = (var == 3 or var == 4)
                    FiendFolio.CardConfig.PlayingThreeCardsDisabled = (var == 2 or var == 4)
                end,
                tooltip = {strset = {'disables', 'custom', 'fiend folio', 'three cards', '', 'enabled by', 'default'}}
            },
        },
    },
    dataharvesting = {
        title = 'data harvesting',
        buttons = {
            {str = 'modify what data', fsize = 2, nosel = true},
            {str = 'you provide to us', fsize = 2, nosel = true},
            {str = '', fsize = 2, nosel = true},
            {str = '- personal info -', nosel = true},
            {str = '', fsize = 2, nosel = true},
            {
                str = 'name',
                choices = {'michael', 'jon', "maria", "peter", "julia", "jon", "steven", "harry", "tom", "bethany", "jeremy", "sam", "james", 'kalu', 'jon', 'earl', 'reimu', 'sephiroth', 'may', 'john', 'holly', 'noelle', 'joe', 'kris', 'rigby'},
                variable = 'DataHarvestName',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Name
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Name = var
                end,
                tooltip = {strset = {'what is your', 'name'}}
            },
            {
                str = 'home address',
                choices = {"39 jersey south", "10 caxton laurels", "23 jethan drive", "17 lane pines", "33 tewkesbury nook", "42 peter walk", "40 wykeham knoll", "15 avenue place", "16 lowther green", "35 deans ridge", "100 billion bean road", "742 evergreen terrace", "31 spooner street", "416 cherry street", "221b baker street", "1600 pennsylvania avenue", "350 fifth avenue", "62 west wallaby street", "29 acacia road", "124 conch street", "13 mushroom alley"},
                variable = 'DataHarvestAddress',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Address
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Address = var
                end,
                tooltip = {strset = {'what is your', 'home address'}}
            },
            {
                str = 'phone number',
                increment = 1, max = 9999999999,
                variable = 'DataHarvestPhoneNumber',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.PhoneNumber
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.PhoneNumber = var
                end,
                tooltip = {strset = {'what is your', 'phone number'}}
            },
            {
                str = 'credit card number',
                increment = 1, max = 9999999999999999,
                variable = 'DataHarvestCreditNumber',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.CreditNumber
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.CreditNumber = var
                end,
                tooltip = {strset = {'what is your', 'credit card', 'number'}}
            },
            {
                str = 'class',
                choices = {"lower", "middle", "upper", "scout", "soldier", "pyro", "demoman", "heavy", "engineer", "medic", "sniper", "spy", "civilian", "artificer", "barbarian", "bard", "cleric", "druid", "fighter", "monk", "paladin", "ranger", "rogue", "sorcerer", "warlock", "wizard"},
                variable = 'DataHarvestClass',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Class
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Class = var
                end,
                tooltip = {strset = {'what is your', 'class'}}
            },
            {
                str = 'age',
                increment = 1, max = 25,
                slider = true,
                variable = 'DataHarvestAge',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Age
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Age = var
                end,
                tooltip = {strset = {'what is your', 'age'}}
            },
            {
                str = 'gender',
                increment = 1, max = 25,
                slider = true,
                variable = 'DataHarvestGender',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Gender
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Gender = var
                end,
                tooltip = {strset = {'what is your', 'gender'}}
            },
            {
                str = 'height',
                increment = 1, max = 25,
                slider = true,
                variable = 'DataHarvestHeight',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Height
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Height = var
                end,
                tooltip = {strset = {'what is your', 'height'}}
            },
            {
                str = 'weight',
                increment = 1, max = 25,
                slider = true,
                variable = 'DataHarvestWeight',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Weight
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Weight = var
                end,
                tooltip = {strset = {'what is your', 'weight'}}
            },
            {
                str = 'net worth',
                increment = 1, max = 25,
                slider = true,
                variable = 'DataHarvestNetWorth',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.NetWorth
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.NetWorth = var
                end,
                tooltip = {strset = {'what is your', 'net worth'}}
            },
            {
                str = 'level',
                increment = 1, max = 25,
                slider = true,
                variable = 'DataHarvestLevel',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Level
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Level = var
                end,
                tooltip = {strset = {'what is your', 'level'}}
            },
            {
                str = 'limb count',
                increment = 1, max = 16,
                slider = true,
                variable = 'DataHarvestLimbCount',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.LimbCount
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.LimbCount = var
                end,
                tooltip = {strset = {'what is your', 'number of', 'limbs'}}
            },
            {str = '', fsize = 2, nosel = true},
            {str = '- tastes - ', nosel = true},
            {str = '', fsize = 2, nosel = true},
            {
                str = 'pet preference',
                choices = {'dogs', 'cats', 'fish', 'rabbits', 'horses', 'reptiles', 'rodents', 'birds', 'bugs', 'other'},
                variable = 'DataHarvestPetPreference',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Pet
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Pet = var
                end,
                tooltip = {strset = {'what is your', 'favorite pet'}}
            },
            {
                str = 'favorite color',
                choices = {'red', 'scarlet', 'vermillion', 'persimmon', 'orange', 'orange peel', 'amber', 'golden yellow', 'yellow', 'lemon-lime', 'chartreuse', 'apple green', 'green', 'viridian', 'teal', 'cerulean', 'blue', 'indigo', 'violet', 'amethyst', 'purple', 'aubergine', 'magenta', 'crimson'},
                variable = 'DataHarvestColorPreference',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Pet
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.Pet = var
                end,
                tooltip = {strset = {'what is your', 'favorite', 'color'}}
            },
            {
                str = 'favorite dev',
                choices = {"fiend", "budj", "blorengerhymes", "bustin blotch", "cadence (ciirulean)", "cake", "cometz", "connor", "creeps", "deadinfinity", "erfly", "ferrium" ,"fuyucchi (maria)","guillotine-21", "gummy", "guwahavel", "happyhead", "jd", "jerb", "jm2k (julia)", "jordy", "minichibis", "notyoursagittarius", "orisghost", "oroshibu", "peas", "peribot", "pixl", "pkpseudo", "poyo", "redrachis", "renren", "sadly just al", "sbody2", "sin", "snakeblock", "sunil_b", "taigatreant", "thx", "titaniumgrunt7 (vermin)", "xalum"},
                variable = 'DataHarvestDevPreference',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.Dev
                end,
                store = function(var)
                    if var == 18 then
                        FiendFolio.savedata.JDMode = true
                    else
                        FiendFolio.savedata.JDMode = nil
                    end
                    FiendFolio.DataHarvesting.Dev = var
                end,
                tooltip = {strset = {'who is your', 'favorite', 'dev'}}
            },
            {str = '', fsize = 2, nosel = true},
            {str = '- cookies -', nosel = true},
            {str = '', fsize = 2, nosel = true},
            {
                str = 'essential cookies',
                choices = {"enabled"},
                variable = 'DataHarvestCookiesEssential',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.CookiesEssential
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.CookiesEssential = var
                end,
                tooltip = {strset = {'essential', 'cookies'}}
            },
            {
                str = 'tracking cookies',
                choices = {"enabled"},
                variable = 'DataHarvestCookiesTracking',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.CookiesTracking
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.CookiesTracking = var
                end,
                tooltip = {strset = {'allows us', 'to track you', 'online'}}
            },
            {
                str = 'bitcoin mining',
                choices = {"enabled", "initialized", "activated", "engaged", "allowed"},
                variable = 'DataHarvestBitcoinMining',
                setting = 1,
                load = function()
                    return FiendFolio.DataHarvesting.BitcoinMining
                end,
                store = function(var)
                    FiendFolio.DataHarvesting.BitcoinMining = var
                end,
                tooltip = {strset = {'allows for', 'mining of', 'bitcoin on', 'your machine'}}
            },
        },
    },
    unlocks = {
        title = "unlocks",
        buttons = {
            {str = "achievements", dest = "achievementviewer", tooltip = {strset = {"view all", "your cool", "finds!"}}},
            {str = "completion notes", dest = "completionnotes", cursoroff = Vector(6, 0), tooltip = {strset = {"check out", "your progress!"}}},
            {str = "unlock manager", dest = "unlocksmanager", tooltip = {strset = {"configuration", "options", "for unlocks!"}}}
        },
        tooltip = {strset = {"fiend folio", "has", tostring(#FiendFolio.ACHIEVEMENT_ORDERED), "unlocks for", "you to find!"}}
    },
    completionnotes = {
        title = "completion notes",
        nocursor = true,
        buttons = {
            {str = ""},
            {str = ""},

            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "", fsize = 2, nosel = true},

            {
                str = "press down for golem",
                nosel = true,
                fsize = 1,

                displayif = function(_, item)
                    return item.bsel == 1
                end,
            },
            {
                str = "press up for fiend",
                nosel = true,
                fsize = 1,

                displayif = function(_, item)
                    return item.bsel > 1
                end,
            },
        },

        postrender = function(item, tbl)
            if item.bsel > 2 then item.bsel = 1 end -- Idk why DSS is letting me pick a third option in the menu with only 2 non-nosel buttons but whatever

            local centre = getScreenCenterPosition()
            local renderDataset = completionCharacterSets[item.bsel]
            local offsets = {NOTE1_RENDER_OFFSET, NOTE2_RENDER_OFFSET}
            if #renderDataset == 1 then offsets = {NOTE3_RENDER_OFFSET} end

            for index, renderData in pairs(renderDataset) do
                if renderData.IsUnlocked() then
                    local dataset = FiendFolio.GetCompletionNoteLayerDataFromPlayerType(renderData.PlayerID)
                    for index, value in pairs(dataset) do
                        completionNoteSprite:SetLayerFrame(index, value)
                    end
                    completionHead:SetFrame(renderData.HeadName, 0)

                    completionNoteSprite:Render(centre + offsets[index], Vector.Zero, Vector.Zero)
                    completionHead:Render(centre + offsets[index] + Vector(30, 85), Vector.Zero, Vector.Zero)
                else
                    completionHead:SetFrame(renderData.HeadName, 1)
                    completionHead:Render(centre + offsets[index] + Vector(30, 85), Vector.Zero, Vector.Zero)

                    completionDoor:SetFrame(renderDataset[index - 1].HeadName, 0)
                    completionDoor:Render(centre + offsets[index], Vector.Zero, Vector.Zero)
                end
            end
        end,
        
        generate = function(item)
            local numAchievements = FiendFolio.TOTAL_COMPLETION_ACHIEVEMENTS
            local numCompleted = FiendFolio.GetNumCompletedAchievements() + 5
            local asPercent = string.format("%.f%%", (numCompleted / numAchievements) * 100)
            local extra = ""
            if numCompleted > numAchievements then
                extra = "!?!"
            elseif numCompleted == numAchievements then
                extra = "!!"
            end
            item.tooltip = {strset = {"you're", asPercent, "done with", "fiend folio!" .. extra}}
        end
    },
    unlocksmanager = {
        title = "unlocks manager",
        fsize = 2,

        buttons = {
            {str = "", nosel = true},
            {
                str = "achievements",
                fsize = 3,
                choices = {"enabled", "disabled"},
                variable = "AchievementsEnabled",
                setting = 1,
                load = function()
                    if FiendFolio.savedata.disableAchievements then
                        return 2
                    else
                        return 1
                    end
                end,
                store = function(var)
                    FiendFolio.savedata.disableAchievements = var == 2
                end,
                tooltip = {strset = {'change this', 'to enable or', 'disable all', 'unlocks.', "we'll still", 'keep track', 'for you!'}}
            },
            {str = "", nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = nil isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = nil isUnlockingAll = false end},
            {str = "", nosel = true},
            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {str = "character unlocks", fsize = 3, nosel = true},
            {str = "", nosel = true},
            {str = "fiend", fsize = 3, dest = "fiendunlocks"},
            {str = "tainted fiend", fsize = 3, dest = "biendunlocks", displayif = function() return FiendFolio.ACHIEVEMENT.BIEND:IsUnlocked() end},
            {str = "golem", fsize = 3, dest = "golemunlocks"},
            {str = "", nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Character" isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Character" isUnlockingAll = false end},
            {str = "", nosel = true},

            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {str = "challenge unlocks", fsize = 3, nosel = true},
            {str = "", fsize = 3, nosel = true},
            -- this isn't a real button, gets replaced later with list of unlocks automatically
            {insertUnlockTag = "Challenge"},
            {str = "", nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Challenge" isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Challenge" isUnlockingAll = false end},
            {str = "", nosel = true},

            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {str = "other unlocks", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {insertUnlockTag = "Misc"},
            {str = "", fsize = 3, nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Misc" isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Misc" isUnlockingAll = false end},
        },
    },
    fiendunlocks = {
        title = "fiend unlocks",
        fsize = 2,
        buttons = {
            {str = "", nosel = true},
            {str = "completion note", fsize = 3, dest = "fiendcompletion", tooltip = completionNoteTip},
            {str = "", nosel = true},
            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {insertUnlockTag = "BiendUnlock"},
            {str = "", nosel = true},
            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {str = "item unlocks", fsize = 3, nosel = true},
            {str = "", fsize = 3, nosel = true},
            {insertUnlockTag = "Fiend"},
            {str = "", nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Fiend" isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Fiend" isUnlockingAll = false end},
            {str = "", nosel = true},
        }
    },
    fiendcompletion = {
        title = "fiend completion",
        fsize = 2,
        buttons = {
            {
                str = "mom's heart / it lives",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_heart",
                setting = 1,

                load = function()
                    return FiendFolio.savedata.completion.fiend.heart + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.heart = var - 1
                end,

                tooltip = {strset = {"lil fiend", "", "unlocks on", "hard"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "isaac",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_isaac",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.isaac + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.isaac = var - 1
                end,

                tooltip = {strset = {"imp soda", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "???",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_bluebaby",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.bbaby + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.bbaby = var - 1
                end,

                tooltip = {strset = {"shard of", "china", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "satan",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_satan",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.satan + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.satan = var - 1
                end,

                tooltip = {strset = {"fiend mix", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "the lamb",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_lamb",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.lamb + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.lamb = var - 1
                end,

                tooltip = {strset = {"prank cookie", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "boss rush",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_rush",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.rush + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.rush = var - 1
                end,

                tooltip = {strset = {"gmo corn", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "hush",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_hush",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.hush + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.hush = var - 1
                end,

                tooltip = {strset = {"+3 fireballs", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mega satan",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_megasatan",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.mega + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.mega = var - 1
                end,

                tooltip = {strset = {"pyromancy", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "ultra greed(ier)",
                choices = {"uncompleted", "completed: greed", "completed: greedier"},
                variable = "fiend_greed",
                setting = 1,

                load = function()
                    return FiendFolio.savedata.completion.fiend.greed + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.greed = var - 1
                end,

                tooltip = {strset = {"cool", "sunglasses", "unlocks on", "greed+", "", "jack cards", "unlock on", "greedier"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "delirium",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_delirium",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.deli + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.deli = var - 1
                end,

                tooltip = {strset = {"fiends horn", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mother",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_mother",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.mother + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.mother = var - 1
                end,

                tooltip = {strset = {"the devils", "harvest", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "beast",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "fiend_beast",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiend.beast + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiend.beast = var - 1
                end,

                tooltip = {strset = {"fetal fiend", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {str = "the fiend folio", nosel = true},
            {str = "unlocked by beating everything on hard", fsize = 1, nosel = true},
            {str = "", nosel = true},
        },
    },
    biendunlocks = {
        title = "t. fiend unlocks",
        fsize = 2,
        buttons = {
            {str = "", nosel = true},
            {str = "completion note", fsize = 3, dest = "biendcompletion", tooltip = completionNoteTip},
            {str = "", nosel = true},
            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {str = "item unlocks", fsize = 3, nosel = true},
            {str = "", fsize = 3, nosel = true},
            {insertUnlockTag = "Biend"},
            {str = "", nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Biend" isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Biend" isUnlockingAll = false end},
            {str = "", nosel = true},
        }
    },
    biendcompletion = {
        title = "t. fiend completion",
        fsize = 2,
        buttons = {
            {
                str = "mom's heart / it lives",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_heart",
                setting = 1,

                load = function()
                    return FiendFolio.savedata.completion.fiendb.heart + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.heart = var - 1
                end,

                tooltip = {strset = {"no unlock"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "isaac",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_isaac",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.isaac + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.isaac = var - 1
                end,

                tooltip = {strset = {"chunk of", "tar", "", "quartet:", "beat isaac,", "???, satan", "and the lamb", "on normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "???",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_bluebaby",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.bbaby + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.bbaby = var - 1
                end,

                tooltip = {strset = {"chunk of", "tar", "", "quartet:", "beat isaac,", "???, satan", "and the lamb", "on normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "satan",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_satan",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.satan + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.satan = var - 1
                end,

                tooltip = {strset = {"chunk of", "tar", "", "quartet:", "beat isaac,", "???, satan", "and the lamb", "on normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "the lamb",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_lamb",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.lamb + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.lamb = var - 1
                end,

                tooltip = {strset = {"chunk of", "tar", "", "quartet:", "beat isaac,", "???, satan", "and the lamb", "on normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "boss rush",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_rush",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.rush + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.rush = var - 1
                end,

                tooltip = {strset = {"soul of", "fiend", "", "duet:", "beat boss", "rush and hush", "on normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "hush",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_hush",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.hush + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.hush = var - 1
                end,

                tooltip = {strset = {"soul of", "fiend", "", "duet:", "beat boss", "rush and hush", "on normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mega satan",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_megasatan",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.mega + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.mega = var - 1
                end,

                tooltip = {strset = {"dire chest", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "ultra greed(ier)",
                choices = {"uncompleted", "completed: greed", "completed: greedier"},
                variable = "biend_greed",
                setting = 1,

                load = function()
                    return FiendFolio.savedata.completion.fiendb.greed + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.greed = var - 1
                end,

                tooltip = {strset = {"+3 fireballs?", "", "unlocks on", "greedier"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "delirium",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_delirium",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.deli + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.deli = var - 1
                end,

                tooltip = {strset = {"malice", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mother",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_mother",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.mother + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.mother = var - 1
                end,

                tooltip = {strset = {"hatred", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "beast",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "biend_beast",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.fiendb.beast + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.fiendb.beast = var - 1
                end,

                tooltip = {strset = {"modern", "ouroboros", "", "unlocks on", "normal+"}}
            }
        },
    },
    golemunlocks = {
        title = "golem unlocks",
        fsize = 2,
        buttons = {
            {str = "", nosel = true},
            {str = "completion note", fsize = 3, dest = "golemcompletion", tooltip = completionNoteTip},
            {str = "", nosel = true},
            {str = "-----------------", fsize = 3, nosel = true},
            {str = "", fsize = 1, nosel = true},
            {str = "item unlocks", fsize = 3, nosel = true},
            {str = "", fsize = 3, nosel = true},
            {insertUnlockTag = "Golem"},
            {str = "", nosel = true},
            {str = "unlock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Golem" isUnlockingAll = true end},
            {str = "lock all", dest = "areyousure", func = function() areYouSureUnlockTag = "Golem" isUnlockingAll = false end},
            {str = "", nosel = true},
        }
    },
    golemcompletion = {
        title = "golem completion",
        fsize = 2,
        buttons = {
            {
                str = "mom's heart / it lives",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_heart",
                setting = 1,

                load = function()
                    return FiendFolio.savedata.completion.golem.heart + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.heart = var - 1
                end,

                tooltip = {strset = {"pet rock", "", "unlocks on", "hard"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "isaac",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_isaac",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.isaac + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.isaac = var - 1
                end,

                tooltip = {strset = {"golem's rock", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "???",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_bluebaby",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.bbaby + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.bbaby = var - 1
                end,

                tooltip = {strset = {"golem's orb", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "satan",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_satan",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.satan + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.satan = var - 1
                end,

                tooltip = {strset = {"cherry bomb", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "the lamb",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_lamb",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.lamb + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.lamb = var - 1
                end,

                tooltip = {strset = {"bridge bombs", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "boss rush",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_rush",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.rush + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.rush = var - 1
                end,

                tooltip = {strset = {"solemn vow", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "hush",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_hush",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.hush + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.hush = var - 1
                end,

                tooltip = {strset = {"dice goblin", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mega satan",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_megasatan",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.mega + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.mega = var - 1
                end,

                tooltip = {strset = {"massive", "amethyst", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "ultra greed(ier)",
                choices = {"uncompleted", "completed: greed", "completed: greedier"},
                variable = "golem_greed",
                setting = 1,

                load = function()
                    return FiendFolio.savedata.completion.golem.greed + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.greed = var - 1
                end,

                tooltip = {strset = {"molten penny", "unlocks on", "greed+", "", "nyx", "unlocks on", "greedier"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "delirium",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_delirium",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.deli + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.deli = var - 1
                end,

                tooltip = {strset = {"perfectly", "generic object", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mother",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_mother",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.mother + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.mother = var - 1
                end,

                tooltip = {strset = {"eternal d12", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "beast",
                choices = {"uncompleted", "completed: normal", "completed: hard"},
                variable = "golem_beast",
                setting = 1,
                
                load = function()
                    return FiendFolio.savedata.completion.golem.beast + 1 or 1
                end,

                store = function(var)
                    FiendFolio.savedata.completion.golem.beast = var - 1
                end,

                tooltip = {strset = {"astropulvis", "", "unlocks on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {str = "snow globe", nosel = true},
            {str = "unlocked by beating everything on hard", fsize = 1, nosel = true},
            {str = "", nosel = true},
        },
    },
    areyousure = {
        title = "are you sure?",
        buttons = {
            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "no", action = "back", glowcolor = 3},
            {str = "", fsize = 2, nosel = true},
            {
                str = "yes",
                action = "back",

                func = function(button, item, root)
                    local achievements = FiendFolio.GetAchievementsWithTag(areYouSureUnlockTag)
                    for _, achievement in ipairs(achievements) do
                        if isUnlockingAll == true then
                            achievement:Unlock(true)
                        else
                            achievement:SetUnlocked(false)
                        end
                    end

                    dssmod.reloadButtons(root, root.Directory.fiendunlocks)
                    dssmod.reloadButtons(root, root.Directory.biendunlocks)
                    dssmod.reloadButtons(root, root.Directory.golemunlocks)
                    dssmod.reloadButtons(root, root.Directory.unlocksmanager)
                end,
            },

            {str = "", nosel = true},
            {str = "you will have to start a new run in", nosel = true, fsize = 1, glowcolor = 3},
            {str = "order for these changes to take effect", nosel = true, fsize = 1, glowcolor = 3},
        },
    },
    unlockspopup = {
        title = "achievements?",
        fsize = 1,
        buttons = {
            {str = "fiendfolio comes with a large list", nosel = true},
            {str = "of unlockables for you to discover", nosel = true},
            {str = "", nosel = true},
            {str = "this is an optional feature", nosel = true},
            
            {str = "", nosel = true},
            {str = "do you want to lock", fsize = 2, nosel = true},
            {str = "some content behind", fsize = 2, nosel = true},
            {str = "achievements?", fsize = 2, nosel = true},
            {str = "", nosel = true},
            {
                str = "yes",
                action = "resume",
                fsize = 3,
                glowcolor = 3,

                func = function()
                    FiendFolio.savedata.disableAchievements = false
                    FiendFolio.savedata.shownUnlocksChoicePopup = true
                    FiendFolio.PostAchievementUpdate(false)
                end,
            },
            {
                str = "no",
                action = "resume",
                fsize = 3,

                func = function(button, item, root)
                    FiendFolio.savedata.disableAchievements = true
                    FiendFolio.savedata.shownUnlocksChoicePopup = true
                    FiendFolio.PostAchievementUpdate(true)

                    SFXManager():Play(SoundEffect.SOUND_FART)
                end
            },

            {str = "", nosel = true},
            {str = "you can change this later in our mod menu", nosel = true},
        },

        tooltip = {strset = {"you can", "change this", "later"}},
    },
	credits = {
        title = 'credits',
        fsize = 1,
        buttons = {
        }
    }
}

local function insertUnlockTags(item)
    for i, v in ipairs(item.buttons) do
        if v.insertUnlockTag then
            local buttons = FiendFolio.GetMenuButtonsForAchievementTag(v.insertUnlockTag)
            for b, button in ipairs(buttons) do
                table.insert(item.buttons, i + b, button)
            end
        end
    end
    
    for i = #item.buttons, 1, -1 do
        local v = item.buttons[i]
        if v.insertUnlockTag then
            table.remove(item.buttons, i)
        end
    end
end

insertUnlockTags(fiendfoliodirectory.unlocksmanager)
insertUnlockTags(fiendfoliodirectory.fiendunlocks)
insertUnlockTags(fiendfoliodirectory.biendunlocks)
insertUnlockTags(fiendfoliodirectory.golemunlocks)

FiendFolio.DSS_DIRECTORY = fiendfoliodirectory
FiendFolio.DSS_MOD = dssmod

local fiendfoliodirectorykey = {
    Item = fiendfoliodirectory.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Fiend Folio", {Run = dssmod.runMenu, Open = dssmod.openMenu, Close = dssmod.closeMenu, Directory = fiendfoliodirectory, DirectoryKey = fiendfoliodirectorykey})

DeadSeaScrollsMenu.AddPalettes({
    {
        Name = "bubbly",
        {145, 188, 191}, -- Back
        {0, 65, 82}, -- Text
        {0, 106, 146}, -- Highlight Text
    },
    {
        Name = "bustin'",
        {102, 65, 55},
        {255, 138, 0},
        {255, 197, 0},
    },
    {
        Name = "expensive",
        {215, 162, 55},
        {255, 214, 141},
        {255, 255, 255},
    },
    {
        Name = "friendly",
        {215, 94, 53},
        {135, 60, 146},
        {182, 39, 203},
    },
    {
        Name = "inky",
        {79, 80, 89},
        {191, 148, 61},
        {205, 182, 133},
    },
    {
        Name = "load mega",
        {121, 79, 57},
        {188, 146, 100},
        {211, 187, 153},
    },
    {
        Name = "scar tissue",
        {190, 173, 172},
        {149, 59, 70},
        {129, 50, 55},
    },
    {
        Name = "honeyed",
        {198, 170, 89},
        {47, 48, 63},
        {89, 48, 38},
    },
    {
        Name = "wart",
        {77, 84, 63},
        {110, 122, 79},
        {162, 165, 100},
    },
    {
        Name = "watered down",
        {175, 178, 198},
        {86, 88, 120},
        {67, 73, 122},
    }
})
