local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.GlassChestDrops = {
	Cards = {
		Runes = { -- If a locked Rune is rolled, it is replaced with its ReplaceWith data
			{CardID = Card.RUNE_HAGALAZ,Anm2 = "005.303_rune1", 	Unlocked = function() return mod.AchievementTrackers.HagalazUnlocked end, 	ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_JERA,	Anm2 = "005.303_rune1", 	Unlocked = function() return mod.AchievementTrackers.JeraUnlocked end, 		ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_EHWAZ,	Anm2 = "005.303_rune1", 	Unlocked = function() return mod.AchievementTrackers.EhwazUnlocked end, 	ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_DAGAZ,	Anm2 = "005.303_rune1", 	Unlocked = function() return mod.AchievementTrackers.DagazUnlocked end,		ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_ANSUZ,	Anm2 = "005.304_rune2", 	Unlocked = function() return mod.AchievementTrackers.AnsuzUnlocked end, 	ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_PERTHRO,Anm2 = "005.304_rune2", 	Unlocked = function() return mod.AchievementTrackers.PerthroUnlocked end, 	ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_BERKANO,Anm2 = "005.304_rune2", 	Unlocked = function() return mod.AchievementTrackers.BerkanoUnlocked end, 	ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_ALGIZ,	Anm2 = "005.304_rune2", 	Unlocked = function() return mod.AchievementTrackers.AlgizUnlocked end, 	ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_BLANK,	Anm2 = "005.304_rune2", 	Unlocked = function() return mod.AchievementTrackers.BlankRuneUnlocked end, ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
			{CardID = Card.RUNE_BLACK,	Anm2 = "005.307_blackrune", Unlocked = function() return mod.AchievementTrackers.BlackRuneUnlocked end, ReplaceWith = {CardID = Card.RUNE_SHARD, Anm2 = "005.313_rune shard"}},
		},
		Souls = { -- If a locked Soul is rolled, it is replaced with a roll from the Runes table
			{CardID = Card.CARD_SOUL_ISAAC,				Anm2 = "005.300.18_soul of isaac",					Unlocked = function() return mod.AchievementTrackers.IsaacSoulUnlocked end},
			{CardID = Card.CARD_SOUL_MAGDALENE,			Anm2 = "005.300.19_soul of magdalene",				Unlocked = function() return mod.AchievementTrackers.MaggySoulUnlocked end},
			{CardID = Card.CARD_SOUL_CAIN,				Anm2 = "005.300.20_soul of cain",					Unlocked = function() return mod.AchievementTrackers.CainSoulUnlocked end},
			{CardID = Card.CARD_SOUL_JUDAS,				Anm2 = "005.300.21_soul of judas",					Unlocked = function() return mod.AchievementTrackers.JudasSoulUnlocked end},
			{CardID = Card.CARD_SOUL_BLUEBABY,			Anm2 = "005.300.22_soul of blue baby",				Unlocked = function() return mod.AchievementTrackers.BlueBabySoulUnlocked end},
			{CardID = Card.CARD_SOUL_EVE,				Anm2 = "005.300.23_soul of eve",					Unlocked = function() return mod.AchievementTrackers.EveSoulUnlocked end},
			{CardID = Card.CARD_SOUL_SAMSON,			Anm2 = "005.300.24_soul of samson",					Unlocked = function() return mod.AchievementTrackers.SamsonSoulUnlocked end},
			{CardID = Card.CARD_SOUL_AZAZEL,			Anm2 = "005.300.25_soul of azazel",					Unlocked = function() return mod.AchievementTrackers.AzazelSoulUnlocked end},
			{CardID = Card.CARD_SOUL_LAZARUS,			Anm2 = "005.300.26_soul of lazarus",				Unlocked = function() return mod.AchievementTrackers.LazarusSoulUnlocked end},
			{CardID = Card.CARD_SOUL_EDEN,				Anm2 = "005.300.27_soul of eden",					Unlocked = function() return mod.AchievementTrackers.EdenSoulUnlocked end},
			{CardID = Card.CARD_SOUL_LOST,				Anm2 = "005.300.28_soul of the lost",				Unlocked = function() return mod.AchievementTrackers.LostSoulUnlocked end},
			{CardID = Card.CARD_SOUL_LILITH,			Anm2 = "005.300.29_soul of lilith",					Unlocked = function() return mod.AchievementTrackers.LilithSoulUnlocked end},
			{CardID = Card.CARD_SOUL_KEEPER,			Anm2 = "005.300.30_soul of the keeper",				Unlocked = function() return mod.AchievementTrackers.KeeperSoulUnlocked end},
			{CardID = Card.CARD_SOUL_APOLLYON,			Anm2 = "005.300.31_soul of apollyon",				Unlocked = function() return mod.AchievementTrackers.ApollyonSoulUnlocked end},
			{CardID = Card.CARD_SOUL_FORGOTTEN,			Anm2 = "005.300.32_soul of the forgotten",			Unlocked = function() return mod.AchievementTrackers.ForgottenSoulUnlocked end},
			{CardID = Card.CARD_SOUL_BETHANY,			Anm2 = "005.300.33_soul of bethany",				Unlocked = function() return mod.AchievementTrackers.BethanySoulUnlocked end},
			{CardID = Card.CARD_SOUL_JACOB,				Anm2 = "005.300.34_soul of jacob",					Unlocked = function() return mod.AchievementTrackers.JacobSoulUnlocked end},
			{CardID = mod.ITEM.CARD.SOUL_OF_FIEND,		Anm2 = "items/cards/soulstones/soulstone_fiend",	Unlocked = function() return mod.ACHIEVEMENT.SOUL_OF_FIEND:IsUnlocked() end},
			{CardID = mod.ITEM.CARD.SOUL_OF_GOLEM,		Anm2 = "items/cards/soulstones/soulstone_golem",	Unlocked = function() return mod.ACHIEVEMENT.SOUL_OF_GOLEM:IsUnlocked() end},
			{CardID = mod.ITEM.CARD.SOUL_OF_RANDOM,		Anm2 = "items/cards/soulstones/soulstone_random",	Unlocked = function() return mod.ACHIEVEMENT.SOUL_OF_RANDOM:IsUnlocked() end},
		},
		Dice = {
			{CardID = mod.ITEM.CARD.GLASS_D4,				Anm2 = "items/cards/glassdice/glass_d4"},
			{CardID = mod.ITEM.CARD.GLASS_D6,				Anm2 = "items/cards/glassdice/glass_d6"},
			{CardID = mod.ITEM.CARD.GLASS_D8,				Anm2 = "items/cards/glassdice/glass_d8"},
			{CardID = mod.ITEM.CARD.GLASS_D12,				Anm2 = "items/cards/glassdice/glass_d12"},
			{CardID = mod.ITEM.CARD.GLASS_D10,				Anm2 = "items/cards/glassdice/glass_d10"},
			{CardID = mod.ITEM.CARD.GLASS_D20,				Anm2 = "items/cards/glassdice/glass_d20"},
			{CardID = mod.ITEM.CARD.GLASS_D100,				Anm2 = "items/cards/glassdice/glass_d100"},
			{CardID = mod.ITEM.CARD.GLASS_SPINDOWN,			Anm2 = "items/cards/glassdice/glass_spindown"},
			{CardID = mod.ITEM.CARD.GLASS_AZURITE_SPINDOWN, Anm2 = "items/cards/glassdice/glass_azurite_spindown"},
			{CardID = mod.ITEM.CARD.GLASS_D2,				Anm2 = "items/cards/glassdice/glass_d2"},
		},
	}
}

mod.RandomChestOutcomes = { -- If a locked Chest Outcome is rolled, it is replaced with its ReplaceWith data
	Coins = {
		["Default"] = 	{Anm2 = "005.021_penny", 			Sub = 1},
		["Nickel"] 	= 	{Anm2 = "005.022_nickel", 			Sub = 2},
		["Dime"] 	= 	{Anm2 = "005.023_dime", 			Sub = 3},
		["Double"] = 	{Anm2 = "005.024_double penny", 	Sub = 4},
		["Lucky"] = 	{Anm2 = "005.026_lucky penny", 		Sub = 5,			Unlocked = function() return mod.AchievementTrackers.LuckyPennyUnlocked end,	ReplaceWith = "Default"},
		["Sticky"] = 	{Anm2 = "005.025_sticky nickel", 	Sub = 6,			Unlocked = function() return mod.AchievementTrackers.StickyNickelUnlocked end,	ReplaceWith = "Nickel"},
		["Golden"] = 	{Anm2 = "005.027_golden penny", 	Sub = 7,			Unlocked = function() return mod.AchievementTrackers.GoldenPennyUnlocked end,	ReplaceWith = "Default"},
		["Cursed"] = 	{Anm2 = "items/pick ups/cursed_penny",	 	Sub = 213},
		["GoldCursed"] ={Anm2 = "items/pick ups/goldfiend_penny", 	Sub = 216,	Unlocked = function() return mod.ACHIEVEMENT.GOLDEN_CURSED_PENNY:IsUnlocked() end, 	ReplaceWith = "Cursed"},
		["Haunted"] = 	{Anm2 = "items/pick ups/haunted_penny",  	Sub = 214,	Unlocked = function() return mod.ACHIEVEMENT.HAUNTED_PENNY:IsUnlocked() end,		ReplaceWith = "Default"},
	},
	Bombs = {
		["Default"] = 	{Anm2 = "005.041_bomb", 			Sub = 1},
		["Double"] = 	{Anm2 = "005.042_double bomb", 		Sub = 2},
		["Golden"] = 	{Anm2 = "005.043_golden bomb", 		Sub = 4,			Unlocked = function() return mod.AchievementTrackers.GoldenBombsUnlocked end, ReplaceWith = "Default"},
		["Troll"] = 	{Anm2 = "004.003_troll bomb", 		Type = 4, Var = 3},
		["MegaTroll"] = {Anm2 = "004.004_megatroll bomb", 	Type = 4, Var = 4},
		["Copper"] =	{Anm2 = "items/pick ups/bombs/copper/_pickup", Sub = 923},
	},
	Poops = {
		["Default"] = 	{Anm2 = "005.042_poop nugget", 		Sub = 0},
		["Double"] = 	{Anm2 = "005.042_big poop nugget", 	Sub = 1},
	},
	Keys = {
		["Default"] = 	{Anm2 = "005.031_key", 				Sub = 1},
		["Golden"] = 	{Anm2 = "005.032_golden key", 		Sub = 2},
		["Double"] = 	{Anm2 = "005.033_keyring", 			Sub = 2},
		["Charged"] = 	{Anm2 = "005.034_chargedkey", 		Sub = 3, AnimationFrame = 14, Unlocked = function() return mod.AchievementTrackers.ChargedKeyUnlocked end, ReplaceWith = "Default"},
	},
	Hearts = {
		["Default"] = 	{Anm2 = "005.011_heart", 			Sub = 1},
		["Half"] = 		{Anm2 = "005.012_heart (half)", 	Sub = 2},
		["Soul"] = 		{Anm2 = "005.013_heart (soul)", 	Sub = 3},
		["Eternal"] = 	{Anm2 = "005.014_heart (eternal)", 	Sub = 4},
		["Double"] = 	{Anm2 = "005.015_double heart", 	Sub = 5},
		["Black"] = 	{Anm2 = "005.016_black heart", 		Sub = 6},
		["Golden"] = 	{Anm2 = "005.017_goldheart", 		Sub = 7,			Unlocked = function() return mod.AchievementTrackers.GoldenHeartsUnlocked end, 		ReplaceWith = "Soul"},
		["HalfSoul"] = 	{Anm2 = "005.018_heart (halfsoul)", Sub = 8,			Unlocked = function() return mod.AchievementTrackers.HalfSoulHeartsUnlocked end, 	ReplaceWith = "Soul"},
		["Scared"] = 	{Anm2 = "005.020_scared heart", 	Sub = 9,			Unlocked = function() return mod.AchievementTrackers.ScaredHeartsUnlocked end, 		ReplaceWith = "Default"},
		["Blended"] = 	{Anm2 = "005.019_blended heart", 	Sub = 10},
		["Bone"] = 		{Anm2 = "005.01a_bone heart", 		Sub = 11,			Unlocked = function() return mod.AchievementTrackers.BoneHeartsUnlocked end, 		ReplaceWith = "Default"},
		["Rotten"] = 	{Anm2 = "005.01b_rotten heart", 	Sub = 12, 			Unlocked = function() return mod.AchievementTrackers.RottenHeartsUnlocked end, 		ReplaceWith = "Default"},
		["Immoral"] = 	{Anm2 = "items/pick ups/fiendish_heart", Var = 1024, 	Unlocked = function() return mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() end,		ReplaceWith = "Soul"},
	},
	Familiars = {
		["Fly"] = 		{Anm2 = "003.043_attack fly", 		Type = 3, Var = 43},
	},
	Sacks = {
		["GrabBag"] = 	{Anm2 = "005.069_grabbag", 			Sub = 1},
		["Black"] = 	{Anm2 = "005.069_black sack", 		Sub = 2,			Unlocked = function() return mod.AchievementTrackers.BlackSackUnlocked end, 		ReplaceWith = "GrabBag"},
	},

}

function mod:GetRandomChestItem(chest)
	local Type = 5
	local Var = 0
	local Sub = 0
	local Anm2 = ""
	local Offset = nilvector
	local AnimationFrame
	local Repeat = 1

	local outcome = "Default"
	local listCheck = "Coins"

	local r = chest:GetDropRNG()
	local rand = r:RandomInt(20)
	if rand < 7 then
		--Coins (35%)
		listCheck = "Coins"
		Var = 20
		rand = r:RandomInt(100)
		if rand < 5 then
			outcome = "Nickel"
		elseif rand < 6 then
			outcome = "Dime"
		elseif rand < 7 then
			outcome = "Golden"
		elseif rand < 8 then
			outcome = "Haunted"
		else
			Repeat = Repeat + r:RandomInt(3)
		end

	elseif rand < 13 then
		--Bombs (30%)
		rand = r:RandomInt(100)
		if rand < 20 then
			outcome = "Double"
		elseif rand < 25 then
			outcome = "Troll"
		elseif rand < 26 then
			outcome = "MegaTroll"
		elseif rand < 27 and not mod:allPlayersAreBBlueBaby() then
			outcome = "Golden"
		elseif rand < 28 then
			outcome = "Copper"
		end
		if mod:allPlayersAreBBlueBaby() and (outcome == "Default" or outcome == "Double") then
			Var = 42
			listCheck = "Poops"
		else
			Var = 40
			listCheck = "Bombs"
		end
	elseif rand < 16 or (mod.anyPlayerHas(TrinketType.TRINKET_DAEMONS_TAIL, true) and rand < 19) then
		--Keys (15%)
		Var = 30
		listCheck = "Keys"
		Offset = Vector(0, 2)
		rand = r:RandomInt(100)
		if rand == 1 then
			outcome = "Golden"
		elseif rand == 2 then
			outcome = "Charged"
		end
	elseif rand < 20 then
		--Hearts (20%)
		Var = 10
		listCheck = "Hearts"
		if mod:allPlayersAreKeeper() then
			listCheck = "Familiars"
			outcome = "Fly"
			Offset = Vector(0, 5)
		elseif mod.anyPlayerHas(TrinketType.TRINKET_DAEMONS_TAIL, true) then
			outcome = "Black"
		else
			rand = r:RandomInt(100)
			if rand == 0 then
				outcome = "Double"
			elseif rand <= 10 then
				local rand = r:RandomInt(100)
				if rand < 10 then
					outcome = "Black"
				elseif rand < 20 then
					outcome = "HalfSoul"
				elseif rand < 30 then
					outcome = "Rotten"
				elseif rand < 35 then
					outcome = "Immoral"
				elseif rand < 40 then
					outcome = "Eternal"
				elseif rand < 41 then
					outcome = "Golden"
				elseif rand < 50 then
					outcome = "Bone"
				else
					outcome = "Soul"
				end
			elseif rand <= 60 then
				outcome = "Half"
			end
		end
	end

	local outputData = mod.RandomChestOutcomes[listCheck][outcome]
	if outputData.Unlocked and not outputData.Unlocked() then
		outcome = outputData.ReplaceWith
	end

	if outcome == "Default" then
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE) or (mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BOGO_BOMBS) and (listCheck == "Poops" or listCheck == "Bombs")) then
			outcome = "Double"
		end
	end
	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SACK_HEAD) then
		local chance = 2
		if listCheck == "Coins" then
			chance = 1
		end
		if r:RandomInt(10) < chance then
			Repeat = 1
			listCheck = "Sacks"
			outcome = "GrabBag"
			Var = 69
		end
	end
	if mod.RandomChestOutcomes[listCheck][outcome] then
		Type = mod.RandomChestOutcomes[listCheck][outcome].Type or Type
		Var = mod.RandomChestOutcomes[listCheck][outcome].Var or Var
		Sub = mod.RandomChestOutcomes[listCheck][outcome].Sub or 0

		Anm2 = mod.RandomChestOutcomes[listCheck][outcome].Anm2
		AnimationFrame = mod.RandomChestOutcomes[listCheck][outcome].AnimationFrame or 0
	end

	return Type, Var, Sub, Anm2, Offset, AnimationFrame, Repeat
end

--Glass Chest
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, chest)
	chest = chest:ToPickup()
	local sprite = chest:GetSprite()
	local chestseed = tostring(chest.InitSeed)
    local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'ChestData', chestseed, {})
	local gd = chest:GetData()
	--chest.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	chest.Velocity = chest.Velocity * 0.8
	if not d.init then
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_PAY_TO_PLAY) then
			gd.payToPlayMode = true
			sprite:ReplaceSpritesheet(0, "gfx/items/slots/glass_chest_paytoplay.png")
			sprite:LoadGraphics()
		end
		if gd.Opened then return end
		chest:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
		sprite:Play("Appear", true)
		--sprite.Color = Color(0,0,0,0.2)
		d.drops = {}
		local r = chest:GetDropRNG()
		local PokerFly
		local PokerMulti = 1
		local MomsKeyMulti = 1
		if mod.anyPlayerHas(TrinketType.TRINKET_POKER_CHIP, true) then
			if math.random(2) == 1 then
				PokerFly = true
			else
				PokerMulti = 2
			end
		end
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_MOMS_KEY) then
			MomsKeyMulti = 2
		end
		if PokerFly then
			table.insert(d.drops, {Type = "Monster", ID = 18, Anm2 = "018.000_attack fly", Animation = "Fly"})
		elseif r:RandomInt(50) == 1 then
			local rand = r:RandomInt(50)
			if rand == 1 then
				table.insert(d.drops, {Type = "Item", ID = mod.GetItemFromCustomItemPool(mod.CustomPool.GLASS_CHEST_RARE, r)})
			elseif rand < 10 then
				for i = 1, PokerMulti do
					table.insert(d.drops, {Type = "Trinket", ID = mod.GetItemFromCustomItemPool(mod.CustomPool.GLASS_CHEST_TRINKET, r)})
				end
			else
				table.insert(d.drops, {Type = "Item", ID = mod.GetItemFromCustomItemPool(mod.CustomPool.GLASS_CHEST_COMMON, r)})
			end
		else
			local rand = r:RandomInt(20)
			local pickupCount
			if rand < 1 then
				for i = 1, PokerMulti do
					local CardDrop = mod.GlassChestDrops.Cards.Runes[r:RandomInt(#mod.GlassChestDrops.Cards.Runes) + 1]
					if CardDrop.Unlocked and not CardDrop.Unlocked() then
						CardDrop = CardDrop.ReplaceWith
					end

					table.insert(d.drops, {Type = "Card", ID = CardDrop.CardID, Anm2 = CardDrop.Anm2})
				end
			elseif rand < 2 then
				for i = 1, PokerMulti do
					local CardDrop = mod.GlassChestDrops.Cards.Souls[r:RandomInt(#mod.GlassChestDrops.Cards.Souls) + 1]
					if CardDrop.Unlocked and not CardDrop.Unlocked() then
						CardDrop = mod.GlassChestDrops.Cards.Runes[r:RandomInt(#mod.GlassChestDrops.Cards.Runes) + 1]
						if CardDrop.Unlocked and not CardDrop.Unlocked() then
							CardDrop = CardDrop.ReplaceWith
						end
					end

					table.insert(d.drops, {Type = "Card", ID = CardDrop.CardID, Anm2 = CardDrop.Anm2})
				end
			elseif rand < 5 then
				for i = 1, PokerMulti do
					local CardDrop = mod.GlassChestDrops.Cards.Dice[r:RandomInt(#mod.GlassChestDrops.Cards.Dice) + 1]
					table.insert(d.drops, {Type = "Card", ID = CardDrop.CardID, Anm2 = CardDrop.Anm2})
				end
			elseif rand < 10 then
				pickupCount = 2
			elseif rand < 16 then
				pickupCount = 3
			elseif rand < 20 then
				pickupCount = 4
			else
				table.insert(d.drops, {Type = "Monster", ID = 20, Anm2 = "020.000_monstro", Animation = "Walk", Scale = 0.3, Offset = Vector(0, 5)})
				for i = 1, 3 do
					table.insert(d.drops, {Type = "Monster", ID = 10, Anm2 = "010.000_frowning gaper", Animation = "WalkVert", Overlay = "Head", OverlayFrame = "16", Scale = 0.3, Offset = Vector(0, 5)})
				end
			end

			if pickupCount then
				pickupCount = pickupCount * MomsKeyMulti
				for i = 1, pickupCount do
					local PType, PVar, PSub, PAnm2, POff, PFrame, PRepeat = mod:GetRandomChestItem(chest)
					local repeatTimes = PRepeat * PokerMulti
					for i = 1, repeatTimes do
						table.insert(d.drops, {Type = "Pickup", TypeNum = PType, Var = PVar, Sub = PSub, Anm2 = PAnm2, Offset = POff, AnimationFrame = PFrame})
					end
				end
			end
		end
		d.init = true
		gd.init = true
	elseif not gd.init then
		chest:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
		if chest.SubType == 1 then
			chest:Remove()
		else
			sprite:Play("Idle")
		end
		gd.init = true
	end

	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 0, false, 1.0)
	end
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", true)
	end

	local dist = Game():GetNearestPlayer(chest.Position).Position:Distance(chest.Position)
	local newAlpha
	if dist < 150 then
		newAlpha = 0.8
	else
		newAlpha = math.max(0.8 - 0.003 * (dist - 150), 0.45)
	end
	gd.Alpha = gd.Alpha or newAlpha
	gd.Alpha = mod:Lerp(gd.Alpha, newAlpha, 0.75)
	
	if chest.FrameCount >= 5 then
		for _, splosion in pairs(Isaac.FindByType(1000, 1, -1, false, false)) do
			if splosion.FrameCount <= 1 then
				if splosion.Position:Distance(chest.Position) < 90 then
					local effect = Isaac.Spawn(1000,7000,0,chest.Position,nilvector,nil)
					effect.DepthOffset = -200
					local efsprite = effect:GetSprite()
					efsprite:Load("gfx/items/slots/glass_chest.anm2",true)
					if mod.anyPlayerHas(TrinketType.TRINKET_FLAT_FILE, true) then
						efsprite:Play("ShatterFade",true)
					else
						efsprite:Play("Shatter",true)
						effect:GetData().DangerousToFeetsies = true
					end
					sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.8, 0, false, math.random(110,130)/100)
					if (not gd.Opened) and mod.anyPlayerHas(TrinketType.TRINKET_BROKEN_PADLOCK, true) then
						mod:openGlassChest(chest)
					end
					chest:Remove()
					return
				end
			end
		end
	end
	for _, siren in pairs(Isaac.FindByType(EntityType.ENTITY_SIREN)) do
		if siren:GetSprite():IsPlaying("Attack1Loop") then
			local effect = Isaac.Spawn(1000,7000,0,chest.Position,nilvector,nil)
			effect.DepthOffset = -200
			local efsprite = effect:GetSprite()
			efsprite:Load("gfx/items/slots/glass_chest.anm2",true)
			if mod.anyPlayerHas(TrinketType.TRINKET_FLAT_FILE, true) then
				efsprite:Play("ShatterFade",true)
			else
				efsprite:Play("Shatter",true)
				effect:GetData().DangerousToFeetsies = true
			end
			sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.8, 0, false, math.random(110,130)/100)
			chest:Remove()
			return
		end
	end
end, 713)

function mod:openGlassChest(chest)
	local chestseed = tostring(chest.InitSeed)
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'ChestData', chestseed, {})
	if d.drops and #d.drops > 0 then
		local vec = RandomVector()
		for i = 1, #d.drops do
			if d.drops[i].Type == "Item" then
				local item = Isaac.Spawn(5, 100, d.drops[i].ID, chest.Position, nilvector, chest)
				item.SpawnerType = 5
				item.SpawnerVariant = 713
				local itemSprite = item:GetSprite()
				item:GetSprite():ReplaceSpritesheet(5, "gfx/items/slots/ff_chest_pedestals.png")
				item:GetSprite():LoadGraphics()
				itemSprite:SetOverlayFrame("Alternates", 4)
				item:Update()
				item:Update()
				item:Update()
				item:Update()
				chest:Remove()
			else
				local vel = vec:Rotated((i / #d.drops * 360) + (-90 + math.random(90))):Resized(math.random(3,6))
				local IType, IVar, ISub = 5, 0, 0
				local SpawnPos = chest.Position
				if d.drops[i].Type == "Trinket" then
					IVar, ISub = 350, d.drops[i].ID
				elseif d.drops[i].Type == "Card" then
					IVar, ISub = 300, d.drops[i].ID
				elseif d.drops[i].Type == "Pickup" then
					IType, IVar, ISub = d.drops[i].TypeNum, d.drops[i].Var, d.drops[i].Sub
				elseif d.drops[i].Type == "Monster" then
					IType, IVar, ISub = d.drops[i].ID, d.drops[i].Var or IVar, d.drops[i].Sub or ISub
					local player = Game():GetNearestPlayer(chest.Position)
					SpawnPos = SpawnPos + (chest.Position - player.Position):Resized(10)
				end
				local pickup = Isaac.Spawn(IType, IVar, ISub, SpawnPos, vel, Isaac.GetPlayer(0))
				if pickup.Type == 3 then
					pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				elseif pickup.Type >= 10 then
					if pickup.CollisionDamage > 0 then
						local StoredColl = pickup.CollisionDamage
						pickup.CollisionDamage = 0
						mod.scheduleForUpdate(function()
							if pickup and pickup:Exists() then
								pickup.CollisionDamage = StoredColl
							end
						end, 10)
						pickup:Update()
					end
				end
			end
		end
	end
	chest.SubType = 1
end

function mod:GlassChestPedestal(pickup)
	--print(pickup.InitSeed)
	if pickup.Variant == 100 then
		local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'PedestalData', tostring(pickup.InitSeed), {})
		if d.replaceMeGlass or (pickup.SpawnerEntity and pickup.SpawnerEntity.Type == 5 and pickup.SpawnerEntity.Variant == 713) then
			pickup:GetSprite():ReplaceSpritesheet(5, "gfx/items/slots/ff_chest_pedestals.png")
			pickup:GetSprite():LoadGraphics()
			pickup:GetSprite():SetOverlayFrame("Alternates", 4)
			d.replaceMeGlass = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.GlassChestPedestal)

mod.GuppyEyeOffsets = {
	[1] = {Vector(0, 4)},
	[2] = {Vector(8, 4), Vector(-8, 4)},
	[3] = {Vector(0, 8), Vector(-12, 0), Vector(12, 0)},
	[4] = {Vector(0, 12), Vector(-12, 6), Vector(12, 6), Vector(0, 0)},
	[5] = {Vector(0, 16), Vector(-9, 9), Vector(9, 9), Vector(-6, 0), Vector(6, 0)},
	[6] = {Vector(-6, 16), Vector(6, 16), Vector(-9, 8), Vector(9, 8), Vector(-6, 0), Vector(6, 0)},
	[7] = {Vector(-6, 16), Vector(6, 16), Vector(-12, 8), Vector(0, 8), Vector(12, 8), Vector(-6, 0), Vector(6, 0)},
	[8] = {Vector(0, 16), Vector(9, 14), Vector(-9, 14), Vector(12, 8), Vector(-12, 8), Vector(9, 2), Vector(-9, 2), Vector(0,0)},
	[9] = {Vector(-12, 16), Vector(0, 16), Vector(12, 16), Vector(-12, 8), Vector(0, 8), Vector(12, 8), Vector(-12, 0), Vector(0,0), Vector(12, 0)},
	[10] ={Vector(-8, 16), Vector(0, 16), Vector(8, 16), Vector(-12, 8), Vector(-4, 8), Vector(4, 8), Vector(12, 8), Vector(-8, 0), Vector(0, 0), Vector(8, 0),},
	[11] ={Vector(-12, 16), Vector(-4, 16), Vector(4, 16), Vector(12, 16), Vector(-8, 8), Vector(0, 8), Vector(8, 8), Vector(-12, 0), Vector(-4, 0), Vector(4, 0), Vector(12, 0)},
	[12] ={Vector(-12, 12), Vector(-4, 12), Vector(4, 12), Vector(12, 12), Vector(-12, 6), Vector(-4, 6), Vector(4, 6), Vector(12, 6), Vector(-12, 0), Vector(-4, 0), Vector(4, 0), Vector(12, 0)},
	[13] ={Vector(-6, 15), Vector(6, 15), Vector(-12, 10), Vector(-4, 10), Vector(4, 10), Vector(12, 10), Vector(-12, 5), Vector(-4, 5), Vector(4, 5), Vector(12, 5), Vector(-8, 0), Vector(0, 0), Vector(8, 0)},
	[14] ={Vector(-8, 15), Vector(0, 15), Vector(8, 15), Vector(-12, 10), Vector(-4, 10), Vector(4, 10), Vector(12, 10), Vector(-12, 5), Vector(-4, 5), Vector(4, 5), Vector(12, 5), Vector(-8, 0), Vector(0, 0), Vector(8, 0)},
	[15] ={Vector(-8, 15), Vector(0, 15), Vector(8, 15), Vector(-12, 10), Vector(-4, 10), Vector(4, 10), Vector(12, 10), Vector(-12, 5), Vector(-4, 5), Vector(4, 5), Vector(12, 5), Vector(-12, 0), Vector(-4, 0), Vector(4, 0), Vector(12, 0)},
	[16] ={Vector(-12, 15), Vector(-4, 15), Vector(4, 15), Vector(12, 15), Vector(-12, 10), Vector(-4, 10), Vector(4, 10), Vector(12, 10), Vector(-12, 5), Vector(-4, 5), Vector(4, 5), Vector(12, 5), Vector(-12, 0), Vector(-4, 0), Vector(4, 0), Vector(12, 0)},
}

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, chest)
	local chestseed = tostring(chest.InitSeed)
    local gd = chest:GetData()
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'ChestData', chestseed, {})
	if chest:GetData().Opened then return end
	local icon = Sprite()
	icon.Color = Color(icon.Color.R, icon.Color.G, icon.Color.B, gd.Alpha or 0.8, icon.Color.RO, icon.Color.GO, icon.Color.BO)


	icon:Load("gfx/005.011_heart.anm2", true)
	icon:SetFrame("Idle", 0)
	local baseOffset = nilvector
	if d.drops and #d.drops > 0 then
		local count = math.min(#d.drops, 16)
		for i = 1, #mod.GuppyEyeOffsets[count] do
			baseOffset = nilvector
			icon.Scale = Vector(0.5, 0.5)
			if d.drops[i].Type then
				if d.drops[i].Type == "Item" then
					icon:Load("gfx/005.100_collectible.anm2", true)
					icon:SetFrame("Idle", 0)
					icon:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(d.drops[i].ID).GfxFileName)
					baseOffset = Vector(0, 12)
					icon:LoadGraphics()
				elseif d.drops[i].Type == "Trinket" then
					icon:Load("gfx/005.350_trinket.anm2", true)
					icon:SetFrame("Idle", 0)
					icon:ReplaceSpritesheet(0, Isaac.GetItemConfig():GetTrinket(d.drops[i].ID).GfxFileName)
					icon:LoadGraphics()
				elseif d.drops[i].Type == "Card" then
					icon:Load("gfx/" .. d.drops[i].Anm2 .. ".anm2", true)
					icon:SetFrame("Idle", 0)
				elseif d.drops[i].Type == "Pickup" then
					icon:Load("gfx/" .. d.drops[i].Anm2 .. ".anm2", true)
					icon:SetFrame("Idle", d.drops[i].AnimationFrame or 0)
					baseOffset = d.drops[i].Offset or  Vector(0, 5)
				elseif d.drops[i].Type == "Monster" then
					icon:Load("gfx/" .. d.drops[i].Anm2 .. ".anm2", true)
					icon:SetFrame(d.drops[i].Animation or "Idle", d.drops[i].AnimationFrame or 0)
					if d.drops[i].Overlay then
						icon:SetOverlayFrame(d.drops[i].Overlay or "Idle", d.drops[i].OverlayFrame or 0)
					end
					baseOffset = d.drops[i].Offset or  Vector(0, 5)
					if d.drops[i].Scale then
						icon.Scale = Vector(d.drops[i].Scale, d.drops[i].Scale)
					end
				--Jokes
				end
			end
			local renderPos = chest.Position + baseOffset - mod.GuppyEyeOffsets[count][i]
			renderPos = Isaac.WorldToScreen(renderPos)
			icon:Render(renderPos, Vector.Zero, Vector.Zero)
		end
	end
end, 713)