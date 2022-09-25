local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

local function playCorrectBubbyAnim(d, sprite)
    local anim
    if d.dir < 0 then
        anim = "Right"
    else
        anim = "Left"
    end
    mod:spritePlay(sprite, "SpinFast" .. anim)
end

function mod:bubbyAI(npc)
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

    npc.SpriteOffset = Vector(0, -7)

    if d.state == "idle" then
        local targetPos = mod:randomConfuse(npc, target.Position)
        local targetVec = (targetPos - npc.Position):Resized(4)
        targetVec = mod:reverseIfFear(npc, targetVec, 1.25)
        npc.Velocity = mod:Lerp(npc.Velocity, targetVec, 0.05)
        mod:spritePlay(sprite, "Walk")
        if (target.Position:Distance(npc.Position) < 165) and ((npc.StateFrame > 30 and r:RandomInt(60) == 1) or npc.StateFrame > 90) and not mod:isScareOrConfuse(npc) then
            d.state = "spinStart"
            mod:spritePlay(sprite, "SpinStart")
            d.startedSpin = nil
        end
    elseif d.state == "spinStart" then
        if sprite:IsFinished("SpinStart") then
            d.state = "spin"
            playCorrectBubbyAnim(d, sprite)
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Start") then
            d.targVec = (target.Position - npc.Position):Resized(9):Rotated(-60 + r:RandomInt(120))
            if npc.Velocity.X > 0 then
                d.dir = 1
            else
                d.dir = -1
            end
            d.shootStart = -30 * d.dir
            d.startedSpin = true
        else
            mod:spritePlay(sprite, "SpinStart")
        end
        if d.startedSpin then
            npc.Velocity = mod:Lerp(npc.Velocity, d.targVec, 0.6)
        else
            npc.Velocity = npc.Velocity * 0.7
        end
    elseif d.state == "spin" then
        npc.Velocity = npc.Velocity * 0.95
        if sprite:IsFinished() then
            d.state = "taunt"
            sprite:Play("Taunt0" .. r:RandomInt(2) + 1, true)
        elseif sprite:IsEventTriggered("Shoot") then
            if npc.StateFrame % 2 == 1 then
                npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, 0.2, 0, false, 1.5)
            end
            d.shootStart = d.shootStart + (60 * d.dir)
            local params = ProjectileParams()
            params.Variant = 4
            params.HeightModifier = -20
            local projspeed = 7
            local vec = Vector(0, projspeed):Rotated(d.shootStart)
            npc:FireProjectiles(npc.Position + vec:Resized(15), vec, 0, params)
        else
            playCorrectBubbyAnim(d, sprite)
        end
    elseif d.state == "taunt" then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished() then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Taunt") then
            npc:PlaySound(SoundEffect["SOUND_LITTLE_HORN_GRUNT_" .. r:RandomInt(2) + 1], 1, 0, false, (r:RandomInt(20) + 120)/100)
        end
    end
end
