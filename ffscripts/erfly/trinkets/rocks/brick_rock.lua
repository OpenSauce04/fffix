local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Currently unused
--[[function mod:brickRockFire(player, tear, rng, pdata, tdata)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK) then
        tear.Variant = TearVariant.STONE
        tear:GetSprite():Load("gfx/projectiles/fortune_cookie_tear.anm2", true)
        tear.CollisionDamage = 15
        tear.Velocity = tear.Velocity*1.3
        player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK)
        tdata.IsBrickTear = true
        tdata.customtype = "brick"
    end
end]]

function mod:spawnBrickTrinket(tear)
    if not game:IsPaused() then 
		sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.6, 0, false, 1.5)
	end
	if tear.Child and tear.Child:Exists() then
		tear.Child:Remove()
		tear.Child = nil
	end
    local brick = Isaac.Spawn(5, 350, FiendFolio.ITEM.ROCK.BRICK_ROCK + tear.SubType, tear.Position, tear.Velocity:Resized(5):Rotated(120 + math.random(120)), tear):ToPickup()
    brick:GetSprite():Play("Appear")
    brick:GetSprite():SetFrame(7)
	brick.Touched = true
end

function mod:brickRockUpdate(tear, tdata)
    --[[if tear:IsDead() and tdata.IsBrickTear then
        mod:spawnBrickTrinket(tear)
    end]]--
	if tdata.IsBrickTear and tear.SubType == TrinketType.TRINKET_GOLDEN_FLAG then
		tdata.sparkleCooldown = (tdata.sparkleCooldown or math.random(3) + 3) - 1
		if tdata.sparkleCooldown <= 0 then
			local expvec = (Vector.FromAngle(tear.Velocity:GetAngleDegrees() - 180) * math.random(10,20)):Rotated(math.random(-30,30))
			local sparkle = Isaac.Spawn(1000, 1727, 0, tear.Position + expvec * 0.1, expvec * 0.3, tear):ToEffect()
			sparkle.SpriteOffset = Vector(0,-15)
			sparkle:Update()
			
			tdata.sparkleCooldown = nil
		end
	end
end

--[[function mod:brickRockColl(tear, ent, tdata)
    if tdata.IsBrickTear then
        mod:spawnBrickTrinket(tear)
    end
end]]--

function mod:brickRockPlayer(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK) then
        player.FireDelay = player.MaxFireDelay
        local aim = player:GetAimDirection()
        if mod:canUseDrawnItem(player, mod.DrawnItemTypes.BrickRock, aim) then
			player:GetData().FFdrawnItemCooldown = player.MaxFireDelay
			
			local multiSub = 0
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
				multiSub = 1
			end
			
			local multiBefore = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.BRICK_ROCK)
			multiBefore = math.max(0, multiBefore - multiSub)
			
			if multiBefore == 1 then
				player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK)
			else
				player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK + TrinketType.TRINKET_GOLDEN_FLAG)
			end
			local multiAfter = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.BRICK_ROCK)
			multiAfter = math.max(0, multiAfter - multiSub)
			
			local isGolden = (multiBefore - multiAfter) == 2
			local tearsub = 0
			if isGolden then
				tearsub = TrinketType.TRINKET_GOLDEN_FLAG
			end
		
            local vec = player:GetAimDirection():Resized(player.ShotSpeed * 13) + player:GetTearMovementInheritance(aim)
            local tear = Isaac.Spawn(2, TearVariant.BRICK, tearsub, player.Position, vec, player):ToTear()
            tear.SpawnerEntity = player
            --tear:GetSprite():Load("gfx/projectiles/brick_rock.anm2", true)
            --tear:GetSprite():Play("Stone1Move", true)
            tear.CollisionDamage = 15
			if isGolden then
				tear.CollisionDamage = 30
			end
            tear.TearFlags = tear.TearFlags | TearFlags.TEAR_CONFUSION
            local tdata = tear:GetData()
            tdata.IsBrickTear = true
            tdata.customtype = "brick"
            --sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, math.random(70,80)/100)
			
			local brickGfx
			brickGfx = Isaac.Spawn(5, 350, FiendFolio.ITEM.ROCK.BRICK_ROCK + tear.SubType, tear.Position, nilvector, player):ToPickup()
			brickGfx.Parent = tear
			brickGfx.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			brickGfx.Visible = false
			brickGfx:GetData().BrickFollowParent = true
            brickGfx:GetSprite():Load("gfx/projectiles/brick_rock.anm2", true)
            brickGfx:GetSprite():Play("Stone1Move", true)
			tear.Child = brickGfx
        end
    end

    local queuedItem = player.QueuedItem
    if queuedItem.Item and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.BRICK_ROCK then
        player:AnimateTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK, "HideItem", "PlayerPickup")
        player:FlushQueueItem()
        player:Update()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, trinket)
	if trinket.SubType % TrinketType.TRINKET_GOLDEN_FLAG == FiendFolio.ITEM.ROCK.BRICK_ROCK and trinket:GetData().BrickFollowParent then
		trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		trinket.Visible = false
		trinket.Velocity = nilvector
		
		if trinket.Parent and trinket.Parent:Exists() then
			trinket.Position = trinket.Parent.Position
		else
			trinket:Remove()
		end
	elseif trinket.SubType == FiendFolio.ITEM.ROCK.BRICK_ROCK + TrinketType.TRINKET_GOLDEN_FLAG and Isaac.GetChallenge() == mod.challenges.brickByBrick then
		local player = Isaac.GetPlayer(0)
		local speed = 1
		if game:GetRoom():IsClear() then speed = 3 end
		trinket.Velocity = (player.Position - trinket.Position):Resized(speed)
		trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	elseif trinket.SubType == FiendFolio.ITEM.ROCK.BRICK_ROCK and Isaac.GetChallenge() == mod.challenges.brickByBrick then
		local player = Isaac.GetPlayer(0)
		local speed = 2.5
		if game:GetRoom():IsClear() then speed = 3 end
		trinket.Velocity = (player.Position - trinket.Position):Resized(speed)
		trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	end
end, 350)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, trinket, collider, low)
	if trinket.SubType % TrinketType.TRINKET_GOLDEN_FLAG == FiendFolio.ITEM.ROCK.BRICK_ROCK and
	   not trinket:GetData().IsGfxBrick and
	   trinket.Touched and
	   collider.Type == EntityType.ENTITY_PLAYER and
	   collider.Variant == 0
	then
		local player = collider:ToPlayer()
		local data = player:GetData().ffsavedata

		if player.Parent == nil and -- Strawman and Soulstones
		   not player:IsCoopGhost() and
		   player:IsExtraAnimationFinished()
		then
			-- Bypass streak text; fake pickup behaviour time
			local t0 = player:GetTrinket(0)
			local t1 = player:GetTrinket(1)
			
			if t0 ~= 0 and t1 ~= 0 then
				player:DropTrinket(player.Position, true)
			end
			
			player:AddTrinket(trinket.SubType)
			player:AnimateTrinket(FiendFolio.ITEM.ROCK.BRICK_ROCK, "HideItem", "PlayerPickup")
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1, 0)
			
			trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			trinket.Visible = false
			trinket:Remove()
		end

		return false
	end
end, PickupVariant.PICKUP_TRINKET)
