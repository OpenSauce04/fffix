local mod = FiendFolio
local game = Game()

function mod:cannedFossilDamage(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CANNED_FOSSIL) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CANNED_FOSSIL)
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CANNED_FOSSIL)
		local fartNum = rng:RandomInt(3)
		if fartNum == 0 then
			game:CharmFart(player.Position, 40+20*mult, player)
		elseif fartNum == 1 then
			game:ButterBeanFart(player.Position, 60+20*mult, player, true, true)
		elseif fartNum == 2 then
			game:Fart(player.Position, 50+20*mult, player, 1, 0, Color.Default)
		end
	end
end