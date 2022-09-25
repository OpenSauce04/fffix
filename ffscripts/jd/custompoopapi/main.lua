local savedata = FiendFolio.savedata
local version = 1
local modname = "FF"

local shouldLoadMod
if CustomPoopAPI and CustomPoopAPI.Version then
	if CustomPoopAPI.ModName == modname then
		shouldLoadMod = true
	elseif CustomPoopAPI.Version < version then
		shouldLoadMod = true
	else
		shouldLoadMod = false
	end
else
	shouldLoadMod = true
end

if shouldLoadMod then
	CustomPoopAPI = RegisterMod("CustomPoopAPI", 1)
	CustomPoopAPI.Version = version
	CustomPoopAPI.ModName = modname
	savedata.CustomPoopAPI = savedata.CustomPoopAPI or {}
	CustomPoopAPI.savedata = savedata.CustomPoopAPI
	include("ffscripts.jd.custompoopapi.taintedbb")
	include("ffscripts.jd.custompoopapi.hold")
end