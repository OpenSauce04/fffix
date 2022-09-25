local mod = FiendFolio
local sfx = SFXManager()

function mod:guardedGarnetHurt(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GUARDED_GARNET) then
		local data = player:GetData()
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.GUARDED_GARNET)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GUARDED_GARNET)
		local chance = 20+10*mult+player.Luck*2
		
		if data.guardedGarnetShield then
			if data.guardedGarnetShield:Exists() then
				data.guardedGarnetShield:Remove()
				data.guardedGarnetShield = nil
				local aura = Isaac.Spawn(1000, 123, 8, player.Position, Vector.Zero, player):ToEffect()
				local color = Color(1, 1, 1, 1, 3, 0.95, 1)
				color:SetColorize(3, 0.3, 0, 0.35)
				aura.Color = color
				aura.SpriteScale = Vector(0.6,0.6)
				for _,entity in ipairs(Isaac.FindInRadius(player.Position, 100, EntityPartition.ENEMY)) do
					if entity:IsActiveEnemy() and (not mod:isFriend(entity)) then
						entity:GetData().fakeKnockbackEffect = true
						entity:GetData().fakeKnockbackData = {(entity.Position-player.Position):Resized(100), 5, 5}
					end
				end
				mod.scheduleForUpdate(function()
					if sfx:IsPlaying(mod.Sounds.FiendHurt) then
						sfx:Stop(mod.Sounds.FiendHurt)
					elseif sfx:IsPlaying(mod.Sounds.GolemHurt) then
						sfx:Stop(mod.Sounds.GolemHurt)
					end
					sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
				end, 0)
				sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 1, 0, false, 1.5)
				return false
			elseif rng:RandomInt(100) < chance then
				local shield = Isaac.Spawn(1000, 1750, 13, player.Position, Vector.Zero, player):ToEffect()
				shield.Target = player
				shield:FollowParent(player)
				shield.DepthOffset = 13
				shield.SpriteOffset = Vector(0,-15*player.SpriteScale.Y)
				shield.SpriteScale = player.SpriteScale
				shield:Update()
				
				data.guardedGarnetShield = shield
			end
		elseif rng:RandomInt(100) < chance then
			local shield = Isaac.Spawn(1000, 1750, 13, player.Position, Vector.Zero, player):ToEffect()
			shield.Target = player
			shield:FollowParent(player)
			shield.DepthOffset = 13
			shield.SpriteOffset = Vector(0,-15*player.SpriteScale.Y)
			shield.SpriteScale = player.SpriteScale
			shield:GetData().fade = 2.5/mult
			shield:Update()
			
			data.guardedGarnetShield = shield
		end
	end
end

function mod:guardedGarnetShieldEffect(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end
end