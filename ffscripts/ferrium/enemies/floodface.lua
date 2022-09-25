local mod = FiendFolio
local game = Game()

function mod:floodfaceAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local targ = npc:GetPlayerTarget()
	local target = mod:randomConfuse(npc, targ.Position)
	local room = game:GetRoom()

	npc.StateFrame = npc.StateFrame+1

	if npc.Velocity.X < -0.5 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	if npc.Velocity:Length() > 0 then
		if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
			if npc.Velocity.Y > 0 then
				mod:spritePlay(sprite, "WalkVert")
				mod:spriteOverlayPlay(sprite, "Head Down")
				if npc.StateFrame % 6 == 0 and npc.StateFrame > 10 and not mod:isConfuse(npc) then
					local targetDir = npc.Velocity:Resized(math.random(75,85)/10):Rotated(math.random(-10,10))
					local params = ProjectileParams()
					params.FallingSpeedModifier = -(math.random(5,11))
					params.FallingAccelModifier = math.random(5,10)/8
					params.Scale = math.random(4,14)/8
					params.Variant = 4
					npc:FireProjectiles(npc.Position+Vector(0,10), targetDir, 0, params)

					--[[local projectile = Isaac.Spawn(9, 4, 0, npc.Position+Vector(0,10), targetDir, npc):ToProjectile()
					projectile.FallingSpeed = -(math.random(5,11))
					projectile.FallingAccel = math.random(5,10)/8
					projectile.Scale = math.random(4,14)/8]]
				end
			else
				mod:spriteOverlayPlay(sprite, "Head Up")
				if npc.StateFrame % 6 == 0 and npc.StateFrame > 10 and not mod:isConfuse(npc) then
					local targetDir = npc.Velocity:Resized(math.random(75,85)/10):Rotated(math.random(-10,10))
					local params = ProjectileParams()
					params.FallingSpeedModifier = -(math.random(5,11))
					params.FallingAccelModifier = math.random(5,10)/8
					params.Scale = math.random(4,14)/8
					params.Variant = 4
					npc:FireProjectiles(npc.Position+Vector(0,-10), targetDir, 0, params)
				end
			end
		else
			mod:spritePlay(sprite, "WalkHori")
			mod:spriteOverlayPlay(sprite, "Head Side")
			if sprite.FlipX == true then
				data.flipVector = Vector(-13,1)
			else
				data.flipVector = Vector(13,1)
			end
			if npc.StateFrame % 6 == 0 and npc.StateFrame > 10 and not mod:isConfuse(npc) then
				local targetDir = npc.Velocity:Resized(math.random(75,85)/10):Rotated(math.random(-10,10))
				local params = ProjectileParams()
				params.FallingSpeedModifier = -(math.random(5,11))
				params.FallingAccelModifier = math.random(5,10)/8
				params.Scale = math.random(4,14)/8
				params.Variant = 4
				npc:FireProjectiles(npc.Position+data.flipVector, targetDir, 0, params)
			end
		end
	else
		mod:spritePlay(sprite, "WalkVert")
		mod:spriteOverlayPlay(sprite, "Head Down")
		if npc.StateFrame % 6 == 0 and npc.StateFrame > 10 and not mod:isConfuse(npc) then
			local targetDir = npc.Velocity:Resized(math.random(75,85)/10):Rotated(math.random(-10,10))
			local params = ProjectileParams()
			params.FallingSpeedModifier = -(math.random(5,11))
			params.FallingAccelModifier = math.random(5,10)/8
			params.Scale = math.random(4,14)/8
			params.Variant = 4
			npc:FireProjectiles(npc.Position+Vector(0,10), targetDir, 0, params)
		end
	end

	if npc.SubType == 0 then
		data.newhome = data.newhome or mod:floodfaceAlign(npc.Position)
		if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.1 or (not room:CheckLine(data.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
			data.newhome = mod:floodfaceAlign(npc.Position)
			npc.StateFrame = 7
		end
		local targvel = (data.newhome - npc.Position):Resized(2)
		if mod:isScare(npc) then
			targvel = (target - npc.Position):Resized(-2)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
	elseif npc.SubType == 1 then
		if mod:isScare(npc) then
			local targvel = (target - npc.Position):Resized(-2)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
		elseif room:CheckLine(npc.Position, target, 0, 1, false, false) == true then
			local targvel = (target - npc.Position):Resized(2)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(target, 0.3, 999, true)
		end
	end
end

function mod:floodfaceAlign(pos) --Dang, another modified function cause I'm too dumb to do things properly
	local room = game:GetRoom()
	local vec = Vector(0, 40)
	local positions = {}
	for i = 1, 4 do
		local gridvalid = true
		local dist = 1
		while gridvalid == true do
			local newpos = pos + (vec:Rotated(i*90) * dist)
			local lastpos = pos + (vec:Rotated(i*90) * (dist - 1))
			local gridColl = room:GetGridCollisionAtPos(newpos)
			if (gridColl ~= GridCollisionClass.COLLISION_NONE or dist > 25) then
				table.insert(positions, lastpos)
				gridvalid = false
			else
				dist = dist + 1
			end
		end
	end
	if #positions > 0 then
		return positions[math.random(#positions)]
	else
		return pos
	end
end