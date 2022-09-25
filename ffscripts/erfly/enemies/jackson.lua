local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Jackson
function mod:jacksonAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		if npc.Velocity.X > 0 then
			mod:spritePlay(sprite, "Walk")
		else
			mod:spritePlay(sprite, "Moonwalk")
		end

		if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(7)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 1, 900, true)
		end

		if npc.StateFrame > 100 then
			if math.random(3) == 1 then
				d.state = "spin"
				npc.StateFrame = 0
			else
				d.state = "kick"
				if targetpos.X < npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			end
		end
	elseif d.state == "kick" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Kick") then
			d.state = "idle"
			sprite.FlipX = false
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local offset = Vector(50, 0)
			if sprite.FlipX then
				offset = offset * -1
			end
			local explosion = Isaac.Spawn(1000, 7012, 0, npc.Position + offset, nilvector, npc)
			explosion.SpriteOffset = Vector(0, -30)
			explosion.SpriteScale = Vector(0.3, 0.3)
		else
			mod:spritePlay(sprite, "Kick")
		end
	elseif d.state == "spin" then
		if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.3, 0, true, 1.5)
		end
		mod:spritePlay(sprite, "Spin")
		mod:CatheryPathFinding(npc, targetpos, {
            Speed = 20,
            Accel = 0.03,
            GiveUp = true
        })
		if npc.FrameCount % 3 == 0 then
			local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, nilvector, npc):ToEffect()
			sparkle.RenderZOffset = -5
			sparkle.SpriteOffset = Vector(-10 + math.random(20), -30 + math.random(20))
			--sparkle.SpriteScale = Vector(0.3,0.3)
		end
		if npc.StateFrame > 200 then
			d.state = "spinend"
			sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
		end
	elseif d.state == "spinend" then
		npc.Velocity = nilvector
		if sprite:IsFinished("SpinEnd") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local explosion = Isaac.Spawn(1000, 7012, 0, npc.Position + Vector(0, 5), nilvector, npc)
			explosion.SpriteOffset = Vector(0, -30)
			explosion.SpriteScale = Vector(0.3, 0.3)
		else
			mod:spritePlay(sprite, "SpinEnd")
		end
	end

	if npc:IsDead() then
		sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
	end

end