local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, useflags)
	local r = player:GetCardRNG(cardID)
	for i = 1, 4 + r:RandomInt(4) do
		local egg = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, player.Position + RandomVector() * math.random(5, 40), nilvector, player)
		egg:GetData().canreroll = false
		egg.EntityCollisionClass = 4
		egg.Parent = player
		egg:GetData().hollow = true

		if not mod.IsActiveRoom() then
			egg:GetData().mixPersistent = true
			egg:GetData().mixRemainingRooms = 1
			egg:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end

		local poof = Isaac.Spawn(1000, 15, 0, egg.Position, nilvector, nil)
		poof.SpriteScale = poof.SpriteScale * 0.5
		poof.Color = Color(0.3,0.3,0.3,1,10 / 255,0,10 / 255)

		egg:Update()
	end
	local CoolEggs = 0
	local randy = r:RandomInt(10)
	if randy < 3 then
		CoolEggs = 1
	elseif randy < 5 then
		CoolEggs = 2
	end
	if CoolEggs > 0 then
		for i = 1, CoolEggs do
			local egg = Isaac.Spawn(5, PickupVariant.PICKUP_FIEND_MINION, 1, player.Position + RandomVector() * math.random(5, 40), nilvector, player)
			egg.EntityCollisionClass = 4
			egg.Parent = player

			if not mod.IsActiveRoom() then
				egg:GetData().mixPersistent = true
				egg:GetData().mixRemainingRooms = 1
				egg:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			end

			local poof = Isaac.Spawn(1000, 15, 0, egg.Position, nilvector, nil)
			poof.SpriteScale = poof.SpriteScale * 0.5
			poof.Color = Color(0.3,0.3,0.3,1,10 / 255,0,10 / 255)

			egg:Update()
		end
	end
	mod:trySayAnnouncerLine(mod.Sounds.SoulOfFiendVO, useflags)
end, mod.ITEM.CARD.SOUL_OF_FIEND)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
	local vec = RandomVector() * 3
	for i = 120, 360, 120 do
		Isaac.Spawn(5, 350, FiendFolio.GetNextMiningMachineTrinket(0, player), player.Position, vec:Rotated(i), player)
	end
end, mod.ITEM.CARD.SOUL_OF_GOLEM)

mod.RandomSouls = {
	Card.CARD_SOUL_ISAAC,
	Card.CARD_SOUL_MAGDALENE,
	Card.CARD_SOUL_CAIN,
	Card.CARD_SOUL_JUDAS,
	Card.CARD_SOUL_BLUEBABY,
	Card.CARD_SOUL_EVE,
	Card.CARD_SOUL_SAMSON,
	Card.CARD_SOUL_AZAZEL,
	Card.CARD_SOUL_LAZARUS,
	Card.CARD_SOUL_EDEN,
	Card.CARD_SOUL_LOST,
	Card.CARD_SOUL_LILITH,
	Card.CARD_SOUL_KEEPER,
	Card.CARD_SOUL_APOLLYON,
	Card.CARD_SOUL_FORGOTTEN,
	Card.CARD_SOUL_BETHANY,
	Card.CARD_SOUL_JACOB,
	mod.ITEM.CARD.SOUL_OF_FIEND,
	mod.ITEM.CARD.SOUL_OF_GOLEM,
}

local fuckYouNicalis = {
	[Card.CARD_SOUL_ISAAC] 		= "Soul of Isaac",
	[Card.CARD_SOUL_MAGDALENE] 	= "Soul of Magdalene",
	[Card.CARD_SOUL_CAIN] 		= "Soul of Cain",
	[Card.CARD_SOUL_JUDAS] 		= "Soul of Judas",
	[Card.CARD_SOUL_BLUEBABY] 	= "Soul of ???",
	[Card.CARD_SOUL_EVE] 		= "Soul of Eve",
	[Card.CARD_SOUL_SAMSON] 	= "Soul of Samson",
	[Card.CARD_SOUL_AZAZEL] 	= "Soul of Azazel",
	[Card.CARD_SOUL_LAZARUS] 	= "Soul of Lazarus",
	[Card.CARD_SOUL_EDEN] 		= "Soul of Eden",
	[Card.CARD_SOUL_LOST] 		= "Soul of the Lost",
	[Card.CARD_SOUL_LILITH] 	= "Soul of the Lost",
	[Card.CARD_SOUL_KEEPER] 	= "Soul of the Keeper",
	[Card.CARD_SOUL_APOLLYON] 	= "Soul of Apollyon",
	[Card.CARD_SOUL_FORGOTTEN] 	= "Soul of the Forgotten",
	[Card.CARD_SOUL_BETHANY] 	= "Soul of Bethany",
	[Card.CARD_SOUL_JACOB] 		= "Soul of Jacob and Esau"
}

--Cos of crashes, forgotten and jacob currently disabled
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, useflags)
	local r = player:GetCardRNG(cardID)
	local choice = mod.RandomSouls[r:RandomInt(#mod.RandomSouls) + 1]
	if choice == Card.CARD_SOUL_LAZARUS then
		player:AnimateCard(Card.CARD_SOUL_LAZARUS)
		if useflags == useflags | UseFlag.USE_MIMIC then
			Isaac.Spawn(5, 300, choice, player.Position, RandomVector()*3, nil)
		else
			player:AddCard(choice)
		end
	else
		player:UseCard(choice)
	end
	local itemconfig = Isaac:GetItemConfig()
	local cardname = itemconfig:GetCard(choice).Name
	if fuckYouNicalis[choice] then
		cardname = fuckYouNicalis[choice]
	end
	local HUD = game:GetHUD()
	HUD:ShowItemText(cardname)
end, mod.ITEM.CARD.SOUL_OF_RANDOM)