local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() and not pickup.Touched then
		local player = opp:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEETROCK) then
			local mult = math.floor(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEETROCK))
			local bedrock = false
			if player:HasTrinket(FiendFolio.ITEM.ROCK.BEDROCK) then
				bedrock = true
				mult = mult+1
			end
			local canPickup = false
			if player:GetMaxHearts() == 0 then
				canPickup = true
			elseif player:CanPickRedHearts() then
				canPickup = true
			end
			
			if canPickup == true then
				player:AddSoulHearts(2+mult*2)
				if bedrock == true then
					player:UseCard(Card.CARD_HOLY, 257)
				end
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1)
			end
		end
	end
end, 380)

function mod:bedsheetNewLevel()
	if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.BEDROCK, true) and game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then
		local mult = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.ROCK.BEDROCK)
		local rng = RNG()
		local seed = game:GetRoom():GetSpawnSeed()
        rng:SetSeed(seed, 0)
		if rng:RandomInt(100) < 33*mult then
			Isaac.Spawn(5, 380, 0, Vector(102, 345), Vector.Zero, nil)
		end
	end
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SHEETROCK) then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SHEETROCK)
			player:AddHearts(2+math.floor(mult*2))
			sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
			local poof = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, player):ToEffect()
			poof.SpriteOffset = Vector(0,-45)
			poof:FollowParent(player)
			poof:Update()
		end
	end
end