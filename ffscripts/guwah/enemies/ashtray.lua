local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:AshtrayAI(npc, sprite, data)
    if not data.Init then
        if npc.SubType % 2 == 1 then
            sprite.FlipX = true
            data.ShootVel = Vector(20,0)
        else
            data.ShootVel = Vector(-20,0)
        end
        npc.StateFrame = (npc.SubType >> 1) * 5
        sprite:Play("Idle01")
        data.Init = true
    end
    npc.Velocity = npc.Velocity * 0.5
    npc.StateFrame = npc.StateFrame - 1
    if npc.StateFrame <= 0 then
        if sprite:IsPlaying("Idle01") then
            sprite:Play("EatCigars")
            npc.StateFrame = 90
        elseif sprite:IsPlaying("Idle02") then
            sprite:Play("StartFire")
            npc.StateFrame = 90
            npc.SplatColor = mod.ColorCharred
        elseif sprite:IsPlaying("FireLoop") then
            sprite:Play("Death")
            data.Shooting = false
            sfx:Stop(mod.Sounds.FlamethrowerLoop)
            sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
        end
    end
    if sprite:IsFinished("EatCigars") then
        sprite:Play("Idle02")
    elseif sprite:IsFinished("StartFire") then
        sprite:Play("FireLoop")
    elseif sprite:IsFinished("Death") then
        npc:Remove()
    end
    if sprite:IsEventTriggered("Shoot") then
        data.Shooting = true
        npc:PlaySound(mod.Sounds.Blaargh, 1.25, 0, false, 0.8)
        npc:PlaySound(mod.Sounds.FlamethrowerLoop, 1, 0, true, 1) 
    elseif sprite:IsEventTriggered("Swallow") then
        npc:PlaySound(mod.Sounds.GlobSwallow, 2, 0, false, 0.8)
    elseif sprite:IsEventTriggered("Gulp") then
        npc:PlaySound(mod.Sounds.CartoonGulp, 1, 0, false, 1)
    elseif sprite:IsEventTriggered("Brace") then
        npc:PlaySound(SoundEffect.SOUND_FRAIL_CHARGE, 0.7, 0, false, 0.8)
    end
    if data.Shooting then
        for i = 1, 3 do
            if i == 3 and sprite:GetFrame() == 5 then
                local flame = Isaac.Spawn(33, 10, 0, npc.Position, data.ShootVel:Rotated(mod:RandomInt(-20,20)):Resized(mod:RandomInt(5,20)), npc)     
                flame.HitPoints = flame.HitPoints * mod:RandomInt(6,10) * 0.1
                flame.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
            else
                local fire = Isaac.Spawn(1000, 7005, 450, npc.Position, data.ShootVel:Rotated(mod:RandomInt(-30,30)), npc):ToEffect()
                fire.Parent = npc
                fire.Visible = false
                fire.SpriteOffset = Vector(0,-10)
                fire:GetData().gridcoll = 0
                fire:GetData().scale = mod:RandomInt(6,12) * 0.1
                fire:GetData().makeVisibleLater = true
            end
        end
    end
    if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
        local shouldStop = true
        for _, ashtray in pairs(Isaac.FindByType(mod.FF.Ashtray.ID, mod.FF.Ashtray.Var)) do
            if ashtray:GetData().Shooting and not ashtray:IsDead() and not mod:isLeavingStatusCorpse(ashtray) and not mod:isStatusCorpse(ashtray) then
                shouldStop = false
            end
        end
        if shouldStop then
            sfx:Stop(mod.Sounds.FlamethrowerLoop)
        end
    end
end