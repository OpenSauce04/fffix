local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.GoldenSlotChestPayouts = {
	{Weight = 5, Output = {PickupVariant.PICKUP_CHEST, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_BOMBCHEST, 0}},
	{Weight = 4, Output = {PickupVariant.PICKUP_SPIKEDCHEST, 0}},
	{Weight = 3, Output = {PickupVariant.PICKUP_ETERNALCHEST, 0}},
	{Weight = 3, Output = {PickupVariant.PICKUP_MIMICCHEST, 0}},
	{Weight = 2, Output = {PickupVariant.PICKUP_OLDCHEST, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_WOODENCHEST, 0}},
	{Weight = 1, Output = {PickupVariant.PICKUP_MEGACHEST, 0}},
	{Weight = 4, Output = {PickupVariant.PICKUP_HAUNTEDCHEST, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_LOCKEDCHEST, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_REDCHEST, 0}},

	{Weight = 5, Output = {PickupVariant.PICKUP_SHOP_CHEST, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_DIRE_CHEST, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_GLASS_CHEST, 0}},
}

local function getRoomToTeleportTo(slot)
    local level = game:GetLevel()
    local currentDesc = level:GetCurrentRoomDesc()
    local currentRoomIndex = currentDesc.SafeGridIndex

    local roomlist = level:GetRooms()
    local possibleRooms = {}
    for i = 0, roomlist.Size - 1 do
        local roomDesc = roomlist:Get(i)
        local index = roomDesc.SafeGridIndex
        if currentRoomIndex ~= index then
            table.insert(possibleRooms, index)
        end
    end
    return possibleRooms[slot:GetDropRNG():RandomInt(#possibleRooms) + 1]
end

local function transformEnemyIntoPickup(slot, enemyArray, enemyAmount, pickupVar, pickupSub)
    local enemyTransformed
    for i = 1, enemyAmount do
        for j = 1, math.min(#enemyArray, 1) do
            local rand = math.random(#enemyArray)
            local pickup = Isaac.Spawn(5, pickupVar, pickupSub, enemyArray[rand].Position, nilvector, slot)
            pickup:SetColor(Color(1,1,1,1,1,1,1), 10, 99, true, false)

            local enemyVec = enemyArray[rand].Position - slot.Position

            local laser = EntityLaser.ShootAngle(2, slot.Position, enemyVec:GetAngleDegrees(), 10, Vector(0, -10), Isaac.GetPlayer())
            local golben = Color(1,1,1,1,0,0,0)
            golben:SetColorize(5,5,0,1)
            laser.Color = golben

            laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            laser.CollisionDamage = 0
            laser.MaxDistance = math.max(enemyVec:Length() - 10, 1)
            laser.Mass = 0
            laser.DepthOffset = 100
            laser.Parent = slot
            laser:Update()
            
            enemyArray[rand]:Remove()
            table.remove(enemyArray, rand)
            enemyTransformed = true
        end
    end
    if enemyTransformed then
        sfx:Play(mod.Sounds.GoldenSlotPolymorph, 1, 0, false, math.random(100,120)/100)
    end
end

function mod:payoutGoldenSlotMachine(slot, payout, player, rng)
    local room = game:GetRoom()

    local activeEnemies = {}
    for i, v in ipairs(Isaac.GetRoomEntities()) do
        if v:IsVulnerableEnemy() and not v:IsBoss() then
            table.insert(activeEnemies, v)
        end
    end

    local activeroom = false
    if #activeEnemies > 0 then
        activeroom = true
    end

    
    --payout = rng:RandomInt(7)
    --Sword
    if payout == 0 then
        --Grants a decaying damage up.
        player:AnimateHappy()
        player:GetData().goldenSlotTempDamage = 1.25
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        --In a room with enemies, also damages them.
        if activeroom then
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE,1,1,false,1)
            for _, e in ipairs(Isaac.GetRoomEntities()) do
                if e:IsVulnerableEnemy() then
                    local damageAmount = math.max(math.max(e.MaxHitPoints/5, 10), player.Damage * 5)
                    e:TakeDamage(damageAmount, 0, EntityRef(player), 0)
                    e:BloodExplode()
                end
            end
        end
    --Clover
    elseif payout == 1 then
        --Spawns a lucky penny.
        if not activeroom then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END, 1, 0, false, 1.5)
            local coin = Isaac.Spawn(5, 20, 5, slot.Position, Vector(0, math.random(30,50)/10):Rotated(-45 + math.random(50)), slot)
            coin:Update()
        --In a room with enemies, instead zaps 3 of the enemies at random and turns them into pennies, with one guaranteed to be lucky.
        else
            transformEnemyIntoPickup(slot, activeEnemies, 1, 20, 5)
            transformEnemyIntoPickup(slot, activeEnemies, 2, 20, 1)
        end
    --Red Key
    elseif payout == 2 then
        --Opens all connected red rooms.
        local level = game:GetLevel()
        local roomIndex = level:GetCurrentRoomIndex()
        local anyRedRooms
        for i = 0, 8 do
            if room:IsDoorSlotAllowed(i) then
                local tryMakeRedRoom = level:MakeRedRoomDoor(roomIndex, i)
                if tryMakeRedRoom then
                    anyRedRooms = true
                    local pos = room:GetDoorSlotPosition(i)
                    for i = 30, 360, 30 do
                        local vec = Vector(0,math.random(4,7)):Rotated(i)
                        local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, pos + vec, vec, slot):ToEffect()
                        smoke.Color = Color(1,1,1,0.3,75 / 255,70 / 255,50 / 255)
                        smoke:Update()
                    end
                end
            end
        end
        if anyRedRooms then
            sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 0, false, 1)
        --If there arent any or they are already open, spawns 2 cracked keys instead.
        elseif not activeroom then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END, 1, 0, false, 1.5)
            local rotAng = -45 + math.random(25)
            for i = -1, 1, 2 do
                local crackedKey = Isaac.Spawn(5, 300, 78, slot.Position, Vector(0, math.random(30,50)/10):Rotated(rotAng * i), slot)
            end
        --In a room with enemies, instead zaps 3 of the enemies at random and turns them into cracked keys.
        else
            transformEnemyIntoPickup(slot, activeEnemies, 2, 300, 78)
        end

    --Fiend!
    elseif payout == 3 then
        if not mod.IsActiveRoom() then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END, 1, 0, false, 1.5)
            --Spawns 1.5 immoral hearts.
            local rotAng = -45 + math.random(25)
            if math.random(2) == 1 then
                rotAng = rotAng * -1
            end
            local heart = Isaac.Spawn(5, PickupVariant.PICKUP_IMMORAL_HEART, 0, slot.Position, Vector(0, math.random(30,50)/10):Rotated(rotAng), slot)
            heart:Update()
            local heart = Isaac.Spawn(5, PickupVariant.PICKUP_HALF_IMMORAL_HEART, 0, slot.Position, Vector(0, math.random(30,50)/10):Rotated(rotAng * -1), slot)
            heart:Update()
            for i = 1, 5 do
                local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, slot.Position, Vector(0,math.random(4,7)):Rotated(-60 + math.random(120)), slot):ToEffect()
                smoke.SpriteRotation = math.random(360)
                smoke.Color = FiendFolio.ColorPsyGrape2
                --smoke.SpriteScale = Vector(2,2)
                smoke.SpriteOffset = Vector(0, -10)
                smoke:Update()
            end
        --In a room with enemies, instead spawns 8 minions over time, with 2 of them guaranteed to turn into hearts on room clear.
        else
            local d = slot:GetData()
            d.minionQueue = d.minionQueue or 0
            d.minionQueue = d.minionQueue + 8
            d.coolminionQueue = d.coolminionQueue or 0
            d.coolminionQueue = d.coolminionQueue + 2
        end
    --XD
    elseif payout == 4 then
        sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END, 1, 0, false, 1.5)
        sfx:Play(mod.Sounds.AceVenturaLaugh, 0.3, 0, false, 1)
        --Spawns a lit golden troll bomb.
        local coin = Isaac.Spawn(4, 18, 0, slot.Position, Vector(0, math.random(30,50)/10):Rotated(-45 + math.random(50)), slot)
        coin:Update()
        --In a room with enemies, fires golden brimstone beams at random, but not aimed at you(or with a tell.) They hurt both you and enemies.
        if activeroom then
            local d = slot:GetData()
            d.upcominglasers = {}
            for i = 1, 3 do
                local ang = math.random(360)
                table.insert(d.upcominglasers, ang)
                local tracer = Isaac.Spawn(1000, 198, 0, slot.Position + Vector(10, 0):Rotated(ang), Vector(0.001,0), slot):ToEffect()
                tracer.Timeout = 20
                tracer.TargetPosition = Vector(1,0):Rotated(ang)
                tracer.LifeSpan = 15
                tracer:FollowParent(slot)
                tracer.Color = Color(1,1,0,0.3,0,0,0)
                tracer:Update()
            end
        end
    --Corn
    elseif payout == 5 then
        --Takes 2-4 random pills.
        local pillcount = 2 + rng:RandomInt(3)
        --In a room with enemies, takes 3-6 random pills and pauses enemies whilst you take the pills.
        if activeroom then
            pillcount = pillcount + 1 + rng:RandomInt(2)
        end
        FiendFolio.QueuePills(player, pillcount)
        player.ControlsEnabled = false
        player:GetData().gmofrozen = true
        for _, e in ipairs(Isaac.GetRoomEntities()) do
            if e:IsVulnerableEnemy() and not e:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                e:AddFreeze(EntityRef(player), pillcount * 10)
            end
        end
    --Seven
    elseif payout == 6 then
        --Spawns a random chest. Any kind of chest!
        if not activeroom then
            sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.4, 0, false, 0.9)
            local poof = Isaac.Spawn(1000, 15, 0, slot.Position, nilvector, slot)
            poof:Update()
            for i = -70, 70, 140 do
                local pickout = mod.randomArrayWeightBased(mod.GoldenSlotChestPayouts)
                if pickout[1] == PickupVariant.PICKUP_MEGACHEST then
                    local spawnpos = room:FindFreePickupSpawnPosition(slot.Position + Vector(0, 40):Rotated(i), 40, true)
                    Isaac.Spawn(5, pickout[1], pickout[2], spawnpos, nilvector, slot)
                    local poof = Isaac.Spawn(1000, 15, 0, spawnpos, nilvector, slot)
                    poof:Update()
                else
                    Isaac.Spawn(5, pickout[1], pickout[2], slot.Position, Vector(0, 15):Rotated(i), slot)
                end
            end
        --In a room with enemies, instead zaps 2 of the enemies at random and turns them into a normal, locked, red, bomb or spiked chest.
        else
            transformEnemyIntoPickup(slot, activeEnemies, 1, mod.randomArrayWeightBased(mod.GoldenSlotChestPayouts)[1], 0)
            transformEnemyIntoPickup(slot, activeEnemies, 1, mod.randomArrayWeightBased(mod.GoldenSlotChestPayouts)[1], 0)
        end
    end
end

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d, rng = slot:GetSprite(), slot:GetData(), slot:GetDropRNG()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    if slot.FrameCount % 15 == 0 then
        local sparkle = Isaac.Spawn(1000, 1727, 0, slot.Position+Vector(math.random(-27, 27),math.random(-30,30)), nilvector, slot):ToEffect()
        sparkle.SpriteOffset = Vector(0,-20)
        --sparkle.SpriteScale = Vector(0.8, 0.8)
        sparkle:SetColor(Color(1,1,1,1,1,1,0), 100, 1, false, false)
        sparkle:Update()
    end
    
    if d.removeOnReentry then
        data.removeOnReentry = true
    end

    if not d.init then
        if data.removeOnReentry or (slot.SubType == 10 and not d.player) then
            slot:Remove()
            return
        end
        slot:SetSize(9, Vector(2,1), 24)
        d.sizeMulti = Vector(2,1)
        if slot.SubType == 10 then
            d.state = "worldRevolving"
            sprite:Play("Initiate", true)
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_PULL_SLOT, 1, 0, false, 1.5)
            d.payoutTimer = 50 + slot:GetDropRNG():RandomInt(20)
        else
            d.state = "idle"
        end
        d.NoDestroy = true
        d.Anims = { 
            "Idle", 
            "Initiate", 
            "Wiggle", 
            "Prize", 
            "WiggleEnd", 
            "Initiate0", 
            "Initiate1",
            "Initiate2",
            "Initiate3",
            "Initiate4",
            "Initiate5",
            "Initiate6",
            "TeleportOut"
        }
        d.init = true
    end

    if d.Position then
        slot.TargetPosition = d.Position
    elseif not d.Position then
        d.Position = slot.Position
    end
    if data.payout and not d.payout then
        d.payout = data.payout
    elseif d.payout and not data.payout then
        data.payout = d.payout
    end
    if data.payoutcount and not d.payoutcount then
        d.payoutcount = data.payoutcount
    elseif d.payoutcount and not data.payoutcount then
        data.payoutcount = d.payoutcount
    end
    if data.failureChance and not d.failureChance then
        d.failureChance = data.failureChance
    elseif d.failureChance and not data.failureChance then
        data.failureChance = d.failureChance
    end
    

    d.StateFrame = d.StateFrame or 0
    d.StateFrame = d.StateFrame + 1

    if d.state == "idle" then
        if data.payout then
            sprite:SetFrame("Prize", data.payout)
        else
            sprite:SetFrame("Idle", 0)
        end
    elseif d.state == "teleout" then
        data.removeOnReentry = true
        d.removeOnReentry = true
        if slot.SubType ~= 10 then
            if not d.foundNewRoom then
                local newIndex = getRoomToTeleportTo(slot)
                --print(newIndex, d.failureChance)
                local goldenSlotSpawns = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'goldenSlotSpawns', {})
                table.insert(goldenSlotSpawns, {RoomIndex = newIndex, FailureChance = d.failureChance or 1})
                d.foundNewRoom = true
            end
        end
        if d.StateFrame > 20 and ((not d.minionQueue) or (d.minionQueue and d.minionQueue <= 0)) and ((not d.upcominglasers) or (d.upcominglasers and #d.upcominglasers <= 0)) then
            if sprite:IsFinished("TeleportOut") then
                slot:Remove()
            elseif sprite:IsEventTriggered("Vwoop") then
                sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP)
                sfx:Play(mod.Sounds.GoldenSlotTele, 1, 0, false, math.random(90,100)/100)
                d.vwoop = true
            elseif sprite:IsEventTriggered("BlastOff") then
                for i = 30, 360, 30 do
                    local sparkle = Isaac.Spawn(1000, 1727, 0, slot.Position, Vector(math.random(40,60)/10, 0):Rotated(i - 10 + math.random(20)), slot):ToEffect()
                    --sparkle.SpriteScale = Vector(0.8, 0.8)
                    sparkle:SetColor(Color(1,1,1,1,1,1,0), 100, 1, false, false)
                    sparkle:Update()
                end
                for i = 15, 345, 30 do
                    local sparkle = Isaac.Spawn(1000, 1727, 0, slot.Position, Vector(math.random(60,80)/10, 0):Rotated(i - 10 + math.random(20)), slot):ToEffect()
                    --sparkle.SpriteScale = Vector(0.8, 0.8)
                    sparkle:SetColor(Color(1,1,1,1,1,1,0), 100, 1, false, false)
                    sparkle:Update()
                end
            else
                mod:spritePlay(sprite, "TeleportOut")
                if not d.vwoop then
                    d.vwoop = true
                    if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP) then
                        sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP, 1, 0, true, 1.5)
                    end
                end
            end
        else
            if data.payout then
                sprite:SetFrame("Prize", data.payout)
            else
                sprite:SetFrame("Idle", 0)
            end
        end
    elseif d.state == "worldRevolving" then
        if sprite:IsFinished("Initiate") or (data.payout and sprite:IsFinished("Initiate" .. data.payout)) then
            mod:spritePlay(sprite, "Wiggle")
        end
        if sprite:IsPlaying("Wiggle") then
            if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP) then
                sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP, 1, 0, true, 1.5)
            end
        end
        if d.StateFrame >= (d.payoutTimer or 27) then
            d.state = "payout"
            data.payout = rng:RandomInt(7)
            d.payout = data.payout
        end
    elseif d.state == "payout" then
        if sprite:IsFinished("WiggleEnd") then
            data.payoutcount = data.payoutcount or 0
            data.payoutcount = data.payoutcount + 1
            d.payoutcount = data.payoutcount
            if slot.SubType == 10 or rng:RandomInt(3) < data.payoutcount or data.payoutcount >= 3 then
                d.state = "teleout"
                d.StateFrame = 0
            else
                d.state = "idle"
            end
            sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP)
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_STOP, 1, 0, false, 1.5)
            mod:payoutGoldenSlotMachine(slot, data.payout, d.player, rng)
        else
            mod:spritePlay(sprite, "WiggleEnd")
        end
    end

    if d.minionQueue and d.minionQueue > 0 then
        d.minionCountdown = d.minionCountdown or 0
        d.minionCountdown = d.minionCountdown - 1
        if d.minionCountdown <= 0 then
            sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.4, 0, false, math.random(130,150)/100)
            local minion
            if d.coolminionQueue and d.coolminionQueue > 0 then
                minion = Isaac.Spawn(5,750,2,slot.Position + Vector(0,math.random(4,8)):Rotated(-60 + math.random(120)), nilvector,slot)
                minion.EntityCollisionClass = 4
                d.coolminionQueue = d.coolminionQueue - 1
            else
                local vec = Vector(0,math.random(4,8)):Rotated(-60 + math.random(120))
                slot.Velocity = vec * -1
                minion = Isaac.Spawn(1000,1736,0,slot.Position + vec, nilvector,slot)
            end
            minion:Update()
            local poof = Isaac.Spawn(1000, 15, 0, minion.Position, nilvector, nil)
            poof.SpriteScale = poof.SpriteScale * 0.5
            poof.Color = Color(0.3,0.3,0.3,1,10 / 255,0,10 / 255)

            d.minionCountdown = 5
            d.minionQueue = d.minionQueue - 1
        end
    else
        d.minionCountdown = nil
    end

    if d.upcominglasers and #d.upcominglasers > 0 then
        d.laserCountdown = d.laserCountdown or 20
        d.laserCountdown = d.laserCountdown - 1
        if d.laserCountdown <= 0 then
            d.laserCountdown = nil
            sfx:Play(mod.Sounds.GoldenSlotBuzz, 1, 0, false, math.random(90,110)/100)
            for i = 1, 3 do
                local laser = EntityLaser.ShootAngle(9, slot.Position, d.upcominglasers[i], 20, Vector(0, -3), slot)
                local golben = Color(1,1,1,1,0,0,0)
                golben:SetColorize(5,4,0,1)
                laser.Color = golben
                laser.DepthOffset = 100
            end
            for i = 1, 3 do
                table.remove(d.upcominglasers, 1)
            end
        end
    end
    
    FiendFolio.StopExplosionHack(slot)
end, mod.FF.GoldenSlotMachine.Var)

FiendFolio.onMachineTouch(mod.FF.GoldenSlotMachine.Var, function(player, slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    
    if d.state == "idle" then
        if player:GetNumCoins() >= 1 then
            player:AddCoins(-1)
            d.state = "worldRevolving"
            d.player = player
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_PULL_SLOT, 1, 0, false, 1.5)
            d.StateFrame = 0
            d.payoutTimer = 25 + slot:GetDropRNG():RandomInt(20)
            if data.payout then
                sprite:Play("Initiate" .. data.payout, true)
            else
                sprite:Play("Initiate", true)
            end
        else
            d.state = "teleout"
            d.StateFrame = 20
        end
    end
end)

function mod:goldenSlotMachinePlayerEffects(player, d)
    if d.goldenSlotTempDamage then
        if d.goldenSlotTempDamage > 1 then
        d.goldenSlotTempDamage = d.goldenSlotTempDamage - 0.0001
        else
            d.goldenSlotTempDamage = nil
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
    end
end

function mod:goldenSlotMachineNewRoom()
    local goldenSlotSpawns = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'goldenSlotSpawns', {})

    if #goldenSlotSpawns > 0 then
        local level = game:GetLevel()
        local currentDesc = level:GetCurrentRoomDesc()
        local currentRoomIndex = currentDesc.SafeGridIndex
        local indexesToRemove = {}
        for i = 1, #goldenSlotSpawns do
            --print(currentRoomIndex, goldenSlotSpawns[i].RoomIndex)
            if goldenSlotSpawns[i].RoomIndex == currentRoomIndex then
                local pos = mod:FindRandomFreePosAirNoGrids(nilvector, 0, nil, true)
                local slot = Isaac.Spawn(6,1040,0,pos, nilvector, nil)
                if slot:GetDropRNG():RandomInt(7) < goldenSlotSpawns[i].FailureChance then
                    local rand = slot:GetDropRNG():RandomInt(3)
                    local itemSub = 644
                    if rand == 1 then
                        itemSub = FiendFolio.ITEM.COLLECTIBLE.DAZZLING_SLOT
                    end
                    local item = Isaac.Spawn(5, 100, itemSub, slot.Position + Vector(0, -4), Vector.Zero, slot):ToPickup()
                    local scorch = Isaac.Spawn(1000, 18, 0, item.Position, nilvector, nil)
                    scorch:Update()

                    if slot:GetDropRNG():RandomInt(3) ~= 1 then
                        local room = game:GetRoom()
                        local pos = room:FindFreePickupSpawnPosition(item.Position, 40, true)
                        local rand = slot:GetDropRNG():RandomInt(5)
                        if rand == 0 then
                            local pickup = Isaac.Spawn(5, 50, 0, pos, nilvector, nil)
                        elseif rand == 1 then
                            local pickup = Isaac.Spawn(4, 18, 0, pos, nilvector, nil)
                        elseif rand == 2 then
                            local pickup = Isaac.Spawn(5, PickupVariant.PICKUP_IMMORAL_HEART, 0, pos, nilvector, nil)
                        elseif rand == 3 then
                            local pickup = Isaac.Spawn(5, 300, 78, pos, nilvector, nil)
                        elseif rand == 4 then
                            local pickup = Isaac.Spawn(5, 20, 5, pos, nilvector, nil)
                        end
                        if pickup then
                            pickup:GetData().DontRemoveRecentReward = true
                        end
                    end

                    slot:Remove()
                    sfx:Play(mod.Sounds.GoldenSlotPayout, 1, 0, false, math.random(95,105)/100)
                else
                    slot:GetData().failureChance = goldenSlotSpawns[i].FailureChance + 1
                end
                table.insert(indexesToRemove, 1, i)
            end
        end
        if #indexesToRemove > 0 then
            for i = 1, #indexesToRemove do
                table.remove(goldenSlotSpawns, indexesToRemove[i])
            end
        end
    end
end

function mod:goldenSlotPed(pickup)
	if pickup.Variant == 100 then
        local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'PedestalData', tostring(pickup.InitSeed), {})
		if d.goldenPedestal or pickup.SpawnerEntity then
			if d.goldenPedestal or (pickup.SpawnerEntity.Type == 6 and pickup.SpawnerEntity.Variant == 1040) then
				pickup:GetSprite():ReplaceSpritesheet(5, "gfx/items/slots/ff_chest_pedestals.png")
				pickup:GetSprite():LoadGraphics()
				pickup:GetSprite():SetOverlayFrame("Alternates", 3)
                d.goldenPedestal = true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.goldenSlotPed)

function mod:goldenSlotSpawning(type, var, sub, pos, vel, spawner, seed)
    if type == 6 and var == 1 and mod.ACHIEVEMENT.GOLDEN_SLOT_MACHINE:IsUnlocked() then
        local rng = RNG()
        rng:SetSeed(seed, 0)
        --if rng:RandomInt(142857) < 777 then --Roughly 1/200s
        if rng:RandomInt(77) < 1 then
            return {6, 1040, 0, seed}
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN , mod.goldenSlotSpawning)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, ID, rng, player)
    if player:GetNumCoins() >= 5 then
        local activeEnemies = {}
        for i, v in ipairs(Isaac.GetRoomEntities()) do
            if v:IsVulnerableEnemy() and not v:IsBoss() then
                table.insert(activeEnemies, v)
            end
        end
        if #activeEnemies > 0 then
            player:AddCoins(-5)
            enemyChoice = activeEnemies[rng:RandomInt(#activeEnemies) + 1]
            local slotpos = enemyChoice.Position
            enemyChoice:Remove()

            local slot = Isaac.Spawn(6,1040,10,slotpos, nilvector, nil)
            slot:GetData().player = player
            slot:SetColor(Color(1,1,1,1,1,1,1), 15, 1, true, false)

            local vec = slotpos - player.Position

            local laser = EntityLaser.ShootAngle(2, player.Position, vec:GetAngleDegrees(), 10, Vector(0, -10), Isaac.GetPlayer())
            local golben = Color(1,1,1,1,0,0,0)
            golben:SetColorize(5,5,0,1)
            laser.Color = golben

            laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            laser.CollisionDamage = 0
            laser.MaxDistance = vec:Length() - 10
            laser.Mass = 0
            laser.DepthOffset = 100
            laser.Parent = player
            laser:GetData().FFForcedEndPosition = slotpos
            laser:Update()

            sfx:Play(mod.Sounds.GoldenSlotPolymorph, 1, 0, false, math.random(100,120)/100)
        
            return true
        end
    end
end, FiendFolio.ITEM.COLLECTIBLE.DAZZLING_SLOT)

function mod:dazzlingSlotLaserUpdate(player, laser, data, rng)
    if data.FFForcedEndPosition then
        local vec = data.FFForcedEndPosition - laser.Parent.Position
        laser.AngleDegrees = vec:GetAngleDegrees()
        laser.MaxDistance = math.max(vec:Length() - 10, 1)
    end
end