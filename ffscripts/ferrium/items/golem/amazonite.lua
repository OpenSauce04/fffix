local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

mod.AddTrinketPickupCallback(
function(player, trinket)
	if not player:GetData().ffsavedata.RunEffects.amazoniteMult then
		player:GetData().ffsavedata.RunEffects.amazoniteMult = 0
	end
	local added = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.AMAZONITE)-player:GetData().ffsavedata.RunEffects.amazoniteMult
	local savedata = FiendFolio.savedata.run
	savedata.amazonite = (savedata.amazonite or 0)+added
	savedata.amazoniteUsed = (savedata.amazoniteUsed or 0)
	player:GetData().ffsavedata.RunEffects.amazoniteMult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.AMAZONITE)
end, 
function(player)
	local loss = player:GetData().ffsavedata.RunEffects.amazoniteMult-player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.AMAZONITE)
	local savedata = FiendFolio.savedata.run
	if savedata.amazonite then
		savedata.amazonite = savedata.amazonite-loss
	else
		savedata.amazonite = 0
	end
	player:GetData().ffsavedata.RunEffects.amazoniteMult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.AMAZONITE)
end, FiendFolio.ITEM.ROCK.AMAZONITE, nil)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	local savedata = FiendFolio.savedata.run
	local data = pickup:GetData()
	if (savedata.amazonite and savedata.amazonite > 0) and (savedata.amazoniteUsed and savedata.amazoniteUsed < savedata.amazonite) and pickup:IsShopItem() then
		if pickup.Variant == 100 and savedata.amazonite > 1 and pickup.Price > 0 then
			pickup.AutoUpdatePrice = false
			pickup.Price = 5
			data.amazoniteReduced = true
		elseif pickup.Variant ~= 100 then
			pickup.AutoUpdatePrice = false
			pickup.Price = PickupPrice.PRICE_FREE
			data.amazoniteReduced = true 
		end
	elseif data.amazoniteReduced == true then
		pickup.AutoUpdatePrice = true
		data.amazoniteReduced = nil
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, coll, low)
	local data = pickup:GetData()
	if data.amazoniteReduced and pickup:IsShopItem() and coll:ToPlayer() then
		local savedata = FiendFolio.savedata.run
		if (savedata.amazonite and savedata.amazonite > 0) and (savedata.amazoniteUsed and savedata.amazoniteUsed < savedata.amazonite) then
			local player = coll:ToPlayer()
			local pdata = player:GetData().ffsavedata.RunEffects
			
			sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
			if not pdata.amazonitePurchased then
				pdata.amazonitePurchased = {}
			end
			table.insert(pdata.amazonitePurchased, {pickup.Type, pickup.Variant, pickup.SubType})
			if pickup.Variant == 100 then
				player:AddCoins(-pickup.Price)
			end
			pickup:Remove()
			Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, player)
			savedata.amazoniteUsed = (savedata.amazoniteUsed or 0)+1
			for i=1,4 do
				Isaac.Spawn(1000, 98, 0, pickup.Position, RandomVector()*math.random(2,6), player)
			end
			return true
		end
	end
end)

function mod:amazoniteNewLevel()
	local savedata = FiendFolio.savedata.run
	if savedata.amazonite then
		savedata.amazonite = 0
	end
	if savedata.amazoniteUsed then
		savedata.amazoniteUsed = 0
	end
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.AMAZONITE) then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.AMAZONITE)
			savedata.amazonite = savedata.amazonite+math.ceil(mult)
		end
		if player:GetData().ffsavedata.RunEffects.amazonitePurchased then
			mod.scheduleForUpdate(function()
				local bought = player:GetData().ffsavedata.RunEffects.amazonitePurchased
				player:AnimateHappy()
				local room = game:GetRoom()
				for _,item in ipairs(bought) do
					local pickup = Isaac.Spawn(item[1], item[2], item[3], room:FindFreePickupSpawnPosition(player.Position, 40, true, false), Vector.Zero, player)
					Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, player)
				end
				sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
				for i=1,4 do
					Isaac.Spawn(1000, 98, 0, player.Position, RandomVector()*math.random(2,6), player)
				end
				player:GetData().ffsavedata.RunEffects.amazonitePurchased = nil
			end, 2)
		end
	end
end