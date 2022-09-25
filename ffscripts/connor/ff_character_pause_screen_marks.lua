local mod = FiendFolio

include("ffscripts.connor.utilities.pause_screen_completion_marks_api")

PauseScreenCompletionMarksAPI:SetShader("StageAPI-RenderAboveHUD")

for _, playerType in pairs(mod.PLAYER) do
	PauseScreenCompletionMarksAPI:AddModCharacterCallback(playerType, function()
		return mod.GetCompletionNoteLayerDataFromPlayerType(playerType)
	end)
end
