local mod = FiendFolio

function mod:dogrockrockUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.DOGROCK_ROCK) then
		local sfx = SFXManager()
		local savedata = data.ffsavedata.RunEffects
		local mult = math.ceil(FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.DOGROCK_ROCK))
		if not savedata.dogrockRock then
			savedata.dogrockRock = 1
			savedata.dogrockRockIncrement = 1
		else
			if savedata.dogrockRock < 100*mult then
				savedata.dogrockRock = savedata.dogrockRock+savedata.dogrockRockIncrement
				savedata.dogrockRockIncrement = savedata.dogrockRockIncrement+0.01
				player:AddCacheFlags(CacheFlag.CACHE_LUCK)
				player:EvaluateItems()
			elseif savedata.dogrockRock ~= 100*mult then
				savedata.dogrockRock = 100*mult
				player:AddCacheFlags(CacheFlag.CACHE_LUCK)
				player:EvaluateItems()
			end
		end
		local near = false
		for _,entity in ipairs(Isaac.FindInRadius(player.Position, 100, EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() and (not mod:isFriend(entity)) and (not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
				local slowMult = math.max(0.2, entity.Position:Distance(player.Position)/(150+math.min(20*mult, 50)))
				entity:AddSlowing(EntityRef(player), 1, slowMult, Color(1.2,1.2,1.2,1,0,0,0.1))
				near = true
			end
		end
		--[[if near == true then
			if not sfx:IsPlaying(mod.Sounds.Dogrock) then
				sfx:Play(mod.Sounds.Dogrock, 0.4, 0, true, 1)
			end
		else
			if sfx:IsPlaying(mod.Sounds.Dogrock) then
				sfx:Stop(mod.Sounds.Dogrock)
			end
		end]]
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, trinket)
	if trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.DOGROCK_ROCK then
		local data = trinket:GetData()
		local sprite = trinket:GetSprite()
		if (not data.heartsEffect or not data.heartsEffect:Exists()) and trinket.FrameCount > 50 then
			data.heartsEffect = Isaac.Spawn(1000, 1750, 12, trinket.Position, Vector.Zero, trinket)
			data.heartsEffect.Parent = trinket
			data.heartsEffect:GetData().offset = 30
			data.heartsEffect:Update()
			data.heartsEffect:Update()
		end
		
		if sprite:GetFilename() == "gfx/005.350_Trinket.anm2" then
			local appear = false
			if sprite:IsPlaying("Appear") then
				appear = true
			end
			sprite:Load("gfx/items/trinkets/golem/dogrockrock.anm2", true)
			if appear == true then
				sprite:Play("Appear", true)
				data.state = "Drop"
			else
				sprite:Play("Idle", true)
				data.state = "Idle"
				data.currentAngle = 4
			end
			sprite:LoadGraphics()
			sprite:Update()
		end
		
		if data.state == "Idle" then
			local target
			local radius = 9999
			for i = 1, Game():GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				if player.Position:Distance(trinket.Position) < radius then
					target = player
					radius = player.Position:Distance(trinket.Position)
				end
			end
			if target == nil then
				mod:spritePlay(sprite, 109)
			elseif not data.override then
				local targAng = (target.Position-trinket.Position):GetAngleDegrees()+90
				if targAng < 0 then
					targAng = targAng+360
				end
				local override = false
				local currentAngle = math.ceil(targAng/90)
				if data.currentAngle ~= currentAngle then
					override = true
					if currentAngle == 4 and data.currentAngle == 1 then
						data.override = {0.5, 3.5}
					elseif currentAngle > data.currentAngle then
						data.override = {data.currentAngle+0.5, 0.5}
					elseif currentAngle == 1 and data.currentAngle == 4 then
						data.override = {0.5, 0.5}
					else
						data.override = {data.currentAngle-0.5, -0.5}
					end
				end
				if override == true then
					mod:spritePlay(sprite, data.currentAngle)
				else
					mod:spritePlay(sprite, currentAngle)
				end
				data.currentAngle = math.ceil(targAng/90)
			else
				mod:spritePlay(sprite, data.override[1])
				if data.override[1] % 1 ~= 0 then
					data.override[1] = data.override[1]+data.override[2]
				else
					data.currentAngle = data.override[1]
					data.override = nil
				end
			end
		elseif data.state == "Drop" then
			if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
				data.state = "Idle"
				data.currentAngle = 4
			end
		end
	end
end, 350)

function mod:charmHeartsEffect(e)
	if not e.Parent or not e.Parent:Exists() then
		e:Remove()
	else
		if not e:GetData().offset then
			e:GetData().offset = 30
		end
		mod:spritePlay(e:GetSprite(), "Charm")
		e.Velocity = e.Parent.Position-Vector(0, e:GetData().offset)-e.Position
	end
end

--[[FiendFolio.AddTrinketPickupCallback(function(player)
	local basedata = player:GetData()
	local data = basedata.ffsavedata.RunEffects
	if not data.dogrockRock then
		data.dogrockRock = "hi"
	end
end, nil, FiendFolio.ITEM.ROCK.DOGROCK_ROCK, nil)]]