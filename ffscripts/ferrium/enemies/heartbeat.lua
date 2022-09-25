local mod = FiendFolio
local game = Game()

function mod:heartbeatAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	if not data.init then
		data.speed = 3.2
		data.inflate = false
		data.shots = 0
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if math.abs(npc.Velocity.X) > 0.2 then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
	else
		sprite.FlipX = false
	end

	if mod:isScare(npc) then
		local targetDir = (targetpos-npc.Position):Resized(-6)
		npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
	elseif game:GetRoom():CheckLine(npc.Position, targetpos, 0, 1, false, false) then
		local targetDir = (targetpos-npc.Position):Resized(data.speed)
		npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
	else
		npc.Pathfinder:FindGridPath(targetpos, data.speed/5.3, 999, true)
	end

	if data.inflate == false then
		if sprite:IsFinished("Inflate") then
			npc.StateFrame = 0
			data.inflate = true
		elseif npc.StateFrame == 80 then
			sprite:Play("Inflate")
			npc:PlaySound(SoundEffect.SOUND_INFLATE, 0.5, 0, false, 1)
			data.speed = 1.7
		elseif npc.StateFrame < 80 then
			mod:spritePlay(sprite, "Idle01")
		end
	else
		if sprite:IsFinished("Deflate") then
			npc.StateFrame = 0
			data.shots = 0
			data.speed = 3.2
			data.inflate = false
		elseif npc.StateFrame == 80 then
			sprite:Play("Deflate")
		elseif npc.StateFrame < 80 then
			mod:spritePlay(sprite, "Idle02")
		end
	end

	if npc:IsDead() and data.inflate == true then
		npc:PlaySound(SoundEffect.SOUND_HEARTIN, 1, 0, false, 1)
		local creep = Isaac.Spawn(1000, 22, 0, npc.Position, Vector.Zero, npc):ToEffect()
		creep.SpriteScale = creep.SpriteScale * 1.3
        creep:Update()
		local params = ProjectileParams()
		params.BulletFlags = params.BulletFlags | ProjectileFlags.HIT_ENEMIES
		for i=0,19 do
			local sDir = RandomVector():Resized((math.random(14, 34)/3))
			npc:FireProjectiles(npc.Position, sDir, 0, params)
		end
		npc:FireProjectiles(npc.Position, Vector(3, 5), 9, params)
	end

	if sprite:IsEventTriggered("Beat") then
		if data.shots > 0 and not mod:isScareOrConfuse(npc) then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
			for i=0,data.shots do
				local params = ProjectileParams()
				params.FallingSpeedModifier = -math.random(10,15)
				params.FallingAccelModifier = math.random(5,14)/8
				local sDir = RandomVector():Resized(math.random(3,7))
				npc:FireProjectiles(npc.Position, sDir, 0, params)
			end
			--data.shots = 0
		end
		npc:PlaySound(SoundEffect.SOUND_HEARTBEAT_FASTEST, 1.5, 0, false, 1.3)
	end
end

function mod:heartbeatHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.inflate == true and flag ~= flag | DamageFlag.DAMAGE_CLONES then
		if data.shots < 4 then
			data.shots = data.shots+1
		end
		npc:TakeDamage(damage*1.5, flag | DamageFlag.DAMAGE_CLONES, source, 0)
		return false
	end
end