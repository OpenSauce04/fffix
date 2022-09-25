local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local kZeroVector = Vector.Zero

local kBrownHornDuration = 60
local kBrownHornSpeed = 40

local kFriendlyDipsToSpawn = 2
local kLaserDamage = 2.5
local kMinWallSlamDamage = 5
local kMaxWallSlamDamagePercentage = 0.1

-- Brown brimstone size modifiers
local kSmall = 0.5
local kBig = 2.0

local DipSubType = {
	NORMAL = 0,
	RED = 1,
	CORNY = 2,
	GOLDEN = 3,
	RAINBOW = 4,
	BLACK = 5,
	HOLY = 6,
	STONE = 12,
	FLAMING = 13,
	POISON = 14,
	BROWNIE = 20,
	WATER = 666,
	CURSED = 667,
	BEE = 668,
	PLATINUM = 669,
	SPIDER = 670,
	EVIL = 671,
	--SPOOP = 672,
}

local DipSubTypeInverted = {}
for k, v in pairs(DipSubType) do
	DipSubTypeInverted[v] = k
end

local GridPoopVariant = {
	NORMAL = 0,
	RED = 1,
	CORNY = 2,
	GOLDEN = 3,
	RAINBOW = 4,
	BLACK = 5,
	HOLY = 6,
}

local BlueBabyPoopVariant = {
	STONE = 11,
	CORNY = 12,
	FLAMING = 13,
	POISON = 14,
	BLACK = 15,
	HOLY = 16,
}

local function colorizeColor(r, g, b, amount, alpha)
	local color = Color(1,1,1, alpha or 1, 0,0,0)
	color:SetColorize(r,g,b,amount or 1)
	return color
end

local kDefaultBrownCreepColor = Color(0.5, 0.6, 0.6, 1, 0.3, 0.4, 0.3)

local PoopType = {
	NORMAL = {
		DipType = DipSubType.NORMAL,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		GridEntityType = GridEntityType.GRID_POOP,
		GridEntityVariant = GridPoopVariant.NORMAL,
	},
	RED = {
		DipType = DipSubType.RED,
		LaserColor = colorizeColor(1.75, 0.0, 0.0, 1.0),
		CreepColor = nil,
		CreepType = EffectVariant.PLAYER_CREEP_RED,
		GridEntityType = GridEntityType.GRID_POOP,
		GridEntityVariant = GridPoopVariant.RED,
	},
	CORNY = {
		DipType = DipSubType.BROWNIE,
		LaserColor = colorizeColor(1, 1, 1.75, -0.5),
		CreepColor = nil,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		BlueBabyPoopVariant = BlueBabyPoopVariant.CORNY,
	},
	WATER = {
		DipType = DipSubType.WATER,
		LaserColor = colorizeColor(1.5, 1.5, 2.0, 2.0),
		CreepColor = nil,
		CreepType = EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL,
		CustomGridEntity = mod.ShampooGrid,
	},
	CURSED = {
		DipType = DipSubType.CURSED,
		LaserColor = colorizeColor(0.8, 0, 1.0, 0.33),
		CreepColor = Color(0.4, 0.5, 0.5, 1, 0.3, 0.2, 0.3),
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		CustomGridEntity = mod.CursedPoopGrid,
	},
	BEE = {
		DipType = DipSubType.BEE,
		LaserColor = colorizeColor(2, 1.25, 0.25),
		CreepColor = colorizeColor(5.5, 3.5, 1),
		CreepType = EffectVariant.CREEP_BROWN,
		CustomGridEntity = mod.BeehiveGrid,
	},
	FLAMING = {
		DipType = DipSubType.FLAMING,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		BlueBabyPoopVariant = BlueBabyPoopVariant.FLAMING,
	},
	POISON = {
		DipType = DipSubType.POISON,
		LaserColor = colorizeColor(0, 0.5, 0, 0.5),
		CreepColor = colorizeColor(0, 2, 0, 1),
		CreepType = EffectVariant.PLAYER_CREEP_RED,
		BlueBabyPoopVariant = BlueBabyPoopVariant.POISON,
	},
	BLACK = {
		DipType = DipSubType.BLACK,
		LaserColor = colorizeColor(0,0,0,0.9),
		CreepColor = nil,
		CreepType = EffectVariant.PLAYER_CREEP_BLACK,
		BlueBabyPoopVariant = BlueBabyPoopVariant.BLACK,
	},
	STONE = {
		DipType = DipSubType.STONE,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		--BlueBabyPoopVariant = BlueBabyPoopVariant.STONE,
		CustomGridEntity = mod.PetrifiedPoopGrid,
	},
	HOLY = {
		DipType = DipSubType.HOLY,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		GridEntityType = GridEntityType.GRID_POOP,
		GridEntityVariant = GridPoopVariant.HOLY,
	},
	GOLDEN = {
		DipType = DipSubType.GOLDEN,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		GridEntityType = GridEntityType.GRID_POOP,
		GridEntityVariant = GridPoopVariant.GOLDEN,
	},
	RAINBOW = {
		DipType = DipSubType.RAINBOW,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		GridEntityType = GridEntityType.GRID_POOP,
		GridEntityVariant = GridPoopVariant.RAINBOW,
	},
	FLY = {
		SpawnFlies = true,
		LaserColor = nil,
		CreepColor = kDefaultBrownCreepColor,
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		BlueBabyPoopVariant = BlueBabyPoopVariant.CORNY,
	},
	SPIDER = {
		DipType = DipSubType.SPIDER,
		LaserColor = colorizeColor(2,2,2,1),
		CreepColor = nil,
		CreepType = EffectVariant.PLAYER_CREEP_WHITE,
		CustomGridEntity = mod.SpiderNestGrid,
	},
	DEMON = {
		DipType = DipSubType.EVIL,
		LaserColor = colorizeColor(1.0, 0.2, 0.2, 0.8),
		CreepColor = Color(0.6, 0.8, 0.8, 1.0, 0, 0.03, 0.0),
		CreepType = EffectVariant.PLAYER_CREEP_RED,
		CustomGridEntity = mod.EvilPoopGrid,
	},
	--[[GHOST = {
		DipType = DipSubType.SPOOP,
		LaserColor = colorizeColor(1.5, 1.5, 1.5, 1),
		CreepColor = colorizeColor(3, 3, 3, 1, 0.75),
		CreepType = EffectVariant.CREEP_SLIPPERY_BROWN,
		GridEntityType = GridEntityType.GRID_POOP,
		GridEntityVariant = GridPoopVariant.NORMAL,
	},]]
}

-- Table for actually identifying what type of poop to use for a given entity.
local EntityPoopData = {}

-- Assigns PoopType data to an entity.
local function assignPoopData(eType, eVariant, eSubType, poopData, exData)
	eVariant = eVariant or -1
	eSubType = eSubType or -1
	
	local tab = EntityPoopData
	
	for _, i in pairs({eType, eVariant, eSubType}) do
		if not tab[i] then
			tab[i] = {}
		end
		tab = tab[i]
	end
	
	tab.Data = poopData
	tab.ExtraData = exData or {}
end

local function assignPoopDataFromTable(tab, data, exData)
	assignPoopData(tab.ID, tab.Var, tab.Sub, data, exData)
end

-- Table used to populate the above EntityPoopData table, because this format was easier to
-- fill in manually. Enemies not listed here use NORMAL.
local EnemiesByPoopType = {
	NORMAL = {
		{13, nil, nil, {Scale = kSmall}},  -- Fly
		{14, 0, nil, {Scale = kSmall}},  -- Pooter
		{14, 1, nil, {Scale = kSmall}},  -- Super Pooter
		{18, nil, nil, {Scale = kSmall}},  -- Attack Fly
		{21, 0, 0, {Scale = kSmall}},  -- Maggot
		{23, 0, 0, {Scale = kSmall}},  -- Charger
		{31, 0, 0, {Scale = kSmall}},  -- Spitty
		{51, 20, 0, {Scale = kSmall}},  -- Envy
		{51, 30, 0, {Scale = kSmall}},  -- Envy
		{51, 21, 0, {Scale = kSmall}},  -- Envy
		{51, 31, 0, {Scale = kSmall}},  -- Envy
		{55, 0, 0, {Scale = kSmall}},  -- Leech
		{55, 1, 0, {Scale = kSmall}},  -- Kamikaze Leech
		{61, 5, 0, {Scale = kSmall}},  -- Bulb
		{73, 0, 0, {Scale = kSmall}},  -- Fistula
		{73, 1, 0, {Scale = kSmall}},  -- Teratoma
		{76, 0, 0, {Scale = kSmall}},  -- Blastoclyst Small
		{77, 0, 0, {Scale = kSmall}},  -- Embryo
		{80, 0, 0, {Scale = kSmall}},  -- Moter
		{85, 0, 0, {Scale = kSmall}},  -- Spider
		{94, 0, 0, {Scale = kSmall}},  -- Big Spider
		{96, 0, 0, {Scale = kSmall}},  -- Eternal Fly
		{217, 0, 0, {Scale = kSmall, Morph=true}},  -- Dip
		{222, 0, 0, {Scale = kSmall}},  -- Ring Fly
		{256, 0, 0, {Scale = kSmall}},  -- Dart Fly
		{260, 10, 0, {Scale = kSmall}},  -- Lil Haunt
		{264, 0, 0, {Scale = kBig}},  -- Mega Fatty
		{265, 0, 0, {Scale = kBig}},  -- Cage
		{281, 0, 0, {Scale = kSmall}},  -- Swarm
		{884, 0, 0, {Scale = kSmall}},  -- SwarmSpider
		{296, 0, 0, {Scale = kSmall}},  -- HushFly
		{23, 3, 0, {Scale = kSmall}},  -- CarrionPrincess
		{808, 0, 0, {Scale = kSmall}},  -- Willo
		{810, 0, 0, {Scale = kSmall}},  -- Small Leech
		{814, 0, 0, {Scale = kSmall}},  -- Strider
		{818, nil, nil, {Scale = kSmall}},  -- Rock Spider
		{853, 0, 0, {Scale = kSmall}},  -- Small Maggot
		{868, 0, 0, {Scale = kSmall}},  -- Army Fly
		{951, 11, 0, {Scale = kSmall}},  -- Ultra Famine Fly
		{951, 21, 0, {Scale = kSmall}},  -- Ultra Pestilence Fly
		{951, 23, 0, {Scale = kSmall}},  -- Ultra Pestilence Fly Ball
		{mod.FF.RolyPoly, {Scale = kSmall}},
		{mod.FF.Splodum, {Scale = kSmall}},
		{mod.FF.Sternum, {Scale = kSmall}},
		{mod.FF.Spooter, {Scale = kSmall}},
		{mod.FF.SuperSpooter, {Scale = kSmall}},
		{mod.FF.BabySpider, {Scale = kSmall}},
		{mod.FF.MegaSpooter, {Scale = kSmall}},
		{mod.FF.LitterBug, {Scale = kSmall}},
		{mod.FF.LitterBugCharmed, {Scale = kSmall}},
		{mod.FF.Skuzz, {Scale = kSmall}},
		{mod.FF.BeadFly, {Scale = kSmall}},
		{mod.FF.Magleech, {Scale = kSmall}},
		{mod.FF.ShotFly, {Scale = kSmall}},
		{mod.FF.Shoter, {Scale = kSmall}},
		{mod.FF.Hostlet, {Scale = kSmall}},
		{mod.FF.RedHostlet, {Scale = kSmall}},
		{mod.FF.Smidgen, {Scale = kSmall}},
		{mod.FF.RedSmidgen, {Scale = kSmall}},
		{mod.FF.Benign, {Scale = kSmall}},
		{mod.FF.Minimoon, {Scale = kSmall}},
		{mod.FF.Wimpy, {Scale = kSmall}},
		{FiendFolio.FFID.SquareFly, nil, nil, {Scale = kSmall}},
		{mod.FF.Snagger, {Scale = kSmall}},
		{mod.FF.ReheatedBeserker, {Scale = kSmall}},
		{mod.FF.Morsel.ID, mod.FF.Morsel.Var, nil, {Scale = kSmall}},
		{mod.FF.Cancerlet, {Scale = kSmall}},
		{mod.FF.Falafel, {Scale = kSmall}},
		{mod.FF.Slick, {Scale = kSmall}},
		{mod.FF.Stump, {Scale = kSmall}},
		{mod.FF.Fossil, {Scale = kSmall}},
		{mod.FF.TadoKid, {Scale = kSmall}},
		{mod.FF.Shitling, {Scale = kSmall, Morph=true}},
		{mod.FF.Grape, {Scale = kSmall}},
		{mod.FF.LightningFly, {Scale = kSmall}},
		{mod.FF.CongaSkuzz, {Scale = kSmall}},
		{mod.FF.RingSkuzz, {Scale = kSmall}},
	},
	RED = {
		{15, 0, 0},  -- Clotty
		{24, 0, 0},  -- Globin
		{24, 1, 0},  -- Gazing Globin
		{25, 1, 0},  -- Red Boom Fly
		{28, 1, 0},  -- CHAD
		{30, 0, 0},  -- Boil
		{61, 0, 0, {Scale = kSmall}},  -- Sucker
		{61, 6, 0, {Scale = kSmall}},  -- Bloodfly
		{78, 0, 0},  -- MomsHeart
		{78, 1, 0},  -- ItLives
		{88, 0, 0},  -- Walking Boil
		{92, 0, 0},  -- Heart
		{98, 0, 0},  -- Heart of Infamy
		{282, 0, 0},  -- Mega Clotty
		{92, 1, 0},  -- HalfHeart
		{92, 1, 1},  -- HalfHeart
		{212, 4, 0},  -- RedSkull
		{mod.FF.ReheatedCharger, {Scale = kSmall}},
		{mod.FF.ReheatedFly, {Scale = kSmall}},
		{mod.FF.ReheatedSpider, {Scale = kSmall}},
		{mod.FF.Heartbeat},
		{mod.FF.Berry},
		{mod.FF.Basco},
		{mod.FF.SpicyDip, {Scale = kSmall, Convert=true}},
		{mod.FF.Organelle, {Scale = kSmall}},
		{mod.FF.Globlet, {Scale = kSmall}},
		{mod.FF.Drumstick, {Scale = kSmall}},
		{mod.FF.Chunky},
		{mod.FF.Meatwad},
		{mod.FF.Chops},
		{mod.FF.Chummer},
	},
	CORNY = {
		{217, 1, 0, {Scale = kSmall, Morph=true}},  -- Corn
		{217, 2, 0, {Scale = kSmall, Morph=true}},  -- BrownieCorn
		{261, 1, 0},  -- Dangle
		{295, 0, 0},  -- Corn Mine
		{402, 0, 0, {Scale = kBig}},  -- Brownie
		{876, 0, 0},  -- Dump
		{876, 1, 0},  -- Dump
		{917, 0, 0},  -- Colostomia
		{918, 0, 0},  -- Turdlet
		{mod.FF.Stomy},
		{mod.FF.SoftServe},
		{mod.FF.Sundae},
		{mod.FF.Scoop},
		{mod.FF.Load},
		{mod.FF.CornLoad},
		{mod.FF.Poople},
		{mod.FF.Cacamancer},
	},
	GOLDEN = {
		{50, 0, 0},  -- Greed
		{50, 1, 0},  -- S Greed
		{293, nil, nil, {Scale = kSmall}},  -- Coin
		{299, 0, 0},  -- GreedGaper
		{406, 0, 0},  -- UltraGreed
		{406, 1, 0},  -- UltraGreed
		{mod.FF.GBF},
		{mod.FF.GoldenPlum},
	},
	RAINBOW = {
		{mod.FF.Peat},
	},
	BLACK = {
		{15, 1, 0},  -- Clotty
		{23, 2, 0, {Scale = kSmall}},  -- Dank Charger
		{24, 2, 0},  -- Globin
		{43, 1, 0},  -- Gish
		{61, 2, 0, {Scale = kSmall}},  -- Ink
		{79, 1, 0},  -- STEVEN
		{79, 11, 0},  -- STEVENB
		{220, 1, 0},  -- Dank Squirt
		{278, 0, 0},  -- Black Globin
		{279, 0, 0},  -- Black Globin
		{280, 0, 0},  -- Black Globin
		{307, 0, 0},  -- Tar Boy
		{307, 0, 1},  -- Tar Boy
		{34, 1, 0},  -- Sticky Leaper
		{40, 2, 0},  -- Slog
		{870, 0, 0, {Scale = kSmall, Convert=true}},  -- Drip
		{871, 0, 0},  -- Splurt
		{878, 0, 0},  -- ButtSlicker
		{888, 0, 0},  -- Shady
		{914, 0, 0},  -- Clog
		{mod.FF.Gobhopper},
		{mod.FF.DankFatty},
		{mod.FF.Squidge},
		{mod.FF.SludgeHost},
		{mod.FF.Guflush},
		{mod.FF.Clogmo},
		{mod.FF.Bunkter},
		{mod.FF.Gunk},
		{mod.FF.Punk},
		{mod.FF.Gorger},
		{mod.FF.Gis},
		{mod.FF.Grater},
		{mod.FF.Gishle},
		{mod.FF.MrGob},
		{mod.FF.Gob},
		{mod.FF.Blot, {Scale = kSmall, Convert=true}},
		{mod.FF.Melty},
		{mod.FF.Pitcher},
		{mod.FF.Tsar},
		{mod.FF.Dollop},
		{mod.FF.Crudemate},
		{mod.FF.Slimer},
	},
	HOLY = {
		{55, 2, 0, {Scale = kSmall}},  -- Holy Leech
		{271, 0, 0},  -- Angel
		{271, 1, 0},  -- Angel
		{272, 0, 0},  -- Angel
		{272, 1, 0},  -- Angel
		{22, 2, 0},  -- Holy Mulligan
		{60, 2, 0},  -- Holy Eye
		{227, 1, 0},  -- Holy Bony
		{805, 0, 0},  -- Bishop
		{950, nil, nil},  -- Dogma
		{mod.FF.Chorister},
		{mod.FF.Cherub},
		{mod.FF.Warden},
		{mod.FF.HolyWobbles},
		{mod.FF.Zealot},
		{mod.FF.Dogrock},
		{mod.FF.ArmouredLooker},
		{mod.FF.Looker},
		{mod.FF.Seeker},
		{mod.FF.Watcher},
	},
	STONE = {
		{42, nil, nil},  -- Grimace
		{804, nil, nil},  -- Grimace
		{809, nil, nil},  -- Grimace
		{202, nil, nil},  -- Stone Shooter
		{203, nil, nil},  -- Brimstone Head
		{302, 0, 0},  -- Stony
		{302, 0, 10},  -- Cross Stony
		{823, 0, 0},  -- Quakey
		{826, 0, 0},  -- Hardy
		{mod.FF.Drillbit},
		{mod.FF.Crucible},
		{mod.FF.Stalagnaught},
		{mod.FF.AntiGolem},
		{mod.FF.Quaker},
		{mod.FF.Shaker},
		{mod.FF.StoneySlammer},
		{mod.FF.StoneySlammerCrazy},
		{mod.FF.Tombit},
		{mod.FF.FossilBoomFly},
		{mod.FF.SuperGrimace},
		{mod.FF.Gravin, {Scale = kSmall}},
		{mod.FF.Thumper},
	},
	FLAMING = {
		{10, 2, 0},  -- Flaming Gaper
		{208, 2, 0},  -- Flaming Fatty
		{54, 0, 0},  -- 
		{226, 2, 0},  -- Crispy
		{15, 3, 0},  -- Grlled Clotty
		{25, 3, 0},  -- DragonFly
		{25, 3, 1},  -- DragonFly
		--{33, nil, nil},  -- Coal, lol
		{41, 4, 0},  -- Black Knight
		{820, 1, 0},  -- Coal Boy
		{824, 1, 0},  -- Grilled Gyro
		{825, 0, 0},  -- Fire Worm
		{833, 0, 0, {Scale = kSmall}},  -- Candler
		{mod.FF.Spitroast, {Scale = kSmall}},
		{mod.FF.Spitfire},
		{mod.FF.BigSmoke},
		{mod.FF.Powderkeg},
		{mod.FF.Fried},
		{mod.FF.Wick},
		{mod.FF.RingLeader},
		{mod.FF.Ashtray},
		{mod.FF.Roasty},
		{mod.FF.Brisket},
		{mod.FF.Smore},
		{mod.FF.Spark, {Scale = kSmall}},
		{mod.FF.Flare},
		{mod.FF.Crisply},
		{mod.FF.Woodburner},
		{mod.FF.WoodburnerEasy},
		{mod.FF.Charlie},
		{mod.FF.Sooty},
		{mod.FF.Smokin},
		{mod.FF.SmokinOld},
		{mod.FF.Flamin},
		{mod.FF.PhoenixIgnited},
		{mod.FF.Blastcore},
		{mod.FF.Buster},
		{mod.FF.GriddleHorn},
		{mod.FF.Pollution},
		{mod.FF.Pollution2},
		{mod.FF.Meltdown},
		{mod.FF.Meltdown2},
		{mod.FF.Firewhirl},
		{mod.FF.Aleya},
		{mod.FF.Tricko},
		{mod.FF.Cairn},
		{mod.FF.Coupile},
		{mod.FF.Coalby},
		{mod.FF.Fumegeist},
		{mod.FF.Smogger},
		{mod.FF.GrilledChunky},
		{mod.FF.GrilledMeatwad},
		{mod.FF.Glob},
		{mod.FF.Sizzle},

	},
	POISON = {
		{30, 1, 0},  -- Gut
		{42, 1, nil},  -- Vomit Grimace
		{46, 0, 0},  -- Sloth
		{46, 1, 0},  -- S Sloth
		{46, 2, 0},  -- Ed
		{61, 1, 0, {Scale = kSmall}},  -- Spit
		{64, 0, 0},  -- Pestilence
		{951, 20, 0},  -- Ultra Pestilence
		{87, 0, 0},  -- Gurgle
		{88, 1, 0},  -- Walking Gut
		{301, 0, 0},  -- Poison Mind
		{25, 5, 0},  -- Sick Boom Fly
		{856, 0, 0},  -- Gasbag
		{874, 0, 0},  -- GasDwarf
		{875, 0, 0},  -- PootMine
		{300, 0, 0},  -- Mushroom
		{mod.FF.LitterBugToxic, {Scale = kSmall}},
		{mod.FF.ReheatedIckyFly, {Scale = kSmall}},
		{mod.FF.ReheatedIckySpider, {Scale = kSmall}},
		{mod.FF.ReheatedIckyCreep},
		{mod.FF.MamaPooter},
		{mod.FF.InfectedMushroom},
		{mod.FF.RotspinCore},
		{mod.FF.RotspinMoon},
		{mod.FF.Spoilie},
		{mod.FF.Wheezer},
		{mod.FF.SmoreSeptic},
		{mod.FF.Mern},
		{mod.FF.Fatshroom},
		{mod.FF.ToxicKnight},
		{mod.FF.ToxicKnightBrain},
		{mod.FF.Spitum},
		{mod.FF.SourpatchSeptic},
		{mod.FF.SourpatchBodySeptic},
		{mod.FF.ShroomLeaper, {Scale = kSmall}},
		{mod.FF.Shiitake, {Scale = kSmall}},
		{mod.FF.RamblinEvilMushroom, {Scale = kSmall}},
		{mod.FF.InfectedMushroom},
		{mod.FF.Droolie},
		{mod.FF.Residuum},
		{mod.FF.Connipshit},
		{mod.FF.Whale},
		{mod.FF.WhaleGuts},
		{mod.FF.MobileMushroom},
	},
	WATER = {
		{22, 1, 0, {Scale = kSmall}},  -- Drowned Hive
		{23, 1, 0, {Scale = kSmall}},  -- Drowned Charger
		{25, 2, 0, {Scale = kSmall}},  -- Drowned Boomfly
		{mod.FF.Cistern},
		{mod.FF.Wetstone},
		{mod.FF.Tubby},
		{mod.FF.BubbleBat},
		{mod.FF.Puffer},
		{mod.FF.Dolphin},
		{mod.FF.Dewdrop},
		{mod.FF.Warty},
		{mod.FF.Drop, {Scale = kSmall, Morph=true}},
		{mod.FF.Dribble},
		{mod.FF.BubbleBaby},
		{mod.FF.Madclaw},
		{mod.FF.MadclawReg},
		{mod.FF.MadclawHide},
		{mod.FF.Zapbladder},
		{mod.FF.Geyser},
		{mod.FF.Bubby},
		{mod.FF.Wire, {Scale = kSmall}},
		{mod.FF.Monsoon},
		{mod.FF.Aquagob},
		{mod.FF.Aquabab, {Scale = kSmall}},
		{mod.FF.Archer},
		{mod.FF.Mightfly},
		{mod.FF.ErodedSmidgen, {Scale = kSmall}},
		{mod.FF.ErodedSmidgenNaked, {Scale = kSmall}},
		{mod.FF.Mayfly, {Scale = kSmall}},
	},
	CURSED = {
		{26, 2, 0},  -- Psychic Maw
		{246, 0, 0},  -- Ragling
		{246, 1, 0},  -- Ragling
		{248, 0, 0},  -- Psychic Horf
		{273, 0, 0},  -- Lamb
		{273, 10, 0},  -- Lamb
		{405, 0, 0},  -- Rag Man
		{405, 1, 0},  -- Rag Man
		{409, 1, 0},  -- Rag Mega
		{24, 3, 0},  -- Cursed Globin
		{828, 0, 0},  -- Necro
		{832, 0, 0},  -- Exorcist
		{832, 1, 0},  -- Fanatic
		{841, 0, 0},  -- Revenant
		{841, 1, 0},  -- Revenant
		{885, 0, 0},  -- Cultist
		{240, 2, 0},  -- Rag Creep
		{mod.FF.PsychoFly},
		{mod.FF.Ragurge},
		{mod.FF.Skulltist},
		{mod.FF.Madhat},
		{mod.FF.Grimoire},
		{mod.FF.ArcaneCreep},
		{mod.FF.Psystalk},
		{mod.FF.Psyclopia},
		{mod.FF.Alderman},
		{mod.FF.ScowlCreep},
		{mod.FF.Crosseyes},
		{mod.FF.Foreseer},
		{mod.FF.Psion},
		{mod.FF.PsionLeech},
		{mod.FF.Psiling, {Scale = kSmall}},
		{mod.FF.Primemind},
		{mod.FF.DeadFly},
		{mod.FF.InnerEye},
		{mod.FF.Enlightened},
		{mod.FF.Unenlightened},
		{mod.FF.Sixth},
		{mod.FF.Clergy},
		{mod.FF.Pyroclasm},
		{mod.FF.Dusk},
		{mod.FF.PsiKnight},
		{mod.FF.PsiKnightBrain},
		{mod.FF.PsychoKnight},
		{mod.FF.Acolyte},
		{mod.FF.Effigy},
		{mod.FF.Outlier},
		{mod.FF.Observer},
		{mod.FF.Hermit},
		{mod.FF.CorruptedContusion},
		{mod.FF.CorruptedSuture},
		{mod.FF.CorruptedMonstro},
		{mod.FF.CorruptedLarry},

	},
	BEE = {
		{mod.FF.Honeydrip},
		{mod.FF.Honeydrop},
		{mod.FF.HoneyEye},
		{mod.FF.Homer},
		{mod.FF.Hover},
		{mod.FF.Stingler},
		{mod.FF.Beebee},
		{mod.FF.Beeter, {Scale = kSmall}},
		{mod.FF.Zingling, {Scale = kSmall}},
		{mod.FF.Ztewie, {Scale = kSmall}},
		{mod.FF.Briar},
	},
	FLY = {
		{91, 0, 0},  -- Swarmer
		{22, 0, 0},  -- Hive
		{22, 3, 0},  -- Tainted Mulligan
		{67, 0, 0},  -- Duke of Flies
		{67, 1, 0},  -- Husk
		{288, 0, 0},  -- Dukie
	},
	SPIDER = {
		{100, nil, nil},  -- Widow
		{100, 1, 0},  -- Wretched
		{101, 0, 0},  -- DaddyLongLegs
		{101, 1, 0},  -- Triachnid
		{205, 0, 0},  -- Nest
		{206, 0, 0},  -- Baby Long Legs
		{206, 1, 0},  -- Small Baby Long Legs
		{207, 0, 0},  -- Crazy Long Legs
		{207, 1, 0},  -- Small Crazy Long Legs
		{215, 0, 0},  -- Level 2 Spider
		{mod.FF.StickySack},
		{mod.FF.WalkingStickySack},
		{mod.FF.StumblingStickySack},
		{mod.FF.ReheatedSackyFly, {Scale = kSmall}},
		{mod.FF.ReheatedSackySpider, {Scale = kSmall}},
		{mod.FF.Cushion},
		{mod.FF.Sackboy},
		{mod.FF.NannyLongLegs},
		{mod.FF.Brood},
		{mod.FF.Carrier},
		{mod.FF.Oralopede},
		{mod.FF.Tommy},
		{mod.FF.Benny},
		{mod.FF.Skuzzball},
		{mod.FF.SkuzzballSmall},
		{mod.FF.Slinger},
		{mod.FF.SlingerBlack},
		{mod.FF.SlingerHead},

	},
	DEMON = {
		{252, 0, 0}, -- Nulls
		{251, 0, 0}, -- Begotten
		{51, 1, 0}, -- Evil Twin
		{259, 0, 0, {Scale = kSmall}}, -- Imp
		{891, 1, 0}, -- Black Goat
		{404, 0, 0}, -- Little Horn
		{411, 0, 0}, -- Big Horn
		{904, 0, 0}, -- Siren
		{267, 0, 0}, -- Dark One
		{268, 0, 0}, -- Adversary
		{906, 0, 0}, -- HornFel
		{69, nil, nil}, -- Loki
		{81, nil, nil}, -- Fallen
		{273, nil, nil}, -- Lamb
		{84, nil, nil}, -- Satan
		{274, nil, nil}, -- MegaSatan
		{951, 0, 0}, -- Beast
		{883, 0, 0}, -- Baby Begotten
		{mod.FF.Doomer},
		{mod.FF.Blazer},
		{mod.FF.Dominated},
		{mod.FF.MsDominator},
		{mod.FF.PsiHunter},
		{mod.FF.Thrall},
		{mod.FF.Kukodemon},
		{mod.FF.PitchforkHitcher},
		{mod.FF.DreadMaw},
		{mod.FF.DreadWeaver},
		

	},
	--[[GHOST = {
		{219, 0, 0},  -- Wizoob
		{260, 0, 0},  -- Haunt
		{285, 0, 0},  -- Red Ghost
		{403, 0, 0},  -- Forsaken
		{260, 10, nil, {Scale = kSmall}},  -- Lil' Haunt
		{816, nil, nil, {Scale = kSmall}},  -- Polty
		{833, nil, nil, {Scale = kSmall}},  -- Candler
		{842, 0, 0},  -- NightWatch
		{882, 0, 0},  -- Dust
		{902, 0, 0},  -- Rainmaker
		{905, 0, 0},  -- Heretic
		{mod.FF.Temper},
		{mod.FF.Yawner},
		{mod.FF.Ghostse},
		{mod.FF.Menace},
		{mod.FF.ThousandEyes.ID, mod.FF.ThousandEyes.Var, nil},
		{mod.FF.Spook},
		{mod.FF.Peekaboo},
		{mod.FF.Gutter},
		{mod.FF.Deathany},
		{mod.FF.Mistmonger},
		{mod.FF.Tango},
		{mod.FF.Ignis},
		{mod.FF.Gritty, {Scale = kSmall}},
		{mod.FF.Specturn, {Scale = kSmall}},
		{mod.FF.Murmur, {Scale = kSmall}},
		{mod.FF.Murasa},
		{mod.FF.Moaner},
		{mod.FF.Banshee},
		{mod.FF.Ripcord},
		{mod.FF.Spoop, {Scale = kSmall, Morph=true}},
		{mod.FF.Sleeper},
		{mod.FF.Shi},
		{mod.FF.Cuffs},
		{mod.FF.Empath},
		{mod.FF.DungeonMaster},
		{mod.FF.Shirk},
		{mod.FF.OrgChaser},
		{mod.FF.OrgBashful},
		{mod.FF.OrgSpeedy},
		{mod.FF.OrgPokey},
		{mod.FF.Ghostbuster},
		{mod.FF.Emmission, {Scale = kSmall}},
		{mod.FF.CongressingEmmission, {Scale = kSmall}},
		{mod.FF.Onlyfan},
		{mod.FF.Haunted},
		{mod.FF.Crotchety},
		{mod.FF.G_Host},
		{mod.FF.Accursed},
		{mod.FF.Whispers},
	},]]
}

-- Parses EnemiesByPoopType to populate the EntityPoopData on init.
for poopType, tab in pairs(EnemiesByPoopType) do
	for _, enemyData in pairs(tab) do
		if type(enemyData[1]) == "table" then
			assignPoopDataFromTable(enemyData[1], PoopType[poopType], enemyData[2])
		else
			assignPoopData(enemyData[1], enemyData[2], enemyData[3], PoopType[poopType], enemyData[4])
		end
	end
end

-- Returns the appropriate poop data for the given entity.,
local function getEntityPoopData(entity)
	-- Dip familiars
	if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.DIP then
		local dipType = DipSubTypeInverted[entity.SubType] or DipSubTypeInverted[0]
		return {
			Data = PoopType[dipType] or PoopType.NORMAL,
			ExtraData = {Scale = kSmall},
		}
	end
	
	-- Other entities
	local tab = EntityPoopData
	for _, i in pairs({entity.Type, entity.Variant, entity.SubType}) do
		if not tab[i] and not tab[-1] then
			return {Data = PoopType.NORMAL, ExtraData = {}}
		end
		tab = tab[i] or tab[-1]
	end
	return tab
end

-- Support for slot variants that can poop.
local SlotsThatCanPoop = {}
for _, variant in pairs({
			4, -- Beggar
			5, -- Devil Beggar
			6, -- Shell Game
			7, -- Key Beggar
			9, -- Bomb Beggar
			13, -- Battery Beggar
			15, -- Hell Game
			18, -- Rotten Beggar
			mod.FF.PokerTable.Var,
			mod.FF.Blacksmith.Var,
			--mod.FF.ZodiacBeggar.Var, --???
			mod.FF.FakeBeggar.Var,
			mod.FF.CellGame.Var,
			mod.FF.HugBeggar.Var,
			mod.FF.CosplayBeggar.Var,
		}) do
	SlotsThatCanPoop[variant] = true
end

-- Returns true if Brown Horn can affect this entity.
local function canBrownHornAffectEntity(entity)
	if entity.Type == EntityType.ENTITY_FAMILIAR then
		return entity.Variant == FamiliarVariant.DIP
	elseif entity.Type == EntityType.ENTITY_FIREPLACE or entity.Type == mod.FFID.Tech then
		return false
	elseif entity.Type == EntityType.ENTITY_SLOT then
		return SlotsThatCanPoop[entity.Variant]
	elseif (mod:isSegmented(entity) or mod:isBasegameSegmented(entity)) and not (mod:isMainSegment(entity) or mod:isBasegameMainSegment(entity)) then
		return false
	end
	
	local tab = EntityPoopData
	
	for _, i in pairs({entity.Type, entity.Variant, entity.SubType}) do
		if not tab[i] and not tab[-1] then
			return entity:IsVulnerableEnemy() or not mod.IsEnemyReallyInvulnerable(entity)
		end
		tab = tab[i] or tab[-1]
	end
	
	if tab then
		return true
	else
		return false
	end
end

-- Try to inflict Brown Horn's effect on an entity.
local function tryBrownHorn(player, entity)
	if canBrownHornAffectEntity(entity) then
		local poopTable = getEntityPoopData(entity)
		local poopData = poopTable.Data
		local poopExtraData = poopTable.ExtraData
		
		if poopExtraData.Morph and entity:ToNPC() then
			-- Replace this entity with a familiar immediately.
			entity:Remove()
			entity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DIP, poopData.DipType, entity.Position, entity.Velocity, player)
			entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		elseif poopExtraData.Convert and entity:ToNPC() then
			-- Permanently charm this enemy.
			entity:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)
			entity:GetData().isBrownHornFriendly = true
		end
		
		local data = entity:GetData()
		
		data.heardTheBrownHorn = true
		data.brownHornSource = player
		data.brownHornAngle = (player.Position - entity.Position):GetAngleDegrees()
		data.brownHornFrames = 0
		data.brownHornVelocity = entity.Velocity
		data.brownHornLastPos = nil
		data.brownHornGoingFast = false
		data.brownHornDidSlam = false
		data.brownHornCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
		
		if data.brownHornPoopLaser then
			data.brownHornPoopLaser.Timeout = 1
			data.brownHornPoopLaser = nil
		end
	end
end

-- Brown Horn on-use function. Find all the valid targets.
function mod:brownHorn(_, rng, player, useFlags, activeSlot)
	for _, entity in pairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 9999, EntityPartition.ENEMY)) do
		tryBrownHorn(player, entity)
	end
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DIP, -1, false, false)) do
		tryBrownHorn(player, entity)
	end
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, -1, -1, false, false)) do
		tryBrownHorn(player, entity)
	end
	for i=0, game:GetNumPlayers()-1 do
		local otherPlayer = game:GetPlayer(i)
		if otherPlayer and otherPlayer:Exists() and otherPlayer.InitSeed ~= player.InitSeed then
			otherPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_POOP)
			for i=0, rng:RandomInt(3) do
				otherPlayer:ThrowFriendlyDip(DipSubType.NORMAL, otherPlayer.Position, kZeroVector)
			end
		end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
		sfx:Play(mod.Sounds.BrownHornLong)
	else
		sfx:Play(mod.Sounds.BrownHorn)
	end
	return {ShowAnim = true}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.brownHorn, mod.ITEM.COLLECTIBLE.THE_BROWN_HORN)

-- Entity update function for entities being affected by Brown Horn.
function mod:brownHornEntityUpdate(entity)
	local data = entity:GetData()
	
	if data.isBrownHornFriendly and game:GetRoom():GetFrameCount() <= 1 then
		entity.Position = Isaac.GetPlayer(0).Position
	end
	
	if data.heardTheBrownHorn then
		local room = game:GetRoom()
		
		local player = data.brownHornSource or Isaac.GetPlayer(0)
		local playerRef = EntityRef(player)
		
		local poopTable = getEntityPoopData(entity)
		local poopData = poopTable.Data
		local poopExtraData = poopTable.ExtraData
		
		local poopScale = poopExtraData.Scale or 1.0
		
		local isFriend = entity.Type == EntityType.ENTITY_FAMILIAR or entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		local isVulnerable = entity:IsVulnerableEnemy() or not mod.IsEnemyReallyInvulnerable(entity)
		
		local brownHornDuration = kBrownHornDuration
		if data.brownHornCarBattery then
			brownHornDuration = math.ceil(brownHornDuration * 1.5)
		end
		
		-- Brown laser
		if not data.brownHornPoopLaser then
			local laserParent = entity
			if mod:isSegmented(entity) or mod:isBasegameSegmented(entity) then
				while laserParent.Child and laserParent.Child.Visible do
					laserParent = laserParent.Child
				end
				if not laserParent:IsVulnerableEnemy() and laserParent.Parent and laserParent.Parent:IsVulnerableEnemy() then
					laserParent = laserParent.Parent
				end
			end
			local laser = EntityLaser.ShootAngle(12, laserParent.Position, data.brownHornAngle, brownHornDuration, kZeroVector, player)
			laser.Parent = laserParent
			laser:SetMaxDistance(50 * poopScale)
			if poopData.LaserColor then
				laser.Color = poopData.LaserColor
			end
			laser.CollisionDamage = kLaserDamage
			laser:GetData().isBrownHornPoopLaser = true
			laser:GetData().brownHornPoopLaserScale = poopScale
			data.brownHornPoopLaser = laser
		end
		
		data.brownHornFrames = (data.brownHornFrames or 0) + 1
		
		if not isFriend then
			-- Brown friends
			if kFriendlyDipsToSpawn > 0 then
				local friendlyDipsToSpawn = math.ceil(kFriendlyDipsToSpawn * poopScale)
				if poopScale == kSmall or (entity.MaxHitPoints < 9 and isVulnerable) then
					friendlyDipsToSpawn = 1
				end
				if entity.MaxHitPoints >= 50 and isVulnerable then
					friendlyDipsToSpawn = friendlyDipsToSpawn + 1
				end
				if data.brownHornCarBattery then
					friendlyDipsToSpawn = friendlyDipsToSpawn + 1
				end
				if friendlyDipsToSpawn > 0 and (data.brownHornFrames - 1) % math.floor(brownHornDuration / friendlyDipsToSpawn) == 0 then
					local friendTargetPos = entity.Position + Vector.FromAngle(data.brownHornAngle) * 150
					local friend
					if poopData.SpawnSpiders then
						friend = player:ThrowBlueSpider(entity.Position, friendTargetPos)
					elseif poopData.SpawnFlies then
						friend = player:AddBlueFlies(1, entity.Position, player)
					else
						friend = player:ThrowFriendlyDip(poopData.DipType, entity.Position, friendTargetPos)
					end
					friend:GetData().fromBrownHorn = true
				end
			end
			
			-- Brown confusion
			if entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
				entity:AddConfusion(playerRef, 1, false)
			else
				entity:AddConfusion(playerRef, 2, false)
			end
		end
		
		-- Brown ending
		if data.brownHornFrames >= brownHornDuration then
			data.heardTheBrownHorn = false
			data.brownHornSource = nil
			if data.brownHornOriginalSpriteOffset then
				entity.SpriteOffset = data.brownHornOriginalSpriteOffset
			end
			return
		end
		
		-- Brown momentum
		local targetVel = Vector.FromAngle(data.brownHornAngle + 180) * kBrownHornSpeed
		local isImmobile = entity:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
				or entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				or entity.Type == EntityType.ENTITY_SLOT or entity.Type == EntityType.ENTITY_BEAST
		if isImmobile then
			if not data.brownHornOriginalSpriteOffset then
				data.brownHornOriginalSpriteOffset = entity.SpriteOffset
			end
			local x = 1.5 * math.sin(0.75 * math.pi * game:GetFrameCount())
			local t = 30
			entity.SpriteOffset = Vector(x, 0)
		else
			-- Some funny stuff going on here.
			-- But essentially I'm trying to coax the enemy's velocity in a specific direction, and
			-- detect if something is impeding them (ie, they hit a wall).
			local currentVel = data.brownHornVelocity
			if not data.brownHornDidSlam and data.brownHornVelocity:Length() > kBrownHornSpeed * 0.35 then
				data.brownHornGoingFast = true
			end
			if data.brownHornLastPos then
				currentVel = data.brownHornLastPos - entity.Position
				for _, axis in pairs({"X", "Y"}) do
					if math.abs(data.brownHornVelocity[axis] * 0.5) > math.abs(currentVel[axis]) then
						if not isFriend and not data.brownHornDidSlam and data.brownHornGoingFast then
							-- Hit a wall, probably.
							game:ShakeScreen(10)
							sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1.15, 0, false, 1.2)
							local wallSlamDamage = math.min(kMinWallSlamDamage, math.ceil(entity.MaxHitPoints * kMaxWallSlamDamagePercentage))
							if data.brownHornCarBattery then
								wallSlamDamage = math.min(kMinWallSlamDamage * 2, math.ceil(wallSlamDamage * 1.5))
							end
							entity:TakeDamage(wallSlamDamage, DamageFlag.DAMAGE_CRUSH, playerRef, 0)
							entity:AddConfusion(playerRef, 20, false)
							data.brownHornGoingFast = false
							data.brownHornDidSlam = true
						end
						data.brownHornVelocity[axis] = mod:Lerp(data.brownHornVelocity[axis], currentVel[axis], 0.33)
					end
				end
			end
			data.brownHornVelocity = mod:Lerp(data.brownHornVelocity, targetVel, 0.03)
			
			local targetPos = entity.Position + data.brownHornVelocity
			targetPos = room:GetClampedPosition(targetPos, entity.Size * 0.5)
			data.brownHornVelocity = targetPos - entity.Position
			
			entity.Velocity = data.brownHornVelocity
			
			-- Fix for enemies like round worms and mushrooms.
			entity.TargetPosition = entity.Position
		end
		
		data.brownHornLastPos = entity.Position
		
		-- Brown chunks
		if entity.FrameCount % 10 == 0 then
			local particleVel = targetVel:Resized(3):Rotated(180 + entity:GetDropRNG():RandomInt(40) - 20)
			local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOP_PARTICLE, 0, entity.Position, particleVel, nil)
			if poopData.LaserColor then
				gib.Color = poopData.LaserColor
			end
		end
		
		-- Brown particles
		--[[if entity.FrameCount % 3 == 0 then
			local particleVel = targetVel:Resized(6):Rotated(180 + entity:GetDropRNG():RandomInt(180) - 90)
			local particle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, entity.Position, particleVel, nil)
			particle:Update()
			if poopData.LaserColor then
				particle.Color = poopData.LaserColor
				local c = particle.Color
				c:SetTint(0.8, 0.5, 0.5, 0.75)
				particle.Color = c
			end
			particle.SpriteScale = particle.SpriteScale * 1.5
		end]]
		
		-- Brown creep
		if entity.FrameCount % 5 == 0 then
			local variant = poopData.CreepType
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, 0, entity.Position, kZeroVector, player)
			creep:Update()
			creep.Parent = player
			if poopData.CreepColor then
				creep.Color = poopData.CreepColor
			end
			creep:GetSprite():Stop()
			creep:GetSprite():SetFrame(0)
		end
		
		mod:brownHornLaserUpdate(data.brownHornPoopLaser)
	elseif data.brownHornPoopLaser then
		data.brownHornPoopLaser.Timeout = 1
		data.brownHornPoopLaser = nil
	end
	
	if data.brownHornJustDied and not entity:IsDead() then
		data.brownHornJustDied = nil
	end
end

-- Brown update for Brown Horn's Brown Laser
function mod:brownHornLaserUpdate(laser)
	local data = laser:GetData()
	
	if not data.isBrownHornPoopLaser then return end
	
	local scale = data.brownHornPoopLaserScale
	if scale < 1.0 then
		laser.SpriteScale = Vector(math.min(laser.SpriteScale.X, scale), math.min(laser.SpriteScale.Y, scale))
	elseif scale > 1.0 and laser.Timeout > 1 then
		laser.SpriteScale = mod:Lerp(laser.SpriteScale, Vector(scale, scale), 0.1)
	end
	
	local parent = laser.Parent
	
	if parent and parent:Exists() then
		local offset = Vector.FromAngle(laser.Angle):Resized(parent.Size * 0.5)
		offset.Y = offset.Y - laser.Parent.Size*0.5
		if offset.Y < 0 then
			laser.DepthOffset = -5
		else
			laser.DepthOffset = 5
		end
		laser.PositionOffset = offset + Vector(0, parent.PositionOffset.Y)
		data.brownHornLaserOffset = laser.PositionOffset
	else
		if data.brownHornLaserOffset then
			laser.PositionOffset = data.brownHornLaserOffset
		end
		if laser.Timeout > 1 then
			laser.Timeout = 1
		end
	end
end

-- Dip familiars and charmed enemies are invulnerable for the duration of Brown Horn's effect.
function mod:brownHornDamage(entity)
	if (entity.Type == EntityType.ENTITY_FAMILIAR or entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and entity:GetData().heardTheBrownHorn then
		return false
	end
end

-- Check if an enemy affected by Brown Horn dies.
function mod:brownHornEntityDeath(entity)
	local data = entity:GetData()
	if data.heardTheBrownHorn and entity:IsEnemy() then
		data.brownHornJustDied = true
	end
end

-- If an enemy affected by Brown horn died and was subsequently removed, spawn a poop.
function mod:brownHornEntityRemove(entity)
	local data = entity:GetData()
	if data.heardTheBrownHorn and data.brownHornJustDied then
		local room = game:GetRoom()
		local player = data.brownHornSource or Isaac.GetPlayer(0)
		if not room:GetGridEntityFromPos(entity.Position) then
			local poopData = getEntityPoopData(entity).Data
			if poopData.CustomGridEntity then
				local customGrid = poopData.CustomGridEntity:Spawn(room:GetGridIndex(entity.Position), true, false)
				if poopData.CustomGridEntity.Name == "FFEvilPoop" then
					customGrid.PersistentData.AuraScale = Vector(0.2, 0.2)
				end
			elseif poopData.BlueBabyPoopVariant then
				Isaac.Spawn(EntityType.ENTITY_POOP, poopData.BlueBabyPoopVariant, 0, entity.Position, kZeroVector, player)
			elseif game:GetRoom():GetType() ~= RoomType.ROOM_DUNGEON then
				Isaac.GridSpawn(poopData.GridEntityType or GridEntityType.GRID_POOP, poopData.GridEntityVariant or 0, entity.Position, false)
			end
		end
	end
end

-- Familiars spawned by Brown Horn are made unable to collide with anything briefly after spawning,
-- so that they don't immediately collide with the enemy they spawned from.
function mod:brownHornFamiliarCollision(entity)
	if entity:GetData().fromBrownHorn and entity.FrameCount <= 20 then
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.brownHornFamiliarCollision, FamiliarVariant.DIP)
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.brownHornFamiliarCollision, FamiliarVariant.BLUE_SPIDER)
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.brownHornFamiliarCollision, FamiliarVariant.BLUE_FLY)
