local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function GetAvaliableNervieGroup(rng, lastgroup)
    local choices = {}
    local otherchoice
    for group, status in pairs(mod.ActiveNervieGroups) do
        if status == "Open" then
            if lastgroup and group == lastgroup then
                otherchoice = group
            else
                table.insert(choices, group)
            end
        end
    end
    local group = mod:GetRandomElem(choices)
    if group then
        mod.ActiveNervieGroups[group] = "Closed"
        return group
    else
        return otherchoice
    end
end

function mod:PlexusAI(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:SetSize(npc.Size, Vector(2,1), 12)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.StateFrame = mod:RandomInt(60,90,rng)
        data.NervieWaves = {}
        data.WaveTimer = 0
        data.State = "Idle"
        data.Init = true
    end
    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    mod.QuickSetEntityGridPath(npc, 900)

    if data.State == "Idle" then
        mod:spritePlay(sprite, "idle")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.NervieGroup = GetAvaliableNervieGroup(rng, data.LastGroupChosen)
            if data.NervieGroup then
                data.State = "Attack"
            else
                npc.StateFrame = mod:RandomInt(15,30,rng)
            end
        end
    elseif data.State == "Attack" then
        if sprite:IsFinished("fire") then
            npc.StateFrame = mod:RandomInt(120,150,rng)
            data.LastGroupChosen = data.NervieGroup
            mod.ActiveNervieGroups[data.NervieGroup] = "Open"
            data.NervieGroup = nil
            data.State = "Idle"
        elseif sprite:IsEventTriggered("SpawnNerves") then
            for _, nervies in pairs(mod.NervieData) do
                if nervies.Group == data.NervieGroup then
                    local nervie = Isaac.Spawn(mod.FF.Nervie.ID, mod.FF.Nervie.Var, 0, nervies.Position, Vector.Zero, npc)
                    nervie.Parent = npc
                    nervie.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    nervie.Visible = false
                    nervie:Update()

                    if nervies.Angle then
                        local wavedata = {}
                        wavedata.Angle = nervies.Angle
                        wavedata.Position = nervies.Position
                        wavedata.Nervie = nervie
                        table.insert(data.NervieWaves, wavedata)
                        data.WaveTimer = 6
                        nervie:GetData().Duration = 10
                    end
                end
                mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 0.6)
            end
        elseif sprite:IsEventTriggered("TriggerNerves") then
            for _, nervie in pairs(Isaac.FindByType(mod.FF.Nervie.ID, mod.FF.Nervie.Var)) do
                if nervie.Parent and nervie.Parent.InitSeed == npc.InitSeed then
                    nervie:GetData().State = "Emerge"
                end
            end
            mod:PlaySound(SoundEffect.SOUND_WEIRD_WORM_SPIT, npc, 0.6, 0.5)
            mod:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A, npc, 0.6, 1.2)
        else
            mod:spritePlay(sprite, "fire")
        end
    end

    data.WaveTimer = data.WaveTimer - 1
    if data.WaveTimer <= 0 then
        for _, wave in pairs(data.NervieWaves) do
            local halfwaypos = wave.Position + Vector(20,0):Rotated(wave.Angle)
            local newpos = wave.Position + Vector(40,0):Rotated(wave.Angle)
            if game:GetRoom():GetGridCollisionAtPos(halfwaypos) <= GridCollisionClass.COLLISION_NONE and game:GetRoom():GetGridCollisionAtPos(newpos) <= GridCollisionClass.COLLISION_NONE then
                wave.Position = newpos
                local nervie = Isaac.Spawn(mod.FF.Nervie.ID, mod.FF.Nervie.Var, 0, wave.Position, Vector.Zero, npc)
                nervie.Parent = wave.Nervie
                nervie.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                nervie.Visible = false
                nervie:GetData().Duration = 10
                nervie:Update()
                wave.Nervie = nervie
            else
                wave = nil
            end
        end
        data.WaveTimer = 6
    end
end

function mod:NervieAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_HIDE_HP_BAR + EntityFlag.FLAG_NO_FLASH_ON_DAMAGE + EntityFlag.FLAG_NO_REWARD)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc.Visible = true
        sprite.FlipX = (rng:RandomFloat() <= 0.5)
        data.State = "Warning"
        data.Init = true
    end
    data.Duration = data.Duration or 30

    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    if npc.EntityCollisionClass > EntityCollisionClass.ENTCOLL_NONE then
        mod.QuickSetEntityGridPath(npc, 900)
    end

    if mod:IsReallyDead(npc.Parent) then
        if data.State == "Warning" then
            npc:Remove()
        elseif data.State == "Idle" then
            data.State = "Leave"
        end
    end

    if data.State == "Warning" then
        if data.WaitPeriod then
            data.WaitPeriod = data.WaitPeriod - 1
            if data.WaitPeriod <= 0 then
                data.State = "Emerge"
            end
        else
            if npc.Parent and npc.Parent:Exists() and npc.Parent.Type == mod.FF.Nervie.ID and npc.Parent.Variant == mod.FF.Nervie.Var then
                if npc.Parent:GetData().State ~= "Warning" then
                    data.WaitPeriod = 6
                end
            end
        end
        mod:spritePlay(sprite, "Tell")
    elseif data.State == "Emerge" then
        if sprite:IsFinished("Emerge") then
            npc.StateFrame = data.Duration
            mod:PlaySound(SoundEffect.SOUND_SHOVEL_DIG, npc, mod:RandomInt(8,12,rng) * 0.1, 0.2)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        else
            mod:spritePlay(sprite, "Emerge")
        end
    elseif data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "Leave"
        end
    elseif data.State == "Leave" then
        if sprite:IsFinished("Submerge") then
            npc:Remove()
        elseif sprite:IsEventTriggered("Disappear") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            mod:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, npc, mod:RandomInt(8,12,rng) * 0.1, 0.3)
        else
            mod:spritePlay(sprite, "Submerge")
        end
    end
end


function mod:NervieColl(npc, collider)
    if collider:ToPlayer() then
        collider:TakeDamage(npc.CollisionDamage, 0, EntityRef(npc), 0)
    end
    return true
end

function mod:NerviePointSetup(npc)
    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    local nerviedata = {}
    nerviedata.Position = npc.Position
    nerviedata.Group = (npc.SubType >> 1 & 3) 
    if npc.SubType % 2 == 1 then
        nerviedata.Angle = 22.5 * (npc.SubType >> 3 & 15)
    end
    table.insert(mod.NervieData, nerviedata)

    mod.ActiveNervieGroups[nerviedata.Group] = "Open"

    npc:Remove()
end