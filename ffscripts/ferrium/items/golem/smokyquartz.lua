local mod = FiendFolio

function mod:smokyQuartzUpdate(player, data)
	if data.smokyQuartzSpeed then
		if data.smokyQuartzSpeed > 0 then
			data.smokyQuartzSpeed = data.smokyQuartzSpeed-0.008
		else
			data.smokyQuartzSpeed = nil
		end
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
	end
end

function mod:smokyQuartzHurt(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SMOKY_QUARTZ) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SMOKY_QUARTZ)
		local range = math.ceil(60+40*mult)
		for _, enemy in ipairs(Isaac.FindInRadius(player.Position, range, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and (not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				--enemy:inflictBLINDED(when it exists)
				enemy:AddConfusion(EntityRef(player), 200, false)
			end
		end
		player:GetData().smokyQuartzSpeed = 2-player.MoveSpeed
		local cloud1 = Isaac.Spawn(1000, 16, 1, player.Position, Vector.Zero, player):ToEffect()
		cloud1.Color = Color(0.1,0.1,0.1,1,0,0,0)
		for i=1,4 do
			local cloud = Isaac.Spawn(1000, 59, 0, player.Position, RandomVector()*math.random(30,70)/10, player):ToEffect()
			cloud.Color = Color(0.1,0.1,0.1,1,0,0,0)
			cloud:SetTimeout(40)
			local size = math.random(80,120)/100
			cloud.SpriteScale = Vector(size, size)
		end
		SFXManager():Play(SoundEffect.SOUND_BLACK_POOF, 1, 0, false, 1)
	end
end