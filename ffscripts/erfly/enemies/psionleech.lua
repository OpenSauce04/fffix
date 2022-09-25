local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:psionicLeechAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local sprite = npc:GetSprite()
    local room = game:GetRoom()

	if not d.init then
		d.state = "wander"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
		mod:spritePlay(sprite, "Hori")
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
	else
		if npc.Velocity.Y > 0 then
			mod:spritePlay(sprite, "Down")
		else
			mod:spritePlay(sprite, "Up")
		end
	end

	if d.state == "wander" then
		d.newhome = d.newhome or mod:GetNewPosAligned(npc.Position)
		if npc.Position:Distance(d.newhome) < 20 or npc.Velocity:Length() < 0.3 or mod:isScare(npc) or (mod:isConfuse(npc) and npc.StateFrame % 5 == 1) or d.feared --[[or not room:CheckLine(d.newhome,npc.Position,0,900,false,false)]] then
			if mod:isScare(npc) then
				d.newhome = npc.Position + mod:SnapVector(npc.Position - target.Position, 90):Resized(60)
				d.feared = true
			else
				d.newhome = mod:GetNewPosAligned(npc.Position, true)
				d.feared = nil
			end
		end

		local targvel = (d.newhome - npc.Position):Resized(5)
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
		local psihunter = mod.FindClosestEntity(npc.Position, 150, mod.FF.Psihunter.ID, mod.FF.Psihunter.Var)
		if psihunter or npc.StateFrame > 50 and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			local targrel = mod:GetPositionAligned(npc.Position, target.Position, 30)
			if targrel or psihunter then
			local vec = mod:SnapVector((target.Position - npc.Position), 90)
			d.targvec = vec:Resized(11)

			npc:PlaySound(mod.Sounds.PsionLeech,1,0,false,math.random(9,11)/10)
			d.state = "attack"
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
			d.touchedonce = false
			end
		end

	elseif d.state == "attack" then
		npc.Velocity = mod:Lerp(npc.Velocity, d.targvec, 0.3)
		if d.touchedonce then
			if room:IsPositionInRoom(npc.Position, 0) then
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			end
		end
		if npc:CollidesWithGrid() then
			if d.touchedonce then
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)  
				d.state = "wander"
				d.newhome = false
			else
				d.touchedonce = true
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				local p = Isaac.Spawn(1000, 7020, 1, npc.Position, nilvector, nil)
				local pcolor = Color(1,1,1,1,0,0,0)
				pcolor:SetColorize(1, 0.3, 1, 1)
				p.Color = pcolor
				p:GetSprite().Offset = Vector(0, -14)
				p:Update()

				npc.Position = target.Position - d.targvec:Resized(200)
				npc:SetColor(Color(0,0,0,1,255 / 255,80 / 255,255 / 255), 5, 999, true, false)

				npc:PlaySound(mod.Sounds.CrosseyeAppear,1.5,0,false,math.random(15,18)/10)
			end
		end
	end

	if npc:IsDead() then
		npc:PlaySound(mod.Sounds.PsionLeech,1,0,false,math.random(9,11)/10)
		local explosion = Isaac.Spawn(1000, 7012, 0, npc.Position, nilvector, npc)
		explosion:Update()
	end
end