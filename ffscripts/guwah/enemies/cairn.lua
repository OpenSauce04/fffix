local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:CairnAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc.SplatColor = mod.ColorFireJuicy
        data.Suffix = npc.Variant - 40 + 1
        data.FireCooldown = 0
        data.State = "Chase"
        data.Init = true
    end

    if data.State == "Chase" then
        if mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(10 - data.Suffix), 0.05)
            mod:spritePlay(sprite, "Walk0"..data.Suffix)
        else
            if mod:CatheryPathFinding(npc, targetpos, {
                Speed = 10 - data.Suffix,
                Accel = 0.05,
                GiveUp = true,
                }) 
            then
                mod:spritePlay(sprite, "Walk0"..data.Suffix)
            else
                mod:spritePlay(sprite, "Idle0"..data.Suffix)
            end
        end

        if data.Suffix == 3 and npc.HitPoints <= 40 then
            data.FlinchAnim = "Flinch01"
            mod:spritePlay(sprite, data.FlinchAnim)
            data.State = "Stagger"
        elseif data.Suffix == 2 and npc.HitPoints <= 20 then
            data.FlinchAnim = "Flinch02"
            mod:spritePlay(sprite, data.FlinchAnim)
            data.State = "Stagger"
        end
    elseif data.State == "Stagger" then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished(data.FlinchAnim) then
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Shoot") then
            mod:ThrowCoalscoopCoal(npc, npc.Velocity:Rotated(180 + mod:RandomInt(-15,15,rng)):Resized(mod:RandomInt(3,5)), 4 - data.Suffix, mod:RandomInt(-4,-2,rng), -70 + ((4 - data.Suffix) * 20))
            local flames = mod:RandomInt(2,3,rng)
            for i = 360/flames, 360, 360/flames do
                local fire = Isaac.Spawn(33,10,0,npc.Position,Vector(3.5,0):Rotated(i + mod:RandomInt(-15,15,rng)),npc)
                fire.HitPoints = fire.MaxHitPoints / 1.5
                fire:Update()
            end
            mod:PlaySound(SoundEffect.SOUND_BEAST_LAVABALL_RISE, npc, 1)
            data.Suffix = data.Suffix - 1
        else
            mod:spritePlay(sprite, data.FlinchAnim)
        end
    end

    if npc:IsDead() then
        for i = data.Suffix, 1, -1 do
            mod:ThrowCoalscoopCoal(npc, npc.Velocity:Rotated(180 + mod:RandomInt(-15,15,rng)):Resized(mod:RandomInt(3,5)), 4 - i, mod:RandomInt(-4,-2,rng), -70 + ((4 - data.Suffix) * 20))
        end
        mod:PlaySound(SoundEffect.SOUND_BEAST_LAVABALL_RISE, npc, 1)
    end

    data.FireCooldown = data.FireCooldown - 1
    if npc:CollidesWithGrid() and npc.Velocity:Length() > 1 and data.FireCooldown <= 0 then
        local fire = Isaac.Spawn(33,10,0,npc.Position,npc.Velocity:Rotated(180 + mod:RandomInt(-15,15,rng)):Resized(2.5),npc)
        fire.HitPoints = fire.MaxHitPoints / 1.5
        fire:Update()
        data.FireCooldown = 10
    end
end

function mod:ThrowCoalscoopCoal(npc, vel, suffix, z_vel, z_init)
    local coal = Isaac.Spawn(mod.FF.CoalscoopCoal.ID, mod.FF.CoalscoopCoal.Var, 0, npc.Position, vel, npc)
    local data = coal:GetData()
    local bounce = z_vel * 0.75
    data.Suffix = suffix
    data.Airborne = true
    data.isthrown = true
	data.z_vel = z_vel
	data.launchedEnemyInfo = {zVel = z_vel, height = z_init, collision = -30}
	data.launchedEnemyInfo.vel = vel
    data.playerobjectscoll = true
    data.launchedEnemyInfo.landFunc = function(npc, tab)
        data.launchedEnemyInfo = {zVel = bounce, landFunc = function() 
            data.launchedEnemyInfo = {zVel = bounce*0.3} 
            data.Airborne = false
        end}
    end
    coal:Update()
end

function mod:CoalscoopCoalUpdate(npc, sprite, data)
    if not data.Init then
        npc.SplatColor = mod.ColorFireJuicy
        data.Suffix = data.Suffix or 1
        local sprite = Sprite()
        sprite:Load("gfx/enemies/coalscoop/monster_coalscoop_coal.anm2")
        sprite:Play("Fire0"..data.Suffix, true)
        data.FireSprite = sprite
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_REWARD)

        data.Init = true
    end
    if data.Airborne then
        npc.Velocity = npc.Velocity * 0.9
        mod:spritePlay(sprite, "InAir0"..data.Suffix)
    else
        npc.Velocity = npc.Velocity * 0.5
        mod:spritePlay(sprite, "Dead0"..data.Suffix)
    end
    data.FireSprite:Update()
    if npc.FrameCount % 30 == 25 or game:GetRoom():IsClear() then
        npc:TakeDamage(0.5, DamageFlag.DAMAGE_CLONES, EntityRef(nil), 0)
    end
end

mod.IsCoalscoopSecondRender = false

function mod:CoalscoopCoalRender(npc, sprite, data, isPaused, isReflected, offset)
    if data.Init and not mod.IsCoalscoopSecondRender then
        mod.IsCoalscoopSecondRender = true
        local scale = math.max(0, npc.HitPoints / npc.MaxHitPoints)
        local height = 0
        if data.launchedEnemyInfo and data.launchedEnemyInfo.height then
            height = data.launchedEnemyInfo.height * 1.5 --Why do i have to multiply it why does this work perfectly all of the sudden
        end
        local spritescale = math.max(0.2, (scale * 0.8) + 0.2)
        data.FireSprite.Scale = Vector(spritescale, spritescale)
        data.FireSprite:Render(Isaac.WorldToScreen(npc.Position + Vector(0, height)))
        local colorscale = math.max(0.5, (scale * 0.5) + 0.5)
        sprite.Color = Color(colorscale,colorscale,colorscale)
        npc:Render(offset)
    end
    mod.IsCoalscoopSecondRender = false
end

function mod:CoalscoopCoalHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(damageFlags, DamageFlag.DAMAGE_FIRE) then
        return false
    else
        local data = npc:GetData()
        if data.Suffix and not mod:HasDamageFlag(damageFlags, DamageFlag.DAMAGE_CLONES) then
            npc:TakeDamage(math.min(amount, 1.7 - (data.Suffix * 0.2)), damageFlags | DamageFlag.DAMAGE_CLONES, source, 0)
            return false
        end
    end
end

function mod:DealFireCollisionDamage(npc, collider)
    if collider:ToPlayer() then
        collider:TakeDamage(1, DamageFlag.DAMAGE_FIRE, EntityRef(npc), 0)
    end
end