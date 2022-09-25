local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:cetusUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.CETUS) then
        local tempEffects = player:GetEffects()
        if tempEffects:HasCollectibleEffect(mod.ITEM.COLLECTIBLE.CETUS) then
            if player.FrameCount % 2 == 0 then
                local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.CETUS)
                local newtear = Isaac.Spawn(2, 0, 0, player.Position, Vector(0,1+rng:RandomInt(15)/3):Rotated(rng:RandomInt(360)), player):ToTear()
                newtear.FallingSpeed = -18 - rng:RandomInt(20)
                newtear.FallingAcceleration = 1.1
                newtear.Height = -10
                newtear.CanTriggerStreakEnd = false
                newtear.CollisionDamage = player.Damage
                newtear.Scale = math.min(1.2, player.Damage/5.5)
                newtear.SpawnerEntity = player
                newtear:GetData().dontCollideBombs = true
                newtear:GetData().isCetusTear = true
                newtear:Update()
            end
        end
    end
end

function mod:cetusPlayerHurt(player)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.CETUS) then
        --sfx:Play(SoundEffect.SOUND_SATAN_HURT, 1, 0, false, 0.5)
        player:UseActiveItem(mod.ITEM.COLLECTIBLE.CETUS)
    end
end

function mod:cetusTearDeath(tear,data)
    if data.isCetusTear then
		FiendFolio.IgnoreAquariusSynergies = true
        local creep = Isaac.Spawn(1000,54,0,tear.Position, nilvector, tear.SpawnerEntity):ToEffect()
        creep.SpawnerEntity = tear.SpawnerEntity
        creep.CollisionDamage = tear.CollisionDamage
        creep.Scale = creep.Scale * math.random(80,120)/100
        creep.Timeout = math.random(60,180)
        creep.Parent = tear.SpawnerEntity
        creep:Update()
		FiendFolio.IgnoreAquariusSynergies = false
    end
end