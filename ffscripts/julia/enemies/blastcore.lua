local mod = FiendFolio
local game = Game()

local function targetCloserToCardinals(npc, target)
    local angle = (target.Position - npc.Position):GetAngleDegrees()

    if target.Position.Y < npc.Position.Y then angle = angle + 360 end

    if (angle >= 30 and angle < 60) or (angle >= 120 and angle < 150) or (angle >= 210 and angle < 240) or (angle >= 300 and angle < 330) then
        return false
    else
        return true
    end
end

local function angleWrap(angle)
    while angle > 360 do
        angle = angle - 360
    end

    while angle < 0 do
        angle = 360 + angle
    end

    --print(angle)
    return math.floor(angle)
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    if npc.Variant == mod.FF.Blastcore.Var then
        if data.FFIsDeathAnimation then
            mod:spritePlay(sprite, "Death")
            if sprite:IsFinished("Death") then
                FiendFolio.BlastcoreDeathEffect(npc)
                npc:Kill()
            end
        else
       

            local player = npc:GetPlayerTarget()

            local target_pos = mod:confusePos(npc, player.Position)

            local vel = npc.Velocity

            if not data.init then
                npc.State = 8
                npc.StateFrame = 0
                npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
                data.IgnoreToxicShock = true
                data.init = true
            end

            vel = ((target_pos - player.Velocity * (npc.State - 7)) - npc.Position):Resized(npc.State - 5 + 1) --loosely chase the player

            if npc.State == 10 then
                vel = vel + vel:Normalized():Rotated(90) * (math.sin(npc.StateFrame * (math.pi / 30)) * 3) --variation

                if npc.StateFrame % 10 == 0 then
                    local smoke = Isaac.Spawn(1000, 88, 0, npc.Position - Vector(0, 10), Vector(math.random(0, 5) - 5, -10), npc):ToEffect()
                    smoke.SpriteScale = smoke.SpriteScale * (math.random(3,6)/10)
                    smoke.Color = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
                    smoke.DepthOffset = -50
                    --smoke.SpriteOffset = Vector(-10 + math.random(20), 0)
                end
            end

            --sprite stuff


            if data.interval and npc.FrameCount % data.interval == 0 then
            local fire = Isaac.Spawn(1000,7005, 20, npc.Position, Vector.Zero, npc):ToEffect()
            fire:GetData().timer = 15
            fire:GetData().gridcoll = 0
            fire:GetData().scale = 0.5
            fire.Parent = npc
                fire:Update()
            end
            if npc.Position:Distance(player.Position) < 80 then --open mouth if close to player
                mod:spritePlay(sprite, "Idle0"..math.max(math.min(3, npc.State - 6), 1))
            else
                mod:spritePlay(sprite, "Idle0"..npc.State - 7)
            end

            --fear handling
            vel = mod:reverseIfFear(npc, vel)

            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.15)

            npc.StateFrame = npc.StateFrame + 1
        end
    end
end, 170)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
    if ent.Variant == mod.FF.Blastcore.Var then
        ent = ent:ToNPC()
        local data = ent:GetData()
        if (mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, flags) or mod:HasDamageFlag(DamageFlag.DAMAGE_CRUSH, flags)) and not mod:IsPlayerDamage(source) then --resist fire and rock waves
            return false
        end

        if ent.State == 8 and ent.HitPoints - damage <= ent.MaxHitPoints / 2 then --blast
            ent:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A, 0.8, 0, false, 0.9)
            data.interval = 10
            ent.State = 9
            ent.StateFrame = 0
        end

        if ent.State == 9 and ent.HitPoints - damage <= ent.MaxHitPoints / 4 then --core
            ent:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A, 1, 0, false, 1.1)
            data.interval = 5
            ent.State = 10
            ent.StateFrame = 0
        end
    end
end, 170)

function FiendFolio.BlastcoreDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        deathAnim:GetData().targetpos = npc:GetPlayerTarget().Position
        deathAnim:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        local angle = (deathAnim:GetData().targetpos - deathAnim.Position):GetAngleDegrees()
        local tracer = Isaac.Spawn(1000, 198, 0, deathAnim.Position + Vector(10, 0):Rotated(angle), Vector(0.001,0), deathAnim):ToEffect()
        tracer.Timeout = 20
        tracer.TargetPosition = Vector(1,0):Rotated(angle)
        tracer.LifeSpan = 15
        tracer:FollowParent(deathAnim)
        tracer.SpriteScale = Vector(3,0.0001)
        tracer.Color = Color(0.5,0.2,0,0.8,0,0,0)
        tracer:Update()
        deathAnim:GetData().init = true
    end
    FiendFolio.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, false, false, true, true)
end

function FiendFolio.BlastcoreDeathEffect(npc)
	local data = npc:GetData()

    --npc:PlaySound(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0, false, 1)

    --local start_i = 45
    --local end_i = 315
    --local step = 90

    --OLD BEHAVIOR: spawn cardinal or diagonal rock waves depending on where the player is

    --if targetCloserToCardinals(npc, npc:GetPlayerTarget()) then
    --    start_i = 0
    --    end_i = 270
    --end

    --NEW BEHAVIOR: box the player in between rock waves
    local targetpos = data.targetpos
    local angle = (targetpos - npc.Position):GetAngleDegrees()

    if targetpos.Y < npc.Position.Y then angle = angle + 360 end

    local r = npc:GetDropRNG()
    local params = ProjectileParams()
    params.Variant = 9
    params.FallingAccelModifier = 1.5
    params.Scale = 1
    mod:SetGatheredProjectiles()
    for i = 60, 360, 60 do
        params.FallingSpeedModifier = -30 + math.random(10)
        local rand = r:RandomFloat()
        npc:FireProjectiles(npc.Position, Vector.One:Resized(mod:RandomInt(2,6)):Rotated(i-40+rand*80), 0, params)
    end
    for _, proj in pairs(mod:GetGatheredProjectiles()) do
        local pSprite = proj:GetSprite()
        pSprite:ReplaceSpritesheet(0, "gfx/projectiles/charredrock_proj.png")
        pSprite:LoadGraphics()
        proj:GetData().toothParticles = Color(50/255, 30/255, 30/255, 1, 0, 0, 0)
        proj:GetData().customProjSplat = "gfx/projectiles/charredrock_splat.png"
    end
    --[[local distance = 80
    local start_i = angleWrap(angle - distance/2)
    local end_i = angleWrap(angle + distance/2)
    local wave = Isaac.Spawn(1000, 62, 1, npc.Position, Vector.Zero, npc):ToEffect()
    wave:GetData().custom = true
    wave:GetData().direction = start_i
    wave = Isaac.Spawn(1000, 62, 1, npc.Position, Vector.Zero, npc):ToEffect()
    wave:GetData().custom = true
    wave:GetData().direction = end_i]]
    local wave = Isaac.Spawn(1000,150,0,npc.Position,Vector.Zero,npc):ToEffect()
    wave.Rotation = angle
    wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
    wave.Parent = npc
    wave.MaxRadius = 30
    game:ShakeScreen(15)
    table.insert(mod.FireShockwaves, {["Spawner"] = npc, ["Position"] = npc.Position}) -- fire effect BUT SWAG
    Isaac.Explode(npc.Position, npc, 40)
    --[[local swave = Isaac.Spawn(1000, 148, 0, npc.Position, Vector.Zero, npc):ToEffect()
    swave.Rotation = angle]]
end

--custom rock wave stuff
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, ent)
    local data = ent:ToEffect():GetData()

    if data.custom and data.direction then
        local room = game:GetRoom()

        if ent.FrameCount == 3 then
            local new_pos = ent.Position + Vector.FromAngle(data.direction) * 30

            if room:GetClampedPosition(new_pos, 0):Distance(new_pos) == 0 then
                local grid_ent = room:GetGridEntity(room:GetGridIndex(ent.Position))

                if grid_ent then
                    if grid_ent.Desc.Type == GridEntityType.GRID_PIT or grid_ent.Desc.Type == GridEntityType.GRID_ROCKB then
                        return
                    elseif grid_ent.Desc.Type == GridEntityType.GRID_ROCK_BOMB and grid_ent.State ~= 2 then
                        grid_ent:Destroy(true)
                        Isaac.Explode(grid_ent.Position, ent, 40)
                        return
                    elseif grid_ent.Desc.Type == GridEntityType.GRID_TNT and grid_ent.State ~= 2 then
                        grid_ent:Destroy(true)
                        Isaac.Explode(grid_ent.Position, ent, 40)
                    elseif not (grid_ent.Desc.Type == GridEntityType.GRID_DOOR or grid_ent.Desc.Type == GridEntityType.GRID_WALL) then
                        grid_ent:Destroy(true)
                        --room:DamageGrid(room:GetGridIndex(ent.Position), 1)
                    end  
                end

                local wave = Isaac.Spawn(1000, 62, ent.SubType, new_pos, Vector.Zero, ent):ToEffect()
                wave:GetData().custom = true
                wave:GetData().direction = data.direction
            end
        end

        --local grid_ent = room:GetGridEntity(room:GetGridIndex(ent.Position))
    
        --destroy grid entities
        --if grid_ent then
        --    if not (grid_ent.Desc.Type == GridEntityType.GRID_DOOR or grid_ent.Desc.Type == GridEntityType.GRID_WALL) then
        --       grid_ent:Destroy(true)
        --    end
        --end

        for _, e in ipairs(Isaac.FindInRadius(ent.Position, 20)) do
            --fireplaces
            if e.Type == EntityType.ENTITY_FIREPLACE then
                e:TakeDamage(1, 0, EntityRef(ent), 0)
            --stone chests
            elseif e.Type == EntityType.ENTITY_PICKUP and e.Variant == 51 then
                e:ToPickup():TryOpenChest()
            --enemies
            elseif e:IsVulnerableEnemy() then
                e:TakeDamage(10, DamageFlag.DAMAGE_CRUSH, EntityRef(ent), 0)
            --player
            elseif e.Type == 1 then
                e:TakeDamage(1, DamageFlag.DAMAGE_CRUSH, EntityRef(ent), 0)
            end
        end
    end
end, 62)