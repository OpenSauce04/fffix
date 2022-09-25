local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.blackListedPickups = {
	[100] = true,
	[340] = true,
	[370] = true,
	[380] = true,
	[390] = true,
}

mod.poopyFamiliars = {
	Common = {1, 2, 20},
	Rare = 	 {3, 4, 5, 6, 12, 13, 14, 666, 667, 668, 669, 670, 671},
}

function mod.getRandomAttackFamiliar(r)
	local val = {3, 43, 0}
	local repeatVal
	local rand = r:RandomInt(20)
	if rand == 0 then
		--Mini isaacs
		val = {3, 228, 0}
	elseif rand == 1 then
		--Fragile Bobbies
		val = {3, mod.ITEM.FAMILIAR.FRAGILE_BOBBY, 0}
	elseif rand < 6 then
		--Spindly spiders
		val = {3, 73, 0}
	elseif rand < 8 then
		--Scurrilous skuzzes
		val = {3, 1026, 0}
		rand = r:RandomInt(10)
		if rand == 1 then
			val[3] = r:RandomInt(4) + 1
			if val[3] == 5 then
				repeatVal = 3
			end
		end
	elseif rand < 10 then
		--Funny poopies
		val = {3, 201, 0}
		rand = r:RandomInt(10)
		if rand < 3 then
			val[3] = mod.poopyFamiliars.Common[r:RandomInt(#mod.poopyFamiliars.Common) + 1]
		elseif rand < 4 then
			val[3] = mod.poopyFamiliars.Rare[r:RandomInt(#mod.poopyFamiliars.Rare) + 1]
		end

	else
		--Fiddly Flies
		rand = r:RandomInt(10)
		if rand == 1 then
			val[3] = r:RandomInt(5) + 1
		end
	end
	return val, repeatVal
end

function mod:useAceCard(card, player, flags)
	local name = string.sub(Isaac.GetItemConfig():GetCard(card).Name, 8)
	local r = player:GetCardRNG(card)
	for _, ent in ipairs(Isaac.GetRoomEntities()) do
		local isMorph
		local hasTimer
		local repeatMe
		if (ent.Type == 5 and not (mod.blackListedPickups[ent.Variant] or ent:ToPickup():IsShopItem())) or (ent:ToNPC() and ent:ToNPC():IsVulnerableEnemy() and not ent:ToNPC():IsBoss()) then
			if name == "Wands" then
				isMorph = {5, 90}
				hasTimer = true
			elseif name == "Pentacles" then
				isMorph = {5, 350}
			elseif name == "Swords" then
				isMorph = {3, 43, 0}
				if game:GetRoom():GetGridCollisionAtPos(ent.Position) == GridCollisionClass.COLLISION_NONE then
					isMorph, repeatMe = mod.getRandomAttackFamiliar(r)
				end
			elseif name == "Cups" then
				isMorph = {5, 70}
			end
			--print(isMorph)
			if isMorph then
				if repeatMe then
					local vec = RandomVector():Resized(15)
					for i = 360/repeatMe, 360, 360/repeatMe do
						local pickup = Isaac.Spawn(3, 43, 5, ent.Position + vec:Rotated(i), nilvector, player)
					end
				else
					local pickup = Isaac.Spawn(isMorph[1] or 5, isMorph[2] or 0, isMorph[3] or 0, ent.Position, nilvector, player)
					if hasTimer then
						pickup = pickup:ToPickup()
						pickup.Timeout = 60
					end
				end
				ent:Remove()
			end
		end
	end
	if name == "Wands" then
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingAceWands, flags, 40)
	elseif name == "Pentacles" then
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingAcePentacles, flags, 40)
	elseif name == "Swords" then
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingAceSwords, flags, 40)
	elseif name == "Cups" then
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingAceCups, flags, 40)
	end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useAceCard, Card.ACE_OF_WANDS)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useAceCard, Card.ACE_OF_PENTACLES)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useAceCard, Card.ACE_OF_SWORDS)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useAceCard, Card.ACE_OF_CUPS)