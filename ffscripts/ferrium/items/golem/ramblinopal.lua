local mod = FiendFolio
local sfx = SFXManager()

function mod:ramblinOpalUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.RAMBLIN_OPAL) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.RAMBLIN_OPAL)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.RAMBLIN_OPAL)
		if not data.opalTimer then
			data.opalTimer = 5
		end
		local totalShrooms = 0
		for _, shroom in ipairs(Isaac.FindByType(mod.FF.Shiitake.ID, mod.FF.Shiitake.Var, -1, false, false)) do
			if mod:isFriend(shroom) then
				local sData = shroom:GetData()
				if sData.ramblinOpal == true then
					totalShrooms = totalShrooms+1
				end
			end
		end
		for _, shroom in ipairs(Isaac.FindByType(mod.FF.FloatingSpore.ID, mod.FF.FloatingSpore.Var, -1, false, false)) do
			if mod:isFriend(shroom) then
				local sData = shroom:GetData()
				if sData.ramblinOpal == true then
					totalShrooms = totalShrooms+1
				end
			end
		end
		
		if data.opalTimer > 0 then
			data.opalTimer = data.opalTimer-1
		elseif rng:RandomInt(40) == 0 and totalShrooms < math.floor(2+mult) and mod.IsActiveRoom() then
			local poof = Isaac.Spawn(1000, 15, 0, player.Position, Vector.Zero, player):ToEffect()
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.3, 0, false, 1)
		
			data.opalTimer = rng:RandomInt(30)+30-math.min(mult*5, 30)
			local spore = Isaac.Spawn(mod.FF.FloatingSpore.ID,mod.FF.FloatingSpore.Var,0,player.Position,Vector.Zero,player)
			local sd = spore:GetData()
			sd.fallspeed = -4
			sd.height = -5
			sd.target = mod:FindRandomFreePos(player, 120, true)
			sd.ramblinOpal = true
			sd.ramblinOpalMult = mult
			spore:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			spore:Update()
		end
	end
end