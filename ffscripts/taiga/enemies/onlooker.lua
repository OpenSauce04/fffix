-- Onlooker --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local numOnlookersFiring = 0 -- for Meat Boy laser sound loop
function mod:onlookerAI(npc, sprite, npcdata)
	if npcdata.init == nil then
		npcdata.init = true
		npcdata.state = "idle"
		npcdata.stateTimer = 0
		npcdata.startPosition = npc.Position
		npcdata.position, npcdata.attachedWall = mod:onlookerNearestWall(npc.Position, npc.SubType)

		npcdata.laserStart = npcdata.position-- + Vector(0,-16)
		local lightingOffset = Vector(0,-15)
		if npcdata.attachedWall == "down" then
			sprite.Rotation = 180
			sprite.Offset = Vector(1,0)
		--	npcdata.laserStart = npcdata.position + Vector(0,16)
			lightingOffset = Vector(0,15)
		elseif npcdata.attachedWall == "left" then
			sprite.Rotation = 270
			--sprite.Offset = Vector(0,-10)
		--	npcdata.laserStart = npcdata.position + Vector(-16,0)
			lightingOffset = Vector(-15,0)
		elseif npcdata.attachedWall == "right" then
			sprite.Rotation = 90
			sprite.Offset = Vector(0,-1)
		--	npcdata.laserStart = npcdata.position + Vector(16,0)
			lightingOffset = Vector(15,0)
		end

		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)

		local securityLaser = Isaac.Spawn(EntityType.ENTITY_EFFECT, Isaac.GetEntityVariantByName("Onlooker Laser"), 0, npcdata.laserStart, nilvector, npc)
		local securityLaserSprite = securityLaser:GetSprite()
		local securityLaserData = securityLaser:GetData()
		securityLaser:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

		local lightingLaser = Isaac.Spawn(EntityType.ENTITY_LASER, 7, 0, npcdata.laserStart + lightingOffset, nilvector, npc):ToLaser()
		local lightingLaserSprite = lightingLaser:GetSprite()

		securityLaserSprite.Offset = Vector(0,-16)
		securityLaser.DepthOffset = 1
		lightingLaser.Angle = 90
		if npcdata.attachedWall == "down" then
			securityLaserSprite.Rotation = 180
			securityLaserSprite.Offset = Vector(1,16)
			securityLaser.DepthOffset = 1
			lightingLaser.Angle = 270
		elseif npcdata.attachedWall == "left" then
			securityLaserSprite.Rotation = 270
			securityLaserSprite.Offset = Vector(-16,0)
			securityLaser.DepthOffset = 10
			lightingLaser.Angle = 0
		elseif npcdata.attachedWall == "right" then
			securityLaserSprite.Rotation = 90
			securityLaserSprite.Offset = Vector(16,-1)
			securityLaser.DepthOffset = 10
			lightingLaser.Angle = 180
		end

		securityLaserSprite.Color = Color(1.0, 1.0, 1.0, 0.0, 0, 0, 0)
		securityLaserSprite:Play("Idle")
		securityLaserData.attachedWall = npcdata.attachedWall
		securityLaserData.state = 0

		lightingLaserSprite.Color = mod.ColorInvisible
		lightingLaserSprite:ReplaceSpritesheet(0, "gfx/enemies/onlooker/blank.png")
		lightingLaserSprite:LoadGraphics()
		lightingLaser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		lightingLaser.CollisionDamage = 0
		lightingLaser:Update()

		npcdata.securityLaser = securityLaser
		npcdata.lightingLaser = lightingLaser
		securityLaserData.lightingLaser = lightingLaser

		if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			sprite:Play("Open")
		else
			sprite:Play("Idle")
			npcdata.state = "watching"
			npcdata.stateTimer = 0
			securityLaserData.state = 1
			securityLaserSprite:Play("Security")
		end
	end

	npc.Position = npcdata.position
	npc.Velocity = nilvector

	if sprite:IsFinished("Open") then
		sprite:Play("Idle")
	elseif sprite:IsFinished("Charge") then
		sprite:Play("Firing")
	elseif sprite:IsFinished("End Firing") then
		sprite:Play("Idle")
	end

	if sprite:IsEventTriggered("Activate") then
		-- fire security laser
		npcdata.state = "watching"
		npcdata.stateTimer = 0
		npcdata.securityLaser:GetData().state = 1
		npcdata.securityLaser:GetSprite():Play("Security")
	elseif sprite:IsEventTriggered("Deactivate") then
		-- stop security laser
		npcdata.state = "idle"
		npcdata.stateTimer = 0
		npcdata.securityLaser:GetData().state = 0
		npcdata.securityLaser:GetSprite():Play("Idle")
	elseif sprite:IsEventTriggered("Fire") then
		-- fire damaging laser
		npcdata.state = "firing"
		npcdata.stateTimer = 60
		npcdata.securityLaser:GetData().state = 1
		npcdata.securityLaser:GetSprite():Play("Fire")
		numOnlookersFiring = numOnlookersFiring + 1
		npc:PlaySound(SoundEffect.SOUND_REDLIGHTNING_ZAP, 0.9, 0, false, 1.0)
	elseif sprite:IsEventTriggered("Stop") then
		-- stop damaging laser
		npcdata.state = "idle"
		npcdata.stateTimer = 0
		npcdata.securityLaser:GetData().state = 0
		npcdata.securityLaser:GetSprite():Play("Idle")
		numOnlookersFiring = numOnlookersFiring - 1
	end

	if npcdata.state == "firing" then
		if not sfx:IsPlaying(mod.Sounds.MeatBoyLaser) then
			sfx:Play(mod.Sounds.MeatBoyLaser, 0.65, 0, true, 1.0)
		end

		npcdata.stateTimer = npcdata.stateTimer - 1
		if npcdata.stateTimer == 0 then
			sprite:Play("End Firing")
		end
	end

	if npcdata.state == "watching" or npcdata.state == "firing" then
		local securityEndpoint, blockingEntity, blockingIsGrid = mod:onlookerGetDamageLaserEndpoint(npcdata.laserStart + npcdata.securityLaser:GetSprite().Offset, npcdata.attachedWall)

		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			local playerPosition = player.Position

			local playerSpotted = false
			if npcdata.attachedWall == "up" then
				if math.abs(playerPosition.X - npc.Position.X) - player.Size * player.SizeMulti.X <= 5 and playerPosition.Y >= npc.Position.Y and playerPosition.Y <= securityEndpoint.Y then
					playerSpotted = true
				end
			elseif npcdata.attachedWall == "down" then
				if math.abs(playerPosition.X - npc.Position.X) - player.Size * player.SizeMulti.X <= 5 and playerPosition.Y <= npc.Position.Y and playerPosition.Y >= securityEndpoint.Y then
					playerSpotted = true
				end
			elseif npcdata.attachedWall == "left" then
				if math.abs(playerPosition.Y - (npc.Position.Y + 10)) - player.Size * player.SizeMulti.Y <= 5 and playerPosition.X >= npc.Position.X and playerPosition.X <= securityEndpoint.X then
					playerSpotted = true
				end
			else
				if math.abs(playerPosition.Y - (npc.Position.Y + 10)) - player.Size * player.SizeMulti.Y <= 5 and playerPosition.X <= npc.Position.X and playerPosition.X >= securityEndpoint.X then
					playerSpotted = true
				end
			end

			if playerSpotted then
				if npcdata.state == "watching" then
					npcdata.state = "idle"
					sprite:Play("Charge")
					break
				elseif npcdata.state == "firing" then
					player:TakeDamage(1, DamageFlag.DAMAGE_LASER, EntityRef(npc), 0)
				end
			end
		end

		if npcdata.state == "firing" then
			for i = 1, #mod.EntityDamagedByOnlookerLaser do
				local damagableEntities
				if mod.EntityDamagedByOnlookerLaser[i][3] then
					damagableEntities = Isaac.FindByType(mod.EntityDamagedByOnlookerLaser[i][1],
					                                     mod.EntityDamagedByOnlookerLaser[i][2],
					                                     mod.EntityDamagedByOnlookerLaser[i][3],
					                                     false,
					                                     false)
				elseif mod.EntityDamagedByOnlookerLaser[i][2] then
					damagableEntities = Isaac.FindByType(mod.EntityDamagedByOnlookerLaser[i][1],
					                                     mod.EntityDamagedByOnlookerLaser[i][2],
					                                     -1,
					                                     false,
					                                     false)
				else
					damagableEntities = Isaac.FindByType(mod.EntityDamagedByOnlookerLaser[i][1],
					                                     -1,
					                                     -1,
					                                     false,
					                                     false)
				end

				for i = 1, #damagableEntities do
					local damagableEnt = damagableEntities[i]
					local damagableEntPosition = damagableEnt.Position

					local damagableEntSpotted = false
					if npcdata.attachedWall == "up" then
						if math.abs(damagableEntPosition.X - npc.Position.X) - damagableEnt.Size * damagableEnt.SizeMulti.X <= 5 and damagableEntPosition.Y >= npc.Position.Y and damagableEntPosition.Y <= securityEndpoint.Y then
							damagableEntSpotted = true
						end
					elseif npcdata.attachedWall == "down" then
						if math.abs(damagableEntPosition.X - npc.Position.X) - damagableEnt.Size * damagableEnt.SizeMulti.X <= 5 and damagableEntPosition.Y <= npc.Position.Y and damagableEntPosition.Y >= securityEndpoint.Y then
							damagableEntSpotted = true
						end
					elseif npcdata.attachedWall == "left" then
						if math.abs(damagableEntPosition.Y - (npc.Position.Y + 10)) - damagableEnt.Size * damagableEnt.SizeMulti.Y <= 5 and damagableEntPosition.X >= npc.Position.X and damagableEntPosition.X <= securityEndpoint.X then
							damagableEntSpotted = true
						end
					else
						if math.abs(damagableEntPosition.Y - (npc.Position.Y + 10)) - damagableEnt.Size * damagableEnt.SizeMulti.Y <= 5 and damagableEntPosition.X <= npc.Position.X and damagableEntPosition.X >= securityEndpoint.X then
							damagableEntSpotted = true
						end
					end

					if damagableEntSpotted then
						damagableEnt:TakeDamage(5, DamageFlag.DAMAGE_LASER, EntityRef(npc), 0)
					end
				end
			end
		end

		if blockingEntity and npcdata.state == "firing" then
			if blockingIsGrid then
				if mod.BlockingGridDamagedByOnlookerLaser[blockingEntity:GetType()] or
				   mod.BlockingGridDamagedByOnlookerLaser[blockingEntity:GetType() .. " " .. blockingEntity:GetVariant()] then
					blockingEntity:Hurt(1)
				end
			else
				if mod.BlockingEntityDamagedByOnlookerLaser[blockingEntity.Type] or
				   mod.BlockingEntityDamagedByOnlookerLaser[blockingEntity.Type .. " " .. blockingEntity.Variant] or
				   mod.BlockingEntityDamagedByOnlookerLaser[blockingEntity.Type .. " " .. blockingEntity.Variant .. " " .. blockingEntity.SubType] then
					blockingEntity:TakeDamage(5, DamageFlag.DAMAGE_LASER, EntityRef(npc), 0)
				end
			end
		end
	end
end

function mod:onlookerTakeDmg(entity, damage, flags, source, countdown)
	return false
end

function mod:renderSecurityLaser(effect)
	local data = effect:GetData()
	if data.state == 1 then
		local sprite = effect:GetSprite()

		local dist, isWall = mod:onlookerGetVisualLaserDistance(effect.Position + sprite.Offset, data.attachedWall)
		local extraLength = 15
		if isWall then
			extraLength = 33
		elseif data.attachedWall == "down" then
			extraLength = 19
		elseif data.attachedWall == "left" then
			extraLength = 16
		elseif data.attachedWall == "right" then
			extraLength = 16
		end
		local endpointDist = 750 - (math.floor(26 * dist) + extraLength - 1)

		local startpointOffset = Vector(0,-751)
		local endpointOffset = Vector(0,-1*endpointDist)
		local laserOffset = Vector(0,-1*(endpointDist+6))
		if data.attachedWall == "down" then
			startpointOffset = Vector(0,751)
			endpointOffset = Vector(0,endpointDist)
			laserOffset = Vector(0,endpointDist+6)
		elseif data.attachedWall == "left" then
			startpointOffset = Vector(-751,0)
			endpointOffset = Vector(-1*endpointDist,0)
			laserOffset = Vector(-1*(endpointDist+6),0)
		elseif data.attachedWall == "right" then
			startpointOffset = Vector(751,0)
			endpointOffset = Vector(endpointDist,0)
			laserOffset = Vector(endpointDist+6,0)
		end

		 -- Render laser
		sprite.Color = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0)
		sprite:Render(Isaac.WorldToScreen(effect.Position), nilvector, Vector(0,endpointDist))

		 -- Render startpoint
		sprite.Offset = sprite.Offset + startpointOffset
		sprite:Render(Isaac.WorldToScreen(effect.Position), Vector(0,750), Vector(0,6))

		 -- Render endpoint
		sprite.Offset = sprite.Offset - startpointOffset + endpointOffset
		sprite:Render(Isaac.WorldToScreen(effect.Position), Vector(0,750), Vector(0,6))

		-- Render impact
		sprite.Offset = sprite.Offset - endpointOffset + laserOffset
		sprite:Render(Isaac.WorldToScreen(effect.Position), Vector(0,751), nilvector)

		-- Reset
		sprite.Offset = sprite.Offset - laserOffset
		sprite.Color = Color(1.0, 1.0, 1.0, 0.0, 0, 0, 0)

		if data.lightingLaser then
			if sprite:IsPlaying("Security") then
				data.lightingLaser:GetSprite().Color = Color(1.5, 0.4, 0.4, 0.5, 0, 0, 0)
			else
				data.lightingLaser:GetSprite().Color = Color(1.5, 1.5, 1.0, 0.75, 0, 0, 0)
			end

			if isWall then
				data.lightingLaser.MaxDistance = dist * 40 + 30
			else
				data.lightingLaser.MaxDistance = dist * 40 + 15
			end
		end
	else
		if data.lightingLaser then
			data.lightingLaser:GetSprite().Color = mod.ColorInvisible
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.renderSecurityLaser, Isaac.GetEntityVariantByName("Onlooker Laser"))

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, e)
	if e.Variant == Isaac.GetEntityVariantByName("Onlooker") then
		local data = e:GetData()
		if data.securityLaser then
			data.securityLaser:Remove()
		end

		if data.lightingLaser then
			data.lightingLaser:Remove()
		end

		if data.state == "firing" then
			numOnlookersFiring = numOnlookersFiring - 1
		end
	end
end, mod.FFID.Taiga)

-- stopping Meat Boy laser sound loop
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
	if numOnlookersFiring == 0 and sfx:IsPlaying(mod.Sounds.MeatBoyLaser) then
		sfx:Stop(mod.Sounds.MeatBoyLaser)
	end
end)

function mod:onlookerNearestWall(position, subtype)
	local room = game:GetRoom()
	local roomshape = room:GetRoomShape()
	local leftX = 60
	local rightX = 580
	local upY = 140
	local downY = 420

	if roomshape == RoomShape.ROOMSHAPE_IH then
		leftX = 60
		rightX = 580
		upY = 220
		downY = 340
	elseif roomshape == RoomShape.ROOMSHAPE_IV then
		leftX = 220
		rightX = 420
		upY = 140
		downY = 420
	elseif roomshape == RoomShape.ROOMSHAPE_1x2 then
		leftX = 60
		rightX = 580
		upY = 140
		downY = 700
	elseif roomshape == RoomShape.ROOMSHAPE_IIV then
		leftX = 220
		rightX = 420
		upY = 140
		downY = 700
	elseif roomshape == RoomShape.ROOMSHAPE_2x1 then
		leftX = 60
		rightX = 1100
		upY = 140
		downY = 420
	elseif roomshape == RoomShape.ROOMSHAPE_IIH then
		leftX = 60
		rightX = 1100
		upY = 220
		downY = 340
	elseif roomshape == RoomShape.ROOMSHAPE_2x2 then
		leftX = 60
		rightX = 1100
		upY = 140
		downY = 700
	elseif roomshape == RoomShape.ROOMSHAPE_LTL then
		leftX = 60
		rightX = 1100
		upY = 140
		downY = 700

		if position.X < 580 then
			upY = 420
		end

		if position.Y < 420 then
			leftX = 580
		end
	elseif roomshape == RoomShape.ROOMSHAPE_LTR then
		leftX = 60
		rightX = 1100
		upY = 140
		downY = 700

		if position.X > 580 then
			upY = 420
		end

		if position.Y < 420 then
			rightX = 580
		end
	elseif roomshape == RoomShape.ROOMSHAPE_LBL then
		leftX = 60
		rightX = 1100
		upY = 140
		downY = 700

		if position.X < 580 then
			downY = 420
		end

		if position.Y > 420 then
			leftX = 580
		end
	elseif roomshape == RoomShape.ROOMSHAPE_LBR then
		leftX = 60
		rightX = 1100
		upY = 140
		downY = 700

		if position.X > 580 then
			downY = 420
		end

		if position.Y > 420 then
			rightX = 580
		end
	end

	local returnPosition, returnWall

	if position.Y < upY then
		-- Force north wall
		returnPosition = Vector(position.X, upY)
		returnWall = "up"
	elseif position.Y > downY then
		-- Force south wall
		returnPosition = Vector(position.X, downY)
		returnWall = "down"
	elseif position.X < leftX then
		-- Force west wall
		returnPosition = Vector(leftX, position.Y)
		returnWall = "left"
	elseif position.X > rightX then
		-- Force east wall
		returnPosition = Vector(rightX, position.Y)
		returnWall = "right"
	else
		-- Select wall like a Wall Creep would
		local leftDist = math.abs(position.X - leftX)
		local rightDist = math.abs(position.X - rightX)
		local upDist = math.abs(position.Y - upY)
		local downDist = math.abs(position.Y - downY)

		local returnDist = downDist
		returnPosition = Vector(position.X, downY)
		returnWall = "down"

		if upDist <= returnDist then
			returnPosition = Vector(position.X, upY)
			returnWall = "up"
			returnDist = upDist
		end

		if rightDist <= returnDist then
			returnPosition = Vector(rightX, position.Y)
			returnWall = "right"
			returnDist = rightDist
		end

		if leftDist <= returnDist then
			returnPosition = Vector(leftX, position.Y)
			returnWall = "left"
			returnDist = leftDist
		end
	end

	return returnPosition, returnWall
end

function mod:getOnlookerLaserEndpointByEntity(laserPosition, attachedWall, e)
	local entityPosition = e.Position
	local entityRadiusX = math.abs(e.Size * e.SizeMulti.X)
	local entityRadiusY = math.abs(e.Size * e.SizeMulti.Y)

	if entityRadiusX == 0 or entityRadiusY == 0 then
		return nil
	end

	if attachedWall == "up" or attachedWall == "down" then
		if math.abs(entityPosition.X - laserPosition.X) > entityRadiusX then
			return nil
		elseif math.abs(entityPosition.X - laserPosition.X) == entityRadiusX then
			return Vector(laserPosition.X, entityPosition.Y)
		else
			local entityOriginLaserX = laserPosition.X - entityPosition.X
			local y1 = entityRadiusY * math.sqrt(entityRadiusX^2 - entityOriginLaserX^2) / entityRadiusX
			local y2 = -1 * y1

			local returnY = entityPosition.Y + math.min(y1, y2)
			if attachedWall == "down" then
				returnY = entityPosition.Y + math.max(y1, y2)
			end

			return Vector(laserPosition.X, returnY)
		end
	else
		if math.abs(entityPosition.Y - laserPosition.Y) > entityRadiusY then
			return nil
		elseif math.abs(entityPosition.Y - laserPosition.Y) == entityRadiusY then
			return Vector(laserPosition.Y, entityPosition.Y)
		else
			local entityOriginLaserY = laserPosition.Y - entityPosition.Y
			local x1 = entityRadiusX * math.sqrt(entityRadiusY^2 - entityOriginLaserY^2) / entityRadiusY
			local x2 = -1 * x1

			local returnX = entityPosition.X + math.min(x1, x2)
			if attachedWall == "right" then
				returnX = entityPosition.X + math.max(x1, x2)
			end

			return Vector(returnX, laserPosition.Y)
		end
	end

	return nil
end

function mod:onlookerGetVisualLaserDistance(position, attachedWall)
	local room = game:GetRoom()
	local startingGridIndex = room:GetGridIndex(position)
	if startingGridIndex == -1 then
		return 0
	end
	local startingGridPosition = room:GetGridPosition(startingGridIndex)

	local positionIter
	if attachedWall == "up" then
		positionIter = Vector(0,40)
	elseif attachedWall == "down" then
		positionIter = Vector(0,-40)
	elseif attachedWall == "left" then
		positionIter = Vector(40,0)
	else
		positionIter = Vector(-40,0)
	end
	local nextGridPosition = startingGridPosition + positionIter

	local numGrids = 0
	while room:GetGridIndex(nextGridPosition) ~= -1 do
		local nextGridCollision = room:GetGridCollisionAtPos(nextGridPosition)
		if nextGridCollision ~= GridCollisionClass.COLLISION_NONE and nextGridCollision ~= GridCollisionClass.COLLISION_PIT then
			local currentGridIndex = room:GetGridIndex(nextGridPosition)
			local currentGridEntityType = room:GetGridEntity(currentGridIndex):GetType()
			local isWall = currentGridEntityType == GridEntityType.GRID_WALL or currentGridEntityType == GridEntityType.GRID_DOOR
			local isCustom = StageAPI.IsCustomGrid(currentGridIndex)

			return numGrids, isWall and not isCustom
		else
			local entitiesInGrid = Isaac.FindInRadius(nextGridPosition, 40, EntityPartition.ENEMY)
			for _, e in pairs(entitiesInGrid) do
				if e.Type == mod.FF.Immural.ID and e.Variant == mod.FF.Immural.Var and e.Position:Distance(nextGridPosition) <= 10 then
					local immuralSprite = e:GetSprite()
					-- Immural compatibility
					if (immuralSprite:IsPlaying("Fall") and immuralSprite:WasEventTriggered("dropped")) or immuralSprite:IsFinished("Fall") then
						return numGrids, false
					elseif immuralSprite:IsPlaying("FloorBound") or immuralSprite:IsFinished("FloorBound") then
						return numGrids, false
					end
				elseif mod.BlocksOnlookerLaser[e.Type] then
					if mod.BlocksOnlookerLaser[e.Type] == "grid" and e.Position:Distance(nextGridPosition) <= 10 then
						return numGrids, false
					elseif mod.BlocksOnlookerLaser[e.Type] == "entity" then
						local endpoint = mod:getOnlookerLaserEndpointByEntity(position, attachedWall, e)
						if endpoint ~= nil then
							local subGridAmount
							if attachedWall == "up" then
								subGridAmount = endpoint.Y - (nextGridPosition.Y - 20)
							elseif attachedWall == "down" then
								subGridAmount = (nextGridPosition.Y + 20) - endpoint.Y
							elseif attachedWall == "left" then
								subGridAmount = endpoint.X - (nextGridPosition.X - 20)
							else
								subGridAmount = (nextGridPosition.X + 20) - endpoint.X
							end

							return numGrids + (subGridAmount / 40), false
						end
					end
				elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant] then
					if mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant] == "grid" and e.Position:Distance(nextGridPosition) <= 10 then
						return numGrids, false
					elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant] == "entity" then
						local endpoint = mod:getOnlookerLaserEndpointByEntity(position, attachedWall, e)
						if endpoint ~= nil then
							local subGridAmount
							if attachedWall == "up" then
								subGridAmount = endpoint.Y - (nextGridPosition.Y - 20)
							elseif attachedWall == "down" then
								subGridAmount = (nextGridPosition.Y + 20) - endpoint.Y
							elseif attachedWall == "left" then
								subGridAmount = endpoint.X - (nextGridPosition.X - 20)
							else
								subGridAmount = (nextGridPosition.X + 20) - endpoint.X
							end

							return numGrids + (subGridAmount / 40), false
						end
					end
				elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant .. " " .. e.SubType] then
					if mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant .. " " .. e.SubType] == "grid" and e.Position:Distance(nextGridPosition) <= 10 then
						return numGrids, false
					elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant .. " " .. e.SubType] == "entity" then
						local endpoint = mod:getOnlookerLaserEndpointByEntity(position, attachedWall, e)
						if endpoint ~= nil then
							local subGridAmount
							if attachedWall == "up" then
								subGridAmount = endpoint.Y - (nextGridPosition.Y - 20)
							elseif attachedWall == "down" then
								subGridAmount = (nextGridPosition.Y + 20) - endpoint.Y
							elseif attachedWall == "left" then
								subGridAmount = endpoint.X - (nextGridPosition.X - 20)
							else
								subGridAmount = (nextGridPosition.X + 20) - endpoint.X
							end

							return numGrids + (subGridAmount / 40), false
						end
					end
				end
			end
		end

		nextGridPosition = nextGridPosition + positionIter
		numGrids = numGrids + 1
	end

	return 0
end

function mod:onlookerGetDamageLaserEndpoint(position, attachedWall)
	local room = game:GetRoom()
	local startingGridIndex = room:GetGridIndex(position)
	if startingGridIndex == -1 then
		return nilvector
	end
	local startingGridPosition = room:GetGridPosition(startingGridIndex)

	local positionIter, gridEdgeSubtract
	local nextGridPosition = startingGridPosition
	if attachedWall == "up" then
		positionIter = Vector(0,40)
		gridEdgeSubtract = Vector(0,-20)
	elseif attachedWall == "down" then
		positionIter = Vector(0,-40)
		gridEdgeSubtract = Vector(0,20)
	elseif attachedWall == "left" then
		positionIter = Vector(40,0)
		gridEdgeSubtract = Vector(-20,0)
	else
		positionIter = Vector(-40,0)
		gridEdgeSubtract = Vector(20,0)
	end
	local nextGridPosition = startingGridPosition + positionIter

	while room:GetGridIndex(nextGridPosition) ~= -1 do
		local nextGridCollision = room:GetGridCollisionAtPos(nextGridPosition)
		if nextGridCollision ~= GridCollisionClass.COLLISION_NONE and nextGridCollision ~= GridCollisionClass.COLLISION_PIT then
			return nextGridPosition + gridEdgeSubtract, room:GetGridEntityFromPos(nextGridPosition), true
		else
			local entitiesInGrid = Isaac.FindInRadius(nextGridPosition, 40, EntityPartition.ENEMY)
			for _, e in pairs(entitiesInGrid) do
				if e.Type == mod.FF.Immural.ID and e.Variant == mod.FF.Immural.Var and e.Position:Distance(nextGridPosition) <= 10 then
					local immuralSprite = e:GetSprite()
					-- Immural compatibility
					if (immuralSprite:IsPlaying("Fall") and immuralSprite:WasEventTriggered("dropped")) or immuralSprite:IsFinished("Fall") then
						return nextGridPosition + gridEdgeSubtract, e, false
					elseif immuralSprite:IsPlaying("FloorBound") or immuralSprite:IsFinished("FloorBound") then
						return nextGridPosition + gridEdgeSubtract, e, false
					end
				elseif mod.BlocksOnlookerLaser[e.Type] then
					if mod.BlocksOnlookerLaser[e.Type] == "grid" and e.Position:Distance(nextGridPosition) <= 10 then
						return nextGridPosition + gridEdgeSubtract, e, false
					elseif mod.BlocksOnlookerLaser[e.Type] == "entity" then
						local endpoint = mod:getOnlookerLaserEndpointByEntity(position, attachedWall, e)
						if endpoint ~= nil then
							return endpoint, e, false
						end
					end
				elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant] then
					if mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant] == "grid" and e.Position:Distance(nextGridPosition) <= 10 then
						return nextGridPosition + gridEdgeSubtract, e, false
					elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant] == "entity" then
						local endpoint = mod:getOnlookerLaserEndpointByEntity(position, attachedWall, e)
						if endpoint ~= nil then
							return endpoint, e, false
						end
					end
				elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant .. " " .. e.SubType] then
					if mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant .. " " .. e.SubType] == "grid" and e.Position:Distance(nextGridPosition) <= 10 then
						return nextGridPosition + gridEdgeSubtract, e, false
					elseif mod.BlocksOnlookerLaser[e.Type .. " " .. e.Variant .. " " .. e.SubType] == "entity" then
						local endpoint = mod:getOnlookerLaserEndpointByEntity(position, attachedWall, e)
						if endpoint ~= nil then
							return endpoint, e, false
						end
					end
				end
			end
		end

		nextGridPosition = nextGridPosition + positionIter
	end

	return nilvector
end
