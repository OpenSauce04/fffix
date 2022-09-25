local mod = FiendFolio
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flag, source)
	if ent:ToPlayer() then
		local player = ent:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.ROCK.ROSE_QUARTZ) then
			local data = player:GetData()
			local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ROSE_QUARTZ))
			if data.roseQuartzShield then
				if data.roseQuartzShield:Exists() then
					if source.Type == 9 then
						data.roseQuartzShield:GetData().flash = true
						return false
					else
						data.roseQuartzShield:Remove()
						
						local shield = Isaac.Spawn(1000, 1750, 5, player.Position, Vector.Zero, player):ToEffect()
						shield.Target = player
						shield:FollowParent(player)
						shield.DepthOffset = 10
						shield.SpriteOffset = Vector(0,-15*player.SpriteScale.Y)
						shield.SpriteScale = player.SpriteScale
						shield:GetData().fade = 2.5/mult
						shield:Update()
						
						data.roseQuartzShield = shield
					end
				else
					local shield = Isaac.Spawn(1000, 1750, 5, player.Position, Vector.Zero, player):ToEffect()
					shield.Target = player
					shield:FollowParent(player)
					shield.DepthOffset = 10
					shield.SpriteOffset = Vector(0,-15*player.SpriteScale.Y)
					shield.SpriteScale = player.SpriteScale
					shield:GetData().fade = 2.5/mult
					shield:Update()
					
					data.roseQuartzShield = shield
				end
			else
				local shield = Isaac.Spawn(1000, 1750, 5, player.Position, Vector.Zero, player):ToEffect()
				shield.Target = player
				shield:FollowParent(player)
				shield.DepthOffset = 10
				shield.SpriteOffset = Vector(0,-15*player.SpriteScale.Y)
				shield.SpriteScale = player.SpriteScale
				shield:GetData().fade = 2.5/mult
				shield:Update()
				
				data.roseQuartzShield = shield
			end
		end
	end
end, 1)

function mod:roseQuartzShieldEffect(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	
	if not data.init then
		if data.fade == nil then
			data.fade = 10
		end
		data.init = true
	end
	
	if sprite:IsFinished("Begin") then
		sprite:Play("Idle")
	elseif data.flash == true then
		sprite:Play("Begin")
		data.flash = false
		sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 1, 0, false, 1.5)
	end
	
	if (data.fade*npc.FrameCount) > 255 then
		npc.Parent:GetData().roseQuartzShield = nil
		sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST, 0.5, 0, false, 2)
		npc:Remove()
	else
		npc:SetColor(Color(1,0.9,0.9, (255-data.fade*npc.FrameCount)/255, 0.4,0.35,0.35), 99, 1, false, false)
	end
end