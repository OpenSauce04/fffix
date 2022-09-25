local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    fam.OrbitDistance = Vector(105,100)
    fam.OrbitSpeed = 0.015
    fam.OrbitLayer = 4
    fam:RecalculateOrbitOffset(fam.OrbitLayer, true)
end, FamiliarVariant.ORANGE_BOOM_FLY)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local sprite = fam:GetSprite()
    local d = fam:GetData()
    local player = fam.Player
    fam.OrbitDistance = Vector(105,100)
    local targetPosition = fam:GetOrbitPosition(player.Position + player.Velocity)
    fam.Velocity = targetPosition - fam.Position
    fam.SpriteOffset = Vector(0,-2)

    if fam.Visible then
        fam.CollisionDamage = 2
        local npcs = Isaac.FindInRadius(fam.Position, 100, EntityPartition.ENEMY)
        local closestdist = 99999
        for _,npc in ipairs(npcs) do
            if npc:IsEnemy() then
                --Please social distance
                local dist = npc.Position:Distance(fam.Position)
                if dist < closestdist then
                    closestdist = dist
                end
                --Likes flies :)
                if ((not npc:ToNPC():IsBoss()) and (FiendFolio.AllFlies[npc.Type] or FiendFolio.AllFlies[npc.Type .. " " .. npc.Variant] or FiendFolio.AllFlies[npc.Type .. " " .. npc.Variant .. " " .. npc.SubType])) then
                    if dist < 50 then
                        npc:AddCharmed(EntityRef(player), 20)
                    end
                end    
            end
        end
        d.swell = d.swell or 0
        if closestdist < 100 then
            d.swell = d.swell + (2 - (closestdist / 50))
        end
        d.swell = math.max(d.swell - 0.3, 0)
    
        if d.swell < 25 then
            mod:spritePlay(sprite, "Idle")
        elseif d.swell < 50 then
            mod:spritePlay(sprite, "Swell1")
        elseif d.swell < 75 then
            mod:spritePlay(sprite, "Swell2")
        else
            mod:spritePlay(sprite, "Swell3")
        end

        if d.swell > 100 then
            d.swell = 0
            fam.Visible = false
            Isaac.Explode(fam.Position, fam, 50)
            for i = 36, 360, 36 do
                local tear = Isaac.Spawn(2, 0, 0, fam.Position, Vector(14,0):Rotated(i), fam):ToTear()
                tear:AddTearFlags(TearFlags.TEAR_CHARM)
                if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                    tear:SetColor(FiendFolio.ColorPsy,0,0,false,false)
                    tear:AddTearFlags(TearFlags.TEAR_HOMING)
                else
                    tear:SetColor(Color(0.8,0.5,0,1,0,0,0),0,0,false,false)
                end
                if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    tear.Scale = 1.1
                    tear.CollisionDamage = 7
                else
                    tear.Scale = 0.9
                    tear.CollisionDamage = 3.5
                end
            end
        end
    else
        fam.CollisionDamage = 0
        d.swell = d.swell + 1
        if d.swell > 300 then
            sfx:Play(mod.Sounds.Tada,0.5,0,false,1.5)
            d.swell = 0
            fam.Visible = true
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, fam.Position, nilvector, fam)
        end
    end
    --print(d.swell)
end, FamiliarVariant.ORANGE_BOOM_FLY)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
    if collider:ToProjectile() then
    	collider:Die()
		local d = fam:GetData()
        d.swell = d.swell + 10
    end
end, FamiliarVariant.ORANGE_BOOM_FLY)