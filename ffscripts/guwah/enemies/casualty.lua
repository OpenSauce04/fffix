local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:CasualtyAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        for i = 1, 2 do
            local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
            splat.SpriteScale = Vector(1.5,1.5)
            splat:Update()
        end
        data.State = "Idle"
        data.Init = true
    end

    mod.QuickSetEntityGridPath(npc, 900)

    if data.State == "Idle" then
        if npc.Pathfinder:HasPathToPos(targetpos, false) then
            if sprite:IsEventTriggered("Move") then
                if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
                    npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4))
                else
                    npc.Pathfinder:FindGridPath(targetpos, 1.8, 900, true)
                end
                mod:FlipSprite(sprite, npc.Position + npc.Velocity, npc.Position)
            else
                mod:spritePlay(sprite, "Walk")
            end
        else
            mod:spritePlay(sprite, "Idle")
            mod:FlipSprite(sprite, targetpos, npc.Position)
        end

        npc.Velocity = npc.Velocity * 0.9
        if npc.FrameCount % 10 == 5 then
            local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
            creep.SpriteScale = Vector(0.1,0.1)
            creep:SetTimeout(30)
            creep:Update()
            local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
            splat.SpriteScale = Vector(0.5,0.5)
            splat:Update()
        end

        if npc.HitPoints <= (npc.MaxHitPoints * 0.5) then
            data.State = "Trip"
        end
    elseif data.State == "Trip" then
        if sprite:WasEventTriggered("Shoot") then
            npc.Velocity = npc.Velocity * 0.6
        else
            npc.Velocity = npc.Velocity * 0.9
        end

        if sprite:IsFinished("Trip") then
            npc.CanShutDoors = false
            data.State = "Dead"
        elseif sprite:IsEventTriggered("Move") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(10))
            mod:FlipSprite(sprite, npc.Position + npc.Velocity, npc.Position)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc)
            npc.Velocity = npc.Velocity * 0.5

            local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
            creep.SpriteScale = Vector(3,3)
            creep:SetTimeout(90)
            creep:Update()
            local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
            splat.SpriteScale = Vector(1.5,1.5)
            splat:Update()
            local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc)
            effect.SpriteScale = Vector(0.8,0.8)
        else
            mod:spritePlay(sprite, "Trip")
        end
    elseif data.State == "Dead" then
        npc.Velocity = npc.Velocity * 0.6
        if npc.FrameCount % 60 == 30 then
            if not room:IsClear() then
                local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
                creep.SpriteScale = Vector(3,3)
                creep:SetTimeout(90)
                creep:Update()
            end
            local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
            splat.SpriteScale = Vector(1.5,1.5)
            splat:Update()
        end
    end
end