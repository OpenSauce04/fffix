local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MightflyAI(npc, sprite, data)
    local isGolden = (npc.Variant == mod.FF.GoldenMightfly.Var)
    if not data.Init then
        local params = ProjectileParams()
        if isGolden then
            params.Variant = mod.FF.BetterCoinProjectile.Var
            npc.SplatColor = mod.ColorLemonYellow
        else
            if mod:CheckStage("Dross", {45}) then
                npc.SplatColor = mod.ColorPoopyPeople
                params.Color = FiendFolio.ColorDrossWater
            else
                npc.SplatColor = mod.ColorWaterPeople
            end
            params.Variant = 4
        end
        params.Spread = 0.7
        data.Params = params
        data.Init = true
    end
    if isGolden then
        if npc.FrameCount % 3 == 0 then
            local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, Vector.Zero, npc):ToEffect()
            sparkle.RenderZOffset = -5
            sparkle.SpriteOffset = Vector(-10 + math.random(20), -30 + math.random(20))
        end
    end
    if npc:IsDead() then
        if isGolden then
            game:ShakeScreen(20)
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY ,1.5,0,false,1)
            local flash = Isaac.Spawn(1000, 7004, 0, game:GetRoom():GetCenterPos(), Vector.Zero, npc):ToEffect()
            flash.RenderZOffset = 1000000
            room:TurnGold()
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PROJECTILE
                and entity.Variant == 0
                and	entity.SpawnerType == npc.Type
                and	entity.SpawnerVariant == npc.Variant
                and entity.FrameCount < 2 then
                    entity:Remove()
                end
                if entity:IsEnemy() then
                    entity:AddMidasFreeze(EntityRef(npc), 1200)
                end
            end
        else
            local sploshEffect = Isaac.Spawn(1000, 1738, 0, npc.Position, Vector.Zero, npc):ToEffect()
            sploshEffect.SpriteOffset = Vector(0, -10)
            sploshEffect.SpriteScale = Vector(0.8, 0.8)
            sploshEffect:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/projectile_bighemo_blue.png");
            sploshEffect:GetSprite():LoadGraphics()
            sploshEffect.Color = data.Params.Color
            sploshEffect:Update()
        end
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        local vec = mod:SnapVector((targetpos - npc.Position):Resized(8), 90)
        local special
        if isGolden then
            special = "awesomeCoin"
        end
        table.insert(mod.TearFountains, {["Duration"] = 45, ["Spawner"] = npc, ["Params"] = data.Params, ["Special"] = special})
        for i = 0, 240, 120 do
            npc:FireProjectiles(npc.Position, vec:Rotated(i), 1, data.Params)
        end
        for _, proj in pairs(mod:GatherProjectiles(npc)) do
            if proj.Variant == 0 then
                proj:Remove()
            elseif isGolden then
                proj:GetData().projType = "awesomeCoin"
            end
        end
    end
end

function mod:AwesomeCoinGet(projectile, data)
    Isaac.Spawn(5,20,1,projectile.Position,projectile.Velocity,projectile)
end