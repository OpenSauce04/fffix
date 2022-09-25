local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:CherubskullInit(npc)
    local hand = Isaac.Spawn(mod.FF.CherubskullHand.ID, mod.FF.CherubskullHand.Var, 0, npc.Position, Vector.Zero, npc)
    npc.Child = hand
    hand.Parent = npc
    for i = 1, npc.SubType do
        local chain = Isaac.Spawn(mod.FF.CherubskullChain.ID, mod.FF.CherubskullChain.Var, mod.FF.CherubskullChain.Sub, npc.Position, Vector.Zero, npc)
        chain:GetData().Offset = i + 0.5
        chain.Child = hand
        chain.Parent = npc
    end
end

function mod:CherubskullAI(npc, sprite, data)
    if not data.Init then
        npc.SplatColor = Color.Default
        data.Tugs = mod:RandomInt(1,4)
        data.Init = true
    end
    if game:GetRoom():IsClear() then
        npc.State = 18
    else
        if npc.State == 18 then
            sfx:Stop(SoundEffect.SOUND_DEVILROOM_DEAL)
        end
        npc.State = 4
    end
    if npc.Child and not mod:IsReallyDead(npc.Child) then
        if data.VelAngle then
            local angle = mod:GetAngleDegreesButGood(npc.Velocity)
            if math.abs(angle - data.VelAngle) > 120 then
                data.Tugs = data.Tugs - 1
                if data.Tugs <= 0 then
                    npc.Child:GetData().Resistance = 0
                    data.Tugs = mod:RandomInt(1,4)
                end
            end
            data.VelAngle = angle
        else
            data.VelAngle = mod:GetAngleDegreesButGood(npc.Velocity)
        end
    end
end

function mod:CherubskullRender(npc, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        if sprite:IsEventTriggered("Leave") then
            sfx:Play(SoundEffect.SOUND_HELL_PORTAL2)
            if npc.Child and not mod:IsReallyDead(npc.Child) then
                npc.Child:Kill()
            end
        elseif sprite:IsFinished("Death") then
            npc:Remove()
        end
    end
end

function mod:CherubskullHandAI(npc, sprite, data)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        data.PrevPos = npc.Position
        data.Resistance = 0.2
        data.Init = true
    end
    if npc.Parent and not mod:IsReallyDead(npc.Parent) then
        --Code is very similar to Derelict Anchor from Retribution, since that was the direct inspiration
        mod:spritePlay(sprite, "Idle")
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, data.Resistance)
        local distance = npc.Position:Distance(npc.Parent.Position + npc.Parent.Velocity)
        local excess = distance - (16 * npc.Parent.SubType)
        if excess > 0 then
            npc.Parent.Velocity = npc.Parent.Velocity:Resized(npc.Parent.Velocity:Length() - excess)
            npc.Velocity = (npc.Parent.Position - npc.Position):Resized(npc.Parent.Velocity:Length())
        end
        if npc.Position:Distance(data.PrevPos) > 20 and npc.Velocity:Length() > 1 then
            local dirtpile = Isaac.Spawn(1000,146,0,npc.Position,Vector.Zero,npc)
            dirtpile:GetSprite().Scale = dirtpile:GetSprite().Scale * 0.8
            data.PrevPos = npc.Position
        end
        if data.Resistance < 0.2 then
            data.Resistance = data.Resistance + (rng:RandomFloat() / 400)
            data.Resistance = math.min(data.Resistance, 0.2)
        end
    else
        npc:Kill()
    end
end

function mod:CherubskullChainAI(effect, sprite, data)
    if not data.Init then
        effect.SpriteOffset = Vector(0,-10)
        sprite:Play("Chain")
        data.Init = true
    end
    if effect.Child and effect.Parent and not (mod:IsReallyDead(effect.Parent) or mod:IsReallyDead(effect.Child)) then
        local vec = effect.Child.Position - effect.Parent.Position
        local length = vec:Length()
        effect.TargetPosition = effect.Parent.Position + vec:Resized((length/(effect.Parent.SubType+2)) * data.Offset)
        effect.Velocity = effect.TargetPosition - effect.Position
    else
        effect:Remove()
        sfx:Play(SoundEffect.SOUND_ANIMA_BREAK)
    end
end

function mod:IgnoreDamage(npc, amount, damageFlags, source)
    return false
end