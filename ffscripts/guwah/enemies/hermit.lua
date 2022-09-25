local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local psionColor = Color(0,0,0,1,255 / 255,80 / 255,255 / 255)

function mod:GetHermitCollectible(npc)
    if mod.savedata.risksRewardItemRollQuality then
        local item = mod.GetItemByLuaFilter(ItemPoolType.POOL_TREASURE, npc:GetDropRNG(), function(configItem)
            return configItem.Quality >= mod.savedata.risksRewardItemRollQuality and configItem.Type ~= ItemType.ITEM_ACTIVE
        end)

        if item then return item end
    end

    local itemPool = game:GetItemPool()
    return itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, true, Isaac.GetPlayer():GetCollectibleRNG(mod.ITEM.COLLECTIBLE.RISKS_REWARD):Next())
end

function mod:HermitAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        data.Item = mod:GetHermitCollectible(npc)

        local gfx = Isaac.GetItemConfig():GetCollectible(data.Item).GfxFileName
        for i = 1, 2 do
            sprite:ReplaceSpritesheet(i, gfx)
        end
        sprite:LoadGraphics()

        data.Difficulty = (game:GetLevel():GetStage() + 1) / 2
        data.Difficulty = math.floor(math.min(data.Difficulty, 3))

        data.state = "disguised"
        data.relativity = Vector(-5,0)
        data.Immune = true
        data.Next = mod:RandomInt(1,3,rng)
        data.Minions = {}
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        data.Init = true
    end

    if data.state == "disguised" then
        npc.Velocity = Vector.Zero
        mod:spritePlay(sprite, "Disguised")
        if targetpos:Distance(npc.Position) < 150 then
            data.state = "appear"
        end
    elseif data.state == "appear" then
        npc.Velocity = Vector.Zero
        if sprite:IsFinished("Appear") then
            npc.StateFrame = mod:RandomInt(45,90,rng)
            data.state = "idle"
        elseif sprite:IsEventTriggered("Sound") then
            if data.Immune then
                data.Immune = false
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
                mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            else
                mod:PlaySound(mod.Sounds.PsionTaunt, npc, 2)
                game:ButterBeanFart(npc.Position, 200, npc, false, true)
                npc.CollisionDamage = 1
            end
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "idle" then
        mod:spritePlay(sprite, "Idle01")
        npc.Velocity = npc.Velocity * 0.85

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.Next = data.Next + 1
            if data.Next > 3 then
                data.Next = 1
            end
            --data.Next = 2
            if data.Next == 1 then
                data.state = "summon"
                data.SummonAngle = 30
                data.Summons = data.Difficulty
            elseif data.Next == 2 then
                data.state = "bulletstart"
                data.IsLeft = (rng:RandomFloat() <= 0.5)
                if data.Difficulty == 3 then
                    data.AngleSpread = {-45, 0, 45}
                elseif data.Difficulty == 2 then
                    data.AngleSpread = {-22, 22}
                else
                    data.AngleSpread = {0}
                end
            elseif data.Next == 3 then
                data.Splosions = data.Difficulty
                data.state = "teleportout"
            end
        end
    elseif data.state == "summon" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Summon") then
            npc.StateFrame = mod:RandomInt(60,120,rng)
            data.state = "idle"
        elseif sprite:IsEventTriggered("Shoot") and data.Summons > 0 then
            local psiling = Isaac.Spawn(mod.FF.Psiling.ID, mod.FF.Psiling.Var, 0, npc.Position+Vector(30,0):Rotated(data.SummonAngle), Vector.Zero, npc)
            psiling:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            psiling.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            psiling.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            psiling:SetColor(psionColor, 5, 999, true, false)
            psiling.Parent = npc
            psiling:GetData().Angle = data.SummonAngle
            table.insert(data.Minions, psiling)

            local effect = Isaac.Spawn(1000, 7020, 1, psiling.Position, Vector.Zero, npc)
            effect.SpriteScale = Vector(0.8,0.8)
            effect:GetSprite().Offset = Vector(0, -10)
            effect.Color = psionColor
            effect:Update()

            data.SummonAngle = data.SummonAngle + 120
            data.Summons = data.Summons - 1
            mod:PlaySound(SoundEffect.SOUND_SUMMONSOUND, npc, 1.2, 0.6)
        else
            mod:spritePlay(sprite, "Summon")
        end
    elseif data.state == "bulletstart" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Attack01Start") then
            data.state = "bulletidle"
            npc.StateFrame = 15
        elseif sprite:IsEventTriggered("Shoot") then
            data.ProjectilesR = {}
            data.ProjectilesL = {}
            for _, angle in pairs(data.AngleSpread) do
                for j = 1, 2 do
                    if j == 2 then
                        angle = angle + 180
                    end
                
                    local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(10,0):Rotated(angle), npc):ToProjectile()
                    local projdata = projectile:GetData()
                    projectile.FallingSpeed = 0
                    projectile.FallingAccel = -0.1
                    projectile.Color = mod.ColorPsy
                    projectile.Scale = 2
                    projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
                    projdata.projType = "crosseyes"
                    projdata.state = 0
                    projdata.angle = angle
                    projdata.dist = 40
                    projectile.Parent = npc
                
                    if j == 2 then
                        table.insert(data.ProjectilesR, projectile)
                    else
                        table.insert(data.ProjectilesL, projectile)
                    end
                end
            end

            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(0,-6)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect.Color = mod.ColorPsy
        
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
            data.LoopingSound = mod.Sounds.CrosseyeShootLoop
        else
            mod:spritePlay(sprite, "Attack01Start")
        end
    elseif data.state == "bulletidle" then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(3)), 0.1)
        mod:spritePlay(sprite, "Idle02")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if mod:CheckForHermitProjectiles(npc, data) then
                if data.IsLeft then
                    data.ShootAnim = "Shoot01"
                else
                    data.ShootAnim = "Shoot02"
                end
                data.state = "bulletshoot"
            else
                data.state = "bulletend"
                sfx:Stop(data.LoopingSound)
                data.LoopingSound = nil
            end
        end
    elseif data.state == "bulletshoot" then
        npc.Velocity = npc.Velocity * 0.98
        local bullets
        if data.IsLeft then
            bullets = data.ProjectilesL
        else
            bullets = data.ProjectilesR
        end

        if sprite:IsFinished(data.ShootAnim) then
            data.IsLeft = not data.IsLeft
            data.state = "bulletidle"
            npc.StateFrame = 15
        elseif sprite:IsEventTriggered("Shoot") then
            local projs = {}
            for i, proj in pairs(bullets) do
                if proj:Exists() then
                    table.insert(projs, {proj,i})
                end
            end
    
            local data = mod:GetRandomElem(projs, rng)
            if data then
                local proj = data[1]
                local projdata = proj:GetData()
                projdata.state = 1
                local targcoord = mod:intercept(proj, target, 16)
                proj.Velocity = targcoord:Resized(16)
                table.remove(bullets, data[2])
            end

            mod:PlaySound(mod.Sounds.CrosseyeAppear, npc, 1.3, 1.5)
        else
            mod:spritePlay(sprite, data.ShootAnim)
        end
    elseif data.state == "bulletend" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished("Revert") then
            npc.StateFrame = mod:RandomInt(60,120,rng)
            data.state = "idle"
        else
            mod:spritePlay(sprite, "Revert")
        end
    elseif data.state == "teleportout" then
        npc.Velocity = Vector.Zero
        if sprite:IsFinished("TeleportOut") then
            npc.Position, data.SplosionAngle = mod:GetHermitTeleportPos(npc, targetpos)
            data.state = "splosions"
        else
            mod:spritePlay(sprite, "TeleportOut")
        end
    elseif data.state == "splosions" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Explosion") then
            if data.Splosions <= 0 then
                npc.Position = mod:FindRandomFreePosAir(targetpos, 100)
                data.state = "teleportin"
            else
                npc.Position, data.SplosionAngle = mod:GetHermitTeleportPos(npc, targetpos)
                sprite:Play("Explosion", true)
            end
        elseif sprite:IsEventTriggered("StartAttack") then
            data.Crosshairs = {}
            local delay = 0
            local vec = Vector(80,0):Rotated(data.SplosionAngle)
            local pos = npc.Position + vec

            while room:IsPositionInRoom(pos, 0) do
                local crosshair = Isaac.Spawn(1000, 7013, 0, pos, Vector.Zero, npc)
                crosshair.Parent = npc
                crosshair:GetData().Delay = delay
                crosshair:GetData().ProjBurst = true
                crosshair.Visible = false
                crosshair:Update()
                table.insert(data.Crosshairs, crosshair)
                delay = delay + 3
                pos = pos + vec
            end

            data.LoopingSound = mod.Sounds.PsionRedirectLoop
        elseif sprite:IsEventTriggered("Shoot") then
            for _, crosshair in pairs(data.Crosshairs) do
                crosshair:GetData().ExplodeTimer = crosshair:GetData().Delay
            end

            data.Splosions = data.Splosions - 1
            mod:PlaySound(mod.Sounds.PsionShoot, npc, 1.2)
            sfx:Stop(data.LoopingSound)
            data.LoopingSound = nil
        else
            mod:spritePlay(sprite, "Explosion")
        end
    elseif data.state == "teleportin" then
        npc.Velocity = npc.Velocity * 0.85
        if sprite:IsFinished("TeleportIn") then
            npc.StateFrame = mod:RandomInt(60,120,rng)
            data.state = "idle"
        else
            mod:spritePlay(sprite, "TeleportIn")
        end
    end

    if sprite:IsEventTriggered("Move") then
        npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(10))
    elseif sprite:IsEventTriggered("TeleportOut") then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        mod:PlaySound(SoundEffect.SOUND_HELL_PORTAL2)

        for _, psiling in pairs(data.Minions) do
            if psiling:Exists() then
                psiling.Parent = nil
            end
        end
    elseif sprite:IsEventTriggered("TeleportIn") then
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        mod:PlaySound(SoundEffect.SOUND_HELL_PORTAL1)
    end

    if data.LoopingSound then
        if not sfx:IsPlaying(data.LoopingSound) then
            mod:PlaySound(data.LoopingSound, npc, 1, 1, true)
        end
    end
end

function mod:HermitRender(npc, sprite, data) --Death anim logic
    if mod:IsNormalRender() and sprite:IsPlaying("Death") then
        if data.LoopingSound then
            sfx:Stop(data.LoopingSound)
            data.LoopingSound = nil
        end
        if sprite:GetFrame() == 62 then
            local item = Isaac.Spawn(5,100,data.Item,npc.Position,Vector.Zero,npc)
            item:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            item.Visible = true
            npc:Remove()
        elseif sprite:IsEventTriggered("Sound") then
            if sprite:GetFrame() == 9 then
                mod:PlaySound(mod.Sounds.PsionDeath, npc, 1.5)
            elseif sprite:GetFrame() == 40 then
                mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            else
                mod:PlaySound(SoundEffect.SOUND_STONE_IMPACT, npc)
            end
        end
    end
end

function mod:HermitHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if data.state == "disguised" then
        data.state = "appear"
    end
    if data.Immune then
        return false
    elseif source.Entity and source.Type == 1000 and source.Variant == 7012 then
        return false
    end
end

function mod:CheckForHermitProjectiles(npc, data)   
    local ret 
    local isLeft
    local isRight

    for _, proj in pairs(data.ProjectilesL) do
        if proj:Exists() then
            ret = true
            isLeft = true
        end
    end
    
    for _, proj in pairs(data.ProjectilesR) do
        if proj:Exists() then
            ret = true
            isRight = true
        end
    end

    if not isLeft then
        data.IsLeft = false
    elseif not isRight then
        data.IsLeft = true
    end

    return ret
end

function mod:GetHermitTeleportPos(npc, targetpos) --(and angle)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local candidates = {}

    for i = 0, 270, 90 do
        local vec = Vector(40,0):Rotated(i)
        local pos = targetpos + vec
        while room:IsPositionInRoom(pos, 0) do
            pos = pos + vec
        end
        if pos:Distance(targetpos) > 80 then
            table.insert(candidates,{pos, i})
        end
    end

    local data = mod:GetRandomElem(candidates, rng)
    if data then
        return data[1], (data[2] + 180)
    else --This should never happen in practice but just incase make the error obvious
        print("Error in Hermit teleport selection")
        return npc.Position, 0
    end
end