local mod = FiendFolio
local game = Game()

function mod:specturnAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local room = game:GetRoom()
	
	if not d.init then
		if (npc.SubType & 1) == 0 then
			d.invuln = true
		else
			d.invuln = false
		end
		if (npc.SubType >> 1 & 1) == 1 then
			d.deathSpawn = false
		else
			d.deathSpawn = true
		end
		local searchNum = (npc.SubType >> 8 & 7)
		if searchNum == 0 then
			d.searchPos = npc.Position
		else
			d.searchPos = npc.Position+Vector(40,0):Rotated(-90+90*searchNum)
		end
		d.rotDir = (npc.SubType >> 7 & 1)
		npc.SplatColor = mod.ColorGhostly
		sprite:Play("Appear")
		d.init = true
	end
	npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	
	if not d.found then
        local newparent = mod:getNearestSpecturnTargets(d.searchPos, 1, 0)[1]
        if newparent then
			local distance = (npc.SubType >> 11 & 15)*20
            npc.Parent = newparent
			local pData = newparent:GetData()
			if pData.specturnChildren == nil then
				pData.specturnChildren = {}
			end
            d.vec = (npc.Position - npc.Parent.Position):Resized(35)
            d.found = true
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            --npc.PositionOffset = Vector(0, (-13 / 26) * 40)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			newparent:GetData().isSpecturnCenter = true
			local num = #pData.specturnChildren+1
			
			
			local targets = mod:getNearestSpecturnTargets(newparent.Position, (npc.SubType >> 2 & 31), 1)
			if #targets > 0 then
				table.insert(pData.specturnChildren, num, {})
			end
			for i=1,#targets do
				local target = targets[i]
				local targetData = target:GetData()
				
				table.insert(pData.specturnChildren[num], i, target)
				targetData.specturnCount = #targets
				targetData.specturnPosition = i
				targetData.specturnRing = num
				
				--target:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				targetData.isSpecturned = true
				--[[local newTarget = Isaac.Spawn(target.Type, target.Variant, target.SubType, npc.Position, Vector.Zero, newparent):ToNPC()
				target:Remove()]]
				
				mod:makeEnemyEternal(target, newparent, (100/#targets)*i, distance, d.invuln, d.deathSpawn, 20, 1, d.rotDir)
				--mod:makeEnemyEternal(newTarget, newparent, 50, 50, true, true, 20, 1, 1)
			end
        else
            sprite:Play("Death")
        end
    end

	if sprite:IsFinished("Appear") then
		if d.rotDir == 1 then
			sprite:Play("IdleReverse")
		else
			sprite:Play("Idle")
		end
	elseif sprite:IsFinished("Death") then
		npc:Remove()
	end

    if npc.Parent then
		local targpos = npc.Parent.Position + d.vec
		local targvec = (targpos - npc.Position)
		local targvel = targvec:Resized(npc.Position:Distance(targpos))
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 1)
		--npc.Position = targpos

		d.vec = d.vec:Rotated(3-6*d.rotDir)
    else
		npc.Velocity = npc.Velocity * 0.6
        sprite:Play("Death")
    end
end

--[[function mod:eternalFuckery(npc)
	local data = npc:GetData()
	if npc.SubType == 114 then
		if not data.init then
			data.isSpecturned = true
			data.specturnChildren = {}
			table.insert(data.specturnChildren, 1, {})
			data.init = true
			for i=1,3 do
				local test
				if i == 1 then
					test = Isaac.Spawn(150, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
				elseif i == 2 then
					test = Isaac.Spawn(150, 0, 1, npc.Position, Vector.Zero, npc):ToNPC()
				elseif i == 3 then
					test = Isaac.Spawn(150, 1, 2, npc.Position, Vector.Zero, npc):ToNPC()
				end
				
				table.insert(data.specturnChildren[1], i, test)
				local targetData = test:GetData()
				targetData.specturnCount = 3
				targetData.specturnPosition = i
				targetData.specturnRing = 1
				targetData.isSpecturned = true
				
				mod:makeEnemyEternal(test, npc, (100/3)*i, 70, false, true, 20, 0.5, 1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.eternalFuckery, 212)]]

function mod:isSpecturnBlacklist(entity)
	return mod.specturnBlacklist[entity.Type] or
	       mod.specturnBlacklist[entity.Type .. " " .. entity.Variant] or
	       mod.specturnBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:getNearestSpecturnTargets(position, numTargets, mode)
	local targets = {}
	local targetDists = {}
	
	if mode == 0 then
		local radius = 99999
		local target = nil
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			if mod:isFriend(entity) or mod:isSpecturnBlacklist2(entity) or entity.Type >= 999 or entity.Type < 10 then
			else
				local distance = position:Distance(entity.Position)
				if distance < radius then
					radius = distance
					target = entity
				end
			end
		end
		table.insert(targets, target)
	elseif mode == 1 then
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			local dist = position:Distance(entity.Position)
			if entity.Type < 10 or entity.Type >= 999 or (not entity:Exists()) or mod:isSpecturnBlacklist(entity) or mod:isFriend(entity) or entity:GetData().isSpecturned or entity:GetData().isSpecturnCenter then
				--do nothing
			else
				for i = 1, numTargets do
					if not targets[i] or dist <= targetDists[i] then
						table.insert(targets, i, entity)
						table.insert(targetDists, i, dist)
						break
					end
				end
			end
		end
	end

	while #targets > numTargets do
		table.remove(targets)
	end

	return targets
end

function mod:isSpecturnBlacklist2(entity)
	return mod.specturnBlacklist2[entity.Type] or
	       mod.specturnBlacklist2[entity.Type .. " " .. entity.Variant] or
	       mod.specturnBlacklist2[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end