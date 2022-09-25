local mod = FiendFolio

local eColor = Color(0.88,0.95,0,1,0.62,0.93,0.14)
eColor:SetColorize(0.65,0.73,0.4,0.55)

mod.electrumSynergies = {
	[CollectibleType.COLLECTIBLE_TAMMYS_HEAD] = function(player)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ELECTRUM)
		local rangle = rng:RandomInt(360)
		for i=1,10 do
			local laser = EntityLaser.ShootAngle(2, player.Position, rangle+36*i, 1, Vector.Zero, player)
			laser.Color = eColor
			laser.CollisionDamage = player.Damage+25
		end
	end,
	[CollectibleType.COLLECTIBLE_KAMIKAZE] = function(player, mult)
		local laser = player:FireTechXLaser(player.Position, player.Velocity, 80, player, mult)
		laser.Timeout = 10
		laser.Color = eColor
	end,
	[CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = function()
		--IDK, not sure how to manage actives that can be lifted.
	end,
	[CollectibleType.COLLECTIBLE_TELEPORT] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			mod:electrumShock(player, mult, rng, itemConfig)
		end, 3)
	end,
	[CollectibleType.COLLECTIBLE_RAZOR_BLADE] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)
	end,
	[CollectibleType.COLLECTIBLE_GUPPYS_PAW] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)
	end,
	[CollectibleType.COLLECTIBLE_IV_BAG] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)
	end,
	[CollectibleType.COLLECTIBLE_NOTCHED_AXE] = function()
	end,
	[CollectibleType.COLLECTIBLE_CANDLE] = function()
	end,
	[CollectibleType.COLLECTIBLE_PORTABLE_SLOT] = function(player, mult, rng, itemConfig)
		if player:GetNumCoins() > 0 then
			mod:electrumShock(player, mult, rng, itemConfig, true)
		end
	end,
	[CollectibleType.COLLECTIBLE_BLOOD_RIGHTS] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)
	end,
	[CollectibleType.COLLECTIBLE_MAGIC_FINGERS] = function(player, mult, rng, itemConfig)
		if player:GetNumCoins() > 0 then
			mod:electrumShock(player, mult, rng, itemConfig, true)
		end
	end,
	[CollectibleType.COLLECTIBLE_RED_CANDLE] = function()
	end,
	[CollectibleType.COLLECTIBLE_BOOMERANG] = function()
	end,
	[CollectibleType.COLLECTIBLE_GLASS_CANNON] = function()
	end,
	[CollectibleType.COLLECTIBLE_FRIEND_BALL] = function()
	end,
	[CollectibleType.COLLECTIBLE_POTATO_PEELER] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)
	end,
	[CollectibleType.COLLECTIBLE_MOMS_BRACELET] = function()
	end,
	
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng)
	local player = mod:GetPlayerUsingItem()
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ELECTRUM) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ELECTRUM)
		local itemConfig = Isaac:GetItemConfig():GetCollectible(item)
		if mod.electrumSynergies[item] then
			mod.electrumSynergies[item](player, mult, rng, itemConfig)
		else
			mod:electrumShock(player, mult, rng, itemConfig)
		end
	end
end)

function mod:electrumShock(player, mult, rng, itemConfig, bypass)
	local charges = itemConfig.MaxCharges
	if charges > 0 or bypass then
		local special = false
		if itemConfig.ChargeType > 0 then
			special = true
		end
		
		local enemies = {}
		for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
				table.insert(enemies, enemy)
			end
		end
		if #enemies > 0 then
			if #enemies > charges then
				local chosen = mod:getSeveralDifferentNumbers(charges, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-player.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(2, player.Position, angle, 1, Vector.Zero, player)
				if special or bypass then
					laser.CollisionDamage = player.Damage
				else
					laser.CollisionDamage = player.Damage+charges^2
				end
				laser.MaxDistance = enemy.Position:Distance(player.Position)
				laser.DisableFollowParent = true
				laser.Color = eColor
			end
		end
	end
end