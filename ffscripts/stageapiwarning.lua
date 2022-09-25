local mod = FiendFolio

local function CheckStageAPIModVersion(modname, checkVersion)
	local modInfo = FiendFolio.getField(StageAPI, 'LoadedMods', modname)
	if not modInfo then
		return false
	end

	local version = modInfo.Version
	-- assumes common version format
	local vnum = tonumber(version)
	local checknum = tonumber(checkVersion)
	return checknum <= vnum
end

FiendFolio.RequiredStageAPIVersion = '2.07'
FiendFolio.GoodStageAPI = StageAPI and StageAPI.Loaded and CheckStageAPIModVersion('StageAPI', FiendFolio.RequiredStageAPIVersion)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if not FiendFolio.GoodStageAPI then
		local version = FiendFolio.getField(StageAPI, 'LoadedMods', 'StageAPI', 'Version')
		local msg = version and 'found v' .. version or 'MISSING!'
		Isaac.RenderText("StageAPI minimum v"
						 .. FiendFolio.RequiredStageAPIVersion
						 .. " Required, " .. msg, 100, 78, 255, 255, 255, 1)
	end

	--[[ ModCompatHack is dead!!! :crab: :crab: :crab:
	if (not ModCompatCallbackHack) and (not mod.doneShowingModCompatWarning) then
		Isaac.RenderText("Mod Compatiblity Hack is missing or outdated", 100, 93, 255, 255, 0, 1)
	end]]
end)