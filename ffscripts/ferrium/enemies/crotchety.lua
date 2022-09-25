local mod = FiendFolio

function mod:crotchetyAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local data = npc:GetData()

	if not data.init then
		if not data.ghost then
			data.state = "Idle"
		else
			data.state = "Revenge Two"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if not data.ghost then
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end
	end

	if data.state == "Idle" then
		sprite:PlayOverlay("Head",true)
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif Game():GetRoom():CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(3)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.4, 900, true)
		end
	elseif data.state == "Revenge" then
		if sprite:IsOverlayFinished("Retaliate") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.shot = nil
		elseif sprite:GetOverlayFrame() == 7 and not data.shot then
			data.shot = true
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(6), 0, ProjectileParams())
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, 1, 0, false, 1)
		else
			mod:spriteOverlayPlay(sprite, "Retaliate")
		end

		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif Game():GetRoom():CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(2.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.4, 900, true)
		end
	elseif data.state == "Revenge Two" then
		if sprite:IsFinished("Death") then
			npc:Remove()
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
			params.Scale = 1.8
			params.Spread = 3.3
			params.Variant = 4
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(6), 2, params)
		else
			mod:spritePlay(sprite, "Death")
		end

		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			local targetvel = (targetpos - npc.Position):Resized(5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.07)
		end
	end
end

function mod:crotchetyHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.state == "Idle" and not mod:isScareOrConfuse(npc) then
		data.state = "Revenge"
	end
	if data.ghost then
		return false
	end
end

function mod:crotchetyKill(ent)
	local npc = ent:ToNPC()
	local data = npc:GetData()

	if not data.ghost then
		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or
			npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or
			mod:isStatusCorpse(npc) or
			mod:isLeavingStatusCorpse(npc) or
			mod:grabbedByBigHorn(npc))
		then
			data.ghost = true
			local ghost = Isaac.Spawn(114, 16, 0, npc.Position, (npc.Position-npc:GetPlayerTarget().Position):Resized(7), npc)
			ghost:ToNPC():Morph(ghost.Type, ghost.Variant, ghost.SubType, npc:ToNPC():GetChampionColorIdx())
			ghost.HitPoints = 0
			ghost:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			ghost:GetData().ghost = true

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				ghost:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
			npc:Remove()
		end
	end
end

function mod:crotchetyDeath(ent)
	local npc = ent:ToNPC()
	local data = npc:GetData()

	if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or
	        npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or
	        mod:isStatusCorpse(npc) or
	        mod:isLeavingStatusCorpse(npc) or
			mod:grabbedByBigHorn(npc))
	then
		mod:spawnBKeeperCoin(npc, true)
		mod:spawnVadeRetroGhost(npc)
	end
end