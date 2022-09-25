local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function findMimePosition()
    local room = game:GetRoom()
    local acceptableMimePositions = {}
    local size = room:GetGridSize()
    for i=0, size do
        local gridpos = room:GetGridPosition(i)
        local nearbyMime
        for _, mimeBlock in ipairs(Isaac.FindByType(mod.FF.MimeBlock.ID, mod.FF.MimeBlock.Var, mod.FF.MimeBlock.Sub, false, false)) do
            if mimeBlock.Position:Distance(gridpos) < 10 then
                nearbyMime = true
                break
            end
        end
        for _, witness in ipairs(Isaac.FindByType(912, -1, -1, false, false)) do
            if witness.Position:Distance(gridpos) < 10 + witness.Size then
                nearbyMime = true
                break
            end
        end
        if not nearbyMime and room:GetGridCollisionAtPos(gridpos) == 0 and room:IsPositionInRoom(gridpos, 0) and not room:GetGridEntity(i) then
            table.insert(acceptableMimePositions, gridpos)
        end
    end 

    if #acceptableMimePositions > 0 then
        --base this off room seed
        local newpos = acceptableMimePositions[math.random(#acceptableMimePositions)]
        return newpos
    end
end

function mod:mimeDegreePlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.MIME_DEGREE) then
        --[[if not data.mimeBlockInRoom or (data.mimeBlockInRoom and not data.mimeBlockInRoom:Exists()) then
            local mimeBlock = Isaac.Spawn(mod.FF.MimeBlock.ID, mod.FF.MimeBlock.Var, mod.FF.MimeBlock.Sub, findMimePosition(), nilvector, player):ToEffect()
            data.mimeBlockInRoom = mimeBlock
            mimeBlock:Update()
        end]]
    end
end

function mod:mimePlayerNewRoom(player, d, savedata)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.MIME_DEGREE) then
        if not room:IsClear() then
            for i = 1, math.random(3,5) do
                local mimePos = findMimePosition()
                if mimePos then
                    local mimeBlock = Isaac.Spawn(mod.FF.MimeBlock.ID, mod.FF.MimeBlock.Var, mod.FF.MimeBlock.Sub, mimePos, nilvector, player):ToEffect()
                end
            end
        end
    end
end

function mod:mimeBlockAI(e)
    local sprite, d = e:GetSprite(), e:GetData()
    local room = game:GetRoom()
    if not d.init then
        sprite:Play("Appear", true)
        d.init = true
    end
    e.SpriteOffset = Vector(0, 12)

    if d.disappearing then
        if sprite:IsFinished("Disappear") then
            e.Visible = false
            e.Position = Vector(-100,-100)
            if e.FrameCount % 10 == 0 then
                local mimePos = findMimePosition()
                if mimePos then
                    sprite:Play("Appear", true)
                    d.disappearing = nil
                    e.Position = mimePos
                    e.Visible = true
                end
            end
        end
    else
        if sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end
        local index = room:GetGridIndex(e.Position)
        room:SetGridPath(index, 1000)
        for _, enemy in pairs(Isaac.FindInRadius(e.Position, 100, EntityPartition.ENEMY)) do
            local dist = (enemy.Position - e.Position):Length()
            if dist < 20 + enemy.Size then
                if not enemy:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK) then
                    enemy.Velocity = mod:Lerp(enemy.Velocity, (enemy.Position - e.Position):Resized((20 + enemy.Size) - dist), 0.1)
                end
            end
        end
        for _, proj in ipairs(Isaac.FindByType(9, -1, -1, false, false)) do
            if proj.Position:Distance(e.Position) < 35 + proj.Size then
                proj:Die()
            end
        end
        if not d.disappearing then
            for _, player in ipairs(Isaac.FindByType(1, -1, -1, false, false)) do
                if player.Position:Distance(e.Position) < 30 + player.Size then
                    room:SetGridPath(index, 900)
                    sfx:Play(mod.Sounds.MimeBlockRelocate, 1, 0, false, math.random(80,120)/100)
                    d.disappearing = true
                    sprite:Play("Disappear", true)
                end
            end
        end
        if not d.disappearing then
            for _, player in ipairs(Isaac.FindByType(4, -1, -1, false, false)) do
                if player.Position:Distance(e.Position) < 50 + player.Size then
                    room:SetGridPath(index, 900)
                    sfx:Play(mod.Sounds.MimeBlockRelocate, 1, 0, false, math.random(80,120)/100)
                    d.disappearing = true
                    sprite:Play("Disappear", true)
                end
            end
        end
        if not d.disappearing then
            for _, witness in ipairs(Isaac.FindByType(912, -1, -1, false, false)) do
                if witness.Position:Distance(e.Position) < 50 + witness.Size then
                    room:SetGridPath(index, 900)
                    sfx:Play(mod.Sounds.MimeBlockRelocate, 1, 0, false, math.random(80,120)/100)
                    d.disappearing = true
                    sprite:Play("Disappear", true)
                end
            end
        end
    end
end

function mod:mimeDegreeLocustAI(e)
    for _, enemy in pairs(Isaac.FindInRadius(e.Position, 100, EntityPartition.ENEMY)) do
        local dist = (enemy.Position - e.Position):Length()
        if dist < 20 + enemy.Size then
            if not enemy:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK) then
                enemy.Velocity = mod:Lerp(enemy.Velocity, (enemy.Position - e.Position):Resized((20 + enemy.Size) - dist), 0.5)
            end
        end
    end

    if e.FrameCount % 60 == 0 then
        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, e.Position, nilvector, e):ToEffect()
        eff.MinRadius = 1
        eff.MaxRadius = 5
        eff.LifeSpan = 10
        eff.Timeout = 10
        eff.SpriteOffset = Vector(0, -15)
        eff.Color = Color(1,1,1,1,0,0,0)
        eff.Visible = false
        eff:FollowParent(e)
        eff:Update()
        eff.Visible = true
    end
end