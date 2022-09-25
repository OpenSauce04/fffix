local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:geyserAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		npc.TargetPosition = npc.Position
		d.smoke1, d.smoke2, d.smoke3 = math.random(25,35), math.random(40,50), math.random(35, 45)
		d.state = "idle"
		d.init = true
		npc.SplatColor = FiendFolio.ColorWaterPeople
		npc.StateFrame = 20
		npc.PositionOffset = Vector(0,10)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.Position = npc.TargetPosition
	npc.Velocity = nilvector

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if sprite:IsEventTriggered("BreatheIn") then
			--npc:PlaySound(SoundEffect.SOUND_LOW_INHALE,0.1,0,false,1)
		elseif sprite:IsEventTriggered("BreatheOut") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_CARD,0.1,0,false,1.4)
			d.smokin = 0
			d.smoke1, d.smoke2, d.smoke3 = math.random(25,35), math.random(40,50), math.random(35, 45)
		end
		if npc.StateFrame > 60 and r:RandomInt(20) == 1 then
			d.state = "attack"
		end
	elseif d.state == "attack" then
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			npc.StateFrame = -200
			d.gassing = nil
		elseif sprite:IsEventTriggered("Sound") then
			d.smokin = nil
		elseif sprite:IsEventTriggered("Shoot") then
			--npc:PlaySound(mod.Sounds.NimbusShoot,1,0,false,0.8)
			npc:PlaySound(mod.Sounds.CisternAttack,1.3,0,false,0.6)
			for i = 90, 360, 90 do
				local vec = Vector(1, 0):Rotated(i)
				mod.ShootBubble(npc, mod.FF.BubbleWateryMed.Sub, npc.Position + vec:Resized(5),vec)
				vec = vec:Rotated(45)
				mod.ShootBubble(npc, mod.FF.BubbleSmall.Sub, npc.Position + vec:Resized(5),vec)
			end
			d.gassing = 0
		else
			mod:spritePlay(sprite, "Attack")
		end

		if d.gassing then
			for i = 45, 360, 45 do
				local vec = Vector(math.random(5, 30)/10, 0):Rotated(-10 + math.random(20)):Rotated(i)
				local vecExtra = Vector(15, 0)
				if i == 90 or i == 270 then
					vecExtra = nilvector
				elseif i == 180 or i == 360 then
					vecExtra = Vector(30, 0)
				end
				if vec.X < 0 then
					vecExtra = vecExtra * -1
				end
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + vec:Resized(15) + vecExtra + npc.PositionOffset, vec, npc)
				smoke.Color = Color(1,1,1,(math.random() * 0.3),0.5,0.5,0.5)
				smoke.SpriteOffset = Vector(0, -20)
				smoke.DepthOffset = 50
				smoke:Update()
			end
			if d.gassing > 10 then
				d.gassing = nil
			end
		end
	end

	if d.smokin then
		d.smokin = d.smokin + 1
		if d.smokin > 5 and d.smokin < d.smoke1 then
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + (Vector(30, -45) * npc.SpriteScale.X) + npc.PositionOffset, Vector(0,-3), npc)
			smoke.DepthOffset = 100
			smoke.SpriteScale = npc.SpriteScale
			local alpha = math.min(0.3, (d.smokin - 5)/ 50)
			smoke.Color = Color(1,1,1,alpha,0.5,0.5,0.5)
			smoke:Update()
		end
		if d.smokin > 10 and d.smokin < d.smoke2 then
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + (Vector(-35, -45) * npc.SpriteScale.X) + npc.PositionOffset, Vector(0,-1), npc)
			smoke.DepthOffset = 100
			smoke.SpriteScale = smoke.SpriteScale * 0.6 * npc.SpriteScale.X
			local alpha = math.min(0.3, (d.smokin - 10)/ 50)
			smoke.Color = Color(1,1,1,alpha,0.5,0.5,0.5)
			smoke:Update()
		end
		if d.smokin > 13 and d.smokin < d.smoke3 then
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + (Vector(17, -54) * npc.SpriteScale.X) + npc.PositionOffset, Vector(0,-1), npc)
			smoke.DepthOffset = 100
			smoke.SpriteScale = smoke.SpriteScale * 0.3 * npc.SpriteScale.X
			local alpha = math.min(0.3, (d.smokin - 13)/ 50)
			smoke.Color = Color(1,1,1,alpha,0.5,0.5,0.5)
			smoke:Update()
		end
		if d.smokin > 50 then
			d.smokin = nil
		end
	end

	if npc:IsDead() then
		for i = 1, 10 do
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + Vector(0,-25 - math.random(30)/100):Rotated(-70 + math.random(140)) + npc.PositionOffset, Vector(0,0 - math.random(30)/100), npc)
			smoke.Color = Color(1,1,1,(math.random() * 0.3),0.5,0.5,0.5)
			smoke:Update()
		end
	end
end