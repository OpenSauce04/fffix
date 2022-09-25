local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.matteDirs = {
	[0] = "Right",
	[1] = "DR",
	[2] = "Down",
	[3] = "DL",
	[4] = "Left",
	[5] = "Up",
	[6] = "Up",
	[7] = "Up",
}

function mod:matteAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	d.wanderCount = d.wanderCount or 0

	if not d.init then
		d.state = "wander"
		d.init = true
	else
		d.wanderCount = d.wanderCount + 1
		npc.StateFrame = npc.StateFrame + 1
	end

	local creachureSpeed = 1.5

	if d.state == "wander" then
		if ((npc.StateFrame > 50 and r:RandomInt(30) == 1) or npc.StateFrame > 150) and not mod:isScareOrConfuse(npc) then
			d.state = "shoot with no ill intent"
			d.dir = r:RandomInt(8)
			mod:spritePlay(sprite, "Shoot" .. mod.matteDirs[d.dir])
		end
		if d.wanderCount > 160 or ((not d.walktarg) and d.wanderCount > 30) or (mod:isConfuse(npc) and d.wanderCount > 10) then
			d.walktarg = mod:FindRandomValidPathPosition(npc)
			d.wanderCount = 0
		end
		if mod:isScare(npc) then
			local targetvel = (target.Position - npc.Position):Resized(creachureSpeed * -1.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif d.walktarg and npc.Position:Distance(d.walktarg) > 30 then
			if game:GetRoom():CheckLine(npc.Position,d.walktarg,0,1,false,false) then
				local targetvel = (d.walktarg - npc.Position):Resized(creachureSpeed)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				mod:CatheryPathFinding(npc, d.walktarg, {
					Speed = creachureSpeed,
					Accel = 0.25,
					GiveUp = true
				})
			end
		else
			npc.Velocity = npc.Velocity * 0.7
			d.wanderCount = d.wanderCount + 2
		end

		local setFrame
		if npc.Velocity:Length() > 1 then
			if sprite:IsPlaying("IdleStill") then
				setFrame = math.floor((sprite:GetFrame() / 5) * 2)
			end
			mod:spritePlay(sprite, "Idle")
		else
			if sprite:IsPlaying("Idle") then
				setFrame = math.floor((sprite:GetFrame() / 2) * 5)
			end
			mod:spritePlay(sprite, "IdleStill")
		end
		if setFrame then
			sprite:SetFrame(setFrame)
		end
	elseif d.state == "shoot with no ill intent" then
		npc.Velocity = npc.Velocity * 0.7
		if sprite:IsFinished() then
			d.state = "wander"
			npc.StateFrame = 0
			d.wanderCount = 0
			d.shooting = nil
		elseif sprite:IsEventTriggered("Eyemerge") then
			d.defensesDown = true
			npc:PlaySound(SoundEffect.SOUND_SKIN_PULL,0.4,0,false,0.8)
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = true
		elseif sprite:IsEventTriggered("ShootEnd") then
			d.shooting = false
			d.defensesDown = nil
			--npc:PlaySound(SoundEffect.SOUND_SKIN_PULL,0.4,0,false,0.7)
		else
			mod:spritePlay(sprite, "Shoot" .. mod.matteDirs[d.dir])
		end

		if d.shooting and npc.FrameCount % 2 == 1 then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,math.random(70,80)/100)
			local params = ProjectileParams()
			params.HeightModifier = -10
			params.BulletFlags = params.BulletFlags | ProjectileFlags.BOUNCE
			local vec = Vector(15, 0):Rotated(d.dir * 45):Rotated(-10 + r:RandomInt(20))
			npc:FireProjectiles(npc.Position + vec, vec:Resized(8), 0, params)
		end
	end
end

function mod:matteHurt(npc, damage, flag, source)
    if not npc:GetData().defensesDown then
        npc.HitPoints = npc.HitPoints + damage * 0.2
    end
end