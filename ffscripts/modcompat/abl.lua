local mod = FiendFolio
local game = Game()

mod.ABLFFBlacklists = {
	{EntityType.ENTITY_THE_HAUNT, -1, -1, {}, "small"},
	{EntityType.ENTITY_POLTY, -1, -1, {}, "small"},
	{EntityType.ENTITY_CANDLER, -1, -1, {}, "small"},
	{EntityType.ENTITY_PORTAL, -1, -1, {}, "small"},
	{EntityType.ENTITY_DUST, -1, -1, {}, "small"},
	{mod.FF.Poople.ID, mod.FF.Poople.Var, -1, {}, "poop"},
	{mod.FF.Scoop.ID, mod.FF.Scoop.Var, -1, {}, "poop"},
	{mod.FF.Sundae.ID, mod.FF.Sundae.Var, -1, {}, "poop"},
	{mod.FF.Load.ID, mod.FF.Load.Var, -1, {}, "poop"},
	{mod.FF.CornLoad.ID, mod.FF.CornLoad.Var, -1, {}, "poop"},
	{mod.FF.SoftServe.ID, mod.FF.SoftServe.Var, -1, {}, "poop"},
	{mod.FF.Ghostse.ID, mod.FF.Ghostse.Var, -1, {}, "poop"},
	{mod.FF.Gnawful.ID, mod.FF.Gnawful.Var, -1, {}, "small"},
	{mod.FF.ThousandEyes.ID, mod.FF.ThousandEyes.Var, -1, {}, "small"},
	{mod.FF.Peekaboo.ID, mod.FF.Peekaboo.Var, -1, {}, "small"},
	{mod.FF.DungeonMaster.ID, mod.FF.DungeonMaster.Var, -1, {}, "small"},
	{mod.FF.G_Host.ID, mod.FF.G_Host.Var, -1, {}, "small"},
	{mod.FF.Dung.ID, mod.FF.Dung.Var, -1, {}, "poop"},
	{mod.FF.Shitling.ID, mod.FF.Shitling.Var, -1, {}, "poop"},
	{mod.FF.Tallboi.ID, mod.FF.Tallboi.Var, -1, {}, "poop"},
	{mod.FF.Yawner.ID, mod.FF.Yawner.Var, -1, {}, "small"},
	{mod.FF.Shirk.ID, mod.FF.Shirk.Var, -1, {}, "small"},
	{mod.FF.Spoop.ID, mod.FF.Spoop.Var, -1, {}, "small"},
	{mod.FF.Menace.ID, mod.FF.Menace.Var, -1, {}, "small"},
	{mod.FF.PaleLimb.ID, mod.FF.PaleLimb.Var, mod.FF.PaleLimb.Sub, {}, "small"},
	{mod.FF.Slick.ID, mod.FF.Slick.Var, -1, {}, "small"},
	{mod.FF.Stump.ID, mod.FF.Stump.Var, -1, {}, "small"},
	{mod.FF.Ossularry.ID, mod.FF.Ossularry.Var, -1, {}, "bone"},
	{mod.FF.BoneWorm.ID, mod.FF.BoneWorm.Var, -1, {}, "bone"},
	{mod.FF.DoomFly.ID, mod.FF.DoomFly.Var, -1, {}, "bone"},
	{mod.FF.Sternum.ID, mod.FF.Sternum.Var, -1, {}, "bone"},
	{mod.FF.MolarOrbital.ID, mod.FF.MolarOrbital.Var, -1, {}, "bone"},
	{mod.FF.MolarSystem.ID, mod.FF.MolarSystem.Var, -1, {}, "bone"},
	{mod.FF.Ribbone.ID, mod.FF.Ribbone.Var, -1, {}, "bone"},
	{mod.FF.Jawbone.ID, mod.FF.Jawbone.Var, -1, {}, "bone"},
	{mod.FF.DryWheeze.ID, mod.FF.DryWheeze.Var, -1, {}, "bone"},
	{mod.FF.Sternum.ID, mod.FF.Sternum.Var, -1, {}, "bone"},
	{mod.FF.Splodum.ID, mod.FF.Splodum.Var, -1, {}, "bone"},
	{mod.FF.Possessed.ID, mod.FF.Possessed.Var, -1, {}, "bone"},
	{mod.FF.Crepitus.ID, mod.FF.Crepitus.Var, -1, {}, "bone"},
	{mod.FF.Cracker.ID, mod.FF.Cracker.Var, -1, {}, "bone"},
	{mod.FF.MrBones.ID, mod.FF.MrBones.Var, -1, {}, "bone"},
	{mod.FF.Moaner.ID, mod.FF.Moaner.Var, -1, {}, "small"},
	{mod.FF.RingOfRingFlies.ID, mod.FF.RingOfRingFlies.Var, -1, {}, "small"},
	{mod.FF.Rancor.ID, mod.FF.Rancor.Var, -1, {}, "stone"},
	{mod.FF.Flickerspirit.ID, mod.FF.Flickerspirit.Var, -1, {}, "small"},
	{mod.FF.Shi.ID, mod.FF.Shi.Var, -1, {}, "small"},
	{mod.FF.Zealot.ID, mod.FF.Zealot.Var, -1, {}, "stone"},
	{mod.FF.Shaker.ID, mod.FF.Shaker.Var, -1, {}, "stone"},
	{mod.FF.MazeRunner.ID, mod.FF.MazeRunner.Var, -1, {}, "bone"},
	{mod.FF.Ripcord.ID, mod.FF.Ripcord.Var, -1, {}, "poop"},
	{mod.FF.BeadFly.ID, mod.FF.BeadFly.Var, -1, {}, "small"},
	{mod.FF.Rotskull.ID, mod.FF.Rotskull.Var, -1, {}, "bone"},
	{mod.FF.Oralopede.ID, mod.FF.Oralopede.Var, -1, {}, "bone"},
	{mod.FF.Oralid.ID, mod.FF.Oralid.Var, -1, {}, "bone"},
	{mod.FF.Skuzz.ID, mod.FF.Skuzz.Var, -1, {}, "small"},
	{mod.FF.RingSkuzz.ID, mod.FF.RingSkuzz.Var, -1, {}, "small"},
	{mod.FF.Skuzzball.ID, mod.FF.Skuzzball.Var, -1, {}, "small"},
	{mod.FF.SkuzzballSmall.ID, mod.FF.SkuzzballSmall.Var, -1, {}, "small"},
	{mod.FF.CongaSkuzz.ID, mod.FF.CongaSkuzz.Var, -1, {}, "small"},
	{mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, -1, {}, "small"},
	{mod.FF.Shoter.ID, mod.FF.Shoter.Var, -1, {}, "small"},
	{mod.FF.Zingling.ID, mod.FF.Zingling.Var, -1, {}, "small"},
	{mod.FF.Beeter.ID, mod.FF.Beeter.Var, -1, {}, "small"},
	{mod.FF.Spooter.ID, mod.FF.Spooter.Var, -1, {}, "small"},
	{mod.FF.SuperSpooter.ID, mod.FF.SuperSpooter.Var, -1, {}, "small"},
	{mod.FF.Spark.ID, mod.FF.Spark.Var, -1, {}, "small"},
	{mod.FF.Smokin.ID, mod.FF.Smokin.Var, -1, {}, "small"},
	{mod.FF.Fumegeist.ID, mod.FF.Fumegeist.Var, -1, {}, "small"},
	{mod.FF.Smogger.ID, mod.FF.Smogger.Var, -1, {}, "small"},
	{mod.FF.LightningFly.ID, mod.FF.LightningFly.Var, -1, {}, "small"},
	{mod.FF.ShittyHorf.ID, mod.FF.ShittyHorf.Var, -1, {}, "poop"},
	{mod.FF.Stomy.ID, mod.FF.Stomy.Var, -1, {}, "poop"},
	{mod.FF.Dollop.ID, mod.FF.Dollop.Var, -1, {}, "poop"},
	{mod.FF.Connipshit.ID, mod.FF.Connipshit.Var, -1, {}, "poop"},
	{mod.FF.ReallyTallboi.ID, mod.FF.ReallyTallboi.Var, -1, {}, "poop"},
	{mod.FF.Smidgen.ID, mod.FF.Smidgen.Var, -1, {}, "small"},
	{mod.FF.RedSmidgen.ID, mod.FF.RedSmidgen.Var, -1, {}, "small"},
	{mod.FF.Shiitake.ID, mod.FF.Shiitake.Var, -1, {}, "small"},
	{mod.FF.Morsel.ID, mod.FF.Morsel.Var, -1, {}, "small"},
	{mod.FF.Bunch.ID, mod.FF.Bunch.Var, -1, {}, "small"},
	{mod.FF.Grape.ID, mod.FF.Grape.Var, -1, {}, "small"},
	{mod.FF.ErodedSmidgen.ID, mod.FF.ErodedSmidgen.Var, -1, {}, "small"},
	{mod.FF.TarBubble.ID, mod.FF.TarBubble.Var, -1, {}, "dank"},
	{mod.FF.Squidge.ID, mod.FF.Squidge.Var, -1, {}, "dank"},
	{mod.FF.Slag.ID, mod.FF.Slag.Var, -1, {}, "dank"},
	{mod.FF.Gunk.ID, mod.FF.Gunk.Var, -1, {}, "dank"},
	{mod.FF.Gorger.ID, mod.FF.Gorger.Var, -1, {}, "dank"},
	{mod.FF.Blot.ID, mod.FF.Blot.Var, -1, {}, "dank"},
	{mod.FF.Pitcher.ID, mod.FF.Pitcher.Var, -1, {}, "dank"},
	{mod.FF.TrashbaggerDank.ID, mod.FF.TrashbaggerDank.Var, mod.FF.TrashbaggerDank.Sub, {}, "dank"},
	{mod.FF.Bunkter.ID, mod.FF.Bunkter.Var, -1, {}, "dank"},
	{mod.FF.Gis.ID, mod.FF.Gis.Var, -1, {}, "dank"},
	{mod.FF.SludgeHost.ID, mod.FF.SludgeHost.Var, -1, {}, "dank"},
	{mod.FF.Grater.ID, mod.FF.Grater.Var, -1, {}, "dank"},
	{mod.FF.Clogmo.ID, mod.FF.Clogmo.Var, -1, {}, "dank"},
	{mod.FF.Piper.ID, mod.FF.Piper.Var, -1, {}, "stone"},
	{mod.FF.Boiler.ID, mod.FF.Boiler.Var, -1, {}, "stone"},
	{mod.FF.Guflush.ID, mod.FF.Guflush.Var, -1, {}, "dank"},
	{mod.FF.Gob.ID, mod.FF.Gob.Var, -1, {}, "dank"},
	{mod.FF.MrGob.ID, mod.FF.MrGob.Var, -1, {}, "dank"},
	{mod.FF.Slimer.ID, mod.FF.Slimer.Var, -1, {}, "dank"},
	{mod.FF.Punk.ID, mod.FF.Punk.Var, -1, {}, "dank"},
	{mod.FF.Gobhopper.ID, mod.FF.Gobhopper.Var, -1, {}, "dank"},
	{mod.FF.Gritty.ID, mod.FF.Gritty.Var, -1, {}, "small"},
	{mod.FF.Limb.ID, mod.FF.Limb.Var, mod.FF.Limb.Sub, {}, "small"},
	{mod.FF.Umbra.ID, mod.FF.Umbra.Var, -1, {}, "small"},
	{mod.FF.Sombra.ID, mod.FF.Sombra.Var, -1, {}, "small"},
	{mod.FF.PsyEg.ID, mod.FF.PsyEg.Var, -1, {}, "small"},
	{mod.FF.Seeker.ID, mod.FF.Seeker.Var, -1, {}, "stone"},
	{mod.FF.Dogrock.ID, mod.FF.Dogrock.Var, -1, {}, "stone"},
	{mod.FF.Looker.ID, mod.FF.Looker.Var, -1, {}, "stone"},
	{EntityType.ENTITY_WIZOOB, -1, -1, {"Corpse Eater"}, "small"}, -- ghosts don't bleed dummy
	{EntityType.ENTITY_RED_GHOST, -1, -1, {"Corpse Eater"}, nil},
	{mod.FF.Poobottle.ID, mod.FF.Poobottle.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Tap.ID, mod.FF.Tap.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Ignis.ID, mod.FF.Ignis.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.Tricko.ID, mod.FF.Tricko.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.RingLeader.ID, mod.FF.RingLeader.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.Aleya.ID, mod.FF.Aleya.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.Temper.ID, mod.FF.Temper.Var, -1, {"Necromancer", "Corpse Eater"}, nil},
	{mod.FF.PatzerShell.ID, mod.FF.PatzerShell.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Pawn.ID, mod.FF.Pawn.Var, -1, {"Necromancer"}, nil},
	{mod.FF.EternalFlickerspirit.ID, mod.FF.EternalFlickerspirit.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Viscerspirit.ID, mod.FF.Viscerspirit.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Flamin.ID, mod.FF.Flamin.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.FlaminChain.ID, mod.FF.FlaminChain.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.FerrWaiting.ID, mod.FF.FerrWaiting.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Cuffs.ID, mod.FF.Cuffs.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
    {mod.FF.StoneySlammer.ID, mod.FF.StoneySlammer.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.JawboneCorpse.ID, mod.FF.JawboneCorpse.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Tombit.ID, mod.FF.Tombit.Var, -1, {"Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Gravin.ID, mod.FF.Gravin.Var, -1, {"Necromancer", "Corpse Eater"}, "stone"},
	{mod.FF.FlyingMaggot.ID, mod.FF.FlyingMaggot.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Gary.ID, mod.FF.Gary.Var, -1, {"Coil", "Necromancer", "Corpse Eater"}, nil},
	{mod.FF.Skulltist.ID, mod.FF.Skulltist.Var, -1, {"Corpse Eater"}, "bone"},
	{mod.FF.Morvid.ID, mod.FF.Morvid.Var, -1, {"Corpse Eater"}, "bone"},
	{mod.FF.Empath.ID, mod.FF.Empath.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.Madhat.ID, mod.FF.Madhat.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.Zissuru.ID, mod.FF.Zissuru.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Nihilist.ID, mod.FF.Nihilist.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Grimoire.ID, mod.FF.Grimoire.Var, -1, {"Corpse Eater"}, "small"},
	{mod.FF.Haemo.ID, mod.FF.Haemo.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Lurch.ID, mod.FF.Lurch.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Apega.ID, mod.FF.Apega.Var, -1, {"Corpse Eater"}, "stone"},
	{mod.FF.MsDominator.ID, mod.FF.MsDominator.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Thrall.ID, mod.FF.Thrall.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.Fingore.ID, mod.FF.Fingore.Var, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.MyiasisProj.ID, mod.FF.MyiasisProj.Var, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.ThrownOralid.ID, mod.FF.ThrownOralid.Var, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, -1, {"Coil", "Corpse Eater"}, nil},
	{mod.FF.LurkerStoma.ID, mod.FF.LurkerStoma.Var, -1, {"Corpse Eater"}, nil},
	{mod.FF.BabySpider.ID, mod.FF.BabySpider.Var, -1, {"Coil"}, "small"},
	{mod.FF.Miscarriage.ID, mod.FF.BabySpider.Var, -1, {"Coil"}, "small"},
}

if AntiMonsterLib then --Antibirth Monster Library compatability
    for _, entry in pairs(mod.ABLFFBlacklists) do
        local blacklists = entry[4]
        for _, list in pairs(blacklists) do
			if not inAMLblacklist(list, entry[1], entry[2], entry[3]) then
            	AMLblacklistEntry(list, entry[1], entry[2], entry[3], "add")
			end
        end 
        if entry[5] then
			if not GetEatenEffect(entry[1], entry[2], entry[3]) == entry[5] then
            	EatenEffectEntry(entry[1], entry[2], entry[3], "add", entry[5])
			end
        end
    end 
	mod:AddToSkulltistWhitelist(false, EntityType.ENTITY_DUMPLING)
	mod:AddToSkulltistWhitelist(true, EntityType.ENTITY_VESSEL)
end

--[[/////////////////////////////////////////--
	HOW TO USE BLACKLIST FUNCTIONS:

Adding / Removing entry:
AMLblacklistEntry(blacklist, Type, Variant, SubType, operation)
	there are 3 possible blacklists: "Coil", "Necromancer" and "Corpse Eater"
	the possible operations are "add" and "remove"
	if the function fails (eg. if you're trying to remove an entry that doesn't exist), it will give an error in the console and return false, otherwise it will return true
	setting the Type or Variant to -1 will include all variants or subtypes

Checking for blacklist entries:
inAMLblacklist(blacklist, checkType, checkVariant, checkSubType)
	there are 3 possible blacklists: "Coil", "Necromancer" and "Corpse Eater"
	returns true if the specified entity is in the blacklist, returns false otherwise
	setting the Type or Variant to -1 will include all variants or subtypes



	HOW TO USE CORPSE EATER EFFECT FUNCTIONS:
	
Adding / Removing entry:
EatenEffectEntry(Type, Variant, SubType, operation, effect)
	there are 5 possible effects: "small" (reduced effects, no projectiles), "bone", "poop", "stone", "dank" (unique projectiles)
	if an entity doesn't have an effect entry it will default to regular blood projectiles with occasional bone ones
	the possible operations are "add" and "remove"
	if the function fails (eg. if you're trying to remove an entry that doesn't exist), it will give an error in the console and return false, otherwise it will return true
	setting the Type or Variant to -1 will include all variants or subtypes
	
Checking for effect entries:
GetEatenEffect(checkType, checkVariant, checkSubType)
	returns the entities effect group as a string if it has an entry, returns false otherwise
	setting the Type or Variant to -1 will include all variants or subtypes
--/////////////////////////////////////////]]--