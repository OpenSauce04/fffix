local mod = FiendFolio

do -- Error Room (Test Pool)
	mod.BaseErrorRoomPool = {
		-- Vanilla
		CollectibleType.COLLECTIBLE_TELEPORT,
		CollectibleType.COLLECTIBLE_DOCTORS_REMOTE,
		CollectibleType.COLLECTIBLE_TECHNOLOGY,
		CollectibleType.COLLECTIBLE_GAMEKID,
		CollectibleType.COLLECTIBLE_ROBO_BABY,
		CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
		CollectibleType.COLLECTIBLE_STOP_WATCH,
		CollectibleType.COLLECTIBLE_TECH_5,
		CollectibleType.COLLECTIBLE_MISSING_NO,
		CollectibleType.COLLECTIBLE_ROBO_BABY_2,
		CollectibleType.COLLECTIBLE_MONGO_BABY,
		CollectibleType.COLLECTIBLE_UNDEFINED,
		CollectibleType.COLLECTIBLE_BROKEN_WATCH,
		CollectibleType.COLLECTIBLE_CONTINUUM,
		CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER,
		CollectibleType.COLLECTIBLE_TECH_X,
		CollectibleType.COLLECTIBLE_CHAOS,
		CollectibleType.COLLECTIBLE_SPIDER_MOD,
		CollectibleType.COLLECTIBLE_GB_BUG,
		CollectibleType.COLLECTIBLE_TELEPORT_2,
		CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,
		CollectibleType.COLLECTIBLE_SACK_HEAD,
		CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY,
		CollectibleType.COLLECTIBLE_VOID,
		CollectibleType.COLLECTIBLE_PAUSE,
		CollectibleType.COLLECTIBLE_DATAMINER,
		CollectibleType.COLLECTIBLE_CLICKER,
		CollectibleType.COLLECTIBLE_METRONOME,
		CollectibleType.COLLECTIBLE_D_INFINITY,
		CollectibleType.COLLECTIBLE_BROKEN_MODEM,
		CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO,
		CollectibleType.COLLECTIBLE_BOT_FLY,
		CollectibleType.COLLECTIBLE_ETERNAL_D6,
		CollectibleType.COLLECTIBLE_R_KEY,
		CollectibleType.COLLECTIBLE_CARD_READING,
		CollectibleType.COLLECTIBLE_STRAW_MAN,
		CollectibleType.COLLECTIBLE_LIL_PORTAL,
		CollectibleType.COLLECTIBLE_GLITCHED_CROWN,
		CollectibleType.COLLECTIBLE_ECHO_CHAMBER,
		CollectibleType.COLLECTIBLE_ABYSS,
		CollectibleType.COLLECTIBLE_SUPLEX,
		CollectibleType.COLLECTIBLE_EVERYTHING_JAR,
		CollectibleType.COLLECTIBLE_TMTRAINER,
		CollectibleType.COLLECTIBLE_SPINDOWN_DICE,

		-- FiendFolio
		mod.ITEM.COLLECTIBLE.RISKS_REWARD,
		mod.ITEM.COLLECTIBLE.ALPHA_COIN,
		mod.ITEM.COLLECTIBLE.FIDDLE_CUBE,
		mod.ITEM.COLLECTIBLE.AVGM,
		mod.ITEM.COLLECTIBLE.CLEAR_CASE,
		mod.ITEM.COLLECTIBLE.ETERNAL_D12,
		mod.ITEM.COLLECTIBLE.WRONG_WARP,
		mod.ITEM.COLLECTIBLE.ETERNAL_D10,
		mod.ITEM.COLLECTIBLE.ROBOBABY3,
		mod.ITEM.COLLECTIBLE.SNOW_GLOBE,
		mod.ITEM.COLLECTIBLE.AZURITE_SPINDOWN,
		mod.ITEM.COLLECTIBLE.NIL_PASTA,
		mod.ITEM.COLLECTIBLE.CLUTCHS_CURSE,
		mod.ITEM.COLLECTIBLE.TIME_ITSELF,
	}
	mod.ExternalErrorRoomPoolAdditions = {}
	mod.RegisterCustomItemPool("ERROR", mod.CustomItemPoolType.COLLECTIBLE, {"BaseErrorRoomPool", "ExternalErrorRoomPoolAdditions"})

	function mod.AddItemsToErrorRoomPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalErrorRoomPoolAdditions, id)
		end
	end
end

do -- Drug Dealer
	mod.BaseDrugDealerPool = { -- This system doesn't support weight yet sorry, if I add that one day I'll update these
		-- Syringes
		CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT, 					-- 3
		CollectibleType.COLLECTIBLE_GROWTH_HORMONES,							-- 2
		CollectibleType.COLLECTIBLE_ROID_RAGE,									-- 4
		CollectibleType.COLLECTIBLE_SPEED_BALL,									-- 2
		CollectibleType.COLLECTIBLE_SYNTHOIL,									-- 2
		CollectibleType.COLLECTIBLE_VIRUS,										-- 3
		CollectibleType.COLLECTIBLE_ADRENALINE,									-- 1
		CollectibleType.COLLECTIBLE_EUTHANASIA,									-- 1

		-- Shrooms
		CollectibleType.COLLECTIBLE_WAVY_CAP,									-- 3
		CollectibleType.COLLECTIBLE_BLUE_CAP,									-- 1
		CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM,								-- 1
		CollectibleType.COLLECTIBLE_MINI_MUSH,									-- 2
		CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN,							-- 2
		CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE,							-- 2
		CollectibleType.COLLECTIBLE_1UP,
		CollectibleType.COLLECTIBLE_GODS_FLESH,
		mod.ITEM.COLLECTIBLE.FRAUDULENT_FUNGUS,

		-- Pills
		CollectibleType.COLLECTIBLE_PLACEBO,									-- 2
		CollectibleType.COLLECTIBLE_FORGET_ME_NOW,								-- 1
		CollectibleType.COLLECTIBLE_PLAN_C,										-- 1
		CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS,						-- 2
		CollectibleType.COLLECTIBLE_MOMS_COIN_PURSE,							-- 4
		CollectibleType.COLLECTIBLE_PHD,										-- 2
		CollectibleType.COLLECTIBLE_FALSE_PHD,									-- 3
		CollectibleType.COLLECTIBLE_LITTLE_BAGGY,								-- 1
		mod.ITEM.COLLECTIBLE.GMO_CORN,											-- 2
		mod.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE,								-- 1

		-- Trafficked Organs
		CollectibleType.COLLECTIBLE_HEART,										-- 4
		CollectibleType.COLLECTIBLE_YUM_HEART,									-- 2
		CollectibleType.COLLECTIBLE_PEEPER,										-- 2
		CollectibleType.COLLECTIBLE_PLACENTA,									-- 2
		CollectibleType.COLLECTIBLE_MAGIC_SCAB,									-- 2
		CollectibleType.COLLECTIBLE_BOBS_BRAIN,									-- 3
		CollectibleType.COLLECTIBLE_ISAACS_HEART,								-- 2
		CollectibleType.COLLECTIBLE_YUCK_HEART,									-- 1
		CollectibleType.COLLECTIBLE_AKELDAMA,									-- 1
		CollectibleType.COLLECTIBLE_MAGIC_SKIN,									-- 2
		CollectibleType.COLLECTIBLE_FIEND_HEART,								-- 2
		CollectibleType.COLLECTIBLE_MYSTERY_EGG,								-- 2
		CollectibleType.COLLECTIBLE_STEM_CELLS,									-- 2
		CollectibleType.COLLECTIBLE_RAW_LIVER,									-- 1
		CollectibleType.COLLECTIBLE_GIANT_CELL,									-- 2
		mod.ITEM.COLLECTIBLE.SLIPPYS_GUTS,
		mod.ITEM.COLLECTIBLE.SLIPPYS_HEART,
		mod.ITEM.COLLECTIBLE.KALUS_HEAD,

		-- Foreign Implements
		CollectibleType.COLLECTIBLE_MOMS_KNIFE,									-- 1
		CollectibleType.COLLECTIBLE_RAZOR_BLADE,								-- 3
		CollectibleType.COLLECTIBLE_BLOOD_RIGHTS,								-- 2
		CollectibleType.COLLECTIBLE_SCISSORS,									-- 2
		CollectibleType.COLLECTIBLE_PINKING_SHEARS,								-- 2
		CollectibleType.COLLECTIBLE_POTATO_PEELER,								-- 2
		CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER,							-- 1
		CollectibleType.COLLECTIBLE_DARK_ARTS,									-- 2
		CollectibleType.COLLECTIBLE_DULL_RAZOR,									-- 2
		CollectibleType.COLLECTIBLE_TOUGH_LOVE,									-- 3
		CollectibleType.COLLECTIBLE_MEAT_CLEAVER,								-- 1
		mod.ITEM.COLLECTIBLE.SANGUINE_HOOK,										-- 3

		-- High Explosives
		CollectibleType.COLLECTIBLE_REMOTE_DETONATOR,							-- 3
		CollectibleType.COLLECTIBLE_HOT_BOMBS,									-- 2
		CollectibleType.COLLECTIBLE_SCATTER_BOMBS,								-- 2
		CollectibleType.COLLECTIBLE_BOOM,										-- 3
		CollectibleType.COLLECTIBLE_MR_MEGA,									-- 2
		CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR,							-- 2
		CollectibleType.COLLECTIBLE_EPIC_FETUS,									-- 1
		CollectibleType.COLLECTIBLE_DR_FETUS,									-- 1
		CollectibleType.COLLECTIBLE_PYROMANIAC,									-- 1
		CollectibleType.COLLECTIBLE_KAMIKAZE,									-- 2
		mod.ITEM.COLLECTIBLE.NUGGET_BOMBS,
		mod.ITEM.COLLECTIBLE.CHERRY_BOMB,										
		mod.ITEM.COLLECTIBLE.BRIDGE_BOMBS,
		mod.ITEM.COLLECTIBLE.TELEBOMBS,

		-- Banned Books
		CollectibleType.COLLECTIBLE_NECRONOMICON,								-- 1
		CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK,							-- 4
		CollectibleType.COLLECTIBLE_OUIJA_BOARD,								-- 1
		CollectibleType.COLLECTIBLE_MISSING_PAGE_2,								-- 2
		CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS,							-- 2
		CollectibleType.COLLECTIBLE_SATANIC_BIBLE,								-- 1
		CollectibleType.COLLECTIBLE_LEMEGETON,									-- 1

		-- Cold Hard Cash
		CollectibleType.COLLECTIBLE_DOLLAR,										-- 1
		CollectibleType.COLLECTIBLE_STEAM_SALE,									-- 3
		CollectibleType.COLLECTIBLE_QUARTER,									-- 3
		CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,							-- 3
		CollectibleType.COLLECTIBLE_PIGGY_BANK,									-- 2
		CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER,							-- 3
		CollectibleType.COLLECTIBLE_CROOKED_PENNY,								-- 2
		CollectibleType.COLLECTIBLE_DEEP_POCKETS,								-- 2
		CollectibleType.COLLECTIBLE_PORTABLE_SLOT,								-- 3
		CollectibleType.COLLECTIBLE_MAGIC_FINGERS,								-- 2
		CollectibleType.COLLECTIBLE_WOODEN_NICKEL,								-- 3
		CollectibleType.COLLECTIBLE_POUND_OF_FLESH,								-- 1
		CollectibleType.COLLECTIBLE_MOMS_PURSE,									-- 2
		CollectibleType.COLLECTIBLE_COUPON,										-- 2
		mod.ITEM.COLLECTIBLE.DADS_WALLET,										-- 2

		-- Oddballs
		CollectibleType.COLLECTIBLE_STRAW_MAN,									-- 1
		CollectibleType.COLLECTIBLE_KEEPERS_BOX,								-- 1
		CollectibleType.COLLECTIBLE_STORE_WHISTLE,								-- 1
		CollectibleType.COLLECTIBLE_MEMBER_CARD,								-- 2
		CollectibleType.COLLECTIBLE_BIRTHRIGHT,									-- 2
		CollectibleType.COLLECTIBLE_BOX,										-- 2
		CollectibleType.COLLECTIBLE_MOVING_BOX,									-- 1
		CollectibleType.COLLECTIBLE_MR_ME,										-- 1
		CollectibleType.COLLECTIBLE_BLOOD_BAG,									-- 3
		CollectibleType.COLLECTIBLE_IV_BAG,										-- 2
		CollectibleType.COLLECTIBLE_EVIL_CHARM,									-- 1
		CollectibleType.COLLECTIBLE_LUCKY_FOOT,									-- 4
		CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER,						-- 2
		CollectibleType.COLLECTIBLE_MOMS_KEY,									-- 3
		CollectibleType.COLLECTIBLE_DADS_KEY,									-- 2
		CollectibleType.COLLECTIBLE_SHARP_KEY,									-- 3
		CollectibleType.COLLECTIBLE_CHEMICAL_PEEL,								-- 2
		CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID,							-- 1
		CollectibleType.COLLECTIBLE_SUPLEX,										-- 1
		CollectibleType.COLLECTIBLE_MOMS_LIPSTICK,								-- 2
		CollectibleType.COLLECTIBLE_CHAOS,										-- 2
		CollectibleType.COLLECTIBLE_GAMEKID,									-- 2
		mod.ITEM.COLLECTIBLE.LAWN_DARTS,										-- 3
	}
	mod.ExternalDrugDealerPoolAdditions = {}
	mod.RegisterCustomItemPool("CONTRABAND", mod.CustomItemPoolType.COLLECTIBLE, {"BaseDrugDealerPool", "ExternalDrugDealerPoolAdditions"})

	function mod.AddItemsToContrabandPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalErrorRoomPoolAdditions, id)
		end
	end
end

do -- Blacksmith
	mod.BaseBlacksmithPool = {
		CollectibleType.COLLECTIBLE_SMELTER,
		CollectibleType.COLLECTIBLE_MOMS_BOX,
		CollectibleType.COLLECTIBLE_BELLY_BUTTON,
		CollectibleType.COLLECTIBLE_MOMS_PURSE,
		CollectibleType.COLLECTIBLE_MARBLES,
	}
	mod.ExternalBlacksmithPoolAdditions = {}
	mod.RegisterCustomItemPool("BLACKSMITH", mod.CustomItemPoolType.COLLECTIBLE, {"BaseBlacksmithPool", "ExternalBlacksmithPoolAdditions"})

	function mod.AddItemsToBlacksmithPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalBlacksmithPoolAdditions, id)
		end
	end
end

do -- Zodiac Beggar
	mod.BaseZodiacBeggarPool = {
		CollectibleType.COLLECTIBLE_ZODIAC,
		CollectibleType.COLLECTIBLE_TAURUS,
		CollectibleType.COLLECTIBLE_ARIES,
		CollectibleType.COLLECTIBLE_CANCER,
		CollectibleType.COLLECTIBLE_LEO,
		CollectibleType.COLLECTIBLE_VIRGO,
		CollectibleType.COLLECTIBLE_LIBRA,
		CollectibleType.COLLECTIBLE_SCORPIO,
		CollectibleType.COLLECTIBLE_SAGITTARIUS,
		CollectibleType.COLLECTIBLE_CAPRICORN,
		CollectibleType.COLLECTIBLE_AQUARIUS,
		CollectibleType.COLLECTIBLE_PISCES,
		CollectibleType.COLLECTIBLE_GEMINI,
		mod.ITEM.COLLECTIBLE.OPHIUCHUS,
		mod.ITEM.COLLECTIBLE.MUSCA,
		mod.ITEM.COLLECTIBLE.CETUS,
	}
	mod.ExternalZodiacBeggarPoolAdditions = {}
	mod.RegisterCustomItemPool("ZODIAC_BEGGAR", mod.CustomItemPoolType.COLLECTIBLE, {"BaseZodiacBeggarPool", "ExternalZodiacBeggarPoolAdditions"})

	function mod.AddItemsToZodiacBeggarPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalZodiacBeggarPoolAdditions, id)
		end
	end
end

do -- Dire Chest
	mod.BaseDireChestPool = {
		-- Immoral Heart Items
		mod.ITEM.COLLECTIBLE.PURPLE_PUTTY,			-- 10
		mod.ITEM.COLLECTIBLE.FETAL_FIEND,			-- 10
		mod.ITEM.COLLECTIBLE.FIEND_HEART,			-- 10
		mod.ITEM.COLLECTIBLE.DEVILLED_EGG,			-- 10
		mod.ITEM.COLLECTIBLE.FIEND_MIX,				-- 10
		mod.ITEM.COLLECTIBLE.EVIL_STICKER,			-- 10

		-- Fiend Items
		mod.ITEM.COLLECTIBLE.GMO_CORN,				-- 10
		mod.ITEM.COLLECTIBLE.LIL_FIEND,				-- 10
		mod.ITEM.COLLECTIBLE.FIENDS_HORN,			-- 10
		mod.ITEM.COLLECTIBLE.DEVILS_HARVEST,		-- 5
		mod.ITEM.COLLECTIBLE.SACK_OF_SPICY,			-- 10
		
		-- Biend (And Biend-Adjacent) Items
		CollectibleType.COLLECTIBLE_BALL_OF_TAR,
		mod.ITEM.COLLECTIBLE.MALICE,
		mod.ITEM.COLLECTIBLE.MODERN_OUROBOROS,
		mod.ITEM.COLLECTIBLE.HORNCOB,

		-- China Items
		mod.ITEM.COLLECTIBLE.HEART_OF_CHINA,

		-- Friend Items
		mod.ITEM.COLLECTIBLE.RUBBER_BULLETS,

		-- Other
		mod.ITEM.COLLECTIBLE.IMP_SODA,				-- 5
		mod.ITEM.COLLECTIBLE.PRANK_COOKIE,			-- 3
		mod.ITEM.COLLECTIBLE.RISKS_REWARD,			-- 5
		mod.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE,	-- 3
		mod.ITEM.COLLECTIBLE.D2, --"It's Purple" - Happyhead -- 3
		mod.ITEM.COLLECTIBLE.CLUTCHS_CURSE 			-- 3
	}
	mod.ExternalDireChestPoolAdditions = {}
	mod.RegisterCustomItemPool("DIRE_CHEST", mod.CustomItemPoolType.COLLECTIBLE, {"BaseDireChestPool", "ExternalDireChestPoolAdditions"})

	function mod.AddItemsToDireChestPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalDireChestPoolAdditions, id)
		end
	end

	mod.BaseDireChestTrinketPool = {
		-- Risk/Reward
		mod.ITEM.TRINKET.FOOLS_GOLD,
		mod.ITEM.TRINKET.CHILI_POWDER,
		mod.ITEM.TRINKET.JEVILSTAIL,
		mod.ITEM.TRINKET.DEALMAKERS,
		mod.ITEM.TRINKET.REDHAND,
		mod.ITEM.TRINKET.FAULTY_FUSE,

		--Wacky
		mod.ITEM.TRINKET.SWALLOWED_M90,

		--Pennies
		mod.ITEM.TRINKET.MOLTEN_PENNY,
		mod.ITEM.TRINKET.GMO_PENNY,
		mod.ITEM.TRINKET.FUZZY_PENNY,
		mod.ITEM.TRINKET.SHARP_PENNY,

		-- Biend
		TrinketType.TRINKET_CHUNK_OF_TAR,
		mod.ITEM.TRINKET.HATRED,

		-- China
		mod.ITEM.TRINKET.SHARD_OF_CHINA,
		mod.ITEM.TRINKET.CURSED_URN,

		-- Fleas
		mod.ITEM.TRINKET.FLEA_MELTDOWN,
		mod.ITEM.TRINKET.FLEA_DELUGE,
		mod.ITEM.TRINKET.FLEA_POLLUTION,
		mod.ITEM.TRINKET.FLEA_PROPAGANDA,
		mod.ITEM.TRINKET.FLEA_CIRCUS,
	}
	mod.ExternalDireChestTrinketPoolAdditions = {}
	mod.RegisterCustomItemPool("DIRE_CHEST_TRINKET", mod.CustomItemPoolType.TRINKET, {"BaseDireChestTrinketPool", "ExternalDireChestTrinketPoolAdditions"})

	function mod.AddItemsToDireChestTrinketPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalDireChestTrinketPoolAdditions, id)
		end
	end
end

do -- Glass Chest
	mod.BaseGlassChestCommonPool = {
		CollectibleType.COLLECTIBLE_MY_REFLECTION,		--5
		CollectibleType.COLLECTIBLE_HOURGLASS,			--66
		CollectibleType.COLLECTIBLE_CHOCOLATE_MILK,		--69
		CollectibleType.COLLECTIBLE_XRAY_VISION,		--76
		CollectibleType.COLLECTIBLE_HOLY_WATER,			--178
		CollectibleType.COLLECTIBLE_20_20,				--245
		CollectibleType.COLLECTIBLE_THE_JAR,			--290
		CollectibleType.COLLECTIBLE_CRYSTAL_BALL,		--158
		CollectibleType.COLLECTIBLE_LOST_CONTACT, 		--213
		CollectibleType.COLLECTIBLE_CURSED_EYE, 		--316
		CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID, 	--317
		CollectibleType.COLLECTIBLE_ISAACS_TEARS, 		--323
		CollectibleType.COLLECTIBLE_GLASS_CANNON, 		--352
		CollectibleType.COLLECTIBLE_SCATTER_BOMBS, 		--366
		CollectibleType.COLLECTIBLE_NIGHT_LIGHT, 		--425
		CollectibleType.COLLECTIBLE_JAR_OF_FLIES, 		--434
		CollectibleType.COLLECTIBLE_MILK, 				--436
		CollectibleType.COLLECTIBLE_SHARD_OF_GLASS, 	--448
		CollectibleType.COLLECTIBLE_ANGELIC_PRISM, 		--528
		CollectibleType.COLLECTIBLE_FREE_LEMONADE, 		--578
		CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR, 	--583
		CollectibleType.COLLECTIBLE_CUBE_BABY, 			--652
		CollectibleType.COLLECTIBLE_CRACKED_ORB, 		--675
		CollectibleType.COLLECTIBLE_JAR_OF_WISPS, 		--685
		CollectibleType.COLLECTIBLE_ESAU_JR, 			--703
		CollectibleType.COLLECTIBLE_EVERYTHING_JAR, 	--720
		CollectibleType.COLLECTIBLE_GLASS_EYE, 			--730
		mod.ITEM.COLLECTIBLE.COOL_SUNGLASSES,			--FF
		mod.ITEM.COLLECTIBLE.GOLEMS_ORB,				--FF
		mod.ITEM.COLLECTIBLE.SHREDDER,					--FF
	}
	mod.ExternalGlassChestCommonPoolAdditions = {}
	mod.RegisterCustomItemPool("GLASS_CHEST_COMMON", mod.CustomItemPoolType.COLLECTIBLE, {"BaseGlassChestCommonPool", "ExternalGlassChestCommonPoolAdditions"})

	function mod.AddItemsToGlassChestCommonPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalGlassChestCommonPoolAdditions, id)
		end
	end

	mod.BaseGlassChestRarePool = {
		CollectibleType.COLLECTIBLE_DR_FETUS,			--52
		CollectibleType.COLLECTIBLE_EPIC_FETUS,			--168
		CollectibleType.COLLECTIBLE_CLEAR_RUNE,			--263
		CollectibleType.COLLECTIBLE_SOY_MILK, 			--330
		CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, --422
		CollectibleType.COLLECTIBLE_SACRED_ORB,			--691
		mod.ITEM.COLLECTIBLE.CLEAR_CASE,				--FF
		mod.ITEM.COLLECTIBLE.AZURITE_SPINDOWN,			--FF
		mod.ITEM.COLLECTIBLE.SNOW_GLOBE, 				--FF
		mod.ITEM.COLLECTIBLE.EXCELSIOR,					--FF
		mod.ITEM.COLLECTIBLE.HEART_OF_CHINA,			--FF
	}
	mod.ExternalGlassChestRarePoolAdditions = {}
	mod.RegisterCustomItemPool("GLASS_CHEST_RARE", mod.CustomItemPoolType.COLLECTIBLE, {"BaseGlassChestRarePool", "ExternalGlassChestRarePoolAdditions"})

	function mod.AddItemsToGlassChestRarePool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalGlassChestRarePoolAdditions, id)
		end
	end

	mod.BaseGlassChestTrinketPool = {
		TrinketType.TRINKET_TEARDROP_CHARM,				--139
		TrinketType.TRINKET_CRYSTAL_KEY,				--170
		TrinketType.TRINKET_ICE_CUBE,					--188
		mod.ITEM.TRINKET.SHARD_OF_CHINA,				--FF
		mod.ITEM.TRINKET.EXTRA_VESSEL,					--FF
		mod.ITEM.TRINKET.MASSIVE_AMETHYST,				--FF
		mod.ITEM.TRINKET.CURSED_URN,					--FF
		mod.ITEM.ROCK.TIME_LOST_DIAMOND,				--FF (Golem)
		mod.ITEM.ROCK.TWENTY_SIDED_EMERALD,				--FF (Golem)
		mod.ITEM.ROCK.TECHNOLOGICAL_RUBY_2,				--FF (Golem)
		mod.ITEM.ROCK.FIENDISH_AMETHYST,				--FF (Golem)
		mod.ITEM.ROCK.FRIENDLY_RAPID_FIRE_OPAL,			--FF (Golem)
	}
	mod.ExternalGlassChestTrinketPoolAdditions = {}
	mod.RegisterCustomItemPool("GLASS_CHEST_TRINKET", mod.CustomItemPoolType.TRINKET, {"BaseGlassChestTrinketPool", "ExternalGlassChestTrinketPoolAdditions"})

	function mod.AddItemsToGlassChestTrinketPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalGlassChestTrinketPoolAdditions, id)
		end
	end
end

do -- Robo Teller
	mod.BaseRoboTellerPool = {
		CollectibleType.COLLECTIBLE_DECK_OF_CARDS,
		CollectibleType.COLLECTIBLE_PRAYER_CARD,
		CollectibleType.COLLECTIBLE_STARTER_DECK,
		CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER,
		CollectibleType.COLLECTIBLE_TAROT_CLOTH,
		CollectibleType.COLLECTIBLE_BOOSTER_PACK,
		CollectibleType.COLLECTIBLE_CARD_READING,
		CollectibleType.COLLECTIBLE_ECHO_CHAMBER,
	}
	mod.ExternalRoboTellerPoolAdditions = {}

	mod.BaseRoboTellerTrinketPool = {
		TrinketType.TRINKET_FRAGMENTED_CARD,
		mod.ITEM.TRINKET.BIFURCATED_STARS,
		mod.ITEM.TRINKET.SPIRE_GROWTH,
		mod.ITEM.TRINKET.CONJOINED_CARD,
	}
	mod.ExternalRoboTellerTrinketPoolAdditions = {}

	mod.RegisterCustomItemPool("ROBO_TELLER", mod.CustomItemPoolType.MIXED, {
		Collectibles = {"BaseRoboTellerPool", "ExternalRoboTellerPoolAdditions"},
		Trinkets = {"BaseRoboTellerTrinketPool", "ExternalRoboTellerTrinketPoolAdditions"},
	})

	function mod.AddItemsToRoboTellerPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalRoboTellerPoolAdditions, id)
		end
	end

	function mod.AddTrinketsToRoboTellerPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalRoboTellerTrinketPoolAdditions, id)
		end
	end
end

do -- Penny Trinkets
	mod.BasePennyTrinketPool = {
		TrinketType.TRINKET_SWALLOWED_PENNY,
		TrinketType.TRINKET_BUTT_PENNY,
		TrinketType.TRINKET_BLOODY_PENNY,
		TrinketType.TRINKET_BURNT_PENNY,
		TrinketType.TRINKET_FLAT_PENNY,
		TrinketType.TRINKET_COUNTERFEIT_PENNY,
		TrinketType.TRINKET_ROTTEN_PENNY,
		TrinketType.TRINKET_BLESSED_PENNY,
		TrinketType.TRINKET_CHARGED_PENNY,
		TrinketType.TRINKET_CURSED_PENNY,
		mod.ITEM.TRINKET.MOLTEN_PENNY,
		mod.ITEM.TRINKET.GMO_PENNY,
		mod.ITEM.TRINKET.FUZZY_PENNY,
		mod.ITEM.TRINKET.SHARP_PENNY,
	}
	mod.ExternalPennyTrinketPoolAdditions = {}
	mod.RegisterCustomItemPool("PENNY_TRINKETS", mod.CustomItemPoolType.TRINKET, {"BasePennyTrinketPool", "ExternalPennyTrinketPoolAdditions"})

	function mod.AddItemsToPennyTrinketPool(itemList)
		for _, id in pairs(itemList) do
			table.insert(mod.ExternalPennyTrinketPoolAdditions, id)
		end
	end
end

--ENCYCLOPEDIA COMPAT (moving this here so i can just use the tables)
if Encyclopedia then
	-- Pools
	local FFItemPoolType = {
		POOL_DIRE_CHEST = Encyclopedia.GetItemPoolIdByName("POOL_DIRE_CHEST"),
		POOL_DEALER = Encyclopedia.GetItemPoolIdByName("POOL_DEALER"),
		POOL_ZODIAC_BEGGAR = Encyclopedia.GetItemPoolIdByName("POOL_ZODIAC_BEGGAR"),
		POOL_PUZZLE_PIECE = Encyclopedia.GetItemPoolIdByName("POOL_PUZZLE_PIECE"),
		POOL_BLACKSMITH = Encyclopedia.GetItemPoolIdByName("POOL_BLACKSMITH"),
		POOL_GLASS_CHEST = Encyclopedia.GetItemPoolIdByName("POOL_GLASS_CHEST"),
		POOL_ROBO_TELLER = Encyclopedia.GetItemPoolIdByName("POOL_ROBO_TELLER"),
	}

	local direSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 0)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_DIRE_CHEST, direSprite)

	local contraSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 1)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_DEALER, contraSprite)

	local zodiacSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 2)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_ZODIAC_BEGGAR, zodiacSprite)

	local puzzleSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 3)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_PUZZLE_PIECE, puzzleSprite)

	local smithSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 4)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_BLACKSMITH, smithSprite)

	local glassSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 5)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_GLASS_CHEST, glassSprite)

	local roboSprite = Encyclopedia.RegisterSprite("gfx/ui/ff_encyclo_itempools.anm2", "Idle", 6)
	Encyclopedia.AddItemPoolSprite(FFItemPoolType.POOL_ROBO_TELLER, roboSprite)
	
	for i, item in ipairs(mod.BaseDireChestPool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_DIRE_CHEST)
	end
	
	for i, item in ipairs(mod.BaseDrugDealerPool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_DEALER)
	end
	
	for i, item in ipairs(mod.BaseZodiacBeggarPool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_ZODIAC_BEGGAR)
	end
	
	local EncycloPuzzle = {
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BOBS_BRAIN),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_DEAD_CAT),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_YO_LISTEN),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_LITTLE_CHAD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BLOOD_PUPPY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_PONY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_GUPPYS_PAW),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_GOAT_HEAD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_PUNCHING_BAG),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_DEAD_BIRD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SMART_FLY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ANGRY_FLY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_YUCK_HEART),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_DEPRESSION),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_NECRONOMICON),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ABEL),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_PURITY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ROSARY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BETRAYAL),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_FRIEND_BALL),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MY_SHADOW),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ISAACS_HEART),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BLANKET),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_FRIEND_FINDER),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BLOOD_OATH),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_FATES_REWARD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MYSTERY_EGG),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_FATE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_INTRUDER),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SHADE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_2SPOOKY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MOMS_WIG),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_LEPROSY),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_NIGHT_LIGHT),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MOMS_PERFUME),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BLUE_BOX),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SPIDER_MOD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_VOODOO_HEAD),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BIBLE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_DARK_BUM),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_PACT),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_FRUITY_PLUM),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BUMBO),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BIG_FAN),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SWORN_PROTECTOR),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_CHAMPION_BELT),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_APPLE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BIRDS_EYE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_RED_STEW),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SAUSAGE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BREAKFAST),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ALMOND_MILK),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_SOY_MILK),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_WAIT_WHAT),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_CRACK_JACKS),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_MILK),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_BACON_GREASE),
		Encyclopedia.GetItem(CollectibleType.COLLECTIBLE_PET_ROCK),
	}
	
	for i, item in ipairs(EncycloPuzzle) do
		EncycloPuzzle[i].Pools = EncycloPuzzle[i].Pools or {}
		table.insert(EncycloPuzzle[i].Pools, FFItemPoolType.POOL_PUZZLE_PIECE)
	end
	
	for i, item in ipairs(mod.BaseBlacksmithPool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_BLACKSMITH)
	end

	for i, item in ipairs(mod.BaseGlassChestCommonPool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_GLASS_CHEST)
	end

	for i, item in ipairs(mod.BaseGlassChestRarePool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_GLASS_CHEST)
	end

	for i, item in ipairs(mod.BaseRoboTellerPool) do
		local entry = Encyclopedia.GetItem(item) or {}
		entry.Pools = entry.Pools or {}
		table.insert(entry.Pools, FFItemPoolType.POOL_ROBO_TELLER)
	end
end
