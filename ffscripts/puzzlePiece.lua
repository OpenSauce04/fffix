local mod = FiendFolio
local jigsawPuzzleBox = TrinketType.TRINKET_JIGSAW_PUZZLE_BOX

mod.PuzzlePieceParts = {
	Fortunes = {
		[1] = {"A pet", "You", "Your fears", "A stranger", "Your favorite food"},
		[2] = {"will hurt", "will help", "will take", "will protect"},
		[3] = {"you", "your life", "your soul", "your enemies"}
	},
	Rewards = {
		[1] = {
			[1] = {
				[1] = CollectibleType.COLLECTIBLE_BOBS_BRAIN,
				[2] = CollectibleType.COLLECTIBLE_DEAD_CAT,
				[3] = CollectibleType.COLLECTIBLE_PET_ROCK,
				[4] = CollectibleType.COLLECTIBLE_TAMMYS_HEAD,
			},
			[2] = {
				[1] = CollectibleType.COLLECTIBLE_YO_LISTEN,
				[2] = CollectibleType.COLLECTIBLE_LITTLE_CHAD,
				[3] = {Type = "Trinket", ID = TrinketType.TRINKET_SOUL},
				[4] = CollectibleType.COLLECTIBLE_BLOOD_PUPPY,
			},
			[3] = {
				[1] = CollectibleType.COLLECTIBLE_PONY,
				[2] = CollectibleType.COLLECTIBLE_GUPPYS_PAW,
				[3] = CollectibleType.COLLECTIBLE_GOAT_HEAD,
				[4] = CollectibleType.COLLECTIBLE_PUNCHING_BAG
			},
			[4] = {
				[1] = CollectibleType.COLLECTIBLE_DEAD_BIRD,
				[2] = CollectibleType.COLLECTIBLE_SMART_FLY,
				[3] = CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL,
				[4] = CollectibleType.COLLECTIBLE_ANGRY_FLY
			},
		},
		[2] = {
			[1] = {
				[1] = CollectibleType.COLLECTIBLE_RAZOR_BLADE,
				[2] = CollectibleType.COLLECTIBLE_YUCK_HEART,
				[3] = CollectibleType.COLLECTIBLE_DEPRESSION,
				[4] = CollectibleType.COLLECTIBLE_NECRONOMICON
			},
			[2] = {
				[1] = CollectibleType.COLLECTIBLE_ABEL,
				[2] = CollectibleType.COLLECTIBLE_PURITY,
				[3] = CollectibleType.COLLECTIBLE_ROSARY,
				[4] = CollectibleType.COLLECTIBLE_BETRAYAL
			},
			[3] = {
				[1] = {Type = "Trinket", ID = TrinketType.TRINKET_ISAACS_HEAD},
				[2] = {Type = "Card", ID = Card.CARD_SUICIDE_KING},
				[3] = {Type = "Trinket", ID = TrinketType.TRINKET_YOUR_SOUL},
				[4] = CollectibleType.COLLECTIBLE_FRIEND_BALL
			},
			[4] = {
				[1] = CollectibleType.COLLECTIBLE_MY_SHADOW,
				[2] = CollectibleType.COLLECTIBLE_ISAACS_HEART,
				[3] = CollectibleType.COLLECTIBLE_BLANKET,
				[4] = CollectibleType.COLLECTIBLE_FRIEND_FINDER
			},
		},
		[3] = {
			[1] = {
				[1] = {Type = "MomsFoot"},
				[2] = CollectibleType.COLLECTIBLE_BLOOD_OATH,
				[3] = CollectibleType.COLLECTIBLE_FATES_REWARD,
				[4] = {Type = "Trinket", ID = TrinketType.TRINKET_MOMS_TOENAIL}
			},
			[2] = {
				[1] = CollectibleType.COLLECTIBLE_MYSTERY_EGG,
				[2] = CollectibleType.COLLECTIBLE_FATE,
				[3] = CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,
				[4] = {Type = "Trinket", ID = TrinketType.TRINKET_PURPLE_HEART}
			},
			[3] = {
				[1] = CollectibleType.COLLECTIBLE_INTRUDER,
				[2] = CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER,
				[3] = CollectibleType.COLLECTIBLE_SHADE,
				[4] = CollectibleType.COLLECTIBLE_2SPOOKY
			},
			[4] = {
				[1] = CollectibleType.COLLECTIBLE_MOMS_WIG,
				[2] = CollectibleType.COLLECTIBLE_LEPROSY,
				[3] = CollectibleType.COLLECTIBLE_NIGHT_LIGHT,
				[4] = CollectibleType.COLLECTIBLE_MOMS_PERFUME
			},
		},
		[4] = {
			[1] = {
				[1] = {Type = "EvilBeggar"},
				[2] = CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION,
				[3] = CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION,
				[4] = CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX
			},
			[2] = {
				[1] = CollectibleType.COLLECTIBLE_BLUE_BOX,
				[2] = CollectibleType.COLLECTIBLE_SPIDER_MOD,
				[3] = CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION,
				[4] = CollectibleType.COLLECTIBLE_VOODOO_HEAD
			},
			[3] = {
				[1] = CollectibleType.COLLECTIBLE_BIBLE,
				[2] = CollectibleType.COLLECTIBLE_DARK_BUM,
				[3] = CollectibleType.COLLECTIBLE_PACT,
				[4] = CollectibleType.COLLECTIBLE_FRUITY_PLUM
			},
			[4] = {
				[1] = CollectibleType.COLLECTIBLE_BUMBO,
				[2] = CollectibleType.COLLECTIBLE_BIG_FAN,
				[3] = CollectibleType.COLLECTIBLE_SWORN_PROTECTOR,
				[4] = CollectibleType.COLLECTIBLE_CHAMPION_BELT
			},
		},
		[5] = {
			[1] = {
				[1] = CollectibleType.COLLECTIBLE_APPLE,
				[2] = CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID,
				[3] = CollectibleType.COLLECTIBLE_BIRDS_EYE,
				[4] = CollectibleType.COLLECTIBLE_RED_STEW
			},
			[2] = {
				[1] = CollectibleType.COLLECTIBLE_SAUSAGE,
				[2] = CollectibleType.COLLECTIBLE_BREAKFAST,
				[3] = CollectibleType.COLLECTIBLE_ALMOND_MILK,
				[4] = CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE
			},
			[3] = {
				[1] = CollectibleType.COLLECTIBLE_BACON_GREASE,
				[2] = CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS,
				[3] = CollectibleType.COLLECTIBLE_SOY_MILK,
				[4] = CollectibleType.COLLECTIBLE_ROTTEN_TOMATO
			},
			[4] = {
				[1] = CollectibleType.COLLECTIBLE_WAIT_WHAT,
				[2] = CollectibleType.COLLECTIBLE_CRACK_JACKS,
				[3] = CollectibleType.COLLECTIBLE_MILK,
				[4] = CollectibleType.COLLECTIBLE_BUTTER_BEAN
			},
		},
	}
}

function mod:usePuzzle(card)
	local player = mod:GetPlayerUsingItem()
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	savedata.puzzleFortunes = savedata.puzzleFortunes or {}
	for i = 1, 3 do
		if not savedata.puzzleFortunes[i] then
			local r = player:GetCardRNG(Card.PUZZLE_PIECE)
			savedata.puzzleFortunes[i] = r:RandomInt(#mod.PuzzlePieceParts.Fortunes[i]) + 1
			break
		end
	end

	local fortune1, fortune2, fortune3 = mod.PuzzlePieceParts.Fortunes[1][savedata.puzzleFortunes[1]] or "____", mod.PuzzlePieceParts.Fortunes[2][savedata.puzzleFortunes[2]] or "____", mod.PuzzlePieceParts.Fortunes[3][savedata.puzzleFortunes[3]] or "____"
	Game():GetHUD():ShowFortuneText (fortune1,fortune2,fortune3) --From here on, Fortune Results
	if savedata.puzzleFortunes[3] then
		if mod.PuzzlePieceParts.Rewards[savedata.puzzleFortunes[1]] and mod.PuzzlePieceParts.Rewards[savedata.puzzleFortunes[1]][savedata.puzzleFortunes[2]] and mod.PuzzlePieceParts.Rewards[savedata.puzzleFortunes[1]][savedata.puzzleFortunes[2]][savedata.puzzleFortunes[3]] then
			local reward = mod.PuzzlePieceParts.Rewards[savedata.puzzleFortunes[1]][savedata.puzzleFortunes[2]][savedata.puzzleFortunes[3]]
			local animatehappy = true
			if type(reward) == "number" then
				Isaac.Spawn(5, 100, reward, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vector(60, 0)), Vector(0,0), nil)
			else
				if reward.Type == "Trinket" then
					Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET, reward.ID, player.Position, Vector(math.random(4, 7), 0):Rotated(90), player)
				elseif reward.Type == "Card" then
					Isaac.Spawn(EntityType.ENTITY_PICKUP,300, reward.ID, player.Position, Vector(math.random(4, 7), 0):Rotated(90), player)
				elseif reward.Type == "MomsFoot" then
					player:UseCard(Card.CARD_HIGH_PRIESTESS)
					animatehappy = false
				elseif reward.Type == "EvilBeggar" then
					Isaac.Spawn(6, 1033, reward, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vector(60, 0)), Vector(0,0), nil)
				end
			end
			if animatehappy then
				player:AnimateHappy()
			else
				player:AnimateSad()
			end
			player:TryRemoveTrinket(jigsawPuzzleBox)
		end
		savedata.puzzleFortunes = {}
		savedata.puzzleSpawns = {}
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.usePuzzle, Card.PUZZLE_PIECE);

--Jigsaw Puzzle Box Trinket
function mod:PostLevel()
	mod.AnyPlayerDo(function(player)
		local savedata = Isaac.GetPlayer():GetData().ffsavedata
		savedata.droppedPiece = savedata.droppedPiece
		if player:HasTrinket(jigsawPuzzleBox) and savedata.droppedPiece ~= 1 then
			local repeatTimes = player:GetTrinketMultiplier(jigsawPuzzleBox)
			for k = 1, repeatTimes do
				Isaac.Spawn(5, 300, Card.PUZZLE_PIECE, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vector(60, 0)), Vector(0,0), nil)
			end
			savedata.droppedPiece = 1
		else
		end
	end)
end
mod:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, mod.PostLevel)
