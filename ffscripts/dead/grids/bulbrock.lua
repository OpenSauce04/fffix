local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

FiendFolio.BulbRockGrid = StageAPI.CustomGrid("FFBulbRock", {
    BaseType = GridEntityType.GRID_TELEPORTER, -- using spikes rather than metal block because metal blocks block explosion damage D:`
    Anm2 = "gfx/grid/grid_bulb_rock.anm2",
    Animation = "Idle",
    RemoveOnAnm2Change = true,
    OverrideGridSpawns = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1029}
})

function mod:tryTriggerBulbRock(forceShut)
    for _, customGrid in ipairs(StageAPI.GetCustomGrids(nil, "FFBulbRock")) do
        customGrid.Data.TryActivation = true
        if forceShut then
            local forcedDarkness = game:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_PITCH_BLACK ~= 0

            sfx:Play(mod.Sounds.LightSwitch,1,0,false,0.9)
            sfx:Play(mod.Sounds.CameraFlash,2,0,false,3)
            if not forcedDarkness then
                game:Darken(1, 150)
            end
            customGrid.GridEntity:GetSprite():Play("Bombed", true)
            customGrid.Data.Cooldown = 150
        end
    end
end

local function bulbRockHitboxCollide(hitbox, hitting)
    if hitting.Type == EntityType.ENTITY_PLAYER or hitting.Type == EntityType.ENTITY_TEAR or hitting.Type == EntityType.ENTITY_PROJECTILE then
        mod:tryTriggerBulbRock()
    end

    return true
end

local function bulbRockHitboxHurt(hitbox, damage, flag, source, countdown)
    if flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
        mod:tryTriggerBulbRock()
    end

    return false
end

function mod.bulbRockUpdate(customGrid)
    local grid = customGrid.GridEntity
    local sprite = grid:GetSprite()
    local forcedDarkness = game:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_PITCH_BLACK ~= 0

    local lightColor = Color(1, 1, 1, 1, 0, 0, 0)
    local lightColorNoAlpha = Color(1, 1, 1, 0, 0, 0, 0)
    if sprite:IsPlaying("Reactivate") then
        lightColor = Color.Lerp(lightColorNoAlpha, lightColor, sprite:GetFrame() / 13)
    elseif sprite:IsPlaying("Bombed") then
        lightColor = Color.Lerp(lightColor, lightColorNoAlpha, sprite:GetFrame() / 20)
    elseif customGrid.Data.Cooldown then
        lightColor = lightColorNoAlpha
    end

    customGrid.Data.Light.Color = lightColor

    grid.State = 2

    if customGrid.Data.Cooldown then
        if sprite:IsFinished() then
            sprite:Play("Recharging")
        end

        customGrid.Data.Cooldown = customGrid.Data.Cooldown - 1
        if customGrid.Data.Cooldown <= 0 then
            sfx:Play(mod.Sounds.LightSwitch,1,0,false,1.1)
            sfx:Play(mod.Sounds.InfinityVoltPlugin,1,0,false,1.5)
            sprite:Play("Reactivate", true)
            customGrid.Data.Cooldown = nil
            customGrid.Data.TryActivation = nil
        end
    elseif customGrid.Data.TryActivation then
        sfx:Play(mod.Sounds.LightSwitch,1,0,false,0.9)
        sfx:Play(mod.Sounds.CameraFlash,2,0,false,3)
        sprite:Play("Bombed", true)

        if not forcedDarkness then
            game:Darken(1, 150)
        end

        customGrid.Data.Cooldown = 150
        customGrid.Data.TryActivation = nil
    else
        if sprite:IsFinished() then
            sprite:Play("Idle")
            if math.random(1, 30) == 1 then
                sprite:Play("Idle2", true)
            end
        end
    end
end

function mod.bulbRockSpawn(customGrid)
    local grid = customGrid.GridEntity
    grid.CollisionClass = GridCollisionClass.COLLISION_SOLID
    customGrid.Data.Hits = {}

    customGrid.Data.Light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LIGHT, 0, grid.Position, Vector.Zero, nil)

    customGrid.Data.Hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 1, grid.Position, Vector.Zero, nil)
    customGrid.Data.Hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    customGrid.Data.Hitbox:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
    local hdata = customGrid.Data.Hitbox:GetData()
    hdata.CustomGrid = customGrid
    hdata.FixToSpawner = true
    hdata.Width = 22
    hdata.Height = 22
    hdata.OnCollide = bulbRockHitboxCollide
    hdata.OnHurt = bulbRockHitboxHurt
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.bulbRockUpdate, FiendFolio.BulbRockGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.bulbRockSpawn, FiendFolio.BulbRockGrid.Name)