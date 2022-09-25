-- Wrong Warp --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local normalStages = {
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_REPENTANCE_B, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_3, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_3, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_3, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_3, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE5, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE5, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE5, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE5, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = true},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = true},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = true},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = true},
	{LevelStage = LevelStage.STAGE3_1, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = true},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = true},
	{LevelStage = LevelStage.STAGE1_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = true},
	{LevelStage = LevelStage.STAGE1_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = true},
	{LevelStage = LevelStage.STAGE2_1, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = true},
	{LevelStage = LevelStage.STAGE2_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = true},
	{LevelStage = LevelStage.STAGE3_2, StageType = StageType.STAGETYPE_REPENTANCE, IsAscent = true},
	{LevelStage = LevelStage.STAGE8, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE8, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE8, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE8, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
}

local greedStages = {
	{LevelStage = LevelStage.STAGE1_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_GREED, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE1_GREED, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_GREED, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE2_GREED, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_GREED, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE3_GREED, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_GREED, StageType = StageType.STAGETYPE_WOTL, IsAscent = false},
	{LevelStage = LevelStage.STAGE4_GREED, StageType = StageType.STAGETYPE_AFTERBIRTH, IsAscent = false},
	{LevelStage = LevelStage.STAGE5_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE5_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE5_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE6_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false},
	{LevelStage = LevelStage.STAGE7_GREED, StageType = StageType.STAGETYPE_ORIGINAL, IsAscent = false}
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, useflags, activeslot, customvardata)
	local level = game:GetLevel()
	local levelstage = level:GetStage()
	local stagetype = level:GetStageType()
	local isAscent = game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH)
	
	local newlevel
	if game:IsGreedMode() then
		repeat
			newlevel = greedStages[rng:RandomInt(#greedStages) + 1]
		until (newlevel.LevelStage ~= levelstage or newlevel.StageType ~= stagetype)
	else
		repeat
			newlevel = normalStages[rng:RandomInt(#normalStages) + 1]
		until (newlevel.LevelStage ~= levelstage or newlevel.StageType ~= stagetype or newlevel.IsAscent ~= isAscent)
	end
	
	player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW)
	level:SetStage(newlevel.LevelStage, newlevel.StageType)
	game:SetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH, newlevel.IsAscent)
	
	game:SetStateFlag(GameStateFlag.STATE_HEAVEN_PATH, false)
	game:SetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT, false)
	game:SetStateFlag(GameStateFlag.STATE_MAUSOLEUM_HEART_KILLED, false)

	return {Remove = true, ShowAnim = useflags ~= useflags | UseFlag.USE_NOANIM}
end, FiendFolio.ITEM.COLLECTIBLE.WRONG_WARP)