local mod = FiendFolio

local beadFlyOutlineSprite = Sprite()
beadFlyOutlineSprite:Load("gfx/enemies/ripcord/monster_diagarmyfly_outline.anm2", true)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == mod.FF.BeadFlyOutline.Sub then
		local data = effect:GetData()
		local sprite = effect:GetSprite()
		
		if (
			not data.beadfly or
			not data.beadfly:Exists()or
			data.beadfly:IsDead() or
			data.beadfly:GetData().outline.InitSeed ~= effect.InitSeed
		) then
			effect:Remove()
		end
	end
end, FiendFolio.FF.BeadFlyOutline.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	if effect.SubType == mod.FF.BeadFlyOutline.Sub then
		local data = effect:GetData()

		if data.beadfly then
			local bead = data.beadfly
			local sprite = bead:GetSprite()
			local pos = Isaac.WorldToScreen(bead.Position)
			
			local spriteloc = "gfx/enemies/ripcord/monster_diagarmyfly.png"
			if bead:GetData().altsprite then
				spriteloc = "gfx/enemies/ripcord/monster_lead_beadfly.png"
			end
			beadFlyOutlineSprite:ReplaceSpritesheet(0, spriteloc)
			beadFlyOutlineSprite:LoadGraphics()
			
			beadFlyOutlineSprite:Play(sprite:GetAnimation())
			beadFlyOutlineSprite:SetFrame(sprite:GetFrame())
			beadFlyOutlineSprite.Color = sprite.Color
			beadFlyOutlineSprite:Render(pos + bead.SpriteOffset, Vector.Zero, Vector.Zero)
		end
	end
end, FiendFolio.FF.BeadFlyOutline.Var)