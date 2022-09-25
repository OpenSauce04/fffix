local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:WeeperAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local room = game:GetRoom()
    if not data.Init then
        if npc.SubType == 1 then
            mod.makeWaitFerr(npc, npc.Type, npc.Variant, 0, 40, true)
        else
            sprite:Play("Eye Open")
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            if data.waited then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
            npc.SplatColor = mod.ColorRottenGreen
        end
        data.Init = true
    end
    mod.QuickSetEntityGridPath(npc)
    mod.NegateKnockoutDrops(npc)
    npc.Velocity = Vector.Zero
    if sprite:IsFinished("Eye Open") then
        sprite:Play("Eye Opened")
        if data.TryAgainSooner then
            data.TryAgainSooner = false
            npc.StateFrame = mod:RandomInt(30,50)
        else
            npc.StateFrame = mod:RandomInt(40,80)
        end
    elseif sprite:IsFinished("Shoot") then
        sprite:Play("Eye Close")
        npc.StateFrame = mod:RandomInt(15,30)
    elseif sprite:IsFinished("Eye Close") then
        npc.StateFrame = npc.StateFrame - 1
        if not data.HiddenAway then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
            npc.Visible = false
            data.HiddenAway = true
        end
        if npc.StateFrame <= 0 then
            sprite:Play("Eye Open")
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
            npc.Position = mod:FindRandomFreePos(npc, 120, false, true)
            npc.Visible = true
            data.HiddenAway = false
        end
    end
    if sprite:IsPlaying("Eye Opened") then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if target.Position:Distance(npc.Position) < 400 then
                sprite:Play("Shoot")
            else
                sprite:Play("Eye Close")
                data.TryAgainSooner = true
                npc.StateFrame = mod:RandomInt(15,30)
            end
        end
    end
    if sprite:IsEventTriggered("Telegraph") then
        local targetpos = npc:GetPlayerTarget().Position
        local rand = (rng:RandomFloat() <= 0.5)
        local tracer = Isaac.Spawn(mod.FF.CustomTracer.ID, mod.FF.CustomTracer.Var, mod.FF.CustomTracer.Sub, npc.Position, Vector.Zero, npc):ToEffect()
        if rand then
            data.ShootRot = -2
            data.Angle = mod:GetAngleDegreesButGood(targetpos - npc.Position) + 15
            tracer:GetData().Weeper = data.ShootRot
        else
            data.Angle = mod:GetAngleDegreesButGood(targetpos - npc.Position) - 15
            data.ShootRot = 2
            tracer:GetData().Weeper = data.ShootRot
        end
        npc.TargetPosition = Vector.One:Rotated(data.Angle)
        tracer:GetData().Angle = data.Angle
        local _, endPos = room:CheckLine(tracer.Position, tracer.Position + Vector(1000,0):Rotated(data.Angle), 3)
        endPos = mod:FixLaserBug(data.Angle, room, endPos)
        tracer.TargetPosition = endPos
        tracer.Color = Color(1,0.5,0.3,0.8)
        tracer:Update()
        npc:PlaySound(mod.Sounds.EpicTwinkle,1,1,false,0.8)
    elseif sprite:IsEventTriggered("Shoot") then
        local laser = Isaac.Spawn(7,2,0,npc.Position, Vector.Zero, npc):ToLaser()
        laser.Parent = npc
        local laserOrigin = laser.Parent.Position
        local _, endPos = room:CheckLine(laserOrigin, laserOrigin + Vector(1000,0):Rotated(data.Angle), 3)
        endPos = mod:FixLaserBug(laser.AngleDegrees, room, endPos)
        laser:SetMaxDistance(laser.Parent.Position:Distance(endPos))
        laser.DepthOffset = npc.DepthOffset + 100
        laser.Angle = data.Angle
        laser:SetTimeout(15)
        laser:GetData().Weeper = data.ShootRot
        laser.CollisionDamage = 0
        laser:Update()
        sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_STRONG)
        sfx:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP)
    end
end

function mod:WeeperLaser(laser, data)
    if not laser.Parent or mod:isStatusCorpse(laser.Parent) then
        laser:SetTimeout(1)
        return
    end
    laser.Angle = laser.Angle + data.Weeper
    local room = game:GetRoom()
    local laserOrigin = laser.Parent.Position
    local _, endPos = room:CheckLine(laserOrigin, laserOrigin + Vector(1000,0):Rotated(laser.AngleDegrees), 3)
    endPos = mod:FixLaserBug(laser.AngleDegrees, room, endPos)
    laser:SetMaxDistance(laser.Parent.Position:Distance(endPos))
    if laser.FrameCount % 2 == 0 then
        local effect = Isaac.Spawn(1000,5,0,endPos,(laserOrigin - endPos):Rotated(mod:RandomInt(-40,40)):Resized(7), laser.Parent)
        effect.Color = mod.ColorRottenGreen
        --[[local projectile = Isaac.Spawn(9,0,0,endPos,(laserOrigin - endPos):Rotated(mod:RandomInt(-40,40)):Resized(7), laser.Parent):ToProjectile()
        if rng:RandomFloat() <= 0.5 then
            effect.Color = mod.ColorCorpseGreen
        else
            effect.Color = mod.ColorCorpseGreen2
        end]]
        local effect2 = Isaac.Spawn(1000,2,2,effect.Position,Vector.Zero,laser.Parent)
        effect2.Color = mod.ColorRottenGreen
    end
end