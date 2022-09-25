local fiendfoliodirectory = FiendFolio.DSS_DIRECTORY
local dssmod = FiendFolio.DSS_MOD
local mod = FiendFolio

local function biendUnlocked()
    return FiendFolio.ACHIEVEMENT.BIEND:IsUnlocked(true)
end

local achievementGroups = {
    {
        Name = "miscellaneous",
        Tag = "Misc",
        Icon = "misc"
    },
    {
        Name = "fiend",
        Tag = "Fiend",
        Icon = "fiend"
    },
    {
        Name = "tainted fiend",
        Tag = "Biend",
        Icon = "biend",
        DisplayIf = biendUnlocked
    },
    {
        Name = "golem",
        Tag = "Golem",
        Icon = "golem"
    },
    {
        Name = "challenge",
        Tag = "Challenge",
        Icon = "challenge"
    },
    {
        Name = "everything",
        Icon = "everything",
        TagToName = {
            Misc = "miscellaneous",
            Fiend = "fiend",
            Biend = "tainted fiend",
            Golem = "golem",
            Challenge = "challenge"
        },
        TagToDisplayIf = {
            Biend = biendUnlocked
        },
        Achievements = {}
    }
}

for _, group in ipairs(achievementGroups) do
    local sprite = Sprite()
    sprite:Load("gfx/ui/achievement/group_icons/group_icon.anm2", false)
    sprite:ReplaceSpritesheet(0, "gfx/ui/achievement/group_icons/icon_" .. group.Icon .. ".png")
    sprite:LoadGraphics()
    sprite:SetFrame("Idle", 0)
    group.Icon = sprite
end

local arrow = Sprite()
arrow:Load("gfx/ui/achievement/group_icons/arrow_icon.anm2", true)

local achievementLockedSprite = Sprite()
achievementLockedSprite:Load("gfx/ui/achievement/_ff_achievement.anm2", false)
achievementLockedSprite:ReplaceSpritesheet(0, "gfx/nothing.png")
achievementLockedSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_locked.png")
achievementLockedSprite:LoadGraphics()

local achievementTooltipSprites = {
    Shadow = "gfx/ui/achievement/group_note/menu_achievement_shadow.png",
    Back = "gfx/ui/achievement/group_note/menu_achievement_back.png",
    Face = "gfx/ui/achievement/group_note/menu_achievement_face.png",
    Border = "gfx/ui/achievement/group_note/menu_achievement_border.png",
    Mask = "gfx/ui/achievement/group_note/menu_achievement_mask.png",
}

for k, v in pairs(achievementTooltipSprites) do
    local sprite = Sprite()
    sprite:Load("gfx/ui/achievement/group_note/menu_achievement.anm2", false)
    sprite:ReplaceSpritesheet(0, v)
    sprite:LoadGraphics()
    achievementTooltipSprites[k] = sprite
end


local displayIndexToScale = {
    [0] = Vector(1, 1),
    [1] = Vector(0.75, 0.75),
    [2] = Vector(0.5, 0.5),
    [3] = Vector(0, 0),
    [4] = Vector(0, 0)
}

local displayIndexToColor = {
    [0] = Color.Default,
    [1] = Color(0.9, 0.9, 0.9, 1, 0, 0, 0),
    [2] = Color(0.8, 0.8, 0.8, 1, 0, 0, 0),
    [3] = Color(0.8, 0.8, 0.8, 0, 0, 0, 0),
    [4] = Color(0, 0, 0, 0, 0, 0, 0)
}

local displayIndexToYPos = {
    [0] = -50,
    [1] = -40,
    [2] = -30,
    [3] = -20,
    [4] = 5000
}

fiendfoliodirectory.achievementviewer = {
    format = {
        Panels = {
            {
                Panel = {
                    StartAppear = function(panel)
                        dssmod.playSound(dssmod.menusounds.Open)
                        panel.AppearFrame = 0
                        panel.Idle = false
                    end,
                    UpdateAppear = function(panel)
                        if panel.SpriteUpdateFrame then
                            panel.AppearFrame = panel.AppearFrame + 1
                            if panel.AppearFrame >= 10 then
                                panel.AppearFrame = nil
                                panel.Idle = true
                                return true
                            end
                        end
                    end,
                    StartDisappear = function(panel)
                        dssmod.playSound(dssmod.menusounds.Close)
                        panel.DisappearFrame = 0
                    end,
                    UpdateDisappear = function(panel)
                        if panel.SpriteUpdateFrame then
                            panel.DisappearFrame = panel.DisappearFrame + 1
                            if panel.DisappearFrame >= 11 then
                                return true
                            end
                        end
                    end,
                    RenderBack = function(panel, panelPos, tbl)
                        local anim, frame = "TrueIdle", 0
                        if panel.AppearFrame then
                            anim, frame = "AppearVert", panel.AppearFrame
                        elseif panel.DisappearFrame then
                            anim, frame = "DisappearVert", panel.DisappearFrame
                        end

                        if panel.ShiftFrame then
                            panel.ShiftFrame = panel.ShiftFrame + 1
                            if panel.ShiftFrame > panel.ShiftLength then
                                panel.ShiftLength = nil
                                panel.ShiftFrame = nil
                                panel.ShiftDirection = nil
                            end
                        end

                        local item = fiendfoliodirectory.achievementviewer
                        local group = achievementGroups[item.achievementgroupselected]
                        local numAchievements = #group.Achievements

                        local displayedAchievements = {}

                        local displayedCount = 7 - 1
                        for i = -(displayedCount / 2), displayedCount / 2, 1 do
                            local listIndex = #displayedAchievements + 1
                            local indexOffset = 0
                            local shiftPercent
                            if panel.ShiftFrame then
                                shiftPercent = panel.ShiftFrame / panel.ShiftLength
                                indexOffset = ((1 - shiftPercent) * panel.ShiftDirection)
                            end

                            local percent = ((listIndex + indexOffset) - 1) / displayedCount
                            local xPos = mod:Lerp(-280, 280, percent)

                            local scale = displayIndexToScale[math.abs(i)]
                            local color = displayIndexToColor[math.abs(i)]
                            local yPos = displayIndexToYPos[math.abs(i)]
                            if shiftPercent then
                                local shiftedScale = displayIndexToScale[math.abs(i + panel.ShiftDirection)]
                                scale = mod:Lerp(shiftedScale, scale, shiftPercent)
                                local shiftedColor = displayIndexToColor[math.abs(i + panel.ShiftDirection)]
                                color = Color.Lerp(shiftedColor, color, shiftPercent)
                                local shiftedY = displayIndexToYPos[math.abs(i + panel.ShiftDirection)]
                                yPos = mod:Lerp(shiftedY, yPos, shiftPercent)
                            end

                            local index = (((item.selectedingroup[group.Name] + i) - 1) % numAchievements) + 1
                            local achievement = group.Achievements[index]
                            displayedAchievements[#displayedAchievements + 1] = {
                                Achievement = achievement.Achievement,
                                Position = Vector(xPos, yPos),
                                Scale = scale,
                                Color = color
                            }
                        end

                        table.sort(displayedAchievements, function(a, b)
                            return a.Position.Y > b.Position.Y
                        end)

                        for _, display in ipairs(displayedAchievements) do
                            local achievement = display.Achievement
                            local useSprite = achievement.Sprite
                            if not achievement:IsUnlocked(true) then
                                useSprite = achievementLockedSprite
                            end

                            useSprite:SetFrame(anim, frame)
                            useSprite.Scale = display.Scale
                            useSprite.Color = display.Color
                            useSprite:Render(panelPos + display.Position + Vector(0, 30), Vector.Zero, Vector.Zero)
                        end
                    end,
                    HandleInputs = function(panel, input, item, itemswitched, tbl)
                        if not itemswitched then
                            local menuinput = input.menu
                            local rawinput = input.raw
                            if rawinput.left > 0 or rawinput.right > 0 then
                                local group = achievementGroups[item.achievementgroupselected]
                                local name = group.Name
                                local numAchievements = #group.Achievements


                                local change
                                if not panel.ShiftFrame then
                                    local usingInput, setChange
                                    if rawinput.right > 0 then
                                        usingInput = rawinput.right
                                        setChange = 1
                                    elseif rawinput.left > 0 then
                                        usingInput = rawinput.left
                                        setChange = -1
                                    end

                                    local shiftLength = 10
                                    if usingInput >= 88 then
                                        shiftLength = 7
                                    end

                                    if (usingInput == 1 or (usingInput >= 18 and usingInput % (shiftLength + 1) == 0)) then
                                        change = setChange
                                        panel.ShiftLength = shiftLength
                                    end
                                end

                                if change then
                                    panel.ShiftFrame = 0
                                    panel.ShiftDirection = change
                                    item.selectedingroup[name] = ((item.selectedingroup[name] + change -  1) % numAchievements) + 1
                                    dssmod.playSound(dssmod.menusounds.Pop3)
                                end
                            elseif menuinput.down or menuinput.up then
                                local change
                                if menuinput.down then
                                    change = 1
                                elseif menuinput.up then
                                    change = -1
                                end

                                if change then
                                    local done = false
                                    while not done do
                                        item.achievementgroupselected = ((item.achievementgroupselected + change - 1) % #achievementGroups) + 1
                                        local group = achievementGroups[item.achievementgroupselected]
                                        if not group.DisplayIf or group.DisplayIf() then
                                            done = true
                                        end
                                    end

                                    dssmod.playSound(dssmod.menusounds.Pop2)
                                end
                            end
                        end
                    end
                },
                Offset = Vector.Zero,
                Color = Color.Default
            },
            {
                Panel = {
                    Sprites = achievementTooltipSprites,
                    Bounds = {-115, -22, 115, 22},
                    Height = 44,
                    TopSpacing = 2,
                    BottomSpacing = 0,
                    DefaultFontSize = 2,
                    DrawPositionOffset = Vector(2, 2),
                    Draw = function(panel, pos, item, tbl)
                        local drawings = {}
                        local group = achievementGroups[item.achievementgroupselected]
                        if item.selectedingroup[group.Name] then
                            local achievementDat = group.Achievements[item.selectedingroup[group.Name]]
                            local achievement = achievementDat.Achievement
                            local tooltipConcat = ""
                            local tooltipConcat2 = ""
                            local singleLineLimit = 3
                            if not achievement.ViewerTooltip then
                                for i, entry in ipairs(achievement.Tooltip) do
                                    local toConcat = entry
                                    if i ~= #achievement.Tooltip and i ~= singleLineLimit then
                                        toConcat = toConcat .. " "
                                    end

                                    if i > singleLineLimit then
                                        tooltipConcat2 = tooltipConcat2 .. toConcat
                                    else
                                        tooltipConcat = tooltipConcat .. toConcat
                                    end
                                end
                            end

                            local name = achievement.Name
                            if not achievement:IsUnlocked(true) then
                                name = "locked!"
                            end

                            local buttons = {
                                {str = "- " .. achievementDat.Group .. " -", fsize = 1},
                                {str = name, fsize = 2},
                            }

                            if tooltipConcat ~= "" then
                                buttons[#buttons + 1] = {str = tooltipConcat, fsize = 1}
                            end

                            if tooltipConcat2 ~= "" then
                                buttons[#buttons + 1] = {str = tooltipConcat2, fsize = 1}
                            end

                            if achievement.ViewerTooltip then
                                for _, str in ipairs(achievement.ViewerTooltip) do
                                    buttons[#buttons + 1] = {str = str, fsize = 1}
                                end
                            end

                            local drawItem = {
                                valign = -1,
                                buttons = buttons
                            }
                            drawings = dssmod.generateMenuDraw(drawItem, drawItem.buttons, pos, panel.Panel)
                        end

                        if group then
                            table.insert(drawings, {type = "spr", pos = Vector(-96, 1), sprite = group.Icon, noclip = true, root = pos, usemenuclr = true})
                            table.insert(drawings, {type = "spr", pos = Vector(-96, -14), anim = "Idle", frame = 0, sprite = arrow, noclip = true, root = pos, usemenuclr = true})
                            table.insert(drawings, {type = "spr", pos = Vector(-96, 16), anim = "Idle", frame = 1, sprite = arrow, noclip = true, root = pos, usemenuclr = true})
                        end

                        for _, drawing in ipairs(drawings) do
                            dssmod.drawMenu(tbl, drawing)
                        end
                    end,
                    DefaultRendering = true
                },
                Offset = Vector(0, 100),
                Color = 1
            }
        }
    },
    generate = function(item, tbl)
        for _, group in ipairs(achievementGroups) do
            group.Achievements = {}
        
            local achievements
            if group.Tag then
                achievements = FiendFolio.GetAchievementsWithTag(group.Tag)
            else
                achievements = FiendFolio.ACHIEVEMENT_ORDERED
            end
        
            for _, achieve in ipairs(achievements) do
                if achieve.Sprite then
                    local groupName = group.Name
                    if group.TagToName then
                        for tag, name in pairs(group.TagToName) do
                            if achieve.Tags[tag] then
                                groupName = name
                                break
                            end
                        end
                    end

                    local display = true
                    if group.TagToDisplayIf then
                        for tag, func in pairs(group.TagToDisplayIf) do
                            if achieve.Tags[tag] and not func() then
                                display = false
                                break
                            end
                        end
                    end

                    if achieve.ViewerDisplayIf and not achieve.ViewerDisplayIf() then
                        display = false
                    end
                    
                    if display then
                        group.Achievements[#group.Achievements + 1] = {Achievement = achieve, Group = groupName}
                    end
                end
            end
        
            item.selectedingroup[group.Name] = 1
        end
    end,
    achievementgroupselected = 1,
    selectedingroup = {}
}

