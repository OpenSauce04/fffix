local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, useflags, activeslot)
    local CloseEnemies = {}
    local npcs = Isaac.FindInRadius(player.Position, 500, EntityPartition.ENEMY)
    for _, npc in ipairs(npcs) do
        npc = npc:ToNPC()
        if npc and npc:IsVulnerableEnemy() then
            table.insert(CloseEnemies, npc)
        end
    end
    for i = 1, 5 do
        local vec = RandomVector() * math.random(200,250)/10
        if #CloseEnemies > 0 then
            local choice = math.random(#CloseEnemies)
            vec = (CloseEnemies[choice].Position - player.Position):Resized(math.random(200,250)/10)
            table.remove(CloseEnemies, choice)
        end
        local spagety = Isaac.Spawn(mod.FF.NilPastaEnd.ID, mod.FF.NilPastaEnd.Var, mod.FF.NilPastaEnd.Sub, player.Position, vec, player):ToEffect()
        spagety.Parent = player
        spagety:Update()
    end
    sfx:Play(mod.Sounds.CleaverThrow,0.3,0,false, math.random(120,150)/100)
    sfx:Play(mod.Sounds.WhipCrack,0.1,0,false, math.random(150,180)/100)
    return true
end, mod.ITEM.COLLECTIBLE.NIL_PASTA)

function mod:nilPastaEnd(e)
    local d, sprite = e:GetData(), e:GetSprite()
    local player = e.Parent
    e.DepthOffset = 50
    if not e.Child then
        local handler = Isaac.Spawn(1000, 1749, 163, e.Position, nilvector, e):ToEffect()
        handler.Parent = e
        handler.Visible = false
        handler:Update()

        local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 163, e.Parent.Position, nilvector, e)
        e.Child = rope

        rope.Parent = handler
        rope.Target = e.Parent

        rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        rope:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        rope.DepthOffset = -50

        rope:GetSprite():Play("Idle", true)
        --rope:GetSprite():SetFrame(100)
        rope:Update()

        rope.SplatColor = Color(1,1,1,0,0,0,0)
    end
    e.Child:Update()
    e.Child:Update()

    if not d.SuccessfullySnared then
        if not d.SnaredDude or (d.SnaredDude and not d.SnaredDude:Exists()) then
            local npcs = Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)
            for _, npc in pairs(npcs) do
                npc = npc:ToNPC()
                if npc and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
                    if npc.Position:Distance(e.Position) < e.Size + npc.Size then
                        d.SnaredDude = npc
                        npc:GetData().DownloadFailuredManually = true
                        d.SuccessfullySnared = true
                        npc:AddFreeze(EntityRef(player),360)
                        break
                    end
                end
            end
        end
    end
    if d.SnaredDude and d.SnaredDude:Exists() and d.SnaredDude:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
        local targetVec = ((d.SnaredDude.Position + d.SnaredDude.Velocity) - e.Position)
        e.Velocity = mod:Lerp(e.Velocity, targetVec, 0.5)
        e.SpriteOffset = mod:Lerp(e.SpriteOffset, Vector(0, -5) + d.SnaredDude.SpriteOffset, 0.1)
        sprite:SetFrame("End", 0)
        e.Visible = true
        
    
        local colR = math.sin(game:GetFrameCount()/20)/5
        local colG = math.cos(game:GetFrameCount()/20)/5
        local colB = math.sin(game:GetFrameCount()/10)/5
        e.Color = Color(1,1,1,1,colR, colG, colB)
        e.Child.Color = e.Color
    else
        if d.SnaredDude and d.SnaredDude:Exists() then
            d.SnaredDude.SplatColor = Color(math.random(), math.random(), math.random(), 1, math.random(), math.random(), math.random())
            d.SnaredDude:BloodExplode()
            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, math.random(50,150)/100)
            for i = 1, 20 do
                local square = Isaac.Spawn(mod.FF.WhiteSquareEffect.ID, mod.FF.WhiteSquareEffect.Var, mod.FF.WhiteSquareEffect.Sub, d.SnaredDude.Position, RandomVector() * math.random(50,100)/10, nil)
                square:Update()
            end
        end
        d.SnaredDude = nil
        e.Visible = false
        e.Velocity = e.Velocity * 0.95
        if e.FrameCount > 10 then
            local targetVec = ((player.Position + player.Velocity) - e.Position)
            if targetVec:Length() > 30 then
                targetVec = targetVec:Resized(30)
            end
            e.Velocity = mod:Lerp(e.Velocity, targetVec, math.min(0.1 + e.FrameCount / 10, 0.5))
            if e.Position:Distance(e.Parent.Position) < 10 then
                if e.Child then
                    e.Child:Remove()
                end
                e:Remove()
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, handler)
	if handler.SubType == 163 then
		if not handler.Parent or not handler.Parent:Exists() then
			handler:Remove()
		else
			handler.Position = handler.Parent.Position + handler.Parent.SpriteOffset + Vector(0,11)
			handler.Velocity = handler.Parent.Velocity
		end
	end
end, 1749)


mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 and npc.SubType == 163 then
        return false
    end
end, EntityType.ENTITY_EVIS)

function mod:nilPastaSquaresAI(e)
    local d = e:GetData()
    e.DepthOffset = -1000
    if not d.init then
        if e.SpawnerEntity then
            e.SpriteOffset = Vector(-(e.SpawnerEntity.Size * 1.5) + math.random(math.ceil(e.SpawnerEntity.Size * 3)), -math.random(math.ceil(e.SpawnerEntity.Size * 3)))
        end
        e.SpriteScale = Vector(math.random(10), math.random(10))
        if math.random(3) == 1 then
            e.Color = Color(1,0,0,1)
        else
            e.Color = Color(1,1,0,1)
        end
        d.init = true
    end
    if e.SpawnerEntity then
        e.Position = e.SpawnerEntity.Position
        e.Velocity = e.SpawnerEntity.Velocity
    end
    if e.FrameCount >= 20 then
        e:Remove()
    elseif e.FrameCount > 10 then
        e.Color = Color(e.Color.R, e.Color.G, e.Color.B, 0.3 - ((e.FrameCount - 10)/10))
    end
    e.SpriteScale = e.SpriteScale * 0.98
    e.Velocity = e.Velocity * 0.9
end

function mod:nilPastaOnLocustDamage(player, locust, entity)
    if not entity:GetData().DownloadFailuredManually then
        if math.random(30) == 1 then
            entity:GetData().DownloadFailuredManually = true
            entity.SplatColor = Color(math.random(), math.random(), math.random(), 1, math.random(), math.random(), math.random())
            entity:BloodExplode()
            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, math.random(50,150)/100)
            for i = 1, 20 do
                local square = Isaac.Spawn(mod.FF.WhiteSquareEffect.ID, mod.FF.WhiteSquareEffect.Var, mod.FF.WhiteSquareEffect.Sub, entity.Position, RandomVector() * math.random(50,100)/10, nil)
                square:Update()
            end
        end
    end
end