local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

FiendFolio.EvilPoopGrid = StageAPI.CustomGrid("FFEvilPoop", {
    BaseType = GridEntityType.GRID_POOP,
    BaseVariant = StageAPI.PoopVariant.Golden,
    Anm2 = "gfx/grid/evilpoop/grid_evilpoop.anm2",
    Animation = "State1",
    OverrideGridSpawns = true,
    RemoveOnAnm2Change = true,
    PoopExplosionColor = mod.ColorDecentlyRed,
    PoopGibSheet = "gfx/grid/evilpoop/effect_evilpoopgibs.png",
    SpawnerEntity = {Type = FiendFolio.FFID.Poop, Variant = 1037}
})

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()
    customGrid.PersistentData.Alpha = 0
    customGrid.PersistentData.Radius = (customGrid.PersistentData.SpawnerEntity and (customGrid.PersistentData.SpawnerEntity.SubType * 0.01)) or 40
    customGrid.PersistentData.AuraScale = Vector(customGrid.PersistentData.Radius, customGrid.PersistentData.Radius)
	FiendFolio.SetPoopSpriteState(grid, sprite)
end, "FFEvilPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    local grid = customGrid.GridEntity
    if customGrid:IsOnGrid() then
        customGrid.PersistentData.RenderPos = grid.Position
        customGrid.PersistentData.Poop = grid
        if customGrid.PersistentData.Fading then
            if customGrid.PersistentData.Alpha > 0 then
                customGrid.PersistentData.Alpha = customGrid.PersistentData.Alpha - 0.1
            end
        else
            if customGrid.PersistentData.Alpha < 1 then
                --customGrid.PersistentData.Alpha = 0.5
                customGrid.PersistentData.Alpha = customGrid.PersistentData.Alpha + 0.25
            end
        end
    end
end, "FFEvilPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_POOP_GIB_SPAWN", 1, function(customGrid, effect)
    local clone = Isaac.Spawn(effect.Type, effect.Variant, effect.SubType, effect.Position, effect.Velocity, nil)
    if clone.Variant == EffectVariant.POOP_PARTICLE then
        clone:GetSprite():ReplaceSpritesheet(0, "gfx/grid/evilpoop/effect_evilpoopgibs.png")
        clone:GetSprite():LoadGraphics()
        clone:GetData().EvilPoopGib = true
    else
        clone:GetSprite().Color = mod.ColorRedPoop
    end

    effect.Visible = false
    effect:Remove()
end, "FFEvilPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    local rng = customGrid.RNG
    local roll = rng:RandomFloat()
    local pos = customGrid.Position
    if roll <= 0.15 then
        if roll <= 0.075 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_FIENDFOLIO_HALF_BLACK_HEART, 0, pos, Vector.Zero, nil)
        else
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pos, Vector.Zero, nil)
        end
    end
    customGrid.PersistentData.Fading = true
end, "FFEvilPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player

    local dip = player:ThrowFriendlyDip(671, familiar.Position, familiar.TargetPosition)
	dip.SplatColor = mod.ColorRedPoop

    familiar.Visible = false
    familiar:Remove()
end, "FFEvilPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", 1, function(customGrid, projectileHelper, holdingEntity)
    if holdingEntity then
        customGrid.PersistentData.Poop = projectileHelper
        customGrid.PersistentData.Vel = holdingEntity.Velocity
        if holdingEntity.Type == 1 then
            customGrid.PersistentData.RenderPos = holdingEntity.Position + Vector(0,-50)
            local enemies = Isaac.FindInRadius(holdingEntity.Position, customGrid.PersistentData.Radius * 200, EntityPartition.ENEMY)
            for _, enemy in ipairs(enemies) do
                enemy:AddConfusion(EntityRef(projectileHelper), 60)
            end
        else
            customGrid.PersistentData.RenderPos = holdingEntity.Position + Vector(0,-55)
        end
    end
end, "FFEvilPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_UPDATE", 1, function(customGrid, projectile)
    customGrid.PersistentData.Poop = projectile
    customGrid.PersistentData.Vel = projectile.Velocity
    customGrid.PersistentData.RenderPos = Vector(projectile.Position.X, projectile.Position.Y + projectile.Height)
    if projectile:ToTear() then
        local enemies = Isaac.FindInRadius(projectile.Position, customGrid.PersistentData.Radius * 200, EntityPartition.ENEMY)
        for _, enemy in ipairs(enemies) do
            enemy:AddConfusion(EntityRef(projectile), 60)
        end
    end
    if projectile:IsDead() then
        customGrid.PersistentData.Alpha = 0
    end
end, "FFEvilPoop")

local darknessAura = Sprite()
darknessAura:Load("gfx/grid/evilpoop/grid_evilpoop.anm2", true)
darknessAura:Play("Aura", true)

function mod:EvilPoopRenderLogic(room)
    local dointerp = false
    if Isaac.GetFrameCount() % 2 == 0 and mod:IsNormalRender() then
        darknessAura:Update()
        dointerp = true
    end
    local evilpoops = StageAPI.GetCustomGrids(nil, "FFEvilPoop")
    if room:GetFrameCount() > 0 then
        for _, evilpoop in pairs(evilpoops) do
            if dointerp and evilpoop.PersistentData.Vel then
                evilpoop.PersistentData.RenderPos = evilpoop.PersistentData.RenderPos + (evilpoop.PersistentData.Vel * 0.5)
            end
            if evilpoop.PersistentData.Alpha > 0 then --If the Evil Poop isn't destroyed, then render the dark aura
                darknessAura.Color = Color(1,1,1,evilpoop.PersistentData.Alpha)
                darknessAura.Scale = evilpoop.PersistentData.AuraScale
                darknessAura:Render(Isaac.WorldToScreen(evilpoop.PersistentData.RenderPos))
            end
        end
        for _, evilpoop in pairs(evilpoops) do
            if evilpoop.PersistentData.Alpha > 0 then --If the Evil Poop isn't destroyed, re-render it above the darkness aura
                evilpoop.PersistentData.Poop:GetSprite():Render(Isaac.WorldToScreen(evilpoop.PersistentData.RenderPos))
            end
        end
    end
    for _, gib in pairs(Isaac.FindByType(1000,58)) do
        if gib:GetData().EvilPoopGib and gib.FrameCount < 60 then
            gib:GetSprite():Render(Isaac.WorldToScreen(gib.Position + gib.PositionOffset))
        end
    end
    for _, proj in pairs(Isaac.FindByType(9)) do
        if proj:GetData().projType == "evilPoop" then
            mod:EvilPoopProjectile(proj:ToProjectile())
        end
    end
end

function mod:EvilDipUpdate(dip, data, sprite)
    local enemies = Isaac.FindInRadius(dip.Position, 45, EntityPartition.ENEMY)
    for _, enemy in ipairs(enemies) do
        enemy:AddConfusion(EntityRef(dip), 60)
    end
end

function mod:EvilDipRender(dip, data, sprite)
    darknessAura.Color = Color(1,1,1,0.5)
    darknessAura.Scale = Vector(0.25,0.25)
    darknessAura:Render(Isaac.WorldToScreen(dip.Position + dip.PositionOffset + Vector(0,-8)))
    sprite:Render(Isaac.WorldToScreen(dip.Position + dip.PositionOffset))
end

function mod:EvilPoopProjectile(projectile)
    local renderpos = Vector(projectile.Position.X, projectile.Position.Y + projectile.Height)
    darknessAura.Color = Color.Default
    darknessAura.Scale = Vector(0.25,0.25)
    darknessAura:Render(Isaac.WorldToScreen(renderpos))
    projectile:GetSprite():Render(Isaac.WorldToScreen(renderpos))
end
