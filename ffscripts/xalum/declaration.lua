local mod = FiendFolio
local game = Game()

mod.gravediggerSummons = {
	{ID = {833, 0},										Count = 3},		--Candler
	{ID = {260, 10},									Count = 2},		--Lil Haunt
	{ID = {mod.FF.Yawner.ID,	mod.FF.Yawner.Var},		Count = 3},
	{ID = {mod.FF.Spoop.ID,		mod.FF.Spoop.Var},		Count = 4},
	{ID = {mod.FF.Ghostse.ID,	mod.FF.Ghostse.Var},	Count = 2},
	{ID = {mod.FF.Peekaboo.ID,	mod.FF.Peekaboo.Var},	Count = 2},
}

mod.KnotSpawnTables = { -- Knot spawns 2 entities from heavy, followed by 2 from medium, and then 2 from light
	Heavy = {
		{Entity = {215, 0, 0}, 	Weight = 1}, 	-- Lvl2 Spider
		{Entity = {94, 0, 0}, 	Weight = 0.5}, 	-- Big Spider
		{Entity = {206, 1, 0},	Weight = 0.5}, 	-- Small Baby Long Legs
		{Entity = {mod.FF.Benny.ID, mod.FF.Benny.Var, 0}, Weight = 1}, -- Benign
	},
	Medium = {
		{Entity = {215, 0, 0}, 	Weight = 0.5}, 	-- Lvl2 Spider
		{Entity = {85, 0, 0},	Weight = 1},	-- Spider
		{Entity = {mod.FF.Skuzz.ID, mod.FF.Skuzz.Var, 0}, Weight = 1} -- Skuzz
	},
	Light = {
		{Entity = {85, 0, 0},	Weight = 1},	-- Spider
		{Entity = {mod.FF.Skuzz.ID, mod.FF.Skuzz.Var, 0}, Weight = 0.5} -- Skuzz
	},
}

mod.ToothyBoners = {
	[FiendFolio.FF.TomaChunk.ID.."/"..FiendFolio.FF.TomaChunk.Var] = true, -- Toma Chunk
	[FiendFolio.FF.ConglobberateSmall.ID.."/"..FiendFolio.FF.ConglobberateSmall.Var] = true, -- Conglobberate (Small)
	[FiendFolio.FF.ConglobberateMedium.ID.."/"..FiendFolio.FF.ConglobberateMedium.Var] = true, -- Conglobberate (Medium)
	[FiendFolio.FF.ConglobberateLarge.ID.."/"..FiendFolio.FF.ConglobberateLarge.Var] = true, -- Conglobberate (Large)
	[FiendFolio.FF.Bub.ID.."/"..FiendFolio.FF.Bub.Var] = true, -- Bub
	[FiendFolio.FF.Benny.ID.."/"..FiendFolio.FF.Benny.Var] = true, -- Benny
	[FiendFolio.FF.Tommy.ID.."/"..FiendFolio.FF.Tommy.Var] = true, -- Tommy
	[FiendFolio.FF.Molargan.ID.."/"..FiendFolio.FF.Molargan.Var] = true, -- Molargan
	[FiendFolio.FF.Steralis.ID.."/"..FiendFolio.FF.Steralis.Var] = true, -- Steralis
	[FiendFolio.FF.Nematode.ID.."/"..FiendFolio.FF.Nematode.Var] = true, -- Nematode
	[FiendFolio.FF.LurkerStoma.ID.."/"..FiendFolio.FF.LurkerStoma.Var] = true, -- Lurker
	[FiendFolio.FF.Musk.ID.."/"..FiendFolio.FF.Musk.Var] = true, -- Musk
}

-- Hi its Guwah im sticking this here bc this system is really similar to the other one
mod.CornyPoopers = {
	[FiendFolio.FF.Load.ID.."/"..FiendFolio.FF.Load.Var] = true, -- Load
	[FiendFolio.FF.Poople.ID.."/"..FiendFolio.FF.Poople.Var] = true, -- Poople
	[FiendFolio.FF.Scoop.ID.."/"..FiendFolio.FF.Scoop.Var] = true, -- Scoop
	[FiendFolio.FF.Sundae.ID.."/"..FiendFolio.FF.Sundae.Var] = true, -- Sundae
	[FiendFolio.FF.SoftServe.ID.."/"..FiendFolio.FF.SoftServe.Var] = true, -- Soft Serve
}

-- idk if this is already defined elsewhere but this won't override anything even if it is :)
mod.TRINKETS = mod.TRINKETS or {}

function mod.XalumBound(value, lower, upper) 	return math.max(lower, math.min(upper, value)) end
function mod.XalumLuckBonus(luck, max, bonus) 	return (mod.XalumBound(luck, 0, max) / max) * bonus end

function mod.NegateKnockoutDrops(npc)
	local beingKnocked = npc:HasEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)

	if beingKnocked then
		npc:ClearEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_CONFUSION)
		npc.Velocity = Vector.Zero
	end
end

function mod.IsPositionCloselyEncased(position)
	local room = game:GetRoom()
	local yes = true
	local off = Vector(40, 0)

	for i = 1, 4 do
		if room:GetGridCollisionAtPos(position + off:Rotated(90 * i)) == GridCollisionClass.COLLISION_NONE then
			yes = false
			break
		end
	end

	return yes
end

function mod.Xalum_gridalignposition(position)
	local x = position.X
	local y = position.Y

	x = 40 * math.floor(x/40 + 0.5)
	y = 40 * math.floor(y/40 + 0.5)

	return Vector(x, y)
end

mod.XalumAlignPositionToGrid = mod.Xalum_gridalignposition

function mod.XalumIsEntityNearGridCentre(entity, distanceLimit)
	return entity.Position:Distance(mod.XalumAlignPositionToGrid(entity.Position)) < (distanceLimit or 5)
end

--[[local ossurender = {}
local ossufont = Font()
ossufont:Load("font/droid.fnt")

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if #ossurender > 0 then
		for _, value in pairs(ossurender) do
			ossufont:DrawString(value[2], value[1].X, value[1].Y, KColor(1, math.min(1, 1 - value[2] / 15), math.min(1, 1 - value[2] / 15), 1))
		end
	end
end)]]


-- A note for other people who wanna use this

-- speedlimit is kinda arbitrary
-- sure, it IS technically an upper cap for speed, but the entity probably won't ever reach it
-- however the entity's speed WILL scale with speedlimit

-- Deprecated
function mod.Xalum_gridpathfind(ent, speedlimit, target)
	local data = ent:GetData()
	if ent:CollidesWithGrid() then
		data.lastgridcollision = ent.FrameCount
	end

	if not data.targetgridpos or data.targetgridpos:Distance(ent.Position) <= 3 or (data.lastgridcollision and data.lastgridcollision + 10 > ent.FrameCount) then
		local t = mod.Xalum_gridalignposition(target)
		local loopingpos = {t}

		--ossurender = {}

		data.IndexedGrids = {}
		local i = 0
		while #loopingpos > 0 do
			local temploop = {}
			for _, p in pairs(loopingpos) do
				local room = game:GetRoom()
				if room:IsPositionInRoom(p, 0) then
					local ents = Isaac.FindInRadius(p, 18)
					local skip
					for _, e in pairs(ents) do
						if e.EntityCollisionClass > 0 and ((e:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) or e:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)) or (e:ToNPC() and e.Velocity:Length() < 0.1)) then
							skip = true
							break
						end
					end

					if not skip or i == 0 then
						local g = room:GetGridEntityFromPos(p)
						if (not g or g.CollisionClass == GridCollisionClass.COLLISION_NONE or i == 0) and not data.IndexedGrids[math.floor(p.X + 0.5).."_"..math.floor(p.Y + 0.5)] then
							data.IndexedGrids[math.floor(p.X + 0.5).."_"..math.floor(p.Y + 0.5)] = i
							temploop[#temploop + 1] = p + Vector(0, 40)
							temploop[#temploop + 1] = p + Vector(0, -40)
							temploop[#temploop + 1] = p + Vector(40, 0)
							temploop[#temploop + 1] = p + Vector(-40, 0)

							--local toscreen = Isaac.WorldToScreen(p - Vector(10, 10))
							--ossurender[#ossurender + 1] = {toscreen, i}
						end
					end
				end
			end
			i = i + 1
			loopingpos = temploop
		end

		local npcpos = mod.Xalum_gridalignposition(ent.Position)
		local index = data.IndexedGrids[math.floor(npcpos.X + 0.5).."_"..math.floor(npcpos.Y + 0.5)]
		local choice = npcpos

		index = index or 99999
		for i = 1, 4 do
			local p = npcpos + Vector(0, 40):Rotated(90 * i)
			local n = data.IndexedGrids[math.floor(p.X + 0.5).."_"..math.floor(p.Y + 0.5)]
			if n and n <= index then
				index = n
				choice = p
			end
		end

		data.targetgridpos = choice
	else
		if data.targetgridpos then
			ent.Velocity = ent.Velocity * 0.4 + (data.targetgridpos - ent.Position):Resized(speedlimit)
			ent.Velocity = ent.Velocity:Resized(math.min(speedlimit, ent.Velocity:Length() * 1.2))
		else
			ent.Velocity = ent.Velocity * 0.8
		end
	end
end

local function shouldGetNewTargetPosition(entity)
	local data = entity:GetData()
	local room = game:GetRoom()

	return (
		not data.targetGridPosition or
		data.targetGridPosition:Distance(entity.Position) < 5 or
		data.targetGridPosition:Distance(entity.Position) > 60 or
		room:GetGridCollisionAtPos(data.targetGridPosition) ~= GridCollisionClass.COLLISION_NONE
	)
end

local function isEntityExceptionToTileBlocking(entity)
	return (
		(entity.Type == mod.FF.Ossularry.ID and entity.Variant == mod.FF.Ossularry.Var)
	)
end

local function doesEntityBlockGridTile(entity)
	local entityResistsKnockback = entity:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	local entityIsUnmovingNPC = entity:ToNPC() and entity.Velocity:Length() < 0.1

	return (
		not entity:ToPlayer() and
		entity.EntityCollisionClass > 0 and
		(entityResistsKnockback or entityIsUnmovingNPC) and
		not isEntityExceptionToTileBlocking(entity)
	)
end

local function doEntitiesBlockGridTile(tilePosition)
	local entities = Isaac.FindInRadius(tilePosition, 18)
	for _, entity in pairs(entities) do
		if doesEntityBlockGridTile(entity) then
			return true
		end
	end
end

-- Version 2.0!
function mod.XalumGridPathfind(entity, targetPosition, speedLimit)
	local data = entity:GetData()

	if shouldGetNewTargetPosition(entity) then
		local room = game:GetRoom()
		local entityPosition = mod.XalumAlignPositionToGrid(entity.Position)
		local targetPosition = mod.XalumAlignPositionToGrid(targetPosition)

		local loopingPositions = {targetPosition}
		local indexedGrids = {}

		local index = 0
		while #loopingPositions > 0 do
			local temporaryLoop = {}

			for _, position in pairs(loopingPositions) do
				if room:IsPositionInRoom(position, 0) then
					if index == 0 or not doEntitiesBlockGridTile(position) then
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
		local index = indexedGrids[entityIndex] or 99999
		local choice = entityPosition

		for i = 1, 4 do
			local position = entityPosition + Vector(40, 0):Rotated(i * 90)
			local positionIndex = room:GetGridIndex(position)
			local value = indexedGrids[positionIndex]

			if value and value <= index then
				index = value
				choice = position
			end
		end

		data.targetGridPosition = choice
	end

	if data.targetGridPosition then
		local targetVelocity = (data.targetGridPosition - entity.Position):Resized(speedLimit)
		entity.Velocity = mod.XalumLerp(entity.Velocity, targetVelocity, 0.4)
	else
		entity.Velocity = mod.XalumLerp(entity.Velocity, Vector.Zero, 0.8)
	end
end

-- Deprecated
function mod.Xalum_gridpathfindlite(ent, speedlimit)
	local data = ent:GetData()
	if not data.pathingdir then data.pathingdir = math.random(4) end

	if ent:CollidesWithGrid() or math.random(100) == math.random(100) then
		local olddir = data.pathingdir
		while data.pathingdir == olddir do
			data.pathingdir = math.random(4)
		end
	end

	ent.Velocity = (ent.Velocity + Vector(speedlimit, 0):Rotated(90 * data.pathingdir)):Resized(mod:Lerp(ent.Velocity:Length(), speedlimit, 0.75))
end

-- 2.0
function mod.XalumLiteGridPathfind(entity, speedLimit)
	local data = entity:GetData()
	local room = game:GetRoom()
	mod.XalumInitNpcRNG(entity)

	local currentGridIndex = room:GetGridIndex(entity.Position)

	data.previousGridIndex = data.previousGridIndex or currentGridIndex
	data.pathingDirection = data.pathingDirection or data.rng:RandomInt(4)

	if entity:CollidesWithGrid() or (mod.XalumIsEntityNearGridCentre(entity) and currentGridIndex ~= data.previousGridIndex) then
		data.previousGridIndex = currentGridIndex

		local newDirection = data.pathingDirection
		local reverseDirection = (data.pathingDirection + 2) % 4
		local i = 0

		repeat
			newDirection = data.rng:RandomInt(4)
			local collision = room:GetGridCollisionAtPos(entity.Position + Vector(30, 0):Rotated(newDirection * 90))

			i = i + 1
		until i >= 32 or (newDirection ~= reverseDirection and collision == GridCollisionClass.COLLISION_NONE)

		if i >= 32 then
			newDirection = reverseDirection
		end

		data.pathingDirection = newDirection
	end

	local targetPosition = entity.Position + Vector(40, 0):Rotated(data.pathingDirection * 90)
	targetPosition = mod.XalumAlignPositionToGrid(targetPosition)

	local targetVelocity = targetPosition - entity.Position
	targetVelocity:Resize(speedLimit)

	entity.Velocity = mod.XalumLerp(entity.Velocity, targetVelocity, 0.4)
end

function mod.XalumRandomPathfind(entity, speedLimit)
	local data = entity:GetData()

	if entity.FrameCount % 60 == 0 or not data.direction or entity:CollidesWithGrid() then
		local room = game:GetRoom()

		local i = 0
		repeat
			data.direction = RandomVector():Resized(speedLimit)
			i = i + 1

			local testPosition = entity.Position + data.direction:Resized(entity.Size * 2)
		until (room:IsPositionInRoom(testPosition, 0) and room:GetGridCollisionAtPos(testPosition) == GridCollisionClass.COLLISION_NONE) or i >= 32

		if i >= 32 then
			data.direction = (room:GetCenterPos() - entity.Position):Resized(speedLimit)
		end
	end

	local targetPosition = entity.Position + data.direction
	local targetVelocity = (targetPosition - entity.Position):Resized(speedLimit)

	entity.Velocity = mod.XalumLerp(entity.Velocity, targetVelocity, 0.1)
end

function mod.Xalum_globinpathfind(npc, speedlimit, target)
	target = target or npc:GetPlayerTarget().Position

	local data = npc:GetData()
	if npc:CollidesWithGrid() then
		data.lastgridcollision = npc.FrameCount
	end

	if game:GetRoom():CheckLine(npc.Position, target + (npc.Position - target):Resized(5), 0, 1, false, false) and not (data.lastgridcollision and data.lastgridcollision + 15 > npc.FrameCount) then
		npc.Velocity = (target - npc.Position):Resized(npc.Velocity:Length() + 1)
	elseif npc.Pathfinder:HasPathToPos(target, false) then
		npc.Pathfinder:FindGridPath(target, npc.Velocity:Length() + 0.1, 2, false)
	else
		npc.Velocity = npc.Velocity * 0.75
	end
	npc.Velocity = npc.Velocity:Resized(math.min(speedlimit, npc.Velocity:Length() * 1.2))
end

function mod.Xalum_Lerp(init, target, percentage)
	return init + (target - init) * percentage
end

-- over-time stylistic changes amirite
mod.XalumLerp = mod.Xalum_Lerp

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, projectile)
	if projectile.Variant == 1 then
		if mod.ToothyBoners[projectile.SpawnerType .. "/" .. projectile.SpawnerVariant] then
			local sprite = projectile:GetSprite()
			sprite:Load("gfx/002.030_black tooth tear.anm2", true)
			sprite:ReplaceSpritesheet(0, "gfx/projectiles/morbus_tooth.png")
			sprite:LoadGraphics()
			sprite:Play("Tooth2Move", false)

			projectile:GetData().tooth = true
		end
	elseif projectile.Variant == 3 then
		if mod.CornyPoopers[projectile.SpawnerType .. "/" .. projectile.SpawnerVariant] and not mod:CheckStage("Dross", {45}) then
			local sprite = projectile:GetSprite()
			sprite:ReplaceSpritesheet(0, "gfx/projectiles/cornpoop_projectile.png")
			sprite:LoadGraphics()
		end
	end
end)

function mod.XalumDamageInArea(source, radius, amount, flags, cooldown)
	for _, player in pairs(Isaac.FindByType(1)) do
		if player.Position:Distance(source.Position) < radius + player.Size then
			player:TakeDamage(amount or 1, flags or 0, EntityRef(source), cooldown or 60)
		end
	end

	for _, heart in pairs(Isaac.FindByType(3, FamiliarVariant.ISAACS_HEART)) do
		if heart.Position:Distance(source.Position) < radius + heart.Size then
			heart:ToFamiliar():TakeDamage(amount or 1, flags and flags | DamageFlag.DAMAGE_ISSAC_HEART or DamageFlag.DAMAGE_ISSAC_HEART, EntityRef(source), cooldown or 60)
		end
	end
end

function mod.XalumGetEntityEquality(one, two)
	return one and two and GetPtrHash(one) == GetPtrHash(two)
end

function mod.XalumFindWall(position, direction)
	local room = game:GetRoom()

	if not direction then direction = Vector(1, 0) end
	direction = direction:Resized(20)
	position = room:GetGridPosition(room:GetGridIndex(position))

	local grid
	repeat
		grid = room:GetGridEntityFromPos(position)
		position = position + direction
	until grid and (grid:GetType() == GridEntityType.GRID_WALL or grid:GetType() == GridEntityType.GRID_DOOR)
	
	return grid
end

function mod.XalumFindRealEntity(target)
	for _, entity in pairs(Isaac.FindByType(target.Type, target.Variant, target.SubType)) do
		if mod.XalumGetEntityEquality(target.Entity or target, entity) then
			return entity
		end
	end
end

function mod.XalumIsPlayerUsingHorsePill(player, flags)
	local pillColour = player:GetPill(0)

	local holdingHorsePill = pillColour & PillColor.PILL_GIANT_FLAG > 0
	local proccedByEchoChamber = flags & UseFlag.USE_NOHUD > 0

	return holdingHorsePill and not proccedByEchoChamber
end

function mod.XalumAnyPlayerHas(itemID)
	for _, player in pairs(Isaac.FindByType(1)) do
		if player:ToPlayer():HasCollectible(itemID) then
			return true
		end
	end
end

function mod.XalumShouldPillEffectTurnNegative(effect)
	local hasfalsePHD = mod.XalumAnyPlayerHas(CollectibleType.COLLECTIBLE_FALSE_PHD)
	local hasNegativeEffect = mod.GoodToBadPillConversion[effect]

	return hasfalsePHD and hasNegativeEffect
end

function mod.XalumShouldPillEffectTurnPositive(effect)
	local hasPHD = mod.XalumAnyPlayerHas(CollectibleType.COLLECTIBLE_PHD)
	local hasVirgo = mod.XalumAnyPlayerHas(CollectibleType.COLLECTIBLE_VIRGO)
	local hasLuckyFoot = mod.XalumAnyPlayerHas(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
	local hasPositiveEffect = mod.BadToGoodPillConversion[effect]

	return (hasPHD or hasVirgo or hasLuckyFoot) and hasPositiveEffect
end

function mod.XalumBreakGridsInRadius(position, radius)
	local gridRadius = 40 * math.ceil(radius / 40)
	local room = game:GetRoom()

	for i = -gridRadius, gridRadius, 40 do
		for j = -gridRadius, gridRadius, 40 do
			local gridPosition = position + Vector(i, j)
			local grid = room:GetGridEntityFromPos(gridPosition)
			
			if grid and not grid:ToDoor() then
				grid:Destroy(false)
			end
		end
	end
end

mod.XalumScheduleData = {}

function mod.XalumSchedule(delay, func, args)
	table.insert(mod.XalumScheduleData, {
		Time = game:GetFrameCount(),
		Delay = delay,
		Call = func,
		Args = args or {},
	})
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local time = game:GetFrameCount()
	for i = #mod.XalumScheduleData, 1, -1 do
		local data = mod.XalumScheduleData[i]
		if data.Time + data.Delay <= time then
			data.Call(table.unpack(data.Args))	
			table.remove(mod.XalumScheduleData, i)
		end
	end
end)

function mod.XalumInitNpcRNG(npc)
	local data = npc:GetData()
	if not data.rng then
		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 42)
	end
end

function mod.QuickSetEntityGridPath(entity, valueOverride)
	if entity.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
		local room = game:GetRoom()
		local positionIndex = room:GetGridIndex(entity.Position)
		room:SetGridPath(positionIndex, valueOverride or 900)
	end
end

function mod.QuickSetEntityGridPathFlying(entity, valueOverride) --safer version for flying enemies
	local room = game:GetRoom()
	local positionIndex = room:GetGridIndex(entity.Position)
	valueOverride = valueOverride or 900
	if entity.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and room:GetGridPath(positionIndex) <= valueOverride then
		room:SetGridPath(positionIndex, valueOverride)
	end
end

function mod.FireClusterProjectiles(npc, velocity, numProjectiles, params)
	local corpseClusterParent = Isaac.Spawn(mod.FF.DummyEffect.ID, mod.FF.DummyEffect.Var, mod.FF.DummyEffect.Sub, npc.Position, velocity, npc)
	
	local params = params or ProjectileParams()
	params.FallingAccelModifier = -0.1

	mod:SetGatheredProjectiles()

	for i = 1, numProjectiles or 10 do
		npc:FireProjectiles(npc.Position, velocity, 0, params)
	end

	local projectiles = mod:GetGatheredProjectiles()
	for i, projectile in pairs(projectiles) do
		projectile:GetData().projType = "corpseCluster"
		projectile.Parent = corpseClusterParent
		projectile.Scale = projectile.Scale * (8 + math.random() * 8) / 10
	end

	corpseClusterParent:GetData().corpseClusters = projectiles
	return projectiles
end

function mod.DoesTearHaveSpectralFlags(tear)
	return (
		tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) or
		tear:HasTearFlags(TearFlags.TEAR_CONTINUUM)
	)
end

function mod.DoesTearHavePiercingFlags(tear)
	return (
		tear:HasTearFlags(TearFlags.TEAR_PIERCING) or
		tear:HasTearFlags(TearFlags.TEAR_PERSISTENT) or
		tear:HasTearFlags(TearFlags.TEAR_BELIAL)
	)
end

function mod.DoesTearHaveInstantKillFlags(tear)
	return (
		tear:HasTearFlags(TearFlags.TEAR_NEEDLE) or
		tear:HasTearFlags(TearFlags.TEAR_HORN)
	)
end

function mod.DoesTearHaveRockBreakingFlags(tear)
	return (
		tear:HasTearFlags(TearFlags.TEAR_ACID) or
		tear:HasTearFlags(TearFlags.TEAR_ROCK)
	)
end

function mod.DoesTearHaveStickyFlags(tear)
	return (
		tear:HasTearFlags(TearFlags.TEAR_STICKY) or
		tear:HasTearFlags(TearFlags.TEAR_BOOGER) or
		tear:HasTearFlags(TearFlags.TEAR_SPORE)
	)
end

function mod.GetPersistentPlayerData(player) -- Just a convenience thing really, saves me from having to validate that this table exists, and also from having to remember what the table is called lmao
	local data = player:GetData()
	data.ffsavedata = data.ffsavedata or {}
	return data.ffsavedata
end

function mod.ThrowSkuzz(origin, targetPosition, spawner, yOffset)
	local skuzz = Isaac.Spawn(mod.FF.Skuzz.ID, mod.FF.Skuzz.Var, 0, origin, Vector.Zero, spawner)
	skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	skuzz:Update()

	local sprite = skuzz:GetSprite()
	sprite:Play("hop", true)

	local data = skuzz:GetData()
	data.state = "hop"
	data.stateframe = 0

	local positionDelta = targetPosition - skuzz.Position
	skuzz.Velocity = Vector(positionDelta.X / 15 , positionDelta.Y / 15) * 0.90
	skuzz.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	skuzz.GridCollisionClass = GridCollisionClass.COLLISION_NONE

	if yOffset then
		skuzz.SpriteOffset = Vector(0, yOffset)
		data.slingerOverride = true
	end

	return skuzz
end

function mod.ThrowFriendlySkuzz(player, vectorDirection)
	local skuzz = Isaac.Spawn(3, FamiliarVariant.ATTACK_SKUZZ, 0, player.Position, vectorDirection, player)
	skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	skuzz:Update()
	return skuzz
end

local knifeVariant = {
	MOMS_KNIFE = 0,
	BONE_CLUB = 1,
	BONE_SCYTHE = 2,
	DONKEY_JAWBONE = 3,
	BAG_OF_CRAFTING = 4,
	SUMPTORIUM = 5,
	NOTCHED_AXE = 9,
	SPIRIT_SWORD = 10,
	TECH_SWORD = 11,
}

function mod.IsKnifeSwingable(knife)
	return (
		knife.Variant == knifeVariant.BONE_CLUB or
		knife.Variant == knifeVariant.BONE_SCYTHE or
		knife.Variant == knifeVariant.DONKEY_JAWBONE or
		knife.Variant == knifeVariant.BAG_OF_CRAFTING or
		knife.Variant == knifeVariant.NOTCHED_AXE or
		knife.Variant == knifeVariant.SPIRIT_SWORD or
		knife.Variant == knifeVariant.TECH_SWORD
	)
end

function mod.GetGlobalTrinketMultiplier(trinketID)
	local cumulation = 0
	mod.AnyPlayerDo(function(player)
		cumulation = cumulation + player:GetTrinketMultiplier(trinketID)
	end)

	return cumulation
end

function mod.IsPlayerHoldingTrinket(player, trinket, strict)
	for i = 0, 1 do
		local held = player:GetTrinket(i)
		if held == trinket or (held & ~ TrinketType.TRINKET_GOLDEN_FLAG == trinket and not strict) then
			return i
		end
	end

	return nil
end

function mod.SmeltHeldTrinket(player, slot)
	local otherSlot = (slot + 1) % 2
	local otherTrinket = player:GetTrinket(otherSlot)

	if otherTrinket ~= 0 then
		player:TryRemoveTrinket(otherTrinket)
	end

	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM)

	if otherTrinket ~= 0 then
		player:AddTrinket(otherTrinket, false)
	end
end

function mod.GetHeldTrinketMultiplier(player, trinket, excludeBox)
	local totalMultiplier = 0
	local addMomsBox
	local boxModifier = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and 1 or 0

	for i = 0, 1 do
		local slotTrinket = player:GetTrinket(i)
		if slotTrinket & ~ TrinketType.TRINKET_GOLDEN_FLAG == trinket then
			local incrementation = playerHasMomsBox and 2 or 1
			if slotTrinket & TrinketType.TRINKET_GOLDEN_FLAG > 0 then
				incrementation = incrementation + 1
			end

			totalMultiplier = totalMultiplier + incrementation
			addMomsBox = not excludeBox
		end
	end

	return totalMultiplier + (addMomsBox and boxModifier or 0)
end

function mod.PlayerHasSmeltedTrinket(player, trinket)
	return player:GetTrinketMultiplier(trinket) > mod.GetHeldTrinketMultiplier(player, trinket)
end

function mod.GetSmeltedTrinketMultiplier(player, trinket, excludeBox)
	return player:GetTrinketMultiplier(trinket) - mod.GetHeldTrinketMultiplier(player, trinket, not excludeBox)
end

function mod.AddSmeltedTrinket(player, trinket, firstPickup)
	local trinket0 = player:GetTrinket(0)
	local trinket1 = player:GetTrinket(1)

	if trinket0 > 0 then player:TryRemoveTrinket(trinket0) end
	if trinket1 > 0 then player:TryRemoveTrinket(trinket1) end

	player:AddTrinket(trinket, firstPickup)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM)

	if trinket1 > 0 then player:AddTrinket(trinket1, false) end
	if trinket0 > 0 then player:AddTrinket(trinket0, false) end
end

function mod.GetItemOfMinimumQuality(qualityMinimum, pool, rng)
	qualityMinimum = math.min(4, qualityMinimum or 2)
	pool = math.max(ItemPoolType.POOL_TREASURE, pool or 0)
	if not rng then
		rng = RNG()
		rng:SetSeed(Random(), 45)
	end

	local itemConfig = Isaac.GetItemConfig()
	local numItems = itemConfig:GetCollectibles().Size - 1
	local itempool = game:GetItemPool()

	for i = 1, numItems do
		if ItemConfig.Config.IsValidCollectible(i) and itemConfig:GetCollectible(i).Quality < qualityMinimum then
			itempool:AddRoomBlacklist(i)
		end
	end

	local foundItem
	for i = 1, 10 do
		local item = itempool:GetCollectible(pool, false, rng:RandomInt(9e9))
		if item ~= 25 then -- Blacklisting breakfast as a quick test for no items of minimum quality left
			foundItem = item
			mod.UniversalRemoveItemFromPools(item)
			break
		end
	end

	itempool:ResetRoomBlacklist()
	return foundItem or mod.GetItemOfMinimumQuality(qualityMinimum - 1, pool) -- Recurse, if there isn't any quality 4 items left, better to roll a quality 3 item than nothing
end

function mod.GetItemByLuaFilter(pool, rng, filter, strict)
	pool = math.max(ItemPoolType.POOL_TREASURE, pool or 0)
	if not rng then
		rng = RNG()
		rng:SetSeed(Random(), 45)
	end

	local itemConfig = Isaac.GetItemConfig()
	local numItems = itemConfig:GetCollectibles().Size - 1
	local itempool = game:GetItemPool()

	for i = 1, numItems do
		if ItemConfig.Config.IsValidCollectible(i) then
			if not filter(itemConfig:GetCollectible(i)) then
				itempool:AddRoomBlacklist(i)
			end
		end
	end

	local foundItem
	for i = 1, 10 do
		local item = itempool:GetCollectible(pool, false, rng:RandomInt(9e9))
		if item ~= 25 then -- Blacklisting breakfast because I say so
			foundItem = item
			mod.UniversalRemoveItemFromPools(item)
			break
		end
	end

	itempool:ResetRoomBlacklist()
	if foundItem or strict then
		return foundItem
	elseif pool ~= ItemPoolType.POOL_TREASURE then
		return mod.GetItemByLuaFilter(ItemPoolType.POOL_TREASURE, rng, filter)
	end

	return 0 -- Error state
end

function mod.GetStringDirectionFromVector(vector)
	local angleDegrees = vector:GetAngleDegrees()
	if math.abs(angleDegrees) < 45 then
		return "Right"
	elseif math.abs(angleDegrees) > 135 then
		return "Left"
	elseif angleDegrees > 0 then
		return "Down"
	elseif angleDegrees < 0 then
		return "Up"
	end
end

function mod.GetExpectedBrokenHeartsFromDamage(player)
	local playerType = player:GetPlayerType()

	if player:HasTrinket(mod.ITEM.TRINKET.HEARTACHE) then
		if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then
			return player:GetTrinketMultiplier(mod.ITEM.TRINKET.HEARTACHE) * 3
		else
			return player:GetTrinketMultiplier(mod.ITEM.TRINKET.HEARTACHE)
		end
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_HEARTBREAK) then
		if mod.WillDamageBeFatal(player, 1, 0, true, true) then
			if playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B then
				return 1
			else
				return 2
			end
		end
	end

	return 0
end

function mod.WillDamageBeFatal(player, amount, flags, ignoreBerserk, ignoreHeartbreak)
	if flags & (DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_FAKE) > 0 then
		return false
	end

	local effects = player:GetEffects()
	local playerType = player:GetPlayerType()
	local brokens = player:GetBrokenHearts()

	if not ignoreBerserk and effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) then -- Option provided to ignore berserk for if your effect wants to proc on hitting 0 hp
		return false
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES) and not effects:HasNullEffect(NullItemID.ID_SPIRIT_SHACKLES_DISABLED) then
		return false
	end

	if playerType == mod.PLAYER.CHINA and brokens >= 11 then
		return true
	end

	if not ignoreHeartbreak and player:HasCollectible(CollectibleType.COLLECTIBLE_HEARTBREAK) then
		return brokens >= 12 - mod.GetExpectedBrokenHeartsFromDamage(player)
	end

	if playerType == PlayerType.PLAYER_JACOB2_B or effects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
		return true
	end

	local bones = player:GetBoneHearts()
	local armour = player:GetSoulHearts()
	local blood = player:GetHearts() - player:GetRottenHearts()

	if (bones > 0 and armour > 0) or (armour > 0 and blood > 0) or (bones > 0 and blood > 0) or bones > 1 then
		return false
	elseif (armour > 0 and armour <= amount) or (blood > 0 and blood <= amount) or bones == 1 then
		return true
	end

	return false
end

function mod.GetClosestGridEntity(position)
	local room = game:GetRoom()
	local closest
	local distance = 9e9

	for i = -40, 40, 40 do
		for j = -40, 40, 40 do
			if i ~= 0 or j ~= 0 then
				local grid = room:GetGridEntityFromPos(position + Vector(i, j))
				if grid and grid.Position:Distance(position) < distance then
					closest = grid
					distance = grid.Position:Distance(position)
				end
			end
		end
	end

	return closest
end

function mod.MakeEntityPersistent(entity, skipMirror)
	if mod.savedata then
		local level = game:GetLevel()
		local desc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
		local index = desc.SafeGridIndex

		mod.savedata.levelEntityPersistence[tostring(index)] = mod.savedata.levelEntityPersistence[tostring(index)] or {}
		table.insert(mod.savedata.levelEntityPersistence[tostring(index)], {
			Type 		= entity.Type,
			Variant 	= entity.Variant,
			SubType		= entity.SubType,
			Position 	= {X = entity.Position.X, Y = entity.Position.Y},
			SkipMirror	= skipMirror,
		})
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if mod.savedata and mod.savedata.levelEntityPersistence then
		local level = game:GetLevel()
		local room = game:GetRoom()
		local desc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
		local index = desc.SafeGridIndex

		if mod.savedata.levelEntityPersistence[tostring(index)] then
			for _, data in pairs(mod.savedata.levelEntityPersistence[tostring(index)]) do
				if not room:IsMirrorWorld() or not data.SkipMirror then
					Isaac.Spawn(data.Type, data.Variant, data.SubType, Vector(data.Position.X, data.Position.Y), Vector.Zero, nil)
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	if mod.savedata then
		mod.savedata.levelEntityPersistence = {}
	end
end)

function mod.PickupIsTrinket(pickup, trinketID, strict)
	return pickup.Variant == 350 and (pickup.SubType == trinketID or (not strict and pickup.SubType & ~ TrinketType.TRINKET_GOLDEN_FLAG == trinketID))
end

-- Priority:
--[[
	Held Golden Trinket
	Held Trinket
	Held Tattered Trinket
	Smelted Golden Trinket
	Smelted Trinket
	Smelted Tattered Trinket
]]

function mod.DowngradeTrinket(player, trinketID, tatteredTrinketID, tatterWithoutMomsBox)
	local holdingTrinket = mod.IsPlayerHoldingTrinket(player, trinketID)
	if holdingTrinket then
		local trinket = player:GetTrinket(holdingTrinket)
		if trinket & TrinketType.TRINKET_GOLDEN_FLAG > 0 then
			player:TryRemoveTrinket(trinketID | TrinketType.TRINKET_GOLDEN_FLAG)
			player:AddTrinket(trinketID)
		else
			player:TryRemoveTrinket(trinketID)
			if (tatterWithoutMomsBox or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)) and tatteredTrinketID then
				player:AddTrinket(tatteredTrinketID)
			end
		end
	elseif tatteredTrinketID and mod.IsPlayerHoldingTrinket(player, tatteredTrinketID) then
		player:TryRemoveTrinket(tatteredTrinketID)
	elseif mod.PlayerHasSmeltedTrinket(player, trinketID) then
		local smeltedMultiplier = mod.GetSmeltedTrinketMultiplier(player, trinketID, true) -- EntityPlayer: player, TrinketType: int, bool: excludeMomsBox 

		-- Gonna have to accept a chance for bugs here unforunately
		-- TryRemoveTrinket just completely shits itself on smelted trinkets if you don't have the correct golden flag value, and there's no way to test that you have a smelted golden trinket

		if smeltedMultiplier >= 2 then -- Assume at least one golden, this may not actually be true. God I wish :HasTrinket(id | gold) discriminated, even if :HasTrinket(id) doesn't
			player:TryRemoveTrinket(trinketID | TrinketType.TRINKET_GOLDEN_FLAG)
			mod.AddSmeltedTrinket(player, trinketID)
		else -- Multiplier == 1, player only has one non-golden trinket, this will always be safe
			player:TryRemoveTrinket(trinketID)

			if (tatterWithoutMomsBox or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)) and tatteredTrinketID then
				mod.AddSmeltedTrinket(player, tatteredTrinketID)
			end
		end
	elseif tatteredTrinketID and mod.PlayerHasSmeltedTrinket(player, tatteredTrinketID) then
		local smeltedMultiplier = mod.GetSmeltedTrinketMultiplier(player, tatteredTrinketID, true)

		if smeltedMultiplier >= 2 then -- Even if the tattered form cannot naturally spawn, a player can use King of Pentacles to get themselves a golden version of it
			player:TryRemoveTrinket(tatteredTrinketID | TrinketType.TRINKET_GOLDEN_FLAG)
		else
			player:TryRemoveTrinket(tatteredTrinketID)
		end
	end
end

function mod.GetBombExplosionRadius(entityBomb) -- Thank you dataminers
	local radius
	local damage = entityBomb.ExplosionDamage

	if entityBomb:HasTearFlags(TearFlags.TEAR_GIGA_BOMB) then
		radius = 130
	elseif damage > 175 then
		radius = 105
	elseif damage > 140 then
		radius = 90
	else
		radius = 75
	end

	return radius * entityBomb.RadiusMultiplier
end

function mod.IsPositionInRangeOfExplosion(position, positionRadius)
	for _, bomb in pairs(Isaac.FindByType(4)) do
		local sprite = bomb:GetSprite()
		if sprite:IsPlaying("Explode") and sprite:GetFrame() == 0 then
			local explosionRadius = mod.GetBombExplosionRadius(bomb:ToBomb())
			if bomb.Position:Distance(position) <= explosionRadius + (positionRadius or 0) then
				return true
			end
		end
	end	
end

function mod.IsEntityInRangeOfExplosion(entity, radiusModifier)
	return mod.IsPositionInRangeOfExplosion(entity.Position, entity.Size + (radiusModifier or 0))
end

function mod.IsPositionOnScreen(pos)
	local myScreenPosition = Isaac.WorldToScreen(pos)
	return (
	myScreenPosition.X >= 0 and
	myScreenPosition.Y >= 0 and
	myScreenPosition.X <= Isaac.GetScreenWidth() and
	myScreenPosition.Y <= Isaac.GetScreenHeight()
	)
end

local function IsCardValid(card, pool)
	for _, id in pairs(pool) do
		if id == card then
			return true
		end
	end

	return false
end

function mod.GetWeightlessUnlockedCard(pool, rng, canSuit, canRune, onlyRune)
	local itempool = game:GetItemPool()
	local card

	local rngseed = rng:GetSeed()

	repeat
		card = itempool:GetCard(rngseed + rng:RandomInt(rngseed), canSuit, canRune, onlyRune)
	until IsCardValid(card, pool)

	return card
end

function mod.RotateTowardsTarget(myAngle, targetAngle, lerpPercent)
	if math.abs(myAngle - targetAngle) > math.abs(myAngle + 360 - targetAngle) then
		targetAngle = targetAngle - 360
	elseif math.abs(myAngle - targetAngle) > math.abs(myAngle - 360 - targetAngle) then
		targetAngle = targetAngle + 360
	end

	return mod.XalumLerp(myAngle, targetAngle, lerpPercent)- myAngle
end