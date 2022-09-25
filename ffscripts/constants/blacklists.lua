local mod = FiendFolio

--GENERAL ENTITY LISTS----

--Cauldron Blacklist
mod.Cloneless = {
	{13, 0, 250}, --Soundmaker Fly
	{mod.FF.PsiKnight.ID, mod.FF.PsiKnight.Var, 1}, 		--Psionic Knight Brain
	{281}, 				--Swarm
	--{666,4}, 			--Bubble Grimace
	{mod.FFID.Tech}, 	--Technical enemies (Bubbles, tar bubbles, etc)
	{mod.FF.Blazer.ID, mod.FF.Blazer.Var},	--Blazer
	{mod.FF.Psion.ID},						--Psion
	{mod.FF.Cortex.ID, mod.FF.Cortex.Var},	--Cortex
	{mod.FF.LilJon.ID, mod.FF.LilJon.Var},	--Lil Jon
	{mod.FF.ToxicKnight.ID, mod.FF.ToxicKnight.Var, 1},						--Toxic Knight Brain
	{mod.FF.EternalFlickerspirit.ID, mod.FF.EternalFlickerspirit.Var},     --Eternal Flickerspirit
	{mod.FF.Viscerspirit.ID, mod.FF.Viscerspirit.Var},                     --Viscerspirit
	{mod.FF.Specturn.ID, mod.FF.Specturn.Var}, 	--Specturn
	{mod.FF.Observer.ID, mod.FF.Observer.Var}, 	--Observer
	{EntityType.ENTITY_PORTAL},                	--Portals / Lil' Portals
	{EntityType.ENTITY_EVIS, 10},              	--Evis Guts
	{mod.FF.Gravin.ID, mod.FF.Gravin.Var},     	--Gravin
	{mod.FF.Tsarball.ID, mod.FF.Tsarball.Var},	--TsarBall

	{mod.FF.Lurker.ID, mod.FF.Lurker.Var},
	{mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var},
	{mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth.Var},
	{mod.FF.LurkerStoma.ID, mod.FF.LurkerStoma.Var},
	{mod.FF.LurkerStretch.ID, mod.FF.LurkerStretch.Var},
	{mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var},
	{mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var},
	{mod.FF.LurkerPsuedoDefault.ID, mod.FF.LurkerPsuedoDefault.Var},
	{mod.FF.LurkerBridgeProj.ID, mod.FF.LurkerBridgeProj.Var},
}


----XALUM ENTITY LISTS----

mod.HaemoBlacklist = {
	{EntityType.ENTITY_GLOBIN, -1, -1},
	{EntityType.ENTITY_BLACK_GLOBIN, -1, -1},
	{EntityType.ENTITY_BLOOD_PUPPY, -1, -1},
	{mod.FF.Cortex.ID, mod.FF.Cortex.Var, mod.FF.Cortex.Sub or -1},
	{mod.FF.HaemoGlobin.ID, mod.FF.HaemoGlobin.Var, mod.FF.HaemoGlobin.Sub or -1},
	{mod.FFID.Tech, -1, -1}, -- Type 150: FF Technical Entities
	{EntityType.ENTITY_EVIS, 10, -1}, --Evis Cords

	{mod.FF.Lurker.ID, mod.FF.Lurker.Var, -1},
	{mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var, -1},
	{mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth.Var, -1},
	{mod.FF.LurkerStoma.ID, mod.FF.LurkerStoma.Var, -1},
	{mod.FF.LurkerStretch.ID, mod.FF.LurkerStretch.Var, -1},
	{mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, -1},
	{mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, -1},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, -1},
	{mod.FF.LurkerPsuedoDefault.ID, mod.FF.LurkerPsuedoDefault.Var, -1},
	{mod.FF.LurkerBridgeProj.ID, mod.FF.LurkerBridgeProj.Var, -1},

}



----GUWAH ENTITY LISTS----

mod.TommyBlacklist = {
	{mod.FFID.Tech, -1, -1}, --FF Technical Entities
	{mod.FF.FerrWaiting.ID, mod.FF.FerrWaiting.Var, -1}, --Ferrium Waiting Entities
	{mod.FF.BabySpider.ID, mod.FF.BabySpider.Var, -1}, 
	{mod.FF.Benny.ID, mod.FF.Benny.Var, -1}, 
	{EntityType.ENTITY_FIREPLACE, -1, -1},
	{EntityType.ENTITY_MOVABLE_TNT, -1, -1},
	{EntityType.ENTITY_EVIS, 10, -1}, --Evis Cords
	{EntityType.ENTITY_BLOOD_PUPPY, -1, -1}, 
	{EntityType.ENTITY_DARK_ESAU, -1, -1}, 
	{EntityType.ENTITY_GENERIC_PROP, -1, -1}, 
	{EntityType.ENTITY_FROZEN_ENEMY, -1, -1}, 
	{EntityType.ENTITY_SIREN_HELPER, -1, -1}, 
	{mod.FF.ThrallCord.ID, mod.FF.ThrallCord.Var, mod.FF.ThrallCord.Sub}, 
	{mod.FF.HarletwinCord.ID, mod.FF.HarletwinCord.Var, mod.FF.HarletwinCord.Sub}, 
	{mod.FF.EffigyCord.ID, mod.FF.EffigyCord.Var, mod.FF.EffigyCord.Sub}, 

	{mod.FF.Lurker.ID, mod.FF.Lurker.Var, -1},
	{mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var, -1},
	{mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth.Var, -1},
	{mod.FF.LurkerStoma.ID, mod.FF.LurkerStoma.Var, -1},
	{mod.FF.LurkerStretch.ID, mod.FF.LurkerStretch.Var, -1},
	{mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, -1},
	{mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, -1},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, -1},
	{mod.FF.LurkerPsuedoDefault.ID, mod.FF.LurkerPsuedoDefault.Var, -1},
	{mod.FF.LurkerBridgeProj.ID, mod.FF.LurkerBridgeProj.Var, -1},
}

FiendFolio.MothmanBlacklist = {
	{EntityType.ENTITY_FIREPLACE, -1, -1},
	{EntityType.ENTITY_MOVABLE_TNT, -1, -1},
	{EntityType.ENTITY_EVIS, 10, -1}, --Evis Cords
	{EntityType.ENTITY_BLOOD_PUPPY, -1, -1}, 
	{EntityType.ENTITY_DARK_ESAU, -1, -1}, 
	{EntityType.ENTITY_GENERIC_PROP, -1, -1}, 
	{EntityType.ENTITY_FROZEN_ENEMY, -1, -1}, 
	{EntityType.ENTITY_SIREN_HELPER, -1, -1}, 
	{mod.FFID.Tech, -1, -1}, --FF Technical Entities
	{mod.FF.FerrWaiting.ID, mod.FF.FerrWaiting.Var, -1}, --Ferrium Waiting Entities
	{mod.FF.ThrallCord.ID, mod.FF.ThrallCord.Var, mod.FF.ThrallCord.Sub}, 
	{mod.FF.HarletwinCord.ID, mod.FF.HarletwinCord.Var, mod.FF.HarletwinCord.Sub}, 
	{mod.FF.EffigyCord.ID, mod.FF.EffigyCord.Var, mod.FF.EffigyCord.Sub}, 

	{mod.FF.Lurker.ID, mod.FF.Lurker.Var, -1},
	{mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var, -1},
	{mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth.Var, -1},
	{mod.FF.LurkerStoma.ID, mod.FF.LurkerStoma.Var, -1},
	{mod.FF.LurkerStretch.ID, mod.FF.LurkerStretch.Var, -1},
	{mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, -1},
	{mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, -1},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, -1},
	{mod.FF.LurkerPsuedoDefault.ID, mod.FF.LurkerPsuedoDefault.Var, -1},
	{mod.FF.LurkerBridgeProj.ID, mod.FF.LurkerBridgeProj.Var, -1},
}

FiendFolio.GrimoireBlacklist = {
	{EntityType.ENTITY_FIREPLACE, -1, -1},
	{EntityType.ENTITY_MOVABLE_TNT, -1, -1},
	{EntityType.ENTITY_STONEHEAD, -1, -1}, --Grimaces
	{EntityType.ENTITY_CONSTANT_STONE_SHOOTER, -1, -1},
	{EntityType.ENTITY_BRIMSTONE_HEAD, -1, -1}, 
	{EntityType.ENTITY_GAPING_MAW, -1, -1}, 
	{EntityType.ENTITY_BROKEN_GAPING_MAW, -1, -1}, 
	{EntityType.ENTITY_GRUDGE, -1, -1}, 
	{EntityType.ENTITY_POKY, -1, -1}, 
	{EntityType.ENTITY_WALL_HUGGER, -1, -1}, --Also includes Banshee
	{EntityType.ENTITY_BALL_AND_CHAIN, -1, -1}, 
	{EntityType.ENTITY_EVIS, 10, -1}, --Evis Cords
	{EntityType.ENTITY_BLOOD_PUPPY, -1, -1}, 
	{EntityType.ENTITY_DARK_ESAU, -1, -1}, 
	{EntityType.ENTITY_GENERIC_PROP, -1, -1}, 
	{EntityType.ENTITY_FROZEN_ENEMY, -1, -1}, 
	{EntityType.ENTITY_SIREN_HELPER, -1, -1}, 
	{mod.FFID.Tech, -1, -1}, --FF Technical Entities
	{mod.FF.SuperGrimace.ID, mod.FF.SuperGrimace.Var, -1}, 
	{mod.FF.GlassEye.ID, mod.FF.GlassEye.Var, -1}, 
	{mod.FF.EyeOfShaggoth.ID, mod.FF.EyeOfShaggoth.Var, -1}, 
	{mod.FF.Temper.ID, mod.FF.Temper.Var, -1}, 
	{mod.FF.Congression.ID, mod.FF.Congression.Var, -1}, 
	{mod.FF.Spook.ID, mod.FF.Spook.Var, -1}, 
	{mod.FF.FerrWaiting.ID, mod.FF.FerrWaiting.Var, -1}, --Ferrium Waiting Entities
	{mod.FF.ThrallCord.ID, mod.FF.ThrallCord.Var, mod.FF.ThrallCord.Sub}, 
	{mod.FF.HarletwinCord.ID, mod.FF.HarletwinCord.Var, mod.FF.HarletwinCord.Sub}, 
	{mod.FF.EffigyCord.ID, mod.FF.EffigyCord.Var, mod.FF.EffigyCord.Sub}, 

	{mod.FF.Lurker.ID, mod.FF.Lurker.Var, -1},
	{mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var, -1},
	{mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth.Var, -1},
	{mod.FF.LurkerStoma.ID, mod.FF.LurkerStoma.Var, -1},
	{mod.FF.LurkerStretch.ID, mod.FF.LurkerStretch.Var, -1},
	{mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, -1},
	{mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, -1},
	{mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, -1},
	{mod.FF.LurkerPsuedoDefault.ID, mod.FF.LurkerPsuedoDefault.Var, -1},
	{mod.FF.LurkerBridgeProj.ID, mod.FF.LurkerBridgeProj.Var, -1},
}

FiendFolio.GrimoireLowPriority = {
	{EntityType.ENTITY_SHOPKEEPER, -1, -1},
	{mod.FF.EternalFlickerspirit.ID, mod.FF.EternalFlickerspirit.Var, -1},
	{mod.FF.Tombit.ID, mod.FF.Tombit.Var, -1},
}

FiendFolio.NihilistSlowdownList = {
	{mod.FF.Shaker.ID, mod.FF.Shaker.Var, -1, 6},
	{mod.FF.Banshee.ID, mod.FF.Banshee.Var, -1, 6},
	{mod.FF.Ragurge.ID, mod.FF.Ragurge.Var, -1, 6},
	{EntityType.ENTITY_REVENANT, -1, -1, 6},
}

FiendFolio.SkulltistWhitelist = {
	{mod.FF.Splodum.ID,mod.FF.Splodum.Var,-1,false}, 
	{EntityType.ENTITY_GLOBIN,-1,-1,true,true},
	{EntityType.ENTITY_BOOMFLY,-1,-1,true,true}, 
	{EntityType.ENTITY_SUCKER,2,-1,true}, --Soul Sucker
	{EntityType.ENTITY_SUCKER,-1,-1,false}, 
	{mod.FF.Empath.ID, mod.FF.Empath.Var,-1,true}, 
	{mod.FF.ManicFly.ID, mod.FF.ManicFly.Var,-1}, 
	{mod.FF.Gravin.ID, mod.FF.Gravin.Var,-1,false}, 
	{EntityType.ENTITY_FULL_FLY,-1,-1,false}, 
	{EntityType.ENTITY_BLACK_BONY,-1,-1,false,true},
	{EntityType.ENTITY_POOFER,-1,-1,true}, 
	{EntityType.ENTITY_MIGRAINE,-1,-1,true,true},
	{EntityType.ENTITY_DUKE,-1,-1,true}, 
	{mod.FF.Facade.ID,mod.FF.Facade.Var,-1,true},
	{EntityType.ENTITY_MULLIGAN,-1,-1,true,true},
	{EntityType.ENTITY_NEST,-1,-1,true,true},
	{EntityType.ENTITY_HIVE,-1,-1,true,true},
	{EntityType.ENTITY_PREY,-1,-1,true,true},
	{EntityType.ENTITY_MEMBRAIN,-1,-1,true,true},
	{mod.FF.Cellulitis.ID,mod.FF.Cellulitis.Var,-1,-1,true,false},
	{EntityType.ENTITY_SQUIRT,-1,-1,true,true},
	{mod.FF.Scoop.ID,mod.FF.Scoop.Var,-1,true},
	{mod.FF.Sundae.ID,mod.FF.Sundae.Var,-1,true},
	{mod.FF.SoftServe.ID,mod.FF.SoftServe.Var,-1,true},
	{mod.FF.ReheatedTickingFly.ID,mod.FF.ReheatedTickingFly.Var,-1,false},
	{mod.FF.FullSpider.ID,mod.FF.FullSpider.Var,-1,false},
	{EntityType.ENTITY_TICKING_SPIDER,-1,-1,false,true},
	{mod.FF.Haunted.ID,mod.FF.Haunted.Var,-1,true},
	{mod.FF.Crotchety.ID,mod.FF.Crotchety.Var,-1,true},
	{mod.FF.Posssessed.ID,mod.FF.Posssessed.Var,-1,true},
	{mod.FF.Tagbag.ID,mod.FF.Tagbag.Var,-1,true},
	{mod.FF.FossilBoomFly.ID,mod.FF.FossilBoomFly.Var,-1,false},
	{mod.FF.Gunk.ID,mod.FF.Gunk.Var,-1,false},
	{mod.FF.Punk.ID,mod.FF.Punk.Var,-1,false},
	{mod.FF.Dogmeat.ID,mod.FF.Dogmeat.Var,-1,true},
	{mod.FF.HeadHoncho.ID,mod.FF.HeadHoncho.Var,-1,true},
	{mod.FF.Carrier.ID,mod.FF.Carrier.Var,-1,true},
	{mod.FF.MiniMinMin.ID,mod.FF.MiniMinMin.Var,-1,true},
	{mod.FF.Blastcore.ID,mod.FF.Blastcore.Var,-1,true},
	{mod.FF.Baro.ID,mod.FF.Baro.Var,-1,true},
	{mod.FF.MamaPooter.ID,mod.FF.MamaPooter.Var,-1,true},
	{mod.FF.BubbleBat.ID,mod.FF.BubbleBat.Var,-1,false},
	{mod.FF.Melty.ID,mod.FF.Melty.Var,-1,true},
	{mod.FF.Coconut.ID,mod.FF.Coconut.Var,-1,true},
	{mod.FF.Coby.ID,mod.FF.Coby.Var,-1,false},
	{mod.FF.DreadMaw.ID,mod.FF.DreadMaw.Var,-1,true},
	{EntityType.ENTITY_MAW,1,-1,false,true}, --Red Maw
	{mod.FF.Rufus.ID,mod.FF.Rufus.Var,-1,true},
}

mod.GridLikeEntities = {
	[mod.FF.BucketheadWait.ID.." "..mod.FF.BucketheadWait.Var.." "..mod.FF.BucketheadWait.Sub] = true,
	[mod.FF.CompostBin.ID.." "..mod.FF.CompostBin.Var.." "..-1] = true,
	[mod.FF.SuperTNT.ID.." "..mod.FF.SuperTNT.Var.." "..-1] = true,
	[mod.FF.ClogmoPipe.ID.." "..mod.FF.ClogmoPipe.Var.." "..-1] = true,
	[mod.FF.ClogmoTunnelHori.ID.." "..mod.FF.ClogmoTunnelHori.Var.." "..-1] = true,
	[mod.FF.ClogmoTunnelVerti.ID.." "..mod.FF.ClogmoTunnelVerti.Var.." "..-1] = true,
}

mod.TomaEnemies = {
	{mod.FF.Foetus.ID, mod.FF.Foetus.Var, -1},
	{mod.FF.ConglobberateSmall.ID, mod.FF.ConglobberateSmall.Var, -1},
	{mod.FF.ConglobberateMedium.ID, mod.FF.ConglobberateMedium.Var, -1},
	{mod.FF.ConglobberateLarge.ID, mod.FF.ConglobberateLarge.Var, -1},
	{mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, -1},
	{mod.FF.Bub.ID, mod.FF.Bub.Var, -1},
	{mod.FF.Molly.ID, mod.FF.Molly.Var, -1},
	{mod.FF.Steralis.ID, mod.FF.Steralis.Var, -1},
	{mod.FF.Nematode.ID, mod.FF.Nematode.Var, -1},
	{mod.FF.Quitter.ID, mod.FF.Quitter.Var, -1},
}

----FERRIUM ENTITY LISTS----

mod.lunksackBlacklist = {
	[mod.FF.Cuffs.ID .. " " .. mod.FF.Cuffs.Var] = true, -- Cuffs
	[13 .. " " .. 0 .. " " .. 250] = true,      --Soundmaker Fly
	[35 .. " " .. 10] = true,		--Mr. Maw Neck
	[79 .. " " .. 20] = true,		--Gemini Cord
	[96] = true,			--Eternal Fly
	[216 .. " " .. 10] = true,		--Swinger Neck
	[EntityType.ENTITY_FROZEN_ENEMY] = true, --Uranus Frozen Enemy
	[mod.FF.Gorger.ID .. " " .. mod.FF.Gorger.Var .. " " .. mod.FF.GorgerAss.Sub] = true,	--Gorger ass
	[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,		--Eternal Flickerspirit
	[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,      -- Viscerspirit
	[mod.FF.DeadFlyOrbital.ID .. " " .. mod.FF.DeadFlyOrbital.Var] = true,		--Eternal Fly reimplementation
	[mod.FF.Harletwin.ID .. " " .. mod.FF.Harletwin.Var .. " " .. 1] = true,		--Harletwin Ball
	[mod.FF.Effigy.ID .. " " .. mod.FF.Effigy.Var .. " " .. 1] = true,		--Effigy Ball
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaHead.Sub] = true,	--Bola Skull
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaNeck.Sub] = true,	--Bola Neck
	[mod.FF.FingoreHand.ID .. " " .. mod.FF.FingoreHand.Var] = true,	--Fingore Hand
	[mod.FF.WarbleTail.ID .. " " .. mod.FF.WarbleTail.Var .. " " .. mod.FF.WarbleTail.Sub] = true,	--Warble Tail
	[mod.FF.RiftWalkerGfx.ID .. " " .. mod.FF.RiftWalkerGfx.Var .. " " .. mod.FF.RiftWalkerGfx.Sub] = true,	--Rift Walker (gfx)
	[mod.FF.ThrallCord.ID .. " " .. mod.FF.ThrallCord.Var .. " " .. mod.FF.ThrallCord.Sub] = true,	--Thrall Chain
	[mod.FF.Gravefire.ID .. " " .. mod.FF.Gravefire.Var] = true,	--Gravefire
	[mod.FF.Specturn.ID .. " " .. mod.FF.Specturn.Var] = true,	-- Specturn
	[33] = true,	--Fireplaces
	[42] = true,	--Grimaces
	[mod.FF.FerrWaiting.ID .. " " .. mod.FF.FerrWaiting.Var] = true,	--Ferrium's waiting enemies
	[mod.FF.ShirkSpot.ID .. " " .. mod.FF.ShirkSpot.Var] = true,	--Shirk Spots
	[mod.FF.DungeonLocker.ID .. " " .. mod.FF.DungeonLocker.Var] = true, -- Dungeon Locker
	[mod.FF.KeyFiend.ID .. " " .. mod.FF.KeyFiend.Var] = true,	--Key Fiend
	[44] = true, --Pokies/variants (Includes pipes, grates, and etc)
	[mod.FF.Onlooker.ID .. " " .. mod.FF.Onlooker.Var] = true,	--Onlooker
	[mod.FF.FoetusCord.ID .. " " .. mod.FF.FoetusCord.Var .. " " .. mod.FF.FoetusCord.Sub] = true, --Foetus Cord
	[mod.FF.ThrallCord.ID .. " " .. mod.FF.ThrallCord.Var .. " " .. mod.FF.ThrallCord.Sub] = true,	--Thrall Cord
	[mod.FF.Pawn.ID .. " " .. mod.FF.Pawn.Var .. " " .. 10] = true, --King Cord Hitbox
	[mod.FF.MorvidPerched.ID .. " " .. mod.FF.MorvidPerched.Var .. " " .. mod.FF.MorvidPerched.Sub] = true, --Perched Morvids
	[FiendFolio.FFID.Tech] = true,	--Technical Entities, sorry Bubble fans
	[EntityType.ENTITY_EVIS .. " " .. 10] = true, --Evis Guts / other cords
	[mod.FF.PatzerShell.ID .. " " .. mod.FF.PatzerShell.Var] = true, --Patzer Shell
	[mod.FF.GlassEye.ID .. " " .. mod.FF.GlassEye.Var] = true, --Glass Eye
	[mod.FF.EyeOfShaggoth.ID .. " " .. mod.FF.EyeOfShaggoth.Var] = true, --Eye of Shaggoth
	[mod.FF.Lurker.ID .. " " .. mod.FF.Lurker.Var] = true,
	[mod.FF.LurkerCore.ID .. " " .. mod.FF.LurkerCore.Var] = true,
	[mod.FF.LurkerStoma.ID .. " " .. mod.FF.LurkerStoma.Var] = true,
	[mod.FF.LurkerStretch.ID .. " " .. mod.FF.LurkerStretch.Var] = true,
	[mod.FF.LurkerTooth.ID .. " " .. mod.FF.LurkerTooth.Var] = true,
	[mod.FF.LurkerBrain.ID .. " " .. mod.FF.LurkerBrain.Var] = true,
	[mod.FF.LurkerCollider.ID .. " " .. mod.FF.LurkerCollider.Var] = true,
	[mod.FF.LurkerStretchCollider.ID .. " " .. mod.FF.LurkerStretchCollider.Var] = true,
	[mod.FF.LurkerPsuedoDefault.ID .. " " .. mod.FF.LurkerPsuedoDefault.Var] = true,
	[mod.FF.LurkerBridgeProj.ID .. " " .. mod.FF.LurkerBridgeProj.Var] = true,
}

--What can't be selected to orbit.
mod.specturnBlacklist = {
	[mod.FF.Cuffs.ID .. " " .. mod.FF.Cuffs.Var] = true, -- Cuffs
	[13 .. " " .. 0 .. " " .. 250] = true,      --Soundmaker Fly
	[35 .. " " .. 1] = true,		--Mr. Maw Head
	[35 .. " " .. 1] = true,		--Mr. Maw Head
	[35 .. " " .. 3] = true,		--Mr. Red Maw Head
	[35 .. " " .. 10] = true,		--Mr. Maw Neck
	[79 .. " " .. 20] = true,		--Gemini Cord
	[96] = true,			--Eternal Fly
	[216 .. " " .. 1] = true,		--Swinger Head
	[216 .. " " .. 10] = true,		--Swinger Neck
	[EntityType.ENTITY_FROZEN_ENEMY] = true, --Uranus Frozen Enemy
	[mod.FF.Gorger.ID .. " " .. mod.FF.Gorger.Var .. " " .. mod.FF.GorgerAss.Sub] = true,	--Gorger ass
	[mod.FF.Cortex.ID .. " " .. mod.FF.Cortex.Var] = true,		--Cortex
	[mod.FF.PsiKnight.ID .. " " .. mod.FF.PsiKnight.Var] = true,	--Psionic Knights
	[mod.FF.ToxicKnight.ID .. " " .. mod.FF.ToxicKnight.Var .. " " .. 0] = true,	--Toxic Knight Husk
	[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,		--Eternal Flickerspirit
	[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,      -- Viscerspirit
	[mod.FF.DeadFlyOrbital.ID .. " " .. mod.FF.DeadFlyOrbital.Var] = true,		--Eternal Fly reimplementation
	[mod.FF.Harletwin.ID .. " " .. mod.FF.Harletwin.Var .. " " .. 1] = true,		--Harletwin Ball
	[mod.FF.Effigy.ID .. " " .. mod.FF.Effigy.Var .. " " .. 1] = true,		--Effigy Ball
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaHead.Sub] = true,	--Bola Skull
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaNeck.Sub] = true,	--Bola Neck
	[mod.FF.FingoreHand.ID .. " " .. mod.FF.FingoreHand.Var] = true,	--Fingore Hand
	[811] = true,	--Deep Gaper
	[mod.FF.WarbleTail.ID .. " " .. mod.FF.WarbleTail.Var .. " " .. mod.FF.WarbleTail.Sub] = true,	--Warble Tail
	[mod.FF.RiftWalkerGfx.ID .. " " .. mod.FF.RiftWalkerGfx.Var .. " " .. mod.FF.RiftWalkerGfx.Sub] = true,	--Rift Walker (gfx)
	[mod.FF.ThrallCord.ID .. " " .. mod.FF.ThrallCord.Var .. " " .. mod.FF.ThrallCord.Sub] = true,	--Thrall Chain
	[mod.FF.Gravefire.ID .. " " .. mod.FF.Gravefire.Var] = true,	--Gravefire
	[mod.FF.Specturn.ID .. " " .. mod.FF.Specturn.Var] = true,	-- Specturn
	[33] = true,	--Fireplaces
	[42] = true,	--Grimaces
	[mod.FF.FerrWaiting.ID .. " " .. mod.FF.FerrWaiting.Var] = true,	--Ferrium's waiting enemies
	[mod.FF.ShirkSpot.ID .. " " .. mod.FF.ShirkSpot.Var] = true,	--Shirk Spots
	[mod.FF.Shirk.ID .. " " .. mod.FF.Shirk.Var] = true,	--Shirks
	[mod.FF.DungeonLocker.ID .. " " .. mod.FF.DungeonLocker.Var] = true, -- Dungeon Locker
	[mod.FF.KeyFiend.ID .. " " .. mod.FF.KeyFiend.Var] = true,	--Key Fiend
	[17] = true,	--Shopkeepers
	[mod.FF.Sternum.ID .. " " .. mod.FF.Sternum.Var] = true, --Sternum
	[mod.FF.Splodum.ID .. " " .. mod.FF.Splodum.Var] = true, --Splodum
	[EntityType.ENTITY_BOIL] = true, --Vanilla stuff that sets its position constantly.
	[EntityType.ENTITY_TARBOY] = true,
	[EntityType.ENTITY_FRED] = true,
	[EntityType.ENTITY_EYE] = true,
	[EntityType.ENTITY_COD_WORM] = true,
	[EntityType.ENTITY_NERVE_ENDING] = true,
	[EntityType.ENTITY_GRUB] = true,
	[EntityType.ENTITY_WALL_CREEP] = true,
	[EntityType.ENTITY_BLIND_CREEP] = true,
	[EntityType.ENTITY_RAGE_CREEP] = true,
	[EntityType.ENTITY_THE_THING] = true,
	[EntityType.ENTITY_ROUND_WORM] = true,
	[EntityType.ENTITY_ROUNDY] = true,
	[EntityType.ENTITY_ULCER] = true,
	[EntityType.ENTITY_NIGHT_CRAWLER] = true,
	[EntityType.ENTITY_MUSHROOM] = true,
	[EntityType.ENTITY_PORTAL] = true,
	[EntityType.ENTITY_LARRYJR] = true,
	[EntityType.ENTITY_MEGA_MAW] = true,
	[EntityType.ENTITY_BIG_HORN] = true,
	[EntityType.ENTITY_STAIN] = true,
	[EntityType.ENTITY_CHUB] = true,
	[EntityType.ENTITY_GURDY] = true,
	[EntityType.ENTITY_POLYCEPHALUS] = true,
	[EntityType.ENTITY_GATE] = true,
	[EntityType.ENTITY_MOM] = true,
	[EntityType.ENTITY_MOMS_HEART] = true,
	[EntityType.ENTITY_DADDYLONGLEGS] = true,
	[EntityType.ENTITY_MAMA_GURDY] = true,
	[EntityType.ENTITY_MR_FRED] = true,
	[EntityType.ENTITY_HUSH] = true,
	[EntityType.ENTITY_SATAN] = true,
	[EntityType.ENTITY_ISAAC] = true,
	[EntityType.ENTITY_THE_LAMB] = true,
	[260 .. " " .. 0] = true, --The Haunt
	[38 .. " " .. 3] = true, --Wrinkly Babies
	[40] = true, --Guts
	[44] = true, --Pokies/variants (Includes pipes, grates, and etc)
	[52] = true, --Doples
	[56] = true, --Lumps
	[35] = true, --Mr. Maws
	[mod.FF.Unshornz.ID .. " " .. mod.FF.Unshornz.Var] = true,	--Unshornz
	[mod.FF.Onlooker.ID .. " " .. mod.FF.Onlooker.Var] = true,	--Onlooker
	[mod.FF.FoetusCord.ID .. " " .. mod.FF.FoetusCord.Var .. " " .. mod.FF.FoetusCord.Sub] = true, --Foetus Cord
	[mod.FF.ThrallCord.ID .. " " .. mod.FF.ThrallCord.Var .. " " .. mod.FF.ThrallCord.Sub] = true,	--Thrall Cord
	[mod.FF.Pawn.ID .. " " .. mod.FF.Pawn.Var .. " " .. 10] = true, --King Cord Hitbox
	[mod.FF.MorvidPerched.ID .. " " .. mod.FF.MorvidPerched.Var .. " " .. mod.FF.MorvidPerched.Sub] = true, --Perched Morvids
	[FiendFolio.FFID.Tech] = true,	--Technical Entities, sorry Bubble fans
	[EntityType.ENTITY_EVIS .. " " .. 10] = true, --Evis Guts / other cords
	[mod.FF.Lurker.ID .. " " .. mod.FF.Lurker.Var] = true,
	[mod.FF.LurkerCore.ID .. " " .. mod.FF.LurkerCore.Var] = true,
	[mod.FF.LurkerStoma.ID .. " " .. mod.FF.LurkerStoma.Var] = true,
	[mod.FF.LurkerStretch.ID .. " " .. mod.FF.LurkerStretch.Var] = true,
	[mod.FF.LurkerTooth.ID .. " " .. mod.FF.LurkerTooth.Var] = true,
	[mod.FF.LurkerBrain.ID .. " " .. mod.FF.LurkerBrain.Var] = true,
	[mod.FF.LurkerCollider.ID .. " " .. mod.FF.LurkerCollider.Var] = true,
	[mod.FF.LurkerStretchCollider.ID .. " " .. mod.FF.LurkerStretchCollider.Var] = true,
	[mod.FF.LurkerPsuedoDefault.ID .. " " .. mod.FF.LurkerPsuedoDefault.Var] = true,
	[mod.FF.LurkerBridgeProj.ID .. " " .. mod.FF.LurkerBridgeProj.Var] = true,
}

--What can't be selected as a Specturn Host.
mod.specturnBlacklist2 = {
	[mod.FF.Cuffs.ID .. " " .. mod.FF.Cuffs.Var] = true, -- Cuffs
	[13 .. " " .. 0 .. " " .. 250] = true,      --Soundmaker Fly
	[35 .. " " .. 10] = true,		--Mr. Maw Neck
	[79 .. " " .. 20] = true,		--Gemini Cord
	[96] = true,			--Eternal Fly
	[216 .. " " .. 10] = true,		--Swinger Neck
	[409 .. " " .. 1] = true,		--Rag Mega's Balls
	[EntityType.ENTITY_FROZEN_ENEMY] = true, --Uranus Frozen Enemy
	[mod.FF.Gorger.ID .. " " .. mod.FF.Gorger.Var .. " " .. mod.FF.GorgerAss.Sub] = true,	--Gorger ass
	[mod.FF.Cortex.ID .. " " .. mod.FF.Cortex.Var] = true,		--Cortex
	[mod.FF.PsiKnight.ID .. " " .. mod.FF.PsiKnight.Var .. " " .. 0] = true,	--Psionic Knight Husk
	[mod.FF.ToxicKnight.ID .. " " .. mod.FF.ToxicKnight.Var .. " " .. 0] = true,	--Toxic Knight Husk
	[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,		--Eternal Flickerspirit
	[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,      -- Viscerspirit
	[mod.FF.DeadFlyOrbital.ID .. " " .. mod.FF.DeadFlyOrbital.Var] = true,		--Eternal Fly reimplementation
	[mod.FF.Harletwin.ID .. " " .. mod.FF.Harletwin.Var .. " " .. 1] = true,		--Harletwin Ball
	[mod.FF.Effigy.ID .. " " .. mod.FF.Effigy.Var .. " " .. 1] = true,		--Effigy Ball
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaHead.Sub] = true,	--Bola Skull
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaNeck.Sub] = true,	--Bola Neck
	[mod.FF.FingoreHand.ID .. " " .. mod.FF.FingoreHand.Var] = true,	--Fingore Hand
	[mod.FF.KeyFiend.ID .. " " .. mod.FF.KeyFiend.Var] = true,	--Key Fiend
	[mod.FF.DungeonLocker.ID .. " " .. mod.FF.DungeonLocker.Var] = true, -- Dungeon Locker
	[811] = true,	--Deep Gaper
	[mod.FF.WarbleTail.ID .. " " .. mod.FF.WarbleTail.Var .. " " .. mod.FF.WarbleTail.Sub] = true,	--Warble Tail
	[mod.FF.RiftWalkerGfx.ID .. " " .. mod.FF.RiftWalkerGfx.Var .. " " .. mod.FF.RiftWalkerGfx.Sub] = true,	--Rift Walker (gfx)
	[mod.FF.ThrallCord.ID .. " " .. mod.FF.ThrallCord.Var .. " " .. mod.FF.ThrallCord.Sub] = true,	--Thrall Chain
	[mod.FF.Gravefire.ID .. " " .. mod.FF.Gravefire.Var] = true,	--Gravefire
	[mod.FF.Specturn.ID .. " " .. mod.FF.Specturn.Var] = true,	-- Specturn
	[mod.FF.FerrWaiting.ID .. " " .. mod.FF.FerrWaiting.Var] = true,	--Ferrium's waiting enemies
	[mod.FF.Lurker.ID .. " " .. mod.FF.Lurker.Var] = true,
	[mod.FF.LurkerStretch.ID .. " " .. mod.FF.LurkerStretch.Var] = true,
	[mod.FF.LurkerBrain.ID .. " " .. mod.FF.LurkerBrain.Var] = true,
	[mod.FF.LurkerCollider.ID .. " " .. mod.FF.LurkerCollider.Var] = true,
	[mod.FF.LurkerStretchCollider.ID .. " " .. mod.FF.LurkerStretchCollider.Var] = true,
	[mod.FF.LurkerBridgeProj.ID .. " " .. mod.FF.LurkerBridgeProj.Var] = true,
}



----TAIGA ENTITY LISTS----

-- Prevents enemies from being connected to by Cuffs
mod.CuffsBlacklist = {
	[mod.FF.Cuffs.ID .. " " .. mod.FF.Cuffs.Var] = true, -- Cuffs
	[13 .. " " .. 0 .. " " .. 250] = true,      --Soundmaker Fly
	[35 .. " " .. 1] = true,		--Mr. Maw Head
	[35 .. " " .. 1] = true,		--Mr. Maw Head
	[35 .. " " .. 3] = true,		--Mr. Red Maw Head
	[35 .. " " .. 10] = true,		--Mr. Maw Neck
	[79 .. " " .. 20] = true,		--Gemini Cord
	[96] = true,			--Eternal Fly
	[216 .. " " .. 1] = true,		--Swinger Head
	[216 .. " " .. 10] = true,		--Swinger Neck
	[409 .. " " .. 1] = true,		--Rag Mega's Balls
	[805] = true,					--Bishops
	[EntityType.ENTITY_FROZEN_ENEMY] = true, --Uranus Frozen Enemy
	[mod.FF.Gorger.ID .. " " .. mod.FF.Gorger.Var .. " " .. mod.FF.GorgerAss.Sub] = true,	--Gorger ass
	[mod.FF.Cortex.ID .. " " .. mod.FF.Cortex.Var] = true,		--Cortex
	[mod.FF.PsiKnight.ID .. " " .. mod.FF.PsiKnight.Var .. " " .. 0] = true,	--Psionic Knight Husk
	[mod.FF.ToxicKnight.ID .. " " .. mod.FF.ToxicKnight.Var .. " " .. 0] = true,	--Toxic Knight Husk
	[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,		--Eternal Flickerspirit
	[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,      -- Viscerspirit
	[mod.FF.DeadFlyOrbital.ID .. " " .. mod.FF.DeadFlyOrbital.Var] = true,		--Eternal Fly reimplementation
	[mod.FF.Harletwin.ID .. " " .. mod.FF.Harletwin.Var .. " " .. 1] = true,		--Harletwin Ball
	[mod.FF.Effigy.ID .. " " .. mod.FF.Effigy.Var .. " " .. 1] = true,		--Effigy Ball
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaHead.Sub] = true,	--Bola Skull
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaNeck.Sub] = true,	--Bola Neck
	[mod.FF.FingoreHand.ID .. " " .. mod.FF.FingoreHand.Var] = true,	--Fingore Hand
	[mod.FF.KeyFiend.ID .. " " .. mod.FF.KeyFiend.Var] = true,	--Key Fiend
	[mod.FF.DungeonLocker.ID .. " " .. mod.FF.DungeonLocker.Var] = true, -- Dungeon Locker
	[811] = true,	--Deep Gaper
	[mod.FF.WarbleTail.ID .. " " .. mod.FF.WarbleTail.Var .. " " .. mod.FF.WarbleTail.Sub] = true,	--Warble Tail
	[mod.FF.RiftWalkerGfx.ID .. " " .. mod.FF.RiftWalkerGfx.Var .. " " .. mod.FF.RiftWalkerGfx.Sub] = true,	--Rift Walker (gfx)
	[mod.FF.ThrallCord.ID .. " " .. mod.FF.ThrallCord.Var .. " " .. mod.FF.ThrallCord.Sub] = true,	--Thrall Chain
	[mod.FF.Gravefire.ID .. " " .. mod.FF.Gravefire.Var] = true,	--Gravefire
	[mod.FF.Specturn.ID .. " " .. mod.FF.Specturn.Var] = true,	-- Specturn
	[mod.FF.FerrWaiting.ID .. " " .. mod.FF.FerrWaiting.Var] = true,	--Ferrium's waiting enemies
	[mod.FF.Cherubskull.ID .. " " .. mod.FF.Cherubskull.Var] = true,	--Cherubskull (so that it connects to the Hand, neat interaction)
	[EntityType.ENTITY_DARK_ESAU] = true,	--Dark Esau
	[EntityType.ENTITY_BLOOD_PUPPY] = true,	--Blood Puppy
}

-- Prevents Empath from responding to the deaths of these enemies
mod.EmpathBlacklist = {
	[mod.FF.Cuffs.ID .. " " .. mod.FF.Cuffs.Var] = true, -- Cuffs
	[EntityType.ENTITY_SWINGER .. " " .. 10] = true,		--Swinger Neck
	[EntityType.ENTITY_FROZEN_ENEMY] = true, --Uranus Frozen Enemy
	[mod.FF.Gorger.ID .. " " .. mod.FF.Gorger.Var .. " " .. mod.FF.GorgerAss.Sub] = true,	--Gorger ass
	[mod.FF.Cortex.ID .. " " .. mod.FF.Cortex.Var] = true,		--Cortex
	[mod.FF.PsiKnight.ID .. " " .. mod.FF.PsiKnight.Var .. " " .. 0] = true,	--Psionic Knight Husk
	[mod.FF.ToxicKnight.ID .. " " .. mod.FF.ToxicKnight.Var .. " " .. 0] = true,	--Toxic Knight Husk
	[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,		--Eternal Flickerspirit
	[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,      -- Viscerspirit
	[mod.FF.Harletwin.ID .. " " .. mod.FF.Harletwin.Var .. " " .. 1] = true,		--Harletwin Ball
	[mod.FF.Effigy.ID .. " " .. mod.FF.Effigy.Var .. " " .. 1] = true,		--Effigy Ball
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaHead.Sub] = true,	--Bola Skull
	[mod.FF.Bola.ID .. " " .. mod.FF.Bola.Var .. " " .. mod.FF.BolaNeck.Sub] = true,	--Bola Neck
	[mod.FF.FingoreHand.ID .. " " .. mod.FF.FingoreHand.Var] = true,	--Fingore Hand
	[EntityType.ENTITY_MOVABLE_TNT] = true,	--Movable TNT
	[EntityType.ENTITY_FIREPLACE] = true,	--Fireplace
	[EntityType.ENTITY_STONEHEAD] = true, -- Grimace
	[EntityType.ENTITY_POKY] = true, -- Poky
	[EntityType.ENTITY_STONE_EYE] = true, -- Stone Eye
	[EntityType.ENTITY_CONSTANT_STONE_SHOOTER] = true, -- Constant Stone Shooter
	[EntityType.ENTITY_BRIMSTONE_HEAD] = true, -- Brimstone Head
	[EntityType.ENTITY_WALL_HUGGER] = true, -- Wall Hugger
	[EntityType.ENTITY_QUAKE_GRIMACE] = true, -- Quake Grimace
	[EntityType.ENTITY_BOMB_GRIMACE] = true, -- Bomb Grimace
	[EntityType.ENTITY_GRUDGE] = true, -- Grudge
	[EntityType.ENTITY_BOMBDROP] = true, -- Troll Bombs
}

-- Basegame grids that Foetus can connect to
mod.FoetusAttachableBasegameGrids = {
	[GridEntityType.GRID_ROCK] = true,
	[GridEntityType.GRID_ROCKB] = true,
	[GridEntityType.GRID_ROCKT] = true,
	[GridEntityType.GRID_ROCK_BOMB] = true,
	[GridEntityType.GRID_ROCK_ALT] = true,
	[GridEntityType.GRID_POOP] = true,
	[GridEntityType.GRID_WALL] = true,
	[GridEntityType.GRID_ROCK_SS] = true,
	[GridEntityType.GRID_PILLAR] = true,
	[GridEntityType.GRID_ROCK_SPIKED] = true,
	[GridEntityType.GRID_ROCK_ALT2] = true,
	[GridEntityType.GRID_ROCK_GOLD] = true,
}

-- StageAPI custom grids that Foetus can connect to (by gridconfig name)
mod.FoetusAttachableCustomGrids = {
	["FFShampoo"] = true,
	["FFBeehive"] = true,
	["FFCursedPoop"] = true,
	["FFPetrifiedPoop"] = true,
	["FFPlatinumPoop"] = true,
	["FFEvilPoop"] = true,
	["FFFlippedBucket"] = true,
	["FFSpiderNest"] = true,
	["FFDogDoo"] = true,
}

-- Blocks Onlooker lasers from passing through the hitboxes of these entities
-- "grid" : Treats the occupied grid as impassible
-- "entity" : Treats only the hitbox as impassible
FiendFolio.BlocksOnlookerLaser = {
	[42] = "grid", -- All Grimaces
	[44 .. " " .. 0] = "entity", -- Poky
	[44 .. " " .. 1] = "entity", -- Slide
	[201] = "grid", -- Stone Eyes
	[202] = "grid", -- Stone Shooters
	[203] = "grid", -- Brimstone Heads
	[218 .. " " .. 0] = "entity", -- Wall Hugger
	[235] = "grid", -- Gaping Maws
	[236] = "grid", -- Broken Gaping Maws
	[292 .. " " .. 0] = "entity", -- Movable TNT
	[292 .. " " .. 750] = "grid", -- Super TNT
	[292 .. " " .. 751] = "grid", -- Water TNT
	[292 .. " " .. 752] = "grid", -- Composters
	[302] = "entity", -- Stoney
	[804] = "grid", -- Quake Grimace
	[809] = "grid", -- Bomb Grimace
	[852] = "entity", -- Spikeball
	[877] = "entity", -- Grudge
	[FiendFolio.FF.AmnioticSac.ID .. " " .. FiendFolio.FF.AmnioticSac.Var] = "grid", -- Amniotic Sacs
	[FiendFolio.FF.StrikerHead.ID .. " " .. FiendFolio.FF.StrikerHead.Var] = "entity", -- Striker Ball
	[FiendFolio.FF.LurkerTooth.ID .. " " .. FiendFolio.FF.LurkerTooth.Var] = "grid", -- Lurker Tooth segment
	--[960 .. " " .. 740 .. " " .. 1] = "grid", -- Dead Immurals (has hardcoded behaviour to better match animation)
}

-- Entities that are damaged by Onlooker lasers whilst blocking
FiendFolio.BlockingEntityDamagedByOnlookerLaser = {
	[292 .. " " .. 752 .. " " .. 3] = true, -- Unstable Composters
	[FiendFolio.FF.AmnioticSac.ID .. " " .. FiendFolio.FF.AmnioticSac.Var] = true, -- Amniotic Sacs
}

-- Entities that are damaged by Onlooker lasers without blocking
FiendFolio.EntityDamagedByOnlookerLaser = {
	FiendFolio.ENT("SentryReg"), -- Sentry
}

-- Basegame grid entities that are damaged by Onlooker whilst blocking
FiendFolio.BlockingGridDamagedByOnlookerLaser = {
	-- And this is where I would put Red TNT... ;_;
}



----TAIGA ITEM LISTS----

-- Special wisps that can spawn from Page of Virtues
-- Regular Book of Virtues Wisps: 17% chance
-- Common Wisps: 33% chance
-- Uncommon Wisps: 45% chance
-- Rare Wisps: 5%
mod.PageOfVirtuesWisps = {
	["Common"] = {
		CollectibleType.COLLECTIBLE_AVGM,
		CollectibleType.COLLECTIBLE_BEAN,
		CollectibleType.COLLECTIBLE_BLACK_HOLE,
		CollectibleType.COLLECTIBLE_BLOOD_RIGHTS,
		CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
		CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS,
		CollectibleType.COLLECTIBLE_COMPOST,
		CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
		CollectibleType.COLLECTIBLE_DAMOCLES,
		CollectibleType.COLLECTIBLE_FLUSH,
		CollectibleType.COLLECTIBLE_IV_BAG,
		CollectibleType.COLLECTIBLE_KEEPERS_BOX,
		CollectibleType.COLLECTIBLE_KIDNEY_BEAN,
		CollectibleType.COLLECTIBLE_THE_NAIL,
		CollectibleType.COLLECTIBLE_RAZOR_BLADE,
		CollectibleType.COLLECTIBLE_SANGUINE_HOOK,
		CollectibleType.COLLECTIBLE_SCOOPER,
		CollectibleType.COLLECTIBLE_SHARP_KEY,
		CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER,
		CollectibleType.COLLECTIBLE_YUCK_HEART,
	},
	["Uncommon"] = {
		CollectibleType.COLLECTIBLE_BEST_FRIEND,
		CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
		CollectibleType.COLLECTIBLE_CRACK_THE_SKY,
		CollectibleType.COLLECTIBLE_FREE_LEMONADE,
		CollectibleType.COLLECTIBLE_GAMEKID,
		CollectibleType.COLLECTIBLE_GLASS_CANNON,
		CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,
		CollectibleType.COLLECTIBLE_LEMON_MISHAP,
		CollectibleType.COLLECTIBLE_MAGIC_SKIN,
		CollectibleType.COLLECTIBLE_MOMS_BRA,
		CollectibleType.COLLECTIBLE_MOMS_PAD,
		CollectibleType.COLLECTIBLE_MONSTER_MANUAL,
		CollectibleType.COLLECTIBLE_MONSTROS_TOOTH,
		CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN,
		CollectibleType.COLLECTIBLE_PINKING_SHEARS,
		CollectibleType.COLLECTIBLE_SCISSORS,
		CollectibleType.COLLECTIBLE_SPIDER_BUTT,
		CollectibleType.COLLECTIBLE_SPRINKLER,
		CollectibleType.COLLECTIBLE_TAMMYS_HEAD,
		CollectibleType.COLLECTIBLE_TELEPATHY_BOOK,
		CollectibleType.COLLECTIBLE_UNDEFINED,
		CollectibleType.COLLECTIBLE_URN_OF_SOULS,
	},
	["Rare"] = {
		CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK,
		CollectibleType.COLLECTIBLE_BEDTIME_STORY,
		CollectibleType.COLLECTIBLE_BIBLE,
		CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD,
		CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS,
		CollectibleType.COLLECTIBLE_GOLDEN_RAZOR,
		CollectibleType.COLLECTIBLE_GUPPYS_HEAD,
		CollectibleType.COLLECTIBLE_HOURGLASS, 
		CollectibleType.COLLECTIBLE_MEGA_BEAN,
		CollectibleType.COLLECTIBLE_MEGA_BLAST,
		CollectibleType.COLLECTIBLE_MR_BOOM,
		CollectibleType.COLLECTIBLE_NECRONOMICON,
		CollectibleType.COLLECTIBLE_PAUSE,
		CollectibleType.COLLECTIBLE_PONY,
		CollectibleType.COLLECTIBLE_PRAYER_CARD,
		CollectibleType.COLLECTIBLE_SULFUR,
		CollectibleType.COLLECTIBLE_TEAR_DETONATOR,
		CollectibleType.COLLECTIBLE_WHITE_PONY,
	},
}



----TAIGA STATUS LISTS----

-- Enemies that are blacklisted from basegame's Uranus Freezing status effect
FiendFolio.IceBlacklist = {
	[FiendFolio.FF.BabySpider.ID .. " " .. FiendFolio.FF.BabySpider.Var] = true, -- Baby Spider
	[FiendFolio.FFID.Tech] = true, -- Technical Entities
	[FiendFolio.FF.CordendCord.ID .. " " .. FiendFolio.FF.CordendCord.Var .. " " .. FiendFolio.FF.CordendCord.Sub] = true, -- Cordend Cord
}

-- Enemies that are whitelisted for basegame's Uranus Freezing status effect; goes around FLAG_NO_STATUS_EFFECTS and IceBlacklist
FiendFolio.IceWhitelist = {
	[FiendFolio.FF.NerveCluster.ID .. " " .. FiendFolio.FF.NerveCluster.Var] = true,
	[FiendFolio.FF.PsyEg.ID .. " " .. FiendFolio.FF.PsyEg.Var] = true,
	[FiendFolio.FF.RiderScythe.ID .. " " .. FiendFolio.FF.RiderScythe.Var] = true,
	[FiendFolio.FF.RollingHollowKnight.ID .. " " .. FiendFolio.FF.RollingHollowKnight.Var] = true,
	[FiendFolio.FF.ChainBall.ID .. " " .. FiendFolio.FF.ChainBall.Var] = true,
	[FiendFolio.FF.SpiderProj.ID .. " " .. FiendFolio.FF.SpiderProj.Var] = true,
}

-- Prevents enemies from being affected by FF's status effects
mod.FFStatusBlacklist = {
	[79 .. " " .. 20] = true, -- Gemini (cord segments)
	[216 .. " " .. 10] = true, -- Swinger (neck)
	[951 .. " " .. 42] = true, -- Ultra Death (heads)
	[mod.FF.HarletwinCord.ID .. " " .. mod.FF.HarletwinCord.Var .. " " .. mod.FF.HarletwinCord.Sub] = true, -- Harletwin (cord segments)
	[mod.FF.EffigyCord.ID .. " " .. mod.FF.EffigyCord.Var .. " " .. mod.FF.EffigyCord.Sub] = true, -- Effigy (cord segments)
	[EntityType.ENTITY_EVIS .. " " .. 10] = true, -- Evis Guts / Sewing Rope / etc.
	[mod.FF.StrikerHead.ID .. " " .. mod.FF.StrikerHead.Var .. " " .. mod.FF.StrikerHead.Sub] = true, -- Striker Ball
}

-- Prevents enemies from being affected by FF's Berserk status effect
mod.BerserkBlacklist = {
	[EntityType.ENTITY_MOMS_HAND] = true,	--Mom's Hand
	[EntityType.ENTITY_MOMS_DEAD_HAND] = true,	--Mom's Dead Hand
	[mod.FF.Ransacked.ID .. " " .. mod.FF.Ransacked.Var] = true,	--Ransacked
}

-- Enemies that are blacklisted from FF's Martyr status effect
FiendFolio.MartyrBlacklist = {
	[EntityType.ENTITY_BLOOD_PUPPY] = true, -- Blood Puppy
	[EntityType.ENTITY_VIS .. " " .. 22] = true, -- Chubber Projectile
	[FiendFolio.FF.BabySpider.ID .. " " .. FiendFolio.FF.BabySpider.Var] = true, -- Baby Spider
	[FiendFolio.FFID.Tech] = true, -- Technical Entities
	[FiendFolio.FF.CordendCord.ID .. " " .. FiendFolio.FF.CordendCord.Var .. " " .. FiendFolio.FF.CordendCord.Sub] = true, -- Cordend Cord
}

-- Enemies that are whitelisted for FF's Martyr status effect; goes around FLAG_NO_STATUS_EFFECTS and MartyrBlacklist
FiendFolio.MartyrWhitelist = {
	[FiendFolio.FF.Patzer.ID .. " " .. FiendFolio.FF.Patzer.Var] = true,
	[FiendFolio.FF.Sackboy.ID .. " " .. FiendFolio.FF.Sackboy.Var] = true,
	[FiendFolio.FF.NerveCluster.ID .. " " .. FiendFolio.FF.NerveCluster.Var] = true,
	[FiendFolio.FF.PsyEg.ID .. " " .. FiendFolio.FF.PsyEg.Var] = true,
	[FiendFolio.FF.RiderScythe.ID .. " " .. FiendFolio.FF.RiderScythe.Var] = true,
	[FiendFolio.FF.RollingHollowKnight.ID .. " " .. FiendFolio.FF.RollingHollowKnight.Var] = true,
	[FiendFolio.FF.ChainBall.ID .. " " .. FiendFolio.FF.ChainBall.Var] = true,
	[FiendFolio.FF.SpiderProj.ID .. " " .. FiendFolio.FF.SpiderProj.Var] = true,
}



----TAIGA TECHNICAL LISTS----

-- Priorities used for changing the variants of tears
mod.TearVariantPriority = {
	-- Technical and other important variants; never overwritten
	[TearVariant.BOBS_HEAD] = 99999,
	[TearVariant.CHAOS_CARD] = 99999,
	[TearVariant.STONE] = 99999,
	[TearVariant.MULTIDIMENSIONAL] = 99999,
	[TearVariant.BELIAL] = 99999,
	[TearVariant.BALLOON] = 99999,
	[TearVariant.BALLOON_BRIMSTONE] = 99999,
	[TearVariant.BALLOON_BOMB] = 99999,
	[TearVariant.GRIDENT] = 99999,
	[TearVariant.KEY] = 99999,
	[TearVariant.KEY_BLOOD] = 99999,
	[TearVariant.ERASER] = 99999,
	[TearVariant.FIRE] = 99999,
	[TearVariant.SWORD_BEAM] = 99999,
	[TearVariant.TECH_SWORD_BEAM] = 99999,
	[TearVariant.BOOMERANG_RIB] = 99999,
	[50] = 99999, -- Fetus tears
	[TearVariant.BRICK] = 99999,
	
	-- Random tear effect; probably shouldn't be overwritten
	[TearVariant.EGG] = 3,
	[TearVariant.COIN] = 3,
	[TearVariant.NEEDLE] = 3,
	[TearVariant.D10] = 3,
	
	-- Random tear effect; can be overwritten
	[TearVariant.TOOTH] = 2,
	[TearVariant.RAZOR] = 2,
	[TearVariant.BLACK_TOOTH] = 2,
	[TearVariant.FIST] = 2,
	[TearVariant.FORTUNE_COOKIE] = 2,
	[TearVariant.PIN] = 2,
	[TearVariant.PIN_BLOOD] = 2,
	[TearVariant.M90_BULLET] = 2,
	[TearVariant.GOLEMS_AR_BULLET] = 2,
	[TearVariant.MULTI_EUCLIDEAN] = 2,
	[TearVariant.LAWN_DART] = 2,
	
	-- Random tear effect; usually overwritten
	[TearVariant.GODS_FLESH] = 1,
	[TearVariant.GODS_FLESH_BLOOD] = 1,
	[TearVariant.EXPLOSIVO] = 1,
	[TearVariant.BOOGER] = 1,
	[TearVariant.SPORE] = 1,
	[TearVariant.HOMING_AMULET] = 1,
	[TearVariant.HOMING_AMULET_BLOOD] = 1,
	[TearVariant.EMOJI_GLASS] = 1,
	
	-- Base tear appearance; try to keep these
	[TearVariant.EYE] = 0.5,
	[TearVariant.EYE_BLOOD] = 0.5,
	[TearVariant.HORNCOB_PILL] = 0.5,
	
	-- Base tear appearance; always overwritten
	[TearVariant.BLUE] = 0,
	[TearVariant.BLOOD] = 0,
	[TearVariant.METALLIC] = 0,
	[TearVariant.FIRE_MIND] = 0,
	[TearVariant.DARK_MATTER] = 0,
	[TearVariant.MYSTERIOUS] = 0,
	[TearVariant.SCHYTHE] = 0,
	[TearVariant.LOST_CONTACT] = 0,
	[TearVariant.CUPID_BLUE] = 0,
	[TearVariant.CUPID_BLOOD] = 0,
	[TearVariant.NAIL] = 0,
	[TearVariant.PUPULA] = 0,
	[TearVariant.PUPULA_BLOOD] = 0,
	[TearVariant.DIAMOND] = 0,
	[TearVariant.NAIL_BLOOD] = 0,
	[TearVariant.GLAUCOMA] = 0,
	[TearVariant.GLAUCOMA_BLOOD] = 0,
	[TearVariant.BONE] = 0,
	[TearVariant.HUNGRY] = 0,
	[TearVariant.ICE] = 0,
	[TearVariant.ROCK] = 0,
	[TearVariant.FROG] = 0,
	[TearVariant.FROG_BLOOD] = 0,
	[TearVariant.PRANK_COOKIE] = 0,
	[TearVariant.MODEL_ROCKET] = 0,
}

-- Tear variants considered bloody; used in changing variants of tears
mod.BloodyTears = {
	[TearVariant.BLOOD] = true,
	[TearVariant.CUPID_BLOOD] = true,
	[TearVariant.PUPULA_BLOOD] = true,
	[TearVariant.GODS_FLESH_BLOOD] = true,
	[TearVariant.NAIL_BLOOD] = true,
	[TearVariant.GLAUCOMA_BLOOD] = true,
	[TearVariant.EYE_BLOOD] = true,
	[TearVariant.HOMING_AMULET_BLOOD] = true,
	[TearVariant.FROG_BLOOD] = true,
	[TearVariant.PIN_BLOOD] = true,
}

-- Entities that will not share HP when linked by Cuffs / cannot be affected by FF's Sewn status effect
FiendFolio.HPSharingBlacklist = {
	[33] = true, -- Fireplace
	[42] = true, -- Grimace
	[44] = true, -- Poky
	[201] = true, -- Stone Eye
	[202] = true, -- Constant Stone Shooter
	[203] = true, -- Brimstone Head
	[218] = true, -- Wall Hugger
	[804] = true, -- Quake Grimace
	[809] = true, -- Bomb Grimace
	[877] = true, -- Grudge
	[FiendFolio.FF.Cordend.ID .. " " .. FiendFolio.FF.Cordend.Var] = true, -- Cordend
}

-- List of custom segmented enemies
FiendFolio.SegmentedEnemies = {
	[FiendFolio.FF.ToxicKnight.ID .. " " .. FiendFolio.FF.ToxicKnight.Var] = true, -- Toxic Knight
	[FiendFolio.FF.PsiKnight.ID .. " " .. FiendFolio.FF.PsiKnight.Var] = true, -- Psionic Knight
	[FiendFolio.FF.Fingore.ID .. " " .. FiendFolio.FF.Fingore.Var] = true, -- Fingore (body)
	[FiendFolio.FF.FingoreHand.ID .. " " .. FiendFolio.FF.FingoreHand.Var] = true, -- Fingore (hand)
	[FiendFolio.FF.Centipede.ID .. " " .. FiendFolio.FF.Centipede.Var] = true, -- Centipede
	[FiendFolio.FF.CentipedeAngy.ID .. " " .. FiendFolio.FF.CentipedeAngy.Var] = true, -- Angy Centipede
	[FiendFolio.FF.Weaver.ID .. " " .. FiendFolio.FF.Weaver.Var] = true, -- Weaver
	[FiendFolio.FF.WeaverSr.ID .. " " .. FiendFolio.FF.WeaverSr.Var] = true, -- Weaver Sr.
	[FiendFolio.FF.DreadWeaver.ID .. " " .. FiendFolio.FF.DreadWeaver.Var] = true, -- Dread Weaver
	[FiendFolio.FF.Thread.ID .. " " .. FiendFolio.FF.Thread.Var] = true, -- Thread
	[FiendFolio.FF.Ossularry.ID .. " " .. FiendFolio.FF.Ossularry.Var] = true, -- Ossularry
	[FiendFolio.FF.Gorger.ID .. " " .. FiendFolio.FF.Gorger.Var] = true, -- Gorger
	[FiendFolio.FF.Kingpin.ID .. " " .. FiendFolio.FF.Kingpin.Var] = true, -- Kingpin
	[FiendFolio.FF.Dusk.ID .. " " .. FiendFolio.FF.Dusk.Var] = true, -- Dusk
	[FiendFolio.FF.DuskHand.ID .. " " .. FiendFolio.FF.DuskHand.Var] = true, -- Dusk (hand)
	[FiendFolio.FF.Tapeworm.ID .. " " .. FiendFolio.FF.Tapeworm.Var] = true, -- Tapeworm
	[FiendFolio.FF.RotspinCore.ID .. " " .. FiendFolio.FF.RotspinCore.Var] = true, -- Rotspin (body)
	[FiendFolio.FF.RotspinMoon.ID .. " " .. FiendFolio.FF.RotspinMoon.Var] = true, -- Rotspin (head)
	[FiendFolio.FF.HollowKnight.ID .. " " .. FiendFolio.FF.HollowKnight.Var] = true, -- Hollow Knight (body)
	[FiendFolio.FF.Cortex.ID .. " " .. FiendFolio.FF.Cortex.Var] = true, -- Hollow Knight (brain)
	[FiendFolio.FF.RollingHollowKnight.ID .. " " .. FiendFolio.FF.RollingHollowKnight.Var] = true, -- Hollow Knight (sanic)
	[FiendFolio.FF.Bola.ID .. " " .. FiendFolio.FF.Bola.Var .. " " .. 0] = true, -- Bola (body)
	[FiendFolio.FF.BolaHead.ID .. " " .. FiendFolio.FF.BolaHead.Var .. " " .. FiendFolio.FF.BolaHead.Sub] = true, -- Bola (head)
	[FiendFolio.FF.MrBones.ID .. " " .. FiendFolio.FF.MrBones.Var] = true, -- Mr. Bones
	[FiendFolio.FF.MrGob.ID .. " " .. FiendFolio.FF.MrGob.Var] = true, -- Mr. Gob
	[FiendFolio.FF.Prick.ID .. " " .. FiendFolio.FF.Prick.Var] = true, -- Prick
	[FiendFolio.FF.Cordend.ID .. " " .. FiendFolio.FF.Cordend.Var] = true, -- Cordend
	[FiendFolio.FF.Warble.ID .. " " .. FiendFolio.FF.Warble.Var] = true, -- Warble
	[FiendFolio.FF.LonelyKnight.ID .. " " .. FiendFolio.FF.LonelyKnight.Var] = true, -- Lonely Knight (body)
	[FiendFolio.FF.LonelyKnightBrain.ID .. " " .. FiendFolio.FF.LonelyKnightBrain.Var] = true, -- Lonely Knight (brain)
	[FiendFolio.FF.LonelyKnightShell.ID .. " " .. FiendFolio.FF.LonelyKnightShell.Var] = true, -- Lonely Knight (shell)
	[FiendFolio.FF.Foetus.ID .. " " .. FiendFolio.FF.Foetus.Var .. " " .. FiendFolio.FF.Foetus.Sub] = true, -- Foetus
	[FiendFolio.FF.FoetusBaby.ID .. " " .. FiendFolio.FF.FoetusBaby.Var .. " " .. FiendFolio.FF.FoetusBaby.Sub] = true, -- Foetu
	[FiendFolio.FF.CorruptedLarry.ID .. " " .. FiendFolio.FF.CorruptedLarry.Var] = true, -- Corrupted Larry
}

-- List of basegame segmented enemies
mod.BasegameSegmentedEnemies = {
	[35 .. " " .. 0] = true, -- Mr. Maw (body)
	[35 .. " " .. 1] = true, -- Mr. Maw (head)
	[35 .. " " .. 2] = true, -- Mr. Red Maw (body)
	[35 .. " " .. 3] = true, -- Mr. Red Maw (head)
	[89] = true, -- Buttlicker
	[216 .. " " .. 0] = true, -- Swinger (body)
	[216 .. " " .. 1] = true, -- Swinger (head)
	[239] = true, -- Grub
	[244 .. " " .. 2] = true, -- Tainted Round Worm

	[19 .. " " .. 0] = true, -- Larry Jr.
	[19 .. " " .. 1] = true, -- The Hollow
	[19 .. " " .. 2] = true, -- Tuff Twins
	[19 .. " " .. 3] = true, -- The Shell
	[28 .. " " .. 0] = true, -- Chub
	[28 .. " " .. 1] = true, -- C.H.A.D.
	[28 .. " " .. 2] = true, -- The Carrion Queen
	[62 .. " " .. 0] = true, -- Pin
	[62 .. " " .. 1] = true, -- Scolex
	[62 .. " " .. 2] = true, -- The Frail
	[62 .. " " .. 3] = true, -- Wormwood
	[79 .. " " .. 0] = true, -- Gemini
	[79 .. " " .. 1] = true, -- Steven
	[79 .. " " .. 10] = true, -- Gemini (baby)
	[79 .. " " .. 11] = true, -- Steven (baby)
	[92 .. " " .. 0] = true, -- Heart
	[92 .. " " .. 1] = true, -- 1/2 Heart
	[93 .. " " .. 0] = true, -- Mask
	[93 .. " " .. 1] = true, -- Mask II
	[97] = true, -- Mask of Infamy
	[98] = true, -- Heart of Infamy
	[266] = true, -- Mama Gurdy
	[912 .. " " .. 0 .. " " .. 0] = true, -- Mother (phase one)
	[912 .. " " .. 0 .. " " .. 2] = true, -- Mother (left arm)
	[912 .. " " .. 0 .. " " .. 3] = true, -- Mother (right arm)
	[918 .. " " .. 0] = true, -- Turdlet
}

-- Main segment of custom segmented enemies
FiendFolio.MainSegment = {
	[FiendFolio.FF.ToxicKnightHusk.ID .. " " .. FiendFolio.FF.ToxicKnightHusk.Var .. " " .. FiendFolio.FF.ToxicKnightHusk.Sub] = true, -- Toxic Knight (body)
	[FiendFolio.FF.PsiKnightHusk.ID .. " " .. FiendFolio.FF.PsiKnightHusk.Var .. " " .. FiendFolio.FF.PsiKnightHusk.Sub] = true, -- Psionic Knight (body)
	[FiendFolio.FF.Fingore.ID .. " " .. FiendFolio.FF.Fingore.Var] = true, -- Fingore (body)
	[FiendFolio.FF.Centipede.ID .. " " .. FiendFolio.FF.Centipede.Var .. " " .. 0] = true, -- Centipede (head)
	[FiendFolio.FF.CentipedeAngy.ID .. " " .. FiendFolio.FF.CentipedeAngy.Var .. " " .. 0] = true, -- Angy Centipede (head)
	[FiendFolio.FF.Weaver.ID .. " " .. FiendFolio.FF.Weaver.Var .. " " .. 0] = true, -- Weaver (head)
	[FiendFolio.FF.WeaverSr.ID .. " " .. FiendFolio.FF.WeaverSr.Var .. " " .. 0] = true, -- Weaver Sr. (head)
	[FiendFolio.FF.DreadWeaver.ID .. " " .. FiendFolio.FF.DreadWeaver.Var .. " " .. 0] = true, -- Dread Weaver (head)
	[FiendFolio.FF.Thread.ID .. " " .. FiendFolio.FF.Thread.Var .. " " .. 0] = true, -- Thread
	[FiendFolio.FF.Ossularry.ID .. " " .. FiendFolio.FF.Ossularry.Var .. " " .. 0] = true, -- Ossularry
	[FiendFolio.FF.Gorger.ID .. " " .. FiendFolio.FF.Gorger.Var .. " " .. 0] = true, -- Gorger (head)
	--[FiendFolio.FF.Kingpin.ID .. " " .. FiendFolio.FF.Kingpin.Var] = true, -- Kingpin is weird
	[FiendFolio.FF.Dusk.ID .. " " .. FiendFolio.FF.Dusk.Var] = true, -- Dusk (head)
	--[FiendFolio.FF.Tapeworm.ID .. " " .. FiendFolio.FF.Tapeworm.Var] = true, -- Tapeworms are weird
	[FiendFolio.FF.RotspinCore.ID .. " " .. FiendFolio.FF.RotspinCore.Var] = true, -- Rotspin (body)
	[FiendFolio.FF.HollowKnight.ID .. " " .. FiendFolio.FF.HollowKnight.Var] = true, -- Hollow Knight (body)
	[FiendFolio.FF.Bola.ID .. " " .. FiendFolio.FF.Bola.Var .. " " .. 0] = true, -- Bola (body)
	--[FiendFolio.FF.MrBones.ID .. " " .. FiendFolio.FF.MrBones.Var] = true, -- Mr. Bones is weird
	[FiendFolio.FF.MrGob.ID .. " " .. FiendFolio.FF.MrGob.Var .. " " .. 0] = true, -- Mr. Gob (body)
	--[FiendFolio.FF.Prick.ID .. " " .. FiendFolio.FF.Prick.Var] = true, -- Prick is weird
	[FiendFolio.FF.Cordend.ID .. " " .. FiendFolio.FF.Cordend.Var .. " " .. 0] = true, -- Cordend (main half)
	--[FiendFolio.FF.Warble.ID .. " " .. FiendFolio.FF.Warble.Var] = true, -- Warble is weird
	[FiendFolio.FF.LonelyKnight.ID .. " " .. FiendFolio.FF.LonelyKnight.Var] = true, -- Lonely Knight (body)
	[FiendFolio.FF.Foetus.ID .. " " .. FiendFolio.FF.Foetus.Var .. " " .. FiendFolio.FF.Foetus.Sub] = true, -- Foetus
}

-- Main segment of basegame segmented enemies
mod.BasegameMainSegment = {
	[35 .. " " .. 1] = true, -- Mr. Maw (head)
	[35 .. " " .. 3] = true, -- Mr. Red Maw (head)
	[92 .. " " .. 0] = true, -- Heart
	[92 .. " " .. 1] = true, -- 1/2 Heart
	[216 .. " " .. 0] = true, -- Swinger (body)
	[244 .. " " .. 2 .. " " .. 0] = true, -- Tainted Round Worm (head)

	[79 .. " " .. 0] = true, -- Gemini
	[79 .. " " .. 1] = true, -- Steven
	[97] = true, -- Mask of Infamy
	[266 .. " " .. 0] = true, -- Mama Gurdy (body)
	[912 .. " " .. 0 .. " " .. 0] = true, -- Mother (phase one)

--	[89] = true, -- Buttlicker is weird
--	[239] = true, -- Grub is weird

--	[19 .. " " .. 0] = true, -- Larry Jr. is weird
--	[19 .. " " .. 1] = true, -- The Hollow is weird
--	[19 .. " " .. 2] = true, -- Tuff Twins is weird
--	[19 .. " " .. 3] = true, -- The Shell is weird
--	[28 .. " " .. 0] = true, -- Chub is weird
--	[28 .. " " .. 1] = true, -- C.H.A.D. is weird
--	[28 .. " " .. 2] = true, -- The Carrion Queen is weird
--	[62 .. " " .. 0] = true, -- Pin is weird
--	[62 .. " " .. 1] = true, -- Scolex is weird
--	[62 .. " " .. 2] = true, -- The Frail is weird
--	[62 .. " " .. 3] = true, -- Wormwood is weird
--	[918 .. " " .. 0] = true, -- Turdlet is weird
}

-- Treats segments as separate entities for Uranus freezing, Dr. Shambles healing, Hemorrhaging DoT, etc. 
-- For custom segmented enemies/bosses like Rotspin, Kingpin, etc.
FiendFolio.ReducedSyncSegments = {
	[FiendFolio.FF.Ossularry.ID .. " " .. FiendFolio.FF.Ossularry.Var] = true, -- Ossularry
	[FiendFolio.FF.Kingpin.ID .. " " .. FiendFolio.FF.Kingpin.Var] = true, -- Kingpin
	[FiendFolio.FF.Dusk.ID .. " " .. FiendFolio.FF.Dusk.Var] = true, -- Dusk
	[FiendFolio.FF.DuskHand.ID .. " " .. FiendFolio.FF.DuskHand.Var] = true, -- Dusk (hand)
	[FiendFolio.FF.Tapeworm.ID .. " " .. FiendFolio.FF.Tapeworm.Var] = true, -- Tapeworm
	[FiendFolio.FF.RotspinCore.ID .. " " .. FiendFolio.FF.RotspinCore.Var] = true, -- Rotspin (body)
	[FiendFolio.FF.RotspinMoon.ID .. " " .. FiendFolio.FF.RotspinMoon.Var] = true, -- Rotspin (head)
	[FiendFolio.FF.MrBones.ID .. " " .. FiendFolio.FF.MrBones.Var] = true, -- Mr. Bones
	[FiendFolio.FF.MrGob.ID .. " " .. FiendFolio.FF.MrGob.Var] = true, -- Mr. Gob
	[FiendFolio.FF.Prick.ID .. " " .. FiendFolio.FF.Prick.Var] = true, -- Prick
	[FiendFolio.FF.Foetus.ID .. " " .. FiendFolio.FF.Foetus.Var .. " " .. FiendFolio.FF.Foetus.Sub] = true, -- Foetus
	[FiendFolio.FF.FoetusBaby.ID .. " " .. FiendFolio.FF.FoetusBaby.Var .. " " .. FiendFolio.FF.FoetusBaby.Sub] = true, -- Foetu
}

-- Treats segments as separate entities for Uranus freezing, Dr. Shambles healing, Hemorrhaging DoT, etc. 
-- For basegame segmented enemies/bosses like Larry Jr., Gemini, etc.
mod.BasegameReducedSyncSegments = {
	[35 .. " " .. 0] = true, -- Mr. Maw (body)
	[35 .. " " .. 1] = true, -- Mr. Maw (head)
	[35 .. " " .. 2] = true, -- Mr. Red Maw (body)
	[35 .. " " .. 3] = true, -- Mr. Red Maw (head)
	[89] = true, -- Buttlicker
	[216 .. " " .. 0] = true, -- Swinger (body)
	[216 .. " " .. 1] = true, -- Swinger (head)

	[19 .. " " .. 0] = true, -- Larry Jr.
	[19 .. " " .. 1] = true, -- The Hollow
	[19 .. " " .. 2] = true, -- Tuff Twins
	[19 .. " " .. 3] = true, -- The Shell
	[79 .. " " .. 0] = true, -- Gemini
	[79 .. " " .. 1] = true, -- Steven
	[79 .. " " .. 10] = true, -- Gemini (baby)
	[79 .. " " .. 11] = true, -- Steven (baby)
	[92 .. " " .. 0] = true, -- Heart
	[92 .. " " .. 1] = true, -- 1/2 Heart
	[93 .. " " .. 0] = true, -- Mask
	[93 .. " " .. 1] = true, -- Mask II
	[97] = true, -- Mask of Infamy
	[98] = true, -- Heart of Infamy
}

---- SBODY ITEM LIST ----

-- AZURITE SPINDOWN --

ffAzuriteSpindownList = {									--ffBlacklistAzurite(table) for modded trinkets. true for single trinkets, table for multi-state trinkets
	[TrinketType.TRINKET_POLAROID_OBSOLETE] = true,
	[mod.ITEM.TRINKET.HALF_VESSEL] = {[mod.ITEM.TRINKET.EXTRA_VESSEL]=true},
	[mod.ITEM.TRINKET.FULL_VESSEL] = {[mod.ITEM.TRINKET.HALF_VESSEL]=true, [mod.ITEM.TRINKET.EXTRA_VESSEL]=true},
	[FiendFolio.ITEM.ROCK.VESSEL_ROCK] = true,
	[FiendFolio.ITEM.ROCK.FULL_VESSEL_ROCK] = {[FiendFolio.ITEM.ROCK.HALF_VESSEL_ROCK]=true, [FiendFolio.ITEM.ROCK.VESSEL_ROCK]=true},	
	[FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE] = {[FiendFolio.ITEM.ROCK.SAND_CASTLE]=true},
	[FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE] = {[FiendFolio.ITEM.ROCK.SAND_CASTLE]=true, [FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE]=true},
	[mod.ITEM.TRINKET.TATTERED_FROG_PUPPET] = true,
	--[FiendFolio.ITEM.ROCK.UNOBTAINIUM] = true,			--mf is so unobtainable that its hardcoded on azurite's code

	-- Achievement Trackers copied directly from the achievement tracker id table in ffscripts.achievements, so that I don't eventually forgot to add one here too
}

-- GENERAL TRINKET BLACKLIST --
mod.TrinketPoolBlacklist = {
	[mod.ITEM.TRINKET.HALF_VESSEL] = true,
	[mod.ITEM.TRINKET.FULL_VESSEL] = true,
	[mod.ITEM.TRINKET.TATTERED_FROG_PUPPET] = true,
	[mod.ITEM.TRINKET.SHATTERED_CURSED_URN] = true,
	[FiendFolio.ITEM.ROCK.UNOBTAINIUM] = true,
}
