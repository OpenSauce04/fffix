local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:GutKnightAI(npc, sprite, data)
    if not data.Init then
        data.Init = true
    end
    if npc.FrameCount % 10 == 2 and npc.I1 < 5 then
        local parent = npc
        while parent.Child and parent.Child:Exists() do
            parent = parent.Child
        end
        local projectile = Isaac.Spawn(9,0,0,npc.Position,Vector.Zero,npc):ToProjectile()
        projectile:GetData().projType = "akeldama"
        projectile.Parent = parent
        parent.Child = projectile
        npc.I1 = npc.I1 + 1
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1, 0.25)
        local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc)
        effect.Color = mod.ColorRottenGreen
        effect.SpriteOffset = Vector(0,-20)
    end
    local animation = sprite:GetAnimation()
    if animation == "Hori" then
        if sprite.FlipX then
            sprite:PlayOverlay("LeftHead")
        else
            sprite:PlayOverlay("RightHead")
        end
    else
        sprite:RemoveOverlay()
    end
    if sprite:IsFinished("Appear") then
        sprite:SetFrame("Down", 0)
    end
    npc.SplatColor = mod.ColorRottenGreen
end

function mod:AkeldamaProjectile(projectile, data)
    if not data.akeldamaInit then
        projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
        projectile.Scale = mod:RandomInt(20,28) * 0.05
        local color = Color(1,1,1)
        color:SetColorize(1,1,1,mod:RandomInt(0,18) * 0.05)
        projectile.Color = color
        projectile.FallingAccel = -0.1
        data.akeldamaInit = true
    end
    if projectile.Parent and projectile.Parent:Exists() then
        projectile.Velocity = mod:Lerp(projectile.Velocity, (projectile.Parent.Position - projectile.Position) / 5, 0.2)
        projectile.DepthOffset = projectile.Parent.DepthOffset * 2
    else
        projectile.FallingAccel = 3
    end
end

function mod:AkeldamaProjectileRemove(projectile, data)
    if projectile.Child and projectile.Child:Exists() and projectile.Parent and projectile.Parent:Exists() then
        projectile.Child.Parent = projectile.Parent
        projectile.Parent.Child = projectile.Child
    end
end