local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:dribbleAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local path = npc.Pathfinder

	if not d.init then
		if mod.isBackdrop("Scarred Womb") then
			npc.SplatColor = mod.ColorNormal
		elseif mod.isBackdrop("Dross") then
			npc.SplatColor = mod.ColorPoopyPeople
		else
			npc.SplatColor = mod.ColorWaterPeople
		end
		d.jumps = 0
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.95
		if npc.StateFrame > 20 and r:RandomInt(10) == 0 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isConfuse(npc) then
			if d.jumps > 1 or mod:isScare(npc) then
				d.state = "charge"
			else
				d.state = "attack"
				if target.Position.X > npc.Position.X then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
			end
		elseif npc.StateFrame > 75 and (r:RandomInt(10) == 0 or mod:isScare(npc)) then
			d.state = "charge"
		end
	elseif d.state == "attack" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			d.jumps = d.jumps + 1
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.LandSoft,1,2,false,1)
			local vec = (target.Position - npc.Position):Resized(8.5)
			local params = ProjectileParams()
			if not mod.isBackdrop("Scarred Womb") then
				params.Variant = 4
			end
			params.FallingSpeedModifier = -10
			params.FallingAccelModifier = 0.3
			params.HeightModifier = 20
			if mod.isBackdrop("Dross") then
				params.Color = FiendFolio.ColorDrossWater
			end
			for i = -30, 30, 30 do
				npc:FireProjectiles(npc.Position, vec:Rotated(i), 0, params)
			end
		else
			mod:spritePlay(sprite, "Attack")
		end
	elseif d.state == "charge" then
		if not d.charging then
			npc.Velocity = npc.Velocity * 0.92
			if sprite:IsEventTriggered("CHAAARGE") then
				local targetpos = mod:randomConfuse(npc, target.Position)
				npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(16))
				npc:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR,1,0,false,1)
				d.charging = 1
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "Charge")
			end
		elseif d.charging == 1 then
			if sprite:IsFinished("Charge") then
				mod:spritePlay(sprite, "ChargeLoop")
				npc.StateFrame = 0
			end
			d.speed = d.speed or npc.Velocity:Length()
			if npc:CollidesWithGrid() then
				d.speed = d.speed * 0.8
			end
			npc.Velocity = npc.Velocity:Resized(d.speed)

			if npc.StateFrame > 50 then
				if d.moist then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
					d.moist = false
				end
				d.charging = 2
				npc.StateFrame = 0
			end
		elseif d.charging == 2 then
			npc.Velocity = npc.Velocity * 0.95
			if npc.StateFrame > 15 then
				d.charging = nil
				d.state = "idle"
				d.jumps = 0
				d.speed = nil
				npc.StateFrame = 0
			end
		end

		if d.charging then
			if npc.Velocity.X > 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
		else
			if target.Position.X > npc.Position.X then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
		end
	else
		d.state = "idle"
	end

	if npc:IsDead() then
	local vec = RandomVector()
		if npc.SpawnerType == mod.FF.Monsoon.ID and npc.SpawnerVariant == mod.FF.Monsoon.Var then
			local drip = Isaac.Spawn(mod.FF.Drop.ID, mod.FF.Drop.Var, 0, npc.Position + vec:Resized(10), nilvector, npc)
				--drip.MaxHitPoints = drip.MaxHitPoints / 2.2
				drip.HitPoints = drip.MaxHitPoints
				drip:Update()
		else
			for i = 180, 360, 180 do
				local drip = Isaac.Spawn(mod.FF.Drop.ID, mod.FF.Drop.Var, 0, npc.Position + vec:Resized(10):Rotated(i), nilvector, npc)
				--drip.MaxHitPoints = drip.MaxHitPoints / 2.2
				drip.HitPoints = drip.MaxHitPoints
				drip:Update()
			end
		end
	end
end