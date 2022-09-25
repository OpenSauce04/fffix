local json = require "json"
FiendFolio.savedata = FiendFolio.savedata or {}
FiendFolio.gamestarted = FiendFolio.gamestarted or false

local SavedataConfig = {
    Persistent = {
        Config = {}
    },
    Run = {},
}

function AddConfig(name, default)

end

function FiendFolio.SaveSaveData() -- this isn't just SaveData because that's already a function on mod and overriding it could be :grimacing:
    FiendFolio.savedata.config = {
        replacementsEnabled = FiendFolio.replacementsEnabled,
        legacyReplacementsEnabled = FiendFolio.legacyReplacementsEnabled,
        ColourBlindMode = FiendFolio.ColourBlindMode,
        ModeEnabled = FiendFolio.ModeEnabled,
        TrueVoteOutcome = FiendFolio.TrueVoteOutcome,
        AutoDebug5 = FiendFolio.AutoDebug5,
        ShowRoomNames = FiendFolio.ShowRoomNames,
        RoomNameOpacity = FiendFolio.RoomNameOpacity,
        RoomNameScale = FiendFolio.RoomNameScale,
        NameTags = FiendFolio.NameTags,
        NameTagKeybind = FiendFolio.NameTagKeybind,
        ItemsEnabled = FiendFolio.ItemsEnabled,
        GreatFortune = FiendFolio.GreatFortune,
        MonsoonName = FiendFolio.MonsoonName,
        FiendConfig = FiendFolio.FiendConfig,
        ChangeAi = FiendFolio.ChangeAi,
        RevShaderUpgrade = FiendFolio.RevShaderUpgrade,
        CardConfig = FiendFolio.CardConfig,
    }

    local psave = mod.getFieldInit(FiendFolio.savedata, 'run', 'playerSaveData', {})
    for i = 1, game:GetNumPlayers() do
        local p = Isaac.GetPlayer(i - 1)
        local data = p:GetData()

        local playerSave = {}
        if data.ffsavedata then
            for key, val in pairs(data.ffsavedata) do
                playerSave[key] = val
            end
        end

        psave[i] = playerSave
    end

    Isaac.SaveModData(mod, json.encode(FiendFolio.savedata))
end

function FiendFolio.LoadSaveData()
    if not mod:HasData() then
        FiendFolio.SaveSaveData()
        print("FiendFolio mod save initialisation")
    else
        FiendFolio.savedata = json.decode(mod:LoadData())

        local config = FiendFolio.savedata.config
        if config then
            FiendFolio.replacementsEnabled       = config.replacementsEnabled or FiendFolio.replacementsEnabled
            FiendFolio.legacyReplacementsEnabled = config.legacyReplacementsEnabled or FiendFolio.legacyReplacementsEnabled
            FiendFolio.ColourBlindMode           = config.ColourBlindMode or FiendFolio.ColourBlindMode
            FiendFolio.ModeEnabled               = config.ModeEnabled or FiendFolio.ModeEnabled
            FiendFolio.TrueVoteOutcome           = config.TrueVoteOutcome or FiendFolio.TrueVoteOutcome
            FiendFolio.AutoDebug5                = config.AutoDebug5 or FiendFolio.AutoDebug5
            FiendFolio.ShowRoomNames             = config.ShowRoomNames or FiendFolio.ShowRoomNames
            FiendFolio.RoomNameOpacity           = config.RoomNameOpacity or FiendFolio.RoomNameOpacity
            FiendFolio.RoomNameScale             = config.RoomNameScale or FiendFolio.RoomNameScale
            FiendFolio.GreatFortune              = config.GreatFortune or FiendFolio.GreatFortune
            FiendFolio.MonsoonName               = config.MonsoonName or FiendFolio.MonsoonName
            FiendFolio.NameTags                  = config.NameTags or FiendFolio.NameTags
            FiendFolio.NameTagKeybind            = config.NameTagKeybind or FiendFolio.NameTagKeybind
            FiendFolio.ItemsEnabled              = config.ItemsEnabled or FiendFolio.ItemsEnabled
            FiendFolio.FiendConfig               = config.FiendConfig or FiendFolio.FiendConfig
            FiendFolio.ChangeAi                  = config.ChangeAi or FiendFolio.ChangeAi
            FiendFolio.RevShaderUpgrade          = config.RevShaderUpgrade or FiendFolio.RevShaderUpgrade
            FiendFolio.CardConfig                = config.CardConfig or FiendFolio.CardConfig
        end
    end
end

FiendFolio.LoadSaveData()

FiendFolio:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    local basedata = player:GetData()
    basedata.ffsavedata = {}
    local data = basedata.ffsavedata

    data.RunEffects = {
        RoomClearCounts = {}, -- intended for keeping track of clear counts since picking up item
        Collectibles = {},
        Trinkets = {},
        TrueRoomClearCounts = {}, -- The above one gets reset whenever you take damage.
    }
end)

FiendFolio:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continuing)
	Isaac.DebugString("PREFFSAVELOAD")
    FiendFolio.LoadSaveData()
	Isaac.DebugString("POSTFFSAVELOAD")

    if not continuing then
        FiendFolio.savedata.run = {}
    end

    if continuing then
        for i = 1, game:GetNumPlayers() do
            local p = Isaac.GetPlayer(i - 1)
            local pdata = p:GetData()

            for key, val in pairs(FiendFolio.savedata.run.playerSaveData[i]) do
                pdata.ffsavedata[key] = val
            end

            AddPlayerShardHearts(p, 0)
            p:AddCacheFlags(CacheFlag.CACHE_ALL)
            p:EvaluateItems()
        end
    end

    gamestarted = true
end)

FiendFolio:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	Isaac.DebugString("PREGAMEEXITPRESAVE")
    FiendFolio.SaveSaveData()
	Isaac.DebugString("PREGAMEEXITPOSTSAVE")
    FiendFolio.gamestarted = false
end)

FiendFolio:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
    FiendFolio.gamestarted = false
end)

FiendFolio:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    FiendFolio.getFieldInit(FiendFolio.savedata, 'run', {}).level = {}
    if FiendFolio.gamestarted then
        FiendFolio.SaveSaveData()
    end
end)