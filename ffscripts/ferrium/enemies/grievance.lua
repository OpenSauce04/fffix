local mod = FiendFolio

function mod:grievanceAI(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local room = Game():GetRoom()

    if not data.init then
        data.state = "Idle"
        npc.CollisionDamage = 0
        local aura = Isaac.Spawn(mod.FF.FocusCrystalRing.ID, mod.FF.FocusCrystalRing.Var, mod.FF.FocusCrystalRing.Sub, npc.Position, Vector.Zero, npc):ToEffect()
		aura.Parent = npc
		aura:FollowParent(npc)
        local val = (100+(npc.SubType-100))/100
        aura.SpriteScale = Vector(val, val)
        data.aura = aura
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    npc.State = 16
    if data.charged then
        npc.CollisionDamage = 1

        if npc:CollidesWithGrid() then
            npc:PlaySound(SoundEffect.SOUND_STONE_IMPACT, 0.5, 0, false, math.random(100,120)/100)
        end

        if npc.Velocity:Length() > 3 then
            if npc.FrameCount % 4 == 0 then
                local cloud = Isaac.Spawn(1000, 59, 0, npc.Position, RandomVector(), npc):ToEffect()
                cloud.SpriteScale = Vector(0.3, 0.3)
                cloud:SetTimeout(10)
                cloud.Color = Color(0.45, 0.45, 0.45, 0.6, 0, 0, 0)
                cloud:Update()
            end
        end
    end
    if room:IsClear() or mod.areRoomPressurePlatesPressed() then
        mod:spritePlay(sprite, "Disabled")
        npc.CollisionDamage = 0
        data.charged = nil
        npc.Mass = 5

        if npc:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end

        if data.aura then
            data.aura:Remove()
            data.aura = nil
        end
    elseif data.state == "Idle" then
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)

        if npc.StateFrame > 30 and data.aura then
            data.aura.Color = Color.Lerp(data.aura.Color, Color(1,1,1,1,0,0,0), 0.05)
        end

        if target.Position:Distance(npc.Position) < npc.SubType and npc.StateFrame > 50 then
            data.state = "Charge"
        end

        mod:spritePlay(sprite, "Disabled")
    elseif data.state == "Charging" then
        npc.Velocity = npc.Velocity:Resized(data.vel)
        data.vel = data.vel*0.98
        if data.vel < 1 then
            data.state = "Stopping"
        end

        local targAng = (target.Position-npc.Position):GetAngleDegrees()-45
		if targAng < 0 then
			targAng = targAng+360
		end
		local currentAngle = math.ceil(targAng/40)
		sprite:SetFrame("Looking", currentAngle)
    elseif data.state == "Stopping" then
        if sprite:IsFinished("Shut") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 1)
            data.charged = nil
        else
            mod:spritePlay(sprite, "Shut")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
    elseif data.state == "Charge" then
        if sprite:IsFinished("Charge") then
            data.state = "Charging"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 1)
            npc.Velocity = (target.Position-npc.Position):Resized(20)
            data.vel = 20
            data.charged = true
        else
            mod:spritePlay(sprite, "Charge")
        end

        if data.charged then
            npc.Velocity = npc.Velocity:Resized(data.vel)
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
        end

        data.aura.Color = Color(1,1,1,0,0,0,0)
    end

    if data.soundCooldown then
        if data.soundCooldown > 0 then
            data.soundCooldown = data.soundCooldown-1
        else
            data.soundCooldown = nil
        end
    end
end

function mod:grievanceColl(npc, coll)
    if coll.Type == mod.FF.Grievance.ID and coll.Variant == mod.FF.Grievance.Var and mod:IsActiveRoom() then
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        coll:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        mod.scheduleForUpdate(function()
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            coll:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end, 1)
        if coll:GetData().charged == nil then
            local cdata = coll:GetData()
            cdata.charged = true
            cdata.vel = npc.Velocity:Length()
            cdata.state = "Charging"
            npc:PlaySound(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 1)
            if cdata.aura then
                cdata.aura.Color = Color(1,1,1,0,0,0,0)
            end
        end
        if not npc:GetData().soundCooldown then
            npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 0.5, 0, false, math.random(100,120)/100)
            npc:GetData().soundCooldown = 4
        end
    end
end