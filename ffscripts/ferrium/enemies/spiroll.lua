local mod = FiendFolio

local numToFrames = {
    12, 14, 16, 2, 4, 6, 8, 10
}

function mod:spirollAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local data = npc:GetData()
    local rng = npc:GetDropRNG()

    if not data.init then
        if npc.SubType % 3 == 0 then
            data.dir = -1+rng:RandomInt(2)*2
        elseif npc.SubType % 3 == 1 then
            data.dir = 1
        else
            data.dir = -1
        end
        data.moveFrame = 0

        if npc.SubType > 2 then
            mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/spiroll/monster_spiroll_vert", 0, true)
            data.vert = true
        end
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.state = "Idle"
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
        data.moveFrame = data.moveFrame+1
    end

    if data.state == "Idle" then
        if data.dir == -1 then
            mod:spritePlay(sprite, "RollBackwards")
        else
            mod:spritePlay(sprite, "RollHori")
        end

        if not mod:isScareOrConfuse(npc) and npc.StateFrame > 10 then
            if data.vert then
                if math.abs(target.Position.Y-npc.Position.Y) < 15 then
                    if npc.Position.X > target.Position.X then
                        data.fireDir = Vector(-10, 0)
                    else
                        data.fireDir = Vector(10, 0)
                    end
                    data.state = "Shoot"
                    local dir = "F"
                    if data.dir == -1 then
                        dir = "B"
                    end
                    local frame = math.ceil(sprite:GetFrame()/2)+1
                    if frame == 9 then
                        frame = 1
                    end
                    data.anim = "S" .. dir .. frame
                    data.roll = numToFrames[frame]
                    npc:FireProjectiles(npc.Position, data.fireDir, 0, ProjectileParams())
                    local splat = Isaac.Spawn(1000, 2, 160, npc.Position, npc.Velocity, npc):ToEffect()
                    splat.DepthOffset = 30
                    splat.SpriteOffset = Vector(0,-10)
                    splat:FollowParent(npc)
                    npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
                    npc.StateFrame = -5
                end
            else
                if math.abs(target.Position.X-npc.Position.X) < 15 then
                    if npc.Position.Y > target.Position.Y then
                        data.fireDir = Vector(0, -10)
                    else
                        data.fireDir = Vector(0, 10)
                    end
                    data.state = "Shoot"
                    local dir = "F"
                    if data.dir == -1 then
                        dir = "B"
                    end
                    local frame = math.ceil(sprite:GetFrame()/2)+1
                    if frame == 9 then
                        frame = 1
                    end
                    data.anim = "S" .. dir .. frame
                    data.roll = numToFrames[frame]
                    npc:FireProjectiles(npc.Position, data.fireDir, 0, ProjectileParams())
                    local splat = Isaac.Spawn(1000, 2, 160, npc.Position, npc.Velocity, npc):ToEffect()
                    splat.DepthOffset = 30
                    splat.SpriteOffset = Vector(0,-10)
                    splat:FollowParent(npc)
                    npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
                    npc.StateFrame = -5
                end
            end
        end
    elseif data.state == "Shoot" then
        if sprite:IsFinished(data.anim) then
            data.state = "Idle"
            if data.dir == 1 then
                sprite:SetFrame("RollHori", data.roll)
            else
                sprite:SetFrame("RollBackwards", data.roll)
            end
        else
            mod:spritePlay(sprite, data.anim)
        end
    end

    if mod:isScare(npc) then
        if data.vert then
            if npc.Position.Y > target.Position.Y then
                data.dir = 1
            else
                data.dir = -1
            end
        else
            if npc.Position.X > target.Position.X then
                data.dir = 1
            else
                data.dir = -1
            end
        end
    elseif mod:isConfuse(npc) and rng:RandomInt(5) == 0 then
        data.dir = -1+rng:RandomInt(2)*2
    end

    if data.vert then
        npc.Velocity = mod:Lerp(npc.Velocity, Vector(0,8*data.dir), 0.3)
    else
        npc.Velocity = mod:Lerp(npc.Velocity, Vector(8*data.dir,0), 0.3)
    end
    if npc:CollidesWithGrid() and data.moveFrame > 5 then
        data.dir = data.dir*-1
        data.moveFrame = 0
        npc.StateFrame = 0
        if data.state == "Shoot" then
            data.state = "Idle"
        end
    end
end

function mod:spirollColl(npc, coll, bool)
    if bool and coll:ToNPC() and coll.Type == mod.FF.Spiroll.ID and coll.Variant == mod.FF.Spiroll.Var then
        npc:GetData().dir = npc:GetData().dir*-1
        coll:GetData().dir = coll:GetData().dir*-1
        npc.Velocity = npc.Velocity*-1
        coll.Velocity = coll.Velocity*-1
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        coll:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        mod.scheduleForUpdate(function()
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            coll:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end, 1)
    end
end