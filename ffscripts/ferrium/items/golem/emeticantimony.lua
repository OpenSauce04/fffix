local mod = FiendFolio
local sfx = SFXManager()

function mod:emeticAntimonyUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.EMETIC_ANTIMONY) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.EMETIC_ANTIMONY)
		if not data.emeticAntimonyTimer then
			data.emeticAntimonyTimer = 41
		end
		
		if data.emeticAntimonyTimer > 0 then
			data.emeticAntimonyTimer = data.emeticAntimonyTimer-1
			if data.emeticAntimonyTimer < 60 and not data.emeticAntimonyWarning then
				data.emeticAntimonyWarning = true
				sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 0.85)
			end
		else
			if data.emeticAntimonyWarning == true then
				sfx:Play(SoundEffect.SOUND_BEEP, 1, 0, false, 0.85)
				data.emeticAntimonyWarning = false
				data.emeticFlash = 5
				data.emeticAntimonyReady = true
				if data.emeticAntimonyWisp then
					data.emeticAntimonyWisp:Remove()
					data.emeticAntimonyWisp:Kill()
				end
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC, false) then
					data.emeticAntimonyWisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_IPECAC,Vector(1200,600),false)
					data.emeticAntimonyWisp.Visible = false
					data.emeticAntimonyWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					data.emeticAntimonyWisp:RemoveFromOrbit()
					data.ffsavedata.emeticAntimonyWispInit = data.emeticAntimonyWisp.InitSeed
				end
			end
			
			if data.emeticAntimonyReady == false then
				if data.emeticAntimonyWisp then
					data.emeticAntimonyWisp:Remove()
					data.emeticAntimonyWisp:Kill()
					data.emeticAntimonyWisp = nil
					data.ffsavedata.emeticAntimonyWispInit = nil
				end
				data.emeticAntimonyWarning = false
				data.emeticAntimonyTimer = 500-math.min(400, 50*mult)
			end
		end
		
		if data.emeticFlash then
			if data.emeticFlash > 0 then
				data.emeticFlash = data.emeticFlash-1
				player.Color = Color.Lerp(player.Color, Color(1,1,1,1,0.2,1,0.2), 0.2)
			else
				player.Color = Color(1,1,1,1,0,0,0)
				data.emeticFlash = nil
			end
		end
		
		if data.emeticAntimonyWisp and data.emeticAntimonyWisp:Exists() then
			data.emeticAntimonyWisp.Visible = false
			data.emeticAntimonyWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end
	elseif data.emeticAntimonyWisp then
		data.emeticAntimonyWisp:Remove()
		data.emeticAntimonyWisp:Kill()
		data.ffsavedata.emeticAntimonyWispInit = nil
		data.emeticAntimonyWisp = nil
	end
end

function mod:emeticAntimonyWispCheck(player, data)
	if data.ffsavedata and data.ffsavedata.emeticAntimonyWispInit then
		for _,wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, 149, false, false)) do
			if wisp.InitSeed == data.ffsavedata.emeticAntimonyWispInit then
				wisp:Remove()
				wisp:Kill()
			end
		end
		data.ffsavedata.emeticAntimonyWispInit = nil
	end
end

--[[mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
	for _, wisp in ipairs(Isaac.FindByType(3, 237, CollectibleType.COLLECTIBLE_IPECAC, false, false)) do
		wispFam = wisp:ToFamiliar()
		local data = wispFam.Player:GetData()
		if data.emeticAntimonyReady then
			wisp.Visible = false
			wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		elseif data.emeticAntimonyReady == false then
			wisp:Remove()
			wisp:Kill()
		end
	end
end)]]