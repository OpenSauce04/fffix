local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:tadoKidAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local r = npc:GetDropRNG()
	local room = game:GetRoom()

	if not d.init then
		d.state = "idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER)
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
		local targetpos = mod:randomConfuse(npc, target.Position)
		if mod:isScare(npc) then
			d.targetvelocity = (targetpos - npc.Position):Resized(-4.5)
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.8)
		elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
			if npc.Position:Distance(target.Position) > 100 then
				d.targetvelocity = (targetpos - npc.Position):Resized(3)
				npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.8)
			else
				npc.Velocity = npc.Velocity * 0.9
			end
		else
			d.targetvelocity = path:FindGridPath(targetpos, 0.4, 1, true)
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity, 0.8)
		end
	end

	if npc.Velocity:Length() > 1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if d.state == "idle" then
		sprite:SetOverlayFrame("Head",sprite:GetFrame())
		if npc.StateFrame > 25 and r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 250 and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			d.state = "shoot"
			mod:spriteOverlayPlay(sprite, "Shoot")
		end
	elseif d.state == "shoot" then
		if sprite:IsOverlayFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 8 then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(7), npc):ToProjectile();
			projectile.Scale = 2
			projectile.FallingAccel = 0
			projectile.FallingSpeed = -0.1
			projectile.Color = mod.ColorPsyGrape
			local projdata = projectile:GetData();
			projdata.target = target
			projdata.projType = "triplesplit"
		else
			mod:spriteOverlayPlay(sprite, "Shoot")
		end
	end

	--[[if npc:IsDead() then
		if r:RandomInt(3) == 1 then
			local tot = mod.spawnent(npc, npc.Position, nilvector, 29, 960):ToNPC()
				tot:Morph(29, 960, 0, npc:GetChampionColorIdx())
			--npc:Morph(29, 960, 0, -1)
			--npc.HitPoints = npc.MaxHitPoints
		end
	end]]
end

function mod:totAI(npc)
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	d.ChangedHP = true
	d.HPIncrease = 0.1

	if npc.State == 4 then
		if npc.StateFrame > 24 then
			npc.State = 5
		end
	elseif npc.State == 5 then
		if npc.StateFrame > 34 and not mod:isScareOrConfuse(npc) then
			npc.State = 3
		end
	end
	if npc:GetSprite():IsEventTriggered("Jump") then
		npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
		local params = ProjectileParams()
		params.FallingSpeedModifier = -25
		params.FallingAccelModifier = 1.4
		params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
		npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized()*7, 0, params)
	end
end

function mod:tadoKidKill(npc)
	if npc:ToNPC():GetDropRNG():RandomInt(2) == 1 then
		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(npc)) then
			local spawned = Isaac.Spawn(mod.FF.Tot.ID, mod.FF.Tot.Var, 0, npc.Position, npc.Velocity, npc)
			spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
			spawned.HitPoints = spawned.MaxHitPoints
			spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end

			npc:Remove()
		end
	end
end