local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.GorgerDir = {
    {"Down", false, 3},
    {"Hori", true, 4},	--Left
    {"Up", false, 1},
    {"Hori", false, 2},	--Right
}

function mod:gorgerAI(npc, subType)
    if subType == mod.FF.GorgerAss.Sub then
        mod:gorgerAssAI(npc)
    else
        mod:gorgerRealAI(npc)
    end
end

--Goocher
function mod:gorgerRealAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    if target.Parent and target.Parent.InitSeed == npc.InitSeed then
        target = Isaac.GetPlayer(0)
    end

    if not d.init then
        --Setup butt
        local ass = mod.spawnent(npc, npc.Position, nilvector, mod.FF.GorgerAss.ID, mod.FF.GorgerAss.Var, mod.FF.GorgerAss.Sub)
        ass.Parent = npc
        npc.Child = ass
        mod:copyFFStatusEffects(npc, ass)
        --States
        --npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
        d.state = "idle"
        d.dir = math.random(4)
        npc.SplatColor = mod.ColorDankBlackReal
        d.init = true
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
    end

    --[[if npc.Child then
        npc:AddEntityFlags(npc.Child:GetEntityFlags())
    end]]

    if npc.State == 17 then
        if npc.Child then
            npc.Child:Remove()
        end
        npc.Velocity = nilvector
        if sprite:IsFinished("Death") then
            npc:Kill()
        else
            mod:spritePlay(sprite, "Death")
        end
    else
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        if d.state == "idle" then
            --local targ = room:GetLaserTarget(npc.Position, npc.Velocity)
            local room = game:GetRoom()
            local distancecheck = 20
            if not room:CheckLine(npc.Position,npc.Position+npc.Velocity:Resized(distancecheck),0,1,false,false) or npc:CollidesWithGrid() or d.changeDir then
                local newdir = {}
                for i = 1, 4 do
                    if room:CheckLine(npc.Position,npc.Position+Vector(distancecheck,0):Rotated(90*i),0,1,false,false) then
                        table.insert(newdir, i)
                    end
                end
                if #newdir > 0 then
                    d.dir = newdir[math.random(#newdir)]
                else
                    --Isaac.ConsoleOutput("I fucked up sowwy daddy\n")
                    d.dir = mod.GorgerDir[d.dir][3]
                end
                d.changeDir = false
            end

            mod:spritePlay(sprite, "WalkNormal" .. mod.GorgerDir[d.dir][1])
            sprite.FlipX = mod.GorgerDir[d.dir][2]

            npc.Velocity = Vector(3, 0):Rotated(90*d.dir)

            if npc.StateFrame > 20 and (math.abs(npc.Position.X - target.Position.X) < 20 or math.abs(npc.Position.Y - target.Position.Y) < 20) then

                local ang = (target.Position - npc.Position):Rotated(90):GetAngleDegrees()
                local newg = ((ang / 90) + 0.5 - ((ang / 90) + 0.5) % 1) + 3
                --Isaac.ConsoleOutput(newg .. "\n")
                if newg == 5 then newg = 1 end
                d.dir = newg
                d.state = "chargestart"
                if npc.Child then
                    npc.Child:Remove()
                end
            end

        elseif d.state == "chargestart" then
            npc.Velocity = npc.Velocity * 0.9
            mod:spritePlay(sprite, "Charge" .. mod.GorgerDir[d.dir][1] .. "Start")
            sprite.FlipX = mod.GorgerDir[d.dir][2]
            if sprite:IsFinished("Charge" .. mod.GorgerDir[d.dir][1] .. "Start") then
                npc.StateFrame = 0
                d.state = "charge"
                npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0,1,2,false,1)
                mod:spritePlay(sprite, "Charge" .. mod.GorgerDir[d.dir][1])
                local ass = mod.spawnent(npc, npc.Position + Vector(-23,0):Rotated(d.dir*90), nilvector, mod.FF.GorgerAss.ID, mod.FF.GorgerAss.Var, mod.FF.GorgerAss.Sub)
                ass.Parent = npc
                ass.HitPoints = npc.HitPoints
                mod:copyFFStatusEffects(npc, ass)
                ass.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                ass:GetSprite():Play("Charge" .. mod.GorgerDir[d.dir][1] .. "Seg", true)
                --ass:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
                npc.Child = ass
            end
        elseif d.state == "charge" then
            mod:spritePlay(sprite, "Charge" .. mod.GorgerDir[d.dir][1])
            sprite.FlipX = mod.GorgerDir[d.dir][2]
            local vec = npc.Velocity:Resized(20)
            --local gridinfront = false
            for k,v in ipairs(mod.GetGridEntities()) do
                if d.dir == 1 or d.dir == 3 then
                    if math.abs(v.Position.X - npc.Position.X) < 30 and math.abs(v.Position.Y - npc.Position.Y) < 50 then
                    v:Destroy()
                    end
                elseif d.dir == 2 or d.dir == 4 then
                    if math.abs(v.Position.Y - npc.Position.Y) < 30 and math.abs(v.Position.X - npc.Position.X) < 50 then
                    v:Destroy()
                    end
                end
            end

            npc.Velocity = Vector(20,0):Rotated(90*d.dir) * (math.max(0.5, 1 - (npc.StateFrame / 100)))

            local creep = Isaac.Spawn(1000, 26, 0, npc.Position, nilvector, npc)
            creep:Update()

            local gridinfront = false
        --[[	local targ = room:GetLaserTarget(npc.Position, npc.Velocity:Normalized())
            if targ:Distance(npc.Position) < 20 then
                gridinfront = true
            end]]
            local room = game:GetRoom()
            if not room:CheckLine(npc.Position,npc.Position+npc.Velocity:Resized(20),0,1,false,false) then
                gridinfront = true
            end

            if gridinfront --[[or (npc.StateFrame > 30 and npc:CollidesWithGrid())]] then
                npc.Velocity = nilvector
                mod:spritePlay(sprite, "Collide" .. mod.GorgerDir[d.dir][1])
                if npc.Child then
                    npc.Child:Remove()
                end
                d.state = "Collide"
                game:ShakeScreen(10)
                npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,1,2,false,1.7)
            end

        elseif d.state == "Collide" then
            npc.Velocity = nilvector
            if sprite:IsFinished("Collide" .. mod.GorgerDir[d.dir][1]) then
                npc.StateFrame = 0
                d.state = "Dizzy"
            end
        elseif d.state == "Dizzy" then
            npc.Velocity = nilvector
            mod:spritePlay(sprite, "Dizzy" .. mod.GorgerDir[d.dir][1])
            if npc.StateFrame > 20 then
                d.state = "DizzyEnd"
                mod:spritePlay(sprite, "Dizzy" .. mod.GorgerDir[d.dir][1] .. "End")
                local ass = mod.spawnent(npc, npc.Position + Vector(-23,0):Rotated(d.dir*90), nilvector, mod.FF.GorgerAss.ID, mod.FF.GorgerAss.Var, mod.FF.GorgerAss.Sub)
                ass.Parent = npc
                ass.HitPoints = npc.HitPoints
                mod:copyFFStatusEffects(npc, ass)
                ass.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                ass:GetSprite():Play("WalkNormal" .. mod.GorgerDir[d.dir][1] .. "Seg", true)
                --ass:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
                npc.Child = ass
            end
        elseif d.state == "DizzyEnd" then
            npc.Velocity = nilvector
            if sprite:IsFinished("Dizzy" .. mod.GorgerDir[d.dir][1] .. "End") then
                npc.StateFrame = 0
                d.state = "idle"
            else
                mod:spritePlay(sprite, "Dizzy" .. mod.GorgerDir[d.dir][1] .. "End")
            end
        end
    end
end

function mod:gorgerAssAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    sprite.Offset = Vector(0, -2)
    npc.SplatColor = mod.ColorDankBlackReal

    if not d.dir then
        if npc.Parent then
            d.dir = npc.Parent:GetData().dir
        else
            d.dir = 1
        end
    end
    if npc.Parent then
        --npc:AddEntityFlags(npc.Parent:GetEntityFlags())
        local pd = npc.Parent:GetData()
        local ps = npc.Parent:GetSprite()
        if npc.Parent:IsDead() then
            npc:Kill()
        end
        if npc.Position:Distance(npc.Parent.Position) > 23 and pd.state ~= "DizzyEnd" then
            npc.Position = npc.Parent.Position + Vector(0,-1) - npc.Parent.Velocity:Resized(23)
            d.dir = pd.dir
            --npc.Velocity = npc.Parent.Velocity
            npc.Velocity = nilvector
        end
        if pd.state == "idle" or pd.state == "chargestart" then
            --mod:spritePlay(sprite, "WalkNormal" .. mod.GorgerDir[d.dir][1] .. "Seg")
            sprite:SetFrame("WalkNormal" .. mod.GorgerDir[d.dir][1] .. "Seg", ps:GetFrame())
            sprite.FlipX = mod.GorgerDir[d.dir][2]
        elseif pd.state == "charge" then
            --mod:spritePlay(sprite, "Charge" .. mod.GorgerDir[d.dir][1] .. "Seg")
            sprite:SetFrame("Charge" .. mod.GorgerDir[d.dir][1] .. "Seg", ps:GetFrame())
            sprite.FlipX = mod.GorgerDir[d.dir][2]
        elseif pd.state == "Dizzy" or pd.state == "DizzyEnd" then
            mod:spritePlay(sprite, "WalkNormal" .. mod.GorgerDir[d.dir][1] .. "Seg")
        end

        if pd.eternalFlickerspirited then
            d.eternalFlickerspirited = true
            npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
        else
            d.eternalFlickerspirited = false
        end

    else
        npc:Remove()
    end
end

function mod:gorgerColl(npc1, npc2)
    if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
        return true
    elseif npc1.Child and npc1.Child.InitSeed == npc2.InitSeed then
        return true
    end

    local d = npc1:ToNPC():GetData()
    if d.state == "idle" and npc2:IsEnemy() then
        d.changeDir = true
    elseif d.state == "charge" then
        if npc2:IsEnemy() then
            npc2:TakeDamage(7, 0, EntityRef(npc1), 0)
        end
    end
end

function mod:gorgerHurt(npc, damage, flag, source)
    --Rise from your ashes ""PreEntityTakeDamage" failed: C stack overflow" error. (please don't actually)
    if npc:ToNPC().State == 17 then
        return false
    end

    local data = npc:GetData()

    if flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
        data.FFLastPoisonProc = data.FFLastPoisonProc or 0
        if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
            return false
        end
        data.FFLastPoisonProc = Isaac.GetFrameCount()

        if flag ~= flag | DamageFlag.DAMAGE_CLONES then
            if npc.SubType == mod.FF.GorgerAss.Sub then
                if npc.Parent then
                    npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
                end
            else
                if npc.Child then
                    npc.Child:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
                end
            end
        end
    elseif flag ~= flag | DamageFlag.DAMAGE_CLONES then -- Regular damage
        if npc.SubType == mod.FF.GorgerAss.Sub then
            if npc.Parent then
                npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            end
        else
            if npc.Child then
                npc.Child:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            end
        end
    end
	--	if flag & DamageFlag.DAMAGE_CLONES == 0 then
	--		if npc.Parent then
	--			npc.Parent:TakeDamage(damage, flag & DamageFlag.DAMAGE_CLONES, EntityRef(npc), 0)
	--		end
		--	if npc.Child then
			 --The line below is commented out to avoid the annoying and mysterious ""PreEntityTakeDamage" failed: C stack overflow" error until further notice.
				--npc.Child:TakeDamage(damage, flag & DamageFlag.DAMAGE_CLONES, EntityRef(npc), 0)
		--	end
	--	end
	--	if npc.HitPoints - damage <= 10 then
	--		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
	--			npc.Velocity = nilvector
	--			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	--			npc.HitPoints = 0
	--			npc:ToNPC().State = 11
	--			return false
	--		end
	--	end
end

function mod:gorgerKill(npc)
	if npc.SubType ~= mod.FF.GorgerAss.Sub then 
		if npc.Child then
			npc.Child:Remove()
		end
	end
end