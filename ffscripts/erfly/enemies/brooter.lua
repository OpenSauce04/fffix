local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.calzoneshoottable = {
	0, --blind maggot
	0,
	0,
	0,
	1, --charger
	1,
	1,
	2, --spitter
	2,
	2,
	3, --creep
	3,
	4, --dank
	4,
}

function mod:shootMaggot(npc, target, shoottype, maggot)
	if(not maggot) then
		if(shoottype == 0) then
			maggot = math.random(3) - 1
		elseif shoottype == 1 then
			local level = game:GetLevel()
			local stage = level:GetStage()
			local stageType = level:GetStageType()
			if stageType == StageType.STAGETYPE_AFTERBIRTH and (stage == 5 or stage == 6) then
				maggot = mod.calzoneshoottable[math.random(1, 14)]
			else
				maggot = mod.calzoneshoottable[math.random(1, 12)]
			end
		elseif shoottype == 2 then
			maggot = 6
		else
			maggot = math.random(3) - 1
		end
	end
	local spawn = mod.spawnent(npc, npc.Position, nilvector, mod.FF.FlyingMaggot.ID, mod.FF.FlyingMaggot.Var, maggot, 0)
	spawn:GetData().targetpos = target
	spawn:Update()
end

function mod:brooterAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	--Movement
		npc.Velocity = npc.Velocity * 0.9
		local targetvel
		if mod:isScare(npc) or npc.Position:Distance(target.Position) < 120 then
			targetvel = (target.Position - npc.Position):Resized(-5)
			d.gridtarget = nil
		else
			if npc.StateFrame % 30 == 0 or (not d.gridtarget) or (mod:isConfuse(npc) and npc.StateFrame % 5 == 0) then
				if (not mod:isScareOrConfuse(npc)) and math.random(3) == 1 then
					d.gridtarget = target.Position
				else
					d.gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				end
			end
			targetvel = (d.gridtarget - npc.Position):Resized(5)
		end

		targetvel = targetvel + (targetvel:Rotated(90):Resized(1) * (math.sin(npc.FrameCount / 10) * 10))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)

	if d.state == "idle" then
		if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
			mod:spritePlay(sprite, "FlyHori")
		elseif npc.Velocity.X > 0.3 then
			mod:spritePlay(sprite, "FlyRight")
		elseif npc.Velocity.X < -0.3 then
			mod:spritePlay(sprite, "FlyLeft")
		else
			mod:spritePlay(sprite, "FlyHori")
		end

		if npc.StateFrame > 100 and math.random(25) == 1 and not mod:isScareOrConfuse(npc) then
			if mod.GetMaggotCount() < 10 then
				d.state = "shootmaggot"


				local vec = target.Position - npc.Position
				vec = vec:Resized(math.min(vec:Length(), 150))
				d.target = game:GetRoom():FindFreeTilePosition(npc.Position + vec, 0)

				if math.abs(vec.Y) > math.abs(vec.X) then
					if vec.Y > 0 then
						d.dir = "Down"
					else
						d.dir = "Up"
					end
				else
					if vec.X > 0 then
						d.dir = "Right"
					else
						d.dir = "Left"
					end
				end
			end
		end

		d.cooldown = d.cooldown or 20
		d.cooldown = d.cooldown - 1

		if d.cooldown < 1 and not mod:isScareOrConfuse(npc) then
			if math.abs(math.abs(npc.Position.X) - math.abs(target.Position.X)) < 20 then
				if target.Position.Y > npc.Position.Y then
					d.dir = 2
				else
					d.dir = 0
				end
				d.state = "chubber"
				npc:PlaySound(mod.Sounds.BeeBuzzPrep, 1, 0, false, math.random(120,130)/100)
			elseif math.abs(math.abs(npc.Position.Y) - math.abs(target.Position.Y)) < 20 then
				d.state = "chubber"
				npc:PlaySound(mod.Sounds.BeeBuzzPrep, 1, 0, false, math.random(140,160)/100)
				if target.Position.X > npc.Position.X then
					d.dir = 1
				else
					d.dir = 3
				end
			end
		end
	elseif d.state == "chubber" then
		if sprite:IsFinished("ShootChubber") then
			d.state = "idle"
			d.cooldown = 30
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH,1,0,false,math.random(90,100)/100)
			--local chub = Isaac.Spawn(39,22,0,npc.Position,Vector(0,20),nil)
			local chub = mod.spawnent(npc, npc.Position, Vector(0,-12):Rotated(90 * d.dir), 39, 22, 1)
			chub:Update()
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(0,20):Rotated(90 * d.dir), 0.8)
		else
			mod:spritePlay(sprite, "ShootChubber")
		end
	elseif d.state == "shootmaggot" then
		if sprite:IsFinished("Shoot" .. d.dir) then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.Burpie, 1, 0, false, math.random(80,90)/100)
			local vec = (d.target - npc.Position):Resized(-10)
			npc.Velocity = mod:Lerp(npc.Velocity,vec, 0.8)
			mod:shootMaggot(npc, d.target, 0)
		else
			mod:spritePlay(sprite, "Shoot" .. d.dir)
		end
	end
end

function mod:flyingMaggotAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	if not d.init then
		d.init = true
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		local targetpos = d.targetpos or npc.Position
		local lengthto = targetpos - npc.Position
		npc.Velocity = lengthto / 15 * 0.9
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	end


	if subt == 1 then
		mod:spritePlay(sprite, "Spin02")
	elseif subt == 2 then
		mod:spritePlay(sprite, "Spin03")
	elseif subt == 3 then
		mod:spritePlay(sprite, "Spin05")
	elseif subt == 4 then
		mod:spritePlay(sprite, "Spin06")
	elseif subt == 6 then
		mod:spritePlay(sprite, "Spin04")
	elseif subt == 7 then
		mod:spritePlay(sprite, "Spin07")
	else
		mod:spritePlay(sprite, "Spin01")
	end

	if npc.Velocity.X > 0 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	sprite.Offset = Vector(0, -2 * (-0.020 * ((npc.StateFrame - 20)^2) + 29.5))
	if sprite.Offset.Y > 0 then
		local enmy = 21
		local var = 0
		local HPmult = 1
		if subt == 1 then
			enmy = 23
		elseif subt == 2 then
			enmy = 31
		elseif subt == 3 then
			enmy = mod.FF.CreepyMaggot.ID
			var = mod.FF.CreepyMaggot.Var
			local creep = Isaac.Spawn(1000, 23, 0, npc.Position, nilvector, npc)
			creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
			creep.Size = creep.Size * 1.5
			creep:GetSprite().Scale = creep:GetSprite().Scale * 1.5
		elseif subt == 4 then
			enmy = 23
			var = 2
			local creep = Isaac.Spawn(1000, EffectVariant.CREEP_BLACK, 0, npc.Position, nilvector, npc)
			creep.Size = creep.Size * 1.5
			creep:GetSprite().Scale = creep:GetSprite().Scale * 1.5
		elseif subt == 6 then
			enmy = 23
			var = 1
			HPmult = 0.5
		elseif subt == 7 then
			enmy = mod.FF.RolyPoly.ID
			var = mod.FF.RolyPoly.Var
		end

		if npc.SpawnerType == mod.FF.Slinger.ID and npc.SpawnerVariant == mod.FF.Slinger.Var then
			HPmult = 0.66
		end

		if npc.Pathfinder:HasPathToPos(npc.Position) then
			local e = mod.spawnent(npc, npc.Position, nilvector, enmy, var):ToNPC()
			e.MaxHitPoints = e.MaxHitPoints * HPmult
			e.HitPoints = e.MaxHitPoints
			e:GetData().ChangedHP = true
			e:GetData().HPIncrease = 0.1
			npc:Remove()
		else
			npc:Kill()
		end
	else
		npc.StateFrame = npc.StateFrame + 4
	end

end