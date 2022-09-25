local mod = FiendFolio
local game = Game()

--this code is a mess! and i dont really care

local function nearFire(npc, radius)
    local fires = Isaac.FindByType(33, 10)

    local return_fires = {}

    for _, f in ipairs(fires) do
        if f.Position:Distance(npc.Position) < radius then
            table.insert(return_fires, f)
        end
    end

    return return_fires
end

local function updateParentPosition(npc)
    if npc.Parent then
        npc.Parent.Position = npc.Position    
        --npc.Parent.Color = npc:GetColor()
        updateParentPosition(npc.Parent)
    end
end

local function updateMinecartPosition(npc) --doesnt work
    local parent = npc

    while parent.Parent do       
        parent = parent.Parent
    end

    local pos = parent:GetData().inMinecart.Position

    parent = npc

    npc.Position = pos

    while parent.Parent do
        parent.Parent.Position = pos
        parent = parent.Parent
    end
end

local function updateParentSegments(npc) --called when a bottom segment dies
    if npc.Parent then
        if npc.Parent:GetData().numSegments ~= nil then
            npc.Parent:GetData().numSegments = npc.Parent:GetData().numSegments - 1

            if npc.Parent:GetData().numSegments == 0 then
                npc.Parent:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
            end

            updateParentSegments(npc.Parent)
        end
    end        
end

local function updateParentState(npc, state) --change state of all segments above
    if npc.Parent then
        npc.Parent:ToNPC().State = state
        npc.Parent:ToNPC().StateFrame = 0

        if state == 6 then --ahhh what a mess
            npc.Parent:GetData().fallingOffset = 20
        end

        updateParentState(npc.Parent, state)
    end
end

local function updateParentStatus(npc) --update your parents facebook status >:) hi i made this work this isnt needed anymore
    if npc.Parent then --oh boy
        if npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
            npc.Parent:AddFreeze(EntityRef(nil), 1)
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_POISON) then
            npc.Parent:AddPoison(EntityRef(nil), 1, 1)
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_SLOW) then
            npc.Parent:AddSlowing(EntityRef(nil), 1, 0.5, npc:GetSprite().Color)
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
            npc.Parent:AddCharmed(EntityRef(nil), 1)
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
            npc.Parent:AddConfusion(EntityRef(nil), 1, true)
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
            npc.Parent:AddFear(EntityRef(nil), 1)
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_BURN) then
            npc.Parent:AddBurn(EntityRef(nil), 1, 1)    
        end

        updateParentStatus(npc.Parent)
    end
end

local function spawnNextSegment(npc, uneven, inverted, step, count)
    count = count or 1

    local data = npc:GetData()

    if data.numSegments > 0 then
        local segment = Isaac.Spawn(170, 100, 0, npc.Position, Vector.Zero, npc)
        segment.Parent = npc
        npc.Child = segment
        data.prevChild = segment

        segment:ToNPC().State = 4
        segment:ToNPC().StateFrame = 0

        local segd = segment:GetData()

        if uneven then
            if inverted then 
                segd.segmentType = 2 --CANNON
            else
                segd.segmentType = 3 --THORN
            end
        else
            if inverted then 
                segd.segmentType = 3 --THORN
            else
                segd.segmentType = 2 --CANNON
            end
        end

        segd.numSegments = data.numSegments - 1

        local new_seg = uneven
        if count % step == 0 then
            new_seg = not uneven
        end

        spawnNextSegment(segment, new_seg, inverted, step, count + 1)
    else
        if data.segmentType == 1 then
            npc:ToNPC().State = 6
            data.fallingOffset = 0
        else
            npc:ToNPC().State = 2        
        end        
        npc:ToNPC().StateFrame = 0    

        Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)

        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        npc:AddEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

local function runAway(npc, room, speed) --returns velocity, flee the target directly unless youre cornered, in which case seek the corner of the room the target is farthest away from and try to go there
    local target = npc:GetPlayerTarget()
    local pathfinder = npc.Pathfinder

    local t = mod:randomConfuse(npc, target.Position)

    local dir = (npc.Position - t):Normalized()

    if room:FindFreeTilePosition(npc.Position + dir * speed, 0):Distance(npc.Position) < 10 and t:Distance(npc.Position) < 120 then --already there and player is nigh
        local bottom_right = room:GetBottomRightPos()
        local top_left = room:GetTopLeftPos()

        local corners = {top_left, Vector(bottom_right.X, top_left.Y), Vector(top_left.X, bottom_right.Y), bottom_right}

        local best_corner
        local best_dist = 0

        for _, c in ipairs(corners) do
            local dist = t:Distance(c)

            if dist > best_dist then
                best_corner = c
                best_dist = dist
            end
        end

        if best_corner then
            dir = (best_corner - npc.Position):Normalized()
            return dir * speed
        end
    end

    return dir * speed
end

local function chaseTarget(npc, room, speed) --returns velocity
    local target = npc:GetPlayerTarget()
    local target_pos = mod:randomConfuse(npc, target.Position)

    local path = npc.Pathfinder

    if room:CheckLine(npc.Position, target_pos, 0, 1, false, false) or npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
        return mod:reverseIfFear(npc, (target_pos - npc.Position):Resized(speed))
    else
        path:FindGridPath(target_pos, speed / 8, 900, true)
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == mod.FF.Prick.Var then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        if npc:HasEntityFlags(EntityFlag.FLAG_SHRINK) then --no
            npc:ClearEntityFlags(EntityFlag.FLAG_SHRINK)
        end

        if npc.State == 0 and npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then --friendly ball safeguard
            data.segmentType = 1
            data.numSegments = 0
            data.step = 1
            data.inverted = false
                
            npc.State = 3
            npc.StateFrame = 0

            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        end

        if data.inMinecart and not npc.Parent then
            local offset = npc.DepthOffset
            local cart = data.inMinecart
            local c = npc

            while c.Child do
                c = c.Child
            end

            cart.Child = c
            c.DepthOffset = offset
            c:GetData().inMinecart = cart
        end

        local path = npc.Pathfinder
        local target = npc:GetPlayerTarget()
		if mod:isInSegmentsOf(target, npc) then -- Charm/bait compatibility
			target = Isaac.GetPlayer(0)
		end
	    data.target_pos = mod:randomConfuse(npc, target.Position)

        if data.segmentType then
            if data.numSegments then --render height
				data.SwayFrame = data.SwayFrame or 0
                local x_offset = math.sin(((data.SwayFrame + data.numSegments * 15) * math.pi) / 15) --* (0.5 + (data.numSegments / 4)) --majestic cactus sway magic
				data.SwayFrame = data.SwayFrame + 1

                --if data.numSegments == 0 and data.segmentType == 1 then
                --    npc.SpriteOffset = Vector(x_offset, -5) --adjust if theres only one burning guy left so it doesnt look weird
                --else    
                    npc.SpriteOffset = Vector(x_offset, -10 + data.numSegments * -20) --stack em real good
                --end

                if data.fallingOffset then -- if currently falling, adjust offset
                    npc.SpriteOffset = npc.SpriteOffset - Vector(0, data.fallingOffset)
                end
                
                if data.numSegments > 0 then -- non damageable segment (not at the bottom)
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                else --damageable segment (at the bottom)
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

                    if sprite:IsEventTriggered("Hop") then
                        npc:PlaySound(SoundEffect.SOUND_FETUS_JUMP, 1.5, 0, false, 1)
                        npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 0.75)

                        local n_fire = nearFire(npc, 40)

                        if #n_fire > 0 then --destroy nearby fires before spawning a new one to avoid cluttering
                            for _, f in ipairs(n_fire) do
                                f:TakeDamage(f.HitPoints, 0, EntityRef(npc), 0)
                                f:Update()
                            end
                        end
                        
                        local fire = Isaac.Spawn(33, 10, 0, npc.Position, Vector.Zero, npc)

                        local room = game:GetRoom()

                        if (target.Position:Distance(npc.Position) < 200 and not npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)) or npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
                            npc.Velocity = runAway(npc, room, 1) * 8
                        else
                            local angle = math.random(0, 360)

                            npc.Velocity = Vector.FromAngle(angle) * 8
                        end

                        if npc.Velocity.X >= 0 then --sprite adjusting for directional hops
                            if not sprite:IsPlaying("Hop02") then
                                sprite:SetAnimation("Hop02", false)
                            end
                        else
                            if not sprite:IsPlaying("Hop01") then
                                sprite:SetAnimation("Hop01", false)
                            end
                        end
                    end

                    if sprite:IsEventTriggered("Land") then --splat
                        local color = Color(1, 0.45, 0.05, 1, 1/1.2, 0.45/1.2, 0.05/1.2)
                        color:SetColorize(1, 0.45, 0.05, 1)
                
                        local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
                        splat.Color = color
                        splat.Scale = math.random(7, 10)/10
                    end

                    if sprite:WasEventTriggered("Land") then
                        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)

                        local n_fire = nearFire(npc, 40)

                        if #n_fire > 0 then --destroy nearby fires to avoid cluttering
                            for _, f in ipairs(n_fire) do
                                f:TakeDamage(f.HitPoints, 0, EntityRef(npc), 0)
                                f:Update()
                            end
                        end
                    end

                    if npc.State == 3 or (npc.State > 7 and npc.State < 12) then --IDLE
                        local n_fire = nearFire(npc, 40)

                        if #n_fire > 0 then --destroy nearby fires to avoid cluttering
                            for _, f in ipairs(n_fire) do
                                f:TakeDamage(f.HitPoints, 0, EntityRef(npc), 0)
                                f:Update()
                            end
                        end

                        if data.segmentType == 1 then --HEAD: hop away and spawn fires

                            --npc.Velocity = mod:Lerp(npc.Velocity, runAway(npc, room, 5), 0.25)

                            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)

                            if not sprite:IsPlaying("SetFire") and npc.StateFrame > 15 then
                                mod:spritePlay(sprite, "Hop01")

                                npc.State = 15
                                npc.StateFrame = 0
                            end

                            --if npc.FrameCount % 60 == 0 and not nearFire(npc) then --fire spawning
                            --    local fire = Isaac.Spawn(33, 10, 0, npc.Position, Vector.Zero, npc)
                            --end

                            if npc.FrameCount % 15 == 0 and npc.Velocity ~= Vector.Zero then --blood splat effect spawning
                                local color = Color(1, 0.45, 0.05, 1, 1/1.2, 0.45/1.2, 0.05/1.2)
                                color:SetColorize(1, 0.45, 0.05, 1)
                
                                local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
                                splat.Color = color
                                splat.Scale = math.random(3,7)/10
                            end

                        elseif data.segmentType == 2 then --CANNON: shoot and move away if player is close, otherwise approach player
                            local room = game:GetRoom()

                            --data.target_pos = mod:randomConfuse(npc, target.Position)
                            local dist = npc:GetPlayerTarget().Position:Distance(npc.Position)

                            if dist < 220 and dist > 180 then
                                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
                            elseif npc:GetPlayerTarget().Position:Distance(npc.Position) <= 180 then
                                npc.Velocity = mod:Lerp(npc.Velocity, runAway(npc, room, 2), 0.25)
                            else
                                local vel = chaseTarget(npc, room, 2)

                                if vel then
                                    npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
                                end
                            end

                            if npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
                                npc.Velocity = mod:Lerp(npc.Velocity, runAway(npc, room, 3), 0.25)
                            end

                        elseif data.segmentType == 3 then --THORN: chase player
                            local room = game:GetRoom()

                            local vel = chaseTarget(npc, room, 2.5)

                            if vel then
                                npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
                            end
                        end

                    elseif npc.State == 12 then --setting on fire
                        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)
                    elseif npc.State == 2 then --appear animation
                        if npc.StateFrame > 30 then
                            if data.segmentType == 2 then
                                npc:ToNPC().State = 8
                            else
                                npc:ToNPC().State = 3
                            end
                            npc.StateFrame = 0
                        end

                        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)
                    end

                    updateParentPosition(npc)

                    --updateParentStatus(npc) (doesnt work yet) hi i made this work this isn't needed anymore
                end

                if data.inMinecart then
                    npc.Velocity = Vector.Zero
                end

                if sprite:IsEventTriggered("Shoot") and not npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_FEAR) then --projectile shooting
                    if sprite:IsPlaying("Shoot01") then
                        for i = 0, 270, 90 do --cardinals
                            local proj = Isaac.Spawn(9, 1, 0, npc.Position + Vector.FromAngle(i) * 24, Vector.FromAngle(i) * 5, npc):ToProjectile()
                            proj.Height = -15

                            local s = proj:GetSprite()
			                s:Load("gfx/projectiles/projectile_prick.anm2",true)
                            s:Play("Idle",false)
                            s.Rotation = i
                            
                            npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)

                            local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector.Zero, nil):ToEffect()
                            smoke.Color = Color(0.9, 0.9, 0.9, 0.3, 0.9, 0.9, 0.9)
                            smoke.SpriteScale = smoke.SpriteScale * 0.4
                        end
                    elseif sprite:IsPlaying("Shoot02") then
                        for i = 45, 315, 90 do --diagonals
                            local proj = Isaac.Spawn(9, 1, 0, npc.Position + Vector.FromAngle(i) * 24, Vector.FromAngle(i) * 5, npc):ToProjectile()
                            proj.Height = -15

                            local s = proj:GetSprite()
			                s:Load("gfx/projectiles/projectile_prick.anm2",true)
                            s:Play("Idle",false)
                            s.Rotation = i
                            
                            npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)

                            for i = 0, 1 do
                                local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position - Vector(18, 0) + i * Vector(36, 0), Vector.Zero, nil):ToEffect()
                                smoke.Color = Color(0.9, 0.9, 0.9, 0.3, 0.9, 0.9, 0.9)
                                smoke.SpriteScale = smoke.SpriteScale * 0.4
                            end
                        end
                    end
                end

                --cannon animation switching stuff
                if npc.State == 8 then
                    if sprite:IsFinished("Shoot01") then
                        npc.State = 10
                        npc.StateFrame = 0
                    end
                elseif npc.State == 9 then
                    if sprite:IsFinished("Shoot02") then
                        npc.State = 11
                        npc.StateFrame = 0
                    end
                elseif npc.State == 10 then
                    if sprite:IsFinished("Switch01") then
                        npc.State = 9
                        npc.StateFrame = 0
                    end
                elseif npc.State == 11 then
                    if sprite:IsFinished("Switch02") then
                        npc.State = 8
                        npc.StateFrame = 0
                    end
                elseif npc.State == 15 then --hop
                    if (sprite:GetAnimation() == "Hop01" and sprite:IsFinished("Hop01")) or (sprite:GetAnimation() == "Hop02" and sprite:IsFinished("Hop02")) then
                        npc.State = 3
                        npc.StateFrame = 0
                    end
                end

                if npc.State == 6 then --fall
                    if npc.StateFrame == 0 then
                        if data.segmentType == 1 and data.numSegments == 0 then --burning head
                            mod:spritePlay(sprite, "SetFire")
                        end

                        data.fallingOffset = 20
                    else
                        data.fallingOffset = math.max(0, data.fallingOffset - 4)
                    end

                    if data.fallingOffset <= 0 then
                        if data.segmentType == 2 and data.numSegments == 0 then
                            npc.State = 8 --shoot
                        elseif data.segmentType == 1 and data.numSegments == 0 then
                            npc.State = 12 --prepare for fire flee
                        else
                            npc.State = 3 --idle
                        end
                        npc.StateFrame = 0
                    end
                end

                npc.StateFrame = npc.StateFrame + 1

                if data.segmentType == 1 and data.numSegments == 0 then --burning head
                    if sprite:IsEventTriggered("Combust") then
                        --npc.DepthOffset = -1000
                        npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A, 1, 0, false, 1)
                        --Isaac.Spawn(33, 10, 0, npc.Position, Vector.Zero, npc)
                    end

                    if sprite:IsFinished("SetFire") then
                        mod:spritePlay(sprite, "Hop01")

                        npc.State = 15 --hop
                        npc.StateFrame = 0
                    end

                    if npc.State == 3 then
                        mod:spritePlay(sprite, "Idle04")
                    end
                else
                    if npc.State == 4 then
                        mod:spritePlay(sprite, "Idle0"..data.segmentType)
                    else
                        if data.segmentType == 2 then --cannon
                            if npc.State == 8 then
                                mod:spritePlay(sprite, "Shoot01") --cardinal shot
                            elseif npc.State == 9 then
                                mod:spritePlay(sprite, "Shoot02") --diagonal shot
                            elseif npc.State == 10 then
                                mod:spritePlay(sprite, "Switch01") --switch to diagonals
                            elseif npc.State == 11 then
                                mod:spritePlay(sprite, "Switch02") --switch to cardinals
                            else
                                mod:spritePlay(sprite, "Idle0"..data.segmentType)
                            end
                        else
                            mod:spritePlay(sprite, "Idle0"..data.segmentType)
                        end
                    end
                end
            end
        end
    end
end, 170)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
    if npc.Variant == mod.FF.Prick.Var and npc:GetData().numSegments then
        if npc:GetData().numSegments == 0 then
            npc.DepthOffset = -20
        else
            npc.DepthOffset = npc:GetData().numSegments * 30
        end
    end
end, 170)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if npc.Variant == mod.FF.Prick.Var then
        local data = npc:GetData()

        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_TARGET)-- | EntityFlag.FLAG_NO_STATUS_EFFECTS) --status effect immunity is temporary until i cba to properly implement it hi i made this work this isnt needed anymore

        if npc.SubType == 999999 then --default 3 segment guy for debug purposes
            data.segmentType = 1
            data.numSegments = 2
            data.step = 1
            data.inverted = false

            npc.State = 4
            npc.StateFrame = 0

            spawnNextSegment(npc, true, data.inverted, data.step)

        elseif npc.SubType ~= 0 then --placed in basement renovator
            data.segmentType = 1 --HEAD
            data.numSegments = (npc.SubType % 1024) - 1 --get number of additional segments from br parameter

            data.step = math.floor(npc.SubType / 2048)

            if npc.SubType & 1024 >= 1024 then
                data.inverted = true
            else
                data.inverted = false
            end

            npc.State = 4 --waiting in line
            npc.StateFrame = 0

            spawnNextSegment(npc, true, data.inverted, data.step)
        end
    end
end, 170)

function mod:prickOnStatusDeath(npc)
    updateParentSegments(npc)
    updateParentState(npc, 6)

    npc:GetData().killed = true
	
	if npc.Child then
		npc.Child.Parent = nil
		npc.Child = nil
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
    if npc.Variant == mod.FF.Prick.Var then
        updateParentSegments(npc)
        updateParentState(npc, 6)

        npc:GetData().killed = true

        local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector.Zero, nil):ToEffect()

        if npc:GetData().segmentType == 1 then
            local color = Color(0, 0, 0, 1, 0, 0, 0) --charred
                
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
            splat.Color = color
            splat.Scale = 1.2

            smoke.Color = Color(0, 0, 0, 0.7, 0, 0, 0)

            local fire = Isaac.Spawn(33, 10, 0, npc.Position, Vector.Zero, npc)
        else
            if npc:GetData().segmentType == 3 then --thorn
                npc:ToNPC():PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, 1, 0, false, 1)

                for i = 20, 335, 45 do --burst into spikes upon death
                    local dir = Vector.FromAngle(i)
                    local proj = Isaac.Spawn(9, 1, 0, npc.Position + dir * 24, dir * 5, npc):ToProjectile()
                    proj.Height = -12

                    local s = proj:GetSprite()
                    s:Load("gfx/projectiles/projectile_prick.anm2",true)
                    s:Play("Idle",false)
                    s.Rotation = i
                end
            end

            smoke.Color = Color(0.9, 0.9, 0.9, 0.7, 0.9, 0.9, 0.9)
        end
        smoke.SpriteScale = smoke.SpriteScale * 1.5
    end
end, 170)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent)
    if ent.Variant == mod.FF.Prick.Var and not ent:GetData().killed then --only update bottom segments, dont do on kill stuff
        updateParentSegments(ent)
        updateParentState(ent, 6)
    end
end, 170)