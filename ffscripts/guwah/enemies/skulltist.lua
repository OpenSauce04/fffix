local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

--Other mods can use this function to make their enemies target-able by Skulltists
function mod:AddToSkulltistWhitelist(highPriority, type, variant, subtype, dontClearAppear)
    variant = variant or -1
    subtype = subtype or -1
    local entry = {type, variant, subtype, highPriority, dontClearAppear}
    table.insert(mod.SkulltistWhitelist, entry)
end

function mod:SkulltistAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        sprite:Play("Idle")
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.StateFrame = mod:RandomInt(30,60)
        data.Skulltist = true
        data.Trajectory = Vector.One:Resized(3):Rotated(mod:RandomAngle())
        npc.I1 = mod:RandomInt(20,30)
        data.Exhaustion = 1
        data.Init = true
    end
    if sprite:IsPlaying("Idle") then
        if npc.StateFrame <= 0 then
            sprite:Play("Attack")
        else
            npc.StateFrame = npc.StateFrame - 1
        end
        if npc.I1 <= 0 then
            npc.I1 = mod:RandomInt(10,15)
            if targetpos:Distance(npc.Position) < 100 or mod:isScare(npc) then
                data.Trajectory = (targetpos - npc.Position):Resized(7):Rotated(mod:RandomInt(-15,15))
            else
                data.Trajectory = (npc.Position - targetpos):Resized(5):Rotated(mod:RandomInt(-120,120))
            end
        else
            npc.I1 = npc.I1 - 1
        end
        npc.Velocity = mod:Lerp(npc.Velocity, npc.Position - (npc.Position + data.Trajectory), 0.1)
    else
        npc.Velocity = Vector.Zero
    end
    if sprite:IsFinished("Attack") then
        sprite:Play("Idle")
    end
    if sprite:IsEventTriggered("Shoot") then
        local filtertag = "SkulltistHighPriority"
        local skulltistFilter = function(position, candidate)
            if candidate:GetData()[filtertag] and mod:isFriend(candidate) == mod:isFriend(npc) then
                return true
            else
                return false
            end
        end
        local enemy = mod:GetNearestEnemy(targetpos, 1000, skulltistFilter)
        if enemy then
            mod:DoSkulltistDeath(npc, enemy)
            npc.StateFrame = mod:RandomInt(100,130)
        else
            filtertag = "SkulltistLowPriority"
            enemy = mod:GetNearestEnemy(targetpos, 1000, skulltistFilter)
            if enemy then
                mod:DoSkulltistDeath(npc, enemy)
                npc.StateFrame = mod:RandomInt(70,100)
            else
                Isaac.Spawn(61, 0, 0, npc.Position + (targetpos - npc.Position):Resized(30), Vector.Zero, npc)
                npc.StateFrame = mod:RandomInt(15 * data.Exhaustion,20 * data.Exhaustion)
                data.Exhaustion = data.Exhaustion + 1
            end
        end
        npc:PlaySound(SoundEffect.SOUND_RAGMAN_1, 0.7, 0, false, 0.8)
        sfx:Play(SoundEffect.SOUND_SUMMONSOUND)    
    end
end

function mod:DoSkulltistDeath(npc, enemy)
    local victim = Isaac.Spawn(enemy.Type, enemy.Variant, enemy.SubType, enemy.Position, Vector.Zero, nil):ToNPC()
    victim = victim:ToNPC()
    victim:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_NO_REWARD + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_EXTRA_GORE)
    if not enemy:GetData().SkulltistDontClearAppear then
        victim:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
    if enemy.MaxHitPoints > 0 then
        victim.MaxHitPoints = enemy.MaxHitPoints
    else
        victim.MaxHitPoints = 1
    end
    if enemy.HitPoints > 0 then
        victim.HitPoints = enemy.HitPoints
    else
        victim.HitPoints = 1
    end
    if enemy:IsChampion() and not enemy:GetChampionColorIdx() == ChampionColor.DARK_RED then
        victim:MakeChampion(69, enemy:GetChampionColorIdx(), true)
    end
    victim.SplatColor = enemy.SplatColor
    if enemy:HasEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH) then
        victim:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    end
    victim.Visible = false
    victim:GetData().SkulltistVictim = true
    mod:SkulltistCaseChecks(enemy, victim)
    if enemy:GetData().GrimoireEnchanted then
        local projectile = Isaac.Spawn(9,0,0,enemy.Position,Vector.Zero,victim):ToProjectile()
        projectile.Color = mod.ColorMausPurple
        projectile.Scale = 2
        projectile.Height = -45
        projectile.FallingAccel = 1
        projectile:GetData().projType = "purpleFlameCross"
    end
    victim:Kill()
    local beam = Isaac.Spawn(1000,7010,1,enemy.Position,Vector.Zero,npc):ToEffect()
    if mod:CheckStage("Gehenna", {47}) then
        beam:GetSprite().Color = Color(1,0,0,1,0.2,0.2,0.2)
    else
        beam:GetSprite().Color = Color(1,0.5,0.7,1)
    end
    beam:FollowParent(enemy)
    npc:GetData().Exhaustion = 1
end

--Not used atm, keeping just in case
function mod:SkulltistCaseChecks(enemy, victim)
    local spawns = {}
    for _, spawn in pairs(spawns) do
        spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

function mod:SkulltistWhitelistCheck(npc) 
    for _, entry in pairs(FiendFolio.SkulltistWhitelist) do
        if mod:CheckID(npc, entry) then
            if entry[4] then
                npc:GetData().SkulltistHighPriority = true
            else
                npc:GetData().SkulltistLowPriority = true
            end
            if entry[5] then
                npc:GetData().SkulltistDontClearAppear = true
            end
            return true
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if npc.Variant == mod.FF.PossessedCorpse.Var then
        if npc.SpawnerEntity and npc.SpawnerEntity:GetData().SkulltistVictim then
            npc:Remove()
        end
    end
end, mod.FF.PossessedCorpse.ID)