-- BIRDS! --

local mod = FiendFolio
local game = Game()



local function GetLandingTarget(npc, data, morvids)
    local room = game:GetRoom()
    local goodIndices = {}
    local badIndices = {}
    for _, morvid in ipairs(morvids) do
        local landingTarget, claimedPillar = morvid:GetData().LandingTarget, morvid:GetData().ClaimedPillar
        if landingTarget then
            badIndices[landingTarget] = true
        end

        if claimedPillar then
            badIndices[claimedPillar] = true
        end
    end

    if not data.Perched and FiendFolio.GenericChaserPathMap.TargetMapSets[1] then
        local map = FiendFolio.GenericChaserPathMap.TargetMapSets[1].Map
        if map then
            for index, moveCost in pairs(map) do
                if not badIndices[index] and moveCost < 10000 then
                    goodIndices[#goodIndices + 1] = index
                end
            end
        end
    end

    if #goodIndices == 0 then
        for i = 0, room:GetGridSize() do
            if not badIndices[i] and room:IsPositionInRoom(room:GetGridPosition(i), 0) then
                if data.Perched then
                    local grid = room:GetGridEntity(i)
                    if grid and grid.Desc.Type == GridEntityType.GRID_PILLAR then
                         goodIndices[#goodIndices + 1] = i
                    end
                elseif room:GetGridCollision(i) == 0 then
                    goodIndices[#goodIndices + 1] = i
                end
            end
        end
    end

    if not data.Perched then
        local preferredIndices = {}
        local playerPositions = {}
        for i = 1, game:GetNumPlayers() do
            playerPositions[#playerPositions + 1] = Isaac.GetPlayer(i - 1).Position
        end

        for _, index in ipairs(goodIndices) do
            local isTooClose, isCloseEnough
            local gpos = room:GetGridPosition(index)
            for _, playerPos in ipairs(playerPositions) do
                local dist = gpos:DistanceSquared(playerPos)
                if dist < 80 ^ 2 then
                    isTooClose = true
                end

                if dist < 400 ^ 2 then
                    isCloseEnough = true
                end
            end

            if not isTooClose and isCloseEnough then
                preferredIndices[#preferredIndices + 1] = index
            end
        end

        if #preferredIndices > 0 then
            return preferredIndices[math.random(1, #preferredIndices)]
        end
    end

    return goodIndices[math.random(1, #goodIndices)]
end

local function crow(npc)
    local pitchVar = (math.random() - 0.5) * 0.25
    npc:PlaySound(FiendFolio.Sounds.Crow, 2, 0, false, 0.75 + pitchVar, 0)
end

function mod:morvidAI(npc, sprite, data)
    local room = game:GetRoom()
    local index = room:GetGridIndex(npc.Position)
    local morvids = {}
    for _, morvid in ipairs(Isaac.FindByType(npc.Type, npc.Variant, -1)) do
        if not morvid:IsDead() and not morvid:HasEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE) then
            morvids[#morvids + 1] = morvid
        end
    end

	if sprite:IsEventTriggered("Flap") then
		local pitchVar = (math.random() - 0.5) * 0.25
		npc:PlaySound(SoundEffect.SOUND_ANGEL_WING, 0.60, 0, false, math.random(75,85)/100)
	end

    if not data.Init then
        if npc.SubType == 1 and room:GetFrameCount() <= 1 then
            local grid = room:GetGridEntityFromPos(npc.Position)
            if not grid or grid.Desc.Type == GridEntityType.GRID_DECORATION then
                Isaac.GridSpawn(GridEntityType.GRID_PILLAR, 0, npc.Position, true)
            elseif grid.Desc.Type ~= GridEntityType.GRID_PILLAR then
                npc:Kill()
                return
            end

            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.Position = npc.Position + Vector(0, 20)
            npc.PositionOffset = Vector(0, -48)
            data.TargetPositionOffset = Vector(0, -48)
            data.Perched = true
            data.ClaimedPillar = index
            crow(npc)
        else
            data.TargetPositionOffset = Vector.Zero
        end

        data.State = "Grounded"

        data.AttackCooldown = math.random(75, 135)

        data.Init = true
    end

    local target = npc:GetPlayerTarget()

    data.UseFFPlayerMap = data.State == "Grounded" or data.State == "FlyEnd"
    if data.State == "Grounded" then
        data.AttackCooldown = data.AttackCooldown - 1
        if data.AttackCooldown <= 0 then
            local flightTimer = 0
            for _, morvid in ipairs(morvids) do
                if GetPtrHash(morvid) ~= GetPtrHash(npc) then
                    flightTimer = flightTimer + math.random(5, 10)
                    morvid:GetData().AttackCooldown = flightTimer
                    morvid:GetData().State = "WaitToFly"
                end
            end

            crow(npc)
            data.AttackCooldown = 0
            data.State = "WaitToFly"
        end
    end

    if data.State == "Grounded" then
        data.FlightTimer = nil

        data.DoWalkFrame = true

        if data.Perched then
            npc.Velocity = Vector.Zero
            if mod.CanIComeOutYet() then
                data.AttackCooldown = data.AttackCooldown - 5
            end
        else
            if room:GetGridPath(index) < 900 then
                room:SetGridPath(index, 900)
            end

            if data.Path then
                FiendFolio.FollowPath(npc, 0.5, data.Path, true, 0.85, 500)
            else
                npc.Velocity = npc.Velocity * 0.85
            end
        end
    elseif data.State == "WaitToFly" then
        if data.Perched then
            npc.Velocity = Vector.Zero
        else
            npc.Velocity = npc.Velocity * 0.85
        end

        local isHopping = sprite:IsPlaying("Hop:)")
        data.DoWalkFrame = not isHopping

        data.AttackCooldown = data.AttackCooldown - 1
        if data.AttackCooldown <= 0 and not isHopping then
            data.State = "Flying"
            local count = mod.GetEntityCount(mod.FF.Morvid.ID, mod.FF.Morvid.Var)
            if count > 4 then
                count = 4
            elseif count < 2 then
                count = 2
            end
            data.FlightTimer = count * mod:RandomInt(50,70) --Note: probably could be improved still
            data.DoWalkFrame = nil
            sprite:Play("Jump", true)
        end

        if data.AttackCooldown >= 26 and math.random(1, 5) == 1 and not isHopping then
            sprite:Play("Hop:)", true)
            data.DoWalkFrame = nil
        end
    elseif data.State == "Flying" then
        if sprite:IsFinished("Jump") then
            sprite:Play("FlyStart", true)
            data.TargetPositionOffset = Vector(0, -70)
            data.AttackCooldown = math.random(15, 45)
        elseif sprite:IsFinished() then
            sprite:Play("Fly", true)
        end

        local anim = sprite:GetAnimation()
        if anim == "Jump" and math.random(1, 20) == 1 then
            crow(npc)
        end

        if anim ~= "FlyEnd" then
            if anim ~= "Jump" then
                if data.Perched and mod.CanIComeOutYet() then
                    data.Perched = nil
                end

                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                data.ClaimedPillar = nil
            end

            data.FlightTimer = data.FlightTimer - 1
            local allFlightDone = true
            for _, morvid in ipairs(morvids) do
                local mdata = morvid:GetData()
                if mdata.State == "WaitToFly" or (mdata.State == "Flying" and mdata.FlightTimer and mdata.FlightTimer > 0) then
                    allFlightDone = false
                end
            end

            if allFlightDone and anim ~= "Shoot" then
                data.UseFFPlayerMap = true -- calculate path so that landing target can be found
                data.State = "FlyEnd"
                data.FlightTimer = nil
            end
        end

        if anim == "Fly" then
            if not data.TargetPosition then
                local attempts = 0
                while not data.TargetPosition do
                    attempts = attempts + 1
                    data.TargetPosition = npc:GetPlayerTarget().Position + RandomVector() * math.random(80, 400)
                    if not room:IsPositionInRoom(data.TargetPosition, 40) and attempts < 20 then
                        data.TargetPosition = nil
                    end
                end
            end

            npc.Velocity = npc.Velocity * 0.925 + (data.TargetPosition - npc.Position):Resized(0.75)

            data.AttackCooldown = data.AttackCooldown - 1

            if npc.Position:DistanceSquared(data.TargetPosition) <= 20 ^ 2 then
                if data.AttackCooldown <= 0 then
                    local anyReadyInsideRoom, isAttackingMorvid = false, false
                    for _, morvid in ipairs(morvids) do
                        local mdata = morvid:GetData()
                        local msprite = morvid:GetSprite()
                        if msprite:IsPlaying("Shoot") then
                            isAttackingMorvid = true
                        elseif mdata.State == "Flying" and mdata.AttackCooldown <= 0 then
                            if room:IsPositionInRoom(morvid.Position, 0) then
                                anyReadyInsideRoom = true
                            end
                        end
                    end

                    if not isAttackingMorvid and (room:IsPositionInRoom(npc.Position, 0) or not anyReadyInsideRoom) and npc.Position:Distance(npc:GetPlayerTarget().Position) >= 100 then
                        crow(npc)
                        sprite:Play("Shoot", true)
                        data.AttackCooldown = math.random(15, 45)
                    end
                end

                data.TargetPosition = nil
            end
        else
            if anim == "Shoot" then
                if sprite:IsEventTriggered("Shoot") then
					npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, math.random(75,85)/100)
                    local target = npc:GetPlayerTarget()
                    local params = ProjectileParams()
                    local bullet = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, (target.Position - npc.Position):Resized(10), npc):ToProjectile()
                    bullet:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
                    bullet:AddHeight(npc.PositionOffset.Y)
                    bullet:AddFallingSpeed(6)
                    local bColor = Color(1, 1, 1, 1, 0, 0, 0)
                    bColor:SetColorize(1, 1, 1, 1)
                    bullet.Color = bColor
                    bullet.Parent = npc
                    local bsprite = bullet:GetSprite()
                    bsprite:Load("gfx/projectiles/morvid_feather.anm2", true)
                    bsprite:Play("Move", true)
                    bullet.SpriteRotation = bullet.Velocity:GetAngleDegrees()
                    local ffFlags = mod:getCustomProjectileFlags(bullet)
                    ffFlags.MatchRotation = true
                    bullet:Update()
                end

                npc.Velocity = npc.Velocity * 0.9
            else
                npc.Velocity = npc.Velocity * 0.8
            end
        end
    elseif data.State == "FlyEnd" then
        if not data.LandingTarget then
            data.LandingTarget = GetLandingTarget(npc, data, morvids)
        end

        if sprite:IsFinished("FlyEnd") then
            if not data.Perched then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end

            data.State = "Grounded"
            data.AttackCooldown = math.random(150, 180)
            data.DoWalkFrame = true
            if data.Perched then
                data.ClaimedPillar = data.LandingTarget
            end

            data.LandingTarget = nil
            data.LerpLanding = nil
            npc.Velocity = Vector.Zero
        elseif sprite:IsFinished() then
            sprite:Play("Fly", true)
        end

        if data.LandingTarget then
            local landingPos = room:GetGridPosition(data.LandingTarget)
            if data.Perched then
                landingPos = landingPos + Vector(0, 20)
            end

            local distance = npc.Position:Distance(landingPos)
            if distance < 40 and not sprite:IsPlaying("FlyEnd") then
                if math.random(1, 3) == 1 then
                    crow(npc)
                end

                sprite:Play("FlyEnd", true)
                data.LerpLanding = 1
                data.LerpLandingStart = npc.Position
                if data.Perched then
                    data.TargetPositionOffset = Vector(0, -48)
                else
                    data.TargetPositionOffset = Vector.Zero
                end
            end

            if data.LerpLanding then
                data.LerpLanding = data.LerpLanding + 1
                if data.LerpLanding <= 7 then
                    npc.Velocity = mod:Lerp(data.LerpLandingStart, landingPos, data.LerpLanding / 7, nil, 2) - npc.Position
                else
                    npc.Velocity = Vector.Zero
                    npc.Position = landingPos
                end
            else
                npc.Velocity = npc.Velocity * 0.8 + (landingPos - npc.Position):Resized(2)
            end
        end
    end

    if sprite:GetAnimation() == "Fly" then
        data.TargetPositionOffset = Vector(0, -70 + mod:Sway(-10, 10, 40, 1.5, 1.5, data.FlightTimer))
    end

    if data.DoWalkFrame then
        if npc.Velocity:Length() > 1 then
            npc:AnimWalkFrame("WalkHori","WalkVert",0)
            sprite.FlipX = npc.Velocity.X < 0
        else
            sprite:SetFrame("WalkVert", 0)
            sprite.FlipX = target.Position.X < npc.Position.X
        end
    else
        sprite.FlipX = target.Position.X < npc.Position.X
    end
end

function mod:morvidRender(npc, sprite, data)
    if not game:IsPaused() and npc:Exists() and data.TargetPositionOffset then
        npc.PositionOffset = mod:Lerp(npc.PositionOffset, data.TargetPositionOffset, 0.1)
    end
end
