local mod = FiendFolio
local game = Game()

function mod:muskAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local data = npc:GetData()
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.init then
        npc.SplatColor = Color(0,0,0,1,0.1,0.1,0.1) --mod.DarkerWeird
        data.state = "Idle"
        data.wrapTime = 0
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
        data.wrapTime = data.wrapTime+1
    end

    if npc.State == 11 then
		if sprite:IsFinished("Death") then
			npc:Kill()
        else
            mod:spritePlay(sprite, "Death")
        end
    else
        if data.state == "Idle" then
            if npc.StateFrame < 45 then
                mod:spritePlay(sprite, "Idle")
            else
                mod:spritePlay(sprite, "Angry")
            end
    
            if npc.Velocity.X > 0 then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end
    
            --Mostly stolen from muk/drooler to make it accurate
            local vel = mod:reverseIfFear(npc, ((targetpos + target.Velocity*50) - npc.Position):Resized(3))
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.1)
            if npc.Position:Distance(target.Position) < 200 and npc.StateFrame > 80 and not mod:isScareOrConfuse(npc) then
                data.chargeCount = 0
                data.state = "ChargeStart"
                data.anim = "ChargeStart"
                data.finalCharge = nil
                npc.StateFrame = 0
                npc:PlaySound(mod.Sounds.MukChargeUp,0.6,1,false,0.7)
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            end
        elseif data.state == "Charging" then
            if data.finalCharge and room:IsPositionInRoom(npc.Position, 0) then
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            end
            if not data.finalCharge and not data.wrapping and (npc.StateFrame > 50 or data.chargeVel < 5) then
                data.slowing = true
            elseif data.finalCharge and npc:CollidesWithGrid() then
                data.state = "Impact"
                data.charging = nil
                npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
                local wallData = mod:FlailerWall(npc.Position, true)
                data.hitDir = wallData[2]
                if data.hitDir ~= 1 then
                    sprite.FlipX = false
                end
                if mod.GetEntityCount(310, 1, 2302) < 4 then
                    local flesh = Isaac.Spawn(310, 1, 2302, npc.Position, Vector(0,-6):Rotated(90*data.hitDir), npc):ToNPC()
                    flesh:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                end
                --Taken from Cancer Boy code
                for i=1,2 do
                    local f = Isaac.Spawn(mod.FF.Cancerlet.ID, mod.FF.Cancerlet.Var, mod.FF.Cancerlet.Sub, npc.Position+Vector(0,-10):Rotated(90*data.hitDir), Vector(0,-3):Rotated(90*data.hitDir+mod:getRoll(-30,30,rng)), npc)
                    local fd = f:GetData()
                    
                    f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    f:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    f.SpriteOffset = Vector(0, -8)
                    
                    fd.fallspeed = -mod:getRoll(6,12,rng)
                    fd.fallaccel = 1
                    fd.state = "shot"
                    
                    f:Update()
                end
                local params = ProjectileParams()
                params.Variant = 1
                for i=1,5 do
                    params.FallingSpeedModifier = -(6+rng:RandomInt(10))
                    params.FallingAccelModifier = (rng:RandomInt(5)+5)/8
                    params.Scale = (rng:RandomInt(30)+80)/100
                    npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(mod:getRoll(4, 8, rng)):Rotated(mod:getRoll(-20, 20, rng)), 0, params)
                end
                local poof = Isaac.Spawn(1000, 16, 5, npc.Position, Vector.Zero, npc):ToEffect()
                poof.SpriteScale = Vector(0.5, 0.5)
                poof.Color = Color(0,0,0,1,0.1,0.1,0.1) --mod.DarkerWeird
                npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            end
    
            if npc.Velocity.Y > 0 then
                mod:spritePlay(sprite, "ChargeLoopDown")
            else
                mod:spritePlay(sprite, "ChargeLoopUp")
            end
        elseif data.state =="Dizzy" then
            if npc.StateFrame > 40 then
                data.state = "DizzyEnd"
            end
    
            mod:spritePlay(sprite, "DizzyLoop")
    
            local confusePos = mod:confusePos(npc, target.Position, nil, nil, true)
            local vel = mod:reverseIfFear(npc, (confusePos - npc.Position):Resized(3))
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.3)
        elseif data.state == "Impact" then
            local dirs = {
                [1] = "Hori",
                [2] = "Up",
                [3] = "Hori",
                [4] = "Down"
            }
            local animDir = dirs[data.hitDir]
    
            if data.hitDir == 1 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
            
            if sprite:IsFinished("Impact" .. animDir) then
                data.state = "DizzyStart"
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            else
                mod:spritePlay(sprite, "Impact" .. animDir)
            end
    
            npc.Velocity = Vector.Zero
        elseif data.state == "ChargeStart" then
            if sprite:IsFinished(data.anim) then
                data.state = "Charging"
                npc.StateFrame = 0
            elseif sprite:IsEventTriggered("Sound") then
                data.charging = true
                data.chargeDir = (target.Position-npc.Position)
                data.chargeVel = 16
                data.chargeCount = data.chargeCount+1
                if data.chargeCount == 3 then
                    data.finalCharge = true
                end
                npc:PlaySound(mod.Sounds.MukCharge,1,1,false,math.random(100,120)/100)
                if data.chargeDir.Y < 0 then
                    sprite:SetAnimation("ChargeStart2", false)
                    data.anim = "ChargeStart2"
                end
            else
                mod:spritePlay(sprite, data.anim)
            end
    
            if not data.charging then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
            end
        elseif data.state == "DizzyStart" then
            if sprite:IsFinished("DizzyStart") then
                data.state = "Dizzy"
                npc.StateFrame = 0
            else
                mod:spritePlay(sprite, "DizzyStart")
            end
    
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
        elseif data.state == "DizzyEnd" then
            if sprite:IsFinished("DizzyEnd") then
                data.state = "Idle"
                npc.StateFrame = 0
            elseif sprite:IsEventTriggered("Sound") then
                npc:PlaySound(mod.Sounds.MukLaugh,1,1,false,1)
            else
                mod:spritePlay(sprite, "DizzyEnd")
            end
    
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
        end
    
        if data.charging then
            if data.slowing then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)
                if npc.Velocity:Length() < 3 then
                    data.state = "ChargeStart"
                    data.anim = "ChargeStart"
                    data.charging = nil
                    data.slowing = nil
                end
            else
                npc.Velocity = mod:Lerp(npc.Velocity, data.chargeDir:Resized(data.chargeVel), 0.35)
                if not data.wrappedX then
                    if npc.Position.X < room:GetTopLeftPos().X-30 then
                        data.wrapTime = 0
                        data.wrapping = true
                    elseif npc.Position.X > room:GetBottomRightPos().X+30 then
                        data.wrapTime = 0
                        data.wrapping = true
                    end
                end
                if not data.wrappedY then
                    if npc.Position.Y < room:GetTopLeftPos().Y-30 then
                        data.wrapTime = 0
                        data.wrapping = true
                    elseif npc.Position.Y > room:GetBottomRightPos().Y+30 then
                        data.wrapTime = 0
                        data.wrapping = true
                    end
                end
            end
            --[[if data.chargeVel > 0 and not data.finalCharge then
                data.chargeVel = data.chargeVel*0.975
            end]]
    
            if npc.Velocity.X > 0 then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end
        end

        if data.wrapping then
            local leftX = room:GetTopLeftPos().X
            local rightX = room:GetBottomRightPos().X
            local bottomY = room:GetBottomRightPos().Y
            local topY = room:GetTopLeftPos().Y
    
            if not data.wrappedX and not data.wrappedY then
                npc.Color = Color.Lerp(npc.Color, Color(npc.Color.R, npc.Color.G, npc.Color.B, 0, npc.Color.RO, npc.Color.GO, npc.Color.BO), 0.15)
            end
            if npc.Color.A < 0.05 or data.wrapTime > 10 then
                if not data.wrappedX then
                    if npc.Position.X < leftX then
                        data.wrappedX = true
                        npc.Position = Vector(rightX+30, npc.Position.Y)
                    elseif npc.Position.X > rightX then
                        data.wrappedX = true
                        npc.Position = Vector(leftX-30, npc.Position.Y)
                    end
                end
                if not data.wrappedY then
                    if npc.Position.Y < topY then
                        data.wrappedY = true
                        npc.Position = Vector(npc.Position.X, bottomY+30)
                    elseif npc.Position.Y > bottomY then
                        data.wrappedY = true
                        npc.Position = Vector(npc.Position.X, topY-30)
                    end
                end
            end
    
            if npc.Position.Y > topY and npc.Position.Y < bottomY then
                data.wrappedY = nil
            end
            if npc.Position.X > leftX and npc.Position.X < rightX then
                data.wrappedX = nil
            end
    
            if room:IsPositionInRoom(npc.Position, 0) then
                data.wrapTime = 0
                data.wrapping = nil
                data.wrappedX = nil
                data.wrappedY = nil
            end

            if data.wrapTime > 50 or npc.Position:Distance(room:GetCenterPos()) > 1500 then
                data.wrapping = nil
                data.wrappedX = nil
                data.wrappedY = nil
            end
        end
    
        if npc.Color.A < 1 then
            if not data.wrapping then
                npc.Color = Color.Lerp(npc.Color, Color(npc.Color.R, npc.Color.G, npc.Color.B, 1, npc.Color.RO, npc.Color.GO, npc.Color.BO), 0.6)
            elseif data.wrappedX or data.wrappedY then
                npc.Color = Color.Lerp(npc.Color, Color(npc.Color.R, npc.Color.G, npc.Color.B, 1, npc.Color.RO, npc.Color.GO, npc.Color.BO), 0.6)
            end
        end
    end
end