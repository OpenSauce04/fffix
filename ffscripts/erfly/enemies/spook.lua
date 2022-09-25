local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:spookAI(npc, subt, var)
    if not npc:Exists() then
        return
    end

	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not mod.spookInRoom then
		mod.spookInRoom = true
	end

    local delay = FiendFolio.GetBits(subt, 0, 8)
	if not d.init then
        local count = FiendFolio.GetBits(subt, 8, 8) + 1
        if count > 1 and npc:Exists() then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            for i = 0, count - 1 do
                local spook = Isaac.Spawn(mod.FF.Spook.ID, mod.FF.Spook.Var, delay + i, npc.Position, nilvector, nil)
                spook:Update()
            end

            npc:Remove()

            return
        end

		if not sfx:IsPlaying(mod.Sounds.GhostHiding) then
			sfx:Play(mod.Sounds.GhostHiding, 1, 0, false, 1)
		end
		mod.spookrecord = {}
		mod.spookrecordplayerstart = {}
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.Visible = false
		npc.Position = Isaac.GetPlayer().Position
		d.moving = true
		d.dist = 35
		--15
		if math.random(2) == 1 then
			sprite.FlipX = true
		end
		d.init = true
	end

	if game:GetRoom():IsClear() then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.Velocity = npc.Velocity * 0.9
		if not d.calmed then
			if not sfx:IsPlaying(mod.Sounds.GhostCalm) then
				sfx:Play(mod.Sounds.GhostCalm, 1, 0, false, 0.7)
			end
			d.calmed = true
		end
		if sprite:IsFinished("Death") then
			npc:Remove()
		else
			mod:spritePlay(sprite,"Death")
		end
	elseif d.moving then
		if mod.spookJustKilledEnemy then
			if not d.screaming then
				mod:spritePlay(sprite, "ChaseStart")
				d.screaming = true
			elseif sprite:IsEventTriggered("Scream") then
				d.catchup = true
				if not sfx:IsPlaying(mod.Sounds.GhostAngered) then
					sfx:Play(mod.Sounds.GhostAngered, 1, 0, false, 1)
				end
			elseif sprite:IsFinished("ChaseStart") then
				mod:spritePlay(sprite, "Chase")
			end
		elseif d.screaming then
			if d.catchup then
				d.catchup = false
				if not sfx:IsPlaying(mod.Sounds.GhostCalm) then
					sfx:Play(mod.Sounds.GhostCalm, 1, 0, false, 1)
				end
			end
			if sprite:IsFinished("ChaseEnd") then
				mod:spritePlay(sprite,"Walk")
				d.screaming = false
			else
				mod:spritePlay(sprite,"ChaseEnd")
			end
		end

		if d.catchup then
			if d.dist > 15 then
				d.dist = d.dist - 1
			end
		else
			if d.dist < 35 then
				d.dist = d.dist + 1
			end
		end
		if mod.spookrecord[1] then
			if #mod.spookrecord[1] > d.dist + (delay * 5) and (mod.spookrecord[1][d.dist + (delay * 5)].position:Distance(mod.spookrecordplayerstart[1]) > 50 or d.budjimsorry) then
				npc.TargetPosition = mod:Lerp(npc.Position, mod.spookrecord[1][d.dist + (delay * 5)].position, 0.2)
				--npc.Velocity = mod:Lerp(npc.Velocity, mod.spookrecord[1][d.dist + (delay * 5)].velocity, 0.2)
				npc.Velocity = npc.TargetPosition - npc.Position
				--maria mode
				--npc.Position = room:GetGridPosition(room:GetGridIndex(mod.spookrecord[1][d.dist + (delay * 5)].position))
				--npc.Velocity = nilvector
				d.budjimsorry = true
				--npc.Velocity = nilvector
				if not d.herenow then
					npc.Visible = true
					sprite:Play("Appear", true)
					d.herenow = true
					if subt < 2 and not sfx:IsPlaying(mod.Sounds.GhostAppear) then
						sfx:Play(mod.Sounds.GhostAppear, 1, 0, false, 1)
					end
				else
					if sprite:IsFinished("Appear") then
						mod:spritePlay(sprite, "Walk")
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					end
				end
			end
		end
	end
end

function mod:spookHurt(npc, damage, flag, source)
    return false
end

function mod.spookLogic()
	if mod.spookInRoom then
        local maxSpookDelay = 0
        for _, spook in ipairs(Isaac.FindByType(mod.FF.Spook.ID, mod.FF.Spook.Var, -1)) do
            maxSpookDelay = math.max(maxSpookDelay, FiendFolio.GetBits(spook.SubType, 0, 8))
        end

		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			mod.spookrecord = mod.spookrecord or {}
			mod.spookrecordplayerstart = mod.spookrecordplayerstart or {}
			if not mod.spookrecord[i] then
				mod.spookrecord[i] = {}
			end
			if not mod.spookrecordplayerstart[i] then
				mod.spookrecordplayerstart[i] = player.Position
			end
			table.insert(mod.spookrecord[i], 1, {position = player.Position, velocity = player.Velocity})
			if #mod.spookrecord[i] > (maxSpookDelay * 5) + 40 then
				table.remove(mod.spookrecord[i], #mod.spookrecord[i])
			end
		end
		if mod.spookJustKilledEnemy then
			mod.spookJustKilledEnemy = mod.spookJustKilledEnemy + 1
			if mod.spookJustKilledEnemy > 120 then
				mod.spookJustKilledEnemy = nil
			end
		end
	end
end