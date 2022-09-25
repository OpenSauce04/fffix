----
-- THE ORGANIZATION
-- they will reorganize your organs in an unpleasant manner
----
local mod = FiendFolio
local game = Game()

local organization = {
    Chaser = Isaac.GetEntityVariantByName("Chaser"),
    Bashful = Isaac.GetEntityVariantByName("Bashful"),
    Speedy = Isaac.GetEntityVariantByName("Speedy"),
    Pokey = Isaac.GetEntityVariantByName("Pokey")
}

local organizationBalance = {
    Chaser = {
        Accel = 0.7,
        AltAccel = 0.45,
        Friction = 0.75,
        MinAttackCooldown = 90,
        MaxAttackCooldown = 150,
        BrainAirSpeed = 20,
        MaxStun = 30
    },
    Bashful = {
        Accel = 0.75,
        NearEndAccel = 0.6,
        NearEndThreshold = 2,
        Friction = 0.75,
        Behind = 2,
        MaxStun = 90,
        MinRage = 30,
        CorpseAnim = "EyeIdle"
    },
    Speedy = {
        Accel = 0.9,
        Friction = 0.75,
        Ahead = 3,
        MaxStun = 30,
        MaxFreeze = 45,
        ChargeSpeed = 15
    },
    Pokey = {
        Accel = 0.4,
        AltAccel = 1.5,
        MaxRage = 150,
        MaxFreeze = 60,
        Friction = 0.75,
        CorpseAnim = "TractIdle02"
    }
}

for k, v in pairs(organization) do
    organizationBalance[v] = organizationBalance[k]
end

-- i'm doing some custom pathfinding for this one so excuse the mess
-- all: has a facing direction, move in it, or turn left or right. no direct backtracking, unless absolutely required (pathing's not smart enough to avoid situations where it would be lol)
-- chaser: targets player, no other rules
-- speedy: targets 3 grids ahead of player's last movement direction, prioritize moving in straight lines
-- bashful: target the space chaser was in two spaces ago, no other rules
-- pokey: targets player, 1/4 chance per tile on its path to turn in a random direction if possible, and end the path

local orgType = Isaac.GetEntityTypeByName("Chaser")
local function getOrganization()
    local orgs = {}
    local orgsByVariant = {}
    for k, v in pairs(organization) do
        local ents = Isaac.FindByType(orgType, v, -1, false, false)
        if not orgsByVariant[v] then
            orgsByVariant[v] = {}
        end

        for _, ent in ipairs(ents) do
			if ent.SubType == 0 then
	            orgs[#orgs + 1] = ent
	            orgsByVariant[v][#orgsByVariant[v] + 1] = ent
			end
		end
    end

    return orgs, orgsByVariant
end

local function getValidOrgMoves(facing, width)
    local absFace = math.abs(facing)
    if absFace > 1 then
        return {1, -1, facing}
    else
        return {width, -width, facing}
    end
end

local function isLineFree(grid1, grid2, direction)
    local count = 0
    local room = game:GetRoom()
    while grid1 ~= grid2 and count < room:GetGridSize() do -- hopefully the latter check isn't necessary cause it should hit a wall / pass the player first, but who knows
        grid1 = grid1 + direction
        count = count + 1

        -- is this grid past the target grid in our direction?
        if grid1 > grid2 and direction > 0 then
            return false
        elseif grid1 < grid2 and direction < 0 then
            return false
        end

        local collision = room:GetGridCollision(grid1)
        if collision ~= GridCollisionClass.COLLISION_NONE then
            return false
        end
    end

    return true
end

local function getOrgAvoidanceCollisions(npc, orgs)
    local exCollisions = {}
    for _, org in ipairs(orgs) do
        if GetPtrHash(org) ~= GetPtrHash(npc) then
            local path, pathindex = org:GetData().Path, org:GetData().PathIndex
            if path and pathindex and path[pathindex] then
                for i = 0, 3 do
                    if path[pathindex + i] then
                        exCollisions[path[pathindex + i]] = true
                    end
                end
            end
        end
    end

    return exCollisions
end

local orgRNG = RNG()
local function pickOrganizationPath(map, startIndex, facing, variant, pathSeed, alt, exCollisions)
    local room = game:GetRoom()
    local width = room:GetGridWidth()

    local tread = {}
    local path = {startIndex}
    local done
    while not done do
        local ind = path[#path]
        orgRNG:SetSeed(pathSeed + (1 + ind) ^ 2, 35) -- this rng is seeded on the index so that when the path is regenerated it will pick the same path consistently

        tread[ind] = true
        local moves = {-1, 1, width, -width}
        local lowestCost
        local lowestInds = {}
        local nonForward = {}
        local treadCount = 0
        for _, move in ipairs(moves) do
            local moveInd = ind + move
            local cost = map[moveInd]

            if tread[moveInd] then
                treadCount = treadCount + 1
            end

            if cost and not tread[moveInd] then
                if cost == 0 then
                    path[#path + 1] = moveInd
                    return path
                end

                if cost < 10000 then
                    if move == -facing then -- AVOID BACKTRACKING!
                        cost = cost + 5000
                    end

                    if variant == organization.Speedy and facing ~= move then
                        cost = cost + 2
                    end

                    if exCollisions and exCollisions[moveInd] then
                        cost = cost + 1
                    end

                    if move ~= -facing then
                        nonForward[#nonForward + 1] = moveInd
                    end

                    local reset
                    if not lowestCost or cost < lowestCost then
                        lowestCost = cost
                        lowestInds = {}
                    end

                    if cost <= lowestCost then
                        lowestInds[#lowestInds + 1] = moveInd
                    end
                end
            end
        end

        if variant == organization.Pokey or (alt and variant == organization.Chaser) and #path > 1 then
            local turnChance = 4
            if alt then
                if variant ~= organization.Chaser then
                    turnChance = 6
                else
                    turnChance = 10
                end
            end

            if orgRNG:RandomInt(turnChance) == 0 then
                if #nonForward > 0 then
                    local rand = orgRNG:RandomInt(#nonForward)
                    path[#path + 1] = nonForward[rand + 1]
                    return path
                end
            end
        end

        if #lowestInds == 0 then
            return path
        else
            path[#path + 1] = lowestInds[orgRNG:RandomInt(#lowestInds) + 1]
        end

        if #path > 10 then
            return path
        end

        facing = path[#path] - ind
    end

    return path
end

FiendFolio.OrganizationPathMap = FiendFolio.NewPathMapFromTable("OrganizationPathMap", {
    GetTargetSets = function()
        return FiendFolio.GetMinimumTargetSets(getOrganization())
    end,
    GetCollisions = function()
        local collisions = {}
        local room = game:GetRoom()
        for i = 0, room:GetGridSize() do
            local path = room:GetGridPath(i)
            local grid = room:GetGridEntity(i)
            if (path >= 1000 and (not grid or grid.Desc.Type ~= GridEntityType.GRID_PIT)) or path == 950 then
                collisions[i] = 10000
            else
                if path >= 950 or (grid and grid.Desc.Type == GridEntityType.GRID_SPIKES_ONOFF) then
                    path = 0
                end

                collisions[i] = path
            end
        end

        return collisions
    end,
    GetValidPositions = function()
        return FiendFolio.GetInsideGrids()
    end,
    OnPathUpdate = function(map)
        local sets = map.TargetMapSets
        local room = game:GetRoom()
        local width = room:GetGridWidth()
        local orgs = getOrganization()
        for _, org in ipairs(orgs) do
            local data = org:GetData()
            local matchingSet = FiendFolio.GetTargetSetMatchingEntity(org, sets, data)
            if matchingSet then
                data.Path = nil
                data.PathIndex = nil
                local avoidance = getOrgAvoidanceCollisions(org, orgs)

                if not data.PathSeed then
                    data.PathSeed = org:GetDropRNG():Next()
                end

                local currentIndex = room:GetGridIndex(org.Position)
                if not data.Facing then
                    local canFace = {}
                    for _, off in ipairs(mod.RoomIndexOffsets) do
                        if matchingSet.Map[currentIndex + off] and matchingSet.Map[currentIndex + off] < 10000 then
                            canFace[#canFace + 1] = off
                        end
                    end

                    data.Facing = (canFace[org:GetDropRNG():RandomInt(#canFace) + 1]) or 1
                end

                local path = pickOrganizationPath(matchingSet.Map, currentIndex, data.Facing, org.Variant, data.PathSeed, data.MoveAlt or data.NoBrainer, avoidance)
                data.Path = path
            end
        end
    end,
    NoAutoUpdate = true,
    OnlyUpdateIf = function()
        return #getOrganization() > 0
    end
})

local pathdebug = false
local function moveOrganization(npc, d, target, variant, alt)
    local orgs, orgsByVariant = getOrganization()
    local room = game:GetRoom()
    local collisions = FiendFolio.OrganizationPathMap.Collisions
    local walkDat = organizationBalance[variant]
    if not d.TargetIndex then
        if npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
            if not d.Corner then
                local lowX, lowY, highX, highY
                for i = 0, room:GetGridSize() do
                    local pos = room:GetGridPosition(i)
                    if room:IsPositionInRoom(pos, 0) then
                        if not lowX or lowX > pos.X then
                            lowX = pos.X
                        end

                        if not lowY or lowY > pos.Y then
                            lowY = pos.Y
                        end

                        if not highX or highX < pos.X then
                            highX = pos.X
                        end

                        if not highY or highY < pos.Y then
                            highY = pos.Y
                        end
                    end
                end

                local corners = {Vector(lowX, lowY), Vector(highX, lowY), Vector(lowX, highY), Vector(highX, highY)}
                local validCorners = {}
                for i, corner in ipairs(corners) do
                    corner = room:GetClampedPosition(corner, 0)
                    local cornerInd = room:GetGridIndex(corner)
                    corners[i] = cornerInd
                    local taken
                    for _, org in ipairs(orgs) do
                        if cornerInd == org:GetData().Corner then
                            taken = true
                            break
                        end
                    end

                    if not taken then
                        validCorners[#validCorners + 1] = cornerInd
                    end
                end

                if #validCorners > 0 then
                    d.Corner = validCorners[math.random(1, #validCorners)]
                else
                    d.Corner = corners[math.random(1, #corners)]
                end
            end

            local playerTooClose = target.Position:DistanceSquared(room:GetGridPosition(d.Corner)) < 160 ^ 2
            if playerTooClose then
                d.TargetIndex = room:GetGridIndex(room:GetCenterPos())
                d.Corner = nil
            else
                d.TargetIndex = d.Corner
            end
        elseif npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
            d.TargetIndex = room:GetGridIndex(room:GetCenterPos())
        elseif variant == organization.Chaser or variant == organization.Pokey then
            if alt then
                if variant == organization.Pokey then
                    local chasers = orgsByVariant[organization.Chaser]
                    if not d.Following or not d.Following:Exists() then
                        d.Following = chasers[npc:GetDropRNG():RandomInt(#chasers) + 1]
                    end

                    d.TargetIndex = d.Following:GetData().BashfulIndex or room:GetGridIndex(d.Following.Position)
                else
                    d.TargetIndex = room:GetGridIndex(d.Brain.Position)
                end
            else
                d.Following = nil
                d.TargetIndex = room:GetGridIndex(target.Position)
            end
        elseif variant == organization.Speedy then
            local ind = room:GetGridIndex(target.Position)
            local gridPos = room:GetGridPosition(ind)
            local add = Vector(0, 0)
            if target.Velocity.X > 0.1 then
                add = add + Vector(walkDat.Ahead * 40, 0)
            elseif target.Velocity.X < -0.1 then
                add = add + Vector(walkDat.Ahead * -40, 0)
            end

            if target.Velocity.Y > 0.1 then
                add = add + Vector(0, walkDat.Ahead * 40)
            elseif target.Velocity.Y < -0.1 then
                add = add + Vector(0, walkDat.Ahead * -40)
            end

            if add.X ~= 0 or add.Y ~= 0 then
                local targPos = Isaac.GetFreeNearPosition(gridPos + add, 0)
                d.TargetIndex = room:GetGridIndex(targPos)
                d.LastTarget = d.TargetIndex
            else
                d.TargetIndex = d.LastTarget or ind
            end
        else
            if not d.Following or not d.Following:Exists() then -- follow first available chaser, or a random organization member that isn't being followed if not available. allows for a follow chain of bashfuls.
                local chasers = orgsByVariant[organization.Chaser]
                for _, chaser in ipairs(chasers) do
                    if not chaser:GetData().HasBashful then
                        d.Following = chaser
                    end
                end

                if not d.Following then
                    local tryToFollow = {}
                    for _, org in ipairs(orgs) do
                        if GetPtrHash(org) ~= GetPtrHash(npc) and not org:GetData().HasBashful then
                            tryToFollow[#tryToFollow + 1] = org
                        end
                    end

                    d.Following = tryToFollow[npc:GetDropRNG():RandomInt(#tryToFollow) + 1]
                end

                if d.Following then
                    d.Following:GetData().HasBashful = true
                end
            end

            if d.Following then
                d.TargetIndex = d.Following:GetData().BashfulIndex
            end

            if not d.TargetIndex then
                d.TargetIndex = room:GetGridIndex(target.Position)
            end
        end
    end

    if d.Path then
        local accel = walkDat.Accel
        if alt and walkDat.AltAccel then
            accel = walkDat.AltAccel
        elseif walkDat.NearEndAccel and d.PathIndex and (#d.Path - d.PathIndex) <= walkDat.NearEndThreshold then
            accel = walkDat.NearEndAccel
        end

        if pathdebug then
            local r, g, b  = 1, 0, 0
            if variant == organization.Bashful then
                r, g, b = 1, 0, 1
            elseif variant == organization.Speedy then
                r, g, b = 0, 0, 1
            elseif variant == organization.Pokey then
                r, g, b = 0, 1, 0
            end

            IDebug.RenderUntilNextUpdate(IDebug.RenderCircle, room:GetGridPosition(d.TargetIndex), nil, 16, nil, nil, Color(r, g, b, 0.75, 0, 0, 0))

            for i, ind in ipairs(d.Path) do
                local alpha = mod:Lerp(0.75, 0.05, (i - 1) / (#d.Path - 1))
                IDebug.RenderUntilNextUpdate(IDebug.RenderCircle, room:GetGridPosition(ind), nil, 16, nil, nil, Color(r, g, b, alpha, 0, 0, 0))
            end
        end

        local hitNextPos = FiendFolio.FollowPath(npc, accel, d.Path, false, walkDat.Friction)
        local ind, fromInd
        if d.PathIndex then
            fromInd = d.Path[d.PathIndex - 1]
            ind = d.Path[d.PathIndex]
        end

        if hitNextPos then
            if ind then
                if fromInd then
                    local oldFacing = d.Facing
                    d.Facing = ind - fromInd
                end

                d.PreviousPositions = d.PreviousPositions or {}
                table.insert(d.PreviousPositions, 1, ind)
                d.BashfulIndex = d.PreviousPositions[organizationBalance.Bashful.Behind]
                d.PreviousPositions[organizationBalance.Bashful.Behind + 1] = nil
            end

            d.TargetIndex = nil
        end
    end
end

local function getOrgFlipFaceDirSuffix(variant, d)
    local suff = ""
    if variant == organization.Chaser then
        if d.NoBrainer then
            suff = "02"
        else
            suff = "01"
        end
    end

    local spriteFlip, animFaceDir = false, "Down"
    if d.Facing then
        if math.abs(d.Facing) == 1 then
            animFaceDir = "Hori"
            spriteFlip = d.Facing == -1
        else
            if d.Facing < 0 then
                animFaceDir = "Up"
            else
                animFaceDir = "Down"
            end
        end
    end

    return spriteFlip, animFaceDir, suff
end

function mod:organizationAI(npc, sprite, d)
    local variant = npc.Variant
    if npc.SubType == 1 then
        if variant == organization.Chaser and (not d.Chaser:Exists() or d.Chaser:IsDead()) then
            npc:BloodExplode()
            npc:Remove()
        end

        return
    end

    local room = game:GetRoom()

    local scaredyGhosts, isEaten
    if d.Activated then
        for i = 1, game:GetNumPlayers() do
            local p = Isaac.GetPlayer(i - 1)
            if p:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_GAMEKID) then
                isEaten = isEaten or p.Position:DistanceSquared(npc.Position) < (npc.Size + p.Size) ^ 2
                scaredyGhosts = true
            end
        end
    end

    if scaredyGhosts then
        npc:RemoveStatusEffects()
        d.PacmanFear = true
        npc:AddEntityFlags(EntityFlag.FLAG_FEAR)
    elseif d.PacmanFear then
        d.PacmanFear = nil
        npc:ClearEntityFlags(EntityFlag.FLAG_FEAR)
    end

    local bal = organizationBalance[variant]
    if not d.Activated then
        if variant == organization.Chaser then
            d.Activated = true
            d.State = "Appear"
            d.Init = true
        else
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

            if variant == organization.Pokey then
                if not sprite:IsPlaying("TractIdle01") then
                    sprite:Play("TractIdle01", true)
                end

                npc.Visible = true
            else
                npc.Visible = false
            end

            npc.Velocity = Vector(0, 0)
        end
    end

    if d.Activated and not d.Init then
        npc.Visible = true
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        d.State = "Appear"
        sprite:Play("Appear", true)
        d.Init = true
    end

    local orgs, orgsByVariant = getOrganization()
    if variant == organization.Chaser then
        local chaserHP, chaserMax = 0, 0
        for _, chaser in ipairs(orgsByVariant[organization.Chaser]) do
            chaserHP = chaserHP + chaser.HitPoints
            chaserMax = chaserMax + chaser.MaxHitPoints
        end

        local percent = chaserHP / chaserMax
        if (percent <= 0.85 or scaredyGhosts) and not d.AwokenSpeedy then
            for _, org in ipairs(orgs) do
                if org.Variant == organization.Chaser then
                    org:GetData().AwokenSpeedy = true
                elseif org.Variant == organization.Speedy then
                    org:GetData().Activated = true
                end
            end
        elseif (percent <= 0.65 or scaredyGhosts) and not d.AwokenBashful then
            for _, org in ipairs(orgs) do
                if org.Variant == organization.Chaser then
                    org:GetData().AwokenBashful = true
                elseif org.Variant == organization.Bashful then
                    org:GetData().Activated = true
                end
            end
        elseif (percent <= 0.45 or scaredyGhosts) and not d.AwokenPokey then
            for _, org in ipairs(orgs) do
                if org.Variant == organization.Chaser then
                    org:GetData().AwokenPokey = true
                elseif org.Variant == organization.Pokey then
                    org:GetData().Activated = true
                end
            end
        end

        if isEaten then
            npc:TakeDamage(9999, 0, EntityRef(npc), 0)
            if d.Brain then
                d.Brain:TakeDamage(9999, 0, EntityRef(npc), 0)
            end

            d.WasEaten = true
        end
    elseif d.State ~= "Death" then
        local dead = #orgsByVariant[organization.Chaser] == 0 or isEaten
        if not dead then
            dead = true
            for _, chaser in ipairs(orgsByVariant[organization.Chaser]) do
                if not chaser:IsDead() then
                    dead = false
                end
            end
        end

        if dead and (not scaredyGhosts or isEaten) then
		    d.Activated = true
            sprite.FlipX = false
            sprite:Play("CorpseDeath", true)
            d.State = "Death"
            d.WasEaten = isEaten
        end
    end

    if d.Brain then
        d.Brain.Visible = true

        local bSprite = d.Brain:GetSprite()
        if d.BrainAirTime then
            d.BrainAirTime = d.BrainAirTime + 1

            if d.BrainAirTime % 3 == 0 then
                local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, d.Brain.Position, Vector(0, 0), npc)
                explosion.PositionOffset = d.Brain.PositionOffset
            end

            local percent = d.BrainAirTime / d.BrainFullAirTime
            local brainPos = mod:Lerp(d.BrainFrom, d.BrainTarget, percent)
            d.Brain.Velocity = brainPos - d.Brain.Position

            if d.BrainAirTime >= d.BrainFullAirTime then
                d.Brain.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                d.Brain.Velocity = Vector(0, 0)
                d.Brain.PositionOffset = Vector(0, 0)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, d.Brain.Position, Vector(0, 0), npc)
                bSprite:Play("Land", true)
                d.BrainAirTime = nil
                d.BrainFullAirTime = nil
                d.BrainRenderTime = nil
                d.BrainTarget = nil
                d.BrainFrom = nil
            end
        else
            if bSprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,0,false,1)

                d.Creep = {}
                local bigCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, d.Brain.Position, Vector(0,0), npc):ToEffect()
                bigCreep.SpriteScale = Vector(2, 2)
                bigCreep:Update()
                d.Creep[#d.Creep + 1] = bigCreep

                for i = 0, 270, 90 do
                    local pos = d.Brain.Position + Vector.FromAngle(i) * 40
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, pos, Vector(0,0), npc):ToEffect()
                    creep:Update()
                    d.Creep[#d.Creep + 1] = creep
                end
            end

            if d.Creep then
                for _, creep in ipairs(d.Creep) do
                    if creep:Exists() then
                        creep:SetTimeout(15)
                    end
                end
            end

            if not bSprite:IsPlaying("Land") and not bSprite:IsPlaying("BrainIdle") then
                bSprite:Play("BrainIdle", true)
            end

            d.Brain.Velocity = Vector(0, 0)
        end
    else
        d.Creep = nil
    end

    if d.TryStun and (d.State == "Idle" or d.State == "Freeze") then
        if variant ~= organization.Pokey then
            d.Stun = bal.MaxStun
        elseif not d.RageTrigger and not d.Rage and d.State == "Idle" then
            d.State = "PokeyRage"
            d.RageTrigger = 1
        end
    end

    if d.Stun then
        if d.State ~= "Idle" and d.State ~= "Freeze" then
            d.Stun = 0
        end

        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        local interval = math.floor(mod:Lerp(4, 10, d.Stun / bal.MaxStun))
        if d.Stun % interval == 0 then
            d.Blip = 2
        end

        if d.Blip then
            npc.Color = Color(1, 1, 1, 0.4, 0, 0, 0)
            d.Blip = d.Blip - 1
            if d.Blip <= 0 then
                d.Blip = nil
            end
        else
            npc.Color = Color(1, 1, 1, 0.1, 0, 0, 0)
        end

        d.Stun = d.Stun - 1
        if d.Stun <= 0 then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.Color = Color(1, 1, 1, 1, 0, 0, 0)
            d.Stun = nil
        end
    end

    if d.WasEaten then
        local allOrgsDead = true
        local rewardSet = false
        for _, org in ipairs(orgs) do
            if not (org:IsDead() or org:HasMortalDamage() or org:GetData().State == "Death" or org:GetData().WasEaten) then
                allOrgsDead = false
            end

            if org:GetData().SpawnDeathReward then
                rewardSet = true
            end
        end

        if allOrgsDead and not rewardSet and #Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_HAUNTED_BADGE, false, false) == 0 then
            if variant == organization.Chaser then
                if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
                    Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_HAUNTED_BADGE, npc.Position, Vector(0, 0), npc)
                end
            else
                d.SpawnDeathReward = true
            end
        end
    end

    if d.State == "Appear" then
        npc.Velocity = Vector(0, 0)
        if sprite:IsFinished("Appear") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            d.State = "Idle"
            d.Moving = true
        end
    elseif d.State == "Death" then
        d.Moving = false
        npc.Velocity = Vector(0, 0)
        if not sprite:IsPlaying("CorpseDeath") then
            if d.SpawnDeathReward then
                Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_HAUNTED_BADGE, npc.Position, Vector(0, 0), npc)
            elseif bal.CorpseAnim then
                local corpse = Isaac.Spawn(npc.Type, npc.Variant, 1, npc.Position, npc.Velocity, npc)
                corpse:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                corpse:GetSprite():Play(bal.CorpseAnim, true)
            end

            npc:Remove()
		elseif sprite:IsEventTriggered("Heartbreak") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 1);
		elseif sprite:IsEventTriggered("Ouch") then
			npc:PlaySound(mod.Sounds.PokeyCalm, 0.4, 0, false, 0.65)
		elseif sprite:IsEventTriggered("HeartBeat") then
			npc:PlaySound(SoundEffect.SOUND_HEARTBEAT_FASTER, 1, 0, false, 1.2);
		elseif sprite:IsEventTriggered("Spitup") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_GURGLE, 1, 0, false, 1.2);
		elseif sprite:IsEventTriggered("Pop") then
			npc:PlaySound(SoundEffect.SOUND_PLOP,1,2,false,math.random(6,8)/10)
		elseif sprite:IsEventTriggered("Drain") then --Bashful fills up with tears
			npc:PlaySound(SoundEffect.SOUND_GASCAN_POUR, 0.5, 0, false, 1.7);
		elseif sprite:IsEventTriggered("Splat") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1.5);
		elseif sprite:IsEventTriggered("Burst") then
			npc:PlaySound(mod.Sounds.FireFizzle, 0.7, 0, false, math.random(70,130)/100)
        end
    elseif d.State == "Freeze" then
        d.Moving = false
        npc.Velocity = npc.Velocity * 0.75
        local freezeIdle = "Idle"
        if variant == organization.Speedy then
            freezeIdle = "Dizzy"
        end

        if sprite:IsEventTriggered("Unstick") then
            npc.Velocity = d.Bounce
        end

        if sprite:IsEventTriggered("Recover") then
            d.Moving = true
        end

        if sprite:IsFinished("Recover") then
            d.Freeze = nil
            d.State = "Idle"
            d.Moving = true
        elseif d.Freeze and not sprite:IsPlaying(d.FreezeAnim) and not sprite:IsPlaying(freezeIdle) then
            sprite:Play(freezeIdle, true)
        end

        if d.Freeze then
            d.Freeze = d.Freeze - 1
            if d.Freeze <= 0 then
                d.Freeze = nil
                sprite:Play("Recover", true)
            end
        end
    elseif d.State == "PokeyRage" then
        local flip, animFaceDir, suff = getOrgFlipFaceDirSuffix(variant, d)
        sprite.FlipX = flip

        if d.RageTrigger == 1 then
            d.ChaseStartAnim = "Chase" .. animFaceDir .. "Start"
            sprite:Play(d.ChaseStartAnim, true)
            d.RageTrigger = 2
			npc:PlaySound(mod.Sounds.PokeyCrazy,1,0,false,math.random(90,110)/100)
        elseif d.RageTrigger == 2 then
            if sprite:IsEventTriggered("ChaseStart") then
                d.Rage = bal.MaxRage
                d.MoveAlt = true
            end

            if sprite:IsFinished(d.ChaseStartAnim) then
                d.RageTrigger = nil
                sprite:Play("Chase" .. animFaceDir .. "Loop", true)
            end
        elseif d.Rage then
            if not sprite:IsPlaying("Chase" .. animFaceDir .. "Loop") then
                sprite:Play("Chase" .. animFaceDir .. "Loop", true)
            end

            for _, bashful in ipairs(orgsByVariant[organization.Bashful]) do
                if bashful.Position:DistanceSquared(npc.Position) < (npc.Size + bashful.Size + 20) ^ 2 then
                    d.Rage = 0
                end
            end

            d.Rage = d.Rage - 1
            if d.Rage <= 0 then
                d.MoveAlt = nil
                d.Rage = nil
                d.Freeze = bal.MaxFreeze
                d.State = "Freeze"
                d.FreezeAnim = "Chase" .. animFaceDir .. "End"
                sprite:Play(d.FreezeAnim, true)
				npc:PlaySound(mod.Sounds.PokeyCalm,0.7,0,false,math.random(90,110)/100)
            end
        end
    elseif d.State == "BashfulRage" then
        local flip, animFaceDir, suff = getOrgFlipFaceDirSuffix(variant, d)
        sprite.FlipX = flip

        if d.RageTrigger == 1 then
			npc:PlaySound(mod.Sounds.BashfulSpotted,0.6,0,false,math.random(125,135)/100)
            d.ShootStartAnim = "Shoot" .. animFaceDir .. "Start"
            sprite:Play(d.ShootStartAnim, true)
            d.RageTrigger = 2
        elseif d.RageTrigger == 2 then
            if sprite:IsEventTriggered("Shoot") then
                d.Rage = 0
            end

            if sprite:IsFinished(d.ShootStartAnim) then
                d.RageTrigger = nil
                sprite:Play("Shoot" .. animFaceDir .. "Loop", true)
            end
        end

        if d.Rage then
            if not d.RageTrigger and not sprite:IsPlaying("Shoot" .. animFaceDir .. "Loop") then
                sprite:Play("Shoot" .. animFaceDir .. "Loop", true)
            end

            if not d.ShotDelay then
                d.ShotDelay = npc:GetDropRNG():RandomInt(5) + 2
            end

            d.ShotDelay = d.ShotDelay - 1
            if d.ShotDelay <= 0 then
                d.ShotDelay = nil
                local curInd = room:GetGridIndex(npc.Position)
                local targInd = curInd - d.Facing
                local targVec = (room:GetGridPosition(targInd) - npc.Position):Resized(6):Rotated(npc:GetDropRNG():RandomInt(31) - 15)
                local params = ProjectileParams()
                npc:FireProjectiles(npc.Position, targVec, 0, params)
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1.2)
            end

            d.Rage = d.Rage + 1
            if d.Rage > bal.MinRage and d.LastFacing ~= d.Facing then
                d.Rage = nil
                d.State = "Idle"
                d.WalkShootAnim = "Shoot" .. animFaceDir .. "End"
                sprite:Play(d.WalkShootAnim, true)
            end
        end

        d.LastFacing = d.Facing
    elseif d.State == "SpeedyRage" then
        d.Moving = false

        local flip, animFaceDir, suff = getOrgFlipFaceDirSuffix(variant, d)
        sprite.FlipX = flip

        if d.RageTrigger == 1 then
            d.ChargeStartAnim = "Charge" .. animFaceDir .. "Start"
            sprite:Play(d.ChargeStartAnim, true)
            d.RageTrigger = 2
        elseif d.RageTrigger == 2 then
            if sprite:IsEventTriggered("Smugass") then
                npc:PlaySound(mod.Sounds.SpeedyStart,1,0,false,math.random(90,110)/100)
            end
            if sprite:IsEventTriggered("Charge") then
                d.Rage = true
				npc:PlaySound(mod.Sounds.SpeedyChargeStart,1.5,0,false,math.random(140,160)/100)
            end

            if sprite:IsFinished(d.ChargeStartAnim) then
                d.RageTrigger = nil
                sprite:Play("Charge" .. animFaceDir .. "Loop", true)
            end
        end

        if d.Rage then
            if not d.RageTrigger and not sprite:IsPlaying("Charge" .. animFaceDir .. "Loop") then
                sprite:Play("Charge" .. animFaceDir .. "Loop", true)
            end

            local curInd = room:GetGridIndex(npc.Position)
            local targInd = curInd + d.Facing
            local targVec = (room:GetGridPosition(targInd) - npc.Position):Resized(bal.ChargeSpeed)
            npc.Velocity = targVec

            local collision
            local checkGridPositions = {room:GetGridPosition(curInd), room:GetGridPosition(targInd)}
            for _, pos in ipairs(checkGridPositions) do
                if pos:DistanceSquared(npc.Position) < (npc.Size + 20) ^ 2 and room:GetGridCollisionAtPos(pos) ~= GridCollisionClass.COLLISION_NONE then
                    collision = true
                    break
                end
            end

            if not collision then
                for i = 1, game:GetNumPlayers() do
                    local p = Isaac.GetPlayer(i - 1)
                    if p.Position:DistanceSquared(npc.Position) < (npc.Size + p.Size) ^ 2 then
                        collision = true
                        break
                    end
                end
            end

            if collision then
                d.Bounce = -npc.Velocity * 0.25
                npc.Velocity = Vector(0, 0)
                d.Rage = nil
                d.Freeze = bal.MaxFreeze
                d.State = "Freeze"
                d.FreezeAnim = "Collision" .. animFaceDir
                sprite:Play(d.FreezeAnim, true)
				npc:PlaySound(mod.Sounds.SpeedyChargeBash,1.5,0,false,math.random(140,160)/100)
            end
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    elseif d.State == "ChaserBrain" then
        local flip, animFaceDir, suff = getOrgFlipFaceDirSuffix(variant, d)
        sprite.FlipX = flip
    elseif d.State == "Idle" then
        local flip, animFaceDir, suff = getOrgFlipFaceDirSuffix(variant, d)
        sprite.FlipX = flip

        -- pick attack if necessary
        if variant == organization.Pokey then
            -- not using target so A) it isn't accidentally triggered and B) all players can trigger it at all times
            for i = 1, game:GetNumPlayers() do
                local p = Isaac.GetPlayer(i - 1)
                if p.Position:DistanceSquared(npc.Position) < (npc.Size + p.Size + 40) ^ 2 then
                    d.State = "PokeyRage"
                    d.RageTrigger = 1
                end
            end
        elseif variant == organization.Bashful and d.Facing then
            local target = npc:GetPlayerTarget()
            if isLineFree(room:GetGridIndex(npc.Position), room:GetGridIndex(target.Position), -d.Facing) and target.Position:DistanceSquared(npc.Position) < (npc.Size + target.Size + 200) ^ 2 then
                d.State = "BashfulRage"
                d.RageTrigger = 1
            end
        elseif variant == organization.Speedy and d.Facing then
            local target = npc:GetPlayerTarget()
            if isLineFree(room:GetGridIndex(npc.Position), room:GetGridIndex(target.Position), d.Facing) then
                d.State = "SpeedyRage"
                d.RageTrigger = 1
            end
        elseif variant == organization.Chaser and d.Facing and not d.NoBrainer then
            if not d.AttackCooldown then
                d.AttackCooldown = npc:GetDropRNG():RandomInt(bal.MaxAttackCooldown - bal.MinAttackCooldown) + bal.MinAttackCooldown
            end

            if not d.SpawnHoming then
                if d.Brainer then
                    d.WalkShootAnim = "BrainLaunch" .. animFaceDir
                    if not d.BrainShootFrame then
                        sprite:Play(d.WalkShootAnim)
                        d.BrainShootFrame = 0
                    end

                    d.BrainShootFrame = sprite:GetFrame()
                    if not sprite:IsPlaying(d.WalkShootAnim) then
                        sprite:Play(d.WalkShootAnim, true)
                        if d.BrainShootFrame > 0 then
                            for i = 1, d.BrainShootFrame do
                                sprite:Update()
                            end
                        end
                    end

                    if sprite:IsEventTriggered("Shoot") then
					    npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,0.7)
					    npc:PlaySound(mod.Sounds.ChaserLaunch,1,0,false,math.random(75,95)/100)
                        d.Brain = Isaac.Spawn(npc.Type, npc.Variant, 1, npc.Position, Vector(0, 0), npc)
                        d.Brain:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        d.Brain.Visible = false
                        d.Brain.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        d.Brain.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                        d.Brain:GetSprite():Play("InAir", true)
                        d.BrainTarget = Isaac.GetFreeNearPosition(npc:GetPlayerTarget().Position, 0)
                        d.BrainFrom = npc.Position
                        d.BrainAirTime = 0
                        d.BrainFullAirTime = math.max(15, math.ceil(d.BrainFrom:Distance(d.BrainTarget) / bal.BrainAirSpeed))
                        d.Brain:GetData().Chaser = npc
                    end

                    if sprite:IsFinished(d.WalkShootAnim) or d.BrainShootFrame >= 30 then
                        d.NoBrainer = true
                        d.Brainer = nil
                        d.BrainShootFrame = nil
                    end
                else
                    d.AttackCooldown = d.AttackCooldown - 1
                    if d.AttackCooldown <= 0 then
                        if d.AwokenPokey then
                            d.Brainer = true
                        elseif d.AwokenBashful then
                            d.SpawnHoming = 3
                            d.Brainer = true
                        else
                            d.SpawnHoming = 5
                        end

                        if d.SpawnHoming then
                            d.WalkShootAnim = "BrainShoot" .. animFaceDir
                            d.BrainShootFrame = 0
                            sprite:Play(d.WalkShootAnim, true)
                        end

                        d.AttackCooldown = nil
                    end
                end
            else
                if sprite:IsEventTriggered("Shoot") then
					npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,0.95)
                    local params = ProjectileParams()
                    params.FallingAccelModifier = -0.1
                    params.HeightModifier = -10
                    params.HomingStrength = 0.5
                    params.BulletFlags = ProjectileFlags.SMART | ProjectileFlags.NO_WALL_COLLIDE
                    npc:FireProjectiles(npc.Position + npc.Velocity:Resized(10), Vector(0, 0), 0, params)
                end

                d.BrainShootFrame = sprite:GetFrame()
                d.WalkShootAnim = "BrainShoot" .. animFaceDir
                if not sprite:IsPlaying(d.WalkShootAnim) then
                    sprite:Play(d.WalkShootAnim, true)
                    if d.BrainShootFrame > 0 then
                        for i = 1, d.BrainShootFrame do
                            sprite:Update()
                        end
                    end
                end

                if sprite:IsFinished(d.WalkShootAnim) or d.BrainShootFrame >= 20 then
                    d.SpawnHoming = d.SpawnHoming - 1
                    if d.SpawnHoming <= 0 then
                        d.BrainShootFrame = nil
                        d.SpawnHoming = nil
                    else
                        d.BrainShootFrame = 0
                        sprite:Play(d.WalkShootAnim, true)
                    end
                end
            end
        elseif variant == organization.Chaser and d.NoBrainer and not d.BrainAirTime then
            if npc.Position:DistanceSquared(d.Brain.Position) < (npc.Size + d.Brain.Size + 20) ^ 2 and d.Moving then
                d.Moving = false
                d.WalkShootAnim = "Recover" .. animFaceDir
                sprite:Play(d.WalkShootAnim, true)
            end

            if not d.Moving then
                npc.Velocity = npc.Velocity * 0.75
            end

            if sprite:IsEventTriggered("BrainGet") then
			    npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
			end
            if sprite:IsEventTriggered("BrainPickUp") then
				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,1)
				npc:PlaySound(mod.Sounds.ChaserPickup,1,0,false,1)
                d.Brain:Remove()
                d.NoBrainer = nil
                d.Brain = nil
                d.Moving = true
            end
        end

        if variant == organization.Pokey then
            if not sprite:IsPlaying("Walk") then
                sprite:Play("Walk", true)
            end
        else
            if (not d.WalkShootAnim or not sprite:IsPlaying(d.WalkShootAnim)) and not sprite:IsPlaying("Walk" .. animFaceDir .. suff) then
                sprite:Play("Walk" .. animFaceDir .. suff, true)
            end
        end
    end

    if d.Moving then
        moveOrganization(npc, d, npc:GetPlayerTarget(), variant, d.MoveAlt or d.NoBrainer)
    else
        d.TargetIndex = nil
    end

    d.TryStun = nil
end

function mod:organizationRender(npc)
    if npc.Variant == organization.Chaser then
        local d = npc:GetData()
        if d.BrainAirTime then
            if not d.BrainRenderTime then
                d.BrainRenderTime = d.BrainAirTime or 0
            end

            d.BrainRenderTime = math.min(d.BrainRenderTime + 0.5, d.BrainAirTime)
            local percent = d.BrainRenderTime / d.BrainFullAirTime
            local brainHeight = Vector(100, 0):Rotated(mod:Lerp(45, 180, percent)).Y + 20
            d.Brain.PositionOffset = Vector(0, -brainHeight)
        end
	end
	if (npc.Variant > 59 and npc.Variant < 64) then
		local sprite = npc:GetSprite()
		if sprite:IsPlaying("Death") or sprite:IsPlaying("Appear") then
			if sprite:IsEventTriggered("Whimper") then
				npc:PlaySound(mod.Sounds.ChaserWhimper, 0.4, 0, false, 0.7)
			elseif sprite:IsEventTriggered("Splatup") then
				npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.ChaserLaunch,1,0,false,0.8)
			elseif sprite:IsEventTriggered("Fade") then
				npc:PlaySound(mod.Sounds.FireFizzle, 0.7, 0, false, math.random(70,130)/100)
			elseif sprite:IsEventTriggered("Fade2") then
				npc:PlaySound(mod.Sounds.GhostFizzle, 1, 0, false, math.random(120,130)/100)
			elseif sprite:IsEventTriggered("Chomp") then
				npc:PlaySound(SoundEffect.SOUND_VAMP_GULP, 0.7, 0, false, 1.7)
			elseif sprite:IsEventTriggered("Smugass") then
				npc:PlaySound(mod.Sounds.SpeedySmugass, 0.7, 0, false, 0.7)
			end
		end
    end
end



local brainflecting
function mod:organizationHurt(e, amount, flags, source, iframes)
    local variant = e.Variant
    if variant >= 60 and variant <= 63 then
        if e.SubType ~= 1 then
            if flags & DamageFlag.DAMAGE_SPIKES ~= 0 then
                return false
            end

            if variant ~= organization.Chaser or (e:GetData().NoBrainer and not brainflecting) then
                e:GetData().TryStun = true
                return false
            end
        elseif variant == organization.Chaser then
            if flags & DamageFlag.DAMAGE_SPIKES ~= 0 then
                return false
            else
                brainflecting = true
                e:GetData().Chaser:TakeDamage(amount, flags, source, iframes)
                brainflecting = nil
                e.HitPoints = e.HitPoints + amount
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.organizationHurt, orgType)
