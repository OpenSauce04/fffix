local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

local defaultAttacks = {"Shoot", "Spawn", "Trashbag"}

function mod:JunkstrapAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local room = game:GetRoom()
	local rng = npc:GetDropRNG()

    if not data.Init then
        npc:SetSize(npc.Size, Vector(3,1), 12)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.StateFrame = 50
        npc.SplatColor = mod.ColorDankBlackReal
        npc.SpriteOffset = Vector(0,-5)
        data.LastChoice = nil
        data.DopeHeadCooldown = 2
        data.SpikesCooldown = 0
        data.RightSide = (rng:RandomFloat() <= 0.5)
        data.State = "Idle"
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    mod.QuickSetEntityGridPath(npc, 900)
    mod:spriteOverlayPlay(sprite, "Flies")

    if data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            npc.StateFrame = 0
            data.SpikesCooldown = data.SpikesCooldown - 1
            data.DopeHeadCooldown = data.DopeHeadCooldown - 1
            local choice
            if data.ShootThePigskin then
                choice = "Trashbag"
            elseif mod.GetEntityCount(mod.FF.DopeHead.ID, mod.FF.DopeHead.Var) >= 3 then
                choice = "Suck"
                data.SubState = "SuckStart"
            elseif npc.HitPoints < (npc.MaxHitPoints * 0.66) and data.SpikesCooldown <= 0 and mod.GetEntityCount(mod.FF.DopeHead.ID, mod.FF.DopeHead.Var) < 2 then
                choice = "Spikes"
                data.SpikesCooldown = 5
            elseif data.DopeHeadCooldown <= 0 then
                choice = "Spawn"
            else
                local choices = {}
                for _, attack in pairs(defaultAttacks) do
                    if not ((data.LastChoice and data.LastChoice == attack) or (attack == "Trashbag" and mod:CountTrashbaggerFlies() > 2)) then
                        table.insert(choices, attack)
                    end
                end
                choice = mod:GetRandomElem(choices, rng)
            end
            data.State = choice
            data.LastChoice = choice
        end
    elseif data.State == "Shoot" then
        if sprite:IsFinished("Attack1") then
            data.State = "Idle"
            npc.StateFrame = mod:RandomInt(50,80,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_GHOST_ROAR, npc)
            data.ShootMode = data.ShootMode or mod:RandomInt(1,2,rng)
            if data.ShootMode == 1 then
                data.ShootMode = 2
                if rng:RandomFloat() <= 0.5 then
                    data.Angles = {-10, 35, 90, 145, 190}
                else
                    data.Angles = {10, 60, 120, 170}
                end
                npc.V1 = Vector(3,0)
                npc.V2 = Vector(20,0)
            elseif data.ShootMode == 2 then
                data.ShootMode = 1 
                data.PredictPos = target.Position + (target.Velocity * 60)
            end
        else
            mod:spritePlay(sprite, "Attack1")
        end

        if sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Stop") then
            if data.ShootMode == 1 and sprite:GetFrame() % 2 == 0 then --Toxic fart shower
                mod:SetGatheredProjectiles()
                local vel = ((data.PredictPos - npc.Position) * 0.03):Rotated(mod:RandomInt(-10,-10,rng))
                local params = ProjectileParams()
                params.Scale = mod:RandomInt(15,25,rng) / 10
                params.FallingSpeedModifier = mod:RandomInt(-50,-40,rng)
                params.FallingAccelModifier = 2 + (mod:RandomInt(0,2,rng)/10)
                params.HeightModifier = -20
				params.Color = FiendFolio.ColorToxicFart 
                npc:FireProjectiles(npc.Position, vel, 0, params)
                for _, proj in pairs(mod:GetGatheredProjectiles()) do
                    proj:GetData().projType = "DangerFart"
                    proj:GetData().fartscale = 1.75
                end

                npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,0.8)

                local newpredict = target.Position + (target.Velocity * 60)
                data.PredictPos = mod:Lerp(data.PredictPos, newpredict, 0.2)
            elseif data.ShootMode == 2 and sprite:GetFrame() % 2 == 0 then
                if npc.StateFrame <= 16 then
                    for _, angle in pairs(data.Angles) do
                        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
                        for i = 1, 3 do
                            local params = ProjectileParams()
                            if rng:RandomFloat() <= 0.6 then
                                params.Color = mod.ColorDankBlackReal
                            else
                                params.Variant = mod:GetRandomElem(mod.TrashbaggerTable)
                            end
                            params.FallingSpeedModifier = mod:RandomInt(-10,-5,rng) * (npc.StateFrame/5)
                            params.FallingAccelModifier = 2
                            params.HeightModifier = -50
                            npc:FireProjectiles(npc.Position + npc.V1:Resized(20):Rotated(angle), npc.V1:Rotated(angle + mod:RandomInt(-10,10,rng)), 0, params)
                        end 
                            
                        local creep = Isaac.Spawn(1000, 26, 0, npc.Position + npc.V2:Rotated(angle), Vector.Zero, npc):ToEffect()
                        creep:SetTimeout(250)
                        creep:Update()
                        local effect = Isaac.Spawn(1000, 2, 3, creep.Position, Vector.Zero, npc) 
                        effect.Color = mod.ColorDankBlackReal
                    end
                end
                       
                npc.V1 = npc.V1:Resized(npc.V1:Length() + 1)
                npc.V2 = npc.V2:Resized(npc.V2:Length() + 15)
                npc.StateFrame = npc.StateFrame + 1
            end
        end
    elseif data.State == "Spawn" then
        if sprite:IsFinished("Attack2") then
            data.State = "Idle"
            npc.StateFrame = mod:RandomInt(50,80,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            local choice
            if data.DopeHeadCooldown <= 0 then
                data.DopeHeadCooldown = 2
                data.LastChoice = nil
                choice = "dopehead"
            elseif mod.GetEntityCount(mod.FF.LitterBugToxic.ID, mod.FF.LitterBugToxic.Var) > 2 then
                choice = "butter"
            elseif mod.GetEntityCount(mod.FF.LitterBug.ID, mod.FF.LitterBug.Var) > 0 then
                choice = "toxic"
            elseif rng:RandomFloat() <= 0.5 then
                choice = "toxic"
            else
                choice = "butter"
            end

            if choice == "toxic" then
                local litterbug = EntityNPC.ThrowSpider(npc.Position, npc, targetpos, false, -50)
                litterbug:Morph(mod.FF.LitterBugToxic.ID, mod.FF.LitterBugToxic.Var, 0, -1)
                litterbug.HitPoints = litterbug.MaxHitPoints
            elseif choice == "butter" then
                for i = 1, 2 do
                    local spawnpos = mod:FindRandomValidPathPosition(npc, 2, 30) + (RandomVector() * mod:RandomInt(0,20))
                    local litterbug = EntityNPC.ThrowSpider(npc.Position, npc, spawnpos, false, -50)
                    litterbug:Morph(mod.FF.LitterBug.ID, mod.FF.LitterBug.Var, 0, -1)
                    litterbug.HitPoints = litterbug.MaxHitPoints
                end
            elseif choice == "dopehead" then
                local dopehead = Isaac.Spawn(mod.FF.DopeHead.ID, mod.FF.DopeHead.Var, 0, npc.Position + Vector(0,20), Vector.Zero, npc)
                dopehead:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
        
            mod:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, npc)
            mod:PlaySound(SoundEffect.SOUND_SUMMONSOUND, npc)
        else
            mod:spritePlay(sprite, "Attack2")
        end
    elseif data.State == "Trashbag" then
        if sprite:IsFinished("Attack3") then
            data.State = "Idle"
            if data.ShootThePigskin then
                npc.StateFrame = 240
                data.RightSide = not data.RightSide
                data.ShootThePigskin = nil
            else
                npc.StateFrame = mod:RandomInt(60,100,rng)
            end
        elseif sprite:IsEventTriggered("Shoot") then
            local params = ProjectileParams()
            local projtarget
            local fartangle
            if data.ShootThePigskin then
                mod:SetGatheredProjectiles()
                params.Variant = mod.FF.PigskinProjectile.Var
                params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
                if data.RightSide then
                    projtarget = Vector(room:GetTopLeftPos().X + 40, targetpos.Y)
                    fartangle = 0
                else
                    projtarget = Vector(room:GetBottomRightPos().X - 40, targetpos.Y)
                    fartangle = 180
                end
            else
                params.Variant = mod.FF.TrashbagProjectile.Var
                projtarget = targetpos
            end
            params.FallingSpeedModifier = -30
            params.FallingAccelModifier = 1.5
            params.HeightModifier = -20
            local vel = ((projtarget - npc.Position) * 0.04)
            npc:FireProjectiles(npc.Position, vel, 0, params)

            if data.ShootThePigskin then
                for _, proj in pairs(mod:GetGatheredProjectiles()) do
                    proj:GetData().XCord = projtarget.X
                    proj:GetData().CCSpin = (rng:RandomFloat() <= 0.5)
                    proj:GetData().FartAngle = fartangle

                    local target = Isaac.Spawn(mod.FF.PigskinTarget.ID, mod.FF.PigskinTarget.Var, mod.FF.PigskinTarget.Sub, proj.Position, Vector.Zero, proj):ToEffect()
                    target.Parent = proj
                    target.DepthOffset = -999
                    proj:GetData().Target = target
                end
            end
        
            mod:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, npc)
        else
            mod:spritePlay(sprite, "Attack3")
        end
    elseif data.State == "Suck" then
        if data.SubState == "SuckStart" then
            if sprite:IsFinished("SuckStart") then
                npc.StateFrame = 120
                data.SubState = "SuckLoop"
            elseif sprite:IsEventTriggered("Sound") then
                mod:PlaySound(mod.Sounds.RefereeWhistle, npc)
            elseif sprite:IsEventTriggered("SuckBegin") then
                data.Sucking = true
                data.DopeHeads = 0
                mod:PlaySound(SoundEffect.SOUND_FIRE_RUSH, npc)
            else
                mod:spritePlay(sprite, "SuckStart")
            end
        elseif data.SubState == "SuckLoop" then
            mod:spritePlay(sprite, "SuckLoop")
            npc.StateFrame = npc.StateFrame - 1
            if data.DopeHeads >= 3 or npc.StateFrame <= 0 then
                data.SubState = "SuckEnd"
            end
        elseif data.SubState == "SuckEnd" then
            if sprite:IsFinished("SuckEnd") then
                data.Anim = "DopeHeadShoot"
                data.SubState = "DopeHeadShoot"
            elseif sprite:IsEventTriggered("SuckEnd") then
                data.Sucking = false
            else
                mod:spritePlay(sprite, "SuckEnd")
            end
        elseif data.SubState == "DopeHeadShoot" then
            if sprite:IsFinished("DopeHeadShootFinal") then
                data.State = "Idle"
                npc.StateFrame = mod:RandomInt(50,80,rng)
            elseif sprite:IsFinished("DopeHeadShoot") then
                if data.DopeHeads <= 1 then
                    data.Anim = "DopeHeadShootFinal"
                    sprite:Play(data.Anim, true)
                else
                    data.Anim = "DopeHeadShoot"
                    sprite:Play(data.Anim, true)
                end
            elseif sprite:IsEventTriggered("Sound") then
                mod:PlaySound(mod.Sounds.RefereeWhistleQuick, npc)
            elseif sprite:IsEventTriggered("Shoot") then
                local vec = (targetpos - npc.Position):Resized(10)
                local dopehead = Isaac.Spawn(mod.FF.DopeHeadProjectile.ID, mod.FF.DopeHeadProjectile.Var, 0, npc.Position + Vector(0,-20), vec, npc)

                data.DopeHeads = data.DopeHeads - 1
                mod:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, npc)
            else
                mod:spritePlay(sprite, data.Anim)
            end
        end

        if data.Sucking then
            for _, dopehead in pairs(Isaac.FindByType(mod.FF.DopeHead.ID, mod.FF.DopeHead.Var)) do
                dopehead:GetData().junksucked = 10
                if dopehead.Position.X < npc.Position.X then
                    mod:spritePlay(dopehead:GetSprite(), "Rotate1")
                else
                    mod:spritePlay(dopehead:GetSprite(), "Rotate2")
                end
                dopehead.Velocity = mod:Lerp(dopehead.Velocity, (npc.Position - dopehead.Position):Resized(10), 0.1)
                if dopehead.Position:Distance(npc.Position) <= 15 then
                    data.DopeHeads = data.DopeHeads + 1
                    dopehead:Remove()
                end
            end

            if npc.FrameCount % 10 == 0 then
                local succ = Isaac.Spawn(1000,151,1,npc.Position,Vector.Zero,npc)
                succ.SpriteOffset = Vector(0,-30)
                succ:Update()
                if npc.FrameCount % 20 == 0 then
                    local succ = Isaac.Spawn(1000,151,0,npc.Position ,Vector.Zero,npc)
                    succ.SpriteOffset = Vector(0,-30)
                    succ:Update()
                end
            end
        end
    elseif data.State == "Spikes" then
        if sprite:IsFinished("SummonSpikes") then
            npc.StateFrame = 30
            data.ShootThePigskin = true
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            data.Spikes = {}
            for i = 0, room:GetGridHeight() - 1 do
                if data.RightSide then
                    local startindex = (room:GetGridWidth()) * (i + 1)
                    for j = startindex - 1, startindex - 4, -1 do
                        if room:GetGridCollision(j) <= GridCollisionClass.COLLISION_NONE then
                            local spikes = Isaac.Spawn(mod.FF.TemporarySpikes.ID,mod.FF.TemporarySpikes.Var,mod.FF.TemporarySpikes.Sub,room:GetGridPosition(j),Vector.Zero,npc)
                            spikes:Update()
                            table.insert(data.Spikes, spikes)
                        end
                    end
                    local index2 = ((room:GetGridWidth()) * i) + 1
                    if room:GetGridCollision(index2) <= GridCollisionClass.COLLISION_NONE then
                        local spikes = Isaac.Spawn(mod.FF.TemporarySpikes.ID,mod.FF.TemporarySpikes.Var,mod.FF.TemporarySpikes.Sub,room:GetGridPosition(index2),Vector.Zero,npc)
                        spikes:Update()
                        table.insert(data.Spikes, spikes)
                    end
                else
                    local startindex = (room:GetGridWidth()) * i
                    for j = startindex, startindex + 3, 1 do
                        if room:GetGridCollision(j) <= GridCollisionClass.COLLISION_NONE then
                            local spikes = Isaac.Spawn(mod.FF.TemporarySpikes.ID,mod.FF.TemporarySpikes.Var,mod.FF.TemporarySpikes.Sub,room:GetGridPosition(j),Vector.Zero,npc)
                            spikes:Update()
                            table.insert(data.Spikes, spikes)
                        end
                    end
                    local index2 = ((room:GetGridWidth()) * (i + 1)) - 2
                    if room:GetGridCollision(index2) <= GridCollisionClass.COLLISION_NONE then
                        local spikes = Isaac.Spawn(mod.FF.TemporarySpikes.ID,mod.FF.TemporarySpikes.Var,mod.FF.TemporarySpikes.Sub,room:GetGridPosition(index2),Vector.Zero,npc)
                        spikes:Update()
                        table.insert(data.Spikes, spikes)
                    end
                end
            end
            local start = room:GetGridWidth() * (room:GetGridHeight() - 2)
            local fin = room:GetGridWidth() * (room:GetGridHeight() - 1)
            for i = start, fin do 
                local pos = room:GetGridPosition(i)
                if mod:GetNearestThing(pos,mod.FF.TemporarySpikes.ID,mod.FF.TemporarySpikes.Var,mod.FF.TemporarySpikes.Sub).Position:Distance(pos) > 10 
                and room:GetGridCollision(i) <= GridCollisionClass.COLLISION_NONE then
                    local spikes = Isaac.Spawn(mod.FF.TemporarySpikes.ID,mod.FF.TemporarySpikes.Var,mod.FF.TemporarySpikes.Sub,pos,Vector.Zero,npc)
                    spikes:Update()
                    table.insert(data.Spikes, spikes)
                end
            end

            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_GRROOWL, npc)

            for _, spikes in pairs(data.Spikes) do
                spikes:GetData().Duration = 240
                spikes:GetSprite():Play("Summon")
            end
        else
            mod:spritePlay(sprite, "SummonSpikes")
        end
    end
end

function mod:JunkstrapRender(npc, sprite)
    if sprite:IsEventTriggered("Explode1") and not npc:GetData().DeathGibbed then
        game:ShakeScreen(15)
        mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, npc, 0.6)
        npc:BloodExplode()
        npc:GetData().DeathGibbed = true
    elseif sprite:IsPlaying("DeathSound") then
        npc:PlaySound(SoundEffect.SOUND_DEVILROOM_DEAL,1,1,false,0.6)
    end
end

function mod:TrashbagProjectileDeath(projectile, sprite)
    local numflies = mod:RandomInt(2,3)
    mod:TrashbaggerUnboxing(projectile, numflies)

    local creep = Isaac.Spawn(1000, 26, 0, projectile.Position, Vector.Zero, projectile):ToEffect()
    creep.SpriteScale = creep.SpriteScale * 3
    creep:SetTimeout(250)
    creep:Update()

    local effect = Isaac.Spawn(1000,16,4,projectile.Position,Vector.Zero,projectile)
    effect.Color = mod.ColorDankBlackReal
    effect.SpriteScale = effect.SpriteScale * 0.8

    for i = 1, mod:RandomInt(8, 12) do
        local var = 0
        local isDanke = (rng:RandomFloat() <= 0.6)
        if not isDanke then
            var = mod:GetRandomElem(mod.TrashbaggerTable)
        end
        local proj = Isaac.Spawn(9, var, 0, projectile.Position, RandomVector() * mod:RandomInt(1,4), projectile):ToProjectile()
        proj.FallingAccel = 2
        proj.FallingSpeed = mod:RandomInt(-45,-30)
        if isDanke then
            proj.Color = mod.ColorDankBlackReal
        end
    end
end

function mod:CountTrashbaggerFlies()
    return (mod.GetEntityCount(EntityType.ENTITY_ATTACKFLY) 
    + mod.GetEntityCount(EntityType.ENTITY_DART_FLY) 
    + mod.GetEntityCount(EntityType.ENTITY_SWARM)
    + mod.GetEntityCount(EntityType.ENTITY_ARMYFLY)
    + mod.GetEntityCount(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var))
end

function mod:FrogProjectile(projectile, sprite, data)
    local scale = projectile.Scale
    local prefix = "Regular"
	if projectile.Variant == mod.FF.FrogProjectileBlood.Var then
		prefix = "Blood"
	end
	
	local anim
	if scale <= 0.3 then
		anim = prefix .. "Tear1"
	elseif scale <= 0.55 then
		anim = prefix .. "Tear2"
	elseif scale <= 0.675 then
		anim = prefix .. "Tear3"
	elseif scale <= 0.8 then
		anim = prefix .. "Tear4"
	elseif scale <= 0.925 then
		anim = prefix .. "Tear5"
	elseif scale <= 1.05 then
		anim = prefix .. "Tear6"
	elseif scale <= 1.175 then
		anim = prefix .. "Tear7"
	elseif scale <= 1.425 then
		anim = prefix .. "Tear8"
	elseif scale <= 1.675 then
		anim = prefix .. "Tear9"
	elseif scale <= 1.925 then
		anim = prefix .. "Tear10"
	elseif scale <= 2.175 then
		anim = prefix .. "Tear11"
	elseif scale <= 2.55 then
		anim = prefix .. "Tear12"
	else
		anim = prefix .. "Tear13"
	end

    mod:spritePlay(sprite, anim)
    projectile.SpriteRotation = projectile.Velocity:GetAngleDegrees()
end

function mod:FrogProjectileDeath(projectile, sprite)
    local splatvar = 12
    if projectile.Variant == mod.FF.FrogProjectileBlood.Var then
		splatvar = 11
	end

    local splat = Isaac.Spawn(1000, splatvar, 0, projectile.Position, Vector.Zero, projectile)
    splat.Color = projectile.Color
    splat.SpriteScale = Vector(projectile.Scale * 0.8, projectile.Scale * 0.8)
    splat.PositionOffset = projectile.PositionOffset

    sfx:Play(SoundEffect.SOUND_TEARIMPACTS)
end

function mod:TemporarySpikes(effect, sprite, data)
    local room = game:GetRoom()

    if not data.Init then
        sprite:Play("Warn")
        effect.DepthOffset = -1000
        data.Index = room:GetGridIndex(effect.Position)
        data.Init = true
    end

    if sprite:IsPlaying("Spikes") then
        data.Duration = data.Duration or 60
        data.Duration = data.Duration - 1
        if data.Duration <= 0 or room:IsClear() then
            sprite:Play("Unsummon")
        end
    end

    if sprite:IsFinished("Summon") then
        sprite:Play("Spikes")
    elseif sprite:IsFinished("Unsummon") then
        effect:Remove()
    end

    if sprite:IsEventTriggered("Shoot") then
        if sprite:IsPlaying("Summon") then
            data.Damaging = true
        elseif sprite:IsPlaying("Unsummon") then
            data.Damaging = false
        end
    end

    if data.Damaging then
        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            if room:GetGridIndex(player.Position) == data.Index and mod:ShouldTakeSpikesDamage(player) then
                player:TakeDamage(2, DamageFlag.DAMAGE_SPIKES, EntityRef(effect.SpawnerEntity), 0)
            end
        end
    end
end

function mod:ShouldTakeSpikesDamage(player) -- mfw CollectibleType.COLLECTIBLE_SOCKS
    return (not (player:IsFlying() or player:HasCollectible(CollectibleType.COLLECTIBLE_SOCKS) or player:HasTrinket(TrinketType.TRINKET_CALLUS)))
end

function mod:PigskinProjectile(projectile, sprite, data)
    mod:spritePlay(sprite, "Move")
    data.Target.Velocity = projectile.Position - data.Target.Position
    projectile.SpriteScale = Vector(projectile.Scale, projectile.Scale)

    if data.CCSpin then
        projectile.SpriteRotation = projectile.SpriteRotation - 2
    else
        projectile.SpriteRotation = projectile.SpriteRotation + 2
    end

    if projectile.Height >= -10 then
        mod:PlaySound(SoundEffect.SOUND_JELLY_BOUNCE, nil, 1.5, 0.5)
        local wave = {}
        wave.Source = projectile.SpawnerEntity
        wave.Position = projectile.Position
        wave.Angle = data.FartAngle
        table.insert(mod.FartWaves, wave)

        if projectile.Scale > 0.6 then
            local targetpos = Vector(data.XCord, game:GetNearestPlayer(projectile.Position).Position.Y)
            local new = Isaac.Spawn(9, projectile.Variant, 0, projectile.Position, (targetpos - projectile.Position) * 0.025, projectile.SpawnerEntity):ToProjectile()
            new.Color = projectile.Color
            new.Scale = projectile.Scale - 0.1
            new.FallingSpeed = -30
            new.FallingAccel = 1
            new.Height = projectile.Height
            new.ProjectileFlags = projectile.ProjectileFlags
            new.SpriteRotation = projectile.SpriteRotation
            new:GetData().projType = data.projType
            new:GetData().XCord = data.XCord
            new:GetData().CCSpin = (rng:RandomFloat() <= 0.5)
            new:GetData().FartAngle = data.FartAngle
            data.Target.Parent = new
            new:GetData().Target = data.Target
            projectile:Remove()
        else
            projectile:Die()
            local splat = Isaac.Spawn(1000, 2, 2, projectile.Position, Vector.Zero, projectile)
            splat.Color = mod.ColorToxicFart
            splat.SpriteOffset = projectile.PositionOffset
            splat:Update()
            local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, projectile.Position, Vector(0, -1), projectile)
            effect:GetData().longonly = true
            effect.Color = Color(0.5, 0.5, 0.5, 1)
            effect.SpriteOffset = projectile.PositionOffset
            effect:Update()
            sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF)
        end
    end
end

function mod:FartWaveUpdate(wave)
    local room = game:GetRoom()
    wave.Timer = wave.Timer or 0
    wave.Timer = wave.Timer - 1

    if wave.Timer <= 0 then
        wave.Position = wave.Position + Vector(40,0):Rotated(wave.Angle)
        if room:IsPositionInRoom(Vector(wave.Position.X, room:GetCenterPos().Y),0) then
            game:ButterBeanFart(wave.Position, 70, wave.Source, true, true)
            wave.Timer = 2
        else
            wave = nil
        end
    end
end

function mod:PigskinTarget(effect, sprite, data)
    if not (effect.Parent and effect.Parent:Exists()) then
        effect:Remove()
    end
end