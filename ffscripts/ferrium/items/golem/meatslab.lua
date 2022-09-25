local mod = FiendFolio

function mod:meatSlabUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.MEAT_SLAB) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MEAT_SLAB)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MEAT_SLAB)
		local heartNum = player:GetMaxHearts()/(player:GetHearts() + player:GetSoulHearts())
		local frames = math.floor(17-math.min(13, heartNum))

		if player.FrameCount % frames == 0 then
			local newtear = Isaac.Spawn(2, 0, 0, player.Position, Vector(0,1+rng:RandomInt(15)/3):Rotated(rng:RandomInt(360)), player):ToTear()
			newtear.FallingSpeed = -8 - rng:RandomInt(20)
			newtear.FallingAcceleration = 1.1
			newtear.Height = -10
			newtear.CanTriggerStreakEnd = false
			newtear.CollisionDamage = player.Damage*mult
			newtear.Scale = math.min(2.5, player.Damage*mult/5.5)
			newtear:GetData().dontCollideBombs = true
			newtear:Update()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, coll)
	if coll.Type == 4 and tear:GetData().dontCollideBombs then
		return true
	end
end)