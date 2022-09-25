-- Fishfreak --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:fishfreakAI(npc, sprite, npcdata)
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	mod.QuickSetEntityGridPath(npc, 900)

	if not npcdata.init then
		if npc.SubType == mod.FF.FishfreakPile.Sub then
			npcdata.state = "pile"
			npcdata.canDamage = false
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		else
			npcdata.state = "idle"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npcdata.canDamage = true
		end
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npcdata.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end
	
	if npcdata.state == "idle" then
		npcdata.canDamage = true
		
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end

		sprite:PlayOverlay("HeadIdle",true)

		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-8)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.7, 900, true)
			npcdata.currentvelocity = npc.Velocity
		end

		if npc.StateFrame >= 60 and (npc.Position:Distance(targetpos) > 120 or path:HasPathToPos(targetpos, false) == false) and not mod:isScareOrConfuse(npc) then
			local piles = Isaac.FindByType(mod.FF.FishfreakPile.ID, mod.FF.FishfreakPile.Var, mod.FF.FishfreakPile.Sub, true, true)
			if #piles > 0 then
				npcdata.state = "submerge"
				sprite:Play("Submerge", true)
				sprite:RemoveOverlay()
				npc.Velocity = nilvector
			end
		end
	elseif npcdata.state == "submerge" then
		npc.Velocity = nilvector
		sprite.FlipX = false
		
		if sprite:IsFinished("Submerge") then
			npcdata.state = "hiding"
			npc.StateFrame = 0
		elseif not sprite:IsPlaying("Submerge") then
			sprite:Play("Submerge", true)
		end
		
		if sprite:IsEventTriggered("Splash") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, 0.7, 0, false, 0.8)
		end
		
		if sprite:IsEventTriggered("NoDMG") then
			npcdata.canDamage = false
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			npcdata.originalCollisionDamage = npc.CollisionDamage
			npc.CollisionDamage = 0
		end
	elseif npcdata.state == "hiding" then
		npc.Velocity = nilvector
		npcdata.canDamage = false
		
		if not (sprite:IsPlaying("Pile") or sprite:IsFinished("Pile")) then
			sprite:Play("Pile", true)
		end
		
		if npc.StateFrame >= 5 then
			npcdata.state = "emerge"
			npc:PlaySound(SoundEffect.SOUND_BONE_HEART, 0.8, 2, false, 0.6)
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			
			local piles = Isaac.FindByType(mod.FF.FishfreakPile.ID, mod.FF.FishfreakPile.Var, mod.FF.FishfreakPile.Sub, true, true)
			local goodpiles = {}
			local okaypiles = {}
			for _, pile in pairs(piles) do
				if pile:ToNPC().Pathfinder:HasPathToPos(target.Position, false) then
					if pile.Position:Distance(target.Position) <= 400 then
						table.insert(goodpiles, pile)
					else
						table.insert(okaypiles, pile)
					end
				end
			end
			local pile = mod:GetRandomElem(goodpiles)
			if not pile then
				pile = mod:GetRandomElem(okaypiles)
			end
			
			if pile then
				--[[if target then
					local closestPile = nil
					local closestPathfindablePile = nil
					
					for i = 1, #piles do
						if closestPile == nil or (closestPile.Position - target.Position):Length() > (piles[i].Position - target.Position):Length() then
							closestPile = piles[i]
						end
						
						if piles[i]:ToNPC().Pathfinder:HasPathToPos(target.Position, false) and
						   (closestPathfindablePile == nil or (closestPathfindablePile.Position - target.Position):Length() > (piles[i].Position - target.Position):Length())
						then
							closestPathfindablePile = piles[i]
						end
					end
					
					pile = closestPathfindablePile or closestPile
				end]]
				
				local pilePos = pile.Position
				pile.Position = npc.Position
				npc.Position = pilePos
				
				mod:swapMinecartContents(npc, pile, EntityGridCollisionClass.GRIDCOLL_GROUND, EntityGridCollisionClass.GRIDCOLL_GROUND)
			end
		end
	elseif npcdata.state == "emerge" then
		npc.Velocity = nilvector
		npcdata.canDamage = true
		npc.CollisionDamage = npcdata.originalCollisionDamage or 1
		
		if sprite:IsFinished("Emerge") then
			npcdata.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.Variant = 1
			params.FallingAccelModifier = 2
			params.Color = mod.ColorFishfreak
			for i = 1, 3 do
				params.FallingSpeedModifier = math.random(-30, -25)
				local vec = (targetpos - npc.Position) + Vector(30, 0):Rotated(math.random(360))
				vec = vec:Resized(math.min(vec:Length(), math.random(6,8)))
				npc:FireProjectiles(npc.Position, vec, 0, params)
			end
		elseif not sprite:IsPlaying("Emerge") then
			sprite:Play("Emerge", true)
		end
	elseif npcdata.state == "pile" then
		npc.Velocity = nilvector
		npcdata.canDamage = false
		mod.QuickSetEntityGridPath(npc, 900)
		if not (sprite:IsPlaying("Pile") or sprite:IsFinished("Pile")) then
			sprite:Play("Pile", true)
		end
		
		local fishies = Isaac.FindByType(mod.FF.Fishfreak.ID, mod.FF.Fishfreak.Var, 0, true, true)
		if #fishies == 0 then
			npcdata.DeathTimer = (npcdata.DeathTimer or 10) - 1
			if npcdata.DeathTimer <= 0 then
				npc:Kill()
			end
		end
	end
end

function mod:fishfreakTakeDmg(entity, damage, flags, source, countdown)
	if not entity:GetData().canDamage then
		return false
	end
end

function mod:fishfreakKill(entity)
	local data = entity:GetData()
	if entity.SubType ~= mod.FF.FishfreakPile.Sub then
		if not (entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) or entity:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(entity)) then
			local spawned = Isaac.Spawn(mod.FF.FishfreakPile.ID, mod.FF.FishfreakPile.Var, mod.FF.FishfreakPile.Sub, entity.Position, nilvector, entity)

			if (entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end

			mod:swapMinecartContents(entity, spawned, EntityGridCollisionClass.GRIDCOLL_GROUND, EntityGridCollisionClass.GRIDCOLL_GROUND)
			entity:Remove()
		end
	end
end
