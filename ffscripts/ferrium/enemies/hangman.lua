local mod = FiendFolio
local game = Game()

local hangmanDirs = {
	[1] = "Left",
	[3] = "Up",
	[5] = "Right",
	[7] = "Down",
}

local function hangmanRotatedPosition(npc, target, mode, clear)
	local data = target:GetData()
	local rng = npc:GetDropRNG()
	local npcData = npc:GetData()
	local room = game:GetRoom()
	if not data.hangmanPositions then
		data.hangmanPositions = {}
	end
	
	for key,npc1 in pairs(data.hangmanPositions) do
		if npc1 and npc1:Exists() then
			if npc1:GetData().state == "Idle" then
				npc1:GetData().chosenPos = nil
				data.hangmanPositions[key] = nil
			end
		else
			data.hangmanPositions[key] = nil
		end
	end
	
	if npcData.chosenPos then
		local pos = target.Position+Vector(110,0):Rotated(-45+45*npcData.chosenPos)
		if clear then
			data.hangmanPositions[npcData.chosenPos] = nil
			npcData.chosenPos = nil
		elseif room:IsPositionInRoom(pos, 0) and room:GetGridCollisionAtPos(pos) < GridCollisionClass.COLLISION_OBJECT then
			return pos
		else
			data.hangmanPositions[npcData.chosenPos] = nil
			npcData.chosenPos = nil
			return nil
		end
	elseif mode == 0 then
		local validPos = {}
		local validerPos = {}
		for i=1,7,2 do
			if data.hangmanPositions[i] == nil then
				table.insert(validPos, i)
			end
		end
		for _,num in ipairs(validPos) do
			if room:IsPositionInRoom(target.Position+Vector(110,0):Rotated(-45+45*num), 0) and room:GetGridCollisionAtPos(target.Position+Vector(110,0):Rotated(-45+45*num)) < GridCollisionClass.COLLISION_OBJECT then
				table.insert(validerPos, {num, target.Position+Vector(110,0):Rotated(-45+45*num)})
			end
		end
		if #validerPos > 0 then
			local radius = 999
			local chosen = npc.Position
			local backupPos
			local backupChosen
			for _,entry in ipairs(validerPos) do
				local pos = entry[2]
				local dist = npc.Position:Distance(pos)
				if dist < radius and dist < npc.Position:Distance(target.Position) then
					radius = npc.Position:Distance(pos)
					chosen = pos
					npcData.chosenPos = entry[1]
				end
				if dist < radius then
					backupPos = pos
					backupChosen = entry[1]
				end
			end
			if not npcData.chosenPos then
				npcData.chosenPos = backupChosen
				return backupPos
			else
				data.hangmanPositions[npcData.chosenPos] = npc
				return chosen
			end
		else
			return nil
		end
	elseif mode == 1 then
		local validPos = {}
		local validerPos = {}
		for i=2,8,2 do
			if data.hangmanPositions[i] == nil then
				table.insert(validPos, i)
			end
		end
		for _,num in ipairs(validPos) do
			if room:IsPositionInRoom(target.Position+Vector(110,0):Rotated(-45+45*num), 0) and room:GetGridCollisionAtPos(target.Position+Vector(110,0):Rotated(-45+45*num)) < GridCollisionClass.COLLISION_OBJECT then
				table.insert(validerPos, {num, target.Position+Vector(110,0):Rotated(-45+45*num)})
			end
		end
		if #validerPos > 0 then
			local radius = 999
			local chosen = npc.Position
			local backupPos
			local backupChosen
			for _,entry in ipairs(validerPos) do
				local pos = entry[2]
				local dist = npc.Position:Distance(pos)
				if dist < radius and dist < npc.Position:Distance(target.Position) then
					radius = npc.Position:Distance(pos)
					chosen = pos
					npcData.chosenPos = entry[1]
				end
				if dist < radius then
					backupPos = pos
					backupChosen = entry[1]
				end
			end
			if not npcData.chosenPos then
				npcData.chosenPos = backupChosen
				return backupPos
			else
				data.hangmanPositions[npcData.chosenPos] = npc
				return chosen
			end
		else
			return nil
		end
	end
end

function mod:hangmanAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rng = npc:GetDropRNG()
	
	if not data.init then
		data.state = "Idle"
		data.shotCount = 0
		data.oscillateFrame = 0
		data.anim = true
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		
		if data.running then
			if data.running > 0 then
				data.running = data.running-1
			else
				data.running = nil
			end
		end
	end
	
	if data.anim then
		if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
			if npc.Velocity.X > 0 then
				mod:spritePlay(sprite, "IdleRight")
			else
				mod:spritePlay(sprite, "IdleLeft")
			end
		else
			if npc.Velocity.Y > 0 then
				mod:spritePlay(sprite, "IdleDown")
			else
				mod:spritePlay(sprite, "IdleUp")
			end
		end
	end
	
	if data.state == "Idle" then
		local targetPos = targetpos+(targetpos-npc.Position):Resized(math.sin(data.oscillateFrame/4)*200):Rotated(90)
		data.oscillateFrame = data.oscillateFrame+1
		if npc.Position:Distance(target.Position) < 170 or data.running or mod:isScare(npc) then
			if not data.running then
				data.running = 20 
			end
			npc.Velocity = mod:Lerp(npc.Velocity, (targetPos-npc.Position):Resized(-8), 0.1)
		else
			npc.Velocity = mod:Lerp(npc.Velocity, (targetPos-npc.Position):Resized(6), 0.3)
		end
		if npc.StateFrame > 35 and rng:RandomInt(55) == 0 and not mod:isScareOrConfuse(npc) then
			if data.shotCount > 3 then
				data.state = "PrepareBomb"
				data.shotCount = 0
			else
				if rng:RandomInt(10) == 1 then
					data.state = "PrepareBomb"
					data.shotCount = 0
				else
					data.state = "PrepareAnim"
					data.anim = false
					npc:PlaySound(mod.Sounds.GunDraw, 0.7, 0, false, 1.6)
				end
			end
			data.oscillateFrame = 0
			npc.StateFrame = 0
			data.fireTimer = 100
			data.shotCount = data.shotCount+1
		elseif npc.StateFrame > 100 and not mod:isScareOrConfuse(npc) then
			if data.shotCount > 3 then
				data.state = "PrepareBomb"
				data.shotCount = 0
			else
				if rng:RandomInt(10) == 1 then
					data.state = "PrepareBomb"
					data.shotCount = 0
				else
					data.state = "PrepareAnim"
					data.anim = false
					npc:PlaySound(mod.Sounds.GunDraw, 0.7, 0, false, 1.2)
				end
			end
			data.oscillateFrame = 0
			npc.StateFrame = 0
			data.fireTimer = 100
			data.shotCount = data.shotCount+1
		end
	elseif data.state == "PrepareAnim" then
		if sprite:IsFinished("FirePrep") then
			data.state = "Prepare"
			data.anim = true
		else
			mod:spritePlay(sprite, "FirePrep")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
	elseif data.state == "Prepare" then
		local pos = hangmanRotatedPosition(npc, target, 0)
		if pos then
			local targetVel = (pos-npc.Position):Resized(8.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.3)
			
			if data.fireTimer > 0 then
				data.fireTimer = data.fireTimer-1
				
				if npc.Position:Distance(pos) < 40 then
					data.state = "Shoot"
					data.anim = false
					local angle = (target.Position-npc.Position):GetAngleDegrees()+135
					if angle < 0 then
						angle = angle+360
					end
					angle = math.ceil(angle/90)
					data.goVel = Vector(0,-9):Rotated(90*angle)
					local switchAngle = mod:GetAngleDifference(npc.Velocity, data.goVel)
					if switchAngle > 90 and switchAngle < 270 then
						data.goVel = data.goVel:Rotated(180)
					end
				end
			else
				data.state = "Shoot"
				data.anim = false
				local angle = (target.Position-npc.Position):GetAngleDegrees()+135
				if angle < 0 then
					angle = angle+360
				end
				angle = math.ceil(angle/90)
				data.goVel = Vector(0,-9):Rotated(90*angle)
				local switchAngle = mod:GetAngleDifference(npc.Velocity, data.goVel)
				if switchAngle > 90 and switchAngle < 270 then
					data.goVel = data.goVel:Rotated(180)
				end
			end
		else
			data.state = "Idle"
			npc.StateFrame = 70
		end
	elseif data.state == "PrepareBomb" then
		local pos = hangmanRotatedPosition(npc, target, 1)
		if pos then
			local targetVel = (pos-npc.Position):Resized(8.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.3)
			
			if data.fireTimer > 0 then
				data.fireTimer = data.fireTimer-1
				
				if npc.Position:Distance(pos) < 40 then
					data.state = "Bomb"
					data.anim = false
				end
			else
				data.state = "Bomb"
				data.anim = false
			end
		else
			data.state = "Idle"
			npc.StateFrame = 70
		end
	elseif data.state == "Shoot" then
		local anim = hangmanDirs[data.chosenPos]
		if anim == nil then
			data.chosenPos = 1
			anim = "Down"
		end
		if sprite:IsFinished("Fire" .. anim) then
			data.state = "Idle"
			npc.StateFrame = 0
			data.anim = true
			hangmanRotatedPosition(npc, target, 0, true)
			data.chosenPos = nil
		elseif sprite:IsEventTriggered("Dakka") then
			npc:FireProjectiles(npc.Position, Vector(-12,0):Rotated(-45+data.chosenPos*45), 0, ProjectileParams())
			npc:PlaySound(mod.Sounds.ShotgunBlast, 0.2, 0, false, math.random(140,200)/100)
		else
			mod:spritePlay(sprite, "Fire" .. anim)
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, data.goVel, 0.3)
	elseif data.state == "Bomb" then
		if not data.bombAnim then
			local anim = "Down"
			if npc.Position.Y > target.Position.Y then
				anim = "Up"
			end
			data.bombAnim = anim
		end
		if sprite:IsFinished("BigShot" .. data.bombAnim) then
			data.state = "Idle"
			npc.StateFrame = 0
			data.anim = true
			data.bombAnim = nil
			hangmanRotatedPosition(npc, target, 0, true)
			data.chosenPos = nil
		elseif sprite:IsEventTriggered("BigShot") then
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.EXPLODE
			params.Scale = 2
			mod:SetGatheredProjectiles()
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(15), 0, params)
			for _, proj in pairs(mod:GetGatheredProjectiles()) do
				mod:makeBrisketProjSprite(proj)
			end
			npc:PlaySound(SoundEffect.SOUND_ROCKET_LAUNCH_SHORT, 1, 0, false, 2)
		else
			mod:spritePlay(sprite, "BigShot" .. data.bombAnim)
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	end
end