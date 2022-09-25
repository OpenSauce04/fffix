local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--This is absolutely shit and old code,
--please don't judge me too much for it
--eventually I should probably try and
--recode these dudes but I've yet to
--really get around to it.

--Meatwad, Slag and Pox
function mod:conkerAI(npc, subtype, variant)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

    local posdist = 20
    if variant == 33 or variant == mod.FF.Outlier.Var then
        posdist = 30
    end

    if not d.init then
        d.init = true
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        if variant == 31 then
            npc.SplatColor = mod.ColorDankBlackReal
        elseif variant == 33 then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        elseif variant == mod.FF.GrilledMeatwad.Var then
            npc.SplatColor = mod.ColorGrilled
        end
        d.npcstate = "Init"
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.FallState == 1 and npc.FrameCount > 5 then
        
        if variant == 32 then
            if npc.FrameCount % --[[(#mod.creepSpawnerCount)]] 5 == 0 and npc.FrameCount > 5 then
                local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
                creep:SetTimeout(30)
                creep:Update();
                local projectile = Isaac.Spawn(9,0,0,npc.Position,Vector.Zero,npc):ToProjectile()
                projectile:GetData().Wobblin = true
                projectile.FallingAccel = -0.15
                projectile.Scale = 1.3
                projectile.Parent = npc
                Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc)
                npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 0.8, 0, false, 1.2)
            end
        elseif variant == mod.FF.GrilledMeatwad.Var then
            --local fire = Isaac.Spawn(1000,7005, 0, npc.Position + RandomVector() * mod:RandomInt(0,20), Vector.Zero, npc):ToEffect()
            --fire:GetData().timer = 20
            --fire.SpriteScale = Vector(0.5,0.5)
            --fire:Update()
            if npc.FrameCount % 10 == 0 and npc.FrameCount > 5 then
                local fire = Isaac.Spawn(33,10,0, npc.Position, Vector.Zero, npc)
                fire.HitPoints = fire.HitPoints / (1.5 + (0.25 * mod:RandomInt(0,4)))
                fire:Update()
            end
        end
    end

    if subtype == 0 then

        if d.npcstate == "Init" then
            local pos = mod.FindClosestVertRock(npc)
            d.FallState = 1
            if pos.Y < npc.Position.Y then
                d.npcstate = "FallUp"
            else
                d.npcstate = "FallDown"
            end

        ------------------------------------------------------------------------------------------------------------

        elseif d.npcstate == "FallUp" then

            if d.FallState == 1 then

                if not sprite:IsPlaying("JumpDown") then
                    sprite:Play("JumpDown", true)
                    d.move = -4
                else
                    d.move = d.move * 1.2
                    d.move = math.max(d.move,-posdist)
                    npc.Velocity = Vector(0, d.move)
                end

                local posgrid = room:GetLaserTarget(npc.Position, Vector(0,-1))
                if npc.Position:Distance(posgrid) < posdist then
                    npc.StateFrame = 0
                    npc.Velocity = nilvector
                    d.FallState = 2
                    mod:spritePlay(sprite, "LandUp")
                    if npc.Variant == mod.FF.Outlier.Var then
                        npc:PlaySound(SoundEffect.SOUND_GOOATTACH0,1,2,false,1)
                    else
                        npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1.4)
                    end
                    if variant == 31 then
                        if not d.first then
                            d.first = true
                        else
                            local params = ProjectileParams()
                            params.Color = mod.ColorDankBlackReal
                            for i = -90, 90, 45 do
                                npc:FireProjectiles(npc.Position + Vector(0,-3), Vector(0,8):Rotated(i) , 0, params)
                            end
                        end
                    end
                end

            elseif d.FallState == 2 then
                if sprite:IsFinished("LandUp") then
                    d.npcstate = "IdleUp"
                    mod:spritePlay(sprite, "IdleUp")
                    d.FallState = nil
                else
                    mod:spritePlay(sprite, "LandUp")
                end
            end

        elseif d.npcstate == "FallDown" then

            if d.FallState == 1 then
                if not sprite:IsPlaying("JumpUp") then
                    sprite:Play("JumpUp", true)
                    d.move = 4
                else
                    d.move = d.move * 1.2
                    d.move = math.min(d.move,posdist)
                    npc.Velocity = Vector(0, d.move)
                end

                local posgrid = room:GetLaserTarget(npc.Position, Vector(0,1))
                if npc.Position:Distance(posgrid) < posdist then
                    npc.StateFrame = 0
                    npc.Velocity = nilvector
                    d.FallState = 2
                    mod:spritePlay(sprite, "LandDown")
                    if npc.Variant == mod.FF.Outlier.Var then
                        npc:PlaySound(SoundEffect.SOUND_GOOATTACH0,1,2,false,1)
                    else
                        npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1.4)
                    end
                    if variant == 31 then
                        if not d.first then
                            d.first = true
                        else
                            local params = ProjectileParams()
                            params.Color = mod.ColorDankBlackReal
                            for i = -90, 90, 45 do
                                npc:FireProjectiles(npc.Position + Vector(0,15), Vector(0,-8):Rotated(i) , 0, params)
                            end
                        end
                    end
                end
            elseif d.FallState == 2 then
                if sprite:IsFinished("LandDown") then
                    d.npcstate = "IdleDown"
                    mod:spritePlay(sprite, "IdleDown")
                    d.FallState = nil
                else
                    mod:spritePlay(sprite, "LandDown")
                end
            end

        ------------------------------------------------------------------------------------------------------------

        elseif d.npcstate == "IdleUp" then
            if variant == 33 then
                npc.Velocity = nilvector
            else

                local SomeValueVariableNameIDC = mod:randomVecConfuse(npc,mod:runIfFear(npc, (target.Position - npc.Position):Normalized(), 3))
                d.targetVel = Vector(SomeValueVariableNameIDC.X, 0)
                npc.Velocity = mod:Lerp(npc.Velocity, d.targetVel,0.2)
            end

            local posgrid = room:GetLaserTarget(npc.Position, Vector(0,-1))
            if npc.Position:Distance(posgrid) > posdist then
                d.FallState = 1
                d.npcstate = "FallUp"
            elseif d.FallState == 0 then
                if sprite:IsFinished("SquishUp") then
                    d.FallState = 1
                    d.npcstate = "FallDown"
                    mod:PoxProjectileClearing(npc)
                else
                    mod:spritePlay(sprite, "SquishUp")
                end
            else
                if npc.StateFrame > 30 then
                    local dif = math.sqrt(math.abs(npc.Position.Y - target.Position.Y))*2.5
                    if (room:CheckLine(target.Position+target.Velocity*dif,npc.Position,3,900,false,false) or room:CheckLine(target.Position,npc.Position,3,900,false,false)) and not (mod:isConfuse(npc) or mod:isScare(npc)) then
                        local check = npc.Position.X - (target.Position.X+target.Velocity.X*dif)
                        local check2 = npc.Position.X - (target.Position.X+target.Velocity.X*dif)
                        if math.abs(check) < 25 or math.abs(check2) < 25 then
                            d.FallState = 0
                        end
                    end
                end
            end

        elseif d.npcstate == "IdleDown" then
            if variant == 33 then
                npc.Velocity = nilvector
            else
                local SomeValueVariableNameIDC = mod:randomVecConfuse(npc,mod:runIfFear(npc, (target.Position - npc.Position):Normalized(), 3))
                d.targetVel = Vector(SomeValueVariableNameIDC.X, 0)
                npc.Velocity = mod:Lerp(npc.Velocity, d.targetVel,0.2)
            end

            local posgrid = room:GetLaserTarget(npc.Position, Vector(0,1))
            if npc.Position:Distance(posgrid) > posdist then
                d.FallState = 1
                d.npcstate = "FallDown"
            elseif d.FallState == 0 then
                if sprite:IsFinished("SquishDown") then
                    d.FallState = 1
                    d.npcstate = "FallUp"
                    mod:PoxProjectileClearing(npc)
                else
                    mod:spritePlay(sprite, "SquishDown")
                end
            else
                if npc.StateFrame > 30 then
                    if variant == 33 then
                        d.FallState = 0
                    else
                        local dif = math.sqrt(math.abs(npc.Position.Y - target.Position.Y))*2.5
                        if (room:CheckLine(target.Position+target.Velocity*dif,npc.Position,3,900,false,false) or room:CheckLine(target.Position,npc.Position,3,900,false,false)) and not (mod:isConfuse(npc) or mod:isScare(npc)) then
                            local check = npc.Position.X - (target.Position.X+target.Velocity.X*dif)
                            local check2 = npc.Position.X - (target.Position.X+target.Velocity.X*dif)
                            if math.abs(check) < 25 or math.abs(check2) < 25 then
                                d.FallState = 0
                            end
                        end
                    end
                end
            end
        end

    ------------------------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------HORIZONTAL VARIANT---------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------

    else

    if d.npcstate == "Init" then
            local pos = mod.FindClosestHoriRock(npc)
            d.FallState = 1
            if pos.X < npc.Position.X then
                d.npcstate = "FallRight"
            else
                d.npcstate = "FallLeft"
            end

        ------------------------------------------------------------------------------------------------------------

        elseif d.npcstate == "FallRight" then

            if d.FallState == 1 then

                if not sprite:IsPlaying("JumpRight") then
                    sprite:Play("JumpRight", true)
                    d.move = -4
                else
                    d.move = d.move * 1.2
                    d.move = math.max(d.move,-posdist)
                    npc.Velocity = Vector(d.move, 0)
                end

                local posgrid = room:GetLaserTarget(npc.Position, Vector(-1,0))
                if npc.Position:Distance(posgrid) < posdist then
                    npc.StateFrame = 0
                    npc.Velocity = nilvector
                    d.FallState = 2
                    mod:spritePlay(sprite, "LandLeft")
                    if npc.Variant == mod.FF.Outlier.Var then
                        npc:PlaySound(SoundEffect.SOUND_GOOATTACH0,1,2,false,1)
                    else
                        npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1.4)
                    end
                    if variant == 31 then
                        if not d.first then
                            d.first = true
                        else
                            local params = ProjectileParams()
                            params.Color = mod.ColorDankBlackReal
                            for i = -90, 90, 45 do
                                npc:FireProjectiles(npc.Position + Vector(0,15), Vector(8,0):Rotated(i) , 0, params)
                            end
                        end
                    end
                end

            elseif d.FallState == 2 then
                if sprite:IsFinished("LandLeft") then
                    d.npcstate = "IdleRight"
                    mod:spritePlay(sprite, "IdleLeft")
                    d.FallState = nil
                else
                    mod:spritePlay(sprite, "LandLeft")
                end
            end

        elseif d.npcstate == "FallLeft" then

            if d.FallState == 1 then
                if not sprite:IsPlaying("JumpLeft") then
                    sprite:Play("JumpLeft", true)
                    d.move = 4
                else
                    d.move = d.move * 1.2
                    d.move = math.min(d.move,posdist)
                    npc.Velocity = Vector(d.move, 0)
                end

                local posgrid = room:GetLaserTarget(npc.Position, Vector(1,0))
                if npc.Position:Distance(posgrid) < posdist then
                    npc.StateFrame = 0
                    npc.Velocity = nilvector
                    d.FallState = 2
                    mod:spritePlay(sprite, "LandRight")
                    if npc.Variant == mod.FF.Outlier.Var then
                        npc:PlaySound(SoundEffect.SOUND_GOOATTACH0,1,2,false,1)
                    else
                        npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1.4)
                    end
                    if variant == 31 then
                        if not d.first then
                            d.first = true
                        else
                            local params = ProjectileParams()
                            params.Color = mod.ColorDankBlackReal
                            for i = -90, 90, 45 do
                                npc:FireProjectiles(npc.Position + Vector(0,15), Vector(-8,0):Rotated(i) , 0, params)
                            end
                        end
                    end
                end
            elseif d.FallState == 2 then
                if sprite:IsFinished("LandRight") then
                    d.npcstate = "IdleLeft"
                    mod:spritePlay(sprite, "IdleRight")
                    d.FallState = nil
                else
                    mod:spritePlay(sprite, "LandRight")
                end
            end

        ------------------------------------------------------------------------------------------------------------

        elseif d.npcstate == "IdleRight" then
            local SomeValueVariableNameIDC = mod:randomVecConfuse(npc,mod:runIfFear(npc, (target.Position - npc.Position):Normalized(), 3))
            d.targetVel = Vector(0, SomeValueVariableNameIDC.Y)
            npc.Velocity = mod:Lerp(npc.Velocity, d.targetVel,0.2)

            local posgrid = room:GetLaserTarget(npc.Position, Vector(-1,0))
            if npc.Position:Distance(posgrid) > posdist then
                d.FallState = 1
                d.npcstate = "FallRight"
            elseif d.FallState == 0 then
                if sprite:IsFinished("SquishLeft") then
                    d.FallState = 1
                    d.npcstate = "FallLeft"
                    mod:PoxProjectileClearing(npc)
                else
                    mod:spritePlay(sprite, "SquishLeft")
                end
            else
                if npc.StateFrame > 30 then
                    local dif = math.sqrt(math.abs(npc.Position.X - target.Position.X))*3.4
                    if (room:CheckLine(target.Position+target.Velocity*dif,npc.Position,3,900,false,false) or room:CheckLine(target.Position,npc.Position,3,900,false,false)) and not (mod:isConfuse(npc) or mod:isScare(npc)) then
                        local check = npc.Position.Y - (target.Position.Y+target.Velocity.Y*dif)
                        local check2 = npc.Position.Y - (target.Position.Y+target.Velocity.Y*dif)
                        if math.abs(check) < 25 or math.abs(check2) < 25 then
                            d.FallState = 0
                        end
                    end
                end
            end

        elseif d.npcstate == "IdleLeft" then
            local SomeValueVariableNameIDC = mod:randomVecConfuse(npc,mod:runIfFear(npc, (target.Position - npc.Position):Normalized(), 3))
            d.targetVel = Vector(0, SomeValueVariableNameIDC.Y)
                npc.Velocity = mod:Lerp(npc.Velocity, d.targetVel,0.2)

            local posgrid = room:GetLaserTarget(npc.Position, Vector(1,0))
            if npc.Position:Distance(posgrid) > posdist then
                d.FallState = 1
                d.npcstate = "FallLeft"
            elseif d.FallState == 0 then
                if sprite:IsFinished("SquishRight") then
                    d.FallState = 1
                    d.npcstate = "FallRight"
                    mod:PoxProjectileClearing(npc)
                else
                    mod:spritePlay(sprite, "SquishRight")
                end
            else
                if npc.StateFrame > 30 then
                    local dif = math.sqrt(math.abs(npc.Position.X - target.Position.X))*3.4
                    if (room:CheckLine(target.Position+target.Velocity*dif,npc.Position,3,900,false,false) or room:CheckLine(target.Position,npc.Position,3,900,false,false)) and not (mod:isConfuse(npc) or mod:isScare(npc)) then
                        local check = npc.Position.Y - (target.Position.Y+target.Velocity.Y*dif)
                        local check2 = npc.Position.Y - (target.Position.Y+target.Velocity.Y*dif)
                        if math.abs(check) < 25 or math.abs(check2) < 25 then
                            d.FallState = 0
                        end
                    end
                end
            end
        end
    end
    if npc.Variant == mod.FF.Outlier.Var then
        if d.npcstate == "IdleUp" or d.npcstate == "IdleDown" or d.npcstate == "IdleRight" or d.npcstate == "IdleLeft" then
            if npc.StateFrame >= 60 and mod:RandomInt(1,5) == 5 then
                mod:TryOutlierTeleport(npc, target)
            end
        end
    end
end

function mod:meatwadHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) and not game:GetRoom():HasWater() then
        if npc.Variant ~= mod.FF.GrilledMeatwad.Var then
            npc = npc:ToNPC()
            local sprite = npc:GetSprite()
            local anim = sprite:GetAnimation()
            npc:Morph(npc.Type, mod.FF.GrilledMeatwad.Var, npc.SubType, npc:GetChampionColorIdx())
            npc.SplatColor = mod.ColorGrilled
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
            mod:spritePlay(sprite, anim)
        end
        if not mod:IsPlayerDamage(source) then
            return false
        end
    end
end

function mod:TryOutlierTeleport(npc, target)
    local room = game:GetRoom()
    local targetpos = target.Position
    npc.StateFrame = 20
    if room:GetGridCollisionAtPos(target.Position) < 2 then
        local potentialspots1 = {}
        local potentialspots2 = {}
        for i = 90, 360, 90 do
            local teleportspot = room:GetLaserTarget(targetpos, Vector(1,0):Rotated(i))
            if teleportspot:Distance(targetpos) > 80 then
                local isolated = true
                for _, outlier in pairs(Isaac.FindByType(mod.FF.Outlier.ID, mod.FF.Outlier.Var, -1, false, false)) do
                    if outlier.Position:Distance(teleportspot) < 50 then
                        isolated = false
                    end
                end
                if isolated then
                    table.insert(potentialspots1, {["Pos"] = teleportspot, ["Angle"] = i})
                else
                    table.insert(potentialspots2, {["Pos"] = teleportspot, ["Angle"] = i})
                end
                
            end 
        end
        local destination = mod:GetRandomElem(potentialspots1)
        if not destination then
            destination = mod:GetRandomElem(potentialspots2)
        end
        if destination then
            local d = npc:GetData()
            local sprite = npc:GetSprite()
            local angle = destination.Angle
            if angle == 90 then
                d.npcstate = "IdleDown"
                npc.SubType = 0
            elseif angle == 180 then
                d.npcstate = "IdleRight"
                npc.SubType = 1
            elseif angle == 270 then
                d.npcstate = "IdleUp"
                npc.SubType = 0
            elseif angle == 360 then
                d.npcstate = "IdleLeft"
                npc.SubType = 1
            end
            --I don't get it either
            if d.npcstate == "IdleRight" then
                mod:spritePlay(sprite, "IdleLeft")
            elseif d.npcstate == "IdleLeft" then
                mod:spritePlay(sprite, "IdleRight")
            else
                mod:spritePlay(sprite, d.npcstate)
            end
            d.FallState = nil
            local p = Isaac.Spawn(1000, 7020, 1, npc.Position, nilvector, nil)
            local pcolor = Color(1,1,1,1,0,0,0)
            pcolor:SetColorize(1, 0.3, 1, 1)
            p.Color = pcolor
            p:GetSprite().Offset = Vector(0, -14)
            p:Update()
            npc.Position = destination.Pos + Vector(15,0):Rotated(angle+180)
            npc:SetColor(Color(0,0,0,1,255 / 255,80 / 255,255 / 255), 5, 999, true, false)
            npc:PlaySound(mod.Sounds.CrosseyeAppear,1.5,0,false,math.random(20,25)/10)
        end
    end
end

function mod:PoxProjectileClearing(npc)
    if npc.Variant == mod.FF.Pox.Var then
        for _, projectile in pairs(Isaac.FindByType(9,0,0,false,false)) do
            if projectile.Parent and projectile.Parent.InitSeed == npc.InitSeed then
                projectile:ToProjectile().FallingAccel = 1
                projectile:GetData().Wobblin = false
            end
        end
    end
end