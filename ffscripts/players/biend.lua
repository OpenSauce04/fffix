local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local hats = {
    {
        Sprite = "astronaut",
        Offset = Vector(0, 1),
        Tears = 0.9
    },
    {
        Sprite = "cat",
        Offset = Vector(0, 3),
        Tears = 0.8,
        Luck = -1
    },
    {
        Sprite = "fedora",
        Offset = Vector(0, -1),
        Damage = 1.1,
        Luck = 1
    },
    {
        Sprite = "flower",
        Luck = 4
    },
    {
        Sprite = "football",
        Offset = Vector(0, -1),
        Damage = 1.1,
        TearSize = 1.25,
        Luck = -1
    },
    {
        Sprite = "ghastly",
        Offset = Vector(0, -1),
        Damage = 2,
        Tears = 1.9
    },
    {
        Sprite = "goggles",
        Offset = Vector(0, 3),
        Tears = 0.5,
        Damage = 0.75,
        TearSize = 0.75
    },
    {
        Sprite = "plumber",
        Tears = 0.95,
        Luck = 1
    },
    {
        Sprite = "viking",
        Offset = Vector(0, -1),
        Damage = 1.2,
        Tears = 1.1
    },
    {
        Sprite = "visor",
        TearSize = 1.75
    }
}

if StageAPI and StageAPI.Loaded then
    StageAPI.AddPlayerGraphicsInfo(FiendFolio.PLAYER.BIEND, {
        Name = "gfx/ui/boss/playername_fiend.png",
        Portrait = "gfx/ui/stage/playerportrait_taintedfiend_rep.png",
        NoShake = false,
        Controls = "gfx/backdrop/controls_fiend.png"
    })
end

function mod:ShouldPlayerGetInitialised(player) -- Credit to Kittenchilly
    if (player.FrameCount == 0 or (game:GetRoom():GetFrameCount() > 1 and player.FrameCount == 1)) and not player.Parent then
        local level = game:GetLevel()

        if (level:GetAbsoluteStage() == LevelStage.STAGE1_1 and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) or level:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX then
            return level:GetCurrentRoomDesc().VisitedCount == 1
        end
    end
end

local function swapPlayerAnm2(player, anm2)
    local sprite = player:GetSprite()
    local anim, frame, isPlaying = sprite:GetAnimation(), sprite:GetFrame(), not sprite:IsFinished()
    sprite:Load(anm2, true)
    if isPlaying then
        sprite:Play(anim, true)
        sprite:SetFrame(frame)
    else
        sprite:SetFrame(anim, frame)
    end
end

local biendBlacklistedItems = {
    CollectibleType.COLLECTIBLE_GUILLOTINE,
    CollectibleType.COLLECTIBLE_SCISSORS,
    CollectibleType.COLLECTIBLE_DECAP_ATTACK
}

function mod.FiendBSkinInit(player)
    swapPlayerAnm2(player, "gfx/characters/player_biend.anm2")
	player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MALICE)

    local pool = game:GetItemPool()
    for _, item in ipairs(biendBlacklistedItems) do
        pool:RemoveCollectible(item)
    end
end

local dirToVec = {
	[Direction.NO_DIRECTION] = Vector(0,0),
	[Direction.LEFT] = Vector(-1,0),
	[Direction.UP] = Vector(0,-1),
	[Direction.RIGHT] = Vector(1,0),
	[Direction.DOWN] = Vector(0,1)
}

local dirToStr = {
	[Direction.NO_DIRECTION] = "Down",
	[Direction.DOWN] = "Down",
	[Direction.UP] = "Up",
	[Direction.LEFT] = "Left",
	[Direction.RIGHT] = "Right",
}

local dirToReverse = {
	[Direction.LEFT] = Direction.RIGHT,
	[Direction.UP] = Direction.DOWN,
	[Direction.RIGHT] = Direction.LEFT,
	[Direction.DOWN] = Direction.UP
}

local function canMaliceHit(ent)
    return (
        ent:ToNPC() 
        and ent:IsActiveEnemy(false) 
        and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        and not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)
        and ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE 
        and ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ENEMIES
    )
end

local function tearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

function mod.SpawnMaliceMinion(parent, pos, vel, tearDelayOffset)
    parent = parent or Isaac.GetPlayer()
    Isaac.ExecuteCommand("addplayer " .. PlayerType.PLAYER_THELOST .. " " .. parent.ControllerIndex)

    local player = Isaac.GetPlayer(game:GetNumPlayers() - 1)
    local sprite = player:GetSprite()
    local data = player:GetData()

    data.MaliceMinion = true
    data.TearDelayOffset = tearDelayOffset

    player.Variant = 1
    player.SubType = 0

    if parent.CanFly then
        sprite:Load("gfx/familiar/biend/flying_malice_minion.anm2", true)
    else
        sprite:Load("gfx/familiar/biend/malice_minion.anm2", true)
    end

    player.Parent = parent

    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()

    player.Position = pos
    player.Velocity = vel
    player:SetMinDamageCooldown(30)

    game:GetHUD():AssignPlayerHUDs()

    return player
end

local function handleMinionDamage(player, parentPlayer)
    if not parentPlayer:GetData().MaliceMinions then return end

    player.Damage = parentPlayer.Damage

    local parentFireDelay = parentPlayer.MaxFireDelay
    local currentTears = 30 / (parentFireDelay + 1)
    local minionCount = #parentPlayer:GetData().MaliceMinions
    local currentTearsTotal = currentTears * minionCount
    if currentTearsTotal > 60 then
        local newDamage = (player.Damage / 60) * currentTearsTotal
        player.Damage = newDamage
    end

    if player:GetData().Hat then
        local hat = player:GetData().Hat
        if hat.Damage then
            player.Damage = player.Damage * hat.Damage
        end
    end
end

local function handleMinionFireDelay(player, parentPlayer)
    if not parentPlayer:GetData().MaliceMinions then return end

    local parentFireDelay = parentPlayer.MaxFireDelay
    local currentTears = 30 / (parentFireDelay + 1)
    local minionCount = #parentPlayer:GetData().MaliceMinions
    local currentTearsTotal = currentTears * minionCount
    if currentTearsTotal > 60 then
        currentTearsTotal = 60
    end

    player.MaxFireDelay = ((30 / (currentTearsTotal / minionCount)) - 1) * player:GetData().TearDelayOffset

    if player:GetData().Hat then
        local hat = player:GetData().Hat
        if hat.Tears then
            player.MaxFireDelay = player.MaxFireDelay * hat.Tears
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    if player:GetData().MaliceSplit then
        if flag == CacheFlag.CACHE_DAMAGE then
            local maxDamage = mod:Lerp(player.Damage * 0.8, player.Damage * 2.25, player:GetData().InitialMinionCount / 6)
            player.Damage = maxDamage / player:GetData().InitialMinionCount
        end
    end

    if player:GetData().MaliceMinion then
        local parentPlayer = player.Parent:ToPlayer()
        if flag == CacheFlag.CACHE_RANGE then
            player.TearHeight = -6
            player.TearRange = parentPlayer.TearRange
        elseif flag == CacheFlag.CACHE_FLYING then
            player.CanFly = parentPlayer.CanFly
        elseif flag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = parentPlayer.TearFlags
        elseif flag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = parentPlayer.TearColor
        elseif flag == CacheFlag.CACHE_DAMAGE then
            handleMinionDamage(player, parentPlayer)
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            handleMinionFireDelay(player, parentPlayer)
        elseif flag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck - 2

            if player:GetData().Hat then
                local hat = player:GetData().Hat
                if hat.Luck then
                    player.Luck = player.Luck + hat.Luck
                end
            end
        end
    else
        if player:GetPlayerType() ~= FiendFolio.PLAYER.BIEND then return end

        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * 0.8
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = tearsUp(player.MaxFireDelay, 0.32)
        elseif flag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = FiendFolio.ColorDankBlackReal
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * 0.9
        end
    end
end)

local function cancelAllMaliceEffects(player)
    local data = player:GetData()

    if data.MaliceMinions then
        for _, minion in ipairs(data.MaliceMinions) do
            if minion.Type == 1 then
                minion:GetData().NoDeathEffects = true
                minion.Visible = false
                minion:Die()
            else
                minion:Remove()
            end
        end

        data.MaliceMinions = nil
    end

    if data.MaliceReformTarget then
        data.MaliceReformTarget:Remove()
        data.MaliceReformTarget = nil
    end

    if data.MaliceProjectile then
        data.MaliceProjectile:Remove()
        data.MaliceProjectile = nil
    end

    data.MaliceSplit = nil
    data.MaliceDashing = nil
    data.MaliceInMirror = nil
    data.Reverse3FireballsDash = nil
    data.Reverse3FireballsDashCount = nil
    data.MaliceReforming = nil
    data.MaliceMegaMush = nil
    data.MaliceHits = nil
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    -- malice works on other players just in case
    local data = player:GetData()

    -- this runs for actual malice minions, not for the player who used malice
    if data.MaliceMinion then
        if data.Leader then
            if player.FrameCount % 3 == 1 then
                local creep = Isaac.Spawn(1000, 45, 0, player.Position, Vector.Zero, player):ToEffect()
                creep.Scale = 0.5
                creep:SetTimeout(10)
                creep:Update()
            end
        end
    end

    if data.MaliceDashing then
        local isMirror = game:GetRoom():IsMirrorWorld()
        if data.MaliceInMirror ~= isMirror then
            if data.MaliceInMirror ~= nil then
                if data.MaliceProjectile and data.MaliceProjectile:Exists() then
                    data.MaliceProjectile.Velocity = -data.MaliceProjectile.Velocity
                end
                
                data.MaliceDashing = dirToReverse[data.MaliceDashing]
            end

            data.MaliceInMirror = isMirror
        end

        if not data.MaliceProjectile or not data.MaliceProjectile:Exists() then
            local vec = dirToVec[data.MaliceDashing]
            data.MaliceProjectile = Isaac.Spawn(FiendFolio.FF.BallOfMalice.ID, FiendFolio.FF.BallOfMalice.Var, FiendFolio.FF.BallOfMalice.Sub, player.Position, vec * 20, player)
            data.MaliceProjectile.Parent = player
            local maliceSprite = data.MaliceProjectile:GetSprite()
            if data.MaliceDashing == Direction.UP then
                maliceSprite:Play("AppearUp", true)
            elseif data.MaliceDashing == Direction.DOWN then
                maliceSprite:Play("AppearDown", true)
            else
                maliceSprite:Play("AppearHori", true)
                data.MaliceProjectile.FlipX = data.MaliceDashing == Direction.LEFT
            end
        end

        local creepPos = player.Position + RandomVector() * 20
        local creep = Isaac.Spawn(1000, 45, 0,creepPos, Vector.Zero, player):ToEffect()
        creep.SpriteScale = Vector.One * 1.5
        creep:SetTimeout(50)
        creep:Update()

        if player.FrameCount % 3 == 0 then
            local splatter = Isaac.Spawn(1000, 2, 2, creepPos, Vector.Zero, player)
            splatter.Color = FiendFolio.ColorDankBlackReal
        end

        local attemptedMovement = player:GetMovementVector()

        data.MaliceMobility = data.MaliceMobility or 0.1
        data.MaliceMobility = mod:Lerp(data.MaliceMobility, 0.05, 0.1)
        data.MaliceProjectile.Velocity = mod:Lerp(data.MaliceProjectile.Velocity:Normalized(), attemptedMovement:Normalized(), data.MaliceMobility) * 20

        data.MaliceHits = data.MaliceHits or {}

        local enemies = Isaac.FindInRadius(data.MaliceProjectile.Position, 40, EntityPartition.ENEMY)
        for _, enemy in ipairs(enemies) do
            if canMaliceHit(enemy) and not data.MaliceHits[GetPtrHash(enemy)] then
                local level = game:GetLevel()
                local stage = level:GetStage()
                local stageType = game:GetLevel():GetStageType()
                if level:IsAscent() then
                    stage = 10
                elseif stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
                    stage = stage + 1
                end

                data.MaliceHits[GetPtrHash(enemy)] = true

                local damageMod = stage * 5
                if data.Reverse3FireballsDash then
                    damageMod = damageMod + 10 + stage * 2
                end

                enemy:TakeDamage(10 + damageMod, 0, EntityRef(player), 0)

                if enemy:HasMortalDamage() then
                    if data.Reverse3FireballsDash then
                        data.Reverse3FireballsDashCount = math.min(4, data.Reverse3FireballsDashCount + 1)
                    end

                    if not FiendFolio.ACHIEVEMENT.IMPLOSION:IsUnlocked(true) and mod.CanRunUnlockAchievements() then
                        mod.savedata.maliceKills = mod.savedata.maliceKills + 1
                        if mod.savedata.maliceKills >= 50 then
                            FiendFolio.ACHIEVEMENT.IMPLOSION:Unlock()
                        end
                    end

                    local isBiend = player:GetPlayerType() == FiendFolio.PLAYER.BIEND
                    if isBiend or data.Reverse3FireballsDash then
                        local odds = 0.2
                        if isBiend and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                            odds = 0.35
                        end

                        if math.random() <= odds then
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_FIENDFOLIO_HALF_BLACK_HEART, 0, enemy.Position, Vector.Zero, player)
                        end
                    end
                end
            end
        end

        local dashEnd
        if player:CollidesWithGrid() or not game:GetRoom():IsPositionInRoom(player.Position, -50) then
            sfx:Play(mod.Sounds.SplashSmall, 0.4, 0, false, math.random(90, 110)/100)
            if data.Reverse3FireballsDash then
                data.Reverse3FireballsDashCount = data.Reverse3FireballsDashCount - 1
                if data.Reverse3FireballsDashCount < 0 then
                    dashEnd = true
                else
                    local splatter = Isaac.Spawn(1000, 2, 0, player.Position, Vector.Zero, player)
                    splatter.Color = FiendFolio.ColorDankBlackReal
                    data.MaliceHits = nil
                    data.MaliceProjectile.Velocity = -data.MaliceProjectile.Velocity
                    data.MaliceMobility = 0.2
                end
            else
                dashEnd = true
            end
        end

        if dashEnd then
            local splatter = Isaac.Spawn(1000, 2, 0, player.Position, Vector.Zero, player)
            splatter.Color = FiendFolio.ColorDankBlackReal
            data.MaliceProjectile = nil
            data.MaliceDashing = nil
            data.MaliceInMirror = nil
            data.MaliceHits = nil
            data.Reverse3FireballsDash = nil
            data.Reverse3FireballsDashCount = nil

            local playerVelLength = player.Velocity:Length()
            if playerVelLength > player.MoveSpeed * 4 then
                player.Velocity = (player.Velocity / playerVelLength) * player.MoveSpeed * 4
            end

            if player:GetPlayerType() == FiendFolio.PLAYER.BIEND then
                data.MaliceSplit = true
                
                data.MaliceMinions = {}

                local minionCount = math.max(2, math.min(math.ceil(player:GetSoulHearts() / 2), 6))

                data.InitialMinionCount = minionCount

                player:SetMinDamageCooldown(45)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()

                local coins = player:GetNumCoins()

                for i = 1, minionCount do
                    local vel = RandomVector() * 4
                    if i == 1 then
                        vel = player.Velocity
                    end
                    
                    local tearDelayOffset = 1
                    if minionCount > 1 then
                        tearDelayOffset = mod:Lerp(0.9, 1.1, (i - 1) / (minionCount - 1))
                    end

                    data.MaliceMinions[#data.MaliceMinions + 1] = mod.SpawnMaliceMinion(player, player.Position, vel, tearDelayOffset)
                end

                player:AddCoins(coins - player:GetNumCoins())
            end
        end
    elseif data.MaliceSplit then
        local oldLeader
        for i = #data.MaliceMinions, 1, -1 do
            local minion = data.MaliceMinions[i]
            if not minion:Exists() then
                table.remove(data.MaliceMinions, i)
            else
                if minion:GetData().Leader then
                    oldLeader = GetPtrHash(minion)
                    minion:GetData().Leader = false
                end
            end
        end

        if #data.MaliceMinions == 0 then
            data.MaliceSplit = nil
            swapPlayerAnm2(player, "gfx/characters/player_biend_miniondeath.anm2")
            player:Die()
            data.MaliceMinions = nil
        else
            if oldLeader ~= GetPtrHash(data.MaliceMinions[1]) then
                player.Position = data.MaliceMinions[1].Position
                player.Velocity = data.MaliceMinions[1].Velocity
            end

            data.MaliceMinions[1]:GetData().Leader = true
        end
    elseif data.MaliceReforming then
        if not data.ReformTarget then
            data.ReformTarget = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, player.Position, player.Velocity, player):ToEffect()
            data.ReformTarget:GetSprite():ReplaceSpritesheet(0, "gfx/effects/biend_reform_target.png")
            data.ReformTarget:GetSprite():LoadGraphics()
            data.ReformTarget:GetSprite():Play("Blink", true)
        end

        data.ReformTarget.Position = player.Position
        data.ReformTarget.Velocity = player.Velocity

        local anyBallTooFar
        for _, minionBall in ipairs(data.MaliceMinions) do
            if minionBall.Position:DistanceSquared(player.Position) > 20 ^ 2 or (minionBall:GetSprite():IsPlaying("Transform") and not minionBall:GetSprite():WasEventTriggered("Transformed")) then
                anyBallTooFar = true
                break
            end
        end

        if not anyBallTooFar then
            for _, minionBall in ipairs(data.MaliceMinions) do
                minionBall:Remove()
            end

            data.ReformTarget:Remove()
            data.ReformTarget = nil

            player.Visible = true 
            local poof = Isaac.Spawn(FiendFolio.FF.BallOfMalice.ID, FiendFolio.FF.BallOfMalice.Var, FiendFolio.FF.BallOfMalice.Sub, player.Position, Vector.Zero, player)
            poof.Parent = player
            poof:GetSprite():Play("Poof", true)
            player:UpdateCanShoot()
            data.MaliceReforming = nil
            data.MaliceMinions = nil

            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end

    if player:GetPlayerType() ~= FiendFolio.PLAYER.BIEND then
        return
    end

    if mod:ShouldPlayerGetInitialised(player) then
        mod.FiendBSkinInit(player)
    end

    if player.FrameCount % 3 == 1 and not data.MaliceHidden and not data.BiendClosetMode then
        local creep = Isaac.Spawn(1000, 45, 0, player.Position, Vector.Zero, player):ToEffect()
        creep.Scale = 0.75
        creep:SetTimeout(10)
        creep:Update()
    end
end)

local playerPickupAnims = {
    LiftItem = true,
    HideItem = true,
    UseItem = true,
    PickupWalkDown = true,
    PickupWalkLeft = true,
    PickupWalkRight = true,
    PickupWalkUp = true
}

local copiedPlayerAnims = {
    Happy = true,
    Sad = true,
    TeleportUp = true,
    TeleportDown = true,
    Glitch = true,
    Jump = true,
    Trapdoor = 1,
    LightTravel = 1,
    DeathTeleport = 1,
}

local recentDeadMinions = {}

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local data = player:GetData()
    if data.MaliceMinion then
        player.PositionOffset = Vector(0, 0)

        local playerParent = player.Parent:ToPlayer()
        local pSprite = playerParent:GetSprite()
        local sprite = player:GetSprite()

        handleMinionDamage(player, playerParent)
        handleMinionFireDelay(player, playerParent)

        sprite.Scale = Vector(0.5, 0.5)

        if playerParent:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not data.Hat then -- birthright handled here rather than when minions are spawned in case you pick up birthright as minions
            if playerParent:GetData().MaliceMinions then
                mod:Shuffle(hats)

                for i, minion in ipairs(playerParent:GetData().MaliceMinions) do
                    local hat = hats[i]
                    if hat then
                        minion:GetData().Hat = hat
                    else
                        minion:GetData().Hat = hats[math.random(1, #hats)]
                    end
                end
            end
        end

        if playerParent.CanFly and sprite:GetFilename() ~= "gfx/familiar/biend/flying_malice_minion.anm2" then
            swapPlayerAnm2(player, "gfx/familiar/biend/flying_malice_minion.anm2")
        elseif not playerParent.CanFly and sprite:GetFilename() ~= "gfx/familiar/biend/malice_minion.anm2" then
            swapPlayerAnm2(player, "gfx/familiar/biend/malice_minion.anm2")
        end

        if data.Leader then
            player.Position = player.Parent.Position
            player.Velocity = player.Parent.Velocity
        else
            local targetAhead = player.Parent.Position + player.Parent.Velocity * 20
            if not data.TargetPosition or targetAhead:DistanceSquared(data.TargetPosition) > 30 ^ 2 then
                data.TargetPosition = targetAhead + RandomVector() * 25
            end

            if data.ForcedAnim == "Trapdoor" then
                local dirFromPlayer = data.TargetPosition - player.Parent.Position
                if dirFromPlayer:LengthSquared() > 15 ^ 2 then
                    data.TargetPosition = player.Parent.Position + dirFromPlayer:Resized(15)
                end
                
                player.Velocity = mod:Lerp(player.Position, data.TargetPosition, 0.1) - player.Position
            elseif not data.ForcedAnim and player.Position:DistanceSquared(data.TargetPosition) > 3 ^ 2 then
                player.Velocity = player.Velocity + (data.TargetPosition - player.Position):Resized(math.max(player.Parent:ToPlayer().MoveSpeed, 0.65) * 1.1 * 0.5)
            else
                player.Velocity = Vector.Zero
            end
        end

        local isDying = sprite:GetAnimation() == "Death" or sprite:GetAnimation() == "LostDeath"
        if isDying and not data.CheckedDeathEffects then
            if not data.NoDeathEffects then
                local splatter = Isaac.Spawn(1000, 2, 0, player.Position, Vector.Zero, player)
                splatter.Color = FiendFolio.ColorDankBlackReal

                Isaac.Spawn(mod.FF.MaliceMinionGhost.ID, mod.FF.MaliceMinionGhost.Var, mod.FF.MaliceMinionGhost.Sub, player.Position, Vector.Zero, player)
            end

            recentDeadMinions[GetPtrHash(player)] = {player.Position, 2}
            data.CheckedDeathEffects = true
            sprite:SetLastFrame()
        end
        
        local playerAnim = pSprite:GetAnimation()
        if data.JustPlayed then
            if (data.JustPlayed ~= playerAnim or pSprite:GetFrame() < data.JustPlayedFrame) then
                data.JustPlayed = nil
            else
                data.JustPlayedFrame = pSprite:GetFrame()
            end
        end

        if not data.Appeared then
            if not data.DelayedAnim and not data.ForcedAnim then
                data.DelayedAnim = "Spawn"
                data.AnimDelay = 0
            end
        elseif copiedPlayerAnims[playerAnim] and not data.JustPlayed then
            data.DelayedAnim = playerAnim
            data.JustPlayed = playerAnim
            data.JustPlayedFrame = pSprite:GetFrame()
            if copiedPlayerAnims[playerAnim] == 1 then
                data.SmallDelay = true
            end
        elseif playerPickupAnims[playerAnim] and not sprite:IsPlaying("UseItem") then
            if not data.CurrentlyPickingUp and not data.DelayedAnim and playerAnim ~= "HideItem" then
                data.PickupAnim = true
                data.DelayedAnim = "LiftItem"
                if playerAnim == "UseItem" then
                    data.DelayedAnim = "UseItem"
                end
            end
        elseif data.CurrentlyPickingUp and not data.DelayedAnim then
            data.DelayedAnim = "HideItem"
        end

        if data.DelayedAnim and not data.AnimDelay then
            if data.Leader or data.SmallDelay then
                data.AnimDelay = math.random(1, 5)
            else
                data.AnimDelay = math.random(1, 15)
            end

            data.SmallDelay = nil
        end

        if data.AnimDelay then
            data.AnimDelay = data.AnimDelay - 1
            if data.AnimDelay <= 0 then
                if data.PickupAnim then
                    data.CurrentlyPickingUp = true
                else
                    data.CurrentlyPickingUp = nil
                end

                data.ForcedAnim = data.DelayedAnim
                data.ForcedAnimFrame = 0
                sprite:Play(data.DelayedAnim, true)
                sprite:SetLastFrame()
                data.ForcedAnimLastFrame = sprite:GetFrame()
                sprite:RemoveOverlay()
                data.AnimDelay = nil
                data.DelayedAnim = nil
                data.PickupAnim = nil
            end
        end

        data.CanRenderHat = false
        if data.ForcedAnim then
            local frame = math.floor(data.ForcedAnimFrame)
            sprite:SetFrame(data.ForcedAnim, frame)

            data.ForcedAnimFrame = data.ForcedAnimFrame + 1
            if data.ForcedAnimFrame >= data.ForcedAnimLastFrame + 1 then
                if data.ForcedAnim == "Trapdoor" then
                    player.Visible = false
                elseif data.ForcedAnim == "Appear" then -- if i don't forcibly stop the appear anim, they transform into random co-op babies?!?
                    sprite:SetFrame("WalkDown", 0)
                    sprite:SetOverlayFrame("HeadDown", 0)
                elseif data.ForcedAnim == "Spawn" then
                    data.Appeared = true
                end

                data.ForcedAnim = nil
                data.ForcedAnimFrame = nil
                data.ForcedAnimLastFrame = nil
            end
        elseif sprite:IsFinished() and not isDying then
            data.CanRenderHat = true

            local fireDir = player:GetFireDirection()

            local walkPrefix = "Walk"
            if data.CurrentlyPickingUp then
                walkPrefix = "PickupWalk"
            end

            if (playerParent and playerParent.CanFly) or data.Flying then
                --walkPrefix = "Fly"
                data.Flying = true
            end

            local moveDirStr
            local noMovement = player.Velocity:LengthSquared() <= 1
            if noMovement then
                moveDirStr = "Down"
            elseif math.abs(player.Velocity.X) > math.abs(player.Velocity.Y) then
                if player.Velocity.X < 0 then
                    moveDirStr = "Left"
                else
                    moveDirStr = "Right"
                end
            else
                if player.Velocity.Y < 0 then
                    moveDirStr = "Up"
                else
                    moveDirStr = "Down"
                end
            end

            local walkAnim = walkPrefix .. moveDirStr
            local headAnim = "Head" .. dirToStr[fireDir]

            if not data.MaxWalkFrame then
                sprite:SetAnimation(walkAnim, false)
                sprite:SetLastFrame()
                data.MaxWalkFrame = sprite:GetFrame()
            end

            data.WalkFrame = ((data.WalkFrame or 0) + 0.5) % data.MaxWalkFrame

            if noMovement and walkPrefix ~= "Fly" then
                sprite:SetFrame(walkAnim, 0)
            else
                sprite:SetFrame(walkAnim, math.floor(data.WalkFrame))
            end

            if walkPrefix ~= "PickupWalk" then
                if fireDir == Direction.NO_DIRECTION then
                    headAnim = "Head" .. moveDirStr
                end

                sprite:SetOverlayFrame(headAnim, (player.FireDelay > (player.MaxFireDelay / 2)) and 2 or 0)
            end
        end
    else
        if (data.MaliceSplit or data.MaliceReforming) then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MALICE) then
                for i = 0, 3 do
                    if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_MALICE then
                        local charge = player:GetActiveCharge(i)
                        player:RemoveCollectible(CollectibleType.COLLECTIBLE_MALICE)
                        player:AddCollectible(CollectibleType.COLLECTIBLE_MALICE_REFORM, charge, false, i, 0)
                    end
                end
            end
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MALICE_REFORM) then
            for i = 0, 3 do
                if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_MALICE_REFORM then
                    local charge = player:GetActiveCharge(i)
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_MALICE_REFORM)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_MALICE, charge, false, i, 0)
                end
            end
        end

        if data.MaliceDashing or data.MaliceSplit or data.MaliceReforming then
            player:SetColor(Color(1, 1, 1, 0, 1, 1, 1), 2, 999, false, false)
            player.Visible = false
            local challenge = game.Challenge
            game.Challenge = 6
            player:UpdateCanShoot()
            game.Challenge = challenge
            data.PlayerShootingLocked = true
            data.MaliceHidden = true

            local activeWeapon = player:GetActiveWeaponEntity()
            if activeWeapon then
                activeWeapon:Remove()
            end
        elseif data.PlayerShootingLocked or data.MaliceHidden then
            player.Visible = true
            player:UpdateCanShoot()
            data.MaliceHidden = nil
            data.PlayerShootingLocked = nil
        end

        if data.MaliceSplit then
            if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
                player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
                for _, minion in ipairs(data.MaliceMinions) do
                    if not minion:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
                        minion:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1)
                    end
                end
            end
        end

        if player:GetPlayerType() ~= FiendFolio.PLAYER.BIEND then return end

        local maxHP = player:GetMaxHearts()
        if maxHP > 0 then
            player:AddMaxHearts(-maxHP)
            player:AddBlackHearts(maxHP)
        end

        if player:GetBoneHearts() > 0 then
            player:AddBlackHearts(player:GetBoneHearts() * 2)
            player:AddBoneHearts(-player:GetBoneHearts())
        end

        if player:GetSoulHearts() > 12 then
            player:AddSoulHearts(12 - player:GetSoulHearts())
        end

        for i = 0, 12 do
            if player:IsBlackHeart(i) then
                player:AddBlackHearts(2)
                player:AddSoulHearts(-2)
            end
        end
    end
end)

local isHeartVariant = {
    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_BLENDED_IMMORAL_HEART] = true,
    [PickupVariant.PICKUP_IMMORAL_HEART] = true,
    [PickupVariant.PICKUP_HALF_IMMORAL_HEART] = true,
    [PickupVariant.PICKUP_FIENDFOLIO_HALF_BLACK_HEART] = true,
    [PickupVariant.PICKUP_FIENDFOLIO_BLENDED_BLACK_HEART] = true
}

local blackHeartSubtypes = {
    [HeartSubType.HEART_BLACK] = true,
    [91] = true, -- benighted hearts, rep+
    [100] = true, -- deserted hearts (blended black hearts), rep+
}

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, colliding)
    local player = colliding:ToPlayer()
    if not player then return end

    if player:GetData().MaliceMinion then
        return true
    end

    if player:GetPlayerType() ~= FiendFolio.PLAYER.BIEND or not isHeartVariant[pickup.Variant] then return end

    if player:GetSoulHearts() >= 12
    or (pickup.Variant == PickupVariant.PICKUP_HEART and not blackHeartSubtypes[pickup.SubType])
    or (pickup.Variant ~= PickupVariant.PICKUP_HEART and pickup.Variant ~= PickupVariant.PICKUP_FIENDFOLIO_HALF_BLACK_HEART and pickup.Variant ~= PickupVariant.PICKUP_FIENDFOLIO_BLENDED_BLACK_HEART) then
        if pickup:IsShopItem() then
            return true
        else
            return false
        end
    end
end)

local heldPickups = {
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_TRINKET] = true,
    [PickupVariant.PICKUP_TAROTCARD] = true,
    [PickupVariant.PICKUP_PILL] = true,
}

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function(_, player, colliding)
    local data = player:GetData()
    if data.MaliceHidden then
        if colliding.Type ~= EntityType.ENTITY_PICKUP or ((data.MaliceDashing or data.MaliceReforming) and colliding.Variant == PickupVariant.PICKUP_SHOPITEM) then
            return true
        elseif (data.MaliceDashing or data.MaliceReforming) and heldPickups[colliding.Variant] then
            return false
        end
    end
end)

local function cancelCollision(_, collidesWith, colliding)
    if colliding:GetData().MaliceHidden then
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, cancelCollision)
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, cancelCollision)

function mod:useMalice(item, rng, player)
    if player.Variant ~= 0 then return end

    if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    end


    local data = player:GetData()
    if not data.MaliceReforming then
        if not data.MaliceDashing and not data.MaliceSplit then
            data.MaliceDashing = player:GetHeadDirection()
            sfx:Play(mod.Sounds.FireballLaunch, 0.4, 0, false, math.random(90, 110)/100)
        elseif data.MaliceSplit then
            data.MaliceSplit = false
            data.MaliceReforming = true
            local allHadHolyMantle = true
            for i, minion in ipairs(data.MaliceMinions) do
                minion.Velocity = Vector.Zero

                if not minion:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
                    allHadHolyMantle = false
                end

                minion:GetData().NoDeathEffects = true
                minion:Die()

                local minionBall = Isaac.Spawn(FiendFolio.FF.BallOfMinion.ID, FiendFolio.FF.BallOfMinion.Var, FiendFolio.FF.BallOfMinion.Sub, minion.Position, Vector.Zero, player)
                minionBall.Parent = player
                data.MaliceMinions[i] = minionBall
            end

            if allHadHolyMantle then
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useMalice, CollectibleType.COLLECTIBLE_MALICE)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useMalice, CollectibleType.COLLECTIBLE_MALICE_REFORM)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
    cancelAllMaliceEffects(player)
end, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, useFlags)
    if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
        player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) -- idiot
    end

    local data = player:GetData()
    data.MaliceDashing = player:GetHeadDirection()
    data.Reverse3FireballsDash = true
    data.Reverse3FireballsDashCount = 4
    sfx:Play(mod.Sounds.FireballLaunch, 0.4, 0, false, math.random(90, 110)/100)

    if data.MaliceSplit or data.MaliceReforming then
        data.MaliceSplit = false
        data.MaliceReforming = false
        if data.MaliceMinions then
            for i, minion in ipairs(data.MaliceMinions) do
                minion.Velocity = Vector.Zero
                minion:GetData().NoDeathEffects = true
                minion:Die()
            end
        end
    end

    FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardThreeFireballsBiend, useFlags, 20)
end, FiendFolio.ITEM.CARD.REVERSE_3_FIREBALLS)

function mod:useMegaMushMalice(item, rng, player)
    if player.Variant ~= 0 then return end
    local data = player:GetData()

    if data.MaliceHidden then
        cancelAllMaliceEffects(player)
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.useMegaMushMalice, CollectibleType.COLLECTIBLE_MEGA_MUSH)

function mod:ballOfMaliceAI(effect)
    if effect.SubType ~= FiendFolio.FF.BallOfMalice.Sub and effect.SubType ~= FiendFolio.FF.BallOfMinion.Sub then return end

    if not effect.Parent or not effect.Parent:Exists() then
        if not effect:GetData().HatredHijacked or effect:GetSprite():IsFinished() then
            effect:Remove()
        end
        return
    end

    local parentData = effect.Parent:GetData()
    local sprite = effect:GetSprite()

    if effect.SubType == FiendFolio.FF.BallOfMinion.Sub then
        if not parentData.MaliceReforming then
            effect:Remove()
        end

        if effect.FrameCount % 3 == 1 then
            local creep = Isaac.Spawn(1000, 45, 0, effect.Position, Vector.Zero, effect):ToEffect()
            creep.Scale = 0.5
            creep:SetTimeout(10)
            creep:Update()
        end

        if sprite:IsPlaying("Idle") or sprite:WasEventTriggered("Transformed") then
            local dist = effect.Parent.Position:Distance(effect.Position)
            local speed = math.min(dist, mod:Lerp(2, 15, math.min(effect.FrameCount, 30) / 30))
            effect.Velocity = (effect.Parent.Position - effect.Position):Resized(speed)
        else
            effect.Velocity = Vector.Zero
        end

        if sprite:IsFinished() then
            sprite:Play("Idle", true)
        end

        return
    end

    if parentData.MaliceDashing and parentData.MaliceProjectile and (GetPtrHash(parentData.MaliceProjectile) == GetPtrHash(effect)) then
        local currentDirection = "Down"
        local currentFlip = false
        if math.abs(effect.Velocity.X) > math.abs(effect.Velocity.Y) then
            currentDirection = "Hori"
            if effect.Velocity.X < 0 then
                currentFlip = true
            end
        elseif effect.Velocity.Y < 0 then
            currentDirection = "Up"
        end

        local anim = sprite:GetAnimation()
        local isAppearing
        if string.sub(anim, 1, 6) == "Appear" then
            isAppearing = true
        end

        if isAppearing then
            if sprite:IsFinished() then
                sprite:Play(currentDirection, true)
            else
                sprite:SetAnimation("Appear" .. currentDirection, false)
            end
        else
            sprite:SetAnimation(currentDirection, false)
        end

        effect.FlipX = currentFlip
    else
        effect.Velocity = Vector.Zero
        if sprite:IsFinished("Poof") then
            parentData.MaliceProjectile = nil
            effect:Remove()
            return
        elseif not sprite:IsPlaying("Poof") then
            sprite:Play("Poof", true)
        end
    end
end

function mod:ballOfMaliceRender(effect)
    if effect.Parent and effect.Parent:GetData().MaliceDashing then
        effect.Parent.Position = effect.Position
        effect.Parent.Velocity = effect.Velocity
    end
end

function mod:maliceMinionGhostAI(effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()

    if not data.Init then
        effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:Play("Death", true)
        sprite:PlayOverlay("Head" .. tostring(math.random(1, 4) .. "Death"), true)
        data.Init = true
    elseif effect:GetSprite():IsFinished() then
        effect:Remove()
    end
end

-- shrink malice minion tears
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if tear.FrameCount < 1 and tear.Parent then
        if tear.Parent:GetData().MaliceMinion then
            local parentPlayer = tear.Parent.Parent
            if parentPlayer and parentPlayer:ToPlayer() and parentPlayer:GetData().MaliceMinions then
                local minionCount = #parentPlayer:GetData().MaliceMinions
                tear:SetKnockbackMultiplier(1 / (minionCount * 1.5))
            else
                tear:SetKnockbackMultiplier(0.5)
            end
            tear.Scale = tear.Scale * 0.75

            local hat = tear.Parent:GetData().Hat
            if hat and hat.TearSize then
                tear.Scale = tear.Scale * hat.TearSize
            end
        end
	end
end)

local function killMinion(ent, damage, flags)
    local parentPlayer = ent.Parent:ToPlayer()
    if ent.Type == EntityType.ENTITY_PLAYER then
        local otherMinions = parentPlayer:GetData().MaliceMinions
        for _, minion in ipairs(otherMinions) do
            minion:SetMinDamageCooldown(30)
        end
        
        ent:Die()
    end

    mod.scheduleForUpdate(function()
        if sfx:IsPlaying(SoundEffect.SOUND_ISAAC_HURT_GRUNT) then
            sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
            sfx:Play(mod.Sounds.BiendHurt, 0.8, 0, false, 1.5)
        end
    end, 1)

    local soulHP = parentPlayer:GetSoulHearts()
    if damage >= soulHP then
        damage = soulHP - 1
    end

    parentPlayer:AddSoulHearts(-damage)
end

function mod:biendHurt(ent, damage, flags)
    if ent:GetData().MaliceMinion then
        if damage > 0 and flags & DamageFlag.DAMAGE_FAKE == 0 then
            killMinion(ent, damage, flags)
        end
    elseif ent:GetData().MaliceHidden then
        if (flags & (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE)) ~= 0 then
            local data = ent:GetData()
            if data.MaliceSplit and data.MaliceMinions and #data.MaliceMinions > 0 then
                killMinion(data.MaliceMinions[math.random(1, #data.MaliceMinions)], damage, flags)
                return false
            else
                return
            end
        else
            return false
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, item, rng, player)
    if player:GetData().MaliceMinion then
        return true
    end
end)

local function nullifyAction(hook)
    if hook == InputHook.GET_ACTION_VALUE then
        return 0
    else
        return false
    end
end

local minionBlacklistedActions = {
    [ButtonAction.ACTION_LEFT] = true,
    [ButtonAction.ACTION_RIGHT] = true,
    [ButtonAction.ACTION_UP] = true,
    [ButtonAction.ACTION_DOWN] = true,
    [ButtonAction.ACTION_BOMB] = true,
}

local dashingPlayerWhitelistedActions = {
    [ButtonAction.ACTION_LEFT] = true,
    [ButtonAction.ACTION_RIGHT] = true,
    [ButtonAction.ACTION_UP] = true,
    [ButtonAction.ACTION_DOWN] = true,
}

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
    if entity and entity.Type == 1 and not mod.IsForcingUnpause(hook, action) then
        local data = entity:GetData()
        if data.MaliceMinion then
            if minionBlacklistedActions[action] then
                return nullifyAction(hook)
            end
        elseif data.MaliceDashing or data.MaliceReforming then
            if not dashingPlayerWhitelistedActions[action] then
                return nullifyAction(hook)
            end
        end
    end
end)

local function spawnMinionBomb(minion, player, bomb, newFilename, anim, frame, damage)
    local newBomb
    if bomb.Variant == BombVariant.BOMB_ROCKET or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA then
        newBomb = minion:FireBomb(minion.Position, player:GetShootingInput(), player)
        newBomb.Color = Color.Default
    else
        newBomb = Isaac.Spawn(EntityType.ENTITY_BOMB, bomb.Variant, 0, minion.Position, bomb.Velocity, player):ToBomb()
    end

    newBomb:SetSize(12, Vector.One, 12)
    newBomb.Flags = bomb.Flags
    newBomb:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
    newBomb:GetData().MaliceSplit = true
    newBomb.RadiusMultiplier = 0.75
    newBomb.ExplosionDamage = damage

    if newFilename then
        newBomb:Update()
        local sprite = newBomb:GetSprite()
        sprite:Load(newFilename, true)
        sprite:Play(anim, true)
        sprite:SetFrame(frame)
    end
end

function mod:malicePostFireBomb(player, bomb)
    if player:GetData().MaliceSplit and not bomb:GetData().MaliceSplit then
        local minions = player:GetData().MaliceMinions

        local oldSprite = bomb:GetSprite()
        local anim, frame = oldSprite:GetAnimation(), oldSprite:GetFrame()
        local filename = oldSprite:GetFilename()
        local newFilename
        local size = tonumber(string.sub(filename, -6, -6))
        if size then
            local preSize = string.sub(filename, 1, -7)
            newFilename = preSize .. "1.anm2"
        end

        local damage = bomb.ExplosionDamage
        local numMinions = #minions
        damage = damage / numMinions

        if numMinions ~= 1 then -- slightly buff damage for multiple minions
            damage = damage * (1 + ((numMinions ^ 0.33) / 12))
        end

        for _, minion in ipairs(minions) do
            if minion:GetData().Leader then
                spawnMinionBomb(minion, player, bomb, newFilename, anim, frame, damage)
            else
                mod.scheduleForUpdate(function()
                    spawnMinionBomb(minion, player, bomb, newFilename, anim, frame, damage)
                end, math.random(0, 4), ModCallbacks.MC_POST_UPDATE, false)
            end
        end

        bomb:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetData().MaliceMinion then
            local sprite = player:GetSprite()
            sprite:Load("gfx/familiar/biend/malice_minion.anm2", true)
            player.Position = player.Parent.Position + RandomVector() * 20
            player:GetData().DelayedAnim = "Appear"
            player:GetData().AnimDelay = 0
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetData().MaliceSplit or player:GetData().MaliceDashing then
            player:GetData().MaliceHits = nil
            player.Visible = false
        elseif player:GetData().MaliceMinion then
            player.Visible = true
        elseif player:GetData().MaliceReforming then
            local data = player:GetData()
            data.MaliceReforming = nil
            data.MaliceMinions = nil
            local poof = Isaac.Spawn(FiendFolio.FF.BallOfMalice.ID, FiendFolio.FF.BallOfMalice.Var, FiendFolio.FF.BallOfMalice.Sub, player.Position, Vector.Zero, player)
            poof.Parent = player
            poof:GetSprite():Play("Poof", true)
            player.Visible = true
            player:UpdateCanShoot()
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for k, v in pairs(recentDeadMinions) do
        v[2] = v[2] - 1
        if v[2] <= 0 then
            recentDeadMinions[k] = nil
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player, offset)
    local data = player:GetData()
    if data.MaliceMinion then
        if data.Leader then
            local playerParent = player.Parent:ToPlayer()
            if playerParent then
                local pSprite = playerParent:GetSprite()
                local anim = pSprite:GetAnimation()
                if playerPickupAnims[anim] then
                    local oldFrame = pSprite:GetFrame()
                    pSprite:SetAnimation("HoleDeath", false)
                    pSprite:SetFrame(0)
                    playerParent.Visible = true
                    playerParent:Render(offset + Vector(0, 10))
                    playerParent.Visible = false
                    pSprite:SetAnimation(anim, false)
                    pSprite:SetFrame(oldFrame)
                end
            end
        end
        
        if data.Hat and data.CanRenderHat then
            if not data.HatSprite then
                local hatSheet = "gfx/familiar/biend/hats/" .. data.Hat.Sprite .. ".png"
                data.HatSprite = Sprite()
                data.HatSprite:Load("gfx/familiar/biend/hats/hat.anm2", false)
                data.HatSprite:ReplaceSpritesheet(0, hatSheet)
                data.HatSprite:LoadGraphics()
            end

            local playerSprite = player:GetSprite()
            data.HatSprite:SetFrame(playerSprite:GetOverlayAnimation(), playerSprite:GetOverlayFrame())
            data.HatSprite:Render(game:GetRoom():WorldToScreenPosition(player.Position) + (data.Hat.Offset or Vector.Zero) + Vector(0, 0.5), Vector.Zero, Vector.Zero)
        end
    end
end)

local minionCounterSprite = Sprite()
minionCounterSprite:Load("gfx/ui/biend_counter.anm2", true)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.POST_RENDER_HP_BAR, 0, function(player, playerSlot, renderOffset)
	local data = player:GetData()
	if data.MaliceSplit and playerSlot ~= CustomHealthAPI.Enums.PlayerSlot.STRAWMAN then
		local numMinions = #data.MaliceMinions
		if numMinions > 6 then
			minionCounterSprite:Play("x6+", true)
		else
			minionCounterSprite:Play("x" .. numMinions, true)
		end

		if numMinions == 1 then
			local regularColor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
			local dangerPulseColorHigh = Color(1.0, 1.0, 1.0, 1.0, 255/255, 0/255, 0/255)
			local dangerPulseColor = Color.Lerp(regularColor, dangerPulseColorHigh, math.max(0, ((Game():GetFrameCount() % 45) - 9) / 9 * -1))

			minionCounterSprite.Color = dangerPulseColor
		else
			minionCounterSprite.Color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		end

		CustomHealthAPI.Helper.RenderHealth(minionCounterSprite, player, playerSlot, 6, renderOffset, 6, Vector(-0.5, 0))
	end
end)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HOLY_MANTLE, 0, function(player, index)
	if player:GetPlayerType() == FiendFolio.PLAYER.BIEND and index >= 6 then
		return {Index = 5, Offset = Vector(CustomHealthAPI.Constants.HEART_PIXEL_WIDTH_DEFAULT / 2, 0)}
	elseif player:GetData().MaliceMinion then
		return {Index = 0, Offset = Vector(-4.5, 0)}
	end
end)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_UNKNOWN_CURSE, 0, function(player, index)
	if player:GetData().MaliceMinion then
		return true
	end
end)

CustomHealthAPI.Library.AddCallback("FiendFolio", CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH, 0, function(player, key)
	if player:GetPlayerType() == FiendFolio.PLAYER.BIEND and player:GetSoulHearts() >= 12 then
		return false
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, var, sub, pos, vel, spawner, seed)
    if id == EntityType.ENTITY_EFFECT and var == EffectVariant.POOF01 then
        local delete
        for k, minion in pairs(recentDeadMinions) do
            local mPos = minion[1]
            if pos:DistanceSquared(Vector(mPos.X, mPos.Y - 10)) < 2 ^ 2 then
                recentDeadMinions[k] = nil
                delete = true
                break
            end
        end

        if delete then
            if sfx:IsPlaying(SoundEffect.SOUND_ISAACDIES) then
                sfx:Stop(SoundEffect.SOUND_ISAACDIES)
            end

            return {
                StageAPI.E.DeleteMeEffect.T,
                StageAPI.E.DeleteMeEffect.V,
                0
            }
        end
    end
end)