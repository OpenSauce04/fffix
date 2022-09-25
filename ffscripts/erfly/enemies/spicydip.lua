local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:berryAI(npc)
	local d = npc:GetData()
	local s = npc:GetSprite()
	local rng = npc:GetDropRNG()

	if s:IsFinished("Appear") then
		s:Play("Idle")
		d.init = true
		d.state = 'idle'
		d.statetime = 0
		d.spawnpos = npc.Position
		d.lastpos = npc.Position
		d.wandertarget = Isaac.GetFreeNearPosition(npc.Position, 160)
		d.firstrev = false
		d.lasthp = npc.MaxHitPoints
	end

	if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.8,0.8)
		blood:Update()
	end

	--local pos = Isaac.WorldToRenderPosition(npc.Position + Vector(0, -40)) + l.scrollOffset
	--l.Font2:DrawString("i want dat meatball", pos.X, pos.Y, l.cyanidecolor, 0, true)

	if d.state == 'idle' then
		if s:IsFinished("RevOutro") then
			s:Play("Idle")
			d.lasthp = npc.HitPoints
		end
		if s:IsPlaying("Idle") and s:GetFrame() == 1 then
			npc.Velocity = npc.Velocity + Vector(0, 3):Rotated(rng:RandomInt(360))
		end
		local entitynpc = npc:ToNPC()
		local target = npc:GetPlayerTarget()
		local dist = (npc.Position - target.Position):Length()
		if (dist < 180 or (npc.HitPoints < d.lasthp)) and d.statetime > 60 then
			d.firstrev = true
			s:Play("RevIntro")
		end
		if s:IsPlaying("RevIntro") and s:GetFrame() == 1 then
			npc:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR,1,0,false,.7)
		end
		if s:IsFinished("RevIntro") then
			--s:Play("Rev")
			d.state = 'roll'
			d.statetime = 0
		end
		npc.Velocity = npc.Velocity * .95
	elseif d.state == 'roll' then
		if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
			s.FlipX = false
			mod:spritePlay(s, "Rev")
		elseif npc.Velocity.X > 0 then
			s.FlipX = false
			mod:spritePlay(s, "Rev2")
		else
			s.FlipX = true
			mod:spritePlay(s, "Rev2")
		end
		if d.statetime > 90 and rng:RandomFloat() < .03 then
			s:Play("RevOutro")
			d.state = 'idle'
			d.statetime = 0
        else
            local pathArgs = {
                Speed = 18,
                Accel = 0.05
            }
			if not mod:CatheryPathFinding(npc, npc:GetPlayerTarget().Position, pathArgs) then
				if (mod:CatheryPathFinding(npc, d.wandertarget, pathArgs) or 0) < 20 then
					d.wandertarget = Isaac.GetFreeNearPosition(npc.Position, 160)
				end
			end
		end
	end

	if d.state == 'flush' then
		npc:Kill()
	end

	if npc:IsDead() and not d.killed then
		d.killed = true
		for i=1, --[[math.random(2,3)]] 2 do
			Isaac.Spawn(mod.FF.SpicyDip.ID, mod.FF.SpicyDip.Var, 0, npc.Position, RandomVector()*7, npc)
		end
	end

	d.statetime = d.statetime + 1
end

function mod:berryHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_POOP, damageFlags) then
        return false
    end
end

function mod:spicyDipAI(npc)
	local d = npc:GetData()
	local s = npc:GetSprite()
	local rng = npc:GetDropRNG()

	if not d.init then
		d.init = true
		d.dir = rng:RandomInt(360)
		--npc:AddConfusion(EntityRef(npc:GetPlayerTarget()), 80 + rng:RandomInt(20), false)
		d.confused = 80 + rng:RandomInt(20)
		d.state = 'confused'
		if d.extraspicy then
			npc.SplatColor = mod.ColorFireJuicy
		end
		d.statetime = 0
	else
		npc.StateFrame = npc.StateFrame + 1
		if d.extraspicy then
			npc.StateFrame = npc.StateFrame + 1
		end
	end

	if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.6,0.6)
		if d.extraspicy then
			blood.Color = Color(0,0,0,1,0.8,0.2,0)
		end
		blood:Update()
	end

	
	if d.extraspicy and npc.FrameCount % 5 == 0 then
		local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position + Vector(0,-5), Vector(mod:RandomInt(-3,3,rng), -6), npc):ToEffect()
		smoke.Color = Color(0.8,0.8,0.8,0.6)
		smoke.SpriteScale = Vector(0.5,0.5)
		smoke.RenderZOffset = 300
		smoke:Update()
	end


	if npc.HitPoints < (d.lasthp or npc.MaxHitPoints) then
		d.lasthp = npc.HitPoints
		if not sfx:IsPlaying(SoundEffect.SOUND_SHAKEY_KID_ROAR) and rng:RandomFloat() < .33 then
			sfx:Play(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1.3)
		end
	end

	if d.init and d.confused > -1 then
		if d.state ~= 'confused' then
			d.state = 'confused'
			d.statetime = 0
		end
	end

	if d.state == 'confused' then
		s:Play("Idle")
		if d.confused < 0 then
			d.state = 'rollstart'
			d.statetime = 0
			--sfx:Play(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1.3)
		else
			if not mod:isConfuse(npc) then
				d.confused = d.confused - 1
			end
			d.dir = d.dir + (rng:RandomFloat() * 14)
			local moveVel = npc.Velocity + Vector(0, .2):Rotated(d.dir)
			npc.Velocity = mod:runIfFear(npc, moveVel, 2, false)
			if d.extraspicy then
				npc.Velocity = npc.Velocity * .98
			else
				npc.Velocity = npc.Velocity * .95
			end
		end
	elseif d.state == 'rollstart' then
		if s:IsFinished("RollStart") then
			d.state = "roll"
			npc.StateFrame = 0
		elseif s:IsEventTriggered("Roar") then
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1.3)
		elseif s:IsEventTriggered("Roll") then
			d.rolling = true
			d.rollstat = 0
		else
			mod:spritePlay(s, "RollStart")
		end
	elseif d.state == "roll" then
		mod:spritePlay(s, "Roll")
		if npc.StateFrame > 120 or mod:isConfuse(npc) then
			d.state = "rollstop"
		end
	elseif d.state == "rollstop" then
		if s:IsFinished("RollEnd") then
			d.state = "confused"
			d.confused = 40 + rng:RandomInt(20)
			d.slowing = false
		elseif s:IsEventTriggered("Slow") then
			d.rolling = false
			d.slowing = true
		else
			mod:spritePlay(s, "RollEnd")
		end

		if d.slowing then
			npc.Velocity = npc.Velocity * 0.95
		end

	--Legacy
	elseif d.state == 'slide' then
		if not s:IsPlaying("Move") then
			s:Play("Move")
		end
		if s:GetFrame() >= 5 and s:GetFrame() <= 20 then
			--if not api.FindGridPath(npc, npc:GetPlayerTarget(), 20, 0.05, true, 100, false) then
			--	npc:AddConfusion(EntityRef(npc:GetPlayerTarget()), 80 + rng:RandomInt(20), false)
			--end
			local entitynpc = npc:ToNPC()
			local target = npc:GetPlayerTarget()
			local diff = target.Position - npc.Position
			npc.Velocity = mod:Lerp(npc.Velocity, diff:Normalized() * 20, 0.05)
		else
			npc.Velocity = npc.Velocity * .95
		end
	end

	if d.state == 'flush' then
		if not s:IsPlaying("Flush") then
			s:Play("Flush")
		end
		if s:IsFinished("Flush") then
			npc:Kill()
		end
	end

	if d.rolling then
		d.rollstat = d.rollstat or 0
		d.rollstat = d.rollstat + 1
		local rolltime = d.rollstat % 25
		if rolltime >= 5 and rolltime <= 20 then
		local entitynpc = npc:ToNPC()
			local target = npc:GetPlayerTarget()
			local diff = mod:runIfFear(npc, target.Position - npc.Position)
			local lerpval = 0.05
			if d.extraspicy then
				lerpval = 0.075
			end
			npc.Velocity = mod:Lerp(npc.Velocity, diff:Normalized() * 18, lerpval)
		else
			npc.Velocity = npc.Velocity * .97
		end
	end


	if npc.Velocity.X < 0 then
		s.FlipX = true
	else
		s.FlipX = false
	end

	d.statetime = d.statetime + 1

	if npc:IsDead() and d.extraspicy then
		game:BombExplosionEffects(npc.Position, 10, 0, Color.Default, npc, 0.65, false, true)
		local fire = Isaac.Spawn(33,10,0,npc.Position,Vector.Zero,npc)
		fire.HitPoints = fire.HitPoints * 0.66
	end
end

function mod:spicyDipHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_POOP, damageFlags) then
        return false
    end
end