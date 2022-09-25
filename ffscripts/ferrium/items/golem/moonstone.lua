local mod = FiendFolio
local game = Game()

function mod:moonstoneNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:GetData().ffsavedata.RunEffects.moonstoneRooms then
			player:GetData().ffsavedata.RunEffects.moonstoneRooms = {}
		end
	end
end

function mod:moonstoneNewRoom()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType == 7 or roomType == 8 or roomType == 29 then
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i-1)
			if player:HasTrinket(FiendFolio.ITEM.ROCK.MOONSTONE) then
				local data = player:GetData().ffsavedata.RunEffects
				local index = level:GetCurrentRoomDesc().ListIndex
				local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MOONSTONE)
				local sfx = SFXManager()
				local mult = math.ceil(player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.MOONSTONE))
				if data.moonstoneRooms then
					local discovered = false
					for _,roomb in ipairs(data.moonstoneRooms) do
						if index == roomb then
							discovered = true
						end
					end
					if discovered == false then
						--sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.5, 0, false, 1)
						player:AnimateHappy()
						table.insert(data.moonstoneRooms, index)
						for i=1,mult do
							local num = rng:RandomInt(4)
							if num == 0 then
								data.moonstoneStats.luck = data.moonstoneStats.luck+1
							elseif num == 1 then
								data.moonstoneStats.tears = data.moonstoneStats.tears+1
							elseif num == 2 then
								data.moonstoneStats.range = data.moonstoneStats.range+1
							elseif num == 3 then
								data.moonstoneStats.shotSpeed = data.moonstoneStats.shotSpeed+1
							end
						end
						player:AddCacheFlags(CacheFlag.CACHE_ALL)
						player:EvaluateItems()
					end
				else
					data.moonstoneRooms = {}
					data.moonstoneStats = {["luck"] = 0, ["tears"] = 0, ["range"] = 0, ["shotSpeed"] = 0}
					--sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.5, 0, false, 1)
					player:AnimateHappy()
					table.insert(data.moonstoneRooms, index)
					for i=1,mult do
						local num = rng:RandomInt(4)
						if num == 0 then
							data.moonstoneStats.luck = data.moonstoneStats.luck+1
						elseif num == 1 then
							data.moonstoneStats.tears = data.moonstoneStats.tears+1
						elseif num == 2 then
							data.moonstoneStats.range = data.moonstoneStats.range+1
						elseif num == 3 then
							data.moonstoneStats.shotSpeed = data.moonstoneStats.shotSpeed+1
						end
					end
					player:AddCacheFlags(CacheFlag.CACHE_ALL)
					player:EvaluateItems()
				end
			end
		end
	end
end