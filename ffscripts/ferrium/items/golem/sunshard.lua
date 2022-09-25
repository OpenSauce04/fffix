local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

mod.AddTrinketPickupCallback(function(player)
    player:GetData().updateSunShardFam = true
end, function(player)
    player:GetData().updateSunShardFam = true
end, FiendFolio.ITEM.ROCK.SUN_SHARD, nil)

function mod:sunShardUpdate(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SUN_SHARD) then
        local mult = math.ceil(FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SUN_SHARD))
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SUN_SHARD)

        if data.updateSunShardFam then
            local nums = mod:getSeveralDifferentNumbers(3, 3, rng)

            if data.refreshSunShardFam and data.sunShard then
                for num,fam in ipairs(data.sunShard) do
                    if num > 1 then
                        fam:GetData().angle = (data.sunShard[1]:GetData().angle+(num-1)*360/math.min(3,mult)) % 360
                    end

                    local pos = player.Position+Vector(1,0):Rotated(fam:GetData().angle):Resized(60)
                    data.sunShard[num] = Isaac.Spawn(3, FamiliarVariant.SUNSHARD_FAMILIAR, nums[num], pos, Vector.Zero, player):ToFamiliar()
                    data.sunShard[num]:GetData().angle = fam:GetData().angle
                    data.sunShard[num]:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    local splat = Isaac.Spawn(1000, 2, 160, pos, Vector.Zero, nil):ToEffect()
                    splat:FollowParent(data.sunShard[num])
                    data.sunShard[num]:Update()
                    fam:Remove()
                    data.refreshSunShardFam = nil
                end
                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 0.5, 0, false, 1.3)
            end

            local rangle = rng:RandomInt(360)
            for i=1,math.min(3, mult) do
                if (not data.sunShard or not data.sunShard[i] or not data.sunShard[i]:Exists()) then
                    if not data.sunShard then
                        data.sunShard = {}
                    end

                    local chosenAngle = rangle
                    if i > 1 then
                        chosenAngle = data.sunShard[1]:GetData().angle+(i-1)*360/math.min(3,mult)
                    end
                    local pos = player.Position+Vector(1,0):Rotated(chosenAngle):Resized(60)
                    local rock = Isaac.Spawn(3, FamiliarVariant.SUNSHARD_FAMILIAR, nums[i], pos, Vector.Zero, player):ToFamiliar()
                    rock.Player = player
                    rock:GetData().angle = chosenAngle
                    data.sunShard[i] = rock
                    rock:Update()
                    rock:Update()
                end
            end
            for num,fam in ipairs(data.sunShard) do
                if num > mult then
                    fam:Remove()
                    data.sunShard[num] = nil
                end
            end
            data.updateSunShardFam = nil
        end
	end
end

function mod:sunShardNewRoom(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SUN_SHARD) then
        data.updateSunShardFam = true
        data.refreshSunShardFam = true
    end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player
	local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SUN_SHARD)
	local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SUN_SHARD)
    local room = game:GetRoom()
	
	if not player:HasTrinket(FiendFolio.ITEM.ROCK.SUN_SHARD) then
		familiar:Remove()
	end
	
	if not data.init then
		data.stateFrame = 0
		data.angle = data.angle or 0
        data.state = "Idle"
        data.speed = 2
		data.init = true
	else
		data.stateFrame = data.stateFrame + 1
		data.angle = data.angle % 360
	end

    data.damaged = nil
	
	local targPos = player.Position+Vector(1,0):Rotated(data.angle):Resized(60)
	familiar.Velocity = targPos-familiar.Position
    data.angle = data.angle+data.speed

    if data.state == "Idle" then
        mod:spritePlay(sprite, "Idle")
    end

    for _,ent in ipairs(Isaac.FindInRadius(familiar.Position, 50, EntityPartition.ENEMY)) do
		if ent:IsActiveEnemy() and (not mod:isFriend(ent)) then
            if familiar.FrameCount % 6 == 0 then
                if ent.Position:Distance(familiar.Position) - ent.Size < 5 then
                    if ent:IsVulnerableEnemy() then
                        ent:TakeDamage(player.Damage/2, 0, EntityRef(player), 0)
                    end
                end
            end
        end
    end
    for _,ent in ipairs(Isaac.FindByType(9,-1,-1,false, true)) do
		if ent.Position:Distance(familiar.Position) - ent.Size < 10 then
			ent:Die()
            if not data.damaged then
                data.damaged = true
            end
		end
	end
    
    if familiar.SubType == 3 then -- Venus, oh oops, didn't account for how the random function worked.
        if data.damaged and data.stateFrame > 30 and (not data.brain or not data.brain:Exists()) and data.state == "Idle" then
            data.state = "Spawn"
        end
        if data.state == "Spawn" then
            if sprite:IsFinished("Spawn") then
                data.state = "Idle"
                data.damaged = nil
                if not data.couldntSpawn then
                    data.stateFrame = 0
                else
                    data.couldntSpawn = nil
                end
            elseif sprite:IsEventTriggered("Sound") then
                sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,0.5,0,false,1.5)
            elseif sprite:IsEventTriggered("Land") then
                if room:GetGridCollisionAtPos(familiar.Position) == 0 then
                    local brain = Isaac.Spawn(32, 0, 0, familiar.Position, Vector.Zero, player):ToNPC()
                    brain:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
                    brain.HitPoints = 10*mult
                    brain:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/the sun/sunbrain.png")
			    	brain:GetSprite():LoadGraphics()
                    brain.Scale = 0.8
                    sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.5, 0, false, 1)
                    data.brain = brain
                else
                    sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,0.5,0,false,1.5)
                    data.couldntSpawn = true
                end
            else
                mod:spritePlay(sprite, "Spawn")
            end
        end
    elseif familiar.SubType == 2 then -- Earth
        if data.damaged and data.stateFrame > 15 and data.state == "Idle" then
            data.state = "Fire"
        end
        if data.state == "Fire" then
            if sprite:IsFinished("Fire") then
                data.state = "Idle"
                data.damaged = nil
                data.stateFrame = 0
            elseif sprite:IsEventTriggered("Shoot") then
                data.firing = 4
                local radius = 9999
                local target
                for _,ent in ipairs(Isaac.FindInRadius(familiar.Position, 500, EntityPartition.ENEMY)) do
                    if ent:IsActiveEnemy() and (not mod:isFriend(ent)) then
                        if ent.Position:Distance(familiar.Position) < radius then
                            radius = ent.Position:Distance(familiar.Position)
                            target = ent
                        end
                    end
                end
                if target then
                    data.shootVec = target.Position-familiar.Position
                else
                    data.shootVec = Vector(0,1):Rotated(rng:RandomInt(360))
                end
                sfx:Play(mod.Sounds.Valvo, 0.6, 0, false, math.random(9,11)/10)
            else
                mod:spritePlay(sprite, "Fire")
            end
        end

        if data.firing then
            if data.firing > 0 then
                for i=1,data.firing do
                    local tear = Isaac.Spawn(2, 1, 0, familiar.Position, data.shootVec:Resized(data.firing*mod:getRoll(70,110,rng)/100*2.5):Rotated(mod:getRoll(-6,6,rng)), familiar):ToTear()
                    tear.Color = mod.ColorLemonYellow
                    tear.Scale = data.firing/3.5*mod:getRoll(70,110,rng)/100
                    tear.FallingAcceleration = mod:getRoll(1,10,rng)/40*(5-data.firing)
                    tear.FallingSpeed = -data.firing/2
                    tear.CollisionDamage = player.Damage/3
                end
                data.firing = data.firing-1
            else
                data.firing = nil
            end
        end
    elseif familiar.SubType == 1 then -- Neptune
        if data.damaged and data.stateFrame > 20 and data.state == "Idle" then
            data.state = "Beating"
            data.stateFrame = 0
            data.speed = 8
        end
        if data.state == "Beating" then
            if data.stateFrame > 120 then
                data.state = "Idle"
                data.damaged = nil
                data.stateFrame = 0
                data.speed = 2
            elseif sprite:IsEventTriggered("Shoot") then
                local tear = Isaac.Spawn(2, 1, 0, familiar.Position, Vector.Zero, familiar):ToTear()
                tear.FallingSpeed = 0
                tear.FallingAcceleration = 0
                sfx:Play(SoundEffect.SOUND_HEARTBEAT_FASTEST, 0.8, 0, false, 1.5)
            else
                mod:spritePlay(sprite, "Beating")
            end
            if familiar.FrameCount % 3 == 0 then
                local creep = Isaac.Spawn(1000, 46, 0, familiar.Position, Vector.Zero, player):ToEffect()
                creep.SpriteScale = Vector(0.4,0.4)
                creep.CollisionDamage = player.Damage/3
            end
        end
    end
end, FamiliarVariant.SUNSHARD_FAMILIAR)