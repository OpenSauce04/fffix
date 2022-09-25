local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:hollowKnightAI(npc)
    local d = npc:GetData()
    local path = npc.Pathfinder
    
    -- For charm compatibility (DOESNT WORK BECAUSE BONY VARIANT AAAAAAAAAAA)
    if d.brain and npc.Target and npc.Target.InitSeed == d.brain.InitSeed then
        npc.Target = Isaac.GetPlayer(0)
    end

    if not d.init then
        --npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
        local brain = Isaac.Spawn(mod.FF.Cortex.ID, mod.FF.Cortex.Var, 0, npc.Position, nilvector, npc)
        brain.Parent = npc
        d.brain = brain
        d.init = true
    end

    if npc.State == 8 then
        npc.State = 4
    end

    npc.Velocity = npc.Velocity:Resized(3)

    if d.brain then
        if d.brain:IsDead() or mod:isStatusCorpse(d.brain) then
            npc:Kill()
        end
    end
end

function mod:cortexAI(npc)
local sprite = npc:GetSprite()
local d = npc:GetData()

    if not d.init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

        if npc.Parent then
            local rand = d.rotval or math.random(75)
            npc.Position = npc.Position + Vector(0,10):Rotated(rand*5)
            d.currFrame = 0
            d.frameOffset = rand
            d.distance = d.distance or 50
        end

        d.init = true
    end

    mod:spritePlay(sprite, "Float")

    if npc.FrameCount % (#mod.creepSpawnerCount/2) == 0 then
        local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
        creep.Scale = (0.7)
        creep:SetTimeout(30)
        creep:Update();
    end

    if npc.Parent then
        if npc.Parent:IsDead() then
            npc:Kill()
        else
            local target = npc.Parent.Position
            local frame = d.currFrame + d.frameOffset
            local distance = math.min(10 + (d.currFrame / 3), d.distance)

            local xvel = math.cos((frame / 12) + math.pi) * (distance)
            local yvel = math.sin((frame / 12) + math.pi) * (distance)

            local direction = Vector(target.X - xvel, target.Y - yvel) - npc.Position

            if direction:Length() > 50 then
                direction:Resize(50)
            end

            npc.Velocity = direction

            local pd = npc.Parent:GetData()
            if pd.eternalFlickerspirited then
                npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
            end

            d.currFrame = d.currFrame + 1
        end
    else
        npc:Kill()
    end
end

function mod:cortexHurt(npc, damage, flag, source)
    if npc.Parent then
        if npc.Parent:GetData().eternalFlickerspirited then
            return false
        end
    end

    local data = npc:GetData()

    if flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
        data.FFLastPoisonProc = data.FFLastPoisonProc or 0
        if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
            return false
        end
        data.FFLastPoisonProc = Isaac.GetFrameCount()

        if flag ~= flag | DamageFlag.DAMAGE_CLONES then
            if npc.Parent then
				npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
			end
			mod:applyFakeDamageFlash(npc)
			return false
        end
    elseif flag ~= flag | DamageFlag.DAMAGE_CLONES then -- Regular damage
        if npc.Parent then
			npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
		end
		mod:applyFakeDamageFlash(npc)
		return false
    end
end

function mod:cortexKill(npc)
    if npc.Parent and not (mod:isLeavingStatusCorpse(npc.Parent) or mod:isStatusCorpse(npc.Parent)) then
        npc.Parent:Kill()
    end
end

function mod:cortexColl(npc1, npc2)
    if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed and npc1.Parent.Index == npc2.Index then -- Prevent selfdamage from charm/bait
        return true
    end
end