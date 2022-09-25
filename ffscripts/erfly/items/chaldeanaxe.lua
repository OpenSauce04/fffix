local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:chaldeanAxePlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.HAPPYHEAD_AXE) then
        local room = game:GetRoom()
        local spawnRate = 150 --How often it spawns in game logic frames (30ps, so 60 is 2 seconds)
        local spawnOff = 30  --The modulo value it spawns at of the above number
        if data.MaliceMinion then
            local minionIndex
            local parentPlayer = player.Parent:ToPlayer()
            if parentPlayer then
                local PlayerMinions = parentPlayer:GetData().MaliceMinions
                if PlayerMinions and #PlayerMinions > 0 then
                    for i = 1, #PlayerMinions do
                        if PlayerMinions[i].InitSeed == player.InitSeed then
                            minionIndex = i
                        end
                    end
                end
            end
            if minionIndex then
                spawnOff = (spawnOff + (minionIndex * 4)) % spawnRate
            end
        end
        if (not data.firedChaldean) and (not data.MaliceSplit) and room:GetFrameCount() % spawnRate == spawnOff then
            data.firedChaldean = true
            local enemy = mod.FindClosestEnemy(player.Position, 500, nil, nil, nil, nil, nil, true)
            if enemy then
                sfx:Play(mod.Sounds.AxeThrow, 0.4, 0, false, math.random(80,120)/100)
                local initialspeed = 35  --How fast it fires out
                local finalspeed = 50    --The speed when it boomerangs back
                local startingAngle = 50 --The starting angle, use it to make it look nice for where it lands / comes out
                
                local vec = (enemy.Position - player.Position):Resized(initialspeed)
                local axe = Isaac.Spawn(1000, 1960, mod.FF.AxeProjectile.Sub, player.Position, vec, player)
                axe.SpawnerEntity = player
                axe:GetData().definedVec = vec:Resized(finalspeed)
                axe.SpriteRotation = vec:GetAngleDegrees() + startingAngle
                --Flips it when on the other side
                if vec.X < 0 then
                    axe.SpriteRotation = axe.SpriteRotation + 180 - (startingAngle * 2)
                end
                axe:Update()
            end
        else
            data.firedChaldean = nil
        end
    end
end

function mod:chaldeanAxeUpdate(e)
    local d, sprite, player = e:GetData(), e:GetSprite(), e.SpawnerEntity or Isaac.GetPlayer()
    player = player:ToPlayer()
    d.definedVec = d.definedVec or RandomVector() * 35
    e.Velocity = mod:Lerp(e.Velocity, d.definedVec * -1, 0.05)

    --Determines whether it should flip or not
    --If you want to not change whether it's clockwise/anti, just make it 1 or -1 for both
    local plusmin = 1
    if d.definedVec.X < 0 then
        plusmin = -1
    end

    local spinMult = 2.3 --Multiply the velocity length by this
    local spinCap = 90   --Maximum spinning speed, too high looks bad
    local spinMin = 0    --Minimum spinning speed, unused as of writing

    e.SpriteRotation = e.SpriteRotation + (((math.max(math.min(e.Velocity:Length() * spinMult, spinCap), spinMin) * plusmin)))
    --e.SpriteRotation = e.SpriteRotation + (25 * plusmin)
    e.SpriteOffset = Vector(0, -15)
    e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    if e.FrameCount > 120 then
        e:Remove()
    end
    if e.FrameCount % 1 == 0 then
        local axeDelay = Isaac.Spawn(1000, 1960, mod.FF.AxeProjectileAfter.Sub, e.Position, nilvector, player)
        axeDelay.SpriteRotation = e.SpriteRotation
        axeDelay.SpriteOffset = e.SpriteOffset
        axeDelay:Update()
    end
    if e.FrameCount % 2 == 0 then
        for _, enemy in pairs(Isaac.FindInRadius(e.Position, e.Size, EntityPartition.ENEMY)) do
            --Collides with player objects at least
            if enemy.EntityCollisionClass > 1 then
                if not mod:isFriend(enemy) then
                    if not enemy:GetData().tookChaldeanAxeDamageRecently then
                        local damage = player.Damage --How much damage it should do, based off the player damage as of writing
                        local damageMulti = 1.5        --A multiplier to make it stronger/weaker, kept default (1) as of writing
                        local damageMinimum = 2      --A minimum for how much damage it should do (to make soy milkers not cry)
                        local damageMaximum = 20      --A maximum for how much damage it should do (to make ipecacers cry)
                        enemy:TakeDamage(math.min(math.max(damage * damageMulti, damageMinimum), damageMaximum), 0, EntityRef(player), 0)
                        sfx:Play(mod.Sounds.CleaverHit,0.15,0,false, math.random(70,80)/100)
                        enemy:BloodExplode()
                        enemy:GetData().tookChaldeanAxeDamageRecently = 5
                    end
                end
            end
        end
    end
end

function mod:chaldeanAxeEffectUpdate(e)
    e.DepthOffset = -50
    e.Color = Color(1,1,1,0.2 - e.FrameCount / 20, 1.5, math.max(0, 1 - e.FrameCount / 2), 0)
    if e.FrameCount >= 5     then
        e:Remove()
    end
end