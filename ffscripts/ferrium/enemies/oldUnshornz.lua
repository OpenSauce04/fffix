local mod = FiendFolio
local game = Game()

function mod:unshornzAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local room = game:GetRoom()
	local rand = npc:GetDropRNG()
	
	if not data.init then
		data.recordParent = {}
		if not data.setStats then
			if npc.SubType % 8 == 0 then
				data.wHMovementDir = Vector(0,1):Rotated(rand:RandomInt(4)*90)
			else
				data.wHMovementDir = Vector(0,1):Rotated((npc.SubType%8)*90) --Left, up, right, down
			end
			if math.floor((npc.SubType%16)/8) == 0 then
				data.wHMovementRotDir = 90
			elseif math.floor((npc.SubType%16)/8) == 1 then
				data.check = true
				data.wHMovementRotDir = -90
			end
		end
		if math.floor(npc.SubType/16) == 1 then
			data.trueLeader = true
		end
		
		data.state = "Appear"
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		data.randomSprite = rand:RandomInt(3)+1
		sprite:Play("Appear0" .. data.randomSprite)
		Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		data.init = true
	end
	
	--[[if data.leadingMember then
		npc:SetColor(Color(1,1,1,1,1,0,0), 999, 1, false, false)
	end]]
	--[[if npc.wHMovementRotDir == 90 then
		npc:SetColor(Color(1,1,1,1,0,1,0), 999, 1, false, false)
	else
		npc:SetColor(Color(1,1,1,1,0,0,1), 999, 1, false, false)
	end]]
	
	if (npc.I1 == 0 and npc.FrameCount > 1) or data.trueLeader then -- Thank you Xalum for the Ossularry code
		if not npc.Child and not data.leadingMember then
			data.leadingMember = true

			local curr = npc
			while curr do
				local did
				local closest
				local dist = 60

				for _, ent in pairs (Isaac.FindByType(npc.Type, npc.Variant, -1)) do
					if ent.Position:Distance(curr.Position) < dist and not ent:GetData().leadingMember and ent:ToNPC().I1 == 0 and math.floor(ent.SubType/16) == 0 then
						closest = ent
						dist = ent.Position:Distance(curr.Position)
					end
				end

				if closest then
					did = true
					
					local cData = closest:GetData()
					curr.Child = closest
					cData.wHMovementDir = curr:GetData().wHMovementDir
					cData.wHMovementRotDir = curr:GetData().wHMovementRotDir
					cData.setStats = true
					closest.Parent = curr
					closest:ToNPC().I1 = closest:ToNPC().I1+1
					curr = closest
				end

				if not did then
					curr = nil 
				end
			end
		end
		
		mod:wallHuggerMovement(npc, 4.8)
		
		--[[if data.state == "Rotate" then
			local gridCheck = mod:unshornzGrid(npc, 0, data.dir:Rotated(data.rotDir))
			local directGrid = mod:unshornzGrid(npc, 1, data.dir)
			
			if directGrid ~= nil then
				data.gridPos = directGrid
				data.turning = nil
			end
			
			if directGrid == nil and room:GetGridCollisionAtPos(data.gridPos) == GridCollisionClass.COLLISION_NONE and gridCheck == nil then
				data.dir = -1*data.dir
				data.state = "SearchingStraight"
			elseif directGrid == nil and npc.Position:Distance(data.gridPos) > 42 and not data.turning then
				data.dir = data.dir:Rotated(-data.rotDir)
				npc.Velocity = Vector.Zero
				data.turning = true
			elseif gridCheck == nil or npc.Position:Distance(gridCheck) > 45 then
				data.targetPos = data.targetPos+data.dir:Rotated(data.rotDir):Resized(4)
			elseif npc.Position:Distance(gridCheck) <= 45 then
				data.gridPos = gridCheck
				data.dir = data.dir:Rotated(data.rotDir)
				npc.Velocity = Vector.Zero
			end
			npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position), 0.7)
		elseif data.state == "SearchingStraight" then
			npc.Velocity = mod:Lerp(npc.Velocity, data.dir:Resized(4), 0.3)
			local gridCheck = mod:unshornzGrid(npc, 0, data.dir)
			if gridCheck ~= nil and npc.Position:Distance(gridCheck) < 40 then
				data.gridPos = gridCheck
				data.targetPos = data.gridPos-data.dir:Resized(40)
				data.state = "Rotate"
			end
		end]]
	elseif npc.FrameCount > 1 then
		if npc.Parent then
			local pData = npc.Parent:GetData()
			if npc.Parent:IsDead() or FiendFolio:isStatusCorpse(npc.Parent) then
				data.leadingMember = true
				npc.I1 = 0
				data.wHMovementState = "SearchingStraight"
				data.breakPoint = npc.Position
				data.wHMovementDir = -1*pData.wHMovementDir
			end
			
			--[[local speed = 4.8
			if npc.Position:Distance(npc.Parent.Position) > 45 then
				speed = 5.2
			elseif npc.Position:Distance(npc.Parent.Position) < 35 then
				speed = 4.4
			end]]
			
			table.insert(data.recordParent, {position = npc.Parent.Position, velocity = npc.Parent.Velocity})
			if #data.recordParent > 15 then
				table.remove(data.recordParent, 1)
			end
			
			if #data.recordParent > 13 then
				npc.TargetPosition = mod:Lerp(npc.Position, data.recordParent[13].position, 0.2)
				npc.Velocity = npc.TargetPosition - npc.Position
			end
			
			--[[if pData.breakPoint ~= nil then
				if npc.Position:Distance(pData.breakPoint) < 5 then
					npc.Position = pData.breakPoint
					data.wHMovementState = "SearchingStraight"
					if npc.Child then
						data.breakPoint = npc.Position
					end
					data.wHMovementDir = -1*data.wHMovementDir
					pData.breakPoint = nil
				end
			end
			
			local hangingoutwithmyfriends -- :)
			if pData.wHMovementState == "SearchingStraight" and data.wHMovementState == "SearchingStraight" then
				hangingoutwithmyfriends = true -- :D
			end
			
			mod:wallHuggerMovement(npc, speed)
			
			if hangingoutwithmyfriends == true and data.wHMovementState ~= "SearchingStraight" then
				hangingoutwithmyfriends = false -- :(
				data.leadingMember = true
				npc.I1 = 0
				if npc.Child then
					npc.Child:GetData().specialBreakup = true
					npc.Child.Parent = nil
				end
			end
			
			if npc.Position:Distance(npc.Parent.Position) > 150 then
				data.leadingMember = true
				npc.I1 = 0
			end]]
			
			--[[if data.wHMovementState == "SearchingStraight" and not data.leadingMember then
				if npc.Parent:GetData().wHMovementState == "SearchingStraight" then
					data.lastKnownPos = npc.Parent.Position
				elseif data.lastKnownPos == nil then
					data.lastKnownPos = npc.Parent.Position
				end
				if math.abs(data.wHMovementDir.X) > math.abs(data.wHMovementDir.Y) then
					npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity+Vector(0, data.lastKnownPos.Y-npc.Position.Y)*0.7, 0.3)
				else
					npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity+Vector(data.lastKnownPos.X-npc.Position.X, 0)*0.7, 0.3)
				end
			end]]
		else
			data.leadingMember = true
			npc.I1 = 0
			if not data.specialBreakup then
				data.wHMovementState = "SearchingStraight"
				data.breakPoint = npc.Position
				data.wHMovementDir = -1*data.wHMovementDir
			end
		end
	end
	
	
	if data.state == "Appear" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Appear0" .. data.randomSprite) or npc.FrameCount > 15 then
			mod:wallHuggerMovement(npc, 4, "Init")
			sprite:Play("Idle0" .. data.randomSprite)
			
			data.state = "NothingLeft"
		end
	end
end

--Kinda designed for later enemies too, but will need tweaking for different size enemies/etc. Also just messy.
function mod:wallHuggerMovement(npc, speed, state, dir, rotationDir) --dir is the direction pointing inwards to whatever it's hugging. Leave blank for random direction.
	local room = game:GetRoom()
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	
	--[[local printTest
	if data.leadingMember then
		printTest = true
	end]]
	
	if not data.wHMovementState then
		data.wHMovementState = "Init"
	end
	if state ~= nil then
		data.wHMovementState = state
	end
	if dir ~= nil then
		data.wHMovementDir = dir
	end
	if rotationDir ~= nil then
		data.wHMovementRotDir = rotationDir
	end

	if data.wHMovementState == "Rotate" then
		local gridCheck = mod:unshornzGrid(npc, 0, data.wHMovementDir:Rotated(data.wHMovementRotDir))
		local directGrid = mod:unshornzGrid(npc, 1, data.wHMovementDir)
			
		if directGrid ~= nil then
			data.wHMovementGridPos = directGrid
			data.wHMovementTurning = nil
		end
			
		if directGrid == nil and room:GetGridCollisionAtPos(data.wHMovementGridPos) == GridCollisionClass.COLLISION_NONE and gridCheck == nil then
			data.wHMovementDir = -1*data.wHMovementDir
			data.wHMovementState = "SearchingStraight"
		elseif directGrid == nil and (npc.Position:Distance(room:GetGridPosition(room:GetGridIndex(npc.Position))) < 8) and not data.wHMovementTurning then
			data.wHMovementDir = data.wHMovementDir:Rotated(-data.wHMovementRotDir)
			--npc.Position = room:GetGridPosition(room:GetGridIndex(npc.Position))
			npc.Velocity = Vector.Zero
			data.wHMovementTurning = true
		elseif gridCheck == nil or npc.Position:Distance(gridCheck) > 45 then
			data.wHMovementTargetPos = data.wHMovementTargetPos+data.wHMovementDir:Rotated(data.wHMovementRotDir):Resized(speed)
		elseif npc.Position:Distance(gridCheck) <= 45 then
			data.wHMovementGridPos = gridCheck
			data.wHMovementDir = data.wHMovementDir:Rotated(data.wHMovementRotDir)
			npc.Velocity = Vector.Zero
		end
		npc.Velocity = mod:Lerp(npc.Velocity, (data.wHMovementTargetPos-npc.Position), 0.6)
	elseif data.wHMovementState == "SearchingStraight" then
		npc.Velocity = mod:Lerp(npc.Velocity, data.wHMovementDir:Resized(speed), 0.3)
		local gridCheck = mod:unshornzGrid(npc, 0, data.wHMovementDir)
		if gridCheck ~= nil and npc.Position:Distance(gridCheck) < 40 then
			data.wHMovementGridPos = gridCheck
			if math.abs(data.wHMovementDir.X) > math.abs(data.wHMovementDir.Y) then
				data.wHMovementTargetPos = Vector(data.wHMovementGridPos.X-data.wHMovementDir:Resized(40).X, npc.Position.Y)
			else
				data.wHMovementTargetPos = Vector(npc.Position.X, data.wHMovementGridPos.Y-data.wHMovementDir:Resized(40).Y)
			end
			--npc.Position = data.wHMovementTargetPos
			data.wHMovementState = "Rotate"
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
		end
	elseif data.wHMovementState == "Init" then
		if dir == nil and data.wHMovementDir == nil then
			data.wHMovementDir = Vector(0,1):Rotated(rand:RandomInt(4)*90)
		end
		if rotationDir == nil and data.wHMovementRotDir == nil then --Clockwise
			data.wHMovementRotDir = -90
		end
		data.wHMovementGridPos = mod:unshornzGrid(npc, 0, data.wHMovementDir)
		data.wHMovementTargetPos = npc.Position
		
		if data.wHMovementGridPos == nil then
			data.wHMovementState = "SearchingStraight"
		else
			data.wHMovementState = "Rotate"
		end
	end
end

function mod:unshornzGrid(npc, mode, dir)
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	local foundGrid = nil
	
	if mode == 0 then --Center of the grid
		local gridIndex = room:GetGridIndex(npc.Position+dir:Resized(40))
		local gridColl = room:GetGridCollision(gridIndex)
		if gridColl == GridCollisionClass.COLLISION_SOLID or gridColl == GridCollisionClass.COLLISION_WALL then
			foundGrid = room:GetGridPosition(gridIndex)
		end
	elseif mode == 1 then --Based off of npc position
		local gridPos = npc.Position+dir:Resized(40)
		local gridColl = room:GetGridCollisionAtPos(gridPos)
		if gridColl == GridCollisionClass.COLLISION_SOLID or gridColl == GridCollisionClass.COLLISION_WALL then
			foundGrid = gridPos
		end
	end
	
	return foundGrid
end

function mod:unshornzColl(npc, coll, bool)
	if npc.Variant == mod.FF.Unshornz.Var then
		if (coll.Type == mod.FFID.Ferrium and coll.Variant == mod.FF.Unshornz.Var) or coll.Type == 40 or coll.Type == 218 or coll.Type == 862 then
			return true
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.unshornzColl, mod.FFID.Ferrium)