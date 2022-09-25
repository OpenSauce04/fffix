local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
    local virtues = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)

    local ghosty = {}
    for _,ghost in ipairs(Isaac.FindByType(mod.FF.AstropulvisGhost.ID, mod.FF.AstropulvisGhost.Var, mod.FF.AstropulvisGhost.Sub, false, false)) do
        table.insert(ghosty, ghost)
    end
    local rocks = false
    for key,rock in pairs(mod.astropulvisRocks) do
        rocks = true
        break
    end
    if #ghosty == 0 and rocks == false then
        local radius = 9999
        local chosenGrid
        for _,grid in ipairs(mod.GetGridEntities()) do
            if grid.CollisionClass == GridCollisionClass.COLLISION_SOLID and grid.Position:Distance(player.Position) < radius and mod.astropulvisRocks[grid:GetGridIndex()] == nil and mod.gridToProjectile[grid:GetType()] ~= nil then
                chosenGrid = grid
                radius = grid.Position:Distance(player.Position)
            end
        end
        if chosenGrid then
            local chosenIndex = chosenGrid:GetGridIndex()
            mod.astropulvisRocks[chosenIndex] = {player = player, grid = chosenGrid, index = chosenGrid:GetGridIndex(), frame = 0, rng = rng}
            --[[chosenGrid:Destroy()
            data.astropulvisGhost = Isaac.Spawn(mod.FF.AstropulvisGhost.ID, mod.FF.AstropulvisGhost.Var, mod.FF.AstropulvisGhost.Sub, chosenGrid.Position, Vector(0,5):Rotated(rng:RandomInt(360)), player)]]
        end
        mod.scheduleForUpdate(function()
            for i=0,3 do
                if player:GetActiveItem(i) == FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS then
                    if player:GetActiveCharge(i) < 85 then
                        player:SetActiveCharge(85, i)
                    end
                end
            end
        end, 0)
    elseif #ghosty > 0 then
        for _,ghost in ipairs(ghosty) do
            if ghost:Exists() then
                ghost:GetData().state = "Explode"
                if virtues then
                    ghost:GetData().spawnWisp = true
                    ghost:GetData().spawnWispPlayer = player
                end
                if mod:playerIsBelialMode(player) then
                    ghost:GetData().belialExplosion = true
                end
            end
        end

        for _,wisp in ipairs(Isaac.FindByType(3, FamiliarVariant.WISP, FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS, false, false)) do
            local explosion = Isaac.Spawn(1000, 144, 1, wisp.Position, Vector.Zero, wisp):ToEffect()
            explosion.CollisionDamage = player.Damage+3*Game():GetLevel():GetAbsoluteStage()/2
            explosion.SpriteScale = Vector(0.7, 0.7)
            sfx:Play(SoundEffect.SOUND_DEMON_HIT, 0.3, 0, false, 1.5)
            wisp:Remove()
        end
    else
        mod.scheduleForUpdate(function()
            for i=0,3 do
                if player:GetActiveItem(i) == FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS then
                    if player:GetActiveCharge(i) < 85 then
                        player:SetActiveCharge(85, i)
                    end
                end
            end
        end, 0)
    end
end, FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS)

function mod:astropulvisGhostEffect(e)
    local data = e:GetData()
    local rng = e:GetDropRNG()
    local sprite = e:GetSprite()

    if not data.init then
        data.anim = rng:RandomInt(3)+1
        data.state = "Idle"
        data.init = true
    end

    if e.Velocity:Length() > 0.5 then
        if e.Velocity.X > 0 then
            sprite.FlipX = false
        else
            sprite.FlipX = true
        end
    end

    if data.state == "Idle" then
        mod:spritePlay(sprite, "Idle" .. data.anim)
    elseif data.state == "Explode" then
        if sprite:IsFinished("Explode" .. data.anim) then
            local rangle = rng:RandomInt(360)
            for i=120,360,120 do
                local newPos = e.Position+Vector(0,50):Rotated(i+rangle)
                local explosion = Isaac.Spawn(1000, 144, 1, newPos, Vector.Zero, e):ToEffect()
                local extDam = 0
                if data.player then
                    extDam = data.player.Damage
                else
                    extDam = 5
                end
                explosion.CollisionDamage = extDam+8*Game():GetLevel():GetAbsoluteStage()/2

                if data.belialExplosion then
                    local newPos2 = e.Position+Vector(0,100):Rotated(i+rangle)
                    local explosion2 = Isaac.Spawn(1000, 144, 1, newPos2, Vector.Zero, e):ToEffect()
                    explosion2.CollisionDamage = extDam+6*Game():GetLevel():GetAbsoluteStage()/2
                    explosion2.SpriteScale = Vector(0.7, 0.7)
                end

                if data.spawnWisp then
                    local wisp = Isaac.Spawn(3, FamiliarVariant.WISP, FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS, e.Position, Vector.Zero, data.spawnWispPlayer):ToFamiliar()
                    wisp.Player = data.spawnWispPlayer
                    data.spawnWisp = nil
                end
                --[[for _, enemy in ipairs(Isaac.FindInRadius(newPos, 30, EntityPartition.ENEMY)) do
					if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
						local damage = (data.player.Damage or 5)+10
						enemy:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(bomb), 0)
					end
				end]]
            end
            sfx:Play(SoundEffect.SOUND_DEMON_HIT, 1, 0, false, 1)
            e:Remove()
        else
            mod:spritePlay(sprite, "Explode" .. data.anim)
        end
    end
    e.Velocity = mod:Lerp(e.Velocity, Vector.Zero, 0.1)
end

function mod:astropulvisGhostInit(e)
    local data = e:GetData()
    local rng = e:GetDropRNG()
    local sprite = e:GetSprite()

    if not data.init then
        data.anim = rng:RandomInt(3)+1
        data.state = "Idle"
        data.init = true
    end

    if e.Velocity:Length() > 0.5 then
        if e.Velocity.X > 0 then
            sprite.FlipX = false
        else
            sprite.FlipX = true
        end
    end

    mod:spritePlay(sprite, "Idle" .. data.anim)
end

function mod:astropulvisRockDestroy(entry)
    if entry.frame < 30 then
        if entry.grid and entry.grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
            entry.grid:GetSprite().Color = Color(1,1,1,1,(entry.frame*4)/255,0,0)
        else
            if entry.grid then
                entry.grid:GetSprite().Color = Color(1,1,1,1,0,0,0)
            end
            mod.astropulvisRocks[entry.index] = nil
        end
        entry.frame = entry.frame+1
    else
        if entry.grid and entry.grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
            entry.grid:GetSprite().Color = Color(1,1,1,0,0,0,0)
            entry.grid:Destroy()
            local ghostvec = Vector(0,5):Rotated(entry.rng:RandomInt(360))
            local target = mod.FindClosestEnemy(entry.grid.Position, 250, true)
            if target then
                ghostvec = (target.Position - entry.grid.Position):Resized(5)
            end
            local ghost = Isaac.Spawn(mod.FF.AstropulvisGhost.ID, mod.FF.AstropulvisGhost.Var, mod.FF.AstropulvisGhost.Sub, entry.grid.Position, ghostvec, entry.player)
            ghost:GetData().player = entry.player

            for i=1,7 do
                local randVel = RandomVector()*math.random(10,30)/20
                local cloud = Isaac.Spawn(1000, 59, 0, entry.grid.Position, Vector.Zero, nil):ToEffect()
                cloud:SetTimeout(math.random(60,200))
                --local color = Color(0.6,0,0,0,0,0,0)
                local color = Color(0.2,0,0.1,0,0,0,0)
                cloud.Color = color
                local randScale = math.random(50,200)/100
                cloud.SpriteScale = Vector(0.5, 0.5)
                cloud:GetData().astroDust = {scale = randScale, vel = randVel, lifespan = math.random(60,200)}
            end
        end
        mod.astropulvisRocks[entry.index] = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
    local data = e:GetData()
    if data.astroDust then
        local rng = e:GetDropRNG()
        local entry = data.astroDust
        e.Velocity = entry.vel
        entry.vel = entry.vel*0.98
        if entry.scale then
            e.SpriteScale = Vector(e.SpriteScale.X+0.05, e.SpriteScale.Y+0.02)
            if e.Color.A < 0.75 then
                e.Color = Color(e.Color.R,e.Color.G,e.Color.B,e.Color.A+0.05, 0,0,0)
            end
			if e.SpriteScale.X >= entry.scale then
				entry.scale = nil
			end
        end
        entry.lifespan = entry.lifespan-1
        --[[if entry.lifespan < 50 then
            e.Color = Color(e.Color.R,e.Color.G,e.Color.B,e.Color.A-0.008, 0,0,0)
            if e.Color.A <= 0 then
                e:Remove()
            end
        end]]

        if entry.lifespan % 22 == 0 then
            local star = Isaac.Spawn(1000, 1727, 0, e.Position+mod:shuntedPosition(20, rng), Vector.Zero, nil):ToEffect()
            --star.Color = Color(e.Color.R,e.Color.G,e.Color.B,0.5, 0,0,0)
            star.Color = Color(1,1,1,0.5,0,0,0)
            local scale = math.random(10,100)/100
            star.SpriteScale = Vector(scale, scale)
        end
    elseif data.holyWobblesDust then
        local rng = e:GetDropRNG()
        local entry = data.holyWobblesDust
        e.Velocity = entry.vel
        entry.vel = entry.vel*0.98
        if entry.scale then
            e.SpriteScale = Vector(e.SpriteScale.X+0.05, e.SpriteScale.Y+0.02)
            local num = 0.2
            if entry.beam then
                num = 0.35
            end
            if e.Color.A < num then
                e.Color = Color(e.Color.R,e.Color.G,e.Color.B,e.Color.A+0.05, e.Color.RO,e.Color.GO,e.Color.BO)
            end
			if e.SpriteScale.X >= entry.scale then
				entry.scale = nil
			end
        end
        if e.SpriteOffset.Y < 0 then
            local num = 1
            if entry.beam then
                num = 0.5
            end
            e.SpriteOffset = Vector(e.SpriteOffset.X, e.SpriteOffset.Y+num)
        end
        entry.lifespan = entry.lifespan-1
        --[[if entry.lifespan < 50 then
            e.Color = Color(e.Color.R,e.Color.G,e.Color.B,e.Color.A-0.008, 0,0,0)
            if e.Color.A <= 0 then
                e:Remove()
            end
        end]]

        if entry.lifespan % 55 == 0 then
            local star = Isaac.Spawn(1000, 1727, 0, e.Position+mod:shuntedPosition(20, rng), Vector.Zero, nil):ToEffect()
            --star.Color = Color(e.Color.R,e.Color.G,e.Color.B,0.5, 0,0,0)
            star.Color = Color(1,1,1,e.Color.A,0,0,0)
            local scale = math.random(10,100)/100
            star.SpriteScale = Vector(scale, scale)
        end

        if entry.npc and entry.npc:Exists() then
            if entry.npc:GetData().gassing and not data.expired then
                e:SetTimeout(entry.timeout)
            else
                data.expired = true
            end
        end
        local room = game:GetRoom()
        if e.Timeout == 40 and entry.beam and entry.npc and not room:IsClear() then
            local beam = Isaac.Spawn(1000, mod.FF.HolyWobblesBeam.Var, mod.FF.HolyWobblesBeam.Sub, e.Position+mod:shuntedPosition(10,rng), Vector.Zero, entry.npc):ToEffect()
            beam.Color = Color(1,0.8,0.3,1,0.2,0.3,0.3)
            beam.SpriteScale = Vector(0.2,1)
            beam.SpriteOffset = Vector(0, -5)
            beam.Scale = 0.3
            beam.Size = 0.3
            beam.Parent = entry.npc
        end
    end
end, 59)