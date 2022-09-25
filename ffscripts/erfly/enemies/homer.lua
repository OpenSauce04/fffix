local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:homerAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()
    
    if not d.init then
        d.state = "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
        npc.CollisionDamage = 0
    end

    npc.SpriteOffset = Vector(0,-10)

    if d.state == "idle" then
        mod:spritePlay(sprite, "Idle01")

        if npc.Velocity.X > 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end

        local targpos = mod:confusePos(npc, target.Position)
        local targvel = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(2))
        npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.05)

        if (not (mod:isScareOrConfuse(npc) or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE))) and ((r:RandomInt(10)+1 == 1 and npc.StateFrame > 10) or npc.StateFrame > 60) and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) then
            d.state = "attack"
            d.keepflippin = true
        end
    elseif d.state == "attack" then
        if d.keepflippin then
            if target.Position.X > npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        end
        if sprite:IsFinished("Shoot") then
            d.state = "asslessChap"
        elseif sprite:IsEventTriggered("Shoot") then
            d.keepflippin = false
            npc:PlaySound(mod.Sounds.FrogShoot,1,0,false,math.random(9,11)/10)
            local vec = (target.Position - npc.Position):Resized(7)
            local stinger = mod.spawnent(npc, npc.Position + vec:Resized(20), vec, mod.FF.StingerProjHoming.ID, mod.FF.StingerProjHoming.Var, mod.FF.StingerProjHoming.Sub)
            stinger:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            stinger.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            stinger.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            stinger.Parent = npc
            stinger:GetData().target = target
            stinger:Update()
            --npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif d.state == "asslessChap" then
        mod:spritePlay(sprite, "Idle02")
        if npc.Velocity.X > 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end

        d.gridtarget = d.gridtarget or mod:FindRandomFreePos(target, 120)
        local targetvel = (d.gridtarget - npc.Position):Resized(2)

        if npc.FrameCount % 3 == 1 then
            local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
            blood.SpriteScale = Vector(0.4,0.4)
            blood:Update()
        end

        if npc.FrameCount % 30 == 1 then
            npc:TakeDamage(0.5, 0, EntityRef(npc), 0)
            for _ = 1, 2 do
                Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector():Resized(r:RandomFloat()*6), npc)
            end
        end

        if npc.Position:Distance(target.Position) < 120 or mod:isScare(npc) then
            targetvel = (target.Position - npc.Position):Resized(-8)
            d.running = true
        else
            if npc.Position:Distance(d.gridtarget) < 20 or (npc.StateFrame % 120 == 0 and game:GetRoom():GetGridCollisionAtPos(npc.Position) < 2) or d.running or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
                d.gridtarget = mod:FindRandomFreePos(target, 120)
                targetvel = (d.gridtarget - npc.Position):Resized(2)
                d.running = false
            end
        end

        npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
    end
end

function mod:homingStingerProjectileAI(npc)
    local d = npc:GetData()

    if not d.init then
        d.target = d.target or npc:GetPlayerTarget()
        d.init = true
        npc.SpriteOffset = Vector(0, -15)
        d.speed = math.random(100,120) / 10
        d.lerpquality = math.random(800, 1000) / 10000
    end

    d.speed = 8.5 + math.sin(npc.FrameCount / 10) * 6
    mod:spritePlay(npc:GetSprite(), "Idle")

    npc.SpriteOffset = Vector(0, -15)

        if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.1, 0, true, 1.8)
        end

    local parentdead
    if npc.Parent then
        if npc.Parent:IsDead() or mod:isStatusCorpse(npc.Parent) then
            parentdead = true
        end
    else
        parentdead = true
    end
    if parentdead then
        sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
        local effect = Isaac.Spawn(1000,7014,1,npc.Position,nilvector,nil)
        effect.SpriteRotation = npc.SpriteRotation
        effect:Update()
        npc:Remove()
    end

    local targetvel = (d.target.Position - npc.Position):Resized(d.speed * mod.slowestPlayerSpeed(0.7, 1))
    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, d.lerpquality)
    if npc.Velocity:Length() > 10 then
        npc.Velocity = npc.Velocity:Resized(10)
    end
    npc.SpriteRotation = npc.Velocity:GetAngleDegrees() + 180
end