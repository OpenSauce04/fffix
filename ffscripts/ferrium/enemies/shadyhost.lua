local mod = FiendFolio

function mod:shadyHostAI(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()

    if not data.init then
        data.state = "Idle"
        data.attackLoop = 0
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)

    if data.state == "Idle" then
        if data.bombed then
            mod:spritePlay(sprite, "Bombed")
        else
            mod:spritePlay(sprite, "Idle")
        end

        if npc.StateFrame > 50 then
            if data.attackLoop == 0 then
                data.state = "Shoot"
                data.attackLoop = 1
            elseif data.attackLoop == 1 then
                data.state = "Shoot"
                data.attackLoop = 0
            end
        end
    elseif data.state == "Shoot" then
        if sprite:IsFinished("Shoot") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Open") then
            npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 1, 0, false, 1.3)
            data.vulnerable = true
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
            local params = ProjectileParams()
            params.Color = mod.ColorShadyRed
            params.Scale = 1.5
            mod:SetGatheredProjectiles()
            for i=-40,40,40 do
    			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(11):Rotated(i), 0, params)
            end
			for _, proj in pairs(mod:GetGatheredProjectiles()) do
                proj:GetData().projType = "shadyHost"
                proj:GetData().detail = "splitShot"
                proj:GetData().target = target
            end
        elseif sprite:IsEventTriggered("Close") then
            npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
            data.vulnerable = nil

            local explosion = Isaac.Spawn(1000, 144, 1, npc.Position, Vector.Zero, npc):ToEffect()
            explosion.Parent = npc
            mod:DamagePlayersInRadius(npc.Position, 50, 1, npc)
            npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 1, 0, false, 1)
            mod.scheduleForUpdate(function()
                local newPos = npc.Position+(target.Position-npc.Position):Resized(65)
                local explosion = Isaac.Spawn(1000, 144, 1, newPos, Vector.Zero, npc):ToEffect()
                explosion.Parent = npc
                explosion.SpriteScale = Vector(0.9,0.9)
                mod:DamagePlayersInRadius(newPos, 50, 1, npc)
                npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.8, 0, false, 1)
                mod.scheduleForUpdate(function()
                    local newerPos = newPos+(target.Position-newPos):Resized(65)
                    local explosion = Isaac.Spawn(1000, 144, 1, newerPos, Vector.Zero, npc):ToEffect()
                    explosion.Parent = npc
                    explosion.SpriteScale = Vector(0.8,0.8)
                    mod:DamagePlayersInRadius(newPos, 40, 1, npc)
                    npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 0.6, 0, false, 1)
                end, 10)
            end, 10)
            
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif data.state == "Teleport" then
        npc.Position = target.Position
        data.state = "Idle"
        npc.StateFrame = 0
    end
end

function mod:shadyHostHurt(npc, damage, flag, source)
    local data = npc:GetData()
    if not data.vulnerable then
        if flag == flag | DamageFlag.DAMAGE_EXPLOSION then
            if data.state == "Idle" and not data.bombed then
                data.bombed = true
            end
        end
        return false
    end
end

function mod.shadyHostProj(v, d)
    if d.projType == "shadyHost" then
        if d.detail == "splitShot" and v:IsDead() then
            if d.target then
                for i=-20,20,20 do
                    local proj = Isaac.Spawn(9, 0, 0, v.Position, (d.target.Position-v.Position):Resized(10):Rotated(i), v):ToProjectile()
                    proj.Color = mod.ColorShadyRed
                    proj.ProjectileFlags = v.ProjectileFlags
                end
            end
        end
    end
end