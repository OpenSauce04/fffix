local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:CoconutAI(npc, sprite, data)
    if not data.Init then
        if data.SpewTime then
            npc.SplatColor = Color(0.3,1,0.3,1,0,0,0)
        else
            npc.SplatColor = Color(1,1,1,0)
        end
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        data.Init = true
    end
    npc.Velocity = Vector.Zero
    mod.QuickSetEntityGridPath(npc)
    mod.NegateKnockoutDrops(npc)
    if sprite:IsPlaying("Idle") or sprite:IsPlaying("SuckLoop") or sprite:IsPlaying("SpewLoop") then
        if npc.StateFrame <= 0 then
            if sprite:IsPlaying("Idle") then
                npc:PlaySound(SoundEffect.SOUND_WORM_SPIT, 1, 4, false, 0.5)
                sprite:Play("SuckStart")
            elseif sprite:IsPlaying("SuckLoop") then
                sprite:Play("SuckStop")
            elseif sprite:IsPlaying("SpewLoop") then
                sprite:Play("SpewEnd")
            end
        else
            npc.StateFrame = npc.StateFrame - 1
            if sprite:IsPlaying("SuckLoop") and not mod:isFriend(npc) then
                for _, player in pairs(Isaac.FindInRadius(npc.Position, 400, EntityPartition.PLAYER)) do
                    local succstrength = (400 - npc.Position:Distance(player.Position)) / 18
                    player.Velocity = mod:Lerp(player.Velocity, (npc.Position - player.Position):Resized(succstrength), 0.05)
                end
                --[[if npc.FrameCount % 10 == 0 then
                    local effect = Isaac.Spawn(1000, EffectVariant.BIG_ATTRACT, 1, npc.Position - Vector(0,10), Vector.Zero, npc)
                    effect:GetSprite().Color = Color(1,1,1,0.1)
                end
                if npc.FrameCount % 20 == 0 then
                    local effect = Isaac.Spawn(1000, EffectVariant.BIG_ATTRACT, 0, npc.Position - Vector(0,10), Vector.Zero, npc)
                    effect:GetSprite().Color = Color(1,1,1,0.1)
                end]]
            end
        end
    end
    if sprite:IsFinished("Appear") or sprite:IsFinished("SuckStop") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(80,100)
    elseif sprite:IsFinished("SuckStart") then
        sprite:Play("SuckLoop")
        npc.StateFrame = mod:RandomInt(20,80)
    elseif sprite:IsFinished("Death") then
        npc:Kill()
    elseif sprite:IsFinished("SpewStart") then
        sprite:Play("SpewLoop")
        npc.StateFrame = 60
    elseif sprite:IsFinished("SpewEnd") then
        sprite:Play("HuskIdle")
    end
    if sprite:IsEventTriggered("Shoot") then
        FiendFolio.CoconutDeathEffect(npc)
    end
end

function FiendFolio.CoconutDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        if not npc:GetData().SpewTime then
            sfx:Stop(SoundEffect.SOUND_DEATH_BURST_LARGE)
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
            deathAnim:GetData().SpewTime = true
        end
    end
    if npc:GetData().SpewTime then
        FiendFolio.genericCustomDeathAnim(npc, "SpewStart", false, onCustomDeath, false, false, true, true)
    else
        FiendFolio.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, false, false, false)
    end
end

function FiendFolio.CoconutDeathEffect(npc)
    Isaac.Spawn(1000, 132, 0, npc.Position, Vector.Zero, npc).Color = mod.ColorWebWhite
    local params = ProjectileParams()
    params.Color = mod.ColorWebWhite
    table.insert(mod.TearFountains, {["Duration"] = 80, ["Spawner"] = npc, ["Params"] = params, ["Special"] = "Coconut"})
end

function mod:TearFountainUpdate(shower)
    if shower.Duration >= 0 then
        local npc = shower.Spawner:ToNPC()
        local params = shower.Params
        params.FallingAccelModifier = 3
        params.FallingSpeedModifier = mod:RandomInt(-100,-20)
        params.Scale = 0.1 * mod:RandomInt(6, 12)
        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position, Vector(mod:RandomInt(-4,4)/2, mod:RandomInt(-4,4)/2), 0, params)
        for _, projectile in pairs(mod:GetGatheredProjectiles()) do
            if shower.Special == "Coconut" then
                projectile:GetData().massCreep = EffectVariant.CREEP_WHITE
            elseif shower.Special == "awesomeCoin" then
                projectile:GetData().projType = "awesomeCoin"
            end
        end
        if shower.Special == "Coconut" then
            if shower.Duration % 3 == 0 then
                sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
            end
            if shower.Duration % 10 == 0 then
                local vel = (mod:FindRandomValidPathPosition(npc, 3) - npc.Position)/mod:RandomInt(10,15)
                FiendFolio.ThrowMaggot(npc.Position, vel, -5, mod:RandomInt(-25, -10), npc)
            end
        end
        shower.Duration = shower.Duration - 1
    else
        shower = nil
    end
end