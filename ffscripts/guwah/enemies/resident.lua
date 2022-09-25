local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local beanRadius = 125

mod.ResidentItems = {
    c38 = {useType = "onShoot", recharge = 180}, --Tammy's Head
    c42 = {useType = "onShoot", recharge = 240}, --Bob's Rotten Head
    c56 = {useType = "proximity", recharge = 300, proximityRadius = 100}, --Lemon Mishap
    c58 = {useType = "onHurt"}, --Book of Shadows
    c83 = {useType = "firstChance", initWait = 15}, --The Nail
    c107 = {useType = "firstChance", initWait = 15}, --The Pinking Shears
    c145 = {useType = "firstChance", initWait = 30}, --Guppy's Head
    c160 = {useType = "firstChance", initWait = 30}, --Crack the Sky 
    c282 = {useType = "jumping", recharge = 60}, --How to Jump
    c288 = {useType = "proximity", proximityRadius = 150}, --Box of Spiders
    c289 = {useType = "onShoot", recharge = 60}, --Red Candle
    c294 = {useType = "proximity", recharge = 30, proximityRadius = beanRadius}, --Butter Bean
    c687 = {useType = "firstChance", initWait = 15}, --Friend Finder
    c1001 = {useType = "onHurt"}, --iPad
    c1002 = {useType = "spam"}, --A.V.G.M.
}

mod.ResidentRandom = {38, 42, 56, 58, 145, 282, 288, 289, 294}
mod.DwellerFriendRandom = {2, 3, 6, 169, 224}

function mod:ResidentAI(npc, sprite, d)
    local target = npc:GetPlayerTarget()
    local room = game:GetRoom()
    if not d.init then
        d.state = "walking"
        if npc.SubType == mod.FF.ResidentRandom.Sub then
            npc.SubType = mod:GetRandomElem(mod.ResidentRandom)
        end
        d.stats = mod.ResidentItems["c"..npc.SubType]
        if d.stats then
            d.useType = d.stats.useType
            if d.useType == "spam" then
                d.state = "spam"
            end
            d.proximityRadius = d.stats.proximityRadius or 100
            if d.stats.initWait then
                d.recharge = mod:RandomInt(3, d.stats.initWait)
            elseif d.stats.recharge then
                d.recharge = 0
            end
            if npc.SubType > mod.FF.ResidentRandom.Sub then
                if npc.SubType == mod.FF.ResidentIPad.Sub then
                    sprite:ReplaceSpritesheet(2, "gfx/items/collectibles/ipad.png")
                elseif npc.SubType == mod.FF.ResidentAVGM.Sub then
                    sprite:ReplaceSpritesheet(2, "gfx/items/collectibles/collectibles_avgm.png")
                end
            else
                sprite:ReplaceSpritesheet(2, Isaac.GetItemConfig():GetCollectible(npc.SubType).GfxFileName)
            end
            sprite:LoadGraphics()
        end
        d.headnum = 0
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end
    --Item use
    if d.state == "itemuse" then
        if not sprite:WasEventTriggered("DownItem") then
            sprite:RemoveOverlay()
        end
        if sprite:IsFinished("Pickup"..d.headnum) then
            d.state = "walking"
        elseif sprite:IsEventTriggered("Item") then
            if npc.SubType == CollectibleType.COLLECTIBLE_THE_NAIL or npc.SubType == CollectibleType.COLLECTIBLE_FRIEND_FINDER then
                mod:ResidentItemEffect(npc, target, d)
                d.diditalready = true
            else
                npc:PlaySound(SoundEffect.SOUND_POWERUP1,0.6,0,false,math.random(80,90)/100)
            end
        elseif sprite:IsEventTriggered("DownItem") then
            if d.diditalready then
                sprite:SetOverlayFrame("Head" .. d.headnum, 0)
            else
                local direction = mod:ResidentItemEffect(npc, target, d)
                if direction then
                    sprite:SetOverlayFrame("Head" .. d.headnum, direction * 2)
                end
            end
            d.diditalready = false
            d.firing = false
        else
            mod:spritePlay(sprite, "Pickup"..d.headnum)
        end
        npc.Velocity = npc.Velocity * 0.8
    --Jumping
    elseif d.state == "jumping" then
        sprite:RemoveOverlay()
        if sprite:IsEventTriggered("Jump") then
            npc.Velocity = d.jumpVec
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        elseif sprite:IsEventTriggered("Land") then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        end
        if sprite:WasEventTriggered("Stop") then
            npc.Velocity = npc.Velocity * 0.7
        else
            npc.Velocity = npc.Velocity * 0.9
        end
        if sprite:IsFinished("Jump") then
            d.state = "walking"
        else
            mod:spritePlay(sprite, "Jump")
        end
    --Spam
    elseif d.state == "spam" then
        if sprite:IsEventTriggered("Item") then
            mod:ResidentItemEffect(npc, target, d)
        end
        mod:spritePlay(sprite, "Spam")
        npc.Velocity = npc.Velocity * 0.65
    --Walking
    elseif d.state == "walking" then

        --Target checking
        local distanceclose = 150
        local checkangle = 20

        --Stats
        local movespeed = 4
        local gridthreshold = 0
        if d.isDemon then
            movespeed = movespeed * 0.82
            gridthreshold = 2
            distanceclose = -100 --Nail-transformed Residents will never try to back away from the player. Charge!!!
            for _, grid in ipairs(mod.GetGridEntities()) do
                if grid.Position:Distance(npc.Position + npc.Velocity) < 45 then
                    if grid.Desc.Type ~= GridEntityType.GRID_DOOR then
                        grid:Destroy()
                    end
                end
            end
        end
        local firerate = 10
        local shotspeed = 8

        --Status Effects
        if mod:isConfuse(npc) then
            if math.random(2) == 1 then
                movespeed = movespeed * -1
            end
            if math.random(3) == 1 then
                movespeed = movespeed * 2.5
            end
        end

        --Targeting
        local targpos = mod:confusePos(npc, target.Position, 30)
        local targdistance = mod:reverseIfFear(npc,targpos - npc.Position)
        local targrel = mod:GetResidentDirection(npc, target, true)

        local targetpos = target.Position
        local distanceabs = npc.Position:Distance(targetpos)

        if distanceabs < distanceclose and room:CheckLine(npc.Position,targetpos,0,3,false,false) and not mod:isScare(npc)  then
            local extravec = 0
            if distanceabs < 100 then
                extravec = distanceabs / 3
            end

            local tpa = target.Position
            if targrel == 0 then
                tpa = target.Position + Vector((target.Position.X - npc.Position.X), -distanceabs - extravec)
            elseif targrel == 1 then
                tpa = target.Position + Vector(-distanceabs - extravec, (target.Position.Y - npc.Position.Y))
            elseif targrel == 2 then
                tpa = target.Position + Vector((target.Position.X - npc.Position.X), distanceabs + extravec)
            elseif targrel == 3 then
                tpa = target.Position + Vector(distanceabs + extravec, (target.Position.Y - npc.Position.Y))
            end

            if npc.Position:Distance(tpa) > 10 then
                d.targetvelocity = (tpa - npc.Position):Resized(movespeed)
                npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
            else
                npc.Velocity = npc.Velocity * 0.8
            end

        else
            if mod:isScare(npc) then
                d.targetvelocity = (targetpos - npc.Position):Resized(movespeed * -1.5)
                npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)

            elseif room:CheckLine(npc.Position,targetpos,gridthreshold,1,false,false) or d.noBody then
                d.targetvelocity = (targetpos - npc.Position):Resized(movespeed)
                npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)

            elseif npc.Pathfinder:HasPathToPos(targetpos, false) then
                mod:CatheryPathFinding(npc, targetpos, {
                    Speed = movespeed,
                    Accel = 0.2,
                    Interval = 1,
                    GiveUp = true
                 })
            else
                local targvec = Vector(npc.Position.X, targetpos.Y)
                if targrel == 2 or targrel == 0 then
                    targvec = Vector(targetpos.X, npc.Position.Y)
                end
                d.targetvelocity = (targvec - npc.Position):Resized(movespeed)
                npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
            end
        end

        if d.noBody then
            mod:spritePlay(sprite, "NoBody")
        else
            if npc.Velocity:Length() > 0.1 then
                if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
                    mod:spritePlay(sprite, "WalkVert"..d.headnum)
                else
                    if npc.Velocity.X > 0 then
                        mod:spritePlay(sprite, "WalkRight"..d.headnum)
                    else
                        mod:spritePlay(sprite, "WalkLeft"..d.headnum)
                    end
                end
            else
                sprite:SetFrame("WalkVert"..d.headnum, 0)
            end
        end
        
        d.IWishICouldshoot = false
        if not d.firing then
            d.headway = targrel * 2
            sprite:SetOverlayFrame("Head" .. d.headnum, d.headway)
            if room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
                if (math.abs(targdistance.X) < checkangle or math.abs(targdistance.Y) < checkangle) then
                    if npc.StateFrame > firerate then
                        d.direction = targrel
                        d.firing = true
                        npc.StateFrame = 0
                    end
                    d.IWishICouldshoot = true
                end
            end
        elseif d.firing then
            sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2 + 1)
            if npc.StateFrame == 1 then
                local shootpos = npc.Position + Vector(0,shotspeed):Rotated(-d.direction * 90)
                local shootvec = Vector(0,shotspeed):Rotated(-d.direction * 90) + (npc.Velocity/3)
                local willShoot = true
                if d.useType == "onShoot" then
                    willShoot = not mod:TryUseResidentItem(npc, d)
                end
                if willShoot then
                    local params = ProjectileParams()
                    if d.isDemon then
                        params.Scale = params.Scale * 1.75
                    end
                    npc:FireProjectiles(shootpos, shootvec, 0, params)
                    npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.9,0,false,0.9)
                end
            end
            if npc.StateFrame > firerate / 2 then
                d.firing = false
                npc.StateFrame = 0
            end
        end

        if d.recharge then
            d.recharge = d.recharge - 1
        end
        if d.useType == "firstChance" then
            mod:TryUseResidentItem(npc, d)
        elseif d.useType == "proximity" and distanceabs < d.proximityRadius then
            mod:TryUseResidentItem(npc, d)
        elseif d.useType == "jumping" and mod:RandomInt(1,15) == 1 then
            mod:TryUseResidentItem(npc, d)
        end
        if npc.SubType == CollectibleType.COLLECTIBLE_BUTTER_BEAN then
            local bomb = mod:GetNearestThing(npc.Position, 4)
            if bomb and bomb.Position:Distance(npc.Position) < beanRadius then
                mod:TryUseResidentItem(npc, d)
            end
        end
    end
end

function mod:ResidentHurt(npc, amount, damageFlags, source)
    local d = npc:GetData()
    if d.isShielded then
        return false
    elseif d.useType == "onHurt" then
        mod:TryUseResidentItem(npc, d)
    end
end

function mod:GetResidentDirection(npc, target, checkFear)
    local targpos = mod:confusePos(npc, target.Position, 30)
    local targdistance = targpos - npc.Position
    if checkFear then
        targdistance = mod:reverseIfFear(npc, targpos - npc.Position)
    end
    local targrel 
    if math.abs(targdistance.X) > math.abs(targdistance.Y) then
        if targdistance.X < 0 then
            targrel = 3 -- Left
        else
            targrel = 1 -- Right
        end
    else
        if targdistance.Y < 0 then
            targrel = 2 -- Up
        else
            targrel = 0 -- Down
        end
    end
    return targrel
end

function mod:TryUseResidentItem(npc, d)
    local mayI = false
    if d.recharge then
        if d.recharge <= 0 then
            mayI = true
            d.recharge = d.stats.recharge
        end
    elseif not d.usedIt then
        mayI = true
    end
    if mayI then
        d.state = "itemuse"
        d.usedIt = true
        if npc.SubType == CollectibleType.COLLECTIBLE_THE_NAIL then
            d.headnum = CollectibleType.COLLECTIBLE_THE_NAIL
        end
    end
    return mayI
end

function mod:ResidentItemEffect(npc, target, d)
    local item = npc.SubType
    local direction = mod:GetResidentDirection(npc, target)
    local returndir = 0
    if item == CollectibleType.COLLECTIBLE_TAMMYS_HEAD then --Tammy's Head
        local params = ProjectileParams()
        params.Scale = 1.8
        npc:FireProjectiles(npc.Position, Vector(8,10), 9, params)
    elseif item == CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD then --Bob's Rotten Head
        local bomb = Isaac.Spawn(9, 8, 0, npc.Position, Vector(0,12):Rotated(-direction * 90), npc)
        local sprite = bomb:GetSprite()
        sprite:Load("gfx/002.004_bobs head tear.anm2", true)
        sprite:Play("Idle")
        bomb:GetData().projType = "bobsRottenHead"
        bomb:Update()
        returndir = direction
    elseif item == CollectibleType.COLLECTIBLE_LEMON_MISHAP then --Lemon Mishap
        npc:PlaySound(SoundEffect.SOUND_GASCAN_POUR,1,0,false,1.2)
        local creep = Isaac.Spawn(mod.FF.LemonMishapEnemy.ID,mod.FF.LemonMishapEnemy.Var,mod.FF.LemonMishapEnemy.Sub,npc.Position,Vector.Zero,npc):ToEffect()
        creep:SetTimeout(300)
        creep:Update()
    elseif item == CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS then --Book of Shadows
        local shield = Isaac.Spawn(mod.FF.ShadowShield.ID,mod.FF.ShadowShield.Var,mod.FF.ShadowShield.Sub,npc.Position,Vector.Zero,npc):ToEffect()
        shield:FollowParent(npc)
        shield.ParentOffset = Vector(0,1)
        shield:SetTimeout(150)
        d.isShielded = true
    elseif item == CollectibleType.COLLECTIBLE_THE_NAIL then --The Nail
        npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A,0.6,0,false,0.8)
        local poof = Isaac.Spawn(1000,15,0,npc.Position,Vector.Zero,npc)
        poof.Color = mod.ColorDankBlackReal
        d.isDemon = true
        npc.MaxHitPoints = npc.MaxHitPoints + 5
        npc.HitPoints = npc.HitPoints + 5
        npc.CollisionDamage = math.max(npc.CollisionDamage, 2)
    elseif item == CollectibleType.COLLECTIBLE_PINKING_SHEARS then --The Pinking Shears
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        d.noBody = true
        local body = Isaac.Spawn(mod.FF.ResidentBody.ID, mod.FF.ResidentBody.Var, 0, npc.Position + Vector(0,10), Vector.Zero, npc):ToNPC()
        body:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if npc:IsChampion() then
            body:MakeChampion(69, npc:GetChampionColorIdx(), true)
            body.HitPoints = body.MaxHitPoints
        end
        local vec = RandomVector()
        Isaac.Spawn(1000,15,0,npc.Position,Vector.Zero,npc)
        Isaac.Spawn(1000,2,2,npc.Position,vec:Resized(10),npc)
        for i = 1, mod:RandomInt(2,4) do
            Isaac.Spawn(1000,5,0,npc.Position,vec:Resized(mod:RandomInt(8,16)):Rotated(mod:RandomInt(-20,20)),npc)
        end
        npc:PlaySound(SoundEffect.SOUND_BLOODBANK_SPAWN,1.3,0,false,0.8)
    elseif item == CollectibleType.COLLECTIBLE_GUPPYS_HEAD then --Guppy's Head
        local max = mod:RandomInt(3,5)
        for i = 1, max do
            local vec = Vector.One:Rotated((360/max) * i)
            local fly = Isaac.Spawn(18, 0, 0, npc.Position + vec:Resized(15), vec:Resized(4), npc)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    elseif item == CollectibleType.COLLECTIBLE_CRACK_THE_SKY then --Crack The Sky
        table.insert(mod.SkyCrackins, {Count = 30, Spawner = npc})
    elseif item == CollectibleType.COLLECTIBLE_HOW_TO_JUMP then
        local targetpos = mod:confusePos(npc, target.Position)
        local endpoint = mod:GetResidentJumpPos(npc, targetpos)
        d.jumpVec = (endpoint - npc.Position)/7
        d.state = "jumping"
    elseif item == CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS then --Box of Spiders
        for i = 1, mod:RandomInt(2,4) do
            EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + RandomVector():Resized(40,80), false, -5)
        end
    elseif item == CollectibleType.COLLECTIBLE_RED_CANDLE then --Red Candle
        Isaac.Spawn(33, 10, 0, npc.Position, Vector(0,12):Rotated(-direction * 90), npc)
        returndir = direction
    elseif item == CollectibleType.COLLECTIBLE_BUTTER_BEAN then --Butter Bean
        game:ButterBeanFart(npc.Position, beanRadius, npc, true, false)
        for _, tear in pairs(Isaac.FindInRadius(npc.Position, beanRadius * 1.2, EntityPartition.TEAR)) do
            tear.Velocity = (tear.Position - npc.Position):Resized(math.max(8, tear.Velocity:Length()))
        end
    elseif item == CollectibleType.COLLECTIBLE_FRIEND_FINDER then --Friend Finder
        local friend = Isaac.Spawn(mod.FF.DwellerRandom.ID, mod.FF.DwellerRandom.Var, mod:GetRandomElem(mod.DwellerFriendRandom), npc.Position, Vector.Zero, npc)
        friend:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        friend.Parent = npc
        local fdata = friend:GetData()
        fdata.walking = false
        fdata.init = true
        fdata.stats = {}
        fdata.itemget = true
        fdata.synced = true
        fdata.checkeditem = true
        fdata.headnum = 0
        local fsprite = friend:GetSprite()
        fsprite:ReplaceSpritesheet(2, mod.DwellerItems["c" .. friend.SubType][1])
        fsprite:LoadGraphics()
        Isaac.Spawn(1000,15,0,friend.Position,Vector.Zero,friend)
        sfx:Play(SoundEffect.SOUND_SUMMON_POOF)
        npc:PlaySound(SoundEffect.SOUND_POWERUP1,0.6,0,false,math.random(80,90)/100)
    elseif item == mod.FF.ResidentIPad.Sub then --iPad
        local room = game:GetRoom()
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if (entity:IsEnemy() or entity:ToPlayer()) and entity.InitSeed ~= npc.InitSeed then
                entity.Position = Vector(entity.Position.X, room:GetGridHeight() * 50)
            end
        end
    elseif item == mod.FF.ResidentAVGM.Sub then --A.V.G.M.
        d.AVGMnext = d.AVGMnext or 2
        d.AVGMuses = d.AVGMuses or 0
        d.AVGMoveralluses = d.AVGMoveralluses or 0
        d.AVGMTarget = d.AVGMTarget or 1
        d.AVGMuses = d.AVGMuses + 1
        d.AVGMoveralluses = d.AVGMoveralluses + 1
        if d.AVGMoveralluses % 2 == 1 then
            game:Darken(1,1000)
            sfx:Play(mod.Sounds.LightSwitch,1,0,false,0.9)
        else
            game:Darken(0,1)
            sfx:Play(mod.Sounds.LightSwitch,1,0,false,1.1)
        end
        if d.AVGMuses >= d.AVGMnext then
			Isaac.Spawn(5,20,213,npc.Position+RandomVector()*40,npc.Velocity,npc)
            d.AVGMnext = d.AVGMnext + (2 * d.AVGMTarget)
            d.AVGMuses = 0
		end
    end
    return returndir
end

function mod:BobsRottenHeadDeath(projectile, data)
    game:BombExplosionEffects(projectile.Position, 100, 0, mod.ColorBobsGreen, projectile, 1, true, true, DamageFlag.DAMAGE_EXPLOSION)
    local effect1 = Isaac.Spawn(1000, 2, 4, projectile.Position, Vector.Zero, projectile)
    effect1.Color = mod.ColorBobsGreen
    local effect2 = Isaac.Spawn(1000, 7, 0, projectile.Position, Vector.Zero, projectile)
    effect2.Color = mod.ColorBobsGreen
    effect2.SpriteScale = effect2.SpriteScale * 1.2
    local cloud = Isaac.Spawn(1000, 141, 0, projectile.Position, Vector.Zero, projectile):ToEffect()
    cloud:SetTimeout(150)
end

function mod:CrackingTheSky(beams)
    if beams.Count < 0 then
        beams = nil
    else
        beams.Count = beams.Count - 1
        if beams.Count % 5 == 0 then
            local pos = Isaac.GetRandomPosition()
            if rng:RandomInt(1,2) == 2 then
                pos = game:GetNearestPlayer(pos).Position + RandomVector():Resized(mod:RandomInt(30,80))
            end
            Isaac.Spawn(1000, 19, 2, Isaac.GetFreeNearPosition(pos, 40), Vector.Zero, beams.Spawner)
        end
    end
end

function mod:GetResidentJumpPos(npc, targetpos)
    local room = game:GetRoom()
    local basevec = targetpos - npc.Position
    for i = 300, 0, -20 do
        local testpos = npc.Position + basevec:Resized(i)
        if room:GetGridCollisionAtPos(testpos) <= 0 then
            return testpos
        end
    end
    return npc.Position
end

function mod:ResidentBodyAI(npc, sprite, d)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not d.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:PlayOverlay("BloodGush")
        d.Init = true
    end
    local movespeed = 5
    if mod:isScare(npc) then
        d.targetvelocity = (targetpos - npc.Position):Resized(movespeed * -1.5)
        npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
    elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
        d.targetvelocity = (targetpos - npc.Position):Resized(movespeed)
        npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
    elseif npc.Pathfinder:HasPathToPos(targetpos, false) then
        mod:CatheryPathFinding(npc, targetpos, {
            Speed = movespeed,
            Accel = 0.2,
            Interval = 1,
            GiveUp = true
         })
    else
        local targvec = Vector(npc.Position.X, targetpos.Y)
        d.targetvelocity = (targvec - npc.Position):Resized(movespeed)
        npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
    end
    if npc.Velocity:Length() > 0.1 then
        if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
            mod:spritePlay(sprite, "WalkVert0")
        else
            if npc.Velocity.X > 0 then
                mod:spritePlay(sprite, "WalkRight0")
            else
                mod:spritePlay(sprite, "WalkLeft0")
            end
        end
    else
        sprite:SetFrame("WalkVert0", 0)
    end
    if mod:RandomInt(1,4) == 1 then
        local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
        splat.SpriteScale = splat.SpriteScale * 0.1 * mod:RandomInt(3,6)
    end
end

function mod:LemonMishapEnemyInit(effect)
    effect.SpriteScale = effect.SpriteScale * 0.1
end

function mod:LemonMishapEnemyAI(effect, sprite, data)
    if not data.Init then
        sprite:Play("Idle")
        effect.SpriteScale = effect.SpriteScale * 0.1
        data.Init = true
    end
    if effect.State == 1 then
        if effect.SpriteScale.X < 1 and effect.SpriteScale.Y < 1 then
            effect.SpriteScale = effect.SpriteScale + Vector(0.05,0.05)
            effect.Size = effect.Size + 3
        end
    end
end

function mod:ShadowShieldAI(effect, sprite, data)
    if not data.Init then
        effect.Timeout = effect.Timeout or 150
    end
    if sprite:IsPlaying("Idle") then
        if effect.FrameCount > effect.Timeout then
            sprite:Play("Blink")
        end
    end
    if sprite:IsFinished("Blink") then
        effect.Parent:GetData().isShielded = false
        effect:Remove()
    end
end

--NO MORE ITEMS!!! -The Management