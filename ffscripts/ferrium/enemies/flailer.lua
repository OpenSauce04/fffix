local mod = FiendFolio
local game = Game()

function mod:FlailerWall(pos, Alignment)
	local vec = Vector(0, 10)
	local room = game:GetRoom()
	local wall = {Position = pos, Dist = 99999, Alignment = 1}

	for i = 1, 4 do
		local keepSearching = true
		local dist = 1
		while keepSearching == true do
			local newpos = pos + (vec:Rotated(i*90) * dist)
			local grident = room:GetGridEntityFromPos(newpos)
			if grident and (grident.Desc.Type == GridEntityType.GRID_WALL or grident.Desc.Type == GridEntityType.GRID_DOOR or grident.Desc.Type == GridEntityType.GRID_PILLAR) then
				if dist < wall.Dist then
                    if math.abs(room:GetTopLeftPos().X-pos.X) < 10 then
                        i = 1
                    elseif math.abs(room:GetTopLeftPos().Y-pos.Y) < 10 then
                        i = 2
                    elseif math.abs(room:GetBottomRightPos().X-pos.X) < 10 then
                        i = 3
                    elseif math.abs(room:GetBottomRightPos().Y-pos.Y) < 10 then
                        i = 4
                    end
					wall = {Position = newpos, Dist = dist, Alignment = i}
				end
				keepSearching = false
			else
				dist = dist + 1
				if dist > 800 then
					keepSearching = false
				end
			end
		end
	end

	if Alignment then
		return {wall.Position, wall.Alignment}
	else
		return wall.Position
	end
end

function mod:flailerAI(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if npc.SubType == 0 then
        if not data.init then
            local head = Isaac.Spawn(mod.FF.FlailerHead.ID, mod.FF.FlailerHead.Var, mod.FF.FlailerHead.Sub, npc.Position, Vector.Zero, npc):ToNPC()
            head.Parent = npc
            head.SpriteOffset = Vector(0,-16)
            npc.Child = head
            data.init = true
        end
        if npc.Child and npc.Child:Exists() and not mod:isStatusCorpse(npc.Child) then
            mod:spritePlay(sprite, "Meat")
            if mod:isScare(npc) then
                local targVel = (targetpos-npc.Position):Resized(-2)
                npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
            elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
                local targVel = (targetpos-npc.Position):Resized(0.8)
                npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
            else
                npc.Pathfinder:FindGridPath(targetpos, 0.2, 900, true)
            end
        else
            npc:Kill()
            local globin = Isaac.Spawn(24, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
        end
    else
        if not data.init then
            data.state = "Idle"
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            data.dist = 70
            data.init = true
        else
            npc.StateFrame = npc.StateFrame+1
        end
        npc.DepthOffset = 500

        if npc.Parent and npc.Parent:Exists() and not mod:isStatusCorpse(npc.Parent) then
            if npc.Parent:GetData().eternalFlickerspirited  and not data.eternalFlickerspirited then
                data.eternalFlickerspirited = true
                --npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
            end

            if data.state == "Idle" then
                npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(2), 0.3)

                if npc.Velocity:Length() > 1 then
                    if npc.Velocity.X > 0 then
                        sprite.FlipX = true
                    else
                        sprite.FlipX = false
                    end
                end
                if not mod:isScareOrConfuse(npc) then
                    if npc.StateFrame > 45 and target.Position:Distance(npc.Position) < 120 then
                        data.state = "Flail"
                        data.subState = "Init"
                        npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                        data.dist = 999
                    elseif npc.StateFrame > 110 then
                        data.state = "Rotate"
                        data.subState = "Init"
                        npc:PlaySound(SoundEffect.SOUND_MAGGOTCHARGE, 1, 0, false, 1)
                        data.dist = 85
                    end
                end

                mod:spritePlay(sprite, "Idle")
            elseif data.state == "Rotate" then
                if data.subState == "Init" then
                    if sprite:IsFinished("RotateStart") then
                        data.subState = "Rotating"
                        npc.StateFrame = 0
                        data.currAngle = mod:GetAngleDegreesButGood(npc.Position-npc.Parent.Position)
                        data.rotDir = 1-rng:RandomInt(2)*2
                        sprite:Play("Rotate", true)
                        sprite:Stop()
                        data.rotDist = 6
                        sprite.FlipX = false
                        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    else
                        mod:spritePlay(sprite, "RotateStart")
                    end
                    local targVel = (npc.Parent.Position-npc.Position):Resized(9)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                elseif data.subState == "Rotating" then
                    if data.currAngle < 0 then
                        data.currAngle = data.currAngle+360
                    end

                    local targPos = npc.Parent.Position+Vector(0,data.rotDist):Rotated(data.currAngle)
                    local targVel = (targPos-npc.Position)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                    if data.rotDist < 80 then
                        data.rotDist = data.rotDist+2
                    end

                    if npc.StateFrame % 4 == 0 then
                        npc:FireProjectiles(npc.Position, Vector(0,6):Rotated(data.currAngle), 0, ProjectileParams())
                    end
                    
                    local spriteAngle = math.abs(360-data.currAngle+45)
                    if data.rotDir == 1 then
                        sprite.FlipX = true
                        spriteAngle = data.currAngle+67.5
                    end
                    spriteAngle = math.floor((spriteAngle % 360)/45)
                    sprite:SetFrame("Rotate", spriteAngle*3)

                    data.currAngle = data.currAngle+10*data.rotDir
                    local wallData = mod:FlailerWall(npc.Position, true)
                    if npc.StateFrame > 120 then
                        data.subState = "Finish"
                        npc.StateFrame = 0
                        npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    elseif wallData[1]:Distance(npc.Position) < 20 then
                        data.hitDir = wallData[2]
                        sprite.FlipX = false
                        data.subState = "Hit"
                        npc:BloodExplode()
                        npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.5, 0, false, 1)
                        for i=1,2 do
                            for j=-1,1,2 do
                                npc:FireProjectiles(npc.Position, Vector(0,-7-(3-i)*2):Rotated(90*data.hitDir+(5+10*i)*j), 0, ProjectileParams())
                            end
                        end
                        if mod.GetEntityCount(310, 1) < 4 then
                            local flesh = Isaac.Spawn(310, 1, 0, npc.Position, Vector(0,-6):Rotated(90*data.hitDir), npc):ToNPC()
                            flesh:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        end
                        local poof = Isaac.Spawn(1000, 16, 5, npc.Position, Vector.Zero, npc):ToEffect()
                        poof.SpriteScale = Vector(0.5, 0.5)
                    end
                elseif data.subState == "Hit" then
                    local dirs = {
                        [1] = "Left",
                        [2] = "Up",
                        [3] = "Right",
                        [4] = "Down"
                    }
                    local animDir = dirs[data.hitDir]
                    
                    if sprite:IsFinished("HitWall" .. animDir) then
                        data.state = "Idle"
                        npc.StateFrame = 0
                        data.dist = 70
                        npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    else
                        mod:spritePlay(sprite, "HitWall" .. animDir)
                    end

                    npc.Velocity = Vector.Zero
                elseif data.subState == "Finish" then
                    if npc.StateFrame > 15 then
                        data.state = "Idle"
                        npc.StateFrame = 0
                        data.dist = 70
                    end
                    mod:spritePlay(sprite, "Idle")
                    local targVel = (npc.Parent.Position-npc.Position):Resized(6)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                end
            elseif data.state == "Flail" then
                if data.subState == "Init" then
                    if target.Position.X > npc.Position.X then
                        sprite:Play("SlamRightStart", true)
                    else
                        sprite:Play("SlamLeftStart", true)
                    end
                    sprite.FlipX = false
                    data.launchedEnemyInfo = {pos = true, zVel = -5, landFunc = function()
                        data.subState = "Launching"
                        data.targPos = target.Position
                        data.targVel = (target.Position-npc.Position)*0.06
                        npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                        data.launchedEnemyInfo = {pos = true, zVel = -16, accel = 0.8,landFunc = function()
                            data.subState = "Ending"
                            npc.StateFrame = 0
                            npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.5, 0, false, 1)
                            local poof = Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc):ToEffect()
                            poof.DepthOffset = 5
                            poof.SpriteScale = Vector(0.8, 0.8)
                            for i=45,315,90 do
                                npc:FireProjectiles(npc.Position, Vector(10,0):Rotated(i), 0, ProjectileParams())
                            end
                            if npc.Velocity.X > 0 then
                                sprite:Play("SlamRight", true)
                            else
                                sprite:Play("SlamLeft", true)
                            end
                            npc.SpriteOffset = Vector.Zero
                        end, additional = function()
                            if npc.PositionOffset.Y < -5 then
                                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                            else
                                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                            end
                        end}
                    end}
                    data.subState = "Searching"
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
                elseif data.subState == "Searching" then
                    local targPos = npc.Position+(target.Position-npc.Position):Resized(-80)

                    local targVel = (targPos-npc.Position):Resized(8)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                elseif data.subState == "Launching" then
                    if npc.Velocity.X > 0 then
                        mod:spritePlay(sprite, "SlamRightLoop")
                    else
                        mod:spritePlay(sprite, "SlamLeftLoop")
                    end

                    npc.Velocity = mod:Lerp(npc.Velocity, data.targVel, 0.3)
                elseif data.subState == "Ending" then
                    if npc.StateFrame > 35 then
                        data.state = "Idle"
                        npc.StateFrame = 0
                        data.dist = 70
                    end

                    if sprite:IsFinished("SlamRight") or sprite:IsFinished("SlamLeft") then
                        sprite:Play("Idle")
                    elseif sprite:IsEventTriggered("Normal") then
                        data.normal = true
                        npc.StateFrame = 0
                    end

                    if data.normal then
                        if npc.SpriteOffset.Y > -16 then
                            npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y-1)
                        else
                            data.normal = nil
                        end
                    end
                    local targVel = (npc.Parent.Position-npc.Position):Resized(3)
                    npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
                end
            end

            local dist = npc.Parent.Position - npc.Position
            if dist:Length() > data.dist then
                local distToClose = dist - dist:Resized(data.dist)
                npc.Velocity = npc.Velocity + distToClose*0.5
            end

            if npc:IsDead() then
                local fistuloid = Isaac.Spawn(308, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
                fistuloid:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                fistuloid:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                --[[fistuloid.State = 5
                if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
					if (target.Position.X - npc.Position.X) > 0 then
						fistuloid.V1 = Vector(1, 0)
					else
						fistuloid.V1 = Vector(-1, 0)
					end
				else
					if (target.Position.Y - npc.Position.Y) > 0 then
						fistuloid.V1 = Vector(0, 1)
					else
						fistuloid.V1 = Vector(0, -1)
					end
				end
                fistuloid.TargetPosition = npc.Position
                fistuloid:Update()]]
                fistuloid.HitPoints = 0
                fistuloid:TakeDamage(1, 0, EntityRef(npc), 0)
            end
        else
            npc:BloodExplode()
            npc.SpriteOffset = Vector.Zero
            npc.PositionOffset = Vector.Zero
            data.launchedEnemyInfo = nil
            npc.PositionOffset = Vector.Zero
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:Morph(308, 0, 0, -1)
        end
    end
end

function mod:flailerRender(npc)
    if npc.SubType == 0 and npc.Child then
        local child = npc.Child
        for i=0,10 do
            local extraOffset = Vector.Zero
            if child:GetData().state == "Idle" then
                extraOffset = Vector(0, 0.45*(i-4.55)^2-10)
            else
                extraOffset = Vector(0, 0.2*(i-4.55)^2-4)
            end
            local childPos = child.Position+child.SpriteOffset+child.PositionOffset
            local tPos = Isaac.WorldToScreen(npc.Position+Vector(0,-10)+i*(childPos-npc.Position)/10-extraOffset)
            local sprite = Sprite()
            sprite:Load("gfx/enemies/flailer/monster_flailerMeat.anm2", true)
            sprite:Play("MeatBall", true)
            sprite:Render(tPos, Vector.Zero, Vector.Zero)
        end
    end
end

function mod:flailerColl(npc, coll, bool)
    if coll:ToNPC() then
        if coll.Type == 310 and coll.Variant == 1 and coll.SubType == 0 then
            return true
        end
        if npc.SubType > 0 then
            if coll.Type == mod.FF.FlailerHead.ID and coll.Variant == mod.FF.FlailerHead.Var then
                return true
            end
        end
    end
end