local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.NECROMANTIC_FOSSIL) then
			if not (npc.Type == mod.FFID.Tech and npc.Variant > 999) then
				local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.NECROMANTIC_FOSSIL)
				local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.NECROMANTIC_FOSSIL)
				local chance = (0.2*mult+mod.XalumLuckBonus(player.Luck, 20, 0.2))*100
				
				if rng:RandomInt(100) < chance then
					local bone = Isaac.Spawn(3, 128, 0, npc.Position, Vector.Zero, player):ToFamiliar()
					bone.Player = player
					bone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.5, 0, false, 2)
					
					for i=1,3 do
						local toothPart = Isaac.Spawn(1000, 35, 0, npc.Position, RandomVector()*math.random(1,5), nil)
					end
				end
			end
		end
	end
end)