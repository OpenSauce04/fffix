local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:GamperAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc.Parent = mod:GetNearestThing(npc.Position, mod.FF.GamperGuts.ID, mod.FF.GamperGuts.Var)

        if npc.Parent then
            npc.Parent.Child = npc
            for i = 1, npc.SubType do
                local vec = npc.Parent.Position - npc.Position
                local offset = i + 0.5
                local pos = npc.Position + vec:Resized((vec:Length()/(npc.SubType+2)) * offset)
                local chain = Isaac.Spawn(mod.FF.GamperChain.ID, mod.FF.GamperChain.Var, mod.FF.GamperChain.Sub, pos, Vector.Zero, npc)
                chain:GetData().Offset = offset
                chain.Child = npc.Parent
                chain.Parent = npc
                chain:Update()
            end
        end

        data.State = "Idle"
        data.HopCooldown = mod:RandomInt(20,40,rng)
        npc.StateFrame = 30
        data.Init = true
    end

    if mod:IsReallyDead(npc.Parent) then
        npc:Kill()
    else
        if data.State == "Idle" then
            mod:spritePlay(sprite, "Idle")
    
            npc.StateFrame = npc.StateFrame - 1
            data.HopCooldown = data.HopCooldown - 1
            if npc.StateFrame <= 0 then
                if (room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 200) or not npc.Parent:GetData().Pegging then
                    data.State = "Lunge"
                    mod:FlipSprite(sprite, npc.Position, targetpos)
                elseif data.HopCooldown <= 0 then
                    data.State = "Hop"
                end
            end
        elseif data.State == "Hop" then
            if sprite:IsFinished("Hop") then
                data.State = "Idle"
                npc.StateFrame = 10
                data.HopCooldown = mod:RandomInt(20,40,rng)
            elseif sprite:IsEventTriggered("Hop") then
                npc.Velocity = RandomVector() * 4
                mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)

                mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP,npc)
            elseif sprite:IsEventTriggered("Land") then
                mod:PlaySound(SoundEffect.SOUND_FETUS_LAND,npc)
            else
                mod:spritePlay(sprite, "Hop")
            end
        elseif data.State == "Lunge" then
            if sprite:IsFinished("Move") then
                data.State = "Idle"
                data.HopCooldown = mod:RandomInt(20,40,rng)
                if npc.Parent:GetData().Pegging then
                    npc.StateFrame = mod:RandomInt(30,60,rng)
                else
                    npc.StateFrame = mod:RandomInt(8,16,rng)
                end
            elseif sprite:IsEventTriggered("Hop") then
                npc.Velocity = (targetpos - npc.Position):Resized(10)
                mod:FlipSprite(sprite, npc.Position, targetpos)

                mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP,npc)
                mod:PlaySound(mod.Sounds.ChompDash,npc,0.8,1.5)
            elseif sprite:IsEventTriggered("Land") then
                mod:PlaySound(SoundEffect.SOUND_FETUS_LAND,npc)
            else
                mod:spritePlay(sprite, "Move")
            end
        end
    
        local dist = npc.Position:Distance(npc.Parent.Position)
        local excess = dist - (npc.SubType * 30)
        if excess > 0 then
            if npc.Parent:GetData().Pegging then
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position - npc.Position):Resized(excess), 0.25)
            else
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position - npc.Position):Resized(excess), 0.05)
                npc.Parent.Velocity = mod:Lerp(npc.Parent.Velocity, (npc.Position - npc.Parent.Position):Resized(excess), 0.25)
            end
        else
            if not (sprite:WasEventTriggered("Hop") and not sprite:WasEventTriggered("Land")) then
                npc.Velocity = npc.Velocity * 0.6
            end
        end
    end
end

function mod:GamperGutsAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        for i = 1, 2 do
            local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
            splat.SpriteScale = Vector(1.5,1.5)
            splat:Update()
        end

        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        data.Pegging = true
        data.State = "Peg"
        data.Init = true
    end

    if data.State == "Peg" then
        mod:spritePlay(sprite, "Peg")
        if npc.HitPoints <= (npc.MaxHitPoints * 0.75) then
            data.State = "Emerge"
        end
    elseif data.State == "Emerge" then
        if sprite:IsFinished("Emerge") then
            data.State = "Guts"
        elseif sprite:IsEventTriggered("Move") then
            mod:PlaySound(SoundEffect.SOUND_SHOVEL_DIG,npc)
            mod:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND,npc)

            for i = 1, mod:RandomInt(3,5) do
				local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector() * mod:RandomInt(1,3), npc)
				rubble:Update()
			end

            data.Pegging = false
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:spritePlay(sprite, "Emerge")
        end
    elseif data.State == "Guts" then
        mod:spritePlay(sprite, "Guts")

        if sprite:IsEventTriggered("Move") then
            if npc.Position:Distance(targetpos) <= 150 then
                npc.Velocity = (npc.Position - targetpos):Resized(6):Rotated(mod:RandomInt(-45,45,rng))
            elseif npc.Child and npc.Child.Position then
                npc.Velocity = (npc.Child.Position - npc.Position):Resized(6):Rotated(mod:RandomInt(-45,45,rng))
            else
                npc.Velocity = RandomVector() * 6
            end
            Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
        end
    end

    if data.Pegging then
        npc.Velocity = Vector.Zero
        mod.QuickSetEntityGridPath(npc)
    else
        npc.Velocity = npc.Velocity * 0.9
    end
end

function mod:GamperChain(effect, sprite, data)
    if not data.Init then
        effect.SpriteOffset = Vector(0,-10)
        sprite:Play("Chain")
        data.Init = true
    end
    if effect.Parent and effect.Parent:Exists() and effect.Child and effect.Child:Exists() then
        local vec = effect.Child.Position - effect.Parent.Position
        local length = vec:Length()
        effect.TargetPosition = effect.Parent.Position + vec:Resized((length/(effect.Parent.SubType+2)) * data.Offset)
        effect.Velocity = effect.TargetPosition - effect.Position
    else
        effect:Remove()
        sfx:Play(SoundEffect.SOUND_ANIMA_BREAK)
    end
end