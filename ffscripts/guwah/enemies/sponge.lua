local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:SpongeAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local player = game:GetPlayer(0)
    local targetpos = npc:GetPlayerTarget().Position
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.SplatColor = mod.ColorLemonYellow
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        data.size = 1
        data.Buffer = 0
        data.Lerp = 1
        data.SpeedCap = 15
        data.state = "orbit"
        data.Params = ProjectileParams()
        data.Params.Variant = 4
        data.Params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        data.Params.CircleAngle = 0
        mod:RecalculateSpongeOrbiting(player)
        data.Init = true
    end
    data.Angle = mod:NormalizeDegrees(data.Angle + 3)
    if data.state == "orbit" then
        --Movement
        local targetangle = data.Angle
        local targoffset = Vector(90,0):Rotated(targetangle)
        npc.TargetPosition = player.Position + targoffset
        local movepos = npc.TargetPosition
        if npc.Position:Distance(player.Position) <= 100 and npc.Position:Distance(npc.TargetPosition) > 15 then --Code wasteland help (thank you Dead)
            local currentangle = mod:GetAngleDegreesButGood(npc.Position - player.Position)
            local angleshift = mod:GetAngleDifferenceDead(targoffset, (npc.Position - player.Position))
            angleshift = (angleshift/math.abs(angleshift)) * (math.min(math.abs(angleshift), 15)) --Minimizes to 15 while retaining sign
            targetangle = currentangle + angleshift
            movepos = player.Position + Vector(90,0):Rotated(targetangle)
        end
        local vec = movepos - npc.Position
        npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(math.min(vec:Length(), data.SpeedCap)), data.Lerp)

        --Growing
        if data.Buffer >= 6 and data.size < 2 then
            data.growing = true
            data.attacktimer = 90
            data.SpeedCap = 8
            data.Lerp = 0.2
        elseif data.Buffer >= 12 and data.size < 3 then
            data.growing = true
            data.attacktimer = 60
            data.SpeedCap = 5
            data.Lerp = 0.1
        elseif data.Buffer >= 18 and data.size < 4 then
            data.growing = true
            data.attacktimer = 30
            data.SpeedCap = 2
            data.Lerp = 0.05
        end

        --Animation / Attack Timer
        if not sprite:IsPlaying("Appear") then
            if data.growing then
                if sprite:IsFinished("Grow"..data.size) then
                    data.size = data.size + 1
                    data.growing = false
                elseif sprite:IsEventTriggered("Sound") then
                    npc:PlaySound(mod.Sounds.BaloonBounce, 0.8, 0, false, 1 + (0.5 * data.size))
                else
                    mod:spritePlay(sprite, "Grow"..data.size)
                end
            else
                if data.attacktimer then
                    data.attacktimer = data.attacktimer - 1
                    if data.attacktimer <= 0 then
                        data.state = "shoot"
                        --mod:RecalculateSpongeOrbiting(game:GetPlayer(0))
                    end
                end
                mod:spritePlay(sprite, "Idle"..data.size)
            end
        end
    elseif data.state == "shoot" then
        npc.Velocity = Vector.Zero
        if sprite:IsFinished("Shoot"..data.size) then
            data.state = "orbit"
            data.attacktimer = nil
            data.splatsounded = false
            data.size = 1
            data.Buffer = 0
            data.Lerp = 1
            data.SpeedCap = 15
            --mod:RecalculateSpongeOrbiting(game:GetPlayer(0))
        elseif sprite:IsEventTriggered("Shoot") or (data.shooting and sprite:GetFrame() % 2 == 0) then
            --Bullets
            for i = 1, 6 do 
                local shootvec = Vector(8, 0):Rotated((360 / 6) * i)
                if data.size > 2 then
                    shootvec = shootvec:Rotated(mod:RandomInt(-6,6,rng))
                end
                npc:FireProjectiles(npc.Position, shootvec, 0, data.Params)
            end

            --Effects
            local spawnpos = npc.Position
            if data.size > 3 then
                spawnpos = spawnpos + (RandomVector() * mod:RandomInt(0,100,rng))
            end
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, spawnpos, Vector.Zero, npc)
            effect.Color = mod.ColorLessSolidWater

            --Sound
            npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, mod:RandomInt(9,11,rng)/10)
            if not data.splatsounded then
                npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, mod:RandomInt(9,11,rng)/10)
                data.splatsounded = true
            end
        else
            mod:spritePlay(sprite, "Shoot"..data.size)
        end
        if data.size >= 4 then
            if sprite:IsEventTriggered("Shoot") then
                data.shooting = true
            elseif sprite:IsEventTriggered("End") then
                data.shooting = false
            end
        end
    end
    if mod:IsReallyDead(npc) then
        npc:GetData().state = "dead"
    end
end

function mod:SpongeColl(npc, collider)
    if collider.Type == 1 then
        return true
    end
end

function mod:SpongeHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    data.Buffer = data.Buffer or 0
    data.Buffer = data.Buffer + amount
    if data.attacktimer and data.size < 4 then --Taking damage increases attack timer a bit unless at max size
        data.attacktimer = data.attacktimer + (amount * (5 - data.size))
    end
end

function mod:SpongeRemove(npc)
    npc:GetData().state = "dead"
    mod:RecalculateSpongeOrbiting(game:GetPlayer(0))
end

function mod:RecalculateSpongeOrbiting(player)
    player:GetData().SpongeAngle = player:GetData().SpongeAngle or 0
    local sorttable = {}
    for _, sponge in pairs(Isaac.FindByType(mod.FF.Sponge.ID, mod.FF.Sponge.Var, -1)) do
        if sponge:GetData().state == "orbit" and not sponge:IsDead() then
            local angle = mod:GetAngleDegreesButGood(sponge.Position - player.Position)
            table.insert(sorttable, {sponge, angle})
        end
    end
    table.sort(sorttable, function( a, b ) return a[2] < b[2] end )
    for i = 1, #sorttable do
        local d = sorttable[i][1]:GetData()
        d.Angle = mod:NormalizeDegrees(((360 / #sorttable) * i) + player:GetData().SpongeAngle)
    end
end