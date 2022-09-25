local mod = FiendFolio

function mod:thwammyAI(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local room = Game():GetRoom()

    if not data.init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)
        sprite:Play("IdleSlammed")
        data.state = "Appear"
        data.initPos = npc.Position
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if not data.isSpecturned then
		if not data.initPos then
			data.initPos = npc.Position
		end
		npc.Velocity = data.initPos-npc.Position
	else
		data.initPos = nil
	end

    if data.state == "Idle" then
        if npc.SubType == 0 and (room:IsClear() or mod.areRoomPressurePlatesPressed()) then
        elseif target.Position:Distance(npc.Position) < 80 then
            if not data.scheduled then
                data.scheduled = 9
            end
        end
        if data.scheduled then
            if data.scheduled > 0 then
                data.scheduled = data.scheduled-1
            else
                data.scheduled = nil
                data.state = "Slamming"
            end
        end
        mod:spritePlay(sprite, "IdleWait")
    elseif data.state == "IdleSlammed" then
        if npc.StateFrame > 30 then
            data.state = "Rising"
        end
    elseif data.state == "Slamming" then
        if sprite:IsFinished("SlamDown") then
            data.state = "IdleSlammed"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Slam") then
            npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.CollisionDamage = 2
            Game():ShakeScreen(10)
            for _, enemy in ipairs(Isaac.FindInRadius(npc.Position, 100, EntityPartition.ENEMY)) do
                if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                    if enemy.Position:DistanceSquared(npc.Position) <= (npc.Size + enemy.Size) ^ 2 then
                        enemy:TakeDamage(50, 0, EntityRef(npc), 0)
                    end
                end
            end
            --[[for _,pl in ipairs(Isaac.FindByType(1, -1, -1, false, false)) do
                local player = pl:ToPlayer()
                if (math.abs(npc.Position.X-player.Position.X) ^ 2 <= (npc.Size*npc.SizeMulti.X + player.Size) ^ 2) and (math.abs(npc.Position.Y-player.Position.Y) ^ 2 <= -5+(npc.Size*npc.SizeMulti.Y + player.Size) ^ 2) then
                --if player.Position:DistanceSquared(npc.Position) <= (npc.Size + player.Size) ^ 2 then
                    player:AddSlowing(EntityRef(npc),60,0.9,Color(1.5,1.5,1.5,1,0,0,0))
			        player:AddEntityFlags(EntityFlag.FLAG_SLOW)
                    if not player:GetData().thwammyCrush then
                        player:GetData().thwammyCrush = 75
                        player:GetData().thwammyOriginal = player.SpriteScale
                        player.SpriteScale = Vector(player.SpriteScale.X*1.5, 0.3)
                    end
                end
            end]]
            for _,grid in ipairs(mod.GetGridEntities()) do
				if grid.Position:Distance(npc.Position) < 80 then
					grid:Destroy()
				end
			end
            mod.scheduleForUpdate(function()
                npc.CollisionDamage = 0
            end, 1)
        else
            mod:spritePlay(sprite, "SlamDown")
        end
    elseif data.state == "Rising" then
        if sprite:IsFinished("Leave") then
            data.state = "Idle"
        elseif sprite:IsEventTriggered("Leave") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else
            mod:spritePlay(sprite, "Leave")
        end
    elseif data.state == "Appear" then
        if sprite:IsFinished("Appear") then
            data.state = "Idle"
        elseif sprite:IsEventTriggered("Leave") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else
            mod:spritePlay(sprite, "Appear")
        end
    end
end

function mod:thwammyHurt(npc)
    return false
end

function mod:thwammyPlayerUpdate(player, data)
    if data.thwammyCrush then
        data.thwammyCrush = data.thwammyCrush-1
        
        if data.thwammyCrush < 0 then
            player.SpriteScale = data.thwammyOriginal
            data.thwammyCrush = nil
        elseif data.thwammyCrush < 10 then
            player.SpriteScale = mod:Lerp(player.SpriteScale, data.thwammyOriginal, 0.3)
        end
    end
end

function mod:thwammyColl(npc, coll)
    if coll:ToPlayer() and npc.CollisionDamage == 2 then
        local player = coll:ToPlayer()
        player:AddSlowing(EntityRef(npc),60,0.9,Color(1.5,1.5,1.5,1,0,0,0))
		player:AddEntityFlags(EntityFlag.FLAG_SLOW)
        if not player:GetData().thwammyCrush then
            player:GetData().thwammyCrush = 75
            player:GetData().thwammyOriginal = player.SpriteScale
            player.SpriteScale = Vector(player.SpriteScale.X*1.5, 0.3)
        end
    end
end