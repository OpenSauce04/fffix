local mod = FiendFolio

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()

		if player:HasTrinket(FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE) then
			local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE))
			local heartTotal = player:GetBoneHearts()*2+player:GetMaxHearts()+player:GetSoulHearts()

			local shopPickup = false
			if pickup:IsShopItem() then
				local queuedItem = player.QueuedItem
				if queuedItem.Item ~= nil then
					shopPickup = true
				end
				if pickup.Price > player:GetNumCoins() then
					shopPickup = true
				end
			end
			
			if shopPickup == false then
				if player:CanPickRedHearts() and (pickup.SubType == 1 or pickup.SubType == 2 or pickup.SubType == 5 or pickup.SubType == 9 or pickup.SubType == 10) then
					local reds = (player:GetEffectiveMaxHearts() - player:GetHearts())
					if mult >= reds then
						mult = reds-1
					end
					player:AddHearts(mult)
				elseif player:CanPickSoulHearts() and (pickup.SubType == 3 or pickup.SubType == 10 or pickup.SubType == 8) then
					if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
						player:AddSoulCharge(mult)
					else
						if mult >= player:GetHeartLimit()-heartTotal then
							mult = player:GetHeartLimit()-heartTotal-1
						end
						player:AddSoulHearts(mult)
					end
				elseif player:CanPickBlackHearts() and pickup.SubType == 6 then
					if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
						player:AddSoulCharge(mult)
					else
						--Oh right, forgot getblackhearts is dumb
						local heartString = mod:intToBinary(player:GetBlackHearts())
						local _,hearts = string.gsub(heartString, "1", " ")
						local black = (player:GetHeartLimit()/2)-hearts
						local souls = player:GetSoulHearts()-hearts*2
						local fakeMult = mult
						if mult % 2 ~= 0 then
							fakeMult = mult+1
						end
						
						if fakeMult >= souls and souls > 0 then
							mult = souls-2
						elseif mult >= black*2 then
							mult = (black*2)-1
						end
						player:AddBlackHearts(mult)
					end
				elseif player:CanPickRottenHearts() and pickup.SubType == 12 then
					local rottens = (math.ceil(player:GetEffectiveMaxHearts()/2) - player:GetRottenHearts())
					if mult >= rottens then
						mult = rottens-1
					end
					player:AddRottenHearts(mult)
				else
					player:AddHearts(mult)
				end
			end
		end
	end
end, 10)

function mod:intToBinary(num)
	local bin = ""
	while num ~= 0 do
		if num%2 == 0 then
			bin = "0" .. bin
		else
			bin = "1" .. bin
		end
		num = math.floor(num/2)
	end
	while string.len(bin) < 4 do
		bin = "0" .. bin
	end
	return bin
end