local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:clergyAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if not d.init then
		npc.SpriteOffset = Vector(1, -7)
		d.state = "idle"
		d.projectiles = {}
		d.offsetCounter = 0
		for i = 120, 360, 120 do
			local projectile = Isaac.Spawn(9, 4, 0, npc.Position, Vector(1,0):Rotated(i), npc):ToProjectile();
			local projdata = projectile:GetData();
			projectile.FallingSpeed = 0
			projectile.FallingAccel = -0.1
			projectile.Color = mod.ColorPsy
			projectile.Scale = 1.5
			projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			projdata.projType = "Clergy"
			projdata.offset = i
			projectile.Parent = npc
			projectile:Update()
			table.insert(d.projectiles, projectile)
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local recalculate = false
	local currSpeed = 1.5

	if d.state == "idle" then
		local vec = target.Position - npc.Position
		if math.abs(vec.X) > math.abs(vec.Y) then
			if vec.X > 0 then
				mod:spritePlay(sprite, "IdleRight")
			else
				mod:spritePlay(sprite, "IdleLeft")
			end
		else
			mod:spritePlay(sprite, "Idle")
		end
		sprite:SetFrame(npc.StateFrame % 16)

		if npc.StateFrame > 30 and #d.projectiles > 0 and math.random(10) == 1 and game:GetRoom():CheckLine(npc.Position,target.Position,3,1,false,false) and not mod:isScareOrConfuse(npc) then
			d.state = "shoot"
			d.targOff = 0
		end
	elseif d.state == "shoot" then
		currSpeed = 1
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = -1
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_RAGMAN_4,1,0,false,math.random(90,110)/100)
			local dist = 9999
			local choice
			for i = 1, #d.projectiles do
				local calcDist = d.projectiles[i].Position:Distance(target.Position)
				if calcDist < dist then
					choice = i
					dist = calcDist
				end
			end
			if choice then
				d.projectiles[choice]:GetData().clergyLaunch = true
				d.projectiles[choice]:GetData().clergyTarget = target
			end
			table.remove(d.projectiles, choice)
			recalculate = true
		elseif sprite:IsEventTriggered("Done") then
			d.targOff = 5
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end

	local targvec = mod:diagonalMove(npc, currSpeed, true)
	npc.Velocity = mod:Lerp(npc.Velocity, targvec:Rotated(math.sin(npc.FrameCount / 10) * 30), 0.3)

	for i = 1, #d.projectiles do
		--print((d.projectiles[i].Position - npc.Position):GetAngleDegrees())
		if d.projectiles[i] and (not d.projectiles[i]:Exists()) then
			table.remove(d.projectiles, i)
			d.offsetAdditional = 1
			npc.StateFrame = 0
			recalculate = true
		end
	end
	if #d.projectiles < 3 and d.state == "idle" and npc.StateFrame % 20 == 0 then
		local projectile = Isaac.Spawn(9, 4, 0, npc.Position, nilvector, npc):ToProjectile();
		local projdata = projectile:GetData();
		projectile.FallingSpeed = 0
		projectile.FallingAccel = -0.1
		projectile.Color = mod.ColorPsyGrape2
		projectile.Scale = 1.5
		projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
		projdata.projType = "Clergy"
		projdata.offset = 0
		projectile.Parent = npc
		projectile:Update()
		table.insert(d.projectiles, projectile)
		d.offsetAdditional = 0
		recalculate = true
	end
	if recalculate then
		d.spawnSet = 0
		local numProj = #d.projectiles
		local firstoff
		for i = 1, #d.projectiles do
			if d.projectiles[i] and (d.projectiles[i]:Exists()) then
				if not firstoff then
					firstoff = (d.projectiles[i].Position - npc.Position):GetAngleDegrees()
				end
				d.projectiles[i]:GetData().offset = ((360 / numProj) * i) + firstoff
			end
		end
	end

	d.offsetCounter = d.offsetCounter or 0
	d.offsetAdditional = d.offsetAdditional or 5
	d.targOff = d.targOff or 5
	d.offsetAdditional = mod:Lerp(d.offsetAdditional, d.targOff, 0.1)
	d.offsetCounter = (d.offsetCounter + d.offsetAdditional) % 360

	d.spawnSet = d.spawnSet or 0
	d.spawnSet = d.spawnSet + 1
end

function mod.clergyProj(v,d)
	if d.clergyLaunch then
		v.FallingAccel = -0.02
		d.stateFrame = d.stateFrame or 1
		if d.Nihilism then
			if d.stateFrame < 30 then
				d.stateFrame = d.stateFrame + 1
			end
		else
			d.stateFrame = d.stateFrame + 1
			if d.stateFrame > 15 then
				d.stateFrame = d.stateFrame + 1
			end
		end
		local lerpness = 1 / d.stateFrame
		v.Velocity = mod:Lerp(v.Velocity, (d.clergyTarget.Position - v.Position):Resized(20), lerpness)

		if v.FrameCount % 3 == 0 then
			local trail = Isaac.Spawn(1000, 111, 0, v.Position, nilvector, v):ToEffect()
			trail:GetSprite().Offset = Vector(0, v.Height)
			trail:GetSprite():ReplaceSpritesheet(0, "gfx/effects/tear_bloodytrail_tear.png");
			trail:GetSprite():LoadGraphics()
			trail.Color = mod.ColorPsyGrape2
			trail.SpriteScale = Vector(0.5, 0.5)
			trail:Update()
		end

	elseif d.projType == "Clergy" then
		if v.Parent and not mod:isStatusCorpse(v.Parent) then
			local p = v.Parent:ToNPC()
			local frameOff = p:GetData().offsetCounter or p.StateFrame
			local targOff = p:GetData().offsetAdditional or 5
			local spawnSet = p:GetData().spawnSet or 5
			local targpos = p.Position + Vector(40, 0):Rotated(d.offset + frameOff)
			local lerpness = math.min(0.5, spawnSet / 20)
			v.Velocity = mod:Lerp(v.Velocity, (targpos - v.Position), lerpness)
			local pdist = v.Position:Distance(p.Position)
			if pdist > 40 then
				v.Velocity = v.Velocity + ((p.Position - v.Position):Resized(pdist - 40))
			end
		else
			v.Velocity = v.Velocity:Resized(math.min(v.Velocity:Length(), 5))
			v.FallingSpeed = 1
			v.FallingAccel = 2
			d.clergyDead = true
		end
		if v.FrameCount % 3 == 0 then
			local trail = Isaac.Spawn(1000, 111, 0, v.Position, v.Velocity * 0.2 + Vector(0, 0 - math.random()*3), v):ToEffect()
			trail:GetSprite().Offset = Vector(0, v.Height)
			trail:GetSprite():ReplaceSpritesheet(0, "gfx/effects/tear_bloodytrail_tear.png");
			trail:GetSprite():LoadGraphics()
			trail.Color = mod.ColorPsyGrape2
			trail.SpriteScale = Vector(0.7, 0.7)
			trail.DepthOffset = -10
			trail:Update()
		end
	end
	if (d.clergyLaunch or d.projType == "Clergy") then
		v.Color = mod.ColorPsyGrape2
	end
end