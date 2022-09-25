local mod = FiendFolio
local game = Game()

local lastUsedHorror

local function reEnt(name, extra)
    local tbl = FiendFolio.ENT(name)
    tbl[4] = extra
    return tbl
end

local sleeperReRenderEnts = {
    reEnt("RiderScythe"),
    {EntityType.ENTITY_PROJECTILE}
}

mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, name)
	if name == "SleeperEtAl" then
        local venuses = Isaac.FindByType(mod.FF.CacophobiaVenus.ID, mod.FF.CacophobiaVenus.Var)
        for _, venus in ipairs(venuses) do
            local data = venus:GetData()
            if data.TheField then
                return {
                    ActiveIn = 1.75
                }
            elseif data.Blackout and not game:IsPaused() then
                return {
                    ActiveIn = 1.5
                }
            end
        end

        local sleepers = Isaac.FindByType(mod.FF.Sleeper.ID, mod.FF.Sleeper.Var)
        local sleeperData
        for _, sleeper in ipairs(sleepers) do
            local data = sleeper:GetData()
            if data.State ~= "Idle" then
                sleeperData = data
                break
            end
        end

        local pause = game:IsPaused()
        if sleeperData and sleeperData.Horror and not pause then
            local pos = sleeperData.Horror.Positions[1]
            local pos2 = sleeperData.Horror.Positions[2]

            local distances = sleeperData.Horror.CircleSizes
            local edgePos = Isaac.WorldToScreen(pos + Vector(distances[1], 0))
            local edgePos2 = Isaac.WorldToScreen(pos2 + Vector(distances[2], 0))
            local fadePos = Isaac.WorldToScreen(pos + Vector(distances[3], 0))
            local fadePos2 = Isaac.WorldToScreen(pos2 + Vector(distances[4], 0))
            pos = Isaac.WorldToScreen(pos)
            pos2 = Isaac.WorldToScreen(pos2)

            local useHorror = {
                ActiveIn = sleeperData.Horror.Strength,
                TargetPositionOne = {pos.X, pos.Y, edgePos.X, edgePos.Y},
                TargetPositionTwo = {pos2.X, pos2.Y, edgePos2.X, edgePos2.Y},
                FadePositions = {fadePos.X, fadePos.Y, fadePos2.X, fadePos2.Y},
                WarpCheck = {pos.X + 1, pos.Y + 1},
                RandomIn = math.random(),
                ColorPulseIn = math.min(sleeperData.Horror.Redness + mod:Sway(0.4, 0.5, 100, nil, nil, game:GetFrameCount()), 1)
            }
            lastUsedHorror = useHorror

            if useHorror.ActiveIn > 0.8 then
                local room = game:GetRoom()
                local scrollOffset = room:GetRenderScrollOffset()
                for _, ent in ipairs(sleeperReRenderEnts) do
                    local found = Isaac.FindByType(ent[1] or -1, ent[2] or -1, ent[3] or -1)
                    for _, entity in ipairs(found) do
                        local layerDat = ent[4]
                        local shouldRender = true
                        if layerDat and type(layerDat) == "function" then
                            shouldRender, layerDat = layerDat(entity)
                        end

                        if shouldRender then
                            if layerDat then
                                local sprite = entity:GetSprite()
                                for _, layer in ipairs(ent[4]) do
                                    sprite:RenderLayer(layer, Isaac.WorldToScreen(entity.Position), Vector.Zero, Vector.Zero)
                                end
                            else
                                entity:Render(scrollOffset)
                            end
                        end
                    end
                end
            end

            return useHorror
        elseif lastUsedHorror and not game:IsPaused() then
            local useHorror = lastUsedHorror
            lastUsedHorror.ActiveIn = mod:Lerp(lastUsedHorror.ActiveIn, 0, 0.05)
            if lastUsedHorror.ActiveIn < 0.01 then
                lastUsedHorror = nil
            end

            return useHorror
        else
            return {
                ActiveIn = 0
            }
        end
    end
end)

--[[
do -- rev shaders (disabled)

FiendFolio.Shaders = {
    ["0"] = {Name = "NilShader"},
    ["1.0"] = {
        Name = "Basement",
		RGB = { 1.1, 0.95, 1 }, --red, green, blue
		Brightness = 0.5,
        Exposure = 0.00,
		Temperature = 0,
		Midtones = {
			RGB = { 1.1, 1.05, 1 },
			Brightness = 0,
			Exposure = 0.00,
			Temperature = 5,
        },
		Shadows = {
			RGB = { 0.8, 1, 1.5 },
			Brightness = -0.05,
			Exposure = 0.00,
			Temperature = 0,
        },
        Highlights = {
            RGB = { 1, 1, 1 },
            Brightness = 0.05,
            Exposure = 0.00,
            Temperature = 0
        },
	},
	["1.1"] = {
        Name = "Celler",
		RGB = { 1.2, 1.15, 0.9 }, --red, green, blue
		Brightness = 0.2,
        Exposure = 0.00,
		Temperature = 0,
		Midtones = {
			RGB = { 1.0, 1.00, 1.1},
			Brightness = -0.05,
			Exposure = 0.00,
			Temperature = 0,
        },
		Shadows = {
			RGB = { 1, 1, 1.0 },
			Brightness = -0.15,
			Exposure = 0.00,
			Temperature = 0,
        },
        Highlights = {
            RGB = { 1.02, 1.05, 1 },
            Brightness = 0.30,
            Exposure = 0.00,
            Temperature = 10
        },
	},
	["1.2"] = {
        Name = "Burning Basement",
		RGB = { 1.25, 1.15, 0.77 }, --red, green, blue
		Brightness = 0.25,
        Exposure = 0.00,
		Temperature = 0,
		Midtones = {
			RGB = { 0.9, 0.9, 1.3 },
			Brightness = 0.12,
			Exposure = 0.00,
			Temperature = 5,
        },
        Shadows = {
			RGB = { 0.5, 0.9, 1.1 },
			Brightness = -0.20,
			Exposure = 0.00,
			Temperature = 0,
        },
        Highlights = {
            RGB = { 1, 1, 1 },
            Brightness = 0.10,
            Exposure = 0.00,
            Temperature = 30
        },
    },
	["3.0"] = {
        Name = "Caves",
		RGB = { 1.2, 1.1, 0.9 },
		Brightness = 0.25,
		Exposure = 0.0,
		Midtones = {
			RGB = { 1.00, 1.10, 1.20 },
			Brightness = 0.0,
			Exposure = 0.00,
			Temperature = 0,
        },
		Shadows = {
			RGB = { 1, 1, 1 },
			Brightness = -0.6,
        },
        Highlights = {
            RGB = { 1.00, 1.00, 1.00 },
            Brightness = 0.0,
            Exposure = 0
        },
	},
	["3.1"] = {
        Name = "Catacombs",
		RGB = { 1.15, 1, 1.05 },
		Brightness = 0.3,
		Exposure = 0.0,
		Midtones = {
			RGB = { 1.20, 1.20, 1.0 },
			Brightness = 0.0,
			Exposure = 0.00,
			Temperature = 6,
        },
		Shadows = {
			RGB = { 1, 1, 1.3 },
			Brightness = -0.6,
        },
        Highlights = {
            RGB = { 1.00, 1.00, 1.00 },
            Brightness = 0.16,
            Exposure = 0
        },
    },
	["3.2"] = {
        Name = "Flooded Caves",
		RGB = { 1, 0.9, 1.2 },
		Brightness = 0.2,
		Exposure = 0.50,
        Shadows = {
			RGB = { 1, 1, 1 },
			Brightness = -1.00,
        },
        Highlights = {
            RGB = { 1.35, 1.25, 0.7 },
            Brightness = 0.0,
            Exposure = 0
        },
    },
	["5.0"] = {
    Name = "Depths",
		RGB = { 1.07, 1.015, 0.89 }, --red, green, blue
		Brightness = 0.055,
		Exposure = 0,
		Contrast = 0.042,
		Saturation = -0.039,
		Midtones = {
			RGB = { 1.07, 1.07, 1 },
			Brightness = -0.04,
			Exposure = 0.00,
			Temperature = 0,
    },
		Shadows = {
			RGB = { 1, 0.5, 1 },
			Brightness = -0.05,
			Exposure = 0.00,
			Temperature = 0,
    },
    Highlights = {
      RGB = { 1, 1, 1 },
      Brightness = 0,
      Exposure = 0.00,
      Temperature = 0
    },
	},
}

for k, v in pairs(FiendFolio.Shaders) do
    FiendFolio.Shaders[k] = { Config = v }
end

FiendFolio.BGTypeToShader = {
    [1] = "1.0",
    [2] = "1.1",
    [3] = "1.2",
    [4] = "3.0",
    [5] = "3.1",
    [6] = "3.2",
    [7] = "5.0",
    [8] = "5.1",
    [9] = "5.2",
    [10] = "7.0",
    [11] = "7.1",
    [12] = "7.2",
    [13] = "0", -- blue womb
    [14] = "10.0",
    [15] = "10.1",
    [16] = "11.0",
    [17] = "11.1",
    [18] = "0", -- mega satan
    [19] = "0", -- library
    [20] = "0", -- shop
    [21] = "0", -- bedroom
    [22] = "0", -- barren room
    [23] = "0", -- secret room
    [24] = "0", -- dice room
    [25] = "0", -- arcade
    [26] = "0", -- error
    [27] = "0", -- blue secret (?)
    [28] = "0", -- ultra greed
}

local function GetCurrentShader()
    if StageAPI.InNewStage() then return end
	if not FiendFolio.RevShaderUpgrade then return "0" end
    local room = game:GetRoom()
    local level = game:GetLevel()
    local stage = level:GetStage()
    if stage < 12 and
    (room.Type == RoomType.ROOM_DEFAULT or room.Type == RoomType.ROOM_BOSS or room.Type == RoomType.ROOM_MINIBOSS or room.Type == RoomType.ROOM_TREASURE) then
        if stage < 9 then stage = math.floor((stage + 1) / 2) * 2 - 1 end -- floor 2s
        return stage .. '.' .. (level:GetStageType() % 3) -- greed mode
    else
        local backdropType = room:GetBackdropType()
        return FiendFolio.BGTypeToShader[backdropType]
    end
end

local function UpdateCurrentShader()
    local shader = GetCurrentShader()
    shader = FiendFolio.Shaders[shader] and shader or "0"
    if shader == FiendFolio.CurrentShader then return end

    if FiendFolio.CurrentShader then FiendFolio.ShaderLerp = 0 end
    if FiendFolio.PrevShader then FiendFolio.Shaders[FiendFolio.PrevShader].Shader.Active = 0 end

    FiendFolio.PrevShader = FiendFolio.CurrentShader
    FiendFolio.CurrentShader = shader
end

local initShaders = false
local function InitShaders()
    FiendFolio.ShaderLerp = 1
    FiendFolio.PrevShader = nil
    FiendFolio.CurrentShader = nil

    if initShaders then return end

    for shaderKey, shader in pairs(FiendFolio.Shaders) do
        local config = shader.Config
        local s = REVEL.CCShader(config.Name)

        if config.RGB then s:SetRGB(table.unpack(config.RGB)) end -- { r, g, b }
        if config.Shadows then s:SetShadows(config.Shadows) end -- { RGB, Temp = n, Brightness = n, WeightExpMult = n, TintHue, TintSat, TintAmount }
        if config.Midtones then s:SetMidtones(config.Midtones) end
        if config.Highlights then s:SetHighlights(config.Highlights) end
        if config.ToneWeight then s:Set3WayWeight(table.unpack(config.ToneWeight)) end -- { shadows, midtones, highlights }
        if config.Levels then s:SetLevels(table.unpack(config.Levels)) end -- { minIn, maxIn, gamma }

        if config.Contrast then s:SetContrast(config.Contrast) end -- number
        if config.Lightness then s:SetLightness(config.Lightness) end -- number
        if config.Saturation then s:SetSaturation(config.Saturation) end -- number
        if config.Brightness then s:SetBrightness(config.Brightness) end -- number
        if config.Temp then s:SetTemp(config.Temp) end -- number

        if config.Tint then s:SetTint(table.unpack(config.Tint)) end -- { hue, saturation, amount }
        if config.TintShadows then s:SetTintShadows(table.unpack(config.TintShadows)) end
        if config.TintMidtones then s:SetTintMidtones(table.unpack(config.TintMidtones)) end
        if config.TintHighlights then s:SetTintHighlights(table.unpack(config.TintHighlights)) end

        if config.BoostSelection then s:SetColBoostSelection(table.unpack(config.BoostSelection)) end -- { hueStart, hueEnd, feather, minSaturation }
        if config.BoostRGB then s:SetColBoostRGB(table.unpack(config.BoostRGB)) end -- { r, g, b }
        if config.BoostSaturation then s:SetColBoostSat(table.unpack(config.BoostSaturation)) end -- number

        function s:OnUpdate()
            if shaderKey == FiendFolio.CurrentShader then
                self.Active = FiendFolio.ShaderLerp
            elseif shaderKey == FiendFolio.PrevShader then
                self.Active = 1 - FiendFolio.ShaderLerp
            else
                self.Active = 0
            end
        end

        shader.Shader = s
    end

    initShaders = true
end

if REVEL then InitShaders() end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not REVEL then return end

    InitShaders()

    UpdateCurrentShader()
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not REVEL then return end

    UpdateCurrentShader()
    FiendFolio.ShaderLerp = FiendFolio:Lerp(FiendFolio.ShaderLerp, 1, 0.08)
end)

end]]
