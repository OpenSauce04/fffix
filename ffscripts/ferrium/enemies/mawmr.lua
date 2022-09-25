local mod = FiendFolio
local game = Game()

function mod:mawMrUpdate(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local room = game:GetRoom()

    if npc.SubType == 0 then
        if not data.init then
            local body = Isaac.Spawn(mod.FF.MawMrBody.ID, mod.FF.MawMrBody.Var, mod.FF.MawMrBody.Sub, npc.Position, Vector.Zero, npc):ToNPC()
            body.Parent = npc
            npc.Child = body
            data.state = "Idle"
            data.init = true
        else
            npc.StateFrame = npc.StateFrame+1
        end

        if npc.Velocity.X > 0 then
            sprite.FlipX = false
        else
            sprite.FlipX = true
        end

        if npc.FrameCount % 20 == 0 then
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
            local rand = math.random(35,60)/100
            splat.SpriteScale = Vector(rand, rand)
            if math.random(5) == 1 then
                npc:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 1, 0, false, 1)
            end
        end

        if npc.Child and npc.Child:Exists() and not mod:isStatusCorpse(npc.Child) then
            mod:spritePlay(sprite, "Down")
            if data.state == "Idle" then
                if mod:isScare(npc) then
                    local targVel = (targetpos-npc.Position):Resized(-6)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
                    local targVel = (targetpos-npc.Position):Resized(5)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                else
                    npc.Pathfinder:FindGridPath(targetpos, 0.45, 900, true)
                end
                mod:updateToNPCPosition(npc, npc.Child)

                if npc.Position:Distance(target.Position) < 100 and room:CheckLine(npc.Position, targetpos, 0, 1, false, false) and npc.FrameCount > 30 then
                    data.state = "Launching"
                    npc.Child:GetData().state = "Launching"
                    npc.Child:ToNPC().StateFrame = 0
                    npc.Child:GetData().launchDir = (target.Position-npc.Position):Resized(15)
                    npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 1)
                end
            elseif data.state == "Launching" then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
            end
        else
            npc:Morph(26, 0, 0, -1)
        end
    else
        if not data.init then
            data.state = "Idle"
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            data.dist = 120
            data.init = true
        else
            npc.StateFrame = npc.StateFrame+1
        end
        npc.DepthOffset = -50

        if npc.Parent and npc.Parent:Exists() and not mod:isStatusCorpse(npc.Parent) then
            if npc.Parent:GetData().eternalFlickerspirited  and not data.eternalFlickerspirited then
                data.eternalFlickerspirited = true
                --npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
            end

            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                if npc.Velocity.X > 0 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
                mod:spritePlay(sprite, "MrMawBodyHori")
            else
                mod:spritePlay(sprite, "MrMawBodyVert")
            end

            if data.state == "Idle" then
            elseif data.state == "Launching" then
                if npc.StateFrame < 40 then
                    npc.Velocity = data.launchDir
                    data.launchDir = data.launchDir*0.9
                    if data.launchDir:Length() < 3 then
                        npc.StateFrame = 40
                    end
                else
                    if room:CheckLine(npc.Position, npc.Parent.Position, 0, 1, false, false) then
                        local targVel = (npc.Parent.Position-npc.Position):Resized(9)
                        npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                    else
                        npc.Pathfinder:FindGridPath(npc.Parent.Position, 0.6, 900, true)
                    end

                    if npc.Position:Distance(npc.Parent.Position) < 5 then
                        data.state = "Idle"
                        npc.Parent:GetData().state = "Idle"
                    end
                end
            end

            local dist = npc.Parent.Position - npc.Position
            if dist:Length() > data.dist then
                local distToClose = dist - dist:Resized(data.dist)
                npc.Velocity = npc.Velocity + distToClose*0.5
            end
        else
            npc:Morph(11, 0, 0, -1)
        end
    end
end

function mod:mawMrRender(npc)
    if npc.SubType == 0 and npc.Child and npc:GetData().state == "Launching" then
        local child = npc.Child
        local dist = (120-npc.Child.Position:Distance(npc.Position))/120
        for i=0,10 do
            local extraOffset = Vector.Zero
            extraOffset = Vector(0, 0.45*(i-4.55)^2-10)*dist
            local childPos = child.Position+child.SpriteOffset+child.PositionOffset
            local tPos = Isaac.WorldToScreen(npc.Position+Vector(0,-10)+i*(childPos-npc.Position)/10-extraOffset)
            local sprite = Sprite()
            sprite:Load("gfx/035.010_mr. maw neck.anm2", true)
            sprite:Play("NeckSegment", true)
            sprite:Render(tPos, Vector.Zero, Vector.Zero)
        end
    end
end

function mod:mawMrColl(npc, coll)
    if coll:ToNPC() then
        if npc.SubType == 1 then
            if coll.Type == mod.FF.MawMr.ID and coll.Variant == mod.FF.MawMr.Var then
                return true
            elseif coll.Type == mod.FF.MrPsychicMaw.ID and coll.Variant == mod.FF.MrPsychicMaw.Var then
                return true
            end
        end
    end
end

function mod:mrPsychicMawUpdate(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if npc.SubType == 0 then
        if not data.init then
            local body = Isaac.Spawn(mod.FF.MrPsychicMawHead.ID, mod.FF.MrPsychicMawHead.Var, mod.FF.MrPsychicMawHead.Sub, npc.Position, Vector.Zero, npc):ToNPC()
            body.SpriteOffset = Vector(0, 6)
            body.Parent = npc
            npc.Child = body
            body:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            body.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            body:Update()
            data.state = "Idle"
            mod:ReplaceEnemySpritesheet(npc, "gfx/bosses/warp_zone/psygusher", 0, true)
            mod:updateToNPCPosition(npc, npc.Child)
            data.init = true
        else
            npc.StateFrame = npc.StateFrame+1
        end

        if npc.Child and npc.Child:Exists() and not mod:isStatusCorpse(npc.Child) then
            if data.state == "Idle" then
                if npc.Velocity:Length() > 1 then
                    if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                        if npc.Velocity.X > 0 then
                            sprite.FlipX = false
                        else
                            sprite.FlipX = true
                        end
                        mod:spritePlay(sprite, "WalkHori")
                    else
                        mod:spritePlay(sprite, "WalkVert")
                    end
                else
                    sprite:SetFrame("WalkVert", 0)
                end

                if mod:isScare(npc) then
                    local targVel = (targetpos-npc.Position):Resized(-6)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
                    local targVel = (targetpos-npc.Position):Resized(5)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                else
                    npc.Pathfinder:FindGridPath(targetpos, 0.45, 900, true)
                end
                mod:updateToNPCPosition(npc, npc.Child)

                if npc.Position:Distance(target.Position) < 100 and room:CheckLine(npc.Position, targetpos, 0, 1, false, false) and npc.FrameCount > 30 then
                    data.state = "Launching"
                    npc.Child:GetData().state = "Launching"
                    npc.Child:ToNPC().StateFrame = 0
                    npc.Child:GetData().launchDir = (target.Position-npc.Position):Resized(15)
                    npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 1)
                end
            elseif data.state == "Launching" then
                sprite:SetFrame("WalkVert", 0)
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
            end
        else
            npc.SubType = 2
        end
    elseif npc.SubType == 1 then
        if not data.init then
            data.state = "Idle"
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            data.dist = 120
            local eternalfriend = Isaac.Spawn(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
			eternalfriend.Parent = npc
			eternalfriend:GetData().rotval = 50
			eternalfriend:Update()
            data.fly = eternalfriend
            data.init = true
        else
            npc.StateFrame = npc.StateFrame+1
        end
        npc.DepthOffset = 50

        if npc.FrameCount % 20 == 0 then
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
            local rand = math.random(35,60)/100
            splat.SpriteScale = Vector(rand, rand)
            if math.random(5) == 1 then
                npc:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 1, 0, false, 1)
            end
        end

        if npc.Velocity.X > 0 then
            sprite.FlipX = false
        else
            sprite.FlipX = true
        end

        if npc.Parent and npc.Parent:Exists() and not mod:isStatusCorpse(npc.Parent) then
            if npc.Parent:GetData().eternalFlickerspirited  and not data.eternalFlickerspirited then
                data.eternalFlickerspirited = true
                --npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
            end

            if data.state == "Idle" then
                if npc.FrameCount < 20 then
                    mod:updateToNPCPosition(npc.Parent, npc)
                end

                mod:spritePlay(sprite, "Idle")
            elseif data.state == "Launching" then
                if npc.StateFrame < 40 then
                    npc.Velocity = data.launchDir
                    data.launchDir = data.launchDir*0.92

                    local ang = mod:GetAngleDifference(data.launchDir, (target.Position-npc.Position))
                    if ang < 180 then
                        data.launchDir = data.launchDir:Rotated(-8)
                    else
                        data.launchDir = data.launchDir:Rotated(8)
                    end
                    if data.launchDir:Length() < 3 then
                        npc.StateFrame = 40

                        sprite:Play("Shoot")
                    end
                else
                    if sprite:IsFinished("Shoot") then
                        sprite:Play("Idle")
                    elseif sprite:IsEventTriggered("Shoot") then
                        local params = ProjectileParams()
                        params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
                        npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(8), 0, params)
                        npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1)
                        local poof = Isaac.Spawn(1000, 11, 0, npc.Position, Vector.Zero, npc):ToEffect()
                        local color = Color(0, 0, 0, 0.5, 0.26, 0.05, 0.4)
                        color:SetColorize(1,1,1,1)
                        poof.Color = color
                        poof.DepthOffset = 200
                        poof.SpriteOffset = Vector(0,-10)
                        poof:FollowParent(npc)
                    end

                    if room:CheckLine(npc.Position, npc.Parent.Position, 0, 1, false, false) then
                        local targVel = (npc.Parent.Position-npc.Position):Resized(9)
                        npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                    else
                        npc.Pathfinder:FindGridPath(npc.Parent.Position, 0.6, 900, true)
                    end

                    if npc.Position:Distance(npc.Parent.Position) < 5 then
                        data.state = "Idle"
                        npc.Parent:GetData().state = "Idle"
                    end
                end
            end

            local dist = npc.Parent.Position - npc.Position
            if dist:Length() > data.dist then
                local distToClose = dist - dist:Resized(data.dist)
                npc.Velocity = npc.Velocity + distToClose*0.5
            end
        else
            npc:Morph(26, 2, 0, -1)
            mod.scheduleForUpdate(function()
                for _,fly in ipairs(Isaac.FindByType(96, 0, 0, false, false)) do
                    if fly.Position:Distance(npc.Position) < 20 and fly.FrameCount == 0 then
                        fly:Remove()
                    end
                end
            end, 2)
        end
    elseif npc.SubType == 2 then
        if not data.gush then
            local gush = Isaac.Spawn(1000, 42, 0, npc.Position, Vector.Zero, npc):ToEffect()
            gush.Parent = npc
            gush:FollowParent(npc)
            gush.SpriteOffset = Vector(0,-6*npc.SpriteScale.Y)
            gush.DepthOffset = npc.DepthOffset+5
            gush:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/warp_zone/psygush.png")
            gush:GetSprite():LoadGraphics()
            mod:ReplaceEnemySpritesheet(npc, "gfx/bosses/warp_zone/psygusher", 0, true)
            
            data.targetPosition = mod:FindRandomValidPathPosition(npc, 3, nil, 90)
            data.gush = true
        else
            npc.StateFrame = npc.StateFrame+1
        end

        if npc.Velocity:Length() > 0.1 then
            npc:AnimWalkFrame("WalkHori","WalkVert",0)
        else
            sprite:SetFrame("WalkVert", 0)
        end

        if npc.Position:Distance(data.targetPosition) < 5 or npc.StateFrame > 60 or data.wasFollowing or npc:CollidesWithGrid() then
            data.targetPosition = mod:FindRandomValidPathPosition(npc, 3, nil, 90)+Vector(-10+rng:RandomInt(20),-10+rng:RandomInt(20))
            npc.StateFrame = 0
            data.wasFollowing = nil
        end

        if mod:isScare(npc) then
            local targetvel = (target.Position - npc.Position):Resized(-4)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.2)
        elseif data.targetPosition then
            if room:CheckLine(npc.Position, data.targetPosition, 0, 1, false, false) then
                local targetvel = (data.targetPosition - npc.Position):Resized(2.5)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
            else
                npc.Pathfinder:FindGridPath(data.targetPosition, 0.35, 900, true)
            end
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
        end

        if npc.FrameCount % 26 == 0 then
            local params = ProjectileParams()
            params.FallingAccelModifier = 0.6
            params.FallingSpeedModifier = -10
            params.HeightModifier = 5
            params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
            npc:FireProjectiles(npc.Position, npc.Velocity:Resized(5), 0, params)
            npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
        end

        if npc.FrameCount % 9 == 0 then
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
            splat.SpriteScale = Vector(0.2,0.2)
        end
    end
end

function mod:mrPsychicMawRender(npc)
    if npc.SubType == 0 and npc.Child and npc:GetData().state == "Launching" then
        local child = npc.Child
        local dist = math.max(0, (120-npc.Child.Position:Distance(npc.Position))/120)
        for i=0,10 do
            local extraOffset = Vector.Zero
            extraOffset = Vector(0, 0.45*(i-4.55)^2-10)*dist
            local childPos = child.Position+child.SpriteOffset+child.PositionOffset+Vector(0,-10)
            local tPos = Isaac.WorldToScreen(npc.Position+Vector(0,-15)+i*(childPos-npc.Position)/10-extraOffset)
            local sprite = Sprite()
            sprite:Load("gfx/035.010_mr. maw neck.anm2", true)
            sprite:Play("NeckSegment", true)
            sprite:Render(tPos, Vector.Zero, Vector.Zero)
        end
    end
end