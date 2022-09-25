local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.BlackListedFlowerCrowns = {
[42] = true,
[218] = true,
[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,
[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,
[EntityType.ENTITY_BLOOD_PUPPY] = true,
[EntityType.ENTITY_DARK_ESAU] = true, --These two just in case
[792 .. " " .. 1888] = true, --Cactus Collider, just in case
}

function mod:flowerCrownNewRoom()
    if mod.anyPlayerHas(mod.ITEM.TRINKET.LOST_FLOWER_CROWN, true) then
        FiendFolio.savedata.run.level = FiendFolio.savedata.run.level or {}
        if not FiendFolio.savedata.run.level.flowerCrownTriggered then
            mod.scheduleForUpdate(function()
                local room = game:GetRoom()
                local validEnemies = {}
                for _, entity in ipairs(Isaac.FindInRadius(room:GetCenterPos(), 9999, EntityPartition.ENEMY)) do
                    if (not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) 
                    and entity:IsVulnerableEnemy()
                    and (not entity:IsBoss()) 
                    and (entity.HitPoints > 0)
                    and entity.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                    and (not mod.BlackListedFlowerCrowns[entity.Type])
                    and (not mod.BlackListedFlowerCrowns[entity.Type .. " " .. entity.Variant])
                    and (not mod:isFriend(entity))
                    then
                        table.insert(validEnemies, entity)
                    end
                end
                --print(#validEnemies)
                if #validEnemies > 0 then            
                    local rand = math.random(#validEnemies)
                    local something = Isaac.Spawn(1000, mod.FF.SomethingThatFades.Var,mod.FF.SomethingThatFades.Sub, validEnemies[rand].Position + Vector(0, 1), nilvector, nil)
                    something:GetSprite():Play("Poof", true)
                    something:Update()

                    local tear = Isaac.Spawn(2, 45, 0, validEnemies[rand].Position, nilvector, nil):ToTear()
                    --tear:AddTearFlags(TearFlags.TEAR_PIERCING)
                    tear.Visible = false
                    tear:Update()
                    validEnemies[rand]:Update()
                    sfx:Play(mod.Sounds.FlowerCrown, 1, 0, false, 1)
                    sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
                    mod.scheduleForUpdate(function()
                        sfx:Stop(SoundEffect.SOUND_PLOP)
                    end, 1)
                    --print(validEnemies[rand].Type, validEnemies[rand].Variant, validEnemies[rand].HitPoints)
                    FiendFolio.savedata.run.level.flowerCrownTriggered = true
                end
            end, 1, nil, true)
        end
    end
end

function mod:SomethingThatFadesAI(e)
    local sprite = e:GetSprite()
    e.Velocity = nilvector
    e.DepthOffset = 1000
    e.SpriteOffset = Vector(0, -10)
    sprite:SetFrame("Poof", 0)
    e.Color = Color(1,1,1, 1 - (0.1 * e.FrameCount))
    if e.FrameCount > 10 then
        e:Remove()
    end
end

FiendFolio.AddTrinketPickupCallback(function(player)
    local d = player:GetData().ffsavedata
    if not d then return end

    if not d.RunEffects.Trinkets.FlowerCrownInitialSpawn then
        if math.random(10) == 1 then
            local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.COOL_PHOTO, pos, nilvector, player)
        end
        d.RunEffects.Trinkets.FlowerCrownInitialSpawn = true
    end
end, nil, mod.ITEM.TRINKET.LOST_FLOWER_CROWN)