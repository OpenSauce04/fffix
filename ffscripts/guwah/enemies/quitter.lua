local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:QuitterAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        data.state = "idle"
        data.walktarg = mod:FindRandomValidPathPosition(npc, 3, 80)
        npc.StateFrame = mod:RandomInt(30,60)
        data.Init = true
    end
    if data.state == "idle" then
        if npc.Position:Distance(data.walktarg) > 10 then
            if room:CheckLine(npc.Position,data.walktarg,0,1,false,false) then
                local targetvel = (data.walktarg - npc.Position):Resized(6)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
            else
                npc.Pathfinder:FindGridPath(data.walktarg, 0.4, 900, true)
            end
        else
            data.walktarg = mod:FindRandomValidPathPosition(npc, 3, 80)
        end
        if npc.Velocity:Length() > 0.1 and npc.FrameCount > 1 then
            mod:spritePlay(sprite, "Walk")
        else
            mod:spritePlay(sprite, "Idle")
        end
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            local sucks1, sucks2, sucks3 = mod:GetQuitterSucks(npc.Position)
            if #sucks1 > 0 or #sucks2 > 0 or #sucks3 > 0 then
                data.state = "suckstart"
            end
        end
    elseif data.state == "suckstart" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("SuckStart") then
            data.state = "sucking"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 1.2)
        elseif sprite:IsEventTriggered("Shoot") then
            data.sucked = {}
            data.chunks = 0
            data.spiders = 0
            data.maggots = 0
            data.pitch = 0.8
            npc.StateFrame = 120
            data.sucking = true
        else
            mod:spritePlay(sprite, "SuckStart")
        end
    elseif data.state == "sucking" then
        npc.Velocity = npc.Velocity * 0.6
        mod:spritePlay(sprite, "SuckContinue")
    elseif data.state == "whiff" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("SuckWhiff") then
            npc.StateFrame = mod:RandomInt(120,180)
            data.walktarg = mod:FindRandomValidPathPosition(npc, 3, 80)
            data.state = "idle"
        else
            mod:spritePlay(sprite, "SuckWhiff")
        end
    elseif data.state == "chomp" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("SuckEnd") then
            npc.StateFrame = mod:RandomInt(20,40)
            data.state = "chewin"
        else
            mod:spritePlay(sprite, "SuckEnd")
        end
    elseif data.state == "chewin" then
        npc.Velocity = npc.Velocity * 0.6
        mod:spritePlay(sprite, "Chew")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.state = "spewin"
        end
        if sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, npc, 1.2)
        end
    elseif data.state == "spewin" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("Spew") then
            npc.StateFrame = mod:RandomInt(120,180)
            data.walktarg = mod:FindRandomValidPathPosition(npc, 3, 80)
            data.state = "idle"
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0, npc, 1.2)
            local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc)
            effect.Color = mod.ColorRedPoop
            effect.SpriteOffset = Vector(0,-10)
            effect.DepthOffset = npc.Position.Y * 1.25
            local vel = (targetpos -  npc.Position):Resized(12)
            if #data.sucked > 0 then
                local dummyeffect = Isaac.Spawn(mod.FF.DummyEffect.ID, mod.FF.DummyEffect.Var, mod.FF.DummyEffect.Sub, npc.Position, vel, npc)
                dummyeffect:GetData().corpseClusters = {}
                local params = ProjectileParams()
                params.FallingAccelModifier = -0.1
                params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
                mod:SetGatheredProjectiles()
                for i = 1, #data.sucked do
                    local projdata = data.sucked[i]
                    params.Scale = projdata.Scale
                    params.Color = projdata.Color
                    params.Variant = projdata.Variant
                    if projdata.IsTooth then
                        params.BulletFlags = params.BulletFlags | ProjectileFlags.BROCCOLI --This is just a backwards way to track what bones should be teeth
                    end
                    npc:FireProjectiles(npc.Position, vel, 0, params)
                end
                for _, proj in pairs(mod:GetGatheredProjectiles()) do
                    table.insert(dummyeffect:GetData().corpseClusters, proj)
                    if proj:HasProjectileFlags(ProjectileFlags.BROCCOLI) then --Turn it into a tooth and remove the flag
                        proj:ClearProjectileFlags(ProjectileFlags.BROCCOLI)
                        local sprite = proj:GetSprite()
                        sprite:Load("gfx/002.030_black tooth tear.anm2", true)
                        sprite:ReplaceSpritesheet(0, "gfx/projectiles/morbus_tooth.png")
                        sprite:LoadGraphics()
                        sprite:Play("Tooth2Move", false)
                        proj:GetData().tooth = true
                    end
                    proj.Parent = dummyeffect
                    proj:GetData().projType = "corpseCluster"
                end
            end
            local maxrot = 15 * (data.chunks - 1)
            for i = 1, data.chunks do
                local chunkvel = vel:Rotated(mod:RandomInt(-maxrot,maxrot))
                local tomachunk = Isaac.Spawn(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, npc.Position + Vector.One:Resized(npc.Size * 2):Rotated(chunkvel:GetAngleDegrees()), chunkvel, npc)
                tomachunk:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                tomachunk.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				tomachunk.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                tomachunk:GetData().fiendfolio_projVel = tomachunk.Velocity
            end
            maxrot = 8 * (data.maggots - 1)
            for i = 1, data.maggots do --All this work to make the Maggots go into bullet mode... thanks Kilburn
                local chunkvel = vel:Rotated(mod:RandomInt(-maxrot,maxrot))
                local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, npc.Position + Vector.One:Resized(npc.Size * 2):Rotated(chunkvel:GetAngleDegrees()), chunkvel, npc):ToNPC()
                maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                maggot.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				maggot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                maggot.State = 16
                maggot.TargetPosition = maggot.Velocity
                maggot.PositionOffset = Vector(0,-24)
                maggot.V1 = Vector(-8,10)
                maggot.I1 = 2
            end
            local spiderballs = data.spiders / 2
            local extraspider = data.spiders % 2 == 1
            maxrot = 8 * (spiderballs - 1)
            for i = 1, spiderballs do
                local chunkvel = vel:Rotated(mod:RandomInt(-maxrot,maxrot))
                local spiderball = Isaac.Spawn(mod.FF.SpiderProj.ID, mod.FF.SpiderProj.Var, 0, npc.Position + Vector.One:Resized(npc.Size * 2):Rotated(chunkvel:GetAngleDegrees()), chunkvel, npc)
                spiderball:GetData().vel = chunkvel
                spiderball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                spiderball.SpriteOffset = Vector(0, 0)
                spiderball:Update()
            end
            if extraspider then
                EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + vel:Resized(mod:RandomInt(30,40)):Rotated(mod:RandomInt(-maxrot,maxrot)), false, 0)
            end
        else
            mod:spritePlay(sprite, "Spew")
        end
    end
    if data.sucking then
        local tears, projectiles, chunks = mod:GetQuitterSucks(npc.Position)
        npc.StateFrame = npc.StateFrame - 1
        if (npc.StateFrame <= 30 and #tears <= 0 and #projectiles <= 0 and #chunks <= 0) or npc.StateFrame <= 0 or data.chunks >= 3 or data.spiders >= 4 or data.maggots >= 5 or #data.sucked >= 15 then
            if data.chunks <= 0 and #data.sucked <= 0 and data.spiders <= 0 and data.maggots <= 0 then
                data.state = "whiff"
            else
                data.state = "chomp"
            end
            data.sucking = false
        end
        if npc.FrameCount % 10 == 0 then
            local succ = Isaac.Spawn(1000,151,1,npc.Position + Vector(0,-15),Vector.Zero,npc)
            succ:Update()
            if npc.FrameCount % 20 == 0 then
                local succ = Isaac.Spawn(1000,151,0,npc.Position + Vector(0,-15),Vector.Zero,npc)
                succ:Update()
            end
        end
        for _, tear in pairs(tears) do
            local distance = tear.Position:Distance(npc.Position)
            local shouldEat = (distance < (npc.Size * 0.6)) and (tear.Height > -50)
            local succstrength = (300 - npc.Position:Distance(tear.Position)) / 6
            if distance < 50 then
                tear:GetData().QuitterSucked = true
            end
            tear.Height = mod:Lerp(tear.Height, -18, 0.15)
            tear.Velocity = mod:Lerp(tear.Velocity, (npc.Position - tear.Position):Resized(succstrength), 0.05)
            if shouldEat then
                mod:AddTearToQuitter(npc, tear)
            end   
        end
        for _, proj in pairs(projectiles) do
            local distance = proj.Position:Distance(npc.Position) 
            local shouldEat = (distance < (npc.Size * 0.6)) and (proj.Height > -50)
            local succstrength = (300 - npc.Position:Distance(proj.Position)) / 6
            if distance < 50 then
                proj:GetData().QuitterSucked = true
            end
            proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
            proj.Height = mod:Lerp(proj.Height, -18, 0.15)
            proj.Velocity = mod:Lerp(proj.Velocity, (npc.Position - proj.Position):Resized(succstrength), 0.05)
            if shouldEat then
                mod:AddProjectileToQuitter(npc, proj)
            end   
        end
        for _, chunk in pairs(chunks) do
            local distance = chunk.Position:Distance(npc.Position)
            local shouldEat = distance < npc.Size
            local succfactor = 6
            if chunk.Type == mod.FF.TomaChunk.ID then
                succfactor = 10
            elseif chunk.Type == EntityType.ENTITY_SPIDER then
                succfactor = 1.5 --Why are so they so damn heavy
            end
            local succstrength = (300 - npc.Position:Distance(chunk.Position)) / succfactor
            if distance < 50 then
                chunk:GetData().QuitterSucked = true
            end
            chunk.Velocity = mod:Lerp(chunk.Velocity, (npc.Position - chunk.Position):Resized(succstrength), 0.05)
            if shouldEat then
                if chunk.Type == mod.FF.TomaChunk.ID then
                    data.chunks = data.chunks + 1
                elseif chunk.Type == EntityType.ENTITY_SPIDER then
                    data.spiders = data.spiders + 1
                elseif chunk.Type == EntityType.ENTITY_SMALL_MAGGOT then
                    data.maggots = data.maggots + 1
                end
                mod:QuitterInhaleSound(npc)
                chunk:BloodExplode()
                chunk:Remove()
            end
        end
    end
end

function mod:GetQuitterSucks(pos)
    local radius = 300
    local tears = {}
    local projectiles = {}
    local chunks = {}
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Position:Distance(pos) < radius then
            if entity.Type == 2 then
                table.insert(tears, entity:ToTear())
            elseif entity.Type == 9 then
                table.insert(projectiles, entity:ToProjectile())
            elseif entity.Type == mod.FF.TomaChunk.ID and entity.Variant == mod.FF.TomaChunk.Var and entity.SubType == mod.FF.TomaChunk.Sub then
                table.insert(chunks, entity:ToNPC())
            elseif entity.Type == EntityType.ENTITY_SMALL_MAGGOT then
                table.insert(chunks, entity:ToNPC())
            elseif entity.Type == EntityType.ENTITY_SPIDER and entity.Variant == 0 then
                table.insert(chunks, entity:ToNPC())
            end
        end
    end
    return tears, projectiles, chunks
end

function mod:QuitterColl(npc, collider)
    local data = npc:GetData()
    if data.sucking then
        if collider:GetData().QuitterSucked then
            if collider.Type == 2 then
                mod:AddTearToQuitter(npc, collider)
            elseif collider.Type == 9 then
                mod:AddProjectileToQuitter(npc, collider)
            end
            return true
        end
    end
end

function mod:QuitterHurt(npc, amount, damageFlags, source)
    if source.Entity and source.Entity:GetData().QuitterSucked then
        return false
    end
end

function mod:CorpseClusterProjectile(projectile, data)
    data.Angle = mod:RandomAngle()
    projectile.TargetPosition = projectile.Parent.Position + Vector.One:Resized(mod:RandomInt(30,40)):Rotated(data.Angle)
    local vec = projectile.TargetPosition - projectile.Position
    vec = vec:Resized(math.min(40, vec:Length()))
    projectile.Velocity = mod:Lerp(projectile.Velocity, vec, 0.02)
end

function mod:AddTearToQuitter(npc, tear)
    tear = tear:ToTear()
    local projdata = {}
    projdata.Variant = mod.TearToProj[tear.Variant] or 0
    projdata.Scale = tear.Scale
    projdata.Color = tear.Color
    projdata.IsTooth = (tear.Variant == 2 or tear.Variant == 30)
    table.insert(npc:GetData().sucked, projdata)
    mod:QuitterInhaleSound(npc)
    tear:Remove()
end

function mod:AddProjectileToQuitter(npc, projectile)
    projectile = projectile:ToProjectile()
    local projdata = {}
    projdata.Variant = projectile.Variant
    projdata.Scale = projectile.Scale
    projdata.Color = projectile.Color
    projdata.IsTooth = projectile:GetData().tooth
    table.insert(npc:GetData().sucked, projdata)
    mod:QuitterInhaleSound(npc)
    projectile:Remove()
end

function mod:QuitterInhaleSound(npc)
    local data = npc:GetData()
    mod:PlaySound(mod.Sounds.KirbyInhale, npc, data.pitch)
    if data.pitch < 2.8 then
        data.pitch = data.pitch + 0.1
    end
end

function mod:DummyEffectInit(effect)
    effect.Visible = false
end

function mod:DummyEffectAI(effect, sprite, data)
    local room = game:GetRoom()
    if data.corpseClusters then
        if effect.FrameCount % 3 == 0 then
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, effect.Position, effect.Velocity:Resized(-5), effect):ToEffect()
            trail.SpriteOffset = Vector(0, -25)
            trail.DepthOffset = -15
            trail.Color = mod.ColorRedPoop
            trail:Update()
        end
        if room:GetGridCollisionAtPos(effect.Position) >= GridCollisionClass.COLLISION_SOLID then
            for _, projectile in pairs(data.corpseClusters) do
                projectile.Velocity = effect.Velocity:Rotated(180 + mod:RandomInt(-60,60))
                projectile:GetData().projType = nil
                projectile:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
            end
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
            local cloud = Isaac.Spawn(1000,16,5,effect.Position,Vector.Zero,effect)
            cloud.Color = mod.ColorRedPoop
            cloud.SpriteScale = Vector(0.7,0.7)
            effect:Remove()
        end
    elseif data.afterImage then
        if effect.FrameCount > 10 then
            effect:Remove()
        end
    end
end

mod.TearToProj = {
    [0] = 4,
    [2] = 1,
    [11] = 4,
    [14] = 4,
    [16] = 4,
    [20] = 7,
    [22] = 9,
    [24] = 4,
    [29] = 1,
    [30] = 1,
    [33] = 16,
    [34] = 16,
    [36] = 4,
    [42] = 9,
    [46] = 2,
}