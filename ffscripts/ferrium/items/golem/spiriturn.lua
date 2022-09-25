local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:spiritUrnUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SPIRIT_URN) then
		local room = game:GetRoom()
		if room:IsAmbushActive() and not data.spiritUrnChallenge then
			data.spiritUrnChallenge = true
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SPIRIT_URN)
			for i=1,2+mult do
				player:AddWisp(0, player.Position, true, false)
			end
			sfx:Play(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, 3)
		end
	end
end

function mod:spiritUrnNewRoom(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SPIRIT_URN) then
		local room = game:GetRoom()
		local rType = room:GetType()
		if (rType == RoomType.ROOM_BOSS or rType == RoomType.ROOM_MINIBOSS) and room:IsFirstVisit() then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SPIRIT_URN)
			mod.scheduleForUpdate(function()
				for i=1,2+mult do
					player:AddWisp(0, player.Position, true, false)
				end
				sfx:Play(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, 3)
			end, 1)
		end
	end
	if player:GetData().spiritUrnChallenge then
		player:GetData().spiritUrnChallenge = nil
	end
end