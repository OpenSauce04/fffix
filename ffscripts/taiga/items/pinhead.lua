-- Pinhead --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:updatePinheadLaserColor(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(3.1, 1.6, 0.7, 1)
		player.LaserColor = lasercolor
	end
end

function mod:pinheadOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			mod:changeTearVariant(tear, TearVariant.PIN, TearVariant.PIN_BLOOD)
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
			tear:GetData().ApplySewn = true
			tear:GetData().ApplySewnDuration = 210 * secondHandMultiplier
		end
	end
end

function mod:pinheadHandleNonPinTearColor(player, tear)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) and tear:GetData().ApplySewn and tear.Variant ~= TearVariant.PIN and tear.Variant ~= TearVariant.PIN_BLOOD then
		tear.Color = Color(0.5, 0.25, 0.10, 1.0, 30/255, 15/255, 0/255)
	end
end

function mod:pinheadOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			local data = bomb:GetData()
			
			bomb.Color = Color(0.5, 0.25, 0.10, 1.0, 30/255, 15/255, 0/255)
			data.ApplySewn = true
			data.ApplySewnDuration = 210 * secondHandMultiplier
		end
	end
end

--function mod:pinheadOnFireKnife(player, knife, secondHandMultiplier)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
--		local luck = math.max(math.floor(player.Luck), 0)
--		if math.random() * 50 <= 20 + (luck * 5) then
--			local data = knife:GetData()
--			
--			data.KnifeColor = Color(0.5, 0.25, 0.10, 1.0, 30/255, 15/255, 0/255)
--			data.ApplySewn = true
--			data.ApplySewnDuration = 210 * secondHandMultiplier
--		end
--	end
--end

function mod:pinheadOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
		end
	end
end

--function mod:pinheadOnFireLaser(player, laser)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
--		laser:GetData().PinheadLaser = true
--	end
--end

--function mod:pinheadOnLaserEndpointInit(endpointData, laserData)
--	endpointData.PinheadLaser = laserData.PinheadLaser
--end

--function mod:pinheadUpdateLaserColors(laser, data)
--	if data.PinheadLaser then
--		--local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
--		--color:SetColorize(3.25, 2.1, 1.4, 1)
--		local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
--		color:SetColorize(3.1, 1.6, 0.7, 1)
--		laser.Color = color
--	end
--end

function mod:pinheadOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
		end
	end
end

function mod:pinheadOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			local data = creep:GetData()
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
			color:SetColorize(3.1, 1.6, 0.7, 1)
			data.FFAquariusColor = color
			
			data.ApplySewn = true
			data.ApplySewnDuration = 210 * secondHandMultiplier
		end
	end
end

function mod:pinheadOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			local data = target:GetData()
			
			data.FFExplosionColor = Color(0.5, 0.25, 0.10, 1.0, 30/255, 15/255, 0/255)
			data.ApplySewn = true
			data.ApplySewnDuration = 210 * secondHandMultiplier
		end
	end
end

function mod:pinheadOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) then
		local luck = math.max(math.floor(player.Luck), 0)
		if math.random() * 50 <= 20 + (luck * 5) then
			FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
		end
	end
end

function mod:pinheadOnLocustDamage(player, locust, entity, secondHandMultiplier)
	if locust.SubType == FiendFolio.ITEM.COLLECTIBLE.PINHEAD then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
		end
	end
end