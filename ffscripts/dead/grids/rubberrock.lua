local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

FiendFolio.RubberRockGrid = StageAPI.CustomGrid("FFRubberRock", {
    BaseType = GridEntityType.GRID_ROCK_ALT,
    Anm2 = "gfx/grid/grid_rubber_rock.anm2",
    RemoveOnAnm2Change = true,
    OverrideGridSpawns = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1025}
})

local function clamp(v, min, max)
    return math.min(math.max(v, min), max)
end

local function pointNearGrid(pos, gridPos, distance)
    local tl = gridPos + Vector(-20, -20)
    local br = gridPos + Vector(20, 20)

    local closestPoint = Vector(clamp(pos.X, tl.X, br.X), clamp(pos.Y, tl.Y, br.Y))
    return pos:DistanceSquared(closestPoint) < distance ^ 2
end

local function bouncePlayers(sprite, pos, ignoreDungeon)
    local players = Isaac.FindInRadius(pos, 28, EntityPartition.PLAYER)
    if #players > 0 then
        local hitPlayer
        for _, player in ipairs(players) do
            if pointNearGrid(player.Position, pos, player.Size + 2) then
                hitPlayer = true
                if not ignoreDungeon and game:GetRoom():GetType() == RoomType.ROOM_DUNGEON then
                    player.Velocity = (player.Position - pos):Resized(15)
                    player.Velocity = Vector(player.Velocity.X, math.max(math.min(player.Velocity.Y, -2.5), -7.5))
                    sfx:Play(mod.Sounds.RubberRockBounce, math.random(60,70)/100, 0, false, math.random(90,110)/100)
                else
                    player.Velocity = (player.Position - pos):Resized(15)
                    sfx:Play(mod.Sounds.RubberRockBounce, math.random(60,70)/100, 0, false, math.random(90,110)/100)
                end
            end
        end

        if hitPlayer then
            sprite:Play("Bounce", true)
        end
    end
end

local function bounceProjectiles(customGrid, sprite, pos, partitions, exception)
    partitions = partitions or (EntityPartition.BULLET | EntityPartition.TEAR)
    local data = customGrid.Data
    local hits = Isaac.FindInRadius(pos, 28, partitions)
    for _, hit in ipairs(hits) do
        local hash = GetPtrHash(hit)
        if not data.Hits[hash] and hash ~= exception then
            if math.abs(hit.Position.X - pos.X) > math.abs(hit.Position.Y - pos.Y) then
                hit.Velocity = Vector(-hit.Velocity.X, hit.Velocity.Y)
                sfx:Play(mod.Sounds.RubberRockBounce, math.random(15,35)/100, 0, false, math.random(140,170)/100)
            else
                hit.Velocity = Vector(hit.Velocity.X, -hit.Velocity.Y)
                sfx:Play(mod.Sounds.RubberRockBounce, math.random(15,35)/100, 0, false, math.random(140,170)/100)
            end

            if not sprite:IsPlaying("Bounce") then
                sprite:Play("Idle2", true)
            end

            data.Hits[hash] = hit
        end
    end
end

local function updateHashedPositions(customGrid, pos)
    local data = customGrid.Data
    for hash, hitEntity in pairs(data.Hits) do
        if not hitEntity:Exists() or hitEntity:IsDead() or hitEntity.Position:DistanceSquared(pos) > 30 ^ 2 then
            data.Hits[hash] = nil
        end
    end
end

function mod.rubberRockUpdate(customGrid)
    if customGrid:IsOnGrid() then
        local grid = customGrid.GridEntity
        if grid.State == 1 and game:GetRoom():GetFrameCount() >= 1 then
            local sprite = grid:GetSprite()
            local data = customGrid.Data

            bounceProjectiles(customGrid, sprite, grid.Position)

            updateHashedPositions(customGrid, grid.Position)

            if not sprite:IsPlaying("Bounce") or sprite:GetFrame() > 3 then
                bouncePlayers(sprite, grid.Position)
            end
        end
    end
end

function mod.rubberRockSpawn(customGrid)
    local grid = customGrid.GridEntity
    if grid.State ~= 2 then
        local sprite = grid:GetSprite()
        sprite:Play("Idle", true)
        customGrid.Data.Hits = {}
    end
end

function FiendFolio.CanKnockbackEntity(ent)
	return ent.Mass < 100 and ent.Friction ~= 0 and not ent:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) and not ent:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) and not FiendFolio.RootedEnemies[ent.Type]
end

local function bounceEnemies(sprite, pos)
    local enemies = Isaac.FindInRadius(pos, 30, EntityPartition.ENEMY)
    if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
            if enemy:IsVulnerableEnemy() and FiendFolio.CanKnockbackEntity(enemy) then
                enemy.Velocity = (enemy.Position - pos):Resized(20)
                sfx:Play(mod.Sounds.RubberRockBounce, 0.5, 0, false, 1)
            end
        end

        sprite:Play("Bounce", true)
    end
end

function mod.rubberRockHeld(customGrid, gridHelper, holdingEntity)
    if holdingEntity then
        local sprite = gridHelper:GetSprite()
        if holdingEntity:ToPlayer() then
            bounceProjectiles(customGrid, sprite, holdingEntity.Position, EntityPartition.BULLET)
            updateHashedPositions(customGrid, holdingEntity.Position)

            if not sprite:IsPlaying("Bounce") or sprite:GetFrame() > 3 then
                bounceEnemies(sprite, holdingEntity.Position)
            end
        else
            bounceProjectiles(customGrid, sprite, holdingEntity.Position)
            updateHashedPositions(customGrid, holdingEntity.Position)

            if not sprite:IsPlaying("Bounce") or sprite:GetFrame() > 3 then
                bouncePlayers(sprite, holdingEntity.Position, true)
            end
        end
    end
end

function mod.rubberRockProjectile(customGrid, projectile)
    local sprite = projectile:GetSprite()

    bounceProjectiles(customGrid, sprite, projectile.Position, nil, GetPtrHash(projectile))
    updateHashedPositions(customGrid, projectile.Position)
    if projectile.Type == EntityType.ENTITY_TEAR then
        if not sprite:IsPlaying("Bounce") or sprite:GetFrame() > 3 then
            bounceEnemies(sprite, projectile.Position)
        end
    else
        if not sprite:IsPlaying("Bounce") or sprite:GetFrame() > 3 then
            bouncePlayers(sprite, projectile.Position, true)
        end
    end
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.rubberRockUpdate, FiendFolio.RubberRockGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.rubberRockSpawn, FiendFolio.RubberRockGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", 1, mod.rubberRockHeld, FiendFolio.RubberRockGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_UPDATE", 1, mod.rubberRockProjectile, FiendFolio.RubberRockGrid.Name)
