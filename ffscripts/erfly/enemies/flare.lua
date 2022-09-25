local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:mrFlareAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()

    if not d.init then
        --npc.SpriteOffset = Vector(0, -5)
        d.state = "idle"
        d.init = true
        npc.SplatColor = mod.ColorCharred
        if npc.Position.X > target.Position.X then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    npc.Velocity = npc.Velocity * 0.3

    if d.unignited and not d.removedFire then
        mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/mrflare/monster_mrflare_extinguished", 1)
        sprite:ReplaceSpritesheet(0, "gfx/nothing.png")
        sprite:LoadGraphics()
        d.removedFire = true
    end

    if d.state == "idle" then
        mod:spritePlay(sprite, "Idle")
        if npc.StateFrame > 40 and target.Position:Distance(npc.Position) < 180 and not mod:isScareOrConfuse(npc) then
            d.state = "shoot"
        end
    elseif d.state == "shoot" then
        if sprite:IsFinished("Shoot") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Shoot") then
            if npc.Position.X > target.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
            npc:PlaySound(mod.Sounds.FlashShakeyKidRoar,1.5,2,false,1)
            local count = math.random(3,7)
            if d.unignited then
                count = math.random(1,3)
            end
            for i = 1, count do
                local fire = Isaac.Spawn(1000,7005, 20, npc.Position, Vector(5,0):Rotated(360/count * i - 25 + math.random(50)), npc):ToEffect()
                if d.unignited then
                    fire:GetData().timer = 10
                else
                    fire:GetData().timer = 50
                end
                fire:GetData().gridcoll = 0
                fire.Parent = npc
            end
        else
            mod:spritePlay(sprite, "Shoot")
        end
    end
end

function mod:flareHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        return false
    end
end

function mod:mrCrisplyAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite()

    if not d.init then
        --npc.SpriteOffset = Vector(0, -5)
        d.state = "idle"
        d.init = true
        npc.SplatColor = mod.ColorCharred
    else
        npc.StateFrame = npc.StateFrame + 1
        if npc.HitPoints < npc.MaxHitPoints / 10 then
            npc.HitPoints = npc.HitPoints * (math.random(950, 999)/1000)
        else
            npc.HitPoints = npc.HitPoints * (math.random(990, 999)/1000)
        end
    end

    npc.Velocity = npc.Velocity * 0.93

    if npc.Velocity.X > 0 then
        sprite.FlipX = true
    else
        sprite.FlipX = false
    end

    npc.SpriteOffset = Vector(npc.FrameCount % 2, 0)

    mod:spritePlay(sprite, "Idle")
    local frametime = math.ceil((npc.MaxHitPoints - npc.HitPoints) / npc.MaxHitPoints * 300)
    sprite:SetOverlayFrame("OverlayFunnies", frametime)

    if npc:IsDead() or npc.HitPoints < 0.1 then
        local count = math.random(7,9)
        npc:PlaySound(mod.Sounds.FlashShakeyKidRoar,1.5,2,false,1)
        for i = 1, count do
            --[[local fire = Isaac.Spawn(1000,7005, 20, npc.Position, Vector(2.5,0):Rotated(360/count * i - 25 + math.random(50)), npc):ToEffect()
            fire:GetData().timer = 350
            fire:GetData().gridcoll = 0
            fire.Parent = npc]]
            local fire = Isaac.Spawn(33,10,0, npc.Position, Vector(2.5,0):Rotated(360/count * i - 25 + math.random(50)), npc)
            fire.HitPoints = fire.HitPoints / 1.5
            fire:Update()
        end
        if not npc:IsDead() then
            npc:Kill()
        end
    end

end