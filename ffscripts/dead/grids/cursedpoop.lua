local mod = FiendFolio
local game = Game()

FiendFolio.CursedPoopGrid = StageAPI.CustomGrid("FFCursedPoop", {
    BaseType = GridEntityType.GRID_POOP,
    Anm2 = "gfx/grid/grid_cursed_poop.anm2",
    RemoveOnAnm2Change = true,
    Animation = "State1",
    OverrideGridSpawns = true,
    PoopExplosionColor = Color(0,0,0,0.7,79 / 255,47 / 255,80 / 255),
    PoopGibSheet = "gfx/grid/grid_cursed_poop_gibs.png",
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1026}
})

local function SpawnCursedPoopAura(pos)
    local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 3, pos + Vector(0,-400), Vector.Zero, nil)
    aura.PositionOffset = Vector(0,400)
    return aura
end

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()

    FiendFolio.SetPoopSpriteState(grid, sprite)

    if grid.State ~= 1000 then
		-- thanks reflections for breaking this entity visually
        customGrid.Data.Effect = SpawnCursedPoopAura(grid.Position)
        customGrid.Data.Effect.Parent = Isaac.GetPlayer()
    end
end, "FFCursedPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    if customGrid.Data.Effect and customGrid.Data.Effect:Exists() then
        customGrid.Data.Effect:Remove()
    end

    local pos = customGrid.Position
    local rng = customGrid.RNG
    local chance = rng:RandomFloat()

    if chance < 0.15 then
        if chance > 0.075 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_CURSEDPENNY, pos, Vector.Zero, nil)
        else
            local half = rng:RandomFloat() > 0.5
            if chance > 0.03525 then
                if half then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_FIENDFOLIO_HALF_BLACK_HEART, 0, pos, Vector.Zero, nil)
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pos, Vector.Zero, nil)
                end
            else
                if half then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HALF_IMMORAL_HEART, 0, pos, Vector.Zero, nil)
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_IMMORAL_HEART, 0, pos, Vector.Zero, nil)
                end
            end
        end
    end
end, "FFCursedPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    local noEffect
    if customGrid:IsOnGrid() then
        local grid = customGrid.GridEntity
    	local sprite = grid:GetSprite()

        if grid.State ~= 1000 then
            local players = Isaac.FindInRadius(grid.Position, 80, EntityPartition.PLAYER)
            for _, player in ipairs(players) do
                player:AddFear(EntityRef(customGrid.Data.Effect), 3)
            end
        elseif customGrid.Data.Effect then
            if customGrid.Data.Effect:Exists() then
                customGrid.Data.Effect:Remove()
            end

            customGrid.Data.Effect = nil
        end
    end
end, "FFCursedPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player

    local dip = player:ThrowFriendlyDip(667, familiar.Position, familiar.TargetPosition)
	dip.SplatColor = Color(0,0,0,0.7,79 / 255,47 / 255,80 / 255)

    familiar.Visible = false
    familiar:Remove()
end, "FFCursedPoop")

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, dip)
	if dip.SubType == 667 then
		dip.SplatColor = Color(0,0,0,0.7,79 / 255,47 / 255,80 / 255)

		if dip.Child == nil then
			local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 3, dip.Position + Vector(0,-400), Vector.Zero, nil):ToEffect()
			aura.PositionOffset = Vector(0,400)
			aura:GetData().FFDipAura = true
			aura.Parent = dip
			dip.Child = aura

			local aurasprite = aura:GetSprite()
			aurasprite.Scale = Vector(0.6, 0.6)
			aurasprite.Offset = Vector(0, -8)
			aurasprite.Color = Color(1.0, 1.0, 1.0, 1.45, 0, 0, 0)
		end

		local enemies = Isaac.FindInRadius(dip.Position, 45, EntityPartition.ENEMY)
		for _, enemy in ipairs(enemies) do
			if enemy:ToNPC() and not (enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or
			                          enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) or
			                          enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				local enemydata = enemy:GetData()
				local frame = game:GetFrameCount()
				if frame == enemydata.FFLastFearApplication then
					-- do nothing
				elseif enemy:HasEntityFlags(EntityFlag.FLAG_FEAR) then
					enemy:AddFear(EntityRef(dip), 1)
					enemydata.FFLastFearApplication = frame
				else
					enemy:AddFear(EntityRef(dip), 10)
					enemydata.FFLastFearApplication = frame
				end
			end
		end
	end
end, FamiliarVariant.DIP)

-- thanks reflections for breaking this one too
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, aura)
	if aura.SubType == 3 then
		local data = aura:GetData()
		if (data.FFDipAura or data.FFProjAura) and aura.Parent then
            if data.FFDipAura then
			    aura.Position = aura.Parent.Position + Vector(0,-400) + aura.Parent.PositionOffset
            else
                aura.Position = Vector(aura.Parent.Position.X, aura.Parent.Position.Y + aura.Parent:ToProjectile().Height) + Vector(0,-400)
            end
			aura.PositionOffset = Vector(0,400)
		end
	end
end, EffectVariant.HALO)

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", 1, function(customGrid, projectileHelper, holdingEntity)
    if holdingEntity then
        if not customGrid.Data.Effect or not customGrid.Data.Effect:Exists() then -- handle respawning when moving between rooms
            customGrid.Data.Effect = SpawnCursedPoopAura(holdingEntity.Position)
            customGrid.Data.Effect.Parent = customGrid.Data.Effect
        end

        customGrid.Data.Effect.Position = holdingEntity.Position + Vector(0, -400)
        customGrid.Data.Effect.Velocity = holdingEntity.Velocity
        if holdingEntity:ToPlayer() then
            local enemies = Isaac.FindInRadius(holdingEntity.Position, 80, EntityPartition.ENEMY)
            for _, enemy in ipairs(enemies) do
                enemy:AddFear(EntityRef(customGrid.Data.Effect), 60)
            end
        else
            local players = Isaac.FindInRadius(holdingEntity.Position, 80, EntityPartition.PLAYER)
            for _, player in ipairs(players) do
                player:AddFear(EntityRef(customGrid.Data.Effect), 3)
            end
        end
    end
end, "FFCursedPoop")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_UPDATE", 1, function(customGrid, projectile)
    if not projectile:IsDead() then
        customGrid.Data.Effect.Position = projectile.Position
        customGrid.Data.Effect.Velocity = projectile.Velocity
		customGrid.Data.Effect.PositionOffset = Vector(0, projectile.Height)
		customGrid.Data.Effect.DepthOffset = 300
    end

    if projectile:ToTear() then
        local enemies = Isaac.FindInRadius(projectile.Position, 80, EntityPartition.ENEMY)
        for _, enemy in ipairs(enemies) do
            enemy:AddFear(EntityRef(customGrid.Data.Effect), 60)
        end
    else
        local players = Isaac.FindInRadius(projectile.Position, 80, EntityPartition.PLAYER)
        for _, player in ipairs(players) do
            player:AddFear(EntityRef(customGrid.Data.Effect), 3)
        end
    end
end, "FFCursedPoop")

function mod:CursedPoopProjectile(projectile, data)
    if not data.CursedPoopInit then
        local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 3, projectile.Position + Vector(0,-400), Vector.Zero, projectile):ToEffect()
        aura.PositionOffset = Vector(0,400)
        aura:GetData().FFProjAura = true
        local aurasprite = aura:GetSprite()
        aurasprite.Scale = Vector(0.6, 0.6)
        aurasprite.Color = Color(1.0, 1.0, 1.0, 1.45, 0, 0, 0)
        aura.Parent = projectile
        projectile.Child = aura
        data.CursedPoopInit = true
    end
    if not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
        local players = Isaac.FindInRadius(projectile.Position, 45, EntityPartition.PLAYER)
        for _, player in ipairs(players) do
            player:AddFear(EntityRef(projectile.Child), 3)
        end
    end
    if projectile:HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) then
        local enemies = Isaac.FindInRadius(projectile.Position, 45, EntityPartition.ENEMY)
        for _, enemy in ipairs(enemies) do
            enemy:AddFear(EntityRef(projectile.Child), 60)
        end
    end
end
