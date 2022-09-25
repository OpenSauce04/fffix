local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:psiling(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()

	npc.SpriteOffset = Vector(0, -10)

	if not d.init then
		d.init = true
		d.state = "idle"
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		if sprite:GetFrame() == 0 then
			if game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and math.random(3) == 1 and not mod:isScareOrConfuse(npc) then
				d.state = "attack"
				mod:spritePlay(sprite, "Attack")
			end
		end
	elseif d.state == "attack" then
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			mod:spritePlay(sprite, "Move")
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.CrosseyeAppear,1.5,0,false,math.random(15,17)/10)
			local params = ProjectileParams()
			params.Scale = 0.6
			params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
			params.HomingStrength = 0.7
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(9), 0, params)
		else
			mod:spritePlay(sprite, "Attack")
		end
	end

	if npc.Parent then --Hermit orbiting
		local targetpos = npc.Parent.Position + Vector(30,0):Rotated(d.Angle)
		npc.Velocity = targetpos - npc.Position
		d.Angle = d.Angle + 5
	else
		if d.Angle then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end

		if sprite:GetFrame() == 0 or sprite:IsEventTriggered("Shoot") then
			local psihunter = mod.FindClosestEntity(npc.Position, 150, mod.FF.Psihunter.ID, mod.FF.Psihunter.Var)
			if psihunter then
				npc.Velocity = (psihunter.Position - npc.Position):Resized(-15)
			elseif mod:isScare(npc) then
				npc.Velocity = (target.Position - npc.Position):Resized(-5)
			elseif mod:isConfuse(npc) or math.random(3) == 1 then
				npc.Velocity = RandomVector() * 5
			else
				npc.Velocity = (target.Position - npc.Position):Resized(5)
			end
		end
		npc.Velocity = npc.Velocity * 0.9
	end
end

function mod:psionEgAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	if not d.init then
		if math.random(2) == 1 then
			sprite.FlipX = true
		end
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		d.init = true
		npc.Position = npc.Position + RandomVector()*math.random(10)
	end
	mod:spritePlay(sprite, "Egg")
	npc.Velocity = nilvector

	if (npc:IsDead() or d.FFPsyEgKill) and not mod:isLeavingStatusCorpse(npc) then
		if not npc:IsDead() then
			npc:Kill()
		end

		local egg = Isaac.Spawn(mod.FF.Psiling.ID, mod.FF.Psiling.Var, 0, npc.Position, nilvector, npc)
		egg:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		egg:Update()
	end
end