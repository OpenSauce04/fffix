local mod = FiendFolio

function mod:shadowlessRockShadowEffect(effect)
	if effect.Parent then
		local proj = effect.Parent:ToProjectile()
		local sprite = effect:GetSprite()
		local data = effect:GetData()
		effect.Velocity = proj.Position-effect.Position
		local effectiveHeight = proj.Height/proj.FallingSpeed
		if effectiveHeight < -50 or effectiveHeight > 0 then
			mod:spritePlay(sprite, "blink1")
		elseif not data.scheduleBlink2 then
			data.scheduleBlink2 = true
		end
		
		if data.scheduleBlink2 then
			if sprite:GetFrame() > 22 then
				sprite:Play("blink2")
				data.scheduleBlink2 = nil
			end
		end
	else
		effect:Remove()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
	if proj.SubType == mod.FF.ShadowlessRock.Sub then
		local data = proj:GetData()
		if not data.shadowlessRockShadow then
			data.shadowlessRockShadow = Isaac.Spawn(mod.FF.ShadowlessRockShadow.ID, mod.FF.ShadowlessRockShadow.Var, mod.FF.ShadowlessRockShadow.Sub, proj.Position, proj.Velocity, proj):ToEffect()
			data.shadowlessRockShadow.Parent = proj
			--data.shadowlessRockShadow:FollowParent(proj)
			data.shadowlessRockShadow.Scale = proj.Scale
		end
	end
end, 9)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
	if proj.SubType == mod.FF.ShadowlessGridProjectile.Sub then
		local data = proj:GetData()
		if not data.shadowlessRockShadow then
			data.shadowlessRockShadow = Isaac.Spawn(mod.FF.ShadowlessRockShadow.ID, mod.FF.ShadowlessRockShadow.Var, mod.FF.ShadowlessRockShadow.Sub, proj.Position, proj.Velocity, proj):ToEffect()
			data.shadowlessRockShadow.Parent = proj
			--data.shadowlessRockShadow:FollowParent(proj)
			data.shadowlessRockShadow.Scale = proj.Scale
		end
	end
end, 8)