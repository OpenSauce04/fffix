local mod = FiendFolio
local game = Game()

local function getEdemaDir(npc, data, rng)
    local vec = Vector(0,1):Rotated(90*data.stuckNum)
    local chosen
    if not data.prevDir or mod:isConfuse(npc) then
        local num = rng:RandomInt(2)*90
        local dir = vec:Rotated(-45+num)
        chosen = dir
    elseif data.prevDir then
        for i=-45,45,90 do
            local dir = vec:Rotated(i)
            local diff = mod:GetAngleDifferenceDead(dir, data.prevDir)
            if math.abs(diff) > 5 then
                chosen = dir
                break
            end
        end
    end
    --[[local proj = Isaac.Spawn(9, 0, 0, npc.Position, chosen:Resized(8), npc):ToProjectile()
    proj:AddProjectileFlags(ProjectileFlags.GHOST)]]
    return chosen
end

local function getEdemaRock(npc) --man you did this in a really stupid way
    local room = game:GetRoom()
    local dist = 9999
    local chosen
    local num
    local data = npc:GetData()
    for i=0,270,90 do
        local dest = room:GetLaserTarget(npc.Position, Vector(0,1):Rotated(i))
        local adjustedPos = npc.Position+data.fallDir:Resized(5)
        if adjustedPos:Distance(dest) < dist and adjustedPos:Distance(dest) < 60 then
            chosen = Vector(0,1):Rotated(i)
            dist = adjustedPos:Distance(dest)
            num = (180+i)/90
        end
    end

    local grid = room:GetGridEntityFromPos(npc.Position+npc:GetData().fallDir:Resized(40))
    if chosen == nil and grid then
        if math.abs(npc.Position.X-grid.Position.X) > math.abs(npc.Position.Y-grid.Position.Y) then
            if data.fallDir.X > 0 then
                num = 1
                chosen = Vector(1,0)
            else
                num = 3
                chosen = Vector(-1,0)
            end
        else
            if data.fallDir.Y > 0 then
                num = 2
                chosen = Vector(0,1)
            else
                num = 4
                chosen = Vector(0,-1)
            end
        end
    end

    return {chosen, num}
end

function mod:edemaAI(npc)
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local sprite = npc:GetSprite()
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local redema = (npc.Variant == mod.FF.Redema.Var)

    if not data.init then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)

        local dir = (npc.SubType >> 1 & 7)
		if dir == 0 then
            local num = rng:RandomInt(4)+1
			data.fallDir = Vector(5,0):Rotated(-45+90*num)
            data.prevDir = data.fallDir:Rotated(180)
		else
			data.fallDir = Vector(5,0):Rotated(-45+90*dir)
            data.prevDir = data.fallDir:Rotated(180)
		end

        if (npc.SubType & 1) == 0 then
            local stuckDir
            local stuckNum
            for j=0,1 do
                local checkPos
                if j == 0 then
                    checkPos = Vector(40, 0)
                else
                    checkPos = Vector(0, 40)
                end
                for i=0,180,180 do
                    local coll = room:GetGridCollisionAtPos(npc.Position+checkPos:Rotated(i))
                    if coll and coll >= GridCollisionClass.COLLISION_OBJECT then
                        if j == 0 then
                            if i == 0 then
                                stuckNum = 1
                            else
                                stuckNum = 3
                            end
                        else
                            if i == 0 then
                                stuckNum = 2
                            else
                                stuckNum = 4
                            end
                        end
                        stuckDir = checkPos:Rotated(i)
                        break
                    end
                end
            end
            if stuckDir then
                data.state = "Stuck"
                data.ignoreFirstRedirect = true
                data.stuckDir = stuckDir
                data.stuckNum = stuckNum
                npc.Position = npc.Position+stuckDir:Resized(10)
                if dir == 0 then
                    data.ignoreFirstRedirect = nil
                end
            else
                data.state = "Falling"
            end
		else
            data.state = "Falling"
		end

        if not redema then
            npc.SplatColor = mod.ColorGreyscale
        end

        local frames = (npc.SubType >> 4 & 63)
        npc.StateFrame = frames-32

        data.rSprite = math.random(1,5)
        data.speed = 0.5
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if data.state == "Stuck" then
        mod:spritePlay(sprite, "Impact0" .. data.rSprite)
        npc.Velocity = Vector.Zero

        local startFall = false
        if (redema and npc.StateFrame >= 26) then -- npc.StateFrame > 16
            startFall = true
        elseif npc.StateFrame >= 30 then -- npc.StateFrame > 24
            startFall = true
        end

        local coll = room:GetGridCollisionAtPos(npc.Position+data.stuckDir:Resized(40))
        if coll < GridCollisionClass.COLLISION_OBJECT then
            local coll2 = room:GetGridCollisionAtPos(npc.Position+data.fallDir:Resized(40))
            if coll2 < GridCollisionClass.COLLISION_OBJECT then
                startFall = true
            end
        end

        if startFall then
            data.state = "Falling"
            if data.ignoreFirstRedirect then
                data.ignoreFirstRedirect = nil
            else
                local dir = getEdemaDir(npc, data, rng)
                data.fallDir = dir
                data.prevDir = dir:Rotated(180)
            end
            data.speed = 0.5
            npc.StateFrame = 0
        end
    elseif data.state == "Falling" then
        mod:spritePlay(sprite, "Idle0" .. data.rSprite)
        
        if npc.FrameCount > 10 then
            if redema then
                if data.speed < 17.5 then -- data.speed < 20
                    data.speed = (data.speed+0.6)*1.1
                end
            elseif data.speed < 15.5 then
                data.speed = (data.speed+0.6)*1.1
            end

            npc.Velocity = mod:Lerp(npc.Velocity, data.fallDir:Resized(data.speed), 0.3)
        end

        local grazingColl = false
        if npc:CollidesWithGrid() then
            for i=90,360,90 do
                local grid = room:GetGridEntityFromPos(npc.Position+Vector(0,30):Rotated(i))
                if grid then
                    if npc.Size+24 > grid.Position:Distance(npc.Position) and grid.CollisionClass > GridCollisionClass.COLLISION_OBJECT then
                        grazingColl = true
                    end
                end
            end
            --npc.Color = Color(1,0,0,1,0,0,0)
        else
            --npc.Color = Color(1,1,1,1,0,0,0)
        end
        local coll = room:GetGridCollisionAtPos(npc.Position+data.fallDir:Resized(30))
        if (coll >= GridCollisionClass.COLLISION_OBJECT or grazingColl) and npc.StateFrame > 5 then
            if redema and npc.StateFrame > 10 then
                local poof = Isaac.Spawn(1000, 2, 5, npc.Position+Vector(0,5), Vector.Zero, npc):ToEffect()
                poof.Color = Color(1,1,1,0.8)
                poof:FollowParent(npc)
                poof.DepthOffset = 20
                local params = ProjectileParams()
                params.HeightModifier = 10
                params.FallingAccelModifier = 0
                params.FallingSpeedModifier = 0
                npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(8), 0, ProjectileParams())
                npc:PlaySound(mod.Sounds.IrisSpit, 0.3, 0, false, 1)
            end

            npc.Velocity = Vector.Zero
            local dir = getEdemaRock(npc)
            data.stuckDir = dir[1]
            data.stuckNum = dir[2]
            data.state = "Stuck"
            if npc.StateFrame > 12 then
                npc.StateFrame = 0
            else
                if redema then
                    npc.StateFrame = 26-npc.StateFrame
                    if data.quickBounce then
                        npc.StateFrame = 26-npc.StateFrame-data.quickBounce
                        data.quickBounce = nil
                    end
                else
                    npc.StateFrame = 32-npc.StateFrame
                    if data.quickBounce then
                        npc.StateFrame = 32-npc.StateFrame-data.quickBounce
                        data.quickBounce = nil
                    end
                end
            end
            data.rSprite = math.random(1,5)
            npc:PlaySound(mod.Sounds.EdemaBounce, 1, 0, false, 1)
        elseif not data.quickBounce and (coll >= GridCollisionClass.COLLISION_OBJECT or grazingColl) then
            data.quickBounce = npc.StateFrame
        end
    end

    if npc:IsDead() and redema then
        local params = ProjectileParams()
        params.HeightModifier = 10
        params.FallingAccelModifier = 0
        params.FallingSpeedModifier = 0
        for i=0,270,90 do
            npc:FireProjectiles(npc.Position, Vector(4,4):Resized(8):Rotated(i), 0, ProjectileParams())
        end
        npc:PlaySound(mod.Sounds.IrisSpit, 0.6, 0, false, 1)
    end
end
