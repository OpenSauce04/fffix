local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

FiendFolio.SootTagGrid = StageAPI.CustomGrid("FFSootTag", {
    BaseType = GridEntityType.GRID_SPIDERWEB,
    Anm2 = "gfx/grid/web/grid_soottag.anm2",
    Animation = "Idle",
    RemoveOnAnm2Change = true,
    OverrideGridSpawns = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1031}
})

function mod.sootTagUpdate(customGrid)
    local grid = customGrid.GridEntity
    if grid.State == 0 then
        local players = Isaac.FindInRadius(grid.Position, 24, EntityPartition.PLAYER)
        for _, player in ipairs(players) do
            local hash = GetPtrHash(player)
            if player:HasEntityFlags(EntityFlag.FLAG_SLOW) then
				if type(customGrid.Data.PlayersAffected[hash]) == "table" then
					customGrid.Data.PlayersAffected[hash].Cooldown = 30
				else
					customGrid.Data.PlayersAffected[hash] = player
				end
            end
        end
    end

    for k, player in pairs(customGrid.Data.PlayersAffected) do
        if type(player) == "table" then
            if player.Player and player.Player:Exists() then
                local cooldown = player.Cooldown
                player.Cooldown = player.Cooldown - 1
                player = player.Player

                if player.FrameCount % 4 <= 2 then
                    player:SetColor(Color(1, 1, 1, 1, 0.16, 0.16, 0.16), 1, 1, true, false)
                end
                
                player:AddEntityFlags(EntityFlag.FLAG_SLOW)
                if cooldown <= 0 then
                    player:ClearEntityFlags(EntityFlag.FLAG_SLOW)
                    customGrid.Data.PlayersAffected[k] = nil
                end
            else
                customGrid.Data.PlayersAffected[k] = nil
            end
        elseif player:Exists() then
            if not player:HasEntityFlags(EntityFlag.FLAG_SLOW) then
                player:AddEntityFlags(EntityFlag.FLAG_SLOW)
                customGrid.Data.PlayersAffected[k] = {Player = player, Cooldown = 30}
            end
        else
            customGrid.Data.PlayersAffected[k] = nil
        end
    end
end

function mod.sootTagUnload(customGrid)
    for k, player in pairs(customGrid.Data.PlayersAffected) do
        if type(player) == "table" and player.Player and player.Player:Exists() then
            player.Player:ClearEntityFlags(EntityFlag.FLAG_SLOW)
        end
    end

    customGrid.Data.PlayersAffected = {}
end

function mod.sootTagSpawn(customGrid)
    customGrid.Data.PlayersAffected = {}

    if customGrid.GridEntity.State == 1 then
        local sprite = customGrid.GridEntity:GetSprite()
        sprite:Play("Bombed", true)
    end
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.sootTagUpdate, FiendFolio.SootTagGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UNLOAD", 1, mod.sootTagUnload, FiendFolio.SootTagGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.sootTagSpawn, FiendFolio.SootTagGrid.Name)