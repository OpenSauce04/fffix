local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:SizzleAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
	local room = game:GetRoom()
    if not data.Init then
		npc.SplatColor = mod.ColorFireJuicy
		if npc.SubType == 1 then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			sprite:Play("Idle02")
			npc.StateFrame = mod:RandomInt(5,10)
			data.state = "extinguish"
			data.stoned = true
			data.extinguished = 1
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		elseif npc.SubType == 2 then
			if data.waited then
				data.state = "emerge"
				npc.Visible = true
				data.airborne = true
				data.splashpos = npc.Position
				npc.Velocity = (mod:GetNearestPosOfCollisionClass(npc.Position, GridCollisionClass.COLLISION_NONE) - npc.Position) / 6
				mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
			else
				room:SpawnGridEntity(room:GetGridIndex(npc.Position), GridEntityType.GRID_PIT, 0, 0, 0)
				mod:UpdatePits()
				mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 80, false)
			end
		else
			npc.StateFrame = mod:RandomInt(50,75)
			data.state = "idle"
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		end
		data.jumps = 0
		data.Init = true
    end
    if data.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.9
        npc.StateFrame = npc.StateFrame - 1
		if npc.StateFrame <= 40 and game:GetRoom():CheckLine(targetpos,npc.Position,3,900,false,false) and not mod:isConfuse(npc) then
			if data.jumps > 1 or mod:isScare(npc) then
				data.state = "charge"
			else
				data.state = "attack"
                mod:FlipSprite(sprite, npc.Position, targetpos)
			end
		elseif npc.StateFrame <= 0 or mod:isScare(npc) then
			if data.jumps > 0 then
				data.state = "charge"
			else
				data.state = "attack"
                mod:FlipSprite(sprite, npc.Position, targetpos)
			end
		end
	elseif data.state == "attack" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Attack") then
			data.state = "idle"
			data.jumps = data.jumps + 1
			npc.StateFrame = mod:RandomInt(50,75)
        elseif sprite:IsEventTriggered("Jump") then
            data.airborne = true
		elseif sprite:IsEventTriggered("Shoot") then
            local wave = Isaac.Spawn(1000,148,0,npc.Position,Vector.Zero,npc):ToEffect()
            wave.Rotation = (targetpos - npc.Position):GetAngleDegrees()
            mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc, 0.8, 1.5)
            local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc):ToEffect()
            effect.Color = mod.ColorFireJuicy
            effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
            data.airborne = false
		else
			mod:spritePlay(sprite, "Attack")
		end
	elseif data.state == "charge" then
		if not data.charging then
			npc.Velocity = npc.Velocity * 0.85
			if sprite:IsEventTriggered("CHAAARGE") then
				npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(16))
				npc:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR,1,0,false,1)
				data.charging = 1
                npc.StateFrame = 50
			else
				mod:spritePlay(sprite, "Charge")
			end
		elseif data.charging == 1 then
			if sprite:IsFinished("Charge") then
				mod:spritePlay(sprite, "ChargeLoop")
			end
			data.speed = data.speed or npc.Velocity:Length()
			if npc:CollidesWithGrid() then
				data.speed = data.speed * 0.8
			end
            if npc.FrameCount % 8 == 0 then
                local fire = Isaac.Spawn(33, 10, 0, npc.Position, Vector.Zero, npc)
                fire.HitPoints = math.max(2, npc.Velocity:Length() / 3 - 1)
				fire:Update()
            end
			npc.Velocity = npc.Velocity:Resized(data.speed)
            npc.StateFrame = npc.StateFrame - 1
			if npc.StateFrame <= 0 then
				data.charging = 2
				npc.StateFrame = 15
			end
		elseif data.charging == 2 then
			npc.Velocity = npc.Velocity * 0.9
            npc.StateFrame = npc.StateFrame - 1
			if npc.StateFrame <= 0 then
				data.charging = nil
				data.state = "extinguish"
				data.extinguished = 0
				data.jumps = 0
				data.speed = nil
				npc.StateFrame = mod:RandomInt(50,75)
				mod:PlaySound(mod.Sounds.SizzleExtinguish, npc, 1)
			end
		end

		if data.charging then
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
		else
            mod:FlipSprite(sprite, npc.Position, targetpos)
		end
	elseif data.state == "extinguish" then
		if data.extinguished == 0 then
			npc.Velocity = npc.Velocity * 0.85
			if sprite:IsFinished("Extinguished") then
				data.extinguished = 1
				npc.StateFrame = mod:RandomInt(5,10)
			elseif sprite:IsEventTriggered("Stoned") then
				data.stoned = true
			else
				mod:spritePlay(sprite, "Extinguished")
			end
			if not sprite:WasEventTriggered("Stoned") then
				local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position + Vector(0,-10), Vector(0,mod:RandomInt(4,7)):Rotated(-35 + mod:RandomInt(0,70) + 180), npc):ToEffect()
				smoke:GetData().longonly = true
				smoke.SpriteRotation = mod:RandomInt(360)
				smoke.Color = Color(0.8,0.8,0.8,0.4)
				smoke.SpriteOffset = Vector(0,3)
				smoke.RenderZOffset = 300
				smoke:Update()
			end
		elseif data.extinguished == 1 then
			npc.Velocity = npc.Velocity * 0.5
			mod:spritePlay(sprite, "Idle02")
			npc.StateFrame = npc.StateFrame - 1
			if npc.StateFrame <= 0 then
				data.TargetIndex = data.TargetIndex or mod:GetSizzleTarget(npc)
				if not mod:IsPitAdjacent(data.TargetIndex) then
					data.TargetIndex = mod:GetSizzleTarget(npc)
				end
				if data.TargetIndex and room:GetGridPosition(data.TargetIndex):Distance(npc.Position) < 40 then
					data.extinguished = 3
					npc.StateFrame = mod:RandomInt(30,45)
				else
					data.extinguished = 2
				end
			end
		elseif data.extinguished == 2 then
			if sprite:WasEventTriggered("Land") then
				npc.Velocity = npc.Velocity * 0.7
			else
				npc.Velocity = npc.Velocity * 0.9
			end
			if sprite:IsEventTriggered("Jump") then
				if data.TargetIndex and mod:IsPitAdjacent(data.TargetIndex) and not mod:isConfuse(npc) then
					if room:CheckLine(npc.Position,room:GetGridPosition(data.TargetIndex),0,1,false,false) then
						npc.Velocity = (room:GetGridPosition(data.TargetIndex) - npc.Position):Resized(8)
					else	
						npc.Pathfinder:FindGridPath(room:GetGridPosition(data.TargetIndex), 2, 900, true)
					end
				else
					npc.Velocity = RandomVector():Resized(8)
				end
				mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
				npc:PlaySound(SoundEffect.SOUND_FETUS_JUMP,0.8,0,false,1)
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_STONE_IMPACT,0.8,0,false,1.2)
			elseif sprite:IsFinished("Hop") then
				data.extinguished = 1
				npc.StateFrame = mod:RandomInt(5,10)
			else
				mod:spritePlay(sprite, "Hop")
			end
		elseif data.extinguished == 3 then
			if sprite:WasEventTriggered("Land") then
				npc.Velocity = npc.Velocity * 0.7
			else
				npc.Velocity = npc.Velocity * 0.9
			end
			if sprite:IsEventTriggered("Jump") then
				local pit = mod:GetNearestGridIndexOfType(GridEntityType.GRID_PIT, GridCollisionClass.COLLISION_PIT, npc.Position) or data.TargetIndex
				npc.Velocity = (room:GetGridPosition(pit) - npc.Position) / 8
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				npc:PlaySound(SoundEffect.SOUND_FETUS_JUMP,0.8,0,false,1)
				mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
			elseif sprite:IsEventTriggered("Land") then
				local effect = Isaac.Spawn(1000,16,67,npc.Position,Vector.Zero,npc):ToEffect()
                effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
                sfx:Play(SoundEffect.SOUND_WAR_LAVA_SPLASH)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
			elseif sprite:IsFinished("HopPit") then
				npc.Visible = false
				npc.StateFrame = npc.StateFrame - 1
				if npc.StateFrame <= 0 then
					data.state = "emerge"
					npc.Visible = true
					data.extinguished = nil
					data.airborne = true
					data.TargetIndex = nil
					data.splashpos = npc.Position
					npc.Velocity = (mod:GetNearestPosOfCollisionClass(npc.Position, GridCollisionClass.COLLISION_NONE) - npc.Position) / 6
					mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
					data.stoned = false
				end
			else
				mod:spritePlay(sprite, "HopPit")
			end
		end
	elseif data.state =="emerge" then
		if sprite:WasEventTriggered("Land") then
			npc.Velocity = npc.Velocity * 0.7
		else
			npc.Velocity = npc.Velocity * 0.9
		end
		if sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
			local effect = Isaac.Spawn(1000,16,67,data.splashpos,Vector.Zero,npc):ToEffect()
			effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
			sfx:Play(SoundEffect.SOUND_WAR_LAVA_SPLASH)
		elseif sprite:IsEventTriggered("Land") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc, 0.8, 1.5)
            local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc):ToEffect()
            effect.Color = mod.ColorFireJuicy
            effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
			data.airborne = false
		elseif sprite:IsFinished("Emerge") then
			data.state = "idle"

		else
			mod:spritePlay(sprite, "Emerge")
		end
	else
		data.state = "idle"
	end

    local interval = 15
    if data.charging then
        interval = 5
    end
    if npc.FrameCount % interval == 1 and not (data.airborne or data.extinguished or data.IsFerrWaiting) then
        local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
        creep.Color = mod.ColorGreyscaleLight
        creep:SetColor(mod.ColorFireJuicy, interval * 3, 0, true, false)
        creep.SpriteScale = creep.SpriteScale * 1.5
        creep:SetTimeout(interval * 2)
    end

	if room:HasWater() then
		npc:Kill()
	end

	if npc:IsDead() then
		local globsub = 0
		if data.stoned then
			for i = 0, 5 do
				local shard = Isaac.Spawn(1000, 35, 0, npc.Position, Vector.One:Resized(rng:RandomFloat()*4):Rotated(mod:RandomAngle()), npc)
				shard.Color = mod.ColorCharred
			end
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
			globsub = 1
		end
		if npc.Visible and not data.Spawned then
			for i = -10, 10, 20 do
				local glob = Isaac.Spawn(mod.FF.Glob.ID, mod.FF.Glob.Var, globsub, npc.Position + Vector(i,0), Vector.Zero, npc)
				glob:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				if globsub == 0 then
					glob:GetData().state = "appear"
				end
			end
		end
	end
end

function mod:GetSizzleTarget(npc)
	local pathfinder = npc.Pathfinder
	local room = game:GetRoom()
	local validtiles = {}
    for i = 0, room:GetGridSize() - 1 do 
		if room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE and mod:IsPitAdjacent(i) and room:IsPositionInRoom(room:GetGridPosition(i),0) and npc.Pathfinder:HasPathToPos(room:GetGridPosition(i)) then
            table.insert(validtiles, i)
        end
	end
	local path = 10000
	local dist = 10000
	local targetindex = nil
	for i, index in pairs(validtiles) do
		local distance = npc.Position:Distance(room:GetGridPosition(index))
		--[[if distance < (dist * 0.66) or not targetindex then --Some trimming to save on performance when there are lots of choices avaliable 
			local length = mod:GridPathLength(npc, room:GetGridPosition(index))
			if (length >= 0 and length < path) or (length == path and distance < dist) then
				targetindex = index
				path = length
				dist = distance
			end
		end]]
		if distance < dist or not targetindex then
			targetindex = index
			dist = distance
		end
	end
	--print(path.." "..targetindex)
	return targetindex
end

function mod:IsPitAdjacent(index)
	local room = game:GetRoom()
	--Isaac.DebugString(index)
	if index and mod:IsValidIndex(index) then
		for _, dir in pairs(mod.GuwahDirections) do
			local adjindex = mod:GetAdjacentIndex(index, dir)
			local grid = room:GetGridEntity(adjindex)
			if grid and grid:GetType() == GridEntityType.GRID_PIT and room:GetGridCollision(adjindex) == GridCollisionClass.COLLISION_PIT then
				return true
			end
		end
	end
end

function mod:IsValidIndex(index)
	local room = game:GetRoom()
	return (index >= 0 and index <= room:GetGridSize() - 1)
end

--modified from Xalum's thing
function mod:GridPathLength(entity, targetPosition)
	local room = game:GetRoom()
	local entityPosition = mod.XalumAlignPositionToGrid(entity.Position)
	targetPosition = mod.XalumAlignPositionToGrid(targetPosition)

	local loopingPositions = {targetPosition}
	local indexedGrids = {}

	local index = 0
	while #loopingPositions > 0 do
		local temporaryLoop = {}

		for _, position in pairs(loopingPositions) do
			if room:IsPositionInRoom(position, 0) then
				if index == 0 or room:GetGridPathFromPos(position) < 900 then
					if room:GetGridCollisionAtPos(position) == GridCollisionClass.COLLISION_NONE or index == 0 then
						local gridIndex = room:GetGridIndex(position)
						if not indexedGrids[gridIndex] then
							indexedGrids[gridIndex] = index

							for i = 1, 4 do
								table.insert(temporaryLoop, position + Vector(40, 0):Rotated(i * 90))
							end
						end
					end
				end
			end
		end
		
		index = index + 1
		loopingPositions = temporaryLoop
	end

	local entityIndex = room:GetGridIndex(entityPosition)
	index = indexedGrids[entityIndex] or 99999

	for i = 1, 4 do
		local position = entityPosition + Vector(40, 0):Rotated(i * 90)
		local positionIndex = room:GetGridIndex(position)
		local value = indexedGrids[positionIndex]

		if value and value <= index then
			index = value
		end
	end

	return index
end