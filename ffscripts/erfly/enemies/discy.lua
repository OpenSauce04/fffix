local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:discyRelay(npc, subt, var)
    if subt == mod.FF.Nobody.Sub then
        mod:nobodyAI(npc)
    else
        mod:discyAI(npc)
    end
end

function mod:discyAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()
	local path = npc.Pathfinder
    local room = game:GetRoom()

    npc.StateFrame = npc.StateFrame + 1

    if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end
    if d.transitioning then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsOverlayPlaying("Transition") and sprite:GetOverlayFrame() >= 11 then
            npc.SubType = mod.FF.Nobody.Sub
            npc.StateFrame = 0
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)
            npc:BloodExplode()
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
            local vec = (target.Position - npc.Position):Resized(9)
            local buzz = Isaac.Spawn(mod.FF.DangerousDiscGuide.ID, mod.FF.DangerousDiscGuide.Var, 0, npc.Position + vec:Resized(30), vec, npc)
            buzz:GetData().shooting = vec
            buzz:Update()
            npc.MaxHitPoints = 30
            npc.HitPoints = npc.MaxHitPoints
            npc.Velocity = -vec:Resized(4)
            mod:nobodyAI(npc)
        else
            mod:spriteOverlayPlay(sprite, "Transition")
        end
    else
        mod:spriteOverlayPlay(sprite, "Head01")
        if npc.StateFrame > 160 or not d.walktarg then
            d.walktarg = mod:FindRandomValidPathPosition(npc)
            npc.StateFrame = 0
        end
        if npc.Position:Distance(d.walktarg) > 30 then
            if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) then
                local targetvel = (d.walktarg - npc.Position):Resized(3)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
            else
                path:FindGridPath(d.walktarg, 0.5, 900, true)
            end
        else
            npc.Velocity = npc.Velocity * 0.7
            npc.StateFrame = npc.StateFrame + 2
        end
    end
end

function FiendFolio.DiscyDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        deathAnim:GetData().Init = true
        deathAnim:GetData().transitioning = true
	end
	FiendFolio.genericCustomDeathAnim(npc, "Transition", true, onCustomDeath, true, true, false)
end

function mod:nobodyAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()

    if not d.init then
        d.state = "passive"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end    

    if d.state == "passive" then
        if not sprite:IsOverlayPlaying("Transition") then
            mod:spriteOverlayPlay(sprite, "Head02")
        end
        d.nextReset = d.nextReset or 30
        if (not d.vec) or npc.StateFrame % d.nextReset == 0 or npc:CollidesWithGrid() then
            d.vec = RandomVector():Resized(3)
            d.nextReset = 20 + r:RandomInt(20)
        end
        if d.vec then
            npc.Velocity = mod:Lerp(npc.Velocity, d.vec, 0.1)
        end
        if target.Position:Distance(npc.Position) < 150 and not sprite:IsOverlayPlaying("Transition") then
            d.state = "aggressive"
            d.angryCooldown = 30
        end
    elseif d.state == "aggressive" then
        d.angryCooldown = d.angryCooldown or 0
        if d.angryCooldown > 0 then
            d.angryCooldown = d.angryCooldown - 1
        end
        local targetpos = mod:randomConfuse(npc, target.Position)
        if d.attacking then
            if sprite:IsOverlayFinished("Shoot") or mod:isScareOrConfuse(npc) then
                d.attacking = nil
                d.shooting = nil
                npc.StateFrame = 0
            elseif sprite:GetOverlayFrame() == 7 then
                d.shooting = true
            else
                mod:spriteOverlayPlay(sprite, "Shoot")
            end
            if d.shooting and npc.StateFrame % 2 == 1 then
                npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1.1)
                local params = ProjectileParams()
                local shotspeed = (((target.Position + target.Velocity * 15) - npc.Position)*0.05):Rotated(-10+math.random(20))
                shotspeed = shotspeed:Resized(math.min(shotspeed:Length(), 15))
                params.Scale = math.random(2, 10) / 10
                params.FallingSpeedModifier = -30 + math.random(10);
                params.FallingAccelModifier = 1.4 + math.random(2)/10;
                npc:FireProjectiles(npc.Position, shotspeed, 0, params)
            end
        else
            mod:spriteOverlayPlay(sprite, "Head02")
            if ((npc.StateFrame > 5 and r:RandomInt(10) == 0) or npc.StateFrame > 15) and targetpos:Distance(npc.Position) < 150 and not mod:isScareOrConfuse(npc) then
                d.attacking = true
            end
            if d.angryCooldown < 1 and targetpos:Distance(npc.Position) > 200 then
                d.state = "passive"
            end
        end
        local room = game:GetRoom()
        if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScareOrConfuse(npc) then
            local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4), 1.5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
        else
            npc.Pathfinder:FindGridPath(targetpos, 0.6, 900, true)
        end
    end
end

function mod:discyHurt(npc, damage, flag, source)
    if npc.SubType == mod.FF.Nobody.Sub then
        local d = npc:GetData()
        if d.state == "passive" then
            d.state = "aggressive"
            d.angryCooldown = 60
        end
    else
        if npc:GetData().transitioning then
            return false
        end
    end
end

function mod:dangerousDiscGuideAI(npc)
	local d = npc:GetData()
    if not d.init then
        if not npc.SpawnerEntity then
            local dir = npc.SubType % 4
            local offset = (npc.SubType >> 3) & 3
            local direction
            if dir == 0 then
                direction = "Up"
            elseif dir == 1 then
                direction = "Down"
            elseif dir == 2 then
                direction = "Left"
            else
                direction = "Right"
            end
            local cc = npc.SubType % 8 > 3
            local posoffset = FiendFolio.WallStickerOffset
            if offset == 1 then
                posoffset = Vector(-posoffset.X, posoffset.Y)
            elseif offset == 2 then
                posoffset = Vector(posoffset.X, -posoffset.Y)
            elseif offset == 3 then
                posoffset = Vector(-posoffset.X, -posoffset.Y)
            end
            npc.Position = npc.Position + posoffset
            mod:WallStickerInit(npc, direction, cc, GridCollisionClass.COLLISION_PIT, 7)
        else
            --print("A Discy probably spawned me.")
        end
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_HIDE_HP_BAR + EntityFlag.FLAG_NO_FLASH_ON_DAMAGE + EntityFlag.FLAG_NO_REWARD + EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Visible = false
        npc.SplatColor = mod.ColorInvisible
        local disc = Isaac.Spawn(mod.FF.DangerousDisc.ID, mod.FF.DangerousDisc.Var, 0, npc.Position, npc.Velocity, npc)
        disc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        disc.Parent = npc
        npc.Child = disc
        d.init = true
    end
    if npc.Child and npc.Child:Exists() then
        if d.shooting then
            if npc:CollidesWithGrid() then
                sfx:Play(mod.Sounds.SawAttach, 2)
                local dir, cc = mod:GetOrientationFromVector(d.shooting)
                mod:WallStickerInit(npc, dir, cc, GridCollisionClass.COLLISION_PIT, 7, true)
                d.shooting = nil
            end
        elseif d.WallStickerData.WallStickerInit and npc.FrameCount > 1 then
            mod:WallStickerMovement(npc, 6)
        end
    else
        npc:Remove()
    end
end

function mod:dangerousDiscAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

    if not d.init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_HIDE_HP_BAR + EntityFlag.FLAG_NO_FLASH_ON_DAMAGE + EntityFlag.FLAG_NO_REWARD + EntityFlag.FLAG_NO_BLOOD_SPLASH)
        d.init = true
    end
    if npc.Parent and npc.Parent:Exists() then
        if not sfx:IsPlaying(mod.Sounds.SawAmbient) then
            sfx:Play(mod.Sounds.SawAmbient, 0.2, 0, true)
        end
        npc.TargetPosition = npc.Parent.Position
        npc.Velocity = npc.TargetPosition - npc.Position
        if npc.FrameCount % 2 == 0 then
            local effect = Isaac.Spawn(1000,66,0,npc.Position,npc.Velocity:Rotated(270 - mod:RandomInt(-90,90)):Resized(10),npc)
            effect.SpriteScale = effect.SpriteScale * (0.05 * mod:RandomInt(20,25))
        end
        mod:spritePlay(sprite, "Idle")
    else
        sfx:Stop(mod.Sounds.SawAmbient)
        npc:Kill()
    end
end