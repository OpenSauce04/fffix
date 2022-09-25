local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:DroolieAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc.StateFrame = mod:RandomInt(60,120)
        npc.SplatColor = mod.ColorSpittyGreen
        data.Init = true
    end
    if npc:IsDead() then
        local params = ProjectileParams()
        params.Color = mod.ColorSpittyGreen
        params.FallingSpeedModifier = -4
        params.FallingAccelModifier = 0.6
        params.CircleAngle = 0
        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position, Vector(8,6), 9, params)
        for _, proj in pairs(mod:GetGatheredProjectiles()) do
            proj:GetData().projType = "acidic splot"
        end
    end
    if data.Shootin then
        if sprite:IsFinished("Shoot") then
            npc.StateFrame = mod:RandomInt(60,120)
            data.Shootin = false
        else
            mod:spritePlay(sprite, "Shoot")
            npc.Velocity = npc.Velocity * 0.9
            if sprite:IsEventTriggered("Shoot") and sprite:IsPlaying("Shoot") then
                local params = ProjectileParams()
                params.Color = mod.ColorSpittyGreen
                params.FallingSpeedModifier = -4
                params.FallingAccelModifier = 0.6
                params.Spread = 1.5
                mod:SetGatheredProjectiles()
                npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(8), 4, params)
                for _, proj in pairs(mod:GetGatheredProjectiles()) do
                    proj:GetData().projType = "acidic splot"
                end
                local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc):ToEffect()
                effect.Color = mod.ColorSpittyGreen
                effect.SpriteOffset = Vector(0,-12)
                effect.DepthOffset = npc.Position.Y * 1.25
                effect:FollowParent(npc)
                mod:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, npc)
            end
            return true
        end
    else
        if sprite:IsEventTriggered("Shoot") then
            local effect = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
            effect.Scale = 0.3
            effect.Color = mod.ColorSpittyGreen
        end
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if game:GetRoom():CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 200 then
                data.Shootin = true
            else
                npc.StateFrame = mod:RandomInt(15,30)
            end
        end
    end
end

function mod:DroolieAITwo(npc) --this only works in npc update for some reason
    if npc:IsDead() then
        for _, proj in pairs(mod:GatherProjectiles(npc)) do
            if not proj:GetData().projType then
                proj:Remove()
            end
        end
    end
end