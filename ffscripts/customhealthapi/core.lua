-- sorry for the lack of documentation atm
-- this isn't version 1.0 for a reason

local version = 0.941
local root = "ffscripts.customhealthapi."
local modname = "Custom Health API (Fiend Folio)"
local modinitials = "FF"

CustomHealthAPI = CustomHealthAPI or {}

local shouldLoadMod
if CustomHealthAPI.Mod and CustomHealthAPI.Mod.Version then
	if CustomHealthAPI.Mod.ModName == modname then
		shouldLoadMod = true
	elseif CustomHealthAPI.Mod.Version < version then
		shouldLoadMod = true
	else
		shouldLoadMod = false
	end
else
	shouldLoadMod = true
end

local anm2TestSprite = Sprite()
anm2TestSprite:Load("gfx/ui/ui_hearts.anm2", true)
anm2TestSprite:Play("RedHeartFull", true)

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

if shouldLoadMod then
	if CustomHealthAPI.Mod then
		if CustomHealthAPI.ForceEndCallbacksToRemove then
			for callback, funcs in pairs(CustomHealthAPI.ForceEndCallbacksToRemove) do
				for subid, subfuncs in pairs(funcs) do
					if type(subfuncs) == "table" then
						for _, func in pairs(subfuncs) do
							func()
						end
					else
						subfuncs()
					end
				end
			end
		end
		
		if CustomHealthAPI.OtherCallbacksToRemove then
			for callback, funcs in pairs(CustomHealthAPI.OtherCallbacksToRemove) do
				for subid, subfuncs in pairs(funcs) do
					if type(subfuncs) == "table" then
						for _, func in pairs(subfuncs) do
							func()
						end
					else
						subfuncs()
					end
				end
			end
		end
	end

	CustomHealthAPI.Mod = RegisterMod(modname, 1)
	CustomHealthAPI.Mod.Version = version
	CustomHealthAPI.Mod.ModName = modname

	CustomHealthAPI.PersistentData = CustomHealthAPI.PersistentData or {}
	CustomHealthAPI.Helper = {}
	CustomHealthAPI.Library = {}
	CustomHealthAPI.Constants = {}
	CustomHealthAPI.Enums = {}

	CustomHealthAPI.Mod.AddedCallbacks = false
	
	CustomHealthAPI.PersistentData.OriginalAddCallback = CustomHealthAPI.PersistentData.OriginalAddCallback or Isaac.AddCallback
	CustomHealthAPI.ForceEndCallbacksToAdd = {}
	CustomHealthAPI.ForceEndCallbacksToRemove = {}
	CustomHealthAPI.OtherCallbacksToAdd = {}
	CustomHealthAPI.OtherCallbacksToRemove = {}
	
	function CustomHealthAPI.Helper.CallbackHandler(self, callbackId, fn, entityId)
		CustomHealthAPI.PersistentData.OriginalAddCallback(self, callbackId, fn, entityId)
		
		local funcsToRemove = CustomHealthAPI.ForceEndCallbacksToRemove[callbackId]
		if funcsToRemove ~= nil then
			for subid, subfuncs in pairs(funcsToRemove) do
				if type(subfuncs) == "table" then
					if entityId == -1 or entityId == nil or entityId == subid then
						for _, func in pairs(subfuncs) do
							func()
						end
					end
				else
					subfuncs()
				end
			end
		end
		
		local funcsToAdd = CustomHealthAPI.ForceEndCallbacksToAdd[callbackId]
		if funcsToAdd ~= nil then
			for subid, subfuncs in pairs(funcsToAdd) do
				if type(subfuncs) == "table" then
					if entityId == -1 or entityId == nil or entityId == subid then
						for _, func in pairs(subfuncs) do
							func()
						end
					end
				else
					subfuncs()
				end
			end
		end
	end
	Isaac.AddCallback = CustomHealthAPI.Helper.CallbackHandler

	include(root .. "definitions.enums")
	include(root .. "library.callbacks")

	include(root .. "definitions.constants")
	include(root .. "library.addhealth.core")
	include(root .. "library.addhealth.red")
	include(root .. "library.addhealth.soul")
	include(root .. "library.addhealth.container")
	include(root .. "library.addhealth.overlay")
	include(root .. "library.masks.initialize")
	include(root .. "library.masks.order")
	include(root .. "library.backups")
	include(root .. "library.canpickkey")
	include(root .. "library.gethp")
	include(root .. "library.register")
	include(root .. "library.misc")
	include(root .. "definitions.characters")
	include(root .. "definitions.health")
	include(root .. "reimpl.actives.genesis")
	include(root .. "reimpl.actives.glowinghourglass")
	include(root .. "reimpl.actives.hiddenplayers")
	include(root .. "reimpl.actives.misc")
	include(root .. "reimpl.cards.reversefool")
	include(root .. "reimpl.cards.reversesun")
	include(root .. "reimpl.cards.strength")
	include(root .. "reimpl.cards.misc")
	include(root .. "reimpl.itempedestals.abaddon")
	include(root .. "reimpl.itempedestals.brittlebones")
	include(root .. "reimpl.itempedestals.core")
	include(root .. "reimpl.pills.hematemesis")
	include(root .. "reimpl.pills.misc")
	include(root .. "reimpl.apioverrides")
	include(root .. "reimpl.damage")
	include(root .. "reimpl.pickups")
	include(root .. "reimpl.renderhealthbar")
	include(root .. "reimpl.restock")
	include(root .. "reimpl.resyncing")
	include(root .. "reimpl.shardofglass")
	include(root .. "reimpl.subplayers")
	include(root .. "reimpl.sumptorium")
	include(root .. "reimpl.whoreofbabylon")
	include(root .. "misc")
	include(root .. "savingandloading")
	
	function CustomHealthAPI.Helper.CheckBadLoad()
		anm2TestSprite:SetFrame("RedHeartFull", 0)
		anm2TestSprite:SetLastFrame()
		return anm2TestSprite:GetFrame() ~= 3
	end
	
	function CustomHealthAPI.Helper.AddTestBadLoadCallback()
		CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_POST_RENDER, CustomHealthAPI.Mod.TestBadLoadCallback, -1)
	end
	CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_POST_RENDER] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_POST_RENDER] or {}
	table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_POST_RENDER], CustomHealthAPI.Helper.AddTestBadLoadCallback)

	function CustomHealthAPI.Helper.RemoveTestBadLoadCallback()
		CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, CustomHealthAPI.Mod.TestBadLoadCallback)
	end
	CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_POST_RENDER] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_POST_RENDER] or {}
	table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_POST_RENDER], CustomHealthAPI.Helper.RemoveTestBadLoadCallback)

	function CustomHealthAPI.Mod:TestBadLoadCallback()
		if CustomHealthAPI.Helper.CheckBadLoad() then
			local fontColor = KColor(1,0.5,0.5,1)
			
			if modinitials ~= nil then
				font:DrawString("[" .. modinitials .. "] Custom Health API animation files failed to load.",70,100,fontColor,0,false)
			else
				font:DrawString("Custom Health API animation files failed to load.",70,100,fontColor,0,false)
			end
			font:DrawString("Restart your game!",70,110,fontColor,0,false)
			
			font:DrawString("(This tends to happen when the mod is first installed, or when",70,120,fontColor,0,false)
			font:DrawString("it is re-enabled via the mod menu.)",70,130,fontColor,0,false)
			font:DrawString("If the issue persists, you may be experiencing a download failure",70,140,fontColor,0,false)
			font:DrawString("or mod incompatibility.",70,150,fontColor,0,false)
			
			font:DrawString("You will also need to restart the game after disabling the mod.",70,160,fontColor,0,false)
		end
	end

	for callback, funcs in pairs(CustomHealthAPI.OtherCallbacksToAdd) do
		for subid, subfuncs in pairs(funcs) do
			if type(subfuncs) == "table" then
				for _, func in pairs(subfuncs) do
					func()
				end
			else
				subfuncs()
			end
		end
	end
	
	for callback, funcs in pairs(CustomHealthAPI.ForceEndCallbacksToAdd) do
		for subid, subfuncs in pairs(funcs) do
			if type(subfuncs) == "table" then
				for _, func in pairs(subfuncs) do
					func()
				end
			else
				subfuncs()
			end
		end
	end
	
	if not CustomHealthAPI.PersistentData.ShownDisclaimer then
		print("Custom Health API: v" .. version .. " Loaded")
		print("DISCLAIMER: Custom Health API causes \"debug 3\" to no longer function. The command \"chapi nodmg\" has been provided as a replacement.")
		CustomHealthAPI.PersistentData.ShownDisclaimer = true
	end
end
