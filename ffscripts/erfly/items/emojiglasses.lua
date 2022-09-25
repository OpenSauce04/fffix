local mod = FiendFolio
local sfx = SFXManager()
local nilvector = Vector.Zero

local emojiVars = {
    JOY = 0,
    CROC = 1,
    CHICK = 2,
    SUNGLASSES = 3,
    IMP = 4,
    GRIMACE = 5,
    WALK = 6,
    WEIRD = 7,
    SICK = 8,
    BOOT = 9,
    SAX = 10,
    BUG = 11,
    GIFT = 12,
    HORSE = 13,
    NERD = 14,
    HEARTEYES = 15,
    KAWAII = 16,
    THINK = 17,
    INVISIBLE = 18,
    GUN = 19,

    TOTAL = 20
}

local EmojiEffects = {
    [emojiVars.JOY] = {Lob = true},
    [emojiVars.CROC] = {Flip = true, Flag = TearFlags.TEAR_PIERCING, MinBombSpeed = 1, Splat = Color(0.36, 0.57, 0.23, 1)},
    [emojiVars.CHICK] = {Flip = true, Lob = true, NoSpin = true, Flag = TearFlags.TEAR_HYDROBOUNCE},
    [emojiVars.SUNGLASSES] = {Lob = true},
    [emojiVars.IMP] = {Lob = true, Splat = Color(0.6, 0.4, 0.8, 1)},
    [emojiVars.GRIMACE] = {Lob = true},
    [emojiVars.WALK] = {Flip = true, MinBombSpeed = 2},
    [emojiVars.WEIRD] = {Roll = true, Flag = TearFlags.TEAR_BOUNCE},
    [emojiVars.SICK] = {Lob = true, SpinMult = 0.25},
    [emojiVars.BOOT] = {Flip = true, Flag = TearFlags.TEAR_PUNCH, Splat = Color(0.75, 0.41, 0.3, 1)},
    [emojiVars.SAX] = {Flip = true},
    [emojiVars.BUG] = {Flip = true, MinBombSpeed = 2, Splat = Color(0.6, 0.4, 0.8, 1)},
    [emojiVars.GIFT] = {Lob = true, Splat = Color(1, 0.85, 0.65, 1)},
    [emojiVars.HORSE] = {Flip = true, Splat = Color(0.75, 0.41, 0.3, 1)},
    [emojiVars.NERD] = {Flag = TearFlags.TEAR_TURN_HORIZONTAL | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_BAIT},
    [emojiVars.HEARTEYES] = {Lob = true, Flag = TearFlags.TEAR_CHARM},
    [emojiVars.KAWAII] = {Flag = TearFlags.TEAR_BOOGER},
    [emojiVars.THINK] = {Flip = true, Flag = TearFlags.TEAR_OCCULT},
    [emojiVars.INVISIBLE] = {Flag = TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL},
    [emojiVars.GUN] = {Flip = true, SpecialLudo = true, Splat = Color(0.6, 0.6, 0.6, 1)},
}

function mod:emojiGlassesPlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.EMOJI_GLASSES) then
        if not data.CurrentEmojis then
            data.CurrentEmojis = {}
            for i = 1, 3 do
                table.insert(data.CurrentEmojis, player:GetDropRNG():RandomInt(emojiVars.TOTAL))
            end
        end
        if player.FrameCount % 120 == 0 then
            if not data.WipedEmojislate then
                table.remove(data.CurrentEmojis, 1)
                table.insert(data.CurrentEmojis, player:GetDropRNG():RandomInt(emojiVars.TOTAL))
                data.WipedEmojislate = true
            end
        else
            data.WipedEmojislate = false
        end
        --print(data.CurrentEmojis[1], data.CurrentEmojis[2], data.CurrentEmojis[3])
    end
end

function mod:emojiGlassesPostFire(player, tear, rng, pdata, tdata, secondHandMultiplier)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.EMOJI_GLASSES) then
        mod:applyRandomEmojiEffectToTear(tear, player, nil, rng, tdata, pdata, secondHandMultiplier)
    end
end

function mod:applyRandomEmojiEffectToTear(tear, player, emojiVar, rng, tdata, pdata, secondHandMultiplier)
    rng = rng or tear:GetDropRNG()
    tdata = tdata or tear:GetData()
    pdata = pdata or player:GetData()
    secondHandMultiplier = secondHandMultiplier or player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
    
    mod:changeTearVariant(tear, TearVariant.EMOJI_GLASS)
    --tdata.EmojiGlassesEffect = rng:RandomInt(emojiVars.TOTAL)
    tdata.EmojiGlassesEffect = emojiVar or pdata.CurrentEmojis[rng:RandomInt(#pdata.CurrentEmojis) + 1]
    --tdata.EmojiGlassesEffect = emojiVars.BUG
    if tear.Variant == TearVariant.EMOJI_GLASS then
        local sprite = tear:GetSprite()
        sprite:SetFrame(tdata.EmojiGlassesEffect)
    end
    if tdata.EmojiGlassesEffect == emojiVars.JOY then
        tear.Velocity = tear.Velocity * 0.5
        tear.FallingSpeed = tear.FallingSpeed - 5
    elseif tdata.EmojiGlassesEffect == emojiVars.CROC then
        tear.Velocity = tear.Velocity * 0.1
        tear.FallingSpeed = 0
        tear.FallingAcceleration = -0.099
    elseif tdata.EmojiGlassesEffect == emojiVars.CHICK then
        tear.FallingAcceleration = 2
    elseif tdata.EmojiGlassesEffect == emojiVars.SUNGLASSES then
        tdata.YinYangOrb = true
        tdata.yinyangstrength = -0.05
        tear.FallingSpeed = 0
        tear.FallingAcceleration = -0.09
    elseif tdata.EmojiGlassesEffect == emojiVars.IMP then
        if math.random(5) == 1 and not tdata.isImpSodaTear then
            tdata.isImpSodaTear = true
            if not tdata.critLightning or not tdata.critLightning:Exists() then
                sfx:Play(mod.Sounds.CritShoot, 0.3, 0, false, math.random(80,120)/100)
                local critLightning = Isaac.Spawn(1000, 1737, 1, tear.Position, nilvector, tear):ToEffect()
                critLightning.Parent = tear
                critLightning.Color = Color(1,1,1,0,0,0,1)
                critLightning:Update()
                tdata.critLightning = critLightning
            end
            tear.CollisionDamage = tear.CollisionDamage * mod.CritDamageMult
        end
    elseif tdata.EmojiGlassesEffect == emojiVars.GRIMACE then
        tdata.ApplyBruise = true
        tdata.ApplyBruiseDuration = 60 * secondHandMultiplier
        tdata.ApplyBruiseStacks = 1
        tdata.ApplyBruiseDamagePerStack = 1
    elseif tdata.EmojiGlassesEffect == emojiVars.WALK then
        tdata.YinYangOrb = true
        tdata.yinyangstrength = 0.1
        tear.FallingSpeed = 0
        tear.FallingAcceleration = -0.09
        tear.KnockbackMultiplier = tear.KnockbackMultiplier * 3
    elseif tdata.EmojiGlassesEffect == emojiVars.WEIRD then
        tear.FallingSpeed = 0
        tear.FallingAcceleration = -0.08
    elseif tdata.EmojiGlassesEffect == emojiVars.BUG then
        tear.CollisionDamage = tear.CollisionDamage * 1.5
        tear.Velocity = tear.Velocity * 0.75
        tear.FallingAcceleration = -0.05
    elseif tdata.EmojiGlassesEffect == emojiVars.HORSE then
        tear.Velocity = tear.Velocity:Resized(20)
        tear.FallingSpeed = 0
        tear.FallingAcceleration = -0.099
    elseif tdata.EmojiGlassesEffect == emojiVars.THINK then
        tear.FallingSpeed = 0
        tear.FallingAcceleration = -0.099
    end
    if EmojiEffects[tdata.EmojiGlassesEffect].Lob then
        tear.FallingSpeed = tear.FallingSpeed + player.TearHeight / 2
        tear.FallingAcceleration = math.max(tear.FallingAcceleration, 0.5)
    end
    if EmojiEffects[tdata.EmojiGlassesEffect].Flag then
        tear.TearFlags = tear.TearFlags | EmojiEffects[tdata.EmojiGlassesEffect].Flag
    end
end

function mod:emojiTearUpdate(tear, d)
    if d.EmojiGlassesEffect then
        if tear.Variant == TearVariant.EMOJI_GLASS then
            local sprite = tear:GetSprite()
            sprite:SetFrame(d.EmojiGlassesEffect)
            if EmojiEffects[d.EmojiGlassesEffect].Flip then
                if not (EmojiEffects[d.EmojiGlassesEffect].SpecialLudo and (tear.TearFlags == tear.TearFlags | TearFlags.TEAR_LUDOVICO)) then
                    if tear.Velocity.X > 0 then
                        sprite.FlipX = true
                    else
                        sprite.FlipX = false
                    end
                end
            else
                sprite.FlipX = false
            end
            if (EmojiEffects[d.EmojiGlassesEffect].Lob or EmojiEffects[d.EmojiGlassesEffect].Roll) and not EmojiEffects[d.EmojiGlassesEffect].NoSpin then
                d.emojiRotation = d.emojiRotation or math.random(360)
                d.emojiRotationAmount = d.emojiRotationAmount or math.random(10,20)
                local rotAmount = d.emojiRotationAmount
                if EmojiEffects[d.EmojiGlassesEffect].SpinMult then
                    rotAmount = rotAmount * EmojiEffects[d.EmojiGlassesEffect].SpinMult
                end
                if tear.Velocity.X > 0 then
                    d.emojiRotation = d.emojiRotation + rotAmount
                else
                    d.emojiRotation = d.emojiRotation - rotAmount
                end
                sprite.Rotation = d.emojiRotation
            end           
        end
        if d.EmojiGlassesEffect == emojiVars.JOY and tear.FrameCount % 3 == 1 then
            local vec = tear.Velocity:Resized(9):Rotated(90 + (tear.FrameCount * 10))
            local newtear = Isaac.Spawn(2, 0, 0, tear.Position + tear.PositionOffset + Vector(0, 20), vec, tear):ToTear()
            newtear.CollisionDamage = tear.CollisionDamage / 3
            newtear.Scale = tear.Scale / 2
        elseif d.EmojiGlassesEffect == emojiVars.BUG then
            local randomvalue = ((math.random(100) - 50))
            tear.Velocity = tear.Velocity:Rotated(randomvalue)
        elseif d.EmojiGlassesEffect == emojiVars.GUN then
            local enemy = mod.FindClosestEnemy(tear.Position, 300, nil, nil, nil, EntityCollisionClass.ENTCOLL_PLAYEROBJECTS)
            if enemy then
                local exactAng = (enemy.Position - tear.Position):Normalized()
                local justFired
                if tear.FrameCount % 10 == 9 then
                    --[[local firepos = Vector(-5, -5) * tear.Scale
                    local sprite = tear:GetSprite()
                    if sprite.FlipX then
                        firepos.X = firepos.X * -1
                    end]]
                    local newtear = Isaac.Spawn(2, TearVariant.M90_BULLET, 0, tear.Position --[[+ firepos:Rotated(sprite.Rotation)]], exactAng:Resized(13), tear):ToTear()
                    newtear.CollisionDamage = tear.CollisionDamage / 2
                    newtear.Scale = tear.Scale / 1.5
                    justFired = true
                end
                if tear.Variant == TearVariant.EMOJI_GLASS then
                    local sprite = tear:GetSprite()
                    if tear.TearFlags == tear.TearFlags | TearFlags.TEAR_LUDOVICO then
                        if exactAng.X < 0 and sprite.FlipX then
                            sprite.FlipX = false
                            d.emojiRotation = nil
                        elseif exactAng.X > 0 and not sprite.FlipX then 
                            sprite.FlipX = true
                            d.emojiRotation = nil
                        end
                    end
                    if sprite.FlipX then
                        d.emojiRotation = d.emojiRotation or 0
                    else
                        d.emojiRotation = d.emojiRotation or 180
                    end
                    local rotVec = Vector.FromAngle(d.emojiRotation):Normalized()
                    if justFired then
                        if sprite.FlipX then
                            rotVec = rotVec:Rotated(-90)
                        else
                            rotVec = rotVec:Rotated(90)
                        end
                    end
                    local lerpVal = mod:Lerp(rotVec, exactAng, 0.5)
                    d.emojiRotation = lerpVal:GetAngleDegrees()
                    if sprite.FlipX then
                        sprite.Rotation = 360 - d.emojiRotation
                    else
                        sprite.Rotation = d.emojiRotation + 180
                    end
                end
            end
        end
    elseif tear.Variant == TearVariant.EMOJI_GLASS then
        local sprite = tear:GetSprite()
        d.setEmojiSprite = d.setEmojiSprite or math.random(emojiVars.TOTAL) - 1
        sprite:SetFrame(d.setEmojiSprite)
        if EmojiEffects[d.setEmojiSprite].Flip then
            if tear.Velocity.X > 0 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        else
            sprite.FlipX = false
        end
    end
end

function mod:emojiGlassesPreTear(tear, ent, tdata)
    if tdata.EmojiGlassesEffect then
        if tdata.EmojiGlassesEffect == emojiVars.SAX then
            if not tdata.alreadyMadeSaxEmojiSound then
                sfx:Play(mod.Sounds.Boink, 2, 0, false,  math.random(80,120)/100)
                tdata.alreadyMadeSaxEmojiSound = true
            end
        end
    end
end

function mod:emojiTearDeath(tear,data)
    if data.EmojiGlassesEffect then
        if tear.Variant == TearVariant.EMOJI_GLASS then
            local splat = Isaac.Spawn(1000, 1960, 33, tear.Position, nilvector, tear):ToEffect()
            splat.PositionOffset = tear.PositionOffset
            splat.SpriteOffset = tear.SpriteOffset
            tear = tear:ToTear()
            splat.SpriteScale = Vector(tear.Scale, tear.Scale) / 2
            splat.Color = EmojiEffects[data.EmojiGlassesEffect].Splat or Color(0.93, 0.77, 0.35, 1)
            splat:Update()
            sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
        end
        if data.EmojiGlassesEffect == emojiVars.GIFT then
            local summonCount = mod.GetEntityCount(3, 43) + mod.GetEntityCount(3, 73) + mod.GetEntityCount(3, 1026)
            if summonCount < 5 then
                sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0, false, 1.3)
                local rand = math.random(3)
                if rand == 1 then
                    local afly = Isaac.Spawn(3, 43, 0, tear.Position, nilvector, tear)
                    afly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    afly:Update()
                elseif rand == 2 then
                    Isaac.GetPlayer(0):ThrowBlueSpider(tear.Position, tear.Position+RandomVector()*25)
                elseif rand == 3 then
                    local skuzz = Isaac.Spawn(3, FamiliarVariant.ATTACK_SKUZZ, 0, tear.Position, nilvector, tear)
                    skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    skuzz:Update()
                end
            end
        elseif data.EmojiGlassesEffect == emojiVars.SICK then
            local creep = Isaac.Spawn(1000, 46, 0, tear.Position, nilvector, tear):ToEffect()
            creep.Timeout = 30
            creep.CollisionDamage = tear.CollisionDamage
            creep.Color = Color(1,1,1,1,-1,1,0)
            creep:Update()
        end
    elseif tear.Variant == TearVariant.EMOJI_GLASS then
        local splat = Isaac.Spawn(1000, 1960, 33, tear.Position, nilvector, tear):ToEffect()
        splat.PositionOffset = tear.PositionOffset
        splat.SpriteOffset = tear.SpriteOffset
        tear = tear:ToTear()
        splat.SpriteScale = Vector(tear.Scale, tear.Scale) / 2
        if data.setEmojiSprite and EmojiEffects[data.setEmojiSprite].Splat then
            splat.Color = EmojiEffects[data.setEmojiSprite].Splat
        else
            splat.Color = Color(0.93, 0.77, 0.35, 1)
        end
        splat:Update()
        sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
    end
end

function mod:emojiPostFireBomb(player, bomb, rng, secondHandMultiplier)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.EMOJI_GLASSES) then
        local bd, pd = bomb:GetData(), player:GetData()
        bd.EmojiGlassesEffect = pd.CurrentEmojis[rng:RandomInt(#pd.CurrentEmojis) + 1]
        --bd.EmojiGlassesEffect = emojiVars.SICK
        bomb.Color = EmojiEffects[bd.EmojiGlassesEffect].Splat or Color(0.93, 0.77, 0.35, 1)
        if bd.EmojiGlassesEffect == emojiVars.CROC then
            bomb.Velocity = bomb.Velocity * 0.1
            bomb.Friction = 5
            bomb.CollisionDamage = player.Damage
            bomb:SetExplosionCountdown(600)
        elseif bd.EmojiGlassesEffect == emojiVars.SUNGLASSES then
            bd.YinYangOrb = true
            bd.yinyangstrength = -0.02
        elseif bd.EmojiGlassesEffect == emojiVars.IMP then
            if math.random(5) == 1 and not bd.isImpSodaTear then
                sfx:Play(mod.Sounds.CritShoot, 0.3, 0, false, math.random(80,120)/100)
                bd.isImpSodaTear = true
                bomb.Color = Color(1.3,1.3,1.3,1,100/255,-150/255,100/255)
                bomb.CollisionDamage = bomb.CollisionDamage * mod.CritDamageMult
            end
        elseif bd.EmojiGlassesEffect == emojiVars.GRIMACE then
            bd.ApplyBruise = true
			bd.ApplyBruiseDuration = 120 * secondHandMultiplier
			bd.ApplyBruiseStacks = 1
			bd.ApplyBruiseDamagePerStack = 1
        elseif bd.EmojiGlassesEffect == emojiVars.WALK then
            bd.YinYangOrb = true
            bd.yinyangstrength = 0.1
            bomb:SetExplosionCountdown(60)
        elseif bd.EmojiGlassesEffect == emojiVars.WEIRD then
            --bomb:SetExplosionCountdown(40)
            --bd.EmojiGlassesStoredVelocity = player.ShotSpeed * 10
        elseif bd.EmojiGlassesEffect == emojiVars.BUG then
            bomb.ExplosionDamage = bomb.ExplosionDamage * 1.5
        elseif bd.EmojiGlassesEffect == emojiVars.HORSE then
            bomb.Velocity = bomb.Velocity * 3
        elseif bd.EmojiGlassesEffect == emojiVars.THINK then
            bomb:SetExplosionCountdown(60)
        end
        if EmojiEffects[bd.EmojiGlassesEffect].Flag then
            bomb.Flags = bomb.Flags | EmojiEffects[bd.EmojiGlassesEffect].Flag
        end
    end
end

function mod:emojiPostBombUpdate(bomb, data)
    if data.EmojiGlassesEffect then
        if data.EmojiGlassesEffect == emojiVars.JOY then
            if bomb.FrameCount % 3 == 1 then
                local vec = bomb.Velocity:Resized(9):Rotated(90 + (bomb.FrameCount * 10))
                local newtear = Isaac.Spawn(2, 0, 0, bomb.Position + bomb.PositionOffset + Vector(0, 20), vec, bomb):ToTear()
                newtear.CollisionDamage = 2
                newtear.Scale = newtear.Scale * 0.8
            end
        elseif data.EmojiGlassesEffect == emojiVars.WEIRD then
            data.EmojiGlassesStoredVelocity = data.EmojiGlassesStoredVelocity or bomb.Velocity:Length()
            if bomb.Velocity:Length() < data.EmojiGlassesStoredVelocity then
                bomb.Velocity = bomb.Velocity:Resized(data.EmojiGlassesStoredVelocity)
            end
        elseif data.EmojiGlassesEffect == emojiVars.BUG then
            local randomvalue = ((math.random(100) - 50))
            bomb.Velocity = bomb.Velocity:Rotated(randomvalue)
        elseif data.EmojiGlassesEffect == emojiVars.GUN then
            local enemy = mod.FindClosestEnemy(bomb.Position, 300, nil, nil, nil, EntityCollisionClass.ENTCOLL_PLAYEROBJECTS)
            if enemy then
                local exactAng = (enemy.Position - bomb.Position):Normalized()
                local justFired
                if bomb.FrameCount % 10 == 9 then
                    local newtear = Isaac.Spawn(2, TearVariant.M90_BULLET, 0, bomb.Position, exactAng:Resized(13), tear):ToTear()
                    justFired = true
                end
                if exactAng.X > 0 then
                    data.EmojiShouldFlip = 1
                    data.emojiRotation = data.emojiRotation or 0
                else
                    data.EmojiShouldFlip = 2
                    data.emojiRotation = data.emojiRotation or 180
                end
                local rotVec = Vector.FromAngle(data.emojiRotation):Normalized()
                if justFired then
                    if exactAng.X > 0 then
                        rotVec = rotVec:Rotated(-90)
                    else
                        rotVec = rotVec:Rotated(90)
                    end
                end
                local lerpVal = mod:Lerp(rotVec, exactAng, 0.5)
                data.emojiRotation = lerpVal:GetAngleDegrees()
            end
        end
        if EmojiEffects[data.EmojiGlassesEffect].MinBombSpeed then
            local minSpeed = EmojiEffects[data.EmojiGlassesEffect].MinBombSpeed
            if bomb.Velocity:Length() < minSpeed then
                bomb.Velocity = bomb.Velocity:Resized(minSpeed)
            end
        end
    end
end

function mod:emojiPostBombRender(bomb, data, offset)
    if data.EmojiGlassesEffect then
        local icon = Sprite()
        icon.Color = bomb.Color

        icon:Load("gfx/projectiles/emoji_tear.anm2", true)
        icon:SetFrame("Idle", data.EmojiGlassesEffect)
        icon.Scale = (Vector(bomb.Size, bomb.Size) / 16) * 0.75
        local AdditionalOffset = Vector(0,0)
        if data.EmojiShouldFlip then
            if data.EmojiShouldFlip == 1 then
                icon.FlipX = true
            end
        elseif EmojiEffects[data.EmojiGlassesEffect].Flip then
            if bomb.Velocity.X > 0 then
                icon.FlipX = true
            end
        end
        if data.EmojiGlassesEffect == emojiVars.GUN then
            if bomb.Velocity.X > 0 then
                data.emojiRotation = data.emojiRotation or 0
            else
                data.emojiRotation = data.emojiRotation or 180
            end
            if icon.FlipX then
                icon.Rotation = 360 - data.emojiRotation
            else
                icon.Rotation = data.emojiRotation + 180
            end
        end
        local offset = Vector(5, -13) * icon.Scale.X
        local renderPos = Isaac.WorldToScreen(bomb.Position + bomb.SpriteOffset + bomb.PositionOffset + offset)
        icon:Render(renderPos, nilvector, nilvector)
    end
end

function mod:emojiGlassesOnRocketFire(player, target, secondHandMultiplier)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.EMOJI_GLASSES) then
        target:GetData().EmojiGlassesRocketDetails = {player, secondHandMultiplier}
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if explosion.SpawnerEntity then
        local boomie = explosion.SpawnerEntity
        local data = boomie:GetData()
        if data.EmojiGlassesEffectSuccessfullyExploded then
            return
        end
	    if data.EmojiGlassesEffect then
            local boomie = explosion.SpawnerEntity
            local data = boomie:GetData()
            if data.EmojiGlassesEffect == emojiVars.GIFT then
                local summonCount = mod.GetEntityCount(3, 43) + mod.GetEntityCount(3, 73) + mod.GetEntityCount(3, 1026)
                if summonCount < 5 then
                    sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0, false, 1.3)
                    local rand = math.random(3)
                    if rand == 1 then
                        local afly = Isaac.Spawn(3, 43, 0, explosion.Position, nilvector, explosion)
                        afly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        afly:Update()
                    elseif rand == 2 then
                        Isaac.GetPlayer(0):ThrowBlueSpider(explosion.Position, explosion.Position+RandomVector()*25)
                    elseif rand == 3 then
                        local skuzz = Isaac.Spawn(3, FamiliarVariant.ATTACK_SKUZZ, 0, explosion.Position, nilvector, explosion)
                        skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        skuzz:Update()
                    end
                end
            elseif data.EmojiGlassesEffect == emojiVars.SICK then
                local creep = Isaac.Spawn(1000, 46, 0, explosion.Position, nilvector, explosion):ToEffect()
                creep.Timeout = 30
                creep.Color = Color(1,1,1,1,-1,1,0)
                creep:Update()
            end
            data.EmojiGlassesEffectSuccessfullyExploded = true
        elseif data.EmojiGlassesRocketDetails then
            local player = data.EmojiGlassesRocketDetails[1]
            if player and player:Exists() then
                if not (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)) then
                    local vec = RandomVector():Resized(player.ShotSpeed * 10)
                    for i = 36, 360, 36 do
                        local tear = Isaac.Spawn(2, 0, 0, explosion.Position, vec:Rotated(i), player):ToTear()
                        tear.CollisionDamage = player.Damage
                        tear.Scale = 1 + ((tear.CollisionDamage / 3.5) - 1)/3
                        mod:applyRandomEmojiEffectToTear(tear, player)
                    end
                end
            end
        end
	end
end, EffectVariant.BOMB_EXPLOSION)

function mod:fireEmojiTearFromLaser(player, laser, rng)
    if laser.Child then
        local endpoint = laser:GetEndPoint()
        local laservec = (laser.Position - endpoint)
        local realEndpoint = laser.Child.Position
        local vec = laservec:Resized(player.ShotSpeed * 10)
        local rotval = math.random(10, 45)
        if math.random(2) == 1 then
            rotval = rotval * -1
        end
        vec = vec:Rotated(rotval)
        local tear = Isaac.Spawn(2, 0, 0, realEndpoint + vec:Resized(15), vec, player):ToTear()
        tear.CollisionDamage = player.Damage
        tear.Scale = 1 + ((tear.CollisionDamage / 3.5) - 1)/3
        tear.Color = laser.Color
        local d = player:GetData()
        local emojiChoice = d.CurrentEmojis[rng:RandomInt(#d.CurrentEmojis) + 1]

        local splat = Isaac.Spawn(1000, 1960, 33, tear.Position, nilvector, tear):ToEffect()
        splat.PositionOffset = tear.PositionOffset
        splat.SpriteOffset = tear.SpriteOffset
        tear = tear:ToTear()
        splat.SpriteScale = Vector(tear.Scale, tear.Scale) / 2
        splat.Color = EmojiEffects[emojiChoice].Splat or Color(0.93, 0.77, 0.35, 1)
        splat:Update()

        mod:applyRandomEmojiEffectToTear(tear, player, emojiChoice, nil, nil, d)
    end
end

function mod:emojiGlassesPreFireLaser(player, laser)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.EMOJI_GLASSES) then
        mod:tryMakeLaserEmoji(laser)
    end
end

function mod:emojiGlassesPostFireLaser(player, laser, rng)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.EMOJI_GLASSES) then
        if laser.Timeout == 1 or laser.OneHit then
            mod:fireEmojiTearFromLaser(player, laser, rng)
        else
            laser:GetData().emojiGlassesLaser = true
        end
    end
end

function mod:emojiGlassesPostLaserUpdate(player, laser, data, rng)
    if data.emojiGlassesLaser then
        if laser.Timeout == -1  then
            if laser.FrameCount % 10 == 2 then
                mod:fireEmojiTearFromLaser(player, laser, rng)
            end
        elseif laser.FrameCount % 3 == 2 then
            mod:fireEmojiTearFromLaser(player, laser, rng)
        end
    end
end