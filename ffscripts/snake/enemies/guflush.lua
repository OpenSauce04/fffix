local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

local guflushAnims = {"BubbleSmall","BubbleBig"}

function mod:GuflushUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local path = npc.Pathfinder
	local r = npc:GetDropRNG()
	local room = game:GetRoom()
	local target = npc:GetPlayerTarget()

	-- init
	if not d.Init then
		d.BubbleState = 1
		mod:spriteOverlayPlay(sprite, "MakeBubbleBig")
		npc.SplatColor = mod.ColorDankBlackReal
		d.RegenFast = false
		d.StateFrame = 60
		d.Init = true
	end

	-- states
	local speed = 1 -- modified by states

	d.BubbleDelay = 80
	if d.RegenFast then
		d.BubbleDelay = 50
	end
	d.StateFrame = d.StateFrame + 1

	-- state handling
	if d.BubbleState == 0 then -- bubbleless
		speed = 6 - (d.StateFrame / (d.BubbleDelay - 10))
		if not sprite:IsOverlayPlaying("Pop") then
			mod:spriteOverlayPlay(sprite, "Head")
		end

		local projInterval = 10
		if d.RegenFast then
			projInterval = 6
		end
		if d.StateFrame % projInterval == 0 and not mod:isScareOrConfuse(npc) then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			local rand = r:RandomFloat()
			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector() * (rand * 3), npc):ToProjectile();
				local projdata = projectile:GetData();
				projectile.FallingSpeed = -(40 - (d.StateFrame / 4)) + math.random(10);
				projectile.FallingAccel = 2
				projectile.Velocity = projectile.Velocity * (math.random(8, 15)/14)
				projectile.Color = mod.ColorDankBlackReal
				projectile.Scale = 0.6
				--projdata.creeptype = "black"
		end

		if d.StateFrame > d.BubbleDelay and not mod:isScareOrConfuse(npc) then
			d.StateFrame = 0
			d.BubbleState = 1
			mod:spriteOverlayPlay(sprite, "MakeBubbleSmall")
			npc:PlaySound(mod.Sounds.BaloonShort, 0.3, 0, false, 2.5)
		end

	elseif d.BubbleState == 1 or d.BubbleState == 2 then -- bubble
		speed = d.BubbleState == 1 and 3 or 1.5
		
		if not sprite:IsOverlayPlaying("Make" .. guflushAnims[d.BubbleState]) then
			mod:spriteOverlayPlay(sprite, "Head" .. guflushAnims[d.BubbleState])
		end

		if d.StateFrame > d.BubbleDelay and not mod:isScareOrConfuse(npc) then
			if d.BubbleState == 1 then
				d.StateFrame = 0
				d.BubbleState = 2
				d.RegenFast = false
				mod:spriteOverlayPlay(sprite, "MakeBubbleBig")
				npc:PlaySound(mod.Sounds.BaloonShort, 0.3, 0, false, 1.5)
			elseif d.StateFrame > d.BubbleDelay then
				if not room:CheckLine(npc.Position,target.Position,3,1,false,false) then
					d.StateFrame = d.BubbleDelay
				else
					d.StateFrame = 0
					d.BubbleState = -1
					mod:spriteOverlayPlay(sprite, "Chomp")
				end
			end
		end

  else -- chomp big bubble
 		speed = 1.5
 		if sprite:IsOverlayFinished("Chomp") then
 			d.StateFrame = 0
 			d.BubbleState = 0
			d.RegenFast = true
 		elseif sprite:GetOverlayFrame() == 33 then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL,1,2,false,math.random(9,11)/10)
			mod:GuflushProjectileSplatter(npc, 42, 12)
		end
	end
	-- on pop bubble
	if (sprite:GetOverlayFrame() == 0 and sprite:IsOverlayPlaying("Pop")) then
		npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL,1,2,false,math.random(9,11)/10)
		mod:GuflushProjectileSplatter(npc, 42, 6)
	end

	-- chase
	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	local targetpos = mod:confusePos(npc, target.Position)

	if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
		local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(speed))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, math.floor(speed) / 7, 900, true)
	end
end

function mod:GuflushHurt(npc, damage, flag, source, countdown)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	
	if d.BubbleState == 2 or d.BubbleState == -1 then
		if sprite:IsOverlayPlaying("HeadBubbleBig") or (sprite:IsOverlayPlaying("Chomp") and sprite:GetOverlayFrame() < 33) then
			d.BubbleState = 0
			d.StateFrame = 0
			mod:spriteOverlayPlay(sprite, "Pop")
			
			npc.HitPoints = npc.HitPoints + damage * 0.4
		end
	end
end

function mod:GuflushProjectileSplatter(npc, fallingSpeed, minVelocity)
	local r = npc:GetDropRNG()
	for i = 50, 360, 50 do
		local rand = r:RandomFloat()
		local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,1.5):Rotated(i-40+rand*80), npc):ToProjectile()
		local projdata = projectile:GetData()
		projectile.FallingSpeed = -fallingSpeed + math.random(10)
		projectile.FallingAccel = 2
		projectile.Velocity = projectile.Velocity * (math.random(minVelocity, minVelocity + 9)/10)
		projectile.Scale = 0.6
		projectile.Color = mod.ColorDankBlackReal
		projdata.creeptype = "black"
	end
end