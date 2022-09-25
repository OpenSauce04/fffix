local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

function mod:shamrockHurt(player, flag, source)
	if flag ~= flag | DamageFlag.DAMAGE_FAKE and flag ~= flag | DamageFlag.DAMAGE_NO_PENALTIES and flag ~= flag | DamageFlag.DAMAGE_IV_BAG and not (source and source.Type == EntityType.ENTITY_SLOT) then
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SHAMROCK) then
			local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHAMROCK))
			local data = player:GetData().ffsavedata.RunEffects
			local lowered
			if mult > 1 then
				data.shamrockDamage = (data.shamrockDamage or 0) + 1
				if data.shamrockDamage >= mult then
					data.shamrockDamage = 0
					data.shamrockCount = (data.shamrockCount or 0) + 1
					lowered = true
				end
			else
				data.shamrockCount = (data.shamrockCount or 0) + 1
				lowered = true
			end
			
			if lowered == true then
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 0.8, 0, false, 1)
				sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.5, 0, false, 3)
				player:AddCacheFlags(CacheFlag.CACHE_LUCK)
				player:EvaluateItems()
			end
		end
	end
end

function mod:shamrockNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:GetData().ffsavedata.RunEffects.shamrockCount then
			player:GetData().ffsavedata.RunEffects.shamrockCount = 0
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	end
end