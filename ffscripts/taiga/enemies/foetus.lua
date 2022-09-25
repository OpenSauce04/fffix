-- Foetus (ported from Morbus, originally coded by Xalum) --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local foetusVectors = {
	Vector(0, -40),
	Vector(40, 0),
	Vector(0, 40),
	Vector(-40, 0),
}

local function hasAttachableGridAtPos(pos)
	local gridIndex = game:GetRoom():GetGridIndex(pos)
	if gridIndex <= -1 then
		return false, false
	end
	
	local customgrids = StageAPI.GetCustomGrids(gridIndex)
	for i = 1, #customgrids do
		if mod.FoetusAttachableCustomGrids[customgrids[i].GridConfig.Name] then
			return true, false
		end
	end
	if #customgrids > 0 then
		return false, false
	end
	
	local basegrid = game:GetRoom():GetGridEntityFromPos(pos)
	if basegrid and mod.FoetusAttachableBasegameGrids[basegrid:GetType()] then
		return true, basegrid:GetType() == GridEntityType.GRID_WALL
	end
	
	return false, false
end

local function findAnchor(pos)
	local room = game:GetRoom()

	local surr = {}
	local walls = {}
	for i = 1, 4 do
		local hasAttachable, isWall = hasAttachableGridAtPos(pos + foetusVectors[i])
		if hasAttachable then
			surr[i] = true
			walls[i] = isWall
		else
			surr[i] = false
			walls[i] = false
		end
	end

	if surr[4] then 
		local offset = Vector(0, 20)
		if walls[4] then
			offset = Vector(0, 0)
		end
		return pos + Vector(-40, 0), room:GetGridIndex(pos + Vector(-40, 0)), offset
	elseif surr[2] then 
		local offset = Vector(0, 20)
		if walls[2] then
			offset = Vector(0, 0)
		end
		return pos + Vector(40, 0), room:GetGridIndex(pos + Vector(40, 0)), offset
	elseif surr[1] then 
		local offset = Vector(0, 20)
		return pos + Vector(0, -40), room:GetGridIndex(pos + Vector(0, -40)), offset
	elseif surr[3] then 
		local offset = Vector(0, 20)
		return pos + Vector(0, 40), room:GetGridIndex(pos + Vector(0, 40)), offset
	end

	return pos, -1, Vector(0, 20)
end

local function canWalkToTarget(npc, target)
	return game:GetRoom():CheckLine(npc.Position, target + (npc.Position - target):Resized(5), 0, 1, false, false)
end

local function foetusPathfind(npc, speedlimit)
	local target = target or npc:GetPlayerTarget().Position

	local npcdata = npc:GetData()
	if npc:CollidesWithGrid() then
		npcdata.lastgridcollision = npc.FrameCount
	end

	if canWalkToTarget(npc, target) and not (npcdata.lastgridcollision and npcdata.lastgridcollision + 15 > npc.FrameCount) then
		npc.Velocity = npc.Velocity * 0.8 + (target - npc.Position):Resized(0.5)
	else
		npc.Pathfinder:FindGridPath(target, npc.Velocity:Length() + 0.1, 2, false)
	end
	npc.Velocity = npc.Velocity:Resized(math.min(speedlimit, npc.Velocity:Length() * 1.2))
end

local function attachedGridIsDestroyed(gridIndex)
	if gridIndex <= -1 then
		return false
	end

	local customgrids = StageAPI.GetCustomGrids(gridIndex)
	for i = 1, #customgrids do
		if not mod.FoetusAttachableCustomGrids[customgrids[i].GridConfig.Name] then
			return true
		end
	end
	
	local grid = game:GetRoom():GetGridEntity(gridIndex)
	if not grid then
		return true
	end
	
	local typ = grid:GetType()
	if typ == GridEntityType.GRID_ROCKB or typ == GridEntityType.GRID_PILLAR or typ == GridEntityType.GRID_WALL then
		return false
	elseif typ == GridEntityType.GRID_POOP then
		return grid.State == 1000
	elseif typ == GridEntityType.GRID_ROCK or
	       typ == GridEntityType.GRID_ROCKT or
	       typ == GridEntityType.GRID_ROCK_BOMB or
	       typ == GridEntityType.GRID_ROCK_ALT or
	       typ == GridEntityType.GRID_ROCK_SS or
	       typ == GridEntityType.GRID_ROCK_SPIKED or
	       typ == GridEntityType.GRID_ROCK_ALT2 or
	       typ == GridEntityType.GRID_ROCK_GOLD
	then
		return grid.State == 2
	else
		return true
	end
end

function mod:foetusAI(npc, sprite, npcdata)
	if npc.SubType == mod.FF.Foetus.Sub then
		if not npcdata.init then
			local anchor, anchorIndex, anchorOffset = findAnchor(npc.Position)
			npcdata.anchor = anchor
			npcdata.anchorIndex = anchorIndex
			npcdata.anchorOffset = anchorOffset
			npcdata.cords = {}
			for i = 1, 7 do
				local cord = Isaac.Spawn(mod.FF.FoetusCord.ID, mod.FF.FoetusCord.Var, mod.FF.FoetusCord.Sub, npc.Position, nilvector, npc)
				cord.Parent = npc
				cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				cord:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
				cord.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				cord.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npcdata.cords[i] = cord
			end

			sprite:PlayOverlay("Awaken")
			npcdata.init = true
			
			npcdata.StateFrame = 0
		else
			npcdata.StateFrame = npcdata.StateFrame + 1
		end
		
		local attachedGridIsDestroyed = attachedGridIsDestroyed(npcdata.anchorIndex)

		if sprite:IsOverlayFinished("Awaken") then
			sprite:PlayOverlay("Head")
			npcdata.woke = true
		end

		if sprite:IsOverlayPlaying("Head") then
			npc:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
			foetusPathfind(npc, npcdata.detached and 6 or 4)

			if npcdata.detached then
				if not npc.Child or not npc.Child:Exists() or npc.Child:IsDead() or mod:isStatusCorpse(npc.Child) or 
				   npc.Child.Type ~= mod.FF.FoetusBaby.ID or npc.Child.Variant ~= mod.FF.FoetusBaby.Var or npc.Child.SubType ~= mod.FF.FoetusBaby.Sub
				then
					if npcdata.cords then
						for _, cord in pairs(npcdata.cords) do
							if cord:Exists() then
								cord:Kill()
							end
						end
						npcdata.cords = nil
					end
				else
					npcdata.anchor = npc.Child.Position + (npc.Position - npc.Child.Position):Resized(15)
				end
			else
				if npc.Position:Distance(npcdata.anchor) > 100 then
					npc.Position = npc.Position + (npcdata.anchor - npc.Position):Resized(npc.Position:Distance(npcdata.anchor) - 100)
				end

				if (npcdata.StateFrame >= 90 and math.random(12) == math.random(12) and npc.Velocity:Length() > 0) or
				   attachedGridIsDestroyed
				then
					local exploding = false
					if npcdata.anchorIndex > -1 and not attachedGridIsDestroyed then
						local grid = game:GetRoom():GetGridEntity(npcdata.anchorIndex)
						if grid then
							local typ = grid:GetType()
							if typ == GridEntityType.GRID_POOP then
								grid:Hurt(99999)
							elseif typ == GridEntityType.GRID_ROCK_BOMB then
								grid:Destroy(true)
								game:BombExplosionEffects(grid.Position, 40)
								exploding = true
							else
								grid:Destroy(true)
							end
						end
					end
					
					local baby = Isaac.Spawn(mod.FF.FoetusBaby.ID, mod.FF.FoetusBaby.Var, mod.FF.FoetusBaby.Sub, npcdata.anchor, nilvector, npc)
					baby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					baby.Parent = npc
					npc.Child = baby
					npcdata.detached = true
					sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.9, 0, false, math.random(6, 8)/10)
					if not attachedGridIsDestroyed then
						local tempOverride = StageAPI.TemporaryIgnoreSpawnOverride
						StageAPI.TemporaryIgnoreSpawnOverride = true
						npc:FireProjectiles(npcdata.anchor, Vector(9, 0), 8, ProjectileParams())
						StageAPI.TemporaryIgnoreSpawnOverride = tempOverride
						sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0, false, 0.8)
						game:ShakeScreen(4)
					end
					
					local clampedPos = game:GetRoom():GetClampedPosition(npc.Child.Position, npc.Child.Size)
					npcdata.anchor = npc.Child.Position + (npc.Position - npc.Child.Position):Resized(15)
					
					if exploding then
						baby:TakeDamage(40, DamageFlag.DAMAGE_EXPLOSION, EntityRef(nil), 0)
					end
				end
			end
		end

		if npcdata.cords then
			for i, cord in pairs(npcdata.cords) do
				local anchorPos = npcdata.anchor
				if not npcdata.detached then
					anchorPos = anchorPos + npcdata.anchorOffset
				end
				if npcdata.woke then
					cord.Velocity = (anchorPos - npc.Position):Resized(npc.Position:Distance(anchorPos) * (i - 1) / -7) + anchorPos - cord.Position
				else
					cord.Position = (anchorPos - npc.Position):Resized(npc.Position:Distance(anchorPos) * (i - 1) / -7) + anchorPos
				end
				local cordsprite = cord:GetSprite()
				cordsprite.Offset = Vector(0, -13*(0.04*(6-i)*(6-i)-1))
				cord:GetData().LastUpdate = game:GetFrameCount()
			end
		end
	elseif npc.SubType == mod.FF.FoetusBaby.Sub then
		
		local target = npc:GetPlayerTarget()

		if target.Position.X < npc.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if sprite:IsFinished("Attack01") then
			sprite:Play("Walk01")
		end

		if sprite:IsEventTriggered("Spiderball") then
			local vec = (target.Position - npc.Position):Resized(15)
			local spiderball = Isaac.Spawn(mod.FF.SpiderProj.ID, mod.FF.SpiderProj.Var, 0, npc.Position + npc.Velocity, vec, npc)
			spiderball:GetData().vel = vec
			spiderball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			spiderball:GetSprite().Offset = Vector(0, -20)
			spiderball:GetSprite().FlipX = not sprite.FlipX
			spiderball:Update()
			
			sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1)
		end

		if npc.Parent then
			if npc.Position:Distance(npc.Parent.Position) > 30 then
				npc.Velocity = (npc.Parent.Position - npc.Position) * 0.05
			end

			if sprite:IsFinished("Walk01") and npc.FrameCount % 3 == 0 and math.random(23) == math.random(23) and 
			   #Isaac.FindByType(EntityType.ENTITY_SPIDER, -1, -1, false, false) < 4 
			then
				sprite:Play("Attack01")
			end

			if (not npc.Parent:Exists() or npc.Parent:IsDead() or mod:isStatusCorpse(npc.Parent) or 
			    npc.Parent.Type ~= mod.FF.Foetus.ID or npc.Parent.Variant ~= mod.FF.Foetus.Var or npc.Parent.SubType ~= mod.FF.Foetus.Sub)
			then
				npc.Parent = nil
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.4, 0, false, 0.8)
			end
		else
			if sprite:IsFinished("Walk01") then
				sprite:Play("Rage")
				sfx:Play(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			elseif sprite:IsFinished("Rage") then
				sprite:Play("Walk02")
			end

			if sprite:IsPlaying("Walk02") then
				npc.Velocity = npc.Velocity * 0.8 + (target.Position - npc.Position):Resized(0.5)
				npc.Velocity = npc.Velocity * 1.2
				if npc.Velocity:Length() > 8 then
					npc.Velocity = npc.Velocity:Resized(8)
				end
			else
				npc.Velocity = npc.Velocity * 0.99
			end
		end
	elseif npc.SubType == mod.FF.FoetusCord.Sub then
		sprite:Play("UmbilicalCord", true)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_REWARD)
		if not npc.Parent or not npc.Parent:Exists() or npc.Parent:IsDead() or mod:isStatusCorpse(npc.Parent) or 
		   npc.Parent.Type ~= mod.FF.Foetus.ID or npc.Parent.Variant ~= mod.FF.Foetus.Var or npc.Parent.SubType ~= mod.FF.Foetus.Sub
		then
			npc:Kill()
		elseif not (npcdata.LastUpdate and game:GetFrameCount() == npcdata.LastUpdate) then
			npc.Velocity = nilvector
		end
	end
end
