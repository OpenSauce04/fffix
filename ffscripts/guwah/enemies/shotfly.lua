local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ShotFlyAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        if npc.SubType == 1 then
            mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType - 1, 30)
        else
            mod:AddSoundmakerFly(npc)
            if data.Charging then
                npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            elseif not data.ForceVec then
                if data.waited then
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    npc:AddEntityFlags(EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)
                    npc.StateFrame = mod:RandomInt(5,30)
                    data.WaitingToDescend = true
                else
                    sprite:Play("Fly")
                end
            end      
        end
        data.Init = true
    end
    if data.WaitingToDescend then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.WaitingToDescend = nil
            data.Descending = true
            sprite:Play("Descend")
            npc.Visible = true
        end  
    elseif data.Descending then
        npc.Velocity = Vector.Zero
        if sprite:IsEventTriggered("Land") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)
        end
        if sprite:IsFinished("Descend") then
            sprite:Play("Fly")
            data.Descending = nil
        end
    elseif data.Charging then
        if not data.PlayedSound then
            npc:PlaySound(mod.Sounds.Ricochet,0.7,0,false,0.8)
            data.PlayedSound = true
        end
        if npc:CollidesWithGrid() then
            npc:Kill()
        end
    else
        if sprite:IsPlaying("Fly") then
            local vel
            if not mod:isScare(npc) then
                if targetpos:Distance(npc.Position) > 100 then
                    local targetposes = {}
                    for i = 90, 360, 90 do
                        local pos = targetpos + Vector(0,100):Rotated(i)
                        if room:IsPositionInRoom(pos, 0) then
                            table.insert(targetposes, pos)
                        end
                    end
                    local newtarget = mod:GetClosestPos(npc.Position, targetposes)
                    local vecpos = newtarget or targetpos
                    vel = (vecpos - npc.Position):Resized(3)
                else
                    vel = (targetpos - npc.Position):Resized(3)
                end
                if npc.Position:Distance(targetpos) < 200 and ((data.CanAttack and npc.FrameCount > 15) or (data.isSpecturnInvuln and npc.FrameCount > 30)) then
                    local margin = 20
                    if npc.Variant == mod.FF.Shoter.Var then
                        margin = 40
                    end
                    if math.abs(npc.Position.X - targetpos.X) < margin then
                        sprite:Play("ChargeStartVerti")
                    elseif math.abs(npc.Position.Y - targetpos.Y) < margin then
                        sprite:Play("ChargeStartHori")
                    end
                    npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                end
            else
                vel = (npc.Position - targetpos):Resized(3)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.3)
        else
            if sprite:IsFinished("ChargeStartHori") then
                if data.ForceVec then
                    if data.ForceVec.X > 0 then
                        sprite:Play("ChargeRight")
                    else
                        sprite:Play("ChargeLeft")
                    end
                    npc.Velocity = data.ForceVec
                elseif npc.Position.X < targetpos.X then
                    local shootvec = Vector(14,0) 
                    if npc.Variant == mod.FF.Shoter.Var then
                        for i = -15, 15, 30 do
                            local fly = Isaac.Spawn(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, 0, npc.Position, shootvec:Rotated(i), npc) 
                            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            fly:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
                            fly.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                            fly:GetSprite():Play("ChargeRight")
                            fly:GetData().Charging = true
                        end
                        data.DontSpawnMore = true
                        npc:Kill()
                    else
                        sprite:Play("ChargeRight")
                        npc.Velocity = shootvec
                    end
                else
                    local shootvec = Vector(-14,0)
                    if npc.Variant == mod.FF.Shoter.Var then
                        for i = -15, 15, 30 do
                            local fly = Isaac.Spawn(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, 0, npc.Position, shootvec:Rotated(i), npc) 
                            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            fly:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
                            fly:GetSprite():Play("ChargeLeft")
                            fly:GetData().Charging = true
                        end
                        data.DontSpawnMore = true
                        npc:Kill()
                    else
                        sprite:Play("ChargeLeft")
                        npc.Velocity = shootvec
                    end
                end
                data.Charging = true
                npc.Parent = nil
                npc.Color:Reset()
            elseif sprite:IsFinished("ChargeStartVerti") then
                if npc.Position.Y < targetpos.Y then
                    local shootvec = Vector(0,14)
                    if npc.Variant == mod.FF.Shoter.Var then
                        for i = -15, 15, 30 do
                            local fly = Isaac.Spawn(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, 0, npc.Position, shootvec:Rotated(i), npc) 
                            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            fly:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
                            fly:GetSprite():Play("ChargeDown")
                            fly:GetData().Charging = true
                        end
                        data.DontSpawnMore = true
                        npc:Kill()
                    else
                        sprite:Play("ChargeDown")
                        npc.Velocity = shootvec
                    end
                else
                    local shootvec = Vector(0,-14)
                    if npc.Variant == mod.FF.Shoter.Var then
                        for i = -15, 15, 30 do
                            local fly = Isaac.Spawn(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, 0, npc.Position, shootvec:Rotated(i), npc) 
                            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            fly:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
                            fly:GetSprite():Play("ChargeUp")
                            fly:GetData().Charging = true
                        end
                        data.DontSpawnMore = true
                        npc:Kill()
                    else
                        sprite:Play("ChargeUp")
                        npc.Velocity = shootvec
                    end
                end
                data.Charging = true
                npc.Parent = nil
                npc.Color:Reset()
            else
                npc.Velocity = Vector.Zero
            end
        end
    end
    if npc:IsDead() then
        if npc.Variant == mod.FF.Shoter.Var then
            if not data.DontSpawnMore then
                for i = 0, 180, 180 do
                    local fly = Isaac.Spawn(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, 0, npc.Position+Vector(15,0):Rotated(i), Vector.Zero, npc) 
                    fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    fly:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
                    fly.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                    fly:GetSprite():Play("ChargeStartHori")
                    fly:GetData().ForceVec = Vector(14,0):Rotated(i)
                end
            end
        else
            local burst = Isaac.Spawn(1000, 3, 0, npc.Position, Vector.Zero, npc)
            burst.SpriteOffset = Vector(0,-14)
        end
    end
end

function mod:ShotFlyHurt(npc, amount, damageFlags, source)
    if amount > 0 then
        npc:GetData().CanAttack = true
    end
end

function mod:GetClosestPos(pos, poses)
    local nearest = nil
    local nearDist = 10000
    for _, hmmpos in pairs(poses) do
        nearest, nearDist = mod:DistanceComparePoses(nearDist, nearest, hmmpos, pos)
    end
    return nearest or pos
end