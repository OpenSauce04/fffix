-- what's wrong with loading an empty lua file every now and then?
if MMC then
    --[[
    FiendFolio.OverriddenMusicData = {
        [Isaac.GetMusicIdByName("FiendFolioCellar")] = {
            Overrides = Music.MUSIC_CELLAR,
            Backdrop  = 4
        },
        [Isaac.GetMusicIdByName("FiendFolioBurningBasement")] = {
            Overrides = Music.MUSIC_BURNING_BASEMENT,
            Backdrop = 2
        }
    }

    FiendFolio.OverriddenTracks = {}
    FiendFolio.OverriddenTrackToReplacement = {}

    for k, v in pairs(FiendFolio.OverriddenMusicData) do
        FiendFolio.OverriddenTracks[#FiendFolio.OverriddenTracks + 1] = v.Overrides
        FiendFolio.OverriddenTrackToReplacement[v.Overrides] = k
    end

    local ffCustomCellar = Isaac.GetMusicIdByName("FiendFolioCellar")
    MMC.AddMusicCallback(FiendFolio, function(_, track)
        local replace = FiendFolio.OverriddenTrackToReplacement[track]
        return replace
    end, table.unpack(FiendFolio.OverriddenTracks))

    local musicmgr = MusicManager()
    local game = Game()
    FiendFolio:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        for track, data in pairs(FiendFolio.OverriddenMusicData) do
            if musicmgr:GetCurrentMusicID() == track then
                if FiendFolio.roomBackdrop and FiendFolio.roomBackdrop == data.Backdrop and not game:GetRoom():IsClear() then
                    if musicmgr:IsLayerEnabled(0) then
                        musicmgr:DisableLayer(0)
                    end

                    if not musicmgr:IsLayerEnabled(1) then
                        musicmgr:EnableLayer(1)
                    end
                else
                    if musicmgr:IsLayerEnabled(1) then
                        musicmgr:DisableLayer(1)
                    end
                end
            end
        end
    end)]]
end
