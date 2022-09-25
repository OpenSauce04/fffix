-- Model Rocket oh god oh fuck not again nightmare nightmare nightmare --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local ACCEL_MAX_MULTIPLIER = 2 -- The maximum multiplier that can applied to velocity and falling acceleration
local ACCEL_MAX_TICK = 15 -- The accelerate tick at which the accelerate multiplier reaches maximum
local ACCEL_ROOT = 2 -- The root of the multiplier; can be thought of as the tick difference between a multiplier with the value of 1 and the maximum multiplier
local ACCEL_DAMAGE_BONUS_BASE = 1.25 -- The base damage of accelerate bonus damage

local function determineMultiplier(currentTick)
  -- Returns the FLAG_ACCEL multiplier for the given FLAG_ACCEL logic tick

  return ACCEL_MAX_MULTIPLIER ^ ((currentTick - (ACCEL_MAX_TICK - ACCEL_ROOT)) / ACCEL_ROOT)
end

function mod.getCurrentModelRocketMultiplier(tear)
	local data = tear:GetData()
	if not data.ModelRocketTear then
		return 1
	else
		return math.min(determineMultiplier(data.ModelRocketFrame), ACCEL_MAX_MULTIPLIER) / ACCEL_MAX_MULTIPLIER
	end
end

local function reverseFallingSpeed(speed, accel)
  -- Reverses the falling speed based upon a given falling acceleration

  return (speed - 0.1 - accel) / 0.9
end

local function forwardFallingSpeed(speed, accel)
  -- Forwards the falling speed based upon a given falling acceleration

  return 0.1 + accel + 0.9 * speed
end

local divlog = math.log(0.9)
local function getAddedHeightAtPeak(initialFallingSpeed, fallingAccel)
	local peakAtTick = math.floor(math.log(1 - 1 / ((((fallingAccel + 0.1) * 10) / initialFallingSpeed / -1) + 1)) / divlog)
	local exptick = (9/10) ^ peakAtTick - 1
	return -9 * initialFallingSpeed * exptick + (9 * exptick + peakAtTick) * ((0.1 + fallingAccel) * 10)
end

function mod:updateModelRocketTear(ent)
	local tear = ent:ToTear()
	local data = tear:GetData()
	
	if data.ModelRocketTear then
		if tear.StickTarget == nil then
			data.ModelRocketDisableDamageOnStick = nil
		end
		
		if data.ModelRocketDisableMovementOnStick or
		   tear.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO
		then
			return
		end
	
		if data.LastModelRocketUpdate ~= game:GetFrameCount() then
			if data.ModelRocketFrame == nil then
				if tear.FallingAcceleration > -0.1 and reverseFallingSpeed(tear.FallingSpeed, tear.FallingAcceleration) < 0 then
					data.ModelRocketFramesToPeak = ACCEL_MAX_TICK
					data.ModelRocketPeakAddedHeight = getAddedHeightAtPeak(reverseFallingSpeed(tear.FallingSpeed, tear.FallingAcceleration), 
																		   tear.FallingAcceleration)
					data.ModelRocketFallingMultiplier = (tear.SpawnerEntity and tear.SpawnerEntity:GetData().ModelRocketArcingTearsFallingSpeedModifier) or 1
				else
					data.ModelRocketFramesToPeak = 0
					data.ModelRocketFallingMultiplier = 1
				end
				
				data.ModelRocketFrame = 0
			else
				data.ModelRocketFrame = data.ModelRocketFrame + 1
			end
			local multiplier = math.min(determineMultiplier(data.ModelRocketFrame), ACCEL_MAX_MULTIPLIER) / ACCEL_MAX_MULTIPLIER
			
			tear.Position = tear.Position - tear.Velocity
			if data.ModelRocketFrame <= ACCEL_MAX_TICK and data.ModelRocketPop then
				tear.Velocity = tear.Velocity - (tear.Velocity * 0.04 * multiplier)
			end
			tear.Velocity = tear.Velocity * multiplier
			tear.Position = tear.Position + tear.Velocity
			
			if data.ModelRocketFrame >= ACCEL_MAX_TICK then
				if data.ModelRocketPop then
					tear.TearFlags = tear.TearFlags | TearFlags.TEAR_POP
					data.ModelRocketPop = nil
					
					tear.FallingAcceleration = data.ModelRocketInitialFallingAcceleration
				end
			elseif tear.TearFlags & TearFlags.TEAR_POP == TearFlags.TEAR_POP then
				tear.TearFlags = tear.TearFlags ~ TearFlags.TEAR_POP
				data.ModelRocketPop = true
				
				data.ModelRocketInitialFallingAcceleration = tear.FallingAcceleration
				tear.FallingSpeed = 0
				tear.FallingAcceleration = -0.1
			end
			
			if data.ModelRocketFrame >= ACCEL_MAX_TICK - 1 then
				if data.ModelRocketBrainWorm then
					tear.TearFlags = tear.TearFlags | TearFlags.TEAR_TURN_HORIZONTAL
					data.ModelRocketBrainWorm = nil
				end
			end
			
			if not data.ModelRocketPop and
			   tear.TearFlags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP and
			   tear.TearFlags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB
			then
				if data.ModelRocketFramesToPeak and data.ModelRocketFramesToPeak > 0 then
					tear.Height = tear.Height - tear.FallingSpeed
					tear.FallingSpeed = data.ModelRocketPeakAddedHeight / 120 * data.ModelRocketFramesToPeak
					tear.Height = tear.Height + tear.FallingSpeed
					
					data.ModelRocketFramesToPeak = data.ModelRocketFramesToPeak - 1
				else
					data.IntendedFallingSpeed = tear.FallingSpeed
					tear.Height = tear.Height - tear.FallingSpeed
					data.ModelRocketFallingMultiplier = data.ModelRocketFallingMultiplier or 1
					tear.FallingSpeed = tear.FallingSpeed * multiplier * data.ModelRocketFallingMultiplier
					if tear.Height + tear.FallingSpeed > 0 then
						tear.FallingSpeed = -1 * tear.Height
						tear.Height = 0
						data.IntendedFallingSpeed = nil
					else
						tear.Height = tear.Height + tear.FallingSpeed
					end
				end
			end
			
			data.LastModelRocketUpdate = game:GetFrameCount()
		end
	end
end

local function revertModelRocketTear(ent)
	local tear = ent:ToTear()
	local data = tear:GetData()
	
	if data.ModelRocketTear then
		if data.ModelRocketDisableMovementOnStick or
		   tear.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO
		then
			return
		end
		
		if data.LastModelRocketReversion ~= game:GetFrameCount() then
			data.ModelRocketFrame = data.ModelRocketFrame or 0
			local multiplier = math.min(determineMultiplier(data.ModelRocketFrame), ACCEL_MAX_MULTIPLIER) / ACCEL_MAX_MULTIPLIER
			
			tear.Velocity = tear.Velocity / multiplier
			
			if data.IntendedFallingSpeed then
				tear.FallingSpeed = data.IntendedFallingSpeed
				local oldFallSpeed = reverseFallingSpeed(tear.FallingSpeed, tear.FallingAcceleration)
				data.ModelRocketFallingMultiplier = data.ModelRocketFallingMultiplier or 1
				tear.FallingSpeed = (tear.FallingSpeed - oldFallSpeed) * multiplier * data.ModelRocketFallingMultiplier + oldFallSpeed
			end
			
			data.LastModelRocketReversion = game:GetFrameCount()
		end
	end
end

--[[function mod:handleOddFrameTears(tear)
	if Isaac.GetFrameCount() % 2 == 1 then
		mod:updateModelRocketTear(tear)
	end
end]]--

--[[function mod:updateModelRocketTears()
	local tears = Isaac.FindByType(EntityType.ENTITY_TEAR)
	
	for _,tear in ipairs(tears) do
		updateModelRocketTear(tear)
	end
end]]--

function mod:revertModelRocketTears()
	if Isaac.GetFrameCount() % 2 == 0 then
		local tears = Isaac.FindByType(EntityType.ENTITY_TEAR)
		
		for _,tear in ipairs(tears) do
			revertModelRocketTear(tear)
		end
	end
end

function mod:updateModelRocketStats(player, flag)
	if flag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MODEL_ROCKET) then
            player.ShotSpeed = player.ShotSpeed * ACCEL_MAX_MULTIPLIER
        end
	end
	
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MODEL_ROCKET) and (flag == CacheFlag.CACHE_SHOTSPEED or flag == CacheFlag.CACHE_RANGE) then
		player:GetData().FFUpdatedRange = true
	end
end

local risingElapsedSteps = ACCEL_MAX_MULTIPLIER ^ (-1 * ACCEL_MAX_TICK / ACCEL_ROOT) * (ACCEL_MAX_MULTIPLIER ^ (ACCEL_MAX_TICK / ACCEL_ROOT) - 1) / (ACCEL_MAX_MULTIPLIER ^ (1 / ACCEL_ROOT) - 1)
function mod:modelRocketRecalculateTearFallingSpeedModifier(player)
	player:GetData().FFUpdatedRange = nil
	player:GetData().ModelRocketArcingTearsFallingSpeedModifier = nil
	
	local fallingSpeed = -1 * player.TearFallingSpeed
	local fallingAccel = player.TearFallingAcceleration
	
	if fallingAccel > -0.1 and fallingSpeed < 0 then
		local desiredsteps = 0
		local desiredheight = player.TearHeight
		local desiredfallingspeed = fallingSpeed
		while (desiredheight < -5 and desiredsteps < 1000) do
			desiredfallingspeed = forwardFallingSpeed(desiredfallingspeed, fallingAccel)
			desiredheight = desiredheight + desiredfallingspeed
			desiredsteps = desiredsteps + 1
		end
		if desiredsteps >= 1000 or desiredsteps == 0 then
			return
		end
		
		local actualsteps = 0
		local actualheight = player.TearHeight + getAddedHeightAtPeak(fallingSpeed, fallingAccel)
		local actualfallingspeed = 0
		while (actualheight < -5 and actualsteps < 1000) do
			actualfallingspeed = forwardFallingSpeed(actualfallingspeed, fallingAccel)
			actualheight = actualheight + actualfallingspeed
			actualsteps = actualsteps + 1
		end
		if actualsteps >= 1000 or actualsteps == 0 then
			return
		end
		
		player:GetData().ModelRocketArcingTearsFallingSpeedModifier = actualsteps / (desiredsteps - risingElapsedSteps)
		--print(desiredsteps, actualsteps, player:GetData().ModelRocketArcingTearsFallingSpeedModifier)
	end
end

function mod:modelRocketOnTearInit(tear)
	if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_PLAYER and tear.SpawnerEntity:GetData().FFUpdatedRange then
		mod:modelRocketRecalculateTearFallingSpeedModifier(tear.SpawnerEntity:ToPlayer())
	end
end

function mod:modelRocketPostPlayerUpdate(player)
	if player:GetData().FFUpdatedRange then
		mod:modelRocketRecalculateTearFallingSpeedModifier(player)
	end
end

function mod:AddModelRocketCallbacks()
	mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.updateModelRocketTear)
	mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.updateModelRocketTear)
	mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.revertModelRocketTears)
	mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.modelRocketOnTearInit)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.modelRocketPostPlayerUpdate)
	mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.modelRocketPostPlayerUpdate)
end

function mod:modelRocketOnFireTear(player, tear)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MODEL_ROCKET) then
		local data = tear:GetData()
		
		data.ModelRocketTear = true
		tear.Mass = tear.Mass / 4
		mod:changeTearVariant(tear, TearVariant.MODEL_ROCKET)
		
		if tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO then
			if tear.TearFlags & TearFlags.TEAR_POP == TearFlags.TEAR_POP then
				tear.TearFlags = tear.TearFlags ~ TearFlags.TEAR_POP
				data.ModelRocketPop = true
				
				data.ModelRocketInitialFallingAcceleration = tear.FallingAcceleration
				tear.FallingSpeed = 0
				tear.FallingAcceleration = -0.1
			end
			
			if tear.TearFlags & TearFlags.TEAR_TURN_HORIZONTAL == TearFlags.TEAR_TURN_HORIZONTAL then
				tear.TearFlags = tear.TearFlags ~ TearFlags.TEAR_TURN_HORIZONTAL
				data.ModelRocketBrainWorm = true
			end
		end
	end
end

function mod:updateModelRocketRange(player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.MODEL_ROCKET) then
        player.TearRange = player.TearRange + 60
    end
end

function mod:modelRocketOnTearDamage(source, newDamage)
	local returndata = {}
	if source.Entity and source.Entity:GetData().ModelRocketTear then
		local tear = source.Entity:ToTear()
		local data = source.Entity:GetData()
	
		if not data.ModelRocketDisableDamageOnStick then
			returndata.newDamage = newDamage + source.Entity.Velocity:Length() / 10 * ACCEL_DAMAGE_BONUS_BASE
			returndata.sendNewDamage = true
		
			if tear.StickTarget ~= nil then
				data.ModelRocketDisableMovementOnStick = true
				data.ModelRocketDisableDamageOnStick = true
			end
		end
	end
	return returndata
end
