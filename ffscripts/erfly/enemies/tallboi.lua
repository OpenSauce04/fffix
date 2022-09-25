local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:tallBoiAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local path = npc.Pathfinder

	local maxshitlings = 7

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorPoop
		d.orbcount = 0
		d.spawnedShitCount = 0
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.Velocity = npc.Velocity * 0.9

	if d.state == "idle" then
		if not d.walking then
			mod:spritePlay(sprite, "Idle")
			if npc.StateFrame > 50 and r:RandomInt(20) == 0 or (mod:isConfuse(npc) and npc.StateFrame > 10 + (d.spawnedShitCount * 30)) then
				d.walking = true
				d.target = mod:FindRandomValidPathPosition(npc, 2, 60)
				npc.StateFrame = 0
			end
		else
			mod:spritePlay(sprite, "Walk")
			if sprite:IsEventTriggered("Waddle") then
				path:FindGridPath(d.target, 0.6, 900, false)
				if d.rot then
					npc.Velocity = npc.Velocity:Rotated(30)
					d.rot = nil
				else
					npc.Velocity = npc.Velocity:Rotated(-30)
					d.rot = true
				end
			end
			if npc.Position:Distance(d.target) < 20 or npc.StateFrame > 50 then
				d.walking = nil
				npc.StateFrame = 0
			end
		end

		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		d.orbcount = d.orbcount + 0.5
		if npc.Position:Distance(target.Position) < 100 + d.orbcount or mod:isScare(npc) then
			if mod.GetEntityCount(mod.FF.Shitling.ID, mod.FF.Shitling.Var) < maxshitlings and not mod:isScareOrConfuse(npc) and npc.StateFrame > d.spawnedShitCount * 30 then
				d.state = "sing"
				d.orbcount = 0
			else
				d.state = "run"
				npc.StateFrame = 0
			end
		end

	elseif d.state == "sing" then
		if sprite:IsFinished("Sing") then
			d.state = "defend"
		elseif sprite:IsEventTriggered("Whistle") then
			npc:PlaySound(SoundEffect.SOUND_WHISTLE,1,0,false,1.3)
			d.checkdone = true
			d.spawnedShitCount = d.spawnedShitCount or 0
			d.spawnedShitCount = d.spawnedShitCount + 1
			local vec = (target.Position - npc.Position):Resized(30)
			d.shitlings = {}
			for i = -50, 50, 50 do
				--local pos = room:FindFreePickupSpawnPosition((npc.Position + vec:Rotated(i)), 0, true)
				local pos = npc.Position + vec:Rotated(i)
				local extravec
				if pos:Distance(target.Position) < 50 then
					--extravec = (pos - npc.Position):Resized(-50)
					pos = npc.Position + vec:Resized(10):Rotated(i)
				else
					extravec = (pos - npc.Position):Resized(15)
					pos = pos + extravec
				end
				local shitling = Isaac.Spawn(mod.FF.Shitling.ID, mod.FF.Shitling.Var, 0, pos, nilvector, npc)
				table.insert(d.shitlings, shitling)
				shitling:Update()
			end
		else
			mod:spritePlay(sprite, "Sing")
		end
		if not d.checkdone then
			if target.Position.X > npc.Position.X then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
		end
	elseif d.state == "defend" then
		mod:spritePlay(sprite, "Idle")
		if target.Position.X > npc.Position.X then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end

		local lostcool = false

		if d.shitlings[2] then
			if d.shitlings[2]:IsDead() then
				lostcool = true
			end
		else
			lostcool = true
		end

		d.orbcount = d.orbcount + 0.4

		if target.Position:Distance(npc.Position) < 75 + d.orbcount then
			lostcool = true
		end

		if lostcool then
			d.state = "run"
			npc:PlaySound(SoundEffect.SOUND_BABY_HURT,1,0,false,0.7)
			npc.StateFrame = 0
		end
	elseif d.state == "run" then
		mod:spritePlay(sprite, "Walk")
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		--local pos = mod:FindRandomValidPathPosition(npc, 2, 60)
		if sprite:IsEventTriggered("Waddle") then
			local targvel = (npc.Position - target.Position):Resized(3)
			if d.rot then
				targvel = targvel:Rotated(30)
				d.rot = nil
			else
				targvel = targvel:Rotated(-30)
				d.rot = true
			end
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.4)
		end

		if npc.StateFrame > 75 then
			if mod.GetEntityCount(mod.FF.Shitling.ID, mod.FF.Shitling.Var) < maxshitlings and not mod:isScareOrConfuse(npc) then
				if npc.Position:Distance(target.Position) < 100 and npc.StateFrame > d.spawnedShitCount * 50 then
					d.state = "sing"
				end
			end
			if npc.StateFrame > 150 or npc:CollidesWithGrid() then
				d.state = "idle"
				d.orbcount = 0
				npc.StateFrame = 0
				d.walking = nil
			end
		end
	end
end

function mod:tallBoiHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.state == "idle" then
        d.state = "sing"
        d.orbcount = 0
    end
end

function mod:shitlingAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorPoop
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
		npc.Velocity = nilvector
	end

	if target.Position.X > npc.Position.X + 40 then
		sprite.FlipX = false
	elseif target.Position.X < npc.Position.X - 40 then
		sprite.FlipX = true
	end

	if sprite:IsEventTriggered("spit") then
		npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,2,false,1.3)
		local params = ProjectileParams()
		params.Variant = 3
		params.HeightModifier = 15
		params.Scale = 0.7
		npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(7), 0, params)
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 10 and r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 200 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			d.state = "spit"
		end
	elseif d.state == "spit" then
		if sprite:IsFinished("Spit") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Spit")
		end
	end
end

function mod:reallyTallBoiAI(npc)
	local sprite, d = npc:GetSprite(), npc:GetData()
	local target = npc:GetPlayerTarget()
	if not d.init then
		d.state = "idle"
		d.init = true
		npc.TargetPosition = npc.Position
		npc.SplatColor = mod.ColorPoop
	else
		npc.StateFrame = npc.StateFrame - 1
	end

	if npc.TargetPosition then
		npc.Position = npc.TargetPosition
		npc.Velocity = nilvector
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.3
		if npc.StateFrame <= -150 and math.random(30) == 1 and not mod:isScareOrConfuse(npc) then
			d.state = "retaliate"
			npc:PlaySound(SoundEffect.SOUND_BABY_HURT,1,0,false,0.15)
		end
	elseif d.state == "sing" then
		if sprite:IsFinished("Sing") then
			d.state = "idle"
			npc.StateFrame = 30
		elseif sprite:IsEventTriggered("Whistle") and not mod:isScare(npc) then
			npc:PlaySound(SoundEffect.SOUND_WHISTLE,1,0,false,0.7)
			d.checkdone = true
			d.spawnedShitCount = d.spawnedShitCount or 0
			d.spawnedShitCount = d.spawnedShitCount + 1
			d.shitlings = d.shitlings or {}
			local vec = (target.Position - npc.Position):Resized(30)
			if mod:isConfuse(npc) then
				vec = RandomVector():Resized(30)
			end
			-- -80, 80, 40
			for i = 1, 5 do
				local num = -80 + (40 * (i - 1))
				if d.shitlings[i] and d.shitlings[i]:Exists() then
					d.shitlings[i]:Remove()
				end
				--local pos = room:FindFreePickupSpawnPosition((npc.Position + vec:Rotated(i)), 0, true)
				local pos = npc.Position + vec:Rotated(num)
				local extravec
				if pos:Distance(target.Position) < 50 then
					--extravec = (pos - npc.Position):Resized(-50)
					pos = npc.Position + vec:Resized(10):Rotated(num)
				else
					extravec = (pos - npc.Position):Resized(15)
					pos = pos + extravec
				end
				local shitling = Isaac.Spawn(mod.FF.Shitling.ID, mod.FF.Shitling.Var, 0, pos, nilvector, npc)
				d.shitlings[i] = shitling
				shitling:Update()
				shitling:BloodExplode()
			end
			if mod.GetEntityCount(217) <= 3 then
				for i = 1, math.random(3) do
					local dipVec = vec:Resized(9):Rotated(50 + math.random(100))
					local dip = Isaac.Spawn(217, 0, 0, npc.Position + dipVec:Resized(npc.Size + 10), dipVec, npc)
					dip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					dip:Update()
				end
			end
		else
			mod:spritePlay(sprite, "Sing")
		end
	elseif d.state == "retaliate" then
		if sprite:IsFinished("Attack01") then
			if mod:isScareOrConfuse(npc) then
				d.state = "idle"
				npc.StateFrame = 30
			elseif d.shitlings then
				local sing
				for i = 1, #d.shitlings do
					if (not d.shitlings[i]) or (not d.shitlings[i]:Exists()) or (d.shitlings[i]:IsDead()) then
						sing = true
						break
					end
				end
				if sing then
					d.state = "sing"
				else
					d.state = "idle"
					npc.StateFrame = 10
				end
			else
				d.state = "sing"
			end
		elseif sprite:IsEventTriggered("Fart") then
			npc:PlaySound(SoundEffect.SOUND_FART_GURG,1,0,false,1)
		elseif sprite:IsEventTriggered("Shoot") and not mod:isScare(npc) then
			npc:PlaySound(SoundEffect.SOUND_FART,1,0,false,0.7)
			local vec = target.Position - npc.Position
			if mod:isConfuse(npc) then
				vec = RandomVector()
			end
			for i = 1, 5 do
				local cloud = Isaac.Spawn(1000, 141, 0, npc.Position, vec:Resized(i * 10), npc):ToEffect()
				cloud.Timeout = 360
				cloud:Update()
			end

		else
			mod:spritePlay(sprite, "Attack01")
		end
	end
end

function mod:reallyTallBoiHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.state == "idle" and npc:ToNPC().StateFrame <= 0 then
        d.state = "retaliate"
		npc:ToNPC():PlaySound(SoundEffect.SOUND_BABY_HURT,1,0,false,0.15)
        d.orbcount = 0
    end
end