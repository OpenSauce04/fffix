local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:d122Update(player, data)
	if data.belialD122 then
		if data.belialD122 > 0 then
			data.belialD122 = data.belialD122-0.1
			if data.belialD122 < 0 then
				data.belialD122 = nil
			end
		else
			data.belialD122 = nil
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
   		player:EvaluateItems()
	end
end

local function snowglobeMap()
	local room = game:GetRoom()
	local size = room:GetGridSize()
	local real = {}
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local door = false
		local doors = mod.availableDoors[room:GetRoomShape()]
		for _,checkDoor in ipairs(doors) do
			local checkedDoor = room:GetDoorSlotPosition(checkDoor)
			if checkedDoor:Distance(gridpos) < 50 then
				door = true
			end
		end
		local gridEnt = room:GetGridEntity(i)
		if gridEnt then
			if gridEnt:GetType() == GridEntityType.GRID_SPIKES or gridEnt:GetType() == GridEntityType.GRID_PRESSURE_PLATE or gridEnt:GetType() == GridEntityType.GRID_TELEPORTER then
				door = true
			end
		end

		if door == false then
			real[i] = true
		end
	end
	return real
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
	local room = game:GetRoom()
	local gridCount = 0
	local virtues = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
	local map = snowglobeMap()
	for _,grid in ipairs(mod.GetGridEntities()) do
		if mod.gridToProjectile[grid:GetType()] or mod.gridToProjectileSpecials[grid:GetType()] then
			if grid.CollisionClass == GridCollisionClass.COLLISION_SOLID or grid.CollisionClass == GridCollisionClass.COLLISION_OBJECT or grid.CollisionClass == GridCollisionClass.COLLISION_WALL then
				local index = grid:GetGridIndex()
				local dir = (mod:FindRandomPosSnowGlobe(grid.Position, rng, 120, true, map)-grid.Position)
				local proj = mod:turnGridtoProjectile(player, index, dir*0.05, false, TearFlags.TEAR_SPECTRAL, true, {GridEntityType.GRID_ROCKB, GridEntityType.GRID_LOCK})
				if proj then
					proj.FallingSpeed = -10
					proj.FallingAcceleration = 0.8
					gridCount = gridCount+1
					--[[if virtues and rng:RandomInt(3) == 0 then
						proj:GetData().d122Wisp = true
						proj:GetData().d122WispSpawner = player
					end]]
				end
			end
		end
	end
	if mod:playerIsBelialMode(player) and gridCount > 0 then
		player:GetData().belialD122 = math.min(5, gridCount)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
   		player:EvaluateItems()
		sfx:Play(SoundEffect.SOUND_DEVIL_CARD, 0.2, 0, false, 1.2)
	end
	for i=0,3 do
		local deathFunc
		if i == 0 then
			deathFunc = function(e, p)
					local effect = Isaac.Spawn(1000,51,0, room:GetGridPosition(room:GetGridIndex(p.Position)), Vector.Zero, p):ToEffect()
					effect:Update()
					local eSprite = effect:GetSprite()
					eSprite:Play("Disappear", true)
					SFXManager():Play(SoundEffect.SOUND_STEAM_HALFSEC, 1, 0, false, 1)
				end
		elseif i == 1 then
			deathFunc = function(e, p) 
					local effect = Isaac.Spawn(1000,52,0, room:GetGridPosition(room:GetGridIndex(p.Position)), Vector.Zero, p):ToEffect()
					local eSprite = effect:GetSprite()
					eSprite:Play("Disappear", true)
					SFXManager():Play(SoundEffect.SOUND_STEAM_HALFSEC, 1, 0, false, 1)
				end
		elseif i == 2 or i== 3 then
			deathFunc = function(e, p) 
					local effect = Isaac.Spawn(1000,15,0, room:GetGridPosition(room:GetGridIndex(p.Position)), Vector.Zero, p):ToEffect()
					SFXManager():Play(SoundEffect.SOUND_STEAM_HALFSEC, 1, 0, false, 1)
				end
		end
	
	
		for _,ent in ipairs(Isaac.FindByType(33, i, -1, false, false)) do
			if ent.HitPoints > 1 then
				local dir = (mod:FindRandomPosSnowGlobe(ent.Position, rng, 120, true)-ent.Position)
				local proj = mod:turnEntitytoProjectile(player, ent, dir*0.05, false, nil, true, nil, nil, nil, deathFunc, true)
				if proj then
					proj.FallingSpeed = -10
					proj.FallingAcceleration = 0.8
				end
			end
		end
	end
	for _,ent in ipairs(Isaac.FindByType(292, -1, -1, false, false)) do
		if ent.HitPoints > 1 then
			local dir = (mod:FindRandomPosSnowGlobe(ent.Position, rng, 120, true)-ent.Position)
			local proj = mod:turnEntitytoProjectile(player, ent, dir*0.05, false, nil, true, nil, nil, nil, function(e,p) local spawn = Isaac.Spawn(e.Type, e.Variant, e.SubType, room:GetGridPosition(room:GetGridIndex(p.Position)), Vector.Zero, p) spawn:Update() spawn.HitPoints = 0 spawn:TakeDamage(999, 0, EntityRef(spawn), 0) end, true)
			if proj then
				proj.FallingSpeed = -10
				proj.FallingAcceleration = 0.8
			end
		end
	end
	game:ShakeScreen(15)
	SFXManager():Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.3,0,false,math.random(110,120)/100)
	return true
end, FiendFolio.ITEM.COLLECTIBLE.SNOW_GLOBE)

function mod:FindRandomPosSnowGlobe(startingPos, rng, radius, findnear, givenTable)
radius = radius or 0
local validPositions = {}
local validPositionsFar = {}
local validPositionsNear = {}
local room = game:GetRoom()
local size = room:GetGridSize()

	if givenTable then
		local valids = {}
		for i=-2,2 do
			for j=-2,2 do
				local pos = startingPos+Vector(40*i,40*j)
				local index = room:GetGridIndex(pos)
				if givenTable[index] then
					table.insert(valids, pos)
				end
			end
		end
		if #valids > 0 then
			return valids[rng:RandomInt(#valids)+1]
		else
			return startingPos
		end
	else
		for i=0, size do
			local gridpos = room:GetGridPosition(i)
			local door = false
			local doors = mod.availableDoors[room:GetRoomShape()]
			for _,checkDoor in ipairs(doors) do
				local checkedDoor = room:GetDoorSlotPosition(checkDoor)
				if checkedDoor:Distance(gridpos) < 50 then
					door = true
				end
			end
			local gridEnt = room:GetGridEntity(i)
			if gridEnt then
				if gridEnt:GetType() == GridEntityType.GRID_SPIKES or gridEnt:GetType() == GridEntityType.GRID_PRESSURE_PLATE or gridEnt:GetType() == GridEntityType.GRID_TELEPORTER then
					door = true
				end
			end
			if room:IsPositionInRoom(gridpos, 0) and door == false then
				table.insert(validPositions, gridpos)
				if startingPos:Distance(gridpos)> radius then
					table.insert(validPositionsFar, gridpos)
				end
				if startingPos:Distance(gridpos)< radius then
					table.insert(validPositionsNear, gridpos)
				end
			end
		end
		if #validPositionsNear > 0 and findnear then
			return validPositionsNear[rng:RandomInt(#validPositionsNear)+1]
		elseif #validPositionsFar > 0 and not findnear then
			return validPositionsFar[rng:RandomInt(#validPositionsFar)+1]
		elseif #validPositions > 0 then
			return validPositions[rng:RandomInt(#validPositions)+1]
		else
			return room:GetRandomPosition(1)
		end
	end
end