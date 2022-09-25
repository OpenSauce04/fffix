-- Prank Cookie --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local prankCookieEffects = {
	{DataFlag = "ApplyBerserk", Weight = 1, Color = Color(0.4, 0.25, 0.25, 1.0, 60/255, -40/255, -40/255)},
	{DataFlag = "ApplyBleed", Weight = 1, Color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 0/255, -25/255)},
	{DataFlag = "ApplyBruise", Weight = 1, Color = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)},
	{DataFlag = "ApplyDrowsy", Weight = 1, Color = Color(0.25, 0.2, 0.6, 1.0, 20/255, 20/255, 40/255)},
	{DataFlag = "ApplyMartyr", Weight = 1, Color = Color(1.0, 1.0, 1.0, 1.0, 50/255, 120/255, 160/255)},
	{DataFlag = "ApplySewn", Weight = 1, Color = Color(0.5, 0.25, 0.10, 1.0, 30/255, 15/255, 0/255)},
	{DataFlag = "ApplyDoom", Weight = 1, Color = Color(0.30, 0.30, 0.30, 1.0, 10/255, -25/255, -25/255)},
	{DataFlag = "isImpSodaTear", Weight = 1, Color = Color(1.0, 1.0, 1.0, 1.0, 100/255, -150/255, 100/255)},
	{DataFlag = "YinYangOrb", Weight = 1, Color = Color(0.05, 0.65, 0.9, 1.0, 0/255, 60/255, 90/255)},
	{DataFlag = "ApplyMultiEuclidean", Weight = 1, Color = Color(2.0, 2.0, 2.0, 1.0, 0/255, 0/255, 0/255)},
}

--prankCookieEffects[1].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- Berserk
prankCookieEffects[2].Color:SetColorize(0.7, 0.4, 0.5, 1.0) -- Bleed
--prankCookieEffects[3].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- Bruise
--prankCookieEffects[4].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- Drowsy
prankCookieEffects[5].Color:SetColorize(0.75, 0.7, 1.0, 1.0) -- Martyr
--prankCookieEffects[6].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- Sewn
prankCookieEffects[7].Color:SetColorize(0.75, 0.5, 0.5, 1.0) -- Doom
--prankCookieEffects[8].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- Crit
--prankCookieEffects[9].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- YinYang
prankCookieEffects[10].Color:SetColorize(1.0, 1.0, 1.0, 1.0) -- MultiEuclidean

local prankCookieLaserColors = {
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Sewn
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Doom
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Berserk/Bleed
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Crit
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Bruise
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Drowsy
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- YinYang
	Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255), -- Martyr
}

--SetColorize(3.0, 0.0, 0.0, 1) -- Bleed
--SetColorize(0.9, 0.8, 2.4, 1) -- Drowsy
--SetColorize(0.2, 4.8, 7.0, 1) -- YinYang

prankCookieLaserColors[1]:SetColorize(2.23, 1.5, 1.0, 1) -- Sewn
prankCookieLaserColors[2]:SetColorize(1.0, 0.1, 0.1, 1) -- Doom
prankCookieLaserColors[3]:SetColorize(3.0, 0.0, 0.0, 1) -- Berserk/Bleed
prankCookieLaserColors[4]:SetColorize(2.85, 0.45, 1.7, 1) -- Crit
prankCookieLaserColors[5]:SetColorize(1.8, 0.2, 2.9, 1) -- Bruise
prankCookieLaserColors[6]:SetColorize(0.9, 0.8, 2.4, 1) -- Drowsy
prankCookieLaserColors[7]:SetColorize(0.08, 1.8, 2.6, 1) -- YinYang
prankCookieLaserColors[8]:SetColorize(1.8, 2.25, 2.6, 1) -- Martyr

local prankCookieAquariusColors = {
	["ApplyBerserk"] = Color(0.8, 0.8, 0.8, 1.0, 0/255, 0/255, 0/255),
	["ApplyBleed"] = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255),
	["ApplyBruise"] = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255),
	["ApplyDrowsy"] = Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255),
	["ApplyMartyr"] = Color(1.0, 1.0, 1.0, 1.0, 50/255, 120/255, 160/255),
	["ApplySewn"] = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255),
	["ApplyDoom"] = Color(0.30, 0.30, 0.30, 1.0, 10/255, -25/255, -25/255),
	["isImpSodaTear"] = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255),
	["YinYangOrb"] = Color(1.4, 1.4, 1.4, 1.0, 0/255, 0/255, 0/255),
	["ApplyMultiEuclidean"] = Color(2.0, 2.0, 2.0, 1.0, 0/255, 0/255, 0/255),
}

prankCookieAquariusColors["ApplyBerserk"]:SetColorize(3.0, 0.0, 0.0, 1) -- Berserk
prankCookieAquariusColors["ApplyBleed"]:SetColorize(4.8, 1.6, 1.4, 1) -- Bleed
prankCookieAquariusColors["ApplyBruise"]:SetColorize(1.8, 0.2, 2.9, 1) -- Bruise
prankCookieAquariusColors["ApplyDrowsy"]:SetColorize(0.9, 0.8, 2.4, 1) -- Drowsy
prankCookieAquariusColors["ApplyMartyr"]:SetColorize(2.8125, 2.625, 3.75, 1) -- Martyr
prankCookieAquariusColors["ApplySewn"]:SetColorize(3.1, 1.6, 0.7, 1) -- Sewn
prankCookieAquariusColors["ApplyDoom"]:SetColorize(0.75, 0.5, 0.5, 1) -- Doom
prankCookieAquariusColors["isImpSodaTear"]:SetColorize(5.7, 0.9, 3.4, 1) -- Crit
prankCookieAquariusColors["YinYangOrb"]:SetColorize(0.096, 2.16, 3.12, 1) -- YinYang
prankCookieAquariusColors["ApplyMultiEuclidean"]:SetColorize(1.0, 1.0, 1.0, 1.0) -- MultiEuclidean

local doomDuration = 180
local doomCountdown = 3
local doomDamageMulti = 5

function mod:prankCookieRollTearEffect(player, tear)
	local prankCookieDataFlag = nil
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		tear.Color = chosenEffect.Color
		mod:changeTearVariant(tear, TearVariant.PRANK_COOKIE)
		prankCookieDataFlag = chosenEffect.DataFlag
	end
	return prankCookieDataFlag
end

function mod:prankCookieOnFireTear(player, tear, prankCookieDataFlag, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local data = tear:GetData()

		if prankCookieDataFlag == "ApplyBerserk" then
			if math.random(15) == 1 then
				data.ApplyBerserk = true
				data.ApplyBerserkDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				data.ApplyBleed = true
				data.ApplyBleedDuration = 180 * secondHandMultiplier
				data.ApplyBleedDamage = player.Damage * 0.5
			end
		elseif prankCookieDataFlag == "ApplyBruise" then
			if math.random() * 25 <= 5 then
				data.ApplyBruise = true
				data.ApplyBruiseDuration = 120 * secondHandMultiplier
				data.ApplyBruiseStacks = 1
				data.ApplyBruiseDamagePerStack = 1
			end
		elseif prankCookieDataFlag == "ApplyDrowsy" then
			if math.random() * 25 <= 5 then
				data.ApplyDrowsy = true
				data.ApplyDrowsyDuration = 60
				data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				data.ApplyMartyr = true
				data.ApplyMartyrDuration = 150 * secondHandMultiplier
				tear.TearFlags = tear.TearFlags | TearFlags.TEAR_CONFUSION
			end
		elseif prankCookieDataFlag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				data.ApplySewn = true
				data.ApplySewnDuration = 210 * secondHandMultiplier
				tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
			end
		elseif prankCookieDataFlag == "ApplyDoom" then
			data.ApplyDoom = true
			data.ApplyDoomDuration = doomDuration * secondHandMultiplier
			data.ApplyDoomCountdown = doomCountdown
			data.ApplyDoomDamage = player.Damage * doomDamageMulti
			
			data.IsPrankCookieDoom = true
			data.PrankCookieDoomPlayerDamage = player.Damage
		elseif prankCookieDataFlag == "isImpSodaTear" then
			if not data.isImpSodaTear and math.random(25) == 1 then
				tear.CollisionDamage = tear.CollisionDamage * 5
				data.isImpSodaTear = true
			end
		elseif prankCookieDataFlag == "YinYangOrb" then
			if not data.YinYangOrb and math.random(20) < 5 then
				tear.CollisionDamage = tear.CollisionDamage * 1.25
				tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
				data.YinYangOrb = true
				if tear:HasTearFlags(BitSet128(0, 1 << (127 - 64))) then data.yinyangstrength = 0.4 end
			end
		elseif prankCookieDataFlag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				data.ApplyMultiEuclidean = true
				data.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier
			end
		end
	end
end

function mod:prankCookieRollBombEffect(player, bomb)
	local prankCookieDataFlag = nil
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		bomb.Color = chosenEffect.Color
		prankCookieDataFlag = chosenEffect.DataFlag
	end
	return prankCookieDataFlag
end

function mod:prankCookieOnFireBomb(player, bomb, prankCookieDataFlag, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local data = bomb:GetData()

		if prankCookieDataFlag == "ApplyBerserk" then
			if math.random(15) == 1 then
				data.ApplyBerserk = true
				data.ApplyBerserkDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				data.ApplyBleed = true
				data.ApplyBleedDuration = 180 * secondHandMultiplier
				data.ApplyBleedDamage = player.Damage * 0.5
			end
		elseif prankCookieDataFlag == "ApplyBruise" then
			if math.random() * 25 <= 5 then
				data.ApplyBruise = true
				data.ApplyBruiseDuration = 120 * secondHandMultiplier
				data.ApplyBruiseStacks = 1
				data.ApplyBruiseDamagePerStack = 1
			end
		elseif prankCookieDataFlag == "ApplyDrowsy" then
			if math.random() * 25 <= 5 then
				data.ApplyDrowsy = true
				data.ApplyDrowsyDuration = 60
				data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				data.ApplyMartyr = true
				data.ApplyMartyrDuration = 150 * secondHandMultiplier
				bomb.Flags = bomb.Flags | TearFlags.TEAR_CONFUSION
			end
		elseif prankCookieDataFlag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				data.ApplySewn = true
				data.ApplySewnDuration = 210 * secondHandMultiplier
				bomb.Flags = bomb.Flags | TearFlags.TEAR_PIERCING
			end
		elseif prankCookieDataFlag == "ApplyDoom" then
			data.ApplyDoom = true
			data.ApplyDoomDuration = doomDuration * secondHandMultiplier
			data.ApplyDoomCountdown = doomCountdown
			data.ApplyDoomDamage = player.Damage * doomDamageMulti
			
			data.IsPrankCookieDoom = true
			data.PrankCookieDoomPlayerDamage = player.Damage
		elseif prankCookieDataFlag == "isImpSodaTear" then
			if not data.isImpSodaTear and math.random(25) == 1 then
				bomb.ExplosionDamage = bomb.ExplosionDamage * 5
				data.isImpSodaTear = true
			end
		elseif prankCookieDataFlag == "YinYangOrb" then
			if not data.YinYangOrb and math.random(20) < 5 then
				bomb.ExplosionDamage = bomb.ExplosionDamage * 1.25
				bomb.Flags = bomb.Flags | TearFlags.TEAR_HOMING
				data.YinYangOrb = true
			end
		elseif prankCookieDataFlag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				data.ApplyMultiEuclidean = true
				data.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier
			end
		end
	end
end

--[[function mod:prankCookieOnFireKnife(player, knife, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		local data = knife:GetData()
		data.KnifeColor = chosenEffect.Color

		local dataflag = chosenEffect.DataFlag

		if dataflag == "ApplyBerserk" then
			if math.random(15) == 1 then
				data.ApplyBerserk = true
				data.ApplyBerserkDuration = 180 * secondHandMultiplier
			end
		elseif dataflag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				data.ApplyBleed = true
				data.ApplyBleedDuration = 180 * secondHandMultiplier
				data.ApplyBleedDamage = player.Damage * 0.5
			end
		elseif dataflag == "ApplyBruise" then
			if math.random() * 25 <= 5 then
				data.ApplyBruise = true
				data.ApplyBruiseDuration = 120 * secondHandMultiplier
				data.ApplyBruiseStacks = 1
				data.ApplyBruiseDamagePerStack = 1
			end
		elseif dataflag == "ApplyDrowsy" then
			if math.random() * 25 <= 5 then
				data.ApplyDrowsyDelayTilFired = true
				data.ApplyDrowsyDuration = 60
				data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
			end
		elseif dataflag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				data.ApplyMartyr = true
				data.ApplyMartyrDuration = 150 * secondHandMultiplier
				data.ApplyMartyrConfuse = true
				data.ApplyMartyrConfuseDuration = 120 * secondHandMultiplier
			end
		elseif dataflag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				data.ApplySewn = true
				data.ApplySewnDuration = 210 * secondHandMultiplier
			end
		elseif dataflag == "ApplyDoom" then
			data.ApplyDoomDelayTilFired = true
			data.ApplyDoomDuration = doomDuration * secondHandMultiplier
			data.ApplyDoomCountdown = doomCountdown
			data.ApplyDoomDamage = player.Damage * doomDamageMulti
			
			data.IsPrankCookieDoom = true
			data.PrankCookieDoomPlayerDamage = player.Damage
		elseif dataflag == "isImpSodaTear" then
			if math.random(25) == 1 then
				data.isImpSodaTearDelayTilFired = true
			end
		elseif dataflag == "YinYangOrb" then
			if math.random(20) < 5 then
				data.YinYangOrbDelayTilFired = true
				data.YinYangOrbDamageMultiplier = 1.25
				-- HOMING HOW
			end
		end
	end
end]]--

function mod:prankCookieOnFireLaser(player, laser)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		laser:GetData().PrankCookieLaser = true
	end
end

function mod:prankCookieOnLaserEndpointInit(endpointData, laserData)
	endpointData.PrankCookieLaser = laserData.PrankCookieLaser
end

--[[mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	local player = nil
	if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() then
		player = laser.SpawnerEntity:ToPlayer()
	end

	local data = laser:GetData()

	--Prank Cookie
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		local dataflag = chosenEffect.DataFlag

		if dataflag == "YinYangOrb" then
			if math.random(20) < 5 then
				data.PrankCookieTemporaryHoming = 30
			end
		end
	end

	if data.PrankCookieTemporaryHoming ~= nil and data.PrankCookieTemporaryHoming > 0 then
		data.PrankCookieTemporaryHoming = data.PrankCookieTemporaryHoming - 1
		laser:AddTearFlags(TearFlags.TEAR_HOMING)
	else
		data.PrankCookieTemporaryHoming = nil
		laser:ClearTearFlags(TearFlags.TEAR_HOMING)
	end
end)]]

function mod:prankCookieUpdateLaserColors(laser, data)
	if data.PrankCookieLaser then
		local ticks = #prankCookieLaserColors * 7
		local currentTick = game:GetFrameCount() % ticks

		local colorA = prankCookieLaserColors[math.floor(currentTick / 7) + 1]
		local colorB = prankCookieLaserColors[math.ceil(currentTick / 7) % #prankCookieLaserColors + 1]
		laser.Color = Color.Lerp(colorA, colorB, (currentTick % 7) / 7)
	end
end

local function getPlayerOfSource(source)
	if source == nil then
		return nil
	elseif source.Entity and source.Entity.SpawnerEntity and source.Entity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		return source.Entity.SpawnerEntity:ToPlayer()
	else
		return nil
	end
end

function mod:prankCookieDoomApply(entity, source, data)
	if data.IsPrankCookieDoom then
		if math.random() * 9 <= 2 then
			FiendFolio.AddDoom(entity, source.Entity.SpawnerEntity, data.ApplyDoomDuration, data.ApplyDoomCountdown, data.ApplyDoomDamage)
		elseif entity.HitPoints > data.PrankCookieDoomPlayerDamage * (data.ApplyDoomCountdown + 1) and 
		       not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
		       not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
		then
			local player = getPlayerOfSource(source)
			if player then
				local pdata = player:GetData()
				
				if math.random() * 9 <= 2 ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
					FiendFolio.AddDoom(entity, source.Entity.SpawnerEntity, data.ApplyDoomDuration, data.ApplyDoomCountdown, data.ApplyDoomDamage)
					pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
				else
					pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
				end
			end
		end
	end
end

local lastKnifePrankCookieDataFlag = nil
function mod:prankCookieRollKnifeEffect(player, entity, source, secondHandMultiplier, hasAppliedBruise, hasProccedSleep)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		local dataflag = chosenEffect.DataFlag
		lastKnifePrankCookieDataFlag = dataflag

		if dataflag == "ApplyBerserk" then
			if math.random(15) == 1 then
				FiendFolio.AddBerserk(entity, player, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
			end
		elseif dataflag == "ApplyBruise" and not hasAppliedBruise then
			if math.random() * 25 <= 5 then
				FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
				return true
			end
		elseif dataflag == "ApplyDrowsy" and not hasProccedSleep then
			if math.random() * 25 <= 5 then
				FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
				entity:AddConfusion(source, 120 * secondHandMultiplier, false)
			end
		elseif dataflag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyDoom" then
			if math.random() * 9 <= 2 then
				FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
			elseif entity.HitPoints > player.Damage * (doomCountdown + 1) and 
				   not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
				   not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
			then
				local pdata = player:GetData()
				
				if math.random() * 9 <= 2 ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
					FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
					pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
				else
					pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
				end
			end
		elseif dataflag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
			end
		end
	end
	return false
end

function mod:prankCookieOnKnifeDamage(player, ent, source, currDamage, hasImpSodaProcced)
	local returndata = {}
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		if lastKnifePrankCookieDataFlag == "isImpSodaTear" and not hasImpSodaProcced then
			if math.random(25) == 1 then
				returndata.newDamage = currDamage * 5
				returndata.sendNewDamage = true

				sfx:Play(mod.Sounds.ImpSodaCrit,0.8,0,false,math.random(80,120)/100)
				local crit = Isaac.Spawn(1000, 1734, 0, ent.Position + Vector(0,1), nilvector, source.Entity):ToEffect()
				crit.SpriteOffset = Vector(0, -15)
				crit:Update()
				ent:BloodExplode()
				game:ShakeScreen(6)
				returndata.hasImpSodaProcced = true
			end
		elseif lastKnifePrankCookieDataFlag == "YinYangOrb" then
			if math.random(20) < 5 then
				returndata.newDamage = currDamage * 1.25
				returndata.sendNewDamage = true
			end
		end
	end
	lastKnifePrankCookieDataFlag = nil
	return returndata
end

local lastLaserPrankCookieDataFlag = nil
function mod:prankCookieRollLaserEffect(player, entity, source, secondHandMultiplier, hasAppliedBruise, hasProccedSleep)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		local dataflag = chosenEffect.DataFlag
		lastLaserPrankCookieDataFlag = dataflag

		if dataflag == "ApplyBerserk" then
			if math.random(15) == 1 then
				FiendFolio.AddBerserk(entity, player, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
			end
		elseif dataflag == "ApplyBruise" and not hasAppliedBruise then
			if math.random() * 25 <= 5 then
				FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
				return true
			end
		elseif dataflag == "ApplyDrowsy" and not hasProccedSleep then
			if math.random() * 25 <= 5 then
				FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
				entity:AddConfusion(source, 120 * secondHandMultiplier, false)
			end
		elseif dataflag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyDoom" then
			if math.random() * 9 <= 2 then
				FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
			elseif entity.HitPoints > player.Damage * (doomCountdown + 1) and 
				   not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
				   not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
			then
				local pdata = player:GetData()
				
				if math.random() * 9 <= 2 ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
					FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
					pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
				else
					pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
				end
			end
		elseif dataflag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
			end
		end
	end
	return false
end

function mod:prankCookieOnLaserDamage(player, ent, source, currDamage, hasImpSodaProcced)
	local returndata = {}
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		if lastLaserPrankCookieDataFlag == "isImpSodaTear" and not hasImpSodaProcced then
			if math.random(25) == 1 then
				returndata.newDamage = currDamage * 5
				returndata.sendNewDamage = true

				sfx:Play(mod.Sounds.ImpSodaCrit,0.8,0,false,math.random(80,120)/100)
				local crit = Isaac.Spawn(1000, 1734, 0, ent.Position + Vector(0,1), nilvector, source.Entity):ToEffect()
				crit.SpriteOffset = Vector(0, -15)
				crit:Update()
				ent:BloodExplode()
				game:ShakeScreen(6)
				returndata.hasImpSodaProcced = true
			end
		elseif lastLaserPrankCookieDataFlag == "YinYangOrb" then
			if math.random(20) < 5 then
				returndata.newDamage = currDamage * 1.25
				returndata.sendNewDamage = true
			end
		end
	end
	lastLaserPrankCookieDataFlag = nil
	return returndata
end

function mod:prankCookieRollAquariusEffect(player, creep)
	local prankCookieDataFlag = nil
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		creep:GetData().FFAquariusColor = prankCookieAquariusColors[chosenEffect.DataFlag]
		prankCookieDataFlag = chosenEffect.DataFlag
	end
	return prankCookieDataFlag
end

function mod:prankCookieOnFireAquarius(player, creep, prankCookieDataFlag, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local data = creep:GetData()

		if prankCookieDataFlag == "ApplyBerserk" then
			if math.random(15) == 1 then
				data.ApplyBerserk = true
				data.ApplyBerserkDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				data.ApplyBleed = true
				data.ApplyBleedDuration = 180 * secondHandMultiplier
				data.ApplyBleedDamage = player.Damage * 0.5
			end
		elseif prankCookieDataFlag == "ApplyBruise" then
			if math.random() * 25 <= 5 then
				data.ApplyBruise = true
				data.ApplyBruiseDuration = 120 * secondHandMultiplier
				data.ApplyBruiseStacks = 1
				data.ApplyBruiseDamagePerStack = 1
			end
		elseif prankCookieDataFlag == "ApplyDrowsy" then
			if math.random() * 25 <= 5 then
				data.ApplyDrowsy = true
				data.ApplyDrowsyDuration = 60
				data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				data.ApplyMartyr = true
				data.ApplyMartyrDuration = 150 * secondHandMultiplier
				data.ApplyMartyrConfuse = true
				data.ApplyMartyrConfuseDuration = 120 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				data.ApplySewn = true
				data.ApplySewnDuration = 210 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyDoom" then
			data.ApplyDoom = true
			data.ApplyDoomDuration = doomDuration * secondHandMultiplier
			data.ApplyDoomCountdown = doomCountdown
			data.ApplyDoomDamage = player.Damage * doomDamageMulti
			
			data.IsPrankCookieDoom = true
			data.PrankCookieDoomPlayerDamage = player.Damage
		elseif prankCookieDataFlag == "isImpSodaTear" then
			if not data.isImpSodaTear and math.random(25) == 1 then
				data.isImpSodaTear = true
			end
		elseif prankCookieDataFlag == "YinYangOrb" then
			if not data.YinYangOrb and math.random(20) < 5 then
				data.YinYangOrb = true
				data.YinYangOrbDamageMultiplier = 1.25
				--HOMING HOW
			end
		elseif prankCookieDataFlag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				data.ApplyMultiEuclidean = true
				data.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier
			end
		end
	end
end

function mod:prankCookieRollRocketEffect(player, target)
	local prankCookieDataFlag = nil
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		target:GetData().FFExplosionColor = chosenEffect.Color
		prankCookieDataFlag = chosenEffect.DataFlag
	end
	return prankCookieDataFlag
end

function mod:prankCookieOnFireRocket(player, target, prankCookieDataFlag, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local data = target:GetData()

		if prankCookieDataFlag == "ApplyBerserk" then
			if math.random(15) == 1 then
				data.ApplyBerserk = true
				data.ApplyBerserkDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				data.ApplyBleed = true
				data.ApplyBleedDuration = 180 * secondHandMultiplier
				data.ApplyBleedDamage = player.Damage * 0.5
			end
		elseif prankCookieDataFlag == "ApplyBruise" then
			if math.random() * 25 <= 5 then
				data.ApplyBruise = true
				data.ApplyBruiseDuration = 120 * secondHandMultiplier
				data.ApplyBruiseStacks = 1
				data.ApplyBruiseDamagePerStack = 1
			end
		elseif prankCookieDataFlag == "ApplyDrowsy" then
			if math.random() * 25 <= 5 then
				data.ApplyDrowsy = true
				data.ApplyDrowsyDuration = 60
				data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				data.ApplyMartyr = true
				data.ApplyMartyrDuration = 150 * secondHandMultiplier
				data.ApplyMartyrConfuse = true
				data.ApplyMartyrConfuseDuration = 120 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				data.ApplySewn = true
				data.ApplySewnDuration = 210 * secondHandMultiplier
			end
		elseif prankCookieDataFlag == "ApplyDoom" then
			data.ApplyDoom = true
			data.ApplyDoomDuration = doomDuration * secondHandMultiplier
			data.ApplyDoomCountdown = doomCountdown
			data.ApplyDoomDamage = player.Damage * doomDamageMulti
			
			data.IsPrankCookieDoom = true
			data.PrankCookieDoomPlayerDamage = player.Damage
		elseif prankCookieDataFlag == "isImpSodaTear" then
			if not data.isImpSodaTear and math.random(25) == 1 then
				data.isImpSodaTear = true
			end
		elseif prankCookieDataFlag == "YinYangOrb" then
			if not data.YinYangOrb and math.random(20) < 5 then
				data.YinYangOrb = true
				data.YinYangOrbDamageMultiplier = 1.25
				--HOMING HOW
			end
		elseif prankCookieDataFlag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				data.ApplyMultiEuclidean = true
				data.ApplyMultiEuclideanDuration = 180 * secondHandMultiplier
			end
		end
	end
end

local lastDarkArtsPrankCookieDataFlag = nil
function mod:prankCookieRollDarkArtsEffect(player, entity, source, secondHandMultiplier, hasAppliedBruise, hasProccedSleep)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		local dataflag = chosenEffect.DataFlag
		lastDarkArtsPrankCookieDataFlag = dataflag

		if dataflag == "ApplyBerserk" then
			if math.random(15) == 1 then
				FiendFolio.AddBerserk(entity, player, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
			end
		elseif dataflag == "ApplyBruise" and not hasAppliedBruise then
			if math.random() * 25 <= 5 then
				FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
				return true
			end
		elseif dataflag == "ApplyDrowsy" and not hasProccedSleep then
			if math.random() * 25 <= 5 then
				FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
				entity:AddConfusion(source, 120 * secondHandMultiplier, false)
			end
		elseif dataflag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyDoom" then
			if math.random() * 9 <= 2 then
				FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
			elseif entity.HitPoints > player.Damage * (doomCountdown + 1) and 
				   not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
				   not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
			then
				local pdata = player:GetData()
				
				if math.random() * 9 <= 2 ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
					FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
					pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
				else
					pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
				end
			end
		elseif dataflag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
			end
		end
	end
	return false
end

function mod:prankCookieOnDarkArtsDamage(player, ent, source, hasImpSodaProcced)
	local returndata = {}
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE) then
		if lastDarkArtsPrankCookieDataFlag == "isImpSodaTear" and not hasImpSodaProcced then
			if math.random(25) == 1 then
				returndata.damageMulti = 5

				sfx:Play(mod.Sounds.ImpSodaCrit,0.8,0,false,math.random(80,120)/100)
				local crit = Isaac.Spawn(1000, 1734, 0, ent.Position + Vector(0,1), nilvector, source.Entity):ToEffect()
				crit.SpriteOffset = Vector(0, -15)
				crit:Update()
				ent:BloodExplode()
				game:ShakeScreen(6)
				returndata.hasImpSodaProcced = true
			end
		elseif lastDarkArtsPrankCookieDataFlag == "YinYangOrb" then
			if math.random(20) < 5 then
				returndata.damageMulti = 1.25
			end
		end
	end
	lastDarkArtsPrankCookieDataFlag = nil
	return returndata
end

local lastLocustPrankCookieDataFlag = nil
function mod:prankCookieRollLocustEffect(player, entity, source, secondHandMultiplier, hasAppliedBruise, hasProccedSleep)
	if source.Entity.SubType == FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE then
		local totalWeight = 0
		for i = 1, #prankCookieEffects do
			totalWeight = totalWeight + prankCookieEffects[i].Weight
		end

		local rand = math.random() * totalWeight
		local chosenEffect = nil
		for i = 1, #prankCookieEffects do
			if rand <= prankCookieEffects[i].Weight then
				chosenEffect = prankCookieEffects[i]
				break
			end
			rand = rand - prankCookieEffects[i].Weight
		end
		if chosenEffect == nil then
			chosenEffect = prankCookieEffects[#prankCookieEffects]
		end

		local dataflag = chosenEffect.DataFlag
		lastLocustPrankCookieDataFlag = dataflag

		if dataflag == "ApplyBerserk" then
			if math.random(15) == 1 then
				FiendFolio.AddBerserk(entity, player, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyBleed" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddBleed(entity, player, 180 * secondHandMultiplier, player.Damage * 0.5)
			end
		elseif dataflag == "ApplyBruise" and not hasAppliedBruise then
			if math.random() * 25 <= 5 then
				FiendFolio.AddBruise(entity, player, 120 * secondHandMultiplier, 1, 1)
				return true
			end
		elseif dataflag == "ApplyDrowsy" and not hasProccedSleep then
			if math.random() * 25 <= 5 then
				FiendFolio.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyMartyr" then
			if math.random() * 30 <= 5 then
				FiendFolio.MarkForMartyrDeath(entity, player, 150 * secondHandMultiplier, false)
				entity:AddConfusion(source, 120 * secondHandMultiplier, false)
			end
		elseif dataflag == "ApplySewn" then
			if math.random() * 50 <= 20 then
				FiendFolio.AddSewn(entity, player, 210 * secondHandMultiplier)
			end
		elseif dataflag == "ApplyDoom" then
			if math.random() * 9 <= 2 then
				FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
			elseif entity.HitPoints > player.Damage * (doomCountdown + 1) and 
				   not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
				   not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
			then
				local pdata = player:GetData()
				
				if math.random() * 9 <= 2 ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
					FiendFolio.AddDoom(entity, player, doomDuration * secondHandMultiplier, doomCountdown, player.Damage * doomDamageMulti)
					pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
				else
					pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
				end
			end
		elseif dataflag == "ApplyMultiEuclidean" then
			if math.random() * 8 <= 2 then
				FiendFolio.AddMultiEuclidean(entity, player, 180 * secondHandMultiplier)
			end
		end
	end
	return false
end

function mod:prankCookieOnLocustDamage(player, ent, source, hasImpSodaProcced)
	local returndata = {}
	if source.Entity.SubType == FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE then
		if lastLocustPrankCookieDataFlag == "isImpSodaTear" and not hasImpSodaProcced then
			if math.random(25) == 1 then
				returndata.damageMulti = 5

				sfx:Play(mod.Sounds.ImpSodaCrit,0.8,0,false,math.random(80,120)/100)
				local crit = Isaac.Spawn(1000, 1734, 0, ent.Position + Vector(0,1), nilvector, source.Entity):ToEffect()
				crit.SpriteOffset = Vector(0, -15)
				crit:Update()
				ent:BloodExplode()
				game:ShakeScreen(6)
				returndata.hasImpSodaProcced = true
			end
		elseif lastLocustPrankCookieDataFlag == "YinYangOrb" then
			if math.random(20) < 5 then
				returndata.damageMulti = 1.25
			end
		end
	end
	lastLocustPrankCookieDataFlag = nil
	return returndata
end