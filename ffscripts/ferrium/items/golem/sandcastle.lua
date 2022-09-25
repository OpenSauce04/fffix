local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

function mod:sandCastleHurt(player, flag, source)
	if flag ~= flag | DamageFlag.DAMAGE_FAKE and flag ~= flag | DamageFlag.DAMAGE_NO_PENALTIES and flag ~= flag | DamageFlag.DAMAGE_IV_BAG and not (source and source.Type == EntityType.ENTITY_SLOT) then
		local data = player:GetData().ffsavedata.RunEffects
		local t0 = player:GetTrinket(0)
		local t1 = player:GetTrinket(1)
		local sandy = false
		
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE) then
			if t1 > 0 then
				player:TryRemoveTrinket(t1)
			end
			if t0 > 0 then
				player:TryRemoveTrinket(t0)
			end
			local held = false
			if t0 == FiendFolio.ITEM.ROCK.SAND_CASTLE % 32768 or t1 == FiendFolio.ITEM.ROCK.SAND_CASTLE % 32768 then
				held = true
			end
			
			if player:HasTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE) and not held then
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.SAND_CASTLE)
				for i=1,mult do --A bit sad if you have multiple, but prevents multiplying castles
					player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE)
				end
				player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false)
				sandy = true
			end
			
			local removed = false
			if t0 > 0 then
				if t0 == FiendFolio.ITEM.ROCK.SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
					removed = true
					sandy = true
				elseif t0 == FiendFolio.ITEM.ROCK.SAND_CASTLE + 32768 then
					if not data.goldCastle then
						data.goldCastle = true
						player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE + 32768)
					else
						data.goldCastle = nil
						player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768)
					end
					sandy = true
					removed = true
				else
					player:AddTrinket(t0)
				end
			end
			if t1 > 0 then
				if removed then player:AddTrinket(t1)
				elseif t1 == FiendFolio.ITEM.ROCK.SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
					sandy = true
				elseif t1 == FiendFolio.ITEM.ROCK.SAND_CASTLE + 32768 then
					if not data.goldCastle then
						data.goldCastle = true
						player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE + 32768)
					else
						data.goldCastle = nil
						player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768)
					end
					sandy = true
				else
					player:AddTrinket(t1)
				end
			end
		end
		
		if player:HasTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE) and not sandy then
			if t1 > 0 then
				player:TryRemoveTrinket(t1)
			end
			if t0 > 0 then
				player:TryRemoveTrinket(t0)
			end
			local held = false
			if t0 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE % 32768 or t1 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE % 32768 then
				held = true
			end
			
			if player:HasTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE) and not held then
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
				for i=1,mult do --A bit sad if you have multiple, but prevents multiplying castles
					player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
				end
				player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false)
				sandy = true
			end
			
			local removed = false
			if t0 > 0 then
				if t0 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
					removed = true
					sandy = true
				elseif t0 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768 then
					if not data.goldCastle then
						data.goldCastle = true
						player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768)
					else
						data.goldCastle = nil
						player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768)
					end
					removed = true
					sandy = true
				else
					player:AddTrinket(t0)
				end
			end
			if t1 > 0 then
				if removed then player:AddTrinket(t1)
				elseif t1 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
					sandy = true
				elseif t1 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768 then
					if not data.goldCastle then
						data.goldCastle = true
						player:AddTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768)
					else
						data.goldCastle = nil
						player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768)
					end
					sandy = true
				else
					player:AddTrinket(t1)
				end
			end
		end
		
		if player:HasTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE) and not sandy then
			if t1 > 0 then
				player:TryRemoveTrinket(t1)
			end
			if t0 > 0 then
				player:TryRemoveTrinket(t0)
			end
			local held = false
			if t0 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE % 32768 or t1 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE % 32768 then
				held = true
			end
			
			if player:HasTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE) and not held then
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
				for i=1,mult do --A bit sad if you have multiple, but prevents multiplying castles
					player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
				end
				player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false)
				sandy = true
			end
			
			local removed = false
			if t0 > 0 then
				if t0 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND)
					removed = true
					sandy = true
				elseif t0 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768 then
					if not data.goldCastle then
						data.goldCastle = true
						player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768)
					else
						data.goldCastle = nil
						player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND + 32768)
					end
					removed = true
					sandy = true
				else
					player:AddTrinket(t0)
				end
			end
			if t1 > 0 then
				if removed then player:AddTrinket(t1)
				elseif t1 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND)
					sandy = true
				elseif t1 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768 then
					if not data.goldCastle then
						data.goldCastle = true
						player:AddTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768)
					else
						data.goldCastle = nil
						player:AddTrinket(FiendFolio.ITEM.ROCK.POCKET_SAND + 32768)
					end
					sandy = true
				else
					player:AddTrinket(t1)
				end
			end
		end
		
		if sandy == true then
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1, 0, false, 1.7)
			for i=1,6 do 
				local sand = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 0, player.Position, RandomVector()*math.random(1,5), nil):ToEffect()
				sand.Color = Color(220/255, 180/255, 170/255, 1, 0, 0, 0)
			end
			player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM, -1)
			mod.scheduleForUpdate(function()
				if sfx:IsPlaying(mod.Sounds.FiendHurt) then
					sfx:Stop(mod.Sounds.FiendHurt)
				elseif sfx:IsPlaying(mod.Sounds.GolemHurt) then
					sfx:Stop(mod.Sounds.GolemHurt)
				end
				sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
			end, 0)
			return false
		end
	end
end

function mod:sandCastleNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:GetData().ffsavedata.RunEffects.goldCastle then
			player:GetData().ffsavedata.RunEffects.goldCastle = nil
		end
		if player:HasTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE) or player:HasTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE) then
			local t0 = player:GetTrinket(0)
			local t1 = player:GetTrinket(1)
			
			if t1 > 0 then
				player:TryRemoveTrinket(t1)
			end
			if t0 > 0 then
				player:TryRemoveTrinket(t0)
			end
			local held = false
			
			if player:HasTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE) or player:HasTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE) then
				local check = false
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
				for i=1,mult do --A bit sad if you have multiple, but prevents multiplying castles
					player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE)
					check = true
				end
				if check then
					player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE)
					player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM, -1)
				end
				check = false
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
				for i=1,mult do --A bit sad if you have multiple, but prevents multiplying castles
					player:TryRemoveTrinket(FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE)
					check = true
				end
				if check then
					player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE)
					player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM, -1)
				end
			end
			
			if t0 > 0 then
				if t0 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE or t0 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE)
				elseif t0 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768 or t0 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768 then
					player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE + 32768)
				else
					player:AddTrinket(t0)
				end
			end
			if t1 > 0 then
				if t1 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE or t1 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE then
					player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE)
				elseif t1 == FiendFolio.ITEM.ROCK.BROKEN_SAND_CASTLE + 32768 or t1 == FiendFolio.ITEM.ROCK.DAMAGED_SAND_CASTLE + 32768 then
					player:AddTrinket(FiendFolio.ITEM.ROCK.SAND_CASTLE + 32768)
				else
					player:AddTrinket(t1)
				end
			end
		end
	end
end