local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:RingLeaderAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:Play("Appear")
        npc.SplatColor = mod.ColorMinMinFireJuicier
        npc.StateFrame = mod:RandomInt(40,60)
        data.Willos = {}
        data.RotBuffer = 0
        mod:AddSoundmakerFly(npc)
        data.Init = true
    end
    if sprite:IsPlaying("Appear") then
        npc.Velocity = Vector.Zero
    else
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(2)), 0.3)
        if sprite:IsPlaying("Fly") then
            if npc.StateFrame <= 0 then
                sprite:Play("Attack")
                npc.StateFrame = mod:RandomInt(110,130)
            else
                npc.StateFrame = npc.StateFrame - 1
            end
        end
    end
    if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") then
        sprite:Play("Fly")
    end
    if sprite:IsEventTriggered("Summon") then
        local angle = mod:RandomAngle()
        data.RotBuffer = angle
        for i = 0, npc.SubType - 1 do
            if i == 1 then
                data.StartAngle = angle
            end
            mod:AddRingWillo(npc, angle, i)
            angle = angle + (360/npc.SubType)
        end
        sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
    elseif sprite:IsEventTriggered("Respawn") then
        local canRespawn = true
        for index, willo in pairs(data.Willos) do
            if willo:IsDead() then
                if canRespawn then  
                    local angle = data.RotBuffer + ((360/npc.SubType)*index)
                    mod:AddRingWillo(npc, angle, index)
                    canRespawn = false
                end
            end
        end
        sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT)
    elseif sprite:IsEventTriggered("Command") then
        for index, willo in pairs(data.Willos) do
            willo:GetSprite():Play("Attack")
        end
        mod:PlaySound(SoundEffect.SOUND_FIRE_RUSH, npc, 1.2, 0.8)
    elseif sprite:IsEventTriggered("Rotate") then
        local rotation = mod:RandomInt(60,120)
        if rng:RandomFloat() <= 0.5 then
            rotation = -rotation
        end
        data.RotBuffer = data.RotBuffer + rotation
        for index, willo in pairs(data.Willos) do
            if not willo:IsDead() then
                local willodata = willo:GetData()
                willodata.RingGoal = willodata.RingAngle + rotation
                willodata.RingInterval = (willodata.RingGoal - willodata.RingAngle) / 5
            end
        end
        sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
    end
end

function mod:AddRingWillo(npc, angle, index)
    local willo = Isaac.Spawn(808,0,0,npc.Position,Vector.Zero,npc):ToNPC()
    willo:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    willo:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
    willo:GetSprite():Play("Appear")
    willo:GetData().RingLeader = npc
    willo:GetData().RingAngle = angle
    npc:GetData().Willos[index] = willo
end

function mod:RingWilloAI(npc, sprite, data)
    local target = data.RingLeader:GetPlayerTarget()
    local targetpos = mod:confusePos(data.RingLeader, target.Position)
    if mod:isFriend(data.RingLeader) then
        npc:AddCharmed(EntityRef(data.RingLeader), -1)
    end
    if data.RingGoal and math.abs(data.RingAngle - data.RingGoal) > 1 then
        data.RingAngle = data.RingAngle + data.RingInterval
    end
    npc.TargetPosition = data.RingLeader.Position + Vector(100,0):Rotated(data.RingAngle)
    local vel = npc.TargetPosition - npc.Position
    if vel:Length() > 30 then 
        vel = vel:Resized(30)
    end
    npc.Velocity = vel
    if sprite:IsEventTriggered("Warn") then
        sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT)
    elseif sprite:IsEventTriggered("Shoot") then
        local params = ProjectileParams()
        params.Variant = 4
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        params.Color = FiendFolio.ColorMinMinFire
        npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(8), 0, params)
        sfx:Play(SoundEffect.SOUND_TEARS_FIRE)
    end
    if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") then
        sprite:Play("Fly")
    end
end