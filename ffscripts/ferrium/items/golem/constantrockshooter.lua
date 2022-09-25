local mod = FiendFolio
local game = Game()

--[[local shootInputs = {
    ButtonAction.ACTION_SHOOTLEFT,
    ButtonAction.ACTION_SHOOTRIGHT,
    ButtonAction.ACTION_SHOOTUP,
    ButtonAction.ACTION_SHOOTDOWN
}

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if game:IsPaused() then return end

    for i = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
        local controllerIndex = player.ControllerIndex
		
		if player:HasTrinket(FiendFolio.ITEM.ROCK.CONSTANT_ROCK_SHOOTER) then
			for _, buttonAction in pairs(shootInputs) do
				local isFiring = Input.IsActionTriggered(buttonAction, controllerIndex)
				if isFiring then
					local data = player:GetData()
					data.LastFireDirection = buttonAction
				end
			end
		end
    end
end)]]

local blacklist = {CollectibleType.COLLECTIBLE_MOMS_KNIFE, CollectibleType.COLLECTIBLE_BRIMSTONE, CollectibleType.COLLECTIBLE_TECH_X, CollectibleType.COLLECTIBLE_CHOCOLATE_MILK, CollectibleType.COLLECTIBLE_KIDNEY_STONE, CollectibleType.COLLECTIBLE_CURSED_EYE}
local blacklist2 = {PlayerType.PLAYER_AZAZEL, PlayerType.PLAYER_THEFORGOTTEN, PlayerType.PLAYER_AZAZEL_B, PlayerType.PLAYER_THEFORGOTTEN_B, PlayerType.PLAYER_SAMSON_B}

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, ent, hook, action)
	if ent and ent:ToPlayer() then
		local player = ent:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.CONSTANT_ROCK_SHOOTER) then
			for i=1,#blacklist do
				if player:HasCollectible(blacklist[i]) then return end
			end
			for i=1,#blacklist2 do
				if player:GetPlayerType() == blacklist2[i] then return end
			end
			local data = player:GetData()
			if data.LastFireDirection then
				if action == data.LastFireDirection then
					return 1.0
				end
			elseif action == ButtonAction.ACTION_SHOOTDOWN then
				return 1.0
			end
		end
	end
end)