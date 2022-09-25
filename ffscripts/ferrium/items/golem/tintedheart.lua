local mod = FiendFolio
local sfx = SFXManager()

function mod:tintedHeartDamage(player, damage, flag, source)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TINTED_HEART) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.TINTED_HEART)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.TINTED_HEART)
		local heartInt = math.floor(mult)
		if flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
			if rng:RandomInt(100) < 15+20*mult then
				if rng:RandomInt(math.max(1, 5-math.floor(mult))) == 0 then
					Isaac.Spawn(5, 10, 3, player.Position, RandomVector()*3, player)
				else
					Isaac.Spawn(5, 10, 8, player.Position, RandomVector()*3, player)
				end
				local bonus = rng:RandomInt(5)
				if bonus == 0 or bonus == 1 then
					Isaac.Spawn(5, 30, 0, player.Position, RandomVector()*3, player)
				elseif bonus == 2 or bonus == 3 then
					Isaac.Spawn(5, 40, 0, player.Position, RandomVector()*3, player)
				else
					Isaac.Spawn(5, 50, 1, player.Position, RandomVector()*3, player)
				end
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6, 0, false, math.random(10,12)/10)
			end
		else
			if rng:RandomInt(100) < 10+10*mult then
				if rng:RandomInt(math.max(1, 4-math.floor(mult))) == 0 then
					Isaac.Spawn(5, 10, 1, player.Position, RandomVector()*3, player)
				else
					Isaac.Spawn(5, 10, 2, player.Position, RandomVector()*3, player)
				end
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6, 0, false, math.random(10,12)/10)
			end
		end
	end
end