local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

function mod:prismaticGeodeUpdate(player, data)
    if data.prismaticGeodeSpeedTimer then
        if data.prismaticGeodeSpeedTimer > 0 then
            data.prismaticGeodeSpeedTimer = data.prismaticGeodeSpeedTimer-1
        else
            data.prismaticGeodeSpeedTimer = nil
            data.prismaticGeodeSpeedBoost = 0
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    end
    if data.prismaticGeodeRangeTimer then
        if data.prismaticGeodeRangeTimer > 0 then
            data.prismaticGeodeRangeTimer = data.prismaticGeodeRangeTimer-1
        else
            data.prismaticGeodeRangeTimer = nil
            data.prismaticGeodeRangeBoost = 0
            player:AddCacheFlags(CacheFlag.CACHE_RANGE)
            player:EvaluateItems()
        end
    end
    if data.prismaticGeodeShotTimer then
        if data.prismaticGeodeShotTimer > 0 then
            data.prismaticGeodeShotTimer = data.prismaticGeodeShotTimer-1
        else
            data.prismaticGeodeShotTimer = nil
            data.prismaticGeodeShotBoost = 0
            player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()
        end
    end
    if data.prismaticGeodeDamageTimer then
        if data.prismaticGeodeDamageTimer > 0 then
            data.prismaticGeodeDamageTimer = data.prismaticGeodeDamageTimer-1
        else
            data.prismaticGeodeDamageTimer = nil
            data.prismaticGeodeDamageBoost = 0
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end
    if data.prismaticGeodeTearTimer then
        if data.prismaticGeodeTearTimer > 0 then
            data.prismaticGeodeTearTimer = data.prismaticGeodeTearTimer-1
        else
            data.prismaticGeodeTearTimer = nil
            data.prismaticGeodeTearBoost = 0
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
    if data.prismaticGeodeRainbowTimer then
        if data.prismaticGeodeRainbowTimer > 0 then
            data.prismaticGeodeRainbowTimer = data.prismaticGeodeRainbowTimer-1
        else
            data.prismaticGeodeRainbowTimer = nil
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.PRISMATIC_GEODE, true) then
		local mult = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.ROCK.PRISMATIC_GEODE)
		if not (npc.Type == mod.FFID.Tech and npc.Variant > 999) and not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD) then
			local chance = mult*12
            local rng = npc:GetDropRNG()
			if rng:RandomInt(100) < chance then
                local subt = rng:RandomInt(6)
                if subt == 3 then
                    if rng:RandomInt(2) == 0 then
                        subt = rng:RandomInt(6) --I know this means it can roll rainbow again but it still makes it rarer
                    end
                end
				Isaac.Spawn(5, PickupVariant.PICKUP_PRISM_SHARD, subt, npc.Position, Vector.Zero, nil):ToPickup()
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 0, false, 2.4)
	end
end, PickupVariant.PICKUP_PRISM_SHARD)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    if pickup.SubType == 6 then
        local rng = pickup:GetDropRNG()
        pickup:Morph(pickup.Type, pickup.Variant, rng:RandomInt(6))
    end
end, PickupVariant.PICKUP_PRISM_SHARD)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if collider.Type == 1 then
		collider = collider:ToPlayer()
		if pickup:IsShopItem() and pickup.Price > collider:GetNumCoins() then
			return true
		else
            if pickup:GetSprite():WasEventTriggered("DropSound") or pickup:GetSprite():IsPlaying("Idle") then
				local data = collider:GetData()
                local timer = 300
                local boost = 1
                if mod.HasTwoGeodes(collider) then
                    timer = 450
                    boost = 2
                end

                if pickup.SubType == 0 then --Speed
                    data.prismaticGeodeSpeedBoost = 0.3*boost
                    data.prismaticGeodeSpeedTimer = timer
                    collider:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.2, 0.2, 0.5), 5, 0, true, false)
                elseif pickup.SubType == 1 then --Range
                    data.prismaticGeodeRangeBoost = 50*boost
                    data.prismaticGeodeRangeTimer = timer
                    collider:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.2, 0.5, 0.2), 5, 0, true, false)
                elseif pickup.SubType == 2 then --Shotspeed
                    data.prismaticGeodeShotBoost = 0.3*boost
                    data.prismaticGeodeShotTimer = timer
                    collider:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.5, 0.2, 0.5), 5, 0, true, false)
                elseif pickup.SubType == 3 then --All
                    data.prismaticGeodeRainbowTimer = timer
                    collider:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.5, 0.5, 0.5), 5, 0, true, false)
                elseif pickup.SubType == 4 then --Damage
                    data.prismaticGeodeDamageBoost = 1*boost
                    data.prismaticGeodeDamageTimer = timer
                    collider:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.5, 0.2, 0.2), 5, 0, true, false)
                elseif pickup.SubType == 5 then --Tears
                    data.prismaticGeodeTearBoost = 1.2*boost
                    data.prismaticGeodeTearTimer = timer
                    collider:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.5, 0.5, 0.2), 5, 0, true, false)
                end

                collider:AddCacheFlags(CacheFlag.CACHE_ALL)
                collider:EvaluateItems()
				
				pickup:GetSprite():Play("Collect")
				sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.5, 0, false, math.random(250,350)/100)

				pickup.EntityCollisionClass = 0

				if pickup:IsShopItem() then
					collider:AddCoins(-1 * pickup.Price)
				end

				if pickup.OptionsPickupIndex ~= 0 then
					local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
					for _, entity in ipairs(pickups) do
						if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
						   (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
						then
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
							entity:Remove()
						end
					end
				end
			end
			return true
        end
    end
end, PickupVariant.PICKUP_PRISM_SHARD)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng)
	local room = game:GetRoom()
    if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.PRISMATIC_GEODE, true) then
		local mult = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.ROCK.PRISMATIC_GEODE)
        local chance = mult*25

        if rng:RandomInt(100) < chance then
            local subt = rng:RandomInt(6)
            if subt == 3 then
                if rng:RandomInt(2) == 0 then
                    subt = rng:RandomInt(6) --I know this means it can roll rainbow again but it still makes it rarer
                end
            end
            Isaac.Spawn(5, PickupVariant.PICKUP_PRISM_SHARD, subt, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector.Zero, nil)
        end
    end
end)