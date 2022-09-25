local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

mod.AddTrinketPickupCallback(
function(player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
		player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_C_SECTION))
	end
end, 
function(player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
		player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_C_SECTION))
	end
end, FiendFolio.ITEM.ROCK.CALZONE_GEODE, nil)

function mod:calzoneGeodeOnFireTear(player, tear, secondHandMultiplier, isLudo, ignorePlayerEffects)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CALZONE_GEODE) and not ignorePlayerEffects	then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local chance = math.min(50,5+5*mult+player.Luck)
		if mod.HasTwoGeodes(player) then
			chance = chance+10
		end
		if rng:RandomInt(100) < chance then
			local dir = nil
			if isLudo and not game:GetRoom():IsClear() then
				dir = tear.Position - player.Position
			elseif not isLudo and tear.CanTriggerStreakEnd then
				dir = tear.Velocity
			end
			if dir ~= nil then mod:fireChubberTear(player, tear, dir, secondHandMultiplier, isLudo) end
		end
	end
end

function mod:calzoneGeodeOnFireLaser(player, laser)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CALZONE_GEODE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local chance = math.min(50,5+5*mult+player.Luck)
		if mod.HasTwoGeodes(player) then
			chance = chance+10
		end
		if rng:RandomInt(100) < chance then
			FiendFolio.scheduleForUpdate(function()
				local vec = Vector(10, 0)
				if laser.Velocity:Length() > 0 then
					vec = laser.Velocity:Resized(10)
				end

				mod:fireChubberTear(player, nil, vec:Rotated(laser.AngleDegrees), nil, nil, true)
			end, 1)
		end
	end
end

function mod:calzoneGeodeOnFireKnife(player, knife)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CALZONE_GEODE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local chance = math.min(50,5+5*mult+player.Luck)
		if mod.HasTwoGeodes(player) then
			chance = chance+10
		end
		if rng:RandomInt(100) < chance then
			mod:fireChubberTear(player, nil, Vector(1,0):Rotated(knife.Rotation), nil, nil, true)
		end
	end
end

function mod:calzoneGeodeOnFireBomb(player, bomb)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CALZONE_GEODE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CALZONE_GEODE)
		local chance = math.min(50,5+5*mult+player.Luck)
		if mod.HasTwoGeodes(player) then
			chance = chance+10
		end
		if rng:RandomInt(100) < chance then
			mod:fireChubberTear(player, nil, bomb.Velocity, nil, nil, true)
		end
	end
end

function mod:fireChubberTear(player, tear, dir, secondHandMultiplier, isLudo, spawnNew)
	if spawnNew then
		local tear = player:FireTear(player.Position, dir:Resized(18), false, true, false, player, 1)
		tear:ChangeVariant(mod.FF.ChubberTear.Var)
		tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_BAIT)
		tear:GetData().chubberPlayer = player
		sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 0.4, 0, false, 1.4)
		for i=1,2 do
			Isaac.Spawn(1000, 5, 0, player.Position, dir:Resized(math.random(5,9)):Rotated(math.random(-10,10)), player)
		end
	else
		if isLudo then
			tear = player:FireTear(player.Position, dir:Resized(18), false, true, false, player, 1)
		end
		tear:ChangeVariant(mod.FF.ChubberTear.Var)
		tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_BAIT)
		tear:GetData().chubberPlayer = player
		tear.Velocity = dir:Resized(18)
		sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 0.4, 0, false, 1.4)
		for i=1,2 do
			Isaac.Spawn(1000, 5, 0, player.Position, dir:Resized(math.random(5,9)):Rotated(math.random(-10,10)), player)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if tear.Variant ~= mod.FF.ChubberTear.Var then return end
	
	local sprite = tear:GetSprite()
	local data = tear:GetData()
	if math.abs(tear.Velocity.X) > math.abs(tear.Velocity.Y) then
		if tear.Velocity.X > 0 then
			tear.FlipX = false
		else
			tear.FlipX = true
		end
		mod:spritePlay(sprite, "Side")
	else
		if tear.Velocity.Y > 0 then
			mod:spritePlay(sprite, "Down")
		else
			mod:spritePlay(sprite, "Up")
		end
	end
	
	tear.FallingSpeed = 0
	tear.FallingAcceleration = -0.05
	tear.Height = -5
	
	if tear.FrameCount > 18 and data.chubberPlayer then
		tear.Velocity = mod:Lerp(tear.Velocity, (data.chubberPlayer.Position-tear.Position):Resized(18), 0.3)
		if tear.Position:Distance(data.chubberPlayer.Position) < 10 then
			tear:Remove()
		end
	elseif tear.FrameCount > 8 and data.chubberPlayer then
		tear.Velocity = mod:Lerp(tear.Velocity, (data.chubberPlayer.Position-tear.Position):Resized(18), 0.05)
	end

	if not data.chubberPlayer then
		tear:Die()
	end
end)