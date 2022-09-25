local mod = FiendFolio
local game = Game()

function mod:dewdropAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rng = npc:GetDropRNG()

	if not data.init then
		npc.SplatColor = mod.ColorWaterPeople
		data.state = "Idle"
		data.frameCount = 30+rng:RandomInt(10)
		if game:GetRoom():HasWater() then
			data.water = true
		end
		data.init = true
	end
	
	if npc.FrameCount % 16 == 0 and not data.water then
		local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
		splat.Color = mod.ColorWaterPeople
		splat:Update()
	end

	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")

		if mod:isScare(npc) then
			local targetVel = (targetpos - npc.Position):Resized(-2)
			npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.1)
		else
			local targetVel = (targetpos - npc.Position):Resized(1.8)
			npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.1)
		end

		if data.frameCount < 0 and not mod:isScareOrConfuse(npc) then
			data.state = "Attack"
			mod:spritePlay(sprite, "Attack")
			data.frameCount = 60+rng:RandomInt(10)
		else
			data.frameCount = data.frameCount-1
		end
	elseif data.state == "Attack" then
		local targetVel = (targetpos - npc.Position):Resized(1)
		npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.1)

		if sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
			for i=0,3 do
				local projVel = Vector(2+rng:RandomInt(4), 0):Rotated(rng:RandomInt(360))
				local projectile = Isaac.Spawn(9, 4, 0, npc.Position, projVel, npc):ToProjectile()
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
				projectile.FallingAccel = -0.0625
				projectile.FallingSpeed = -3
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
				mod:makeCharmProj(npc, projectile)
				projectile:GetData().projType = "dewdrop"
			end
		elseif sprite:IsFinished("Attack") then
			data.state = "Idle"
		end
	end
end

function mod.dewdropProj(v,d)
	if d.projType == "dewdrop" then
		if v.SpawnerEntity and v.SpawnerEntity:Exists() and not mod:isStatusCorpse(v.SpawnerEntity) then
			if v.FrameCount > 10 then
				v.Velocity = mod:Lerp(v.Velocity, v.SpawnerEntity.Velocity, 0.1)
			end
		elseif not d.splish then
			v.Velocity = v.Velocity*0.7
			v.FallingSpeed = -10
			v.FallingAccel = 1.5
			d.splish = true
		else
			v.Velocity = v.Velocity*0.7
		end
	end
end