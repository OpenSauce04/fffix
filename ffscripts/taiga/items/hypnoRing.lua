-- Hypno Ring --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:updateHypnoRingLaserColor(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
		local lasercolor = Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(0.9, 0.8, 2.4, 1)
		player.LaserColor = lasercolor
	end
end

function mod:hypnoRingOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			local data = tear:GetData()

			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(0.25, 0.2, 0.6, 1.0, 20/255, 20/255, 40/255)
			color:SetColorize(1.0, 1.0, 1.0, 1)
			tear.Color = color
		end
	end
end

function mod:hypnoRingOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			local data = bomb:GetData()
			
			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(0.25, 0.2, 0.6, 1.0, 20/255, 20/255, 40/255)
			color:SetColorize(1.0, 1.0, 1.0, 1)
			bomb.Color = color
		end
	end
end

--function mod:hypnoRingOnFireKnife(player, knife, secondHandMultiplier)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
--		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
--			local data = knife:GetData()
--			
--			data.ApplyDrowsyDelayTilFired = true
--			data.ApplyDrowsyDuration = 60
--			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
--
--			local color = Color(0.25, 0.2, 0.6, 1.0, 20/255, 20/255, 40/255)
--			color:SetColorize(1.0, 1.0, 1.0, 1)
--			data.KnifeColor = color
--		end
--	end
--end

function mod:hypnoRingOnKnifeDamage(player, entity, secondHandMultiplier, hasProccedSleep)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) and not hasProccedSleep then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end

--function mod:hypnoRingOnFireLaser(player, laser)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
--		laser:GetData().HypnoRingLaser = true
--	end
--end

--function mod:hypnoRingOnLaserEndpointInit(endpointData, laserData)
--	endpointData.HypnoRingLaser = laserData.HypnoRingLaser
--end

--function mod:hypnoRingUpdateLaserColors(laser, data)
--	if data.HypnoRingLaser then
--		local color = Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255)
--		color:SetColorize(0.9, 0.8, 2.4, 1)
--		laser.Color = color
--	end
--end

function mod:hypnoRingOnLaserDamage(player, entity, secondHandMultiplier, hasProccedSleep)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) and not hasProccedSleep then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end

function mod:hypnoRingOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			local data = creep:GetData()

			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255)
			color:SetColorize(0.9, 0.8, 2.4, 1)
			data.FFAquariusColor = color
		end
	end
end

function mod:hypnoRingOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			local data = target:GetData()

			data.ApplyDrowsy = true
			data.ApplyDrowsyDuration = 60
			data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier

			local color = Color(0.25, 0.2, 0.6, 1.0, 20/255, 20/255, 40/255)
			color:SetColorize(1.0, 1.0, 1.0, 1)
			data.FFExplosionColor = color
		end
	end
end

function mod:hypnoRingOnDarkArtsDamage(player, entity, secondHandMultiplier, hasProccedSleep)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING) and not hasProccedSleep then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end

function mod:hypnoRingOnLocustDamage(player, locust, entity, secondHandMultiplier, hasProccedSleep)
	if locust.SubType == FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING and not hasProccedSleep then
		if math.random() * 25 <= 5 + math.min(player.Luck, 10) / 3 then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	elseif locust.SubType == FiendFolio.ITEM.COLLECTIBLE.BEDTIME_STORY and not hasProccedSleep then
		if math.random() * 100 <= 5 + math.min(player.Luck, 10) / 3 then
			FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
		end
	end
end