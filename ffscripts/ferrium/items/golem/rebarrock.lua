local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flag, source)
	if ent:ToPlayer() then
		local player = ent:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.REBAR_ROCK) then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REBAR_ROCK)
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.REBAR_ROCK)
			local chance = math.min(50, 25*mult)
			local reds = true
			if player:GetSoulHearts() > 0 or player:GetBlackHearts() > 0 or player:GetBoneHearts() > 0 then
				reds = false
			end
			if (flag ~= flag | DamageFlag.DAMAGE_CLONES and flag ~= flag | DamageFlag.DAMAGE_FAKE) and (reds == true or (flag & DamageFlag.DAMAGE_RED_HEARTS ~= 0 and player:GetHearts() > 0)) then
				local sfx = SFXManager()
				local num = rng:RandomInt(100)
				--print(num .. ", " .. chance)
				if num < chance then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM, -1)
					mod.scheduleForUpdate(function()
						if sfx:IsPlaying(mod.Sounds.FiendHurt) then
							sfx:Stop(mod.Sounds.FiendHurt)
						elseif sfx:IsPlaying(mod.Sounds.GolemHurt) then
							sfx:Stop(mod.Sounds.GolemHurt)
						end
						sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
					end, 0)
					sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 0, false, 1.5)
					return false
				else
					local room = game:GetRoom()
					if damage > 1 and not (room:GetType() == RoomType.ROOM_SACRIFICE and flag & DamageFlag.DAMAGE_SPIKES ~= 0) then
						player:TakeDamage(1, flag | DamageFlag.DAMAGE_CLONES, source, 20)
						if sfx:IsPlaying(mod.Sounds.FiendHurt) then
							sfx:Stop(mod.Sounds.FiendHurt)
						elseif sfx:IsPlaying(mod.Sounds.GolemHurt) then
							sfx:Stop(mod.Sounds.GolemHurt)
						end
						sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
						
						if player:GetPlayerType() == FiendFolio.PLAYER.FIEND or player:GetPlayerType() == FiendFolio.PLAYER.BIEND then
							sfx:Play(mod.Sounds.FiendHurt, 0.8, 0, false, 1)
						--Removed something here, don't forget
						elseif player:GetPlayerType() == FiendFolio.PLAYER.GOLEM or player:GetPlayerType() == FiendFolio.PLAYER.BOLEM then
							sfx:Play(mod.Sounds.GolemHurt, 0.8, 0, false, 1)
						else
							sfx:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 1, 0, false, 1)
						end
						return false
					end
				end
			end
		end
	end
end, 1)