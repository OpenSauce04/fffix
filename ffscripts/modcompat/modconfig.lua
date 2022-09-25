--THIS FILE IS UNUSED

function FiendFolio.DoModConfig()

if not ModConfigMenu then return end

--ModConfigMenu.AddText("Fiend Folio", "General", "Epic Fiend Folio")
--ModConfigMenu.AddText("Fiend Folio", "Fiend", "Epic Fiend")

ModConfigMenu.AddSetting("Fiend Folio", "General", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.replacementsEnabled
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.replacementsEnabled then
			onOff = "Enabled"
		end
		return "Replacements: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.replacementsEnabled = currentBool
	end,
	Info = {
		"This setting allows for enemy replacements to occur.",
		"For example, Warheads will occasionally replace red boom flies.",
		"Enabled by default"
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "General", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.legacyReplacementsEnabled
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.legacyReplacementsEnabled then
			onOff = "Enabled"
		end
		return "Legacy Replacements: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.legacyReplacementsEnabled = currentBool
	end,
	Info = {
		"Some default enemy replacements are disabled",
		"Set this to true to bring these replacements back",
		"Disabled by default",
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "General", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.ChangeAi
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.ChangeAi then
			onOff = "Enabled"
		end
		return "FF Ai Changes: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.ChangeAi = currentBool
	end,
	Info = {
		"this setting lets some vanilla",
		"enemies have altered ai",
		"enabled by default",
	}
})

--[[ModConfigMenu.AddSetting("Fiend Folio", "General", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.ColourBlindMode
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.ColourBlindMode then
			onOff = "Enabled"
		end
		return "Colour Blind Mode: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.ColourBlindMode = currentBool
	end,
	Info = {
		"Reskins green puzzle blocks to be",
		"a yellow with a higher brightness value",
		"Disabled by default",
	}
})]]

ModConfigMenu.AddSetting("Fiend Folio", "General", {
	Type = ModConfigMenuOptionType.NUMBER,
	CurrentSetting = function()
		return FiendFolio.NameTags
	end,
	Minimum = 0,
	Maximum = 2,
	Display = function()
      local modeStrings = {
			[0] = "Enabled",
			[1] = "N key",
			[2] = "Disabled",
		}
		return "Name tags: " .. modeStrings[FiendFolio.NameTags]
	end,
	OnChange = function(currentBool)
		FiendFolio.NameTags = currentBool
	end,
	Info = {
		"Gives a name tag to every FiendFolio enemy",
		"Disabled by default",
	}
})


ModConfigMenu.AddSpace("Fiend Folio", "General")

ModConfigMenu.AddSetting("Fiend Folio", "General", {
	Type = ModConfigMenuOptionType.NUMBER,
	CurrentSetting = function()
		return FiendFolio.ModeEnabled
	end,
	Minimum = 0,
	Maximum = 2,
	Display = function()
		local modeStrings = {
			[0] = "Disabled",
			[1] = "Mern",
			[2] = "Super Easy",
		}
		return "Special Mode: " .. modeStrings[FiendFolio.ModeEnabled]
	end,
	OnChange = function(currentNum)
		FiendFolio.ModeEnabled = currentNum
	end,
	Info = {
		"Mern Mode: We're not sure what this does",
		"Super Easy Mode: For people who can't stand difficulty",
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.ClassicTears
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.FiendConfig.ClassicTears then
			onOff = "Enabled"
		end
		return "Classic Tears: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.ClassicTears = currentBool
	end,
	Info = {
		"Fiend's tears become more faithful to The Devil's Harvest!",
		"(For optimal faith, also disable fireballs)",
		"Disabled by default"
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.DisableFiendFireball
	end,
	Display = function()
		local onOff = "Enabled"
		if FiendFolio.FiendConfig.DisableFiendFireball then
			onOff = "Disabled"
		end
		return "Chargable Fireball: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.DisableFiendFireball = currentBool
	end,
	Info = {
		"Allows the option of an extra chargeable attack!",
		"Disabled by default"
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.AlternateFireballSprite
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.FiendConfig.AlternateFireballSprite then
			onOff = "Enabled"
		end
		return "Alternate Fireball Sprite: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.AlternateFireballSprite = currentBool
	end,
	Info = {
		"Gives Fiend's fireball a rocky core",
		"Disabled by default"
	}
})

ModConfigMenu.AddSpace("Fiend Folio", "Fiend")

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.DisableUnlocks
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.FiendConfig.DisableUnlocks then
			onOff = "Enabled"
		end
		return "Skip Unlocks: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.DisableUnlocks = currentBool
	end,
	Info = {
		"Allows you to instantly unlock all of Fiend's items",
		"We do recommend you unlock them yourself though!",
		"Disabled by default"
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.DisableFiendItems
	end,
	Display = function()
		local onOff = "Enabled"
		if FiendFolio.FiendConfig.DisableFiendItems then
			onOff = "Disabled"
		end
		return "Fiend Themed Items: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.DisableFiendItems = currentBool
	end,
	Info = {
		"Set whether you want Fiend's",
		"unlockable items to appear",
		"Enabled by default"
	}
})

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.DisableAdditionalItems
	end,
	Display = function()
		local onOff = "Enabled"
		if FiendFolio.FiendConfig.DisableAdditionalItems then
			onOff = "Disabled"
		end
		return "Additional Items: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.DisableAdditionalItems = currentBool
	end,
	Info = {
		"Allows for other Fiend Folio items to appear",
		"Enabled by default"
	}
})

ModConfigMenu.AddSpace("Fiend Folio", "Fiend")

ModConfigMenu.AddSetting("Fiend Folio", "Fiend", {
	Type = ModConfigMenuOptionType.BOOLEAN,
	CurrentSetting = function()
		return FiendFolio.FiendConfig.ImpBabyMode
	end,
	Display = function()
		local onOff = "Disabled"
		if FiendFolio.FiendConfig.ImpBabyMode then
			onOff = "Enabled"
		end
		return "Imp Baby Mode: " .. onOff
	end,
	OnChange = function(currentBool)
		FiendFolio.FiendConfig.ImpBabyMode = currentBool
	end,
	Info = {
		"Do not play with this enabled",
		"Disabled by default"
	}
})

end

local didInitMenu = false
FiendFolio:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if didInitMenu then return end

    FiendFolio.DoModConfig()
    didInitMenu = true
end)
