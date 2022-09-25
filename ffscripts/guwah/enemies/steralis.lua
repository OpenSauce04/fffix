local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:SteralisAI(npc, sprite, data)
    local room = game:GetRoom()
    if not data.init then
        npc:SetSize(npc.Size, Vector(1.5,1), 12)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.resurfaced = npc.FrameCount
        data.lastleap = npc.FrameCount
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc.Visible = false
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
        data.waiting = true
        npc.StateFrame = mod:RandomInt(200,250)
        npc.SpriteOffset = Vector(0,10)
        data.init = true
    end
    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)

    if sprite:IsFinished("Appear") then
        sprite:Play("Intro")
    elseif sprite:IsFinished("tell") then
        sprite:Play("emerge")
        game:ShakeScreen(10)
    elseif sprite:IsFinished("emerge") then
        sprite:Play("idle")
        npc.StateFrame = mod:RandomInt(45,90)
    end
    if data.waiting then
        npc.StateFrame = npc.StateFrame - 1
        if (npc.SubType == 0 and npc.StateFrame <= 0) or mod.CanIComeOutYet() then
            npc.Position = npc:GetPlayerTarget().Position
            if room:GetGridCollisionAtPos(npc.Position) ~= GridCollisionClass.COLLISION_PIT then
                local safe = true
                for _, s in pairs (Isaac.FindByType(npc.Type, npc.Variant, npc.SubType)) do
                    if s.InitSeed ~= npc.InitSeed and s.Position:Distance(npc.Position) - s.Size - npc.Size <= 0 and s.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL then
                        safe = false
                    end
                end
                if safe then
                    sprite:Play("tell")
                    npc.Visible = true
                    npc.StateFrame = 40
                    data.waiting = false
                end
            end
        end
    else
        if sprite:IsPlaying("idle") then
            mod.QuickSetEntityGridPath(npc, 900)
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                sprite:Play("leap")
                npc.StateFrame = mod:RandomInt(45,90)
                data.lastleap = npc.FrameCount
            end
        end
    
        if sprite:IsEventTriggered("collend") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.canDeathAnim = false
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
        end
    
        if sprite:IsEventTriggered("collstart") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            data.canDeathAnim = true
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
            sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_3, 1.5)
            sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
            local params = ProjectileParams()
            params.FallingAccelModifier = 2
            for _ = 1, mod:RandomInt(12, 20) do
                params.FallingSpeedModifier = mod:RandomInt(-30, -10) * 1.5
                params.Variant = mod:RandomInt(0,1)
                npc:FireProjectiles(npc.Position, Vector(30, 0):Rotated(mod:RandomAngle()):Resized(0.5 * mod:RandomInt(3,10)), 0, params)
            end
            for _ = 1, mod:RandomInt(4, 7) do
                local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(mod:RandomInt(2,8)), npc)
                if mod.roomBackdrop == 10 or mod.GetEntityCount(150,1000,10) > 0 then
                    rubble:GetData().changespritesheet = "gfx/grid/morbus/morbus_rocks.png"
                end
                rubble:Update()
            end
            game:ShakeScreen(10)
            game:BombDamage(npc.Position, 0, npc.Size * 1.5, true, npc, 0, 0, npc)
        end
    
        if sprite:IsEventTriggered("rocksound") then
            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.7, 0, false, mod:RandomInt(9, 11)/10)
            game:ShakeScreen(5)
        end
    
        if sprite:IsEventTriggered("impact") and not data.FFIsDeathAnimation then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            data.canDeathAnim = true
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
            sfx:Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
            local params = ProjectileParams()
            params.Variant = 1
            npc:FireProjectiles(npc.Position, Vector(8,10), 9, params)
            game:ShakeScreen(10)
            for _ = 1, mod:RandomInt(3, 5) do
                local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(mod:RandomInt(2,8)), npc)
                if mod.roomBackdrop == 10 or mod.GetEntityCount(150,1000,10) > 0 then
                    rubble:GetData().changespritesheet = "gfx/grid/morbus/morbus_rocks.png"
                end
            end
        end
    
        if sprite:IsEventTriggered("wormnoise") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.canDeathAnim = false
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
            sfx:Play(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.6)
        end
    
        if (sprite:IsFinished("leap") or sprite:IsFinished("Intro")) and npc.FrameCount > 40 then
            npc.Position = npc:GetPlayerTarget().Position
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 and room:GetGridCollisionAtPos(npc.Position) ~= GridCollisionClass.COLLISION_PIT then
                local safe = true
                for _, s in pairs (Isaac.FindByType(npc.Type, npc.Variant, npc.SubType)) do
                    if s.InitSeed ~= npc.InitSeed and s.Position:Distance(npc.Position) - s.Size - npc.Size <= 0 and s.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL then
                        safe = false
                    end
                end
                if safe then
                    sprite:Play("tell")
                    npc.Visible = true
                    npc.StateFrame = 20
                    data.resurfaced = npc.FrameCount
                end
            end
        end
    
        if sprite:IsFinished("death") then
            npc:Remove()
        end
    end
end

function FiendFolio.SteralisDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        deathAnim:GetData().init = true
    end
    if npc:GetData().canDeathAnim then
        mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_1, npc, 0.6)
        FiendFolio.genericCustomDeathAnim(npc, "death", true, onCustomDeath, false, false, true, true)
    end
    game:ShakeScreen(5)
end