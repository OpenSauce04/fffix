-- Crucifix --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:updateCrucifixTearLaserColor(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		local tearcolor = Color(1.0, 1.0, 1.0, 1.0, 50/255, 120/255, 160/255)
		tearcolor:SetColorize(0.75, 0.7, 1, 1)
		player.TearColor = tearcolor
		
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(3.75, 5.25, 6, 1)
		player.LaserColor = lasercolor
	end
end

function mod:crucifixOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		local data = tear:GetData()
		data.ApplyMartyr = true
		data.ApplyMartyrDuration = 150 * secondHandMultiplier
		--tear.Color = Color(1.0, 1.0, 1.0, 1.0, 45/255, 120/255, 160/255)
	end
end

function mod:crucifixOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		local data = bomb:GetData()
	
		data.ApplyMartyr = true
		data.ApplyMartyrDuration = 150 * secondHandMultiplier
		--bomb.Color = Color(1.0, 1.0, 1.0, 1.0, 45/255, 120/255, 160/255)
	end
end

--function mod:crucifixOnKnifeUpdate(player, knife, secondHandMultiplier)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
--		local data = knife:GetData()
--		--knife.Color = Color(1.0, 1.0, 1.0, 1.0, 45/255, 120/255, 160/255)
--		data.ApplyMartyr = true
--		data.ApplyMartyrDuration = 150 * secondHandMultiplier
--	else
--		local data = knife:GetData()
--		data.ApplyMartyr = nil
--		data.ApplyMartyrDuration = nil
--	end
--end

function mod:crucifixOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
	end
end

--function mod:crucifixOnFireLaser(player, laser)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
--		laser:GetData().MartyrLaser = true
--	end
--end

--function mod:crucifixOnLaserEndpointInit(endpointData, laserData)
--	endpointData.MartyrLaser = laserData.MartyrLaser
--end

--function mod:crucifixUpdateLaserColors(laser, data)
--	if data.MartyrLaser then
--		local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
--		color:SetColorize(3.75, 5.25, 6, 1)
--		laser.Color = color
--	end
--end

function mod:crucifixOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
	end
end

function mod:crucifixOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		local data = creep:GetData()
	
		data.ApplyMartyr = true
		data.ApplyMartyrDuration = 150 * secondHandMultiplier
		
		--local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		--color:SetColorize(3.75, 5.25, 6, 1)
		--data.FFAquariusColor = color
	end
end

function mod:crucifixOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		local data = target:GetData()
	
		data.ApplyMartyr = true
		data.ApplyMartyrDuration = 150 * secondHandMultiplier
		--data.FFExplosionColor = Color(1.0, 1.0, 1.0, 1.0, 45/255, 120/255, 160/255)
	end
end

function mod:crucifixOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX) then
		FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
	end
end

function mod:crucifixOnLocustDamage(player, locust, entity, secondHandMultiplier)
	if locust.SubType == FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX then
		FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
	end
end