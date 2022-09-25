local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function LipomaMovement(npc, target, speed, sprite)
	speed = speed or 2
	local path = npc.Pathfinder
	local targetPos = target.Position
	if game:GetRoom():CheckLine(npc.Position,targetPos,0,1,false,false) then
		local targetvel = (targetPos - npc.Position):Resized(speed)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		if path:HasPathToPos(targetPos, false) then
			path:FindGridPath(targetPos, speed/10, 900, true)
		else
			npc.Velocity = npc.Velocity * 0.2
		end
	end
	if npc.Velocity.X < 0 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end
end

function mod:lipomaAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		if d.waited then
			d.state = "appear"
			npc.Visible = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			sprite:Play("Idle01")
			sprite:Play("Appear")
			mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
		elseif npc.SubType == 1 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 80)
		else
			d.state = "idle"
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	--[[d.Position = d.Position or npc.Position
	if d.Position then
		npc.Position = mod:Lerp(npc.Position, d.Position, 0.6)
		npc.Velocity = npc.Velocity * 0.1
	end]]

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle01")
		if npc.StateFrame > 40 and math.random(10) == 1 then
			d.state = "move"
			mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
		else
			LipomaMovement(npc, target, 2, sprite)
			if npc.HitPoints < npc.MaxHitPoints * 0.66 then
				if npc.Pathfinder:HasPathToPos(target.Position, true) or game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) then
					d.state = "death"
					mod:spritePlay(sprite, "Burst")
				end
			end
		end
	elseif d.state == "move" then
		npc.Velocity = npc.Velocity * 0.1
		if sprite:IsFinished("Submerge") then
			d.state = "appear"
			npc.Position = mod:FindRandomFreePosAirNoGrids(target.Position, 120, nil, true)
			mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
			--d.Position = npc.Position
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif d.state == "appear" then
		npc.Velocity = npc.Velocity * 0.1
		if sprite:IsFinished("Appear") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Appear")
		end
	elseif d.state == "death" then
		if not sprite:IsPlaying("Burst") then
			mod:spritePlay(sprite, "Idle02")
			d.shooting = true
		end
		if sprite:IsEventTriggered("Shoot") then
			d.shooting = true
			mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
			local effect = Isaac.Spawn(1000,16,4,npc.Position,Vector.Zero,npc)
			effect.Color = mod.ColorGurdyOrange
			effect.SpriteScale = effect.SpriteScale * 0.8
			effect.DepthOffset = npc.Position.Y * 1.25
		end
		if d.shooting then
			LipomaMovement(npc, target, 1, sprite)
			if npc.FrameCount % 3 == 1 then
				local targetpos = mod:randomConfuse(npc, target.Position)
				local shotspeed = ((targetpos - npc.Position)*0.04):Rotated(-10+math.random(20))
				
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, shotspeed, npc):ToProjectile()
				projectile.FallingSpeed = -40 + math.random(10);
				projectile.FallingAccel = 1.4 + math.random(2)/10;
				projectile:GetData().projType = "PusyCreep"
				projectile.Color = mod.ColorGurdyOrange
				projectile:Update()
				mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2, 0.5)
			end
		else
			npc.Velocity = npc.Velocity * 0.1
		end
	end
end