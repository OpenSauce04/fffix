local mod = FiendFolio

function mod:stalagnaughtAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()
	local room = Game():GetRoom()

	if not data.init then
		npc.SplatColor = Color(0.15, 0, 0, 1, 25 / 255, 25 / 255, 25 / 255)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		if data.waited then
			npc.Visible = false
			if npc.SubType == 3 then
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
				npc.StateFrame = rand:RandomInt(20)-10
				data.waitTimer = rand:RandomInt(20)
				data.state = "Underground"
				data.extraWarning = true
			elseif npc.SubType == 2 then
				mod:spritePlay(sprite, "InCeiling")
				npc.Visible = true
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
				data.state = "Hanging Out"
				data.substate = "Falling"
				npc.StateFrame = 0
			end
		elseif npc.SubType == 0 then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.state = "Hanging Out"
			data.substate = "Hanging"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		elseif npc.SubType == 1 then
			data.state = "Idle"
			data.waitTimer = rand:RandomInt(15)
		elseif (npc.SubType == 2 or npc.SubType == 3) and not data.waited then
			local dist = -10
			if npc.SubType == 2 then
				dist = 60
			end
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, dist, false)
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	npc.Velocity = npc.Velocity*0.4

	if data.state == "Hanging Out" then
		if data.substate == "Hanging" then
			if npc.Position:Distance(target.Position) < 80 and npc.StateFrame > 25 then
				npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0, 0.6, 0, false, 1.23)
				data.substate = "Falling"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "InCeiling")
			end
			if mod.CanIComeOutYet() then
				if mod.farFromAllPlayers(npc.Position, 60) then
					data.substate = "Falling"
					npc.StateFrame = 0
				end
			end
		elseif data.substate == "Falling" then
			if sprite:IsFinished("Fall") then
				data.substate = "Fallen"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 0.35, 0, false, 1.25)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			elseif npc.StateFrame > 20 then
				mod:spritePlay(sprite, "Fall")
			end
		elseif data.substate == "Fallen" then
			if npc.StateFrame > 25 then
				data.substate = "FirstBurrow"
			else
				mod:spritePlay(sprite, "Fallen")
			end
		elseif data.substate == "FirstBurrow" then
			if sprite:IsFinished("Transition") then
				data.state = "Underground"
				data.waitTimer = rand:RandomInt(30)
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 0.6, 0, false, 1.2)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			else
				mod:spritePlay(sprite, "Transition")
				if npc.StateFrame % 4 == 0 then
					npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.15, 0, false, math.random(8,12)/10)
				end
			end
		end
	elseif data.state == "Idle" then
		if npc.StateFrame > 12+data.waitTimer then
			data.state = "Burrowing"
		else
			mod:spritePlay(sprite, "Idle")
		end
	elseif data.state == "Coming Up" then
		if data.extraWarning == true then
			npc.StateFrame = -15
			data.extraWarning = false
		end
		if npc.StateFrame > 20 then
			if sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.4, 0, false, 1.2)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			elseif sprite:IsFinished("Emerge") then
				data.state = "Idle"
				data.waitTimer = rand:RandomInt(23)
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "Emerge")
			end
		else
			if npc.Visible == false then
				npc.Visible = true
			end
			mod:spritePlay(sprite, "GroundShake")
			if npc.StateFrame % 4 == 0 then
				npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.3, 0, false, math.random(8,12)/10)
			end
		end
	elseif data.state == "Burrowing" then
		if sprite:IsFinished("Submerge") then
			data.state = "Underground"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 0.45, 0, false, 1.3)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif data.state == "Underground" then
		if npc.StateFrame > 20+data.waitTimer then
			if mod:isConfuse(npc) then
				npc.Position = mod:FindRandomFreePos(npc)
				data.state = "Coming Up"
				npc.StateFrame = 0
			elseif not mod:isScare(npc) then
				if room:GetGridCollisionAtPos(target.Position) == GridCollisionClass.COLLISION_NONE then
					npc.Position = target.Position
					local amIAlone = true
					for _,enemy in ipairs(Isaac.FindInRadius(target.Position, 40, EntityPartition.ENEMY)) do
						if enemy.Type == 114 and enemy.Variant == 18 then
							amIAlone = false
						end
					end
					if amIAlone == true then
						local dirtVision = false
						for i= -1, 1, 2 do
							if room:GetGridCollisionAtPos(target.Position+Vector(40*i, 0)) ~= GridCollisionClass.COLLISION_NONE then
								dirtVision = true
								break
							end
						end
						for i= -1, 1, 2 do
							if room:GetGridCollisionAtPos(target.Position+Vector(0, 40*i)) ~= GridCollisionClass.COLLISION_NONE then
								dirtVision = true
								break
							end
						end
						if dirtVision == true then
							npc.Position = room:GetGridPosition(room:GetGridIndex(npc.Position))
						end
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
						data.state = "Coming Up"
						npc.StateFrame = 0
					else
						npc.StateFrame = rand:RandomInt(20)
					end
				else
					npc.StateFrame = rand:RandomInt(20)
				end
			end
		end
	end
end