-- Fetal Fiend --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(p, added)
	local player = p
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			player = player:GetOtherTwin()
		end
	end
	
	if CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		return
	end
	
	local hearts = CustomHealthAPI.Library.GetHealthInOrder(player)
	for i = #hearts, 1, -1 do
		local health = hearts[i]
		local key = health.Other.Key
		local typeOfKey = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
		
		if typeOfKey == CustomHealthAPI.Enums.HealthTypes.SOUL and key ~= "IMMORAL_HEART" then
			CustomHealthAPI.Library.TryConvertOtherKey(player, i, "IMMORAL_HEART", true)
		end
	end
	
	local redHearts = player:GetHearts()
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY and redHearts > 0 then
		redHearts = redHearts - 1
	end
	player:AddHearts(-redHearts)
	mod:AddImmoralHearts(player, math.ceil(redHearts / 2))
end, nil, FiendFolio.ITEM.COLLECTIBLE.FETAL_FIEND)

--function mod:updateFetalFiendDamage(player)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FETAL_FIEND) then
--		player.Damage = player.Damage * 1.4
--	end
--end
