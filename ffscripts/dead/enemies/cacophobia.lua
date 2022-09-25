local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local music = MusicManager()

local patternsFilenames = {
    "al",
	"blor",
    "bub",
    "ciiru",
    "cornmunity", -- wouldn't this be fun
    "creeps",
    "dead",
    "erfly",
    "ferrium",
    "guillotine21",
    "guwah",
    "jm2k",
    "jon",
    "mariamy",
    "mini",
    "peas",
    "pixelo",
    "pk",
    "ren",
    "sin",
    "sunil",
    "taiga",
    "vermin",
    "xalum"
}

local patternsLayouts = {}

for _, filename in ipairs(patternsFilenames) do
    local success, result = pcall(include, "resources.luarooms.cacophobia.patterns_" .. filename)
    if success then
        patternsLayouts[#patternsLayouts + 1] = {Rooms = result, Name = filename}
    end
end

local patternsList = StageAPI.RoomsList("FFCacophobiaPatterns", table.unpack(patternsLayouts))

local patternSubTypeCounts = {}

local setVariant = 0
for _, layout in ipairs(patternsList.All) do
    layout.Variant = setVariant

    patternSubTypeCounts[layout.SubType] = (patternSubTypeCounts[layout.SubType] or 0) + 1

    setVariant = setVariant + 1
end

local eyeSprite = Sprite()
eyeSprite:Load("gfx/bosses/cacophobia/caco_eye.anm2", true)

local musicChoices = {
    {
        Music = mod.Music.Venus1,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Venus3,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Venus4,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Venus6,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Venus7,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Venus5,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Venus8,
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Cacophobia1,
        MaximumHPWeight = 0,
        MinimumHPWeight = 1,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Cacophobia2,
        MaximumHPWeight = 0,
        MinimumHPWeight = 1,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Cacophobia3,
        MaximumHPWeight = 0,
        MinimumHPWeight = 1,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Cacophobia4,
        MaximumHPWeight = 0,
        MinimumHPWeight = 1,
        MaximumHP = 0.5,
        MinimumHP = 0.25
    },
    {
        Music = mod.Music.Cacophobia5,
        MaximumHPWeight = 0,
        MinimumHPWeight = 0.01,
        MaximumHP = 0.5,
        MinimumHP = 0.25,
        Condition = function(npc, data)
            return not data.CacophobiaKnockedOnYourDoor
        end,
        Trigger = function(npc, data)
            data.CacophobiaKnockedOnYourDoor = true
        end
    },
}

local recentMusicWeightMulti = {
    0.1,
    0.25,
    0.5,
    0.75
}

local roomDifficultyPhases = {
    {
        MaximumHP = 1,
        MinimumHP = 0.75,
        MinimumDifficulty = 1,
        MaximumDifficulty = 5
    },
    {
        MaximumHP = 0.75,
        MinimumHP = 0.5,
        MinimumDifficulty = 5,
        MaximumDifficulty = 10
    },
    {
        MaximumHP = 0.5,
        MinimumHP = 0.25,
        MinimumDifficulty = 10,
        MaximumDifficulty = 15,
        Difficulty0Weight = 0.5
    },
    {
        MaximumHP = 0.25,
        MinimumHP = 0,
        MinimumDifficulty = 15,
        Difficulty0Weight = 0.2
    }
}

local idleAnimations = {
    Idle1 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0,
        MaximumHP = 1,
        MinimumHP = 0
    },
    Idle2 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.1,
        MaximumHP = 1,
        MinimumHP = 0
    },
    Idle3 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.2,
        MaximumHP = 0.9,
        MinimumHP = 0
    },
    Idle4 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.2,
        MaximumHP = 0.9,
        MinimumHP = 0
    },
    Idle5 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.4,
        MaximumHP = 0.75,
        MinimumHP = 0
    },
    Idle6 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.4,
        MaximumHP = 0.75,
        MinimumHP = 0
    },
    Idle7 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.7,
        MaximumHP = 0.5,
        MinimumHP = 0
    },
    Idle8 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 0.7,
        MaximumHP = 0.5,
        MinimumHP = 0
    },
    Idle9 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 1,
        MaximumHP = 0.35,
        MinimumHP = 0
    },
    Idle10 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 1,
        MaximumHP = 0.35,
        MinimumHP = 0,
        Condition = function(npc)
            local room = game:GetRoom()
            return npc.Position.Y < room:GetCenterPos().Y
        end
    },
    Idle11 = {
        MaximumHPWeight = 0.2,
        MinimumHPWeight = 0.2,
        MaximumHP = 0.2,
        MinimumHP = 0,
        Condition = function(npc, data)
            return not data.DoneStatuePose
        end,
        Trigger = function(npc, data)
            data.DoneStatuePose = true
        end
    },
    Idle12 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 1,
        MaximumHP = 0.25,
        MinimumHP = 0
    },
    Idle13 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 1,
        MaximumHP = 0.25,
        MinimumHP = 0
    },
    Idle14 = {
        MaximumHPWeight = 1,
        MinimumHPWeight = 1,
        MaximumHP = 0.25,
        MinimumHP = 0
    }
}

StageAPI.AddMetadataEntity({
    Name = "CacophobiaTarget",
    BitValues = {
        GroupID = {Offset = 0, Length = 16}
    }
}, 12005, 1)

StageAPI.AddMetadataEntity({
    Name = "CacophobiaEyeModifier",
    BitValues = {
        AngleOffset = {Offset = 0, Length = 4},
        TargetMode = {Offset = 4, Length = 2},
        StartTargetGroup = {Offset = 6, Length = 5},
        EndTargetGroup = {Offset = 11, Length = 5},
    }
}, 12008, 1)

local projectileVelocities = {
    [1] = 2, -- slowest
    [2] = 4, -- slow
    [3] = 7, -- standard
    [4] = 10 -- fast
}
local function spawnCacophobiaProjectile(npc, pos, direction, velocityMode, timeSkip)
    local velocity = direction * projectileVelocities[velocityMode]
    local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos + velocity * timeSkip, velocity, npc):ToProjectile()
    projectile:GetData().CacophobiaProjectile = true
    projectile.FallingAccel = -0.1
    projectile.Height = -7
    return projectile
end

local removedEntityTypes = {
    EntityType.ENTITY_TEAR,
    EntityType.ENTITY_PROJECTILE,
    EntityType.ENTITY_LASER,
    EntityType.ENTITY_BOMB,
    EntityType.ENTITY_BLOOD_PUPPY -- converts back to familiar
}

local removedEffectVariants = {
    EffectVariant.CREEP_BLACK,
    EffectVariant.CREEP_BROWN,
    EffectVariant.CREEP_GREEN,
    EffectVariant.CREEP_LIQUID_POOP,
    EffectVariant.CREEP_SLIPPERY_BROWN,
    EffectVariant.CREEP_SLIPPERY_BROWN_GROWING,
    EffectVariant.CREEP_STATIC,
    EffectVariant.CREEP_WHITE,
    EffectVariant.CREEP_YELLOW,
    EffectVariant.PLAYER_CREEP_BLACK,
    EffectVariant.PLAYER_CREEP_BLACKPOWDER,
    EffectVariant.PLAYER_CREEP_GREEN,
    EffectVariant.PLAYER_CREEP_HOLYWATER,
    EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL,
    EffectVariant.PLAYER_CREEP_LEMON_MISHAP,
    EffectVariant.PLAYER_CREEP_LEMON_PARTY,
    EffectVariant.PLAYER_CREEP_PUDDLE_MILK,
    EffectVariant.PLAYER_CREEP_RED,
    EffectVariant.PLAYER_CREEP_WHITE
}

local function clearCacophobiaEnts(data)
    if data.Hitboxes then
        for _, hitbox in ipairs(data.Hitboxes) do
            hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end

    for _, removeType in ipairs(removedEntityTypes) do
        for _, entity in ipairs(Isaac.FindByType(removeType)) do
            if not entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
                entity:Remove()
            end
        end
    end

    for _, removeVariant in ipairs(removedEffectVariants) do
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, removeVariant)) do
            if not entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
                entity:Remove()
            end
        end
    end

    local room = game:GetRoom()
    for i = 0, room:GetGridSize() do
        local grid = room:GetGridEntity(i)
        if grid and grid.Desc.Type == GridEntityType.GRID_DECORATION then
            room:RemoveGridEntity(i, 0, false)
        end
    end
end

local requirePatternSubtype = nil
local skipDifficultyZero = nil
local skipPatternVariants = {}
local isCacophobiaNotUpdating = nil
local cacophobiaMusicInterfered = nil
local cacophobiaSpeedInterfered = nil
local cacophobiaHUDInterfered = nil
local cacophobiaHPPercent

local function hpBasedWeight(hpPercent, minimumHP, maximumHP, minimumHPWeight, maximumHPWeight)
    if hpPercent < minimumHP then
        return minimumHPWeight
    elseif hpPercent > maximumHP then
        return maximumHPWeight
    end

    local percentThrough = 1 - ((hpPercent - minimumHP) / (maximumHP - minimumHP))
    local weight = mod:Lerp(maximumHPWeight, minimumHPWeight, percentThrough)
    return weight
end

function mod:cacophobiaAI(npc, sprite, data)
    if not data.Init then
        data.Init = true
        data.Cooldown = 60
        data.SetSelfPosition = npc.Position
        data.Renderer = StageAPI.SpawnFloorEffect(npc.Position, Vector.Zero, npc, nil, false, mod.FF.CacophobiaRenderer.Var)
        data.Renderer.Parent = npc
        data.FirstPattern = true
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS)
    end

    isCacophobiaNotUpdating = false
    data.Updated = true

    npc.Position = data.SetSelfPosition
    npc.Velocity = Vector.Zero

    if not data.Blackout then
        data.Cooldown = data.Cooldown - 1
    else
        data.Blackout = data.Blackout - 1
        --HI DEAD REN WANTED ME TO ADD THIS
        --HOPE YOU DON'T MIND :)
        -- SIGNED, VENUS

        --HI VENUS THANKS, I UPDATED THIS TO USE THE NEW SPRITES
        -- SIGNED, DEAD
        if data.Blackout <= 0 then
            StageAPI.ChangeRoomGfx(mod.CacophobiaBackdrop)

            local poseOptions = {}
            local hpPercent = npc.HitPoints / npc.MaxHitPoints
            for anim, option in pairs(idleAnimations) do
                if not option.Condition or option.Condition(npc, data) then
                    if hpPercent >= option.MinimumHP and hpPercent <= option.MaximumHP then
                        local weight = hpBasedWeight(hpPercent, option.MinimumHP, option.MaximumHP, option.MinimumHPWeight, option.MaximumHPWeight)
                        poseOptions[#poseOptions + 1] = {{anim, option}, weight}
                    end
                end
            end

            local chosenPose = StageAPI.WeightedRNG(poseOptions)
            local anim = chosenPose[1]
            if chosenPose[2].Trigger then
                chosenPose[2].Trigger(npc, data)
            end

            sprite:Play(anim, true)
            sfx:Play(mod.Sounds.VenusBackToFight, 1, 0, false, 0.9, 0)

            data.RecentMusic = data.RecentMusic or {}

            local musicOptions = {}
            for _, option in ipairs(musicChoices) do
                local valid = true
                if option.Condition and not option.Condition(npc, data) then
                    valid = false
                end

                if valid then
                    local weight = hpBasedWeight(hpPercent, option.MinimumHP, option.MaximumHP, option.MinimumHPWeight, option.MaximumHPWeight)
                    for i = 1, #recentMusicWeightMulti do
                        if data.RecentMusic[i] == option.Music then
                            weight = weight * recentMusicWeightMulti[i]
                        end
                    end

                    musicOptions[#musicOptions + 1] = {option, weight}
                end
            end

            local toPlay = StageAPI.WeightedRNG(musicOptions)

            cacophobiaMusicInterfered = true
            local noPlayMusic
            if toPlay.Trigger then
                noPlayMusic = toPlay.Trigger(npc, data)
            end

            table.insert(data.RecentMusic, 1, toPlay.Music)
            data.RecentMusic[#recentMusicWeightMulti + 1] = nil
            
            if not noPlayMusic then
                music:Play(toPlay.Music, Options.MusicVolume)
                music:Resume()
            end

            if cacophobiaHUDInterfered then
                game:GetHUD():SetVisible(true)
                cacophobiaHUDInterfered = nil
            end

            data.Blackout = nil
        end

        if data.SetPlayerPosition then
            for i = 0, game:GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(i)
                player.Position = data.SetPlayerPosition
                player.Velocity = Vector.Zero
                if data.Blackout then
                    player.ControlsCooldown = 2
                end
            end
        end
    end

    local room = game:GetRoom()

    if data.Cooldown <= 0 and not data.Blackout then
        clearCacophobiaEnts(data)

        if data.FirstPattern then
            npc.HitPoints = npc.MaxHitPoints
            data.FirstPattern = nil
        end

        skipPatternVariants = {}
        requirePatternSubtype = nil
        cacophobiaHPPercent = npc.HitPoints / npc.MaxHitPoints

        if data.Pattern then
            skipPatternVariants[data.Pattern.Variant] = true

            if data.LastRandomPattern then
                skipPatternVariants[data.LastRandomPattern] = true
            end

            if data.Pattern.NextPatternSubtype == - 1 then
                while data.Pattern.Repeat == 0 and data.Pattern.Parent do
                    data.Pattern = data.Pattern.Parent
                end
            end

            if data.Pattern.Difficulty == 0 then
                skipDifficultyZero = true
            end

            if data.Pattern.Repeat == 0 and data.Pattern.InitialRepeat > 0 then
                skipPatternVariants[data.Pattern.Variant] = true
                data.Pattern = nil
            else
                if data.Pattern.Repeat > 0 then
                    data.Pattern.Repeat = data.Pattern.Repeat - 1
                end
    
                if data.Pattern.NextPatternSubtype ~= -1 then
                    requirePatternSubtype = data.Pattern.NextPatternSubtype
                end
            end
        end

        local seed = Random()
        local newPatternLayout = StageAPI.ChooseRoomLayout(patternsList, seed, room:GetRoomShape(), nil, false, true, nil, nil)
        local entities, _, _, _, _, metadata = StageAPI.ObtainSpawnObjects(newPatternLayout, seed)

        local isSubPattern = not not requirePatternSubtype

        skipPatternVariants= {}
        skipDifficultyZero = nil
        requirePatternSubtype = nil
        cacophobiaHPPercent = nil

        local newPattern = {
            Eyes = {},
            Targets = {},
            Repeat = 0,
            InitialRepeat = 0,
            Cooldown = 0,
            BlackoutTime = 0,
            FrameCount = 0,
            IsSubPattern = isSubPattern,
            Variant = newPatternLayout.Variant,
            SubType = newPatternLayout.SubType,
            Difficulty = newPatternLayout.Difficulty,
            PatternName = tostring(newPatternLayout.Variant) .. " " .. newPatternLayout.Name,
            NextPatternSubtype = -1
        }

        if newPattern.SubType == 0 then
            data.LastRandomPattern = newPattern.Variant
        end

        local targets = metadata:Search{Name = "CacophobiaTarget"}
        for _, target in ipairs(targets) do
            local pos = room:GetGridPosition(target.Index)
            local group = target.BitValues.GroupID
            newPattern.Targets[group] = newPattern.Targets[group] or {}
            newPattern.Targets[group][#newPattern.Targets[group] + 1] = pos
        end

        local parent = data.Pattern
        while parent and parent.InitialRepeat == 0 do -- pick the first parent of the current pattern that has a repeat > 0
            parent = parent.Parent
        end

        if parent then
            newPattern.Parent = parent
        end

        local globalTimeModifier = 0

        for index, stack in pairs(entities) do
            local pos = room:GetGridPosition(index)
            for _, entityDat in ipairs(stack) do
                local entity = entityDat.Data
                if entity.Type == 12000 then
                    data.SetSelfPosition = pos

                    newPattern.NextPatternSubtype = FiendFolio.GetBits(entity.Variant, 0, 12) - 1
                    newPattern.Repeat = FiendFolio.GetBits(entity.Variant, 12, 4)
                    newPattern.InitialRepeat = newPattern.Repeat
                    newPattern.Cooldown = FiendFolio.GetBits(entity.SubType, 0, 8) * 3
                    newPattern.BlackoutTime = FiendFolio.GetBits(entity.SubType, 8, 8) * 3
                elseif entity.Type == 12001 then
                    data.SetPlayerPosition = pos
                elseif entity.Type == 12002 or entity.Type == 12003 or entity.Type == 12004 then
                    local eyeData = {
                        Position = pos,
                        Radial = entity.Type == 12002,
                        Targeted = entity.Type == 12004,
                        InitialDelay = (FiendFolio.GetBits(entity.Variant, 0, 8) - 127) * 3,
                        LoopDelay = FiendFolio.GetBits(entity.Variant, 8, 8) - 1,
                        TimesFired = 0,
                    }

                    local eyeModifiers = metadata:Search({Index = index, Name = "CacophobiaEyeModifier"})
                    for _, modifier in ipairs(eyeModifiers) do
                        eyeData.AngleOffsetBy = modifier.BitValues.AngleOffset * (360 / 16)
                        eyeData.TargetGroupMode = modifier.BitValues.TargetMode
                        eyeData.StartTargetGroup = modifier.BitValues.StartTargetGroup
                        eyeData.EndTargetGroup = modifier.BitValues.EndTargetGroup
                    end

                    if eyeData.Targeted then
                        eyeData.TargetGroup = FiendFolio.GetBits(entity.SubType, 0, 6)
                        eyeData.VelocityMode = FiendFolio.GetBits(entity.SubType, 6, 2) + 1
                        eyeData.NumProjectiles = FiendFolio.GetBits(entity.SubType, 8, 4)
                        eyeData.Spread = FiendFolio.GetBits(entity.SubType, 12, 4) * 10
                    else
                        eyeData.AimMode = FiendFolio.GetBits(entity.SubType, 0, 2)
                        eyeData.VelocityMode = FiendFolio.GetBits(entity.SubType, 2, 2) + 1
                        eyeData.NumProjectiles = FiendFolio.GetBits(entity.SubType, 4, 4)
                        eyeData.Angle = FiendFolio.GetBits(entity.SubType, 8, 4) * (360 / 16)
                    end

                    if eyeData.TargetGroupMode and eyeData.TargetGroupMode ~= 0 then
                        eyeData.TargetGroup = eyeData.StartTargetGroup
                        eyeData.Targeted = true
                    end
                    
                    if eyeData.Angle then
                        eyeData.Direction = Vector.FromAngle(eyeData.Angle)
                    end

                    eyeData.Timer = eyeData.InitialDelay

                    if eyeData.LoopDelay ~= -1 then
                        eyeData.LoopDelay = eyeData.LoopDelay * 3
                    end
                    
                    if eyeData.Radial then
                        eyeData.NumProjectiles = eyeData.NumProjectiles + 1
                        eyeData.NumGaps = FiendFolio.GetBits(entity.SubType, 12, 4)
                    elseif not eyeData.Targeted then
                        eyeData.Spread = FiendFolio.GetBits(entity.SubType, 12, 4) * 10
                    end

                    newPattern.Eyes[#newPattern.Eyes + 1] = eyeData
                elseif entity.Type == 12006 then
                    local eyeData = {
                        Position = pos,
                        NumProjectiles = 0,
                        WeirdEyeMode = FiendFolio.GetBits(entity.SubType, 0, 4),
                        Shaking = FiendFolio.GetBits(entity.SubType, 4, 1) == 1,
                        Unblinking = FiendFolio.GetBits(entity.SubType, 5, 1) == 1,
                        TargetGroup = FiendFolio.GetBits(entity.SubType, 6, 6)
                    }

                    newPattern.Eyes[#newPattern.Eyes + 1] = eyeData
                elseif entity.Type == 12007 then
                    globalTimeModifier = globalTimeModifier + (FiendFolio.GetBits(entity.SubType, 0, 8) - 127) * 3
                end
            end
        end

        for _, eye in ipairs(newPattern.Eyes) do
            if eye.InitialDelay then
                eye.InitialDelay = eye.InitialDelay + globalTimeModifier
                eye.Timer = eye.InitialDelay
            end

            eye.ToSpawn = (data.SetPlayerPosition - eye.Position):GetAngleDegrees()
        end
        
        data.Blackout = newPattern.BlackoutTime

        if newPattern.BlackoutTime ~= 0 then
            sfx:Play(mod.Sounds.VenusToBlack, 1, 0, false, 1, 0)
        end

        if game:GetHUD():IsVisible() then
            game:GetHUD():SetVisible(false)
            cacophobiaHUDInterfered = true
        end

        music:Pause()
        cacophobiaMusicInterfered = true

        data.Pattern = newPattern
        data.Cooldown = newPattern.Cooldown
    end

    if data.Pattern and not data.Blackout then
        data.Pattern.FrameCount = data.Pattern.FrameCount + 1

        game:Darken(0.8, 30)

        local players = {}
        for i = 0, game:GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            player.MoveSpeed = 1
            players[#players + 1] = {Player = player, CloseEyes = {}}
        end

        cacophobiaSpeedInterfered = true

        local target = npc:GetPlayerTarget()
        local globalShake = RandomVector() * 0.5
        for eyeIndex, eye in ipairs(data.Pattern.Eyes) do
            for _, player in ipairs(players) do
                local p = player.Player
                local distance = eye.Position:DistanceSquared(p.Position)
                for i = 1, 2 do
                    if not player.CloseEyes[i] or distance < player.CloseEyes[i].Distance then
                        table.insert(player.CloseEyes, i, {Distance = distance, Eye = eyeIndex})
                        break
                    end
                end

                player.CloseEyes[3] = nil
            end

            eye.PupilOffset = (target.Position - eye.Position):Resized(2)

            if eye.NumProjectiles ~= 0 then
                while eye.Timer <= 0 and not eye.StopShooting do
                    local timeSkip = math.abs(eye.Timer)

                    local targetDirection
                    if eye.Targeted then
                        local groupPositions = data.Pattern.Targets[eye.TargetGroup]
                        if groupPositions and #groupPositions > 0 then
                            targetDirection = (groupPositions[math.random(1, #groupPositions)] - eye.Position):Normalized()
                        end
                    else
                        targetDirection = eye.Direction
                        if eye.AimMode == 1 then
                            targetDirection = eye.Direction:Rotated((target.Position - eye.Position):GetAngleDegrees())
                        elseif eye.AimMode == 2 then
                            targetDirection = RandomVector()
                        elseif eye.AimMode == 3 then
                            targetDirection = eye.Direction:Rotated(eye.ToSpawn)
                        end
                    end

                    if eye.TargetGroupMode == 1 then
                        eye.TargetGroupDirection = eye.TargetGroupDirection or 1
                        if eye.TargetGroup == eye.EndTargetGroup then
                            eye.TargetGroupDirection = -1
                        elseif eye.TargetGroup == eye.StartTargetGroup then
                            eye.TargetGroupDirection = 1
                        end

                        eye.TargetGroup = eye.TargetGroup + eye.TargetGroupDirection
                    elseif eye.TargetGroupMode == 2 then
                        eye.TargetGroup = eye.TargetGroup + 1
                        if eye.TargetGroup > eye.EndTargetGroup then
                            eye.TargetGroup = eye.StartTargetGroup
                        end
                    end

                    if targetDirection then
                        if eye.AngleOffsetBy then
                            targetDirection = targetDirection:Rotated(eye.AngleOffsetBy * eye.TimesFired)
                        end

                        if eye.Radial then
                            local gapModulo
                            if eye.NumGaps ~= 0 then
                                gapModulo = eye.NumProjectiles / eye.NumGaps
                            end
                            
                            for i = 0, eye.NumProjectiles - 1 do
                                if not gapModulo or i % gapModulo ~= 0 then
                                    local dir = targetDirection:Rotated((360 / eye.NumProjectiles) * i)
                                    spawnCacophobiaProjectile(npc, eye.Position, dir, eye.VelocityMode, timeSkip)
                                end
                            end
                        elseif targetDirection then
                            for i = 0, eye.NumProjectiles - 1 do
                                if eye.NumProjectiles == 1 then
                                    spawnCacophobiaProjectile(npc, eye.Position, targetDirection, eye.VelocityMode, timeSkip)
                                else
                                    local angle = mod:Lerp(-eye.Spread / 2, eye.Spread / 2, i / (eye.NumProjectiles - 1))
                                    local dir = targetDirection:Rotated(angle)
                                    spawnCacophobiaProjectile(npc, eye.Position, dir, eye.VelocityMode, timeSkip)
                                end
                            end
                        end
                    end

                    eye.TimesFired = eye.TimesFired + 1
                    if eye.LoopDelay == -1 then
                        eye.StopShooting = true
                        break
                    else
                        eye.Timer = eye.Timer + eye.LoopDelay
                    end
                end

                local timeSinceLastShoot = eye.LoopDelay - eye.Timer
                local timeUntilNextShoot = eye.Timer

                if eye.StopShooting then
                    timeUntilNextShoot = 999
                end

                if timeSinceLastShoot < timeUntilNextShoot then
                    if timeSinceLastShoot <= 10 then
                        eye.ShootFrame = 6 + timeSinceLastShoot
                    else
                        eye.ShootFrame = nil
                    end
                else
                    if timeUntilNextShoot <= 6 then
                        eye.ShootFrame = 6 - timeUntilNextShoot
                    else
                        eye.ShootFrame = nil
                    end
                end

                eye.Timer = eye.Timer - 1
            else
                if eye.WeirdEyeMode == 1 then
                    eye.BlinkFrame = 10
                elseif eye.WeirdEyeMode == 2 then
                    eye.PupilOffset = -eye.PupilOffset
                elseif eye.WeirdEyeMode == 3 or eye.WeirdEyeMode == 4 then
                    local toVenus = (npc.Position - eye.Position):Resized(2)
                    if eye.WeirdEyeMode == 3 then
                        eye.PupilOffset = -toVenus
                    else
                        eye.PupilOffset = toVenus
                    end
                elseif eye.WeirdEyeMode == 5 then
                    eye.PupilOffset = Vector.Zero
                elseif eye.WeirdEyeMode == 6 then
                    local groupPositions = data.Pattern.Targets[eye.TargetGroup]
                    if groupPositions and #groupPositions > 0 then
                        eye.PupilOffset = (groupPositions[1] - eye.Position):Resized(2)
                    end
                end

                if eye.Shaking then
                    eye.PupilOffset = eye.PupilOffset + globalShake
                end

                if not eye.Unblinking and eye.WeirdEyeMode ~= 1 then
                    if not eye.BlinkFrame then
                        if math.random(1, 400) == 1 then
                            eye.BlinkFrame = 0
                        end
                    else
                        eye.BlinkFrame = eye.BlinkFrame + 1
                        if eye.BlinkFrame >= 26 then
                            eye.BlinkFrame = nil
                        end
                    end
                end
            end
        end

        -- hitbox fun!
        local eyesNeedingHitboxes = {}
        local eyeHitboxCount = 0

        data.Hitboxes = data.Hitboxes or {}
        for i = #data.Hitboxes, 1, -1 do
            local hitbox = data.Hitboxes[i]
            if not hitbox:Exists() then
                table.remove(data.Hitboxes, i)
            else
                hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            end
        end

        for _, player in ipairs(players) do
            for i = 1, 2 do
                if player.CloseEyes[i] then
                    if not eyesNeedingHitboxes[player.CloseEyes[i].Eye] then
                        eyesNeedingHitboxes[player.CloseEyes[i].Eye] = true
                        eyeHitboxCount = eyeHitboxCount + 1
                    end
                end
            end
        end

        local nextHitbox = 1
        for eyeIndex, _ in pairs(eyesNeedingHitboxes) do
            local eye = data.Pattern.Eyes[eyeIndex]
            local pos = eye.Position

            local hitbox
            if data.Hitboxes[nextHitbox] then
                hitbox = data.Hitboxes[nextHitbox]
            else
                local newHitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, pos, Vector.Zero, npc)
                newHitbox.SpawnerEntity = npc
                newHitbox.Parent = npc
                newHitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                newHitbox.CollisionDamage = 2
                newHitbox:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
                newHitbox:GetData().OnAnimaSola = function(hb, chain)
                    chain.Position = npc.Position
                    chain.Target = npc
                end

                data.Hitboxes[nextHitbox] = newHitbox
                hitbox = data.Hitboxes[nextHitbox]
            end

            if data.Pattern.FrameCount >= 15 or data.Pattern.IsSubPattern then
                hitbox.CollisionDamage = 2
            else
                hitbox.CollisionDamage = 0
            end

            hitbox.Velocity = Vector.Zero
            hitbox.Position = pos
            hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            hitbox:GetData().FixToPosition = pos

            nextHitbox = nextHitbox + 1
        end
    end
end

local cacophobiaPlayerInterfered = nil
function mod:checkCacophobiaFrozen()
    local venus = Isaac.FindByType(mod.FF.CacophobiaVenus.ID, mod.FF.CacophobiaVenus.Var)[1]
    if venus then
        local data = venus:GetData()
        local sprite = venus:GetSprite()
        if sprite:GetAnimation() == "Death" then
            venus.Visible = false
            if data.Pattern or (not data.Blackout and not data.TheField) then
                clearCacophobiaEnts(data)
                data.Pattern = nil
                sfx:Play(mod.Sounds.VenusToBlack, 1, 0, false, 1, 0)
                music:Pause()
                local frame = sprite:GetFrame()
                venus:ToNPC():Morph(venus.Type, venus.Variant, 1, -1)
                sprite = venus:GetSprite()
                sprite:Play("Death", true)
                sprite:SetFrame(frame)
            end

            cacophobiaMusicInterfered = true

            sfx:Stop(SoundEffect.SOUND_SATAN_ROOM_APPEAR)
            sfx:Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
            sfx:Stop(SoundEffect.SOUND_DOOR_HEAVY_OPEN)

            data.Blackout = 2

            local room = game:GetRoom()
            if sprite:IsEventTriggered("The Field") then
                if not data.TheField then
                    sfx:Play(mod.Sounds.VenusBackToFight, 1, 0, false, 0.9, 0)
                    music:Resume()
                    music:Play(mod.Music.TheField, Options.MusicVolume)

                    if game:GetHUD():IsVisible() then
                        game:GetHUD():SetVisible(false)
                        cacophobiaHUDInterfered = true
                    end

                    data.TheField = true
                end
            elseif sprite:IsEventTriggered("Blackout") then
                if data.TheField then
                    sfx:Play(mod.Sounds.VenusToBlack, 1, 0, false, 1, 0)
                    music:Pause()

                    if cacophobiaHUDInterfered then
                        game:GetHUD():SetVisible(true)
                        cacophobiaHUDInterfered = nil
                    end

                    data.TheField = false
                end
            elseif sprite:IsFinished() then
                if FiendFolio.GolemExists() and room:GetType() == RoomType.ROOM_BOSS then
                    local trinket = FiendFolio.GetGolemTrinket()
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinket, room:GetCenterPos() + Vector(0, 40), RandomVector() * 2, nil)
                end

                StageAPI.ChangeBackdrop(BackdropType.SCARRED_WOMB)
                music:Resume()
                music:Play(mod.Music.BossOver, Options.MusicVolume)
                sfx:Play(mod.Sounds.VenusBackToFight, 1, 0, false, 0.9, 0)
            end

            if data.TheField then
                data.Blackout = nil
            else
                data.Blackout = 2
            end
            
            for i = 0, room:GetGridSize() do
                local grid = room:GetGridEntity(i)
                if grid then
                    if grid.Desc.Type == GridEntityType.GRID_DOOR then
                        grid.State = 1
                    elseif grid.Desc.Type == GridEntityType.GRID_TRAPDOOR or grid.Desc.Type == GridEntityType.GRID_STAIRS then
                        grid.State = 0
                    end
                end
            end

            for i = 0, game:GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(i)
                if not data.TheField then
                    player.Position = room:GetCenterPos()
                    player.ControlsCooldown = math.max(player.ControlsCooldown, 2)
                end

                if player.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then -- this is to make sure you don't pick up the item while in the field
                    cacophobiaPlayerInterfered = true
                    player:GetData().CacophobiaChangedCollision = player.EntityCollisionClass
                    player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                end
            end
        else
            if data.Pattern then
                if data.Updated then
                    data.Updated = false
                else
                    if data.Blackout then -- in case venus is frozen during blackout, try to make it behave as usual
                        mod:cacophobiaAI(venus:ToNPC(), venus:GetSprite(), data)
                        data.Updated = false
                    end

                    isCacophobiaNotUpdating = true
                end
            end
        end
    else
        if cacophobiaMusicInterfered then
            local musicID = music:GetCurrentMusicID()
            for _, choice in ipairs(musicChoices) do
                if choice.Music == musicID then
                    music:Play(Music.MUSIC_NULL, 1)
                end
            end

            music:Resume()
            cacophobiaMusicInterfered = nil
        end

        if cacophobiaPlayerInterfered or cacophobiaSpeedInterfered then
            for i = 0, game:GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(i)
                local data = player:GetData()
                if data.CacophobiaChangedCollision then
                    player.EntityCollisionClass = data.CacophobiaChangedCollision
                    data.CacophobiaChangedCollision = nil
                end
                
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end

            cacophobiaPlayerInterfered = nil
            cacophobiaSpeedInterfered = nil
        end

        if cacophobiaHUDInterfered then
            game:GetHUD():SetVisible(true)
            cacophobiaHUDInterfered = nil
        end
    end
end

function mod:cacophobiaRendererAI(effect, offset)
    local venus = effect.Parent
    if not venus or not venus:Exists() then
        effect:Remove()
        return
    end

    venus = venus:ToNPC()

    local data = venus:GetData()
    if data.Pattern then
        local room = game:GetRoom()
        for _, eye in ipairs(data.Pattern.Eyes) do
            local screenPos = room:WorldToScreenPosition(eye.Position)

            eyeSprite:SetFrame("Base", 0)
            eyeSprite:Render(screenPos)

            eyeSprite:SetFrame("Pupil", 0)
            eyeSprite:Render(screenPos + (eye.PupilOffset or Vector.Zero))

            if eye.ShootFrame then
                eyeSprite:SetFrame("Shoot", eye.ShootFrame)
            elseif eye.BlinkFrame then
                eyeSprite:SetFrame("Blink", eye.BlinkFrame)
            else
                eyeSprite:SetFrame("Idle", venus.FrameCount % 20)
            end

            eyeSprite:Render(screenPos)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.cacophobiaRendererAI, mod.FF.CacophobiaRenderer.Var)

local theField = Sprite()
theField:Load("gfx/backdrop/cacophobia/the_field.anm2", true)
theField:SetFrame("Idle", 0)

function mod:cacophobiaRoomRender()
    local venus = Isaac.FindByType(mod.FF.CacophobiaVenus.ID, mod.FF.CacophobiaVenus.Var)[1]
    if venus then
        if venus:GetData().TheField then
            local room = game:GetRoom()
            local renderPos = room:WorldToScreenPosition(room:GetTopLeftPos() - Vector(80, 80))
            theField:Render(renderPos)

            local offset = room:GetRenderScrollOffset()
            for i = 0, game:GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(i)
                if player.Visible then
                    player:RenderShadowLayer(offset)
                    player:Render(offset)
                end
            end
        elseif game:IsPaused() and venus:GetData().Blackout then
            StageAPI.RenderBlackScreen(1)
        end
    end
end

function mod:cacophobiaProjectileAI(proj, data)
    if isCacophobiaNotUpdating then
        if not data.FrozeProjectile then
            data.FrozeProjectile = proj.Velocity
        end

        proj.Velocity = Vector.Zero
    elseif data.FrozeProjectile then
        proj.Velocity = data.FrozeProjectile
        data.FrozeProjectile = nil
    end
end

StageAPI.AddCallback("FiendFolio", "POST_CHECK_VALID_ROOM", 1, function(layout)
    local hasCacophobia = #Isaac.FindByType(mod.FF.CacophobiaVenus.ID, mod.FF.CacophobiaVenus.Var) > 0
    if not hasCacophobia then
        skipPatternVariants = {}
        requirePatternSubtype = nil
        cacophobiaHPPercent = nil
        skipDifficultyZero = nil
        return
    end

    if requirePatternSubtype then
        if layout.SubType ~= requirePatternSubtype then
            return false
        else
            return layout.Weight
        end
    elseif layout.SubType ~= 0 then
        return false
    end

    if skipPatternVariants[layout.Variant] then
        if not requirePatternSubtype or patternSubTypeCounts[layout.SubType] > 1 then
            return false
        end
    end

    if layout.Weight >= 99 then -- for testing convenience these layouts aren't affected by health difficulty scaling
        return
    end

    if layout.Difficulty == 0 and skipDifficultyZero and not requirePatternSubtype then
        return false
    end

    if cacophobiaHPPercent then
        local activePhase
        for _, phase in ipairs(roomDifficultyPhases) do
            if cacophobiaHPPercent > phase.MinimumHP and cacophobiaHPPercent <= phase.MaximumHP then
                activePhase = phase
                break
            end
        end

        if activePhase then
            local percentThroughPhase = 1 - ((cacophobiaHPPercent - activePhase.MinimumHP) / (activePhase.MaximumHP - activePhase.MinimumHP))

            if layout.Difficulty == 0 then
                return (activePhase.Difficulty0Weight or 1) * layout.Weight
            elseif activePhase.MinimumDifficulty and activePhase.MaximumDifficulty then
                if layout.Difficulty >= activePhase.MinimumDifficulty and layout.Difficulty <= activePhase.MaximumDifficulty then
                    local difficultyPercent = (layout.Difficulty - activePhase.MinimumDifficulty) / (activePhase.MaximumDifficulty - activePhase.MinimumDifficulty)
                    local difficultyModifier = mod:Lerp(1 - difficultyPercent, difficultyPercent, percentThroughPhase)
                    return layout.Weight * difficultyModifier
                else
                    return 0
                end
            elseif (activePhase.MinimumDifficulty and layout.Difficulty < activePhase.MinimumDifficulty) or (activePhase.MaximumDifficulty and layout.Difficulty > activePhase.MaximumDifficulty) then
                return 0
            end
        elseif layout.Difficulty > 5 then
            return false
        end
    end
end)

function mod:cacophobiaHurt(npc, damage, flag, source, cooldown)
    if npc:IsDead() then
        return
    end

    local data = npc:GetData()
    if not data.Pattern then -- detecting lethal damage is annoying so let's just fake damage altogether :D
        npc.HitPoints = math.max(0, npc.HitPoints - damage)
        npc:SetColor(FiendFolio.damageFlashColor, 2, 0, false, false)
        return false
    end
end