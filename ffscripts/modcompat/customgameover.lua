if CustomGameOver then

CustomGameOver.ANM2s.FiendFolio = {
	Filepath = "gfx/ui/death screen_ff.anm2",
	AnimName = "Diary",
	Entity = {
		Offset = Vector(0, 0),
		EnemyLayerID = 5,
		BossLayerID = 3,
		EnemyFrames = {},
		BossFrames = {},
	},
}

local enemyFrames = CustomGameOver.ANM2s.FiendFolio.Entity.EnemyFrames
local bossFrames = CustomGameOver.ANM2s.FiendFolio.Entity.BossFrames

local GetVariantID = CustomGameOver.Functions.GetVariantID
local GetSubTypeID = CustomGameOver.Functions.GetSubTypeID

-- This function is used to make sure that definitions set by other mods are not overwritten.
local function setIfNotExists(tbl, id, val)
	if tbl[id] == nil then
		tbl[id] = val
	end
end

-- Character, Items, Familiars & Grids --
	-- Locks --
	setIfNotExists(enemyFrames, GetVariantID(1000, 1013), 61) -- Blue Lock
	setIfNotExists(enemyFrames, GetVariantID(1000, 1014), 61) -- Green Lock
	setIfNotExists(enemyFrames, GetVariantID(1000, 1015), 61) -- Red Lock
	setIfNotExists(enemyFrames, GetVariantID(1000, 1017), 61) -- Blue Chain Lock
	setIfNotExists(enemyFrames, GetVariantID(1000, 1018), 61) -- Green Chain Lock
	setIfNotExists(enemyFrames, GetVariantID(1000, 1019), 61) -- Red Chain Lock

	-- Fire Pot --
	setIfNotExists(enemyFrames, GetVariantID(1000, 1016), 61) -- Fire Pot

	-- Vermin TNTs --
	setIfNotExists(enemyFrames, GetVariantID(292, 750), 439) -- Super TNT
	setIfNotExists(enemyFrames, GetVariantID(292, 751), 113) -- Water TNT

-- Technical --
	-- Dank Fatty Slime --
	setIfNotExists(enemyFrames, GetVariantID(950, 0), 226) -- Tar Bubble
	setIfNotExists(enemyFrames, GetSubTypeID(950, 0, 1), 274) -- Spider Egg

	-- Bubbles --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 0), 214) -- Bubble (Tiny)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 1), 214) -- Bubble (Small)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 2), 214) -- Bubble (Medium)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 3), 214) -- Bubble (Large)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 4), 214) -- Bubble (Fly)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 5), 214) -- Bubble (Spider)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 6), 218) -- Bubble (Explosive)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 7), 218) -- Bubble (Small watery)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 8), 218) -- Bubble (Medium watery)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1, 9), 218) -- Bubble (Large watery)

	-- Fly Balls --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 2, 0), 5) -- Fly Bundle

	-- Nimbus Cloud --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 3, 0), 5) -- Nimbus Cloud

	-- Jawbone Corpse --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 4, 0), 247) -- Jawbone Corpse

	-- Bone Rocket --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 5, 0), 299) -- Bone Rocket

	-- Stinger Projectile --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 6, 0), 315) -- Stinger Projectile

	-- Big Stinger Projectile --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 6, 1), 315) -- Homing Stinger Projectile

	-- Spore Projectile --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 7, 0), 247) -- Spore Projectile

	-- Dogmeat Projectile --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 8, 0), 348) -- Nerve Cluster

	-- Worm Projectile --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 9, 0), 247) -- Flying Maggot

	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 0), 83) -- lvl2 Spider (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 1), 83) -- Ticking Spider (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 2), 83) -- Baby Long Legs (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 3), 83) -- Small Baby Long Legs (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 4), 83) -- Crazy Long Legs (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 5), 83) -- Small Crazy Long Legs (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 10, 6), 83) -- Full Spider (Waiting)

	setIfNotExists(enemyFrames, GetSubTypeID(950, 11, 0), 83) -- Rider's Scythe

	-- Hollow Knight Projectile --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 12, 0), 83) -- Hollow Knight Projectile

	setIfNotExists(enemyFrames, GetVariantID(950, 13), 161) -- Sparkly Cross
	setIfNotExists(enemyFrames, GetVariantID(950, 14), 405) -- Gary
	setIfNotExists(enemyFrames, GetVariantID(950, 15), 427) -- Floating Spore

	-- Waiting Worms --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 1), 83) -- Round Worm (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 2), 83) -- Nightcrawler (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 3), 83) -- Ulcer (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 4), 83) -- Roundy (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 5), 83) -- Tube Worm (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 6), 83) -- Parabite (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 7), 83) -- Scarred Parabite (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 8), 83) -- Bone Worm (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 9), 83) -- Drink Worm (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 10), 83) -- Lump (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 11), 83) -- Fred (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 12), 83) -- Weaver (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 13), 83) -- Weaver Sr.(Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 14), 83) -- Pin (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 15), 83) -- Scolex (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 16), 83) -- Frail (Waiting)
	setIfNotExists(enemyFrames, GetSubTypeID(950, 16, 17), 83) -- KP (Waiting)

	-- Big Hemo --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 17, 0), 5) -- Mega Haemolacria Projectile
	setIfNotExists(enemyFrames, GetSubTypeID(950, 18, 0), 5) -- Horse Projectile

	setIfNotExists(enemyFrames, GetVariantID(950, 19), 161) -- Bone Cross
	setIfNotExists(enemyFrames, GetVariantID(950, 20), 161) -- Chain ball

	setIfNotExists(enemyFrames, GetVariantID(950, 21), 161) -- Sternum Rib

	-- Snagger Key --
	setIfNotExists(enemyFrames, GetVariantID(950, 22), 161) -- Key Projectile
	setIfNotExists(enemyFrames, GetVariantID(950, 23), 283) -- Psyeg

	-- Backdrop Replacer --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1000, 0), 1) -- Backdrop Replacer

	-- Ramblin Mushroom Waypoints --
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1001, 0), 1) -- Red Ramblepoint
	setIfNotExists(enemyFrames, GetSubTypeID(950, 1002, 0), 1) -- Blue Ramblepoint

-- Enemies --
	-- Hungrygan --
	setIfNotExists(enemyFrames, GetVariantID(16, 960), 200) -- Facade

	-- Roly Poly --
	setIfNotExists(enemyFrames, GetVariantID(21, 960), 238) -- Roly Poly
	setIfNotExists(enemyFrames, GetSubTypeID(21, 960, 1), 238) -- Septic Poly

	-- Nimbus --
	setIfNotExists(enemyFrames, GetVariantID(21, 666), 237) -- Nimbus
	setIfNotExists(enemyFrames, GetSubTypeID(21, 666, 1), 237) -- Septic Nimbus

	-- Cistern --
	setIfNotExists(enemyFrames, GetVariantID(22, 666), 182) -- Cistern

	-- Rocket Charger --
	setIfNotExists(enemyFrames, GetVariantID(23, 960), 179) -- Sternum
	setIfNotExists(enemyFrames, GetVariantID(23, 961), 407) -- Splodum

	-- Reheated Charger --
	setIfNotExists(enemyFrames, GetVariantID(23, 1700), 16) -- Reheated Charger

	-- Doom Fly --
	setIfNotExists(enemyFrames, GetVariantID(25, 960), 187) -- Doom Fly

	-- Golden Boom Fly --
	setIfNotExists(enemyFrames, GetVariantID(25, 961), 193) -- Golden Boom Fly

	-- Warhead --
	setIfNotExists(enemyFrames, GetVariantID(25, 962), 293) -- Warhead
	setIfNotExists(enemyFrames, GetVariantID(25, 963), 293) -- Drainer

	setIfNotExists(enemyFrames, GetSubTypeID(27, 0, 710), 24) -- Reheated Host
	setIfNotExists(enemyFrames, GetSubTypeID(27, 0, 711), 24) -- Reheated Host
	setIfNotExists(enemyFrames, GetSubTypeID(27, 0, 712), 24) -- Reheated Host

	-- Tado Tot --
	setIfNotExists(enemyFrames, GetVariantID(29, 960), 250) -- Tot

	-- Spinneretch --
	setIfNotExists(enemyFrames, GetVariantID(29, 961), 263) -- Spinneretch

	-- Sourpatch Head --
	setIfNotExists(enemyFrames, GetVariantID(29, 962), 337) -- Sourpatch Head
	setIfNotExists(enemyFrames, GetSubTypeID(29, 962, 1), 337) -- Limepatch Head

	-- Sticky Sack --
	setIfNotExists(enemyFrames, GetVariantID(30, 960), 251) -- Sticky Sack
	setIfNotExists(enemyFrames, GetVariantID(88, 960), 322) -- Walking Sticky Sack

	-- Crepitus --
	setIfNotExists(enemyFrames, GetVariantID(227, 666), 313) -- Crepitus

	-- Hollow Knight --
	setIfNotExists(enemyFrames, GetVariantID(227, 960), 197) -- Hollow Knight

	-- Psionic Knight --
	setIfNotExists(enemyFrames, GetSubTypeID(21, 961, 0), 211) -- Psionic Knight

	-- Powderkeg --
	setIfNotExists(enemyFrames, GetVariantID(227, 961), 292) -- Powderkeg

	-- Wetstone --
	setIfNotExists(enemyFrames, GetVariantID(42, 960), 210) -- Wetstone

	-- Cursed Grimace --
	setIfNotExists(enemyFrames, GetVariantID(42, 961), 185) -- Cauldron

	-- Furnace --
	setIfNotExists(enemyFrames, GetVariantID(42, 962), 365) -- Furnace

	-- Artery --
	setIfNotExists(enemyFrames, GetVariantID(44, 960), 39) -- Artery (Mobile)
	setIfNotExists(enemyFrames, GetVariantID(44, 961), 39) -- Artery (Spinning)
	setIfNotExists(enemyFrames, GetVariantID(44, 962), 39) -- Vein

	-- Pipes --
	setIfNotExists(enemyFrames, GetVariantID(44, 1710), 287) -- Septic Pipe
	setIfNotExists(enemyFrames, GetVariantID(44, 1711), 288) -- Sewer Pipe
	setIfNotExists(enemyFrames, GetVariantID(44, 1712), 289) -- Sludge Pipe
	setIfNotExists(enemyFrames, GetVariantID(44, 1713), 290) -- Sphincter
	setIfNotExists(enemyFrames, GetVariantID(44, 1714), 342) -- Split Pipe

	-- Graterhole --
	setIfNotExists(enemyFrames, GetVariantID(44, 980), 39) -- Grate

	-- Hungry Para-Bite --
	setIfNotExists(enemyFrames, GetVariantID(58, 960), 48) -- Hungry Para-Bite

	-- Spitroast --
	setIfNotExists(enemyFrames, GetVariantID(61, 960), 258) -- Spitroast

	-- Spooter --
	setIfNotExists(enemyFrames, GetVariantID(85, 960), 213) -- Spooter
	setIfNotExists(enemyFrames, GetVariantID(85, 961), 217) -- Super Spooter

	-- Baby Spider --
	setIfNotExists(enemyFrames, GetVariantID(85, 962), 252) -- Baby Spider

	-- Gutbuster --
	setIfNotExists(enemyFrames, GetVariantID(207, 960), 196) -- Gutbuster

	-- Jawbone --
	setIfNotExists(enemyFrames, GetVariantID(234, 960), 247) -- Jawbone

	-- Dank Fatty --
	setIfNotExists(enemyFrames, GetVariantID(208, 960), 186) -- Squidge

	-- Drowned Fatty --
	setIfNotExists(enemyFrames, GetVariantID(208, 961), 190) -- Tubby

	-- Mama Fatty --
	setIfNotExists(enemyFrames, GetVariantID(208, 962), 235) -- Mouthful

	-- Big Smoke --
	setIfNotExists(enemyFrames, GetVariantID(208, 963), 302) -- Big Smoke

	setIfNotExists(enemyFrames, GetVariantID(214, 710), 82) -- Icky Fly
	setIfNotExists(enemyFrames, GetVariantID(214, 711), 82) -- Bobby Fly
	setIfNotExists(enemyFrames, GetVariantID(214, 712), 82) -- Reheated Fly
	setIfNotExists(enemyFrames, GetVariantID(214, 713), 82) -- Sacky Fly
	setIfNotExists(enemyFrames, GetVariantID(214, 714), 82) -- Chompy Fly
	setIfNotExists(enemyFrames, GetVariantID(214, 715), 82) -- Ticking Fly

	setIfNotExists(enemyFrames, GetVariantID(215, 710), 83) -- Full Spider
	setIfNotExists(enemyFrames, GetVariantID(215, 711), 83) -- Bobby Spider
	setIfNotExists(enemyFrames, GetVariantID(215, 712), 83) -- Reheated Spider
	setIfNotExists(enemyFrames, GetVariantID(215, 713), 83) -- Sacky Spider
	setIfNotExists(enemyFrames, GetVariantID(215, 714), 83) -- Icky Spider
	setIfNotExists(enemyFrames, GetVariantID(215, 715), 83) -- Chompy Spider

	setIfNotExists(enemyFrames, GetVariantID(87, 710), 0) -- Reheated Gurgle
	setIfNotExists(enemyFrames, GetVariantID(284, 710), 130) -- Reheated Cyclopia

	-- Spark --
	setIfNotExists(enemyFrames, GetVariantID(960, 152), 334) -- Spark

	-- Fried --
	setIfNotExists(enemyFrames, GetVariantID(240, 700), 335) -- Fried

	-- Ogre Creep --
	setIfNotExists(enemyFrames, GetVariantID(240, 701), 347) -- Ogre Creep

	-- Reheated Creeps --
	setIfNotExists(enemyFrames, GetVariantID(240, 710), 335) -- Icky Creep
	setIfNotExists(enemyFrames, GetVariantID(240, 711), 335) -- Techy Creep

	-- Bone Worm --
	setIfNotExists(enemyFrames, GetVariantID(244, 960), 180) -- Bone Worm

	-- Drowned Fat Bat --
	setIfNotExists(enemyFrames, GetVariantID(258, 960), 189) -- Bubble Bat

	-- Ribbone --
	setIfNotExists(enemyFrames, GetVariantID(258, 961), 248) -- Ribbone

	-- Implemented Vermin's Funny Name --
	-- Dangler --
	setIfNotExists(enemyFrames, GetVariantID(610, 0), 417) -- Dangler

	-- Soft Serve --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 0, 0), 233) -- Soft Serve
	setIfNotExists(enemyFrames, GetSubTypeID(666, 1, 0), 240) -- Sundae
	setIfNotExists(enemyFrames, GetSubTypeID(666, 2, 0), 205) -- Scoop

	-- Load --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 10, 0), 228) -- Load
	setIfNotExists(enemyFrames, GetSubTypeID(666, 11, 0), 229) -- Corn Load

	-- Baro --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 20, 0), 176) -- Baro

	-- Chorister --
	setIfNotExists(enemyFrames, GetVariantID(666, 30), 181) -- Chorister

	-- Foamy --
	setIfNotExists(enemyFrames, GetVariantID(666, 40), 270) -- Foamy

	-- Fathead --
	setIfNotExists(enemyFrames, GetVariantID(666, 50), 285) -- Fathead

	-- Skuzz --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 60, 0), 321) -- Skuzz

	-- Ransacked --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 70, 0), 346) -- Ransacked

	-- Skuzzball --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 80, 0), 320) -- Skuzzball
	setIfNotExists(enemyFrames, GetSubTypeID(666, 81, 0), 344) -- Skuzzball	(Small)

	-- Boiler --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 90, 0), 350) -- Boiler

	-- Drink Worm --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 100, 0), 328) -- Drink Worm

	-- wOBBLES --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 110, 0), 327) -- Wobbles

	-- Sludge Host --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 120, 0), 379) -- Sludge Host

	-- Creepertum --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 130, 0), 381) -- Creepterum
	setIfNotExists(enemyFrames, GetSubTypeID(666, 131, 0), 381) -- Corposlave

	-- Curdle --
	setIfNotExists(enemyFrames, GetVariantID(666, 140), 367) -- Curdle
	setIfNotExists(enemyFrames, GetVariantID(666, 141), 438) -- Curdle (Naked)

	-- Calzone --
	setIfNotExists(enemyFrames, GetSubTypeID(666, 150, 0), 418) -- Calzone
	setIfNotExists(enemyFrames, GetSubTypeID(666, 150, 1), 446) -- Panini

	-- Honeydrop --
	setIfNotExists(bossFrames, GetVariantID(666, 160), 103) -- Honeydrop
	setIfNotExists(enemyFrames, GetVariantID(666, 161), 368) -- Bella

	-- Marge --
	setIfNotExists(enemyFrames, GetVariantID(666, 180), 430) -- Marge

	-- Heiress --
	setIfNotExists(bossFrames, GetVariantID(666, 190), 103) -- Heiress
	setIfNotExists(enemyFrames, GetVariantID(666, 191), 430) -- Heiress Skull
	setIfNotExists(bossFrames, GetVariantID(666, 191), 430) -- Queeny III

	-- Guillotine21 Stuff --
	-- Honey Eye --
	setIfNotExists(enemyFrames, GetVariantID(940, 0), 392) -- Honey Eye

	-- Julia enemies --
	-- Temper --
	setIfNotExists(enemyFrames, GetVariantID(970, 0), 234) -- Temper

	-- Spinny --
	setIfNotExists(enemyFrames, GetVariantID(970, 10), 209) -- Spinny

	-- Congression --
	setIfNotExists(enemyFrames, GetVariantID(709, 0), 183) -- Congression
	setIfNotExists(enemyFrames, GetVariantID(709, 1), 183) -- Congression W

	-- Lighting Fly --
	setIfNotExists(enemyFrames, GetVariantID(970, 30), 202) -- Lightning Fly

	-- Blot --
	setIfNotExists(enemyFrames, GetVariantID(970, 40), 178) -- Blot

	-- Melty --
	setIfNotExists(enemyFrames, GetVariantID(970, 50), 230) -- Melty

	-- Pitcher --
	setIfNotExists(enemyFrames, GetVariantID(970, 60), 253) -- Pitcher

	-- Moron --
	setIfNotExists(enemyFrames, GetVariantID(970, 70), 436) -- Mutant Horf

	-- Slammers --
	setIfNotExists(enemyFrames, GetSubTypeID(951, 0, 0), 239) -- Slammer
	setIfNotExists(enemyFrames, GetSubTypeID(951, 1, 0), 212) -- Wimpy
	setIfNotExists(enemyFrames, GetSubTypeID(951, 2, 0), 216) -- Stoney Slammer
	setIfNotExists(enemyFrames, GetSubTypeID(951, 3, 0), 216) -- Crazy Stoney Slammer
	setIfNotExists(enemyFrames, GetSubTypeID(951, 4, 0), 204) -- Smasher
	setIfNotExists(enemyFrames, GetSubTypeID(951, 5, 0), 208) -- S'More
	setIfNotExists(enemyFrames, GetSubTypeID(951, 6, 0), 239) -- S'Eptic

	-- Square Fly --
	setIfNotExists(enemyFrames, GetSubTypeID(952, 0, 0), 221) -- Square Fly (Clockwise)
	setIfNotExists(enemyFrames, GetSubTypeID(952, 1, 0), 224) -- Square Fly (Counter-clockwise)

	-- Sniffle --
	setIfNotExists(enemyFrames, GetVariantID(953, 0), 223) -- Sniffle

	-- Snagger --
	setIfNotExists(enemyFrames, GetVariantID(954, 0), 220) -- Snagger

	-- Weaver --
	setIfNotExists(enemyFrames, GetVariantID(955, 0), 254) -- Weaver
	setIfNotExists(enemyFrames, GetVariantID(955, 1), 419) -- Weaver Sr.
	setIfNotExists(enemyFrames, GetVariantID(955, 2), 448) -- Dread Weaver
	setIfNotExists(enemyFrames, GetVariantID(955, 3), 461) -- Thread

	-- Craterface --
	setIfNotExists(enemyFrames, GetVariantID(956, 0), 184) -- Craterface

	-- Muk --
	setIfNotExists(enemyFrames, GetVariantID(956, 69), 236) -- Drooler

	-- Blazer --
	setIfNotExists(enemyFrames, GetVariantID(956, 666), 177) -- Blazer

	-- Psion --
	setIfNotExists(bossFrames, GetVariantID(959, 0), 98) -- Psion

	-- Poople --
	setIfNotExists(enemyFrames, GetVariantID(960, 0), 203) -- Poople

	-- Clotter --
	setIfNotExists(enemyFrames, GetVariantID(960, 10), 199) -- Dung

	-- Nerve --
	setIfNotExists(enemyFrames, GetVariantID(960, 20), 9) -- Nerve
	setIfNotExists(enemyFrames, GetSubTypeID(960, 20, 1), 9) -- Nerve's Tentacles

	-- Slag --
	setIfNotExists(enemyFrames, GetVariantID(960, 30), 222) -- Meatwad
	setIfNotExists(enemyFrames, GetVariantID(960, 31), 225) -- Slag
	setIfNotExists(enemyFrames, GetVariantID(960, 32), 232) -- Pox
	setIfNotExists(enemyFrames, GetVariantID(960, 33), 255) -- Haunch

	-- Gutbuster Guts --
	setIfNotExists(enemyFrames, GetVariantID(960, 40), 257) -- Offal

	-- Morsel --
	setIfNotExists(enemyFrames, GetVariantID(960, 50), 231) -- Morsel

	-- Frog --
	setIfNotExists(enemyFrames, GetVariantID(960, 60), 192) -- Frog

	-- Motor Neuron --
	setIfNotExists(enemyFrames, GetVariantID(960, 70), 241) -- Motor Neuron

	-- Dweller --
	setIfNotExists(enemyFrames, GetVariantID(960, 80), 191) -- Dweller
	setIfNotExists(enemyFrames, GetVariantID(960, 81), 191) -- Dweller Brother

	-- Warty --
	setIfNotExists(enemyFrames, GetVariantID(960, 90), 206) -- Warty

	-- Gunk --
	setIfNotExists(enemyFrames, GetVariantID(960, 100), 195) -- Gunk
	setIfNotExists(enemyFrames, GetVariantID(960, 101), 195) -- Punk

	-- Gleek --
	setIfNotExists(enemyFrames, GetVariantID(960, 110), 219) -- Gleek

	-- Ribeye --
	setIfNotExists(enemyFrames, GetVariantID(960, 120), 215) -- Ribeye

	-- Cortex --
	setIfNotExists(enemyFrames, GetVariantID(960, 130), 198) -- Cortex

	-- Gorger --
	setIfNotExists(enemyFrames, GetVariantID(960, 140), 194) -- Gorger

	-- Drip --
	setIfNotExists(enemyFrames, GetVariantID(960, 150), 188) -- Drip

	-- Dribble --
	setIfNotExists(enemyFrames, GetVariantID(960, 151), 420) -- Dribble

	-- Fossil --
	setIfNotExists(enemyFrames, GetVariantID(960, 160), 242) -- Fossil

	-- Sentry --
	setIfNotExists(enemyFrames, GetVariantID(960, 161), 411) -- Sentry
	setIfNotExists(enemyFrames, GetSubTypeID(960, 161, 1), 465) -- Sentry Shell

	-- Balor --
	setIfNotExists(enemyFrames, GetVariantID(960, 170), 175) -- Balor
	setIfNotExists(enemyFrames, GetSubTypeID(960, 170, 1), 175) -- Septic Balor

	-- Eyesore --
	setIfNotExists(enemyFrames, GetVariantID(960, 171), 271) -- Eyesore

	-- Gander --
	setIfNotExists(enemyFrames, GetVariantID(960, 172), 272) -- Gander

	-- Beeter --
	setIfNotExists(enemyFrames, GetVariantID(960, 180), 244) -- Beeter

	-- Lil Jon --
	setIfNotExists(enemyFrames, GetVariantID(960, 190), 243) -- Lil' Jon
	setIfNotExists(enemyFrames, GetSubTypeID(960, 190, 1), 243) -- Elite Jon

	-- Crosseyes --
	setIfNotExists(enemyFrames, GetVariantID(960, 200), 246) -- Crosseyes

	-- Tado Kid --
	setIfNotExists(enemyFrames, GetVariantID(960, 210), 249) -- Tado Kid

	-- Toxic Knight --
	setIfNotExists(enemyFrames, GetVariantID(960, 220), 256) -- Toxic Knight

	-- Haunted and Yawner --
	setIfNotExists(enemyFrames, GetVariantID(960, 230), 260) -- Haunted
	setIfNotExists(enemyFrames, GetVariantID(960, 231), 261) -- Yawner

	-- Fishface --
	setIfNotExists(enemyFrames, GetVariantID(960, 240), 259) -- Fishface
	setIfNotExists(enemyFrames, GetSubTypeID(960, 240, 1), 259) -- Fishface (Waiting)

	setIfNotExists(enemyFrames, GetVariantID(960, 241), 259) -- Shiny Fishface

	-- Bubble Blowing Double Baby --
	setIfNotExists(enemyFrames, GetVariantID(960, 250), 284) -- Bubble Blowing Double Baby

	-- Spitum --
	setIfNotExists(enemyFrames, GetVariantID(960, 260), 262) -- Spitum

	-- Ghostse --
	setIfNotExists(enemyFrames, GetVariantID(960, 270), 265) -- Ghostse
	setIfNotExists(bossFrames, GetVariantID(960, 271), 265) -- Ghostse (Easy Mode)
	setIfNotExists(enemyFrames, GetVariantID(960, 272), 265) -- Septic Ghostse

	-- Mr. Flare --
	setIfNotExists(enemyFrames, GetVariantID(960, 280), 282) -- Mr. Flare
	setIfNotExists(enemyFrames, GetVariantID(960, 281), 409) -- Mr. Crisply

	-- Incisor --
	setIfNotExists(enemyFrames, GetVariantID(960, 290), 201) -- Incisor

	-- Starving --
	setIfNotExists(enemyFrames, GetVariantID(960, 300), 280) -- Starving

	-- Woodburner --
	setIfNotExists(enemyFrames, GetVariantID(960, 310), 281) -- Woodburner
	setIfNotExists(enemyFrames, GetVariantID(960, 311), 281) -- Woodburner (Easy mode)

	-- Baby Bat --
	setIfNotExists(enemyFrames, GetVariantID(960, 320), 301) -- Milk Tooth

	-- Squire --
	setIfNotExists(enemyFrames, GetSubTypeID(960, 330, 0), 227) -- Squire

	-- Foreseer --
	setIfNotExists(enemyFrames, GetVariantID(960, 340), 291) -- Foreseer

	-- Psionic Leech --
	setIfNotExists(enemyFrames, GetVariantID(960, 341), 421) -- Psleech

	-- Fumegeist --
	setIfNotExists(enemyFrames, GetVariantID(960, 350), 294) -- Fumegeist

	-- Mote --
	setIfNotExists(enemyFrames, GetVariantID(960, 351), 336) -- Mote

	-- Sourpatch --
	setIfNotExists(enemyFrames, GetVariantID(960, 360), 312) -- Sourpatch
	setIfNotExists(enemyFrames, GetVariantID(960, 361), 340) -- Sourpatch Body
	setIfNotExists(enemyFrames, GetSubTypeID(960, 360, 1), 312) -- Limepatch
	setIfNotExists(enemyFrames, GetSubTypeID(960, 361, 1), 340) -- Limepatch Body

	-- Blood Cell --
	setIfNotExists(enemyFrames, GetVariantID(960, 370), 330) -- Mobile Blood Cell
	setIfNotExists(enemyFrames, GetVariantID(960, 371), 331) -- Spinning Blood Cell

	-- Madclaw --
	setIfNotExists(enemyFrames, GetVariantID(960, 380), 318) -- Madclaw

	-- Head Honcho --
	setIfNotExists(enemyFrames, GetVariantID(960, 390), 309) -- Head Honcho

	-- Hivemind --
	setIfNotExists(enemyFrames, GetVariantID(960, 400), 314) -- Colonel

	-- Zingling --
	setIfNotExists(enemyFrames, GetVariantID(960, 401), 315) -- Zingling

	-- Globulon --
	setIfNotExists(enemyFrames, GetVariantID(960, 410), 319) -- Globulon

	-- Primemind --
	setIfNotExists(enemyFrames, GetVariantID(960, 420), 316) -- Primemind

	-- Charlie --
	setIfNotExists(enemyFrames, GetVariantID(960, 430), 303) -- Charlie

	-- Sooty --
	setIfNotExists(enemyFrames, GetVariantID(960, 431), 304) -- Sooty

	-- Smokin --
	setIfNotExists(enemyFrames, GetVariantID(960, 440), 310) -- Ultimate Smokin
	setIfNotExists(enemyFrames, GetVariantID(960, 441), 310) -- Smokin
	setIfNotExists(enemyFrames, GetVariantID(960, 442), 431) -- Flamin
	setIfNotExists(enemyFrames, GetSubTypeID(960, 442, 1), 431) -- Flamin Chain

	-- Flickerspirit --
	setIfNotExists(enemyFrames, GetVariantID(960, 450), 317) -- Flickerspirit

	-- Eternal Flickerspirit --
	setIfNotExists(enemyFrames, GetVariantID(960, 451), 404) -- Eternal Flickerspirit

	-- Deadfly --
	setIfNotExists(enemyFrames, GetVariantID(960, 460), 329) -- Deadfly
	setIfNotExists(enemyFrames, GetVariantID(960, 461), 5) -- Eternal Fly

	-- Dogmeat --
	setIfNotExists(enemyFrames, GetVariantID(960, 470), 348) -- Dogmeat

	-- Brooter --
	setIfNotExists(enemyFrames, GetVariantID(960, 480), 349) -- Brooter

	-- Tap --
	setIfNotExists(enemyFrames, GetVariantID(960, 490), 343) -- Tap

	-- Tall bois 'n Shitlinz --
	setIfNotExists(enemyFrames, GetVariantID(960, 500), 326) -- Tall Boi
	setIfNotExists(enemyFrames, GetVariantID(960, 501), 325) -- Shitling

	-- Peepling --
	setIfNotExists(enemyFrames, GetVariantID(960, 510), 324) -- Peepling

	--Effigy --
	setIfNotExists(enemyFrames, GetVariantID(960, 520), 352) -- Harletwin
	setIfNotExists(enemyFrames, GetSubTypeID(960, 520, 1), 352) -- Harletwin Cord
	setIfNotExists(enemyFrames, GetVariantID(960, 521), 332) -- Effigy
	setIfNotExists(enemyFrames, GetSubTypeID(960, 521, 1), 332) -- Effigy Cord

	-- Gis --
	setIfNotExists(enemyFrames, GetVariantID(960, 530), 333) -- Gis

	-- Centipede --
	setIfNotExists(enemyFrames, GetVariantID(960, 540), 383) -- Centipede
	setIfNotExists(enemyFrames, GetSubTypeID(960, 540, 1), 383) -- Centipede Segment
	setIfNotExists(enemyFrames, GetVariantID(960, 541), 383) -- Angy Centipede

	-- Smoking Mulligan --
	setIfNotExists(enemyFrames, GetVariantID(960, 550), 266) -- Mullikaboom

	-- Poobottle --
	setIfNotExists(enemyFrames, GetVariantID(960, 560), 360) -- Poobottle
	setIfNotExists(enemyFrames, GetVariantID(960, 561), 449) -- Drainfly

	-- Grater --
	setIfNotExists(enemyFrames, GetVariantID(960, 570), 364) -- Grater

	-- Tombit --
	setIfNotExists(enemyFrames, GetVariantID(960, 580), 432) -- Tombit
	setIfNotExists(enemyFrames, GetVariantID(960, 581), 433) -- Gravin

	-- Homer --
	setIfNotExists(enemyFrames, GetVariantID(960, 590), 374) -- Homer

	-- Gishle --
	setIfNotExists(enemyFrames, GetVariantID(960, 600), 363) -- Gishle

	-- Hover --
	setIfNotExists(enemyFrames, GetVariantID(960, 610), 375) -- Hover

	-- Sagging Sucker --
	setIfNotExists(enemyFrames, GetVariantID(960, 620), 357) -- Sagging Sucker

	-- Red Horf --
	setIfNotExists(enemyFrames, GetVariantID(960, 630), 369) -- Red Horf

	-- Zapbladder --
	setIfNotExists(enemyFrames, GetVariantID(960, 640), 422) -- Zapbladder
	setIfNotExists(enemyFrames, GetVariantID(960, 641), 423) -- Wire

	-- Piper --
	setIfNotExists(enemyFrames, GetVariantID(960, 650), 424) -- Piper

	-- Scythe Rider --
	setIfNotExists(enemyFrames, GetVariantID(960, 660), 410) -- Scythe Rider

	-- Ms. Dominator --
	setIfNotExists(enemyFrames, GetVariantID(960, 670), 377) -- Ms. Dominator
	setIfNotExists(enemyFrames, GetVariantID(960, 671), 425) -- Dominated

	-- Custom Boom Fly --
	-- Fossilized Boom Fly --
	setIfNotExists(enemyFrames, GetVariantID(960, 680), 361) -- Fossilized Boom Fly

	-- Stingler --
	setIfNotExists(enemyFrames, GetVariantID(960, 681), 376) -- Stingler

	-- Space left open for Trickle --
	setIfNotExists(enemyFrames, GetVariantID(960, 682), 353) -- Trickle (Flying)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 682, 1), 354) -- Trickle (Skittering)

	-- Fishaac --
	setIfNotExists(enemyFrames, GetVariantID(960, 690), 372) -- Fishaac

	-- Bumble --
	setIfNotExists(enemyFrames, GetVariantID(960, 700), 306) -- Bumbler

	-- Menace --
	setIfNotExists(enemyFrames, GetVariantID(960, 710), 380) -- Menace

	-- Thousand Eyes --
	setIfNotExists(enemyFrames, GetVariantID(960, 711), 402) -- Thousand Eyes

	-- Warden --
	setIfNotExists(enemyFrames, GetVariantID(960, 720), 426) -- Warden

	-- Eroded Host --
	setIfNotExists(enemyFrames, GetSubTypeID(960, 730, 0), 278) -- Eroded Host

	-- Immural --
	setIfNotExists(enemyFrames, GetVariantID(960, 740), 408) -- Immural

	-- Shiitake --
	setIfNotExists(enemyFrames, GetVariantID(960, 750), 427) -- Shiitake

	-- Bowler --
	setIfNotExists(enemyFrames, GetSubTypeID(960, 760, 0), 386) -- Bowler
	setIfNotExists(enemyFrames, GetSubTypeID(960, 760, 1), 388) -- Loafer
	setIfNotExists(enemyFrames, GetSubTypeID(960, 760, 2), 387) -- Bowler Ball

	-- Septic --
	setIfNotExists(enemyFrames, GetSubTypeID(960, 769, 0), 386) -- Septic Bowler
	setIfNotExists(enemyFrames, GetSubTypeID(960, 769, 1), 388) -- Septic Loafer
	setIfNotExists(enemyFrames, GetSubTypeID(960, 769, 2), 387) -- Septic Bowler Ball

	setIfNotExists(enemyFrames, GetVariantID(960, 770), 384) -- Mr. Horf
	setIfNotExists(enemyFrames, GetVariantID(960, 771), 384) -- Thrown Horf

	setIfNotExists(enemyFrames, GetVariantID(960, 772), 385) -- Mr. Red Horf
	setIfNotExists(enemyFrames, GetVariantID(960, 773), 385) -- Thrown Red Horf

	-- Cordify --
	setIfNotExists(enemyFrames, GetVariantID(960, 780), 382) -- Cordify

	-- Spook - CONGA LADS --
	setIfNotExists(enemyFrames, GetVariantID(960, 790), 341) -- Spook
	setIfNotExists(enemyFrames, GetVariantID(960, 791), 341) -- Spook Spawner

	-- Utero Pillar --
	setIfNotExists(enemyFrames, GetVariantID(960, 800), 358) -- Utero Pillar

	-- Organelle --
	setIfNotExists(enemyFrames, GetVariantID(960, 801), 378) -- Organelle

	-- Honeydrip --
	setIfNotExists(enemyFrames, GetVariantID(960, 810), 393) -- Honeydrip

	-- Slim --
	setIfNotExists(enemyFrames, GetSubTypeID(960, 820, 0), 389) -- Slim
	setIfNotExists(enemyFrames, GetSubTypeID(960, 821, 0), 390) -- Pale Slim
	setIfNotExists(enemyFrames, GetSubTypeID(960, 821, 1), 391) -- Jim

	-- Pester --
	setIfNotExists(enemyFrames, GetVariantID(960, 830), 412) -- Pester

	-- Ramblin' Evil Mushroom --
	setIfNotExists(enemyFrames, GetVariantID(960, 840), 434) -- Ramblin' Evil Mushroom

	-- Bola --
	setIfNotExists(enemyFrames, GetVariantID(960, 850), 362) -- Bola
	setIfNotExists(enemyFrames, GetSubTypeID(960, 850, 2), 362) -- Bola Neck

	-- Smidgen - Baby Host --
	setIfNotExists(enemyFrames, GetVariantID(960, 860), 435) -- Smidgen
	setIfNotExists(enemyFrames, GetVariantID(960, 861), 445) -- Red Smidgen

	-- Looker --
	setIfNotExists(enemyFrames, GetVariantID(960, 870), 444) -- Armoured Looker
	setIfNotExists(enemyFrames, GetSubTypeID(960, 870, 1), 441) -- Looker

	-- Peekaboo --
	setIfNotExists(enemyFrames, GetVariantID(960, 880), 442) -- Peek-a-boo
	setIfNotExists(enemyFrames, GetVariantID(960, 881), 443) -- Peek-a-boo Eye

	-- Why --
	setIfNotExists(enemyFrames, GetVariantID(960, 888), 447) -- Ring of Ring Flies

	-- Shambles --
	setIfNotExists(enemyFrames, GetVariantID(960, 890), 450) -- Dr. Shambles

	-- Inner Eye --
	setIfNotExists(enemyFrames, GetVariantID(960, 900), 454) -- Inner Eye
	setIfNotExists(enemyFrames, GetVariantID(960, 901), 453) -- Enlightened
	setIfNotExists(enemyFrames, GetSubTypeID(960, 901, 1), 453) -- Unenlightened

	-- Mr. Gob --
	setIfNotExists(enemyFrames, GetVariantID(960, 910), 455) -- Mr. Gob
	setIfNotExists(enemyFrames, GetVariantID(960, 911), 456) -- Gob

	-- Globscraper --
	setIfNotExists(enemyFrames, GetVariantID(960, 920), 356) -- Globscraper

	-- Foe --
	setIfNotExists(enemyFrames, GetVariantID(960, 930), 406) -- Foe

	-- Psi Hunter --
	setIfNotExists(enemyFrames, GetVariantID(960, 940), 286) -- Psi Hunter
	setIfNotExists(enemyFrames, GetVariantID(960, 941), 466) -- Psiling

	-- Umbra --
	setIfNotExists(enemyFrames, GetVariantID(960, 950), 370) -- Umbra
	setIfNotExists(enemyFrames, GetVariantID(960, 950), 370, 1) -- Blistered Umbra
	setIfNotExists(enemyFrames, GetVariantID(960, 951), 452) -- Eclipse

	-- Seeker --
	setIfNotExists(enemyFrames, GetVariantID(960, 960), 462) -- Seeker

	-- C Word and Neonate --
	setIfNotExists(enemyFrames, GetVariantID(960, 970), 464) -- C Word
	setIfNotExists(enemyFrames, GetVariantID(960, 971), 463) -- Neonate

-- Oroshibu --
	-- Valvo --
	setIfNotExists(enemyFrames, GetVariantID(812, 0), 416) -- Valvo

	-- Sombra --
	setIfNotExists(enemyFrames, GetVariantID(812, 1), 345) -- Sombra

-- Snakeskin --
	-- Womb Pillar --
	setIfNotExists(enemyFrames, GetVariantID(808, 110), 351) -- Womb Pillar

	-- Watcher --
	setIfNotExists(enemyFrames, GetVariantID(808, 111), 414) -- Watcher

	-- Watcher Eye --
	setIfNotExists(enemyFrames, GetVariantID(808, 112), 415) -- Watcher Eye

	-- Mistmonger --
	setIfNotExists(enemyFrames, GetVariantID(808, 113), 371) -- Mistmonger

	-- Cordend --
	setIfNotExists(enemyFrames, GetVariantID(808, 114), 355) -- Cordend

	-- Cordend's Right Half --
	setIfNotExists(enemyFrames, GetSubTypeID(808, 114, 1), 355) -- Cordend's Right Half

	-- Cordend Cord --
	setIfNotExists(enemyFrames, GetSubTypeID(808, 114, 2), 355) -- Cordend Cord

	-- Guflush
	setIfNotExists(enemyFrames, GetVariantID(808, 115), 413) -- Guflush

-- Weird extras --
	-- MOTHER ORB --
	setIfNotExists(enemyFrames, GetVariantID(960, 1000), 273) -- Mother Orb

	-- Jackson --
	setIfNotExists(enemyFrames, GetVariantID(960, 1001), 273) -- Jackson

	-- The Freezer --
	setIfNotExists(enemyFrames, GetVariantID(960, 1002), 273) -- The Freezer

	-- Peat --
	setIfNotExists(bossFrames, GetVariantID(960, 1003), 273) -- Peat

	-- Horse --
	setIfNotExists(bossFrames, GetVariantID(960, 1004), 273) -- Horse

	-- Baba --
	setIfNotExists(enemyFrames, GetVariantID(960, 1715), 273) -- Baba

	-- Fish --
	setIfNotExists(enemyFrames, GetVariantID(960, 1716), 451) -- Fish from Nuclear Throne

	-- Beserker reheadted --
	setIfNotExists(enemyFrames, GetVariantID(960, 1710), 273) -- Beserker

	-- Binding of Isaac: Reheated --
	setIfNotExists(enemyFrames, GetVariantID(960, 1711), 273) -- The Binding of Isaac: Reheated

	setIfNotExists(enemyFrames, GetVariantID(960, 1713), 1) -- Spider (Nicalis)

-- Melon coded --
	-- Fat Shroom and Shroom Leapers --
	setIfNotExists(enemyFrames, GetVariantID(960, 2000), 296) -- Splattercap
	setIfNotExists(enemyFrames, GetVariantID(960, 2001), 295) -- Cordy

	-- Berry and Spicy Dip --
	setIfNotExists(enemyFrames, GetVariantID(960, 2002), 298) -- Berry
	setIfNotExists(enemyFrames, GetVariantID(960, 2003), 297) -- Spicy Dip

-- small divider just so this point is easier to locate between erfly's stuff and the bosses --
	-- Possessed and Moaner --
	setIfNotExists(enemyFrames, GetVariantID(227, 750), 276) -- Possessed
	setIfNotExists(enemyFrames, GetVariantID(750, 10), 276) -- Possessed Corpse
	setIfNotExists(enemyFrames, GetVariantID(750, 20), 277) -- Moaner

	-- Kitty Kannon
	setIfNotExists(enemyFrames, GetVariantID(750, 30), 299) -- Unpawtunate
	setIfNotExists(enemyFrames, GetVariantID(750, 40), 300) -- Unpawtunate Skull

	-- Mama Pooter --
	setIfNotExists(enemyFrames, GetVariantID(750, 50), 308) -- Mama Pooter
	setIfNotExists(enemyFrames, GetVariantID(21, 750), 307) -- Creepy Maggot

	-- Gravedigger --
	setIfNotExists(bossFrames, GetVariantID(750, 60), 99) -- Gravedigger
	setIfNotExists(enemyFrames, GetVariantID(750, 70), 183) -- Gravefire

	-- Sackboy --
	setIfNotExists(enemyFrames, GetVariantID(750, 80), 403) -- Sackboy

	-- Gnawful --
	setIfNotExists(enemyFrames, GetVariantID(750, 90), 305) -- Gnawful

	-- Ragurge --
	setIfNotExists(enemyFrames, GetVariantID(750, 100), 311) -- Ragurge

	-- Wick --
	setIfNotExists(enemyFrames, GetVariantID(750, 110), 267) -- Wick

	-- Banshee --
	setIfNotExists(enemyFrames, GetVariantID(218, 750), 339) -- Banshee

	-- Infected Mushroom --
	setIfNotExists(enemyFrames, GetVariantID(750, 130), 275) -- Infected Mushroom

	-- Bone Slammer --
	setIfNotExists(enemyFrames, GetSubTypeID(750, 140, 0), 323) -- Cracker

	-- Nuchal --
	setIfNotExists(enemyFrames, GetVariantID(750, 150), 338) -- Nuchal
	setIfNotExists(enemyFrames, GetVariantID(750, 151), 338) -- Nuchal (Detached)
	setIfNotExists(enemyFrames, GetVariantID(750, 152), 338) -- Nuchal (Cord)

-- BOSSES (ID 980) --
	-- Buck --
	setIfNotExists(bossFrames, GetVariantID(980, 0), 95) -- Buck

	-- Lez --
	setIfNotExists(enemyFrames, GetSubTypeID(980, 0, 100), 437) -- Lez

	-- Batty --
	setIfNotExists(bossFrames, GetVariantID(980, 10), 96) -- Battie

	-- Buster --
	setIfNotExists(bossFrames, GetVariantID(980, 20), 101) -- Buster
	setIfNotExists(enemyFrames, GetSubTypeID(980, 21, 0), 428) -- Commission

	-- Griddle --
	setIfNotExists(bossFrames, GetVariantID(980, 30), 102) -- Griddle Horn

	-- Moistro --
	setIfNotExists(bossFrames, GetVariantID(980, 40), 100) -- Monsoon

	-- The Sun --
	setIfNotExists(enemyFrames, GetVariantID(980, 50), 429) -- The Sun
	setIfNotExists(bossFrames, GetVariantID(980, 51), 110) -- Venus
	setIfNotExists(bossFrames, GetVariantID(980, 52), 110) -- Earth
	setIfNotExists(bossFrames, GetVariantID(980, 53), 110) -- Neptune
	setIfNotExists(enemyFrames, GetVariantID(980, 54), 429) -- Moon
	setIfNotExists(enemyFrames, GetVariantID(980, 55), 429) -- Sun Spike

	-- The Organization --
	setIfNotExists(bossFrames, GetVariantID(980, 60), 105) -- Chaser
	setIfNotExists(bossFrames, GetSubTypeID(980, 60, 1), 105) -- Chaser Brain
	setIfNotExists(bossFrames, GetVariantID(980, 61), 106) -- Bashful
	setIfNotExists(enemyFrames, GetSubTypeID(980, 61, 1), 106) -- Bashful Corpse
	setIfNotExists(bossFrames, GetVariantID(980, 62), 107) -- Speedy
	setIfNotExists(bossFrames, GetVariantID(980, 63), 108) -- Pokey
	setIfNotExists(enemyFrames, GetSubTypeID(980, 63, 1), 106) -- Pokey Corpse

	-- Basco --
	setIfNotExists(bossFrames, GetVariantID(980, 70), 100) -- Basco
	setIfNotExists(enemyFrames, GetVariantID(980, 71), 100) -- Basco's Food

	-- Kingpin --
	setIfNotExists(bossFrames, GetVariantID(980, 80), 112) -- Kingpin

	-- Peeping --
	setIfNotExists(bossFrames, GetVariantID(980, 90), 97) -- Peeping
	setIfNotExists(bossFrames, GetVariantID(980, 91), 97) -- Peeping (Phase 2)

	setIfNotExists(enemyFrames, GetVariantID(980, 92), 457) -- Peepstalk
	setIfNotExists(enemyFrames, GetVariantID(980, 93), 458) -- Peepee

	-- Luncheon --
	setIfNotExists(bossFrames, GetVariantID(980, 100), 111) -- Luncheon
	setIfNotExists(enemyFrames, GetVariantID(980, 101), 394) -- Tapeworm
	setIfNotExists(enemyFrames, GetVariantID(980, 102), 398) -- Generic Egg
	setIfNotExists(enemyFrames, GetSubTypeID(980, 102, 1), 398) -- Petunia Egg
	setIfNotExists(enemyFrames, GetSubTypeID(980, 102, 2), 399) -- Greg Egg
	setIfNotExists(enemyFrames, GetSubTypeID(980, 102, 3), 400) -- Minkus Egg
	setIfNotExists(enemyFrames, GetSubTypeID(980, 102, 4), 401) -- Boris Egg
	setIfNotExists(enemyFrames, GetSubTypeID(980, 103, 0), 394) -- Worm Ball

	setIfNotExists(bossFrames, GetVariantID(980, 110), 113) -- Pollution
	setIfNotExists(bossFrames, GetVariantID(980, 111), 114) -- Pollution (Horsepowered)

	-- Best Boss --
	setIfNotExists(bossFrames, GetVariantID(980, 1000), 4) -- Blue Horf

	-- Dukey Demony --
	setIfNotExists(bossFrames, GetVariantID(980, 1010), 4) -- Duke of Demons
    setIfNotExists(enemyFrames, GetVariantID(980, 1011), 258) -- Duke's Demon

	-- v1.1 & v1.2 --
	setIfNotExists(enemyFrames, GetSubTypeID(960, 761, 0), 467) -- Striker
	setIfNotExists(enemyFrames, GetSubTypeID(960, 761, 1), 469) -- Pale Loafer
	setIfNotExists(enemyFrames, GetSubTypeID(960, 761, 2), 468) -- Striker Ball

	setIfNotExists(enemyFrames, GetSubTypeID(960, 820, 2), 470) -- Limb
	setIfNotExists(enemyFrames, GetSubTypeID(960, 821, 2), 471) -- Pale Limb

	setIfNotExists(enemyFrames, GetSubTypeID(292, 752, 0), 476) -- Buttery Compost Bin
	setIfNotExists(enemyFrames, GetSubTypeID(292, 752, 1), 476) -- Gassy Compost Bin
	setIfNotExists(enemyFrames, GetSubTypeID(292, 752, 2), 476) -- Scented Compost Bin
	setIfNotExists(enemyFrames, GetSubTypeID(292, 752, 3), 476) -- Unstable Compost Bin

	setIfNotExists(enemyFrames, GetVariantID(950, 24), 475) -- Amniotic Sac

	setIfNotExists(enemyFrames, GetVariantID(1000, 1024), 61) -- Lily Pad

	setIfNotExists(enemyFrames, GetSubTypeID(666, 200, 0), 472) -- Patzer
	setIfNotExists(enemyFrames, GetSubTypeID(666, 201, 0), 472) -- Patzer Shell

	setIfNotExists(enemyFrames, GetVariantID(960, 683), 473) -- Bunch
	setIfNotExists(enemyFrames, GetSubTypeID(960, 683, 1), 474) -- Grape

	setIfNotExists(enemyFrames, GetVariantID(950, 25), 283) -- Davy Crockett
	setIfNotExists(enemyFrames, GetVariantID(950, 26), 113) -- Barrel of Nuclear Waste
	setIfNotExists(enemyFrames, GetVariantID(960, 51), 231) -- Falafel
	setIfNotExists(bossFrames, GetVariantID(980, 120), 115) -- Meltdown
	setIfNotExists(bossFrames, GetVariantID(980, 121), 116) -- Meltdown (Raptured)
	setIfNotExists(bossFrames, GetVariantID(980, 122), 115) -- Fake Horse

	setIfNotExists(enemyFrames, GetVariantID(227, 667), 313) -- Mr. Bones

	setIfNotExists(enemyFrames, GetSubTypeID(21, 960, 2), 238) -- Isopoly

	setIfNotExists(enemyFrames, GetVariantID(930, 10), 359) -- Magleech

	setIfNotExists(enemyFrames, GetVariantID(930, 20), 35) -- Myiasis
	setIfNotExists(enemyFrames, GetVariantID(930, 21), 35) -- Myiasis Projectile

	setIfNotExists(enemyFrames, GetVariantID(930, 30), 404) -- Viscerspirit

	setIfNotExists(enemyFrames, GetVariantID(239, 750), 102) -- Ossularry

	setIfNotExists(bossFrames, GetSubTypeID(980, 1000, 1), 4) -- Blue Horf 2

	setIfNotExists(enemyFrames, GetVariantID(960, 862), 435) -- Eroded Smidgen

	setIfNotExists(enemyFrames, GetVariantID(85, 963), 217) -- Mega Spooter
	setIfNotExists(enemyFrames, GetSubTypeID(88, 961, 0), 322) -- Stumbling Sticky Sack
	setIfNotExists(enemyFrames, GetVariantID(61, 961), 258) -- Spitfire
	setIfNotExists(enemyFrames, GetSubTypeID(951, 7, 0), 239) -- Stompy
	setIfNotExists(enemyFrames, GetSubTypeID(666, 152, 0), 446) -- Breadbin

	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 2), 191) -- Dweller (Inner Eye)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 3), 191) -- Dweller (Spoon Bender)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 6), 191) -- Dweller (Number One)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 8), 191) -- Dweller (Brother Bobby)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 68), 191) -- Dweller (Technology)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 169), 191) -- Dweller (Polyphemus)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 224), 191) -- Dweller (Cricket's Body)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 316), 191) -- Dweller (Cursed Eye)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 330), 191) -- Dweller (Soy Milk)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 496), 191) -- Dweller (Euthanasia)
	setIfNotExists(enemyFrames, GetSubTypeID(960, 80, 1000), 191) -- Dweller (Random)

	setIfNotExists(enemyFrames, GetVariantID(960, 980), 175) -- Flanks

	setIfNotExists(enemyFrames, GetVariantID(920, 222), 0) -- Onlooker
end
