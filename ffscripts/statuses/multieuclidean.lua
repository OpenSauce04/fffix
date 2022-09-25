local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 2

function mod:handleMultiEuclidean(npc, data, sprite)
	data.FFMultiEuclideanDuration = data.FFMultiEuclideanDuration - 1
	if data.FFMultiEuclideanDuration >= 0 then
        --Visuals
        local s = math.sin(game:GetFrameCount()/20*math.pi)
        local multiEuclidColor = Color(-s*2, -s*2, -s*2, 1, (s+1)/2, (s+1)/2, (s+1)/2)
        multiEuclidColor:SetColorize(1, 1, 1, 1)
        npc:SetColor(multiEuclidColor, 1, statusColorPriority, false, false)
		local lasers = Isaac.FindByType(7, -1, -1, false, false)
		for _, laser in pairs(lasers) do
			laser = laser:ToLaser()
			if laser.Child and laser.Parent and laser.Parent.Type == EntityType.ENTITY_PLAYER then
				if (not laser:GetData().FFMultiEuclideanTearSpawner) and (not laser.OneHit or not laser:GetData().AlreadyDuplicatedByMultiEuclidean) then
					local endpoint = laser.Child.Position
					local laservec = (endpoint - laser.Position)
					if laser:GetData().AlreadyDuplicatedByMultiEuclidean then
						laservec = (laser:GetEndPoint() - laser.Position)
					end
					local npcvec = (npc.Position - laser.Position)
					if laservec:Length() > npcvec:Length() - npc.Size then
						local entryVec = laservec:Resized(npcvec:Length())
						local laserCheckPoint = laser.Position + entryVec
						if npc.Position:Distance(laserCheckPoint) <= npc.Size + laser.Size then
							--laser.Color = Color(0,1,1,1)
							if laser.OneHit then
								for i = -90, 90, 180 do
									local offsetVec = laservec:Resized(laser.Size):Rotated(i)
									local newlaser = EntityLaser.ShootAngle(laser.Variant, entryVec + offsetVec, laservec:GetAngleDegrees(), math.max(laser.Timeout, 1), laser.PositionOffset, laser.SpawnerEntity)
									newlaser.TearFlags = laser.TearFlags
									newlaser.CollisionDamage = laser.CollisionDamage
									newlaser.Color = laser.Color
									if laser.MaxDistance > 0 then
										newlaser:SetMaxDistance(math.max(1, (laser.MaxDistance + npc.Size + 10) - entryVec:Length()))
									end
									newlaser:GetData().AlreadyDuplicatedByMultiEuclidean = true
									newlaser:GetData().FFMultiEuclideanTearSpawner = npc
									newlaser.DisableFollowParent = true
									newlaser.Position = laserCheckPoint + offsetVec
									newlaser.OneHit = true
									newlaser:Update()
								end
								laser:GetData().AlreadyDuplicatedByMultiEuclidean = true
								laser:Remove()
							else
								local ldata = laser:GetData()
								if ldata.AlreadyDuplicatedByMultiEuclidean then
									if ldata.MultiEuclideanStoredLength > 0 and laser.MaxDistance > ldata.MultiEuclideanStoredLength + npc.Size + 10 then
										ldata.AlreadyDuplicatedByMultiEuclidean = 0
										laser:SetMaxDistance(ldata.MultiEuclideanStoredLength)
									else
										ldata.MultiEuclideanEntryPoint = laserCheckPoint
										--ldata.MultiEuclideanStoredLength = laser.MaxDistance
										laser:SetMaxDistance(entryVec:Length())
										ldata.AlreadyDuplicatedByMultiEuclidean = 2
									end
								else
									for i = -90, 90, 180 do
										local offsetVec = laservec:Resized(laser.Size):Rotated(i)
										local newlaser = EntityLaser.ShootAngle(laser.Variant, entryVec + offsetVec, laservec:GetAngleDegrees(), 0, laser.PositionOffset, laser.SpawnerEntity)
										newlaser.TearFlags = laser.TearFlags
										newlaser.CollisionDamage = laser.CollisionDamage
										newlaser.Color = laser.Color
										if laser.MaxDistance > 0 then
											newlaser:SetMaxDistance(math.max(1, (laser.MaxDistance + npc.Size + 10) - entryVec:Length()))
										end
										newlaser:GetData().AlreadyDuplicatedByMultiEuclidean = true
										newlaser:GetData().MultiEuclideanFatherLaser = laser
										newlaser:GetData().MultiEuclideanLaserOffset = i
										newlaser:GetData().FFMultiEuclideanTearSpawner = npc
										newlaser.DisableFollowParent = true
										newlaser.Position = laserCheckPoint + offsetVec
										newlaser:Update()
									end
									ldata.MultiEuclideanStoredLength = laser.MaxDistance
									laser:SetMaxDistance(entryVec:Length())
									ldata.MultiEuclideanEntryPoint = laserCheckPoint
									ldata.AlreadyDuplicatedByMultiEuclidean = 2
								end
							end
						end
					end
				end
			end
		end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, entity, mysteryBoolean)
	local tdata = tear:GetData()
    local spawnerEntity = tdata.FFMultiEuclideanTearSpawner
	local data = entity:GetData()

    if tdata.FFMultiEuclideanTearSpawner and spawnerEntity and spawnerEntity:Exists() then
		if spawnerEntity.Index == entity.Index and spawnerEntity.InitSeed == entity.InitSeed then
			return true
		elseif mod:isSegmented(spawnerEntity) and mod:isInSegmentsOf(entity, spawnerEntity) then
			return true
		elseif mod:isBasegameSegmented(spawnerEntity) and mod:isInBasegameSegmentsOf(entity, spawnerEntity) then
			return true
        end
    else
		if tear.FrameCount >= 2 then
			if not tdata.AlreadyDuplicatedByMultiEuclidean then
				if data.FFMultiEuclideanDuration and data.FFMultiEuclideanDuration >= 0 then
					local player
					if tear.SpawnerEntity and tear.SpawnerEntity.Type == 1 then
						player = tear.SpawnerEntity:ToPlayer()
					else
						player = Isaac.GetPlayer()
					end
					local pdata = player:GetData()
					pdata.cannotFireMoreSlippyTears = true
					for i = -90, 90, 180 do
						local offsetVec = tear.Velocity:Resized(tear.Size):Rotated(i)
						local newtear = player:FireTear(tear.Position + offsetVec, tear.Velocity, false, true, false, entity)
						newtear.TearFlags = tear.TearFlags
						if newtear.Variant ~= tear.Variant then newtear:ChangeVariant(tear.Variant) end
						newtear:GetData().FFMultiEuclideanTearSpawner = entity
					end
					tear:GetData().FFMultiEuclideanTearSetColor = true
					pdata.cannotFireMoreSlippyTears = false
					tdata.AlreadyDuplicatedByMultiEuclidean = true
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, function(_, bomb, entity, mysteryBoolean)
	local tdata = bomb:GetData()
    local spawnerEntity = tdata.FFMultiEuclideanTearSpawner
	local data = entity:GetData()

    if tdata.FFMultiEuclideanTearSpawner and spawnerEntity and spawnerEntity:Exists() then
		if spawnerEntity.Index == entity.Index and spawnerEntity.InitSeed == entity.InitSeed then
			return true
		elseif mod:isSegmented(spawnerEntity) and mod:isInSegmentsOf(entity, spawnerEntity) then
			return true
		elseif mod:isBasegameSegmented(spawnerEntity) and mod:isInBasegameSegmentsOf(entity, spawnerEntity) then
			return true
        end
    else
        if not tdata.AlreadyDuplicatedByMultiEuclidean then
            if data.FFMultiEuclideanDuration and data.FFMultiEuclideanDuration >= 0 then
                local player
                if bomb.SpawnerEntity and bomb.SpawnerEntity.Type == 1 then
                    player = bomb.SpawnerEntity:ToPlayer()
                else
                    player = Isaac.GetPlayer()
                end
                for i = -90, 90, 180 do
                    local offsetVec = bomb.Velocity:Resized(bomb.Size):Rotated(i)
                    local newbomb = player:FireBomb(bomb.Position + offsetVec, bomb.Velocity, entity)
					newbomb.Flags = bomb.Flags
                    newbomb:GetData().FFMultiEuclideanTearSpawner = entity
                end
                tdata.AlreadyDuplicatedByMultiEuclidean = true
                bomb:Remove()
            end
        end
	end
end)

--[[mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, function(_, knife, entity, mysteryBoolean)
	local tdata = knife:GetData()
    local spawnerEntity = tdata.FFMultiEuclideanTearSpawner
	local data = entity:GetData()

    if tdata.FFMultiEuclideanTearSpawner and spawnerEntity and spawnerEntity:Exists() then
		if spawnerEntity.Index == entity.Index and spawnerEntity.InitSeed == entity.InitSeed then
			return true
		elseif mod:isSegmented(spawnerEntity) and mod:isInSegmentsOf(entity, spawnerEntity) then
			return true
		elseif mod:isBasegameSegmented(spawnerEntity) and mod:isInBasegameSegmentsOf(entity, spawnerEntity) then
			return true
        end
    else
        if not tdata.AlreadyDuplicatedByMultiEuclidean then
            if data.FFMultiEuclideanDuration and data.FFMultiEuclideanDuration >= 0 then
                local player
                if knife.SpawnerEntity and knife.SpawnerEntity.Type == 1 then
                    player = knife.SpawnerEntity:ToPlayer()
                else
                    player = Isaac.GetPlayer()
                end
                for i = -5, 5, 10 do
                    local newKnife = player:FireKnife(player, i, false, 2, 0)
                    newKnife:GetData().FFMultiEuclideanTearSpawner = entity
                    newknife.Velocity = Vector(10 * player.ShotSpeed,0):Rotated(knife.Rotation)
                end
                tdata.AlreadyDuplicatedByMultiEuclidean = true
            end
        end
	end
end)]]

function mod:euclideanTearUpdate(tear, tdata)
    if tdata.FFMultiEuclideanTearSpawner or tear:GetData().FFMultiEuclideanTearSetColor then
        local s = math.sin(game:GetFrameCount()/20*math.pi)
        local multiEuclidColor = Color(-s*2, -s*2, -s*2, 1, (s+1)/2, (s+1)/2, (s+1)/2)
        multiEuclidColor:SetColorize(1, 1, 1, 1)
        tear.Color = multiEuclidColor
    end
end

function mod:multiEuclideanPostBombUpdate(bomb, data)
    if data.FFMultiEuclideanTearSpawner then
        local s = math.sin(game:GetFrameCount()/20*math.pi)
        local multiEuclidColor = Color(-s*2, -s*2, -s*2, 1, (s+1)/2, (s+1)/2, (s+1)/2)
        multiEuclidColor:SetColorize(1, 1, 1, 1)
        bomb.Color = multiEuclidColor
    end
end

function mod:multiEuclideanLaserUpdate(player, laser, data, rng)
    if data.FFMultiEuclideanTearSpawner then
        local s = math.sin(game:GetFrameCount()/20*math.pi)
        local multiEuclidColor = Color(-s*2, -s*2, -s*2, 1, (s+1)/2, (s+1)/2, (s+1)/2)
        multiEuclidColor:SetColorize(1, 1, 1, 1)
        laser.Color = multiEuclidColor
    end
	if data.MultiEuclideanFatherLaser then
		if data.MultiEuclideanFatherLaser:Exists() and data.MultiEuclideanFatherLaser.Child then
			if data.MultiEuclideanFatherLaser:GetData().AlreadyDuplicatedByMultiEuclidean then
				local fathervec = data.MultiEuclideanFatherLaser.Child.Position - data.MultiEuclideanFatherLaser.Position
				local offsetPos = fathervec:Rotated(data.MultiEuclideanLaserOffset):Resized(data.MultiEuclideanFatherLaser.Size)
				--[[if data.MultiEuclideanFatherLaser:GetData().MultiEuclideanEntryPoint then
					laser.Position = data.MultiEuclideanFatherLaser:GetData().MultiEuclideanEntryPoint + offsetPos
				else]]
					laser.Position = data.MultiEuclideanFatherLaser.Child.Position + offsetPos
				--end
				local maxlength = data.MultiEuclideanFatherLaser:GetData().MultiEuclideanStoredLength
				local curlength = data.MultiEuclideanFatherLaser.LaserLength
				if maxlength then
					if maxlength <= 0 then
						laser:SetMaxDistance(0)
					else
						laser:SetMaxDistance(math.max(1,maxlength + 25 - curlength))
					end
				end
				laser.AngleDegrees = data.MultiEuclideanFatherLaser.AngleDegrees
				laser.LastAngleDegrees = data.MultiEuclideanFatherLaser.LastAngleDegrees
			else
				laser:Remove()
			end
		else
			laser:Remove()
		end
	elseif (not laser.OneHit) and data.AlreadyDuplicatedByMultiEuclidean then
		if tonumber(data.AlreadyDuplicatedByMultiEuclidean) then
			data.AlreadyDuplicatedByMultiEuclidean = data.AlreadyDuplicatedByMultiEuclidean - 1
			if data.AlreadyDuplicatedByMultiEuclidean <= 0 then
				if data.MultiEuclideanStoredLength then
					laser:SetMaxDistance(data.MultiEuclideanStoredLength)
					laser.LaserLength = laser.MaxDistance
				end
				data.AlreadyDuplicatedByMultiEuclidean = nil
			end
		end
	end
end



function FiendFolio.AddMultiEuclidean(entity, source, duration, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddMultiEuclidean(segment, source, duration, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.AddMultiEuclidean(segment, source, duration, true)
			end
		end
	end

	local data = entity:GetData()
	if entity:ToNPC():IsBoss() and 
	   (mod:hasCustomStatus(entity) or (data.FFBossStatusResistance and (not data.FFBossStatusResistanceFromBruise))) 
	then
		--do nothing
	elseif not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity)) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFMultiEuclideanDuration = math.max(data.FFMultiEuclideanDuration or 0, duration)
		data.FFMultiEuclideanSource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveMultiEuclidean(entity, isCloned)
	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveMultiEuclidean(segment, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.RemoveMultiEuclidean(segment, true)
			end
		end
	end

	local data = entity:GetData()
	data.FFMultiEuclideanDuration = nil
end

function mod:multiEuclideanOnApply(entity, source, data)
	if data.ApplyMultiEuclidean then
		FiendFolio.AddMultiEuclidean(entity, source.Entity.SpawnerEntity, data.ApplyMultiEuclideanDuration)
	end
end

function mod:multiEuclideanOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFMultiEuclideanDuration ~= nil and data.FFMultiEuclideanDuration > 0 and not clearingStatus then
		mod:handleMultiEuclidean(npc, data, sprite)
		--data.hasFFStatusIcon = true
	else
		data.FFMultiEuclideanDuration = nil
	end
end

function mod:copyMultiEuclidean(copyData, sourceData)
	copyData.FFMultiEuclideanDuration = sourceData.FFMultiEuclideanDuration
	copyData.FFMultiEuclideanSource = sourceData.FFMultiEuclideanSource
end