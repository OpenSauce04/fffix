local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:friendlymonCard(cardID, player)
    local rng = player:GetCardRNG(cardID)
    local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
    local successful
    --Dragon Energy, Uses a random other card effect
    local dragonRNG
    if cardID == mod.ITEM.CARD.ENERGY_DRAGON then
        dragonRNG = rng:RandomInt(10) + 1
    end
    --print(dragonRNG)
    for i, v in ipairs(Isaac.GetRoomEntities()) do
        if v:IsVulnerableEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            --Grass Energy, Poisons enemies
            if cardID == mod.ITEM.CARD.ENERGY_GRASS or dragonRNG == 1 then
                v:AddPoison(EntityRef(player), 120, player.Damage)

            --Fire Energy, Burns enemies
            elseif cardID == mod.ITEM.CARD.ENERGY_FIRE or dragonRNG == 2 then
                v:AddBurn(EntityRef(player), 120, player.Damage)

            --Water Energy, Bloats enemies (FF Effect)
            elseif cardID == mod.ITEM.CARD.ENERGY_WATER or dragonRNG == 3 then
               --mod.AddBloated(v, player, 120, player.Damage, player.MaxFireDelay, player.ShotSpeed, player.TearHeight, player.TearFallingSpeed, player.TearFallingAcceleration, player.TearFlags, player.TearColor)
               local damg = player.Damage
               for k = 0, 120 * secondHandMultiplier, 20 do
                    mod.scheduleForUpdate(function()
                        if v and v:Exists() then
                            for i = 45, 360, 45 do
                                local vec = Vector(9, 0):Rotated(i):Rotated(2.25 * k/2)
                                local tear = Isaac.Spawn(2, 0, 0, v.Position + v.Velocity + vec:Resized(v.Size + 5), vec, nil):ToTear()
                                tear.Scale = 0.75
                                tear.CollisionDamage = damg
                                tear.FallingAcceleration = -0.05
                                v:TakeDamage(damg/10, 0, EntityRef(Isaac.GetPlayer()), 0)
                            end
                        end
                    end, k)
                end
            --Lightning Energy, Petrifies enemies (subject to change)
            elseif cardID == mod.ITEM.CARD.ENERGY_LIGHTNING or dragonRNG == 4 then
                --v:AddFreeze(EntityRef(player), 120)
                local damg = player.Damage
                for k = 0, 120 * secondHandMultiplier, 5 do
                     mod.scheduleForUpdate(function()
                         if v and v:Exists() then
                            local laser = EntityLaser.ShootAngle(10, v.Position, math.random(360), 2, Vector(0, -10), Isaac.GetPlayer())
                            laser.Parent = v
                            laser.CollisionDamage = damg
                            laser.MaxDistance = v.Size + math.random(50,100)
                            laser.OneHit = true
                            laser:Update()
                            v:TakeDamage(damg/10, 0, EntityRef(Isaac.GetPlayer()), 0)
                         end
                     end, k)
                 end

            --Fighting Energy, Beserks enemies (FF Effect)
            elseif cardID == mod.ITEM.CARD.ENERGY_FIGHTING or dragonRNG == 5 then
                mod.AddBerserk(v, player, 120 * secondHandMultiplier)

            --Psychic Energy, Confuses enemies
            elseif cardID == mod.ITEM.CARD.ENERGY_PSYCHIC or dragonRNG == 6 then
                --v:AddConfusion(EntityRef(player), 120, false)
                --mod.AddDrowsy(v, player, 60, 360 * secondHandMultiplier)
                for k = 0, 2 * secondHandMultiplier do
                    mod.scheduleForUpdate(function()
                        if v and v:Exists() then
                            v:AddConfusion(EntityRef(player), 120, false)
                        end
                    end, k * 120)
                end

            --Colorless Energy, Hemorrhages enemies (FF Effect)
            elseif cardID == mod.ITEM.CARD.ENERGY_COLORLESS or dragonRNG == 7 then
                mod.AddBleed(v, player, 120 * secondHandMultiplier, player.Damage)
                successful = true

            --Darkness Energy, Fears enemies
            elseif cardID == mod.ITEM.CARD.ENERGY_DARKNESS or dragonRNG == 8 then
                v:AddFear(EntityRef(player), 120)

            --Metal Energy, Bruises enemies (FF Effect)
            elseif cardID == mod.ITEM.CARD.ENERGY_METAL or dragonRNG == 9 then
                for i = 0, 3 do
                    mod.scheduleForUpdate(function()
                        if v and v:Exists() then
                            mod.AddBruise(v, player, (120 * secondHandMultiplier) - (30 * i), 1, player.Damage / 4)
                            if not sfx:IsPlaying(mod.Sounds.PvZBucket) then
                                sfx:Play(mod.Sounds.PvZBucket, 1, 0, false, 1 + (i * 0.2))
                            end
                        end
                    end, 1 + (30 * i))
                end

            --Fairy Energy, Charms enemies
            elseif cardID == mod.ITEM.CARD.ENERGY_FAIRY or dragonRNG == 10 then
                v:AddCharmed(EntityRef(player), 120)
            end
        end
    end

    --Effects
    if cardID == mod.ITEM.CARD.ENERGY_GRASS or dragonRNG == 1 then
        sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 1, 0, false, 0.8)
        for i = 1, 100 do
			local vecX = math.random(50,100)
			if math.random(2) == 1 then
				vecX = vecX * -1
			end

			local side = -400 + math.random(room:GetGridWidth()*40 + 650)

			local eff = Isaac.Spawn(1000, 138, 961, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
			eff.Color = Color(0.5,1,0.5,1,0,1,0)
            eff:GetData().opacity = 0.1
			eff:GetSprite():Stop()
			eff:GetSprite():SetFrame(math.random(4)-1)
			eff.Timeout = 50
			eff:Update()
		end
    elseif cardID == mod.ITEM.CARD.ENERGY_FIRE or dragonRNG == 2 then
        sfx:Play(SoundEffect.SOUND_FIRE_RUSH, 1, 0, false, 1)
        --[[for i = 1, 100 do
			local vecX = math.random(50,100)
			if math.random(2) == 1 then
				vecX = vecX * -1
			end

			local side = -400 + math.random(room:GetGridWidth()*40 + 650)

			local eff = Isaac.Spawn(1000, 138, 961, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
			eff.Color = Color(-1,-1,-1,1,0,0,0)
            eff:GetData().opacity = 1
			eff:GetSprite():Stop()
			eff:GetSprite():SetFrame(math.random(4)-1)
			eff.Timeout = 50
			eff:Update()
		end]]
    elseif cardID == mod.ITEM.CARD.ENERGY_WATER or dragonRNG == 3 then
        local splash = Isaac.Spawn(1000, 132, 0, player.Position, nilvector, player):ToEffect()
        sfx:Play(mod.Sounds.SplashLargePlonkless, 0.5, 0, false, 1)
        splash:FollowParent(player)
        for i = 45, 360, 45 do
            local vec = Vector(9, 0):Rotated(i)
            local tear = Isaac.Spawn(2, 0, 0, player.Position + player.Velocity + vec:Resized(player.Size + 5), vec, player):ToTear()
            tear.Scale = 0.75
            tear.CollisionDamage = player.Damage
            tear.FallingAcceleration = -0.05
        end
    elseif cardID == mod.ITEM.CARD.ENERGY_LIGHTNING or dragonRNG == 4 then
        for i = 1, 3 do
            local laser = EntityLaser.ShootAngle(10, player.Position, math.random(360), 2, Vector(0, -10), player)
            laser.Parent = player
            laser.CollisionDamage = player.Damage
            laser.MaxDistance = player.Size + math.random(50,100)
            laser.OneHit = true
            laser:Update()
        end
    elseif cardID == mod.ITEM.CARD.ENERGY_FIGHTING or dragonRNG == 5 then
        sfx:Play(mod.Sounds.FlashDevilCard, 0.4, 0, false, 0.75)
        for i = 1, 100 do
			local vecX = math.random(50,100)
			if math.random(2) == 1 then
				vecX = vecX * -1
			end

			local side = -400 + math.random(room:GetGridWidth()*40 + 650)

			local eff = Isaac.Spawn(1000, 138, 961, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
			eff.Color = Color(1,0.5,0.5,1,0.5,0,0)
            eff:GetData().opacity = 0.3
			eff:GetSprite():Stop()
			eff:GetSprite():SetFrame(math.random(4)-1)
			eff.Timeout = 50
			eff:Update()
		end
    elseif cardID == mod.ITEM.CARD.ENERGY_PSYCHIC or dragonRNG == 6 then
        sfx:Play(mod.Sounds.EnergyPsychic, 1, 0, false, 1)
        local ring = Isaac.Spawn(mod.FF.PsychicRing.ID,mod.FF.PsychicRing.Var,mod.FF.PsychicRing.Sub, player.Position, nilvector, player):ToEffect()
        ring:FollowParent(player)
        ring.SpriteScale = Vector(0.3,0.3)
        ring.SpriteOffset = Vector(0, -player.SpriteScale.X/2 * 40)
        ring.Color = Color(1,1,1,0.3)
        ring:Update()
    elseif cardID == mod.ITEM.CARD.ENERGY_COLORLESS or dragonRNG == 7 then
        mod:explodePlayer(player, true)
    elseif cardID == mod.ITEM.CARD.ENERGY_DARKNESS or dragonRNG == 8 then
        sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 0, false, 0.5)
        game:Darken(1, 120 * secondHandMultiplier)
    elseif cardID == mod.ITEM.CARD.ENERGY_FAIRY or dragonRNG == 10 then
        sfx:Play(mod.Sounds.EnergyFairy, 1, 0, false, 1)
        local ring = Isaac.Spawn(mod.FF.LoveHeart.ID,mod.FF.LoveHeart.Var,mod.FF.LoveHeart.Sub, player.Position, nilvector, player):ToEffect()
        ring:FollowParent(player)
        --ring.SpriteScale = Vector(0.3,0.3)
        ring.SpriteOffset = Vector(0, -player.SpriteScale.X/2 * 40)
        ring.Color = Color(1,1,1,0.7)
        ring:Update()
    end
    if player:HasTrinket(mod.ITEM.TRINKET.ENERGY_SEARCHER) then
        if rng:RandomInt(3) == 0 then
            local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)
            Isaac.Spawn(5, 302, 2, pos, nilvector, nil)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_GRASS)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_FIRE)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_WATER)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_LIGHTNING)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_FIGHTING)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_PSYCHIC)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_COLORLESS)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_DARKNESS)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_METAL)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_DRAGON)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.friendlymonCard, mod.ITEM.CARD.ENERGY_FAIRY)

function mod:psychicRingAI(e)
    if e:GetSprite():IsFinished("Idle") then
        e:Remove()
    end
end

function mod:loveHeartAI(e)
    if e:GetSprite():IsFinished("Idle") then
        e:Remove()
    end
end