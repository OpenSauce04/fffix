local fiendfoliodirectory = FiendFolio.DSS_DIRECTORY
local dssmod = FiendFolio.DSS_MOD

local credits = {
    --[[
    {str = "team folio", nosel = true, fsize = 1},
    {"fiend", "mod lead", tooltip = {"v", "'u'"}},
	"",
    {"budj", "coder", tooltip = {"buster is", "not that", "hard"}},
    {"blorengerhymes", "spriter, coder", tooltip = {"with orange"}},
    {"bustin blotch", "tester"},
    {"cadence (ciirulean)", "spriter", tooltip = {"arbiter of", " death and", "fuzz"}},
    {"cake", "coder"},
    {"cometz", "spriter", tooltip = {"i got", "lucky"}},
    {"connor", "coder"},
    {"creeps", "spriter", tooltip = {"can i get", "back to you", "on that"}},
    {"deadinfinity", "coder", tooltip = {"please eat", "all of my", "lovely", "ghosts"}},
    {"erfly", "coder", tooltip = {"isaac curse", "is real"}},
    {"ferrium", "coder, spriter", tooltip = {"wait, we", "get quotes?"}},
    {"fuyucchi (maria)", "spriter", tooltip = {"move and", "i'll shoot!", "", "i messed up.", "", "i mean,", "shoot and", "i'll move!"}},
    {"guillotine-21", "coder, spriter"},
    {"gummy", "spriter", tooltip = {"oh right", "i made stuff", "for it"}},
	{"guwahavel", "coder, spriter", tooltip = {"the quirky", "antibirth", "inspired", "isaac mod"}},
    {"happyhead", "spriter, sounds, 3d", tooltip = {"oh um"}},
    {"jerb", "coder"},
    {"jm2k (julia)", "coder, spriter", tooltip = {"estranged", "mother of", "buck"}},
    {"jontherealjon", "spriter, voices", tooltip = {"proponent of", "dogtology"}},
    {"jordy", "tester"},
    {"melon", "devil's harvest"},
    {"minichibis", "founder, coder, spriter", tooltip = {"haha whee"}},
    {"notyoursagittarius", "spriter"},
    {"orisghost", "spriter"},
    {"oroshibu", "coder"},
    {"peas", "spriter, voices", tooltip = {"creator of", "antibirth"}},
    {"pixelo", "spriter",  tooltip = {"thank you", "erflyy for", "squirty sunday"}},
	{"pkpseudo", "spriter", tooltip = {"every pk", "has its", "mausoleum"}},
	{"poyo", "spriter", tooltip = {"uhh", "i don't know"}},
    {"renren", "music", tooltip = {"victim 4"}},
    {"sadly just al", "spriter", tooltip = {"poopy boner"}},
    {"sbody2", "coder, spriter", tooltip = {"", "", "", "", "", "", "", "bottom text"}},
    {"snakeblock", "coder, spriter"},
    {"sunil_b", "spriter", tooltip = {"go to the", "dark room", "", "i beg of you"}},
    {"taigatreant", "coder", tooltip = {"hmm", "i'll have to", "think on that"}},
    {"thx", "co-founder, spriter"},
    {"titaniumgrunt7 (vermin)", "spriter", tooltip = {"aha! you", "read my spell,", "now i have", "all your", "powers!"}},
    {"xalum", "coder", tooltip = {"last seen:", "sept. 2019", "", "call", "07944 xxxxxx", "if located"}},
    "",
	{"almost everyone", "rooms", tooltip = {"especially", "sadly just al,", "sunil_b", "and vermin"}},
	{"mern", "mern, traitor", tooltip = {"mern"}},
	{"peribot", "moral support", tooltip = {"evil"}},
	"",]]
    {str = "special thanks to", fsize = 2, nosel = true},
    "",
    "community credits",
    "",
    {"amy", "wiki, sprites", tooltip = {"delirious buck", "locusts", "enhanced boss ", "bar sprites"}},
    {"attfooy", "enemy designer", tooltip = {"nihilist"}},
    {"breadward macgluten", "guest spriter", tooltip = {"fient", "fend", "", "floor art"}},
    {"cubesjr32", "item designer", tooltip = {"mime degree"}},
    {"cuerzor", "guest spriter", tooltip = {"eid icons"}},
    {"blueresonant ", "item designer", tooltip = {"lemon mishuh?"}},
    {"fork guy", "enemy desginer", tooltip = {"gritty"}},
    {"hairy", "enemy designer", tooltip = {"matte"}},
    {"hooty", "joke enemy designer", tooltip = {"grinner"}},
    {"jubbalub", "trinket designer", tooltip = {"angry faic"}},
    {"moofy", "guest spriter + designer", tooltip = {"grinner"}},
    {"pasta", "guest spriter + designer", tooltip = {"spoop"}},
    {"pemthebun", "trinket designer", tooltip = {"locked shackle"}},
    {"ridleybruh", "guest spriter", tooltip = {"ugh costumes"}},
    {"rolly polly", "guest spriter", tooltip = {"fiend costumes"}},
    {"shanepatsmith", "voice acting", tooltip = {"pill and card", "voiceovers"}},
    {"shauner", "guest spriter + designer", tooltip = {"jammed,", "hostlet", "pet peeve"}},
	{"sipher nil", "trinket designer", tooltip = {"sharp penny", "nitro crystal"}},
	{"that azazel fire", "guest spriter", tooltip = {"enhanced", "boss bar", "icons"}},
	{"watchmeojo", "item designer", tooltip = {"bottle of", "water"}},
	{"wibi", "sound designer", tooltip = {"soul of fiend", "sentence","mixing"}},
    "",
    "everyone who contributed",
	"rooms or fortunes",
    "",
    "stronger than golem",
    "",
    {"alter", ""},
    {"danial", ""},
    {"dastarod", ""},
    {"gabe", ""},
    {"honeyfox", ""},
    "",
    "additional thanks",
    "",
	{"barack obama", "thanks!"},
	{"cathery", "devil's harvest"},
	{"circusqueen", "trans brimstone"},
	{"dogjoneswildson", ""},
	{"drtapeworm", ""},
	{"eden", "placed pill"},
	{"electoon", ""},
	{"emffles", "teraphobia"},
	{"filloax", "morbus"},
	{"kilburn", "sprites", tooltip = {"fiend", "co-op select", "", "devil's harvest", "item sprite"}},
    {"klester", "cacamancer va"},
	{"lung", "heretic mod"},
    {"melon", "devil's harvest"},
    {"mern", "mern, traitor", tooltip = {"mern"}},
    {"noodle", "modding of isaac"},
	{"quartz", ""},
	{"rob franzese", "acting", tooltip = {"real life", "peter griffin"}},
	{"rustybucket", "visual design", tooltip = {"robo-baby 3.0", "appearance"}},
	{"sissi6", "", tooltip = {"beans"}},
	{"springboi", "devil's harvest", tooltip = {"give download", "to the devil", "harvest mod"}},
	{"tealx", ""},
	{"toby fox", "undertale"},
	{"wuggy", "sprites", tooltip = {"emoji glasses", "item sprite", "and costume"}},
	{"xnami", "devil's harvest"},
    "",
	"thank you too to the",
	"people who responded to our",
	"tweets and discord posts",
	"",
    {ShowFlag = true},
    "you all made it fun for us",
    "",
	{"greeb", "production baby", tooltip = {"ayy lmao"}},
	"",
	"",
}

local devs = {
    bustin = {
        name = "bustin",
        subname = "(bustin blotch)",
        subheader = "tester",
        pos = Vector(303, 171),
        row = 7,
        col = 10
    },
    pixelo = {
        name = "pixelo",
        subheader = "spriter",
        tooltip = {"thank you", "erflyy for", "squirty sunday"},
        pos = Vector(172, 165),
        row = 7,
        col = 5
    },
    guillotine = {
        name = "guillotine",
        subname = "(guillotine-21)",
        subheader = "coder, spriter",
        pos = Vector(230, 152),
        row = 7,
        col = 7
    },
    thx = {
        name = "thx",
        subheader = "cofounder, spriter",
        pos = Vector(113, 143),
        row = 6,
        col = 3
    },
    pkpseudo = {
        name = "pkpseudo",
        subheader = "spriter",
        tooltip = {"every pk", "has its", "mausoleum"},
        pos = Vector(96, 158),
        ySortOffset = 10,
        row = 7,
        col = 3
    },
    guwah = {
        name = "guwahavel",
        subheader = "coder, spriter",
        tooltip = {"professional", "nitpicker"},
        pos = Vector(256, 21),
        row = 3,
        col = 9,
    },
    mini = {
        name = "minichibis",
        subheader = "founder, coder, spriter",
        tooltip = {"haha whee"},
        pos = Vector(193, 124),
        row = 6,
        col = 6
    },
    connor = {
        name = "connor",
        subname = "(ghostbroster)",
        subheader = "coder",
        tooltip = {"little man", "little guy"},
        pos = Vector(252, 151),
        row = 7,
        col = 8
    },
    budj = {
        name = "budj",
        subheader = "coder",
        tooltip = {"buster is", "not that", "hard"},
        pos = Vector(332, 67),
        ySortOffset = 100,
        row = 3,
        col = 11
    },
    cadence = {
        name = "cadence",
        subname = "(ciirulean)",
        subheader = "spriter",
        tooltip = {"arbiter of", " death and", "fuzz"},
        pos = Vector(155, 113),
        row = 6,
        col = 5
    },
    julia = {
        name = "jm2k",
        subname = "(julia)",
        subheader = "coder, spriter",
        tooltip = {"estranged", "mother of", "buck"},
        pos = Vector(139, 151),
        row = 7,
        col = 4
    },
    sunil = {
        name = "sunil_b",
        subheader = "spriter, rooms!",
        tooltip = {"go to the", "dark room", "", "i beg of you"},
        pos = Vector(31, 58),
        row = 3,
        col = 1,
    },
    blor = {
        name = "blorenge",
        subname = "(blorengerhymes)",
        subheader = "spriter, coder",
        tooltip = {"with orange"},
        pos = Vector(334, 141),
        row = 6,
        col = 11
    },
    al = {
        name = "al",
        subname = "(sadly just al)",
        subheader = "spriter",
        tooltip = {"poopy boner"},
        pos = Vector(254, 113),
        ySortOffset = 20,
        row = 6,
        col = 8
    },
    sbody = {
        name = "sbody2",
        subheader = "coder, spriter",
        tooltip = {"", "", "", "", "", "bottom text"},
        pos = Vector(311, 134),
        ySortOffset = 30,
        row = 6,
        col = 10
    },
    ren = {
        name = "renren",
        subheader = "music",
        tooltip = {"victim 4"},
        pos = Vector(299, 50),
        row = 3,
        col = 10
    },
    vermin = {
        name = "vermin",
        subname = "(titaniumgrunt7)",
        subheader = "spriter",
        tooltip = {"aha! you", "read my spell,", "now i have", "all your", "powers!"},
        pos = Vector(67, 158),
        row = 7,
        col = 2
    },
    gummy = {
        name = "gummy",
        subheader = "spriter",
        tooltip = {"oh right", "i made stuff", "for it"},
        pos = Vector(283, 143),
        row = 7,
        col = 9
    },
    maria = {
        name = "fuyucchi",
        subname = "(maria)",
        subheader = "spriter, musician",
        tooltip = {"move and", "i'll shoot!", "", "i messed up.", "", "i mean,", "shoot and", "i'll move!"},
        pos = Vector(33, 152),
        row = 7,
        col = 1
    },
    cake = {
        name = "cake",
        subheader = "coder",
		tooltip = {"feel weirb"},
        pos = Vector(25, 126),
        row = 5,
        col = 1
    },
    dead = {
        name = "dead",
        subheader = "coder",
        tooltip = {"i made", "this menu!"},
        pos = Vector(321, 105),
        row = 5,
        col = 10
    },
    oroshibu = {
        name = "oroshibu",
        subheader = "coder",
        pos = Vector(76, 122),
        row = 6,
        col = 2
    },
    xalum = {
        name = "xalum",
        subheader = "coder",
        tooltip = {"last seen:", "sept. 2019", "", "call", "07944 xxxxxx", "if found"},
        pos = Vector(58, 112),
        row = 5,
        col = 2
    },
    cometz = {
        name = "cometz",
        subheader = "spriter",
        tooltip = {"something", "funny"},
        pos = Vector(38, 102),
        row = 4,
        col = 1,
    },
    peas = {
        name = "peas",
        subheader = "spriter, voices",
        tooltip = {"creator of", "antibirth"},
        pos = Vector(292, 124),
        row = 6,
        col = 9
    },
    jon = {
        name = "redrachis",
        subheader = "spriter, voices",
        tooltip = {"proponent of", "dogtology"},
        pos = Vector(279, 100),
        row = 5,
        col = 9
    },
    happyhead = {
        name = "happyhead",
        subheader = "spriter, sounds, 3d",
        tooltip = {"oh um"},
        pos = Vector(297, 88),
        row = 4,
        col = 10
    },
    snake = {
        name = "snakeblock",
        subheader = "coder, spriter",
        pos = Vector(65, 86),
        row = 4,
        col = 2
    },
    poyo = {
        name = "poyo",
        subheader = "spriter",
        tooltip = {"uhh", "i don't know"},
        pos = Vector(127, 115),
        row = 5,
        col = 4
    },
    creeps = {
        name = "creeps",
        subheader = "spriter",
        tooltip = {"she's thinking", "about", "her wife"},
        pos = Vector(174, 91),
        row = 5,
        col = 6
    },
    erfly = {
        name = "erfly",
        subheader = "coder",
        tooltip = {"isaac curse", "is real"},
        pos = Vector(146, 89),
        row = 4,
        col = 5
    },
    funkengine = {
        name = "funkengine",
        subheader = "tester",
        pos = Vector(93, 110),
        row = 5,
        col = 3
    },
    taiga = {
        name = "taigatreant",
        subheader = "coder",
        tooltip = {"lost in the", "custom health", "mines"},
        pos = Vector(231, 132),
        row = 6,
        col = 7,
    },
    jordy = {
        name = "jordy",
        subheader = "tester",
        pos = Vector(209, 106),
        row = 5,
        col = 7
    },
    ori = {
        name = "orisghost",
        subheader = "spriter",
        pos = Vector(240, 88),
        row = 4,
        col = 8
    },
    jerb = {
        name = "jerb",
        subheader = "coder",
        pos = Vector(268, 74),
        row = 4,
        col = 9
    },
    ferrium = {
        name = "ferrium",
        subheader = "coder, spriter",
        tooltip = {"jd was here"},
        pos = Vector(115, 85),
        row = 4,
        col = 4
    },
    sin = {
        name = "sin",
        subheader = "rooms!",
        pos = Vector(91, 70),
        row = 4,
        col = 3
    },
    jd = {
        name = "jd",
        subheader = "coder",
        tooltip = {"jd was here"},
        pos = Vector(85, 30),
        row = 3,
        col = 3
    },
    --[[
    sag = {
        pos = Vector(361, 93)
    },]]
    sag = {
        name = "sag",
        subname = "(notyoursagittarius)",
        subheader = "spriter",
        pos = Vector(340, 97),
        row = 4,
        col = 11
    },
    fiend = {
        name = "fiend",
        subheader = "mod lead",
        tooltip = {"v", "'u'"},
        pos = Vector(332, 15),
        row = 1,
        col = 11,
    },
    peribot = {
        name = "peribot",
        subheader = "moral support",
        subheader2 = "2018-2022",
        tooltip = {"press menu", "confirm to", "view the", "special thanks!"},
        dest = "credits",
        pos = Vector(342, 31),
        row = 2,
        col = 11
    }
}

local devsYSorted = {}

local devs2DGrid = {}

local maxRow, maxCol = 0, 0
for k, v in pairs(devs) do
    local sprite = Sprite()
    sprite:Load("gfx/ui/ff_developers/dev.anm2", false)
    if FiendFolio.savedata.JDMode then
        sprite:ReplaceSpritesheet(0, "gfx/ui/ff_developers/jd.png")
    else
        sprite:ReplaceSpritesheet(0, "gfx/ui/ff_developers/" .. k .. ".png")
    end
    sprite:LoadGraphics()
    sprite:Play("Idle")
    v.sprite = sprite

    v.ySort = v.pos.Y + (v.ySortOffset or 0)

    if not devs2DGrid[v.row] then
        devs2DGrid[v.row] = {}
    end

    devs2DGrid[v.row][v.col] = v

    maxRow, maxCol = math.max(maxRow, v.row), math.max(maxCol, v.col)

    local insertAt = #devsYSorted + 1
    for i, dev in ipairs(devsYSorted) do
        if v.ySort < dev.ySort then
            insertAt = i
            break
        end
    end

    table.insert(devsYSorted, insertAt, v)
end

local ffCreditsPaper = Sprite()
ffCreditsPaper:Load("gfx/ui/ff_developers/paper.anm2", true)

local ffCreditsPaperMask = Sprite()
ffCreditsPaperMask:Load("gfx/ui/ff_developers/paper.anm2", true)
ffCreditsPaperMask:ReplaceSpritesheet(1, "gfx/ui/ff_developers/paper.png")
ffCreditsPaperMask:LoadGraphics()

fiendfoliodirectory.awesomecredits = {
    format = {
        Panels = {
            {
                Panel = {
                    Sprites = {
                        Face = ffCreditsPaper,
                        Mask = ffCreditsPaperMask
                    },
                    StartAppear = function(panel, tbl, skipOpenAnimation)
                        dssmod.playSound(dssmod.menusounds.Open)
                        dssmod.defaultPanelStartAppear(panel, tbl, skipOpenAnimation)
                    end,
                    StartDisappear = function()
                        dssmod.playSound(dssmod.menusounds.Close)
                    end,
                    Draw = function(panel, panelPos, item)
                        for _, dev in ipairs(devsYSorted) do
                            local rpos = dev.pos + panelPos + Vector(-200, -112)
                            dev.sprite.Color = Color(0, 0, 0, 1, 221 / 255, 179 / 255, 226 / 255)
                            dev.sprite:Render(rpos, Vector.Zero, Vector.Zero)

                            if dev.buttonindex ~= item.bsel then
                                dev.sprite.Color = Color(1, 1, 1, 0.8, 0, 0, 0)
                            else
                                dev.sprite.Color = Color.Default
                            end

                            dev.sprite:Render(rpos, Vector.Zero, Vector.Zero)
                        end
                    end,
                    HandleInputs = function(panel, input, item, itemswitched, tbl)
                        dssmod.handleInputs(item, itemswitched, tbl)
                    end,
                    DefaultRendering = true
                },
                Color = Color.Default,
                Offset = Vector(-50, 0)
            },
            {
                Panel = dssmod.panels.tooltip,
                Offset = Vector(180, -2),
                Color = 1
            }
        }
    },
    generate = function()
    end,
    gridx = maxCol,
    buttons = {}
}

for row = 1, maxRow do
    for column = 1, maxCol do
        local button = {}
        local buttonIndex = #fiendfoliodirectory.awesomecredits.buttons + 1
        if devs2DGrid[row][column] then
            local dev = devs2DGrid[row][column]
            dev.buttonindex = buttonIndex

            local baseFontSize = 2

            button.dest = dev.dest

            button.tooltip = {
                buttons = {
                    {str = dev.name, fsize = baseFontSize},
                    {str = dev.subheader, fsize = 1},
                }
            }

            if dev.subname then
                table.insert(button.tooltip.buttons, 1, {str = dev.subname, fsize = 1})
            end

            if dev.subheader2 then
                button.tooltip.buttons[#button.tooltip.buttons + 1] = {str = dev.subheader2, fsize = 1}
            end

            button.tooltip.buttons[#button.tooltip.buttons + 1] = {str = ""}

            if dev.tooltip then
                local extraFontSize = 2
                if #dev.tooltip > 6 then
                    extraFontSize = 1
                end

                for _, str in ipairs(dev.tooltip) do
                    button.tooltip.buttons[#button.tooltip.buttons + 1] = {str = str, fsize = extraFontSize}
                end
            end
        else
            button.nosel = true
        end

        fiendfoliodirectory.awesomecredits.buttons[buttonIndex] = button
    end
end

local coolSprite =  Sprite()
coolSprite:Load("gfx/ui/transrights_BITCH.anm2", true)
coolSprite:SetFrame("Flag", 0)

for _, credit in ipairs(credits) do
    if type(credit) == "string" then
        fiendfoliodirectory.credits.buttons[#fiendfoliodirectory.credits.buttons + 1] = {str = credit, nosel = true}
    elseif credit.fsize then
        fiendfoliodirectory.credits.buttons[#fiendfoliodirectory.credits.buttons + 1] = credit
    elseif credit.ShowFlag then
        local button = {spr = {sprite = coolSprite, width = -150, height = 1, center = true}, nosel = true}
        fiendfoliodirectory.credits.buttons[#fiendfoliodirectory.credits.buttons + 1] = button
    else
        for i, part in ipairs(credit) do
            if i ~= 1 then
                if i == 2 then
                    local button = {strpair = {{str = credit[1]}, {str = part}}}
                    if credit.tooltip then
                        if type(credit.tooltip) == "string" then
                            credit.tooltip = {credit.tooltip}
                        end
                        button.tooltip = {strset = credit.tooltip}
                    end
                    fiendfoliodirectory.credits.buttons[#fiendfoliodirectory.credits.buttons + 1] = button
                else
                    fiendfoliodirectory.credits.buttons[#fiendfoliodirectory.credits.buttons + 1] = {strpair = {{str = ''}, {str = part}}, nosel = true}
                end
            end
        end
    end
end