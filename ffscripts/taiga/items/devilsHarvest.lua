-- The Devil's Harvest --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:animDevilsHarvestRespawn(player, data)
	if data.animateDevilsHarvest then
		player:AnimateCollectible(FiendFolio.ITEM.COLLECTIBLE.DEVILS_HARVEST)
		data.animateDevilsHarvest = nil
	end
end

function mod:handleDevilsHarvestRespawn(player, data)
	--The Devil's Harvest
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DEVILS_HARVEST) then
		local sprite = player:GetSprite()
		--[[if not data.revivingViaDevilsHarvest and
		   not player:GetEffects():HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		then
			player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, false)
		end]]--
		
		if player:IsDead() and sprite:IsFinished(sprite:GetAnimation()) then
			data.revivingViaDevilsHarvest = true
			data.animateDevilsHarvest = true
			player:RemoveCollectible(FiendFolio.ITEM.COLLECTIBLE.DEVILS_HARVEST)

			player:Revive()

			local level = game:GetLevel()
			local room = game:GetRoom()

			local enterDoorIndex = level.EnterDoor
			if enterDoorIndex == -1 or room:GetDoor(enterDoorIndex) == nil or level:GetCurrentRoomIndex() == level:GetPreviousRoomIndex() then
				game:StartRoomTransition(level:GetCurrentRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.ANKH)
			else
				local enterDoor = room:GetDoor(enterDoorIndex)
				local targetRoomIndex = enterDoor.TargetRoomIndex
				local targetRoomDirection = enterDoor.Direction

				level.LeaveDoor = -1 -- api why
				game:StartRoomTransition(targetRoomIndex, targetRoomDirection, RoomTransitionAnim.ANKH)
			end
		end
	end
end

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.POST_PLAYER_REVIVED, 0, function(player)
	local data = player:GetData()
	
	if data.revivingViaDevilsHarvest then
		--CustomHealthAPI.Library.ResetPlayerData(player)
		if player:GetPlayerType() == FiendFolio.PLAYER.BIEND then
			player:AddEternalHearts(-999)
			player:AddGoldenHearts(-999)
			player:AddBlackHearts(-999)
			player:AddBoneHearts(-999)
			player:AddMaxHearts(-999)
			player:AddSoulHearts(-999)

			player:AddBlackHearts(4)
		else
			player:ChangePlayerType(FiendFolio.PLAYER.FIEND)
			player:AddEternalHearts(-999)
			player:AddGoldenHearts(-999)
			player:AddBlackHearts(-999)
			player:AddBoneHearts(-999)
			player:AddMaxHearts(-999)
			player:AddSoulHearts(-999)

			player:AddBlackHearts(4)
			mod:AddImmoralHearts(player, 2)
		end
		player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/devils_harvest_revive.anm2"))
		data.revivingViaDevilsHarvest = nil
	end
end)
