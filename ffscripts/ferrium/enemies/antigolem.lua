local mod = FiendFolio
local game = Game()

function mod:antiGolemAI(npc)
	local room = game:GetRoom()
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	if target and target.Type == 3 then
		target = target:ToFamiliar().Player
	end
	local confuseTarget = mod:randomConfuse(npc, target.Position)
	local rand = npc:GetDropRNG()
	local path = npc.Pathfinder
	
	if not data.init then
		if npc.SubType == 0 then
			data.animationNum = "01"
		else
			data.animationNum = "02"
		end
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		data.startled = 0
		data.bombTimer = 0
		data.killedRecently = 0
		--npc.SplatColor = Color(0.15, 0, 0, 1, 25 / 255, 25 / 255, 25 / 255)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		data.goHere = npc.Position
		data.state = "Appear"
		data.hiding = false
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	--[[if data.targetType and npc.FrameCount % 10 == 0 then
		Isaac.ConsoleOutput(data.targetType)
	end]]
	
	if npc.HitPoints > npc.MaxHitPoints then
		local increase = math.ceil(npc.HitPoints - npc.MaxHitPoints)
		npc:SetColor(Color(1,1,1,1,0,0,(increase * 3) / 255),15,1,true,false)
	end
	
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		if data.animationNum == "02" then
			data.animationNum = "01"
			Isaac.Spawn(5, 41, 0 , npc.Position, npc.Velocity*0.4, npc)
		end
	end
	
	if data.state == "Idle" then
		if data.bombTimer > 0 then
			data.bombTimer = data.bombTimer-1
		else
			local bombDetect = Isaac.FindByType(4, -1, -1, false, false)
			for _, checkBomb in pairs(bombDetect) do
				if checkBomb.Position:Distance(npc.Position) < 140 then
					if not checkBomb.Parent or checkBomb.Parent ~= npc then
						data.bomb = checkBomb
					end
				end
			end
		end
		
		local tintedSpider = Isaac.FindByType(818, 1, -1, false, false)
		local radius = 600
		for _, checkSpider in pairs(tintedSpider) do
			local distance = checkSpider.Position:Distance(npc.Position)
			if distance < radius then
				radius = distance
				if path:HasPathToPos(checkSpider.Position) then
					data.spider = checkSpider
				end
			end
		end
		
		if data.killedRecently > 0 then
			for _, heart in ipairs(Isaac.FindByType(5, 10, -1, false, false)) do
				if heart.Position:Distance(npc.Position) < 50 and heart.FrameCount < 2 then
					heart:Remove()
				end
			end
			data.killedRecently = data.killedRecently-1
		end
		
		if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
			if (target.Position.X - npc.Position.X) > 0 then
				--data.cardinal = Vector(70, 0) --Right
				data.direction = 0
			else
				--data.cardinal = Vector(-70, 0) --Left
				data.direction = 2
			end
		else
			if (target.Position.Y - npc.Position.Y) > 0 then
				--data.cardinal = Vector(0, 70) --Down
				data.direction = 1
			else
				--data.cardinal = Vector(0, -70) --Up
				data.direction = 3
			end
		end
		
		if not data.gonnagetyou then
			if not data.spider then
				if data.currentlyHiding == true then
					if npc.Position:Distance(target.Position) < 220 then
						if npc.StateFrame > 60 and rand:RandomInt(5) == 1 then
							data.state = "Bomb"
							--data.randomTime = rand:RandomInt(3)+1
							data.randomTime = 2
						end
					end
				elseif data.targetType == "findClosest" and not data.bomb and npc.Position:Distance(target.Position) < 280 then
					if math.abs(target.Position.X-npc.Position.X) < 80 or math.abs(target.Position.Y-npc.Position.Y) < 80 then
						if npc.StateFrame > 60 and rand:RandomInt(5) == 1 then
							data.state = "Bomb"
							--data.randomTime = rand:RandomInt(3)+1
							data.randomTime = 2
						end
					end
				end
			end
		
			if path:HasPathToPos(target.Position, false) then
				data.gonnagetyou = true
				data.movement = true
			else
				if npc.StateFrame % 30 == 0 or data.checkAgain then
					data.checkAgain = nil
					data.movement = true
					if data.abandon == true then
						local lookTable = mod:antiGolemSurveyLand(npc, target, path, "Exit", rand)
						if lookTable ~= nil then
							data.goHere = lookTable[2]
							data.targetType = lookTable[1]
							if data.targetType == "hideout" then
								data.hidded = nil
								npc.StateFrame = 0
								data.hiding = true
								data.abandonTimer = 70
							else
								data.hiding = false
							end
						else
							data.goHere = mod:antiGolemFindSpot(npc, target.Position, path, "Player")
							data.targetType = "findClosest"
							data.hiding = false
						end
					elseif data.hiding == false and not data.abandon then
						local lookTable = mod:antiGolemSurveyLand(npc, target, path, "Hide", rand)
						if lookTable ~= nil then
							data.goHere = lookTable[2]
							data.targetType = lookTable[1]
							if data.targetType == "hideout" then
								data.hidded = nil
								npc.StateFrame = 0
								data.hiding = true
								data.abandonTimer = 70
							else
								data.hiding = false
							end
						else
							data.goHere = mod:antiGolemFindSpot(npc, target.Position, path, "Player")
							data.targetType = "findClosest"
							data.hiding = false
						end
					end
				end
				
				--[[if data.abandon == true and npc.StateFrame > 200 then
					data.abandon = false
					data.movement = true
					if data.currentlyHiding == true then
						data.currentlyHiding = false
					end
				end]]
				
				if data.bomb then
					npc.StateFrame = 0
					if npc:GetData().eternalFlickerspirited ~= true then
						data.goHere = mod:antiGolemFindSpot(npc, data.bomb.Position, path, "Bomb")
					else
						data.goHere = mod:antiGolemFindSpot(npc, target.Position, path, "Player")
					end
					
					if not data.goHere then
						data.goHere = npc.Position
					end
					if data.currentlyHiding == true then
						data.currentlyHiding = false
					end
					if npc.Position:Distance(data.goHere) > 5 then
						data.movement = true
					else
						data.movement = false
					end
					if not data.bomb:Exists() then
						data.movement = true
						data.bomb = nil
						if data.targetType == "hideout" then
							data.abandon = true
						end
					end
				elseif data.targetType == "findClosest" then
					if mod:antiGolemFindSpot(npc, target.Position, path, "Player") ~= nil and mod:antiGolemFindSpot(npc, target.Position, path, "Player"):Distance(npc.Position) > 5 then
						data.goHere = mod:antiGolemFindSpot(npc, target.Position, path, "Player")
						data.movement = true
					else
						data.movement = false
					end
				elseif data.targetType == "hideout" and not data.abandon then
					if data.goHere:Distance(npc.Position) > 5 then
						data.movement = true
						data.currentlyHiding = false
					else
						if not data.hidded then
							npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR,1,0,false,math.random(180,200)/100)
							data.hidded = true
						end
						data.currentlyHiding = true
						data.movement = false
						if npc.Position:Distance(target.Position) < 220 then
							data.abandonTimer = 70
						else
							data.abandonTimer = data.abandonTimer-1
							if data.abandonTimer <= 0 then
								data.abandon = true
								npc.StateFrame = 29
							end
						end
					end
				elseif not data.bomb and (data.targetType == "exit" or data.targetType == "bombPlace" or data.targetType == "bombHideout") then
					if npc.Position:Distance(data.goHere) < 5 and npc.StateFrame > 10 then
						data.setBomb = data.bomb
						npc:PlaySound(SoundEffect.SOUND_FETUS_LAND, 1, 0, false ,1)
						data.bomb = Isaac.Spawn(4, 13, 0, npc.Position, Vector.Zero, npc):ToBomb()
						data.bomb.ExplosionDamage = 20
						data.bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						data.goHere = mod:antiGolemFindSpot(npc, data.bomb.Position, path, "Bomb")
						if not data.goHere then
							data.goHere = npc.Position
						end
						data.targetType = "findClosest"
					else
						data.checkAgain = true
					end
				end
				
				if data.spider then
					if data.spider.Position:Distance(npc.Position) < 40 then
						data.spider:Kill()
						data.killedRecently = 3
					end
					
					if path:HasPathToPos(data.spider.Position) then
						data.goHere = data.spider.Position
						data.movement = true
						if data.currentlyHiding == true then
							data.currentlyHiding = false
						end
					else
						data.spider = nil
					end
					
					if data.spider and data.spider:IsDead() then
						npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR,1,0,false,math.random(180,200)/100)
						data.movement = true
						data.spider = nil
						local poof = Isaac.Spawn(1000, 49, 0, npc.Position, Vector.Zero, npc):ToEffect()
						poof.SpriteOffset = Vector(0,-45)
						poof:FollowParent(npc)
						poof:Update()
						npc.HitPoints = npc.HitPoints + 25
						if npc.HitPoints > npc.MaxHitPoints * 1.5 then
							npc.HitPoints = npc.MaxHitPoints * 1.5
						end
						data.checkAgain = true
						npc:PlaySound(SoundEffect.SOUND_HOLY,0.7,0,false,1)
						if data.targetType == "hideout" then
							data.abandon = true
						end
					end
				end
				
				if data.bomb and data.setBomb and data.bomb ~= data.setBomb and npc:GetData().eternalFlickerspirited ~= true then
					local targetDir = (npc.Position-data.bomb.Position):Resized(4)
					npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
				elseif data.movement == true then
					if mod:isScare(npc) then
						local targetDir = (confuseTarget-npc.Position):Resized(-6)
						npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
					elseif game:GetRoom():CheckLine(npc.Position, data.goHere, 0, 1, false, false) then
						local targetDir = (data.goHere-npc.Position):Resized(4)
						npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
					else
						npc.Pathfinder:FindGridPath(data.goHere, 0.5, 999, true)
					end
				else
					npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
				end
			end
		else
			if not path:HasPathToPos(target.Position, false) then
				data.gonnagetyou = nil
				data.movement = true
			end
			
			if npc.Position:Distance(target.Position) < 200 and not data.spider then
				if math.abs(target.Position.X-npc.Position.X) < 75 or math.abs(target.Position.Y-npc.Position.Y) < 75 then
					if npc.StateFrame > 60 and rand:RandomInt(5) == 1 then
						data.state = "Bomb"
						--data.randomTime = rand:RandomInt(3)+1
						data.randomTime = 2
					end
				end
			end
			
			local offsetTarget = target.Position+Vector(-140, 0):Rotated(90*data.direction)
			if not mod:isScareOrConfuse(npc) then
				data.aiming = true
			else
				data.aiming = false
			end
			
			if data.aiming ~= true then
				if sprite:IsOverlayPlaying("HeadRight" .. data.animationNum) or sprite:IsOverlayPlaying("HeadLeft" .. data.animationNum) or sprite:IsOverlayPlaying("HeadUp" .. data.animationNum) or sprite:IsOverlayPlaying("HeadDown" .. data.animationNum) then
					sprite:RemoveOverlay()
				end
			end
			
			if data.bomb then
				if npc:GetData().eternalFlickerspirited ~= true then
					data.startled = data.startled+1
				end
				
				if not data.bomb:Exists() then
					data.setBomb = nil
					data.movement = true
					data.bomb = nil
					data.startled = 0
				end
			elseif data.spider then
				if data.spider.Position:Distance(npc.Position) < 40 then
					data.spider:Kill()
					data.killedrecently = 3
				end
				
				if data.spider:IsDead() and data.spider.Position:Distance(npc.Position) < 40 then
					npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR,1,0,false,math.random(180,200)/100)
					data.movement = true
					data.spider = nil
					local poof = Isaac.Spawn(1000, 49, 0, npc.Position, Vector.Zero, npc):ToEffect()
					poof.SpriteOffset = Vector(0,-45)
					poof:FollowParent(npc)
					poof:Update()
					npc.HitPoints = npc.HitPoints + 25
					if npc.HitPoints > npc.MaxHitPoints * 1.5 then
						npc.HitPoints = npc.MaxHitPoints * 1.5
					end
					npc:PlaySound(SoundEffect.SOUND_HOLY,1,0,false,1)
				end
			end
			
			if mod:isScare(npc) then
				local targetDir = (confuseTarget-npc.Position):Resized(-6)
				npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
			elseif mod:isConfuse(npc) then
				if room:CheckLine(npc.Position, confuseTarget, 0, 1, false, false) then
					local targetDir = (confuseTarget-npc.Position):Resized(4)
					npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
				else
					npc.Pathfinder:FindGridPath(confuseTarget, 0.5, 999, true)
				end
			elseif data.bomb and data.startled > 12 then
				if data.movement == true then
					npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-data.bomb.Position):Resized(4), 0.3)
				else
					npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
				end
			elseif data.spider then
				if sprite:IsOverlayPlaying("HeadRight" .. data.animationNum) or sprite:IsOverlayPlaying("HeadLeft" .. data.animationNum) or sprite:IsOverlayPlaying("HeadUp" .. data.animationNum) or sprite:IsOverlayPlaying("HeadDown" .. data.animationNum) then
					sprite:RemoveOverlay()
				end
				if path:HasPathToPos(data.spider.Position) then
					data.aiming = false
					if room:CheckLine(npc.Position, data.spider.Position, 0, 1, false, false) then
						local targetDir = (data.spider.Position-npc.Position):Resized(5.4)
						npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
					else
						npc.Pathfinder:FindGridPath(data.spider.Position, 0.6, 999, true)
					end
				else
					data.spider = nil
				end
			elseif npc.Position:Distance(offsetTarget) > 10 then
				if data.aiming == true then
					if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
						if npc.Velocity.X > 0 then
							mod:spritePlay(sprite, "WalkRight")
						else
							mod:spritePlay(sprite, "WalkLeft")
						end
					else
						mod:spritePlay(sprite, "WalkVert")
					end
					if data.direction == 0 then
						mod:spriteOverlayPlay(sprite, "HeadRight" .. data.animationNum)
					elseif data.direction == 1 then
						mod:spriteOverlayPlay(sprite, "HeadDown" .. data.animationNum)
					elseif data.direction == 2 then
						mod:spriteOverlayPlay(sprite, "HeadLeft" .. data.animationNum)
					elseif data.direction == 3 then
						mod:spriteOverlayPlay(sprite, "HeadUp" .. data.animationNum)
					end
				end
				if room:CheckLine(npc.Position, offsetTarget, 0, 1, false, false) then
					local targetDir = (offsetTarget-npc.Position):Resized(4)
					npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
				else
					npc.Pathfinder:FindGridPath(offsetTarget, 0.5, 999, true)
				end
			else
				if sprite:IsOverlayPlaying("HeadRight" .. data.animationNum) or sprite:IsOverlayPlaying("HeadLeft" .. data.animationNum) or sprite:IsOverlayPlaying("HeadUp" .. data.animationNum) or sprite:IsOverlayPlaying("HeadDown" .. data.animationNum) then
					sprite:RemoveOverlay()
				end
				
				if data.aiming == true then
					if data.direction == 0 then
						mod:spritePlay(sprite, "IdleRight" .. data.animationNum)
					elseif data.direction == 1 then
						mod:spritePlay(sprite, "IdleDown" .. data.animationNum)
					elseif data.direction == 2 then
						mod:spritePlay(sprite, "IdleLeft" .. data.animationNum)
					elseif data.direction == 3 then
						mod:spritePlay(sprite, "IdleUp" .. data.animationNum)
					end
				end
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			end
		end
		
		if data.bomb or not data.gonnagetyou then
			if sprite:IsOverlayPlaying("HeadRight" .. data.animationNum) or sprite:IsOverlayPlaying("HeadLeft" .. data.animationNum) or sprite:IsOverlayPlaying("HeadUp" .. data.animationNum) or sprite:IsOverlayPlaying("HeadDown" .. data.animationNum) then
				sprite:RemoveOverlay()
			end
			data.aiming = false
			if data.bomb then
				data.currentlyHiding = false
				data.movement = true
			end
		end
	
		if data.aiming == true and not data.bomb then
		elseif data.currentlyHiding == true and not data.abandon then
			if data.direction == 0 then
				mod:spritePlay(sprite, "IdleRight" .. data.animationNum)
			elseif data.direction == 1 then
				mod:spritePlay(sprite, "IdleDown" .. data.animationNum)
			elseif data.direction == 2 then
				mod:spritePlay(sprite, "IdleLeft" .. data.animationNum)
			elseif data.direction == 3 then
				mod:spritePlay(sprite, "IdleUp" .. data.animationNum)
			end
		elseif data.movement == false then
			mod:spritePlay(sprite, "IdleDown" .. data.animationNum)
		elseif npc.Velocity:Length() > 0 then
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					mod:spritePlay(sprite, "WalkDown" .. data.animationNum)
				else
					mod:spritePlay(sprite, "WalkUp" .. data.animationNum)
				end
			else
				if npc.Velocity.X > 0 then
					mod:spritePlay(sprite, "WalkRight" .. data.animationNum)
				else
					mod:spritePlay(sprite, "WalkLeft" .. data.animationNum)
				end
			end
		else
			mod:spritePlay(sprite, "IdleDown" .. data.animationNum)
		end
	elseif data.state == "Bomb" then
		if sprite:IsOverlayPlaying("HeadRight" .. data.animationNum) or sprite:IsOverlayPlaying("HeadLeft" .. data.animationNum) or sprite:IsOverlayPlaying("HeadUp" .. data.animationNum) or sprite:IsOverlayPlaying("HeadDown" .. data.animationNum) then
			sprite:RemoveOverlay()
		end
	
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
		if sprite:IsFinished("ThrowBomb" .. data.animationNum .. data.randomTime) then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Bomb") then
			npc:PlaySound(SoundEffect.SOUND_FETUS_FEET, 1, 0, false, 1)
			data.holdingBomb = Isaac.Spawn(4, 13, 0, npc.Position+npc.Velocity, Vector.Zero, npc):ToBomb()
			data.holdingBomb:GetData().antiGolem = true
			data.holdingBomb.DepthOffset = 2
			data.holdingBomb.PositionOffset = Vector(0,-15)
			data.holdingBomb.Parent = npc
			data.holdingBomb:SetExplosionCountdown(36)
			data.holdingBomb.ExplosionDamage = 20
		elseif sprite:IsEventTriggered("Shoot") then
			data.bombTimer = 15
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR,1,0,false,math.random(180,200)/100)
			if data.holdingBomb and data.holdingBomb:Exists() then
				data.holdingBomb:Remove()
				data.holdingBomb = nil
				mod.throwShit(npc.Position, (target.Position-npc.Position):Resized(15), -30, -5, npc, "redBomb", (90/data.randomTime), 20)
			else
				data.holdingBomb = nil
			end
		else
			mod:spritePlay(sprite, "ThrowBomb" .. data.animationNum .. data.randomTime)
		end
	elseif data.state == "Appear" then
		npc.Velocity = npc.Velocity*0.6
		if sprite:IsFinished("Appear" .. data.animationNum) then
			data.state = "Idle"
		else
			mod:spritePlay(sprite, "Appear" .. data.animationNum)
		end
	end
end

function mod:antiGolemSurveyLand(npc, target, path, hiding, rand)
	local room = game:GetRoom()
	local size = room:GetGridSize()
	local possiblePlaces = {}
	local hideouts = {}
	local possibleHideouts = {}
	local exits = {}
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i) 
		if room:GetGridCollisionAtPos(gridpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(gridpos, 0) then
			if path:HasPathToPos(gridpos, false) then
				for j = 1, 4 do
					local gridvalid = true
					local lastChance = false
					local firstPit = false
					local encounteredRock = false
					local emptyChain = 0
					local totalEmpty = 0
					local dist = 1
					local exitable = true
					while gridvalid == true do
						local newpos = gridpos + (Vector(0, 40):Rotated(j*90) * dist)
						local lastpos = gridpos + (Vector(0, 40):Rotated(j*90) * (dist - 1))
						local gridColl = room:GetGridCollisionAtPos(newpos)
						if (gridColl == GridCollisionClass.COLLISION_WALL or dist > 25) then
							gridvalid = false
						elseif (room:GetGridEntityFromPos(newpos) and room:GetGridEntityFromPos(newpos).Desc.Type == GridEntityType.GRID_ROCKB) then
							gridvalid = false
						elseif gridColl == GridCollisionClass.COLLISION_NONE and path:HasPathToPos(newpos, false) then
							gridvalid = false
						else
							if gridColl == GridCollisionClass.COLLISION_PIT then
								if dist == 1 then
									exitable = false
									firstPit = true
								elseif room:GetGridCollisionAtPos(lastpos) ~= GridCollisionClass.COLLISION_SOLID or lastChance == true then
									exitable = false
								end
								lastChance = true
							elseif gridColl == GridCollisionClass.COLLISION_SOLID then
								encounteredRock = true
							elseif gridColl == GridCollisionClass.COLLISION_NONE then
								emptyChain = emptyChain+1
								local testPath = Isaac.Spawn(114, 5, 0, newpos, Vector.Zero, nil):ToNPC()
								testPath.Visible = false
								testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
								testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
								testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
								if testPath.Pathfinder:HasPathToPos(target.Position, false) then
									if exitable == true and encounteredRock == true then
										if mod:antiGolemFindSpot(npc, gridpos, path, "Bomb") ~= nil or npc:GetData().eternalFlickerspirited == true then
											table.insert(exits, {gridpos, dist-emptyChain})
											gridvalid = false
										end
									end
									if dist-emptyChain < 3 then
										table.insert(hideouts, gridpos)
										gridvalid = false
									elseif encounteredRock == true then
										if mod:antiGolemFindSpot(npc, gridpos, path, "Bomb") ~= nil or npc:GetData().eternalFlickerspirited == true and firstPit == false then
											table.insert(possibleHideouts, gridpos)
											gridvalid = false
										end
									end
								else
									if room:GetGridCollisionAtPos(lastpos) ~= GridCollisionClass.COLLISION_NONE and firstPit == false and encounteredRock == true then
										if mod:antiGolemFindSpot(npc, gridpos, path, "Bomb") ~= nil or npc:GetData().eternalFlickerspirited == true then
											table.insert(possiblePlaces, gridpos)
											gridvalid = false
										end
									end
								end
								testPath:Remove()
							end
							dist = dist + 1
						end
					end
				end
			end
		end
	end
	
	if hiding == "Hide" then
		if #hideouts > 0 then
			local choice = nil
			local radius = 9999
			for i=1,#hideouts do
				if hideouts[i]:Distance(target.Position) < radius then
					radius = hideouts[i]:Distance(target.Position)
					choice = hideouts[i]
				end
			end
			return {"hideout", choice}
		elseif #exits > 0 then
			local choice = {}
			local radius = 9999
			for i=1,#exits do
				if exits[i][2] < radius then
					radius = exits[i][2]
					choice = exits[i][1]
				end
			end
			return {"exit", choice}
		elseif #possiblePlaces > 0 then
			local choice = nil
			local radius = 9999
			for i=1,#possiblePlaces do
				if possiblePlaces[i]:Distance(target.Position) < radius then
					radius = possiblePlaces[i]:Distance(target.Position)
					choice = possiblePlaces[i]
				end
			end
			return {"bombPlace", choice}
		elseif #possibleHideouts > 0 then
			local choice = nil
			local radius = 9999
			for i=1,#possibleHideouts do
				if possibleHideouts[i]:Distance(target.Position) < radius then
					radius = possibleHideouts[i]:Distance(target.Position)
					choice = possibleHideouts[i]
				end
			end
			return {"bombHideout", choice}
		else
			return nil
		end
	elseif hiding == "Exit" then
		if #exits > 0 then
			local choice = {}
			local radius = 9999
			for i=1,#exits do
				if exits[i][2] < radius then
					radius = exits[i][2]
					choice = exits[i][1]
				end
			end
			return {"exit", choice}
		elseif #hideouts < 0 then
			local choice = nil
			local radius = 9999
			for i=1,#exits do
				if hideouts[i]:Distance(target.Position) < radius then
					radius = hideouts[i]:Distance(target.Position)
					choice = hideouts[i]
				end
			end
			return {"hideout", choice}
		elseif #possiblePlaces > 0 then
			local choice = nil
			local radius = 9999
			for i=1,#possiblePlaces do
				if possiblePlaces[i]:Distance(target.Position) < radius then
					radius = possiblePlaces[i]:Distance(target.Position)
					choice = possiblePlaces[i]
				end
			end
			return {"bombPlace", choice}
		elseif #possibleHideouts > 0 then
			local choice = nil
			local radius = 9999
			for i=1,#possibleHideouts do
				if possibleHideouts[i]:Distance(target.Position) < radius then
					radius = possibleHideouts[i]:Distance(target.Position)
					choice = possibleHideouts[i]
				end
			end
			return {"bombHideout", choice}
		else
			return nil
		end
	else
		if #exits > 0 then
			local choice = {}
			local radius = 9999
			for i=1,#exits do
				if exits[i][2] < radius then
					radius = exits[i][2]
					choice = exits[i][1]
				end
			end
			return {"exit", choice}
		elseif #possiblePlaces > 0 then
			local choice = nil
			local radius = 9999
			for i=1,#possiblePlaces do
				if possiblePlaces[i]:Distance(target.Position) < radius then
					radius = possiblePlaces[i]:Distance(target.Position)
					choice = possiblePlaces[i]
				end
			end
			return {"bombPlace", choice}
		else
			return nil
		end
	end
end

function mod:antiGolemFindSpot(npc, targetpos, path, mode)
	local room = game:GetRoom()
	local radius = 9999
	local goHere = nil
	local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollisionAtPos(gridpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(gridpos, 0) then
			if mode == "Player" then
				if gridpos:Distance(targetpos) < radius and path:HasPathToPos(gridpos) then
					radius = targetpos:Distance(gridpos)
					goHere = gridpos
				end
			elseif mode == "Bomb" then
				if (gridpos:Distance(targetpos) < radius and gridpos:Distance(targetpos) > 100 and path:HasPathToPos(gridpos)) or npc:GetData().eternalFlickerspirited == true then 
					goHere = gridpos
				end
			end
		end
	end
	return goHere
end

function mod:antiGolemHurt(npc, damage, flag, source)
	if flag & DamageFlag.DAMAGE_EXPLOSION == 0 and not npc:GetData().FFMartyrUranusDamage then
		return false
	end
end