local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

FiendFolio.SpiderNestGrid = StageAPI.CustomGrid("FFSpiderNest", {
    BaseType = GridEntityType.GRID_POOP,
    Anm2 = "gfx/grid/spidernest/spidernest.anm2",
    Animation = "State1",
    OverrideGridSpawns = true,
    RemoveOnAnm2Change = true,
    PoopExplosionColor = mod.ColorPureWhite,
    PoopGibSheet = "gfx/grid/spidernest/spidernest_gibs.png",
    SpawnerEntity = {Type = FiendFolio.FFID.Poop, Variant = 1032}
})

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()
	FiendFolio.SetPoopSpriteState(grid, sprite)
end, "FFSpiderNest")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    if customGrid:IsOnGrid() then
        local grid = customGrid.GridEntity
        if grid.State >= 750 then
            grid:Destroy()
        end
    end
end, "FFSpiderNest")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    local pos = customGrid.Position
    local rng = customGrid.RNG
    sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.6, 0, false, 1.5)
    sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 0.6, 0, false, 1)
    local stage = game:GetLevel():GetStage()
    EntityNPC.ThrowSpider(pos, nil, pos + Vector(mod:RandomInt(-15,15,rng), mod:RandomInt(-15,15,rng)), false, 0)
    for _ = 1, mod:RandomInt(4, 5 + stage, rng) do
        local baby = EntityNPC.ThrowSpider(pos, nil, pos + Vector(mod:RandomInt(-40,40,rng), mod:RandomInt(-40,40,rng)), false, 0)
        baby:Morph(mod.FF.BabySpider.ID, mod.FF.BabySpider.Var, 0, -1)
    end
end, "FFSpiderNest")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player

    local dip = player:ThrowFriendlyDip(670, familiar.Position, familiar.TargetPosition)
	dip.SplatColor = mod.ColorPureWhite

    familiar.Visible = false
    familiar:Remove()
end, "FFSpiderNest")

function mod:SpiderDipUpdate(dip, data, sprite)
    dip.SplatColor = mod.ColorPureWhite
    data.SpiderDipCooldown = data.SpiderDipCooldown or 0
    data.SpiderDipCooldown = data.SpiderDipCooldown - 1
end

function mod:SpiderDipHurt(dip, source, data)
    data.SpiderDipCooldown = data.SpiderDipCooldown or 0
    if data.SpiderDipCooldown <= 0 then
        dip.Player:ThrowBlueSpider(dip.Position, dip.Position + RandomVector() * mod:RandomInt(10,30))
        data.SpiderDipCooldown = 150
    end
end
