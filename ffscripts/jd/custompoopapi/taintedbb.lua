local mod = CustomPoopAPI
local game = Game()
mod.rng = RNG()

mod.PoopSpellPool = {Common = {}, Uncommon = {}, Rare = {}, Special = {}}
mod.SpellSprites = {}

mod.PoopSpellCallbacks = {["ALL"] = {}}
mod.FillBagCallbacks = {}

mod.SpellTypes = {"POOP", "CORNY", "BURNING", "STONE", "STINKY", "BLACK", "HOLY", "LIQUID", "FART", "BOMB", "DIARREAH"}
mod.SpellAnimations = {"Idle", "IdleSmall", "TransparentSmall", "Transparent"}

function mod:AddPoopSpellCallback(funct, spell)
	if spell then
		mod.PoopSpellCallbacks[spell] = mod.PoopSpellCallbacks[spell] or {}
		table.insert(mod.PoopSpellCallbacks[spell], {funct, spell})
	else
		table.insert(mod.PoopSpellCallbacks["ALL"], {funct, spell})
	end
end

function mod:RunPoopSpellCallback(spell, args)
	local callbacks = mod.PoopSpellCallbacks[spell] or {}
	for _, callback in pairs(callbacks) do
		callback[1](_, args[1], args[2])
	end
	for _, callback in pairs(mod.PoopSpellCallbacks["ALL"]) do
		callback[1](_, args[1], args[2])
	end
end

function mod:AddFillBagCallback(funct)
	table.insert(mod.FillBagCallbacks, funct)
end

function mod:RunFillBagCallback()
	for _, callback in pairs(mod.FillBagCallbacks) do
		callback()
	end
end

function mod:Shuffle(tbl)
	for i = #tbl, 2, -1 do
    local j = mod:RandomInt(1, i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function mod:RandomInt(min, max, customRNG) --This and GetRandomElem were written by Guwahavel (hi)
    local rand = customRNG or mod.rng 
    if not max then
        max = min
        min = 0
    end  
    if min > max then 
        local temp = min
        min = max
        max = temp
    end
    return min + (rand:RandomInt(max - min + 1))
end

function mod:GetRandomElem(table, customRNG)
    if table and #table > 0 then
		local index = mod:RandomInt(1, #table, customRNG)
        return table[index], index
    end
end

function mod:GetRandomElemWeighted(tbl)
	local totalweight = 0
	for i, entry in pairs(tbl) do
		if entry.Weight then
			totalweight = totalweight + entry.Weight
		end
	end
	local randomfloat = mod.rng:RandomFloat()*totalweight
	for i, entry in pairs(tbl) do
		if entry.Weight then
			randomfloat = randomfloat - entry.Weight
		end
		if randomfloat < 0 then
			return entry
		end
	end
end

mod.savedata.persistentPlayerData = mod.savedata.persistentPlayerData or {}
function mod.GetPersistentPlayerData(player) --From Retribution, by Xalum
	if player and mod.savedata and mod.savedata.persistentPlayerData then
		local seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
		local playerType = player:GetPlayerType()

		if playerType == PlayerType.PLAYER_LAZARUS2_B then
			seedReference = CollectibleType.COLLECTIBLE_INNER_EYE
		end

		local tableIndex = player:GetCollectibleRNG(seedReference):GetSeed()
		tableIndex = tostring(tableIndex)

		mod.savedata.persistentPlayerData[tableIndex] = mod.savedata.persistentPlayerData[tableIndex] or {}
		return mod.savedata.persistentPlayerData[tableIndex]
	else
		return {}
	end
end

function mod:FillPoopBag(tbl)
	for i, entry in pairs(mod.PoopSpellPool.Special) do
		if mod.rng:RandomFloat() <= entry.Weight then
			table.insert(tbl, entry.Spell)
		end
	end
	for i = 1, 5 do
		local entry = mod:GetRandomElemWeighted(mod.PoopSpellPool.Common)
		if entry then
			table.insert(tbl, entry.Spell)
		end
	end
	for i = 1, 11 do
		local entry = table.insert(tbl, mod:GetRandomElemWeighted(mod.PoopSpellPool.Uncommon).Spell)
		if entry then
			table.insert(tbl, entry.Spell)
		end
	end
	local rareentry = table.insert(tbl, mod:GetRandomElemWeighted(mod.PoopSpellPool.Rare).Spell)
	if rareentry then
		table.insert(tbl, entry.Spell)
	end
	
	mod:Shuffle(tbl)
	mod:RunFillBagCallback()
end

function mod:AddSpellToPool(spell, pool, weight)
	table.insert(mod.PoopSpellPool[pool], {Spell = spell, Weight = weight})
end

local reticle = Sprite()
reticle:Load("gfx/ui/ui_custompoops.anm2", true)
reticle:ReplaceSpritesheet(0, "gfx/ui/ui_poops.png")
reticle:LoadGraphics()
reticle:Play("Idle")
reticle:SetFrame(11)

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
	if action == ButtonAction.ACTION_BOMB and entity:ToPlayer() and entity:ToPlayer():GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
		local player = entity:ToPlayer()
		local savedata = mod.GetPersistentPlayerData(player)
		savedata.Poops = savedata.Poops or {}
		savedata.PoopBacklog = savedata.PoopBacklog or {}
		if #savedata.PoopBacklog == 0 then
			mod:FillPoopBag(savedata.PoopBacklog)
		end
		if #savedata.Poops < 6 then
			for i = 1, 6 - #savedata.Poops do
				if savedata.PoopBacklog[1] then
					table.insert(savedata.Poops, savedata.PoopBacklog[1])
					table.remove(savedata.PoopBacklog, 1)
				end
			end
		end
		if Input.IsActionTriggered(action, player.ControllerIndex) and not player:ThrowHeldEntity(Vector.Zero) and player:GetPoopMana() > 0 and savedata.Poops then
			if savedata and savedata.Poops then
				player:AddPoopMana(-1)
				mod:RunPoopSpellCallback(savedata.Poops[1], {savedata.Poops[1], player})
				table.remove(savedata.Poops, 1)
			end
		end
		return false
	end
end, InputHook.IS_ACTION_TRIGGERED)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function(_)
	local player = Isaac.GetPlayer(0)
	local hudOffset = Options.HUDOffset
	local offset = Vector(hudOffset * 20, hudOffset * 12)
	if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B and game:GetHUD():IsVisible() then
		local savedata = mod.GetPersistentPlayerData(player)
		if savedata.Poops then
			for i = 2, 6 do
				if player:GetPoopMana() >= i then
					mod.SpellSprites[savedata.Poops[i]].IdleSmall:Render(Vector(38+12*i, 40)+offset)
				else
					mod.SpellSprites[savedata.Poops[i]].TransparentSmall:Render(Vector(38+12*i, 40)+offset)
				end
				--print(savedata.Poops[i][1], mod.SpellSprites[savedata.Poops[i][1]][1]:GetFrame())
			end
			if player:GetPoopMana() >= 1 then
				mod.SpellSprites[savedata.Poops[1]].Idle:Render(Vector(50, 40)+offset)
			else
				mod.SpellSprites[savedata.Poops[1]].Transparent:Render(Vector(50, 40)+offset)
			end
			reticle:Render(Vector(50,40)+offset)
		end
	end
	--[[if game:GetFrameCount() % 2 == 0 then
		mod.SpellSprites["GOLD"][1]:Update()
	end]]
end)

for i = PoopSpellType.SPELL_POOP, PoopSpellType.NUM_POOP_SPELLS - 1 do
	local spelltype = mod.SpellTypes[i]
	mod.SpellSprites[spelltype] = mod.SpellSprites[spelltype] or {}
	
	for j = 1, 4 do
		mod.SpellSprites[spelltype][mod.SpellAnimations[j]] = Sprite()
		mod.SpellSprites[spelltype][mod.SpellAnimations[j]]:Load("gfx/ui/ui_custompoops.anm2", true)
		mod.SpellSprites[spelltype][mod.SpellAnimations[j]]:ReplaceSpritesheet(0, "gfx/ui/ui_poops.png")
		mod.SpellSprites[spelltype][mod.SpellAnimations[j]]:LoadGraphics()
		mod.SpellSprites[spelltype][mod.SpellAnimations[j]]:Play(mod.SpellAnimations[j])
		mod.SpellSprites[spelltype][mod.SpellAnimations[j]]:SetFrame(i-1)
	end
	
	mod:AddPoopSpellCallback(function(_, spell, player)
		player:UsePoopSpell(i)
	end, spelltype)
end

mod:AddSpellToPool("POOP", "Common", 5)
mod:AddSpellToPool("FART", "Common", 5)
mod:AddSpellToPool("CORNY", "Common", 1)
mod:AddSpellToPool("BURNING", "Common", 1)
mod:AddSpellToPool("STINKY", "Common", 1)
mod:AddSpellToPool("STONE", "Common", 1)
mod:AddSpellToPool("BOMB", "Common", 1)

mod:AddSpellToPool("CORNY", "Uncommon", 1)
mod:AddSpellToPool("BURNING", "Uncommon", 1)
mod:AddSpellToPool("STINKY", "Uncommon", 1)
mod:AddSpellToPool("STONE", "Uncommon", 1)
mod:AddSpellToPool("BOMB", "Uncommon", 1)

mod:AddSpellToPool("BLACK", "Rare", 1)
mod:AddSpellToPool("HOLY", "Rare", 1)
mod:AddSpellToPool("DIARREAH", "Rare", 1)

mod:AddSpellToPool("BOMB", "Special", 1)
mod:AddSpellToPool("FART", "Special", 1)
mod:AddSpellToPool("LIQUID", "Special", 1)