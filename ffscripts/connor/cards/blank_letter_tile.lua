local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local kZeroVector = Vector.Zero

local kDamageBonus = 1
local kTearsBonus = 1

local kBltDataKey = "FF_BLANK_LETTER_TILE"

local function GetBltData(player)
	local data = player:GetData().ffsavedata
	if not data then return end
	if not data[kBltDataKey] then
		data[kBltDataKey] = {
			queued = 0,
			buttons = {},
			numHeld = 0,
			usedLastFrame = false,
		}
	end
	return data[kBltDataKey]
end

function mod:resetBlankLetterTileData()
	for i=0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(i)
		
		if player and player:Exists() then
			player:GetData().ffsavedata[kBltDataKey] = nil
		end
	end
end

local buttonsSprite = Sprite()
buttonsSprite:Load("gfx/ui/buttons.anm2", true)

local ButtonMap = {
	--[[[0] = { -- DPad Left
		Sprite = buttonsSprite,
		Anim = "Vita",
		Frame = 7,
		Offset = Vector(0, 6),
	},
	[1] = { -- DPad Right
		Sprite = buttonsSprite,
		Anim = "Vita",
		Frame = 6,
		Offset = Vector(0, 6),
	},
	[2] = { -- DPad Up
		Sprite = buttonsSprite,
		Anim = "Vita",
		Frame = 5,
		Offset = Vector(0, 6),
	},
	[3] = { -- DPad Down
		Sprite = buttonsSprite,
		Anim = "Vita",
		Frame = 4,
		Offset = Vector(0, 6),
	},]]
	[0] = { -- DPad Left
		Name = "Left",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 19,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-9, 6),
	},
	[1] = { -- DPad Right
		Name = "Right",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 18,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-8, 6),
	},
	[2] = { -- DPad Up
		Name = "Up",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 17,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-8, 6),
	},
	[3] = { -- DPad Down
		Name = "Down",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 16,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-8, 7),
	},
	[4] = { -- Bottom Face Button (A)
		Name = "(Shoot Down)",
		Sprite = buttonsSprite,
		Anim = "Switch_JoyCon",
		Frame = 2,
		Offset = Vector(0, 6),
	},
	[5] = { -- Right Face Button (B)
		Name = "(Shoot Right)",
		Sprite = buttonsSprite,
		Anim = "Switch_JoyCon",
		Frame = 0,
		Offset = Vector(0, 6),
	},
	[6] = { -- Left Face Button (X)
		Name = "(Shoot Left)",
		Sprite = buttonsSprite,
		Anim = "Switch_JoyCon",
		Frame = 1,
		Offset = Vector(0, 6),
	},
	[7] = { -- Top Face Button (Y)
		Name = "(Shoot Up)",
		Sprite = buttonsSprite,
		Anim = "Switch_JoyCon",
		Frame = 3,
		Offset = Vector(0, 6),
	},
	[8] = "L1",
	[9] = "L2",
	[10] = "LS",
	[11] = "R1",
	[12] = "R2",
	[13] = "RS",
	[14] = "Select",
	--[15] = "Start",
	[Keyboard.KEY_SPACE] = " ",
	[Keyboard.KEY_APOSTROPHE] = "\"",
	[Keyboard.KEY_COMMA] = ",",
	[Keyboard.KEY_MINUS] = "-",
	[Keyboard.KEY_PERIOD] = ".",
	[Keyboard.KEY_SLASH] = "/",
	[Keyboard.KEY_0] = "0",
	[Keyboard.KEY_1] = "1",
	[Keyboard.KEY_2] = "2",
	[Keyboard.KEY_3] = "3",
	[Keyboard.KEY_4] = "4",
	[Keyboard.KEY_5] = "5",
	[Keyboard.KEY_6] = "6",
	[Keyboard.KEY_7] = "7",
	[Keyboard.KEY_8] = "8",
	[Keyboard.KEY_9] = "9",
	[Keyboard.KEY_SEMICOLON] = ";",
	[Keyboard.KEY_EQUAL] = "=",
	[Keyboard.KEY_A] = "A",
	[Keyboard.KEY_B] = "B",
	[Keyboard.KEY_C] = "C",
	[Keyboard.KEY_D] = "D",
	[Keyboard.KEY_E] = "E",
	[Keyboard.KEY_F] = "F",
	[Keyboard.KEY_G] = "G",
	[Keyboard.KEY_H] = "H",
	[Keyboard.KEY_I] = "I",
	[Keyboard.KEY_J] = "J",
	[Keyboard.KEY_K] = "K",
	[Keyboard.KEY_L] = "L",
	[Keyboard.KEY_M] = "M",
	[Keyboard.KEY_N] = "N",
	[Keyboard.KEY_O] = "O",
	[Keyboard.KEY_P] = "P",
	[Keyboard.KEY_Q] = "Q",
	[Keyboard.KEY_R] = "R",
	[Keyboard.KEY_S] = "S",
	[Keyboard.KEY_T] = "T",
	[Keyboard.KEY_U] = "U",
	[Keyboard.KEY_V] = "V",
	[Keyboard.KEY_W] = "W",
	[Keyboard.KEY_X] = "X",
	[Keyboard.KEY_Y] = "Y",
	[Keyboard.KEY_Z] = "Z",
	[Keyboard.KEY_LEFT_BRACKET] = "[",
	[Keyboard.KEY_BACKSLASH] = "\\",
	[Keyboard.KEY_RIGHT_BRACKET] = "]",
	--[Keyboard.KEY_GRAVE_ACCENT] = "~",
	--[Keyboard.KEY_WORLD_1] = "",
	--[Keyboard.KEY_WORLD_2] = "",
	--[Keyboard.KEY_ESCAPE] = "",
	[Keyboard.KEY_ENTER] = "Enter",
	[Keyboard.KEY_TAB] = "Tab",
	[Keyboard.KEY_BACKSPACE] = "Back",
	[Keyboard.KEY_INSERT] = "Insert",
	[Keyboard.KEY_DELETE] = "Delete",
	[Keyboard.KEY_RIGHT] = {
		Name = "Right",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 18,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-8, 6),
	},
	[Keyboard.KEY_LEFT] = {
		Name = "Left",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 19,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-9, 6),
	},
	[Keyboard.KEY_UP] = {
		Name = "Up",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 17,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-8, 6),
	},
	[Keyboard.KEY_DOWN] = {
		Name = "Down",
		Sprite = buttonsSprite,
		Anim = "PS4",
		Frame = 16,
		TopLeftClamp = Vector(18, 0),
		Offset = Vector(-8, 7),
	},
	[Keyboard.KEY_PAGE_UP] = "PgUp",
	[Keyboard.KEY_PAGE_DOWN] = "PgDn",
	[Keyboard.KEY_HOME] = "Home",
	[Keyboard.KEY_END] = "End",
	[Keyboard.KEY_CAPS_LOCK] = "CapsLk",
	[Keyboard.KEY_SCROLL_LOCK] = "ScrlLk",
	[Keyboard.KEY_NUM_LOCK] = "NumLk",
	[Keyboard.KEY_PRINT_SCREEN] = "PrtSc",
	--[Keyboard.KEY_PAUSE] = "Pause",
	[Keyboard.KEY_F1] = "F1",
	[Keyboard.KEY_F2] = "F2",
	[Keyboard.KEY_F3] = "F3",
	[Keyboard.KEY_F4] = "F4",
	[Keyboard.KEY_F5] = "F5",
	[Keyboard.KEY_F6] = "F6",
	[Keyboard.KEY_F7] = "F7",
	[Keyboard.KEY_F8] = "F8",
	[Keyboard.KEY_F9] = "F9",
	[Keyboard.KEY_F10] = "F10",
	[Keyboard.KEY_F11] = "F11",
	[Keyboard.KEY_F12] = "F12",
	[Keyboard.KEY_F13] = "F13",
	[Keyboard.KEY_F14] = "F14",
	[Keyboard.KEY_F15] = "F15",
	[Keyboard.KEY_F16] = "F16",
	[Keyboard.KEY_F17] = "F17",
	[Keyboard.KEY_F18] = "F18",
	[Keyboard.KEY_F19] = "F19",
	[Keyboard.KEY_F20] = "F20",
	[Keyboard.KEY_F21] = "F21",
	[Keyboard.KEY_F22] = "F22",
	[Keyboard.KEY_F23] = "F23",
	[Keyboard.KEY_F24] = "F24",
	[Keyboard.KEY_F25] = "F25",
	[Keyboard.KEY_KP_0] = "0",
	[Keyboard.KEY_KP_1] = "1",
	[Keyboard.KEY_KP_2] = "2",
	[Keyboard.KEY_KP_3] = "3",
	[Keyboard.KEY_KP_4] = "4",
	[Keyboard.KEY_KP_5] = "5",
	[Keyboard.KEY_KP_6] = "6",
	[Keyboard.KEY_KP_7] = "7",
	[Keyboard.KEY_KP_8] = "8",
	[Keyboard.KEY_KP_9] = "9",
	[Keyboard.KEY_KP_DECIMAL] = ".",
	[Keyboard.KEY_KP_DIVIDE] = "/",
	[Keyboard.KEY_KP_MULTIPLY] = "*",
	[Keyboard.KEY_KP_SUBTRACT] = "-",
	[Keyboard.KEY_KP_ADD] = "+",
	[Keyboard.KEY_KP_ENTER] = "Enter",
	[Keyboard.KEY_KP_EQUAL] = "=",
	[Keyboard.KEY_LEFT_SHIFT] = "Shift",
	[Keyboard.KEY_LEFT_CONTROL] = "Ctrl",
	[Keyboard.KEY_LEFT_ALT] = "Alt",
	[Keyboard.KEY_LEFT_SUPER] = "Super",
	[Keyboard.KEY_RIGHT_SHIFT] = "Shift",
	[Keyboard.KEY_RIGHT_CONTROL] = "Ctrl",
	[Keyboard.KEY_RIGHT_ALT] = "Alt",
	[Keyboard.KEY_RIGHT_SUPER] = "Super",
	--[Keyboard.KEY_MENU] = "Menu",
}

function mod:blankLetterTile(_, player, useFlags)
	local data = GetBltData(player)
	if not data then return end
	
	data.queued = data.queued + 1
	data.usedLastFrame = true
	
	sfx:Play(SoundEffect.SOUND_SHELLGAME)
	
	if player.ControllerIndex == 0 then
		game:GetHUD():ShowItemText("Choose a key!")
	else
		game:GetHUD():ShowItemText("Choose a button!")
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.blankLetterTile, mod.ITEM.CARD.BLANK_LETTER_TILE)

local function CheckButton(player, i)
	local data = GetBltData(player)
	
	if ButtonMap[i] and not data.buttons[i] and Input.IsButtonTriggered(i, player.ControllerIndex) then
		data.buttons[i] = true
		data.queued = data.queued - 1
		
		sfx:Play(SoundEffect.SOUND_SHELLGAME)
		local str
		if type(ButtonMap[i]) == "table" then
			str = ButtonMap[i].Name
		elseif i == Keyboard.KEY_SPACE then
			str = "Spacebar"
		else
			str = ButtonMap[i]
		end
		game:GetHUD():ShowItemText("You chose: " .. str)
	end
end

function mod:blankLetterTileUpdate(player)
	local data = GetBltData(player)
	if not data then return end
	
	-- Check for a new input.
	if not data.usedLastFrame and data.queued > 0 then
		if player.ControllerIndex == 0 then
			-- Check keyboard inputs.
			for _, i in pairs(Keyboard) do
				CheckButton(player, i)
				if data.queued <= 0 then break end
			end
		else
			-- Check controller inputs.
			for i=0, 31 do
				CheckButton(player, i)
				if data.queued <= 0 then break end
			end
		end
	end
	
	data.usedLastFrame = false
	
	-- Check if the current buttons are held down.
	local numHeld = 0
	local prevNumHeld = data.numHeld
	
	for button, _ in pairs(data.buttons) do
		if Input.IsButtonPressed(button, player.ControllerIndex) then
			numHeld = numHeld + 1
		end
	end
	
	data.numHeld = numHeld
	
	if numHeld ~= prevNumHeld then
		if kDamageBonus > 0 then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		end
		if kTearsBonus > 0 then
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		end
		player:EvaluateItems()
	end
end

-- Cache

function mod:blankLetterTileDamageCache(player)
	if kDamageBonus > 0 then
		local data = GetBltData(player)
		if not data then return end
		player.Damage = player.Damage + data.numHeld * kDamageBonus
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.blankLetterTileDamageCache, CacheFlag.CACHE_DAMAGE)

local function tearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

function mod:blankLetterTileTearsCache(player)
	if kTearsBonus > 0 then
		local data = GetBltData(player)
		if not data then return end
		player.MaxFireDelay = tearsUp(player.MaxFireDelay, data.numHeld * kTearsBonus)
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.blankLetterTileTearsCache, CacheFlag.CACHE_FIREDELAY)

-- Rendering

local tileSprite = Sprite()
tileSprite:Load("gfx/items/cards/blank_letter_tile.anm2", true)
tileSprite:Play("Idle", true)
tileSprite.Offset = Vector(0, 6)

local font = Font()
font:Load("font/terminus8.fnt")
local fontWhite = KColor(1,1,1,1,0,0,0)
local fontBlack = KColor(0,0,0,1,0,0,0)
local fontOffset = Vector(-2, -7)
local fontScale = Vector(1, 1)

function mod:blankLetterTileRender(player)
	local data = GetBltData(player)
	if not data then return end
	
	local startOffset = Vector(0, -60)
	local stepOffset = Vector(0, -20)
	
	local pos = Isaac.WorldToScreen(player.Position + startOffset)
	
	for button, _ in pairs(data.buttons) do
		if not (player.ControllerIndex > 0 and button >= 32) and Input.IsButtonPressed(button, player.ControllerIndex) then
			tileSprite:Render(pos)
			
			local str
			local scale = fontScale
			local offset = fontOffset
			
			if ButtonMap[button] then
				if type(ButtonMap[button]) == 'table' then
					local tab = ButtonMap[button]
					local sprite = tab.Sprite
					sprite:SetFrame(tab.Anim, tab.Frame)
					sprite:Render(
							pos + offset + (tab.Offset or kZeroVector),
							tab.TopLeftClamp or kZeroVector,
							tab.BottomRightClamp or kZeroVector)
				else
					str = ""..ButtonMap[button]
				end
			else
				str = ""..button
			end
			
			if str then
				font:DrawStringScaled(str, pos.X + offset.X, pos.Y + offset.Y, scale.X, scale.Y, fontWhite, 1, true)
			end
			
			pos = pos + stepOffset
		end
	end
end
