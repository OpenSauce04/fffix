local mod = FiendFolio

function mod:starSapphireUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.STAR_SAPPHIRE) then
		if not data.starSapphire or not data.starSapphire:Exists() then
			local rock = Isaac.Spawn(3, FamiliarVariant.STAR_SAPPHIRE_GEM, 0, player.Position, Vector.Zero, player):ToFamiliar()
			rock.Player = player
			data.starSapphire = rock
			rock:Update()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player
	local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.STAR_SAPPHIRE)
	local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.STAR_SAPPHIRE)
	
	if not player:HasTrinket(FiendFolio.ITEM.ROCK.STAR_SAPPHIRE) then
		familiar:Remove()
	end
	if sprite:IsPlaying() then
		sprite:Stop()
	end
	if not data.init then
		data.stateframe = 0
		data.angle = 0
		data.init = true
	else
		data.stateframe = data.stateframe + 1
		data.angle = data.angle % 360
	end
	
	local targPos = player.Position+Vector(1,0):Rotated(data.angle):Resized(50)
	--familiar.Position = targPos
	if familiar.Position:Distance(targPos) > 10 then
		familiar.Velocity = mod:Lerp(familiar.Velocity, (targPos-familiar.Position):Resized(10), 0.1)
	else
		familiar.Velocity = mod:Lerp(familiar.Velocity, (targPos-familiar.Position), 0.01)
	end
	
	local maxRadius = 999
	local target
	local backup
	for _,ent in ipairs(Isaac.FindInRadius(player.Position, 500, EntityPartition.ENEMY)) do
		if ent:IsActiveEnemy() and (not mod:isFriend(ent)) then
			local data = ent:GetData()
			local dist = familiar.Position:Distance(ent.Position)
			local dont = false
			data.starSapphireTimer = data.starSapphireTimer or 0
			if data.starSapphireTimer > 60 and not data.starSapphireExempt then
				data.starSapphireExempt = true
			end
			if dist < maxRadius then
				if data.starSapphireExempt then
					backup = ent
				else
					maxRadius = familiar.Position:Distance(ent.Position)
					target = ent
				end
			end
			
			if familiar.FrameCount % 7 == 0 then
				if ent.Position:Distance(familiar.Position) - ent.Size < 5 then
					if ent:IsActiveEnemy() and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
						ent:TakeDamage(player.Damage/2, 0, EntityRef(player), 0)
					end
				end
			end
		end
	end
	for _,ent in ipairs(Isaac.FindByType(9,-1,-1,false, true)) do
		if ent.Position:Distance(familiar.Position) - ent.Size < 10 then
			ent:Die()
		else
			local dist = familiar.Position:Distance(ent.Position)
			if dist < maxRadius then
				maxRadius = familiar.Position:Distance(ent.Position)
				target = ent
			end
		end
	end
	if target == nil and backup then
		target = backup
	end
	
	if target then
		target:GetData().starSapphireTimer = (target:GetData().starSapphireTimer or 0)+4
		local targAngle = (target.Position-player.Position):GetAngleDegrees()
		if targAngle < 0 then
			targAngle = targAngle+360
		end
		data.angle = targAngle
	else
		data.angle = data.angle+2
	end
	
	local frame = 16-math.floor((((data.angle-90) % 360)+11.25)/22.5)
	sprite:SetFrame("Directions", frame)
end, FamiliarVariant.STAR_SAPPHIRE_GEM)

function mod:starSapphireChecks(npc)
	local data = npc:GetData()
	if data.starSapphireTimer then
		if data.starSapphireExempt and data.starSapphireTimer <= 0 then
			data.starSapphireExempt = nil
		end
		data.starSapphireTimer = data.starSapphireTimer-1
	end
end