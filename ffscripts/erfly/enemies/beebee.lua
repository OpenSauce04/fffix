local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local beebeeDirs = {
    ["Down"] = Vector(0,1),
    ["Up"] = Vector(0,-1),
    ["Hori"] = Vector(1,0),
}

function mod:beebeeAI(npc)
    local sprite, d, target = npc:GetSprite(), npc:GetData(), npc:GetPlayerTarget()

    if not d.init then
        d.state = "idle"
        d.init = true
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        if npc.SubType < 4 then
            npc.Velocity = Vector.One:Rotated(npc.SubType * 90)
        elseif npc.SubType == 4 then
            npc.Velocity = RandomVector()
        end
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        if not (sprite:IsPlaying("ShootDown") or sprite:IsPlaying("ShootHori") or sprite:IsPlaying("ShootUp")) then
            mod:spritePlay(sprite, "WalkIdle")
        end
        local targvel = mod:diagonalMove(npc, 5, true)
        d.lerpness = d.lerpness or 0.1
        d.lerpness = math.min(d.lerpness + 0.005, 0.1)
        npc.Velocity = mod:Lerp(npc.Velocity, targvel, d.lerpness)

        if npc.StateFrame > 30 and not mod:isScareOrConfuse(npc) then
            local chargeMargin = 50
            if math.abs(target.Position.X - npc.Position.X) < chargeMargin then
                d.targChargeStart = Vector(target.Position.X, npc.Position.Y)
                if target.Position.Y > npc.Position.Y then
                    d.dir = "Down"
                else
                    d.dir = "Up"
                end
            elseif math.abs(target.Position.Y - npc.Position.Y) < chargeMargin then
                d.dir = "Hori"
                d.targChargeStart = Vector(npc.Position.X, target.Position.Y)
                if target.Position.X > npc.Position.X then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                    d.spriteWasFlipped = true
                end
            end
            if d.dir then
                d.state = "charge"
                sprite:Play("Charge" .. d.dir .. "Start")
            end
        end
    elseif d.state == "waitingForSomethingToHappen" then
        mod:spritePlay(sprite, "WalkIdle")
        npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(math.random(10)/10):Rotated(-30 + math.random(60)), 0.2)
        npc.Velocity = npc.Velocity * 0.8
        if npc.StateFrame > 20 or d.Stingerless or mod:isScareOrConfuse(npc) or mod:isCharm(npc) then
            npc.StateFrame = 0
            d.state = "idle"
            d.spriteWasFlipped = nil
            d.dir = nil
            d.lerpness = 0.015
        else
            local chargeMargin = 150
            if (d.dir == "Up" or d.dir == "Down") and math.abs(target.Position.X - npc.Position.X) < chargeMargin then
                d.spriteWasFlipped = false
                if target.Position.Y > npc.Position.Y then
                    d.dir = "Up"
                    d.state = "shootout"
                else
                    d.dir = "Down"
                    d.state = "shootout"
                end
            elseif d.dir == "Hori" and math.abs(target.Position.Y - npc.Position.Y) < chargeMargin then
                if (not d.spriteWasFlipped) and target.Position.X > npc.Position.X then
                    d.spriteWasFlipped = false
                    d.state = "shootout"
                elseif d.spriteWasFlipped then 
                    d.spriteWasFlipped = true
                    d.state = "shootout"              
                end
            end
        end
    elseif d.state == "shootout" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsEventTriggered("Recover") or sprite:IsFinished("Shoot" .. d.dir) then
            sprite.FlipX = false
            npc.StateFrame = 0
            d.state = "idle"
            d.spriteWasFlipped = nil
            d.dir = nil
            d.lerpness = 0.015
        elseif sprite:IsEventTriggered("Prep") then
            if d.spriteWasFlipped then
                sprite.FlipX = true
            end
        elseif sprite:IsEventTriggered("Shoot") then
            local vec = beebeeDirs[d.dir]
            if not sprite.FlipX then
                vec = vec * -1
            end
            npc:PlaySound(mod.Sounds.FrogShoot,0.7,0,false,math.random(13,15)/10)
            local stinger = Isaac.Spawn(mod.FF.StingerProjBeebee.ID, mod.FF.StingerProjBeebee.Var, mod.FF.StingerProjBeebee.Sub, npc.Position + vec:Resized(10), vec:Resized(12), npc)
            stinger:GetData().TargVec = vec:Resized(15)
            stinger.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            stinger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            stinger:Update()
            d.Stingerless = true
            sprite:ReplaceSpritesheet(0, "gfx/enemies/beebee/monster_beebee02.png")
            sprite:LoadGraphics()
        else
            mod:spritePlay(sprite, "Shoot" .. d.dir)
        end
    elseif d.state == "charge" then
        if sprite:IsFinished("Charge" .. d.dir .. "Start") then
            mod:spritePlay(sprite, "Charge" .. d.dir)
        elseif sprite:IsEventTriggered("Prep") then
            npc:PlaySound(mod.Sounds.BeeBuzzPrep, 1, 0, false, math.random(180,220)/100)
        elseif sprite:IsEventTriggered("Dash") then
            d.charging = true
            npc:PlaySound(mod.Sounds.BeeBuzz, 1, 0, false, math.random(180,220)/100)
        end
        if d.charging then
            local vec = beebeeDirs[d.dir]
            if d.dir == "Down" then
                npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, 0), 0.2)
            elseif d.dir == "Up" then
                npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -10), 0.2)
            else
                npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.1)
            end
            if sprite.FlipX then
                vec = vec * -1
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(20), 0.2)
            if game:GetRoom():GetGridCollisionAtPos(npc.Position + vec:Resized(25)) >= GridCollisionClass.COLLISION_WALL --[[npc:CollidesWithGrid()]] then
                d.state = "impact"
                d.charging = false
                d.targChargeStart = nil
                npc.Velocity = Vector.Zero
                npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.5, 1, false, math.random(200,300)/100)
                npc:PlaySound(mod.Sounds.FunnyBonk, 0.2, 1, false, math.random(80,120)/100)
            end
        else
            npc.Velocity = npc.Velocity * 0.8
            if d.targChargeStart then
                npc.Velocity = mod:Lerp(npc.Velocity, (d.targChargeStart - npc.Position) * 0.4, 0.1)
            end
        end
    end
    if d.state == "impact" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:GetFrame() >= 17 then
            npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, nilvector, 0.2)
        elseif d.dir == "Up" then
            npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, 0), 0.2)
        elseif d.dir == "Down" then
            npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, 20), 0.5)
        
        end
        if sprite:IsFinished("Impact" .. d.dir) then
            npc.StateFrame = 0
            d.state = "waitingForSomethingToHappen"
        elseif sprite:IsEventTriggered("Unflip") then
            sprite.FlipX = false
        else
            mod:spritePlay(sprite, "Impact" .. d.dir)
        end

    end
end

function mod:beebeeStingerProjectileAI(npc)
    local sprite, d, target = npc:GetSprite(), npc:GetData(), npc:GetPlayerTarget()
    mod:spritePlay(sprite, "Idle")
    d.targetSpriteoffset = d.targetSpriteoffset or -30
    if npc.SpawnerEntity and npc.SpawnerEntity:Exists() then
        if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.1, 0, true, 1.8)
        end
        if d.returning then
            local targvec = ((npc.SpawnerEntity.Position + npc.SpawnerEntity.Velocity) - npc.Position)
            d.speed = d.speed or 1
            d.speed = math.min(d.speed + 1, 25)
            if targvec:Length() > d.speed then
                targvec = targvec:Resized(d.speed)
            end
            local lerpness = 0.2
            if npc.Position:Distance(npc.SpawnerEntity.Position) < 50 then
                lerpness = 1
                d.targetSpriteoffset = mod:Lerp(d.targetSpriteoffset, -50, 0.2)
            else
                d.targetSpriteoffset = mod:Lerp(d.targetSpriteoffset, -15, 0.2)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, targvec, lerpness)
            if npc.Position:Distance(npc.SpawnerEntity.Position) < 20 then
                sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
                npc.SpawnerEntity:GetData().Stingerless = nil
                local sPsprite = npc.SpawnerEntity:GetSprite()
                sPsprite:ReplaceSpritesheet(0, "gfx/enemies/beebee/monster_beebee.png")
                sPsprite:LoadGraphics()
                npc:Remove()
            end
        else
            d.targetSpriteoffset = mod:Lerp(d.targetSpriteoffset, -15, 0.2)
            d.TargVec = mod:Lerp(d.TargVec, target.Position - npc.Position, 0.005):Resized(12)
            npc.Velocity = d.TargVec
        end

        if npc.FrameCount >= 25 then
            d.returning = true
        end
        npc.SpriteOffset = Vector(0, d.targetSpriteoffset)
        npc.SpriteRotation = npc.Velocity:GetAngleDegrees() + 180

        if npc:CollidesWithGrid() then
            d.returning = true
        end
    else
        sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
        local effect = Isaac.Spawn(1000,7014,1,npc.Position,nilvector,nil)
        effect.SpriteRotation = npc.SpriteRotation
        effect:Update()
        npc:Remove()
    end
end