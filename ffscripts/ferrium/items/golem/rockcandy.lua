local mod = FiendFolio
local game = Game()

function mod:rockCandyUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
    	for _, n in pairs(Isaac.GetRoomEntities()) do
    		if n:IsEnemy() and 
			   n:IsDead() and 
			   not (n:GetData().CheckedRockCandy or  
			        (n.Type == mod.FFID.Tech and n.Variant > 999)) 
			then
				local room = game:GetRoom()
    			if n:GetDropRNG():RandomInt(100) < math.min(15*mult+player.Luck, 40) then
					local rockCandy = Isaac.Spawn(5, 10, 2, n.Position, Vector.Zero, player):ToPickup()
					rockCandy.Timeout = math.floor(40+mult*20)
					rockCandy:Update()
					rockCandy:GetSprite():ReplaceSpritesheet(0, "gfx/items/pick ups/rockcandy_heart.png")
					rockCandy:GetSprite():LoadGraphics()
    			end
    			n:GetData().CheckedRockCandy = true
    		end
    	end
    end
end

function mod:rockCandyOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local data = tear:GetData()
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			tear.CollisionDamage = tear.CollisionDamage * 1.5
			local sprite = tear:GetSprite()
			--local size = string.sub(sprite:GetAnimation(),-1,-1)
			tear.Variant = TearVariant.DIAMOND
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_CHARM
			sprite:Load("gfx/002.018_diamond tear.anm2")
			--sprite:ReplaceSpritesheet(0, "gfx/projectiles/rockCandy_tear.png")
			local color = Color(1.5,1.5,1.5,1,0,0,0)
			color:SetColorize(5,0.5,0.5,1)
			tear.Color = color
			
			sprite:LoadGraphics()
		end
	end
end

function mod:rockCandyOnKnifeDamage(player, entity, secondHandMultiplier, damage)
	local returndata = {}
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			entity:AddCharmed(EntityRef(player), 180 * secondHandMultiplier, false)
			returndata.newDamage = damage*1.5
			returndata.sendNewDamage = true
		end
	end
	return returndata
end

function mod:rockCandyOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local data = bomb:GetData()
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			bomb.ExplosionDamage = bomb.ExplosionDamage * 1.5
			--Remove Confusion and add Blind once that is finished
			--data.ApplyBlind = true
			--data.ApplyBlindDuration = 180 * secondHandMultiplier
			bomb.Flags = bomb.Flags | TearFlags.TEAR_CHARM
			
			local color = Color(1.5,1.5,1.5,1,0,0,0)
			color:SetColorize(1.3,0.7,0.7,1)
			bomb.Color = color
		end
	end
end

function mod:rockCandyOnLaserDamage(player, entity, secondHandMultiplier, damage)
	local returndata = {}
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			entity:AddCharmed(EntityRef(player), 180 * secondHandMultiplier, false)
			returndata.newDamage = damage * 1.5
			returndata.sendNewDamage = true
		end
	end
	return returndata
end

function mod:rockCandyOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			data.ApplyCharm = true
			data.ApplyCharmDuration = 180 * secondHandMultiplier
			data.RockCandyMultiplier = 1.5
			
			local color = Color(1.5,1.5,1.5,1,0,0,0)
			color:SetColorize(1.3,0.7,0.7,1)
			data.FFAquariusColor = color
		end
	end
end

function mod:rockCandyOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			local data = target:GetData()
			data.ApplyCharm = true
			data.ApplyCharmDuration = 180 * secondHandMultiplier
			data.RockCandyMultiplier = 1.5
			
			local color = Color(1.5,1.5,1.5,1,0,0,0)
			color:SetColorize(1.3,0.7,0.7,1)
			data.FFExplosionColor = color
		end
	end
end

function mod:rockCandyOnDarkArtsDamage(player, entity, secondHandMultiplier, damage)
	local returndata = {}
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_CANDY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_CANDY)
		local chance = 5+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			entity:AddCharmed(EntityRef(player), 180 * secondHandMultiplier, false)
			returndata.newDamage = damage * 1.5
			returndata.sendNewDamage = true
		end
	end
	return returndata
end

function mod:charmOnApply(entity, source, data)
	if data.ApplyCharm then
		entity:AddCharmed(EntityRef(source.Entity.SpawnerEntity), data.ApplyCharmDuration)
	end
end