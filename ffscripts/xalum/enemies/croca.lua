local mod = FiendFolio
local game = Game()

--[[ SubTypes
	0: Facing Left
	1: Facing Up
	2: Facing Right
	3: Facing Down
]]

local function shouldCharge(npc, facing)
	if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) and npc.FrameCount == 1 then
		return false
	end

	for i = 20, 140, 60 do
		local room = game:GetRoom()
		local targetEntity = npc:GetPlayerTarget()
		local validTargetPosition = targetEntity.Position:Distance(npc.Position + facing * i) < 60
		local hasLineOfSight = room:CheckLine(npc.Position, targetEntity.Position, 0)

		if validTargetPosition and hasLineOfSight then
			return true
		end
	end
end

local function shouldCharge2(npc)
	local targetAngle = math.abs((npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()) % 90

	if targetAngle < 15 or targetAngle > 85 then
		return true
	end
end

local function getStalkSubType(npc)
	local targetAngle = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()

	if math.abs(targetAngle) > 135 then
		npc.SubType = 0
	elseif math.abs(targetAngle) < 45 then
		npc.SubType = 2
	elseif targetAngle > 0 then
		npc.SubType = 3
	else
		npc.SubType = 1
	end
end

local function getIdleSubType(npc, newGridPosition)
	local targetAngle = (npc.Position - newGridPosition):GetAngleDegrees()

	if math.abs(targetAngle) > 135 then
		npc.SubType = 0
	elseif math.abs(targetAngle) < 45 then
		npc.SubType = 2
	elseif targetAngle > 0 then
		npc.SubType = 3
	else
		npc.SubType = 1
	end
end

return {
	Init = function(npc)
		local data = npc:GetData()
		data.state = "idle"

		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 42)

		data.slideDirection = data.rng:RandomInt(2) * 180 - 90

		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end,	
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)

		local facing = Vector(-1, 0):Rotated(npc.SubType * 90)
		local animationDirection = "Hori"
		if npc.SubType == 1 then
			animationDirection = "Up"
		elseif npc.SubType == 3 then
			animationDirection = "Down"
		end

		sprite.FlipX = npc.SubType == 2

		if data.state == "idle" then
			sprite:Play("Idle" .. animationDirection)

			local gridlock = -facing
			local shifting = facing:Rotated(data.slideDirection)

			local room = game:GetRoom()
			local behindDistance = npc.SubType % 2 == 1 and 20 or 40

			local behindGrid = room:GetGridEntityFromPos(npc.Position + gridlock:Resized(behindDistance))
			local sideGrid = room:GetGridEntityFromPos(npc.Position + shifting:Resized(20))
			local diagonalGrid = room:GetGridEntityFromPos(npc.Position + shifting:Resized(20) + gridlock:Resized(40))

			local supported = behindGrid and behindGrid.CollisionClass ~= GridCollisionClass.COLLISION_NONE
			local blocked = sideGrid and sideGrid.CollisionClass ~= GridCollisionClass.COLLISION_NONE
			local supportedDiagonally = diagonalGrid and diagonalGrid.CollisionClass ~= GridCollisionClass.COLLISION_NONE

			local edging = supported and not blocked and not supportedDiagonally

			if supported then
				gridlock = Vector.Zero
			end

			if blocked or edging then
				data.slideDirection = -data.slideDirection
				shifting = -shifting
			end

			local targetVelocity = shifting:Resized(1) + gridlock:Resized(0.75)
			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.1)

			if npc.FrameCount % 30 == 0 and math.random() < 1/5 then
				npc:PlaySound(mod.Sounds.CrocaIdle, 4, 0, false, 1)
			end

			if shouldCharge(npc, facing) then
				data.state = "charge1"
				data.chargeDirection = facing * 12
				data.chargeFrame = npc.FrameCount
				data.firstChargeSubType = npc.SubType

				npc:PlaySound(mod.Sounds.CrocaCharge, 2.75, 0, false, 1.15)
			end
		elseif data.state == "charge1" then
			sprite:Play("Charge" .. animationDirection)
			npc.Velocity = mod.XalumLerp(npc.Velocity, data.chargeDirection, 0.2)

			if npc.FrameCount - data.chargeFrame >= 30 then
				data.state = "stalk"
			end
		elseif data.state == "stalk" then
			sprite:Play("Idle" .. animationDirection)

			local targetEntity = npc:GetPlayerTarget()
			local targetPosition = (npc.Position - targetEntity.Position):Resized(100) + targetEntity.Position
			local targetVelocity = targetPosition - npc.Position
			targetVelocity:Resize(math.min(4, targetVelocity:Length()))

			getStalkSubType(npc)

			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.1)

			if shouldCharge2(npc) and npc.SubType ~= data.firstChargeSubType then
				data.state = "prepareCharge2"
				data.prepareFrame = npc.FrameCount

				--npc:PlaySound(mod.Sounds.CrocaIdle, 3, 0, false, 0.7)
			end
		elseif data.state == "prepareCharge2" then
			sprite:Play("Idle" .. animationDirection)

			local targetPosition = mod.XalumAlignPositionToGrid(npc.Position)
			local targetVelocity = (targetPosition - npc.Position)
			targetVelocity:Resize(math.min(4, targetVelocity:Length()))

			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.3)

			if npc.FrameCount - data.prepareFrame >= 20 then
				data.state = "charge2"
				data.chargeDirection = facing * 15

				npc:PlaySound(mod.Sounds.CrocaCharge, 2.75, 0, false, 1.15)
			end
		elseif data.state == "charge2" then
			sprite:Play("Charge" .. animationDirection)
			npc.Velocity = mod.XalumLerp(npc.Velocity, data.chargeDirection, 0.2)

			local room = game:GetRoom()
			local targetCollision = room:GetGridCollisionAtPos(npc.Position + facing * 60)
			if targetCollision ~= GridCollisionClass.COLLISION_NONE then
				data.state = "idle"
				getIdleSubType(npc, npc.Position + facing * 60)
			end
		end
	end,
}