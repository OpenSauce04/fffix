local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:TommyAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        data.CC = (rng:RandomFloat() <= 0.5)
        npc.StateFrame = mod:RandomInt(10, 20)
        npc.SplatColor = mod.ColorDullGray
        data.TommyFilter = function(position, candidate)
            if mod:CheckIDInTable(candidate, FiendFolio.TommyBlacklist) 
                or candidate.EntityCollisionClass <= EntityCollisionClass.ENTCOLL_NONE
                or mod:isFriend(candidate) ~= mod:isFriend(npc)
                or not candidate.Visible then
                return false
            else
                return true
            end
        end
        data.Init = true
    end
    if npc.State == 8 and npc.StateFrame > 0 then
        npc.State = 4
    elseif npc.State == 4 then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            npc.State = 8
        end
    end
    if sprite:IsEventTriggered("TommyShoot") then
        local benny = Isaac.Spawn(mod.FF.Benny.ID, mod.FF.Benny.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
        benny:GetData().Ballin = true
        benny:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        benny.StateFrame = mod:RandomInt(80,120)
        benny:GetData().Angle = mod:RandomAngle()
        benny:GetData().CC = data.CC
        npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, mod:RandomInt(6, 8)/10)
        npc.StateFrame = math.floor(mod:RandomInt(100,140) * ((mod.GetEntityCount(mod.FF.Benny.ID,mod.FF.Benny.Var) + 1)) * 0.5)
        for i = -60, 60, 15 do
            local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, Vector(0, -5):Rotated(i - 10 + math.random(20)), npc):ToEffect()
            smoke:GetData().longonly = true
            smoke.Color = Color(0.2,0.2,0.2)
			smoke.SpriteOffset = Vector(0, -25)
			smoke:Update()
		end
        benny.Parent = mod:GetNearestEnemy(targetpos, 400, data.TommyFilter)
    end
end

function mod:BennyAI(npc, sprite, data)
    if not data.Init then
        npc.SplatColor = mod.ColorDullGray
        data.Init = true
    end
    if data.Ballin then
        if not data.BallinInit then
            sprite:Play("Ball")
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            npc.CollisionDamage = 0
            data.BallinInit = true
        end
        if npc.Parent and not mod:IsReallyDead(npc.Parent) then
            data.ParentCollClass = npc.Parent.GridCollisionClass
            npc.TargetPosition = npc.Parent.Position + Vector(30,0):Rotated(data.Angle)
            if data.CC then
                data.Angle = data.Angle - 3
            else
                data.Angle = data.Angle + 3
            end
            local vel = npc.TargetPosition - npc.Position
            vel = vel:Resized(math.min(vel:Length(), 10))
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.4)
        else
            if mod:AmISoftlocked(npc) and not data.ParentCollClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
                npc:Kill()
            else
                npc.Velocity = npc.Velocity * 0.8
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end
        end
        if sprite:IsPlaying("Ball") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 and not mod:AmISoftlocked(npc) then
                sprite:Play("Grow")
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end
        end
        if sprite:IsFinished("Grow") then
            npc.CollisionDamage = 1
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            data.Ballin = false
        end
        return true
    else
        if sprite:IsEventTriggered("BennyShoot") then
            for _ = 1, mod:RandomInt(4,7) do
                local params = ProjectileParams()
                params.FallingSpeedModifier = mod:RandomInt(-30, -10) * 1.5
                params.FallingAccelModifier = 2
                params.Variant = mod:RandomInt(0,1)
                npc:FireProjectiles(npc.Position, Vector(30, 0):Rotated(mod:RandomAngle()):Resized(mod:RandomInt(1,3)), 0, params)
            end
            npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 0.8, 0, false, mod:RandomInt(11, 13)/10)
            local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, Vector(0,-5), npc)
            smoke:GetData().longonly = true
            smoke.Color = Color(0.2,0.2,0.2)
            smoke.SpriteOffset = Vector(0, -10)
            smoke:Update()
        end
    end
end

function mod:BennyHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if amount > 0 and data.Ballin and not mod:HasDamageFlag(damageFlags, DamageFlag.DAMAGE_CLONES) then
        npc:TakeDamage(amount/4, damageFlags | DamageFlag.DAMAGE_CLONES, source, 0)
        npc:SetColor(Color(0.5, 0.5, 0.5, 1.0, 0.2, 0.2, 0.2), 5, 0, true, false)
        return false
    end
end