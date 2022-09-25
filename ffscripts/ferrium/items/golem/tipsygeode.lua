local mod = FiendFolio
local game = Game()

local moveInputs = {
    [0] = ButtonAction.ACTION_RIGHT,
    [1] = ButtonAction.ACTION_UP,
	[2] = ButtonAction.ACTION_LEFT,
	[3] = ButtonAction.ACTION_DOWN,
}

function mod:isButtonMovementAligned(dir1, dir2)
	if (dir1 == ButtonAction.ACTION_RIGHT or dir1 == ButtonAction.ACTION_LEFT) then
		if (dir2 == ButtonAction.ACTION_RIGHT or dir2 == ButtonAction.ACTION_LEFT) then
			return true
		else
			return false
		end
	else
		if (dir2 == ButtonAction.ACTION_UP or dir2 == ButtonAction.ACTION_DOWN) then
			return true
		else
			return false
		end
	end
end

function mod:tipsyGeodeUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TIPSY_GEODE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TIPSY_GEODE)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TIPSY_GEODE)
		
		if not data.tipsyAngle then
			data.tipsyAngle = rng:RandomInt(360)
		end
		
		data.tipsyGeodeStrength = 0.3
		if mod.HasTwoGeodes(player) then
			data.tipsyGeodeStrength = 0.5
		end
		
		data.tipsyAngle = data.tipsyAngle+rng:RandomInt(30)-12
		
		if data.tipsyAngle < 0 then
			data.tipsyAngle = data.tipsyAngle+360
		end
		
		local dir = math.floor((data.tipsyAngle % 360)/90)
		data.tipsyGeodeDirection = moveInputs[dir]
	end
end

--[[mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if game:IsPaused() then return end

    for i = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
        local controllerIndex = player.ControllerIndex
		if player:HasTrinket(FiendFolio.ITEM.ROCK.TIPSY_GEODE) then
			local data = player:GetData()
			for _, buttonAction in pairs(moveInputs) do
				local isMoving = Input.IsActionTriggered(buttonAction, controllerIndex)
				if isMoving then
					data.lastMoveDirection = buttonAction
				end
			end
		end
    end
end)]]

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, ent, hook, action)
	if ent and ent:ToPlayer() then
		local player = ent:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.TIPSY_GEODE) then
			local data = player:GetData()
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TIPSY_GEODE)
			
			if not mod:isButtonMovementAligned(data.tipsyGeodeDirection, data.lastMoveDirection) then
				if action == data.tipsyGeodeDirection then
					return data.tipsyGeodeStrength
				end
			end
		end
	end
end)