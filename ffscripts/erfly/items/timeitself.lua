local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:timeItselfOnFireTear(player, tear, tdata, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
        if math.random() * 8 <= 2 + player.Luck * 0.4 then
            mod:changeTearVariant(tear, TearVariant.MULTI_EUCLIDEAN)
            tdata.ApplyMultiEuclidean = true
            tdata.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier
        end
	end
end

function mod:timeItselfOnFireBomb(player, bomb, rng, pdata, bdata, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			bdata.ApplyMultiEuclidean = true
			bdata.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier
			
			local color = Color(0,0,0,1)
			bomb.Color = color
		end
	end
end

function mod:timeItselfOnRocketFire(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
            local data = target:GetData()

			data.ApplyMultiEuclidean = true
			data.ApplyMultiEuclidean = 180 * secondHandMultiplier

			local color = Color(0,0,0,1)
			data.FFExplosionColor = color
		end
	end
end

function mod:timeItselfOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
		end
    end
end

function mod:timeItselfOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
		end
	end
end

function mod:timeItselfOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			local data = creep:GetData()

			data.ApplyMultiEuclidean = true
            data.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier

			local color = Color(-1,-1,-1,1)
			data.FFAquariusColor = color
		end
	end
end

function mod:timeItselfOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF) then
		if math.random() * 8 <= 2 + player.Luck * 0.4 then
			FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
		end
	end
end

function mod:timeItselfOnLocustDamage(player, locust, entity, secondHandMultiplier)
	if math.random() * 8 <= 2 + player.Luck * 0.4 then
		FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
	end
end

function mod:timeItselfLocustAI(locust)
	local s = math.sin(game:GetFrameCount()/20*math.pi)
	local multiEuclidColor = Color(-s*2, -s*2, -s*2, 1, (s+1)/2, (s+1)/2, (s+1)/2)
	multiEuclidColor:SetColorize(1, 1, 1, 1)
	locust.Color = multiEuclidColor
end