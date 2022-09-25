local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:FindRandomFreePosOnlyfanApparition(pos, radius, avoidnearby)
    radius = radius or 0
    local validPositions = {}
    local validPositionsFar = {}
    local room = game:GetRoom()
    local size = room:GetGridSize()
    local nearbyThings = {}
    for _, p in pairs(Isaac.FindByType(1)) do
        table.insert(nearbyThings, p)
    end
    for _, p in pairs(Isaac.FindByType(mod.FF.OnlyfanAfterimage.ID, mod.FF.OnlyfanAfterimage.Var, mod.FF.OnlyfanAfterimage.Sub)) do
        table.insert(nearbyThings, p)
    end
    for i=0, size do
        local gridpos = room:GetGridPosition(i)
        if room:GetGridCollisionAtPos(gridpos) <= GridCollisionClass.COLLISION_PIT and room:IsPositionInRoom(gridpos, 0) then
            if (not avoidnearby) or (avoidnearby and not mod.FindClosestEnemy(gridpos, 30)) then
                local anythingNearby
                local weakNearby
                for j = 1, #nearbyThings do   
                    if gridpos:Distance(nearbyThings[j].Position) < 30 then
                        anythingNearby = true
                        break
                    elseif gridpos:Distance(nearbyThings[j].Position) < 150 then
                        weakNearby = true
                        break
                    end
                end
                if not anythingNearby then
                    table.insert(validPositions, gridpos)
                    local dist = pos:Distance(gridpos)
                    if dist > radius then
                        if not weakNearby then
                            table.insert(validPositionsFar, gridpos)
                        end
                    end
                end
            end
        end
    end
    if #validPositionsFar > 0 then
        return validPositionsFar[math.random(#validPositionsFar)]
    elseif #validPositions > 0 then
        return validPositions[math.random(#validPositions)]
    else
        return room:GetRandomPosition(1)
    end
end

function mod:onlyfanAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
        npc.SplatColor = mod.ColorInvisible
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if mod:isScare(npc) then
			d.targetvel = (target.Position - npc.Position):Resized(-4)
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
		else
			if npc.Position:Distance(target.Position) < 120 then
				d.targetvel = (target.Position - npc.Position):Resized(-10)
				d.running = true
			elseif npc.StateFrame % 30 == 1 or d.running then
                local gridtarget = mod:FindRandomFreePosAirWithPitOrNoColl(target.Position, 120)
                d.targetvel = (gridtarget - npc.Position):Resized(3)
                d.running = false
            else
                local gridtarget = mod:FindRandomFreePosAirWithPitOrNoColl(target.Position, 120)
                d.targetvel = d.targetvel or (gridtarget - npc.Position):Resized(5)
			end
		end
        npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)

        if game:GetRoom():GetGridCollisionAtPos(npc.Position) <= GridCollisionClass.COLLISION_PIT then
            if npc.StateFrame > 90 and math.random(30) then
                d.state = "dive"
            end
        end
    elseif d.state == "dive" then
        npc.Velocity = nilvector
        if sprite:IsFinished("Dive") then
            npc.Visible = false
            d.state = "waiting"
            npc.StateFrame = 0
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            
            npc:PlaySound(mod.Sounds.OnlyfanBwop, 1, 0, false, 1)
            local poses = {1,2,3,4}
            d.afterImages = {}
            for i = 1, 3 do
                local pos = mod:FindRandomFreePosOnlyfanApparition(target.Position, 120, true)
                local afterimage = Isaac.Spawn(mod.FF.OnlyfanAfterimage.ID, mod.FF.OnlyfanAfterimage.Var, mod.FF.OnlyfanAfterimage.Sub, pos, nilvector, npc)
                local poseChoice = math.random(#poses)
                afterimage:GetData().pose = poses[poseChoice]
                table.remove(poses, poseChoice)
                table.insert(d.afterImages, afterimage)
                afterimage.Parent = npc
                afterimage:Update()
            end
            d.pose = poses[1]
        elseif sprite:IsEventTriggered("Fwoosh") then
            local splash = Isaac.Spawn(1000, 132, 0, npc.Position, nilvector, npc)
            splash.SpriteScale = Vector(0.5,0.5)
            splash.DepthOffset = 10
            splash:Update()
            npc:PlaySound(mod.Sounds.SplashLargePlonkless, 0.3, 0, false, 1.5)
        else
            mod:spritePlay(sprite, "Dive")
        end
    elseif d.state == "waiting" then
        npc.Velocity = nilvector
        if npc.StateFrame > 30 then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.Position = mod:FindRandomFreePosOnlyfanApparition(target.Position, 120, true)
            npc.Visible = true
            d.state = "reappear"
            mod:spritePlay(sprite, "Emerge")
            local splash = Isaac.Spawn(1000, 132, 0, npc.Position, nilvector, npc)
            splash.SpriteScale = Vector(0.5,0.5)
            splash.DepthOffset = 10
            splash:Update()
            npc:PlaySound(mod.Sounds.SplashLargePlonkless, 0.3, 0, false, 1.5)
        end
    elseif d.state == "reappear" then
        npc.Velocity = nilvector
        if sprite:IsFinished("Emerge") then
            d.state = "pose"
            mod:spritePlay(sprite, "Pose" .. d.pose .. "Transition")
        else
            mod:spritePlay(sprite, "Emerge")
        end
    elseif d.state == "pose" then
        npc.Velocity = nilvector
        if sprite:IsFinished("Pose" .. d.pose .. "Transition") then
            d.state = "pose"
            mod:spritePlay(sprite, "Pose" .. d.pose .. "Hold")
        end
        if sprite:IsEventTriggered("Spawn") then
            d.tearSpawnPositions = {}
            for i = 1, #d.afterImages do
                if d.afterImages[i] and d.afterImages[i]:Exists() then
                    d.tearSpawnPositions[i] = d.afterImages[i].Position
                    d.afterImages[i]:GetData().Dying = true
                end
            end
        end
        if d.tearSpawnPositions then
            if npc.FrameCount % 5 == 0 then
                local anySuccesses
                for i = 1, #d.tearSpawnPositions do
                    if d.tearSpawnPositions[i] then
                        d.tearSpawnPositions[i] = d.tearSpawnPositions[i] + (npc.Position - d.tearSpawnPositions[i]):Resized(25)
                        local splash = Isaac.Spawn(1000, 7002, 0, d.tearSpawnPositions[i], nilvector, npc)
                        splash:Update()
                        local params = ProjectileParams()
                        params.HeightModifier = 10
                        params.FallingSpeedModifier = -12
                        params.FallingAccelModifier = 0.7
                        params.Variant = 4
                        npc:FireProjectiles(d.tearSpawnPositions[i], nilvector, 0, params)
                        if d.tearSpawnPositions[i]:Distance(npc.Position) < 15 then
                            d.tearSpawnPositions[i] = false
                        else
                            anySuccesses = true
                        end
                    end
                end
                if not anySuccesses then
                    d.state = "returnToIdle"
                    d.tearSpawnPositions = nil
                else
                    npc:PlaySound(mod.Sounds.Plorp, 0.3, 0, false, 1.8)
                end
            end
        end
    elseif d.state == "returnToIdle" then
        npc.Velocity = nilvector
        if sprite:IsFinished("Pose" .. d.pose .. "Exit") then
            d.state = "idle"
            npc.StateFrame = 0
        else
            mod:spritePlay(sprite, "Pose" .. d.pose .. "Exit")
        end
    end
end

function mod:onlyfanAfterimage(e)
    local sprite, d = e:GetSprite(), e:GetData()
    d.pose = d.pose or math.random(4)
    if not d.init then
        d.init = true
        mod:spritePlay(sprite, "Image0" .. d.pose .. "Appear")
    end
    if sprite:IsFinished("Image0" .. d.pose .. "Appear") then
        mod:spritePlay(sprite, "Image0" .. d.pose)
    end
    if e.Parent then
        if not e.Parent:Exists() then
            d.Dying = true
        end
    end
    if d.Dying then
        e.Color = Color(e.Color.R,e.Color.G,e.Color.B,e.Color.A - (e.Color.A/5))
        if e.Color.A <= 0.2 then
            local poof = Isaac.Spawn(1000, 12, 0, e.Position, Vector.Zero, e)
            poof.SpriteOffset = Vector(0, -15)
            poof.Color = FiendFolio.ColorGhostly
            e:Remove()
        end
    end
end
