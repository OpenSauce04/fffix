local mod = FiendFolio
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.NITRO_CRYSTAL) then
			local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.NITRO_CRYSTAL)
			if pickup.SubType == 3 then
                mult = mult * 10
            elseif pickup.SubType == 2 then
                mult = mult * 5
            elseif pickup.SubType == 4 then
                mult = mult * 2
            end
            local d = player:GetData()
            if not d.nitroCrystalStatBoost then
                local status = Isaac.Spawn(mod.FF.NitroStatus.ID, mod.FF.NitroStatus.Var, mod.FF.NitroStatus.Sub, player.Position, nilvector, player)
                status:Update()
                sfx:Play(mod.Sounds.NitroActive, 1, 0, false, math.random(90,110)/100)
            end
            d.nitroCrystalStatBoost = d.nitroCrystalStatBoost or 0
            d.nitroCrystalStatBoost = d.nitroCrystalStatBoost + 50 * mult
            player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
		end
	end
end, 20)

function mod:nitroCrystalPlayerEffects(player, data)
    if data.nitroCrystalStatBoost then
        if player:HasTrinket(FiendFolio.ITEM.ROCK.NITRO_CRYSTAL) then
            if player.FrameCount % 5 == 0 then
                local sparkle = Isaac.Spawn(1000, 7003, 0, player.Position, nilvector, player):ToEffect()
                sparkle.RenderZOffset = 50
                sparkle:FollowParent(player)
                sparkle.SpriteOffset = Vector(0, -15) + Vector(-20 + math.random(40), -15 + math.random(30))
            end
        end
        if data.nitroCrystalStatBoost > 0 then
            if player.FrameCount % 10 == 0 then
                data.nitroCrystalStatBoost = data.nitroCrystalStatBoost - 1
                player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        else
            data.nitroCrystalStatBoost = nil
            if player:HasTrinket(FiendFolio.ITEM.ROCK.NITRO_CRYSTAL) then
                local status = Isaac.Spawn(mod.FF.NitroStatus.ID, mod.FF.NitroStatus.Var, mod.FF.NitroStatus.Sub, player.Position, nilvector, player)
                status:GetSprite():Play("Expired", true)
                status:Update()
                sfx:Play(mod.Sounds.NitroExpired, 1, 0, false, math.random(90,110)/100)
            end
            player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
end

function mod:nitroStatusIndicatorUpdate(e)
    local sprite = e:GetSprite()
    if sprite:IsFinished("Active") or sprite:IsFinished("Expired") then
        e:Remove()
    end
end