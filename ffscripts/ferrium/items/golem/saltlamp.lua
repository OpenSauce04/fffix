local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

function mod:saltLampUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.SALT_LAMP) then
		local data = player:GetData().ffsavedata
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SALT_LAMP)
		data.saltLampMax = 3600*mult
		if not data.saltLampDuration then
			data.saltLampDuration = 3600
		end
		if not data.saltLamp or (not data.saltLamp:Exists()) then
			local aura = Isaac.Spawn(mod.FF.SaltLampAura.ID, mod.FF.SaltLampAura.Var, mod.FF.SaltLampAura.Sub, player.Position, player.Velocity, player):ToEffect()
			aura.SpriteOffset = Vector(0,-15)*player.SpriteScale.Y
			aura.DepthOffset = -10
			aura.Parent = player
			aura:FollowParent(player)
			aura:GetData().saltLampMax = data.saltLampMax
			aura:GetData().saltLampDuration = data.saltLampDuration
			aura:Update()
			data.saltLamp = aura
		end
		if data.saltLampDuration > 0 then
			data.saltLampDuration = data.saltLampDuration-1
			data.saltLampExtinguished = false
			
			for _, shot in ipairs(Isaac.FindByType(9, -1, -1, false, false)) do
				if shot.Position:Distance(player.Position) <= 50 then
					shot.Velocity = mod:Lerp(shot.Velocity, (shot.Position-player.Position):Resized(4), 0.15)
				end
			end
			for _,entity in ipairs(Isaac.FindInRadius(player.Position, 60, EntityPartition.ENEMY)) do
				entity.Velocity = mod:Lerp(entity.Velocity, (entity.Position-player.Position):Resized(4), 0.15)
			end
		elseif not data.saltLampExtinguished then
			sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.5, 0, false, 1.2)
			data.saltLampExtinguished = true
		end
	end
end

function mod:saltLampAuraEffect(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	
	if npc.Parent and npc.Parent:ToPlayer():HasTrinket(FiendFolio.ITEM.ROCK.SALT_LAMP) then
		local pData = npc.Parent:GetData().ffsavedata
		local saltLampDuration = pData.saltLampDuration
		local saltLampMax = pData.saltLampMax
		if saltLampDuration > 600 then
			mod:spritePlay(sprite, "Idle")
		else
			mod:spritePlay(sprite, "IdleLow")
		end
		--print(saltLampDuration)
		if saltLampDuration < 1800 then
			local alphaColor = math.max(0, 21*(saltLampDuration^(1/3)))
			npc.Color = Color(1,1,1,alphaColor/255, 0, 0, 0)
			npc.SpriteScale = Vector(0.75, 0.75)
		else
			local scaleVal = 0.75+math.min(0.25, 0.25*(saltLampDuration-1800)/1800)
			npc.SpriteScale = Vector(scaleVal, scaleVal)
			npc.Color = Color.Lerp(npc.Color, Color(1,1,1,1,0,0,0), 0.1)
		end
	else
		npc:Remove()
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SALT_LAMP) then
			local data = player:GetData().ffsavedata
			if pickup.Variant == 90 then
				local canPickUp = false
				if pickup.SubType == 3 then
					data.saltLampDuration = data.saltLampMax*2
					canPickUp = true
				elseif pickup.SubType == 2 and data.saltLampDuration < data.saltLampMax then
					if data.saltLampDuration < data.saltLampMax/2 then
						data.saltLampDuration = data.saltLampMax/2
					else
						data.saltLampDuration = data.saltLampMax
					end
					canPickUp = true
				elseif data.saltLampDuration < data.saltLampMax then
					data.saltLampDuration = data.saltLampMax
					canPickUp = true
				end
				
				if not player:NeedsCharge() and canPickUp == true then
					sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false, 1)
					pickup.Velocity = Vector.Zero
					pickup.Touched = true
					pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					pickup:GetSprite():Play("Collect", true)
					pickup:Die()
				end
			elseif pickup.Variant == 30 and data.saltLampDuration < data.saltLampMax then
				if pickup.SubType == 4 or pickup.SubType == 181 or pickup.SubType == 183 then
					data.saltLampDuration = data.saltLampMax
					if not player:NeedsCharge() then
						sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false, 1)
					end
				end
			end
		end
	end
end)

function mod:saltLampNewLevel()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SALT_LAMP) then
			local data = player:GetData().ffsavedata
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SALT_LAMP)
			data.saltLampMax = 3600*mult
			if not data.saltLampDuration or data.saltLampDuration < data.saltLampMax then
				data.saltLampDuration = data.saltLampMax
			end
		end
	end
end