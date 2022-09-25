local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:whaleAI(npc)
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local sprite = npc:GetSprite()
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.init then
        if data.dead then
            data.state = "MaggotBurst"
            npc.CollisionDamage = 0
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        elseif data.whaleSpawn then
            data.state = "Launched"
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            data.cordLength = 250
        elseif npc.SubType == mod.FF.Whale.Sub then
            local pathfinder = Isaac.Spawn(mod.FF.ChummerPathfinder.ID, mod.FF.ChummerPathfinder.Var, 1, npc.Position, Vector.Zero, npc):ToNPC()
            pathfinder.Parent = npc
            npc.Child = pathfinder
            data.state = "Idle"
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        elseif npc.SubType == mod.FF.WhaleGuts.Sub then
            data.state = "Idle"
        end

        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if npc.SubType == mod.FF.Whale.Sub then --Whale
        if data.state == "Idle" then
            if data.gutsSpawn then
                mod:spritePlay(sprite, "Idle2")
            else
                if (npc.Position:Distance(target.Position) < 70 and npc.FrameCount > 40) or npc.HitPoints < 4*npc.MaxHitPoints/5 then
                    data.state = "Bursting"
                    data.gassing = true
                    npc.StateFrame = 0
                    npc:PlaySound(mod.Sounds.GasHissShort, 4, 0, false, 2)
                end

                mod:spritePlay(sprite, "Idle")
            end
        elseif data.state == "Corpse" then
            if not data.guts or (data.guts:IsDead() or mod:isStatusCorpse(data.guts)) then
                data.state = "CorpseDeath"
                data.guts = nil
                npc.CanShutDoors = false
            end

            npc.Velocity = Vector.Zero
            mod:spritePlay(sprite, "Idle3")
        elseif data.state == "Bursting" then
            local vec = Vector(1,0)
            if sprite.FlipX == true then
                vec = Vector(-1,0)
            end

            if sprite:IsFinished("Rupture") then
                data.state = "Idle"
            elseif sprite:IsEventTriggered("Burst") then
                sfx:Stop(mod.Sounds.GasHissShort)
                local vel = vec:Resized(25)+npc.Velocity
                data.gassing = nil
                data.gutsSpawn = true
                npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 0.8)
                local guts = Isaac.Spawn(mod.FF.WhaleGuts.ID, mod.FF.WhaleGuts.Var, mod.FF.WhaleGuts.Sub, npc.Position, vel, npc):ToNPC()
                guts:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local cord = Isaac.Spawn(mod.FF.WhaleCord.ID, mod.FF.WhaleCord.Var, mod.FF.WhaleCord.Sub, npc.Position, Vector.Zero, npc):ToNPC()
                cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local dummyeffect = mod:AddDummyEffect(npc, Vector(10,-30))
                data.dummy = dummyeffect
                data.dummyX = 10
                data.dummyY = -30
                cord.Parent = dummyeffect
                cord.Target = guts
                guts:GetData().launchedEnemyInfo = {zVel = -3, vel = vel, landFunc = function(npc1, tab)
                    npc1:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
                    npc1:GetData().state = "Idle"
                    npc1.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                end}
                guts:GetSprite():Play("Idle", true)
                guts:GetSprite():Play("Spawn", true)
                guts:GetData().whaleSpawn = true
                guts.Parent = npc
                data.guts = guts
                data.cord = cord
                guts:GetData().cord = cord
                local poof = Isaac.Spawn(1000, 16, 5, npc.Position+vec:Resized(20)+Vector(0,-50), Vector.Zero, npc):ToEffect()
                poof.SpriteScale = Vector(0.8,0.8)
                poof.Color = Color(0.8,0.8,0.8,1,0,0,0)
                npc:BloodExplode()
                for i=1,20 do
                    local gib = Isaac.Spawn(1000, 5, 0, npc.Position, vec:Resized(math.random(5,10)):Rotated(math.random(-70,70)), npc)
                    if math.random(5) == 1 then
                        gib:GetSprite():Play("Guts02", true)
                    end
                end
                for i=1,4 do
                    local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, npc.Position, RandomVector()*math.random(3,10), npc):ToEffect()
                    smoke.Color = Color(158/255, 11/255, 15/255, 67/255, 0, 0, 0)
                    smoke:SetTimeout(50 + math.random(20))
                    smoke:Update()
                end
            else
                mod:spritePlay(sprite, "Rupture")
            end

            if data.gassing then
                if npc.StateFrame % 5 == 0 then
                    local vel = vec:Resized(npc.StateFrame/2):Rotated(mod:getRoll(0,60,rng))+npc.Velocity
                    local cloud = Isaac.Spawn(1000, 141, 0, npc.Position, vel, npc):ToEffect()
					cloud.Parent = npc
					cloud.SpriteScale = Vector(0.3, 0.3)
					cloud:GetData().moveGasInfo = {timeout = 80, grow = 0.015, growLimit = 0.4+npc.StateFrame/100}
                end
            end
        elseif data.state == "MaggotBurst" then
            if sprite:IsFinished("Rupture2") then
                data.state = "Corpse"
            elseif sprite:IsEventTriggered("Thump") then
                npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
            elseif sprite:IsEventTriggered("Burst2") then
                npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 0.8)
                local vec = Vector(2,0)
                if sprite.FlipX then
                    vec = Vector(-2,0)
                end
                local charger = Isaac.Spawn(855, 0, 0, npc.Position+vec:Resized(60), Vector.Zero, npc):ToNPC()
                charger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                charger.State = 8
                charger.V1 = vec
                local poof = Isaac.Spawn(1000, 16, 5, npc.Position+vec:Resized(80)+Vector(0,-10), Vector.Zero, npc):ToEffect()
                poof.SpriteScale = Vector(0.8,0.8)
                poof.Color = Color(0.8,0.8,0.8,1,0,0,0)

                for i=1,4 do
                    local vel = vec:Resized(rng:RandomInt(4)+2):Rotated(mod:getRoll(-90,90,rng))
                    mod.ThrowMaggot(npc.Position+vec:Resized(80), vel, -5, mod:getRoll(-25,-15,rng), npc)
                end
                for i=1,10 do
                    local params = ProjectileParams()
                    params.FallingSpeedModifier = mod:getRoll(-30,-15,rng)
                    params.FallingAccelModifier = 1.1
                    params.Scale = mod:getRoll(60,200,rng)/100
                    npc:FireProjectiles(npc.Position+vec:Resized(80), vec:Resized(rng:RandomInt(4)+2):Rotated(mod:getRoll(-90,90,rng)), 0, params)
                end
                for i=-90,90,45 do
                    local params = ProjectileParams()
                    params.FallingSpeedModifier = 0
                    params.FallingAccelModifier = -0.15
                    params.Scale = 1.5
                    params.BulletFlags = params.BulletFlags | ProjectileFlags.ACCELERATE
                    params.Acceleration = 0.92
                    npc:FireProjectiles(npc.Position+vec:Resized(80), vec:Resized(12):Rotated(i), 0, params)
                end

                --why is just adjusting the parentoffset not working
                if data.dummy and data.dummy:Exists() then
                    data.dummy:Remove()
                end
                if data.cord then
                    local dummyeffect = mod:AddDummyEffect(npc, Vector(40,0))
                    data.dummy = dummyeffect
                    data.cord.Parent = dummyeffect
                end
            else
                mod:spritePlay(sprite, "Rupture2")
            end
            npc.Velocity = Vector.Zero
        elseif data.state == "CorpseDeath" then
            if sprite:IsFinished("Death2") then
                data.noDeathAnim = true
                if data.dummy then
                    data.dummy:Remove()
                    data.dummy = nil
                end
                npc:Kill()
            else
                mod:spritePlay(sprite, "Death2")
            end
            npc.Velocity = Vector.Zero
        elseif data.state == "GutDeath" then
            if sprite:IsFinished("Death1") then
                data.noDeathAnim = true
                if data.dummy then
                    data.dummy:Remove()
                    data.dummy = nil
                end
                npc:Kill()
            elseif sprite:IsEventTriggered("Thump") then
                npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
            else
                mod:spritePlay(sprite, "Death1")
            end
            npc.Velocity = Vector.Zero
        end

        if data.dummy and not data.dead then
            if sprite.FlipX == true then
                data.dummy.ParentOffset = Vector(-data.dummyX, data.dummyY)
            else
                data.dummy.ParentOffset = Vector(data.dummyX, data.dummyY)
            end
        end

        if data.gutsSpawn then
            if data.guts and (data.guts:IsDead() or mod:isStatusCorpse(data.guts)) then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                npc.CollisionDamage = 0
                if npc.Child then
                    npc.Child:Remove()
                end
                npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                data.state = "GutDeath"
                data.guts = nil
                npc.CanShutDoors = false
            end

            if npc.FrameCount % 12 == 0 then
                local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
                local randScale = math.random(20,100)/100
                splat.SpriteScale = Vector(randScale, randScale)
            end
        end
    elseif npc.SubType == mod.FF.WhaleGuts.Sub then --Whale Guts
        if data.state == "Idle" then
            if data.whaleSpawn then
                local realTargetPos = mod:FindClosestValidPosition(npc, target, 100, 120, 1)
                local vec = (realTargetPos-npc.Position)

                if sprite:IsEventTriggered("Scootch") then
                    npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(7), 0.4)
                else
                    npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(2), 0.3)
                end
            else
                if not data.targPos then
                    data.moveTimer = 0
                    data.targPos = mod:FindRandomVisiblePosition(npc, npc.Position, 3, 100, 120)
                end
                if npc.Position:Distance(data.targPos) < 10 or (mod:isConfuse(npc) and npc.FrameCount % 10 == 0) or data.moveTimer > 25 then
                    data.moveTimer = 0
                    data.targPos = mod:FindRandomVisiblePosition(npc, npc.Position, 3, 100, 120)
                end
                data.moveTimer = data.moveTimer+1
                if mod:isScare(npc) then
                    local targVel = (npc.Position-targetpos):Resized(3)
			    	npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                else
                    local vec = (data.targPos-npc.Position)

                    if sprite:IsEventTriggered("Scootch") then
                        npc:PlaySound(SoundEffect.SOUND_MEAT_FEET_SLOW0, 0.3, 0, false, math.random(18,22)/10)
                        npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(6), 0.4)
                    else
                        npc.Velocity = mod:Lerp(npc.Velocity, vec:Normalized(), 0.1)
                    end
                end
            end

            if npc.StateFrame > 40 and rng:RandomInt(30) == 0 and not mod:isScareOrConfuse(npc) then
                data.state = "Shoot"
            elseif npc.StateFrame > 80 and not mod:isScareOrConfuse(npc) then
                data.state = "Shoot"
            end

            mod:spritePlay(sprite, "Idle")
        elseif data.state == "Shoot" then
            if sprite:IsFinished("Shoot") then
                data.state = "Idle"
                npc.StateFrame = 0
                data.moveTimer = 500
            elseif sprite:IsEventTriggered("Shoot") then
                data.WormyShoot = 4
                data.WormPoint = npc.Position
                local realtarget = mod:intercept(npc, target, 10)
                data.WormVec = realtarget:Rotated(-20)
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 0.7)
            else
                mod:spritePlay(sprite, "Shoot")
            end

            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)

            --just stealing this from marzy ilu guwah smoochies *kiss*
            if data.WormyShoot and npc.FrameCount % 2 == 0 then
                data.WormyShoot = data.WormyShoot or -1
                data.WormyShoot = data.WormyShoot - 1
                data.WormPoint = data.WormPoint or npc.Position
                if data.WormyShoot >= 0 then
                    local params = ProjectileParams()
                    params.Color = mod.ColorWigglyMaggot
                    params.FallingAccelModifier = -0.15
                    params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
                    params.Scale = data.WormyShoot/2
                    mod:SetGatheredProjectiles()
                    for i = 0, 240, 120 do
                        local shootvec = data.WormVec:Rotated(i):Resized(8)
                        npc:FireProjectiles(data.WormPoint + shootvec:Resized(data.WormyShoot * 2), shootvec, 0, params)
                    end
                    for _, projectile in pairs(mod:GetGatheredProjectiles()) do
                        local data1 = projectile:GetData()
                        data1.projType = "wigglyWorm"
                    end
                end
            end
        elseif data.state == "Launched" then

        end

        if data.whaleSpawn then
            if npc.Parent and npc.Parent:Exists() then
                local dist = npc.Parent.Position - npc.Position
                if dist:Length() > data.cordLength then
                    local distToClose = dist - dist:Resized(data.cordLength)
                    npc.Velocity = npc.Velocity + distToClose*0.5
                end

                if data.cordLength > 120 then
                    data.cordLength = data.cordLength-1
                end
            else
                if data.cord and data.cord:Exists() then
                    data.cord:Remove()
                end
                data.whaleSpawn = nil
                npc.Parent = nil
            end
        end

        if npc.FrameCount % 8 == 0 then
            Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc)
        end
    end
end

function mod.whaleDeathAnim(npc)
    local data = npc:GetData()
    if not data.noDeathAnim then
        local onCustomDeath = function(npc, deathAnim)
            deathAnim:GetData().dead = true
            if npc.Child then
                npc.Child:Remove()
            end
            if data.dummy then
                data.dummy:Remove()
                data.dummy = nil
            end
            if data.guts and data.guts:Exists() then
                deathAnim:GetData().guts = data.guts
                deathAnim:GetData().cord = data.cord
                data.guts.Parent = deathAnim
                local dummyeffect = mod:AddDummyEffect(npc, Vector(10,-30))
                data.cord.Parent = dummyeffect
                deathAnim:GetData().dummy = dummyeffect
            end
        end

        mod.genericCustomDeathAnim(npc, "Rupture2", true, onCustomDeath, false, false)
    end
end

function mod:whaleHurt(npc, damage, flag, source)
    local data = npc:GetData()
    if flag ~= flag | DamageFlag.DAMAGE_CLONES  and data.state == "Bursting" then
        npc:TakeDamage(damage*0.05, flag | DamageFlag.DAMAGE_CLONES, source, 0)
        return false
    end
end