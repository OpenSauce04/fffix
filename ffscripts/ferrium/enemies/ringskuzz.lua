local mod = FiendFolio
local game = Game()

local function getRingSkuzzCenter(npc)
	local subt = npc.SubType
	local averagePos
	for _,skuzz in ipairs(Isaac.FindByType(mod.FF.RingSkuzz.ID, mod.FF.RingSkuzz.Var, subt, false, true)) do
		if not averagePos then
			averagePos = skuzz.Position
		else
			averagePos = skuzz.Position+(averagePos-skuzz.Position)/2
		end
	end
	return (averagePos or npc.Position)
end

local function recalculateRingSkuzzOrbit(npcTable) --Second wave of copypasting from Wires -> Specturn
	local wires = {}

	local initialoffset
	for _, wire in pairs(npcTable) do
		if wire:Exists() and not (wire:IsDead() or mod:isStatusCorpse(wire) or mod:isLeavingStatusCorpse(wire)) then
			local wireD = wire:GetData()
			if #wires < 1 then
				table.insert(wires, wire)
			else
				for i = 1, #wires do
					if wireD.rotatedAngle < wires[i]:GetData().rotatedAngle then
						table.insert(wires, i, wire)
						break
					end
				end
				if wireD.rotatedAngle > wires[#wires]:GetData().rotatedAngle then
					table.insert(wires, wire)
				end
			end
		end
	end

	if #wires > 0 then
		local initialoffset = wires[1]:GetData().rotatedAngle
		local divnum = #wires

		for i = 1, divnum do
			wires[i]:GetData().newRotatedAngle = initialoffset + (360/divnum) * (i - 1)
		end
	end
end

function mod:ringSkuzzAI(npc)
	local data = npc:GetData()
	local room = game:GetRoom()
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()

	if not data.init then
		data.state = "Idle"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BURSTING_SACK) then
			sprite:Load("gfx/enemies/skuzzball/skuzzgriend.anm2",true)
			npc.CollisionDamage = 0
		end

		local angles = 360/mod.GetEntityCount(mod.FF.RingSkuzz.ID, mod.FF.RingSkuzz.Var, npc.SubType)
		
		if mod.ringSkuzzGroups[npc.SubType] == nil then
			mod.ringSkuzzGroups[npc.SubType] = {}
			table.insert(mod.ringSkuzzGroups[npc.SubType], npc)
		else
			table.insert(mod.ringSkuzzGroups[npc.SubType], npc)
		end

		data.rotatedAngle = #mod.ringSkuzzGroups[npc.SubType]*angles
		
		data.ringRadius = 70
		
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Idle" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
		
		if npc.StateFrame > 30 then
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
			if mod:isConfuse(npc) then
				data.targetPos = mod:chooserandomlocationforskuzz(npc, 150, 50, not (npc:HasEntityFlags(EntityFlag.FLAG_FEAR) or npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)))
			else
				local center = getRingSkuzzCenter(npc)
				if not data.rotatedAngle then
					data.rotatedAngle = (npc.Position-center):GetAngleDegrees()
				end
				recalculateRingSkuzzOrbit(mod.ringSkuzzGroups[npc.SubType])
				data.rotatedAngle = (data.newRotatedAngle or 0)+40
				local dir = 75
				if mod:isScare(npc) then
					dir = -75
				end
				data.targetPos = center+Vector(0,data.ringRadius):Rotated(data.rotatedAngle)+(target.Position-center):Resized(dir)
			end
			if data.ringRadius == 70 then
				data.ringRadius = 40
			else
				data.ringRadius = 70
			end
			if (data.targetPos-npc.Position):Length() > 120 then
				data.targetPos = (data.targetPos-npc.Position):Resized(120)+npc.Position
			end
			data.targetPos = room:FindFreeTilePosition(data.targetPos, 0)
			local lengthto = data.targetPos - npc.Position
			npc.Velocity = Vector(lengthto.X / 15 , lengthto.Y / 15) * 0.90
			
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
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "land")
		end
	end
end