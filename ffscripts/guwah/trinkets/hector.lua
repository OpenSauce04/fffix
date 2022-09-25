local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:HectorDamageCheck(player)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.HECTOR) and not player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
        mod:DropHector(player)
    end
end

function mod:DropHector(player)
    local vec = RandomVector()
    if mod:IsTrinketGulped(player, FiendFolio.ITEM.ROCK.HECTOR) then
        for i = 1, 12 do
            local newtear = Isaac.Spawn(2, 0, 0, player.Position, vec:Rotated(math.random(60) - 30):Resized(math.random(20,100)/10), player):ToTear()
            newtear.FallingSpeed = -25 - math.random(5)
            newtear.FallingAcceleration = 1.5 + (math.random() * 0.5)
            newtear.Height = -15
            newtear.CanTriggerStreakEnd = false
            newtear.CollisionDamage = player.Damage
            newtear:Update()
            sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT)
        end
    end
    player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.HECTOR)
    Isaac.Spawn(5, 350, FiendFolio.ITEM.ROCK.HECTOR, player.Position, vec:Resized(mod:RandomInt(10,20)), player)
end
