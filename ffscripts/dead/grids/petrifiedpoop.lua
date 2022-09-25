FiendFolio.PetrifiedPoopGrid = StageAPI.CustomGrid("FFPetrifiedPoop", {
    BaseType = GridEntityType.GRID_POOP,
    BaseVariant = StageAPI.PoopVariant.Golden,
    Anm2 = "gfx/grid/grid_petrified_poop.anm2",
    RemoveOnAnm2Change = true,
    Animation = "State1",
    OverrideGridSpawns = true,
    CustomPoopGibs = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1028}
})

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()

    FiendFolio.SetPoopSpriteState(grid, sprite)
end, "FFPetrifiedPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_POOP_GIB_SPAWN", 1, function(customGrid, effect)
    local rng = customGrid.RNG
    if customGrid.Lifted or (customGrid.GridEntity and customGrid.GridEntity.State == 1000) then
        if not customGrid.PersistentData.SpawnedRockGibs then
            customGrid.PersistentData.SpawnedRockGibs = true
            for i = 1, rng:RandomInt(3) + 3 do
                local rockParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 196609, effect.Position, RandomVector() * 2, nil)
                rockParticle:Update()
            end
            SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        end
    end

    if effect.Variant ~= EffectVariant.POOP_EXPLOSION then
        local toothParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, effect.Position, effect.Velocity, nil)
        toothParticle.Color = Color(0.6, 0.6, 0.6, 1, 0, 0, 0)
    end

    effect.Visible = false
    effect:Remove()
end, "FFPetrifiedPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player
    player:ThrowFriendlyDip(12, familiar.Position, familiar.TargetPosition)
    familiar.Visible = false
    familiar:Remove()
end, "FFPetrifiedPoop")
