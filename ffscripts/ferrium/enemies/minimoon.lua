local mod = FiendFolio

function mod:minimoonAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()

	if not data.init then
		data.state = "Idle"
		if npc.SubType > 0 then
			data.velDir = Vector.Zero
			data.velDir = Vector(0,-5):Rotated(45+90*npc.SubType)
			npc.Velocity = mod:Lerp(npc.Velocity, data.velDir, 0.4)
			if data.velDir.X > 0 then
				data.xState = true
			else
				data.xState = false
			end
			if data.velDir.Y > 0 then
				data.yState = true
			else
				data.yState = false
			end
		else
			data.velDir = Vector(5,0):Rotated(45+90*math.random(5))
			npc.Velocity = mod:Lerp(npc.Velocity, data.velDir, 0.4)
			if data.velDir.X > 0 then
				data.xState = true
			else
				data.xState = false
			end
			if data.velDir.Y > 0 then
				data.yState = true
			else
				data.yState = false
			end
		end
		npc.StateFrame = 40
		data.rotDir = 1
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	mod:spritePlay(sprite, "Idle")
	if data.state == "Idle" then
		local minimoonTarget = mod.minimoonOrbit(npc.Position)
		if npc.Velocity.X >= 0 then
			if data.xState == false then
				data.velDir.X = -1*data.velDir.X
				data.xState = true
			end
		else
			if data.xState == true then
				data.velDir.X = -1*data.velDir.X
				data.xState = false
			end
		end
		if npc.Velocity.Y >= 0 then
			if data.yState == false then
				data.velDir.Y = -1*data.velDir.Y
				data.yState = true
			end
		else
			if data.yState == true then
				data.velDir.Y = -1*data.velDir.Y
				data.yState = false
			end
		end
		npc.Velocity = mod:Lerp(npc.Velocity, data.velDir, 0.4)

		if npc.StateFrame > 60 and mod.minimoonOrbit(npc.Position) then
			data.enemy = mod.minimoonOrbit(npc.Position)
			data.eAngle = (npc.Position-data.enemy.Position):GetAngleDegrees()
			data.eDistance = (npc.Position-data.enemy.Position):Length()
			npc.StateFrame = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			--[[if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					if data.eAngle > 180 then
						data.rotDir = 1
					else
						data.rotDir = -1
					end
				else
					if data.eAngle > 180 then
						data.rotDir = -1
					else
						data.rotDir = 1
					end
				end
			else
				if npc.Velocity.Y > 0 then
					if data.eAngle > 90 and data.eAngle < 270 then
						data.rotDir = -1
					else
						data.rotDir = 1
					end
				else
					if data.eAngle > 90 and data.eAngle < 270 then
						data.rotDir = 1
					else
						data.rotDir = -1
					end
				end
			end]]
			local mAngle = (data.enemy.Position-npc.Position):GetAngleDegrees()
			if data.velDir:GetAngleDegrees() >= 270 and mAngle <= 90 then
				data.rotDir = 1
			elseif data.velDir:GetAngleDegrees() <= 90 and mAngle >= 270 then
				data.rotDir = -1
			elseif data.velDir:GetAngleDegrees() < mAngle then
				data.rotDir = 1
			elseif data.velDir:GetAngleDegrees() > mAngle then
				data.rotDir = -1
			end
			data.state = "Orbit"
		end
	elseif data.state == "Orbit" then
		if npc.StateFrame < 80 and data.enemy then
			local rotateAngle = data.eAngle+npc.StateFrame*(75/data.eDistance)*2.5*data.rotDir
			data.velDir = Vector(5,0):Rotated(data.rotDir*90+rotateAngle)
			local targetPos = data.enemy.Position+Vector.FromAngle(rotateAngle):Resized(data.eDistance)
			npc.Velocity = mod:Lerp(npc.Velocity, targetPos-npc.Position, 0.2)
			
			if data.enemy:IsDead() or data.enemy.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ALL or npc:CollidesWithGrid() == true then
				data.enemy = nil
				npc.Velocity = mod:Lerp(npc.Velocity, data.velDir, 0.4)
			end
		else
			data.enemy = nil
		end
		if not data.enemy then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.Velocity = mod:Lerp(npc.Velocity, data.velDir, 0.4)
			if data.velDir.X > 0 then
				data.xState = true
			else
				data.xState = false
			end
			if data.velDir.Y > 0 then
				data.yState = true
			else
				data.yState = false
			end
			npc.StateFrame = 0
			data.state = "Idle"
		end
	end
end

mod.minimoonBlacklist = {
{114,11}, -- Other Minimoons
{160,451}, -- Eternal Flickerspirits
{130,30} -- Viscerspirits
}

function mod.minimoonOrbit(position)
	local radius = 0
	local enemy = nil
	for _,entity in ipairs(Isaac.FindInRadius(position, 75, EntityPartition.ENEMY)) do
		if entity:IsActiveEnemy() and not mod:isFriend(entity) then
			local blacklisted = false
			for _, check in ipairs(mod.minimoonBlacklist) do
				if check[1] == entity.Type and check[2] == entity.Variant then
					blacklisted = true
				end
			end
			if not blacklisted then
				local distance = position:Distance(entity.Position)
				if distance > radius then
					radius = distance
					enemy = entity
				end
			end
		end
	end
	return enemy
end