local mod = FiendFolio
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		
		if player:HasTrinket(FiendFolio.ITEM.ROCK.INSATIABLE_APATITE) then
            if pickup:IsShopItem() and pickup.Price > player:GetNumCoins() then
                return true
            else
                local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.INSATIABLE_APATITE)
                local data = player:GetData()
                if pickup.SubType == 1 or pickup.SubType == 2 or pickup.SubType == 5 or pickup.SubType == 9 or (pickup.SubType == 10 and player:CanPickRedHearts()) then
                    local strength = 0
					local remove = false
                    if pickup.SubType == 1 or pickup.SubType == 9 or pickup.SubType == 10 then
                        strength = 2
                    elseif pickup.SubType == 2 then
                        strength = 1
                    elseif pickup.SubType == 5 then
                        strength = 4
                    end
                    if player:CanPickRedHearts() then
                        --[[if rng:RandomInt(2) == 0 then
                            remove = true
                        end]]
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                    	data.insatiableApatiteStrength = data.insatiableApatiteStrength+strength*0.5
                    else
                        remove = true
                    end
					
					if remove then
						pickup:Remove()
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+strength
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						for i=1,4 do
							Isaac.Spawn(1000, 5, 0, player.Position, RandomVector()*math.random(4), player)
						end
						sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
                        return false
					end
				elseif (pickup.SubType == 3 or pickup.SubType == 10 or pickup.SubType == 8) then
					local strength = 0
					local remove = false
					if pickup.SubType == 3 or pickup.SubType == 10 then
						strength = 2
					else
						strength = 1
					end
					if player:CanPickSoulHearts() then
						--[[if rng:RandomInt(2) == 0 then
                            remove = true
                        end]]
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+strength*0.5
						data.insatiableApatiteDecay = 0.01
                    else
						remove = true
                    end

					if remove == true then
						pickup:Remove()
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+strength
						data.insatiableApatiteDecay = 0.01
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						local gibs = Isaac.Spawn(1000, 2, 160, pickup.Position, Vector.Zero, player)
						gibs.Color = Color(0.1,0.4,1,1,0.31,0.35,0.5)
						sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
                        return false
					end
				elseif player:CanPickBlackHearts() and pickup.SubType == 6 then
					local remove = false
					if player:CanPickBlackHearts() then
						--[[if rng:RandomInt(2) == 0 then
                            remove = true
                        end]]
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+1
						data.insatiableApatiteBlackHeart = true
                    else --I guess black hearts just don't collide when full? Maybe immoral hearts.
						remove = true
                    end

					if remove == true then
						pickup:Remove()
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+2
						data.insatiableApatiteBlackHeart = true
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						local gibs = Isaac.Spawn(1000, 2, 160, pickup.Position, Vector.Zero, player)
						gibs.Color = Color(0.1,0.2,0.2,1,0,0,0)
						sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
                        return false
					end
				elseif pickup.SubType == 12 then --Rotten Heart
					local remove = false
					if player:CanPickRottenHearts() then
						--[[if rng:RandomInt(2) == 0 then
                            remove = true
                        end]]
						player:AddBlueFlies(2, player.Position, player)
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                    	data.insatiableApatiteStrength = data.insatiableApatiteStrength+0.5
                    else
						remove = true
                    end

					if remove == true then
						player:AddBlueFlies(4, player.Position, player)
						pickup:Remove()
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+1
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						for i=1,4 do
							Isaac.Spawn(1000, 5, 0, player.Position, RandomVector()*math.random(4), player)
						end
						sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
                        return false
					end
				elseif pickup.SubType == 4 then --Eternal Heart
					if rng:RandomInt(2) == 0 then
						pickup:Remove()
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
                        data.insatiableApatiteStrength = data.insatiableApatiteStrength+6
						player:AddHearts(12)
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						local gibs = Isaac.Spawn(1000, 2, 160, pickup.Position, Vector.Zero, player)
						gibs.Color = Color(0.1,0.2,0.2,1,1,1,1)
						sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
                        return false
					end
				elseif pickup.SubType == 7 then --Golden Heart
					local remove = false
					if player:CanPickGoldenHearts() then
						--[[if rng:RandomInt(2) == 0 then
							remove = true
						end]]
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
						data.insatiableApatiteStrength = data.insatiableApatiteStrength+1
						player:AddCoins(3)
						sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
					else
						remove = true
					end

					if remove == true then
						pickup:Remove()
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
						data.insatiableApatiteStrength = data.insatiableApatiteStrength+2
						player:AddCoins(7)
						sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						for i=1,4 do
							Isaac.Spawn(1000, 98, 0, player.Position, RandomVector()*math.random(4), player)
						end
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
						return false
					end
				elseif pickup.SubType == 11 then --Bone Heart
					local remove = false
					if player:CanPickBoneHearts() then
						--[[if rng:RandomInt(2) == 0 then
							remove = true
						end]]
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
						data.insatiableApatiteStrength = data.insatiableApatiteStrength+2
						for i=1,4 do
							local bone = Isaac.Spawn(3, FamiliarVariant.BONE_ORBITAL, 0, player.Position, Vector.Zero, player):ToFamiliar()
							bone.Player = player
						end
					else
						remove = true
					end

					if remove == true then
						pickup:Remove()
						data.insatiableApatiteStrength = data.insatiableApatiteStrength or 0
						data.insatiableApatiteStrength = data.insatiableApatiteStrength+4
						for i=1,8 do
							local bone = Isaac.Spawn(3, FamiliarVariant.BONE_ORBITAL, 0, player.Position, Vector.Zero, player):ToFamiliar()
							bone.Player = player
						end
						local bony = Isaac.Spawn(EntityType.ENTITY_BONY, 0, 0, player.Position, Vector.Zero, player):ToNPC()
						bony:AddCharmed(EntityRef(player), -1)
						sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, 1)
						sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 1)
						for i=1,4 do
							Isaac.Spawn(1000, 35, 0, player.Position, RandomVector()*math.random(4), player)
						end
			
						Game():GetLevel():SetHeartPicked()
						Game():ClearStagesWithoutHeartsPicked()
						Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						
						return false
					end
				end
            end
        end
    end
end, 10)

function mod:insatiableApatiteUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.INSATIABLE_APATITE) and data.insatiableApatiteStrength then
		if not data.insatiableApatiteDecay then
			data.insatiableApatiteDecay = 0.02
		end
		if player.FrameCount % 10 == 0 then
			if data.insatiableApatiteStrength > 0 then
				data.insatiableApatiteStrength = math.min(10, data.insatiableApatiteStrength-data.insatiableApatiteDecay)
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			else
				data.insatiableApatiteStrength = 0
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				data.insatiableApatiteDecay = 0.02
				if data.insatiableApatiteBlackHeart then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM, -1)
					data.insatiableApatiteBlackHeart = nil
				end
			end
		end
	end
end

FiendFolio.AddTrinketPickupCallback(nil, function(player)
	if player:GetData().insatiableApatiteStrength then
		player:GetData().insatiableApatiteStrength = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end, FiendFolio.ITEM.ROCK.INSATIABLE_APATITE, nil)