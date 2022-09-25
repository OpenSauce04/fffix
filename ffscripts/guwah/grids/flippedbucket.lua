local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

FiendFolio.FlippedBucketGrid = StageAPI.CustomGrid("FFFlippedBucket", {
    BaseType = GridEntityType.GRID_ROCK_ALT,
    Anm2 = "gfx/grid/flippedbucket/grid_flipped_bucket.anm2",
    RemoveOnAnm2Change = true,
    Animation = "Idle",
    Frame = 0,
    VariantFrames = 1,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1038}
})

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local room = game:GetRoom()
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()
    local newsheet
    grid:SetVariant(0) --Prevents tear splashing when broken
    if mod.roomBackdrop == 9 or mod.GetEntityCount(150, 1000, 9) > 0 then --Load Dross skin (in two flavors)
        newsheet = "gfx/grid/flippedbucket/flipped_bucket_pee.png"
    elseif room:GetBackdropType() == BackdropType.DROSS then
        newsheet = "gfx/grid/flippedbucket/flipped_bucket_dross.png"
    end
    if newsheet then
        sprite:ReplaceSpritesheet(0, newsheet)
        sprite:LoadGraphics()
    end
end, "FFFlippedBucket")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 0, function(customGrid) --Frame 1 checks :[
    local grid = customGrid.GridEntity
    if customGrid:IsOnGrid() then
        local room = game:GetRoom()
        if room:GetFrameCount() == 1 then --Custom backdrops are bitchy and require checking twice
            if mod.GetEntityCount(EntityType.ENTITY_POLTY, 0) > 0 then --If Polty then turn it into normal Bucket
                customGrid:Remove(true)
                grid:Init(customGrid.RNG:Next())
            elseif mod.roomBackdrop == 9 or mod.GetEntityCount(150, 1000, 9) > 0 then
                local sprite = grid:GetSprite()
                sprite:ReplaceSpritesheet(0, "gfx/grid/flippedbucket/flipped_bucket_pee.png")
                sprite:LoadGraphics()
            end
        end
    end
end, "FFFlippedBucket")
