local mod = FiendFolio
local game = Game()

local greenGreen = Color(1, 1, 1, 1, 0, 0, 0)
greenGreen:SetColorize(0, 1, 0, 1)
FiendFolio.PoisonPoopGrid = StageAPI.CustomGrid("FFPoisonPoop", {
    BaseType = GridEntityType.GRID_POOP,
    Anm2 = "gfx/grid/grid_poison_poop.anm2",
    RemoveOnAnm2Change = true,
    Animation = "State1",
    OverrideGridSpawns = true,
    PoopExplosionColor = greenGreen,
    PoopGibColor = greenGreen,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1033}
})

local function SpawnPoisonPoopAura(pos, gasType)
    local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, gasType or 0, pos, Vector.Zero, nil):ToEffect()
    aura.SpawnerType = FiendFolio.FFID.Grid
    aura.SpawnerVariant = 1033
    return aura
end

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()

    FiendFolio.SetPoopSpriteState(grid, sprite)

    local stage = game:GetLevel():GetStage()
    local stageType = game:GetLevel():GetStageType()
    if stage <= 2 and (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B) then
        customGrid.Data.GasType = 1
    end

    if grid.State ~= 1000 then
        customGrid.Data.Effect = SpawnPoisonPoopAura(grid.Position, customGrid.Data.GasType)
        customGrid.Data.Effect:SetTimeout(30)
    end
end, "FFPoisonPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid)
    local pos = customGrid.Position
    local spawner = nil

    if customGrid.Data.Effect then
        if customGrid.Data.Effect.SpawnerType == EntityType.ENTITY_PLAYER then -- player thrown
            spawner = Isaac.GetPlayer()
        end

        customGrid.Data.Effect:Remove()
    end

    for i = 1, 8 do
        local angle = i * (360 / 8)
        local dir = Vector.FromAngle(angle)
        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, customGrid.Data.GasType or 0, pos + dir * 20, dir * 7, spawner):ToEffect()
        if not spawner then
            eff.SpawnerType = FiendFolio.FFID.Grid
            eff.SpawnerVariant = 1033
        end
        
        eff:SetTimeout(120)
    end

    local rng = customGrid.RNG
    local chance = rng:RandomFloat()
    if chance < 0.1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, pos, Vector.Zero, nil)
    end
end, "FFPoisonPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    if customGrid:IsOnGrid() then
        local grid = customGrid.GridEntity
        if grid.State ~= 1000 then
            customGrid.Data.Effect:SetTimeout(30)
        elseif customGrid.Data.Effect then
            if customGrid.Data.Effect:Exists() then
                customGrid.Data.Effect:Remove()
            end

            customGrid.Data.Effect = nil
        end
    end
end, "FFPoisonPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player

    player:ThrowFriendlyDip(14, familiar.Position, familiar.TargetPosition)
    familiar.Visible = false
    familiar:Remove()
end, "FFPoisonPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", 1, function(customGrid, projectileHelper, holdingEntity)
    if holdingEntity then
        if not customGrid.Data.Effect or not customGrid.Data.Effect:Exists() then -- handle respawning when moving between rooms
            customGrid.Data.Effect = SpawnPoisonPoopAura(holdingEntity.Position, customGrid.Data.GasType)
        end

        customGrid.Data.Effect:SetTimeout(30)
        customGrid.Data.Effect.Position = holdingEntity.Position
        customGrid.Data.Effect.PositionOffset = Vector(0, -20)
        customGrid.Data.Effect.Velocity = holdingEntity.Velocity
        customGrid.Data.Effect.SpawnerEntity = holdingEntity
        customGrid.Data.Effect.SpawnerType = holdingEntity.Type
    end
end, "FFPoisonPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_UPDATE", 1, function(customGrid, projectile)
    if not projectile:IsDead() then
        customGrid.Data.Effect:SetTimeout(30)
        customGrid.Data.Effect.Position = projectile.Position
        customGrid.Data.Effect.Velocity = projectile.Velocity
		customGrid.Data.Effect.PositionOffset = projectile.PositionOffset + Vector(0, 20)
    end
end, "FFPoisonPoop")