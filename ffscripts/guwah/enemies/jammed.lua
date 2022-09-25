local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:JammedAI(npc, sprite, data)
    local isRed = npc.SubType == mod.FF.RedJammed.Sub
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if sprite:IsOverlayPlaying("HeadAttack") then
        npc.Velocity = Vector.Zero
        sprite:SetFrame("WalkVert", 0)
        if sprite:GetOverlayFrame() == 23 and not data.Shooted then
            mod:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, npc)
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
            mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 1.5, 0.6)
            local smidgevar
            if isRed then
                smidgevar = mod.FF.RedSmidgen.Var
            else
                smidgevar = mod.FF.Smidgen.Var
            end 
            local vel = targetpos - npc.Position
            local smidgen = Isaac.Spawn(mod.FF.Smidgen.ID, smidgevar, 0, npc.Position + vel:Resized(20), vel:Resized(5), npc)
            if isRed then
                smidgen:GetSprite():Play("Shoot")
                smidgen:GetData().state = "shoot"
                smidgen:GetData().ShootInit = true
            end
            smidgen:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            local effect = Isaac.Spawn(1000,2,4,npc.Position,Vector.Zero,npc)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
            effect.SpriteOffset = Vector(0,-5)
            data.Shooted = true
        end
    elseif sprite:IsOverlayFinished("HeadAttack") then
        data.Shooted = false
    end
    if npc:IsDead() then
        local hostletvar
        local hostletsub
        if isRed then
            hostletvar = mod.FF.RedHostlet.Var
            hostletsub = mod.FF.RedHostlet.Sub
        else
            hostletvar = mod.FF.Hostlet.Var
            hostletsub = mod.FF.Hostlet.Sub
        end 
        local hostlet = Isaac.Spawn(mod.FF.Hostlet.ID, hostletvar, hostletsub, npc.Position, Vector.Zero, npc)
        hostlet:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        table.insert(mod.JamDeletions, {["Position"] = npc.Position, ["Duration"] = 1})
    end
end

function mod:JamDeletion(zone)
    --If I remove the duration part it doesnt work idk this game is jank
    zone.Duration = zone.Duration - 1
    for _, enemy in pairs(Isaac.FindInRadius(zone.Position, 20, EntityPartition.ENEMY)) do
        if enemy.Type == 29 or enemy.Type == 94 then
            if enemy.FrameCount < 1 then
                enemy:Remove()
            end
        end
    end
    if zone.Duration <= 0 then
        zone = nil
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local data = npc:GetData()
    if data.IsHostlet then
        mod:HostletAI(npc, npc:GetSprite(), data)
    --Just gonna give vanilla Hosts shooting SFX don't mind me
    elseif npc.Variant <= 1 and npc.SubType == 0 and npc:GetSprite():IsEventTriggered("Shoot") then
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
    end
end, EntityType.ENTITY_HOST)

function mod:HostletAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if sprite:IsEventTriggered("HostletShoot") then
        local params = ProjectileParams()
        params.Scale = 0.75
        params.FallingSpeedModifier = 1.8
        params.HeightModifier = 5
        if npc.SubType == mod.FF.RedHostlet.Sub then
            for i = -60, 60, 30 do
                npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(7):Rotated(i), 0, params)
            end
        else
            for i = -45, 45, 45 do
                npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(7):Rotated(i), 0, params)
            end
        end
        local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc)
        effect.DepthOffset = npc.Position.Y * 1.25
        effect.SpriteOffset = Vector(0,-5)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2)
    end
end