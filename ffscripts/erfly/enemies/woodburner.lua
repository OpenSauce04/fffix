local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:woodburnerAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder
	local sprite = npc:GetSprite()

	if not d.init then
		d.state = "idle"
		mod:spriteOverlayPlay(sprite, "Head")
		d.init = true
		d.gopos = RandomVector()*40
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.spinning then
		sprite.FlipX = true
		if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.3, 0, true, 1.5)
		end
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-12):Rotated(-25 + math.random(50))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.04)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) and targetpos:Distance(npc.Position) < 150 then
			local targetvel = (targetpos - npc.Position):Resized(12):Rotated(-25 + math.random(50))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.04)
		else
			 mod:CatheryPathFinding(npc, d.gopos, {
                Speed = 12,
                Accel = 0.04,
                GiveUp = true
             })
		end

		if npc.StateFrame % 30 == 0 then
			d.gopos = mod:FindRandomValidPathPosition(npc, 2)
		end

		if npc.StateFrame % 10 == 0 then
			local vec = RandomVector()*5
            for i = 1, 3 do
                local angle = i * 120
                local vel = vec:Rotated(angle)
				local fire = Isaac.Spawn(1000,7005, 10, npc.Position, vel, npc)
				fire.Parent = npc
				fire:GetData().initVel = vel
				fire:GetData().parentcounter = 1
			end
		end

		--Old code that made them leave fires
		--[[if npc.StateFrame % 15 == 0 then
			local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
			fire:GetData().timer = 50
			fire.Parent = npc
			fire:Update()
		end]]
	else
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end
	end

	if d.state == "idle" then
		mod:spriteOverlayPlay(sprite, "Head")

		path:EvadeTarget(npc.Position + (d.gopos-npc.Position):Resized(-10))
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-7):Rotated(-25 + math.random(50))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.07)
		elseif game:GetRoom():CheckLine(npc.Position,d.gopos,0,1,false,false) then
			local targetvel = (d.gopos - npc.Position):Resized(7):Rotated(-25 + math.random(50))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.07)
		else
			if npc.FrameCount % 3 == 1 then
				mod:CatheryPathFinding(npc, d.gopos, {
                    Speed = 7,
                    Accel = 0.14,
                    GiveUp = true
                })
			end
		end

		if npc.StateFrame % 20 == 0 then
			d.gopos = mod:FindRandomValidPathPosition(npc, 3)
		end

		if npc.StateFrame > 30 and r:RandomInt(30) == 0 and not mod:isConfuse(npc) then
			d.state = "spinstart"
		end

	elseif d.state == "spinstart" then
		if not d.spinning then
			npc.Velocity = npc.Velocity * 0.8
		end
		if sprite:IsOverlayFinished("SpinStart") then
			d.state = "spinloop"
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 13 then
			npc:PlaySound(mod.Sounds.MonsterYellFlash,1,2,false,math.random(110,120)/100)
			d.spinning = true
			d.gopos = mod:FindRandomValidPathPosition(npc, 2)
		else
			mod:spriteOverlayPlay(sprite, "SpinStart")
		end

	elseif d.state == "spinloop" then
		mod:spriteOverlayPlay(sprite, "SpinLoop")
		if npc.StateFrame > 40 or (npc.StateFrame > 20 and r:RandomInt(40) == 0) then
			d.state = "spinstop"
		end

	elseif d.state == "spinstop" then
		if not d.spinning then
			npc.Velocity = npc.Velocity * 0.8
		end
		if sprite:IsOverlayFinished("SpinStop") then
			d.state = "idle"
			d.gopos = mod:FindRandomValidPathPosition(npc, 3)
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 9 then
			sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
			d.spinning = false
		else
			mod:spriteOverlayPlay(sprite, "SpinStop")
		end
	end

	if npc:IsDead() then
		sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
	end

end

function mod:woodburnerHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        return false
    end
end

function mod:woodburnerEasyModeAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local path = npc.Pathfinder
	local sprite = npc:GetSprite()

	if not d.init then
		d.state = "idle"
		mod:spriteOverlayPlay(sprite, "Head2")
		d.init = true
		d.gopos = RandomVector()*40
		if not path:HasPathToPos(targetpos) then
			npc:Remove()
			d.removed = true
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if d.state == "idle" then
		mod:spriteOverlayPlay(sprite, "Head2")

		path:EvadeTarget(npc.Position + (d.gopos-npc.Position):Resized(-10))
		if game:GetRoom():CheckLine(npc.Position,d.gopos,0,1,false,false) then
			local targetvel = (d.gopos - npc.Position):Resized(7):Rotated(-25 + math.random(50))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.07)
		else
			if npc.FrameCount % 3 == 1 then
				mod:CatheryPathFinding(npc, d.gopos, {
                    Speed = 7,
                    Accel = 0.07,
                    GiveUp = true
                })
			end
		end

		if npc.StateFrame % 20 == 0 then
			d.gopos = mod:FindRandomValidPathPosition(npc, 3)
		end
	end

	if npc:IsDead() and not d.removed then
		Isaac.Spawn(1000, 104, 0, npc.Position, nilvector, npc)
		npc:PlaySound(SoundEffect.SOUND_HAPPY_RAINBOW,1,0,false,1)
	end
end

function mod:woodburnerEasyColl(npc1, npc2)
	local d = npc1:GetData()
	if not d.charmed then
		if (npc2.Type == 1 or (npc2.Type == mod.FF.WoodburnerEasy.ID and npc2.Variant == mod.FF.WoodburnerEasy.Var and npc2.SubType == 1) or (npc2.Type == mod.FF.GhostseEasy.ID and npc2.Variant == mod.FF.GhostseEasy.Var and npc2.SubType == 1)) then
			npc1:PlaySound(SoundEffect.SOUND_BROWNIE_LAUGH,1,0,false,math.random(10,16)/10)
			npc1:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
			npc1.SubType = 1
			d.charmed = true
		end
	end
end