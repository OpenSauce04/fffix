local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:nannyLongLegsAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local playerStepping
	d.playerStepTimer = d.playerStepTimer or 0
	d.playerStepTimer = d.playerStepTimer + 1
	for i = 1, game:GetNumPlayers() do
		local p = Isaac.GetPlayer(i - 1)
		local grident = game:GetRoom():GetGridEntityFromPos(p.Position)
		if grident and grident.Desc.Type == GridEntityType.GRID_SPIDERWEB then
			playerStepping = true
			d.playerStepTimer = 0
		end
	end

	if d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.75
		if not (sprite:IsPlaying("Blink") or sprite:IsPlaying("Angry Stop")) then
			mod:spritePlay(sprite, "Idle")
			if math.random(30) == 1 then
				mod:spritePlay(sprite, "Blink")
			end
		end
		if playerStepping then
			d.state = "pissed"
			mod:spritePlay(sprite, "Angry Start")
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.75
		if sprite:IsFinished("Shoot") then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,0,false,0.9)
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(8), 0, ProjectileParams())
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "pissed" then
		if not sprite:IsPlaying("Angry Start") then
				mod:CatheryPathFinding(npc, target.Position, {
				Speed = 10,
				Accel = 0.1,
				GiveUp = true
				})
			if npc.Velocity:Length() > 0.1 then
				mod:spritePlay(sprite, "Walk")
			else
				mod:spritePlay(sprite, "Idle Angry")
			end
			if (not playerStepping) and d.playerStepTimer > 15 then
				d.state = "cautious"
				npc.StateFrame = 0
			end
		end
	elseif d.state == "cautious" then
		npc.Velocity = npc.Velocity * 0.75
		if npc.StateFrame > 60 then
			d.state = "idle"
			mod:spritePlay(sprite, "Angry Stop")
		else
			mod:spritePlay(sprite, "Idle Angry")
		end
		if playerStepping then
			d.state = "pissed"
		end
	end
end

function mod:nannyLongLegsHurt(npc, damage, flag, source)
	local d = npc:GetData()
	if d.state == "idle" and npc:ToNPC().StateFrame > 10 then
		d.state = "shoot"
	end
end