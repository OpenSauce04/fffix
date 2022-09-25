local mod = FiendFolio
local game = Game()

function mod:gabberAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local player = target:ToPlayer()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 200)
		Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		data.spoodBeast = 0
		data.direction = "Down"
		data.state = "Appear"
		sprite:Play("IdleDown")
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if data.state == "Idle" then
		if npc.Velocity:Length() > 0 then
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					mod:spritePlay(sprite, "WalkDown")
				else
					mod:spritePlay(sprite, "WalkUp")
				end
			else
				if npc.Velocity.X > 0 then
					mod:spritePlay(sprite, "WalkRight")
				else
					mod:spritePlay(sprite, "WalkLeft")
				end
			end
		else
			mod:spritePlay(sprite, "IdleDown")
		end

		if sprite:IsEventTriggered("Step") then
			data.spoodBeast = 5
		elseif data.spoodBeast > 0 then
			data.spoodBeast = (data.spoodBeast/1.2)-0.1
		end

		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-target.Position):Resized(1+data.spoodBeast), 0.4)
		elseif npc.Position:Distance(data.goHere) < 20 or npc.StateFrame > 120 then
			data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 200)
			npc.StateFrame = 0
		elseif room:CheckLine(npc.Position, data.goHere, 0, 1, false, false) then
			npc.Velocity = mod:Lerp(npc.Velocity, (data.goHere-npc.Position):Resized(0.1+data.spoodBeast), 0.4)
		else
			npc.Pathfinder:FindGridPath(data.goHere, 0.1+(data.spoodBeast/8), 999, true)
		end

		if player and not mod:isConfuse(npc) then
			if Options.MouseControl == true then
				if Input.IsMouseBtnPressed(0) == true or not (player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0) then -- I'm dumb and forgot a not when testing so I guess there's the whole mouse controls options for no reason
					if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
						if (target.Position.X - npc.Position.X) > 0 then
							data.direction = "Right"
						else
							data.direction = "Left"
						end
					else
						if (target.Position.Y - npc.Position.Y) > 0 then
							data.direction = "Down"
						else
							data.direction = "Up"
						end
					end
					data.state = "GibberingStart"
				end
			else
				if not (player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0) then
					if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
						if (target.Position.X - npc.Position.X) > 0 then
							data.direction = "Right"
						else
							data.direction = "Left"
						end
					else
						if (target.Position.Y - npc.Position.Y) > 0 then
							data.direction = "Down"
						else
							data.direction = "Up"
						end
					end
					data.state = "GibberingStart"
				end
			end
		end
	elseif data.state == "GibberingStart" then
		if sprite:IsFinished("StartShoot" .. data.direction) then
			npc.StateFrame = 8
			data.state = "Gibbering"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 0.85)
		else
			mod:spritePlay(sprite, "StartShoot" .. data.direction)
		end

		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
	elseif data.state == "Gibbering" then
		if (npc.StateFrame-5) % 4 == 0 then
			npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, 0.5, 0, false, 0.9+(rand:RandomInt(20)/100))
		end
		if npc.StateFrame % 9 == 0 then
			local dir = Vector.Zero
			if data.direction == "Down" then
				dir = Vector(0, 10):Rotated(rand:RandomInt(80)-40)
			elseif data.direction == "Left" then
				dir = Vector(-10, 0):Rotated(rand:RandomInt(80)-40)
			elseif data.direction == "Up" then
				dir =Vector(0, -10):Rotated(rand:RandomInt(80)-40)
			elseif data.direction == "Right" then
				dir = Vector(10, 0):Rotated(rand:RandomInt(80)-40)
			end
			local proj = Isaac.Spawn(9, 0, 0, npc.Position+dir, dir, npc):ToProjectile()
			mod:makeCharmProj(npc, proj)
			local pData = proj:GetData()
			pData.gabberProj = true
			pData.ready = true
			pData.dir = dir
			pData.player = player
			pData.projV = dir
		end

		if Options.MouseControl == true then
			if not player or Input.IsMouseBtnPressed(0) == false and (player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0) then
				data.state = "GibberingEnd"
			else
				mod:spritePlay(sprite, "Shoot" .. data.direction .. "Loop")
			end
		else
			if not player or (player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0) then
				data.state = "GibberingEnd"
			else
				mod:spritePlay(sprite, "Shoot" .. data.direction .. "Loop")
			end
		end

		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
	elseif data.state == "GibberingEnd" then
		if sprite:IsFinished("Shoot" .. data.direction .. "End") then
			data.state = "Idle"
			data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 200)
		else
			mod:spritePlay(sprite, "Shoot" .. data.direction .. "End")
		end

		if Options.MouseControl == true then
			if player then
				if Input.IsMouseBtnPressed(0) == true or not (player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0) then
					data.state = "Gibbering"
					npc.StateFrame = 8
				end
			end
		else
			if player then
				if not (player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0) then
					data.state = "Gibbering"
					npc.StateFrame = 8
				end
			end
		end

		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
	elseif data.state == "Appear" then
		if sprite:IsEventTriggered("Roar") then
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0, 1.3, 0, false, 0.85)
		elseif sprite:IsEventTriggered("Click") then
			npc:PlaySound(SoundEffect.SOUND_SCYTHE_BREAK, 0.9, 0, false, 1.4)
		elseif sprite:IsFinished("Appear") then
			data.state = "Idle"
		else
			mod:spritePlay(sprite, "Appear")
		end

		npc.Velocity = npc.Velocity*0.7
	end
end

function mod.gabberProj(v, d)
	if d.gabberProj == true then
		if v.SpawnerEntity and v.SpawnerEntity:Exists() and not mod:isStatusCorpse(v.SpawnerEntity) and d.player and d.player:Exists() then
			d.player = v.SpawnerEntity:ToNPC():GetPlayerTarget():ToPlayer()
			if d.ready == true then
				d.projV = mod:Lerp(d.projV, Vector.Zero, 0.15)
				v.Velocity = d.projV+v.SpawnerEntity.Velocity*0.75
				v.FallingSpeed = -0.01
				v.FallingAccel = -0.01

				if Options.MouseControl == true then
					if not d.player or Input.IsMouseBtnPressed(0) == false or (d.player:GetShootingInput().X == 0 and d.player:GetShootingInput().Y == 0) then
						d.ready = false
						v.Velocity = mod:Lerp(v.Velocity, d.dir, 0.6)
					end
				else
					if not d.player or (d.player:GetShootingInput().X == 0 and d.player:GetShootingInput().Y == 0) then
						d.ready = false
						v.Velocity = mod:Lerp(v.Velocity, d.dir, 0.6)
					end
				end
			else
				if Options.MouseControl == true then
					if d.player and Input.IsMouseBtnPressed(0) == true or not (d.player:GetShootingInput().X == 0 and d.player:GetShootingInput().Y == 0) then
						v.Velocity = mod:Lerp(v.Velocity, Vector.Zero, 0.6)
						v.FallingSpeed = -0.01
						v.FallingAccel = -0.01
					else
						v.Velocity = mod:Lerp(v.Velocity, d.dir, 0.6)
						v.FallingSpeed = 0
					end
				else
					if d.player and not (d.player:GetShootingInput().X == 0 and d.player:GetShootingInput().Y == 0) then
						v.Velocity = mod:Lerp(v.Velocity, Vector.Zero, 0.6)
						v.FallingSpeed = -0.01
						v.FallingAccel = -0.01
					else
						v.Velocity = mod:Lerp(v.Velocity, d.dir, 0.6)
						v.FallingSpeed = 0
					end
				end
			end
		else
			v.Velocity = mod:Lerp(v.Velocity, d.dir, 0.6)
		end
	end
end