local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:fishaacAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "move"
		d.invcount = 0
		d.hitcount = d.hitcount or 0
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.invincible then
		if (d.wasbruised and d.invcount > 25) or d.invcount > 40 then
			npc.Color = mod.ColorNormal
			d.invincible = false
			d.wasbruised = nil
			d.invcount = 0
		else
			if d.invcount == 0 then
				mod:applyFakeDamageFlash(npc)
			elseif d.invcount % 4 == 2 then
				npc:SetColor(mod.ColorInvisible, 2, 0, false, false)
			end
			d.invcount = d.invcount + 1
			--if d.invcount < 2 then
			--	npc.Color = Color(30,1,1,1,0,0,0)
			--elseif d.invcount % 4 < 2 then
			--	npc.Color = mod.ColorNormal
			--else
			--	npc.Color = mod.ColorInvisible
			--end
		end
	end

	if d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.7
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 20 then
			if mod:isScareOrConfuse(npc) then
				d.state = "move"
			else
				d.state = "shooting"
			end
		end
	elseif d.state == "hurt" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Damage") then
			d.state = d.oldstate
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Damage")
		end
	elseif d.state == "move" then
		npc.Velocity = npc.Velocity * 0.93
		mod:spritePlay(sprite, "Moving")
		if sprite:IsEventTriggered("Move") then
			local vec = mod:runIfFear(npc, RandomVector():Resized(8), 8)
			npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.3)
		elseif sprite:IsEventTriggered("Shlap") then
			npc:PlaySound(mod.Sounds.SplashSmall,1,0,false,1.3)
		end
		if npc.StateFrame > 20 and math.random(20) == 1 and not mod:isScareOrConfuse(npc) then
			d.state = "shootready"
			mod:spritePlay(sprite, "Idle")
			npc.StateFrame = 0
		end
	elseif d.state == "shootready" then
		npc.Velocity = npc.Velocity * 0.7
		if sprite:IsFinished("Readying") then
			d.state = "idle"
			d.shots = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,1.5,0,false,1.5)
		elseif npc.StateFrame > 10 then
			mod:spritePlay(sprite, "Readying")
		end
	elseif d.state == "shooting" then
		npc.Velocity = npc.Velocity * 0.7
		if d.shooting then
			if npc.StateFrame > 8 then
				d.shooting = false
				if d.shots > 3 or mod:isScareOrConfuse(npc) then
					d.state = "enoughshooting"
				end
			elseif npc.StateFrame == 5 then
				sprite:SetFrame("Shoot" .. d.dir, 1)
			end

		else
			if not d.shooting then
				if math.abs(target.Position.Y - npc.Position.Y) > math.abs(target.Position.X - npc.Position.X) then
					if target.Position.Y > npc.Position.Y then
						d.dir = "Down"
						d.vec = 0
					else
						d.dir = "Up"
						d.vec = 180
					end
				else
					if target.Position.X > npc.Position.X then
						d.dir = "Right"
						d.vec = 270
					else
						d.dir = "Left"
						d.vec = 90
					end
				end
				d.shots = d.shots + 1
				npc.StateFrame = 0
				d.shooting = true

				sprite:SetFrame("Shoot" .. d.dir, 4)

				npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.7,0,false,1.3)
				local params = ProjectileParams()
				params.FallingAccelModifier = -0.1
				npc:FireProjectiles(npc.Position, Vector(0,7):Rotated(d.vec - 20 + math.random(40)), 0, params)
			end
		end
	elseif d.state == "enoughshooting" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("FinishedShooting") then
			d.state = "move"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "FinishedShooting")
		end
	end
end

function mod:fishaacHurt(npc, damage, flag, source)
    local d = npc:GetData()
    d.hitcount = d.hitcount or 0
    if not d.invincible then
		if npc.HitPoints <= 1 then
			npc:Kill()
		else
			npc:ToNPC():PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_5,1,0,false,math.random(13,16)/10)
			d.hurt = true
			d.invincible = true
			if d.state == "shooting" or d.state == "shootready" then
				d.shooting = false
				d.shots = 0
				d.oldstate = "idle"
			else
				d.oldstate = "move"
			end
			d.state = "hurt"
			d.hitcount = d.hitcount + 1
			npc.HitPoints = npc.HitPoints - 1
			d.wasbruised = d.FFBruiseInstances ~= nil and #d.FFBruiseInstances > 0
			return false
		end
    elseif d.invincible then
        return false
    end
end

function mod.fishaacDeathAnim(npc)
    local DeadFish = Isaac.Spawn(1000, 1730, 0, npc.Position, nilvector, npc):ToEffect()
    sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A,1,0,false,math.random(130,140)/100)
    if npc.Velocity.X < 0 then
        DeadFish:GetSprite().FlipX = true
    end
    DeadFish:Update()
end

function mod:fishDed(e)
	local sprite = e:GetSprite()
	local d = e:GetData()
	if not d.anim then
		if math.random(5) == 1 then
			d.anim = "DedFunny"
		else
			d.anim = "Ded"
		end
		if e.SubType == 1 then
			d.anim = "temp"
			sprite:Play("Death", true)
		end
	end
	if e.SubType == 1 then
		if d.anim == "dead" then
			mod:spritePlay(sprite, "Dead")
		else
			if sprite:IsFinished("Death") then
				d.anim = "dead"
			end
		end
	else
		mod:spritePlay(sprite, d.anim)
	end

	if e.FrameCount > 50 then
		local removal = (e.FrameCount - 50) / 100
		removal = math.min(0.3, removal)
		e.Color = Color(1 - removal, 1 - removal, 1- removal, 1, 0, 0, 0)
	end

	if e.FrameCount == 50 then
		local vec = Vector(10, -3)
		if sprite.FlipX then
			vec = Vector(-10, -3)
		end
		for i = 1, math.random(1,7) do
			Isaac.Spawn(1000, 33, 0, e.Position + vec, nilvector, e):ToEffect()
		end
		for i = 1, math.random(1,7) do
			Isaac.Spawn(1000, 21, 0, e.Position + vec, nilvector, e):ToEffect()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.fishDed, 1730)