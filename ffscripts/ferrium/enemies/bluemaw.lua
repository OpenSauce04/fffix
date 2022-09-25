local mod = FiendFolio
local game = Game()

function mod:blueConjoinedMawAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	local head1Pos = npc.Position-Vector(10,0)
	local head2Pos = npc.Position+Vector(10,0)
	
	
	if not data.init then
		data.state1 = "Idle"
		data.state2 = "Idle"
		data.head2Count = 0
		data.init = true
		npc.I2 = 15
		
		--[[for i=1,2 do
			local eternalfriend = Isaac.Spawn(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
			eternalfriend.Parent = npc
			eternalfriend:GetData().rotval = 50 * i
			eternalfriend:Update()
		end]]
		
		for i=1,2 do
			local test = Isaac.Spawn(12, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
			mod:makeEnemyEternal(test, npc, 50*i, 100)
		end
	else
		--npc.I1 = npc.I1+1
		--npc.I2 = npc.I2+1
	end
	
	if mod:isScare(npc) then
		npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(-2), 0.2)
	else
		npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(1), 0.2)
	end
	
	if data.state2 == "Idle" then
		if npc.FrameCount % 35 == 0 then
			if data.head2Count > 0 then
				data.head2Count = data.head2Count-1
			end
		end
		
		if npc.I2 > 25 and not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
			data.state2 = "Firing"
			data.nextProj = false
		else
			mod:spriteOverlayPlay(sprite, "Idle2")
		end
	elseif data.state2 == "Firing" then
		if sprite:IsOverlayFinished("Fire2") then
			if data.head2Count < 11 then
				if not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
					sprite:PlayOverlay("Fire2", true)
				end
			else
				data.state2 = "Exhausted"
				npc.I2 = 0
			end
		elseif sprite:GetOverlayFrame() == 3 then
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, 0.7, 0, false, math.random(110,145)/100)
			data.head2Count = data.head2Count+1
			if data.nextProj == false then
				local params = ProjectileParams()
				params.Scale = 0.8
				npc:FireProjectiles(head2Pos, (target.Position-head2Pos):Resized(10), 0, params)
				data.nextProj = true
			else
				local params = ProjectileParams()
				params.Scale = 0.8
				local lookAhead = mod:intercept(npc, target, 9)
				npc:FireProjectiles(head2Pos, lookAhead:Resized(10), 0, ProjectileParams())
				data.nextProj = false
			end
		else
			mod:spriteOverlayPlay(sprite, "Fire2")
		end
	elseif data.state2 == "Exhausted" then
		if npc.I2 > 90 then
			data.state2 = "Idle"
			data.head2Count = 0
		else
			mod:spriteOverlayPlay(sprite, "Exhaust")
		end
	end
	
	if data.state1 == "Idle" then
		mod:spritePlay(sprite, "Idle1")
		if npc.I1 > 30 then
			if rand:RandomInt(50) == 1 or npc.I1 > 60 then
				data.state1 = "Charging"
				sprite:Play("ChargeStart")
				npc.I1 = 0
			end
		end
	elseif data.state1 == "Charging" then
		if sprite:IsFinished("ChargeStart") then
			sprite:Play("ChargeIdle")
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_LOW_INHALE, 0.8, 0, false, 1.1)
		end
		
		if npc.I1 > 60 and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
			data.state1 = "Fire"
		elseif npc.I1 > 60 then
			data.state1 = "Fire"
		end
	elseif data.state1 == "Fire" then
		if sprite:IsFinished("Fire1") then
			data.state1 = "Idle"
			npc.I1 = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR, 1, 0, false, 1.3)
			local proj = Isaac.Spawn(9, 0, 0, head1Pos, (target.Position-head1Pos):Resized(2), npc):ToProjectile()
			proj.Scale = 2
			proj.FallingSpeed = -0.5
			proj.FallingAccel = -0.05
			proj:GetData().projType = "blueMaw"
			proj:GetData().target = target
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.SMART
		else
			mod:spritePlay(sprite, "Fire1")
		end
	end
end

function mod.blueMawProj(v, d)
	if d.projType == "blueMaw" then
		v.FallingSpeed = 0
		v.FallingAccel = -0.01
		
		v.Velocity = mod:Lerp(v.Velocity, (d.target.Position-v.Position):Resized(2), 0.08)
	end
end