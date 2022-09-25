local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local TrailblazerSegmentAnims = {"Body1", "Body2", "Tail"}

function mod:TrailblazerAI(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if not data.Init then
        if npc.SubType == mod.FF.TrailblazerFlameSegment.Sub then
            npc.SplatColor = mod.ColorFireJuicy
        end
        if not data.IsSegment then --Head-only init
            for i = 1, 3 do
                local butt = Isaac.Spawn(mod.FF.Trailblazer.ID, mod.FF.Trailblazer.Var, (i > 1 and mod.FF.TrailblazerFlameSegment.Sub or 0), npc.Position, Vector.Zero, npc)
                butt.Parent = npc
                butt.DepthOffset = -3 * i
                butt:GetData().MoveDelay = i * 3
                butt:GetData().IsSegment = true
                butt:GetData().SegmentAnim = TrailblazerSegmentAnims[i]
            end
            mod:spritePlay(sprite, "HeadDown")
            data.MoveDelay = 0
            data.MovementLog = {}
        end
        npc.StateFrame = 0
        data.SwayFrame = 0
        data.State = "Idle"
        data.Init = true
    end

    if data.IsSegment then
        if mod:IsReallyDead(npc.Parent) then
            npc:Kill()
        else
            local targpos = npc.Parent:GetData().MovementLog[npc.FrameCount - data.MoveDelay]
            if targpos then
                npc.Velocity = targpos - npc.Position
            end

            npc.Color = npc.Parent.Color
            sprite.Color = npc.Parent:GetSprite().Color
            mod:spritePlay(sprite, data.SegmentAnim)
        end
    else
        if data.State == "Idle" then
            data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position, true)
            if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (mod:isScareOrConfuse(npc) and npc.StateFrame % 10 == 0) then
                data.newhome = mod:GetNewPosAligned(npc.Position, true)
            end
            local targvel = (data.newhome - npc.Position):Resized(5)
            npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
            
            npc.StateFrame = npc.StateFrame - 1
            if npc.FrameCount > 0 then
                mod:spritePlay(sprite, "Head"..mod:GetMoveString(npc.Velocity))
            end
        elseif data.State == "Charge" then
            local anim = "Charge"..mod:GetMoveString(data.ChargeVec)

            if sprite:IsFinished(anim) then
                npc.StateFrame = 30
                data.newhome = nil
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Shoot") then
                mod:PlaySound(mod.Sounds.FireLight, npc, 1.5)
                mod:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, npc, 1.8, 0.5)
                npc.Velocity = data.ChargeVec
            else
                mod:spritePlay(sprite, anim)
            end

            if sprite:WasEventTriggered("Shoot") then
                npc.Velocity = npc.Velocity * 0.95
                if sprite:GetFrame() % 2 == 0 then
                    local fire = Isaac.Spawn(1000,7005,20,npc.Position + (RandomVector() * mod:RandomInt(0,5,rng)),Vector.Zero,npc)
                    fire:GetData().timer = 120
                    fire:GetData().scale = mod:RandomInt(50,75,rng) * 0.01
                    fire.Parent = npc
                    fire:Update()
                end
            else
                npc.Velocity = npc.Velocity * 0.6
            end
        end

        data.MovementLog[npc.FrameCount] = npc.Position
    end
end

function mod:TrailblazerRender(npc, sprite, data, isPaused, isReflected, offset)
    if data.IsSegment and data.Init then
        if not (isPaused or isReflected) then
            data.SwayFrame = data.SwayFrame + 0.1
            local sway = math.sin(((data.SwayFrame + (data.MoveDelay/2) * math.pi) * 20) / 20) * (2 + (data.MoveDelay/5))
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, sway), 0.25)
            else
                npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(sway, 0), 0.25)
            end
        end
    end
end

function mod:TrailblazerColl(npc, collider)
    if collider.Type == mod.FF.Trailblazer.ID and collider.Variant == mod.FF.Trailblazer.Var then
        return true
    end
end

function mod:TrailblazerHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) and not mod:IsPlayerDamage(source) then
        return false
    elseif data.Init then
        if not data.IsSegment then
            for _, butt in ipairs(Isaac.FindByType(mod.FF.Trailblazer.ID, mod.FF.Trailblazer.Var)) do
                if butt.Parent and butt.Parent.InitSeed == npc.InitSeed then
                    butt:TakeDamage(amount, damageFlags | DamageFlag.DAMAGE_CLONES, source, 0)
                end
            end

            if data.State == "Idle" and npc.StateFrame <= 0 and not (npc.HitPoints - amount <= 0) then
                local vec = mod:SnapVector(npc.Velocity, 90)
                local angle
                if not room:CheckLine(npc.Position, npc.Position + vec:Rotated(90):Resized(80), 2) then
                    angle = -90
                elseif not room:CheckLine(npc.Position, npc.Position + vec:Rotated(-90):Resized(80), 2) then
                    angle = 90 
                else
                    angle = (rng:RandomFloat() <= 0.5 and 90 or -90)
                end
                data.ChargeVec = vec:Rotated(angle):Resized(12)
                data.State = "Charge"
                mod:PlaySound(SoundEffect.SOUND_FLAME_BURST, npc)
            end
        elseif not mod:HasDamageFlag(DamageFlag.DAMAGE_CLONES, damageFlags) then
            npc.Parent:TakeDamage(amount, damageFlags, source, 0)
            return false
        end
    end
end