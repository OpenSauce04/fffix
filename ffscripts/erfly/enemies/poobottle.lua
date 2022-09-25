local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.drainerSheets = {
    "monster_drainfly_black",
    "monster_drainfly_gold",
    "monster_drainfly_poop",
    "monster_drainfly_red",
    "monster_drainfly_shampoo",
    "monster_drainfly_white",
    "monster_drainfly_white2",
    "monster_drainfly_honey",
    "monster_drainfly_cursed",
    "monster_drainfly_stone",
    "monster_drainfly_platinum",
    "monster_drainfly_evil",
}

function mod:poobottleAI(npc, subt, variant)
    local sprite = npc:GetSprite();
    local d = npc:GetData();
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()

    local isDrainFly = variant == 561

    if not d.init then
        d.state = "idle"
        d.init = true
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        mod:spritePlay(sprite, "Fly")
        npc.SpriteOffset = Vector(0, -30)
        if mod:isScare(npc) then
            d.state = "flyaway"
            npc.StateFrame = 0
        end
        if d.poop then
            if d.poop.State > 999 then
                d.poop = nil
                npc.StateFrame = 0
            else
                local pooppos = mod:GetPoopPos(d.poop)
                local targetvel = (pooppos - npc.Position):Resized(8)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
                if npc.Position:Distance(pooppos) < 50 then
                    d.state = "targetspotted"
                    npc.StateFrame = 0
                    mod:spritePlay(sprite, "Target")
                    if pooppos.X < npc.Position.X then
                        sprite.FlipX = false
                    else
                        sprite.FlipX = true
                    end
                end
            end
        else
            npc.Velocity = npc.Velocity * 0.9
            local newpoop = mod:FindClosestPoop(npc.Position)
            if newpoop then
                d.poop = newpoop
            else
                if npc.StateFrame > 15 then
                    d.state = "flyaway"
                    npc.StateFrame = 0
                end
            end

        end
    elseif d.state == "targetspotted" then
        if sprite:IsFinished("Target") then
            mod:spritePlay(sprite, "TargetLoop")
        end
        local pooppos = mod:GetPoopPos(d.poop)
        local targetvel = (pooppos - npc.Position):Resized(8)
        npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.2)
        npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -75), 0.1)
        if npc.SpriteOffset.Y < -70 and npc.Position:Distance(pooppos) < 10 then
            d.state = "landhostart"
            d.fallvelocity = nil
            npc.Position = pooppos
        end
    elseif d.state == "landhostart" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("FlyDown") then
            mod:spritePlay(sprite, "Impact")
            d.state = "impact"
        else
            mod:spritePlay(sprite, "FlyDown")
        end
        if sprite:GetFrame() > 16 then
            d.fallvelocity = d.fallvelocity or 8
            d.fallvelocity = d.fallvelocity + 2
            npc.SpriteOffset = Vector(0, math.min(0, npc.SpriteOffset.Y + d.fallvelocity))
        end
    --[[elseif d.state == "landho" then
        mod:spritePlay(sprite, "FlyDownLoop")	--Sorry Jon for this not being used
        d.fallvelocity = d.fallvelocity + 2
        npc.SpriteOffset = Vector(0, math.min(0, npc.SpriteOffset.Y + d.fallvelocity))
        if d.fallvelocity > 6 then
            d.state = "impact"
            Isaac.ConsoleOutput("impacting")
        end]]
    elseif d.state == "impact" then
        npc.Velocity = npc.Velocity * 0.7
        npc.SpriteOffset = Vector(0, math.min(0, npc.SpriteOffset.Y + d.fallvelocity))
        if sprite:IsFinished("Impact") then
            d.state = "dizzy"
            npc.StateFrame = 0
        elseif sprite:GetFrame() == 1 then
            d.randwait = r:RandomFloat() * 20
            npc.SpriteOffset = nilvector
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            if d.poop and d.poop.State ~= 1000 then
                local pooType = d.poop.Desc.Variant
                d.splattedPooType = pooType
                d.splattedPooType2 = mod:CheckForCustomPoop(d.poop:GetGridIndex())
                if isDrainFly then
                    mod:SetDrainflySheet(sprite, d.splattedPooType, d.splattedPooType2)
                end
                for i = 45, 360, 45 do
                    if d.splattedPooType2 == "FFShampoo" then
                        if i % 90 ~= 0 then
                            mod.ShootBubble(npc, 2, npc.Position,Vector(0,6):Rotated(i))
                        end
                    else
                        local params, special = mod:GetPoobottleParams(d.splattedPooType, d.splattedPooType2)
                        params.FallingSpeedModifier = -1 * math.random(10, 30) / 10
                        params.FallingAccelModifier = 0.1
                        if special then
                            mod:SetGatheredProjectiles()
                        end
                        npc:FireProjectiles(npc.Position, Vector(0,6):Rotated(i), 0, params)
                        if special then
                            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                                proj:GetData().projType = special
                            end
                        end
                    end
                end
                d.poop:Hurt(1000)
                if pooType == 1 and isDrainFly then
                    d.poop:ToPoop().ReviveTimer = math.floor((40 + d.randwait) * 2) + 40
                end
                d.zilch = false
            else
                if isDrainFly then
                    sprite:ReplaceSpritesheet(1, "gfx/enemies/drainfly/monster_drainfly_zilch.png")
                    sprite:LoadGraphics()
                end
                d.zilch = true
            end
        else
            mod:spritePlay(sprite, "Impact")
        end
    elseif d.state == "dizzy" then
        npc.Velocity = npc.Velocity * 0.7
        mod:spritePlay(sprite, "Dizzy")
        local mult = 1
        if isDrainFly then
            mult = 2
        end
        local waittime = (40 + d.randwait) * mult
        if d.zilch and isDrainFly then
            waittime = 25
        end
        if npc.StateFrame > waittime then
            d.state = "recover"
            mod:spritePlay(sprite, "Recover")
        end
        if isDrainFly then
            local pooType = d.splattedPooType
            local pooType2 = d.splattedPooType2
            mod:DrainflyProjectiles(npc, pooType, pooType2)
            if npc.StateFrame % 5 == 1 then
                mod:DrainflyCreep(npc, pooType, pooType2)
            end
            if pooType2 == "FFShampoo" then -- regular
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType2 == "FFSpiderNest" then
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType2 == "FFBeehive" then
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType2 == "FFPetrifiedPoop" then
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType == 0 then -- regular
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType == 1 then -- red
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType == 2 then -- corn / charming
                if npc.StateFrame % 30 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType == 4 then --rainbow
                if npc.StateFrame % 15 == 10 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
                if npc.StateFrame % 5 == 0 then
                    sprite:ReplaceSpritesheet(1, "gfx/enemies/drainfly/" .. mod.drainerSheets[math.random(#mod.drainerSheets)] .. ".png")
                    sprite:LoadGraphics()
                end
            elseif pooType == 5 then -- black
                if npc.StateFrame % 30 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType == 6 then -- white
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType and pooType >= 7 and pooType <= 10 then -- giant
                if npc.StateFrame % 50 == 20 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            elseif pooType == 11 then -- charming
                if npc.StateFrame % 15 == 10 then
                    mod:DrainflyEnemySpawn(npc, pooType, pooType2)
                end
            end
        end
    elseif d.state == "recover" then
        if sprite:IsFinished("Recover") then
            d.state = "idle"
        else
            mod:spritePlay(sprite, "Recover")
        end
        if sprite:GetFrame() > 8 then
            npc.Velocity = npc.Velocity * 0.9
            npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -30), 0.1)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            if npc.SpriteOffset.Y < -25 then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
        else
            npc.Velocity = npc.Velocity * 0.7
        end
    elseif d.state == "flyaway" then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        d.vec = d.vec or RandomVector()*15
        npc.Velocity = mod:Lerp(npc.Velocity, d.vec, 0.03)
        npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -100), 0.02)
        d.ColorVal = d.ColorVal or 1
        d.ColorVal = mod:Lerp(d.ColorVal, 0, 0.02)
        npc.Color = Color(d.ColorVal,d.ColorVal,d.ColorVal,1,0,0,0)
        npc.Scale = mod:Lerp(npc.Scale, 2, 0.005)
        local room = game:GetRoom()
        if npc.Position.X < -100 or npc.Position.X > room:GetGridWidth()*40+100 or npc.Position.Y > room:GetGridHeight()*40+300 or npc.Position.Y < -300 then
            npc:Remove()
        end
        if npc.StateFrame > 10 then
            npc.CanShutDoors = false
        end
    end
end

function mod:GetPoopPos(poop)
    local poooffset = Vector.Zero
    local pooType = poop.Desc.Variant
    if pooType >= 7 and pooType <= 10 then --Giant Poop Offset, to keep them centered
        if pooType == 7 then
            poooffset = Vector(20,20)
        elseif pooType == 8 then
            poooffset = Vector(-20,20)
        elseif pooType == 9 then
            poooffset = Vector(20,-20)
        elseif pooType == 10 then
            poooffset = Vector(-20,-20)
        end
    end
    return (poop.Position + poooffset)
end

function mod:CheckForCustomPoop(index)
    local custompootype
    if StageAPI.IsCustomGrid(index, "FFShampoo") then 
        custompootype = "FFShampoo"
    elseif StageAPI.IsCustomGrid(index, "FFBeehive") then 
        custompootype = "FFBeehive"
    elseif StageAPI.IsCustomGrid(index, "FFSpiderNest") then 
        custompootype = "FFSpiderNest"
    elseif StageAPI.IsCustomGrid(index, "FFCursedPoop") then 
        custompootype = "FFCursedPoop"
    elseif StageAPI.IsCustomGrid(index, "FFPetrifiedPoop") then 
        custompootype = "FFPetrifiedPoop"
    elseif StageAPI.IsCustomGrid(index, "FFPlatinumPoop") then 
        custompootype = "FFPlatinumPoop"
    elseif StageAPI.IsCustomGrid(index, "FFEvilPoop") then 
        custompootype = "FFEvilPoop"
    end
    return custompootype
end

function mod:GetPoobottleParams(pooType, pooType2)
    local params = ProjectileParams()
    local special
    --print(pooType2)
    if pooType == 0 then 
        if pooType2 == "FFShampoo" then --shampoo
            --No params bc ur spawning bubbles stupid bithc
        elseif pooType2 == "FFSpiderNest" then --spidernest
            params.Color = mod.ColorWebWhite
        elseif pooType2 == "FFBeehive" then --beehive
            params.Color = mod.ColorHoneyYellow
        elseif pooType2 ==  "FFCursedPoop" then --cursed
            if mod:RandomInt(1,2) == 1 then
                params.Variant = ProjectileVariant.PROJECTILE_BONE
            else
                params.Variant = ProjectileVariant.PROJECTILE_TEAR
                params.Color = Color(0.5,0.3,0.5)
                special = "cursedPoop"
            end
        else -- normal
            params.Variant = ProjectileVariant.PROJECTILE_PUKE
        end
    elseif pooType == 1 then -- red
        params.Variant = ProjectileVariant.PROJECTILE_TEAR
        params.Color = mod.ColorRedPoop
    elseif pooType == 2 then -- corny
        if mod:RandomInt(1,2) == 1 then
            params.Variant = ProjectileVariant.PROJECTILE_CORN
        else
            params.Variant = ProjectileVariant.PROJECTILE_PUKE
        end
    elseif pooType == 3 then 
        if pooType2 == "FFPetrifiedPoop" then --petrified
            params.Variant = ProjectileVariant.PROJECTILE_ROCK
        elseif pooType2 == "FFEvilPoop" then --evil
            params.Variant = ProjectileVariant.PROJECTILE_TEAR
            params.Color = Color(0.5,0.1,0.1)
            special = "evilPoop"
        elseif pooType2 == "FFPlatinumPoop" then --platinum
            if mod:RandomInt(1,2) == 1 then
                params.Variant = ProjectileVariant.PROJECTILE_COIN
                params.Color = mod.ColorGreyscale
            else
                params.Color = mod.ColorPlatinum
            end
        else -- golden
            if mod:RandomInt(1,2) == 1 then
                params.Variant = ProjectileVariant.PROJECTILE_COIN
            else
                params.Color = mod.ColorGolden
            end
        end
    elseif pooType == 4 then --rainbow
        params.Variant = ProjectileVariant.PROJECTILE_TEAR
        params.Color = Color(math.random(1, 10) * 0.1, math.random(1, 10) * 0.1, math.random(1, 10) * 0.1, 1, 0, 0, 0)
    elseif pooType == 5 then -- black
        params.Color = mod.ColorDankBlackReal
    elseif pooType == 6 then -- white
        params.Color = Color(1,1,1,0.3,0.2,0.9,1)
        params.Variant = ProjectileVariant.PROJECTILE_TEAR
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
    elseif pooType >= 6 and pooType <= 10 then --giant
        params.Variant = ProjectileVariant.PROJECTILE_PUKE
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        params.Scale = 2
    elseif pooType == 11 then --charming
        params.Variant = ProjectileVariant.PROJECTILE_PUKE
    end
    return params, special
end

function mod:SetDrainflySheet(sprite, pooType, pooType2)
    local path 
    if pooType == 0 then -- regular
        if pooType2 == "FFShampoo" then
            path = "gfx/enemies/drainfly/monster_drainfly_shampoo.png"
        elseif pooType2 == "FFSpiderNest" then
            path = "gfx/enemies/drainfly/monster_drainfly_white.png"
        elseif pooType2 == "FFBeehive" then
            path = "gfx/enemies/drainfly/monster_drainfly_honey.png"
        elseif pooType2 == "FFCursedPoop" then
            path = "gfx/enemies/drainfly/monster_drainfly_cursed.png"
        else
            path = "gfx/enemies/drainfly/monster_drainfly_poop.png"
        end
    elseif pooType == 1 then -- red
        path = "gfx/enemies/drainfly/monster_drainfly_red.png"
    elseif pooType == 2 then -- corn
        path = "gfx/enemies/drainfly/monster_drainfly_poop.png"
    elseif pooType == 3 then -- gold
        if pooType2 == "FFPetrifiedPoop" then
            path = "gfx/enemies/drainfly/monster_drainfly_stone.png"
        elseif pooType2 == "FFPlatinumPoop" then
            path = "gfx/enemies/drainfly/monster_drainfly_platinum.png"
        elseif pooType2 == "FFEvilPoop" then
            path = "gfx/enemies/drainfly/monster_drainfly_evil.png"
        else
            path = "gfx/enemies/drainfly/monster_drainfly_gold.png"
        end
    elseif pooType == 4 then --rainbow
        path = "gfx/enemies/drainfly/" .. mod.drainerSheets[math.random(#mod.drainerSheets)] .. ".png"
    elseif pooType == 5 then -- black
        path = "gfx/enemies/drainfly/monster_drainfly_black.png"
    elseif pooType == 6 then -- white
        path = "gfx/enemies/drainfly/monster_drainfly_white2.png"
    else --default
        path = "gfx/enemies/drainfly/monster_drainfly_poop.png"
    end
    if path then
        sprite:ReplaceSpritesheet(1, path)
        sprite:LoadGraphics()
    end
end

function mod:DrainflyProjectiles(npc, pooType, pooType2)
    local interval = 9
    if pooType2 == "FFShampoo" then
        interval = 15
    elseif pooType == 3 then
        if pooType2 == "FFPlatinumPoop" then
            interval = 3
        elseif not pooType2 then
            interval = 5
        end
    elseif pooType == 4 then
        interval = 5
    end
    if npc.StateFrame % interval == 0 and not npc:GetData().zilch then
        if pooType2 == "FFShampoo" then
            mod.ShootBubble(npc, 1, npc.Position,RandomVector()*3)
        else
            local params, special = mod:GetPoobottleParams(pooType, pooType2)
            if special then
                mod:SetGatheredProjectiles()
            end
            npc:FireProjectiles(npc.Position, RandomVector():Resized(6), 0, params)
            if special then
                for _, proj in pairs(mod:GetGatheredProjectiles()) do
                    proj:GetData().projType = special
                end
            end
        end
        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 0.65, 0, false, 1)
    end
end

function mod:DrainflyEnemySpawn(npc, pooType, pooType2)
    local numCustomPoopSpawns = 4
    local rng = npc:GetDropRNG()
    local wackyInt
    if pooType == 4 then --rainbow
        if rng:RandomFloat() <= 0.5 then
            wackyInt = mod:RandomInt(1,numCustomPoopSpawns,rng)
        end
        pooType = mod:RandomInt(0,7,rng)
    end
    if pooType2 == "FFShampoo" or (wackyInt and wackyInt == 1) then
        local vec = RandomVector()
        local poop = Isaac.Spawn(mod.FF.Drop.ID,mod.FF.Drop.Var,0,npc.Position + vec:Resized(10), vec:Resized(2), npc)
        poop:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
        poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    elseif pooType2 == "FFSpiderNest" or (wackyInt and wackyInt == 2) then
        if mod:RandomInt(1,2) == 1 then
            local spider = EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(mod:RandomInt(-15,15), mod:RandomInt(-15,15)), false, -30)
            spider:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
        else
            for i = 1, mod:RandomInt(2,3) do
                local baby = EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(mod:RandomInt(-15,15), mod:RandomInt(-15,15)), false, -30)
                baby:Morph(mod.FF.BabySpider.ID, mod.FF.BabySpider.Var, 0, -1)
                baby:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
            end
        end
        npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH, 0.5, 0, false, 1)
    elseif pooType2 == "FFBeehive" or (wackyInt and wackyInt == 3) then
        local vec = RandomVector()
        local bee 
        if mod:RandomInt(1,2) == 1 then
            bee = Isaac.Spawn(256, 0, 0, npc.Position + vec:Resized(10), vec:Resized(2), npc)
        else
            bee = mod.cheekyspawn(npc.Position + vec * 7.5, npc, npc.Position + vec * 50, 281, 0, 0)
        end
        bee:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        bee:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
    elseif pooType2 == "FFPetrifiedPoop" or (wackyInt and wackyInt == 4) then
        local vec = RandomVector()
        local spider = mod.throwShit(npc.Position + vec:Resized(10), vec:Resized(math.random(2,6)/4), -10, -math.random(3,5), npc, "rockSpider")
        spider:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
    elseif pooType == 0 or pooType == 11 then -- regular/charming
        local vec = RandomVector()
        local var = 217
        if mod:CheckStage("Dross", {45}) and pooType ~= 11 then
            var = 870
        end
        local poop = Isaac.Spawn(var,0,0,npc.Position + vec:Resized(10), vec:Resized(2), npc)
        poop:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
        poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    elseif pooType == 1 then -- red
        local vec = RandomVector()
        local poop = Isaac.Spawn(mod.FF.SpicyDip.ID,mod.FF.SpicyDip.Var,0,npc.Position + vec:Resized(10), vec:Resized(2), npc)
        poop:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
        poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    elseif pooType == 2 then -- corn
        if mod:RandomInt(1,2) == 1 then
            local vec = RandomVector()
            local var = 18
            if math.random(3) == 1 then
                var = 13
            end
            local fly = Isaac.Spawn(var,0,0,npc.Position + vec:Resized(10), vec:Resized(2), npc)
            fly:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        else
            local vec = RandomVector()
            local var = 1
            if mod:CheckStage("Dross", {45}) then
                var = 3
            end
            local poop = Isaac.Spawn(217,var,0,npc.Position + vec:Resized(10), vec:Resized(2), npc)
            poop:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
            poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    elseif pooType == 3 then -- gold
        --None
    elseif pooType == 5 then -- black
        local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, npc.Position, RandomVector()*2, npc):ToNPC()
        local blotdata = blot:GetData()
        blotdata.downvelocity = -15 + math.random(10);
        blotdata.downaccel = 2.5
        blot.Velocity = blot.Velocity * (math.random(12, 20)/7.5)
        blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
        blot:GetSprite().Offset = Vector(0, -1)
        blotdata.state = "air"
        blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        blot:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
    elseif pooType == 6 then -- white
        local vec = RandomVector()
        local gost = Isaac.Spawn(mod.FF.Spoop.ID,mod.FF.Spoop.Var,mod:RandomInt(3,6),npc.Position + vec:Resized(10), vec:Resized(2), npc)
        gost:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
        gost:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    elseif pooType >= 7 and pooType <= 10 then -- giant
        local vec = RandomVector()
        local var = 220
        if mod:CheckStage("Dross", {45}) then
            var = 871
        end
        local poop = Isaac.Spawn(var,0,0,npc.Position + vec:Resized(10), vec:Resized(2), npc)
        poop:SetColor(Color(1.5,1.5,1.5,0.2,0,0,0),6,1,true,false)
        poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

function mod:DrainflyCreep(npc, pooType, pooType2)
    local creepvar 
    local creepcolor
    if pooType2 == "FFBeehive" then
        creepvar = EffectVariant.CREEP_BROWN
        creepcolor = Color(1,1,1,1,0,0,0)
        creepcolor:SetColorize(5.5, 3.5, 1, 1)
    elseif pooType2 == "FFSpiderNest" then
        creepvar = EffectVariant.CREEP_WHITE
    elseif pooType == 1 then
        creepvar = EffectVariant.CREEP_RED
        creepcolor = Color(1,1,1,1,0.2,0.2,0.2)
    elseif pooType == 5 then
        creepvar = EffectVariant.CREEP_BLACK
    elseif pooType == 4 then
        creepvar = mod:RandomInt(22,24)
        creepcolor = Color(1, 1, 1, 1, math.random(1, 10) * 0.1, math.random(1, 10) * 0.1, math.random(1, 10) * 0.1)
    end
    if creepvar then
        local creep = Isaac.Spawn(1000, creepvar, 0, npc.Position + (RandomVector() * math.random(15,30)), Vector.Zero, npc):ToEffect()
        if creepcolor then
            creep.Color = creepcolor
        end
        creep:Update()
    end
end

function mod:poobottleHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_POOP, damageFlags) then
        return false
    end
end