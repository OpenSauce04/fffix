local mod = CustomPoopAPI
local game = Game()
local itemconfig = Isaac.GetItemConfig()

local CUSTOM_HOLD = Isaac.GetItemIdByName(" Hold")
local myItem = CUSTOM_HOLD

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player)
	local savedata = mod.GetPersistentPlayerData(player)
	if savedata.Poops then
		if not savedata.StoredPoop and player:GetPoopMana() > 0 then
			player:AddPoopMana(-1)
			savedata.StoredPoop = savedata.Poops[1]
			table.remove(savedata.Poops, 1)
			SFXManager():Play(SoundEffect.SOUND_POOPITEM_STORE)
			return true
		elseif not player:ThrowHeldEntity(Vector.Zero) then
			mod:RunPoopSpellCallback(savedata.StoredPoop, {savedata.StoredPoop, player})
			savedata.StoredPoop = nil
		end
	end
end, CUSTOM_HOLD)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLD) then
		player:SetPocketActiveItem(CUSTOM_HOLD, ActiveSlot.SLOT_POCKET)
	end
end, PlayerType.PLAYER_BLUEBABY_B)


--Sanio's renderActive helper (with some modifications)!
local function GetBottomRightNoOffset()
    return game:GetRoom():GetRenderSurfaceTopLeft() * 2 + Vector(442, 286)
end

local function GetBottomLeftNoOffset()
    return Vector(0, GetBottomRightNoOffset().Y)
end

local function GetTopRightNoOffset()
    return Vector(GetBottomRightNoOffset().X, 0)
end

local function GetTopLeftNoOffset()
    return Vector.Zero
end

local function GetScreenBottomRight()
    local hudOffset = Options.HUDOffset
    local offset = Vector(-hudOffset * 16, -hudOffset * 6)

    return GetBottomRightNoOffset() + offset
end

local function GetScreenBottomLeft()
    local hudOffset = Options.HUDOffset
    local offset = Vector(hudOffset * 20, -hudOffset * 12)

    return GetBottomLeftNoOffset() + offset
end

local function GetScreenTopRight()
    local hudOffset = Options.HUDOffset
    local offset = Vector(-hudOffset * 20, hudOffset * 12)

    return GetTopRightNoOffset() + offset
end

local function GetScreenTopLeft()
    local hudOffset = Options.HUDOffset
    local offset = Vector(hudOffset * 20, hudOffset * 12)

    return GetTopLeftNoOffset() + offset
end

local function GetActiveSlots(player, itemID)
    local slots = {}
    if player:HasCollectible(itemID) then
        for i = 2, 3 do
            local item = player:GetActiveItem(i)
            if item > 0 then
                local configitem = itemconfig:GetCollectible(item)
                local charges = configitem.MaxCharges
                if player:GetActiveCharge(i) >= charges then
                    table.insert(slots, i)
                end
            end
        end
    end
    return slots
end

local function GetAllMainPlayers()
    local players = {}
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetMainTwin():GetPlayerType() == player:GetPlayerType() --Is the main twin of 2 players
            and (not player.Parent or player.Parent.Type ~= EntityType.ENTITY_PLAYER) --Not an item-related spawned-in player.
        then
            table.insert(players, player)
        end
    end
    return players
end

local ActivePlayers = {
    [1] = {
        Player = nil,
        Offset = Vector(20, 15),
        ScreenPos = GetScreenTopLeft(),
    },
    [2] = {
        Player = nil,
        Offset = Vector(-159, 0),
        ScreenPos = GetScreenTopRight(),
    },
    [3] = {
        Player = nil,
        Offset = Vector(16, -33),
        ScreenPos = GetScreenBottomLeft(),
    },
    [4] = {
        Player = nil,
        Offset = Vector(-20, -16),
        ScreenPos = GetScreenBottomRight(),
    }
}

local function AddActivePlayers(i, player)
    ActivePlayers[i].Player = player

    --Funny Esau takes up p4 spot if they're from p1
    if i == 1
        and player:GetOtherTwin() ~= nil
        and player:GetOtherTwin():GetPlayerType() == PlayerType.PLAYER_ESAU
        and ActivePlayers[4].Player == nil then
        ActivePlayers[4].Player = player
    end
end

local numHUDPlayers = 1

function mod:UpdatePlayerActivePoses()
    local players = GetAllMainPlayers()

    if #players ~= numHUDPlayers then
        numHUDPlayers = #players
        for i = 1, 4 do
            ActivePlayers[i].Player = nil
        end
    end

    for i = 1, #players do
        if i > 4 then break end

        local player = players[i]

        if player:HasCollectible(myItem)
            and ActivePlayers[i].Player == nil
        then
            AddActivePlayers(i, player)
        elseif not player:HasCollectible(myItem)
            and ActivePlayers[i].Player ~= nil then
            ActivePlayers[i].Player = nil
        end
    end
end

local function HasBook(player)
    local hasVirtues = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
    local hasBelial = player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    local hasBook = hasVirtues or hasBelial

    return hasBook
end

function mod:HoldRender(sprite, activePlayer)
	if sprite:IsLoaded()
		and game:GetHUD():IsVisible()
	then
		ActivePlayers[1].ScreenPos = GetScreenTopLeft()
		ActivePlayers[2].ScreenPos = GetScreenTopRight()
		ActivePlayers[3].ScreenPos = GetScreenBottomLeft()
		ActivePlayers[4].ScreenPos = GetScreenBottomRight()
		local slots = GetActiveSlots(activePlayer.Player, myItem)
		for j = 1, #slots do
			local slotOffset = Vector.Zero
			local pos = activePlayer.ScreenPos + activePlayer.Offset
			local size = 1
			if GetPtrHash(activePlayer.Player) == GetPtrHash(Isaac.GetPlayer(0)) and (slots[j] == ActiveSlot.SLOT_POCKET or slots[j] == ActiveSlot.SLOT_POCKET2) then
				pos = GetScreenBottomRight() +ActivePlayers[4].Offset
				local found
				for s = 0, 3 do
					local card = activePlayer.Player:GetCard(s)
					local pill = activePlayer.Player:GetPill(s)
					if card == 0 and pill == 0 and not found then
						if s > 0 then
							size = 0.5
							slotOffset = Vector(8,-12 * s)
						end
						found = true
					end
				end
			elseif slots[j] == ActiveSlot.SLOT_SECONDARY then
				slotOffset = Vector(-16,-8)
				size = 0.5
			end
			sprite.Scale = Vector(size, size)
			if slotOffset:Length() == 0 then
				slotOffset = slotOffset + Vector(0.5, 5)
			else
				slotOffset = slotOffset + Vector(0.5, 1)
			end
			local renderpos = pos + slotOffset
			sprite:Render(renderpos, Vector.Zero, Vector.Zero)
		end
	end
end

--MC_POST_RENDER
function mod:OnRender()
	mod:UpdatePlayerActivePoses()
	for i = 1, #ActivePlayers do
		local activePlayer = ActivePlayers[i]
		if activePlayer and activePlayer.Player ~= nil then
			local savedata = mod.GetPersistentPlayerData(activePlayer.Player)
			if savedata.StoredPoop then
				mod:HoldRender(mod.SpellSprites[savedata.StoredPoop].IdleSmall, ActivePlayers[i])
			end
		end
	end
end

function mod:ResetOnGameStart(iscontinued)
	mod.rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
	if not iscontinued then
		mod.savedata.persistentPlayerData = {}
		for i = 1, 4 do
			ActivePlayers[i].Player = nil
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.OnRender)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ResetOnGameStart)