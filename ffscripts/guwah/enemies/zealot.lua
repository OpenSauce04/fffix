local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ZealotAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local crosshair = data.Crosshair
    if not data.Init then
        npc.I1 = 0
        npc.Velocity = Vector.Zero
        npc.SplatColor = mod.ColorDankBlackReal
        data.Vel = 1
        data.Init = true
    end
    mod.QuickSetEntityGridPath(npc)
    if (targetpos:Distance(npc.Position) < 80 or mod:isScare(npc)) and npc.I1 <= 0 then
        npc.Velocity = (npc.Position - targetpos):Resized(5)
        npc.I1 = 10
    else
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
        npc.I1 = npc.I1 - 1
    end
    if sprite:IsPlaying("Idle") then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            sprite:Play("Focus")
            npc.StateFrame = 30
        end
    elseif sprite:IsPlaying("Focusing") then
        if crosshair then
            if not crosshair:Exists() then
                sprite:Play("Appear")
                data.Vel = 1
            else
                if crosshair:GetData().TargetLock or crosshair.Position:Distance(target.Position) < 10 then
                    if not crosshair:GetData().TargetLock then
                        crosshair:GetData().TargetLock = target
                    end
                    crosshair.Velocity = crosshair:GetData().TargetLock.Position - crosshair.Position
                    npc.StateFrame = npc.StateFrame - 1
                    data.Vel = 1
                else
                    crosshair.Velocity = mod:Lerp(crosshair.Velocity, (targetpos - crosshair.Position):Resized(data.Vel), 0.3)
                    data.Vel = data.Vel + 0.1
                end
                if npc.StateFrame <= 0 then
                    sfx:Play(mod.Sounds.ZealotLockOn)
                    sprite:Play("Summoning Beam")
                end
            end
        end
    end
    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(10,60)
    elseif sprite:IsFinished("Focus") then
        sprite:Play("Focusing")
    elseif sprite:IsFinished("Summoning Beam") then
        sprite:Play("Idle")
        npc.StateFrame = mod:RandomInt(130,170)
    end
    if sprite:IsEventTriggered("Targeting") then
        data.Crosshair = Isaac.Spawn(1000,mod.FF.ZealotCrosshair.Var,mod.FF.ZealotCrosshair.Sub,npc.Position + (targetpos - npc.Position):Resized(30),Vector.Zero,npc):ToEffect()
        data.Crosshair.Visible = false
        sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE)
    elseif sprite:IsEventTriggered("Crosshair Lock") then
        if crosshair then
            crosshair:GetData().LockedVel = true
        end
    elseif sprite:IsEventTriggered("Shoot") then
        if crosshair then
            crosshair:GetSprite():Play("Shoot")
        end
    end
end

function mod:ZealotCrosshairAI(effect, sprite, data)
    if not data.Init then
        sprite:Play("Appear")
        effect.Visible = true
        data.Init = true
    end
    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
    elseif sprite:IsFinished("Shoot") then
        effect:Remove()
    end
    if data.LockedVel then
        effect.Velocity = Vector.Zero
    end
    if sprite:IsEventTriggered("Shoot") and not data.Disarmed then
        Isaac.Spawn(1000,mod.FF.ZealotBeam.Var,mod.FF.ZealotBeam.Sub,effect.Position,Vector.Zero,effect.SpawnerEntity)
    end
    if effect.SpawnerEntity then
        if (effect.SpawnerEntity:IsDead() or mod:isStatusCorpse(effect.SpawnerEntity)) and not sprite:IsPlaying("Shoot") then
            sprite:Play("Shoot")
            data.Disarmed = true
            data.LockedVel = true
        end
    else
		sprite:Play("Shoot")
        data.Disarmed = true
        data.LockedVel = true
	end
    effect.DepthOffset = 0
end

function mod:ZealotBeamInit(effect)
    local sprite = effect:GetSprite()
    if mod:CheckStage("Cathedral", {15}) or mod:CheckStage("Chest", {17}) then
        for i = 0, 2 do
            sprite:ReplaceSpritesheet(i, "gfx/enemies/zealot/monster_zealot_cathedral.png")
        end
        sprite:LoadGraphics()
    end
end

function mod:ZealotBeamAI(effect, sprite, data)
    if not data.Init then
        sprite:Play("Appear")
        sfx:Play(mod.Sounds.ZealotBoom, 0.8)
        if effect.SpawnerEntity then
            if mod:isFriend(effect.SpawnerEntity) then
                data.Partition = EntityPartition.ENEMY
            elseif mod:isCharm(effect.SpawnerEntity) then
                data.Partition = EntityPartition.PLAYER + EntityPartition.ENEMY
            else
                data.Partition = EntityPartition.PLAYER
            end
        else
            data.Partition = EntityPartition.PLAYER
        end
        data.Init = true
    end
    if sprite:IsFinished("Appear") then
        sprite:Play("Loop")
    end
    if sprite:IsFinished("Disappear") then
        effect:Remove()
    elseif not sprite:IsPlaying("Disappear") then
        if not sfx:IsPlaying(mod.Sounds.ZealotHum) then
            sfx:Play(mod.Sounds.ZealotHum, 0.2, 0, true)
        end
        for _, entity in pairs(Isaac.FindInRadius(effect.Position, 32, data.Partition)) do
            if math.abs(entity.Position.Y - effect.Position.Y) <= 20 then
                entity:TakeDamage(2, 0, EntityRef(effect), 0)
            end
        end
        if effect.FrameCount > 160 or game:GetRoom():IsClear() then
            sprite:Play("Disappear")
            sfx:Play(mod.Sounds.ZealotFade, 0.2)
            Isaac.Spawn(1000,18,1,effect.Position,Vector.Zero,effect)
        end
    end
    if sprite:IsPlaying("Disappear") and sprite:GetFrame() == 9 then
        sfx:Stop(mod.Sounds.ZealotHum)
    end
end