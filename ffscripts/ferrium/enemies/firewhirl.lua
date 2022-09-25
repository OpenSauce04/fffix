local mod = FiendFolio
local sfx = SFXManager()

function mod:firewhirlAI(npc)
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local rng = npc:GetDropRNG()
    local sprite = npc:GetSprite()

    if not data.init then
        data.state = "Idle"
        data.init = true
        npc:PlaySound(SoundEffect.SOUND_FLAME_BURST, 0.4, 0, false, 1.5)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if data.state == "Idle" then
        if npc.StateFrame > 50 and rng:RandomInt(50) == 0 and not mod:isScareOrConfuse(npc) then
            data.state = "Start"
        elseif npc.StateFrame > 100 and not mod:isScareOrConfuse(npc) then
            data.state = "Start"
        end


        if npc.StateFrame % 30 == 0 or not data.targetVel then
			local targpos = mod:FindRandomFreePosAir(npc.Position, 120)
			data.targetVel = (targpos - npc.Position):Resized(1.5)
		end
        if mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-target.Position):Resized(2.5), 0.3)
        else
            npc.Velocity = mod:Lerp(npc.Velocity, data.targetVel, 0.1)
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
        mod:spritePlay(sprite, "Idle")
    elseif data.state == "Spinning" then
        if npc.StateFrame > 170 then
            data.state = "End"
        end

        if npc.StateFrame % 26 == 0 then
            local params = ProjectileParams()
            params.Variant = 1
            params.HeightModifier = -5
            params.FallingAccelModifier = 0
            params.FallingSpeedModifier = -4
            params.BulletFlags = params.BulletFlags | ProjectileFlags.NO_WALL_COLLIDE
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position+mod:shuntedPosition(40,rng), Vector.Zero, 0, params)
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                proj:GetData().ashSpawn = true
                proj.Parent = npc
                proj:GetData().target = target
                proj:Update()
            end
        end

        for _, player1 in ipairs(Isaac.FindByType(1,-1,-1, false, true)) do
            local player = player1:ToPlayer()
            local strength = math.min(1.2, math.max(0, (500-npc.Position:Distance(player.Position))/400))

            if player.MoveSpeed < 1 then
                strength = strength*player.MoveSpeed
            end

            if not player:GetData().firewhirlPull then
                player:GetData().firewhirlPull = (npc.Position-player.Position):Resized(strength)
            else
                player:GetData().firewhirlPull = mod:Lerp(player:GetData().firewhirlPull, (npc.Position-player.Position):Resized(strength), 0.5)
            end
            --player.Velocity = mod:Lerp(player.Velocity, player:GetData().firewhirlPull, 0.1)
        end

        local targVel = (targetpos-npc.Position):Resized(math.min(2, npc.Position:Distance(targetpos)/50))
        npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.2)

        mod:spritePlay(sprite, "Spin")
    elseif data.state == "Start" then
        if sprite:IsFinished("SpinStart") then
            data.state = "Spinning"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "SpinStart")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
    elseif data.state == "End" then
        if sprite:IsFinished("SpinEnd") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "SpinEnd")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
    end

    --[[if npc.FrameCount % 40 == 0 then
        local params = ProjectileParams()
        params.Variant = 1
        params.HeightModifier = -5
        params.FallingAccelModifier = 0
        params.FallingSpeedModifier = -4
        mod:SetGatheredProjectiles()
		npc:FireProjectiles(npc.Position+mod:shuntedPosition(40,rng), Vector.Zero, 0, params)
		for _, proj in pairs(mod:GetGatheredProjectiles()) do
            proj:GetData().ashSpawn = true
            proj.Parent = npc
            proj:GetData().target = target
            proj:Update()
        end
    end]]
end

function mod:firewhirlPullUpdate(player, data)
    if data.firewhirlPull then
        player.Velocity = mod:Lerp(player.Velocity, data.firewhirlPull, 0.1)

        local pulling = false
        for _, fireswirl in ipairs(Isaac.FindByType(mod.FF.Firewhirl.ID, mod.FF.Firewhirl.Var, -1, false, true)) do
            if fireswirl:GetData().state == "Spinning" then
                pulling = true
            end
        end

        if not pulling then
            data.firewhirlPull = nil
        end
    end
end

--1000, 133 - ripple

function mod.ashSpawnProj(v, d)
    if d.ashSpawn then
        if not d.ashInit then
            d.state = "Spawning"
            v.Height = -5
            v.FallingAccel = 0
            v.FallingSpeed = -4
            v.Color = Color(v.Color.R,v.Color.G,v.Color.B,0,v.Color.RO,v.Color.BO,v.Color.GO)
            d.ashStateFrame = 0

            local ripple = Isaac.Spawn(1000, 133, 0, v.Position, Vector.Zero, v):ToEffect()
            ripple.Color = Color(0.7,0.61,0.2,1,0.3,0.1,0)
            sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)

            d.ashInit = true
        else
            d.ashStateFrame = d.ashStateFrame+1
        end

        if d.state == "Spawning" then
            v.FallingSpeed = -4
            v.FallingAccel = 0

            if v.Color.A < 1 then
                v.Color = Color(v.Color.R,v.Color.G,v.Color.B,v.Color.A+20/255,v.Color.RO,v.Color.BO,v.Color.GO)
            end
            if d.ashStateFrame > 8 then
                d.state = "Waiting"
                v.FallingSpeed = 0
                d.ashStateFrame = 0
            end

            v.Velocity = mod:Lerp(v.Velocity, v.Parent.Velocity, 0.1)
        elseif d.state == "Waiting" then
            v.FallingSpeed = 0
            v.FallingAccel = 0
            if d.ashStateFrame > 5 then
                v.Velocity = (d.target.Position-v.Position):Resized(d.ashVel or 13)
                v:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
                d.state = "Finished"
                v.FallingSpeed = -8
                v.FallingAccel = 0.8
                sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
            end
            v.Velocity = mod:Lerp(v.Velocity, v.Parent.Velocity, 0.1)
        end

        if v.FrameCount % 2 == 0 then
            local ember = Isaac.Spawn(1000, 66, 0, v.Position+mod:shuntedPosition(10), RandomVector(), v):ToEffect()
            ember.SpriteOffset = Vector(0, v.Height+12)
        end
        if v.FrameCount % 3 == 0 and v.FrameCount > 2 then
            local trail = Isaac.Spawn(1000, 111, 0, v.Position, RandomVector()*2, v):ToEffect()
            trail.Color = Color(0.95,1,0.2,1,0.3,0.5,0)
            local scaler = v.Scale*math.random(75,90)/100
            trail.SpriteScale = Vector(scaler, scaler)
            trail.SpriteOffset = Vector(0, v.Height+12)
            trail.DepthOffset = -80
            trail:Update()
        end

        if not v.Parent or v.Parent:IsDead() or mod:isStatusCorpse(v.Parent) then
            v:Die()
        end
    end
end