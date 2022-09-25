local mod = FiendFolio

local ebbFilepath = "gfx/ui/bosshp_icons/ff/"

local ebbIcons = {
    {
        BossID = mod.FF.Buck,
        Sprite = "buck",
    },
    {
        BossID = mod.FF.Honeydrop,
        Sprite = "honeydrop",
        Conditionals = {
            {
                function(entity)
                    return entity.SubType == 1
                end,
                ebbFilepath .. "honeydrop_red" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.Battie,
        Sprite = "battie",
        Conditionals = {
            {
                function(entity)
                    return entity.SubType == 1
                end,
                ebbFilepath .. "battie_brown" .. ".png"
            },
            {
                function(entity)
                    return entity.SubType == 2
                end,
                ebbFilepath .. "battie_purple" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.Buster,
        Sprite = "buster",
    },
    {
        BossID = mod.FF.GriddleHorn,
        Sprite = "griddlehorn",
    },
    {
        BossID = mod.FF.Monsoon,
        Sprite = "monsoon",
        Conditionals = {
            {
                function(entity)
                    return entity:GetData().IsATinyBoy and not FiendFolio.isBackdrop("Scarred Womb")
                end,
                ebbFilepath .. "monsoon_small" .. ".png"
            },
            {
                function(entity)
                    return FiendFolio.isBackdrop("Scarred Womb") and not entity:GetData().IsATinyBoy
                end,
                ebbFilepath .. "monsoon_blood" .. ".png"
            },
            {
                function(entity)
                    return FiendFolio.isBackdrop("Scarred Womb") and entity:GetData().IsATinyBoy
                end,
                ebbFilepath .. "monsoon_small_blood" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.SunVenus,
        Sprite = "sun_venus",
    },
    {
        BossID = mod.FF.SunEarth,
        Sprite = "sun_earth",
    },
    {
        BossID = mod.FF.SunNeptune,
        Sprite = "sun_neptune",
    },
    {
        BossID = mod.FF.OrgChaser,
        Sprite = "organization1",
        Conditionals = {
            {
                function(entity)
                    return entity:GetData().AwokenPokey
                end,
                ebbFilepath .. "organization" .. "4" .. ".png"
            },
            {
                function(entity)
                    return entity:GetData().AwokenBashful
                end,
                ebbFilepath .. "organization" .. "3" .. ".png"
            },
            {
                function(entity)
                    return entity:GetData().AwokenSpeedy
                end,
                ebbFilepath .. "organization" .. "2" .. ".png"
            },
        }
    },
    {
        BossID = mod.FF.Basco,
        Sprite = "basco",
        Conditionals = {
            {
                function(entity)
                    return entity:GetData().enraged
                end,
                ebbFilepath .. "basco2" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.Kingpin,
        Sprite = "kingpin"
    },
    {
        BossID = mod.FF.Peeping,
        Sprite = "peeping"
    },
    {
        BossID = mod.FF.Peeping2,
        Sprite = "peeping2"
    },
    {
        BossID = mod.FF.Luncheon,
        Sprite = "luncheon",
    },
    {
        BossID = mod.FF.Pollution,
        Sprite = "pollution",
    },
    {
        BossID = mod.FF.Pollution2,
        Sprite = "pollution2",
    },
    {
        BossID = mod.FF.Meltdown,
        Sprite = "meltdown",
    },
    {
        BossID = mod.FF.Meltdown2,
        Sprite = "meltdown2",
    },
    {
        BossID = mod.FF.Aquagob,
        Sprite = "aquagob"
    },
    {
        BossID = mod.FF.Dusk,
        Sprite = "dusk"
    },
    {
        BossID = mod.FF.Tsar,
        Sprite = "tsar",
        Conditionals = {
            {
                function(entity)
                    return entity:GetData().form == 1
                end,
                ebbFilepath .. "tsar_" .. "green" .. ".png"
            },
            {
                function(entity)
                    return entity:GetData().form == 2
                end,
                ebbFilepath .. "tsar_" .. "yellow" .. ".png"
            },
            {
                function(entity)
                    return entity:GetData().form == 3
                end,
                ebbFilepath .. "tsar_" .. "brown" .. ".png"
            },
        }
    },
    {
        BossID = mod.FF.Cacamancer,
        Sprite = "cacamancer"
    },
    {
        BossID = mod.FF.Gutso,
        Sprite = "gutso",
        Conditionals = {
            {
                function(entity)
                    return entity:GetData().phase2Began
                end,
                ebbFilepath .. "gutso2" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.Slinger,
        Sprite = "slinger",
        Conditionals = {
            {
                function(entity)
                    return entity.SubType == 1
                end,
                ebbFilepath .. "slinger_black" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.MrDead,
        Sprite = "mrdead",
    },
    {
        BossID = mod.FF.WarpZone,
        Sprite = "warpzone"
    },
    {
        BossID = mod.FF.CorruptedLarry,
        Sprite = "corrupted_larry_jr",
        Conditionals = {
            {
                function(entity)
                    return entity.Parent
                end,
                ebbFilepath .. "corrupted_larry_jr_segment" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.CorruptedContusion,
        Sprite = "corrupted_contusion"
    },
    {
        BossID = mod.FF.CorruptedSuture,
        Sprite = "corrupted_suture"
    },
    {
        BossID = mod.FF.CorruptedMonstro,
        Sprite = "corrupted_monstro"
    },
    {
        BossID = mod.FF.Ghostbuster,
        Sprite = "ghostbuster"
    },
    {
        BossID = mod.FF.WhispersController,
        Sprite = "whispers"
    },
    {
        BossID = mod.FF.Psion,
        Sprite = "psion"
    },
    {
        BossID = mod.FF.Gravedigger,
        Sprite = "gravedigger"
    },
    {
        BossID = mod.FF.Hermit,
        Sprite = "hermit"
    },
    {
        BossID = mod.FF.CacophobiaVenus,
        Sprite = "caco1",
        Size64 = true,
        Conditionals = {
            {
                function(entity)
                    return entity:GetData().Pattern 
                end,
                ebbFilepath .. "caco2" .. ".png"
            }
        }
    },
    {
        BossID = mod.FF.Junkstrap,
        Sprite = "junkstrap"
    },
}
mod.scheduleForUpdate(function()
    if HPBars then
        if HPBars.BossIgnoreList then
            HPBars.BossIgnoreList[mod.FF.Kingpin.ID .. "." .. mod.FF.Kingpin.Var] = function(entity)
                return entity.Parent ~= nil
            end
            HPBars.BossIgnoreList[mod.FF.DuskHand.ID .. "." .. mod.FF.DuskHand.Var] = function(entity)
                return true
            end
            HPBars.BossIgnoreList[mod.FF.Whispers.ID .. "." .. mod.FF.Whispers.Var] = function(entity)
                return true
            end
            HPBars.BossIgnoreList[mod.FF.OrgChaserBrain.ID .. "." .. mod.FF.OrgChaserBrain.Var] = function(entity)
                if entity.SubType == mod.FF.OrgChaserBrain.Sub then return true end
            end
            HPBars.BossIgnoreList[mod.FF.OrgBashful.ID .. "." .. mod.FF.OrgBashful.Var] = function(entity)
                return true
            end
            HPBars.BossIgnoreList[mod.FF.OrgSpeedy.ID .. "." .. mod.FF.OrgSpeedy.Var] = function(entity)
                return true
            end
            HPBars.BossIgnoreList[mod.FF.OrgPokey.ID .. "." .. mod.FF.OrgPokey.Var] = function(entity)
                return true
            end
            HPBars.BossIgnoreList[mod.FF.Peeping.ID .. "." .. mod.FF.Peeping.Var] = function(entity)
                return entity:GetData().spawnedPhase2
            end
            HPBars.BossIgnoreList[mod.FF.Meltdown.ID .. "." .. mod.FF.Meltdown.Var] = function(entity)
                return entity:GetData().spawnedPhase2
            end
            HPBars.BossIgnoreList[mod.FF.Pollution.ID .. "." .. mod.FF.Pollution.Var] = function(entity)
                return entity:GetData().spawnedPhase2
            end
            HPBars.BossIgnoreList[mod.FF.WarpZone.ID .. "." .. mod.FF.WarpZone.Var] = function(entity)
                return entity:GetData().hiding and entity:GetData().state ~= "Return"
            end
            HPBars.BossIgnoreList[mod.FF.CorruptedContusion.ID .. "." .. mod.FF.CorruptedContusion.Var] = function(entity)
                return entity:GetData().dead
            end
        end
        if HPBars.BossDefinitions then
            for i = 1, #ebbIcons do
                local position
                if ebbIcons[i].BossID then
                    position = ebbIcons[i].BossID.ID .. "." .. ebbIcons[i].BossID.Var
                end
                if position then
                    local anm2Override
                    if ebbIcons[i].Size64 then
                        anm2Override = "gfx/ui/bosshp_icons/bosshp_icon_64px.anm2"
                    end
                    HPBars.BossDefinitions[position] = {
                        sprite = ebbFilepath .. ebbIcons[i].Sprite .. ".png",
                        offset = ebbIcons[i].Offset or Vector.Zero,
                        iconAnm2 = anm2Override,
                    }
                    if ebbIcons[i].Conditionals then
                        HPBars.BossDefinitions[position].conditionalSprites = {}
                        for k = 1, #ebbIcons[i].Conditionals do
                            HPBars.BossDefinitions[position].conditionalSprites[k] = ebbIcons[i].Conditionals[k]
                        end
                    end
                end
            end
            HPBars.BossDefinitions["19.0"].bossColors[mod.FF.LarryGhost.Sub] = "_ghost"
            HPBars.BossDefinitions["19.1"].bossColors[mod.FF.HollowFuckedUpAndEvil.Sub] = "_possessed"
            HPBars.BossDefinitions["20.0"].bossColors[mod.FF.MucusMonstro.Sub] = "_mucus"
            HPBars.BossDefinitions["45.10"].bossColors[mod.FF.FiendMom.ChampIndex] = "_fiend"
            HPBars.BossDefinitions["62.0"].bossColors[mod.FF.TechnoPin.Sub] = "_techno"
            HPBars.BossDefinitions["67.1"].bossColors[mod.FF.WineHusk.Sub] = "_grape"
            HPBars.BossDefinitions["71.0"].bossColors[mod.FF.BeehiveFistulaBig.Sub] = "_beehive"
            HPBars.BossDefinitions["72.0"].bossColors[mod.FF.BeehiveFistulaMedium.Sub] = "_beehive"
            --HPBars.BossDefinitions["73.0"].bossColors[mod.FF.BeehiveFistulaSmall.Sub] = "_beehive"
            HPBars.BossDefinitions["97.0"].bossColors[mod.FF.YellowMaskOfInfamy.Sub] = "_kidney"
            HPBars.BossDefinitions["98.0"].bossColors[mod.FF.KidneyOfInfamy.Sub] = "_kidney"
            HPBars.BossDefinitions["100.0"].bossColors[mod.FF.BabyWidowChampion.Sub] = "_albino"

            --Ones that need setup
            HPBars.BossDefinitions["69.0"].bossColors = HPBars.BossDefinitions["69.0"].bossColors or {}
            HPBars.BossDefinitions["69.0"].bossColors[mod.FF.AlienLokiChampion.Sub] = "_green"
            HPBars.BossDefinitions["908.0"].bossColors = HPBars.BossDefinitions["908.0"].bossColors or {}
            HPBars.BossDefinitions["908.0"].bossColors[mod.FF.GoldenPlum.Sub] = "_golden"
            --HAH AHA HA HAHAHA WOFSAUGE
            HPBars.BossDefinitions["73.0"].bossColors = HPBars.BossDefinitions["73.0"].bossColors or {"_grey"}
            HPBars.BossDefinitions["73.0"].bossColors[mod.FF.BeehiveFistulaSmall.Sub] = "_beehive"
        end
    end
end, 1, ModCallbacks.MC_INPUT_ACTION, true)