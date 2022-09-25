local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MazeRunnerAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        if data.fiendfolio_spawnedFromHaemoGlobin then
            mod:MazeRunnerPhaseTwo(npc)
        elseif npc.SubType == 0 then
            local twin = Isaac.Spawn(mod.FF.MazeRunner.ID, mod.FF.MazeRunner.Var, mod.FF.MazeRunnerRed.Sub, mod:GetMirroredRoomPos(npc.Position), Vector.Zero, nil):ToNPC()
            twin.Parent = npc
            npc.Child = twin
            if npc:IsChampion() then
                twin:MakeChampion(npc.InitSeed, npc:GetChampionColorIdx(), true)
                twin.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                twin.HitPoints = twin.MaxHitPoints
            end
            npc.StateFrame = mod:RandomInt(60,100)
        end
        data.Init = true
    end
    if data.Recovering then
        mod:spritePlay(sprite, data.LastAnim)
        if npc.Parent and npc.Parent:Exists() then
            npc.TargetPosition = mod:GetMirroredRoomPos(npc.Parent.Position)
            npc.Velocity = npc.TargetPosition - npc.Position
        else
            npc.Velocity = npc.Velocity * 0.8
        end
        if npc.SubType == 0 or npc.I1 == 1 then
            if npc.StateFrame <= 0 then
                if npc.I1 == 1 then
                    npc.StateFrame = 30
                else
                    npc.StateFrame = mod:RandomInt(120,160)
                end
                data.Recovering = false
                data.Charging = false
                if npc.Child and npc.Child:Exists() then
                    npc.Child:GetData().Charging = false
                    npc.Child:GetData().Recovering = false
                end
            else
                npc.StateFrame = npc.StateFrame - 1
            end
        end
    elseif data.Charging then
        mod:AnimateMazerunner(npc, data.ChargeVec)
        data.LastAnim = sprite:GetAnimation()
        if npc.Parent and npc.Parent:Exists() then
            npc.TargetPosition = mod:GetMirroredRoomPos(npc.Parent.Position)
            npc.Velocity = npc.TargetPosition - npc.Position
        elseif npc.Velocity:Length() < 12 then
            npc.Velocity = npc.Velocity * 1.05
        end
        if npc:CollidesWithGrid() and not (npc.Parent and npc.I1 ~= 1) then
            local params = ProjectileParams()
            params.FallingSpeedModifier = 2
            local speed = 6
            if npc.Child then
                if npc.Child:Exists() and npc.Child:GetData().Charging then
                    npc.Child:GetData().Recovering = true
                    for i = -60, 60, 40 do
                        npc.Child:ToNPC():FireProjectiles(npc.Child.Position, npc.Child:GetData().ChargeVec:Resized(speed):Rotated(i + 180), 0, params)
                    end
                    local effect = Isaac.Spawn(1000,16,4,npc.Child.Position,Vector.Zero,npc.Child):ToEffect()
                    effect:FollowParent(npc.Child)
                    effect.SpriteScale = Vector(0.6,0.6)
                end
            end
            for i = -60, 60, 40 do
                npc:FireProjectiles(npc.Position, data.ChargeVec:Resized(speed):Rotated(i + 180), 0, params)
            end
            local effect = Isaac.Spawn(1000,16,4,npc.Position,Vector.Zero,npc):ToEffect()
            effect:FollowParent(npc)
            effect.SpriteScale = Vector(0.6,0.6)
            sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.8)
            if npc.SubType == 0 or npc.I1 == 1 then
                npc.StateFrame = 30
            end
            data.Recovering = true
        end
    elseif npc.I1 == 1 then
        if not data.P2Init then
            sprite:Play("Transition")
            data.P2Init = true
        end
        if sprite:IsFinished("Transition") then
            sprite:Play("WalkDown2")
        end
        if sprite:IsPlaying("Transition") then
            npc.Velocity = Vector.Zero
            if sprite:IsEventTriggered("Shoot") then
                mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 1, 0.8)
            end
        else
            mod:AnimateMazerunner(npc, npc.Velocity)
            local chargevel = mod:GetChargeVector(targetpos - npc.Position, npc.Velocity:Length())
            if npc.Velocity:Length() > 4 and npc.StateFrame <= 0 and (math.abs(targetpos.X - npc.Position.X) < 15 or math.abs(targetpos.Y - npc.Position.Y) < 15) and mod:LineCheckPlus(npc, chargevel, npc.Position:Distance(targetpos)) then
                npc.Velocity = chargevel
                data.ChargeVec = chargevel
                data.Charging = true
            else
                local vel 
                if mod:isScare(npc) then
                    vel = (targetpos - npc.Position):Resized(-7)
                    data.newhome = nil
                elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
                    vel = (targetpos - npc.Position):Resized(5)
                    data.newhome = nil
                elseif npc.Pathfinder:HasPathToPos(targetpos) then
                    npc.Pathfinder:FindGridPath(targetpos, (7 * 0.1) + 0.2, 900, true)
                    data.newhome = nil
                else
                    data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position)
                    if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (not room:CheckLine(data.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
                        data.newhome = mod:GetNewPosAligned(npc.Position)
                    end
                    local targvel = (data.newhome - npc.Position):Resized(5)
                    if mod:isScare(npc) then
                        targvel = (targetpos - npc.Position):Resized(-7)
                    end
                    npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
                end
                if vel then
                    npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
                end
                npc.StateFrame = npc.StateFrame - 1
            end
        end
    else
        if sprite:IsFinished("Appear") then
            sprite:Play("WalkDown")
        end
        if not sprite:IsPlaying("Appear") then
            mod:AnimateMazerunner(npc, npc.Velocity)
        end
    end
    if npc.SubType == mod.FF.MazeRunnerRed.Sub then
        if npc.Parent and not mod:IsReallyDead(npc.Parent) then
            npc.TargetPosition = mod:GetMirroredRoomPos(npc.Parent.Position)
            npc.Velocity = npc.TargetPosition - npc.Position
        elseif npc.I1 ~= 1 then
            mod:MazeRunnerPhaseTwo(npc)
        end
    else
        if npc.Child and not mod:IsReallyDead(npc.Child) then
            if sprite:IsPlaying("Appear") then
                npc.Velocity = Vector.Zero
            elseif not data.Charging or data.Recovering then
                if npc.StateFrame <= 0 then
                    local chargevel = mod:GetChargeVector(npc.Velocity, npc.Velocity:Length())
                    if npc.Velocity:Length() >= 2 and mod:LineCheckPlus(npc, chargevel, 100) then
                        npc.Velocity = chargevel
                        data.ChargeVec = chargevel
                        data.Charging = true
                        npc.Child:GetData().Charging = true
                        npc.Child:GetData().ChargeVec = chargevel:Rotated(180)
                    end
                end
                if not data.Charging then
                    data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position)
                    if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (not room:CheckLine(data.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
                        data.newhome = mod:GetNewPosAligned(npc.Position)
                    end
                    local targvel = (data.newhome - npc.Position):Resized(2.5)
                    if mod:isScare(npc) then
                        targvel = (targetpos - npc.Position):Resized(-4)
                    end
                    npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
                    npc.StateFrame = npc.StateFrame - 1
                end
            end
        elseif npc.I1 ~= 1 then
            mod:MazeRunnerPhaseTwo(npc)
        end
    end
end

function mod:GetMirroredRoomPos(pos)
    local center = game:GetRoom():GetCenterPos()
    local targetVec = pos - center
    targetVec = Vector(targetVec.X * -1, targetVec.Y * -1)
    return center + targetVec
end

function mod:AnimateMazerunner(npc, vec)
    local sprite = npc:GetSprite()
    if vec:Length() <= 0.1 then
        if npc.I1 == 1 then
            sprite:SetFrame("WalkDown2", 0)
        else
            sprite:SetFrame("WalkDown", 0)
        end
    else
        local anim
        if math.abs(vec.X) > math.abs(vec.Y) then
            if vec.X > 0 then
                anim = "WalkRight"
            else
                anim = "WalkLeft"
            end
        else
            if vec.Y > 0 then
                anim = "WalkDown"
            else
                anim = "WalkUp"
            end
        end
        if npc.I1 == 1 then
            anim = anim.."2"
        end
        mod:spritePlay(sprite, anim)
    end
end

function mod:MazeRunnerPhaseTwo(npc)
    local data = npc:GetData()
    npc.I1 = 1
    data.Charging = false
    data.Recovering = false
    npc.StateFrame = 10
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end

function mod:GetChargeVector(vec, length)
    if math.abs(vec.X) > math.abs(vec.Y) then
        if vec.X < 0 then
            return Vector(-length, 0)
        else
            return Vector(length, 0)
        end
    else
        if vec.Y < 0 then
            return Vector(0, -length)
        else
            return Vector(0, length)
        end
    end
end

function mod:LineCheckPlus(npc, vec, length)
    local room = game:GetRoom()
    local pos = npc.Position
    if room:CheckLine(pos, pos + vec:Resized(length), 0, false, false) then
        pos = npc.Position + vec:Rotated(90):Resized(npc.Size)
        if room:CheckLine(pos, pos + vec:Resized(length), 0, false, false) then
            pos = npc.Position + vec:Rotated(270):Resized(npc.Size)
            if room:CheckLine(pos, pos + vec:Resized(length), 0, false, false) then
                return true
            end
        end
    end
    return false
end