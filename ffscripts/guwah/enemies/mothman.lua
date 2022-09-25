local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function GetMothmanTarget() --Borrowed from Morvid
    local room = game:GetRoom()
    local goodIndices = {}

    if FiendFolio.GenericChaserPathMap.TargetMapSets[1] then
        local map = FiendFolio.GenericChaserPathMap.TargetMapSets[1].Map
        if map then
            for index, moveCost in pairs(map) do
                if moveCost < 10000 then
                    goodIndices[#goodIndices + 1] = index
                end
            end
        end
    end

    if #goodIndices == 0 then
        for i = 0, room:GetGridSize() do
            if room:IsPositionInRoom(room:GetGridPosition(i), 0) and room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE then
                goodIndices[#goodIndices + 1] = i
            end
        end
    end

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
        return mod:GetRandomElem(preferredIndices)
    end

    return mod:GetRandomElem(goodIndices)
end

local function MothmanProjectile(npc)
    local params = ProjectileParams()
    params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
    params.FallingSpeedModifier = 20
    params.HeightModifier = -80
    npc:FireProjectiles(npc.Position, RandomVector():Resized(mod:RandomInt(1,3)) + (npc.Velocity * 0.5), 0, params)
    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1, 0.6)
    local effect = Isaac.Spawn(1000, 2, 1, npc.Position + (RandomVector()*mod:RandomInt(1,3)), Vector.Zero, npc):ToEffect()
    effect:FollowParent(npc)
    effect.SpriteScale = Vector(0.75,0.75)
    effect.DepthOffset = 1000
    if npc:GetSprite().FlipX then
        effect.SpriteOffset = Vector(-3,-45)
    else
        effect.SpriteOffset = Vector(3,-45)
    end
end

function mod:MothmanAI(npc, sprite, data)
    local room = game:GetRoom()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        data.state = "idle"
        npc.StateFrame = mod:RandomInt(30,60)
        data.MothmanFilter = function(position, candidate)
            if (mod:CheckIDInTable(candidate, FiendFolio.MothmanBlacklist) or mod:isFriend(candidate) ~= mod:isFriend(npc) or candidate.InitSeed == npc.InitSeed or candidate.Visible == false or candidate.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE) then
                return false
            else
                return true
            end
        end
        data.Init = true
    end
    if data.state == "idle" then
        mod:spritePlay(sprite, "Idle")
        npc.Velocity = npc.Velocity * 0.8
        if mod:RandomInt(20) == 1 then
            npc.TargetPosition = mod:FindRandomValidPathPosition(npc)
            data.state = "walk"
        end
        mod:MothmanAttackCheck(npc, data)
    elseif data.state == "walk" then
        mod:spritePlay(sprite, "Walk")
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        if sprite:IsEventTriggered("StartStep") then
            data.movin = true
        elseif sprite:IsEventTriggered("StopStep") then
            data.movin = false
            npc.Velocity = npc.Velocity * 0.5
        end
        if npc.Position:Distance(npc.TargetPosition) > 30 then
            if data.movin then
                if room:CheckLine(npc.Position,npc.TargetPosition,0,1,false,false) then
                    local targetvel = (npc.TargetPosition - npc.Position):Resized(6)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
                else
                    npc.Pathfinder:FindGridPath(npc.TargetPosition, 0.5, 900, true)
                end
            end
        else
            npc.Velocity = npc.Velocity * 0.8
            data.state = "idle"
            data.movin = false
        end
        mod:MothmanAttackCheck(npc, data)
    elseif data.state == "screech" then
        if sprite:IsFinished("Screech") then
            data.state = "idle"
            npc.StateFrame = mod:RandomInt(60,90)
        elseif sprite:IsEventTriggered("Shoot") then
            local target = mod:GetNearestEnemy(targetpos, nil, data.MothmanFilter)
            if target then
                local effect = Isaac.Spawn(mod.FF.ReverseBloodPoof.ID,mod.FF.ReverseBloodPoof.Var,mod.FF.ReverseBloodPoof.Sub,target.Position,Vector.Zero,npc):ToEffect()
                effect:FollowParent(target)
                effect.DepthOffset = target.Position.Y * 1.25
                effect.ParentOffset = Vector(0,-10)
                mod:FlipSprite(sprite, npc.Position, target.Position)
            end
            mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_HISS, npc, 1.2)
            local effect = Isaac.Spawn(1000, 164, 0, npc.Position + Vector(0,-20), Vector.Zero, npc)
            effect:GetSprite().Scale = Vector(0.3,0.3)
            effect.Color = mod.ColorLemonYellow
        else
            mod:spritePlay(sprite, "Screech")
        end
        npc.Velocity = npc.Velocity * 0.8
    elseif data.state == "flystart" then
        if sprite:IsFinished("TakeFlight") then
            data.state = "flying"
            npc.StateFrame = mod:RandomInt(30,45)
        elseif sprite:IsEventTriggered("Jump") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
        else
            mod:spritePlay(sprite, "TakeFlight")
        end
        npc.Velocity = npc.Velocity * 0.8
    elseif data.state == "flying" then
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        mod:spritePlay(sprite, "IdleFlying")
        npc.StateFrame = npc.StateFrame - 1
        npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(2), 0.1)
        if npc.StateFrame <= 0 then
            data.state = "attackstart"
        end
    elseif data.state == "attackstart" then
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        if sprite:IsFinished("AttackStart") then
            data.state = "attacking"
        elseif sprite:IsEventTriggered("Shoot") then
            local vec = targetpos - npc.Position
            npc.TargetPosition = npc.Position + vec:Resized(math.max(300,vec:Length()))
            npc.Velocity = (npc.TargetPosition - npc.Position):Resized(6)
            mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_HISS, npc, 1.2)
        else
            mod:spritePlay(sprite, "AttackStart")
        end
        if sprite:WasEventTriggered("Shoot") then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(8), 0.1)
            if npc.FrameCount % 5 == 0 then
                MothmanProjectile(npc)
            end
        else
            npc.Velocity = npc.Velocity * 0.8
        end
    elseif data.state == "attacking" then
        mod:spritePlay(sprite, "AttackLoop")
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        if npc.Position:Distance(npc.TargetPosition) < 10 then
            local targindex = GetMothmanTarget()
            npc.TargetPosition = room:GetGridPosition(targindex)
            data.state = "lookingtoland"
        else
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(8), 0.1)
        end
        if npc.FrameCount % 5 == 0 then
            MothmanProjectile(npc)
        end
    elseif data.state == "lookingtoland" then
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        mod:spritePlay(sprite, "IdleFlying")
        if npc.Position:Distance(npc.TargetPosition) < 10 then
            data.state = "landing"
        else
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(6.5), 0.25)
        end
    elseif data.state == "landing" then
        if sprite:IsFinished("EndFlight") then
            data.state = "idle"
            npc.StateFrame = mod:RandomInt(60,120)
        elseif sprite:IsEventTriggered("Land") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
            mod:PlaySound(SoundEffect.SOUND_FETUS_LAND, npc, 1, 0.8)
        else
            mod:spritePlay(sprite, "EndFlight")
        end
        npc.Velocity = npc.Velocity * 0.6
    end
end

function mod:MothmanAttackCheck(npc, data)
    npc.StateFrame = npc.StateFrame - 1
    if npc.StateFrame <= 0 then
        if data.DidScreech then
            data.state = "flystart"
            data.DidScreech = false
        else
            if mod:GetAnyEnemy(data.MothmanFilter) then
                data.state = "screech"
            else
                npc.StateFrame = mod:RandomInt(30,60)
            end
            data.DidScreech = true
        end
        data.movin = false
    end
end

function mod:ReverseBloodPoofAI(effect, sprite, data)
    if sprite:IsFinished("Poof") then
        if not data.NoShooting then
            for i = 90, 360, 90 do
                Isaac.Spawn(9,0,0,effect.Position,Vector(10,0):Rotated(i),effect)
            end
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
        end
        effect:Remove()
    end
end