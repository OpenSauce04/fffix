local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:vinylGeodeNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		local level = game:GetLevel()
		local stage = level:GetAbsoluteStage()
		
		local t0 = player:GetTrinket(0)
        local t1 = player:GetTrinket(1)
		
		local held = false
		if (t0 == FiendFolio.ITEM.ROCK.VINYL_GEODE_A % 32768 or t1 == FiendFolio.ITEM.ROCK.VINYL_GEODE_A % 32768) or (t0 == FiendFolio.ITEM.ROCK.VINYL_GEODE_B % 32768 or t1 == FiendFolio.ITEM.ROCK.VINYL_GEODE_B % 32768) then
			held = true
		end
		
		if held then
			local switchA = false
			local switchB = false
			if stage < 10 then
				if stage % 2 == 1 then
					switchA = true
				else
					switchB = true
				end
			elseif stage == 10 or stage == 12 or stage == 13 then
				switchA = true
			elseif stage == 11 then
				switchB = true
			end
			
			local switched = false
			if switchA then
				if t0 == FiendFolio.ITEM.ROCK.VINYL_GEODE_A % 32768 then
					if t1 > 0 then
						player:TryRemoveTrinket(t1)
					end
					player:TryRemoveTrinket(t0)
					if mod:IsGoldTrinket(t0) then
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_B + 32768)
						if t1 > 0 then
							player:AddTrinket(t1)
						end
					else
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_B)
						if t1 > 0 then
							player:AddTrinket(t1)
						end
					end
					switched = true
				elseif t1 == FiendFolio.ITEM.ROCK.VINYL_GEODE_A % 32768 then
					player:TryRemoveTrinket(t1)
					if mod:IsGoldTrinket(t1) then
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_B + 32768)
					else
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_B)
					end
					switched = true
				end
			elseif switchB then
				if t0 == FiendFolio.ITEM.ROCK.VINYL_GEODE_B % 32768 then
					if t1 > 0 then
						player:TryRemoveTrinket(t1)
					end
					player:TryRemoveTrinket(t0)
					if mod:IsGoldTrinket(t0) then
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_A + 32768)
						if t1 > 0 then
							player:AddTrinket(t1)
						end
					else
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_A)
						if t1 > 0 then
							player:AddTrinket(t1)
						end
					end
					switched = true
				elseif t1 == FiendFolio.ITEM.ROCK.VINYL_GEODE_B % 32768 then
					player:TryRemoveTrinket(t1)
					if mod:IsGoldTrinket(t1) then
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_A + 32768)
					else
						player:AddTrinket(FiendFolio.ITEM.ROCK.VINYL_GEODE_A)
					end
					switched = true
				end
			end
			if switched == true then
				mod.scheduleForUpdate(function()
					sfx:Play(mod.Sounds.RecordScratch, 0.3, 0, false, 1)
				end, 1)
			end
		end
	end
end