local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:arteryAI(npc, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
    local room = game:GetRoom()

	npc.State = 0
	npc.Velocity = nilvector
	npc.RenderZOffset = -5000

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		if (room:HasTriggerPressurePlates() and room:IsClear()) then
			d.state = "closed"
		else
			d.state = "open"
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.FrameCount % 10 == 0 then
		for _,ClosePickup in ipairs(Isaac.FindInRadius(npc.Position, 1, EntityPartition.PICKUP)) do
			ClosePickup.Velocity = RandomVector()*2
		end
	end

	if d.state == "open" then
		mod:spritePlay(sprite, "Open")
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		if (room:HasTriggerPressurePlates() and room:IsClear()) then
			d.state = "close"
		end
		if npc.StateFrame % 50 == 25 then
			local searchtype
			if npc.SubType > 0 then
				searchtype = npc.SubType
			end
			if var == mod.FF.ArteryM.Var then
				local vein = mod.FindRandomEntity(npc, mod.FF.Vein.ID, mod.FF.Vein.Var, searchtype, true)
				if vein then
					local cell = mod.spawnent(npc, npc.Position, nilvector, mod.FF.BloodCell.ID, mod.FF.BloodCell.Var, npc.SubType)
					cell:GetSprite():Play("Appear", true)
				end
			elseif var == mod.FF.ArteryS.Var then
				local vein = mod.FindRandomEntity(npc, mod.FF.Vein.ID, mod.FF.Vein.Var, searchtype)
				if vein then
					local cell = mod.spawnent(npc, npc.Position, nilvector, mod.FF.BloodCellAir.ID, mod.FF.BloodCellAir.Var, npc.SubType)
					cell:GetSprite():Play("Appear", true)
				end
			end
		end
	elseif d.state == "close" then
		if sprite:IsFinished("Close") then
			d.state = "closed"
		else
			mod:spritePlay(sprite, "Close")
		end
	elseif d.state == "closed" then
		mod:spritePlay(sprite, "Closed")
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end
end

function mod:veinAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
    local room = game:GetRoom()

	npc.State = 0
	if d.secretMode then
		npc.Velocity = npc.Velocity * 0.9
	else
		npc.Velocity = nilvector
	end
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	npc.RenderZOffset = -5000

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		if math.random(5000) == 4536 then
			d.secretMode = 1
		end
		if (room:HasTriggerPressurePlates() and room:IsClear()) then
			d.state = "closed"
		else
			d.state = "open"
		end
		d.init = true
	end

	if npc.FrameCount % 10 == 0 then
		for _,ClosePickup in ipairs(Isaac.FindInRadius(npc.Position, 1, EntityPartition.PICKUP)) do
			if d.secretMode and not d.firstMove then
				npc:PlaySound(mod.Sounds.SlideWhistle,1,0,false,1)
				d.firstMove = true
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				if ClosePickup.Position:Distance(npc.Position) < 1 then
					npc.Velocity = RandomVector()*2
				else
					npc.Velocity = (npc.Position - ClosePickup.Position):Resized(2)
				end
			else
				if ClosePickup.Position:Distance(npc.Position) < 1 then
					ClosePickup.Velocity = RandomVector()*2
				else
					ClosePickup.Velocity = (ClosePickup.Position - npc.Position):Resized(2)
				end
			end
		end
	end

	if d.state == "open" then
		mod:spritePlay(sprite, "Open")
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		if (room:HasTriggerPressurePlates() and room:IsClear()) then
			d.state = "close"
		end
	elseif d.state == "close" then
		if sprite:IsFinished("Close") then
			d.state = "closed"
		else
			mod:spritePlay(sprite, "Close")
		end
	elseif d.state == "closed" then
		mod:spritePlay(sprite, "Closed")
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end
end

function mod:bloodCellAI(npc)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
    local room = game:GetRoom()

	if not d.init then
		if npc.Variant == 371 then
			d.flying = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		end
		if not d.target then
			local vein
			if d.flying then
				if npc.SubType == 0 then
					vein = mod.FindRandomEntity(npc, mod.FF.Vein.ID, mod.FF.Vein.Var)
				else
					vein = mod.FindRandomEntity(npc, mod.FF.Vein.ID, mod.FF.Vein.Var, npc.SubType)
				end
			else
				if npc.SubType == 0 then
					vein = mod.FindRandomEntity(npc, mod.FF.Vein.ID, mod.FF.Vein.Var, nil, true)
				else
					vein = mod.FindRandomEntity(npc, mod.FF.Vein.ID, mod.FF.Vein.Var, npc.SubType, true)
				end
			end
			if vein then
				d.target = vein
			else
				npc:BloodExplode()
				npc:Remove()
				return
			end
		end

		if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
			d.state = "wander"
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		else
			d.state = "appear"
		end
		d.init = true

	end

	if (room:HasTriggerPressurePlates() and room:IsClear()) or not d.target then
		npc:BloodExplode()
		npc:Remove()
		return
	elseif d.target:IsDead() then
		npc:BloodExplode()
		npc:Remove()
		return
	end

	if d.state == "appear" then
		local targetpos = d.target.Position
		if d.flying then
			local targetvel = (targetpos - npc.Position):Resized(3)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.4, 900, true)
		end
		if sprite:IsFinished("Appear") then
			d.state = "wander"
		else
			mod:spritePlay(sprite, "Appear")
		end
	elseif d.state == "wander" then

		if d.flying then
			mod:spritePlay(sprite, "Move")
		else
			if npc.Velocity:Length() > 0.1 then
				npc:AnimWalkFrame("WalkHori","WalkVert",0)
			else
				sprite:SetFrame("WalkVert", 0)
			end
		end

		local targetpos = d.target.Position
		if d.flying or room:CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.6, 900, true)
		end

		if npc.Position:Distance(targetpos) < 50 and (d.flying or room:CheckLine(targetpos,npc.Position,3,900,false,false)) then
			d.state = "exit"
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		end

	elseif d.state == "exit" then
		local targetpos = d.target.Position

		if npc.Position:Distance(targetpos) < 10 then
			npc.Position = targetpos
		else
			local targetvel = (targetpos - npc.Position):Resized(4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		end

		if sprite:IsFinished("Disappear") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Disappear")
		end
	end

	if npc:HasMortalDamage() then
		npc:BloodExplode()
		npc:Remove()
	end
end