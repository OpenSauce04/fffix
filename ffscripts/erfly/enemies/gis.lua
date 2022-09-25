local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:gisAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorDankBlackReal
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
        local room = game:GetRoom()
		if npc.Velocity:Length() > 0.5 then
			mod:spritePlay(sprite, "Walk")
			if npc.Velocity.X > 0.3 then
				sprite.FlipX = false
			elseif npc.Velocity.X < 0.3 then
				sprite.FlipX = true
			end
		else
			mod:spritePlay(sprite, "Idle")
		end

		d.newhome = d.newhome or mod:GetNewPosAligned(npc.Position)
		if npc.Position:Distance(d.newhome) < 20 or npc.Velocity:Length() < 0.3 or (not room:CheckLine(d.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
			d.newhome = mod:GetNewPosAligned(npc.Position)
		end

		local targvel = (d.newhome - npc.Position):Resized(1.8)
		if mod:isScare(npc) then
			targvel = (target.Position - npc.Position):Resized(-2)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)

		if npc.StateFrame > 50 and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			local targrel = mod:GetPositionAligned(npc.Position, target.Position, 30)
			if targrel then
			d.targrel = targrel
				d.state = "attack"
				d.anim = "Shoot"
			end
		end

	elseif d.state == "attack" then
		npc.Velocity = npc.Velocity * 0.9
		if d.targrel == 1 then
			sprite.FlipX = true
		elseif d.targrel == 2 then
			d.anim = "Shoot02"
		elseif d.targrel == 3 then
			sprite.FlipX = false
		end
		if sprite:IsFinished(d.anim) then
			d.state = "idle"
			npc.StateFrame = 0
			d.newhome = nil
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = true
		elseif sprite:IsEventTriggered("StopShoot") then
			d.shooting = false
		else
			mod:spritePlay(sprite, d.anim)
		end
	end

	if d.shooting then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, -5):Rotated(d.targrel * 90), 0.2)
		local vec = Vector(0,10):Rotated(d.targrel * 90):Rotated(math.random(-15, 15))
		if npc.FrameCount % 2 == 1 then
			npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,0.9)
			local params = ProjectileParams()
			params.Color = mod.ColorDankBlackReal
			npc:FireProjectiles(npc.Position, vec, 0, params)
		end
		if mod.GetEntityCount(mod.FF.TarBubble.ID, mod.FF.TarBubble.Var) < 10 then
			if npc.FrameCount % 15 == 1 then
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, vec, npc):ToProjectile()
				local projdata = projectile:GetData();
				projectile.FallingSpeed = -10 + math.random(10)
				projectile.FallingAccel = 0.3
				projectile.Velocity = projectile.Velocity:Normalized() * math.random(5, 8)
				projectile.Scale = 2
				projectile.Color = mod.ColorDankBlackReal
				projdata.projType = "dank slime"
			end
		end
	end
end