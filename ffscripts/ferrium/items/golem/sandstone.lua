local mod = FiendFolio
local sfx = SFXManager()

function mod:sandstoneDamage(player, damage, flag, source)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)

		if flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1, 0, false, 1)
			local t0 = player:GetTrinket(0)
			local t1 = player:GetTrinket(1)

			if t1 > 0 then
				player:TryRemoveTrinket(t1)
			end
			if t0 > 0 then
				player:TryRemoveTrinket(t0)
			end
			local held = false
			if t0 == FiendFolio.ITEM.ROCK.SANDSTONE % 32768 or t1 == FiendFolio.ITEM.ROCK.SANDSTONE % 32768 then
				held = true
			end
			

			if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) and not held then --oh, so golden trinkets are just two normal trinkets hidden as one
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.SANDSTONE)
				player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.SANDSTONE)
				local newMult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.SANDSTONE)
				if mult-newMult == 1 then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND)
				else
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND + 32768)
				end
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false)
			end
			
			local removed = false
			if t0 > 0 then
				if t0 == FiendFolio.ITEM.ROCK.SANDSTONE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND)
					removed = true
				elseif t0 == FiendFolio.ITEM.ROCK.SANDSTONE + 32768 then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND + 32768)
					removed = true
				else
					player:AddTrinket(t0)
				end
			end
			if t1 > 0 then
				if removed then player:AddTrinket(t1)
				elseif t1 == FiendFolio.ITEM.ROCK.SANDSTONE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND)
				elseif t1 == FiendFolio.ITEM.ROCK.SANDSTONE + 32768 then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND + 32768)
				else
					player:AddTrinket(t1)
				end
			end
		end
	end
end

function mod:sandstoneOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local data = tear:GetData()
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			tear.CollisionDamage = tear.CollisionDamage * 4
			local sprite = tear:GetSprite()
			--local size = string.sub(sprite:GetAnimation(),-1,-1)
			--Remove Confusion and add Blind once that is finished
			--data.ApplyBlind = true
			--data.ApplyBlindDuration = 180 * secondHandMultiplier
			tear.Variant = 42
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SHRINK | TearFlags.TEAR_CONFUSION
			sprite:Load("gfx/002.042_rock tear.anm2")
			sprite:ReplaceSpritesheet(0, "gfx/projectiles/sandstone_tear.png")
			--sprite:Play("Rotate" .. size, true)
			sprite:LoadGraphics()
			tear.Scale = tear.Scale*1.5
		end
	end
end

function mod:sandstoneOnKnifeDamage(player, entity, secondHandMultiplier, currDamage)
	local returndata = {}
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			entity:AddConfusion(EntityRef(player), 180 * secondHandMultiplier, false)
			returndata.newDamage = currDamage * 2
			returndata.sendNewDamage = true
		end
	end
	return returndata
end

function mod:sandstoneOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local data = bomb:GetData()
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			bomb.ExplosionDamage = bomb.ExplosionDamage * 2
			--Remove Confusion and add Blind once that is finished
			--data.ApplyBlind = true
			--data.ApplyBlindDuration = 180 * secondHandMultiplier
			bomb.Flags = bomb.Flags | TearFlags.TEAR_CONFUSION
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 40/255, 40/255)
			color:SetColorize(0.5, 0.3, 0.2, 1)
			bomb.Color = color
		end
	end
end

function mod:sandstoneOnLaserDamage(player, entity, secondHandMultiplier, damage)
	local returndata = {}
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			entity:AddConfusion(EntityRef(player), 180 * secondHandMultiplier, false)
			returndata.newDamage = damage * 2
			returndata.sendNewDamage = true
		end
	end
	return returndata
end

function mod:sandstoneOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			--data.ApplyBlind = true
			--data.ApplyBlindDuration = 180 * secondHandMultiplier
			data.SandstoneMultiplier = 2
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 40/255, 40/255)
			color:SetColorize(0.5, 0.3, 0.2, 1)
			data.FFAquariusColor = color
		end
	end
end

function mod:sandstoneOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			local data = target:GetData()
			--data.ApplyBlind = true
			--data.ApplyBlindDuration = 180 * secondHandMultiplier
			data.SandstoneMultiplier = 2
			
			local color = Color(1.0, 1.0, 1.0, 1.0, 80/255, 40/255, 40/255)
			color:SetColorize(0.5, 0.3, 0.2, 1)
			data.FFExplosionColor = color
		end
	end
end

function mod:sandstoneOnDarkArtsDamage(player, entity, secondHandMultiplier, damage)
	local returndata = {}
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SANDSTONE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SANDSTONE)
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SANDSTONE)
		local chance = 10+10*mult+3*player.Luck

		if rng:RandomInt(100) < chance then
			entity:AddConfusion(EntityRef(player), 180 * secondHandMultiplier, false)
			returndata.newDamage = damage * 2
			returndata.sendNewDamage = true
		end
	end
	return returndata
end
