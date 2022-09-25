
--This setting allows for enemy replacements to occur.
--In the mod for example, Warheads will occasionally replace red boom flies.
--Set this to false to prevent this from occurring.
--Default value is true.
FiendFolio.replacementsEnabled = true

--In the Fiend Folio mod, some default enemy replacements are disabled.
--The Thing for example, no longer will replace Wall Creeps, Rage Creeps and Blind Creeps.
--Set this to true to bring these replacements back.
--Default value is false.
FiendFolio.legacyReplacementsEnabled = false

--Reskins green puzzle blocks to be a yellow with a higher brightness value
--Default value is false
--No longer supported bc like it wasnt good lol!
FiendFolio.ColourBlindMode = false

--This setting allows for different special modes

--Setting 1: Mern Mode
--We're not exactly sure what this one does

--Setting 2: Super Easy Mode
--For people who can't stand difficulty
--This disables all enemies, and leaves in only one special easy enemy.

--Default value is 0
FiendFolio.ModeEnabled = 0

--This setting allows FF enemies to have name tags

--Setting 0: Disabled
--FF enemies dont have name tags

--Setting 1: Always
--FF enemies always have visible name tags

--Setting 2: Toggle
--Press assigned key to make name tags visibles or not

--Default value is 0
FiendFolio.NameTags = 0
FiendFolio.NameTagKeybind = -1

-- If false, FF items will not appear (default true)
FiendFolio.ItemsEnabled = true
-- If false, FF cards will not appear
FiendFolio.CardsEnabled = true

--Automatically enables debug 5 at the start of a run (default false unless you're one of those team folio nerds)
FiendFolio.ShowRoomNames = 1
FiendFolio.RoomNameOpacity = 1
FiendFolio.RoomNameScale = 2

--Every tear fired has a chance to be a Fortune Cookie tear (default false)
FiendFolio.GreatFortune = false

--Changes Monsoon's name
FiendFolio.MonsoonNames = {
	[1] = "gfx/bosses/moistro/bossname_monsoon.png",
	[2] = "gfx/bosses/moistro/bossname_moistro.png",
	[3] = "gfx/bosses/moistro/bossname_jack.png",
	[4] = "gfx/bosses/moistro/bossname_compromise.png",
	[5] = "gfx/bosses/moistro/bossname_compromise2.png"
}

FiendFolio.MonsoonName = 1

--Changes Warp Zone's name
FiendFolio.WarpZoneNames = {
	[1] = "gfx/bosses/warp_zone/bossname_warpzone.png",
	[2] = "gfx/bosses/warp_zone/bossname_warpzooooone.png",
	[3] = "gfx/bosses/warp_zone/bossname_megaportal.png",
}

FiendFolio.WarpZoneName = 1

--Allows for some different AI stuff to occur! (default true)
FiendFolio.ChangeAi = true

--If rev's enabled, uses them shaders for vanilla things (default true)
FiendFolio.RevShaderUpgrade = true

--A small collection of Config for FiendFolio's titular character Fiend and his unlocks will live here
FiendFolio.FiendConfig = {
	ClassicTears = false, --Default value is false, when true Fiend's tears are more faithful to The Devil's Harvest
	ImpBabyMode = false, --Default value is false, We highly recommend that you do not play with this enabled
}

FiendFolio.CardConfig = {}
FiendFolio.ItemConfig = {}
FiendFolio.HotkeyConfig = {
	Taunts = true,
	Killbinds = false,
}
FiendFolio.DataHarvesting = {
	Name = 1,
	Address = 1,
	Class = 1,
	Pet = 1,
	Color = 1,
	Dev = 1,
	PhoneNumber = 1,
	CreditNumber = 1,
	Age = 13,
	Gender = 13,
	Height = 13,
	Weight = 13,
	NetWorth = 13,
	Level = 13,
	LimbCount = 4,
	CookiesEssential = 1,
	CookiesTracking = 1,
	BitcoinMining = 1,
}

FiendFolio.CustomFortunesEnabled = true
FiendFolio.WackyPoopsEnabled = true
FiendFolio.BossPoolOverhaulEnabled = true