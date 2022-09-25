local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	if game.Challenge == mod.challenges.chinaShop then
		mod.scheduleForUpdate(function()
			if player and player:Exists() and player:GetPlayerType() ~= FiendFolio.PLAYER.CHINA then
				if (game:GetFrameCount() == 0) then
					Isaac.ExecuteCommand("restart " .. FiendFolio.PLAYER.CHINA)
				else
					player:ChangePlayerType(mod.PLAYER.CHINA)
					player:AddBombs(-1)
					--sorry xal
					local chinasHorns = Isaac.GetCostumeIdByPath("gfx/characters/china_horns.anm2")
					local chinaHead = Isaac.GetCostumeIdByPath("gfx/characters/china_head.anm2")
					player:AddNullCostume(chinaHead)
					player:AddNullCostume(chinasHorns)
				end
			end
		end, 0, ModCallbacks.MC_POST_RENDER, true)
	end
end, 0)