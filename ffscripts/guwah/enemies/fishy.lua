local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:FishyAI(npc, sprite, data)
    if not data.Init then
        npc.SplatColor = mod.ColorInvisible
        local eternalfriend = Isaac.Spawn(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
        eternalfriend.Parent = npc
        npc.Child = eternalfriend
        eternalfriend:GetData().rotval = mod:RandomInt(0,100)
        eternalfriend:Update()
        data.Init = true
        if rng:RandomFloat() <= 0.5 then
            sprite.FlipX = true
        end
    end
    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
    elseif sprite:IsFinished("Spit") and not data.FlyingFish then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        npc.Velocity = (npc.TargetPosition - npc.Position)/15
        data.FlyingFish = true
    end
    if sprite:IsEventTriggered("Hop") then
        npc.Velocity = RandomVector():Resized(4)
        sfx:Play(SoundEffect.SOUND_SPLATTER, 0.3, 0, false, 0.7)
    elseif sprite:IsEventTriggered("Spawn") then
        local necrotic = Isaac.Spawn(mod.FF.Necrotic.ID, mod.FF.Necrotic.Var, mod.FF.Necrotic.Sub, npc.Position, Vector.Zero, npc):ToNPC()
        if npc:IsChampion() then
            necrotic:MakeChampion(npc.InitSeed, npc:GetChampionColorIdx(), true)
        end
        necrotic.HitPoints = necrotic.MaxHitPoints
        necrotic:GetSprite():Play("AppearFish")
        necrotic:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if npc.Child and npc.Child:Exists() then
            npc.Child:GetData().AnimOverride = true
            npc.Child:GetSprite():Play("TeleportOut")
        end
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        local bingo = (targetpos - npc.Position):Normalized() * math.min(200, (npc.Position - targetpos):Length())
        npc.TargetPosition = game:GetRoom():FindFreeTilePosition(npc.Position + bingo, 40) + (RandomVector())
        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
        sfx:Play(SoundEffect.SOUND_HEARTOUT, 1, 0, false, 1)
    elseif data.FlyingFish then
        if npc.StateFrame >= 15 then
            local fish = Isaac.Spawn(mod.FF.Fish.ID, mod.FF.Fish.Var, mod.FF.Fish.Sub, npc.Position, Vector.Zero, npc)
            fish.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            fish:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
            fish:GetSprite():Play("Land")
            if npc.Child and npc.Child:Exists() then
                fish.Child = npc.Child
                npc.Child.Parent = fish
                npc.Child:GetSprite():Play("TeleportIn")
            else
                fish:GetData().NoFly = true
            end
            npc:Remove()
        else
            npc.StateFrame = npc.StateFrame + 1
        end
    else
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
    end
end

function FiendFolio.FishyDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        if npc.Child and npc.Child:Exists() then
            deathAnim.Child = npc.Child
            npc.Child.Parent = deathAnim
        end
        deathAnim:GetData().Init = true
	end
	FiendFolio.genericCustomDeathAnim(npc, "Spit", true, onCustomDeath, true, true)
end

function FiendFolio.FishyDeathEffect(npc)
    
end

function mod:NecroticAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not sprite:IsPlaying("Appear") and not sprite:IsPlaying("AppearFish") then
        npc:AnimWalkFrame("WalkHori","WalkVert",1)
        local vel 
        if mod:isScare(npc) then
            vel = (targetpos - npc.Position):Resized(-4)
        elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            vel = (targetpos - npc.Position):Resized(4)
        else
            npc.Pathfinder:FindGridPath(targetpos, 0.6, 900, true)
        end
        if vel then
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
        end
    else
        npc.Velocity = Vector.Zero
    end
end

function mod:FishAI(npc, sprite, data)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if not sprite:IsPlaying("Land") then
            sprite:Play("Idle2")
        end
        if not (npc.Child or data.NoFly) then
            local eternalfriend = Isaac.Spawn(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
            eternalfriend.Parent = npc
            npc.Child = eternalfriend
            eternalfriend:GetData().rotval = mod:RandomInt(0,100)
            eternalfriend:Update()
        end
        if rng:RandomFloat() <= 0.5 then
            sprite.FlipX = true
        end
        data.Init = true
    end
    if sprite:IsFinished("Land") then
        sprite:Play("Idle2")
    end
    if sprite:IsEventTriggered("Land") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1.5, 0, false, 0.8)
    end
    npc.Velocity = npc.Velocity * 0.7
end