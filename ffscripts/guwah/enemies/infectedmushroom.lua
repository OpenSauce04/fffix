local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local infectedRing = Sprite()
infectedRing:Load("gfx/enemies/infected mushroom/big ring.anm2")
infectedRing:Play("Ring", true)
infectedRing.Color = mod.ColorArcanePinkA

function mod:InfectedMushroomAI(npc, sprite, data, isPaused, isReflected)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        mod:FlipSprite(sprite, npc.Position, npc:GetPlayerTarget().Position)
        data.Radius = npc.SubType * 2
        data.State = "Idle"

        local spores = 0
        local fails = 0
        while spores < data.Radius / 10 and fails < 20 do
            local spawnpos = npc.Position + Vector(mod:RandomInt(25, data.Radius), 0):Rotated(mod:RandomAngle(rng))
            if game:GetRoom():GetGridCollisionAtPos(spawnpos) <= GridCollisionClass.COLLISION_NONE then
                local spore = Isaac.Spawn(mod.FF.InfectedGrowth.ID, mod.FF.InfectedGrowth.Var, mod.FF.InfectedGrowth.Sub, spawnpos, Vector.Zero, npc)
                spore.Parent = npc
                spores = spores + 1
            else
                fails = fails + 1
            end
        end

        local ring = Isaac.Spawn(mod.FF.InfectedRing.ID, mod.FF.InfectedRing.Var, mod.FF.InfectedRing.Sub, npc.Position, Vector.Zero, npc)
        ring.Color = mod.ColorArcanePinkA
        ring.SpriteScale = Vector(data.Radius / 150, data.Radius / 150)
        ring.Parent = npc

        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod.QuickSetEntityGridPath(npc, 900)

    if data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        for _, enemy in pairs (Isaac.FindInRadius(npc.Position, data.Radius, EntityPartition.ENEMY)) do
            if enemy:IsActiveEnemy() and not (enemy.Type == mod.FF.InfectedMushroom.ID and enemy.Variant == mod.FF.InfectedMushroom.Var) then
                enemy:SetColor(mod.ColorArcanePink, 20, 2, false, false)
                enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
                enemy:GetData().InfectedConfuzzle = 20
            end
        end
        if not mod.AreThereEntitiesButNotThisOne(mod.FF.InfectedMushroom.ID, nil, mod.FF.InfectedMushroom.Var) and npc.FrameCount > 30 then
            data.State = "Death"
        end
        --[[if Isaac.GetPlayer().Position:Distance(npc.Position) < data.Radius then
            print(data.Radius)
        end]]
    elseif data.State == "Death" then
        if sprite:IsEventTriggered("Shoot") then
            game:Fart(npc.Position, 80, npc, 1, 0)
			mod:FakeFart(npc, npc.Position)
            npc:Kill()
        else
            mod:spritePlay(sprite, "Die")
        end
    end
end

function mod:InfectedConfuzzleUpdate(npc, data)
    local rng = npc:GetDropRNG()

    if data.InfectedConfuzzle then
        data.InfectedCooldown = data.InfectedCooldown or mod:RandomInt(60,120,rng)
        data.InfectedConfuzzle = data.InfectedConfuzzle - 1
        data.InfectedCooldown = data.InfectedCooldown - 1
        if data.InfectedCooldown <= 0 and rng:RandomFloat() <= 0.05 then
            local color = mod:RandomColor(0, 0.2)
            
            mod:SetGatheredProjectiles()
            local params = ProjectileParams()
            params.BulletFlags = params.BulletFlags | ProjectileFlags.WIGGLE | ProjectileFlags.ACCELERATE | ProjectileFlags.NO_WALL_COLLIDE
            params.FallingAccelModifier = -0.17
            params.FallingSpeedModifier = 0
            --params.Color = color
            params.Variant = 6
            npc:FireProjectiles(npc.Position, (npc:GetPlayerTarget().Position-npc.Position):Resized(2), 0, params)
            data.InfectedCooldown = mod:RandomInt(60,120)
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.8)

            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(0,-14)
            local s = effect:GetSprite()
            s:ReplaceSpritesheet(4, "gfx/effects/effect_002_bloodpoof_alt_white.png")
            s:LoadGraphics()
            effect.Color = color

            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                proj:GetData().RainbowCycle = true
                proj:Update()
            end
        end
        if data.InfectedConfuzzle <= 0 then
            npc:ClearEntityFlags(EntityFlag.FLAG_CONFUSION)
            data.InfectedConfuzzle = nil
        end
    end
end

function mod:RainbowProjectile(projectile, data)
    data.ColorFrame = data.ColorFrame or mod:RandomInt(0,120)
    data.ColorFrame = data.ColorFrame + 1
    local r = mod:Sway(0.2, 1, 120, 2, 2, data.ColorFrame)
    local g = mod:Sway(0.2, 1, 120, 2, 2, data.ColorFrame + 40)
    local b = mod:Sway(0.2, 1, 120, 2, 2, data.ColorFrame + 80)
    projectile.Color = Color(r,g,b)
end

function mod:InfectedGrowthUpdate(effect, sprite, data)
    data.Suffix = data.Suffix or mod:RandomInt(1,3)
    mod:spritePlay(sprite, "Growth"..data.Suffix)

    if effect.Parent then
        if mod:IsReallyDead(effect.Parent) or effect.Parent:GetData().State == "Death" then
            effect:Remove()
        end
    end
end

function mod:InfectedRingUpdate(effect, sprite, data)
    if not data.Init then
        sprite:Play("appear")
        effect.DepthOffset = -1000
        sprite.Rotation = mod:RandomAngle()
        data.Init = true
    end

    if sprite:IsFinished("appear") then
        sprite:Play("Ring")
    elseif sprite:IsFinished("unappear") then
        effect:Remove()
    end
    if effect.Parent and not sprite:IsPlaying("unappear") then
        if mod:IsReallyDead(effect.Parent) or effect.Parent:GetData().State == "Death" then
            sprite:Play("unappear")
        end
    end
end