local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:shellmetAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rng = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Idle"
		data.movement = 0
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if npc.Velocity.X > 0.15 then
		npc.FlipX = true
	else
		npc.FlipX = false
	end
	
	if data.state == "Idle" then
		if npc.Velocity:Length() > 0.5 then
			mod:spritePlay(sprite, "Walk")
		else
			mod:spritePlay(sprite, "Idle")
		end
		
		if data.movement == 0 then
			if npc.Position:Distance(targetpos) < 80 then
				data.targetPos = mod:FindClosestValidPosition(npc, target, 80, 100, 1)
			else
				data.targetPos = mod:FindRandomValidPathPosition(npc, 3, 80, 100)
			end
			data.movement = 1
			data.movementTimer = 20
			mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		elseif data.movement == 1 then
			if data.movementTimer > 0 then
				data.movementTimer = data.movementTimer-1
			end
		
			if npc.Position:Distance(data.targetPos) < 10 or data.movementTimer <= 0 or npc.Position:Distance(target.Position) < 40 or not data.targetPos then
				data.movement = 0
			else
				if mod:isScare(npc) then
					npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-data.targetPos):Resized(3), 0.3)
				elseif room:CheckLine(npc.Position, data.targetPos, 0) then
					npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position):Resized(1.8), 0.3)
				else
					npc.Pathfinder:FindGridPath(targetpos, 0.25, 999, true)
				end
			end
		end
		
		if sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_FETUS_LAND, 0.23, 0, false, math.random(190,210)/100)
		end
		
		if not mod:isScare(npc) then
			if npc.StateFrame > 40 and rng:RandomInt(50) == 0 then
				data.state = "JumpIn"
				--npc.Velocity = (targetpos-npc.Position):Resized(4)
				npc.StateFrame = 0
				--data.targetDir = (targetpos-npc.Position)
				mod:spritePlay(sprite, "SpinStart")
			elseif npc.StateFrame > 80 then
				data.state = "JumpIn"
				--npc.Velocity = (targetpos-npc.Position):Resized(4)
				npc.StateFrame = 0
				--data.targetDir = (targetpos-npc.Position)
				mod:spritePlay(sprite, "SpinStart")
			end
		end
	elseif data.state == "Spinnin" then
		if npc.Position:Distance(target.Position) < 100 then
			local targAngle = (targetpos-npc.Position)
			local diff = mod:GetAngleDifference(targAngle, npc.Velocity)
			if diff < 180 then
				npc.Velocity = npc.Velocity:Rotated(2)
			elseif diff > 180 then
				npc.Velocity = npc.Velocity:Rotated(-2)
			end
		end
		if npc.Velocity:Length() < data.spinVel then
			npc.Velocity = npc.Velocity:Resized(data.spinVel)
		elseif npc.Velocity:Length() > 14 then
			npc.Velocity = npc.Velocity:Resized(14)
		end
		if npc.StateFrame < 110 then
			if data.spinVel < 10 then
				data.spinVel = data.spinVel+0.5
			end
		else
			if data.spinVel > 5 then
				data.spinVel = data.spinVel-0.12
			else
				data.state = "JumpOut"
			end
		end
		
		if data.soundCooldown and data.soundCooldown > 0 then
			data.soundCooldown = data.soundCooldown-1
		elseif npc:CollidesWithGrid() then
			npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 0.45, 0, false, math.random(90,110)/100)
			data.soundCooldown = 3
			--[[local params = ProjectileParams()
			params.Variant = 9
			params.FallingSpeedModifier = -15
			params.FallingAccelModifier = 1.2
			for i=1,2 do
				npc:FireProjectiles(npc.Position, RandomVector()*(1+rng:RandomInt(5)), 0, params)
			end]]
		end
		mod:spritePlay(sprite, "Spin")
	elseif data.state == "JumpIn" then
		if sprite:IsFinished("SpinStart") then
			npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 1, 0, false, 1)
			data.state = "Spinnin"
			data.spinVel = 5
			npc.StateFrame = 0
			if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
				sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.25, 0, true, 1)
			end
			data.jumpStart = nil
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1.6)
		else
			--mod:spritePlay(sprite, "SpinStart")
		end
		
		if npc.StateFrame > 8 then
			if not data.jumpStart then
				npc.Velocity = (targetpos-npc.Position):Resized(4)
				data.jumpStart = true
			end
			if npc.Velocity:Length() < 4 then
				npc.Velocity = npc.Velocity:Resized(4)
			elseif npc.Velocity:Length() > 8 then
				npc.Velocity = npc.Velocity:Resized(8)
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
		end
		--npc.Velocity = mod:Lerp(npc.Velocity, data.targetDir:Resized(5), 0.3)
	elseif data.state == "JumpOut" then
		if sprite:IsFinished("SpinEnd") then
			data.state = "Idle"
			data.finished = nil
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Stop") then
			npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1.6)
			data.finished = true
			sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
		else
			mod:spritePlay(sprite, "SpinEnd")
		end
		
		if not data.finished then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.05)
			if npc:CollidesWithGrid() then
				npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 0.45, 0, false, math.random(90,110)/100)
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
		end
	end
	
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
	end
end

function mod:shellmetColl(npc, coll, low)
	if coll.Type == mod.FF.Shellmet.ID and coll.Variant == mod.FF.Shellmet.Var then
		npc.Velocity = npc.Velocity+(npc.Position-coll.Position):Resized(1)
		coll.Velocity = coll.Velocity+(coll.Position-npc.Position):Resized(1)
	end
end