local isEvaluateCacheFunction = 0

function CustomHealthAPI.Helper.AddPreEvaluateCacheCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_EVALUATE_CACHE, CustomHealthAPI.Mod.PreEvaluateCacheCallback, -1) 
end
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE] or {}
table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE], CustomHealthAPI.Helper.AddPreEvaluateCacheCallback)

function CustomHealthAPI.Helper.RemovePreEvaluateCacheCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, CustomHealthAPI.Mod.PreEvaluateCacheCallback) 
end
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE] or {}
table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE], CustomHealthAPI.Helper.RemovePreEvaluateCacheCallback)

function CustomHealthAPI.Mod:PreEvaluateCacheCallback()
	isEvaluateCacheFunction = isEvaluateCacheFunction + 1
end

function CustomHealthAPI.Helper.AddPostEvaluateCacheCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_EVALUATE_CACHE, CustomHealthAPI.Mod.PostEvaluateCacheCallback, -1)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_EVALUATE_CACHE], CustomHealthAPI.Helper.AddPostEvaluateCacheCallback)

function CustomHealthAPI.Helper.RemovePostEvaluateCacheCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, CustomHealthAPI.Mod.PostEvaluateCacheCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_EVALUATE_CACHE], CustomHealthAPI.Helper.RemovePostEvaluateCacheCallback)

function CustomHealthAPI.Mod:PostEvaluateCacheCallback()
	isEvaluateCacheFunction = isEvaluateCacheFunction - 1
end

function CustomHealthAPI.Helper.AddResetEvaluateCacheCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_POST_UPDATE, CustomHealthAPI.Mod.ResetEvaluateCacheCallback, -1)
end
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_POST_UPDATE] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_POST_UPDATE] or {}
table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_POST_UPDATE], CustomHealthAPI.Helper.AddResetEvaluateCacheCallback)

function CustomHealthAPI.Helper.RemoveResetEvaluateCacheCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, CustomHealthAPI.Mod.ResetEvaluateCacheCallback)
end
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_POST_UPDATE] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_POST_UPDATE] or {}
table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_POST_UPDATE], CustomHealthAPI.Helper.RemoveResetEvaluateCacheCallback)

function CustomHealthAPI.Mod:ResetEvaluateCacheCallback()
	if isEvaluateCacheFunction ~= 0 then
		print("Custom Health API ERROR: Evaluate Items callback detection failed with value " .. isEvaluateCacheFunction .. ".")
		isEvaluateCacheFunction = 0
	end
end

if not CustomHealthAPI.PersistentData.OverriddenFunctions then
	CustomHealthAPI.PersistentData.OverriddenFunctions = {}

	local META, META0
	local function BeginClass(T)
		META = {}
		if type(T) == "function" then
			META0 = getmetatable(T())
		else
			META0 = getmetatable(T).__class
		end
	end

	local function EndClass()
		local oldIndex = META0.__index
		local newMeta = META
		
		rawset(META0, "__index", function(self, k)
			return newMeta[k] or oldIndex(self, k)
		end)
	end

	BeginClass(EntityPlayer)
	
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddBlackHearts = META0.AddBlackHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddBoneHearts = META0.AddBoneHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddBrokenHearts = META0.AddBrokenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddCollectible = META0.AddCollectible
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddEternalHearts = META0.AddEternalHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddGoldenHearts = META0.AddGoldenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts = META0.AddHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddMaxHearts = META0.AddMaxHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddRottenHearts = META0.AddRottenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddSoulHearts = META0.AddSoulHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickBlackHearts = META0.CanPickBlackHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickBoneHearts = META0.CanPickBoneHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickGoldenHearts = META0.CanPickGoldenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickRedHearts = META0.CanPickRedHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickRottenHearts = META0.CanPickRottenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickSoulHearts = META0.CanPickSoulHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.EvaluateItems = META0.EvaluateItems
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetBlackHearts = META0.GetBlackHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetBoneHearts = META0.GetBoneHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetBrokenHearts = META0.GetBrokenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetEffectiveMaxHearts = META0.GetEffectiveMaxHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetEternalHearts = META0.GetEternalHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetGoldenHearts = META0.GetGoldenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetHeartLimit = META0.GetHeartLimit
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts = META0.GetHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetMaxHearts = META0.GetMaxHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetRottenHearts = META0.GetRottenHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.GetSoulHearts = META0.GetSoulHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.HasFullHearts = META0.HasFullHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.HasFullHeartsAndSoulHearts = META0.HasFullHeartsAndSoulHearts
	CustomHealthAPI.PersistentData.OverriddenFunctions.IsBlackHeart = META0.IsBlackHeart
	CustomHealthAPI.PersistentData.OverriddenFunctions.IsBoneHeart = META0.IsBoneHeart
	CustomHealthAPI.PersistentData.OverriddenFunctions.RemoveBlackHeart = META0.RemoveBlackHeart
	CustomHealthAPI.PersistentData.OverriddenFunctions.SetFullHearts = META0.SetFullHearts

	function META:AddBlackHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddBlackHearts(self, hp)
	end

	function META:AddBoneHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddBoneHearts(self, hp)
	end

	function META:AddBrokenHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddBrokenHearts(self, hp)
	end

	function META:AddCollectible(item, charge, firstTimePickingUp, slot, varData)
		CustomHealthAPI.Helper.HookFunctions.AddCollectible(self, item, charge, firstTimePickingUp, slot, varData)
	end

	function META:AddEternalHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddEternalHearts(self, hp)
	end

	function META:AddGoldenHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddGoldenHearts(self, hp)
	end

	function META:AddHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddHearts(self, hp)
	end

	function META:AddMaxHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddMaxHearts(self, hp)
	end

	function META:AddRottenHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddRottenHearts(self, hp)
	end

	function META:AddSoulHearts(hp)
		CustomHealthAPI.Helper.HookFunctions.AddSoulHearts(self, hp)
	end

	function META:CanPickBlackHearts()
		return CustomHealthAPI.Helper.HookFunctions.CanPickBlackHearts(self)
	end

	function META:CanPickBoneHearts()
		return CustomHealthAPI.Helper.HookFunctions.CanPickBoneHearts(self)
	end

	function META:CanPickGoldenHearts()
		return CustomHealthAPI.Helper.HookFunctions.CanPickGoldenHearts(self)
	end

	function META:CanPickRedHearts()
		return CustomHealthAPI.Helper.HookFunctions.CanPickRedHearts(self)
	end

	function META:CanPickRottenHearts()
		return CustomHealthAPI.Helper.HookFunctions.CanPickRottenHearts(self)
	end

	function META:CanPickSoulHearts()
		return CustomHealthAPI.Helper.HookFunctions.CanPickSoulHearts(self)
	end

	function META:EvaluateItems()
		return CustomHealthAPI.Helper.HookFunctions.EvaluateItems(self)
	end

	function META:GetBlackHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetBlackHearts(self)
	end

	function META:GetBoneHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetBoneHearts(self)
	end

	function META:GetBrokenHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetBrokenHearts(self)
	end

	function META:GetEffectiveMaxHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetEffectiveMaxHearts(self)
	end

	function META:GetEternalHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetEternalHearts(self)
	end

	function META:GetGoldenHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetGoldenHearts(self)
	end

	function META:GetHeartLimit()
		return CustomHealthAPI.Helper.HookFunctions.GetHeartLimit(self)
	end

	function META:GetHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetHearts(self)
	end

	function META:GetMaxHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetMaxHearts(self)
	end

	function META:GetRottenHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetRottenHearts(self)
	end

	function META:GetSoulHearts()
		return CustomHealthAPI.Helper.HookFunctions.GetSoulHearts(self)
	end

	function META:HasFullHearts()
		return CustomHealthAPI.Helper.HookFunctions.HasFullHearts(self)
	end

	function META:HasFullHeartsAndSoulHearts()
		return CustomHealthAPI.Helper.HookFunctions.HasFullHeartsAndSoulHearts(self)
	end

	function META:IsBlackHeart(heart)
		return CustomHealthAPI.Helper.HookFunctions.IsBlackHeart(self, heart)
	end

	function META:IsBoneHeart(heart)
		return CustomHealthAPI.Helper.HookFunctions.IsBoneHeart(self, heart)
	end

	function META:RemoveBlackHeart(heart)
		CustomHealthAPI.Helper.HookFunctions.RemoveBlackHeart(self, heart)
	end

	function META:SetFullHearts()
		CustomHealthAPI.Helper.HookFunctions.SetFullHearts(self)
	end

	EndClass()
end

CustomHealthAPI.Helper.HookFunctions = {}
	
CustomHealthAPI.Helper.HookFunctions.AddBlackHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddBlackHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "BLACK_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddBlackHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddBoneHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddBoneHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "BONE_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddBoneHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddBrokenHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddBrokenHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "BROKEN_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddBrokenHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddCollectible = function(player, item, charge, firstTimePickingUp, slot, varData)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddCollectible(player:GetOtherTwin(), item, charge, firstTimePickingUp, slot, varData)
		end
	end
	
	if CustomHealthAPI then
		if not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
			CustomHealthAPI.Helper.CheckIfHealthOrderSet()
			CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
			CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
	end
	
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddCollectible(player, 
	                                                                  item, 
	                                                                  charge or 0, 
	                                                                  firstTimePickingUp or firstTimePickingUp == nil, 
	                                                                  slot or ActiveSlot.SLOT_PRIMARY, 
	                                                                  varData or 0)
	
	if CustomHealthAPI then
		if not CustomHealthAPI.Helper.PlayerIsIgnored(player) and firstTimePickingUp then
			CustomHealthAPI.Helper.HandleCollectibleHP(player, item)
		end
	end
end

CustomHealthAPI.Helper.HookFunctions.AddEternalHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddEternalHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "ETERNAL_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddEternalHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddGoldenHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddGoldenHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "GOLDEN_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddGoldenHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "RED_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddMaxHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddMaxHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "EMPTY_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddMaxHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddRottenHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddRottenHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "ROTTEN_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddRottenHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.AddSoulHearts = function(player, hp)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.AddSoulHearts(player:GetOtherTwin(), hp)
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", hp)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddSoulHearts(player, hp)
	end
end

CustomHealthAPI.Helper.HookFunctions.CanPickBlackHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.CanPickBlackHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI then
		return CustomHealthAPI.Library.CanPickKey(player, "BLACK_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickBlackHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.CanPickBoneHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.CanPickBoneHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI then
		return CustomHealthAPI.Library.CanPickKey(player, "BONE_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickBoneHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.CanPickGoldenHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.CanPickGoldenHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI then
		return CustomHealthAPI.Library.CanPickKey(player, "GOLDEN_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickGoldenHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.CanPickRedHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.CanPickRedHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI then
		return CustomHealthAPI.Library.CanPickKey(player, "RED_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickRedHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.CanPickRottenHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.CanPickRottenHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI then
		return CustomHealthAPI.Library.CanPickKey(player, "ROTTEN_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickRottenHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.CanPickSoulHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.CanPickSoulHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI then
		return CustomHealthAPI.Library.CanPickKey(player, "SOUL_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.CanPickSoulHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.EvaluateItems = function(player)
	if not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
	end
	
	isEvaluateCacheFunction = isEvaluateCacheFunction + 1
	CustomHealthAPI.PersistentData.OverriddenFunctions.EvaluateItems(player)
	isEvaluateCacheFunction = isEvaluateCacheFunction - 1
end

CustomHealthAPI.Helper.HookFunctions.GetBlackHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetBlackHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		
		local data = player:GetData().CustomHealthAPISavedata
		local otherMasks = data.OtherHealthMasks
		
		local blackHearts = 0
		for i = #otherMasks, 1, -1 do
			local mask = otherMasks[i]
			for j = #mask, 1, -1 do
				local health = mask[j]
				if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
					blackHearts = blackHearts << 1
					
					local key = health.Key
					if key == "BLACK_HEART" then
						blackHearts = blackHearts + 1
					end
				end
			end
		end
		
		return blackHearts
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetBlackHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetBoneHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetBoneHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalBoneHP(player, basegameFormat)
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetBoneHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetBrokenHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetBrokenHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalKeys(player, "BROKEN_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetBrokenHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetEffectiveMaxHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetEffectiveMaxHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetRedCapacity(player)
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetEffectiveMaxHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetEternalHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetEternalHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		
		local data = player:GetData().CustomHealthAPISavedata
		if data ~= nil then
			return data.Overlays["ETERNAL_HEART"] or 0
		else
			return CustomHealthAPI.PersistentData.OverriddenFunctions.GetEternalHearts(player)
		end
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetEternalHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetGoldenHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetGoldenHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		
		local data = player:GetData().CustomHealthAPISavedata
		if data ~= nil then
			return data.Overlays["GOLDEN_HEART"] or 0
		else
			return CustomHealthAPI.PersistentData.OverriddenFunctions.GetEternalHearts(player)
		end
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetGoldenHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetHeartLimit = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetHeartLimit(player:GetOtherTwin())
		end
	end
	
	return CustomHealthAPI.PersistentData.OverriddenFunctions.GetHeartLimit(player)
end

CustomHealthAPI.Helper.HookFunctions.GetHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalRedHP(player, false, true)
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetMaxHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetMaxHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalMaxHP(player)
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetMaxHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetRottenHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetRottenHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalKeys(player, "ROTTEN_HEART")
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetRottenHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.GetSoulHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.GetSoulHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalSoulHP(player, false, true)
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.GetSoulHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.HasFullHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.HasFullHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetRedCapacity(player) - CustomHealthAPI.Helper.GetTotalRedHP(player, true) <= 0
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.HasFullHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.HasFullHeartsAndSoulHearts = function(player)
	-- so this checks if red hp + soul hp > max hp (ignoring bone)
	-- ...what is the point of this?
	-- does anyone actually use this function?
	-- this isn't what i thought it would do at all
	-- i thought it would check if your red hp + soul hp fills the entire hp bar
	-- that would actually be useful
	-- and why does it ignore bone heart red capacity?
	-- hasfullhearts doesn't do that
	-- florian why
	-- nicalis why
	-- spider why
	-- kilburn why
	-- who do i blame for this
	-- why does this exist
	-- okay so apparently this is the check for regular challenge room doors???
	-- why is it not just called checkifchallengedoorshouldopen or something
	-- the current name is just confusing
	-- goddamnit
	
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.HasFullHeartsAndSoulHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		return CustomHealthAPI.Helper.GetTotalMaxHP(player) - (CustomHealthAPI.Helper.GetTotalRedHP(player, true) + CustomHealthAPI.Helper.GetTotalSoulHP(player, true)) <= 0
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.HasFullHeartsAndSoulHearts(player)
	end
end

CustomHealthAPI.Helper.HookFunctions.IsBlackHeart = function(player, heart)
	--...why does this skip over the even numbers
	--it's not even a half heart thing
	--it just flat out skips the even numbers and returns false for them
	--wtf
	
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.IsBlackHeart(player:GetOtherTwin(), heart)
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		CustomHealthAPI.Helper.CheckIfHealthOrderSet()
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		if isEvaluateCacheFunction <= 0 then
			CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		end
		
		if heart % 2 == 0 or heart < 0 then
			return false
		end
		
		local data = player:GetData().CustomHealthAPISavedata
		local otherMasks = data.OtherHealthMasks
		
		local soulHeartsToProcess = math.floor(heart / 2) + 1
		for i = 1, #otherMasks do
			local mask = otherMasks[i]
			for j = 1, #mask do
				local health = mask[j]
				if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
					soulHeartsToProcess = soulHeartsToProcess - 1
					
					local key = health.Key
					if soulHeartsToProcess == 0 then
						if key == "BLACK_HEART" then
							return true
						else
							return false
						end
					end
				end
			end
		end
		
		return false
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.IsBlackHeart(player, heart)
	end
end

CustomHealthAPI.Helper.HookFunctions.IsBoneHeart = function(player, heart)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.IsBoneHeart(player:GetOtherTwin(), heart)
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		if heart < 0 then
			return false
		end
		
		local data = player:GetData().CustomHealthAPISavedata
		local otherMasks = data.OtherHealthMasks
		
		local heartsToProcess = heart + 1
		for i = 1, #otherMasks do
			local mask = otherMasks[i]
			for j = 1, #mask do
				local health = mask[j]
				if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
					heartsToProcess = heartsToProcess - 1
					
					local key = health.Key
					if heartsToProcess == 0 then
						return false
					end
				elseif CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.CONTAINER and
				       CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].KindContained ~= CustomHealthAPI.Enums.HealthKinds.NONE and 
				       CustomHealthAPI.Library.GetInfoOfHealth(health, "MaxHP") > 0
				then
					heartsToProcess = heartsToProcess - 1
					
					local key = health.Key
					if heartsToProcess == 0 then
						return true
					end
				end
			end
		end
		
		return false
	else
		return CustomHealthAPI.PersistentData.OverriddenFunctions.IsBoneHeart(player, heart)
	end
end

CustomHealthAPI.Helper.HookFunctions.RemoveBlackHeart = function(player, heart)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.RemoveBlackHeart(player:GetOtherTwin(), heart)
		end
	end
	
	if CustomHealthAPI and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		if heart < 0 then
			return
		end
		
		local data = player:GetData().CustomHealthAPISavedata
		local otherMasks = data.OtherHealthMasks
		
		local soulHeartsToProcess = math.floor(heart / 2) + 1
		for i = 1, #otherMasks do
			local mask = otherMasks[i]
			for j = 1, #mask do
				local health = mask[j]
				if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
					soulHeartsToProcess = soulHeartsToProcess - 1
					
					local key = health.Key
					if soulHeartsToProcess == 0 then
						if key == "BLACK_HEART" then
							health.Key = "SOUL_HEART"
							CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
							return
						end
					end
				end
			end
		end
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.RemoveBlackHeart(player, heart)
	end
end

CustomHealthAPI.Helper.HookFunctions.SetFullHearts = function(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.HookFunctions.SetFullHearts(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI.Library.AddHealth then
		CustomHealthAPI.Library.AddHealth(player, "RED_HEART", 99, true, true)
	else
		CustomHealthAPI.PersistentData.OverriddenFunctions.SetFullHearts(player)
	end
end
