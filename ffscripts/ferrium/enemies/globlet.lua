local mod = FiendFolio

function mod:globletAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()

	if not data.init then
		if npc.SubType == 1 then
			data.ooze = true
		end
		if not data.ooze then
			data.state = "Idle"
		else
			data.state = "Ooze"
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if math.random(160) == 1 and not data.ooze then
        npc:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 0.6, 0, false, 1.3)
    end

	if data.state == "Idle" then
		if not data.ooze then
			if npc.Velocity:Length() > 0.1 then
				npc:AnimWalkFrame("WalkHori","WalkVert",0)
			else
				sprite:SetFrame("WalkVert", 0)
			end

			if mod:isScare(npc) then
				local targetvel = (targetpos - npc.Position):Resized(-5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
			elseif Game():GetRoom():CheckLine(npc.Position, targetpos, 0, 1, false, false) then
				local targetvel = (targetpos - npc.Position):Resized(3.5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.25)
			else
				npc.Pathfinder:FindGridPath(targetpos, 0.5, 900, true)
			end
		else
			if npc.Velocity:Length() > 0.1 then
				npc:AnimWalkFrame("WalkHoriB","WalkVertB",0)
			else
				sprite:SetFrame("WalkVertB", 0)
			end

			if mod:isScare(npc) then
				local targetvel = (targetpos - npc.Position):Resized(-10)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
			else
				local targetvel = (targetpos - npc.Position):Resized(6.5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.075)
			end

			if npc.StateFrame % 6 == 0 and rand:RandomInt(2) == 0 then
				local jitter = (targetpos - npc.Position):Rotated(90):Resized(-4+rand:RandomInt(80)/10)
				npc.Velocity = npc.Velocity+jitter
			end
		end
	elseif data.state == "Ooze" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
		if sprite:IsEventTriggered("Reform") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 0.8, 0, false, 1.2)
		elseif sprite:IsFinished("Regen") then
			data.state = "Idle"
		else
			mod:spritePlay(sprite, "Regen")
		end
	end
end

function mod:globletKill(ent)
	local npc = ent:ToNPC()
	local data = npc:GetData()

	if not data.ooze then
		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or
			npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or
			mod:isStatusCorpse(npc) or
			mod:isLeavingStatusCorpse(npc) or
			mod:grabbedByBigHorn(npc))
		then
			data.ooze = true
			local ooze = Isaac.Spawn(114, 15, 0, npc.Position, npc.Velocity*0.6, npc)
			ooze:ToNPC():Morph(ooze.Type, ooze.Variant, ooze.SubType, npc:ToNPC():GetChampionColorIdx())
			ooze.HitPoints = 16
			ooze:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			ooze:GetData().ooze = true

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				ooze:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
			npc:Remove()
		end
	end
end

function mod:globletDeath(ent)
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