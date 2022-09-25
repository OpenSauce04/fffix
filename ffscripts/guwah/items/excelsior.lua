local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()
local itemconfig = Isaac.GetItemConfig()

function mod:ExcelsiorPlayerLogic(player, data)
    data.ExcelsiorQueuedUpdates = data.ExcelsiorQueuedUpdates or {}
    for _, fireworks in pairs(data.ExcelsiorQueuedUpdates) do
        fireworks.FrameCount = fireworks.FrameCount or 0
        fireworks.FrameCount = fireworks.FrameCount + 1
        if fireworks.FrameCount > 0 then
            if not fireworks.Init then 
                if player:GetActiveCharge(fireworks.UseSlot) < fireworks.PrevCharge or not player:HasCollectible(fireworks.PrevItem) then --This prevents cheese via items which you hold over your head, like the Candle
                    local coindiff = fireworks.PrevCoins - player:GetNumCoins() --If the player consumes Coins, Keys, Bombs, Hearts, or gains Broken Hearts, shoot more fireworks
                    local keydiff = fireworks.PrevKeys - player:GetNumKeys()
                    local bombdiff = fireworks.PrevBombs - player:GetNumBombs()
                    local heartdiff = fireworks.PrevHearts - player:GetHearts()
                    local brokendiff = player:GetBrokenHearts() - fireworks.PrevBrokenHearts 
                    fireworks.Count = fireworks.Count + math.max(coindiff * 2, 0)
                    fireworks.Count = fireworks.Count + math.max(keydiff * 2, 0)
                    fireworks.Count = fireworks.Count + math.max(bombdiff * 2, 0)
                    fireworks.Count = fireworks.Count + math.max(heartdiff * 2, 0)
                    fireworks.Count = fireworks.Count + math.max(brokendiff * 8, 0)
                    if not player:HasCollectible(fireworks.PrevItem) then --If the item was a single-use item, shoot more rockets with increased damage
                        fireworks.Damage = fireworks.Damage * 3
                        fireworks.Count = fireworks.Count + 20
                    end
                    if Excelsior then --If the Excelsior mod is enabled, shoot 33% more fireworks
                        fireworks.Count = math.floor(fireworks.Count * 1.33)
                    end
                else
                    fireworks.Count = 0
                end
                fireworks.Init = true
            end
            if fireworks.Count > 0 and fireworks.FrameCount % 4 == 0 then
                --print(fireworks.Count)
                fireworks.Count = fireworks.Count - 1  
                local firework = Isaac.Spawn(mod.FF.FireworkRocket.ID,mod.FF.FireworkRocket.Var,mod:RandomInt(0,2),player.Position,RandomVector():Resized(10),player)
                local fwData = firework:GetData()
                fwData.Damage = fireworks.Damage
                fwData.IsFireworkRocket = true --So it "works" with multidimensional baby
                sfx:Play(mod.Sounds.ExcelsiorShoot, 0.5)
            else
                fireworks = nil 
            end
        end
    end
end

function mod:ExcelsiorActiveLogic(player, data, itemID, useFlags, slot)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EXCELSIOR) and (useFlags & UseFlag.USE_OWNED > 0) then
        data.ExcelsiorQueuedUpdates = data.ExcelsiorQueuedUpdates or {}
        local configitem = itemconfig:GetCollectible(itemID)
        local charges = configitem.MaxCharges
        local fireworks = {}
        fireworks.Count = 0
        fireworks.Damage = math.max(player.Damage * 2, 7)
        fireworks.PrevItem = itemID
        fireworks.PrevBombs = player:GetNumBombs()
        fireworks.PrevKeys = player:GetNumKeys()
        fireworks.PrevCoins = player:GetNumCoins()
        fireworks.PrevHearts = player:GetHearts()
        fireworks.PrevBrokenHearts = player:GetBrokenHearts()
        fireworks.UseSlot = slot
        fireworks.PrevCharge = player:GetActiveCharge(slot)
        if configitem.ChargeType == 1 then --Time-based recharge items deal less damage
            fireworks.Damage = fireworks.Damage * 0.66
            fireworks.Count = ((charges / 45) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EXCELSIOR))
        elseif configitem.ChargeType == 2 then --Berserk
            fireworks.Count = 8
        else --Regular items
            fireworks.Count = (charges * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EXCELSIOR) * 2) + 1 
        end
        table.insert(data.ExcelsiorQueuedUpdates, fireworks)
    end
end

function mod:FireworkRocketAI(tear, data, sprite)
    if not data.Init then
        data.Frame = 0 + (tear.SubType * 3)
        data.Damage = data.Damage or 3.5
        data.ParticleScale = 0.8
        if data.Damage > 24 then
            data.Frame = data.Frame + 2
            data.ParticleScale = 1.5
        elseif data.Damage > 12 then
            data.Frame = data.Frame + 1
            data.ParticleScale = 1
        end
        sprite:SetFrame("Idle", data.Frame)
        if tear.SubType == 0 then
            data.BoomColor = Color(1,1,1,1,0.6,0,0)
            data.SparkleColor = Color(1,0.5,0.5,1,0.6,0,0)
        elseif tear.SubType == 1 then
            data.BoomColor = Color(1,1,1,1,0,0.6,0)
            data.SparkleColor = Color(0.5,1,0.5,1,0,0.6,0)
        else
            data.BoomColor =  Color(1,1,1,1,0,0,0.6)
            data.SparkleColor = Color(0.5,0.5,1,1,0,0,0.6)
        end
        data.HomingDelay = mod:RandomInt(5,15)
        tear.FallingAcceleration = -0.1
        tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        data.Filter = function(position, candidate)
            if candidate:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) or candidate:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                return false
            else
                return true
            end
        end
        data.Init = true
    end
    if tear.FrameCount > data.HomingDelay then
        local target = mod:GetNearestEnemy(tear.Position, 1200, data.Filter)
        if target then
            local angleDifference = mod:GetAngleDifference(target.Position - tear.Position, tear.Velocity)
            local rotstrength = mod:RandomInt(6,12)
            local rotation = rotstrength
            if angleDifference < rotstrength and angleDifference > -rotstrength then
                rotation = angleDifference
            elseif angleDifference > 180 then
                rotation = -rotstrength
            end
            tear.Velocity = mod:Lerp(tear.Velocity:Rotated(rotation), tear.Velocity, 0.1):Resized(10)
        end
    end
    if tear.FrameCount % 2 == 0 then
        local particle = Isaac.Spawn(1000,7003,0,tear.Position,tear.Velocity:Rotated(180 + mod:RandomInt(-45,45)):Resized(5),tear)
        particle.Color = data.SparkleColor
        particle.SpriteOffset = Vector(0, -15)
        particle.SpriteScale = particle.SpriteScale * data.ParticleScale
    end
    if tear.Variant == 21 and not data.MultiFix then --Fixing Multidimensional Baby interaction
        sprite:Load("gfx/projectiles/tear_firework_rocket.anm2", true)
        sprite:SetFrame("Idle", data.Frame)
        tear.Color = mod.ColorMultidimensional
        data.MultiFix = true
    end
    if tear.FrameCount > 150 then
        mod:FireworkExplosion(tear, data)
    end
    sprite.Rotation = mod:GetAngleDegreesButGood(tear.Velocity * -1)
end

function mod:FireworkRocketColl(tear, collider)
    local data = tear:GetData()
    if data.Init and collider:IsEnemy() and data.Filter(_, collider) then
        mod:FireworkExplosion(tear, data)
    end
    return true
end

function mod:FireworkExplosion(tear, data)
    local player = Isaac.GetPlayer(0)
    if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
        player = tear.SpawnerEntity:ToPlayer()
    end
    local bomb = player:FireBomb(tear.Position,Vector(0,0),player)
    bomb.ExplosionDamage = data.Damage
    bomb.RadiusMultiplier = 0.5
    bomb.Visible = false
    bomb.Color = data.BoomColor
    bomb:GetData().IsFireworkExplosion = true
    bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    bomb:SetExplosionCountdown(0)
    local sparklevec = RandomVector()
    for i = 1, 6 do
        local particle = Isaac.Spawn(1000,7003,0,tear.Position,sparklevec:Resized(mod:RandomInt(5,10)):Rotated(((360/6) * i) + mod:RandomInt(-15,15)),tear)
        particle.Color = data.SparkleColor
    end
    tear:Remove()
    sfx:Play(mod.Sounds.ExcelsiorBoom, 0.5)
end