local mod = FiendFolio
local game = Game()

function mod:spankyAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local data = npc:GetData()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.init then
        data.state = "Idle"
        data.runTimer = 0
        data.moveTimer = 0
        data.projectile = "failsafe"
        data.init = true
    else
        data.moveTimer = data.moveTimer+1
        npc.StateFrame = npc.StateFrame+1
    end

    if data.state == "Idle" then
        if npc.Velocity:Length() > 0.15 then
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                mod:spritePlay(sprite, "WalkHori")
            else
                mod:spritePlay(sprite, "WalkVert")
            end
        else
            sprite:SetFrame("WalkVert", 0)
        end
        if npc.Velocity.X > 0 then
            sprite.FlipX = false
        else
            sprite.FlipX = true
        end

        if not data.pickUp then
            local dist = 9999
            local chosen
            for _,glob in ipairs(Isaac.FindByType(160, 153, -1, false, true)) do
                if glob:GetData().state == "extinguished" or glob:GetData().state == "roll" then
                    if npc.Pathfinder:HasPathToPos(glob.Position) and glob:GetData().spankyClaimed == nil and glob.Position:Distance(npc.Position) < dist and not glob:GetData().launchedEnemyInfo then
                        chosen = glob
                        dist = glob.Position:Distance(npc.Position)
                    end
                end
            end
            if not data.noSmidgen then
                local smidgen
                for _,spider in ipairs(Isaac.FindByType(160, 861, -1, false, true)) do
                    if npc.Pathfinder:HasPathToPos(spider.Position) and spider:GetData().spankyClaimed == nil and spider.Position:Distance(npc.Position) < dist and not spider:GetData().launchedEnemyInfo then
                        chosen = spider
                        dist = spider.Position:Distance(npc.Position)
                    end
                    smidgen = true
                end
                for _,spider in ipairs(Isaac.FindByType(160, 860, -1, false, true)) do
                    if npc.Pathfinder:HasPathToPos(spider.Position) and spider:GetData().spankyClaimed == nil and spider.Position:Distance(npc.Position) < dist and not spider:GetData().launchedEnemyInfo then
                        chosen = spider
                        dist = spider.Position:Distance(npc.Position)
                    end
                    smidgen = true
                end
                if not smidgen then
                    data.noSmidgen = true
                end
            end
            if not data.noFrowny then
                local frowny
                for _,spider in ipairs(Isaac.FindByType(114, 6, -1, false, true)) do
                    if npc.Pathfinder:HasPathToPos(spider.Position) and spider:GetData().spankyClaimed == nil and spider.Position:Distance(npc.Position) < dist and not spider:GetData().launchedEnemyInfo then
                        chosen = spider
                        dist = spider.Position:Distance(npc.Position)
                    end
                    frowny = true
                end
                if not frowny then
                    data.noFrowny = true
                end
            end
            for _,coal in ipairs(Isaac.FindByType(33, 11, -1, false, true)) do
                if npc.Pathfinder:HasPathToPos(coal.Position) and coal:GetData().spankyClaimed == nil and coal.Position:Distance(npc.Position) < dist and not coal:GetData().launchedEnemyInfo then
                    chosen = coal
                    dist = coal.Position:Distance(npc.Position)
                end
            end
            for _,spider in ipairs(Isaac.FindByType(818, -1, -1, false, true)) do
                if npc.Pathfinder:HasPathToPos(spider.Position) and spider:GetData().spankyClaimed == nil and spider.Position:Distance(npc.Position) < dist and not spider:GetData().launchedEnemyInfo then
                    chosen = spider
                    dist = spider.Position:Distance(npc.Position)
                end
            end

            if chosen then
                chosen:GetData().spankyClaimed = npc
                data.pickUp = chosen
            end
        end

        if mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-target.Position):Resized(6), 0.3)
        elseif data.pickUp and npc.StateFrame > 0 then
            if data.pickUp:Exists() and not mod:isStatusCorpse(data.pickUp) then
                local coalPos = mod:confusePos(npc, data.pickUp.Position)
                if room:CheckLine(npc.Position, coalPos, 0, 900, false, false) or npc.Position:Distance(coalPos) < 50 then
                    npc.Velocity = mod:Lerp(npc.Velocity, (coalPos-npc.Position):Resized(4), 0.3)
                else
                    npc.Pathfinder:FindGridPath(coalPos, 0.35, 900, true)
                end

                if data.pickUp.Position:DistanceSquared(npc.Position) <= (npc.Size + data.pickUp.Size + 10) ^ 2 then
                    data.state = "Picking"
                    data.pickUp:GetData().gettingPicked = true
                    data.pickUp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    if data.pickUp.Type == 818 and data.pickUp.Variant == 2 then
                        data.anim = "Coal"
                        data.projectile = "CoalSpider"
                    elseif data.pickUp.Type == 818 and data.pickUp.Variant == 0 then
                        data.anim = "Rock"
                        data.projectile = "RockSpider"
                    elseif data.pickUp.Type == 33 and data.pickUp.Variant == 11 then
                        data.anim = "Coal"
                        data.projectile = "Coal"
                    elseif data.pickUp.Type == 818 and data.pickUp.Variant == 1 then
                        data.anim = "Rock"
                        data.projectile = "TintedRockSpider"
                    elseif data.pickUp.Type == mod.FF.Glob.ID and data.pickUp.Variant == mod.FF.Glob.Var then
                        data.anim = "Empty"
                        data.projectile = "Glob"
                    else
                        data.anim = "Empty"
                        data.projectile = "Custom"
                    end
                end

                if data.pickUp.Type == 85 then
                    data.pickUp = nil
                elseif data.pickUp.Type == mod.FF.Glob.ID and data.pickUp.Variant == mod.FF.Glob.Var then
                    local pData = data.pickUp:GetData()
                    if pData.state == "idle" or pData.state == "rollend" then
                        pData.spankyClaimed = nil
                        data.pickUp = nil
                    end
                end
            else
                data.pickUp = nil
            end
        else
            if not data.findPos and data.runTimer <= 0 then
                data.findPos = mod:FindRandomValidPathPosition(npc, 3, 80, 120)
            end
            if data.runTimer > 0 then
                data.runTimer = data.runTimer-1
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-target.Position):Resized(3), 0.3)
            elseif mod:isConfuse(npc) then
                npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(2), 0.3)
            elseif npc.StateFrame > 60 and rng:RandomInt(40) == 0 and room:CheckLine(npc.Position, target.Position, 3, 900, false, false) then
                data.state = "Picking"
                data.projectile = "Rock"
                data.anim = "Rock"
            elseif npc.StateFrame > 100 and room:CheckLine(npc.Position, target.Position, 3, 900, false, false) then
                data.state = "Picking"
                data.projectile = "Rock"
                data.anim = "Rock"
            elseif data.moveTimer < 0 then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
            elseif data.findPos:Distance(npc.Position) < 10 or data.moveTimer > 60 then
                data.moveTimer = -mod:getRoll(10,25,rng)
                data.findPos = mod:FindRandomValidPathPosition(npc, 3, 80, 120)
            elseif room:CheckLine(npc.Position, data.findPos, 0, 900, false, false) then
                npc.Velocity = mod:Lerp(npc.Velocity, (data.findPos-npc.Position):Resized(2.5), 0.3)
            else
                npc.Pathfinder:FindGridPath(targetpos, 0.18, 900, true)
            end

            if npc.Position:Distance(target.Position) < 80 then
                data.runTimer = 48
                data.findPos = nil
            end
        end
    elseif data.state == "Picking" then
        if data.pickUp and data.pickUp:Exists() then
            --mod:updateToNPCPosition(npc, data.pickUp, npc.Position+Vector(0,10))
            data.pickUp.Velocity = npc.Velocity
        end

        if data.pickUp and data.pickUp.Type == 85 then
            data.pickUp = nil
            data.state = "Idle"
            npc.StateFrame = 0
        end

        if sprite:IsFinished("PickUp" .. data.anim) then
            data.state = "Firing"
        elseif sprite:IsEventTriggered("Shoot") then
            if data.pickUp and data.pickUp:Exists() then
                if data.pickUp.Type == 33 and data.pickUp.Variant == 11 then
                    data.projectile = "Coal"
                elseif data.projectile == "Custom" or data.projectile == "Glob" then
                    data.custom = {data.pickUp.Type, data.pickUp.Variant, data.pickUp.SubType}
                    if data.projectile == "Glob" then
                        SFXManager():Stop(mod.Sounds.RolyPolyRoll)
                    end
                end
                data.shotHealth = data.pickUp.HitPoints
                data.pickUp:Remove()
                data.pickUp = nil
            else
                data.projectile = "Rock"
            end
            npc:PlaySound(SoundEffect.SOUND_FETUS_LAND, 1, 0, false, 1.6)
        else
            mod:spritePlay(sprite, "PickUp" .. data.anim)
        end
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "Firing" then
        if sprite:IsFinished("Shoot") then
            data.projectile = "failsafe"
            data.state = "Idle"
            npc.StateFrame = -20
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(mod.Sounds.SpankyShoot, 2, 0, false, math.random(85,105)/100)
            if data.projectile == "Rock" then
                local params = ProjectileParams()
                params.Variant = 9
                npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(16), 0, params)
            elseif data.projectile == "Coal" then
                local rSpider = Isaac.Spawn(33, 11, mod:getRoll(1,3), npc.Position, (target.Position-npc.Position):Resized(20), npc):ToNPC()
                local bounce = -2*0.3
                rSpider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                rSpider.PositionOffset = Vector(0,-15)
                local rData = rSpider:GetData()
                rData.launchedEnemyInfo = {zVel = -1.2, height = -5, collision = -10, vel = (target.Position-npc.Position):Resized(20), landFunc = function()
                    rData.launchedEnemyInfo = {zVel = bounce, vel = rSpider.Velocity, landFunc = function() rData.launchedEnemyInfo = {zVel = bounce*0.5, vel = rSpider.Velocity*0.5} end}
                    rSpider.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end, accel = 0.1}
                rSpider.HitPoints = data.shotHealth
            elseif data.projectile == "Custom" then
                local proj = Isaac.Spawn(data.custom[1], data.custom[2], data.custom[3], npc.Position, (target.Position-npc.Position):Resized(20), npc):ToNPC()
                proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local pData = proj:GetData()
                pData.spankyShot = true
                pData.launchedEnemyInfo = {zVel = -1.2, height=-15, vel = (target.Position-npc.Position):Resized(20), landFunc = function()
                    proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end, additional = function() proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS end, accel = 0.1}
                proj.HitPoints = data.shotHealth
            elseif data.projectile == "Glob" then
                local proj = Isaac.Spawn(data.custom[1], data.custom[2], 1, npc.Position, (target.Position-npc.Position):Resized(20), npc):ToNPC()
                proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local pData = proj:GetData()
                pData.spankyShot = true
                pData.launchedEnemyInfo = {zVel = -1.2, height=-15, vel = (target.Position-npc.Position):Resized(20), landFunc = function()
                    if mod:CheckIndexForGrid(room:GetGridIndex(proj.Position), GridEntityType.GRID_PIT, GridCollisionClass.COLLISION_PIT) then
                        Isaac.Spawn(1000,16,66,proj.Position,Vector.Zero,proj)
                        mod:PlaySound(SoundEffect.SOUND_WAR_LAVA_SPLASH, proj, 1.2, 0.8)
                        proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                        proj:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                        proj.Visible = false
                        pData.plonked = true
                        pData.state = "rollend"
                        pData.airborne = true
                        proj.StateFrame = mod:RandomInt(30,45)
                        proj.Velocity = Vector.Zero
                    else
                        pData.state = "rollstart"
                        proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                        proj.TargetPosition = mod:GetGlobTarget(proj)
                    end
                end, additional = function() proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS end, accel = 0.1}
                mod:FlipSprite(proj:GetSprite(), proj.Position, proj.Position + proj.Velocity)
                proj.HitPoints = data.shotHealth
            else
                local var = 0
                if data.projectile == "CoalSpider" then
                    var = 2
                elseif data.projectile == "TintedRockSpider" then
                    var = 1
                end
                local rSpider = Isaac.Spawn(818, var, mod:getRoll(1,3), npc.Position, (target.Position-npc.Position):Resized(20), npc):ToNPC()
                local bounce = -2*0.3
                rSpider.PositionOffset = Vector(0,-15)
                rSpider.State = 16
                rSpider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local rData = rSpider:GetData()
                rData.launchedEnemyInfo = {zVel = -1.2, height = -5, collision = -10, vel = (target.Position-npc.Position):Resized(20), landFunc = function()
                    rData.launchedEnemyInfo = {zVel = bounce, vel = rSpider.Velocity, landFunc = function() rData.launchedEnemyInfo = {zVel = bounce*0.5, vel = rSpider.Velocity*0.5} end}
                    rSpider.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end, accel = 0.1}
                rSpider.HitPoints = data.shotHealth
            end
        else
            mod:spritePlay(sprite, "Shoot")
        end

        npc.Velocity = Vector.Zero
    end

    if npc:IsDead() then
        npc:PlaySound(mod.Sounds.SpankyDeath, 2, 0, false, 1)
    end
    if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
        if data.pickUp then
            data.pickUp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end
    end
end

function mod:spankyColl(npc, coll)
    if coll:ToNPC() and (coll.Type == 818 or (coll.Type == 33 and coll.Variant == 11)) then
        return true
    elseif coll:ToNPC() and coll:GetData().spankyShot and coll.FrameCount < 10 then
        return true
    end
end