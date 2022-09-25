local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ClogmoAI(npc, sprite, data)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.SplatColor = mod.ColorDankBlackReal
        sprite:Play("Emerge")
        local pipe = Isaac.Spawn(mod.FF.ClogmoPipe.ID, mod.FF.ClogmoPipe.Var, npc.SubType, npc.Position, Vector.Zero, npc)
        data.Pipe = pipe
        data.Clobject = pipe
        npc.DepthOffset = pipe.Position.Y * 1.1
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        mod.ClogmoGroups[npc.SubType] = "Closed"
        data.Group = npc.SubType
        data.Init = true
    end
    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    if sprite:IsFinished("Emerge") or sprite:IsFinished("Emerge(flustered)") then
        if not data.FirstTime then
            npc.StateFrame = mod:RandomInt(0,15)
            data.FirstTime = true
        else
            npc.StateFrame = mod:RandomInt(90,105)
        end
        sprite:Play("Idle")
    elseif sprite:IsFinished("Submerge") and not data.IllBeBack then
        data.Clogging = true
        data.Clobject = data.Tunnel
    end
    if sprite:IsPlaying("Idle") then
        if npc.StateFrame <= 0 then
            local choiches = {}
            for i, entry in pairs(mod.ClogmoGroups) do
                --print(i.." "..entry)
                if entry == "Open" then
                    table.insert(choiches, i)
                end
            end
            if choiches and #choiches > 0 then
                local choiche = mod:GetRandomElem(choiches) 
                local pipe = mod:GetRandomThing(mod.FF.ClogmoPipe.ID, mod.FF.ClogmoPipe.Var, choiche)
                local tunnel = mod:GetClogmoTunnel(choiche)
                if pipe and tunnel then
                    mod.ClogmoGroups[choiche] = "Closed"
                    mod.ClogmoGroups[data.Group] = "Open"
                    data.Group = choiche
                    data.Tunnel = tunnel
                    data.Pipe = pipe
                    sprite:Play("Submerge")
                    npc.StateFrame = mod:RandomInt(25,40)
                else
                    npc.StateFrame = mod:RandomInt(10,15)
                end
            else
                local choiche = data.Group
                local pipe = data.Pipe
                local tunnel = mod:GetClogmoTunnel(choiche)
                if pipe and tunnel then
                    data.Tunnel = tunnel
                    sprite:Play("Submerge")
                    npc.StateFrame = mod:RandomInt(25,40)
                else
                    npc.StateFrame = mod:RandomInt(10,15)
                end
            end
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    elseif data.Clogging then
        local tunnel = data.Tunnel
        local pipe = data.Pipe
        if npc.StateFrame <= 0 then
            if tunnel:Exists() and not tunnel:GetData().Expander and not npc:IsDead() then
                tunnel:GetSprite():Play(tunnel:GetData().Prefix.." (expand)")
                tunnel:GetData().Expander = npc
                tunnel:GetData().DamageBuffer = 0
                npc.StateFrame = mod:RandomInt(15,30)
            elseif pipe:Exists() and not pipe:GetData().Spraying then
                pipe:GetSprite():Play(pipe:GetData().Prefix.." (spray start)")
                pipe:GetData().Spraying = true
                pipe:GetData().PipeSprayer = npc
            end
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    elseif data.IllBeBack then
        if npc.StateFrame <= 0 then
            sprite:Play("Emerge(flustered)")
            data.IllBeBack = false
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    end
    if sprite:IsEventTriggered("Laugh") then
        npc:PlaySound(SoundEffect.SOUND_BROWNIE_LAUGH, 0.7, 0, false, 1.15)
    elseif sprite:IsEventTriggered("NoDMG") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
    elseif sprite:IsEventTriggered("DMG") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
    end
    if data.Clobject then
        npc.Position = data.Clobject.Position
        if data.Clobject:IsDead() or not data.Clobject:Exists() then
            npc:Kill()
        end
    end
end

function mod:ClogmoRemove(npc, data)
    if data.Group then
        mod.ClogmoGroups[data.Group] = "Open"
    end
    if data.Pipe and data.Pipe:Exists() then
        local pipe = data.Pipe
        if not pipe:GetSprite():IsPlaying(pipe:GetData().Prefix) then
            pipe:GetSprite():Play(pipe:GetData().Prefix.." (spray end)")
        end
        pipe:GetData().Spraying = false
        pipe:GetData().PipeSprayer = nil
    end    
    if data.Tunnel and data.Tunnel:Exists() then
        local tunnel = data.Tunnel
        tunnel:GetData().Expander = nil
    end
end

function mod:GetClogmoTunnel(choiche)
    local tunnels = {}
    for _, tunnel in pairs(Isaac.FindByType(mod.FF.ClogmoTunnelHori.ID, mod.FF.ClogmoTunnelHori.Var, choiche)) do
        table.insert(tunnels, tunnel)
    end
    for _, tunnel in pairs(Isaac.FindByType(mod.FF.ClogmoTunnelVerti.ID, mod.FF.ClogmoTunnelVerti.Var, choiche)) do
        table.insert(tunnels, tunnel)
    end
    if tunnels and #tunnels > 0 then
        return mod:GetRandomElem(tunnels)
    else
        return nil
    end
end

function mod:ClogmoPipeAI(npc, sprite, data)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_HIDE_HP_BAR + EntityFlag.FLAG_NO_FLASH_ON_DAMAGE + EntityFlag.FLAG_NO_REWARD + EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if npc.InitSeed % 2 == 1 then
            data.Prefix = "Pipe2"
        else
            data.Prefix = "Pipe1"
        end
        if not mod.ClogmoGroups[npc.SubType] then
            mod.ClogmoGroups[npc.SubType] = "Open"
        end
        npc.Position = npc.Position + Vector(0,7)
        --npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        mod.QuickSetEntityGridPath(npc, 950)
        sprite:Play(data.Prefix)
        data.Init = true
    end
    local prefix = data.Prefix
    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    if sprite:IsFinished(prefix.." (spray start)") then
        sprite:Play(prefix.." (spray loop)")
    elseif sprite:IsFinished(prefix.." (spray end)") then
        sprite:Play(prefix)
    end
    if sprite:IsPlaying(prefix.." (spray loop)") then
        local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(mod:RandomInt(-4,4)/2, mod:RandomInt(-4,4)/2), npc):ToProjectile()
        projectile.Color = mod.ColorDankBlackReal
        projectile.FallingSpeed = mod:RandomInt(-100,-20)
        projectile.FallingAccel = 3
        projectile.Scale = 0.1 * mod:RandomInt(8, 10)
        projectile:GetData().massCreep = EffectVariant.CREEP_BLACK
        mod:ProjectileFriendCheck(npc, projectile)
        if npc.FrameCount % 2 == 1 then
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES,0.8,0,false,0.9)
        end
    end
    if npc:IsDead() then
        mod.QuickSetEntityGridPath(npc, 0)
        local grid = Isaac.GridSpawn(2, 0, npc.Position, true)
        grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_pipes.png")
        grid:GetSprite():LoadGraphics()
        grid:Destroy()
    end
    return true
end

function mod:ClogmoTunnelAI(npc, sprite, data)
    local room = game:GetRoom()
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_HIDE_HP_BAR + EntityFlag.FLAG_NO_FLASH_ON_DAMAGE + EntityFlag.FLAG_NO_REWARD + EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if npc.Variant == mod.FF.ClogmoTunnelVerti.Var then
            data.Prefix = "Tunnel_V"
            npc:SetSize(npc.Size, Vector(1,4), 16)
            npc.Position = npc.Position + Vector(0,15)
            npc.SpriteOffset = Vector(0,-10)
            data.Offset1 = Vector(0,-20)
            data.Offset2 = Vector(0,20)
        else
            data.Prefix = "Tunnel_H"
            npc:SetSize(npc.Size, Vector(3.5,0.8), 16)
            npc.Position = npc.Position + Vector(20,0)
            npc.SpriteOffset = Vector(-15,0)
            data.Offset1 = Vector(-25,0)
            data.Offset2 = Vector(25,0)
        end
        room:SetGridPath(room:GetGridIndex(npc.Position + data.Offset1), 950)
        room:SetGridPath(room:GetGridIndex(npc.Position + data.Offset2), 950)
        if not mod.ClogmoGroups[npc.SubType] then
            mod.ClogmoGroups[npc.SubType] = "Open"
        end
        --npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        sprite:Play(data.Prefix)
        data.Init = true
    end
    local prefix = data.Prefix
    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    if sprite:IsFinished(prefix.." (expand)") then
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        sprite:Play(prefix.." (expanded)")
    elseif sprite:IsFinished(prefix.." (release)") then
        sprite:Play(prefix)
    end
    if sprite:IsEventTriggered("Clunk1") then
        sfx:Play(mod.Sounds.PipeClunk1)
    elseif sprite:IsEventTriggered("Clunk2") then
        sfx:Play(mod.Sounds.PipeClunk2)
    elseif sprite:IsEventTriggered("Shrink") then
        sfx:Play(mod.Sounds.PipeShift, 2)
    end
    if npc:IsDead() then
        room:SetGridPath(room:GetGridIndex(npc.Position + data.Offset1), 0)
        room:SetGridPath(room:GetGridIndex(npc.Position + data.Offset2), 0)
        for i = 0, 1 do
            local pos = npc.Position + data.Offset1
            if i > 0 then 
                pos = npc.Position + data.Offset2
            end
            local grid = Isaac.GridSpawn(2, 0, pos, true)
            grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_pipes.png")
            grid:GetSprite():LoadGraphics()
            grid:Destroy()
        end
    end
    return true
end

function mod:ClogmoGridHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, damageFlags) then
        npc:Kill()
    else
        if data.Expander then
            data.DamageBuffer = data.DamageBuffer + amount
            mod:applyFakeDamageFlash(npc)
            if data.DamageBuffer > 15 then
                local clogmo = data.Expander
                local clogdata = clogmo:GetData()
                local pipe = clogdata.Pipe
                data.Expander = nil
                data.DamageBuffer = 0
                npc:GetSprite():Play(data.Prefix.." (release)")
                npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
                if pipe:Exists() then
                    pipe:GetSprite():Play(pipe:GetData().Prefix.." (spray end)")
                    pipe:GetData().Spraying = false
                    pipe:GetData().PipeSprayer = nil
                    clogmo.Position = pipe.Position
                    clogmo.DepthOffset = pipe.Position.Y * 1.1
                    clogmo.StateFrame = 10
                    clogdata.IllBeBack = true
                    clogdata.Clogging = false
                    clogdata.Clobject = pipe
                else
                    clogmo:Kill()
                end
            end
        end
        return false
    end
end

function mod:ClogmoGridRemove(npc, data)
    local room = game:GetRoom()
    if npc.Variant == mod.FF.ClogmoPipe.Var then
        mod.QuickSetEntityGridPath(npc, 0)
    else
        if data.Offset1 and data.Offset2 then
            room:SetGridPath(room:GetGridIndex(npc.Position + data.Offset1), 0)
            room:SetGridPath(room:GetGridIndex(npc.Position + data.Offset2), 0)
        end
    end
end

function mod:LagFriendlyCreep(pos, radius, creeptype)
    local room = game:GetRoom()
    local creepcount = mod:GetCreepCount(creeptype)
    local toomany = false
    if room:IsPositionInRoom(pos, -radius) then
        local othercreep = mod:GetNearestThing(pos, 1000, creeptype)
        if othercreep and othercreep:ToEffect().State == 1 then --Ignore fading creeps
            if othercreep.Position:Distance(pos) < radius then
                toomany = true
            end
        elseif creepcount > 80 then
            toomany = true
        end
        local creep = Isaac.Spawn(1000, creeptype, 0, pos, Vector.Zero, projectile)
        if toomany then
            creep:ToEffect():SetTimeout(0) --Looks smoother than spawning no creep at all
        end
        creep:Update()
    end
end

function mod:GetCreepCount(creepvariant)
    local count = 0
    local creeps = Isaac.FindByType(1000, creepvariant)
    for _, creep in pairs(creeps) do
        if creep:ToEffect().State == 1 then --Ignore fading creeps
            count = count + 1
        end
    end
    return count
end