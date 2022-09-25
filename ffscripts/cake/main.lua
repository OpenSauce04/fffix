local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--cake enemies ai functions
local enemies369 = {
[mod.FF.Trashbagger.Var] = function(npc, data, sprite) -- Trashbagger and Stomy
    local r = npc:GetDropRNG()
    local path = npc.Pathfinder
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)

    if npc.FrameCount % (#mod.creepSpawnerCount * 4 - 1) == 1 and npc.SubType == 1 then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, npc.Position, Vector(0,0), npc):ToEffect();
        creep:Update()
    end

    if not data.init then
        data.state = "idle"
        if npc.SubType == 2 then
            npc.SplatColor = mod.ColorBrowniePoop
        end
        data.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if data.state == "idle" then
        npc:AnimWalkFrame("WalkHori", "WalkVert", 0.3)

        if mod:isScare(npc) then
            local targetvel = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvel = (targetpos - npc.Position):Resized(3)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        else
            path:FindGridPath(targetpos, 0.4, 900, true)
        end
        if npc.FrameCount % 8 == 0 and math.random(25) == math.random(25) and not mod:isScareOrConfuse(npc) and npc.StateFrame > 30 then
            data.state = "shoot"
            sprite:Play("Attack01", false)
        end
        if npc.StateFrame > 30 and npc.Position:Distance(targetpos) - target.Size <= 90 and not mod:isScareOrConfuse(npc) then
            data.state = "shoot"
            sprite:Play("Attack01", false)
        end

    elseif data.state == "shoot" then
        --sprite:Play("Attack01", false)
        npc.Velocity = npc.Velocity * 0.7

        if sprite:GetFrame() == 55 then
            data.state = "idle"
        end
    end

    if sprite:IsPlaying('Attack01') or sprite:IsPlaying('Attack02') then
        local params = ProjectileParams()
            if sprite:IsEventTriggered('Shoot') then
                local projspeed = 8
                params.FallingSpeedModifier = -20+math.random(10)
                params.FallingAccelModifier = 2
                params.HeightModifier = -25
                params.Variant = 3
                local targcoord = mod:intercept(npc, target, projspeed)
                local shootvec = targcoord:Normalized() * projspeed

                if sprite:IsPlaying('Attack01') and npc.SubType ~= 2 then
                    npc:FireProjectiles(npc.Position, shootvec, 0, params)
                else if sprite:IsPlaying('Attack01') and npc.SubType == 2 then
                    local vel = ((target.Position - npc.Position) / 30):Rotated(-45 + 45)
                    if vel:Length() > 13 then
                        vel = vel:Resized(13)
                    end
                    sfx:Play(SoundEffect.SOUND_ANGRY_GURGLE, 1.0, 0, false, 1.5);
                    sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF, 1.5, 0, false, 1.5);
                    local rand = r:RandomFloat()
                    local bombshot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, vel + npc.Velocity, npc):ToProjectile()
                    local bombd = bombshot:GetData()
                    bombshot.SpawnerEntity = npc
                    bombshot.FallingSpeed = -25
                    bombshot.FallingAccel = 1.2
                    bombshot.Scale = 1
                    bombshot.SpawnerEntity = npc
                    bombd.SpawnerEntity = npc
                    bombd.projType = "thrownbomb"
                    if npc.SubType == 2 then bombd.poopBomb = true end
                end
            end
        end
        if sprite:IsPlaying('Attack01') and npc.SubType ~= 2 then
            for i = 1, 30 do
                if sprite:GetFrame() == i+1 and sprite:GetFrame() >= 17 then
                    local rand = math.random(1,8)
                    params.FallingSpeedModifier = -1.2 * (math.random(15, 15) + math.random());
                    params.FallingAccelModifier = 2
                    params.HeightModifier = -25
                    params.VelocityMulti = ((math.random(2,3) * 0.5) * 0.1) + (math.random());
                    params.Variant = mod.TrashbaggerTable[math.random(1, #mod.TrashbaggerTable)]
                    if npc.SubType == 2 then
                        params.Variant = 3
                    end
                    npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(30-40+rand*80) + nilvector, 0, params)
                    sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.7, 0, false, 1);
                end
            end
        end
    end

    if npc:IsDead() then
        if npc.SubType < 2 then
            --[[for i = 0, mod:RandomInt(0,1) do
                mod.ThrowMaggot(npc.Position, RandomVector():Resized(math.random(2, 5)), -14, math.random(-15, -10), npc)
            end]]
            local extraflies = mod:RandomInt(0, npc.SubType + 1)
            mod:TrashbaggerUnboxing(npc, extraflies)
        else
            sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1.5, 0, false, 1.5)
        end
    end
end,
[mod.FF.Pipeneck.Var] = function(npc, data, sprite)
    local r = npc:GetDropRNG()
    local path = npc.Pathfinder
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.init then
        data.state = "idle"
        data.init = true
        data.directionSplash = Vector.Zero
        data.directionSpread = Vector.Zero
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    local velx = npc.Velocity.X
    local vely = npc.Velocity.Y

    --[[
    if math.abs(velx) > math.abs(vely) then
        if velx > 0 then
            data.dir = "Right"
        else
            data.dir = "Left"
        end
    else
        if vely > 0 then
            data.dir = "Down"
        else
            data.dir = "Up"
        end
    end
    ]]--

    if math.abs(target.Position.Y - npc.Position.Y) > math.abs(target.Position.X - npc.Position.X) then
        if target.Position.Y > npc.Position.Y then
            data.dir = "Down"
        else
            data.dir = "Up"
        end
    else
        if target.Position.X > npc.Position.X then
            data.dir = "Right"
        else
            data.dir = "Left"
        end
    end

    if data.state == "idle" then
        npc:AnimWalkFrame("WalkHori", "WalkVert", 0.3)

        if mod:isScare(npc) then
            local targetvel = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvel = (targetpos - npc.Position):Resized(3)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        else
            path:FindGridPath(targetpos, 0.4, 900, true)
        end
        if npc.FrameCount % 8 == 0 and math.random(25) == math.random(25) and not mod:isScareOrConfuse(npc) and npc.StateFrame > 30 and data.state ~= "shoot"  then
            --print("randomshot")
            data.state = "shoot"
            if data.dir == "Up" then
                sprite:Play("SlamUp", false)
                data.directionSplash = Vector(0,-70)
            elseif data.dir == "Down" then
                sprite:Play("SlamDown", false)
                data.directionSplash = Vector(0,90)
            elseif data.dir == "Left" then
                npc.FlipX = true
                sprite:Play("SlamHori", true)
                data.directionSplash = Vector(-100,0)
            elseif data.dir == "Right" then
                npc.FlipX = false
                sprite:Play("SlamHori", true)
                data.directionSplash = Vector(100,0)
            end
        end
        if npc.StateFrame > 30 and npc.Position:Distance(targetpos) - target.Size <= 120 and not mod:isScareOrConfuse(npc) and data.state ~= "shoot" then
            data.state = "shoot"
            if data.dir == "Up" then
                sprite:Play("SlamUp", false)
                data.directionSplash = Vector(0,-70)
                data.directionSplash = Vector(0,-70)
            elseif data.dir == "Down" then
                sprite:Play("SlamDown", false)
                data.directionSplash = Vector(0,90)
            elseif data.dir == "Left" then
                npc.FlipX = true
                sprite:Play("SlamHori", false)
                data.directionSplash = Vector(-100,0)
            elseif data.dir == "Right" then
                npc.FlipX = false
                sprite:Play("SlamHori", false)
                data.directionSplash = Vector(100,0)
            end
        end
    elseif data.state == "shoot" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:GetFrame() == 55 then
            data.state = "idle"
        end
    end

    if sprite:IsPlaying('SlamDown') or sprite:IsPlaying('SlamUp') or sprite:IsPlaying('SlamHori')  then
        local params = ProjectileParams()
        npc.StateFrame = 0
        if sprite:IsEventTriggered('Shoot') then
            for i = 1, 30 do
                local rand = math.random(1,8)
                params.FallingSpeedModifier = -1 * (math.random(5, 20) + math.random());
                params.FallingAccelModifier = 1.5 + math.random()
                params.VelocityMulti = ((math.random(3,6) * 0.5) * 0.1)+0.5;
                --print(params.VelocityMulti)
                params.Variant = 3
                npc:FireProjectiles(npc.Position+data.directionSplash, Vector(0,8):Rotated(rand*80) + nilvector, 0, params)
                sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.7, 0, false, 1);
                sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 0.8)
            end
        
            local hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, npc.Position+data.directionSplash, Vector.Zero, npc)
            local hdata = hitbox:GetData()
            hdata.PositionOffset = data.directionSplash
            hdata.FixToSpawner = true
            hdata.Relay = true
            hitbox.CollisionDamage = 1
            hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        
            local hitbox2 = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, npc.Position+(data.directionSplash/2), Vector.Zero, npc)
            local hdata2 = hitbox2:GetData()
            hdata2.Rotation = data.directionSplash:GetAngleDegrees()
            hdata2.Width = 40
            hdata2.Height = 6
            hitbox2.CollisionDamage = 1
            hitbox2.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            hitbox2.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        
            data.Hitbox = hitbox
            data.Hitbox2 = hitbox2
        elseif sprite:IsEventTriggered("Lift") then
            data.Hitbox:Remove()
            data.Hitbox2:Remove()
        end
    end
end,
[mod.FF.Cappin.Var] = function(npc, data, sprite)
    local data = npc:GetData()
    local r = npc:GetDropRNG()
    local target = npc:GetPlayerTarget()
    local path = npc.Pathfinder
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local sprite = npc:GetSprite()

    if not data.init then
        data.state = "idle"
        data.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    local velx = npc.Velocity.X
    local vely = npc.Velocity.Y

    if data.state == "idle" then

        if math.abs(velx) > math.abs(vely) then
            if velx > 0 then
                npc.FlipX = false
                data.dir = "Right"
                sprite:Play("WalkHori")
            else
                npc.FlipX = true
                data.dir = "Left"
                sprite:Play("WalkHori")
            end
        else
            if vely > 0 then
                data.dir = "Down"
                sprite:Play("WalkDown")
            else
                data.dir = "Up"
                sprite:Play("WalkUp")
            end
        end

        if math.abs(target.Position.Y - npc.Position.Y) > math.abs(target.Position.X - npc.Position.X) then
            if target.Position.Y > npc.Position.Y then
                data.chargeTo = "Down"
            else
                data.chargeTo = "Up"
            end
        else
            if target.Position.X > npc.Position.X then
                data.chargeTo = "Right"
            else
                data.chargeTo = "Left"
            end
        end

        if npc.StateFrame < 3 then
            sprite:Play("Idle")
        end

        data.newhome = data.newhome or mod:FindRandomValidPathPosition(npc)
        local pdist = target.Position:Distance(npc.Position)
        if mod:isScare(npc) then
            npc.Velocity = (npc.Position - target.Position):Resized(math.max(1, 5 - pdist/50))
            data.newhome = nil
        elseif npc.Position:Distance(data.newhome) < 5 or npc.Velocity:Length() < 1 or (mod:isConfuse(npc) and npc.FrameCount % 30 == 1) then
            data.newhome = mod:FindRandomValidPathPosition(npc)
            path:FindGridPath(data.newhome, 0.4, 900, true)
        else
            path:FindGridPath(data.newhome, 0.4, 900, true)
        end
        if npc.StateFrame > 30 and npc.Position:Distance(targetpos) - target.Size <= 160 and mod:getCardinalCloseness(target.Position, npc.Position) <= 20 then
            data.state = "charge"
            if data.chargeTo == "Up" then
                sprite:Play("ChargeUp", false)
            elseif data.chargeTo == "Down" then
                sprite:Play("ChargeDown", false)
            elseif data.chargeTo == "Left" then
                npc.FlipX = true
                sprite:Play("ChargeHori", false)
            elseif data.chargeTo == "Right" then
                npc.FlipX = false
                sprite:Play("ChargeHori", false)
            end
            data.chargepos = target.Position
            npc.StateFrame = 0
            local targetpos = mod:randomConfuse(npc, target.Position)
            npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(16))
            npc:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR,0.7,0,false,1.6)
        end
    end

    if data.state == "charge" then
        if data.chargeTo == "Up" then
            npc.Velocity = Vector(0,-6)
        elseif data.chargeTo == "Down" then
            npc.Velocity = Vector(0,6)
        elseif data.chargeTo == "Left" then
            npc.Velocity = Vector(-6,0)
        elseif data.chargeTo == "Right" then
            npc.Velocity = Vector(6,0)
        end
        npc.Velocity = npc.Velocity:Resized(6)
        if npc.StateFrame == 40 or npc:CollidesWithGrid() then
            npc.Velocity = npc.Velocity *0.2
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP,0.8,0,false,1.5)
            data.state = "trip"
            if data.chargeTo == "Up" then
                sprite:Play("TripUp", false)
            elseif data.chargeTo == "Down" then
                sprite:Play("TripDown", false)
            elseif data.chargeTo == "Left" then
                npc.FlipX = false
                sprite:Play("TripHori", false)
            elseif data.chargeTo == "Right" then
                npc.FlipX = true
                sprite:Play("TripHori", false)
            end
        end
    end
    if sprite:IsEventTriggered("Trip") then
        data.state = "tripped"
    end
    if (sprite:IsFinished("TripHori") or sprite:IsFinished("TripDown") or sprite:IsFinished("TripUp")) then
        data.state = "tripped"
        npc.StateFrame = 0
        if data.chargeTo == "Up" then
                sprite:Play("TrippedUp", false)
        elseif data.chargeTo == "Down" then
                sprite:Play("TrippedDown", false)
        elseif data.chargeTo == "Left" then
                npc.FlipX = false
                sprite:Play("TrippedHori", false)
        elseif data.chargeTo == "Right" then
                npc.FlipX = true
                sprite:Play("TrippedHori", false)
        end
    end
    if data.state ~= "idle" and (sprite:IsFinished("RecoverHori") or sprite:IsFinished("RecoverDown") or sprite:IsFinished("RecoverUp")) then
        data.state = "idle"
        npc.StateFrame = 0
    end

    if data.state == "tripped" then
        npc.Velocity = npc.Velocity *0
        if npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        end
        if npc.StateFrame == 70 then
            data.state = "Recovering"
            if data.chargeTo == "Up" then
                sprite:Play("RecoverUp", false)
            elseif data.chargeTo == "Down" then
                sprite:Play("RecoverDown", false)
            elseif data.chargeTo == "Left" then
                npc.FlipX = false
                sprite:Play("RecoverHori", false)
            elseif data.chargeTo == "Right" then
                npc.FlipX = true
                sprite:Play("RecoverHori", false)
            end
        end
    else
        if not npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
        end
    end
end,
[mod.FF.Shottie.Var] = function(npc, data, sprite)
    local path = npc.Pathfinder
    local d = data
    local sprite  = npc:GetSprite()
    local params = ProjectileParams()
    local target = npc:GetPlayerTarget()

    --Specific Shottie Variables
    --[[print(data.state)
    print(data.ammostate)
    print(data.ammotype)--]]

    if not data.init then
        data.state = "idle"
        data.ammostate = "none"
        data.init = true
        data.ammotype = math.random(4)+1
        sprite:PlayOverlay("Head01", true)
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    --anim

    if data.state ~= "idle" then
        if target.Position.X < npc.Position.X then
            sprite.FlipX = false
        else
            sprite.FlipX = true
        end
    else
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            if npc.Velocity.X > 0 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        end
    end
    if data.state ~= "shooting" then
        if npc.Velocity:Length() > 1 then
            if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
                    mod:spritePlay(sprite, "WalkVert")
                else
                    if npc.Velocity.X < 0 then
                        if sprite.FlipX then
                            mod:spritePlay(sprite, "WalkRight")
                        else
                            mod:spritePlay(sprite, "WalkHori")
                        end
                    else
                        if sprite.FlipX then
                            mod:spritePlay(sprite, "WalkHori")
                        else
                            mod:spritePlay(sprite, "WalkRight")
                        end
                    end
                end
            else
                sprite:SetFrame("WalkVert", 0)
            end
    end

    --anim end, this dude has to be like this because of his pointing head

    local targetpos = mod:confusePos(npc, target.Position)
    local distanceabs = npc.Position:Distance(targetpos)

    --movement
    if data.ammostate == "none" and data.state == "idle" then --Actively Avoids Player
        if mod:isScare(npc) then
            local targetvel = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvel = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        else
            path:FindGridPath(targetpos, 0.4, 900, true)
        end
        --v Down here is random Reload v
        if npc.FrameCount % 8 == 0 and (math.random(25) == math.random(25) or npc.StateFrame >= 30+math.random(12)) and not mod:isScareOrConfuse(npc) and npc.StateFrame > 10 then
            data.ammotype = math.random(4)+1
            sprite:PlayOverlay("Head0"..data.ammotype.."Start", true)
            data.state = "loading"
            npc.Velocity = npc.Velocity*0
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            --print("randomshot"..data.ammotype)
        end
    elseif (data.ammostate == "fullyloaded" or data.ammostate == "halfloaded") and data.state == "idle" then
        if mod:isScare(npc) then
            local targetvel = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvel = (targetpos - npc.Position):Resized(4)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        else
            path:FindGridPath(targetpos, 0.4, 900, true)
        end
    end
    --movement end

    if sprite:IsOverlayFinished("Head0"..data.ammotype.."Start") then
        data.ammostate = "fullyloaded"
        data.state = "idle"
        sprite:PlayOverlay("Head0"..data.ammotype, true)
        npc.StateFrame = 0
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end

    --Shoots
    if sprite:GetOverlayFrame() == 16 and (sprite:IsOverlayPlaying('Shoot0'..data.ammotype..'01') or sprite:IsOverlayPlaying('Shoot0'..data.ammotype..'02')) then
        if data.ammotype == 3 or (data.ammotype == 4 and sprite:IsOverlayPlaying('Shoot0'..data.ammotype..'02')) or (data.ammotype == 5 and sprite:IsOverlayPlaying('Shoot0'..data.ammotype..'01')) then
            local shootvec = (target.Position - (npc.Position + npc.SpriteOffset)):Resized(11)
            params.Spread = 0.6
            params.Variant = 3
            npc:FireProjectiles(npc.Position, shootvec, 4,params)
            npc:PlaySound(mod.Sounds.ShottieShot, 1, 0, false, math.random(95,105)/100)
            npc.Velocity = -(shootvec/2)
        elseif data.ammotype == 2 or (data.ammotype == 4 and sprite:IsOverlayPlaying('Shoot0'..data.ammotype..'01')) or (data.ammotype == 5 and sprite:IsOverlayPlaying('Shoot0'..data.ammotype..'02')) then
            params.Variant = 1
            local shootvec = (target.Position - (npc.Position + npc.SpriteOffset)):Resized(11)
            local proj = Isaac.Spawn(9,3,0,(npc.Position + npc.SpriteOffset) + shootvec:Resized(11), shootvec, npc):ToProjectile()
            proj:GetSprite():Load("gfx/projectiles/projectile_shottie_paper_wad.anm2", true)
            proj:GetSprite():Play("Move")
            mod:FlipSprite(proj:GetSprite(), npc.Position, target.Position)
            --proj:AddScale(0.5)
            proj:GetData().projType = "shottieFlak"
            proj:Update()
            npc.Velocity = -(shootvec/2)
        end
        npc:PlaySound(mod.Sounds.ShottieFlak, 1, 0, false, math.random(90,95)/100)
    end

    --Recoil
    if data.state == "shooting" then
    npc.Velocity = npc.Velocity/1.2
    end

    --Sound
    if sprite:GetOverlayFrame() == 14 and sprite:IsOverlayPlaying('Head0'..data.ammotype..'Start') then
        npc:PlaySound(mod.Sounds.ShottieReload, 0.5, 0, false, math.random(95,105)/100)
    end


    if npc.StateFrame > 15 and math.random(2) == 1 and data.state == "idle" and (data.ammostate == "fullyloaded" or data.ammostate == "halfloaded") and game:GetRoom():CheckLine(npc.Position, target.Position + target.Velocity*5,3,1,false,false) and not mod:isScareOrConfuse(npc) then
        npc.StateFrame = 0
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.Velocity = npc.Velocity *0
        data.state = "shooting"
        if data.ammostate == "fullyloaded" then
            sprite:PlayOverlay("Shoot0"..data.ammotype.."01", true)
            sprite:Play("Shoot0"..data.ammotype.."01", true)
            data.ammostate = "halfloaded"
        elseif data.ammostate == "halfloaded"  then
            sprite:PlayOverlay("Shoot0"..data.ammotype.."02", true)
            sprite:Play("Shoot0"..data.ammotype.."02", true)
            data.ammostate = "none"
        end
    end
    if sprite:IsOverlayFinished("Shoot0"..data.ammotype.."01") then
        data.state = "idle"
        sprite:PlayOverlay("Head0"..data.ammotype.."02", true)
        npc.StateFrame = 0
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end
    if sprite:IsOverlayFinished("Shoot0"..data.ammotype.."02") then
        data.state = "idle"
        sprite:PlayOverlay("Head01", true)
        npc.StateFrame = 0
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end
end,
[mod.FF.Shi.Var] = function(npc, data, sprite) -- Shi
    local r = npc:GetDropRNG()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()

    local shadoworbs = false --Guwah alt attack test, set to true to enable

    if not data.init then
        data.state = "appear"
        mod:spritePlay(sprite, "Appear")
        data.close = false
        data.init = true
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        data.SwipeCooldown = 30
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    --Attack
    if shadoworbs then
        if npc.StateFrame >= 15 then
            npc.StateFrame = 0
            --npc:PlaySound(SoundEffect.SOUND_STATIC,0.5,0,false,1.2)
            local projs = {}
            local roughpos = targetpos + (target.Velocity * 20)
            local spawnpos = mod:FindRandomFreePosAirNoGrids(targetpos, 100, 200) + (RandomVector() * mod:RandomInt(0,20,r))
            local proj = Isaac.Spawn(9,0,0,spawnpos,Vector.Zero,npc):ToProjectile()
            table.insert(projs, proj)
            spawnpos = mod:FindRandomFreePosAirNoGrids(targetpos, 200) + (RandomVector() * mod:RandomInt(0,20,r))
            proj = Isaac.Spawn(9,0,0,spawnpos,Vector.Zero,npc):ToProjectile()
            table.insert(projs, proj)
            for _, proj in pairs(projs) do
                proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
                proj.Scale = mod:RandomInt(5,15,r) * 0.1
                proj.Color = mod.ColorDankBlackReal
                proj:SetColor(mod.ColorDankBlackFake, 15, 1, true, false)
                proj.FallingAccel = -0.15
                proj:GetData().Wobblin = true
                proj:GetData().WobblinTimer = mod:RandomInt(110,150,r)
                proj:GetData().projType = "shiShadowOrb"
                proj:Update()

                local effect = Isaac.Spawn(1000,2,5,proj.Position,Vector.Zero,proj)
                effect.Color = mod.ColorDankBlackReal
                effect.SpriteScale = Vector(0.8,0.8)
                effect.PositionOffset = proj.PositionOffset
            end
        end
    else
        if npc.StateFrame >= 45 then
            npc.StateFrame = 0
            npc:PlaySound(SoundEffect.SOUND_STATIC,0.5,0,false,1.2)
            --local projVel = Vector(npc.Velocity.X+math.random(3,5),npc.Velocity.Y):Rotated(math.random(360))
            local dir = math.random(1,4)
            local projectile = nil
            if dir == 1 then --LEFT
                projectile = Isaac.Spawn(9, 4, 0, target.Position + Vector(-95,0), Vector.Zero, npc):ToProjectile()
                projectile:GetData().offset = Vector(-95,0)
            elseif dir == 2 then --RIGHT
                projectile = Isaac.Spawn(9, 4, 0, target.Position + Vector(95,0), Vector.Zero, npc):ToProjectile()
                projectile:GetData().offset = Vector(95,0)
            elseif dir == 3 then --UP
                projectile = Isaac.Spawn(9, 4, 0, target.Position + Vector(0,-95), Vector.Zero, npc):ToProjectile()
                projectile:GetData().offset = Vector(0,-95)
            elseif dir == 4 then -- DOWN
                projectile = Isaac.Spawn(9, 4, 0, target.Position + Vector(0,95), Vector.Zero, npc):ToProjectile()
                projectile:GetData().offset = Vector(0,95)
            end
            projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
            projectile:GetData().projType = "shi"
            projectile:GetData().follow = target
            projectile.FallingAccel = -0.0625
            projectile.FallingSpeed = -3
            local s = projectile:GetSprite()
            s:Load("gfx/projectiles/projectile_prick.anm2",true)
            s:Play("Idle",false)

            if dir == 1 then --Left
            s.Rotation = 0
            --projectile:GetData().trailOffset = Vector(-3,0)
            elseif dir == 2 then --RIGHT
            s.Rotation = 90*2
            --projectile:GetData().trailOffset = Vector(3,0)
            elseif dir == 3 then --UP
            s.Rotation = 90
            --projectile:GetData().trailOffset = Vector(0,-3)
            elseif dir == 4 then -- DOWN
            s.Rotation = 90*3
            --projectile:GetData().trailOffset = Vector(0,3)
            end

            local shiProjColor = Color(1,1,1,1,0,0,0)
            shiProjColor:SetColorize(124/255, 124/255, 124/255, 1)
            projectile.Color = shiProjColor
        end
    end

    if data.state == "idle" then
        --Movement
        if mod:isScare(npc) then
            local targetvel = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        else
            local targetvel = ((targetpos - npc.Position)/20)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
            npc.Velocity:Clamped (0, 0, 4, 4)
            --npc.Velocity = npc.Position:Distance(targetpos)
        end
        --Is Close
        data.SwipeCooldown = data.SwipeCooldown - 1
        if npc.Position:Distance(targetpos) - target.Size <= 80 and data.SwipeCooldown <= 0 then
            if data.close == false then
            data.close = true
            --Swipe Attack Prep
            sprite:Play("Swipe")
            sprite:PlayOverlay("Swipe")
            end
        --else
        -- if data.close == true then
        --	data.close = false
        --	mod:spriteOverlayPlay(sprite, "Idle (head swap to far)")
        -- end
        end
        if sprite:IsOverlayFinished("Idle (head swap to far)") then
            sprite:Play("Idle (head)")
            sprite:Play("Idle")
            sprite:PlayOverlay("Idle (head)")
        end
        if sprite:IsPlaying("Swipe") then
            npc.Velocity = npc.Velocity*0
            local f = sprite:GetFrame()
            if f == 16 then
                data.state = "swipe"
                local vec = target.Position - npc.Position
                npc.Velocity = npc.Velocity + vec:Resized(27)
                npc:PlaySound(mod.Sounds.ShiScream,0.75,0,false,math.random(90,110)/100)
            end
        end

        if sprite:IsOverlayFinished("Idle (head swap to far)") then
            sprite:Play("Idle")
            sprite:PlayOverlay("Idle (head)")
        end
    elseif data.state == "appear" then
        if sprite:IsFinished("Appear") then
            data.state = "idle"
            sprite:Play("Idle")
            sprite:PlayOverlay("Idle (head)")
        end
    elseif data.state == "swipe" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsOverlayFinished("Swipe") then
            data.state = "idle"
            data.close = false
            data.SwipeCooldown = 75
            sprite:Play("Idle")
            sprite:PlayOverlay("Idle (head swap to far)")
            --npc.StateFrame = 0
        end
    end
end,
}
    
function mod.cakeProj(v,d)
    if d.projType == "shi" then
        if v.SpawnerEntity and v.SpawnerEntity:Exists() and not mod:isStatusCorpse(v.SpawnerEntity) then
            if v.FrameCount == 1 then
                local shiProjColor = Color(1,1,1,1,0,0,0)
                shiProjColor:SetColorize(255/255, 255/255, 255/255, 1)
                local trail = Isaac.Spawn(1000, 16, 0, v.Position, v.Velocity * 0.2 + Vector(0, 0 - math.random()*3), v):ToEffect()
                trail:GetSprite():LoadGraphics()
                trail.Color = shiProjColor
                trail.SpriteScale = Vector(0.75, 0.75)
                trail.DepthOffset = -10
                trail:Update()
            end
            if v.FrameCount > 40 then
                if v.FrameCount == 45 then
                v.Velocity = (d.offset*0.2)
                end

                if v.FrameCount > 45 then
                v.Velocity = v.Velocity*0.8
                end
                if v.FrameCount > 50 then
                v.Velocity = -(d.offset*0.5)
                end
            else
                v.Velocity = (d.follow.Position + d.offset) - v.Position
            end
        --elseif not d.splish then
        --	v.Velocity = v.Velocity*0.7
        --	v.FallingSpeed = -1
        ---	v.FallingAccel = 1.5
        --	d.splish = true
        --else
        --	v.Velocity = v.Velocity*0.7
        else
        v:Remove()
        end
    elseif d.projType == "shottieFlak" then
		v.Velocity = v.Velocity * math.max(0.5,(1 - v.FrameCount / 200))

		if v:IsDead() then
			for i = 0, 360, 60 do
				local shootvec = Vector(9,0):Rotated(i)
				local proj = Isaac.Spawn(9,3,0,v.Position + shootvec:Resized(10), shootvec, v):ToProjectile()
				mod:makeProjectileConsiderFriend(v.SpawnerEntity, proj)
				proj:Update()
			end
			--sfx:Play(SoundEffect.SOUND_PLOP,0.5,2,false,math.random(60,80)/100)
			v:Die()
		end
    elseif d.projType == "shiShadowOrb" then
        v.Velocity = v.Velocity * 0.8
        if v.FrameCount >= 20 then
            v.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        else
            v.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end
    end
end

function mod.shiDeathAnim(e)
    local npc = e:ToNPC()
    
    mod:basicDeathAnimation(npc, "Death", true)
    npc:GetSprite():RemoveOverlay()
end

function mod:TrashbaggerUnboxing(npc, extraflies)
    local r = npc:GetDropRNG()
    for i = 0, extraflies do
        local flytype = mod:GetRandomElem(FiendFolio.TrashbaggerFlies)
        if flytype == 281 then
            local fly = mod.cheekyspawn(npc.Position, npc, npc.Position + Vector(2,0):Rotated(mod:RandomAngle()), 281, 0, 0)
        else
            local flyvar = 0
            if flytype == 450 then
                flyvar = mod.FF.ShotFly.Var
            end
            local fly = Isaac.Spawn(flytype, flyvar, 0, npc.Position, Vector(2,0):Rotated(mod:RandomAngle()), npc)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end					
    end
    if r:RandomFloat() <= 0.5 then
        local extrafly = Isaac.Spawn(13, 0, 0, npc.Position, Vector(2,0):Rotated(mod:RandomAngle()), npc)
        extrafly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
    sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF, 1.5, 0, false, 1.5)
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if enemies369[npc.Variant] then 
        enemies369[npc.Variant](npc, npc:GetData(), npc:GetSprite())
    end
end, FiendFolio.FFID.Cake)