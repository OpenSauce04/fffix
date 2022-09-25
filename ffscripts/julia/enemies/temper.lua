local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--temper          tmeperm tmemtmm mm   mm m  m m  ghost that grows angry
function mod:temperAI(npc, sprite, npcdata)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local room = game:GetRoom()

	if npc.Velocity.X > 0 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	if npcdata.state == "init" then
		npc.SplatColor = FiendFolio.ColorGhostly
		npcdata.cooldown = 120
		npcdata.charge_cooldown = 1;
		npcdata.charge_duration = 15;
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npcdata.state = "idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
	elseif npcdata.state == "idle" then
		--local d = target.Position - npc.Position
		--mod:lustymove(npc, npcdata, target.Position, 0.1 + d:Length()/2000, 1 + d:Length()/200)
		if npc.FrameCount % 20 == 0 and npc.Velocity:Length() < 1 then
			npc.Velocity = Vector(math.random() - 0.5, math.random() - 0.5)
		elseif npc.Velocity:Length() > 0.5 then
			npc.Velocity = npc.Velocity * 0.9
		end

		mod:spritePlay(sprite, "Walk")

		--Detect if knife / player nearby
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			etype = entity.Type
			if (etype == 1 and entity.Velocity:Length() > 1) or etype == 8 then
				if entity.Position:Distance(npc.Position) < 60 and not mod:isScareOrConfuse(npc) then
					npcdata.state = "moveinit"
				end
			end
		end

	elseif npcdata.state == "moveinit" then
		if sprite:IsFinished("ChaseStart") then
			npcdata.state = "move"
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		elseif sprite:IsEventTriggered("Scream") then
			local pitch = math.random(11,15)/10
			npc:PlaySound(mod.Sounds.TemperAnger,1,2,false,pitch)
		else
			mod:spritePlay(sprite, "ChaseStart")
		end
	elseif npcdata.state == "move" then
		local d = target.Position - npc.Position
		mod:lustymove(npc, npcdata, mod:confusePos(npc, target.Position), 0.3 + d:Length()/200, 3 + d:Length()/20)
		if npcdata.cooldown > 13 then
			mod:spritePlay(sprite, "Chase")
			npcdata.cooldown = npcdata.cooldown - 1
		elseif not mod:isConfuse(npc) then
			if sprite:IsFinished("ChargeStart") then
				npcdata.state = "charge"
				npcdata.charge_duration = 20
				npcdata.cooldown = 1
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		end
		if mod:isScare(npc) then
			npcdata.state = "init"
		end
	elseif npcdata.state == "charge" then
		npcdata.cooldown = 120
		mod:spritePlay(sprite, "Charge")
		--npcdata.targetVelocity = npc.Velocity/1.5;

		if npcdata.charge_cooldown > 1 then
			npcdata.charge_cooldown = npcdata.charge_cooldown - 1
		elseif npcdata.charge_cooldown > 0 then
			npcdata.targetVel = (target.Position - npc.Position):Resized(13)
			local pitch = math.random(10,12)/10
			npc:PlaySound(mod.Sounds.TemperCharge,1,0,false,pitch)
			npcdata.charge_cooldown = npcdata.charge_cooldown - 1
		else
			if npcdata.charge_duration > 10 then
				npc.Velocity = npcdata.targetVel
				npcdata.charge_duration = npcdata.charge_duration - 1
			elseif npcdata.charge_duration > 0 then
				npc.Velocity = npc.Velocity * 0.9
				npcdata.charge_duration = npcdata.charge_duration - 1
			else
				npcdata.state = "move"
				npcdata.charge_duration = 20
				npcdata.charge_cooldown = 1
			end
		end
	elseif npcdata.state == "death" then
		npc.Velocity = nilvector
		if sprite:IsEventTriggered("Dead") then
			npc:Remove()
		end
	else npcdata.state = "init"
	end

	if room:IsClear() and not mod.FindDoorShutter() then
		if npcdata.state == "idle" then
			sprite:Play("Death", true)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Velocity = nilvector
			npcdata.state = "death"
		elseif npcdata.state == "move" or npcdata.state == "charge" then
			sprite:Play("DeathChase", true)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Velocity = nilvector
			npcdata.state = "death"
		end
	end
end

function mod:temperHurt(npc, damage)
	if npc:GetData().state == "idle" then
		npc:GetData().state = "moveinit"
	end
	return false
end
--mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.temperHurt, 707)