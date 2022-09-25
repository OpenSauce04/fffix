local mod = FiendFolio

function mod:benignAI(npc)
	local sprite = npc:GetSprite()
	local enVel

	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end

	if sprite:IsPlaying("Idle") then
		enVel = mod:diagonalMove(npc, 2, 1)
		npc.Velocity = mod:Lerp(npc.Velocity, enVel, 0.1)
	elseif sprite:IsPlaying("Retaliate") then
		enVel = mod:diagonalMove(npc, 1.5, 1)
		npc.Velocity = mod:Lerp(npc.Velocity, enVel, 0.1)

		if sprite:IsEventTriggered("shoot") then
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,0,false,math.random(180,220)/100)
			local angle = math.random(360)
			for i=0,2 do
				--Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,8):Rotated(angle+180*i), npc)
				npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(angle+120*i), 0, ProjectileParams())
			end
			local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc):ToEffect()
			effect:FollowParent(npc)
			effect.DepthOffset = npc.Position.Y * 1.25
			effect.SpriteOffset = Vector(0,-13)
		end
	elseif sprite:IsFinished("Retaliate") then
		sprite:Play("Idle")
	end
end

function mod:benignHurt(npc, damage, flag, source)
	local sprite = npc:GetSprite()
	if sprite:IsPlaying("Idle") and not mod:isScareOrConfuse(npc) then
		sprite:Play("Retaliate")
	end
end