FiendFolio:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == FiendFolio.FF.RipcordRingGib.Sub then
		local data = effect:GetData()

		if effect.SpriteOffset.Y + data.vel >= 0 then
			effect.Velocity = Vector.Zero
			effect.SpriteOffset = Vector.Zero

			effect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
		else
			effect.SpriteOffset = effect.SpriteOffset + Vector(0, data.vel)
			effect.SpriteRotation = effect.SpriteRotation + 60

			data.vel = data.vel + 0.75
		end

	end
end, FiendFolio.FF.RipcordRingGib.Var)