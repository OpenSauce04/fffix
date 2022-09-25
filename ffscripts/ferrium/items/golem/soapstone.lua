local mod = FiendFolio

function mod:soapStoneHurt(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SOAP_STONE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SOAP_STONE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SOAP_STONE)
		for _,proj in ipairs(Isaac.FindByType(9,-1,-1,false,true)) do
			proj:Die()
		end
		
		mod.scheduleForUpdate(function()
			for i=1,3+mult do
				local velocity = Vector(0,math.max(0.2, rng:RandomInt(8)/3)):Rotated(rng:RandomInt(360))
				velocity = velocity + player:GetTearMovementInheritance(velocity)
				local bubble = Isaac.Spawn(150, 1, 0, player.Position, velocity, player)
				bubble:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
				bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				bubble:Update()
				bubble:GetSprite():Load("gfx/projectiles/bubble/bubble_tiny_friendly.anm2", true)
				bubble:GetSprite():Play("Idle", true)
				bubble:GetSprite():LoadGraphics()
			end
		end, 3)
	end
end