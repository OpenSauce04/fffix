local mod = FiendFolio
local game = Game()

--congression of souls
mod.congressionrandos = {2, 3, 52, 53, 56, 57, 102, 103, 106, 107, 152, 153, 156, 157}

function mod:congressionRandom()
    local roomheight = room:GetGridHeight()
    local randpos = (math.random((roomheight - 3)) + 2) * 50
    return randpos
end

function mod:congressionAI(npc, sprite, npcdata, subType) --why the hell does stopwatch make them stop moving instead of just slowing down
	npc.State = 0
	npc.Friction = 1
	local intensity = 2.5
	local speed = 0.1
	local move_speed = 4
	local isWestCongression = FiendFolio.GetBits(subType, 0, 1) == 1
	if isWestCongression then
		sprite.FlipX = true
		move_speed = -4
	end
	if not npcdata.init then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		sprite:Play("Walk",0)
		npcdata.sine = 39.2
		npcdata.state = "idle"
		npcdata.init = true
		npc.Velocity = Vector(move_speed,npc.Velocity.Y)

		npcdata.randospawn = FiendFolio.GetBits(subType, 2, 1) == 1

		local positionOffset = FiendFolio.GetBits(subType, 3, 5) - 10
		npc.Position = Vector(npc.Position.X + (positionOffset * 40), npc.Position.Y)

		if game:GetLevel():GetCurrentRoomDesc().PressurePlatesTriggered and room:IsClear() then
			npc:Remove()
		end
	elseif npcdata.state == "idle" then
		if room:HasTriggerPressurePlates() and room:IsClear() and sprite:IsPlaying("Walk") and sprite:GetFrame() == 1 then
			npcdata.state = "die"
			sprite:Play("Die",0)
		end
		--Isaac.DebugString(npc.Position.X)

		--eastbound movement
		if not isWestCongression then
			if npc.Position.X > room:GetGridWidth()*40+100 then
				local ypos
				if npcdata.randospawn then
					ypos = mod:congressionRandom()
				else
					ypos = npc.Position.Y
				end
				npc.Position = Vector(-100, ypos)
			end
		--westbound movement
		else
			if npc.Position.X < -100 then
				local ypos
				if npcdata.randospawn then
					ypos = mod:congressionRandom()
				else
					ypos = npc.Position.Y
				end
				npc.Position = Vector(room:GetGridWidth()*40+100, ypos)
			end
		end

		if FiendFolio.GetBits(subType, 1, 1) == 0 then -- sine or no sine
			npc.Velocity = Vector(move_speed, 0)
		else
			if not isWestCongression then
				npcdata.sine = npcdata.sine - speed
			else
				npcdata.sine = npcdata.sine + speed
			end

			npc.Velocity = Vector(move_speed, math.sin(npcdata.sine)*intensity)
		end
	elseif npcdata.state == "die" then
		if sprite:IsFinished("Die") then
			npc:Remove()
		end
	else
		npcdata.init = false
	end
end

function mod:congressionHurt(npc, damage, flag, source)
	if npc.Variant < 2 then
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.congressionHurt, 709)