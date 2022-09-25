local mod = FiendFolio
local game = Game()

FiendFolio.PlatinumPoopGrid = StageAPI.CustomGrid("FFPlatinumPoop", {
    BaseType = GridEntityType.GRID_POOP,
    BaseVariant = StageAPI.PoopVariant.Golden,
    Anm2 = "gfx/grid/grid_platinum_poop.anm2",
    RemoveOnAnm2Change = true,
    Animation = "State1",
    OverrideGridSpawns = true,
    CustomPoopGibs = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1027}
})

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()

    FiendFolio.SetPoopSpriteState(grid, sprite)
end, "FFPlatinumPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid)
    local pos = customGrid.Position
    if not customGrid:IsOnGrid() then
        game:ShakeScreen(20)
    end

    local rng = customGrid.RNG
    local dimes = rng:RandomInt(2) + 2
    for i = 1, dimes do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME, pos, RandomVector() * 3, nil)
    end
end, "FFPlatinumPoop")

local function doShimmer(customGrid, sprite)
    if not sprite then
        sprite = customGrid.GridEntity:GetSprite()
    end

    local rng = customGrid.RNG

    if not customGrid.Data.ShimmerTime then
        customGrid.Data.ShimmerTime = rng:RandomInt(60) + 45
    end

    customGrid.Data.ShimmerTime = customGrid.Data.ShimmerTime - 1
    if customGrid.Data.ShimmerTime <= 0 then
        local suffix = string.sub(sprite:GetAnimation(), -1)
        if tonumber(suffix) and suffix ~= "5" and sprite:IsFinished() then
            sprite:Play("Shimmer" .. suffix, true)
        end

        customGrid.Data.ShimmerTime = nil
    end
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    if customGrid:IsOnGrid() then
        doShimmer(customGrid)
    end
end, "FFPlatinumPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", 1, function(customGrid, projectileHelper, holdingEntity)
    doShimmer(customGrid, projectileHelper:GetSprite())

    if holdingEntity then
        if not projectileHelper:GetData().ShakenScreen then
            game:ShakeScreen(10)
            projectileHelper:GetData().ShakenScreen = true
        end

        holdingEntity.Velocity = holdingEntity.Velocity * 0.75
    end
end, "FFPlatinumPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_UPDATE", 1, function(customGrid, projectile)
    doShimmer(customGrid, projectile:GetSprite())
end, "FFPlatinumPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_POOP_GIB_SPAWN", 1, function(customGrid, effect)
    local clone = Isaac.Spawn(effect.Type, effect.Variant, effect.SubType, effect.Position, effect.Velocity, nil)
    if clone.Variant == EffectVariant.POOP_PARTICLE then
        clone:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_platinum_gibs.png")
        clone:GetSprite():LoadGraphics()
    else
        clone:GetSprite().Color = Color(0,0,0,0.7,131 / 255,131 / 255,131 / 255)
    end

    effect.Visible = false
    effect:Remove()
end, "FFPlatinumPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player

    local dip = player:ThrowFriendlyDip(669, familiar.Position, familiar.TargetPosition)
	dip.CollisionDamage = 10.5
	dip.SplatColor = Color(0,0,0,0.7,131 / 255,131 / 255,131 / 255)

    familiar.Visible = false
    familiar:Remove()
end, "FFPlatinumPoop")

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, dip)
	if dip.SubType == 669 then
		dip.SplatColor = Color(0,0,0,0.7,131 / 255,131 / 255,131 / 255)
	end
end, FamiliarVariant.DIP)

function mod:platinumDipOnDamage(entity, source)
	if source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.DIP and source.Entity and source.Entity.SubType == 669 then
		local secondHandMultiplier = 1
		if source.Entity:ToFamiliar().Player then
			secondHandMultiplier = source.Entity:ToFamiliar().Player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
		end

		FiendFolio.MarkForMartyrDeath(entity, source.Entity, 150 * secondHandMultiplier, false)
	end
end