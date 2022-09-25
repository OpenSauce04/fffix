local mod = FiendFolio
local game = Game()

local function congaSkuzzShift(npc, pos, hopCount)
	local room = game:GetRoom()
	local vel = (pos-npc.Position)
	if hopCount % 2 == 0 then
		vel = vel:Resized(40):Rotated(-90)
		return room:FindFreeTilePosition(pos+vel, 20)
	else
		vel = vel:Resized(40):Rotated(90)
		return room:FindFreeTilePosition(pos+vel, 20)
	end
end

function mod:congaSkuzzAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	
	if not data.init then
		data.state = "Idle"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BURSTING_SACK) then
			sprite:Load("gfx/enemies/skuzzball/skuzzgriend.anm2",true)
			npc.CollisionDamage = 0
		end
		
		if npc.SubType > 0 then
			data.trueLeader = true
		end
		data.hopCount = 0
		
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if (npc.I1 == 0 and npc.FrameCount > 1) or data.trueLeader then
		if not npc.Child and not data.leadingMember then
			data.leadingMember = true
				
			local curr = npc
			while curr do
				local did
				local closest
				local dist = 60
				for _, ent in pairs (Isaac.FindByType(npc.Type, npc.Variant, -1)) do
					if ent.Position:Distance(curr.Position) < dist and not ent:GetData().leadingMember and ent:ToNPC().I1 == 0 and ent.SubType == 0 then
						closest = ent
						dist = ent.Position:Distance(curr.Position)
					end
				end

				if closest then
					did = true

					local cData = closest:GetData()
					curr.Child = closest
					closest.Parent = curr
					closest:ToNPC().I1 = curr:ToNPC().I1+1
					curr = closest
				end

				if not did then
					curr = nil 
				end
			end
		end
	elseif npc.FrameCount > 1 then
		if npc.Parent and npc.Parent:Exists() then
			if npc.Parent:IsDead() or FiendFolio:isStatusCorpse(npc.Parent) then
				data.leadingMember = true
				npc.I1 = 0
			end
		else
			data.leadingMember = true
			npc.I1 = 0
		end
	end
	
	--[[if npc.I1 == 0 then
		npc.Color = Color(1,1,1,1,1,0,0)
	end]]
	
	if data.state == "Idle" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
		
		if npc.StateFrame > 80 and npc.I1 == 0 then
			data.state = "Start"
		elseif npc.Parent and npc.Parent:GetData().state == "Hop" then
			data.state = "Start"
		end
		
		mod:spritePlay(sprite, "idle")
	elseif data.state == "Hop" then
		mod:spritePlay(sprite, "hop")
	elseif data.state == "Start" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
		
		if sprite:IsFinished("hopstart") then
			npc:PlaySound(SoundEffect.SOUND_FETUS_LAND,0.6,1,false,2.7)
			data.state = "Hop"
			if npc.I1 > 0 and npc.Parent then
				data.targetPos = (npc.Parent:GetData().originalPos or npc.Parent.Position)
			elseif mod:isScare(npc) then
				data.targetPos = mod:FindClosestFreePosition(npc, target, nil, 120, 1)
			elseif mod:isConfuse(npc) then
				data.targetPos = mod:chooserandomlocationforskuzz(npc, 150, 50, not (npc:HasEntityFlags(EntityFlag.FLAG_FEAR) or npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)))
			else
				data.targetPos = mod:FindClosestFreePosition(npc, target, nil, 120, 0)
				if npc.Position:Distance(target.Position) > 100 then
					data.targetPos = congaSkuzzShift(npc, data.targetPos, data.hopCount)
					--Isaac.Spawn(9, 0, 0, data.targetPos, Vector.Zero, nil)
				end
			end
			
			local lengthto = data.targetPos - npc.Position
			npc.Velocity = Vector(lengthto.X / 15 , lengthto.Y / 15) * 0.90
			
			data.hopCount  = data.hopCount+1
			data.originalPos = npc.Position
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			data.launchedEnemyInfo = {zVel = -11, accel = 0.65, collision = 0, pos = true, vel = Vector(lengthto.X / 15 , lengthto.Y / 15) * 0.90,landFunc = function(npc, tab)
				npc:PlaySound(SoundEffect.SOUND_FETUS_LAND,0.6,1,false,1.7)
				data.state = "Land"
				npc.Velocity = Vector.Zero
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end}
		else
			mod:spritePlay(sprite, "hopstart")
		end
	elseif data.state == "Land" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("land") then
			data.state = "Idle"
			if data.hopCount < 3 then
				npc.StateFrame = 70
			else
				data.hopCount = 0
				npc.StateFrame = 0
			end
		else
			mod:spritePlay(sprite, "land")
		end
	end
end