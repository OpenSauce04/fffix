local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:RotdrinkAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc.SplatColor = mod.ColorRottenGreen
        data.Speed = 2
        sprite:PlayOverlay("Head01")
        data.Init = true
    end
    if npc.HitPoints < npc.MaxHitPoints / 3 and data.Speed < 6 then
        data.Speed = 6
        sprite:PlayOverlay("Head03")
        npc:BloodExplode()
        local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc)
        effect.Color = mod.ColorRottenGreen
        effect.DepthOffset = npc.Position.Y * 1.25
    elseif npc.HitPoints < (npc.MaxHitPoints / 3) * 2 and data.Speed < 4 then
        data.Speed = 4
        sprite:PlayOverlay("Head02")
        npc:BloodExplode()
        local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc)
        effect.Color = mod.ColorRottenGreen
        effect.DepthOffset = npc.Position.Y * 1.25
    end
    npc:AnimWalkFrame("WalkHori","WalkVert",1)
    local vel 
    if mod:isScare(npc) then
		vel = (targetpos - npc.Position):Resized(-data.Speed)
	elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
		vel = (targetpos - npc.Position):Resized(data.Speed)
	else
		npc.Pathfinder:FindGridPath(targetpos, (data.Speed * 0.1) + 0.2, 900, true)
	end
    if vel then
        npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
    end
    if npc:IsDead() then
        mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 1.5, 1)
        local skull = Isaac.Spawn(mod.FF.Rotskull.ID, mod.FF.Rotskull.Var, mod.FF.Rotskull.Sub, npc.Position, npc.Velocity, npc):ToNPC()
        skull:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if npc:IsChampion() then
            skull:MakeChampion(npc.InitSeed, npc:GetChampionColorIdx(), true)
            skull.HitPoints = skull.MaxHitPoints
        end
        for i = 1, mod:RandomInt(1,2) do
            local maggotvel = (mod:FindRandomValidPathPosition(npc, 3) - npc.Position)/mod:RandomInt(20,25)
            FiendFolio.ThrowMaggot(npc.Position, maggotvel, -5, mod:RandomInt(-15, -10), npc)
        end
        local effect = Isaac.Spawn(1000,2,3,npc.Position,Vector.Zero,npc)
        effect.Color = mod.ColorRottenGreen
        effect.DepthOffset = npc.Position.Y * 1.25
    end
end

mod.RotskullAnims = {"SkullRight", "SkullDRight", "SkullDown", "SkullDLeft", "SkullLeft", "SkullULeft", "SkullUp", "SkullURight"}

function mod:RotskullAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        sprite:Play("SkullDown")
        data.Init = true
    end
    local vel
    if mod:isScare(npc) then
        mod:UnscareWhenOutOfRoom(npc)
        if npc.Position:Distance(target.Position) < 300 then
            vel = (targetpos - npc.Position):Resized(-20)
        else
            npc.Velocity = npc.Velocity * 0.9
        end
    else
        vel = (targetpos - npc.Position):Resized(20)
    end
    if vel then
        npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.05)
        local angle = math.floor(((mod:GetAngleDegreesButGood(vel)+12.5)%360)/45)
        sprite:SetAnimation(mod.RotskullAnims[angle+1], false)
    end
end