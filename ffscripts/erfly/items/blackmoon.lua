local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local blackmoonVolume = 0.3
local blackmoonAnimEnd = 95

function mod:blackmoonPlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then

    end
end

function mod.blackMoonSoundStuff()
    --[[if sfx:IsPlaying(mod.Sounds.BlackMoonLoop) then
        local readyToStop = true
        for _, blackmooner in ipairs(Isaac.FindByType(1000, 666, 170, false, false)) do
            if blackmooner:GetSprite():GetFrame() < blackmoonAnimEnd then
                readyToStop = false
            end
        end
        if readyToStop then
            sfx:Stop(mod.Sounds.BlackMoonLoop)
            sfx:Play(mod.Sounds.BlackMoonEnd,blackmoonVolume,0,false,1)
        end
    end]]
end

function mod:updateBlackMoonTearLaserColor(player)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
		player.TearColor = FiendFolio.ColorShadyRed
		player.LaserColor = FiendFolio.ColorShadyRed
	end
end

function mod:blackMoonPostFire(player, tear, rng, pdata, tdata)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
		tdata.BlackMoonInflicting = true
	end
end

function mod:blackMoonPostFireBomb(player, bomb, rng)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
		bomb:GetData().BlackMoonInflicting = true
	end
end

function mod:blackMoonFireLaser(player, laser, rng)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
		laser:GetData().BlackMoonInflicting = true
	end
end

function mod:blackMoonOnKnifeUpdate(player, knife)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
		knife:GetData().BlackMoonInflicting = true
    else
        if knife:GetData().BlackMoonInflicting then
            knife:GetData().BlackMoonInflicting = false
        end
	end
end

function mod:blackMoonOnRocketFire(player, target)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
        target:GetData().BlackMoonInflicting = true
    end
end
function mod:blackMoonOnFireAquarius(player, creep)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
        creep:GetData().BlackMoonInflicting = true
    end
end

function mod:blackMoonlocustAI(locust, subtype)
    locust:GetData().BlackMoonInflicting = true
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, damage, flags, source, countdown)
    local player
    if entity:IsEnemy() then
        if source then
            if source.Entity then
                if source.Entity.Type == 1 or (source.Entity.Type == EntityType.ENTITY_EFFECT and source.Entity.Variant == EffectVariant.DARK_SNARE) then
                    local checkEnt = source.Entity
                    if source.Entity.Type == 1000 then
                        checkEnt = source.Entity.SpawnerEntity
                    end

                    if checkEnt and checkEnt:Exists() then
                        checkEnt = checkEnt:ToPlayer()
                        if checkEnt and checkEnt:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
                            player = checkEnt
                        end
                    end
                else
                    if source.Entity:GetData().BlackMoonInflicting then
                        if source.Entity.SpawnerEntity then
                            if source.Entity.SpawnerEntity.Type == 1 then
                                player = source.Entity.SpawnerEntity
                            elseif source.Entity.SpawnerEntity.Type == 3 then
                                if source.Entity.SpawnerEntity:ToFamiliar().Player then
                                    player = source.Entity.SpawnerEntity:ToFamiliar().Player
                                end
                            end
                        end
                    end
                end
            end
        end
        if player then
            player = player:ToPlayer()
            --if player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_MOON) then
                for i = 1, 2 do
                    mod.scheduleForUpdate(function()
                        --safety check
                        if not player or (player and not player:Exists()) then
                            player = Isaac.GetPlayer()
                        end
                        if entity and entity:Exists() and entity:IsEnemy() and entity:IsDead() and not (entity:GetData().checkedBlackMoon or (entity.Type == mod.FFID.Tech and entity.Variant > 999)) then
                            local cloud = Isaac.Spawn(1000, 666, 170, entity.Position, nilvector, player)
                            local scale = math.log(entity.MaxHitPoints, 1.3)
                            scale = math.min(scale, 100)
                            scale = math.max(scale, 5)
                            cloud:GetData().Scale = scale
                            cloud:GetData().Parent = player
                            cloud:Update()
                            --[[if not (sfx:IsPlaying(mod.Sounds.BlackMoonIntro) or sfx:IsPlaying(mod.Sounds.BlackMoonLoop)) then
                                sfx:Play(mod.Sounds.BlackMoonIntro,blackmoonVolume,0,false,1)
                                sfx:Stop(mod.Sounds.BlackMoonEnd)
                            end]]
                            entity:GetData().checkedBlackMoon = true
                        end
                    end, i)
                end
            --end
        end
    end
end)

function mod:blackMoonAura(eff)
    local sprite = eff:GetSprite()
    local d = eff:GetData()
    local player = eff.Parent or Isaac.GetPlayer()
    local baseSize = 17

    local circleRange = (player.TearRange/260) / baseSize
    circleRange = math.max(circleRange, 1/(baseSize * 2))
    circleRange = math.min(circleRange, 1/10)

    if not d.init then
        sprite:Load("gfx/effects/bigRedCircle.anm2", true)
        sprite:Play("AuraOnly", true)
        sprite.Scale = Vector(d.Scale * circleRange, d.Scale * circleRange)
        local cloud = Isaac.Spawn(1000, 666, 171, eff.Position, nilvector, eff)
        cloud.Parent = eff
        cloud:Update()
        d.init = true
    end

    if sprite:GetFrame() < blackmoonAnimEnd then
        --[[if not (sfx:IsPlaying(mod.Sounds.BlackMoonIntro) or sfx:IsPlaying(mod.Sounds.BlackMoonLoop)) then
            sfx:Play(mod.Sounds.BlackMoonLoop,blackmoonVolume,0,false,1)
        end]]
    end

    --eff.SpriteScale = Vector(1, 0.5)
    eff.DepthOffset = -100

    local playerInside
    local procFrame = 5
    if eff.FrameCount % procFrame == 0 then
        local radius = sprite.Scale.X * 80
        for _,enemy in ipairs(Isaac.FindInRadius(eff.Position, radius + 300, EntityPartition.ENEMY)) do
            local pp = enemy.Position
            local ep = eff.Position
            local size = enemy.Size
            if math.abs(ep.X - pp.X) < radius + size and math.abs(ep.Y - pp.Y) < (radius/2) + size and pp:Distance(ep) < (radius * 0.95) + size then
                --playerInside = true
                local damage = ((player.Damage * procFrame ) / math.max(player.MaxFireDelay, 0.01))*0.5
                enemy:TakeDamage(damage, 0, EntityRef(eff), 5)
            end

        end
    end
    if playerInside then
        eff.Color = Color(0,1,1)
    else
        eff.Color = Color(1,1,1)
    end
    --d.cap = d.cap or 30
    --sprite.PlaybackSpeed = 100 / d.cap
    if sprite:IsFinished("AuraOnly") then
        eff:Remove()
    end
end

function mod:blackMoonMiddle(eff)
    local sprite = eff:GetSprite()
    local d = eff:GetData()

    if not d.init then
        sprite:Load("gfx/effects/bigRedCircle.anm2", true)
        sprite:Play("AlakazamOnly", true)
        d.init = true
    end
    if eff.Parent then
        sprite:SetFrame("AlakazamOnly", eff.Parent:GetSprite():GetFrame())
        sprite.Scale = eff.Parent:GetSprite().Scale
    else
        eff:Remove()
    end
end