local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local infinityVoltFiredCostume = Isaac.GetCostumeIdByPath("gfx/characters/infinity_volt_fired.anm2")

function mod:infinityVoltPlayerUpdate(player, data)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.INFINITY_VOLT) then
        if data.infinityVoltFired then
            if not data.infinityVoltFired:Exists() then
                player:TryRemoveNullCostume(infinityVoltFiredCostume)
                data.infinityVoltFired = nil
            end
        end
    end
end

function mod:infinityVoltDoubleTap(player, aim, data, sdata)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.INFINITY_VOLT) then
        if data.infinityVoltFired then
            if data.infinityVoltFired:GetData().socket then
                sfx:Play(mod.Sounds.InfinityVoltPlugout, 1, 0, false, 1)
                data.infinityVoltFired:GetData().socket = nil
                data.infinityVoltFired:GetSprite():SetFrame("Idle", 0)
            end
        elseif (not data.infinityVoltFired) then
            if aim:Length() > 0.5 then
                aim = aim:Normalized()
                local initSpeed = 35
                local vec = aim:Resized(initSpeed)
                vec = vec + player:GetTearMovementInheritance(vec)
                local plug = Isaac.Spawn(mod.FF.InfinityVoltEnd.ID, mod.FF.InfinityVoltEnd.Var, mod.FF.InfinityVoltEnd.Sub, player.Position, vec, player):ToEffect()
                plug.Parent = player
                plug:Update()
                data.infinityVoltFired = plug
                player:AddNullCostume(infinityVoltFiredCostume)
                sfx:Play(mod.Sounds.CleaverThrow,0.3,0,false, math.random(70,90)/100)
            end
        end
    end
end

function mod:infinityVoltCordEndUpdate(e)
    local d = e:GetData()
    local sprite = e:GetSprite()
    e.SpriteOffset = Vector(0, -15)
    if e.Parent then
        local p = e.Parent:ToPlayer()
        e.SpriteRotation = (e.Position - e.Parent.Position):GetAngleDegrees()
        if not e.Child then
            local handler = Isaac.Spawn(1000, 1749, 161, e.Position, nilvector, e):ToEffect()
            handler.Parent = e
            handler.Visible = false
            handler:Update()

            local dummyTarget = Isaac.Spawn(1000, 1960, 0, e.Parent.Position, nilvector, e):ToEffect()
            dummyTarget.Parent = e.Parent
            dummyTarget.Visible = false
    
            local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 161, e.Parent.Position, nilvector, e)
            e.Child = rope
    
            rope.Parent = handler
            rope.Target = dummyTarget
            dummyTarget.Child = rope
            dummyTarget:Update()
    
            rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            rope:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            rope.DepthOffset = 300
    
            rope:GetSprite():Play("Idle", true)
            rope:GetSprite():SetFrame(100)
            rope:Update()
    
            rope.SplatColor = Color(1,1,1,0,0,0,0)
        end
        if p:GetHeadDirection() == Direction.UP or p:GetHeadDirection() == Direction.RIGHT then
            e.Child.DepthOffset = 0
        else
            e.Child.DepthOffset = 30
        end
        e.Child:Update()
        e.Child:Update()
        if (not d.triedSocketing) then
            local target = mod.FindClosestEnemy(e.Position, 30, true, nil, nil, EntityCollisionClass.ENTCOLL_PLAYEROBJECTS)
            if target then
                if target.HitPoints < p.Damage / 10 then
                    target:TakeDamage(p.Damage/10, 0, EntityRef(p), 0)
                else
                    d.socket = target
                    d.triedSocketing = true
                    sfx:Play(mod.Sounds.InfinityVoltPlugin, 1, 0, false, 1)
                end
            end
        end
        if d.socket then
            if not d.socket:Exists() or d.socket.EntityCollisionClass == 0 then
                sfx:Play(mod.Sounds.InfinityVoltPlugout, 1, 0, false, 1)
                d.socket = nil
                sprite:SetFrame("Idle", 0)
            else
                if d.socket.Position.X > e.Parent.Position.X then
                    e.Child:GetSprite().FlipX = false
                else
                    e.Child:GetSprite().FlipX = true
                end
                sprite:SetFrame("Idle", 1)

                local targetVec = (d.socket.Position - Vector(24,0):Rotated(e.SpriteRotation)) - e.Position
                e.Velocity = mod:Lerp(e.Velocity, targetVec, 0.75)
                
                if e.Parent.Position:Distance(d.socket.Position) > (150 + d.socket.Size) then
                    local targetVec = (d.socket.Position - e.Parent.Position)
                    local length = targetVec:Length() - (150 + d.socket.Size)
                    targetVec = targetVec:Resized(length/10)
                    e.Parent.Velocity = e.Parent.Velocity + targetVec
                    d.socket.Velocity = d.socket.Velocity - (targetVec / 10)
                end

                d.socketTimeConnected = d.socketTimeConnected or 0
                d.socketTimeConnected = d.socketTimeConnected + 1
                local zapMod = 5
                if d.socketTimeConnected >= 180 then
                    game:BombExplosionEffects(d.socket.Position, 30)
                    d.socket = nil
                elseif d.socketTimeConnected >= 120 then
                    zapMod = 3
                    if d.socketTimeConnected == 120 then
                        d.socket:AddBurn(EntityRef(p), 60, p.Damage)
                    end
                elseif d.socketTimeConnected % 5 == 1 then
                    d.socket:AddCharmed(EntityRef(p), 5)
                end
                if d.socketTimeConnected > 5 and d.socketTimeConnected % zapMod == 1 then
                    local laser = EntityLaser.ShootAngle(10, d.socket.Position, math.random(360), 2, Vector(0, -10), p)
                    laser.Parent = d.socket
                    laser.CollisionDamage = p.Damage
                    laser.MaxDistance = d.socket.Size + math.random(50,100)
                    laser.OneHit = true
                    laser:Update()
                    d.socket:TakeDamage(p.Damage/10, 0, EntityRef(p), 0)
                end
            end
        else
            sprite:SetFrame("Idle", 0)
            if e.FrameCount > 5 then
                local targetVec = ((p.Position + p.Velocity) - e.Position)
                if targetVec:Length() > 30 then
                    targetVec = targetVec:Resized(30)
                end
                e.Velocity = mod:Lerp(e.Velocity, targetVec, math.min(0.1 + e.FrameCount / 10, 1))
                if e.Position:Distance(e.Parent.Position) < 10 then
                    if e.Child then
                        e.Child:Remove()
                    end
                    e:Remove()
                end
            elseif e.FrameCount > 2 then
                e.Velocity = e.Velocity * 0.3
            elseif room:GetGridCollisionAtPos(e.Position) > 1 then
                if not (p.CanFly or p.TearFlags == p.TearFlags | TearFlags.TEAR_SPECTRAL) then 
                    e.Velocity = e.Velocity * 0.1
                end
            end
        end
    else
        if e.Child then
            e.Child:Remove()
        end
        e:Remove()
    end
end

local headDirs = {
    [Direction.NO_DIRECTION]    = Vector(11, -5),
    [Direction.LEFT]            = Vector(-5, -6),
    [Direction.UP]              = Vector(-11, -8),
    [Direction.RIGHT]           = Vector(5, -6),
    [Direction.DOWN]            = Vector(11, -5),
}

function mod:dummyRopeTargetAI(e)
    if not e.Child then
        e:Remove()
    elseif e.Parent then
        local p = e.Parent:ToPlayer()
        e.Position = p.Position + (headDirs[p:GetHeadDirection()] * p.SpriteScale)
    else
        e:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, handler)
	if handler.SubType == 161 then
		if not handler.Parent or not handler.Parent:Exists() then
			handler:Remove()
		else
			handler.Position = handler.Parent.Position + handler.Parent.SpriteOffset + Vector(0,11)
			handler.Velocity = handler.Parent.Velocity
		end
	end
end, 1749)


mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 and npc.SubType == 161 then
        return false
    end
end, EntityType.ENTITY_EVIS)

function mod:infinityVoltLocustAI(fam)
    local d = fam:GetData()
    local p = fam.Player
	if fam.State == -1 then
        local vec = fam.Position - p.Position
        if not d.laser or (d.laser and not d.laser:Exists()) then
            d.laser = EntityLaser.ShootAngle(10, p.Position, vec:GetAngleDegrees(), 999999999, Vector(0, -20), p)
        end
        d.laser.Angle = vec:GetAngleDegrees()
        d.laser.MaxDistance = vec:Length()
        d.laser.CollisionDamage = mod:getLocustDamage(fam, 0.1)
        d.laser.Mass = 0.1
        d.laser:Update()
    else
        if d.laser and d.laser:Exists() then
            d.laser:Remove()
            d.laser = nil
        end
    end
end