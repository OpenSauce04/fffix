local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:peatAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if npc.StateFrame > 20 then
			local fun = math.random(6)
			if fun == 1 then
				d.state = "joomp"
				npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1,1,0,false,0.75)
			elseif fun > 1 and fun < 5 then
				d.state = "attackkmode"
			else
				npc.StateFrame = 0
			end
		end

	elseif d.state == "attackkmode" then
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if game:GetRoom():CheckLine(npc.Position,target.Position,0,1,false,false) then
			local targetvel = (target.Position - npc.Position):Resized(7)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(target.Position, 1, 900, true)
		end

		if npc.Velocity.Y < 0 then
			mod:spritePlay(sprite, "WalkUp")
		else
			mod:spritePlay(sprite, "Walk")
		end

		if npc.Position:Distance(target.Position) < 75 then
			d.state = "PUNCH"
			d.turning = true
		end

	elseif d.state == "PUNCH" then
		npc.Velocity = npc.Velocity * 0.1
		if d.turning then
			if target.Position.X < npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		end
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Punch") then
			d.turning = false
			for _,entity in ipairs(Isaac.GetRoomEntities()) do
				if entity.Position:Distance(npc.Position + (target.Position - npc.Position):Resized(15)) < 75 then
					if entity.Type == 1 then
						npc:PlaySound(mod.Sounds.EpicPunch,1,0,false,1)
						entity:TakeDamage(1, 0, EntityRef(npc), 0)
						entity.Velocity = entity.Velocity + (entity.Position - npc.Position):Resized(15)
					end
					if entity:IsActiveEnemy() and entity.Variant ~= 1003 then
						entity:TakeDamage(15, 0, EntityRef(npc), 0)
						entity.Velocity = entity.Velocity + (entity.Position - npc.Position):Resized(15)
					end
				end
			end
		else
			mod:spritePlay(sprite, "Attack")
		end

	elseif d.state == "joomp" then
		if sprite:IsFinished("Jump") then
			d.state = "joompland"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Position = target.Position
			npc.StateFrame = 0
			npc.Velocity = nilvector
		else
			mod:spritePlay(sprite, "Jump")
		end
	elseif d.state == "joompland" then
		npc.Velocity = npc.Velocity * 0.1
		if npc.StateFrame == 6 then
			npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1,1,0,false,1.25)
		end
		if npc.StateFrame > 5 then
			if sprite:IsFinished("Land") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:GetFrame() == 3 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				local explosion = Isaac.Spawn(1000, 7012, 0, npc.Position, nilvector, npc)
				explosion:Update()
			else
				mod:spritePlay(sprite, "Land")
			end
		end
	end
end
