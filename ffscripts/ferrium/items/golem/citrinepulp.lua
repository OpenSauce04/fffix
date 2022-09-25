local mod = FiendFolio
local sfx = SFXManager()

function mod:citrinePulpUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CITRINE_PULP) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CITRINE_PULP)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CITRINE_PULP)
		local HELP = 0
		for _,entity in ipairs(Isaac.FindInRadius(player.Position, 45, EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() then
				HELP = HELP+1
			end
		end
		
		if not data.citrineTimer then
			data.citrineTimer = 0
		end
		
		if data.citrineTimer > 0 then
			data.citrineTimer = data.citrineTimer-1
		elseif HELP > 0 then
			if rng:RandomInt(40-math.min(10,HELP)) == 0 then
				sfx:Play(SoundEffect.SOUND_GASCAN_POUR, 0.8, 0, false, 2)
				local piss = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_LEMON_MISHAP, 0, player.Position, Vector.Zero, player):ToEffect()
				local pisscolor = Color(1,0.72,1,1,0,0,0)
				piss.Color = pisscolor
				piss.CollisionDamage = player.Damage
				piss:Update()
				data.citrineTimer = 400
			end
		end
	end
end

function mod:fireCitrine(player, dir)
	local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CITRINE_PULP)
	local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CITRINE_PULP)
	local chance = math.min(50,10+10*mult+player.Luck*2)
	
	if rng:RandomInt(100) < chance then
		for i=1,5+math.min(mult*2, 10) do
			local newtear = Isaac.Spawn(2, 0, 0, player.Position, dir:Rotated(math.random(-40,40)):Resized(math.random(50,90)/10), player):ToTear()
			local scalecalc = math.random(30,60) / 100
			newtear.Scale = scalecalc
			newtear.FallingSpeed = -5 - math.random(15)
			newtear.FallingAcceleration = 1.1 + (math.random() * 0.5)
			newtear.Height = -10
			newtear.CanTriggerStreakEnd = false
			newtear.Color = Color(2,5,0.4,1,0.1,0,0)
			newtear:GetData().DMG = player.Damage * 0.3
			newtear.CollisionDamage = mod:LuaRound(scalecalc, 1)
			newtear:Update()
		end
	end
end