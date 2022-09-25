local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MolarSystemAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        data.AnimSuffix = 0
        data.Interval = 4
        for i = 1, npc.SubType do
            mod:AddMolarOrbital(npc, i, mod:RandomAngle(), 2)
            data.AnimSuffix = data.AnimSuffix + 1
            data.Interval = data.Interval - 1
        end
        sprite:Play("Idle"..data.AnimSuffix)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        data.Init = true
    end
    npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(1.3)), 0.3)
    if sprite:IsFinished("Flinch"..data.AnimSuffix) then
        sprite:Play("Idle"..data.AnimSuffix)
    end
end

function mod:MolarSystemHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    if data.Init then
        local initsuffix = data.AnimSuffix
        local interval = npc.MaxHitPoints / (data.Interval * 2)
        local health = npc.HitPoints - amount
        if data.AnimSuffix < 4 and health < interval * (data.Interval) then
            data.AnimSuffix = 4
        elseif data.AnimSuffix < 3 and health < interval * (data.Interval + 1) then
            data.AnimSuffix = 3
        elseif data.AnimSuffix < 2 and health < interval * (data.Interval + 2) then
            data.AnimSuffix = 2
        elseif data.AnimSuffix < 1 and health < interval * (data.Interval + 3) then
            data.AnimSuffix = 1
        end
        if data.AnimSuffix > initsuffix then
            sprite:Play("Flinch"..data.AnimSuffix)
            mod:PlaySound(SoundEffect.SOUND_BONE_SNAP, npc, 1, 0.5)
            mod:PlaySound(SoundEffect.SOUND_BOIL_HATCH, npc, 1.5, 0.5)
            for i = initsuffix + 1, data.AnimSuffix do
                local angle = mod:RandomAngle()
                local sourceplayer = mod:GetPlayerSource(source)
                if sourceplayer then
                    angle = mod:GetAngleDegreesButGood((sourceplayer.Position - npc.Position):Rotated(50 + mod:RandomInt(-45, 45))) --idk whyyy this angle works but fuck you???
                end
                mod:AddMolarOrbital(npc, i, angle)
            end
        end
    end
end

function mod:AddMolarOrbital(npc, i, angle, orbitshift)
    local orbital = Isaac.Spawn(mod.FF.MolarOrbital.ID, mod.FF.MolarOrbital.Var, 0, npc.Position, Vector.Zero, npc) 
    orbital.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    orbital.Parent = npc
    local orbdata = orbital:GetData()
    orbdata.Angle = angle
    orbdata.AngleShift = 4
    orbdata.GoalDistance = 30 * i
    orbdata.Distance = orbital.Position:Distance(npc.Position)
    if mod:RandomInt(1,2) == 1 then
        orbdata.AngleShift = -orbdata.AngleShift
    end
    orbdata.OrbitShift = orbitshift or 5
    orbital.Position = npc.Position + Vector(0,orbdata.Distance):Rotated(orbdata.Angle)
end

function mod:MolarOrbitalAI(npc, sprite, data)
    if not data.Init then
        sprite:Play("Idle"..mod:RandomInt(0,2))
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_TARGET)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        data.Init = true
    end
    if npc.Parent and npc.Parent:Exists() then
        npc.Velocity = (npc.Parent.Position + Vector(0,data.Distance):Rotated(data.Angle)) - npc.Position
        if data.Distance < data.GoalDistance then
            data.Distance = data.Distance + data.OrbitShift
        end
        data.Angle = data.Angle + data.AngleShift
    else
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.Velocity = npc.Velocity * 0.94
    end
end

function mod:MolarOrbitalDeath(npc)
    sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
    mod:PlaySound(SoundEffect.SOUND_BOIL_HATCH, npc, 1, 0.8)
    mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, npc, 2, 0.5)
    for i = 0, 2 do
        Isaac.Spawn(1000, 35, 0, npc.Position, Vector.One:Resized(rng:RandomFloat()*4):Rotated(mod:RandomAngle()), npc)
    end
end