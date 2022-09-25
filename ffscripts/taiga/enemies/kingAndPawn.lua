-- King and Pawn --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function isNotAvoidedDirection(d, avoid)
	return avoid == nil or d.X ~= avoid.X or d.Y ~= avoid.Y
end

-- King --
local function getPathableDirectionsKing(position, avoidDirection)
	local directions = {}
	local room = game:GetRoom()
	local currentGridIndex = room:GetGridIndex(position)
	local currentGridPosition = room:GetGridPosition(currentGridIndex)
	
	local topLeftCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(-40,-40))
	local topCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(0,-40))
	local topRightCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(40,-40))
	local rightCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(40,0))
	local bottomRightCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(40,40))
	local bottomCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(0,40))
	local bottomLeftCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(-40,40))
	local leftCollision = room:GetGridCollisionAtPos(currentGridPosition + Vector(-40,0))
	
	if topLeftCollision == GridCollisionClass.COLLISION_NONE and 
	   topCollision == GridCollisionClass.COLLISION_NONE and 
	   leftCollision == GridCollisionClass.COLLISION_NONE and
	   isNotAvoidedDirection(Vector(-1,-1), avoidDirection)
	then
		table.insert(directions, Vector(-1,-1))
	end
	
	if topCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(0,-1), avoidDirection) 
	then
		table.insert(directions, Vector(0,-1))
	end
	
	if topRightCollision == GridCollisionClass.COLLISION_NONE and 
	   topCollision == GridCollisionClass.COLLISION_NONE and 
	   rightCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(1,-1), avoidDirection) 
	then
		table.insert(directions, Vector(1,-1))
	end
	
	if rightCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(1,0), avoidDirection) 
	then
		table.insert(directions, Vector(1,0))
	end
	
	if bottomRightCollision == GridCollisionClass.COLLISION_NONE and 
	   bottomCollision == GridCollisionClass.COLLISION_NONE and 
	   rightCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(1,1), avoidDirection) 
	then
		table.insert(directions, Vector(1,1))
	end
	
	if bottomCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(0,1), avoidDirection) 
	then
		table.insert(directions, Vector(0,1))
	end
	
	if bottomLeftCollision == GridCollisionClass.COLLISION_NONE and 
	   bottomCollision == GridCollisionClass.COLLISION_NONE and 
	   leftCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(-1,1), avoidDirection) 
	then
		table.insert(directions, Vector(-1,1))
	end
	
	if leftCollision == GridCollisionClass.COLLISION_NONE and 
	   isNotAvoidedDirection(Vector(-1,0), avoidDirection) 
	then
		table.insert(directions, Vector(-1,0))
	end
	
	return directions
end

local function getNewDirectionKing(frame, position, npcdata, avoidDirection)
	local directions = getPathableDirectionsKing(position, avoidDirection)
	if #directions > 0 then
		npcdata.currentDirection = directions[math.random(#directions)]
		npcdata.currentDirectionProbability = 1.0
		
		local room = game:GetRoom()
		npcdata.currentGridIndex = room:GetGridIndex(position)
		npcdata.nextGridIndex = room:GetGridIndex(room:GetGridPosition(npcdata.currentGridIndex) + npcdata.currentDirection * 40)
		npcdata.frameLastDirectionGot = frame
	end
end

local function moveInCurrentDirectionKing(frame, position, npcdata)
	local room = game:GetRoom()
	npcdata.currentGridIndex = room:GetGridIndex(position)
	npcdata.nextGridIndex = room:GetGridIndex(room:GetGridPosition(npcdata.currentGridIndex) + npcdata.currentDirection * 40)
	npcdata.frameLastDirectionGot = frame
end

local function nextInCurrentDirectionIsBlockedKing(position, npcdata)
	local room = game:GetRoom()
	local gridIndex = room:GetGridIndex(position)
	local gridPosition = room:GetGridPosition(gridIndex)
	
	if room:GetGridCollisionAtPos(gridPosition + npcdata.currentDirection * 40) ~= GridCollisionClass.COLLISION_NONE then
		return true
	elseif npcdata.currentDirection.X ~= 0.0 and 
		   npcdata.currentDirection.Y ~= 0.0 and
		   (room:GetGridCollisionAtPos(gridPosition + Vector(npcdata.currentDirection.X, 0) * 40) ~= GridCollisionClass.COLLISION_NONE or
		    room:GetGridCollisionAtPos(gridPosition + Vector(0, npcdata.currentDirection.Y) * 40) ~= GridCollisionClass.COLLISION_NONE)
	then
		return true
	else
		return false
	end
end

function mod:kingAI(npc, sprite, npcdata)
	local room = game:GetRoom()

	if not npcdata.init then
		npcdata.Pawns = npcdata.Pawns or {}
		
		for i = 1, npc.SubType do
			local pawn = Isaac.Spawn(mod.FF.Pawn.ID, mod.FF.Pawn.Var, 0, npc.Position + Vector(0,40):Rotated(math.random(360)), nilvector, npc)
			pawn.Parent = npc
			table.insert(npcdata.Pawns, pawn)
		end

		npcdata.JumpCooldown = 0
		npcdata.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
		npcdata.JumpCooldown = npcdata.JumpCooldown + 1
	end

	if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") then
		npcdata.JumpCooldown = 0
		npcdata.state = "idle"
		sprite:Play("Idle")
	end

	for i, pawn in pairs(npcdata.Pawns) do
		if mod:IsReallyDead(pawn) then
			table.remove(npcdata.Pawns, i)
		end
	end

	if npcdata.state == "idle" then
		if npcdata.currentDirection == nil then
			getNewDirectionKing(npc.FrameCount, npc.Position, npcdata)
		elseif room:GetGridCollision(npcdata.nextGridIndex) ~= GridCollisionClass.COLLISION_NONE then
			getNewDirectionKing(npc.FrameCount, npc.Position, npcdata)
		elseif npc.FrameCount - npcdata.frameLastDirectionGot > 150 then
			getNewDirectionKing(npc.FrameCount, npc.Position, npcdata, npcdata.currentDirection)
		elseif room:GetGridIndex(npc.Position) ~= npcdata.currentGridIndex and room:GetGridIndex(npc.Position) ~= npcdata.nextGridIndex and
			room:GetGridIndex(npc.Position) ~= room:GetGridIndex(room:GetGridPosition(npcdata.currentGridIndex) + Vector(npcdata.currentDirection.X, 0) * 40) and 
			room:GetGridIndex(npc.Position) ~= room:GetGridIndex(room:GetGridPosition(npcdata.currentGridIndex) + Vector(0, npcdata.currentDirection.Y) * 40)
		then
			getNewDirectionKing(npc.FrameCount, npc.Position, npcdata)
		elseif math.abs(npc.Position.X - room:GetGridPosition(npcdata.nextGridIndex).X) <= 0.6 and 
			math.abs(npc.Position.Y - room:GetGridPosition(npcdata.nextGridIndex).Y) <= 0.6
		then
			npcdata.currentDirectionProbability = npcdata.currentDirectionProbability * 0.8
			if nextInCurrentDirectionIsBlockedKing(npc.Position, npcdata) or math.random() > npcdata.currentDirectionProbability then
				getNewDirectionKing(npc.FrameCount, npc.Position, npcdata)
			else
				moveInCurrentDirectionKing(npc.FrameCount, npc.Position, npcdata)
			end
		end
		
		if npcdata.currentDirection then
			local vel = room:GetGridPosition(npcdata.nextGridIndex) - npc.Position
			vel = vel:Resized(math.min(0.5, vel:Length()))
			npc.Velocity = vel * 0.8 + npc.Velocity * 0.2
		else
			npc.Velocity = Vector(0,0)
		end
		
		if npc.FrameCount % 30 == 0 then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect()
			--creep.Scale = 1.5
			creep:SetTimeout(200)
			creep:Update()
			
			local frame = creep:GetSprite():GetFrame()
			creep:GetSprite():Play("BigBlood0" .. (math.random(7) - 1))
			creep:GetSprite():SetFrame(frame)
		end

		if #npcdata.Pawns <= 2 and npcdata.JumpCooldown > (30 * (#npcdata.Pawns + 1)) and mod:RandomInt(1,10,npc:GetDropRNG()) == 1 then
			npcdata.state = "shoot"
			sprite:Play("Shoot")
		end
	elseif npcdata.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.5
		if sprite:IsEventTriggered("Jump") then
			sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			local params = ProjectileParams()
			params.Scale = 1.5
			npc:FireProjectiles(npc.Position, Vector(8,0), 8, params)
		end
	end
end

-- Pawn --
local function getPawnGridIndices(position)
	local x = math.floor(position.X / 20 + 0.5)
	local y = math.floor(position.Y / 20 + 0.5)
	
	return x, y
end

local function getPawnGridIndicesVector(position)
	local x = math.floor(position.X / 20 + 0.5)
	local y = math.floor(position.Y / 20 + 0.5)
	
	return Vector(x, y)
end

local function getPawnGridPosition(gridX, gridY)
	return Vector(gridX * 20, gridY * 20)
end

local function pawnGridIsBlocked(gridX, gridY)
	local room = game:GetRoom()
	local gridPosition = getPawnGridPosition(gridX, gridY)
	
	return room:GetGridCollisionAtPos(gridPosition + Vector(15,0)) ~= GridCollisionClass.COLLISION_NONE or
	       room:GetGridCollisionAtPos(gridPosition + Vector(-15,0)) ~= GridCollisionClass.COLLISION_NONE or
	       room:GetGridCollisionAtPos(gridPosition + Vector(0,15)) ~= GridCollisionClass.COLLISION_NONE or
	       room:GetGridCollisionAtPos(gridPosition + Vector(0,-15)) ~= GridCollisionClass.COLLISION_NONE
end

local function pawnTileInsideRadius(gridX, gridY, ringPosition, radius)
	local gridPosition = getPawnGridPosition(gridX, gridY)
	
	return (gridPosition - ringPosition):Length() < radius
end

local function pawnTileOutsideRadius(gridX, gridY, ringPosition, radius)
	local gridPosition = getPawnGridPosition(gridX, gridY)
	
	return (gridPosition - ringPosition):Length() > radius
end

local function pawnTileWithinRing(gridX, gridY, ringPosition, innerRadius, outerRadius)
	return not (pawnTileInsideRadius(gridX, gridY, ringPosition, innerRadius) or pawnTileOutsideRadius(gridX, gridY, ringPosition, outerRadius))
end

local function getPathableDirectionsPawn(position, parentPosition, avoidDirection)
	local directions = {}
	local room = game:GetRoom()
	
	local topCollision = room:GetGridCollisionAtPos(position + Vector(0,-25))
	local rightCollision = room:GetGridCollisionAtPos(position + Vector(25,0))
	local bottomCollision = room:GetGridCollisionAtPos(position + Vector(0,25))
	local leftCollision = room:GetGridCollisionAtPos(position + Vector(-25,0))
	
	local gridX, gridY = getPawnGridIndices(position)
	
	if topCollision == GridCollisionClass.COLLISION_NONE and 
	   pawnTileWithinRing(gridX, gridY - 1, parentPosition, 40, 90) and
	   isNotAvoidedDirection(Vector(0,-1), avoidDirection)
	then
		table.insert(directions, Vector(0,-1))
	end
	if rightCollision == GridCollisionClass.COLLISION_NONE and 
	   pawnTileWithinRing(gridX + 1, gridY, parentPosition, 40, 90) and
	   isNotAvoidedDirection(Vector(1,0), avoidDirection) 
	then
		table.insert(directions, Vector(1,0))
	end
	if bottomCollision == GridCollisionClass.COLLISION_NONE and 
	   pawnTileWithinRing(gridX, gridY + 1, parentPosition, 40, 90) and
	   isNotAvoidedDirection(Vector(0,1), avoidDirection) 
	then
		table.insert(directions, Vector(0,1))
	end
	if leftCollision == GridCollisionClass.COLLISION_NONE and 
	   pawnTileWithinRing(gridX - 1, gridY, parentPosition, 40, 90) and
	   isNotAvoidedDirection(Vector(-1,0), avoidDirection) 
	then
		table.insert(directions, Vector(-1,0))
	end
	
	return directions
end

local function getNewWanderDirectionPawn(frame, position, npcdata, parentPosition, avoidDirection)
	local directions = getPathableDirectionsPawn(position, parentPosition, avoidDirection)
	if #directions > 0 then
		npcdata.currentDirection = directions[math.random(#directions)]
		npcdata.currentDirectionProbability = 1.0
		
		local room = game:GetRoom()
		local gridX, gridY = getPawnGridIndices(position)
		npcdata.currentGridIndexX = gridX
		npcdata.currentGridIndexY = gridY
		npcdata.nextGridIndexX = math.floor(gridX + npcdata.currentDirection.X)
		npcdata.nextGridIndexY = math.floor(gridY + npcdata.currentDirection.Y)
		npcdata.frameLastDirectionGot = frame
		npcdata.doNotTryToPathfindTil = nil
	end
end

local function moveInCurrentDirectionPawn(frame, position, npcdata)
	local room = game:GetRoom()
	npcdata.currentGridIndexX, npcdata.currentGridIndexY = getPawnGridIndices(position)
	npcdata.nextGridIndexX, npcdata.nextGridIndexY = getPawnGridIndices(position + npcdata.currentDirection * 20)
	npcdata.frameLastDirectionGot = frame
	npcdata.doNotTryToPathfindTil = nil
end

local function getNextCheapestGrid(toBeChecked, costs, targetGrid)
	local estimatedCheapestGrid = nil
	local estimatedCheapestCost = 99999
	
	for i = 1, #toBeChecked do
		local grid = toBeChecked[i]
		local estimatedCost = costs[grid.X][grid.Y] + math.abs(targetGrid.X - grid.X) + math.abs(targetGrid.Y - grid.Y)
		
		if estimatedCost < estimatedCheapestCost then
			estimatedCheapestGrid = i
			estimatedCheapestCost = estimatedCost
		end
	end
	
	return estimatedCheapestGrid
end

local function moveTowardsPositionPawn(frame, position, targetPosition, npcdata)
	if not npcdata.imEternal then
		if frame < (npcdata.doNotTryToPathfindTil or 0) then
			return
		end
		npcdata.doNotTryToPathfindTil = frame + 20

		--A* pathfinding
		local npcGrid = getPawnGridIndicesVector(position)
		local startingGrid = getPawnGridIndicesVector(targetPosition)

		local costs = {}
		for i = 1, 60 do
			table.insert(costs, {})
		end
		costs[startingGrid.X][startingGrid.Y] = 0
		
		local toBeChecked = {startingGrid}
		while #toBeChecked > 0 do
			local nextCheapestGridIndex = getNextCheapestGrid(toBeChecked, costs, npcGrid)
			
			local currentGrid = toBeChecked[nextCheapestGridIndex]
			local currentGridCost = costs[currentGrid.X][currentGrid.Y]
			table.remove(toBeChecked, nextCheapestGridIndex)
			
			local nextGridUp = currentGrid + Vector(0,-1)
			local nextGridDown = currentGrid + Vector(0,1)
			local nextGridLeft = currentGrid + Vector(-1,0)
			local nextGridRight = currentGrid + Vector(1,0)
			
			if costs[nextGridUp.X][nextGridUp.Y] == nil and not pawnGridIsBlocked(nextGridUp.X, nextGridUp.Y) then
				costs[nextGridUp.X][nextGridUp.Y] = currentGridCost + 1
				table.insert(toBeChecked, nextGridUp)
			end
			if costs[nextGridDown.X][nextGridDown.Y] == nil and not pawnGridIsBlocked(nextGridDown.X, nextGridDown.Y) then
				costs[nextGridDown.X][nextGridDown.Y] = currentGridCost + 1
				table.insert(toBeChecked, nextGridDown)
			end
			if costs[nextGridLeft.X][nextGridLeft.Y] == nil and not pawnGridIsBlocked(nextGridLeft.X, nextGridLeft.Y) then
				costs[nextGridLeft.X][nextGridLeft.Y] = currentGridCost + 1
				table.insert(toBeChecked, nextGridLeft)
			end
			if costs[nextGridRight.X][nextGridRight.Y] == nil and not pawnGridIsBlocked(nextGridRight.X, nextGridRight.Y) then
				costs[nextGridRight.X][nextGridRight.Y] = currentGridCost + 1
				table.insert(toBeChecked, nextGridRight)
			end
			
			if (nextGridUp.X == npcGrid.X and nextGridUp.Y == npcGrid.Y) or
			(nextGridDown.X == npcGrid.X and nextGridDown.Y == npcGrid.Y) or
			(nextGridLeft.X == npcGrid.X and nextGridLeft.Y == npcGrid.Y) or
			(nextGridRight.X == npcGrid.X and nextGridRight.Y == npcGrid.Y)
			then
				break
			end
		end
		
		local potentialGridUp = npcGrid + Vector(0,-1)
		local potentialGridDown = npcGrid + Vector(0,1)
		local potentialGridLeft = npcGrid + Vector(-1,0)
		local potentialGridRight = npcGrid + Vector(1,0)
		
		local potentialGridUpCost = costs[potentialGridUp.X][potentialGridUp.Y] or 99999
		local potentialGridDownCost = costs[potentialGridDown.X][potentialGridDown.Y] or 99999
		local potentialGridLeftCost = costs[potentialGridLeft.X][potentialGridLeft.Y] or 99999
		local potentialGridRightCost = costs[potentialGridRight.X][potentialGridRight.Y] or 99999
		
		local closestGrid = potentialGridUp
		local closestGridCost = potentialGridUpCost
		
		if closestGridCost > potentialGridDownCost then
			closestGrid = potentialGridDown
			closestGridCost = potentialGridDownCost
		end
		
		if closestGridCost > potentialGridLeftCost then
			closestGrid = potentialGridLeft
			closestGridCost = potentialGridLeftCost
		end
		
		if closestGridCost > potentialGridRightCost then
			closestGrid = potentialGridRight
			closestGridCost = potentialGridRightCost
		end
		
		--for i = 1, 30 do
		--	for j = 1, 30 do
		--		if costs[i][j] ~= nil then
		--			local position = Isaac.WorldToRenderPosition(getPawnGridPosition(i, j))
		--			Isaac.RenderScaledText(costs[i][j], position.X, position.Y, 0.5, 0.5, 1, 1, 1, 0.5)
		--		end
		--	end
		--end
		
		if closestGridCost ~= 99999 then
			npcdata.currentDirection = closestGrid - npcGrid
			npcdata.currentDirectionProbability = 0
			
			npcdata.currentGridIndexX = npcGrid.X
			npcdata.currentGridIndexY = npcGrid.Y
			npcdata.nextGridIndexX = closestGrid.X
			npcdata.nextGridIndexY = closestGrid.Y
			npcdata.frameLastDirectionGot = frame
			npcdata.doNotTryToPathfindTil = nil
		elseif npcGrid.X % 2 ~= npcGrid.Y % 2 and not pawnGridIsBlocked(getPawnGridIndices(position + npcdata.currentDirection * 20)) then
			moveInCurrentDirectionPawn(frame, position, npcdata)
		else
			local nextGridUp = npcGrid + Vector(0,-1)
			local nextGridDown = npcGrid + Vector(0,1)
			local nextGridLeft = npcGrid + Vector(-1,0)
			local nextGridRight = npcGrid + Vector(1,0)
			
			local nextGridUpCost = math.abs(startingGrid.X - nextGridUp.X) + math.abs(startingGrid.Y - nextGridUp.Y)
			local nextGridDownCost = math.abs(startingGrid.X - nextGridDown.X) + math.abs(startingGrid.Y - nextGridDown.Y)
			local nextGridLeftCost = math.abs(startingGrid.X - nextGridLeft.X) + math.abs(startingGrid.Y - nextGridLeft.Y)
			local nextGridRightCost = math.abs(startingGrid.X - nextGridRight.X) + math.abs(startingGrid.Y - nextGridRight.Y)
			
			local closestGrid = nil
			local closestGridCost = 99999
			
			if not pawnGridIsBlocked(nextGridLeft.X, nextGridLeft.Y) and 
			(nextGridLeftCost < closestGridCost or (nextGridLeftCost == closestGridCost and math.random(2) == 1)) 
			then
				closestGrid = nextGridLeft
				closestGridCost = nextGridLeftCost
			end
			if not pawnGridIsBlocked(nextGridRight.X, nextGridRight.Y) and 
			(nextGridRightCost < closestGridCost or (nextGridRightCost == closestGridCost and math.random(2) == 1)) 
			then
				closestGrid = nextGridRight
				closestGridCost = nextGridRightCost
			end
			if not pawnGridIsBlocked(nextGridUp.X, nextGridUp.Y) and 
			(nextGridUpCost < closestGridCost or (nextGridUpCost == closestGridCost and math.random(2) == 1)) 
			then
				closestGrid = nextGridUp
				closestGridCost = nextGridUpCost
			end
			if not pawnGridIsBlocked(nextGridDown.X, nextGridDown.Y) and 
			(nextGridDownCost < closestGridCost or (nextGridDownCost == closestGridCost and math.random(2) == 1)) 
			then
				closestGrid = nextGridDown
				closestGridCost = nextGridDownCost
			end
			
			if closestGridCost ~= 99999 then
				npcdata.currentDirection = closestGrid - npcGrid
				npcdata.currentDirectionProbability = 0
				
				npcdata.currentGridIndexX = npcGrid.X
				npcdata.currentGridIndexY = npcGrid.Y
				npcdata.nextGridIndexX = closestGrid.X
				npcdata.nextGridIndexY = closestGrid.Y
				npcdata.frameLastDirectionGot = frame
				npcdata.doNotTryToPathfindTil = nil
			end
		end
	end
end

local function retreatFromPositionPawn(frame, position, targetPosition, npcdata)
	local npcGrid = getPawnGridIndicesVector(position)
		
	local nextGridUp = npcGrid + Vector(0,-1)
	local nextGridDown = npcGrid + Vector(0,1)
	local nextGridLeft = npcGrid + Vector(-1,0)
	local nextGridRight = npcGrid + Vector(1,0)
	
	local furthestGrid = nil
	local furthestGridDist = -99999
	
	if not pawnGridIsBlocked(nextGridUp.X, nextGridUp.Y) then
		local dist = (getPawnGridPosition(nextGridUp.X, nextGridUp.Y) - targetPosition):Length()
		if dist > furthestGridDist then
			furthestGrid = nextGridUp
			furthestGridDist = dist
		end
	end
	if not pawnGridIsBlocked(nextGridDown.X, nextGridDown.Y) then
		local dist = (getPawnGridPosition(nextGridDown.X, nextGridDown.Y) - targetPosition):Length()
		if dist > furthestGridDist then
			furthestGrid = nextGridDown
			furthestGridDist = dist
		end
	end
	if not pawnGridIsBlocked(nextGridLeft.X, nextGridLeft.Y) then
		local dist = (getPawnGridPosition(nextGridLeft.X, nextGridLeft.Y) - targetPosition):Length()
		if dist > furthestGridDist then
			furthestGrid = nextGridLeft
			furthestGridDist = dist
		end
	end
	if not pawnGridIsBlocked(nextGridRight.X, nextGridRight.Y) then
		local dist = (getPawnGridPosition(nextGridRight.X, nextGridRight.Y) - targetPosition):Length()
		if dist > furthestGridDist then
			furthestGrid = nextGridRight
			furthestGridDist = dist
		end
	end
	
	if furthestGridDist ~= -99999 then
		npcdata.currentDirection = furthestGrid - npcGrid
		npcdata.currentDirectionProbability = 0
		
		npcdata.currentGridIndexX = npcGrid.X
		npcdata.currentGridIndexY = npcGrid.Y
		npcdata.nextGridIndexX = furthestGrid.X
		npcdata.nextGridIndexY = furthestGrid.Y
		npcdata.frameLastDirectionGot = frame
		npcdata.doNotTryToPathfindTil = nil
	end
end

function mod:pawnAI(npc, sprite, npcdata)
	if npc.SubType == 10 then
		mod:kingCordHitboxAI(npc, sprite, npcdata)
		return
	end
	
	if not npcdata.init then
		npcdata.State = "Wander"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		
		if not npc.Parent then
			local shortestDist = 99999
			local kings = Isaac.FindByType(mod.FF.King.ID, mod.FF.King.Var, -1)
			for _, king in ipairs(kings) do
				local dist = (king.Position - npc.Position):Length()
				if dist < shortestDist then
					shortestDist = dist
					npc.Parent = king
				end
			end
			
			if npc.Parent then
				local kingdata = npc.Parent:GetData()
				kingdata.Pawns = kingdata.Pawns or {}
				table.insert(kingdata.Pawns, npc)
			end
		end
		
		npcdata.init = true
	end
	
	if not npc.Parent or 
	   not npc.Parent:Exists() or 
	   npc.Parent:IsDead() or 
	   mod:isStatusCorpse(npc.Parent) or 
	   npc.Parent.Type ~= mod.FF.King.ID or 
	   npc.Parent.Variant ~= mod.FF.King.Var 
	then
		npc:Kill()
		return
	end
	
	if not npc.Child or 
	   not npc.Child:Exists() 
	then
		local cord = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 23, npc.Position, nilvector, nil)
		cord:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        
		cord.Parent = npc.Parent
		cord.Target = npc
		
		npc.Child = cord
		cord.DepthOffset = -20
		
		cord:GetSprite():Play("Idle", true)
		cord:GetSprite():SetFrame(105)
		cord:Update()
		
		cord.SplatColor = Color(1,1,1,1,0,0,0)
	end
	
	local room = game:GetRoom()
	local gridX, gridY = getPawnGridIndices(npc.Position)
	
	if npc.Parent:ToNPC().StateFrame > 75 and mod:RandomInt(1,10,npc:GetDropRNG()) == 1 and npcdata.State == "Wander" then
		local target = npc:GetPlayerTarget()
		
		if (target.Position - npc.Position):Length() <= 400 then
			local targetAngle = (target.Position - npc.Position):GetAngleDegrees()
		
			if targetAngle < 0 then 
				targetAngle = targetAngle + 360 
			end
			
			local chargeDirection = nil
			if math.abs(targetAngle) < 5 or math.abs(targetAngle - 360) < 5 then
				if npc.Parent.Position.X < npc.Position.X or math.abs(npc.Position.Y - npc.Parent.Position.Y) > npc.Parent.Size + npc.Size * 2 then
					local pawns = npc.Parent:GetData().Pawns
					local blocked = false
					for i = 1, #pawns do
						local pawn = pawns[i]
						if pawn.Index ~= npc.Index and
						   pawn.InitSeed ~= npc.InitSeed and
						   pawn:Exists() and
						   pawn.Position.X >= npc.Position.X and 
						   math.abs(npc.Position.Y - pawn.Position.Y) <= pawn.Size + npc.Size * 2 
						then
							blocked = true
							break
						end
					end
					
					if not blocked then
						chargeDirection = Vector(1,0)
					end
				end
			elseif math.abs(targetAngle - 90) < 5 then
				if npc.Parent.Position.Y < npc.Position.Y or math.abs(npc.Position.X - npc.Parent.Position.X) > npc.Parent.Size + npc.Size * 2 then
					local pawns = npc.Parent:GetData().Pawns
					local blocked = false
					for i = 1, #pawns do
						local pawn = pawns[i]
						if pawn.Index ~= npc.Index and
						   pawn.InitSeed ~= npc.InitSeed and
						   pawn:Exists() and
						   pawn.Position.Y >= npc.Position.Y and 
						   math.abs(npc.Position.X - pawn.Position.X) <= pawn.Size + npc.Size * 2
						then
							blocked = true
							break
						end
					end
					
					if not blocked then
						chargeDirection = Vector(0,1)
					end
				end
			elseif math.abs(targetAngle - 180) < 5 then
				if npc.Parent.Position.X > npc.Position.X or math.abs(npc.Position.Y - npc.Parent.Position.Y) > npc.Parent.Size + npc.Size * 2 then
					local pawns = npc.Parent:GetData().Pawns
					local blocked = false
					for i = 1, #pawns do
						local pawn = pawns[i]
						if pawn.Index ~= npc.Index and
						   pawn.InitSeed ~= npc.InitSeed and
						   pawn:Exists() and
						   pawn.Position.X <= npc.Position.X and 
						   math.abs(npc.Position.Y - pawn.Position.Y) <= pawn.Size + npc.Size * 2 
						then
							blocked = true
							break
						end
					end
					
					if not blocked then
						chargeDirection = Vector(-1,0)
					end
				end
			elseif math.abs(targetAngle - 270) < 5 then
				if npc.Parent.Position.Y > npc.Position.Y or math.abs(npc.Position.X - npc.Parent.Position.X) > npc.Parent.Size + npc.Size * 2 then
					local pawns = npc.Parent:GetData().Pawns
					local blocked = false
					for i = 1, #pawns do
						local pawn = pawns[i]
						if pawn.Index ~= npc.Index and
						   pawn.InitSeed ~= npc.InitSeed and
						   pawn:Exists() and
						   pawn.Position.Y <= npc.Position.Y and 
						   math.abs(npc.Position.X - pawn.Position.X) <= pawn.Size + npc.Size * 2
						then
							blocked = true
							break
						end
					end
					
					if not blocked then
						chargeDirection = Vector(0,-1)
					end
				end
			end
			
			if chargeDirection ~= nil and room:CheckLine(npc.Position, target.Position, 0) then
				npc.Parent:ToNPC().StateFrame = 0
				npcdata.State = "Charge"
				
				npcdata.currentDirection = chargeDirection
				npcdata.currentDirectionProbability = 0
				
				npcdata.currentGridIndexX = gridX
				npcdata.currentGridIndexY = gridY
				npcdata.nextGridIndexX = gridX + chargeDirection.X
				npcdata.nextGridIndexY = gridY + chargeDirection.Y
				npcdata.frameLastDirectionGot = npc.FrameCount
			end
		end
	end
	
	if npcdata.State ~= "Charge" then
		if pawnTileOutsideRadius(gridX, gridY, npc.Parent.Position, 90) then
			npcdata.State = "Return"
		elseif pawnTileInsideRadius(gridX, gridY, npc.Parent.Position, 40) then
			npcdata.State = "Retreat"
		else
			npcdata.State = "Wander"
		end
	end
	
	if npcdata.currentDirection == nil then
		if npcdata.State == "Wander" then
			getNewWanderDirectionPawn(npc.FrameCount, npc.Position, npcdata, npc.Parent.Position)
		elseif npcdata.State == "Return" then
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		elseif npcdata.State == "Retreat" then
			retreatFromPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		else
			npcdata.State = "Return"
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		end
	elseif pawnGridIsBlocked(npcdata.nextGridIndexX, npcdata.nextGridIndexY) or 
	       (npcdata.State == "Wander" and not pawnTileWithinRing(npcdata.nextGridIndexX, npcdata.nextGridIndexY, npc.Parent.Position, 40, 90))
	then
		if npcdata.State == "Wander" then
			getNewWanderDirectionPawn(npc.FrameCount, npc.Position, npcdata, npc.Parent.Position)
		elseif npcdata.State == "Return" then
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		elseif npcdata.State == "Retreat" then
			retreatFromPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		else
			npcdata.State = "Return"
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		end
	elseif npc.FrameCount - npcdata.frameLastDirectionGot > 20 then
		if npcdata.State == "Wander" then
			getNewWanderDirectionPawn(npc.FrameCount, npc.Position, npcdata, npc.Parent.Position, npcdata.currentDirection)
		elseif npcdata.State == "Return" then
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		elseif npcdata.State == "Retreat" then
			retreatFromPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		else
			npcdata.State = "Return"
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		end
	elseif (gridX ~= npcdata.currentGridIndexX or gridY ~= npcdata.currentGridIndexY) and
	       (gridX ~= npcdata.nextGridIndexX or gridY ~= npcdata.nextGridIndexY)
	then
		if npcdata.State == "Wander" then
			getNewWanderDirectionPawn(npc.FrameCount, npc.Position, npcdata, npc.Parent.Position)
		elseif npcdata.State == "Return" then
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		elseif npcdata.State == "Retreat" then
			retreatFromPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		else
			npcdata.State = "Return"
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		end
	elseif npcdata.State ~= "Charge" and
	       math.abs(npc.Position.X - getPawnGridPosition(npcdata.nextGridIndexX, npcdata.nextGridIndexY).X) <= 3.1 and 
		   math.abs(npc.Position.Y - getPawnGridPosition(npcdata.nextGridIndexX, npcdata.nextGridIndexY).Y) <= 3.1
	then
		if npcdata.State == "Wander" then
			npcdata.currentDirectionProbability = npcdata.currentDirectionProbability * 0.95
			if pawnGridIsBlocked(getPawnGridIndices(npc.Position + npcdata.currentDirection * 20)) or math.random() > npcdata.currentDirectionProbability then
				getNewWanderDirectionPawn(npc.FrameCount, npc.Position, npcdata, npc.Parent.Position)
			else
				moveInCurrentDirectionPawn(npc.FrameCount, npc.Position, npcdata)
			end
		elseif npcdata.State == "Return" then
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		elseif npcdata.State == "Retreat" then
			retreatFromPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		end
	elseif npcdata.State == "Charge" and
	       math.abs(npc.Position.X - getPawnGridPosition(npcdata.nextGridIndexX, npcdata.nextGridIndexY).X) <= 6.1 and 
		   math.abs(npc.Position.Y - getPawnGridPosition(npcdata.nextGridIndexX, npcdata.nextGridIndexY).Y) <= 6.1
	then
		if pawnGridIsBlocked(getPawnGridIndices(npc.Position + npcdata.currentDirection * 20)) then
			npcdata.State = "Return"
			moveTowardsPositionPawn(npc.FrameCount, npc.Position, npc.Parent.Position, npcdata)
		else
			moveInCurrentDirectionPawn(npc.FrameCount, npc.Position, npcdata)
		end
	end
	
	if npcdata.currentDirection then
		local vel = getPawnGridPosition(npcdata.nextGridIndexX, npcdata.nextGridIndexY) - npc.Position
		if npcdata.State == "Charge" then
			vel = vel:Resized(math.min(6.0, vel:Length()))
		else
			vel = vel:Resized(math.min(3.0, vel:Length()))
		end
		
		npc.Velocity = vel * 0.8 + npc.Velocity * 0.2
	else
		npc.Velocity = Vector(0,0)
	end
	
    if npc.Velocity:Length() > 1 then
        npc:AnimWalkFrame("WalkHori", "WalkVert", 0)
		if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
			sprite:PlayOverlay("HeadHori")
		elseif npc.Velocity.Y < 0 then
			sprite:PlayOverlay("HeadUp")
		else
			sprite:PlayOverlay("HeadDown")
		end
    else
        sprite:SetFrame("WalkVert", 0)
		sprite:PlayOverlay("HeadDown")
    end
	
	mod:handleKingCordHitboxes(npc, npc.Parent, npc.Child)
end

function mod:pawnCollision(npc, collider, low)
	if npc.SubType == 10 then
		return mod:kingCordHitboxCollision(npc, collider, low)
	end
	
	if not npc.Parent or 
	   not npc.Parent:Exists() or 
	   npc.Parent:IsDead() or 
	   mod:isStatusCorpse(npc.Parent) or 
	   npc.Parent.Type ~= mod.FF.King.ID or 
	   npc.Parent.Variant ~= mod.FF.King.Var 
	then
		return
	end
	
	if collider.Type == mod.FF.Pawn.ID and collider.Variant == mod.FF.Pawn.Var then
		local npcdata = npc:GetData()
		if npcdata.State == "Wander" and npcdata.currentDirection then
			npcdata.currentDirection = npcdata.currentDirection * -1
			moveInCurrentDirectionPawn(npc.FrameCount, npc.Position, npcdata)
			npcdata.currentDirectionProbability = 1.0
		elseif npcdata.State == "Return" and npcdata.currentDirection then
			npcdata.currentDirection = npcdata.currentDirection * -1
			moveInCurrentDirectionPawn(npc.FrameCount, npc.Position, npcdata)
			npcdata.currentDirectionProbability = 0.0
		end
	end
end

-- King Cord --
function mod:handleKingCordHitboxes(pawn, king, cord)
	if not (not pawn or 
	        not pawn:Exists() or 
	        pawn:IsDead() or 
	        mod:isStatusCorpse(pawn) or
	        not king or 
	        not king:Exists() or 
	        king:IsDead() or 
	        mod:isStatusCorpse(king) or
	        not cord or 
	        not cord:Exists() or 
	        cord:IsDead() or 
	        mod:isStatusCorpse(cord))
	then
		local pawndata = pawn:GetData()
		
		pawndata.Hitboxes = pawndata.Hitboxes or {}
		local dist = (pawn.Position - king.Position):Length() - 30
		
		local i = 1
		while dist >= 0 do
			local hitbox = pawndata.Hitboxes[i]
			if not hitbox or not hitbox:Exists() then
				hitbox = Isaac.Spawn(mod.FF.Pawn.ID, mod.FF.Pawn.Var, 10, nilvector, nilvector, nil)
				pawndata.Hitboxes[i] = hitbox
				hitbox.Parent = pawn
				hitbox.Child = cord
				
				hitbox:Update()
			end
			
			hitbox.Position = (pawn.Position - king.Position):Resized(dist) + king.Position
			dist = dist - 30
			i = i + 1
		end
		
		for j = #pawndata.Hitboxes, i, -1 do
			pawndata.Hitboxes[j]:Remove()
			pawndata.Hitboxes[j] = nil
		end
	end
end

function mod:kingCordHitboxAI(npc, sprite, npcdata)
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	npc.Visible = false
	npc.Velocity = nilvector
	npc:GetSprite().Color = Color(1,1,1,0,0,0,0)
	
	if not npc.Parent or 
	   not npc.Parent:Exists() or 
	   npc.Parent:IsDead() or 
	   mod:isStatusCorpse(npc.Parent) or 
	   npc.Parent.Type ~= mod.FF.Pawn.ID or 
	   npc.Parent.Variant ~= mod.FF.Pawn.Var 
	then
		npc:Kill()
	end
end

function mod:kingCordHitboxCollision(npc, collider, low)
	if collider.Type == EntityType.ENTITY_PLAYER then
		return true
	end
end

function mod:pawnTakeDmg(entity, damage, flags, source, countdown)
	if entity.SubType == 10 and entity.Child and damage > 0.0 then
		entity.Child:TakeDamage(damage, flags, source, countdown)
		entity.Child:GetData().LastDamageFrame = entity.Child.FrameCount
		return false
	elseif entity.SubType ~= 10 then
		return false
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, cord)
	if cord.Variant == 10 and cord.SubType == 23 then
		local data = cord:GetData()
		local sprite = cord:GetSprite()
		
		local frame = sprite:GetFrame()
		if data.LastDamageFrame == nil or cord.FrameCount - data.LastDamageFrame > 2 then
			sprite:SetFrame("Idle", frame)
		else
			sprite:SetFrame("DamageFlash", frame)
		end
	end
end, EntityType.ENTITY_EVIS)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
	if entity.Variant == 10 and entity.SubType == 23 and entity.Target and entity.Target.Type == 120 then
		entity.Target:Kill()
	end
end, EntityType.ENTITY_EVIS)
