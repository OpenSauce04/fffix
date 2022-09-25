local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

FiendFolio.GoldenRewardPlateGrid = StageAPI.CustomGrid("FFGoldenRewardPlate", {
    BaseType = GridEntityType.GRID_PRESSURE_PLATE,
    BaseVariant = 1,
    Anm2 = "gfx/grid/grid_pressureplate_gold.anm2",
    Animation = "Off",
    RemoveOnAnm2Change = true,
    OverrideGridSpawns = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1030}
})

function mod.goldenRewardPlateUpdate(customGrid)
    local grid = customGrid.GridEntity
    local sprite = grid:GetSprite()

    if sprite:IsPlaying("Switched") then
        if not customGrid.PersistentData.Hit then
            customGrid.PersistentData.Hit = true
            customGrid.PersistentData.Remaining = customGrid.PersistentData.Remaining - 1
            if customGrid.PersistentData.Remaining <= 0 then
                sprite:Play("Switched_Perma", true)
				grid.State = 6
            end

            sfx:Stop(SoundEffect.SOUND_BUTTON_PRESS)
            sfx:Play(mod.Sounds.GoldenButtonPress, 1, 0, false, 1, 0)
        end
    else
        customGrid.PersistentData.Hit = false
    end

    if grid.State == 3 and sprite:GetAnimation() == "On" and #Isaac.FindInRadius(grid.Position, 24, EntityPartition.PLAYER) == 0 then
        grid.State = 5
        sprite:Play("Back_Off", true)
    end

    if grid.State == 5 and sprite:IsFinished() then
        sprite:Play("Off", true)
        local anm2, animation, frame = sprite:GetFilename(), sprite:GetAnimation(), sprite:GetFrame()
        customGrid.PersistentData.Rolls = customGrid.PersistentData.Rolls + 1
        grid:Init(customGrid.Data.RNG:Next())
        sprite:Load(anm2, true)
        sprite:Play(animation, true)
        sprite:SetFrame(frame)
        grid.State = 0
    end
	
	if sprite:IsFinished("Switched_Perma") then
		grid.State = 0
		sprite:Play("Switched", true)
		sprite:SetFrame(4)
		grid:Update()
		grid.State = 6
		sprite:Play("On_Perma", true)
	end
end

function mod.goldenRewardPlateSpawn(customGrid)
    if not FiendFolio.ACHIEVEMENT.GOLDEN_REWARD_PLATE:IsUnlocked() then
        local grid = customGrid.GridEntity
        customGrid:Remove(true)

        grid:GetSprite():Load("gfx/grid/grid_pressureplate.anm2")
        grid:GetSprite():Play("Off")
        return
    end

    local grid = customGrid.GridEntity

    customGrid.Data.RNG = RNG()
    customGrid.Data.RNG:SetSeed(game:GetRoom():GetSpawnSeed() + (customGrid.GridIndex ^ 3), 35)

    if customGrid.PersistentData.Rolls then
        for i = 1, customGrid.PersistentData.Rolls do
            customGrid.Data.RNG:Next()
        end
    end

    if not customGrid.PersistentData.Remaining then
        customGrid.PersistentData.Rolls = 1
        customGrid.PersistentData.Remaining = customGrid.Data.RNG:RandomInt(5) + 3
    end

    if grid.State >= 3 then
        local sprite = grid:GetSprite()
        if grid.State == 5 then
            sprite:Play("Back_Off", true)
        elseif customGrid.PersistentData.Remaining <= 0 then
            sprite:Play("On_Perma", true)
        else
            sprite:Play("On", true)
        end
    end
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.goldenRewardPlateUpdate, FiendFolio.GoldenRewardPlateGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.goldenRewardPlateSpawn, FiendFolio.GoldenRewardPlateGrid.Name)