FiendFolio.ACHIEVEMENT = {
	-- Order of this table determines order of button appearance in menu

	-- To-do unlocks
	--[[
		Community Rocks:    Beat Challenge #FF_ - The Gauntlet
	]]

	{
		ID = "FIENDISH_FOES",
		AlwaysUnlocked = true,
		Note = "fiendish_foes",
		Tags = {"Misc"},
		NoInsertTags = {"Misc"},
		Tooltip = {"thank you", "for playing", "our mod"}
	},

	-- Character Unlocks
	{
		ID = "FIEND",
		AlwaysUnlocked = true,
		Note = "achievement_fiend",
		Name = "fiend",
		Tags = {"Fiend"},
		NoInsertTags = {"Fiend"},
		Tooltip = {"the iconic", "trickster", "returns"}
	},
	{
		ID = "GOLEM",
		AlwaysUnlocked = true,
		Note = "achievement_golem",
		Name = "golem",
		Tags = {"Golem"},
		NoInsertTags = {"Golem"},
		Tooltip = {"the mother", "orb's riddle", "was finally", "cracked!"}
	},
	{
		ID = "BIEND", -- used for save data and code access, don't change!
		Note = "achievement_fiendb",
		Name = "tainted fiend",
		Tooltip = {"open a", "certain closet", "as fiend"},
		Tags = {"BiendUnlock", "Character", "Biend"},
		NoInsertTags = {"Biend"}
	},

	-- Fiend Unlocks
	{
		ID = "IMMORAL_HEART",
		Note = "immoral_heart",
		Tooltip = {"beat", "mom", "as fiend"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "LIL_FIEND",
		Note = "lil_fiend",
		Item = FiendFolio.ITEM.COLLECTIBLE.LIL_FIEND,
		Tooltip = {"beat", "mom's heart", "on hard", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Heart"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "IMP_SODA",
		Note = "imp_soda",
		Item = FiendFolio.ITEM.COLLECTIBLE.IMP_SODA,
		Tooltip = {"beat", "isaac", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Isaac"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "HEART_OF_CHINA",
		Note = "heart_of_china",
		Item = FiendFolio.ITEM.COLLECTIBLE.HEART_OF_CHINA,
		Tooltip = {"beat", "???", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "BlueBaby"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "FIEND_MIX",
		Note = "fiend_mix",
		Item = FiendFolio.ITEM.COLLECTIBLE.FIEND_MIX,
		Tooltip = {"beat", "satan", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Satan"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "PRANK_COOKIE",
		Note = "prank_cookie",
		Item = FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE,
		Tooltip = {"beat", "the lamb", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Lamb"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "GMO_CORN",
		Note = "gmo_corn",
		Item = FiendFolio.ITEM.COLLECTIBLE.GMO_CORN,
		Tooltip = {"beat", "boss rush", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "BossRush"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "PLUS_3_FIREBALLS",
		Note = "3_fireballs",
		Card = FiendFolio.ITEM.CARD.PLUS_3_FIREBALLS,
		Name = "+3 fireballs",
		Tooltip = {"beat", "hush", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Hush"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "FIENDS_HORN",
		Note = "fiends_horn",
		Item = FiendFolio.ITEM.COLLECTIBLE.FIENDS_HORN,
		Name = "fiend's horn",
		Tooltip = {"beat", "delirium", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Delirium"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "PYROMANCY",
		Note = "pyromancy",
		Item = FiendFolio.ITEM.COLLECTIBLE.PYROMANCY,
		Tooltip = {"beat", "mega satan", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "MegaSatan"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "DEVILS_HARVEST",
		Note = "the_devils_harvest",
		Item = FiendFolio.ITEM.COLLECTIBLE.DEVILS_HARVEST,
		Name = "the devil's harvest",
		Tooltip = {"beat", "mother", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Mother"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "FETAL_FIEND",
		Note = "fetal_fiend",
		Item = FiendFolio.ITEM.COLLECTIBLE.FETAL_FIEND,
		Tooltip = {"beat", "beast", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Beast"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "COOL_SUNGLASSES",
		Note = "cool_sunglasses",
		Item = FiendFolio.ITEM.COLLECTIBLE.COOL_SUNGLASSES,
		Tooltip = {"beat", "greed mode", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Greed"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "JACK_CARDS",
		Note = "jack_cards",
		Card = {
			FiendFolio.ITEM.CARD.JACK_OF_CLUBS,
			FiendFolio.ITEM.CARD.MISPRINTED_JACK_OF_CLUBS,
			FiendFolio.ITEM.CARD.JACK_OF_DIAMONDS,
			FiendFolio.ITEM.CARD.JACK_OF_HEARTS,
			FiendFolio.ITEM.CARD.JACK_OF_SPADES
		},
		Tooltip = {"beat", "greedier mode", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "Greedier"},
		Tags = {"Fiend", "Character"}
	},
	{
		ID = "FIEND_FOLIO",
		Note = "fiendfolio",
		Item = FiendFolio.ITEM.COLLECTIBLE.FIEND_FOLIO,
		Name = "fiend folio",
		Tooltip = {"beat", "everything", "on hard", "as fiend"},
		CompletionMark = {FiendFolio.PLAYER.FIEND, "All"},
		Tags = {"Fiend", "Character"}
	},

	-- Biend Unlocks
	{
		ID = "CHUNK_OF_TAR",
		Note = "chunk_of_tar",
		Trinket = FiendFolio.ITEM.TRINKET.CHUNK_OF_TAR,
		Tooltip = {"beat isaac,", "???, satan", "and the lamb", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "Quartet"},
		Tags = {"Biend", "Character"}
	},
	{
		ID = "SOUL_OF_FIEND",
		Note = "soul_of_fiend",
		Card = FiendFolio.ITEM.CARD.SOUL_OF_FIEND,
		Tooltip = {"beat boss", "rush and hush", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "Duet"},
		Tags = {"Biend", "Character"}
	},
	{
		ID = "GOLDEN_SLOT_MACHINE",
		Note = "golden_slot_machine",
		Tooltip = {"beat", "mega satan", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "MegaSatan"},
		Tags = {"Biend", "Character"}
	},
	{
		ID = "REVERSE_3_FIREBALLS",
		Note = "3_fireballs_evil",
		Card = FiendFolio.ITEM.CARD.REVERSE_3_FIREBALLS,
		Name = "reverse +3 fireballs",
		Tooltip = {"beat", "greedier mode", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "Greedier"},
		Tags = {"Biend", "Character"}
	},
	{
		ID = "MALICE",
		Note = "malice",
		Item = FiendFolio.ITEM.COLLECTIBLE.MALICE,
		Tooltip = {"beat", "delirium", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "Delirium"},
		Tags = {"Biend", "Character"}
	},
	{
		ID = "HATRED",
		Note = "hatred",
		Trinket = FiendFolio.ITEM.TRINKET.HATRED,
		Tooltip = {"beat", "mother", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "Mother"},
		Tags = {"Biend", "Character"}
	},
	{
		ID = "MODERN_OUROBOROS",
		Note = "modern_ouroboros",
		Item = FiendFolio.ITEM.COLLECTIBLE.MODERN_OUROBOROS,
		Tooltip = {"beat", "beast", "as tainted", "fiend"},
		CompletionMark = {FiendFolio.PLAYER.BIEND, "Beast"},
		Tags = {"Biend", "Character"}
	},

	-- Golem Unlocks
	{
		ID = "PET_ROCK",
		Note = "pet_rock",
		Item = FiendFolio.ITEM.COLLECTIBLE.PET_ROCK,
		Tooltip = {"beat", "mom's heart", "on hard", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Heart"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "GOLEMS_ROCK",
		Note = "golems_rock",
		Item = FiendFolio.ITEM.COLLECTIBLE.GOLEMS_ROCK,
		Name = "golem's rock",
		Tooltip = {"beat", "isaac", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Isaac"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "GOLEMS_ORB",
		Note = "golems_orb",
		Item = FiendFolio.ITEM.COLLECTIBLE.GOLEMS_ORB,
		Name = "golem's orb",
		Tooltip = {"beat", "???", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "BlueBaby"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "CHERRY_BOMB",
		Note = "cherry_bomb",
		Item = FiendFolio.ITEM.COLLECTIBLE.CHERRY_BOMB,
		Tooltip = {"beat", "satan", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Satan"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "BRIDGE_BOMBS",
		Note = "bridge_bombs",
		Item = FiendFolio.ITEM.COLLECTIBLE.BRIDGE_BOMBS,
		Tooltip = {"beat", "the lamb", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Lamb"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "SOLEMN_VOW",
		Note = "solemn_vow",
		Trinket = FiendFolio.ITEM.TRINKET.SOLEMN_VOW,
		Tooltip = {"beat", "boss rush", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "BossRush"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "DICE_GOBLIN",
		Note = "dice_goblin",
		Item = FiendFolio.ITEM.COLLECTIBLE.DICE_GOBLIN,
		Tooltip = {"beat", "hush", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Hush"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "PERFECTLY_GENERIC_OBJECT",
		Note = "pgo",
		Item = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4,
		Tooltip = {"beat", "delirium", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Delirium"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "MASSIVE_AMETHYST",
		Note = "massive_amethyst",
		Trinket = FiendFolio.ITEM.TRINKET.MASSIVE_AMETHYST,
		Tooltip = {"beat", "mega satan", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "MegaSatan"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "ETERNAL_D12",
		Note = "eternal_d12",
		Item = FiendFolio.ITEM.COLLECTIBLE.ETERNAL_D12,
		Tooltip = {"beat", "mother", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Mother"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "ASTROPULVIS",
		Note = "astropulvis",
		Item = FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS,
		Tooltip = {"beat", "beast", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Beast"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "MOLTEN_PENNY",
		Note = "molten_penny",
		Trinket = FiendFolio.ITEM.TRINKET.MOLTEN_PENNY,
		Tooltip = {"beat", "greed mode", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Greed"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "NYX",
		Note = "nyx",
		Item = FiendFolio.ITEM.COLLECTIBLE.NYX,
		Tooltip = {"beat", "greedier mode", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "Greedier"},
		Tags = {"Golem", "Character"}
	},
	{
		ID = "SNOW_GLOBE",
		Note = "snow_globe",
		Item = FiendFolio.ITEM.COLLECTIBLE.SNOW_GLOBE,
		Tooltip = {"beat", "everything", "on hard", "as golem"},
		CompletionMark = {FiendFolio.PLAYER.GOLEM, "All"},
		Tags = {"Golem", "Character"}
	},

	-- Misc Unlocks
	{
		ID = "PURPLE_PUTTY",
		Note = "purple_putty",
		Item = FiendFolio.ITEM.COLLECTIBLE.PURPLE_PUTTY,
		Tooltip = {"kill", "50 enemies", "with immoral", "minions"},
		Tags = {"Misc"}
	},
	{
		ID = "FIEND_HEART",
		Note = "aehrt",
		Name = ">3",
		Item = FiendFolio.ITEM.COLLECTIBLE.FIEND_HEART,
		Tooltip = {"have 6 or", "more immoral", "hearts at once"},
		ViewerTooltip = {"have 6 or more immoral hearts", "at once"},
		Tags = {"Misc"},
		ViewerDisplayIf = function()
			return FiendFolio.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked()
		end,
	},
	{
		ID = "DEVILLED_EGG",
		Note = "devilled_egg",
		Item = FiendFolio.ITEM.COLLECTIBLE.DEVILLED_EGG,
		Tooltip = {"kill", "greg the egg"},
		Tags = {"Misc"}
	},
	{
		ID = "SKIP_CARD",
		Note = "skip_card",
		Card = FiendFolio.ITEM.CARD.SKIP_CARD,
		Tooltip = {"skip 20", "rooms"},
		Tags = {"Misc"}
	},
	{
		ID = "ZODIAC_BEGGAR",
		Note = "zodiac_beggar",
		Tooltip = {"enter a", "planetarium"},
		Tags = {"Misc"}
	},
	{
		ID = "FRAUDULENT_FUNGUS",
		Note = "fraudulent_fungus",
		Item = FiendFolio.ITEM.COLLECTIBLE.FRAUDULENT_FUNGUS,
		Tooltip = {"have 3", "or more", "rotten hearts", "at once"},
		Tags = {"Misc"}
	},
	{
		ID = "EVIL_STICKER",
		Note = "evil_sticker",
		Item = FiendFolio.ITEM.COLLECTIBLE.EVIL_STICKER,
		Tooltip = {"get the worst", "cursed penny", "payout"},
		Tags = {"Misc"}
	},
	{
		ID = "GOLDEN_CURSED_PENNY",
		Note = "golden_cursed_penny",
		Tooltip = {"pick up 50", "cursed pennies"},
		Tags = {"Misc"}
	},
	{
		ID = "BLACK_LANTERN",
		Note = "black_lantern",
		Item = FiendFolio.ITEM.COLLECTIBLE.BLACK_LANTERN,
		Tooltip = {"kill", "gravedigger"},
		Tags = {"Misc"}
	},
	{
		ID = "RISKS_REWARD",
		Note = "risks_reward",
		Item = FiendFolio.ITEM.COLLECTIBLE.RISKS_REWARD,
		Tooltip = {"kill", "psion"},
		Tags = {"Misc"}
	},
	{
		ID = "FLEA_OF_MELTDOWN",
		Note = "flea_of_meltdown",
		Trinket = FiendFolio.ITEM.TRINKET.FLEA_MELTDOWN,
		Tooltip = {"kill", "meltdown", "3 times"},
		Tags = {"Misc"}
	},
	{
		ID = "FLEA_OF_DELUGE",
		Note = "flea_of_deluge",
		Trinket = FiendFolio.ITEM.TRINKET.FLEA_DELUGE,
		Tooltip = {"kill", "meltdown", "3 times"},
		Tags = {"Misc"}
	},
	{
		ID = "FLEA_OF_POLLUTION",
		Note = "flea_of_pollution",
		Trinket = FiendFolio.ITEM.TRINKET.FLEA_POLLUTION,
		Tooltip = {"kill", "pollution", "3 times"},
		Tags = {"Misc"}
	},
	{
		ID = "FLEA_OF_PROPAGANDA",
		Note = "flea_of_propaganda",
		Trinket = FiendFolio.ITEM.TRINKET.FLEA_PROPAGANDA,
		Tooltip = {"kill", "pollution", "3 times"},
		Tags = {"Misc"}
	},
	{
		ID = "FLEA_CIRCUS",
		Note = "flea_circus",
		Trinket = FiendFolio.ITEM.TRINKET.FLEA_CIRCUS,
		Tooltip = {"unlock every", "apocalypse", "flea"},
		Tags = {"Misc"}
	},
	{
		ID = "BEAST_BEGGAR",
		Note = "evil_beggar",
		Tooltip = {"kill", "the beast"},
		Tags = {"Misc"}
	},
	{
		ID = "SOUL_OF_RANDOM",
		Note = "soul_of_random",
		Card = FiendFolio.ITEM.CARD.SOUL_OF_RANDOM,
		Tooltip = {"unlock half", "of all", "soul stones"},
		Tags = {"Misc"}
	},
	{
		ID = "MERN",
		Note = "mern",
		Item = FiendFolio.ITEM.COLLECTIBLE.CORN_KERNEL,
		Tooltip = {"build a mern"},
		Tags = {"Misc"}
	},
	{
		ID = "BIFURCATED_STARS",
		Note = "bifurcated_stars",
		Trinket = FiendFolio.ITEM.TRINKET.BIFURCATED_STARS,
		-- Tooltip = {"enter an", "item room", "you skipped", "during ascent"}, -- This quite heavily reads to me like you have to skip an item room during ascent and somehow get back to it
		Tooltip = {"enter an", "ascent item", "room you had", "previously", "skipped"},
		Tags = {"Misc"}
	},
	{
		ID = "DELUXE",
		Note = "the_deluxe",
		Item = FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE,
		Tooltip = {"unlock every", "type of heart"},
		Tags = {"Misc"}
	},
	{
		ID = "QUEEN_OF_CLUBS",
		Note = "queen_of_clubs",
		Card = FiendFolio.ITEM.CARD.QUEEN_OF_CLUBS,
		Tooltip = {"kill", "singe"},
		Tags = {"Misc"}
	},
	{
		ID = "THIRTEEN_OF_STARS",
		Note = "13_of_stars",
		Card = FiendFolio.ITEM.CARD.THIRTEEN_OF_STARS,
		Tooltip = {"chance when", "using a new", "tmtrainer", "item"},
		Tags = {"Misc"},
		Challenge = true,
	},
	{
		ID = "MINOR_ARCANA_KINGS",
		Note = "kings_minor_arcana",
		Card = {
			FiendFolio.ITEM.CARD.KING_OF_WANDS,
			FiendFolio.ITEM.CARD.KING_OF_PENTACLES,
			FiendFolio.ITEM.CARD.KING_OF_SWORDS,
			FiendFolio.ITEM.CARD.KING_OF_CUPS,
		},
		Tooltip = {"unlock:", "", "horse pills", "gold trinkets", "gold batteries"},
		ViewerTooltip = {"unlock horse pills, gold trinkets,", "and gold batteries"},
		Tags = {"Misc"}
	},
	{
		ID = "KING_OF_DIAMONDS",
		Note = "king_of_diamonds",
		Card = FiendFolio.ITEM.CARD.KING_OF_DIAMONDS,
		Tooltip = {"blow up", "25 fool's", "gold rocks"},
		Tags = {"Misc"}
	},
	{
		ID = "PLAGUE_OF_DECAY",
		Note = "plague_of_decay",
		Card = FiendFolio.ITEM.CARD.PLAGUE_OF_DECAY,
		Tooltip = {"bomb a", "rotten beggar"},
		Tags = {"Misc"}
	},
	{
		ID = "IMPLOSION",
		Note = "implosion",
		Card = FiendFolio.ITEM.CARD.IMPLOSION,
		Tooltip = {"kill 50", "enemies using", "malice's", "fireball"},
		Tags = {"Misc"}
	},
	{
		ID = "SOUL_OF_GOLEM",
		Note = "soul_of_golem",
		Card = FiendFolio.ITEM.CARD.SOUL_OF_GOLEM,
		Tooltip = {"use any", "soul stone", "as golem"},
		Tags = {"Misc"}
	},
	{
		ID = "GOLDEN_REWARD_PLATE",
		Note = "golden_button",
		Tooltip = {"press 79", "reward plates"},
		Tags = {"Misc"}
	},
	{
		ID = "GLASS_CHEST",
		Note = "glass_chest",
		Tooltip = {"kill a boss", "in the mirror", "dimension"},
		Tags = {"Misc"},
	},
	{
		ID = "HAUNTED_PENNY",
		Note = "haunted_penny",
		Tooltip = {"have 8", "virtues wisps", "at once"},
		Tags = {"Misc"},
	},
	{
		ID = "SHARD_OF_CHINA",
		Note = "shard_of_china",
		Trinket = FiendFolio.ITEM.TRINKET.SHARD_OF_CHINA,
		Tooltip = {"die as china"},
		Tags = {"Misc"},
		Challenge = true,
	},
	{
		ID = "DIRE_CHEST",
		Note = "dire_chest",
		Trinket = FiendFolio.ITEM.TRINKET.MIDDLE_HAND,
		-- Tooltip = {"complete the", "brown ritual"},
		Tooltip = {"convert a red", "chest into a", "dire chest", "using the", "secret method", "---------", "or make the", "middle hand"},
		ViewerTooltip = {"convert a red chest into a dire chest", "or make the middle hand"},
		Tags = {"Misc"},
	},
	{
		ID = "52_DECK",
		Note = "52_deck",
		Tooltip = {"trounce the", "poker table", "dealer and", "make him", "ragequit"},
		Tags = {"Misc"},
	},
	{
		ID = "RIGHT_HAND",
		Note = "the_right_hand",
		Trinket = FiendFolio.ITEM.TRINKET.RIGHT_HAND,
		Tooltip = {"kill ???", "while holding", "the left hand"},
		Tags = {"Misc"},
	},
	{
		ID = "MORBUS",
		Note = "morbus",
		Tooltip = {"enter", "the corpse"},
		Tags = {"Misc"},
		NoMenu = true,
		AlwaysUnlock = true, -- Ignores canAchievementsUnlock and canChallengeAchievementsUnlock
	},
	{
		ID = "MORBID_HEART",
		Note = "morbid_heart",
		Item = {
			FiendFolio.ITEM.COLLECTIBLE.DADS_DIP,
			FiendFolio.ITEM.COLLECTIBLE.YICK_HEART,
		},
		Tooltip = {"kill mr dead"},
		Tags = {"Misc"},
	},

	-- Challenge Unlocks
	{
		ID = "SLIPPYS_ORGANS",
		Note = "slippys_organs",
		Name = "slippy's organs",
		Item = {
			FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_GUTS,
			FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_HEART,
			FiendFolio.ITEM.COLLECTIBLE.FROG_HEAD
		},
		Trinket = FiendFolio.ITEM.TRINKET.FROG_PUPPET,
		Tooltip = {"complete", "frog mode", "---------", "unlocks", "4 items"},
		ViewerTooltip = {"complete frog mode"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "DEIMOS",
		Note = "deimos",
		Item = FiendFolio.ITEM.COLLECTIBLE.DEIMOS,
		Tooltip = {"complete", "isaac rebuilt"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "LAWN_DARTS",
		Note = "lawn_darts",
		Item = FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS,
		Tooltip = {"complete", "tower offense"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "CHINAS_BELONGINGS",
		Note = "chinas_belongings",
		Name = "china's belongings",
		Trinket = {
			FiendFolio.ITEM.TRINKET.HEARTACHE,
			FiendFolio.ITEM.TRINKET.CURSED_URN,
		},
		Tooltip = {"complete", "handle with", "care", "---------", "unlocks", "2 items"},
		ViewerTooltip = {"complete handle with care"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "GAUNTLET_BEATEN",
		Note = "achievement_community",
		Name = "community achievement",
		Item = FiendFolio.ITEM.COLLECTIBLE.COMMUNITY_ACHIEVEMENT,
		Tooltip = {"complete", "the gauntlet"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "BRICK_SEPARATOR",
		Note = "brick_seperator",
		Card = FiendFolio.ITEM.CARD.BRICK_SEPERATOR,
		Tooltip = {"complete", "brick by brick"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "GREEN_HOUSE",
		Note = "green_house",
		Card = FiendFolio.ITEM.CARD.GREEN_HOUSE,
		Tooltip = {"complete", "dad's home+"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "PETRIFIED_GEL",
		Note = "petrified_gel",
		Trinket = FiendFolio.ITEM.TRINKET.PETRIFIED_GEL,
		Tooltip = {"complete", "dirty bubble", "challenge"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "SPARE_RIBS",
		Note = "spare_ribs",
		Item = FiendFolio.ITEM.COLLECTIBLE.SPARE_RIBS,
		Tooltip = {"complete", "the real jon"},
		Tags = {"Challenge"},
		Challenge = true,
	},
	{
		ID = "RED_HAND",
		Note = "red_hand",
		Trinket = FiendFolio.ITEM.TRINKET.REDHAND,
		Tooltip = {"complete", "hands on"},
		Tags = {"Challenge"},
		Challenge = true,
	},

	-- hidden tracker achievements
	{
		ID = "ETERNAL_REWARD_OBTAINED",
		NoMenu = true,
		Challenge = true,
		NoCountCompletion = true
	}
}

local mod = FiendFolio
local game = Game()

-- autogenerated from achievements
local lockedItems = {}
local lockedTrinkets = {}
local lockedCards = {}

local playerToCompletionManagerName = {
	[FiendFolio.PLAYER.FIEND] = "Fiend",
	[FiendFolio.PLAYER.BIEND] = "FiendB",
	[FiendFolio.PLAYER.GOLEM] = "Golem"
}

local Achievement = StageAPI.Class("Achievement")

function Achievement:Init(id, tbl)
	self.ID = id

	if tbl.Note then
		self.Note = "gfx/ui/achievement/" .. tbl.Note .. ".png"
		self.Sprite = Sprite()
		self.Sprite:Load("gfx/ui/achievement/_ff_achievement.anm2", false)
		self.Sprite:ReplaceSpritesheet(0, "gfx/nothing.png")
		self.Sprite:ReplaceSpritesheet(2, self.Note)
		self.Sprite:LoadGraphics()
	end

	if tbl.Item then
		self.Item = tbl.Item
		if type(tbl.Item) ~= "table" then
			self.Item = {tbl.Item}
		end

		for _, item in ipairs(self.Item) do
			lockedItems[item] = self
		end
	end

	if tbl.Card then
		self.Card = tbl.Card
		if type(tbl.Card) ~= "table" then
			self.Card = {tbl.Card}
		end

		for _, card in ipairs(self.Card) do
			lockedCards[card] = self
		end
	end

	if tbl.Trinket then
		self.Trinket = tbl.Trinket
		if type(tbl.Trinket) ~= "table" then
			self.Trinket = {tbl.Trinket}
		end

		for _, trinket in ipairs(self.Trinket) do
			lockedTrinkets[trinket] = self
		end
	end

	if tbl.CompletionMark then
		self.CompletionMark = {
			Player = tbl.CompletionMark[1],
			Mark = tbl.CompletionMark[2]
		}
		self.CompletionMark.PlayerName = playerToCompletionManagerName[self.CompletionMark.Player]
	end

	self.Tags = {}
	if tbl.Tags then
		for i, tag in ipairs(tbl.Tags) do
			self.Tags[i] = tag
			self.Tags[tag] = true
		end
	end

	self.NoInsertTags = {}
	if tbl.NoInsertTags then
		for i, tag in ipairs(tbl.NoInsertTags) do
			self.NoInsertTags[i] = tag
			self.NoInsertTags[tag] = true
		end
	end

	self.Name = tbl.Name
	self.Group = tbl.Group
	self.NoMenu = tbl.NoMenu
	if tbl.Tooltip then
		if not self.Name then
			self.Name = string.gsub(string.lower(tbl.Note), "_", " ")
		end

		self.Tooltip = tbl.Tooltip

		if not self.NoMenu then
			self.MenuButton = {
				str = self.Name,
				choices = {"locked", "unlocked"},
				variable = self.ID,
				setting = 1,
				load = function()
					return self:IsUnlocked(true) and 2 or 1
				end,
				store = function(var)
					self:SetUnlocked(var == 2)
				end,
				changefunc = function(button)
					self:SetUnlocked(button.setting == 2)
				end,
				tooltip = {strset = self.Tooltip}
			}
		end
	end

	if tbl.ViewerTooltip then
		self.ViewerTooltip = tbl.ViewerTooltip
	end

	self.ViewerDisplayIf = tbl.ViewerDisplayIf

	self.NoCountCompletion = tbl.NoCountCompletion -- Achievement is not required for 100% completion
	self.AlwaysUnlocked    = tbl.AlwaysUnlocked	   -- Achievement is always unlocked, will always be visible on the viewer, and has no unlock condition
	self.AlwaysUnlock 	   = tbl.AlwaysUnlock 	   -- Achievement cannot be blocked from unlocking except by Basement Renovator
	self.Challenge 		   = tbl.Challenge 		   -- Achievement uses the Challenge unlocks condition to test whether this unlock should be prevented
	self.Unobtainable 	   = tbl.Unobtainable	   -- In case you want to make an unobtainable achievement for some reason?

	if self.Unobtainable or self.AlwaysUnlocked then
		self.NoCountCompletion = true
	end
end

function Achievement:IsUnlocked(ignoreModifiers)
	if self.Unobtainable then
		return false
	end

	if self.AlwaysUnlocked then
		return true
	end

	local canLock = FiendFolio.AreAchievementsEnabled()
	if not canLock and not ignoreModifiers then
		return true
	end

	-- sometimes unlock checks will run before save data is loaded
	return FiendFolio.savedata.achievements and FiendFolio.savedata.achievements[self.ID] == true
end

function Achievement:Unlock(noNote)
	if self.Unobtainable or self.AlwaysUnlocked then
		return
	end

	if not self:IsUnlocked(true) then
		local canLock, canUnlockAchievements, canUnlockChallengeAchievements, blockAlwaysUnlock = FiendFolio.AreAchievementsEnabled()
		if canUnlockAchievements or (canUnlockChallengeAchievements and self.Challenge) or (self.AlwaysUnlock and not blockAlwaysUnlock) then
			self:SetUnlocked(true)

			if canLock and not noNote then
				FiendFolio.QueueAchievementNote(self.Note)
				FiendFolio.PostAchievementUpdate(noNote)
			end
		end
	end
end

function Achievement:SetUnlocked(bool)
	if not self.AlwaysUnlocked then
		FiendFolio.savedata.achievements[self.ID] = bool
	end
end

FiendFolio.ACHIEVEMENT_ORDERED = {}
FiendFolio.TOTAL_COMPLETION_ACHIEVEMENTS = 0

for i, achievementData in ipairs(FiendFolio.ACHIEVEMENT) do
	local achievement = Achievement(achievementData.ID, achievementData)
	if not achievement.NoCountCompletion then
		FiendFolio.TOTAL_COMPLETION_ACHIEVEMENTS = FiendFolio.TOTAL_COMPLETION_ACHIEVEMENTS + 1
	end

	FiendFolio.ACHIEVEMENT[i] = nil
	FiendFolio.ACHIEVEMENT[achievementData.ID] = achievement
	FiendFolio.ACHIEVEMENT_ORDERED[i] = FiendFolio.ACHIEVEMENT[achievementData.ID]
end

-- Returns:
--[[
	1: Can achievements lock features
	2: Can achievements be unlocked
	3: Can achievements with the Challenge attribute be unlocked
	4: Are achievements with the AlwaysUnlock attribute blocked
]]
function FiendFolio.AreAchievementsEnabled()
	if BasementRenovator and BasementRenovator.InTestRoom and BasementRenovator.InTestStage and (BasementRenovator:InTestRoom() or BasementRenovator:InTestStage()) then
		return false, false, false, true
	end

	if FiendFolio.savedata.disableAchievements then
		return false, FiendFolio.CanRunUnlockAchievements(), FiendFolio.CanChallengeRunUnlockAchievements(), false
	end

	return true, FiendFolio.CanRunUnlockAchievements(), FiendFolio.CanChallengeRunUnlockAchievements(), false
end

function FiendFolio.GetNumCompletedAchievements()
	local count = 0
	for _, achievement in ipairs(FiendFolio.ACHIEVEMENT_ORDERED) do
		if achievement:IsUnlocked(true) and not achievement.NoCountCompletion then
			count = count + 1
		end
	end

	return count
end

function FiendFolio.GetAchievementsWithTag(tag)
	local achievements = {}
	for _, achievement in ipairs(FiendFolio.ACHIEVEMENT_ORDERED) do
		if not tag or achievement.Tags[tag] then
			achievements[#achievements + 1] = achievement
		end
	end

	return achievements
end

function FiendFolio.GetMenuButtonsForAchievementTag(tag)
	local achievements = FiendFolio.GetAchievementsWithTag(tag)
	local buttons = {}
	for _, achievement in ipairs(achievements) do
		if achievement.MenuButton and not achievement.NoInsertTags[tag] then
			if #buttons ~= 0 then
				buttons[#buttons + 1] = {str = "", fsize = 1, nosel = true}
			end

			buttons[#buttons + 1] = achievement.MenuButton
		end
	end

	return buttons
end

function FiendFolio.GetAchievementCompletionMarkData(playerType)
	local out = {}
	for _, achievement in ipairs(FiendFolio.ACHIEVEMENT_ORDERED) do
		if achievement.CompletionMark and achievement.CompletionMark.Player == playerType then
			out[achievement.CompletionMark.Mark] = {
				"null",
				nil,
				function()
					achievement:Unlock()
				end
			}
		end
	end

	return out
end

function FiendFolio.InitCharacterCompletionMarks()
	mod.InitCharacterCompletion("Fiend", false)
	mod.AssociateCompletionUnlocks(FiendFolio.PLAYER.FIEND, FiendFolio.GetAchievementCompletionMarkData(FiendFolio.PLAYER.FIEND))

	mod.InitCharacterCompletion("Fiend", true)
	mod.AssociateCompletionUnlocks(FiendFolio.PLAYER.BIEND, FiendFolio.GetAchievementCompletionMarkData(FiendFolio.PLAYER.BIEND))

	mod.InitCharacterCompletion("Golem", false)
	mod.AssociateCompletionUnlocks(FiendFolio.PLAYER.GOLEM, FiendFolio.GetAchievementCompletionMarkData(FiendFolio.PLAYER.GOLEM))
end

-- If for some reason you get all completion marks, and then choose to re-lock the items locked behind them, this will unlock them on game start
function FiendFolio.TryUnlockCompletionAchievements()
	for _, achievement in ipairs(FiendFolio.ACHIEVEMENT_ORDERED) do
		if achievement.CompletionMark and not achievement:IsUnlocked() then
			if mod.IsCompletionMarkUnlocked(achievement.CompletionMark.PlayerName, achievement.CompletionMark.Mark) then
				achievement:Unlock(true)
			end
		end
	end
end

-- Basics, remove not-unlocked collectibles, trinkets, cards from pool
function FiendFolio.IsCollectibleLocked(id, ignoreModifiers)
	if lockedItems[id] then
		return not lockedItems[id]:IsUnlocked(ignoreModifiers)
	else
		return false
	end
end

function FiendFolio.IsTrinketLocked(id, ignoreModifiers)
	if lockedTrinkets[id] then
		return not lockedTrinkets[id]:IsUnlocked(ignoreModifiers)
	else
		return false
	end
end

function FiendFolio.IsCardLocked(id, ignoreModifiers)
	if lockedCards[id] then
		return not lockedCards[id]:IsUnlocked(ignoreModifiers)
	else
		return false
	end
end

FiendFolio.AchievementTrackerTrinkets = {
	IsaacSoulUnlocked 		= Isaac.GetTrinketIdByName("ISAAC_SOUL_TRACKER"),
	MaggySoulUnlocked 		= Isaac.GetTrinketIdByName("MAGGY_SOUL_TRACKER"),
	CainSoulUnlocked 		= Isaac.GetTrinketIdByName("CAIN_SOUL_TRACKER"),
	JudasSoulUnlocked 		= Isaac.GetTrinketIdByName("JUDAS_SOUL_TRACKER"),
	BlueBabySoulUnlocked 	= Isaac.GetTrinketIdByName("BLUE_BABY_SOUL_TRACKER"),
	EveSoulUnlocked 		= Isaac.GetTrinketIdByName("EVE_SOUL_TRACKER"),
	SamsonSoulUnlocked 		= Isaac.GetTrinketIdByName("SAMSON_SOUL_TRACKER"),
	AzazelSoulUnlocked 		= Isaac.GetTrinketIdByName("AZAZEL_SOUL_TRACKER"),
	LazarusSoulUnlocked 	= Isaac.GetTrinketIdByName("LAZARUS_SOUL_TRACKER"),
	EdenSoulUnlocked 		= Isaac.GetTrinketIdByName("EDEN_SOUL_TRACKER"),
	LostSoulUnlocked 		= Isaac.GetTrinketIdByName("LOST_SOUL_TRACKER"),
	LilithSoulUnlocked 		= Isaac.GetTrinketIdByName("LILITH_SOUL_TRACKER"),
	KeeperSoulUnlocked 		= Isaac.GetTrinketIdByName("KEEPER_SOUL_TRACKER"),
	ApollyonSoulUnlocked 	= Isaac.GetTrinketIdByName("APOLLYON_SOUL_TRACKER"),
	ForgottenSoulUnlocked 	= Isaac.GetTrinketIdByName("FORGOTTEN_SOUL_TRACKER"),
	BethanySoulUnlocked 	= Isaac.GetTrinketIdByName("BETHANY_SOUL_TRACKER"),
	JacobSoulUnlocked 		= Isaac.GetTrinketIdByName("JACOB_SOUL_TRACKER"),
	HorsePillsUnlocked		= Isaac.GetTrinketIdByName("HORSE_PILLS_TRACKER"),
	GoldenBatteryUnlocked	= Isaac.GetTrinketIdByName("GOLDEN_BATTERY_TRACKER"),
	GoldenTrinketsUnlocked	= Isaac.GetTrinketIdByName("GOLDEN_TRINKETS_TRACKER"),
	GoldenHeartsUnlocked	= Isaac.GetTrinketIdByName("GOLDEN_HEART_TRACKER"),
	HalfSoulHeartsUnlocked	= Isaac.GetTrinketIdByName("HALF_SOUL_HEART_TRACKER"), -- Technically just an Everything is Terrible!!! tracker
	ScaredHeartsUnlocked	= Isaac.GetTrinketIdByName("SCARED_HEART_TRACKER"),
	BoneHeartsUnlocked		= Isaac.GetTrinketIdByName("BONE_HEART_TRACKER"),
	RottenHeartsUnlocked	= Isaac.GetTrinketIdByName("ROTTEN_HEART_TRACKER"),
	GoldenPillsUnlocked		= Isaac.GetTrinketIdByName("GOLDEN_PILL_TRACKER"),
	GoldenBombsUnlocked		= Isaac.GetTrinketIdByName("GOLDEN_BOMB_TRACKER"),
	LuckyPennyUnlocked		= Isaac.GetTrinketIdByName("LUCKY_PENNY_TRACKER"),
	StickyNickelUnlocked	= Isaac.GetTrinketIdByName("STICKY_NICKEL_TRACKER"),
	GoldenPennyUnlocked		= Isaac.GetTrinketIdByName("GOLDEN_PENNY_TRACKER"),
	ChargedKeyUnlocked		= Isaac.GetTrinketIdByName("CHARGED_KEY_TRACKER"),
	CellarUnlocked			= Isaac.GetTrinketIdByName("CELLAR_TRACKER"),
	WombUnlocked			= Isaac.GetTrinketIdByName("WOMB_TRACKER"), -- This is the achievement that determines whether having mods enabled disables unlocks
	HagalazUnlocked			= Isaac.GetTrinketIdByName("HAGALAZ_TRACKER"),
	JeraUnlocked			= Isaac.GetTrinketIdByName("JERA_TRACKER"),
	EhwazUnlocked			= Isaac.GetTrinketIdByName("EHWAZ_TRACKER"),
	DagazUnlocked			= Isaac.GetTrinketIdByName("DAGAZ_TRACKER"),
	AnsuzUnlocked			= Isaac.GetTrinketIdByName("ANSUZ_TRACKER"),
	PerthroUnlocked			= Isaac.GetTrinketIdByName("PERTHRO_TRACKER"),
	BerkanoUnlocked			= Isaac.GetTrinketIdByName("BERKANO_TRACKER"),
	AlgizUnlocked			= Isaac.GetTrinketIdByName("ALGIZ_TRACKER"),
	BlankRuneUnlocked		= Isaac.GetTrinketIdByName("BLANK_RUNE_TRACKER"),
	BlackRuneUnlocked		= Isaac.GetTrinketIdByName("BLACK_RUNE_TRACKER"),
	BlackSackUnlocked		= Isaac.GetTrinketIdByName("BLACK_SACK_TRACKER"),
}

if Encyclopedia then
	for _, id in pairs(FiendFolio.AchievementTrackerTrinkets) do
		Encyclopedia.AddTrinket({
			Class = "Fiend Folio",
			ID = id,
			WikiDesc = "",
			Hide = true,
			ModName = "Fiend Folio",
		})
	end
end

local achievementTrackerIds = {}
for name, id in pairs(FiendFolio.AchievementTrackerTrinkets) do
	achievementTrackerIds[id] = true
	ffAzuriteSpindownList[id] = true
end

FiendFolio.TrinketsByID = {}
for name, id in pairs(FiendFolio.ITEM.TRINKET) do
	FiendFolio.TrinketsByID[id] = true
end

FiendFolio.ItemsByID = {}
for name, id in pairs(FiendFolio.ITEM.COLLECTIBLE) do
	FiendFolio.ItemsByID[id] = true
end

FiendFolio.CardsByID = {}
for name, id in pairs(FiendFolio.ITEM.CARD) do
	FiendFolio.CardsByID[id] = true
end

function FiendFolio.RemoveLockedCollectiblesFromPool()
	local pool = game:GetItemPool()
	for id, achievement in pairs(lockedItems) do
		if not achievement:IsUnlocked() then
			pool:RemoveCollectible(id)
		end
	end

	if not FiendFolio.ItemsEnabled then
		for _, id in pairs(FiendFolio.ITEM.COLLECTIBLE) do
			pool:RemoveCollectible(id)
		end
	end
end

function FiendFolio.RemoveLockedTrinketsFromPool()
	local pool = game:GetItemPool()
	for id, achievement in pairs(lockedTrinkets) do
		if not achievement:IsUnlocked() then
			pool:RemoveTrinket(id)
		end
	end

	for id, _ in pairs(achievementTrackerIds) do
		pool:RemoveTrinket(id)
	end

	if not FiendFolio.ItemsEnabled then
		for _, id in pairs(FiendFolio.ITEM.TRINKET) do
			pool:RemoveTrinket(id)
		end
	end
end

function FiendFolio.RemoveLockedFromPools()
	FiendFolio.RemoveLockedCollectiblesFromPool()
	FiendFolio.RemoveLockedTrinketsFromPool()
end

local antiRecursion
--[[
mod:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, card, canSuit, canRune, forceRune)
	if (mod.IsCardLocked(card) or FiendFolio.NoCardNaturalSpawn(card)) and not antiRecursion then
		antiRecursion = true

		local itempool = game:GetItemPool()
		local new
		local i = 0

		repeat
			i = i + 1
			new = itempool:GetCard(rng:GetSeed() + i, canSuit, canRune, forceRune)
		until not (mod.IsCardLocked(new) or FiendFolio.NoCardNaturalSpawn(new))

		antiRecursion = false

		return new
	end
end)]]

mod:AddCallback(ModCallbacks.MC_GET_TRINKET, function(_, trinket, rng)
	if (achievementTrackerIds[trinket] or mod.IsTrinketLocked(trinket) or (not FiendFolio.ItemsEnabled and FiendFolio.TrinketsByID[trinket])) and not antiRecursion then
		antiRecursion = true

		mod.RemoveLockedTrinketsFromPool()

		local itempool = game:GetItemPool()
		local new = itempool:GetTrinket()

		antiRecursion = false

		return new
	end
end)

function FiendFolio.InitAchievementTrackers()
	local itempool = game:GetItemPool()
	FiendFolio.AchievementTrackers = {}
	for name, id in pairs(FiendFolio.AchievementTrackerTrinkets) do
		FiendFolio.AchievementTrackers[name] = itempool:RemoveTrinket(id)
	end

	FiendFolio.PostAchievementUpdate()
end

function FiendFolio.AchievementsPostGameStart()
	FiendFolio.TryUnlockCompletionAchievements()
	FiendFolio.InitAchievementTrackers()
	FiendFolio.RemoveLockedFromPools()

	FiendFolio.TryLockBiendInHome()
end

function FiendFolio.GetAchievementSetUnlockCount(set)
	local count = 0
	for _, name in ipairs(set) do
		if FiendFolio.AchievementTrackers[name] == true then
			count = count + 1
		elseif FiendFolio.ACHIEVEMENT[name] then
			if FiendFolio.ACHIEVEMENT[name]:IsUnlocked(true) then
				count = count + 1
			end
		end
	end

	return count
end

function FiendFolio.IsAchievementSetUnlocked(set)
	return FiendFolio.GetAchievementSetUnlockCount(set) == #set
end

function FiendFolio.CanRunUnlockAchievements(forceNew) -- Made in conjunction with Thicco Catto
	if mod.CurrentRunCanGrantUnlocks ~= nil and not forceNew then return mod.CurrentRunCanGrantUnlocks end

	local machine = Isaac.Spawn(6, 11, 0, Vector.Zero, Vector.Zero, nil)
	mod.CurrentRunCanGrantUnlocks = machine:Exists()
	machine:Remove()

	return mod.CurrentRunCanGrantUnlocks
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() mod.CurrentRunCanGrantUnlocks = nil end)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, function() mod.CurrentRunCanGrantUnlocks = nil end)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function() mod.CurrentRunCanGrantUnlocks = nil end)

function FiendFolio.CanChallengeRunUnlockAchievements()
	return mod.AchievementTrackers and mod.AchievementTrackers.WombUnlocked
end

------------------------------------------
-- RANDOM UNLOCK CONDITIONS START HERE! --
------------------------------------------


-- Unlocks based on sets of unlocks
-- Soul of random, deluxe, kings of the minor arcana, flea circus
local soulOfRandomList = {
	"IsaacSoulUnlocked",
	"MaggySoulUnlocked",
	"CainSoulUnlocked",
	"JudasSoulUnlocked",
	"BlueBabySoulUnlocked",
	"EveSoulUnlocked",
	"SamsonSoulUnlocked",
	"AzazelSoulUnlocked",
	"LazarusSoulUnlocked",
	"EdenSoulUnlocked",
	"LostSoulUnlocked",
	"LilithSoulUnlocked",
	"KeeperSoulUnlocked",
	"ApollyonSoulUnlocked",
	"ForgottenSoulUnlocked",
	"BethanySoulUnlocked",
	"JacobSoulUnlocked",

	"SOUL_OF_FIEND",
	"SOUL_OF_GOLEM"
}

local minorArcanaKingsList = {
	"HorsePillsUnlocked",
	"GoldenBatteryUnlocked",
	"GoldenTrinketsUnlocked"
}

local deluxeList = {
	"GoldenHeartsUnlocked",
	"HalfSoulHeartsUnlocked",
	"ScaredHeartsUnlocked",
	"BoneHeartsUnlocked",
	"RottenHeartsUnlocked",

	"IMMORAL_HEART",
	"MORBID_HEART",
}

local fleaCircusList = {
	"FLEA_OF_MELTDOWN",
	"FLEA_OF_DELUGE",
	"FLEA_OF_POLLUTION",
	"FLEA_OF_PROPAGANDA"
}

function FiendFolio.PostAchievementUpdate(noNote)
	if mod.savedata.shownUnlocksChoicePopup and mod.CanRunUnlockAchievements() then
		if not FiendFolio.ACHIEVEMENT.SOUL_OF_RANDOM:IsUnlocked(true) then
			local soulStonesCount = FiendFolio.GetAchievementSetUnlockCount(soulOfRandomList)
			if soulStonesCount >= #soulOfRandomList / 2 then
				FiendFolio.ACHIEVEMENT.SOUL_OF_RANDOM:Unlock(noNote)
			end
		end

		if not FiendFolio.ACHIEVEMENT.FLEA_CIRCUS:IsUnlocked(true) and FiendFolio.IsAchievementSetUnlocked(fleaCircusList) then
			FiendFolio.ACHIEVEMENT.FLEA_CIRCUS:Unlock(noNote)
		end

		if not FiendFolio.ACHIEVEMENT.MINOR_ARCANA_KINGS:IsUnlocked(true) and FiendFolio.IsAchievementSetUnlocked(minorArcanaKingsList) then
			FiendFolio.ACHIEVEMENT.MINOR_ARCANA_KINGS:Unlock(noNote)
		end

		if not FiendFolio.ACHIEVEMENT.DELUXE:IsUnlocked(true) and FiendFolio.IsAchievementSetUnlocked(deluxeList) then
			FiendFolio.ACHIEVEMENT.DELUXE:Unlock(noNote)
		end
	end
end

-- King of diamonds, golden reward plate, mern, skip card
local isCurrentRoomClear
local existentFoolsGold = {}
local existentRewardPlates = {}

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if mod.CanRunUnlockAchievements() then
		local room = game:GetRoom()
		isCurrentRoomClear = room:IsClear()

		if not FiendFolio.ACHIEVEMENT.KING_OF_DIAMONDS:IsUnlocked(true) then
			for _, index in pairs(existentFoolsGold) do
				local grid = room:GetGridEntity(index)
				if grid and grid:GetType() == GridEntityType.GRID_ROCK_GOLD and grid.State == 2 then
					mod.savedata.foolsGoldBombed = mod.savedata.foolsGoldBombed + 1
				end
			end

			existentFoolsGold = {}
			for i = 0, room:GetGridSize() do
				local grid = room:GetGridEntity(i)
				if grid and grid:GetType() == GridEntityType.GRID_ROCK_GOLD and not StageAPI.IsCustomGrid(i) then
					if grid.State == 1 then
						table.insert(existentFoolsGold, i)
					end
				end
			end
			
			if mod.savedata.foolsGoldBombed >= 25 then
				FiendFolio.ACHIEVEMENT.KING_OF_DIAMONDS:Unlock()
			end
		end

		if not FiendFolio.ACHIEVEMENT.GOLDEN_REWARD_PLATE:IsUnlocked(true) then
			for _, index in pairs(existentRewardPlates) do
				local grid = room:GetGridEntity(index)
				if grid and grid:ToPressurePlate() and (grid.State == 3 or grid.State == 4) then
					mod.savedata.pressedRewardPlates = mod.savedata.pressedRewardPlates + 1
				end
			end

			existentRewardPlates = {}
			for i = 0, room:GetGridSize() do
				local grid = room:GetGridEntity(i)
				if grid and grid:ToPressurePlate() and grid:GetVariant() == 1 and grid.State == 0 and not StageAPI.IsCustomGrid(i) then
					table.insert(existentRewardPlates, i)
				end
			end

			if mod.savedata.pressedRewardPlates >= 79 then
				FiendFolio.ACHIEVEMENT.GOLDEN_REWARD_PLATE:Unlock()
			end
		end
	end

	if not FiendFolio.ACHIEVEMENT.MERN:IsUnlocked(true) and Isaac.CountEntities(nil, 3, FamiliarVariant.MERN_4) > 0 then
		FiendFolio.ACHIEVEMENT.MERN:Unlock()
	end
end)

local function ThrownFoolsGoldCheck(projectile)
	local sprite = projectile:GetSprite()
	if projectile:IsDead() and sprite:GetFilename() == "gfx/grid/grid_rock.anm2" and sprite:GetAnimation() == "foolsgold" then
		mod.savedata.foolsGoldBombed = mod.savedata.foolsGoldBombed + 1
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity) if mod.CanRunUnlockAchievements() and entity.Variant == ProjectileVariant.PROJECTILE_GRID then ThrownFoolsGoldCheck(entity) end end, 9)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity) if mod.CanRunUnlockAchievements() and entity.Variant == TearVariant.GRIDENT               then ThrownFoolsGoldCheck(entity) end end, 2)

-- Skip card, zodiac beggar, bifurcated stars, morbus!
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if mod.INITIALISED_UNLOCKS then
		local room = game:GetRoom()

		if isCurrentRoomClear ~= nil and not isCurrentRoomClear and mod.CanRunUnlockAchievements() then
			isCurrentRoomClear = nil

			mod.savedata.skippedRooms = mod.savedata.skippedRooms + 1
			if mod.savedata.skippedRooms >= 20 and not FiendFolio.ACHIEVEMENT.SKIP_CARD:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.SKIP_CARD:Unlock()
			end
		end

		if not FiendFolio.ACHIEVEMENT.ZODIAC_BEGGAR:IsUnlocked(true) and room:GetType() == RoomType.ROOM_PLANETARIUM then
			FiendFolio.ACHIEVEMENT.ZODIAC_BEGGAR:Unlock()
		end

		if not FiendFolio.ACHIEVEMENT.BIFURCATED_STARS:IsUnlocked(true) and game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) and room:GetType() == RoomType.ROOM_TREASURE and room:IsFirstVisit() then
			FiendFolio.ACHIEVEMENT.BIFURCATED_STARS:Unlock()
		end

		if not FiendFolio.ACHIEVEMENT.MORBUS:IsUnlocked(true) then
			local level = game:GetLevel()
			if level:GetStage() == LevelStage.STAGE4_1 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE then -- I'm in Corpse
				FiendFolio.ACHIEVEMENT.MORBUS:Unlock()
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	isCurrentRoomClear = nil
end)

-- fiend heart (aehrt), purple putty, fraudulent fungus, haunted penny, shard of china
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked(true) then
		if not mod.ACHIEVEMENT.FIEND_HEART:IsUnlocked(true) and mod.GetImmoralHeartsNum(player) >= 12 then
			mod.ACHIEVEMENT.FIEND_HEART:Unlock()
		end

		if not mod.ACHIEVEMENT.PURPLE_PUTTY:IsUnlocked(true) and mod.savedata.immoralMinionKills >= 50 then
			mod.ACHIEVEMENT.PURPLE_PUTTY:Unlock()
		end
	end

	if not mod.ACHIEVEMENT.FRAUDULENT_FUNGUS:IsUnlocked(true) and player:GetRottenHearts() >= 3 then
		mod.ACHIEVEMENT.FRAUDULENT_FUNGUS:Unlock()
	end

	if not mod.ACHIEVEMENT.HAUNTED_PENNY:IsUnlocked(true) and Isaac.CountEntities(player, 3, FamiliarVariant.WISP, -1) >= 8 then
		mod.ACHIEVEMENT.HAUNTED_PENNY:Unlock()
	end
end)

-- plague of decay (kill a rotten beggar)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	if game:GetRoom():GetFrameCount() > 0 and entity.Type == EntityType.ENTITY_SLOT and entity.Variant == 18 and entity.EntityCollisionClass == 4 then
		if not FiendFolio.ACHIEVEMENT.PLAGUE_OF_DECAY:IsUnlocked(true) then
			FiendFolio.ACHIEVEMENT.PLAGUE_OF_DECAY:Unlock()
		end
	end
end)

-- thirteen of stars
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player)
	if id < 0 and not FiendFolio.ACHIEVEMENT.THIRTEEN_OF_STARS:IsUnlocked(true) and not mod.savedata.tmtrainerIdsUsed[tostring(id)] then -- TMTRAINER time baby
		mod.savedata.tmtrainerIdsUsed[tostring(id)] = true

		if rng:RandomFloat() < 0.2 then
			FiendFolio.ACHIEVEMENT.THIRTEEN_OF_STARS:Unlock()
		end
	end
end)

local soulStonesList = {
	-- Vanilla
	[Card.CARD_SOUL_ISAAC] 		= true,
	[Card.CARD_SOUL_MAGDALENE]	= true,
	[Card.CARD_SOUL_CAIN]		= true,
	[Card.CARD_SOUL_JUDAS]		= true,
	[Card.CARD_SOUL_BLUEBABY]	= true,
	[Card.CARD_SOUL_EVE]		= true,
	[Card.CARD_SOUL_SAMSON]		= true,
	[Card.CARD_SOUL_AZAZEL]		= true,
	[Card.CARD_SOUL_LAZARUS]	= true,
	[Card.CARD_SOUL_EDEN]		= true,
	[Card.CARD_SOUL_LOST]		= true,
	[Card.CARD_SOUL_LILITH]		= true,
	[Card.CARD_SOUL_KEEPER]		= true,
	[Card.CARD_SOUL_APOLLYON]	= true,
	[Card.CARD_SOUL_FORGOTTEN]	= true,
	[Card.CARD_SOUL_BETHANY]	= true,
	[Card.CARD_SOUL_JACOB]		= true,

	-- FF
	[mod.ITEM.CARD.SOUL_OF_FIEND]		= true,
	[mod.ITEM.CARD.SOUL_OF_GOLEM]		= true,
	[mod.ITEM.CARD.SOUL_OF_RANDOM]		= true,
}

-- soul of golem
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, id, player)
	if soulStonesList[id] and player:GetPlayerType() == mod.PLAYER.GOLEM then
		if not mod.ACHIEVEMENT.SOUL_OF_GOLEM:IsUnlocked(true) then
			mod.ACHIEVEMENT.SOUL_OF_GOLEM:Unlock()
		end
	end
end)

-- immoral hearts, Glass Chest
local function GameHasFiend()
	for _, player in pairs(Isaac.FindByType(1)) do
		if player:ToPlayer():GetPlayerType() == mod.PLAYER.FIEND then
			return true
		end
	end

	return false
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	if not mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked(true) and GameHasFiend() then
		local room = game:GetRoom()

		if room:GetType() == RoomType.ROOM_BOSS and game:GetLevel():GetStage() ~= LevelStage.STAGE7 then
			local boss = room:GetBossID()
			if boss == 6 or boss == 89 then -- Mom / Maus Mom
				mod.ACHIEVEMENT.IMMORAL_HEART:Unlock()
			end
		end
	end

	if not mod.ACHIEVEMENT.GLASS_CHEST:IsUnlocked(true) then
		local room = game:GetRoom()
		if room:GetType() == RoomType.ROOM_BOSS and room:IsMirrorWorld() then
			mod.ACHIEVEMENT.GLASS_CHEST:Unlock()
		end
	end
end)

-- flea of meltdown, flea of deluge
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc.Variant == mod.FF.Meltdown2.Var and game:GetRoom():GetType() == RoomType.ROOM_BOSS and mod.CanRunUnlockAchievements() then
		mod.savedata.meltdownKills = mod.savedata.meltdownKills + 1

		if mod.savedata.meltdownKills >= 3 then
			if not mod.ACHIEVEMENT.FLEA_OF_MELTDOWN:IsUnlocked(true) then
				mod.ACHIEVEMENT.FLEA_OF_MELTDOWN:Unlock()
			end
			if not mod.ACHIEVEMENT.FLEA_OF_DELUGE:IsUnlocked(true) then
				mod.ACHIEVEMENT.FLEA_OF_DELUGE:Unlock()
			end
		end
	end
end, mod.FF.Meltdown2.ID)

-- flea of pollution, flea of propaganda
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc.Variant == mod.FF.Pollution2.Var and game:GetRoom():GetType() == RoomType.ROOM_BOSS and mod.CanRunUnlockAchievements() then
		mod.savedata.pollutionKills = mod.savedata.pollutionKills + 1

		if mod.savedata.pollutionKills >= 3 then
			if not mod.ACHIEVEMENT.FLEA_OF_POLLUTION:IsUnlocked(true) then
				mod.ACHIEVEMENT.FLEA_OF_POLLUTION:Unlock()
			end

			if not mod.ACHIEVEMENT.FLEA_OF_PROPAGANDA:IsUnlocked(true) then
				mod.ACHIEVEMENT.FLEA_OF_PROPAGANDA:Unlock()
			end
		end
	end
end, mod.FF.Pollution2.ID)

-- queen of clubs
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc.Variant == 0 and game:GetRoom():GetBossID() == 93 and not mod.ACHIEVEMENT.QUEEN_OF_CLUBS:IsUnlocked(true) then
		mod.ACHIEVEMENT.QUEEN_OF_CLUBS:Unlock()
	end
end, EntityType.ENTITY_SINGE)

-- The Right Hand
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc.Variant == 1 and game:GetRoom():GetBossID() == 40 and not mod.ACHIEVEMENT.RIGHT_HAND:IsUnlocked(true) then
		local anyPlayerHasLeftHand
		mod.AnyPlayerDo(function(player)
			if player:HasTrinket(TrinketType.TRINKET_LEFT_HAND) or player:HasTrinket(mod.ITEM.ROCK.LEFT_FOSSIL) then
				anyPlayerHasLeftHand = true
			end
		end)

		if anyPlayerHasLeftHand then
			mod.ACHIEVEMENT.RIGHT_HAND:Unlock()
		end
	end
end, EntityType.ENTITY_ISAAC)

-- Morbid Heart
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc.Variant == mod.FF.MrDead.Var and game:GetRoom():GetType() == RoomType.ROOM_BOSS then
		if not mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked(true) then
			mod.ACHIEVEMENT.MORBID_HEART:Unlock()
		end

		if game.Challenge == 0 then
			Isaac.Spawn(5, mod.PICKUP.VARIANT.MORBID_HEART, 0, npc.Position, RandomVector(), npc)
		end
	end
end, mod.FF.MrDead.ID)

-- Beast Beggar
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
	if npc.Variant == 0 then -- The Beast, not horsemen
		if not mod.ACHIEVEMENT.BEAST_BEGGAR:IsUnlocked(true) then
			mod.ACHIEVEMENT.BEAST_BEGGAR:Unlock()
		end
	end
end, EntityType.ENTITY_BEAST)

-- challenge unlocks!
-- dad's home, green house
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider:ToPlayer() then
		if game.Challenge == mod.challenges.dadsHomePlus then
			if not FiendFolio.ACHIEVEMENT.GREEN_HOUSE:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.GREEN_HOUSE:Unlock()
			end
		end
	end
end, 960) -- Golden Medallion

-- every other challenge!
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider:ToPlayer() then
		if game.Challenge == mod.challenges.theRealJon then
			if not FiendFolio.ACHIEVEMENT.SPARE_RIBS:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.SPARE_RIBS:Unlock()
			end
		elseif game.Challenge == mod.challenges.dirtyBubble then
			if not FiendFolio.ACHIEVEMENT.PETRIFIED_GEL:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.PETRIFIED_GEL:Unlock()
			end
		elseif game.Challenge == mod.challenges.frogMode then
			if not FiendFolio.ACHIEVEMENT.SLIPPYS_ORGANS:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.SLIPPYS_ORGANS:Unlock()
			end
		elseif game.Challenge == mod.challenges.handsOn then
			if not FiendFolio.ACHIEVEMENT.RED_HAND:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.RED_HAND:Unlock()
			end
		elseif game.Challenge == mod.challenges.isaacRebuilt then
			if not FiendFolio.ACHIEVEMENT.DEIMOS:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.DEIMOS:Unlock()
			end
		elseif game.Challenge == mod.challenges.brickByBrick then
			if not FiendFolio.ACHIEVEMENT.BRICK_SEPARATOR:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.BRICK_SEPARATOR:Unlock()
			end
		elseif game.Challenge == mod.challenges.towerOffense then
			if not FiendFolio.ACHIEVEMENT.LAWN_DARTS:IsUnlocked(true) then
				FiendFolio.ACHIEVEMENT.LAWN_DARTS:Unlock()
			end
		elseif game.Challenge == mod.challenges.chinaShop then
			if not mod.ACHIEVEMENT.CHINAS_BELONGINGS:IsUnlocked(true) then
				mod.ACHIEVEMENT.CHINAS_BELONGINGS:Unlock()
			end
		elseif game.Challenge == mod.challenges.theGauntlet then
			if not mod.ACHIEVEMENT.GAUNTLET_BEATEN:IsUnlocked(true) then
				mod.ACHIEVEMENT.GAUNTLET_BEATEN:Unlock()
			end
		end
	end
end, PickupVariant.PICKUP_TROPHY)

-- Biend
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	for _, slot in pairs(Isaac.FindByType(6, 14)) do
		if slot:GetSprite():IsFinished("PayPrize") then
			if Isaac.GetPlayer():GetPlayerType() == mod.PLAYER.FIEND then
				FiendFolio.ACHIEVEMENT.BIEND:Unlock()
			end
		end
	end
end)


------------------------------------------
-- LOCKED THINGS DISABLING STARTS HERE! --
------------------------------------------

-- Cards placed in rooms, zodiac beggar, beast beggar
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, sub, pos, vel, spawner, seed)
	if typ == EntityType.ENTITY_PICKUP and var == PickupVariant.PICKUP_TAROTCARD then
		if FiendFolio.IsCardLocked(sub) then
			local itempool = game:GetItemPool()
			return {5, 300, itempool:GetCard(seed, false, false, false), seed}
		end
	elseif typ == EntityType.ENTITY_SLOT then
		if var == mod.FF.ZodiacBeggar.Var and not FiendFolio.ACHIEVEMENT.ZODIAC_BEGGAR:IsUnlocked() and game:GetRoom():GetType() ~= RoomType.ROOM_PLANETARIUM then
			return {5, 10, 3, seed}
		elseif var == mod.FF.EvilBeggar.Var and not FiendFolio.ACHIEVEMENT.BEAST_BEGGAR:IsUnlocked() then
			return {6, 5, 0, seed}
		elseif var == 1040 and not mod.ACHIEVEMENT.GOLDEN_SLOT_MACHINE:IsUnlocked() then
			return {6, 1, 0, seed}
		end
	end
end)

-- Locked Cards nuclear option
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if FiendFolio.IsCardLocked(pickup.SubType) then
		pickup:Morph(5, 300, 0, true, true)
	end
end, 300)

-- Immoral hearts & variants
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SpawnerType ~= 1 and not mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() and not GameHasFiend() then
		pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, true, true)
	end
end, mod.PICKUP.VARIANT.IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SpawnerType ~= 1 and not mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() and not GameHasFiend() then
		pickup:Morph(5, mod.PICKUP.VARIANT.HALF_BLACK_HEART, 0, true, true)
	end
end, mod.PICKUP.VARIANT.HALF_IMMORAL_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SpawnerType ~= 1 and not mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() and not GameHasFiend() then
		pickup:Morph(5, mod.PICKUP.VARIANT.BLENDED_BLACK_HEART, 0, true, true)
	end
end, mod.PICKUP.VARIANT.BLENDED_IMMORAL_HEART)

-- Morbid hearts
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if not mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() then
		if mod.AchievementTrackers.RottenHeartsUnlocked then
			pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN)
		else
			pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL)
		end
	end
end, mod.PICKUP.VARIANT.MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if not mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() then
		if mod.AchievementTrackers.RottenHeartsUnlocked then
			pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN)
		else
			pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF)
		end
	end
end, mod.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if not mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() then
		if mod.AchievementTrackers.RottenHeartsUnlocked then
			pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN)
		else
			pickup:Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF)
		end
	end
end, mod.PICKUP.VARIANT.THIRD_MORBID_HEART)

-- Golden cursed penny
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SubType == mod.PICKUP.COIN.GOLDENCURSED and not mod.ACHIEVEMENT.GOLDEN_CURSED_PENNY:IsUnlocked() then
		pickup:Morph(5, PickupVariant.PICKUP_COIN, mod.PICKUP.COIN.CURSED)
	end
end, PickupVariant.PICKUP_COIN)

-- Haunted Penny
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SubType == mod.PICKUP.COIN.HAUNTED and not mod.ACHIEVEMENT.HAUNTED_PENNY:IsUnlocked() then
		pickup:Morph(5, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY)
	end
end, PickupVariant.PICKUP_COIN)

-- Dire chest
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if not mod.ACHIEVEMENT.DIRE_CHEST:IsUnlocked() then
		pickup:Morph(5, PickupVariant.PICKUP_REDCHEST, 0)
	end
end, mod.PICKUP.VARIANT.DIRE_CHEST)

-- Glass chest
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if not mod.ACHIEVEMENT.GLASS_CHEST:IsUnlocked() then
		pickup:Morph(5, PickupVariant.PICKUP_LOCKEDCHEST, 0)
	end
end, mod.PICKUP.VARIANT.GLASS_CHEST)

-- 52 Deck
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SubType == 11 then
		if not mod.ACHIEVEMENT["52_DECK"]:IsUnlocked() then
			pickup:Morph(5, PickupVariant.PICKUP_GRAB_BAG, 0)
		end
	end
end, mod.PICKUP.VARIANT.DECK52)

-- Biend Locks
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if not FiendFolio.ACHIEVEMENT.BIEND:IsUnlocked() then
		local level = game:GetLevel()
		local desc = level:GetCurrentRoomDesc()

		local playerType = Isaac.GetPlayer():GetPlayerType()

		if level:GetStage() == LevelStage.STAGE8 and desc.SafeGridIndex == 94 and ((playerType == mod.PLAYER.FIEND and mod.CanRunUnlockAchievements()) or playerType == mod.PLAYER.BIEND) then
			for _, shopkeeper in pairs(Isaac.FindByType(17)) do
				shopkeeper:Remove()
			end

			for _, item in pairs(Isaac.FindByType(5)) do
				item:Remove()
			end

			local room = game:GetRoom()
			local centre = room:GetCenterPos()
			local biend = Isaac.FindByType(6, 14)[1] or Isaac.Spawn(6, 14, 0, centre, Vector.Zero, nil)
			local sprite = biend:GetSprite()
			sprite:ReplaceSpritesheet(0, "gfx/characters/costumes/player_fiendb.png")
			sprite:LoadGraphics()

			if playerType == mod.PLAYER.BIEND then
				local door = room:GetDoor(2)
				room:RemoveGridEntity(door:GetGridIndex(), 0, false)

				for i = 1, 3 do
					Isaac.Spawn(1000, 21, 0, centre, Vector.Zero, nil)
				end

				Isaac.Spawn(1000, 64, 0, centre, Vector.Zero, nil)
			end
		end
	end
end)

function FiendFolio.SafeEndGame()
	-- disable achievements
	game:GetSeeds():AddSeedEffect(SeedEffect.SEED_PREVENT_ALL_CURSES)
	game:End(3)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if not FiendFolio.ACHIEVEMENT.BIEND:IsUnlocked() and game.Difficulty >= Difficulty.DIFFICULTY_GREED and Isaac.GetPlayer():GetPlayerType() == mod.PLAYER.BIEND then
		FiendFolio.SafeEndGame()
	end

	if Isaac.GetPlayer():GetPlayerType() == mod.PLAYER.BOLEM then
		FiendFolio.SafeEndGame()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player.FrameCount > 0 then
		FiendFolio.TryLockBiendInHome(player)
	end
end)

function FiendFolio.TryLockBiendInHome(player)
	player = player or Isaac.GetPlayer()
	if not FiendFolio.ACHIEVEMENT.BIEND:IsUnlocked() and player:GetPlayerType() == mod.PLAYER.BIEND then
		player.ControlsEnabled = false
		player.Visible = false
		player:GetData().BiendClosetMode = true

		local hud = game:GetHUD()
		hud:SetVisible(false)

		if game.Difficulty < Difficulty.DIFFICULTY_GREED then
			local level = game:GetLevel()
			if level:GetStage() ~= LevelStage.STAGE8 then
				Isaac.ExecuteCommand("stage 13")
				level:ChangeRoom(95)

				player.Position = Vector(245, 280)
				player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_RED_KEY, ActiveSlot.SLOT_POCKET2)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_RED_KEY, UseFlag.USE_OWNED + UseFlag.USE_NOANIM, ActiveSlot.SLOT_POCKET2)
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_RED_KEY)
				player.Position = Vector(160, 280)

				SFXManager():Stop(SoundEffect.SOUND_UNLOCK00)
			end
		end
	end
end