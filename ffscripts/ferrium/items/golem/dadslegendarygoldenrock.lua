local mod = FiendFolio
local game = Game()

function mod:dadsLegendaryGoldenRockSwap(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK) then
		for i=0,1 do
			if player:GetTrinket(i) == FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK and player:GetTrinket(i) < 32768 then
				player:TryRemoveTrinket(player:GetTrinket(i))
				player:AddTrinket(FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK+32768)
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, trinket)
	if trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK then
		local sprite = trinket:GetSprite()
		if trinket.SubType < 32768 then
			Isaac.Spawn(5, 350, FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK+32768, trinket.Position, trinket.Velocity, nil)
			trinket:Remove()
		end
		
		if game:GetFrameCount() % 15 == 0 then
			local sparkle = Isaac.Spawn(1000, 1727, 0, trinket.Position+Vector(math.random(-10,10),math.random(-10,10)), Vector.Zero, trinket):ToEffect()
			sparkle.SpriteOffset = Vector(0,-7)
			sparkle.SpriteScale = Vector(0.8, 0.8)
			sparkle:SetColor(Color(1,1,1,1,1,1,0), 100, 1, false, false)
			sparkle:Update()
		end
	end
end, PickupVariant.PICKUP_TRINKET)