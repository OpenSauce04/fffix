local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ZtewieAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        if npc.SubType > 1 then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            local ztewiegroup = {}
            local vec = RandomVector()*10
            for i = 1, npc.SubType do
                local bee = Isaac.Spawn(mod.FF.Ztewie.ID, mod.FF.Ztewie.Var, 0, npc.Position + vec:Rotated(360/i), Vector.Zero, npc.SpawnerEntity):ToNPC()
                bee:GetData().ImBaby = true
				if npc:IsChampion() and i == 1 then
					bee:MakeChampion(69, npc:GetChampionColorIdx(), true)
					bee.HitPoints = bee.MaxHitPoints
				end
                table.insert(ztewiegroup, EntityRef(bee))
            end
            table.insert(mod.ZtewieGroups, {["Bees"] = ztewiegroup, ["CenterPos"] = npc.Position})
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:Remove()
        elseif not data.ImBaby then
            table.insert(mod.ZtewieGroups, {["Bees"] = {EntityRef(npc)}, ["CenterPos"] = npc.Position})
        end
        sprite:Play("Appear")
        data.state = "idle"
        --mod:AddSoundmakerFly(npc) --It sounded painful
        data.Init = true
    end
    if data.state == "idle" then
        if data.flashin then
            if sprite:IsEventTriggered("Finish") then
                sprite:Play("Idle")
                data.flashin = false
            else
                mod:spritePlay(sprite, "Flash")
            end
        else
            mod:spritePlay(sprite, "Fly")
            if data.FlashDelay then
                data.FlashDelay = data.FlashDelay - 1
                if data.FlashDelay <= 0 and sprite:GetFrame() == 1 then
                    data.FlashDelay = nil
                    data.flashin = true
                end
            end
        end
        if data.TargetPos then --Assigned by the group, if its not assigned probably shouldn't try to move!
            data.TargetAngle = data.TargetAngle or mod:RandomAngle()
            data.TargetOffset = data.TargetOffset or mod:RandomInt(0,40)
            if mod:RandomInt(1,5) == 1 then
                data.TargetAngle = data.TargetAngle + mod:RandomInt(-45,45)
                data.TargetOffset = mod:RandomInt(0,40)
            end
            npc.TargetPosition = data.TargetPos + Vector.One:Resized(data.TargetOffset):Rotated(data.TargetAngle)
            if mod:RandomInt(1,3) == 1 or npc.Position:Distance(npc.TargetPosition) > 100 then
                local targetvec = (npc.TargetPosition - npc.Position):Rotated(mod:RandomInt(-20,20)) / 5
                if targetvec:Length() > 12 then
                    targetvec = targetvec:Resized(12)
                end
                npc.Velocity = mod:Lerp(npc.Velocity, targetvec, 0.05)
            end
        end
        mod:FlipSprite(sprite, npc.Position, targetpos)
    elseif data.state == "dashstart" then
        if sprite:IsFinished("DashStart") then
            sprite:Play("Dash")
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.state = "dash"
            npc:PlaySound(mod.Sounds.BeeBuzzPrep, 0.8, 0, false, mod:RandomInt(240,280)/100)
        else
            mod:spritePlay(sprite, "DashStart")
        end
        npc.Velocity = npc.Velocity * 0.9
    elseif data.state == "dash" then
        if npc.Position:Distance(npc.TargetPosition) <= 15 then
            data.state = "shoot"
            sprite:Play("AttackFull")
        else
            npc.Velocity = (npc.TargetPosition - npc.Position):Resized(15)
        end
        mod:spritePlay(sprite, "Dash")
    elseif data.state == "shoot" then
        if sprite:IsFinished("AttackFull") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.state = "idle"
            data.flashin = false
            sprite:Play("Idle")
        else
            mod:spritePlay(sprite, "AttackFull")
        end
        if sprite:IsEventTriggered("Shoot") then
            mod:FlipSprite(sprite, npc.Position, targetpos)
            npc:PlaySound(mod.Sounds.FrogShoot,0.7,0,false,mod:RandomInt(12,14)/10)
            local dummyeffect1 = mod:AddDummyEffect(npc, Vector(10,3))
            local vel = (targetpos - npc.Position):Resized(30)
            local tip = Isaac.Spawn(mod.FF.ZtewieStinger.ID, mod.FF.ZtewieStinger.Var, 0, npc.Position - vel:Resized(npc.Size+2), vel, npc)
            local dummyeffect2 = mod:AddDummyEffect(tip, Vector(-5,0):Rotated(vel:GetAngleDegrees()))
            local cord = Isaac.Spawn(mod.FF.ZtewieCord.ID, mod.FF.ZtewieCord.Var, mod.FF.ZtewieCord.Sub, npc.Position, Vector.Zero, npc)
            cord:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            if mod:isFriend(npc) then
                tip.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
            else
                tip.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            end
            cord.Parent = dummyeffect1
            cord.Target = dummyeffect2
            cord.TargetPosition = Vector.One
            tip.Child = cord
            tip.Parent = npc
            cord.SplatColor = Color(1,1,1,1,0,0,0)
            cord:Update()
            tip.SpriteOffset = Vector(0,-12)
            tip.DepthOffset = npc.Position.Y * 1.25
            cord.DepthOffset = npc.Position.Y * 1.25
            tip:GetData().Effect = dummyeffect2
            data.Effect = dummyeffect1
            data.Stinger = tip
            local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc):ToEffect()
            effect.Color = Color(1,1,1,0.6)
            effect.SpriteOffset = Vector(0,-3)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect:FollowParent(npc)
        elseif sprite:IsEventTriggered("Finish") then
            data.Effect:Remove()
            data.Effect = nil
            data.Stinger.Child:Remove()
            data.Stinger:GetData().Effect:Remove()
            data.Stinger.Visible = false
            data.Stinger:Remove()
            data.Stinger = nil
        end
        npc.Velocity = npc.Velocity * 0.8
    end
end

function mod:ZtewieRemove(npc, data)
    if data.Effect then
        data.Effect:Remove()
    end
    if data.Stinger then
        data.Stinger.Child:Kill()
        data.Stinger:GetData().Effect:Remove()
        data.Stinger.Visible = false
        data.Stinger:Kill()
    end
end

function mod:ZtewieGroupControl(group)
    local room = game:GetRoom()
    group.FlashTimer = group.FlashTimer or mod:RandomInt(60,120)
    group.FlashTimer = group.FlashTimer - 1
    group.AttackTimer = group.AttackTimer or mod:RandomInt(90,150)
    group.AttackTimer = group.AttackTimer - 1
    group.GiveUpTimer = group.GiveUpTimer or 90
    group.GiveUpTimer = group.GiveUpTimer - 1
    group.TargetPos = group.TargetPos or mod:FindRandomFreePosAirNoGrids(group.CenterPos, 120)
    local bees = {}
    for _, beeref in pairs(group.Bees) do
        if beeref.Entity then
            if mod:IsReallyDead(beeref.Entity) then
                beeref.Entity = nil
            else
                table.insert(bees, beeref.Entity)
            end
        end
    end
    local count = #bees
    --print(count)
    if count > 0 then
        for _, bee in pairs(bees) do
            bee:GetData().TargetPos = group.CenterPos
        end
        if group.TargetPos:Distance(group.CenterPos) <= 5 or group.GiveUpTimer <= 0 then
            if count <= 3 then
                group.TargetPos = game:GetNearestPlayer(group.TargetPos).Position
            else
                group.TargetPos = mod:FindRandomFreePosAirNoGrids(group.CenterPos, 120)
            end
            group.GiveUpTimer = 90
        elseif room:GetFrameCount() > 30 then
            group.CenterPos = group.CenterPos + (group.TargetPos - group.CenterPos):Resized(2.5)
        end
        if group.FlashTimer <= 0 then
            local flashbees = {}
            for _, bee in pairs(bees) do
                if bee:Exists() and bee:GetData().state == "idle" and bee.Position:Distance(group.CenterPos) < 120 then
                    table.insert(flashbees, bee)
                end
            end
            local averagepos = Vector(0,0)
            for _, bee in pairs(flashbees) do
                averagepos = averagepos + bee.Position
            end
            averagepos = averagepos / #flashbees
            for _, bee in pairs(flashbees) do
                local dist = averagepos:Distance(bee.Position)
                bee:GetData().FlashDelay = math.floor(dist / 4)
            end
            group.FlashTimer = mod:RandomInt(60,120)
        end
        if group.AttackTimer <= 0 then
            local targetpos = game:GetNearestPlayer(group.CenterPos).Position
            local distance = 10000
            local attackbee 
            for _, bee in pairs(bees) do
                if not (mod:IsReallyDead(bee) or bee:GetData().state ~= "idle") then
                    local dist = bee.Position:Distance(targetpos)
                    if dist < distance then
                        attackbee = bee
                        distance = dist
                    end
                end
            end
            if attackbee then
                attackbee:GetData().state = "dashstart"
                local length = (targetpos - attackbee.Position):Length()
                length = math.max(20, length - 20)
                attackbee.TargetPosition = attackbee.Position + ((targetpos - attackbee.Position):Resized(length))
                mod:FlipSprite(attackbee:GetSprite(), attackbee.Position, attackbee.TargetPosition)
                group.AttackTimer = mod:RandomInt(120,150)
            end
        end
    else
        group = nil
    end
end

function mod:ZtewieStingerAI(npc, sprite, data)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:Play("Idle")
        sprite.Rotation = npc.Velocity:GetAngleDegrees()
        data.Init = true
    end
    npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position - npc.Position):Resized(120), 0.03)
    if npc.Parent and mod:IsReallyDead(npc.Parent) then
        npc:Kill()
        npc.Child:Kill()
    end
end

function mod:ZtewieStingerColl(npc, collider)
    if collider:ToPlayer() then
        collider:TakeDamage(1, 0, EntityRef(npc), 0)
    elseif collider:ToNPC() and not mod:isFriend(collider) then
        collider:TakeDamage(10, 0, EntityRef(npc), 0)
    end
    return true
end