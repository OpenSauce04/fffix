local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ShirkAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        if npc.SubType == 1 then
            mod.makeWaitFerr(npc, npc.Type, npc.Variant, 0, 40)
            Isaac.Spawn(mod.FF.ShirkSpot.ID, mod.FF.ShirkSpot.Var, 0, npc.Position, Vector.Zero, npc)
        else
            npc.SplatColor = mod.ColorGhostly
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            sprite:Play("Appear")
            if data.waited then
                npc.Visible = true
            else
                Isaac.Spawn(mod.FF.ShirkSpot.ID, mod.FF.ShirkSpot.Var, 0, npc.Position, Vector.Zero, npc)
            end
            data.Index = room:GetGridIndex(npc.Position)
            mod.ShirkSpots[data.Index] = "Closed"
        end
        data.Init = true
    end
    npc.Velocity = npc.Velocity * 0.7
    if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(20,30)
    elseif sprite:IsFinished("Leave") then
        npc.Visible = false
        if npc.StateFrame <= 0 then
            mod:ShirkSpotSelection(npc, sprite, data)
            npc.Position = npc.TargetPosition
            sprite:Play("Appear")
            npc.Visible = true
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    end
    if sprite:IsPlaying("Idle") then
        if not mod:IsShirkSpotSafe(npc.Position, targetpos) then
            mod:ShirkTeleport(npc, sprite, data)
        end
        if npc.StateFrame <= 0 and targetpos:Distance(npc.Position) < 200 then
            sprite:Play("Shoot")
        else
            npc.StateFrame = npc.StateFrame - 1
        end
        npc.I1 = npc.I1 - 1
    end
    if sprite:IsEventTriggered("Shoot") then
        local params = ProjectileParams()
        params.BulletFlags = ProjectileFlags.GHOST
        params.Variant = 4
        npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 0, params)
        mod:PlaySound(mod.Sounds.FlashShakeyKidRoar, npc, 1.5, 1.5)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT)
        local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
        effect.SpriteOffset = Vector(0,-6)
        effect.DepthOffset = npc.Position.Y * 1.25
		effect.Color = mod.ColorGhostly
        mod:FlipSprite(sprite, npc.Position, targetpos)
    elseif sprite:IsEventTriggered("NoDMG") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        mod:PlaySound(SoundEffect.SOUND_FLOATY_BABY_ROAR, npc, 3, 0.5)
    elseif sprite:IsEventTriggered("DMG") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
    end
end

function mod:ShirkHurt(npc, amount, damageFlags, source)
    mod:ShirkTeleport(npc, npc:GetSprite(), npc:GetData())
end

function mod:ShirkRemove(npc, data)
    if data.Spot and data.Spot:GetData().Index then
        mod.ShirkSpots[data.Spot:GetData().Index] = "Open"
    end
end

function mod:IsShirkSpotSafe(spotpos, targetpos)
    return not (targetpos:Distance(spotpos) < 60 and game:GetRoom():CheckLine(spotpos, targetpos, 3, 0, false, false))
end

function mod:ShirkTeleport(npc, sprite, data)
    local room = game:GetRoom()
    if npc.I1 <= 0 then
        sprite:Play("Leave")
        npc.StateFrame = 20
        if room:GetRoomShape() >= 8 then
            npc.I1 = 80
        else
            npc.I1 = 40
        end
    end
end

function mod:ShirkSpotSelection(npc, sprite, data)
    local room = game:GetRoom()
    local openspots = {}
    for index, spot in pairs(mod.ShirkSpots) do
        local pos = room:GetGridPosition(index)
        if spot ~= "Closed" and mod:IsShirkSpotSafe(pos, game:GetNearestPlayer(pos).Position) then
            table.insert(openspots, index)
        end
    end
    local newindex = mod:GetRandomElem(openspots) or data.Index
    mod.ShirkSpots[data.Index] = "Open"
    data.Index = newindex
    mod.ShirkSpots[newindex] = "Closed"  
    npc.TargetPosition = room:GetGridPosition(newindex)
end

function mod:ShirkSpotAI(npc, sprite, data)
    local room = game:GetRoom()
    if not data.Init then
        npc.Visible = false
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:GetData().DungeonLocked = true
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        data.Index = room:GetGridIndex(npc.Position)
        npc.TargetPosition = room:GetGridPosition(data.Index)
        data.Init = true
    end
    if room:GetFrameCount() == 1 and not mod.ShirkSpots[data.Index] then
        mod.ShirkSpots[data.Index] = "Open"
        npc:Remove()
    end
    npc.Position = npc.TargetPosition
end