local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--Motor Neuron, MotorNeuron
function mod:walkingNerveAI(npc, subType)
    local sprite  = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local d = npc:GetData()
    local path = npc.Pathfinder
    local room = game:GetRoom()
    
    if not d.init then
        d.npcstate = "idle"
        npc.Velocity = RandomVector():Normalized()*1.5
        d.nextrandom = math.random(25)
        npc.StateFrame = 15
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if npc.Velocity:Length() > 0.1 then
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            if npc.Velocity.X > 0 then
                mod:spritePlay(sprite, "WalkRight")
            else
                mod:spritePlay(sprite, "WalkLeft")
            end
        else
            mod:spritePlay(sprite, "WalkVert")
        end
    else
        sprite:SetFrame("WalkVert", 0)
    end

    if d.npcstate == "idle" then
        mod:spriteOverlayPlay(sprite, "Idle")
        if npc.Position:Distance(targetpos) < 200 then
            d.target = true
        else
            d.target = false
        end
        if mod:isScare(npc) then
            d.targetvelocity = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.8)
        elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
            d.targetvelocity = (targetpos - npc.Position):Resized(3)
            npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.8)
        else
            d.targetvelocity = path:FindGridPath(targetpos, 0.5, 1, true)
            npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity, 0.8)
        end
        if room:CheckLine(npc.Position,targetpos,0,1,false,false) and npc.StateFrame > 45 and npc.Position:Distance(targetpos) < 100 and not mod:isConfuse(npc) then
            d.swingstate = 1
            d.npcstate = "swing"
        end

    elseif d.npcstate == "swing" then
        npc.Velocity = npc.Velocity * 0.9
        --[[if room:CheckLine(npc.Position,targetpos,0,1,false,false) then
            d.targetvelocity = (targetpos - npc.Position):Resized(3)
            npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.8)
        else
            d.targetvelocity = path:FindGridPath(targetpos, 0.5, 1, true)
            npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity, 0.8)
        end]]

        if d.swingstate == 1 then
            if sprite:IsOverlayFinished("AttackStart") then
                npc.StateFrame = 0
                d.swingstate = 2
                npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            elseif sprite:IsOverlayPlaying("AttackStart") and sprite:GetOverlayFrame() == 3 then
                npc:PlaySound(mod.Sounds.WhipCrack,0.1,0,false,1.4)
            else
                mod:spriteOverlayPlay(sprite, "AttackStart")
            end

        elseif d.swingstate == 2 then
            npc.SubType = 1
            for _, entity in pairs(Isaac.FindInRadius(npc.Position, 70)) do
                if entity:ToBomb() or entity:ToTear() then
                    entity.Velocity = (entity.Position - npc.Position):Resized(15)
                elseif entity:ToPlayer() then
                    if entity:ToPlayer():GetDamageCooldown() == 0 then
                        npc:PlaySound(mod.Sounds.WhipCrack,0.4,0,false,0.8)
                        entity.Velocity = (entity.Position - npc.Position):Resized(15)
                    end
                    entity:TakeDamage(1, 0, EntityRef(npc), 0)
                elseif entity.Type == mod.FF.Punted.ID and entity.Variant == mod.FF.Punted.Var then
                    if entity:GetData().State == "Dead" then
                        mod:flingPunted(entity:ToNPC(), npc, entity:GetData())
                        npc:PlaySound(mod.Sounds.WhipCrack,0.4,0,false,0.8)
                    end
                end
            end
            mod:spriteOverlayPlay(sprite, "AttackLoop")
            if sprite:GetOverlayFrame() == 0 then
                npc:PlaySound(mod.Sounds.WingFlap,2,0,false,math.random(70,80)/100)
            end
            if npc.StateFrame > 100 and math.random(10) == 1 then
                d.swingstate = 3
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                --npc:SetSize(13, Vector(1,1), 40)
            end

        elseif d.swingstate == 3 then
            npc.SubType = 0
            if sprite:IsOverlayFinished("AttackEnd") then
                npc.StateFrame = 0
                d.npcstate = "idle"
            else
                mod:spriteOverlayPlay(sprite, "AttackEnd")
            end
        end
    end
end