local mod = FiendFolio

function mod:castedAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local target = npc:GetPlayerTarget()

    if not data.init then
        local num = rng:RandomInt(5)+1

        sprite:ReplaceSpritesheet(0, "gfx/enemies/casted/monster_casted" .. num .. ".png")
        sprite:ReplaceSpritesheet(1, "gfx/enemies/casted/monster_casted" .. num .. "_glow.png")
        sprite:LoadGraphics()
        data.state = "Idle"
        npc.StateFrame = -15
        data.init = true
    end
    npc.State = 16

    if data.state == "Idle" then
        if target.Position:Distance(npc.Position) < 100 and npc.StateFrame > 30 then
            data.state = "FlameStart"
        end

        mod:spritePlay(sprite, "Idle")
    elseif data.state == "Flaming" then
        if npc.StateFrame > 60 then
            data.state = "FlameEnd"
            data.burning = false
        end

        mod:spritePlay(sprite, "AttackLoop")
    elseif data.state == "FlameEnd" then
        if sprite:IsFinished("AttackEnd") then
            data.state = "Idle"
            npc.StateFrame = 0
        else
            mod:spritePlay(sprite, "AttackEnd")
        end
    elseif data.state == "FlameStart" then
        if sprite:IsFinished("AttackStart") then
            data.state = "Flaming"
        elseif sprite:IsEventTriggered("Shoot") then
            npc.StateFrame = 0
            data.burning = true
        else
            mod:spritePlay(sprite, "AttackStart")
        end
    end

    if data.burning then
        if npc.StateFrame % 10 == 0 then
            --well this is literally just spitfire code but it works so ehhhhhhh
            npc:PlaySound(mod.Sounds.FireFizzle, 0.4, 0, false, 1.3)
			local numberofflames = 6
			for i = 1, numberofflames do
				local fire = Isaac.Spawn(1000,7005, 1, npc.Position, Vector(6,0):Rotated((360/numberofflames) * i+npc.FrameCount*4), npc)
				fire:Update()
			end
        end
    end
end

function mod:castedHurt(npc, data, source)
    if source and source.Type == 1000 and source.Variant == 7005 then
    elseif data.state == "Idle" and npc:ToNPC().StateFrame > 30 then
        data.state = "FlameStart"
    end
end