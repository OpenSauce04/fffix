-- Rubber Bullets --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:updateRubberBulletsLaserColor(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(1.8, 0.2, 2.9, 1)
		player.LaserColor = lasercolor
	end
end

function mod:rubberBulletsOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			local data = tear:GetData()

			data.ApplyBruise = true
			data.ApplyBruiseDuration = 120 * secondHandMultiplier
			data.ApplyBruiseStacks = 1
			data.ApplyBruiseDamagePerStack = 1

			mod:changeTearVariant(tear, TearVariant.M90_BULLET)
			
			tear.Color = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)

			if not tear:HasTearFlags(BitSet128(0, 1 << (127 - 64))) then
				tear.Velocity = tear.Velocity * 1.5
				sfx:Play(mod.Sounds.ShotgunBlast,0.7,0,false,math.random(80,120)/100)
			end
		end
	end
end

function mod:rubberBulletsOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			local data = bomb:GetData()

			data.ApplyBruise = true
			data.ApplyBruiseDuration = 120 * secondHandMultiplier
			data.ApplyBruiseStacks = 1
			data.ApplyBruiseDamagePerStack = 1

			bomb.Velocity = bomb.Velocity * 1.5
			bomb.Color = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)
		end
	end
end

--function mod:rubberBulletsOnFireKnife(player, knife, secondHandMultiplier)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
--		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
--			local data = knife:GetData()
--			
--			data.KnifeColor = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)
--			data.ApplyBruise = true
--			data.ApplyBruiseDuration = 120 * secondHandMultiplier
--			data.ApplyBruiseStacks = 1
--			data.ApplyBruiseDamagePerStack = 1
--		end
--	end
--end

function mod:rubberBulletsOnKnifeDamage(player, entity, secondHandMultiplier, hasAppliedBruise)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) and not hasAppliedBruise then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
			return true
		end
	end
	return false
end

--function mod:rubberBulletsOnFireLaser(player, laser)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
--		laser:GetData().RubberBulletsLaser = true
--	end
--end

--function mod:rubberBulletsOnLaserEndpointInit(endpointData, laserData)
--	endpointData.RubberBulletsLaser = laserData.RubberBulletsLaser
--end

--function mod:rubberBulletsUpdateLaserColors(laser, data)
--	if data.RubberBulletsLaser then
--		local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
--		color:SetColorize(1.8, 0.2, 2.9, 1)
--		laser.Color = color
--	end
--end

function mod:rubberBulletsOnLaserDamage(player, entity, secondHandMultiplier, hasAppliedBruise)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) and not hasAppliedBruise then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
			return true
		end
	end
	return false
end

function mod:rubberBulletsOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			local data = creep:GetData()

			data.ApplyBruise = true
			data.ApplyBruiseDuration = 120 * secondHandMultiplier
			data.ApplyBruiseStacks = 1
			data.ApplyBruiseDamagePerStack = 1

			local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
			color:SetColorize(1.8, 0.2, 2.9, 1)
			data.FFAquariusColor = color
		end
	end
end

function mod:rubberBulletsOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			local data = target:GetData()

			data.ApplyBruise = true
			data.ApplyBruiseDuration = 120 * secondHandMultiplier
			data.ApplyBruiseStacks = 1
			data.ApplyBruiseDamagePerStack = 1

			data.FFExplosionColor = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)
		end
	end
end

function mod:rubberBulletsOnDarkArtsDamage(player, entity, secondHandMultiplier, hasAppliedBruise)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS) and not hasAppliedBruise then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
			return true
		end
	end
	return false
end

function mod:rubberBulletsOnLocustDamage(player, locust, entity, secondHandMultiplier, hasAppliedBruise)
	if locust.SubType == FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS then
		if math.random() * 25 <= math.min(12.5, 5 + player.Luck * 0.75) then
			FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
			return true
		end
	end
	return false
end