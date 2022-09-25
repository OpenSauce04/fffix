local mod = FiendFolio

function mod:tangoAI(npc) -- Tango
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rand = npc:GetDropRNG()

	if not data.init then
		npc.SplatColor = mod.ColorGhostly
		data.beat = 0
		data.stateFrame = 53 -- Should be 22 numbers less than the minimum data stateFrame.
		data.state = "idle"
		data.init = true
	else
		data.stateFrame = data.stateFrame+1
	end

	if npc.State == 17 then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Death") then
			npc:Remove()
		elseif not sprite:IsPlaying("Death") then
			sprite:Play("Death")
		end
	elseif data.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame % 40 == 0 then
			local target = mod:FindRandomFreePosAir(targetpos, 120)
			data.targetVel = (target - npc.Position):Resized(2.5)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, data.targetVel, 0.1)
		if data.stateFrame >= 75 and data.stateFrame < 95 and rand:RandomInt(20) == 0 and not mod:isScareOrConfuse(npc) and not mod:isCharm(npc) then
			sprite:Play("AttackStart")
			npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			data.state = "lagtrain"
		elseif data.stateFrame >= 95 and not mod:isScareOrConfuse(npc) and not mod:isCharm(npc) then
			sprite:Play("AttackStart")
			npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			data.state = "lagtrain"
		end
	elseif data.state == "lagtrain" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
		if data.beat == 0 then
			if sprite:IsFinished("AttackStart") then
				local warpPos = (targetpos - npc.Position):Normalized()*45
				data.prevNum = math.random(4)
				sprite:Play(mod.tangoPoses[data.prevNum])
				npc.Position = npc.Position+warpPos
				data.beat = 1
			end
		elseif data.beat < 3 then
			if sprite:IsFinished() then
				local warpPos = (targetpos - npc.Position):Normalized()*45
				if data.beat % 2 == 0 then
					local tangoImage = Isaac.Spawn(1000, 1750, 0, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				else
					local tangoImage = Isaac.Spawn(1000, 1750, 1, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				end
				npc.Position = npc.Position+warpPos
				data.prevNum = mod:nextTangoPose(data.prevNum)
				sprite:Play(mod.tangoPoses[data.prevNum])
				data.beat = data.beat+1
			end
		else
			if sprite:IsFinished("AttackEnd") then
				data.state = "idle"
				data.beat = 0
				data.stateFrame = 0
			elseif sprite:IsFinished() then
				local warpPos = (targetpos - npc.Position):Normalized()*45
				sprite:Play("AttackEnd")
				if data.beat % 2 == 0 then
					local tangoImage = Isaac.Spawn(1000, 1750, 0, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				else
					local tangoImage = Isaac.Spawn(1000, 1750, 1, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				end
				npc.Position = npc.Position+warpPos
				npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			end
		end
	end
end

mod.tangoPoses = {"Image01", "Image02", "Image03", "Image04", "Image05"}
function mod:nextTangoPose(prevnum)
	local tnumber = math.random(10)
	if tnumber > 5 and tnumber < 10 then
		tnumber = tnumber-5
	elseif tnumber == 10 then
		tnumber = tnumber-math.random(6,9)
	end
	if tnumber == prevnum then
		if tnumber > 1 then
			tnumber = tnumber-1
		else
			tnumber = tnumber+1
		end
	end
	return tnumber
end

function mod:tangoafterimageAI(npc) -- Tango's Afterimage
	local sprite = npc:GetSprite()
	local data = npc:GetData()

	if npc.FrameCount > 50 then
		if npc.SubType == 0 then
			for i=0,3 do
				local projectile = Isaac.Spawn(9, 4, 0, npc.Position, Vector(0,8):Rotated(90*i), npc):ToProjectile()
				--projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			end
		else
			for i=0,3 do
				local projectile = Isaac.Spawn(9, 4, 0, npc.Position, Vector(0,8):Rotated(45+(90*i)), npc):ToProjectile()
				--projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			end
		end
		local poof = Isaac.Spawn(1000, 12, 0, npc.Position, Vector.Zero, npc)
		poof.Color = FiendFolio.ColorGhostly
		SFXManager():Play(SoundEffect.SOUND_CANDLE_LIGHT,1.2,0,false,1)
		npc:Remove()
	end
end
