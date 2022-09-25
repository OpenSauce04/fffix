local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:carrotAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()

    if not d.init then
        if npc.SubType == 1 then
            npc.Position = npc.Position + Vector(20, 0)
        end
        d.init = true
        npc.SpriteOffset = Vector(0, -1)
        d.rollSet = 0
        d.state = "idle"
        if math.random(2) == 1 then
            sprite.FlipX = true
        end
        npc.SplatColor = mod.ColorCarrotOrange
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    d.startPos = d.startPos or npc.Position
    d.rollSet = math.floor((npc.Position.Y - d.startPos.Y) / 5) % 8
    d.rollBit = d.rollBit or 0
    d.rollBit = (d.rollBit + (1 + (npc.Velocity.Y * 0.3))) % 24
    sprite:SetFrame("Idle" .. d.rollSet, math.floor(d.rollBit))

    if d.state == "idle" then
        if npc.StateFrame >= 10 then
            d.state = "roll"
            npc.StateFrame = 0
            if mod:GetClosestVerticalGridPos(npc.Position).Y > npc.Position.Y then
                d.rollDir = -1
            else
                d.rollDir = 1
            end
        end
    elseif d.state == "roll" then
        npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, d.rollDir * 10), 0.1)
        local room = game:GetRoom()
        if npc.StateFrame > 10 and room:GetGridCollisionAtPos(npc.Position + npc.Velocity:Resized(20) + Vector(0, -5)) > 0 then
            d.state = "idle"
            npc.Velocity = nilvector
            npc.StateFrame = 0
        end
        if npc.Position:Distance(d.savedPos or npc.Position) < 1 then
            d.counter = d.counter or 0
            d.counter = d.counter + 1
            if d.counter > 10 then
                d.rollDir = d.rollDir * -1
                d.counter = 0
            end
        else
            d.counter = 0
        end
        d.savedPos = npc.Position
    end
end