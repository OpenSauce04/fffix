local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:rockFromAnAbyssNewRoom()
	mod.scheduleForUpdate(function()
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(FiendFolio.ITEM.ROCK.ROCK_FROM_AN_ABYSS) then
				local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROCK_FROM_AN_ABYSS)
				local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ROCK_FROM_AN_ABYSS)
				local chance = (20+3*player.Luck)*mult
				
				if rng:RandomInt(100) < chance then
					local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
					local enemies = {}
					for _,entity in ipairs(Isaac.FindInRadius(player.Position, 1050, EntityPartition.ENEMY)) do
						local entity = entity:ToNPC()
						if (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) and entity:IsActiveEnemy() then
							table.insert(enemies, entity)
						end
					end
					local cursedEnemy = false
					for i=1,3 do
						if #enemies > 0 then
							cursedEnemy = true
							local chosen = rng:RandomInt(#enemies)+1
							mod.AddDoom(enemies[chosen], player, 300 * secondHandMultiplier, 3, player.Damage*5)
							enemies[chosen]:GetData().rockFromAnAbyss = 10
							local aura = Isaac.Spawn(1000, 123, 8, enemies[chosen].Position, Vector.Zero, nil):ToEffect()
							aura.SpriteScale = Vector(0.5,0.5)
							local aura = Isaac.Spawn(1000, 123, 8, enemies[chosen].Position, Vector.Zero, nil):ToEffect()
							aura.SpriteScale = Vector(1,1)
							table.remove(enemies, chosen)
						end
					end
					if cursedEnemy == true then
						sfx:Play(SoundEffect.SOUND_DOGMA_BLACKHOLE_OPEN, 0.5, 0, false, 2)
					end
				end
			end
		end
	end, 1)
end

--[[mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	local data = npc:GetData()
	
	if data.rockFromAnAbyss then
		if data.rockFromAnAbyss > 0 then
			data.rockFromAnAbyss = data.rockFromAnAbyss-1
			npc.Color = Color.Lerp(npc.Color, Color(0,0,0,1,0,0,0), 0.05)
			if data.rockFromAnAbyss == 0 then
				npc.Color = Color(0.6,0.6,0.6,1,0,0,0)
			end
		else
			npc.Color = Color(1,1,1,1,0,0,0)
			data.rockFromAnAbyss = nil
		end
	end
end)]]