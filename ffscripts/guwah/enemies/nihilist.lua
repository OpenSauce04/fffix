local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:NihilistAI(npc, sprite, data)
    if not data.Init then
        npc.SplatColor = mod.ColorDarkPurple
        local aura = Isaac.Spawn(mod.FF.NihilistAura.ID, mod.FF.NihilistAura.Var, mod.FF.NihilistAura.Sub, npc.Position, Vector.Zero, npc):ToEffect()
        aura:FollowParent(npc)
        aura.Parent = npc
        aura.ParentOffset = Vector(0,-1)
        local scale = Vector.One:Resized((npc.SubType / 100))
        aura.SpriteScale = scale
        data.Init = true
    end
    if npc.Velocity:Length() < 0.5 then
        mod:spritePlay(sprite, "Idle")
    else
        npc:AnimWalkFrame("WalkHori", "WalkVert", 0)
    end
    local nihilistFilter = function (position, proj)
        if proj:GetData().Nihilism then
            return false
        else
            return true
        end
    end
    local proj = mod:GetNearestThing(npc.Position, 9, -1, -1, nihilistFilter)
    if proj and proj.Position:Distance(npc.Position) > npc.SubType then
        npc.Velocity = mod:Lerp(npc.Velocity, (proj.Position - npc.Position):Resized(2), 0.3)
    else
        if not data.walktarg then
            data.walktarg = mod:FindRandomValidPathPosition(npc)
            npc.StateFrame = 0
        end
        if npc.Position:Distance(data.walktarg) > 30 then
            local room = game:GetRoom()
            if room:CheckLine(npc.Position,data.walktarg,0,1,false,false) then
                local targetvel = (data.walktarg - npc.Position):Resized(1.5)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
            else
                npc.Pathfinder:FindGridPath(data.walktarg, 0.35, 900, true)
            end
        else
            data.walktarg = nil
        end
    end
end

function mod:NihilistAuraAI(effect, sprite, data)
    if not data.Init then
        sprite:Play("Idle")
        data.Rotation = 0.2
        if mod:RandomInt(0,1) == 1 then
            data.Rotation = data.Rotation * -1
        end
        data.Init = true
    end
    if effect.Parent and effect.Parent:Exists() then
        effect.DepthOffset = effect.Parent.DepthOffset * 0.75
        for _, projectile in pairs(Isaac.FindInRadius(effect.Position, effect.Parent.SubType, EntityPartition.BULLET)) do
            projectile = projectile:ToProjectile()
            if not projectile:GetData().Nihilism then
                projectile:AddProjectileFlags(ProjectileFlags.CONTINUUM)
                projectile:ClearProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.DECELERATE)
                projectile:GetData().Nihilism = 1600
                if projectile.SpawnerEntity then
                    for _, entry in pairs(FiendFolio.NihilistSlowdownList) do
                        local bool = mod:CheckID(projectile.SpawnerEntity, entry)
                        if bool then
                            projectile:GetData().ForceSpeed = entry[4]
                        end
                    end
                end
            end
        end
        sprite.Rotation = sprite.Rotation + data.Rotation
    else
        effect:Remove()
    end
end

function mod:NihilismProjectile(projectile, data)
    if projectile.HomingStrength > 0.9 then
        projectile.HomingStrength = 0.9
    end
    if data.Nihilism > 0 and (projectile.FrameCount < 300 or data.projType == "Psyker") then
        local height = -18 
        if projectile.Variant == 2 then
            projectile.SpriteOffset = Vector(0, mod:Lerp(projectile.SpriteOffset.Y, 15, 0.15))
        end
        projectile.Height = mod:Lerp(projectile.Height, height, 0.15)
        projectile.FallingAccel = -0.1
        if data.projType == "Psyker" then
            if data.projOrient == "Hori" then
                data.Nihilism = data.Nihilism - math.abs(projectile.Velocity.X) * 1.5
                projectile.Velocity = Vector(data.projVel.X * 1.5, projectile.Velocity.Y)
            else
                data.Nihilism = data.Nihilism - math.abs(projectile.Velocity.Y) * 1.5
                projectile.Velocity = Vector(projectile.Velocity.X, data.projVel.Y * 1.5)
            end
        elseif data.projType == "Clergy" then
            if data.clergyLaunch or data.clergyDead then
                data.Nihilism = data.Nihilism - projectile.Velocity:Length() 
            end
        else
            local speed = data.ForceSpeed or 10
            projectile.Velocity = mod:Lerp(projectile.Velocity, projectile.Velocity:Resized(speed), 0.05)
            data.Nihilism = data.Nihilism - projectile.Velocity:Length() 
        end
    else
        projectile.FallingAccel = 3
    end
    local grid = game:GetRoom():GetGridEntityFromPos(projectile.Position + projectile.Velocity)
    if grid then
        if grid:GetType() == GridEntityType.GRID_PILLAR then
            projectile:Die()
        end
    end
end