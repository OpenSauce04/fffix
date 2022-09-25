-- Lawn Darts --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:updateLawnDartsLaserColor(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(4.8, 1.6, 1.4, 1)
		player.LaserColor = lasercolor
	end
end

function mod:lawnDartsOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			local data = tear:GetData()
			
			data.ApplyBleed = true
			data.ApplyBleedDuration = 180 * secondHandMultiplier
			data.ApplyBleedDamage = player.Damage * 0.5
			mod:changeTearVariant(tear, TearVariant.LAWN_DART)
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 0.5, 0, false, 1 / tear.Scale)
			--[[local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 0/255, -25/255)
			color:SetColorize(0.7, 0.4, 0.5, 1)
			tear.Color = color]]
		end
	end
end

function mod:lawnDartsOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			local data = bomb:GetData()
			
			data.ApplyBleed = true
			data.ApplyBleedDuration = 180 * secondHandMultiplier
			data.ApplyBleedDamage = player.Damage * 0.5
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 0/255, -25/255)
			color:SetColorize(0.7, 0.4, 0.5, 1)
			bomb.Color = color
		end
	end
end

--function mod:lawnDartsOnFireKnife(player, knife, secondHandMultiplier)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
--		if math.random() * 8 <= 2 + player.Luck * 0.4 then
--			local data = knife:GetData()
--			
--			data.ApplyBleed = true
--			data.ApplyBleedDuration = 180 * secondHandMultiplier
--			data.ApplyBleedDamage = player.Damage * 0.5
--			
--			local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 0/255, -25/255)
--			color:SetColorize(0.7, 0.4, 0.5, 1)
--			data.KnifeColor = color
--		end
--	end
--end

function mod:lawnDartsOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
		end
	end
end

--function mod:lawnDartsOnFireLaser(player, laser)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
--		laser:GetData().LawnDartsLaser = true
--	end
--end

--function mod:lawnDartsOnLaserEndpointInit(endpointData, laserData)
--	endpointData.LawnDartsLaser = laserData.LawnDartsLaser
--end

--function mod:lawnDartsUpdateLaserColors(laser, data)
--	if data.LawnDartsLaser then
--		local color = Color(1.6, 1.6, 1.6, 1.0, 0/255, 0/255, 0/255)
--		color:SetColorize(3.0, 1.0, 1.0, 1)
--		laser.Color = color
--	end
--end

function mod:lawnDartsOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
		end
	end
end

function mod:lawnDartsOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			local data = creep:GetData()

			data.ApplyBleed = true
			data.ApplyBleedDuration = 180 * secondHandMultiplier
			data.ApplyBleedDamage = player.Damage * 0.5

			local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
			color:SetColorize(4.8, 1.6, 1.4, 1)
			data.FFAquariusColor = color
		end
	end
end

function mod:lawnDartsOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			local data = target:GetData()

			data.ApplyBleed = true
			data.ApplyBleedDuration = 180 * secondHandMultiplier
			data.ApplyBleedDamage = player.Damage * 0.5

			local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 0/255, -25/255)
			color:SetColorize(0.7, 0.4, 0.5, 1)
			data.FFExplosionColor = color
		end
	end
end

function mod:lawnDartsOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
		end
	end
end

function mod:lawnDartsOnLocustDamage(player, locust, entity, secondHandMultiplier)
	if locust.SubType == FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
		end
	end
end