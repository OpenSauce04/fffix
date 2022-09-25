local mod = FiendFolio

function mod:frownyAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	local room = Game():GetRoom()

	if not data.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		if data.spankyShot then
			data.state = "Idle"
		else
			data.state = "Appear"
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	npc.Velocity = npc.Velocity*0.9

	--[[mod.scheduleForUpdate(function()
		for _, laser in pairs(Isaac.FindByType(7, -1, -1, false, false)) do
			laser = laser:ToLaser()
			local laserVec = laser:GetEndPoint() - (laser.Position + laser.PositionOffset)
			if (laser.Position + laserVec:Normalized()):Distance(npc.Position) < laser.Position:Distance(npc.Position) and laser.Parent == then
				local beingHit
				if math.abs(math.abs(laser.Position.X) - math.abs(npc.Position.X)) < 30 and math.abs(laserVec.Y) > math.abs(laserVec.X) then
					beingHit = true
				elseif math.abs(math.abs(laser.Position.Y) - math.abs(npc.Position.Y)) < 30 and math.abs(laserVec.X) > math.abs(laserVec.Y)then
					beingHit = true
				end
				if beingHit then
					npc.Velocity = npc.Velocity+laserVec:Resized(2)
				end
			end
		end
	end, 1, ModCallbacks.MC_POST_UPDATE)]]

	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")

		if npc.StateFrame > 20 and rand:RandomInt(20) == 1 and npc.Velocity:Length() < 1.5 and target.Position:Distance(npc.Position) < 150 and room:CheckLine(target.Position, npc.Position, 3, 1, false, false) then
			data.state = "Attack"
		elseif room:IsClear() then
			data.state = "Die"
		end
	elseif data.state == "Attack" then
		if room:IsClear() then
			data.state = "Die"
		elseif sprite:IsFinished("Attack") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.HeightModifier = 15
			params.Scale = 0.5
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, 1, 0, false, 1)
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(7), 0, params)
		else
			mod:spritePlay(sprite, "Attack")
		end
	elseif data.state == "Die" then
		if sprite:IsFinished("Die") then
			npc:Kill()
		else
			mod:spritePlay(sprite, "Die")
		end
	elseif data.state == "Appear" then
		if sprite:IsFinished("AppearAnim") then
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Yell") then
			npc:PlaySound(SoundEffect.SOUND_SPEWER, 0.8, 0, false, 1.1)
		else
			mod:spritePlay(sprite, "AppearAnim")
		end
	end
end

function mod:frownyHurt(npc, damage, flag, source)
	return false
end