local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MarlinAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        data.state = "idle"
        npc.StateFrame = mod:RandomInt(20,35)
        data.Suffix = "Down"
        data.Init = true
    end
    if data.state == "idle" then
        if npc.FrameCount > 0 then
            data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position)
            if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (not room:CheckLine(data.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
                data.newhome = mod:GetNewPosAligned(npc.Position)
            end
            local targvel = (data.newhome - npc.Position):Resized(3)
            npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)

            if npc.Velocity:Length() > 0.01 then
               local suffix, flipX = mod:GetMoveString(npc.Velocity, true)
               sprite.FlipX = flipX
               data.Suffix = suffix
               mod:spritePlay(sprite, "Move "..data.Suffix)
            else
                data.Suffix = "Down"
                sprite:SetFrame("Move "..data.Suffix, 0)
            end

            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                local check, suffix, flipX = mod:KnightTargetCheck(npc, targetpos, data.Suffix, sprite.FlipX)
                if check and room:CheckLine(npc.Position, targetpos, 0, 0, false, true) then
                    data.state = "chargeprep"
                    data.Suffix = suffix
                    data.ChargeVec = mod:SnapVector((targetpos - npc.Position), 90)
                    sprite.FlipX = flipX
                end
            end
        end
    elseif data.state == "chargeprep" then
        local anim = "Attack"..data.Suffix
        if sprite:IsFinished(anim) then
            data.state = "charge"
        else
            mod:spritePlay(sprite, anim)
        end
        if sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 1, 0.8)
        elseif sprite:IsEventTriggered("Dash") then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.charging = true
        end
        if sprite:WasEventTriggered("Dash") then
            npc.Velocity = mod:Lerp(npc.Velocity, data.ChargeVec:Resized(10), 0.5)
            mod:MarlinChargeCheck(npc)
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    elseif data.state == "charge" then
        local anim = "Run"..data.Suffix
        if not mod:MarlinChargeCheck(npc) then
            mod:spritePlay(sprite, anim)
        end
        npc.Velocity = mod:Lerp(npc.Velocity, data.ChargeVec:Resized(10), 0.5)
    elseif data.state == "bounce" then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished("Bounce") then
            data.state = "idle"
            data.newhome = nil
            npc.StateFrame = mod:RandomInt(30,45)
        else
            mod:spritePlay(sprite, "Bounce")
        end 
        if sprite:IsEventTriggered("Hit") then
            mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, npc, 1.7)
        end
    elseif data.state == "attack" then
        npc.Velocity = npc.Velocity * 0.75
        local anim = "Hit"..data.Suffix
        if sprite:IsFinished(anim) then
            data.state = "idle"
            data.newhome = nil
            npc.StateFrame = mod:RandomInt(30,45)
        else
            mod:spritePlay(sprite, anim)
        end
        if sprite:IsEventTriggered("Hit") then
            mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, npc, 1.7)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_SHELLGAME, npc, 0.8)
            local rocksub = data.RockSub
            local ball = Isaac.Spawn(915,1,rocksub,npc.Position,Vector.Zero,npc):ToNPC()
            ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            ball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            ball.V2 = Vector(0,-40)
            local balldata = ball:GetData()
            balldata.marlinTossed = true
            ball:Update()
            data.RockSub = nil
        end
    end
    if npc:IsDead() then
        if data.RockSub then
            local ball = Isaac.Spawn(915,1,data.RockSub,npc.Position + data.ChargeVec:Resized(npc.Size),npc.Velocity,npc):ToNPC()
            ball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    end
end

function mod:MarlinChargeCheck(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local room = game:GetRoom()
    local endpoint = npc.Position + data.ChargeVec:Resized(npc.Size + 5)
    if room:GetGridCollisionAtPos(endpoint) > GridCollisionClass.COLLISION_NONE --[[npc:CollidesWithGrid()]] then
        local grid = mod:GetNearestRock(endpoint)
        if grid and grid.Position:Distance(endpoint) < 30 then
            local gridtype = grid:GetType()
            grid:Destroy()
            if grid:ToRock() and not (gridtype == GridEntityType.GRID_ROCKB or gridtype == GridEntityType.GRID_ROCK_ALT or gridtype == GridEntityType.GRID_ROCK_ALT2) then
                local rocklayer = 3
                local rocksub 
                if data.Suffix == "Up" then
                    rocklayer = 4
                end
                if gridtype == GridEntityType.GRID_ROCK_GOLD then
                    rocksub = mod.FF.RockBallGold.Sub
                else
                    if mod:CheckStage("Mines", {32, 37, 58}) then
                        rocksub = mod.FF.RockBallMines.Sub
                    else
                        rocksub = mod.FF.RockBallAshpit.Sub
                    end
                end
                data.RockSub = rocksub
                sprite:ReplaceSpritesheet(rocklayer, mod:GetBallSheet(rocksub))
                sprite:LoadGraphics()
                data.state = "attack"
            else
                data.state = "bounce"
            end    
        else
            data.state = "bounce"
        end
        data.charging = false
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        return true
    end
end

function mod:MarlinColl(npc, collider)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    if collider.Type == 915 and collider.Variant == 1 then
        if collider:GetData().marlinTossed then
            return true
        elseif data.charging then
            local endpoint = npc.Position + data.ChargeVec:Resized(npc.Size + 5)
            if collider.Position:Distance(endpoint) < 30 then
                collider:Remove()
                local rocksub = mod:GetBallType(collider.SubType)
                data.RockSub = rocksub
                local rocklayer = 3
                if data.Suffix == "Up" then
                    rocklayer = 4
                end
                sprite:ReplaceSpritesheet(rocklayer, mod:GetBallSheet(rocksub))
                sprite:LoadGraphics()
                data.state = "attack"
                data.charging = false
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            end
        end
    end
end

function mod:GetBallType(subtype)
    local mask = subtype % 8
	return subtype - mask
end

function mod:GetBallSheet(ballType)
    local skin = "gfx/bosses/repentance/singe_ball.png"
    if ballType == mod.FF.RockBallMines.Sub then
        skin = "gfx/grid/balls/rockball_mine.png"
    elseif ballType == mod.FF.RockBallMinesLava.Sub then
        skin = "gfx/grid/balls/rockball_mine_lava.png"
    elseif ballType == mod.FF.RockBallAshpit.Sub then
        skin = "gfx/grid/balls/rockball_ashpit.png"
    elseif ballType == mod.FF.RockBallAshpitLava.Sub then
        skin = "gfx/grid/balls/rockball_ashpit_lava.png"
    elseif ballType == mod.FF.RockBallGold.Sub then
        skin = "gfx/grid/balls/rockball_gold.png"
    elseif ballType == mod.FF.RockBallTumbleweed.Sub then
        skin = "gfx/grid/balls/rockball_tumbleweed.png"
    elseif ballType == mod.FF.RockBallFootball.Sub then
        skin = "gfx/grid/balls/rockball_football.png"
    end
    return skin
end

function mod:GetMoveString(vec, doFlipX)
    if math.abs(vec.Y) > math.abs(vec.X) then
        if vec.Y > 0 then
            return "Down", false
        else
            return "Up", false
        end
    else
        if vec.X > 0 then
            if doFlipX then
                return "Hori", false
            else
                return "Right", false
            end
        else
            if doFlipX then
                return "Hori", true
            else
                return "Left", false
            end
        end
    end
end

function mod:KnightTargetCheck(npc, targetpos, suffix, flipX, margin)
    margin = margin or (npc.Size * 2)
    local isAligned = (math.abs(npc.Position.X - targetpos.X) < margin or math.abs(npc.Position.Y - targetpos.Y) < margin)
    if isAligned and suffix then
        local isBehind = true
        if suffix == "Hori" then
            if flipX then
                isBehind = targetpos.X > npc.Position.X 
            else
                isBehind = targetpos.X < npc.Position.X 
            end
        elseif suffix == "Right" then
            isBehind = targetpos.X > npc.Position.X 
        elseif suffix == "Hori" then
            isBehind = targetpos.X < npc.Position.X 
        elseif suffix == "Down" then
            isBehind = targetpos.Y > npc.Position.Y
        elseif suffix == "Up" then
            isBehind = targetpos.X < npc.Position.X 
        end
        if not isBehind then
            local vec = targetpos - npc.Position
            return true, mod:GetMoveString(vec, true)
        end
    end
end