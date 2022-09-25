local mod = FiendFolio
local game = Game()

mod.pyroclasmAnimDirections = {
    [0] = "Left",
    [1] = "Up",
    [2] = "Right",
    [3] = "Down"
}

local function pyroclasmUpdateAnim(npc, anim, start)
    start = start or false

    local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget() or Isaac.GetPlayer(0)

    local oldAnim = sprite:GetAnimation()

    local facingAngle = (player.Position - npc.Position):GetAngleDegrees()
    local direction = 0

    if player.Position.Y < npc.Position.Y then facingAngle = facingAngle + 360 end

    if facingAngle >= 315 or facingAngle < 45 then direction = 2
    elseif facingAngle >= 45 and facingAngle < 135 then direction = 3
    elseif facingAngle >= 135 and facingAngle < 225 then direction = 0
    else direction = 1 end

    local frame = sprite:GetFrame()
    if start then frame = 0 end

    mod:spritePlay(sprite, anim..mod.pyroclasmAnimDirections[direction])
    npc:GetData().anim = anim..mod.pyroclasmAnimDirections[direction]

    if oldAnim ~= npc:GetData().anim then sprite:SetFrame(frame) end
end

local function closeToOthers(npc, dist)
    local others = Isaac.FindByType(170, npc.Variant)

    for _, o in pairs(others) do
        if o.Index ~= npc.Index and o.Position:Distance(npc.Position) < dist then return o end
    end

    return false
end

local function isFireNearby(position, radius)
    for _, e in pairs(Isaac.FindInRadius(position, radius)) do
        if e.Type == 33 then
            return e
        end
    end
    return false
end

local function pyroclasmGetNewPos(npc, target, room) -- i hope this finally works properly
    local predict = target.Position + target.Velocity
    local pos = predict
    local deg = math.random(1, 360) 

    pos = room:FindFreePickupSpawnPosition(predict + Vector.FromAngle(deg) * math.random(180, 220), 80, true) --get random position on a circle of slightly variable diameter around the player

    for i=1,360 do 
        if not (pos:Distance(predict) < 80 or closeToOthers(npc, 80)) then break end --but dont teleport too close to where the player will be or another pyroclasm is
           
        deg = deg + 1

        pos = room:FindFreePickupSpawnPosition(predict + Vector.FromAngle(deg) * 200, 80, true)
    end

    local fire = isFireNearby(pos, 20) --so it doesnt teleport into fires
    if fire then pos = Isaac.GetFreeNearPosition(fire.Position, 40) end

    return pos
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj) --fancy cursed bone effect
    if proj.SpawnerType == 170 and proj.SpawnerVariant == 90 then --if spawned by pyroclasm
        if proj.FrameCount % 2 == 0 then
            local c = Color(0.77, 0.8, 0.8, 0.7, 0.4, 0.7, 1)
            --c:SetTint(0.97, 0.95, 1, 1)

            local haemoCenter = Isaac.Spawn(1000, 111, 0, proj.Position, proj.Velocity, proj):ToEffect()
            haemoCenter.SpriteOffset = Vector(0, proj.Height + 10)
            haemoCenter.DepthOffset = -100
            haemoCenter.SpriteScale = Vector(0.5, 0.5)
            haemoCenter.Color = c

            local haemo = Isaac.Spawn(1000, 111, 0, proj.Position, Vector(0, 0), proj):ToEffect()
            haemo.SpriteOffset = Vector(math.random(-4,4), proj.Height + 10 + math.random(-4,4))
            haemo.DepthOffset = -100
            local ss = math.random(0, 5) / 10
            haemo.SpriteScale = Vector(ss, ss)       
            haemo.Color = c
            haemo:Update()
        end
    end

end, 1)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == mod.FF.Pyroclasm.Var then
        local sprite = npc:GetSprite()
        local player = npc:GetPlayerTarget()
        
        if npc:GetData().state == "appear" then
            mod:spritePlay(sprite, "Appear")

            if sprite:IsFinished("Appear") then
                if npc:GetData().inMinecart then --if in minecart dont teleport
                    npc:GetData().shootingTimer = math.random(2, 16)
                    npc:GetData().teleportTimer = nil
                else
                    npc:GetData().shootingTimer = nil
                    npc:GetData().teleportTimer = math.random(2, 16)
                end
                npc:GetData().state = "idle"
                npc.StateFrame = 0
            end
        elseif npc:GetData().state == "init" then --init

            if closeToOthers(npc, 20) then --if you get wayyy too close to another guy, teleport away immediately
                --npc:PlaySound(SoundEffect.SOUND_SKIN_PULL, 1, 0, false, 1)

                --pyroclasmUpdateAnim(npc, "Teleport", true)
                --npc:GetData().state = "teleport"
                --npc.StateFrame = 0
                local room = game:GetRoom()

                npc.Position = pyroclasmGetNewPos(npc, player, room)
            end

            if npc.StateFrame > 9 then
                npc:GetData().shootingTimer = math.random(2, 16)
                npc:GetData().teleportTimer = nil
                npc:GetData().state = "idle"
                npc.StateFrame = 0
            else
                pyroclasmUpdateAnim(npc, "Back")
            end

        elseif npc:GetData().state == "idle" then --idle

            pyroclasmUpdateAnim(npc, "Idle")

            if not npc:GetData().teleportTimer then
                if npc.StateFrame > npc:GetData().shootingTimer and not mod:isScareOrConfuse(npc) then --after a bit, go into attack mode
                    pyroclasmUpdateAnim(npc, "Shoot", true)
                    npc:GetData().state = "attack"
                    npc.StateFrame = 0
                end
            elseif npc.StateFrame > npc:GetData().teleportTimer and not mod:isScareOrConfuse(npc) then --if in pre-teleport idle, teleport
                npc:PlaySound(SoundEffect.SOUND_SKIN_PULL, 1, 0, false, 1)

                pyroclasmUpdateAnim(npc, "Teleport", true)
                npc:GetData().state = "teleport"
                npc.StateFrame = 0
            end

        elseif npc:GetData().state == "attack" then

            if sprite:IsEventTriggered("Reload") then --load up with shots
                npc:GetData().shotsLeft = 4
            end

            if sprite:IsEventTriggered("Shoot") and npc:GetData().shotsLeft > 0 then --unload shots
                if not mod:isScareOrConfuse(npc) then --fear/confusion check
                    local params = ProjectileParams()
                    params.Variant = 1
                    params.HeightModifier = -10

                    npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
                    npc:FireProjectiles(npc.Position, (player.Position - npc.Position):Normalized() * 8, 0, params)
                end

                npc:GetData().shotsLeft = npc:GetData().shotsLeft - 1
            end

            if sprite:GetFrame() >= 41 then --once done attacking, go into pre-teleport idle
                if npc:GetData().inMinecart then --if in minecart dont teleport
                    npc:GetData().shootingTimer = math.random(2, 16)
                    npc:GetData().teleportTimer = nil
                else
                    npc:GetData().shootingTimer = nil
                    npc:GetData().teleportTimer = math.random(2, 16)
                end
                npc:GetData().state = "idle"
                npc.StateFrame = 0
            else
                pyroclasmUpdateAnim(npc, "Shoot")
            end

        elseif npc:GetData().state == "teleport" then

            if sprite:GetFrame() >= 16 then
                local room = game:GetRoom() --teleport behind player

                npc.Position = pyroclasmGetNewPos(npc, player, room)

                pyroclasmUpdateAnim(npc, "Back", true)
                npc:GetData().state = "init"
                npc.StateFrame = 0
            else
                pyroclasmUpdateAnim(npc, "Teleport")
            end

        end
        
        npc.StateFrame = npc.StateFrame + 1

        if npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then  --dont slide around or slightly away from player if scared
            npc.Velocity = (npc.Position - player.Position):Normalized() * 0.5
        elseif npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
            npc.Velocity = mod:Lerp(npc.Velocity, Vector(math.random(-1, 1), math.random(-1, 1)), 0.5)
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector(0,0), 0.5)
        end
    end
end, 170)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if npc.Variant == mod.FF.Pyroclasm.Var then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:GetData().state = "appear"
        npc.StateFrame = 0
        npc:GetSprite():Play("BackDown", true)

        npc:GetData().shotsLeft = 0
    end
end, 170)