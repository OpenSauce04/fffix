local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:DollopAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        data.state = "idle"
        data.speed = 3
        npc.SplatColor = mod.ColorPoop
        npc.StateFrame = mod:RandomInt(45,90)
        data.Init = true
    end
    npc:AnimWalkFrame("WalkHori","WalkVert",1)
    local vel 
    if mod:isScare(npc) then
        vel = (targetpos - npc.Position):Resized(-data.speed)
    elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
        vel = (targetpos - npc.Position):Resized(data.speed)
    else
        npc.Pathfinder:FindGridPath(targetpos, (data.speed * 0.1) + 0.2, 900, true)
    end
    if vel then
        npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
    end
    if data.state == "idle" then
        mod:spriteOverlayPlay(sprite, "Head")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            local cap = math.max(3, mod.GetEntityCount(mod.FF.Dollop.ID, mod.FF.Dollop.Var) * 2)
            if cap > mod.GetEntityCount(870,0,0) then
                data.state = "shoot"
                data.speed = 2
            else
                npc.StateFrame = mod:RandomInt(15,45)
            end
        end
    elseif data.state == "shoot" then
        if sprite:IsOverlayFinished("Attack") then
            data.state = "idle"
            data.Shooted = false
            data.speed = 3
            npc.StateFrame = mod:RandomInt(90,150)
        elseif sprite:GetOverlayFrame() == 20 and not data.Shooted then
            local bingo = (targetpos - npc.Position):Normalized() * math.min(150, (npc.Position - targetpos):Length())
            local coll = GridCollisionClass.COLLISION_NONE
            if game:GetRoom():HasWater() then
                coll = GridCollisionClass.COLLISION_PIT
            end
            local target = mod:GetNearestPosOfCollisionClassOrLess(npc.Position + bingo, coll) + (RandomVector())
            local vec = (target - npc.Position) / 18
            Isaac.Spawn(mod.FF.FlyingDrip.ID,mod.FF.FlyingDrip.Var,mod.FF.FlyingDrip.Sub,npc.Position,vec,npc)
            mod:PlaySound(mod.Sounds.Burpie, npc, mod:RandomInt(60,80)/100, 0.8)
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
            local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc):ToEffect()
            effect.DepthOffset = npc.Position.Y * 1.25
            if sprite.FlipX then
                effect.SpriteOffset = Vector(-4,-14)
            else
                effect.SpriteOffset = Vector(4,-14)
            end
            effect.Color = mod.ColorPoop
            effect:FollowParent(npc)
            data.Shooted = true
        else
            mod:spriteOverlayPlay(sprite, "Attack")
        end
    end
end

function mod:FlyingDripRender(effect, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        data.StateFrame = data.StateFrame or 2
        mod:spritePlay(sprite, "Fly")
        mod:FlipSprite(sprite, effect.Position, effect.Position + effect.Velocity)
        local curve = math.sin(math.rad(9 * data.StateFrame))
        local height = 0 - curve * 40
        sprite.Offset = Vector(0, height)
        if height >= 0 then
            effect.Visible = false
            effect:Remove()
            local drip = Isaac.Spawn(870,0,0,effect.Position,effect.Velocity,effect)
            drip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        else
            data.StateFrame = data.StateFrame + 0.5
        end
    end
end