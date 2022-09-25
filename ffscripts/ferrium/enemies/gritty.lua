local mod = FiendFolio
local game = Game()

--Credits to Fork Guy for the concept and design

function mod:grittyAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()
	
	if not data.init then
		if data.waited then
			data.state = "Waiting"
		elseif npc.SubType == 0 then
			data.state = "Appear"
		elseif not data.waited then
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, -10, false)
		end
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.Visible = false
		data.appearDelay = 20+rand:RandomInt(30)
		npc.SplatColor = FiendFolio.ColorGhostly
		data.justThrown = 0
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	local checkSinge = Isaac.FindByType(915, 0, -1, false)
	local danger = false
	for _, check in pairs(checkSinge) do
		if check.Position:Distance(npc.Position) < 120 then
			data.watchOut = check
			danger = true
		end
	end
	if danger == false then
		data.watchOut = nil
	end
	
	if data.targetBall and not data.targetBall:Exists() then
		npc.StateFrame = 0
		data.targetBall = nil
		data.state = "Idle"
	end
	
	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 60 and data.targetBall == nil and not mod:isScareOrConfuse(npc) then
			if mod.GetEntityCount(915, 1, -1) > 0 then
				data.targetBall = mod.findGrittyBalls(npc.Position)
				if data.targetBall ~= nil then
					data.targetBall:GetData().grittyClaimed = npc
				end
			else
				data.state = "Run"
				npc.CanShutDoors = false
				npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
			end
		end
		
		if data.targetBall and npc.Position:Distance(data.targetBall.Position) < 40 then
			data.state = "Pickup"
			npc.StateFrame = 0
			data.pickingUp = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.DepthOffset = 6
			if mod:GetBallType(data.targetBall.SubType) == mod.FF.RockBallGold.Sub and mod:RandomInt(1,2) == 2 then
				data.goldrun = true
			end
		end
		
		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(-8), 0.05)
		elseif mod:isConfuse(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (mod:randomConfuse(npc, target.Position)-npc.Position):Resized(10), 0.05)
		elseif data.watchOut ~= nil then
			npc.Velocity = mod:Lerp(npc.Velocity, (data.watchOut.Position-npc.Position):Resized(-8), 0.05)
		elseif data.targetBall ~= nil then
			npc.Velocity = mod:Lerp(npc.Velocity, (data.targetBall.Position-npc.Position):Resized(10), 0.05)
		else
			if target.Position:Distance(npc.Position) > 100 then
				npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(8), 0.05)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(-8), 0.05)
			end
		end
	elseif data.state == "Waiting" then
		npc.Velocity = Vector.Zero
		sprite:Play("Hiding", true)
		data.state = "Appear"
		data.appearDelay = rand:RandomInt(10)
	elseif data.state == "Chasing" then
		mod:spritePlay(sprite, "PickupIdle")
		
		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(-8), 0.05)
		elseif mod:isConfuse(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (mod:randomConfuse(npc, target.Position)-npc.Position):Resized(10), 0.05)
		else
			npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(15), 0.05)
		end
		if npc.StateFrame > 20 and npc.Position:Distance(target.Position) < 200 and not mod:isScareOrConfuse(npc) then
			data.state = "Throw"
			sprite:Play("Throw")
		end
	elseif data.state == "Pickup" then
		local targVec = ((data.targetBall.Position+Vector(0,-5))-npc.Position)
		if data.pickingUp == 0 then
			mod:spritePlay(sprite, "Idle")
			local targVec2 = targVec*0.4
			if (targVec*0.4):Length() > 9 then
				targVec2 = targVec:Resized(9)
			end
			npc.Velocity = mod:Lerp(npc.Velocity, targVec2, 0.3)
		elseif data.pickingUp == 1 then
			npc.Velocity = mod:Lerp(npc.Velocity, targVec, 0.4)
		elseif data.pickingUp == 2 then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.8)
		end
		
		if sprite:IsFinished("Pickup") then
			if data.goldrun then
				data.state = "Run"
				npc.CanShutDoors = false
				npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
				data.targetBall:GetData().breakOnImpact = true
				data.targetBall.GridCollisionClass = GridCollisionClass.COLLISION_NONE
			else
				data.state = "Chasing"
				npc.StateFrame = 0
			end
		elseif sprite:IsEventTriggered("PickupThrow") then
			data.targetBall:GetData().pickedUp = true
			npc.Velocity = Vector.Zero
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			npc.DepthOffset = 0
			data.pickingUp = 2
		end
		
		if npc.Position:Distance(data.targetBall.Position+Vector(0,-5)) < 5 and data.pickingUp == 0 and npc.StateFrame > 20 then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			sprite:Play("Pickup")
			data.pickingUp = 1
		end
	elseif data.state == "Throw" then
		if sprite:IsFinished("Throw") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("PickupThrow") then
			local bData = data.targetBall:GetData()
			bData.pickedUp = nil
			bData.justThrown = 3
			bData.grittyClaimed = nil
			bData.holdPosition = nil
			local rocksub = mod:GetBallType(data.targetBall.SubType)
			local velfactor = npc.Velocity * 1.5
			if rocksub == mod.FF.RockBallMinesLava.Sub or rocksub == mod.FF.RockBallAshpitLava.Sub then
				bData.breakOnImpact = true
				velfactor = npc.Velocity
			elseif rocksub == mod.FF.RockBallGold.Sub then
				bData.breakOnImpact = true
			end
			data.targetBall.Velocity = velfactor+(target.Position-npc.Position):Resized(9)
			data.targetBall = nil
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.03)
	elseif data.state == "Appear" then
		npc.Velocity = Vector.Zero
		if data.appearDelay > 0 then
			data.appearDelay = data.appearDelay-1
		elseif mod.farFromAllPlayers(npc.Position, 50) then
			npc.Visible = true
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			data.state = "Appearing"
			mod:spritePlay(sprite, "GroundAppear")
		end
	elseif data.state == "Appearing" then
		npc.Velocity = npc.Velocity*0.8
		if sprite:IsFinished("GroundAppear") then
			data.state = "Idle"
			npc.StateFrame = 50
		elseif sprite:IsEventTriggered("Appear") then
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			local poofy = Isaac.Spawn(1000, 16, 2, npc.Position+Vector(0,10), Vector.Zero, npc):ToEffect()
			poofy.SpriteScale = Vector(0.55, 0.65)
			poofy.Color = mod.ColorGreyscale
			if math.random(2) == 1 then
				poofy:GetSprite().FlipX = true
			end
			poofy:Update()
			npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(12,21)/10)
		elseif sprite:IsEventTriggered("DustPoof") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			local poofy = Isaac.Spawn(1000, 16, 2, npc.Position+Vector(0,10), Vector.Zero, npc):ToEffect()
			poofy.SpriteScale = Vector(0.5, 0.5)
			poofy.Color = mod.ColorGreyscale
			if math.random(2) == 1 then
				poofy:GetSprite().FlipX = true
			end
			poofy:Update()
			npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.1, 0, false, math.random(12,21)/10)
		end
	elseif data.state == "Run" then
		if data.goldrun then
			mod:spritePlay(sprite, "PickupIdle")
		else
			mod:spritePlay(sprite, "Idle")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(-8), 0.05)
		
		if npc.Position:Distance(target.Position) > 500 then
			local cNum = (255-npc.StateFrame*3)
			npc:SetColor(Color(cNum/255, cNum/255, cNum/255, cNum/255, 0, 0, 0), 15, 1, true, false)
			if cNum <= 0 then
				npc:Remove()
				if data.targetBall then
					data.targetBall:Remove()
				end
			end
		else
			npc.StateFrame = 0
		end
	end
end

function mod:grittyHurt(npc, damage, flag, source)
	if flag ~= flag | DamageFlag.DAMAGE_CLONES and source.Entity and ((source.Entity.Type == 915 and source.Entity.Variant == 1) or (source.Entity.SpawnerType == 915 and source.Entity.SpawnerVariant == 1)) then
		npc:TakeDamage(damage/4, flag | DamageFlag.DAMAGE_CLONES, source, 0)
		return false
	end
end

function mod.findGrittyBalls(pos)
	local target = nil
	local radius = 9999
	local normalballs = {}
	local goldballs = {}
	for _,ball in ipairs(Isaac.FindByType(915, 1, -1, EntityPartition.ENEMY, false)) do
		local balltype = mod:GetBallType(ball.SubType)
		if balltype == mod.FF.RockBallGold.Sub then
			table.insert(goldballs, ball)
		else
			table.insert(normalballs, ball)
		end
	end
	local balltable
	if normalballs and #normalballs > 0 then
		balltable = normalballs
	else
		--print("its gold")
		balltable = goldballs
	end
	for _, ball in pairs(balltable) do
		local realBall = ball:ToNPC()
		local data = realBall:GetData()
		if data.grittyClaimed == nil and ball.Visible == true then
			local distance = realBall.Position:Distance(pos)
			if distance < radius and realBall.V2.Y > -20 then
				target = ball
				radius = distance
			end
		end
	end
	
	return target
end

function mod:singeBallsAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local room = game:GetRoom()
	
	if not data.init then
		local mask = npc.SubType % 8

		if mask & 2 ~= 0 then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
			npc.State = 16
			npc.Visible = false
		elseif mask & 1 ~= 0 then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.falling = true
			npc.State = 16
		end

		if mask & 4 == 0 then
			data.breakAfter = true
		end
		
		data.init = true
	end
	
	if data.breakAfter == true then
		if room:IsClear() and npc.V2.Y >= 0 and mod.CanIComeOutYet() then
			npc:Kill()
		end
	end
	
	if data.grittyClaimed ~= nil then
		if not data.grittyClaimed:Exists() or mod:isStatusCorpse(data.grittyClaimed) then
			data.grittyClaimed = nil
			if data.pickedUp == true then
				data.pickedUp = nil
				data.holdPosition = nil
			end
		end
	end

	if data.pickedUp == true then
		if data.holdPosition == nil then
			if sprite:IsPlaying("RollVert") then
				data.playing = "RollVert"
			else
				data.playing = "RollHori"
			end
			data.holdPosition = npc.V1
			npc.V2 = Vector(0,-20)
		else
			npc.V2 = Vector(0,-40)
		end
		npc.V1 = data.holdPosition
		sprite:Play(data.playing, true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = GridCollisionClass.COLLISION_WALL
		npc.Velocity = data.grittyClaimed.Position-npc.Position
		if npc.Index < data.grittyClaimed.Index then
			npc.Velocity = npc.Velocity+data.grittyClaimed.Velocity
		end
	elseif data.justThrown and data.justThrown > 0 then
		data.justThrown = data.justThrown-1
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = GridCollisionClass.COLLISION_WALL
	end
	
	if npc.State == 16 then
		if data.falling then
			npc.V2 = Vector(0, data.forceHeight or -490)
			npc.State = 3
			npc.Visible = true
		else
			npc.StateFrame = npc.StateFrame+1
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			if mod.CanIComeOutYet() then
				if npc.StateFrame > 15 then
					if mod.farFromAllPlayers(npc.Position, 60) then
						npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
						data.falling = true
						npc.V2 = Vector(0, -490)
					end
				end
			else
				npc.StateFrame = 0
			end
		end
	else
		if data.marlinTossed then
			if npc.V2.Y <= -400 then
				local rocksub = mod:GetBallType(npc.SubType)
				local ball = Isaac.Spawn(915,1,rocksub + 1,npc:GetPlayerTarget().Position,Vector.Zero,npc):ToNPC()
				local balldata = ball:GetData()
				balldata.fallfaster = true
				balldata.forceHeight = -340
				if rocksub == mod.FF.RockBallMinesLava.Sub or rocksub == mod.FF.RockBallAshpitLava.Sub or rocksub == mod.FF.RockBallGold.Sub then
					balldata.breakOnImpact = true
				end
				ball:Update()
				npc:Remove()
			else
				npc.V2 = Vector(0, npc.V2.Y - 75)
			end
		elseif npc.FrameCount > 0 then
			if data.fallfaster then
				if npc.V2.Y >= -16 then
					data.fallfaster = false
				else
					npc.V2 = Vector(0, npc.V2.Y + 15)
				end
			end
			if data.breakOnImpact then
				if npc.V2.Y >= 0 then
					npc:Kill()
				end
			end
		end
	end
end