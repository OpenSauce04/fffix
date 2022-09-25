local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:BlareAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()

    if not data.Init then
        data.State = "HorfIdle"
        data.WakeUpTimer = mod:RandomInt(300,450,rng)
        npc.StateFrame = mod:RandomInt(20,40,rng)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.Init = true
    end

    if data.State == "HorfIdle" then
        mod:spritePlay(sprite, "Idle01")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 200 then
                data.State = "HorfShoot"
            end
        end
    elseif data.State == "HorfShoot" then
        if sprite:IsFinished("Shoot01") then
            data.State = "HorfIdle"
            npc.StateFrame = mod:RandomInt(20,40,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            local params = ProjectileParams()
            params.HeightModifier = 15
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(7), 0, params)

            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(0,3)
            effect.Color = Color(1,1,1,0.8)
            effect.DepthOffset = npc.Position.Y * 1.25

            mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc)
        else
            mod:spritePlay(sprite, "Shoot01")
        end
    elseif data.State == "Transform" then
        if sprite:IsFinished("Transform") then
            npc.StateFrame = mod:RandomInt(60,90,rng)
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.Transformed = true
            mod:SetCollisionDamage(npc, 2)
            data.Speed = 5.5
            data.State = "MonsterIdle"
            mod:spriteOverlayPlay(sprite, "IdleHead")
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.6)
            mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 0.6)
            mod:PlaySound(mod.Sounds.StretchEye, npc, 1.5)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_BONE_BREAK, npc, 0.8)
            mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 0.8)
            for i = 0, 5 do
                Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector() * rng:RandomFloat() * 6, npc)
            end
        else
            mod:spritePlay(sprite, "Transform")
        end
    elseif data.State == "MonsterIdle" then
        mod:spriteOverlayPlay(sprite, "IdleHead")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 300 then
                data.State = "MonsterShoot"
                data.Speed = 2.5
            end
        end
    elseif data.State == "MonsterShoot" then
        if sprite:IsOverlayFinished("ShootHead") then
            npc.StateFrame = mod:RandomInt(60,90,rng)
            data.Speed = 5.5
            data.Shooted = false
            data.State = "MonsterIdle"
        elseif sprite:GetOverlayFrame() == 10 and not data.Shooted then
            local params = ProjectileParams()
            params.Scale = 1.5
            params.Spread = 0.8
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 1, params)

            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(-6,-28)
            effect.Color = Color(1,1,1,0.8)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect:FollowParent(npc)

            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.4)
            mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 0.35)
            data.Shooted = true
        else
            mod:spriteOverlayPlay(sprite, "ShootHead")
        end
    end

    if data.Transformed then
        local anim
        if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(data.Speed)), 0.25)
        else
            npc.Pathfinder:FindGridPath(targetpos, (data.Speed * 0.1) + 0.2, 900, true)
        end
        if npc.Velocity:Length() >= 0.1 then
            anim = "WalkBody"
            if npc.Velocity.X < 0 then
                anim = anim .. "Flip"
            end
        else
            anim = "IdleBody"             
            if targetpos.X < npc.Position.X then
                anim = anim .. "Flip"
            end
        end

        mod:spritePlay(sprite, anim)
    else
        npc.Velocity = npc.Velocity * 0.5

        data.WakeUpTimer = data.WakeUpTimer - 1
        if (room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 40) or data.WakeUpTimer <= 0 or npc.HitPoints < (npc.MaxHitPoints * 0.9) then
            mod:ProvokeBlare(npc, data) 
        end
    end

    mod.QuickSetEntityGridPath(npc, 900)
    if npc.FrameCount % 15 == 5 then
        Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
    end
end

function mod:SetCollisionDamage(npc, amount)
    local min = 1
    if npc:GetChampionColorIdx() == 19 or npc:GetChampionColorIdx() == 23 then
        min = 4
    elseif npc:IsChampion() then
        min = 2
    end
    npc.CollisionDamage = math.max(min, amount)
end

function mod:ProvokeBlare(npc, data)
    data.State = "Transform"
    data.Provoked = true

    for _, blare in pairs(Isaac.FindByType(mod.FF.Blare.ID, mod.FF.Blare.Var)) do
        if blare:GetData().WakeUpTimer then
            blare:GetData().WakeUpTimer = math.min(blare:GetData().WakeUpTimer, mod:RandomInt(15,30))
        end
    end
end