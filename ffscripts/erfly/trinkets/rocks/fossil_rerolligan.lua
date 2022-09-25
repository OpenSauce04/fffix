local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:updateRerolliganFossilLaserColor(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(3.5, 2.3, 1.5, 1)
		player.LaserColor = lasercolor
	end
end

function mod:rerolliganFossilFire(player, tear, rng, pdata, tdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if rng:RandomInt(50) < chance then
            mod:changeTearVariant(tear, TearVariant.D10)
            tdata.isRerolliganTear = true
        end
    end
end

function mod:rerolliganFossilFireBomb(player, bomb, rng, pdata, bdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if rng:RandomInt(50) < chance then
            bdata.isRerolliganTear = true
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 50/255, 30/255, 10/255)
			color:SetColorize(0.7, 0.45, 0.35, 1)
			bomb.Color = color
        end
    end
end

--[[function mod:rerolliganFossilFireKnife(player, knife, rng, pdata, kdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if math.random(50) < chance then
            kdata.isRerolliganTearDelayTilFired = true
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 50/255, 30/255, 10/255)
			color:SetColorize(0.7, 0.45, 0.35, 1)
			kdata.KnifeColor = color
        end
    end
end]]--

function mod:rerolliganFossilFireAquarius(player, creep, rng, pdata, cdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if rng:RandomInt(50) < chance then
            cdata.isRerolliganTear = true

			local color = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
			color:SetColorize(3.5, 2.3, 1.5, 1)
			cdata.FFAquariusColor = color
        end
    end
end

function mod:rerolliganFossilFireRocket(player, target, rng, pdata, tdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if rng:RandomInt(50) < chance then
            tdata.isRerolliganTear = true

			local color = Color(1.0, 1.0, 1.0, 1.0, 50/255, 30/255, 10/255)
			color:SetColorize(0.7, 0.45, 0.35, 1)
			tdata.FFExplosionColor = color
        end
    end
end

--[[function mod:rerolliganFossilColl(tear, ent, tdata)
    if tdata.isRerolliganTear then
        if ent:ToNPC():CanReroll() and 
		   ent.Type ~= EntityType.ENTITY_FROZEN_ENEMY and 
		   (tdata.lastRerolliganFrame == nil or game:GetFrameCount() - tdata.lastRerolliganFrame >= 60)
		then
            game:RerollEnemy(ent)
            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1)
            tdata.denySound = true
			
			if tear:HasTearFlags(BitSet128(0, 1 << (127 - 64))) then -- Ludo
				tdata.lastRerolliganFrame = game:GetFrameCount()
			end
        end
        
		if not tear:HasTearFlags(BitSet128(0, 1 << (127 - 64))) then -- Ludo
			tear:Die()
		end
    end
end]]--

local checkingForRerolledEnt = false
local rerolledEnt = nil
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	if checkingForRerolledEnt then
		rerolledEnt = npc
		checkingForRerolledEnt = false
	end
end)

function mod:rerolliganFossilDamage(ent, source, sdata)
	local returnval = false
	if sdata.isRerolliganTear then
		local edata = ent:GetData()

		if ent:ToNPC():CanReroll() and 
		   ent.Type ~= EntityType.ENTITY_FROZEN_ENEMY and
		   (edata.lastRerolliganFrame == nil or game:GetFrameCount() - edata.lastRerolliganFrame >= 60)
		then
			checkingForRerolledEnt = true
			game:RerollEnemy(ent)
            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1)
			checkingForRerolledEnt = false
			
			if rerolledEnt then
				rerolledEnt:GetData().lastRerolliganFrame = game:GetFrameCount()
				returnval = true
			end
			rerolledEnt = nil
			
			if source.Type == EntityType.ENTITY_TEAR and not source.Entity:ToTear():HasTearFlags(BitSet128(0, 1 << (127 - 64))) then -- Ludo
				sdata.denySound = true
				source.Entity:Die()
			end
		end
	end
	return returnval
end

function mod:rerolliganFossilOnKnifeDamage(player, ent)
	local returnval = false
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if math.random(50) < chance then
			local edata = ent:GetData()

			if ent:ToNPC():CanReroll() and 
			   ent.Type ~= EntityType.ENTITY_FROZEN_ENEMY and
			   (edata.lastRerolliganFrame == nil or game:GetFrameCount() - edata.lastRerolliganFrame >= 60)
			then
				checkingForRerolledEnt = true
				game:RerollEnemy(ent)
				sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1)
				checkingForRerolledEnt = false
				
				if rerolledEnt then
					rerolledEnt:GetData().lastRerolliganFrame = game:GetFrameCount()
					returnval = true
				end
				rerolledEnt = nil
			end
        end
    end
	return returnval
end

function mod:rerolliganFossilOnLaserDamage(player, ent)
	local returnval = false
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if math.random(50) < chance then
			local edata = ent:GetData()

			if ent:ToNPC():CanReroll() and 
			   ent.Type ~= EntityType.ENTITY_FROZEN_ENEMY and
			   (edata.lastRerolliganFrame == nil or game:GetFrameCount() - edata.lastRerolliganFrame >= 60)
			then
				checkingForRerolledEnt = true
				game:RerollEnemy(ent)
				sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1)
				checkingForRerolledEnt = false
				
				if rerolledEnt then
					rerolledEnt:GetData().lastRerolliganFrame = game:GetFrameCount()
					returnval = true
				end
				rerolledEnt = nil
			end
        end
    end
	return returnval
end

function mod:rerolliganFossilOnDarkArtsDamage(player, ent)
	local returnval = false
    if player:HasTrinket(FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        --print(chance)
        if math.random(50) < chance then
			local edata = ent:GetData()

			if ent:ToNPC():CanReroll() and 
			   ent.Type ~= EntityType.ENTITY_FROZEN_ENEMY and
			   (edata.lastRerolliganFrame == nil or game:GetFrameCount() - edata.lastRerolliganFrame >= 60)
			then
				checkingForRerolledEnt = true
				game:RerollEnemy(ent)
				sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1)
				checkingForRerolledEnt = false
				
				if rerolledEnt then
					rerolledEnt:GetData().lastRerolliganFrame = game:GetFrameCount()
					returnval = true
				end
				rerolledEnt = nil
			end
        end
    end
	return returnval
end

FiendFolio.FossilBreakEffects[FiendFolio.ITEM.ROCK.REROLLIGAN_FOSSIL] = function(player, spawner)
    Isaac.Spawn(5, 300, Card.GLASS_D10, spawner.Position, RandomVector() * 5, spawner)
    for i = 1, 2 do
        local r = spawner:GetDropRNG()
        local rand = r:RandomInt(#FiendFolio.GlassDice) + 1
        Isaac.Spawn(5, 300, FiendFolio.GlassDice[rand].id, spawner.Position, RandomVector() * 5, spawner)
    end
end