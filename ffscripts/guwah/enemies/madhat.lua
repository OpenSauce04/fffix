local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MadhatAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local vec = (targetpos - npc.Position)
    if not data.Init then
        sprite:Play("Appear")
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        data.Init = true
    end
    if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(60, 80)
        data.PivotPoint = npc.Position + vec:Resized(mod:RandomInt(25,40)):Rotated(mod:RandomInt(-90,90))
        data.Distance = data.PivotPoint:Distance(npc.Position)
        data.Angle = mod:GetAngleDegreesButGood(data.PivotPoint - npc.Position) + 140
        data.AngleShift = data.AngleShift or 5
        npc.I1 = mod:RandomInt(20,30)
    end
    if sprite:IsEventTriggered("Shoot") then
        local targcoord = mod:intercept(npc, target, 9.5)
        local shootvec = targcoord:Normalized() * 9.5
        npc:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, 0.8, 0, false, mod:RandomInt(110,120)/100)
        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1.3, 0, false, 0.8)
        local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, mod:RandomInt(2,4), npc.Position, shootvec, npc)
        proj:GetData().isSpiked = true
        proj:GetData().EffectTime = 60 --Default to 120 if this isn't there
        local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
        effect.SpriteOffset = Vector(0,-14)
        effect.DepthOffset = npc.Position.Y * 1.25
        local s = effect:GetSprite()
        s:ReplaceSpritesheet(4, "gfx/effects/effect_002_bloodpoof_alt_white.png")
		s:LoadGraphics()
		effect.Color = mod.duskDebuffCols[proj.SubType]
    end
    if sprite:IsPlaying("Idle") then
        if npc.I1 <= 0 then
            local angle = mod:RandomInt(-90,90)
            if targetpos:Distance(npc.Position) < 100 or mod:isScare(npc) then
                angle = mod:RandomInt(160,200)
            end
            data.PivotPoint = npc.Position + vec:Resized(mod:RandomInt(25,40)):Rotated(angle)
            data.Distance = data.PivotPoint:Distance(npc.Position)
            data.Angle = mod:GetAngleDegreesButGood(data.PivotPoint - npc.Position) + 140
            data.AngleShift = -data.AngleShift or 5
            npc.I1 = mod:RandomInt(20,30)
        else
            npc.I1 = npc.I1 - 1
        end
        if npc.StateFrame <= 0 then
            if game:GetRoom():CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 400 then
                sprite:Play("Shoot") 
            end
        else
            npc.StateFrame = npc.StateFrame - 1
        end
        npc.TargetPosition = data.PivotPoint + Vector.One:Rotated(data.Angle):Resized(data.Distance)
        local movevec = npc.TargetPosition - npc.Position
        if movevec:Length() > 8 then
            movevec = movevec:Resized(8)
        end
        npc.Velocity = mod:Lerp(npc.Velocity, movevec, 0.05)
        data.Angle = data.Angle + data.AngleShift
    else
        npc.Velocity = npc.Velocity * 0.9
    end
end