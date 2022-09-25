local mod = FiendFolio

-- Game Config
local game = Game()
local nilvector = Vector.Zero

local function getAllWhispers()
	return Isaac.FindByType(mod.FF.WhispersController.ID, mod.FF.WhispersController.Var, -1, false, false)
end

mod.WhisperMarkers = {}
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	mod.WhisperMarkers = {}

	local markers = Isaac.FindByType(mod.FF.WhispersMarker.ID, mod.FF.WhispersMarker.Var, -1, false, false)
	if #markers > 0 then
		local sweepMarkers = {
			Groups = {},
			Min = {},
			Max = {},
			Loop = {}
		}
		local shootMarkers = {
			Groups = {}
		}
		for _, marker in ipairs(markers) do
			local pointType = FiendFolio.GetBits(marker.SubType, 0, 1)
			local group = FiendFolio.GetBits(marker.SubType, 1, 4)
			local sweepIndex = FiendFolio.GetBits(marker.SubType, 5, 4)
			local xOffset = FiendFolio.GetBits(marker.SubType, 9, 3) - 3
			local yOffset = FiendFolio.GetBits(marker.SubType, 12, 3) - 3
			local loop = FiendFolio.GetBits(marker.SubType, 15, 1) == 1
			local pos = marker.Position + Vector(40 * xOffset, 40 * yOffset)

			if pointType == 0 then -- shoot point
				if not mod:Contains(shootMarkers.Groups, group) then
					shootMarkers.Groups[#shootMarkers.Groups + 1] = group
				end

				shootMarkers[group] = shootMarkers[group] or {}
				shootMarkers[group][#shootMarkers[group] + 1] = pos
			else -- sweep point
				if not mod:Contains(sweepMarkers.Groups, group) then
					sweepMarkers.Groups[#sweepMarkers.Groups + 1] = group
				end

				sweepMarkers[group] = sweepMarkers[group] or {}
				sweepMarkers[group][sweepIndex] = pos
				sweepMarkers.Min[group] = sweepMarkers.Min[group] or sweepIndex
				sweepMarkers.Min[group] = math.min(sweepIndex, sweepMarkers.Min[group])
				sweepMarkers.Max[group] = sweepMarkers.Max[group] or sweepIndex
				sweepMarkers.Max[group] = math.max(sweepIndex, sweepMarkers.Max[group])
				sweepMarkers.Loop[group] = sweepMarkers.Loop[group] or loop
			end


			marker:Remove()
		end

		mod.WhisperMarkers.Sweep = sweepMarkers
		mod.WhisperMarkers.Shoot = shootMarkers
	end
end)

-- Ghosty Stuff


local GhostyBalanceTable = {
	speedIdle = 3,
	speedSweep = 7.25,
	speedShoot = 1.5,
}

-- Upon Spawn
function mod:whispersControllerInit(npc)
	local data = npc:GetData()

	data.buddies = {}

	for i = 1, 3 do
		local vecfun = Vector(0,10):Rotated(i * (360/3))
		local buddy = Isaac.Spawn(mod.FF.Whispers.ID, mod.FF.Whispers.Var, 0, npc.Position + vecfun, Vector.Zero, npc)
		buddy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		buddy:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
		buddy.Parent = npc
		buddy:GetData().orbitOffset = (i*(360/3))

		local sprite = buddy:GetSprite()
		sprite:Play("ChargeStart")
		if i == 2 then
			sprite:ReplaceSpritesheet(0, "gfx/bosses/whispers/ghosty2.png")
			sprite:LoadGraphics()
		end
		if i == 3 then
			sprite:ReplaceSpritesheet(0, "gfx/bosses/whispers/ghosty3.png")
			sprite:LoadGraphics()
		end
		buddy:Update()

		data.buddies[i] = buddy
	end

	data.bal = GhostyBalanceTable
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	npc:AddEntityFlags(EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_STATUS_EFFECTS)
	data.SweepCount = 0
	data.Direction = data.Direction or "Down"
	data.Shooting = false
	npc.Color = Color(1,1,1,0,0,0,0)
	npc.Visible = false
end


local function GhostyGetDir(npc, sprite, data)
	local target = npc:GetPlayerTarget()
	local targetdistance = target.Position - npc.Position
	local targetrel

	if math.abs(targetdistance.X) > math.abs(targetdistance.Y) then
		if targetdistance.X < 0 then
			targetrel = "Left"
		else
			targetrel = "Right"
		end
	else
		if targetdistance.Y < 0 then
			targetrel = "Up"
		else
			targetrel = "Down"
		end
	end

	return targetrel
end


local function GhostyIdleBehavior(npc, sprite, data)
	local target = npc:GetPlayerTarget()
	local targetvel = (target.Position - npc.Position):Resized(data.bal.speedIdle)
	data.Shooting = false
	
	if not sprite:IsPlaying("Idle") then
		sprite:Play("Idle", true)
	end
	
	for i = 1, 3 do
		data.buddies[i]:GetData().State = data.State
	end

	npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
end


local function pickShootPos(npc, data)
	local target = npc:GetPlayerTarget()
	local shootPositions = data.ShootMarkers[data.ShootGroup]
	local bestPositions = {}
	local okayPositions = {}
	local yeahPositions = {}
	local ehPositions = {}

	for _, shootPos in ipairs(shootPositions) do
		local distanceToPlayer = 0
		local distanceToLastShoot = 0
		if target then
			distanceToPlayer = shootPos:Distance(target.Position)
		end

		if data.ShootPosition then
			distanceToLastShoot = shootPos:Distance(data.ShootPosition)
		end

		if distanceToPlayer > 150 and distanceToPlayer < 350 and distanceToLastShoot > 150 then
			bestPositions[#bestPositions + 1] = shootPos
		elseif distanceToPlayer > 150 and distanceToPlayer < 350 then
			okayPositions[#okayPositions + 1] = shootPos
		elseif distanceToPlayer > 150 and distanceToLastShoot > 150 then
			yeahPositions[#yeahPositions + 1] = shootPos
		elseif distanceToPlayer > 150 then
			ehPositions[#ehPositions + 1] = shootPos
		end
	end

	if #bestPositions > 0 then
		data.ShootPosition = bestPositions[math.random(1, #bestPositions)]
	elseif #okayPositions > 0 then
		data.ShootPosition = okayPositions[math.random(1, #okayPositions)]
	elseif #yeahPositions > 0 then
		data.ShootPosition = yeahPositions[math.random(1, #yeahPositions)]
	elseif #ehPositions > 0 then
		data.ShootPosition = ehPositions[math.random(1, #ehPositions)]
	else
		data.ShootPosition = shootPositions[math.random(1, #shootPositions)]
	end
end

local function GhostyShootBehavior(npc, sprite, data)
	local target = npc:GetPlayerTarget()
	local targetvel = (target.Position - npc.Position):Resized(data.bal.speedShoot)
	
	npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)	
	
	if not data.Shooting then
		data.Direction = GhostyGetDir(npc, sprite, data)
	end
	
	if not sprite:IsPlaying("ShootLoop" .. data.Direction) and not data.Shooting then
		sprite:Play("ShootLoop" .. data.Direction)
		
		for i = 1, 3 do
			--data.buddies[i]:GetData().State = data.State
			data.buddies[i]:GetSprite():Play("ShootLoop" .. data.Direction)
		end				
	end
	
	if npc.FrameCount % 60 == 0 then
		data.Shooting = true
		sprite:Play("ShootEnd" .. data.Direction)
		for i = 1, 3 do
			--data.buddies[i]:GetData().State = data.State
			data.buddies[i]:GetSprite():Play("ShootEnd" .. data.Direction)
		end				
	end	
	
	if sprite:IsEventTriggered("Shoot") then
		npc:PlaySound(SoundEffect.SOUND_WEIRD_WORM_SPIT,0.8,0,false,1.5)
		local angle = angle or 0
		
		if data.Direction == "Up" then
			angle = 0
		elseif data.Direction == "Right" then
			angle = 1
		elseif data.Direction == "Down" then
			angle = 2
		elseif data.Direction == "Left" then
			angle = 3
		end

		for i = 1, 3 do
			local e = Isaac.Spawn(1000, 2, 2, data.buddies[i].Position, nilvector, npc):ToEffect()
			e.Color = Color(0,0,0,0.3,204 / 255,204 / 255,204 / 255)

			for j = 1, 3 do
				local vel = Vector(0, (-8 - (2*j) - (math.random(5)/10))):Rotated((angle * 90) + math.random(-1,1))
				local p = Isaac.Spawn(9, 4, 0, data.buddies[i].Position, vel, npc):ToProjectile()
				p.FallingSpeed = -4 - (math.random(5)/20)
				p.FallingAccel = 0.5 - (j/10) - (math.random(5)/20)
				p.Scale = 1 + math.random(4)/8
				p.Parent = npc
				p.ProjectileFlags = p.ProjectileFlags | ProjectileFlags.GHOST
			end
		end
	end

	if sprite:IsFinished("ShootEnd" .. data.Direction) then
		data.State = "Idle"
		for i = 1, 3 do
			data.buddies[i]:GetData().State = data.State
		end
	end
end


local function GhostySweepBehavior(npc, sprite, data)
	if sprite:IsFinished("Reappear") and (data.SweepPos == "Left" or data.SweepPos == "Right") then
		sprite:Play("ChargeLoop")
	end

	local sweepPos = data.SweepMarkers[data.SweepGroup][data.SweepIndex]
	local targetVel = (sweepPos - npc.Position):Resized(data.bal.speedSweep)
	npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.05)

	if npc.Position:DistanceSquared(sweepPos) < 20 ^ 2 then
		local backwards = data.SweepIndex - data.SweepDirection
		data.SweepIndex = data.SweepIndex + data.SweepDirection
		if not data.SweepMarkers[data.SweepGroup][data.SweepIndex] then -- switch directions
			if data.SweepLoop then
				if data.SweepDirection == 1 then
					data.SweepIndex = data.SweepMin
				else
					data.SweepIndex = data.SweepMax
				end

				data.SweepCount = data.SweepCount + 1
			else
				if data.SweepMarkers[data.SweepGroup][backwards] then
					data.SweepDirection = -data.SweepDirection
					data.SweepIndex = backwards
					data.SweepCount = data.SweepCount + 1
				elseif npc.FrameCount % 120 == 1 then
					data.SweepCount = data.SweepCount + 1
				end
			end
		end
	end

	if data.SweepCount == 3 then
		sprite:Play("ChargeEnd")
		npc.Velocity = npc.Velocity * 0.8
		data.SweepCount = 0
		data.SweepPos = "End"

		for i = 1, 3 do
			data.buddies[i]:GetSprite():Play("ChargeEnd")
		end
	end

	if sprite:IsFinished("ChargeEnd") then
		data.State = "Idle"

		for i = 1, 3 do
			data.buddies[i]:GetData().State = data.State
		end
	end
end


local function GhostyTeleport(npc, sprite, data)
	npc.Velocity = npc.Velocity * 0.8

	if sprite:IsFinished("Vanish") then
		if data.Attack == "Sweep" then
			sprite:Play("Reappear")

			for i = 1, 3 do
				data.buddies[i]:GetSprite():Play("Reappear")
			end
			
			npc.Position = data.SweepMarkers[data.SweepGroup][data.SweepIndex]
			if data.SweepMarkers[data.SweepGroup][data.SweepIndex + data.SweepDirection] then
				data.SweepIndex = data.SweepIndex + data.SweepDirection
			end
		elseif data.Attack == "Shoot" then
			pickShootPos(npc, data)
			npc.Position = data.ShootPosition
			data.Direction = GhostyGetDir(npc, sprite, data)
			sprite:Play("ShootStart" .. data.Direction)

			for i = 1, 3 do
				data.buddies[i]:GetSprite():Play("ShootStart" .. data.Direction)
			end

		else
			print("ERROR: Attack not set")
			data.State = "Idle"
		end

		for i = 1, 3 do
			data.buddies[i]:GetData().Attack = data.Attack
			data.buddies[i].Position = npc.Position
		end

		local e = Isaac.Spawn(1000, 16, 0, npc.Position, nilvector, npc):ToEffect()
		npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.5, 0, false, math.random(100,120)/100)
		e.Color = Color(0,0,0,0.3,204 / 255,204 / 255,204 / 255)
		e.SpriteScale = e.SpriteScale * 1.5		
	end

	if sprite:IsFinished("Reappear") then
		data.State = "Sweep"
		npc:PlaySound(SoundEffect.SOUND_SATAN_GROW,0.8,0,false,2.5)

		for i = 1, 3 do
			data.buddies[i]:GetData().State = data.State
			data.buddies[i].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		end
	end

	if data.Direction then	
		if sprite:IsFinished("ShootStart" .. data.Direction) then
			data.State = "Shoot"
		end

		for i = 1, 3 do
			data.buddies[i]:GetData().State = data.State
			data.buddies[i].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		end
	end
end


function mod:whispersControllerAI(npc, sprite, data)
	if not data.Init then
		data.Init = true
		mod:whispersControllerInit(npc)
	end

	if sprite:IsFinished("Appear") then
		data.State = "Idle"
	end

	if npc.FrameCount > 0 and (not data.ShootMarkers or not data.SweepMarkers) then
		local shootMarkers = mod.WhisperMarkers.Shoot
		local sweepMarkers = mod.WhisperMarkers.Sweep
		local numShootGroups = #shootMarkers.Groups
		local numSweepGroups = #sweepMarkers.Groups
		if numShootGroups == 0 or numSweepGroups == 0 then
			if numShootGroups == 0 then
				print("[Error] INVALID WHISPER GROUPS, NO SHOOTING POSITIONS")
			end
			
			if numSweepGroups == 0 then
				print("[Error] INVALID WHISPER GROUPS, NO SWEEPING POSITIONS")
			end
			
			npc:Kill()
		end

		data.ShootMarkers = shootMarkers
		data.SweepMarkers = sweepMarkers
	end

	local whispers = getAllWhispers()
	local allIdle = true
	for _, whisper in ipairs(whispers) do
		if whisper:GetData().State ~= "Idle" then
			allIdle = false
			break
		end
	end
	
	local target = npc:GetPlayerTarget()
	-- Picks between two attacks every 2 seconds idling
	if npc.FrameCount > 0 and npc.FrameCount % 120 == 0 and data.State == "Idle" then
		if data.TimesToShoot then
			data.TimesToShoot = data.TimesToShoot - 1
			if data.TimesToShoot <= 0 then
				data.TimesToShoot = nil
			end
		end

		if data.TimesToShoot then
			data.Attack = "Shoot"
			data.State = "Teleport"
			sprite:Play("Vanish")
			for i = 1, 3 do
				data.buddies[i]:GetData().State = data.State
				data.buddies[i]:GetSprite():Play("Vanish")
			end
		elseif allIdle then
			local nextAttack, timesToShoot
			if data.Attack == "Shoot" then
				nextAttack = "Sweep"
			elseif data.Attack == "Sweep" then
				nextAttack = "Shoot"
				timesToShoot = math.random(2, 3)
			else
				if math.random(1, 3) == 1 then
					nextAttack = "Sweep"
				else
					nextAttack = "Shoot"
					timesToShoot = math.random(1, 2)
				end
			end

			local groups, baseGroups
			if nextAttack == "Shoot" then
				baseGroups = data.ShootMarkers.Groups
			else
				baseGroups = data.SweepMarkers.Groups
			end

			groups = StageAPI.Copy(baseGroups)
			mod:Shuffle(groups)

			local sweepOffset = math.random(0, 1)
			for i, whisper in ipairs(whispers) do
				local group
				if #groups > 0 then
					group = groups[#groups]
					groups[#groups] = nil
				else
					group = baseGroups[math.random(1, #baseGroups)]
				end

				local wdata, wsprite = whisper:GetData(), whisper:GetSprite()
				wdata.Attack = nextAttack
				wdata.State = "Teleport"
				wsprite:Play("Vanish")

				if nextAttack == "Shoot" then
					wdata.ShootGroup = group
					wdata.TimesToShoot = timesToShoot
				else
					wdata.SweepGroup = group
					local sweepMin = data.SweepMarkers.Min[group]
					local sweepMax = data.SweepMarkers.Max[group]
					local sweepLoop = data.SweepMarkers.Loop[group]

					wdata.SweepLoop = sweepLoop

					if #whispers == 1 then -- if only one whispers, start sweep from furthest pos from player
						local minPos = data.SweepMarkers[group][sweepMin]
						local maxPos = data.SweepMarkers[group][sweepMax]
						if target and target.Position:DistanceSquared(minPos) > target.Position:DistanceSquared(maxPos) then
							wdata.SweepIndex = sweepMin
							wdata.SweepDirection = 1
						else
							wdata.SweepIndex = sweepMax
							wdata.SweepDirection = -1
						end
					else
						local startAt = (i + sweepOffset) % 2
						if startAt == 0 then
							wdata.SweepIndex = sweepMin
							wdata.SweepDirection = 1
						else
							wdata.SweepIndex = sweepMax
							wdata.SweepDirection = -1
						end
					end

					wdata.SweepMin = sweepMin
					wdata.SweepMax = sweepMax
				end

				for i2 = 1, 3 do
					wdata.buddies[i2]:GetData().State = wdata.State
					wdata.buddies[i2]:GetSprite():Play("Vanish")
				end
			end
		end

		if data.Attack == "Shoot" and data.State == "Teleport" then -- this looks complex and stupid and maybe it is but all its really supposed to do is make it not shoot too close to the player or where it last shot

		end
	end

	if data.State == "Idle" then
		GhostyIdleBehavior(npc, sprite, data)
		--data.Teleport = true		
	end
		
	if data.State == "Teleport" then
		GhostyTeleport(npc, sprite, data)
	end
	
	if data.State == "Sweep" then
		GhostySweepBehavior(npc, sprite, data)
	end
	
	if data.State == "Shoot" then
		GhostyShootBehavior(npc, sprite, data)
	end
end


-- Buddy shit
local BuddyBalanceTable = {
	distanceDefault = 60,
	distanceShoot = 100,
	distanceBig = 180,
	
	speedDefault = 4,
	speedShoot = 2,
	speedFast = 6
}

function mod:whispersInit(npc)
	local data = npc:GetData()
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	npc.SplatColor = Color(0,0,0,0.3,204 / 255,204 / 255,204 / 255)
	data.bal = BuddyBalanceTable
	data.distance = data.bal.distanceDefault
	data.speed = 0
	data.appear = true
end

function mod:whispersAI(npc, sprite, data)
	if not data.Init then
		mod:whispersInit(npc)
		data.Init = true
	end

	if data.appear then
		sprite:Play("ChargeStart")
	end

	if sprite:IsFinished("ChargeStart") then
		data.appear = false
	end

	if npc.Parent then
		if npc.Parent:IsDead() then
			npc.Parent:Remove()
			npc:Kill()
		else
			local distance, speed = data.bal.distanceDefault, data.bal.speedDefault
			if data.State == "Idle" then
				if not sprite:IsPlaying("ChargeStart") and not sprite:IsPlaying("Idle") then
					sprite:Play("Idle")
				end
			end

			if data.State == "Teleport" then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				if data.Attack == "Sweep" then
					distance = data.bal.distanceBig
				elseif data.Attack == "Shoot" then
					distance = data.bal.distanceShoot
				end

				speed = data.bal.speedFast
			else
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			end

			if data.State == "Sweep" then
				if not sprite:IsPlaying("ChargeLoop") then
					sprite:Play("ChargeLoop")
				end

				distance = data.bal.distanceBig
				speed = data.bal.speedFast
			end

			if data.State == "Shoot" then
				distance = data.bal.distanceShoot
				speed = data.bal.speedFast
			end

			data.distance = mod:Lerp(data.distance, distance, 0.1)
			data.speed = mod:Lerp(data.speed, speed, 0.2)

			local targetpos = npc.Parent.Position + Vector(0, data.distance):Rotated(data.orbitOffset)
			local targetvec = (targetpos - npc.Position)
			local targetvel = targetvec:Resized(math.min(20,targetvec:Length() / 10))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 1)
			data.orbitOffset = data.orbitOffset + data.speed
		end
	else
		npc:Kill()
	end
end

function mod:whispersHurt(npc, damage, flag, source)
	if npc.Parent then
		if npc.Parent.Variant == mod.FF.WhispersController.Var then
			npc:SetColor(FiendFolio.damageFlashColor, 2, 0, false, false)
			npc.Parent:TakeDamage(damage, flag, EntityRef(npc), 0)
			return false
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
	for _, npc in pairs(Isaac.FindByType(mod.FF.Whispers.ID, mod.FF.Whispers.Var)) do
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end
end, CollectibleType.COLLECTIBLE_MEAT_CLEAVER)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	for _, npc in pairs(Isaac.FindByType(mod.FF.Whispers.ID, mod.FF.Whispers.Var)) do
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end
end, CollectibleType.COLLECTIBLE_MEAT_CLEAVER)