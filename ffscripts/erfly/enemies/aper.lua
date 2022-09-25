local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Dople 2, AperUpdate
function mod:aperAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	d.target = d.target or npc:GetPlayerTarget()
	local target = d.target
    local room = game:GetRoom()

	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		d.init = true
	end

	local targetpos = target.Position
	local centre = room:GetCenterPos()
	local targetVec = targetpos - centre
	if npc.SubType == 1 then
		targetVec = Vector(targetVec.X * -1, targetVec.Y)
	elseif npc.SubType == 2 then
		targetVec = Vector(targetVec.X, targetVec.Y * -1)
	else
		targetVec = Vector(targetVec.X * -1, targetVec.Y * -1)
	end
	npc.TargetPosition = centre + targetVec
	local preferredHead = "HeadUp"
	local preferredTravel = "Walk"

	local vec = npc.TargetPosition - npc.Position
	local gridcoll = room:GetGridCollisionAtPos(npc.TargetPosition)
	if gridcoll > 0 then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		preferredTravel = "Fly"
	else
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	end
	if (target:ToPlayer() and target:ToPlayer().CanFly) then
		preferredTravel = "Fly"
	end

	local grident = room:GetGridEntityFromPos(npc.Position)
	if grident and grident.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
		print(grident.State)
		if grident.State == 0 then
			local plate = grident:ToPressurePlate()
			local player = Isaac.GetPlayer()
			local oldPos = player.Position

			player.Position = plate.Position
			plate:Update()
			player.Position = oldPos
		end
	end
	if target.Velocity:Length() > 0.1 and npc.TargetPosition:Distance(npc.Position) > 0.1 then

		if math.abs(vec.X) > math.abs(vec.Y) then
			--mod:spritePlay(sprite, "WalkHori")
			if vec.X > 0 then
				preferredHead = "HeadRight"
				mod:spritePlay(sprite, preferredTravel .. "Right")
			else
				preferredHead = "HeadLeft"
				mod:spritePlay(sprite, preferredTravel .. "Left")
			end
		else
			mod:spritePlay(sprite, preferredTravel .. "Vert")
			if vec.Y > 0 then
				preferredHead = "HeadDown"
			else
				preferredHead = "HeadUp"
			end
		end
	else
		npc.Velocity = nilvector
		if preferredTravel == "Fly" then
			mod:spritePlay(sprite, "FlyVert")
		else
			sprite:SetFrame("WalkVert", 0)
		end
		if npc.SubType == 1 then
			preferredHead = "HeadDown"
		end
	end

	local player = target:ToPlayer()
	local shooting
	--print(player.FireDelay)
	if player then
		if d.readyToFire and (player.FireDelay > d.readyToFire) then
			if player:GetAimDirection():Length() >= 0.2 then
				shooting = player:GetAimDirection():Normalized() * -1
				if npc.SubType == 1 then
					shooting = Vector(shooting.X, shooting.Y * -1)
				elseif npc.SubType == 2 then
					shooting = Vector(shooting.X * -1, shooting.Y)
				end
				d.readyToFire = nil
			end
		end
		if player.FireDelay then
			d.readyToFire = player.FireDelay
		end
	end

	if shooting then
		local vec = (shooting) + (npc.Velocity * 0.1):Resized(math.min((npc.Velocity * 0.1):Length(), 0.9))
		local projectile = Isaac.Spawn(9, 0, 0, npc.Position + vec:Resized(10) + RandomVector()*math.random(1,30)/10, vec:Resized(3), npc):ToProjectile();
		local projdata = projectile:GetData()
		projdata.projType = "Aper"
		projectile.FallingSpeed = 0
		projectile.Height = -40
		projectile.FallingAccel = -0.1
		projectile:Update()

		d.overrideTimer = 10
		if math.abs(shooting.X) > math.abs(shooting.Y) then
			--mod:spritePlay(sprite, "WalkHori")
			if shooting.X > 0 then
				d.overrideHead = "HeadRight"
			else
				d.overrideHead = "HeadLeft"
			end
		else
			if shooting.Y > 0 then
				d.overrideHead = "HeadDown"
			else
				d.overrideHead = "HeadUp"
			end
		end
	end
	local overrideFrame
	if d.overrideTimer and d.overrideTimer >= 0 then
		d.overrideTimer = d.overrideTimer - 1
		preferredHead = d.overrideHead
		if d.overrideTimer > 5 then
			overrideFrame = 2
		end
	end

	sprite:SetOverlayFrame(preferredHead, overrideFrame or 0)

	npc.Velocity = vec
end

function mod.AperProj(v,d)
	if d.projType == "Aper" then
		if v.FrameCount > 120 then
			v.FallingAccel = 1
		elseif v.FrameCount < 100 then
			v.Height = mod:Lerp(v.Height, -23, 0.01)
		end
	end
end