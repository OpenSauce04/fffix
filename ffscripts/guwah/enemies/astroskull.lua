local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()
local music = MusicManager()

function mod:AstroskullAI(npc, sprite, data)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        local numskulls = math.floor(npc.SubType / 2) --Why is math.floor even neccessary here??
        local CC = npc.SubType % 2 == 1
        for i = 1, numskulls do
            local angle = (360/numskulls) * i
            local lil = Isaac.Spawn(mod.FF.LilJunkie.ID, mod.FF.LilJunkie.Var, 0, npc.Position + Vector(30,0):Rotated(angle), Vector.Zero, npc)
            lil.Parent = npc
            local lildata = lil:GetData()
            lildata.Angle = angle
            if CC then
                lildata.CC = true
                sprite:Load("gfx/enemies/astroskull/monster_craterhead_alt.anm2", true)
                sprite:SetFrame("Idle", 0)
            end
        end
        npc.SplatColor = Color.Default
        data.Init = true
    end
    if game:GetRoom():IsClear() then
        npc.State = 18
    else
        if npc.State == 18 then
            sfx:Stop(SoundEffect.SOUND_DEVILROOM_DEAL)
        end
        npc.State = 4
    end
end

function mod:AstroskullRender(npc, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        if sprite:IsEventTriggered("Break") and not data.Broken then
            npc:BloodExplode()
            data.Broken = true
        elseif sprite:IsFinished("Death") then
            npc:Remove()
        end
    end
end

function mod:LilJunkieAI(npc, sprite, data)
    if not data.Init then
        data.Counter = 30
        npc.StateFrame = mod:RandomInt(60,150)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        data.state = "idle"
        data.Init = true
    end
    if data.state == "idle" then
        if data.blinkin then
            if sprite:IsFinished("Blink") then
                npc.StateFrame = mod:RandomInt(60,150)
                data.blinkin = false
            else
                mod:spritePlay(sprite, "Blink")
            end
        else
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.blinkin = true
            else
                mod:spritePlay(sprite, "Idle")
            end
        end
        if npc.Parent and not mod:IsReallyDead(npc.Parent) then
            if npc.FrameCount > 30 then
                data.Counter = data.Counter + 0.25
            end
            if data.CC then
                data.Angle = data.Angle - 3
            else
                data.Angle = data.Angle + 3
            end
            data.Distance = (40 * (1 + math.sin(math.rad(9 * data.Counter)))) + 30
            npc.TargetPosition = mod:GetSyncedPos(npc, npc.Parent) + Vector.One:Resized(data.Distance):Rotated(data.Angle)
            npc.Velocity = npc.TargetPosition - npc.Position
        else
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.Velocity = Vector.Zero
            data.state = "death"
        end
    elseif data.state == "death" then
        if sprite:IsFinished("Death") then
            npc:Remove()
        elseif sprite:IsEventTriggered("Break") then
            npc:BloodExplode()
            mod:LilJunkieDeath(npc)
        else
            mod:spritePlay(sprite, "Death")
        end
    end
end

function mod:LilJunkieDeath(npc)
    sfx:Stop(SoundEffect.SOUND_DEATH_BURST_BONE)
    mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, npc, 1.5)
end

function mod:GetSyncedPos(npc, parent)
    local returnpos = parent.Position
    if npc.Index < parent.Index then
        returnpos = returnpos + parent.Velocity
    end
    return returnpos
end