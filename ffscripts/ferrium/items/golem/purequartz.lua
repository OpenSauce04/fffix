local mod = FiendFolio

function mod:pureQuartzHurt(player, damage, flag)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.PURE_QUARTZ) then
		local souls = player:GetSoulHearts()
		local reds = false
		if flag == flag | DamageFlag.DAMAGE_RED_HEARTS and player:GetHearts() > 0 then
			reds = true
		end
		if damage >= souls and souls > 0 and not reds then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.PURE_QUARTZ)
			mod.scheduleForUpdate(function()
				player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)
				--[[local tempEff = player:GetEffects()
				if not tempEff:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS) then
					tempEff:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, 1)
				end
				local shadows = tempEff:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
				if shadows then
					print(shadows.Cooldown)
					shadows.Cooldown = 10
				end]]
				for i=1,mult do
					player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM, -1)
				end
				SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1)
			end, 1)
		end
	end
end