local mod = FiendFolio
local game = Game()

function TeleporterPathToPos(npc, pos, mode) --look this is messy but im getting back into the swing of things and pathtopos sucks
	local path = npc.Pathfinder
	local room = game:GetRoom()
    local TRUEing = false
    local freePos = npc.Position

	if path:HasPathToPos(pos) then
		TRUEing = true
	elseif room:GetGridEntityFromPos(npc.Position) and room:GetGridEntityFromPos(npc.Position):GetType() == GridEntityType.GRID_TELEPORTER then
		local found = {}
		for i=90,360,90 do
			local checkPos = npc.Position+Vector(0,40):Rotated(i)
			if room:GetGridCollisionAtPos(checkPos) == GridCollisionClass.COLLISION_NONE then
				local testPath = Isaac.Spawn(mod.FFID.Ferrium, 5, 0, checkPos, Vector.Zero, nil):ToNPC()
                testPath.Visible = false
                testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                if testPath.Pathfinder:HasPathToPos(pos, false) then
					testPath:Remove()
                    table.insert(found, checkPos)
					break
				else
                    testPath:Remove()
				end
			end
		end
		if #found > 0 then
            if #found > 1 then
                local dist = 9999
                for _,pos2 in ipairs(found) do
                    if pos2:Distance(pos) < dist then
                        dist = pos2:Distance(pos)
                        freePos = pos2
                    end
                end
            else
                freePos = found[1]
            end
			TRUEing = true
		end
	end

    if TRUEing == true and mode then
        return true
    elseif mode then
        return false
    else
        return freePos
    end
end

function mod.setAcolyteTelInfo()
    mod.acolyteTelInfo.info = {}
    mod.acolyteTelInfo.dests = {}
    for _,grid in ipairs(mod.GetGridEntities()) do
        if grid:GetType() == GridEntityType.GRID_TELEPORTER then
            table.insert(mod.acolyteTelInfo.info, {grid = grid, index = grid:GetGridIndex(), var = grid.Desc.Variant, state = grid.State})
        end
    end
    for _,entry in ipairs(mod.acolyteTelInfo.info) do
        if not mod.acolyteTelInfo.dests[entry.var] then
            mod.acolyteTelInfo.dests[entry.var] = {}
        end
        local varTab = mod.acolyteTelInfo.dests[entry.var]
        if entry.state == 0 then
            local firstVar
            local totalCount = 1
            for _,entrii in ipairs(mod.acolyteTelInfo.info) do
                if entry.var == entrii.var and entry.index ~= entrii.index then
                    if firstVar == nil then
                        firstVar = entrii.index
                    end
                    totalCount = totalCount+1
                    if entry.index < entrii.index then
                        varTab[entry.index] = entrii.index
                        break
                    end
                end
            end
            if varTab[entry.index] == nil and totalCount > 1 then
                varTab[entry.index] = firstVar
            end
        end
    end
end

function mod:acolyteAI(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.init then
        data.state = "Idle"
        data.prevTel = 0
        data.moveSpeed = 5
        --[[local level = game:GetLevel()
        local stage = level:GetStage()
		local stageType = level:GetStageType()
        if stageType == StageType.STAGETYPE_REPENTANCE_B and (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2) then
            mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/acolyte/monster_acolyte_gehenna", 1, true)
        end]]
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if npc.FrameCount > 0 then
        if not mod.acolyteTelInfo then
            mod.acolyteTelInfo = {}
            mod.setAcolyteTelInfo()
        else
            for _,tel in ipairs(mod.acolyteTelInfo.info) do
                local currTel = room:GetGridEntity(tel.index)
                if currTel.State ~= tel.state then
                    mod.acolyteTelInfo = {}
                    mod.setAcolyteTelInfo()
                    break
                end
            end
        end
        if data.state == "Idle" then
            if sprite:IsEventTriggered("Sound") then
                npc:PlaySound(SoundEffect.SOUND_SCYTHE_BREAK, 0.25, 0, false, math.random(150,250)/100)
            end

            if data.queuedLunge then
                data.state = "Lunge"
                data.movement = false
                data.queuedLunge = nil
            end
            if target:ToPlayer() and data.increased then
                local player = target:ToPlayer()
                if player.MoveSpeed*7 < data.moveSpeed then
                    data.moveSpeed = player.MoveSpeed*7
                end
                data.increased = nil
            end

            if npc.Velocity:Length() > 0.1 then
                --npc:AnimWalkFrame("WalkHori","WalkVert",0)
                if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                    mod:spritePlay(sprite, "WalkHori")
                else
                    mod:spritePlay(sprite, "WalkVert")
                end
                if npc.Velocity.X > 0 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
            else
                mod:spritePlay(sprite, "Idle")
            end

            if mod:isScare(npc) then
                local targetvel = (targetpos - npc.Position):Resized(-data.moveSpeed*1.5)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
                data.teleporterHere = nil
            elseif data.quickerTel then
                local pos = data.quickerTel.Position
                if room:CheckLine(npc.Position, pos, 0, 1, false, false) or npc.Position:Distance(pos) < 50 then
                    local targetvel = (pos - npc.Position):Resized(data.moveSpeed)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
                elseif npc.Pathfinder:HasPathToPos(pos) then
                    npc.Pathfinder:FindGridPath(pos, data.moveSpeed/6.5, 900, true)
                elseif TeleporterPathToPos(npc, pos, false) then
                    npc.Velocity = mod:Lerp(npc.Velocity, (TeleporterPathToPos(npc, pos, false)-npc.Position):Resized(data.moveSpeed), 0.3)
                end

                if npc.Position:Distance(pos) < 20 then
                    local telDex = mod.acolyteTelInfo.dests[data.quickerTel.Desc.Variant][data.quickerTel:GetGridIndex()]
                    if telDex then
                        data.telDest = room:GetGridPosition(telDex)
                        data.prevTel = telDex
                        data.state = "TelOut"
                        npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1, 1, 0, false, 1)
                    else
                        data.quickerTel = nil
                    end
                end
                if not TeleporterPathToPos(npc, pos, true) or not npc.Pathfinder:HasPathToPos(target.Position) then
                    data.quickerTel = nil
                end
            elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
                local targetvel = (targetpos - npc.Position):Resized(data.moveSpeed)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)

                local quickerDist = 9999
                local quickerPort
                for _,tel in ipairs(mod.acolyteTelInfo.info) do
                    if tel.state == 0 then
                        local pos = tel.grid.Position
                        local dist = pos:Distance(npc.Position)
                        local targDist = targetpos:Distance(npc.Position)
                        if dist < targDist and TeleporterPathToPos(npc, pos, true) then
                            local destIndex = mod.acolyteTelInfo.dests[tel.var][tel.index]
                            if destIndex then
                                local destPos = room:GetGridPosition(destIndex)
                                local testPath = Isaac.Spawn(mod.FFID.Ferrium, 5, 0, destPos, Vector.Zero, nil):ToNPC()
                                testPath.Visible = false
                                testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                                testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                                if TeleporterPathToPos(testPath, target.Position, true) then
                                --if testPath.Pathfinder:HasPathToPos(target.Position, false) then
                                    if destPos:Distance(targetpos)+dist < targDist and destPos:Distance(targetpos)+dist < quickerDist then
                                        quickerDist = destPos:Distance(targetpos)+dist
                                        quickerPort = tel
                                    end
                                end
                                testPath:Remove()
                            end
                        end
                    end
                end
                if quickerPort then
                    data.quickerTel = quickerPort.grid
                end
                data.teleporterHere = nil
            else
                if npc.Pathfinder:HasPathToPos(target.Position, false) then
                    npc.Pathfinder:FindGridPath(targetpos, data.moveSpeed/6.5, 900, true)
                    local quickerDist = 9999
                    local quickerPort
                    for _,tel in ipairs(mod.acolyteTelInfo.info) do
                        if tel.state == 0 then
                            local pos = tel.grid.Position
                            local dist = pos:Distance(npc.Position)
                            local targDist = targetpos:Distance(npc.Position)
                            if dist < targDist and TeleporterPathToPos(npc, pos, true) then
                                local destIndex = mod.acolyteTelInfo.dests[tel.var][tel.index]
                                if destIndex then
                                    local destPos = room:GetGridPosition(destIndex)
                                    local testPath = Isaac.Spawn(mod.FFID.Ferrium, 5, 0, destPos, Vector.Zero, nil):ToNPC()
                                    testPath.Visible = false
                                    testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                    testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                                    testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                                    if TeleporterPathToPos(testPath, target.Position, true) then
                                    --if testPath.Pathfinder:HasPathToPos(target.Position, false) then
                                        if destPos:Distance(targetpos)+dist < targDist and destPos:Distance(targetpos)+dist < quickerDist and not (npc.StateFrame < 15 and data.prevTel == tel.index) then
                                            quickerDist = destPos:Distance(targetpos)+dist
                                            quickerPort = tel
                                        end
                                    end
                                    testPath:Remove()
                                end
                            end
                        end
                    end
                    if quickerPort then
                        data.quickerTel = quickerPort.grid
                    end
                    data.teleporterHere = nil
                else
                    if not data.teleporterHere then
                        local tels = {}
                        local goodTels = {}
                        for _,entry in ipairs(mod.acolyteTelInfo.info) do
                            if TeleporterPathToPos(npc, entry.grid.Position, true) then
                            --if npc.Pathfinder:HasPathToPos(entry.grid.Position, false) then
                                local destIndex = mod.acolyteTelInfo.dests[entry.var][entry.index]
                                --Isaac.Spawn(9, 0, 0, room:GetGridPosition(entry.index), Vector.Zero, nil)
                                if destIndex then
                                    local destPos = room:GetGridPosition(destIndex)
                                    local testPath = Isaac.Spawn(mod.FFID.Ferrium, 5, 0, destPos, Vector.Zero, nil):ToNPC()
                                    testPath.Visible = false
                                    testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                    testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                                    testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                                    if TeleporterPathToPos(testPath, target.Position, true) and not (npc.StateFrame < 15 and data.prevTel == entry.index) then
                                        table.insert(goodTels, entry.grid)
                                    elseif not (npc.StateFrame < 40 and data.prevTel == entry.index) then
                                        table.insert(tels, entry)
                                    end
                                    testPath:Remove()
                                end
                            end
                        end

                        if #goodTels > 0 then
                            if #goodTels == 1 then
                                data.teleporterHere = goodTels[1]
                            else
                                local dist = 9999
                                local dest
                                for _,grid in ipairs(goodTels) do
                                    if grid.Position:Distance(npc.Position) < dist then
                                        dest = grid
                                    end
                                end
                                if dest then
                                    data.teleporterHere = dest
                                else
                                    data.teleporterHere = nil
                                end
                            end
                        else
                            if #tels > 0 then
                                data.teleporterHere = tels[rng:RandomInt(#tels)+1].grid
                            end
                        end
                    end
                    if data.teleporterHere then
                        local pos = data.teleporterHere.Position
                        --Isaac.Spawn(9, 0, 0, pos, Vector.Zero, nil)
                        if room:CheckLine(npc.Position, pos, 0, 1, false, false) or npc.Position:Distance(pos) < 50 then
                            local targetvel = (pos - npc.Position):Resized(data.moveSpeed)
                            npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
                        elseif npc.Pathfinder:HasPathToPos(pos) then
                            npc.Pathfinder:FindGridPath(pos, data.moveSpeed/6.5, 900, true)
                        elseif TeleporterPathToPos(npc, pos, false) then
                            npc.Velocity = mod:Lerp(npc.Velocity, (TeleporterPathToPos(npc, pos, false)-npc.Position):Resized(data.moveSpeed), 0.3)
                        end

                        if npc.Position:Distance(pos) < 20 then
                            local telDex = mod.acolyteTelInfo.dests[data.teleporterHere.Desc.Variant][data.teleporterHere:GetGridIndex()]
                            if telDex then
                                data.telDest = room:GetGridPosition(telDex)
                                data.prevTel = telDex
                                data.state = "TelOut"
                                npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1, 1, 0, false, 1)
                                --npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                            end
                        end
                        if not TeleporterPathToPos(npc, pos, true) then
                            data.teleporterHere = nil
                        end
                    else
                        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
                    end
                end
            end
        elseif data.state == "Lunge" then
            if math.abs(npc.Velocity.X) > 0.2 then
                if npc.Velocity.X > 0 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
            else
                sprite.FlipX = false
            end

            if sprite:IsFinished("SpeedUp") then
                data.state = "Idle"
            elseif sprite:IsEventTriggered("Lunge") then
                npc:PlaySound(mod.Sounds.MonsterYellFlash, 1, 0, false, math.random(80,120)/100)
                if TeleporterPathToPos(npc, targetpos, true) then
                    data.movement = true
                    data.moveDir = (targetpos-npc.Position):Resized(15)
                end
            else
                mod:spritePlay(sprite, "SpeedUp")
            end

            if not data.movement then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
            else
                npc.Velocity = mod:Lerp(npc.Velocity, data.moveDir, 0.3)
                data.moveDir = data.moveDir*0.9
            end
        elseif data.state == "TelOut" then
            if sprite:IsFinished("TeleportUp") then
                data.state = "TelIn"
                npc.Position = data.telDest+mod:shuntedPosition(5, rng)
                npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL2, 1, 0, false, 1)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            else
                mod:spritePlay(sprite, "TeleportUp")
            end

            npc.Velocity = Vector.Zero
        elseif data.state == "TelIn" then
            if sprite:IsFinished("TeleportDown") then
                data.state = "Idle"
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                data.telDest = nil
                data.teleporterHere = nil
                npc.StateFrame = 0
            else
                mod:spritePlay(sprite, "TeleportDown")
            end

            npc.Velocity = Vector.Zero
        end
    end

    if npc:IsDead() and not data.deathTriggered then
        for _,ent in ipairs(Isaac.FindByType(mod.FF.Acolyte.ID, mod.FF.Acolyte.Var, -1, false, false)) do
            if not ent:IsDead() then
                local data2 = ent:GetData()
                data2.moveSpeed = math.min((data2.moveSpeed or 0)+2, 10)
                data2.increased = true
                if data2.state == "Idle" then
                    data2.state = "Lunge"
                    data2.movement = false
                else
                    data2.queuedLunge = true
                end
            end
        end
        data.deathTriggered = true
    end
end