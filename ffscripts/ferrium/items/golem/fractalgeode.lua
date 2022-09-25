local mod = FiendFolio

function mod:fractalGeodeOnFireTear(player, tear, secondHand, ludo, ignore)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end

        if rng:RandomInt(100) < chance and not ignore then
            local data = tear:GetData()
            if not ludo then
                data.fractalGeodeTear = true
                data.fractalInitialVel = tear.Velocity
                data.fractalRotatingVel = tear.Velocity
                data.fractalDir = 1-rng:RandomInt(2)*2
            end
            if sleep == true then
                data.ApplyDrowsy = true
                data.ApplyDrowsyDuration = 5
                data.ApplyDrowsySleepDuration = 180 * secondHand
                local color = Color(0.5, 0.5, 0.7, 1, 0.35, 0.4, 0.75)
                color:SetColorize(1, 1, 1, 1)
                tear.Color = color
            else
                data.ApplyDrowsy = true
			    data.ApplyDrowsyDuration = 60
			    data.ApplyDrowsySleepDuration = 180 * secondHand
                local color = Color(0.3, 0.3, 0.5, 1, 0.2, 0.3, 0.6)
                color:SetColorize(1, 1, 1, 1)
                tear.Color = color
            end
            tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
        end
	end
end

function mod.fractalTear(v, d)
    if d.fractalGeodeTear then
        v.Velocity = d.fractalInitialVel*0.3+d.fractalRotatingVel:Rotated(-15)*0.8
        d.fractalRotatingVel = d.fractalRotatingVel:Rotated(15*d.fractalDir)
        v.FallingSpeed = 0
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, trinket)
	if trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.FRACTAL_GEODE then
		local sprite = trinket:GetSprite()
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/fractal_geode.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
			else
				sprite:Play("Idle", true)
			end
			sprite:LoadGraphics()
			sprite:Update()
		end
	end
end, 350)

function mod:fractalGeodeOnFireBomb(player, bomb, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end

        if rng:RandomInt(100) < chance then
            local data = bomb:GetData()
            if sleep == true then
                data.ApplyDrowsy = true
                data.ApplyDrowsyDuration = 5
                data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
                local color = Color(0.5, 0.5, 0.7, 1, 0.35, 0.4, 0.75)
                color:SetColorize(1, 1, 1, 1)
                bomb.Color = color
            else
                data.ApplyDrowsy = true
			    data.ApplyDrowsyDuration = 60
			    data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
                local color = Color(0.3, 0.3, 0.5, 1, 0.2, 0.3, 0.6)
                color:SetColorize(1, 1, 1, 1)
                bomb.Color = color
            end
        end
	end
end

function mod:fractalGeodeOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end
		
		if rng:RandomInt(100) < chance then
            if sleep then
                mod.AddDrowsy(entity, player, 5, 180 * secondHandMultiplier)
            else
    			mod.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
            end
		end
	end
end

function mod:fractalGeodeOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end
		
		if rng:RandomInt(100) < chance then
            if sleep then
                mod.AddDrowsy(entity, player, 5, 180 * secondHandMultiplier)
            else
    			mod.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
            end
		end
	end
end

function mod:fractalGeodeOnFireAquarius(player, creep, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end
		
		if rng:RandomInt(100) < chance then
            local data = creep:GetData()
            data.ApplyDrowsy = true
            data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
            if sleep then
                data.ApplyDrowsyDuration = 5
                local color = Color(0.5, 0.5, 0.7, 1, 0.35, 0.4, 0.75)
                color:SetColorize(1, 1, 1, 1)
                data.FFAquariusColor = color
            else
    			data.ApplyDrowsyDuration = 60
                local color = Color(0.3, 0.3, 0.5, 1, 0.2, 0.3, 0.6)
                color:SetColorize(1, 1, 1, 1)
                data.FFAquariusColor = color
            end
		end
	end
end

function mod:fractalGeodeOnFireRocket(player, target, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end
		
		if rng:RandomInt(100) < chance then
            local data = target:GetData()
            data.ApplyDrowsy = true
            data.ApplyDrowsySleepDuration = 180 * secondHandMultiplier
            if sleep then
                data.ApplyDrowsyDuration = 5
                local color = Color(0.5, 0.5, 0.7, 1, 0.35, 0.4, 0.75)
                color:SetColorize(1, 1, 1, 1)
                data.FFExplosionColor = color
            else
    			data.ApplyDrowsyDuration = 60
                local color = Color(0.3, 0.3, 0.5, 1, 0.2, 0.3, 0.6)
                color:SetColorize(1, 1, 1, 1)
                data.FFExplosionColor = color
            end
		end
	end
end

function mod:fractalGeodeOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FRACTAL_GEODE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FRACTAL_GEODE)
        local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100
        local sleep

        if mod.HasTwoGeodes(player) then
            chance = chance+20
            if rng:RandomInt(2) == 0 then
                sleep = true
            end
        end
		
		if rng:RandomInt(100) < chance then
            if sleep then
                mod.AddDrowsy(entity, player, 5, 180 * secondHandMultiplier)
            else
    			mod.AddDrowsy(entity, player, 60, 180 * secondHandMultiplier)
            end
		end
	end
end
