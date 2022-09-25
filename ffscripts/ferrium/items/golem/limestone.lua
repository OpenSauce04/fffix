local mod = FiendFolio
local game = Game()

function mod:limestoneUpdate(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.LIMESTONE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.LIMESTONE)
		if player.FrameCount % 3 == 0 then
			local creep = Isaac.Spawn(1000, 46, 0, player.Position, Vector.Zero, player):ToEffect()
			creep.Color = Color(0,1,1,1,0,math.random(18,30)/100,0)
			creep.CollisionDamage = mult*player.Damage/2
			creep.SpriteScale = Vector(0.7,0.7)
		end
		
		for _,ent in ipairs(Isaac.FindByType(25, 962, -1, false, true)) do --Warhead
			ent:AddCharmed(EntityRef(player), -1)
		end
		
		for _,ent in ipairs(Isaac.FindByType(29, 962, -1, false, true)) do --Heads
			ent:AddCharmed(EntityRef(player), -1)
		end
		
		for _,ent in ipairs(Isaac.FindByType(160, 360, -1, false, true)) do --Full
			ent:AddCharmed(EntityRef(player), -1)
		end
		
		for _,ent in ipairs(Isaac.FindByType(160, 361, -1, false, true)) do --Bodies
			ent:AddCharmed(EntityRef(player), -1)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_,t,v,s, index, seed, seed)
	if t == 160 and v == 360 and s == 0 then
		for i = 1, game:GetNumPlayers() do
			local p = Isaac.GetPlayer(i - 1)
			if p:HasTrinket(FiendFolio.ITEM.ROCK.LIMESTONE) then
				local rng = p:GetTrinketRNG(FiendFolio.ITEM.ROCK.LIMESTONE)
				local mult = mod.GetGolemTrinketPower(p, FiendFolio.ITEM.ROCK.LIMESTONE)
				local chance = 33*mult
				
				if rng:RandomInt(100) < chance then
					return {160, 360, 1}
				end
			end
		end
	elseif t == 160 and v == 361 and s == 0 then
		for i = 1, game:GetNumPlayers() do
			local p = Isaac.GetPlayer(i - 1)
			if p:HasTrinket(FiendFolio.ITEM.ROCK.LIMESTONE) then
				local rng = p:GetTrinketRNG(FiendFolio.ITEM.ROCK.LIMESTONE)
				local mult = mod.GetGolemTrinketPower(p, FiendFolio.ITEM.ROCK.LIMESTONE)
				local chance = 33*mult
				
				if rng:RandomInt(100) < chance then
					return {160, 361, 1}
				end
			end
		end
	elseif t == 29 and v == 962 and s == 0 then
		for i = 1, game:GetNumPlayers() do
			local p = Isaac.GetPlayer(i - 1)
			if p:HasTrinket(FiendFolio.ITEM.ROCK.LIMESTONE) then
				local rng = p:GetTrinketRNG(FiendFolio.ITEM.ROCK.LIMESTONE)
				local mult = mod.GetGolemTrinketPower(p, FiendFolio.ITEM.ROCK.LIMESTONE)
				local chance = 33*mult
				
				if rng:RandomInt(100) < chance then
					return {29, 962, 1}
				end
			end
		end
	end
end)