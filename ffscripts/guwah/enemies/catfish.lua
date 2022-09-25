local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:CatfishAI(npc, sprite, data)
    local room = game:GetRoom()
    if not data.Init then
        data.Index = room:GetGridIndex(npc.Position)
        if npc.SubType == 1 then
            mod.makeWaitFerr(npc, npc.Type, npc.Variant, 0, 30)
        else
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            if data.waited then
                npc.Visible = true
                mod.OccupiedGrids[data.Index] = "Closed"
            end
            sprite:Play("Appear")
        end
        if room:GetFrameCount() <= 1 then
            room:SpawnGridEntity(data.Index, GridEntityType.GRID_PIT, 0, 0, 0)
        end
        data.Init = true
    end
    mod.NegateKnockoutDrops(npc)
    if sprite:IsFinished("Appear") or sprite:IsFinished("Emerge") then
        sprite:Play("Idle")
        data.Moved = false
        if sprite:IsFinished("Appear") then
            if data.Established then
                npc.StateFrame = mod:RandomInt(30,60)
            else
                npc.StateFrame = mod:RandomInt(15,30)
                data.Established = true
            end
        else
            npc.StateFrame = mod:RandomInt(80,110)
        end
    elseif sprite:IsFinished("Spawn") or sprite:IsFinished("Submerge") then
        if not data.Moved then
            mod.OccupiedGrids[data.Index] = "Open"
            data.Index = mod:GetUnoccupiedPit(data.Index)
            mod.OccupiedGrids[data.Index] = "Closed"
            npc.StateFrame = mod:RandomInt(30,45)
            data.Moved = true
        else
            if npc.StateFrame <= 0 then
                sprite:Play("Emerge")
            else
                npc.StateFrame = npc.StateFrame - 1
            end
        end
    end
    if sprite:IsPlaying("Idle") then
        if npc.StateFrame <= 0 then
            local cap = math.max(3, mod.GetEntityCount(mod.FF.Catfish.ID, mod.FF.Catfish.Var) * 2)
            if cap > mod.GetEntityCount(mod.FF.Mayfly.ID, mod.FF.Mayfly.Var) then
                sprite:Play("Spawn")
            else
                sprite:Play("Submerge")
            end
        else
            npc.StateFrame = npc.StateFrame - 1
        end
    end
    if sprite:IsEventTriggered("Splash") then
        Isaac.Spawn(1000,132,0,npc.Position,Vector.Zero,npc)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        npc:PlaySound(mod.Sounds.SplashLarge,0.6,0,false,1.2)
    elseif sprite:IsEventTriggered("Spawn") then
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        local vel = (targetpos - npc.Position):Resized(10)
        local mayfly = Isaac.Spawn(mod.FF.Mayfly.ID, mod.FF.Mayfly.Var, 0, npc.Position + vel:Resized(30), vel, npc)
        mayfly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        mod:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, npc)
    elseif sprite:IsEventTriggered("Submerge") then
        Isaac.Spawn(mod.FF.LargeWaterRipple.ID, mod.FF.LargeWaterRipple.Var, mod.FF.LargeWaterRipple.Sub, npc.Position, Vector.Zero, npc)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_HIDE_HP_BAR)
        npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
    end
    npc.Position = room:GetGridPosition(data.Index)
    npc.Velocity = Vector.Zero
end

function mod:LargeWaterRippleInit(effect)
    if mod:CheckStage("Dross", {45}) then
        effect.Color = Color(0.5,0.4,0.2)
    end
end

function mod:LargeWaterRippleAI(effect, sprite, data)
    if not data.Init then
        sprite:Play("Poof")
    end
    if sprite:IsFinished("Poof") then
        effect:Remove()
    end
end