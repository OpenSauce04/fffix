local mod = FiendFolio
local sfx = SFXManager()

function mod:heavyMetalUpdate(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.HEAVY_METAL) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.HEAVY_METAL)
        local diff = 0.15*mult
        local thresh = 1*mult
        if player.MoveSpeed < thresh then
            diff = math.max(0.15*mult, thresh-player.MoveSpeed)
        end

        data.heavyMetalSpeedBoost = diff
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end

function mod:heavyMetalHurt(player, flag, source)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.HEAVY_METAL) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.HEAVY_METAL)
        local chance = (player:GetData().heavyMetalSpeedBoost or 0)*50

        if rng:RandomInt(100) < chance then
            sfx:Play(mod.Sounds.PvZBucket, 1.5, 0, false, math.random(90,110)/100)
            player:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.8, 0.8, 0.8), 5, 0, true, false)
			player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM, -1)
			mod.scheduleForUpdate(function()
				if sfx:IsPlaying(mod.Sounds.FiendHurt) then
					sfx:Stop(mod.Sounds.FiendHurt)
				elseif sfx:IsPlaying(mod.Sounds.GolemHurt) then
					sfx:Stop(mod.Sounds.GolemHurt)
				end
				sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
			end, 0)
			return false
        end
    end
end