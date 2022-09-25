local mod = FiendFolio
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:crossEyesAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		d.state = "idle"
		d.dir = math.random(2)
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
		d.relativity = (target.Position - npc.Position):Resized(10)
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		npc.Velocity = npc.Velocity * 0.97
		if npc.FrameCount % 20 == 0 then
			local dir
			if d.dir == 1 then
				dir = 20 + math.random(20)
				d.dir = 2
			else
				dir = -20 - math.random(20)
				d.dir = 1
			end
			local psihunter = mod.FindClosestEntity(npc.Position, 150, mod.FF.Psihunter.ID, mod.FF.Psihunter.Var)
			if psihunter then
				npc.Velocity = (psihunter.Position - npc.Position):Resized(-15)
			else
				local targpos = mod:randomConfuse(npc, target.Position)
				npc.Velocity = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(8):Rotated(dir), 1.2)
			end
		end

		if npc.Position:Distance(target.Position) < 200 and npc.StateFrame > 20 and not (mod:isScareOrConfuse(npc) or psihunter) then
			d.state = "attackstart"
			npc:PlaySound(mod.Sounds.PsionTaunt,1.2,0,false,math.random(130,150)/100)
			if target.Position.X > npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		end

	elseif d.state == "attackstart" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("AttackStart") then
			d.state = "waaaait"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("SpawnProjectile") then
			npc:PlaySound(mod.Sounds.PsionBubbleBreak,0.8,0,false,1)
			d.shootloop = true
			d.projecties = {}
			for i = -70, 70, 140 do
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, d.relativity:Rotated(i), npc):ToProjectile();
				local projdata = projectile:GetData();
				projectile.FallingSpeed = 0
				projectile.FallingAccel = -0.1
				projectile.Color = mod.ColorPsy
				projectile.Scale = 2
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
				projdata.projType = "crosseyes"
				projdata.state = 0
				projdata.dist = 70
				projdata.angle = (i)
				projectile.Parent = npc
				table.insert(d.projecties, projectile)
			end
		else
			mod:spritePlay(sprite, "AttackStart")
		end

	elseif d.state == "waaaait" then
		mod:spritePlay(sprite, "ProjectileHold")
		if npc.StateFrame > 6 then
			d.state = "FIRE"
		end
	elseif d.state == "FIRE" then
		if sprite:IsFinished("Shoot") then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			if target.Position.X > npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			sfx:Stop(mod.Sounds.CrosseyeShootLoop)
			d.shootloop = false
			npc:PlaySound(mod.Sounds.CrosseyeAppear,2,0,false,math.random(9,11)/10)
			for _, proj in ipairs(d.projecties) do
				if not proj:IsDead() then
					local projdata = proj:GetData()
					projdata.state = 1
					proj.Velocity = (target.Position - proj.Position):Resized(16):Rotated(projdata.angle * (-0.3 + math.min(0.3, target.Position:Distance(proj.Position) / 50)))
				end
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end

	if d.shootloop then
		if not sfx:IsPlaying(mod.Sounds.CrosseyeShootLoop) then
			sfx:Play(mod.Sounds.CrosseyeShootLoop, 1.2, 0, true, 1)
		end
	end

	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		sfx:Stop(mod.Sounds.CrosseyeShootLoop)
	end
end

function mod.crosseyesprojupdate(v,d)
	if d.projType == "crosseyes" then
		v.Color = mod.ColorPsy
		if d.state == 0 then
			v.Velocity = nilvector
			if v.Parent then
				if v.Parent:IsDead() or mod:isStatusCorpse(v.Parent) then
					d.state = 2
				else
					local FloatPosOffset = math.min(d.dist, v.FrameCount ^ 1.8)
					v.Position = v.Parent.Position + v.Parent:GetData().relativity:Resized(FloatPosOffset):Rotated(d.angle)
				end
			else
				d.state = 2
			end
		elseif d.state == 1 then
			--v.Velocity = d.angle
			if d.count then
				d.count = d.count + 1
				if d.count == 2 then
					v.ProjectileFlags = v.ProjectileFlags | ProjectileFlags.SMART
				elseif d.count == 15 then
					v.FallingAccel = -0.05
				end
			else
				d.count = 1
			end
		elseif d.state == 2 then
			v.FallingSpeed = 1
			v.FallingAccel = 1
		end
	end
end