-- Toy Piano --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local duration = 180
local countdown = 3
local damageMulti = 5

function mod:updateToyPianoTearLaserColor(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		local tearcolor = Color(0.30, 0.30, 0.30, 1.0, 10/255, -25/255, -25/255)
		tearcolor:SetColorize(0.75, 0.5, 0.5, 1.0)
		player.TearColor = tearcolor
			
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(1.0, 0.1, 0.1, 1)
		player.LaserColor = lasercolor
	end
end

function mod:toyPianoOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		local data = tear:GetData()
		
		data.ApplyDoom = true
		data.ApplyDoomDuration = duration * secondHandMultiplier
		data.ApplyDoomCountdown = countdown
		data.ApplyDoomDamage = player.Damage * damageMulti
		
		data.IsToyPiano = true
		data.ToyPianoPlayerDamage = player.Damage
		data.ToyPianoPlayerLuck = player.Luck
	end
end

function mod:toyPianoOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		local data = bomb:GetData()
		
		data.ApplyDoom = true
		data.ApplyDoomDuration = duration * secondHandMultiplier
		data.ApplyDoomCountdown = countdown
		data.ApplyDoomDamage = player.Damage * damageMulti
		
		data.IsToyPiano = true
		data.ToyPianoPlayerDamage = player.Damage
		data.ToyPianoPlayerLuck = player.Luck
	end
end

--[[function mod:toyPianoOnFireKnife(player, knife, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		local data = knife:GetData()
		
		data.ApplyDoomDelayTilFired = true
		data.ApplyDoomDuration = duration * secondHandMultiplier
		data.ApplyDoomCountdown = countdown
		data.ApplyDoomDamage = player.Damage * damageMulti
		
		data.IsToyPiano = true
		data.ToyPianoPlayerDamage = player.Damage
		data.ToyPianoPlayerLuck = player.Luck
	end
end]]--

function mod:toyPianoOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		if math.random() * 9 <= 2 + player.Luck * 2.5 / 12 then
			FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
		elseif entity.HitPoints > player.Damage * (countdown + 1) and 
		       not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
		       not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
		then
			local pdata = player:GetData()
			
			--print(pdata.ToyPianoPseudoRandomCounter, (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3))
			
			if math.random() * 9 <= (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
				--print("SUCCESS")
				FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
				pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
			else
				--print("FAILURE")
				pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
			end
		end
	end
end

--function mod:toyPianoOnFireLaser(player, laser)
--	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
--		laser:GetData().ToyPianoLaser = true
--	end
--end

--function mod:toyPianoOnLaserEndpointInit(endpointData, laserData)
--	endpointData.ToyPianoLaser = laserData.ToyPianoLaser
--end

--function mod:toyPianoUpdateLaserColors(laser, data)
--	if data.ToyPianoLaser then
--		local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
--		color:SetColorize(1.0, 0.1, 0.1, 1)
--		laser.Color = color
--	end
--end

local function getPlayerOfSource(source)
	if source == nil then
		return nil
	elseif source.Entity and source.Entity.SpawnerEntity and source.Entity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		return source.Entity.SpawnerEntity:ToPlayer()
	else
		return nil
	end
end

function mod:toyPianoOnApply(entity, source, data)
	if data.IsToyPiano then
		if math.random() * 9 <= 2 + data.ToyPianoPlayerLuck * 2.5 / 12 then
			FiendFolio.AddDoom(entity, source.Entity.SpawnerEntity, data.ApplyDoomDuration, data.ApplyDoomCountdown, data.ApplyDoomDamage)
		elseif entity.HitPoints > data.ToyPianoPlayerDamage * (data.ApplyDoomCountdown + 1) and 
		       not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
		       not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
		then
			local player = getPlayerOfSource(source)
			if player then
				local pdata = player:GetData()
				
				--print(pdata.ToyPianoPseudoRandomCounter, (2 + data.ToyPianoPlayerLuck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3))
				
				if math.random() * 9 <= (2 + data.ToyPianoPlayerLuck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
					--print("SUCCESS")
					FiendFolio.AddDoom(entity, source.Entity.SpawnerEntity, data.ApplyDoomDuration, data.ApplyDoomCountdown, data.ApplyDoomDamage)
					pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
				else
					--print("FAILURE")
					pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
				end
			end
		end
	end
end

function mod:toyPianoOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		if math.random() * 9 <= 2 + player.Luck * 2.5 / 12 then
			FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
		elseif entity.HitPoints > player.Damage * (countdown + 1) and 
		       not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
		       not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
		then
			local pdata = player:GetData()
			
			--print(pdata.ToyPianoPseudoRandomCounter, (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3))
			
			if math.random() * 9 <= (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
				--print("SUCCESS")
				FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
				pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
			else
				--print("FAILURE")
				pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
			end
		end
	end
end

function mod:toyPianoOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		local data = creep:GetData()

		data.ApplyDoom = true
		data.ApplyDoomDuration = duration * secondHandMultiplier
		data.ApplyDoomCountdown = countdown
		data.ApplyDoomDamage = player.Damage * damageMulti
		
		data.IsToyPiano = true
		data.ToyPianoPlayerDamage = player.Damage
		data.ToyPianoPlayerLuck = player.Luck
	end
end

function mod:toyPianoOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		local data = target:GetData()

		data.ApplyDoom = true
		data.ApplyDoomDuration = duration * secondHandMultiplier
		data.ApplyDoomCountdown = countdown
		data.ApplyDoomDamage = player.Damage * damageMulti
		
		data.IsToyPiano = true
		data.ToyPianoPlayerDamage = player.Damage
		data.ToyPianoPlayerLuck = player.Luck
	end
end

function mod:toyPianoOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO) then
		if math.random() * 9 <= 2 + player.Luck * 2.5 / 12 then
			FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
		elseif entity.HitPoints > player.Damage * (countdown + 1) and 
		       not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
		       not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
		then
			local pdata = player:GetData()
			
			--print(pdata.ToyPianoPseudoRandomCounter, (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3))
			
			if math.random() * 9 <= (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
				--print("SUCCESS")
				FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
				pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
			else
				--print("FAILURE")
				pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
			end
		end
	end
end

function mod:toyPianoOnLocustDamage(player, locust, entity, secondHandMultiplier)
	if locust.SubType == FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO then
		if math.random() * 9 <= 2 + player.Luck * 2.5 / 12 then
			FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
		elseif entity.HitPoints > player.Damage * (countdown + 1) and 
		       not (entity:ToNPC() and entity:ToNPC():IsBoss()) and 
		       not (entity:GetData().FFDoomDuration ~= nil and entity:GetData().FFDoomDuration > 0)
		then
			local pdata = player:GetData()
			
			--print(pdata.ToyPianoPseudoRandomCounter, (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3))
			
			if math.random() * 9 <= (2 + player.Luck * 2.5 / 12) ^ ((pdata.ToyPianoPseudoRandomCounter or 3) / 3) then
				--print("SUCCESS")
				FiendFolio.AddDoom(entity, player, duration * secondHandMultiplier, countdown, player.Damage * damageMulti)
				pdata.ToyPianoPseudoRandomCounter = math.min((pdata.ToyPianoPseudoRandomCounter or 3) - 1, 3)
			else
				--print("FAILURE")
				pdata.ToyPianoPseudoRandomCounter = math.max((pdata.ToyPianoPseudoRandomCounter or 3) + 1, 3)
			end
		end
	end
end