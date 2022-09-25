local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.toxicDirs = {
    Vector(-1.5,1.5),
    Vector(-1.5,-1.5),
    Vector(1.5,-1.5),
    Vector(1.5,1.5),
}

function mod:toxicKnightAI(npc, subt)
    local d = npc:GetData();
    local room = game:GetRoom()

    --Fucka's brain
    if subt == 1 then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.Visible = false
        npc.CollisionDamage = 0
        npc:SetSize(17, Vector(1,1), 40)
        if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
            local sprite = npc:GetSprite();

            npc.Position = npc.Parent.Position - npc.Parent.Velocity:Resized(7)
            npc.Velocity = nilvector
            if d.eternalFlickerspirited then
                npc.Parent:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
            end
        else
            npc:Remove()
        end

    --Real fucka hours
    else
        local sprite = npc:GetSprite();
        local target = npc:GetPlayerTarget()

        if not d.init then
            d.dir = math.random(4)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.SplatColor = mod.ColorSpittyGreen

            local hurtbox = mod.spawnent(npc, npc.Position, nilvector, mod.FF.ToxicKnight.ID, mod.FF.ToxicKnight.Var, 1)
            hurtbox.Parent = npc
            hurtbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            hurtbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			hurtbox:GetSprite():Play("Hidden", true)
            npc.Child = hurtbox
            hurtbox:Update()

            d.init = true
        end

        --if (npc.Child and npc.Child:IsDead()) or not npc.Child then
        --	npc:Kill()
        --end

        if (not npc.Child) and (not mod:isLeavingStatusCorpse(npc)) then
            npc:Kill()
        elseif npc.Child then
            if target.InitSeed == npc.Child.InitSeed then -- For charm compatibility
                target = Isaac.GetPlayer(0)
            end
        end

        if npc.Velocity:Length() > 1 then
            local dirVert
            if npc.Velocity.Y < 0 then
                dirVert = "Up"
            else
                dirVert = "Down"
            end
            local dirHori
            if npc.Velocity.X > 0 then
                dirHori = "1"
            else
                dirHori = "2"
            end
            mod:spritePlay(sprite, "Diag" .. dirVert .. dirHori)
        else
            sprite:SetFrame("DiagDown1", 0)
        end

        if d.dir then
            if not d.charging then
                if math.random(100) == 1 then
                    d.changeDir = true
                end
                local distancecheck = 20
                if --[[not room:CheckLine(npc.Position,npc.Position+npc.Velocity:Resized(distancecheck),0,1,false,false) or ]]npc:CollidesWithGrid() or d.changeDir then
                    local newdir = {}
                    for i = 1, 4 do
                        if room:CheckLine(npc.Position,npc.Position+Vector(distancecheck,distancecheck):Rotated(90*i),0,1,false,false) then
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

                npc.Velocity = mod:Lerp(npc.Velocity, mod.toxicDirs[d.dir], 0.2)

                if room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isConfuse(npc) then
                    local vec = mod:reverseIfFear(npc, target.Position - npc.Position)
                    local g = vec:GetAngleDegrees() % 90
                    --Isaac.ConsoleOutput(g .. "\n")
                    if g > 35 and g < 55 then
                        if vec.X > 0 then
                            if vec.Y > 0 then
                                d.dir = 4
                            else
                                d.dir = 3
                            end
                        else
                            if vec.Y > 0 then
                                d.dir = 1
                            else
                                d.dir = 2
                            end
                        end
                        d.charging = true
                    end
                end
                --npc.Velocity = nilvector
            else
                npc.Velocity = mod:Lerp(npc.Velocity, mod.toxicDirs[d.dir]:Resized(4), 0.2)
                if npc:CollidesWithGrid() then
                    d.charging = false
                    d.changeDir = true
                end
            end
        end
    end
end

function mod:toxicKnightColl(npc1, npc2)
    if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
        return true
    elseif npc1.Child and npc1.Child.InitSeed == npc2.InitSeed then
        return true
    end
end

function mod:toxicKnightHurt(npc, damage, flag, source)
    local data = npc:GetData()

    --if data.FFForceFreezeOnDeath then -- For Uranus compatibility
    --	return nil
    --elseif flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
    if flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
        data.FFLastPoisonProc = data.FFLastPoisonProc or 0
        if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
            return false
        end
        data.FFLastPoisonProc = Isaac.GetFrameCount()

        if flag ~= flag | DamageFlag.DAMAGE_CLONES then
            if npc.SubType ~= 1 then
                --if npc.Child then
				--	npc.Child:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
				--end
			else
				if npc.Parent then
					npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
				end
				return false
			end
        end
    elseif flag ~= flag | DamageFlag.DAMAGE_CLONES then -- Regular damage
        if npc.SubType ~= 1 then
            return false
        else
            if npc.Parent then
				npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
			end
			return false
		end
    --elseif npc.SubType ~= 1 and flag ~= flag | DamageFlag.DAMAGE_NOKILL then -- For Uranus compatibility
    --	npc:TakeDamage(damage, flag | DamageFlag.DAMAGE_NOKILL, source, 0)
    --	return false
    end
    
	--	if flag ~= flag | DamageFlag.DAMAGE_CLONES then
	--		if npc.SubType ~= 1 then
	--			return false
	--		else
	--			if npc.Parent then
	--				npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, EntityRef(npc), 0)
	--			end
	--		end
	--	end
end

function mod:toxicKnightKill(npc)
	if npc.Child then
		npc.Child:Remove()
	end
end