local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local robotRockLaserColors = {
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
	Color(2, 2, 2, 1.0, 0/255, 0/255, 0/255),
}

robotRockLaserColors[1]:SetColorize(1, 0.2, 0.24, 1)
robotRockLaserColors[2]:SetColorize(1.1, 0.6, 0.2, 1)
robotRockLaserColors[3]:SetColorize(1.1, 1.1, 0.2, 1)
robotRockLaserColors[4]:SetColorize(0.24, 1, 0.26, 1)
robotRockLaserColors[5]:SetColorize(0.22, 0.9, 1, 1)
robotRockLaserColors[6]:SetColorize(0.2, 0.29, 1, 1)
robotRockLaserColors[7]:SetColorize(0.64, 0.2, 1, 1)
robotRockLaserColors[8]:SetColorize(1.05, 0.2, 1, 1)

function mod:robotRockUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROBOT_ROCK) then
		local queuedItem = player.QueuedItem
		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.ROBOT_ROCK then
			if not data.robotRockHeld then
				sfx:Play(mod.Sounds.RobotRock, 1, 0, false, 1)
				data.robotRockLasers = nil
				data.robotRockHeld = true
			end
		else
			data.robotRockHeld = nil
		end
	
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROBOT_ROCK)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROBOT_ROCK)
        local numLasers = 2
        if mult < 1 then
            numLasers = 1
        elseif mult >= 2 then
            numLasers = math.ceil(mult)
        end

		if data.robotRockHeld or player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
		else
			if not data.robotRockLasers or #data.robotRockLasers ~= numLasers then
				data.robotRockLasers = {}


				for i = 1, numLasers do
					data.robotRockLasers[i] = {player:FireTechLaser(player.Position, 0, Vector(0,1):Rotated(360/i), false, false, player, 0.2), i}
				end

				for num, lasera in ipairs(data.robotRockLasers) do
					local laser = lasera[1]
					local num = lasera[2]
					laser.PositionOffset = Vector(0, -5)
					laser.DepthOffset = player.DepthOffset - 10
					laser.Mass = 0
					laser.IsActiveRotating = true
					if num < 4 then
						laser.RotationSpd = 10-num*2
						laser.MaxDistance = 110-num*12
					else
						local neg = 1
						if rng:RandomInt(2) == 0 then
							neg = -1
						end
						laser.RotationSpd = neg*(4+rng:RandomInt(5))
						laser.MaxDistance = 100-rng:RandomInt(40)
					end
					laser:SetTimeout(50)
					laser:GetData().robotrock = true
					laser:ClearTearFlags(TearFlags.TEAR_EXPLOSIVE)
					laser:Update()
				end

				sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
			end

			for _, lasera in ipairs(data.robotRockLasers) do
				local laser = lasera[1]
				local num = lasera[2]
				if not laser:Exists() then
					for _, l2a in ipairs(data.robotRockLasers) do
						local l2 = l2a[1]
						if l2:Exists() then
							l2:Remove()
						end
					end

					data.robotRockLasers = nil
					break
				else
					laser:SetTimeout(4)
					laser.SpriteScale = Vector.One
					laser.Velocity = player.Position - laser.Position
					laser.RotationDegrees = 10
					laser.IsActiveRotating = true
					laser:ClearTearFlags(TearFlags.TEAR_EXPLOSIVE)
					
					local ticks = #robotRockLaserColors * 7
					local currentTick = game:GetFrameCount() % ticks
					
					local colorA = robotRockLaserColors[math.floor(currentTick / 7) + 1]
					local colorB = robotRockLaserColors[math.ceil(currentTick / 7) % #robotRockLaserColors + 1]
					if (player:HasCollectible(CollectibleType.COLLECTIBLE_PRANK_COOKIE) or player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE)) then
					else
						laser.Color = Color.Lerp(colorA, colorB, (currentTick % 7) / 7)
					end
					data.robotRockStatusNum = math.ceil(currentTick / 7) % #robotRockLaserColors + 1

					--[[if statusNum == 1 then     --R
						laser:AddTearFlags(TearFlags.TEAR_FREEZE)
						laser:ClearTearFlags(TearFlags.TEAR_CHARM)
					elseif statusNum == 2 then --O
						laser:AddTearFlags(TearFlags.TEAR_BURN)
						laser:ClearTearFlags(TearFlags.TEAR_FREEZE)
					elseif statusNum == 3 then --Y
						laser:AddTearFlags(TearFlags.TEAR_JACOBS)
						laser:ClearTearFlags(TearFlags.TEAR_BURN)
					elseif statusNum == 4 then --G
						laser:AddTearFlags(TearFlags.TEAR_POISON)
						laser:ClearTearFlags(TearFlags.TEAR_JACOBS)
					elseif statusNum == 5 then --T
						laser:AddTearFlags(TearFlags.TEAR_SLOW)
						laser:ClearTearFlags(TearFlags.TEAR_POISON)
					elseif statusNum == 6 then --B
						laser:AddTearFlags(TearFlags.TEAR_ICE)
						laser:ClearTearFlags(TearFlags.TEAR_SLOW)
					elseif statusNum == 7 then --P
						laser:AddTearFlags(TearFlags.TEAR_FEAR)
						laser:ClearTearFlags(TearFlags.TEAR_ICE)
					elseif statusNum == 8 then --P
						laser:AddTearFlags(TearFlags.TEAR_CHARM)
						laser:ClearTearFlags(TearFlags.TEAR_FEAR)
					end]]
				end
			end
		end
    elseif data.robotRockLasers and #data.robotRockLasers > 0 then
        data.robotRockLasers = nil
	end
end

--[[mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	if laser:GetData().robotrock then
		laser:ClearTearFlags(TearFlags.TEAR_EXPLOSIVE)
	end
end, 2)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if explosion.SpawnerEntity then
		print("spawner")
	end
	if explosion.Child then
		print("parent")
	end
end, EffectVariant.BOMB_EXPLOSION)]]

function mod:robotRockOnLaserDamage(player, ent, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROBOT_ROCK) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROBOT_ROCK)
		if rng:RandomInt(4) == 0 then
			if ent.Position:Distance(player.Position) < 100 then
				local data = player:GetData()
				if data.robotRockStatusNum then
					if data.robotRockStatusNum == 1 then
						ent:AddEntityFlags(EntityFlag.FLAG_BAITED)
					elseif data.robotRockStatusNum == 2 then
						ent:AddBurn(EntityRef(player), 100 * secondHandMultiplier, player.Damage)
					elseif data.robotRockStatusNum == 3 then
						ent:AddConfusion(EntityRef(player), 100 * secondHandMultiplier, false)
					elseif data.robotRockStatusNum == 4 then
						ent:AddPoison(EntityRef(player), 100 * secondHandMultiplier, player.Damage)
					elseif data.robotRockStatusNum == 5 then
						ent:AddShrink(EntityRef(player), 100 * secondHandMultiplier)
					elseif data.robotRockStatusNum == 6 then
						ent:AddSlowing(EntityRef(player), 100 * secondHandMultiplier, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
					elseif data.robotRockStatusNum == 7 then
						ent:AddFear(EntityRef(player), 100 * secondHandMultiplier)
					elseif data.robotRockStatusNum == 8 then
						ent:AddCharmed(EntityRef(player), 100 * secondHandMultiplier)
					end
				end
			end
		end
	end
end