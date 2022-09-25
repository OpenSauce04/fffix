-- Fiend Mix --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.FiendMixMinions = {
	["RED_HEART"] = {{ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 7, Dataflags = {{"hollowanim", true}}},
	                 {ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 6, Dataflags = {}}},
	["ROTTEN_HEART"] = {{ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 8, Dataflags = {{"hollowanim", true}}}},
	["SOUL_HEART"] = {{ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 10, Dataflags = {{"hollowanim", true}}},
	                  {ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 9, Dataflags = {}}},
	["BLACK_HEART"] = {{ID = 1000, Var = EffectVariant.PICKUP_FIEND_MINION, Sub = 1, Dataflags = {{"hollow", true}, {"canreroll", false}, {"fiendBonus", true}}},
	                   {ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 1, Dataflags = {{"fiendBonus", true}}}},
	["IMMORAL_HEART"] = {{ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 3, Dataflags = {{"hollowanim", true}}},
	                     {ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 2, Dataflags = {}}},
	["ETERNAL_HEART"] = {{ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 4, Dataflags = {{"hollowanim", true}}}},
	["GOLDEN_HEART"] = {{ID = 5, Var = FiendFolio.PICKUP.VARIANT.FIEND_MINION, Sub = 5, Dataflags = {}}},
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, p, useflags, activeslot, customvardata)
	local player = p
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			player = player:GetOtherTwin()
		end
	end
	
	if CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		return
	end
	
	local heartsRemoved = {}

	heartsRemoved["ETERNAL_HEART"] = player:GetEternalHearts()
	heartsRemoved["GOLDEN_HEART"] = player:GetGoldenHearts()

	player:AddEternalHearts(-1 * heartsRemoved["ETERNAL_HEART"])
	player:AddGoldenHearts(-1 * heartsRemoved["GOLDEN_HEART"])
	
	local redHeartsToRemove = math.floor(player:GetHearts() / 2)
	if redHeartsToRemove == 0 and player:GetHearts() > 0 and player:GetBoneHearts() > 0 then
		redHeartsToRemove = player:GetHearts()
	end
	
	local soulHeartsToRemove = math.floor(player:GetSoulHearts() / 2)
	if soulHeartsToRemove == 0 and player:GetSoulHearts() > 0 and player:GetHearts() + player:GetBoneHearts() > 0 then
		soulHeartsToRemove = player:GetSoulHearts()
	end
	
	local hearts = CustomHealthAPI.Library.GetHealthInOrder(player)
	
	for i = #hearts, 1, -1 do
		local health = hearts[i]
		if health.Red ~= nil then
			local key = health.Red.Key
			local maxHPOfKey = CustomHealthAPI.Library.GetInfoOfKey(key, "MaxHP")
			
			if maxHPOfKey <= 1 then
				if redHeartsToRemove < 2 and player:GetHearts() - 2 == 0 and player:GetBoneHearts() == 0 then
					break
				else
					heartsRemoved[key] = (heartsRemoved[key] or 0) + 1
					redHeartsToRemove = redHeartsToRemove - 2
					CustomHealthAPI.Library.RemoveRedKey(player, i)
				end
			else
				if redHeartsToRemove >= health.Red.HP then
					heartsRemoved[key] = (heartsRemoved[key] or 0) + health.Red.HP
					redHeartsToRemove = redHeartsToRemove - health.Red.HP
					CustomHealthAPI.Library.RemoveRedKey(player, i)
				else
					heartsRemoved[key] = (heartsRemoved[key] or 0) + redHeartsToRemove
					health.Red.HP = health.Red.HP - redHeartsToRemove
					redHeartsToRemove = 0
					CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
				end
			end
		end
		
		if redHeartsToRemove <= 0 then
			break
		end
	end
	
	for i = #hearts, 1, -1 do
		local health = hearts[i]
		local key = health.Other.Key
		local typeOfKey = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
		
		if typeOfKey == CustomHealthAPI.Enums.HealthTypes.SOUL then
			local maxHPOfKey = CustomHealthAPI.Library.GetInfoOfKey(key, "MaxHP")
			
			if maxHPOfKey <= 1 then
				if soulHeartsToRemove < 2 and player:GetSoulHearts() - 2 == 0 and player:GetHearts() + player:GetBoneHearts() == 0  then
					break
				else
					heartsRemoved[key] = (heartsRemoved[key] or 0) + 1
					soulHeartsToRemove = soulHeartsToRemove - 2
					CustomHealthAPI.Library.RemoveOtherKey(player, i)
				end
			else
				if soulHeartsToRemove >= health.Other.HP then
					heartsRemoved[key] = (heartsRemoved[key] or 0) + health.Other.HP
					soulHeartsToRemove = soulHeartsToRemove - health.Other.HP
					CustomHealthAPI.Library.RemoveOtherKey(player, i)
				else
					heartsRemoved[key] = (heartsRemoved[key] or 0) + soulHeartsToRemove
					health.Other.HP = health.Other.HP - soulHeartsToRemove
					soulHeartsToRemove = 0
					CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
				end
			end
		end
		
		if soulHeartsToRemove <= 0 then
			break
		end
	end

	local eggs = {}
	
	for k, amount in pairs(heartsRemoved) do
		local key = k
		if not FiendFolio.FiendMixMinions[key] then
			local typeOfKey = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
			if typeOfKey == CustomHealthAPI.Enums.HealthTypes.RED then
				key = "RED_HEART"
			elseif typeOfKey == CustomHealthAPI.Enums.HealthTypes.SOUL then
				key = "SOUL_HEART"
			else
				key = "GOLDEN_HEART"
			end
		end
		
		local amountToRemove = amount
		while amountToRemove > 0 do
			local hasSpawned = false
			for i = amountToRemove, 1, -1 do
				if FiendFolio.FiendMixMinions[key][i] ~= nil then
					local config = FiendFolio.FiendMixMinions[key][i]
					
					local egg = Isaac.Spawn(config.ID, 
					                        config.Var, 
					                        config.Sub, 
					                        player.Position, 
					                        Vector(math.random(-5, 5), 
					                        math.random(-5, 5)), 
					                        player)
					table.insert(eggs, egg)
					for _, dataflag in ipairs(config.Dataflags) do
						egg:GetData()[dataflag[1]] = dataflag[2]
					end
					
					amountToRemove = amountToRemove - i
					hasSpawned = true
					break
				end
			end
			
			if not hasSpawned then break end
		end
	end

	local isActiveRoom = mod.IsActiveRoom()
	for _,egg in ipairs(eggs) do
		egg:GetSprite():Play("Drop", true)
		if math.random(2) == 1 then
			egg:GetSprite().FlipX = true
		end

		if not isActiveRoom then
			egg:GetData().mixPersistent = true
			egg:GetData().mixRemainingRooms = 1
			egg:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end

		egg.Parent = player
		egg:Update()
	end
	
	local hasVirtues = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
	if hasVirtues then
		for i = 1, #eggs do
			player:AddWisp(FiendFolio.ITEM.COLLECTIBLE.FIEND_MIX, player.Position)
		end
		if #eggs > 0 then
			sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
		end
	end

	return useflags ~= useflags | UseFlag.USE_NOANIM
end, FiendFolio.ITEM.COLLECTIBLE.FIEND_MIX)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, FiendFolio.ITEM.COLLECTIBLE.FIEND_MIX)) do
		wisp:GetData().NoSpawn = true
		wisp:Kill()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, e)
	if e.Variant == FamiliarVariant.WISP and e.SubType == FiendFolio.ITEM.COLLECTIBLE.FIEND_MIX then
		local player = e:ToFamiliar().Player
		if player and not e:GetData().NoSpawn then
			local egg = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, e.Position, nilvector, player)
			egg:GetData().canreroll = false
			egg.EntityCollisionClass = 4
			egg.Parent = player
			egg:GetData().hollow = true
			
			egg:GetSprite():Play("Drop", true)
			if math.random(2) == 1 then
				egg:GetSprite().FlipX = true
			end

			local isActiveRoom = mod.IsActiveRoom()
			if not isActiveRoom then
				egg:GetData().mixPersistent = true
				egg:GetData().mixRemainingRooms = 1
				egg:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			end
			
			egg:Update()
		end
	end
end, EntityType.ENTITY_FAMILIAR)
