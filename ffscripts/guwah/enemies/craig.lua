local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:CraigAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc.StateFrame = mod:RandomInt(45,60,rng)
        data.State = "Wander"
        sprite:Play("Idle1")
        data.Init = true
    end

    if data.State == "Wander" then
        local walkpos 
        npc.StateFrame = npc.StateFrame - 1

        if npc.StateFrame <= 0 then
            data.BulbPos = data.BulbPos or mod:GetCraigPos(npc)
            if data.BulbPos and npc.Position:Distance(data.BulbPos) < 20 then
                npc.TargetPosition = mod:GetNearestBulbRockPos(npc.Position)
                local vec = npc.TargetPosition - npc.Position
                data.Anim = "Chomp" .. mod:GetMoveString(mod:SnapVector(vec, 90))
                data.State = "Jump"
            end
            if data.BulbPos then
                walkpos = data.BulbPos
            end
        end

        if not walkpos then 
            data.MovePos = data.MovePos or mod:FindRandomValidPathPosition(npc)
            if npc.Position:Distance(data.MovePos) < 20 then
                data.MovePos = mod:FindRandomValidPathPosition(npc)
            end
            walkpos = data.MovePos
        end

        if walkpos then
            local vel
            walkpos = mod:confusePos(npc, walkpos)
            
            if mod:isScare(npc) and npc.Position:Distance(targetpos) <= 200 then
                vel = (npc.Position - table):Resized(3)
            elseif room:CheckLine(npc.Position,walkpos,0,1,false,false) then
                vel = (walkpos - npc.Position):Resized(3)
            else
                npc.Pathfinder:FindGridPath(walkpos, 0.6, 900, true)
            end
        
            if vel then
                npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.1)
            end
        else
            npc.Velocity = npc.Velocity * 0.8
        end

        local anim
        local suffix
        if npc.Velocity:Length() > 0.1 then
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                anim = "WalkHori"
                if npc.Velocity.X < 0 then
                    suffix = 1
                else
                    suffix = 2
                end
            else
                anim = "WalkVert"
                if targetpos.X < npc.Position.X then
                    suffix = 1
                else
                    suffix = 2
                end
            end
        else
            anim = "Idle"
            if targetpos.X < npc.Position.X then
                suffix = 1
            else
                suffix = 2
            end
        end
        if npc.FrameCount > 1 then
            sprite:SetAnimation(anim..suffix, false)
        end
    elseif data.State == "Jump" then
        if sprite:IsFinished(data.Anim) then
            data.Anim = "ShootDown"
            data.State = "Shoot"
        elseif sprite:IsEventTriggered("Jump") then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            local vec = npc.TargetPosition - npc.Position
            vec = vec:Resized(vec:Length() - 10)
            npc.Velocity = vec / 4
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP,npc)
            mod:PlaySound(mod.Sounds.CraigJump,npc)
        elseif sprite:IsEventTriggered("Chomp") then
            npc.Velocity = Vector.Zero
            mod:tryTriggerBulbRock(true)
        elseif sprite:IsEventTriggered("Detach") then
            local landpos = mod:FindSafeSpawnSpot(npc.Position, 100, 200, true)
            npc.Velocity = (landpos - npc.Position) / 5
        elseif sprite:IsEventTriggered("Land") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc.Velocity = npc.Velocity * 0.25
            mod:PlaySound(SoundEffect.SOUND_FETUS_LAND,npc)
        else 
            mod:spritePlay(sprite, data.Anim)
        end

        if sprite:WasEventTriggered("Chomp") and not sprite:WasEventTriggered("Detach") then
            npc.Velocity = Vector.Zero
        else
            npc.Velocity = npc.Velocity * 0.8
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished(data.Anim) then
            sprite:Play("Idle1")
            npc.StateFrame = mod:RandomInt(60,90,rng)
            data.State = "Wander"
            data.MovePos = nil
            data.BulbPos = nil
        elseif sprite:IsEventTriggered("Warn") then
            local vec = targetpos - npc.Position
            data.ShootAngle = mod:GetAngleDegreesButGood(vec)
            data.Anim = "Shoot" .. mod:GetMoveString(mod:SnapVector(vec, 90))
            sprite:SetAnimation(data.Anim, false)

            local tracer = Isaac.Spawn(1000, 198, 0, npc.Position + Vector(10, 0):Rotated(data.ShootAngle), Vector(0.001,0), npc):ToEffect()
            tracer.Timeout = 20
            tracer.TargetPosition = Vector(1,0):Rotated(data.ShootAngle)
            tracer.LifeSpan = 15
            tracer:FollowParent(npc)
            tracer.SpriteScale = Vector(5,5)
            tracer.Color = mod.ColorLemonYellow
            tracer:Update()
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(mod.Sounds.CraigLaser,npc,1,2)
            local laser = EntityLaser.ShootAngle(14, npc.Position, data.ShootAngle, 20, Vector(0,-30), npc)
            laser.Color = mod.ColorLemonYellow
        else
            mod:spritePlay(sprite, data.Anim)
        end
    end
end

function mod:CraigHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(damageFlags, DamageFlag.DAMAGE_LASER) and source.Entity and source.Type == mod.FF.Craig.ID and source.Variant == mod.FF.Craig.Var then
        return false
    end
end

function mod:GetNearestBulbRockPos(pos)
    local bulbpos
    local dist = 9999
    for _, bulbrock in pairs(StageAPI.GetCustomGrids(nil, "FFBulbRock")) do
        local grid = bulbrock.GridEntity
        if grid and grid.Position:Distance(pos) < dist then
            bulbpos = grid.Position
            dist = grid.Position:Distance(pos)
        end
    end
    return bulbpos
end

function mod:GetCraigPos(npc)
	local room = game:GetRoom()
	local validtiles = {}

    for i = 0, room:GetGridSize() - 1 do 
        local gridpos = room:GetGridPosition(i)
        local bulbpos = mod:GetNearestBulbRockPos(gridpos)
		if bulbpos and bulbpos:Distance(gridpos) <= 160 and room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE and npc.Pathfinder:HasPathToPos(gridpos) and room:IsPositionInRoom(gridpos,0) then
            table.insert(validtiles, i)
        end
	end

	local dist = 10000
	local targetpos = nil
	for i, index in pairs(validtiles) do
		local distance = npc.Position:Distance(room:GetGridPosition(index))
		if distance < dist or not targetpos then
			targetpos = room:GetGridPosition(index)
			dist = distance
		end
	end

	return targetpos
end