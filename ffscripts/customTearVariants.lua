-----------------------------------------------------------
-- Custom tear variants
-----------------------------------------------------------

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

-----------------------------------------------------------
-- General
-----------------------------------------------------------

function mod:changeTearVariant(tear, var, bloodvar, force)
	if (mod.TearVariantPriority[tear.Variant] or 0) <= mod.TearVariantPriority[var] or force then
		if bloodvar and tear:GetData().IsBloodyTear then
			tear:ChangeVariant(bloodvar)
		else
			tear:ChangeVariant(var)
		end
		tear:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		
		if var ~= tear:GetData().FFLastVariant then
			tear:GetData().FFCustomTearSprite = nil
			tear:GetData().FFLastVariant = var
		end
	end
end

function mod:changeToRandomTearVariant(tear, force)
	local variants = {}
	for k,v in pairs(mod.TearVariantPriority) do
		if v ~= 99999 then
			table.insert(variants, k)
		end
	end
	
	if tear.Variant == TearVariant.SCHYTHE then
		tear.Scale = tear.Scale / 2
	end
	
	local var = variants[math.random(#variants)]
	if var ~= tear.Variant then
		mod:changeTearVariant(tear, var, nil, force)
	end
end

local function getTearScale6(tear)
	local sprite = tear:GetSprite()
	local scale = tear.Scale
	local sizeMulti = tear.SizeMulti
	local flags = tear.TearFlags
	
	if scale > 2.55 then
        return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
	elseif flags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW or flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO then
		if scale <= 0.675 then
			return Vector((scale * sizeMulti.X) / 0.5, (scale * sizeMulti.Y) / 0.5)
		elseif scale <= 2.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		else
			return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
		end
    else
        return sizeMulti
	end
end

local function getTearScale13(tear)
	local sprite = tear:GetSprite()
	local scale = tear.Scale
	local sizeMulti = tear.SizeMulti
	local flags = tear.TearFlags
	
	if scale > 2.55 then
        return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
	elseif flags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW or flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO then
		if scale <= 0.3 then
			return Vector((scale * sizeMulti.X) / 0.25, (scale * sizeMulti.Y) / 0.25)
		elseif scale <= 0.55 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		elseif scale <= 1.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.125) * 0.125 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		elseif scale <= 2.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		else
			return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
		end
    else
        return sizeMulti
	end
end

-- NOTE: Modified from Sbody's Missing Tear GFX mod
local function getNormalTearPoofVariant(scale, height)
	--if scale > 1.8625 then
	--	if height < -5 then
	--		return TEAR_POOF_A_LARGE    -- Wall impact
	--	else
	--		return TEAR_POOF_B_LARGE    -- Floor impact
	--	end
	if scale > 0.8 then
		if height < -5 then
			return EffectVariant.TEAR_POOF_A    -- Wall impact
		else
			return EffectVariant.TEAR_POOF_B    -- Floor impact
		end
	elseif scale > 0.4 then
		return EffectVariant.TEAR_POOF_SMALL
	else
		return EffectVariant.TEAR_POOF_VERYSMALL
	end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if mod.BloodyTears[tear.Variant] then
		tear:GetData().IsBloodyTear = true
	end
end)

function mod:renderCustomTear(tear, offset)
	if tear.Variant == TearVariant.FORTUNE_COOKIE then
		mod:fortuneCookieTearRender(tear, offset)
	elseif tear.Variant == TearVariant.HOMING_AMULET or tear.Variant == TearVariant.HOMING_AMULET_BLOOD then
		mod:homingAmuletTearRender(tear, offset)
	elseif tear.Variant == TearVariant.FROG or tear.Variant == TearVariant.FROG_BLOOD then
		mod:frogTearRender(tear, offset)
	elseif tear.Variant == TearVariant.PIN or tear.Variant == TearVariant.PIN_BLOOD then
		mod:pinTearRender(tear, offset)
	elseif tear.Variant == TearVariant.D10 then
		mod:d10TearRender(tear, offset)
	elseif tear.Variant == TearVariant.M90_BULLET or tear.Variant == TearVariant.GOLEMS_AR_BULLET then
		mod:m90BulletTearRender(tear, offset, tear.Variant)
	elseif tear.Variant == TearVariant.PRANK_COOKIE then
		mod:prankCookieTearRender(tear, offset)
	elseif tear.Variant == TearVariant.BOOMERANG_RIB then
		mod:boomerangRibTearRender(tear, offset)
	elseif tear.Variant == TearVariant.BRICK then
		mod:brickTearRender(tear, offset)
	elseif tear.Variant == TearVariant.MODEL_ROCKET then
		mod:rocketTearRender(tear, offset)
	elseif tear.Variant == TearVariant.MULTI_EUCLIDEAN then
		mod:multiEuclideanTearRender(tear, offset)
	elseif tear.Variant == TearVariant.HORNCOB_PILL then
		mod:hornCobPillTearRender(tear, offset)
	elseif tear.Variant == TearVariant.LAWN_DART then
		mod:lawnDartTearRender(tear, offset)
	end

	local data = tear:GetData()
	data.FFLastVariant = tear.Variant
	
	data.RocketTearPreviousLength = tear.Velocity:Length()
	if tear.Variant ~= TearVariant.MODEL_ROCKET then
		data.RocketTearPreviousSuffix = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, mod.renderCustomTear)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
	local tear = tear:ToTear()
	if tear.Variant == TearVariant.BRICK then
		mod:brickTearSplat(tear)
		return
    end
	
	if game:IsPaused() then return end
	
	if tear.Variant == TearVariant.FORTUNE_COOKIE then
		mod:fortuneCookieTearSplat(tear)
	elseif tear.Variant == TearVariant.HOMING_AMULET or tear.Variant == TearVariant.HOMING_AMULET_BLOOD then
		mod:homingAmuletTearSplat(tear)
	elseif tear.Variant == TearVariant.FROG or tear.Variant == TearVariant.FROG_BLOOD then
		mod:frogTearSplat(tear)
	elseif tear.Variant == TearVariant.PIN or tear.Variant == TearVariant.PIN_BLOOD then
		mod:pinTearSplat(tear)
	elseif tear.Variant == TearVariant.D10 then
		mod:d10TearSplat(tear)
	elseif tear.Variant == TearVariant.M90_BULLET or tear.Variant == TearVariant.GOLEMS_AR_BULLET then
		mod:m90BulletTearSplat(tear, tear.Variant)
	elseif tear.Variant == TearVariant.PRANK_COOKIE then
		mod:prankCookieTearSplat(tear)
	elseif tear.Variant == TearVariant.BOOMERANG_RIB then
		mod:boomerangRibTearSplat(tear)
	elseif tear.Variant == TearVariant.MODEL_ROCKET then
		mod:rocketTearSplat(tear)
	elseif tear.Variant == TearVariant.MULTI_EUCLIDEAN then
		mod:multiEuclideanTearSplat(tear)
	elseif tear.Variant == TearVariant.HORNCOB_PILL then
		mod:hornCobPillTearSplat(tear)
	elseif tear.Variant == TearVariant.LAWN_DART then
		mod:lawnDartTearSplat(tear)
    end
end, EntityType.ENTITY_TEAR)

-----------------------------------------------------------
-- Fortune Cookie tear
-----------------------------------------------------------

function mod:fortuneCookieTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/fortune_cookie_tear.anm2", true)
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.675 then
		anim = "Stone1Move"
	elseif scale <= 0.925 then
		anim = "Stone2Move"
	elseif scale <= 1.175 then
		anim = "Stone3Move"
	elseif scale <= 1.675 then
		anim = "Stone4Move"
	elseif scale <= 2.175 then
		anim = "Stone5Move"
	else
		anim = "Stone6Move"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale6(tear)
	sprite.Scale = spritescale
	
	if flags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
		sprite.Rotation = tearsprite.Rotation
		sprite.FlipX = tearsprite.FlipX
		sprite.FlipY = tearsprite.FlipY
	else
		sprite.Rotation = 0
		sprite.FlipX = false
		sprite.FlipY = false
	end
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:fortuneCookieTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.5, 0, false, math.random() + 0.5)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 920, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end

-----------------------------------------------------------
-- Homing Amulet tear
-----------------------------------------------------------

function mod:homingAmuletTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		if tear.Variant == TearVariant.HOMING_AMULET_BLOOD then
			sprite:Load("gfx/projectiles/homingamuletblood.anm2", true)
		else
			sprite:Load("gfx/projectiles/homingamulet.anm2", true)
		end
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local prefix = "Regular"
	if tear.Variant == TearVariant.HOMING_AMULET_BLOOD then
		prefix = "Blood"
	end
	
	local anim
	if scale <= 0.3 then
		anim = prefix .. "Tear1"
	elseif scale <= 0.55 then
		anim = prefix .. "Tear2"
	elseif scale <= 0.675 then
		anim = prefix .. "Tear3"
	elseif scale <= 0.8 then
		anim = prefix .. "Tear4"
	elseif scale <= 0.925 then
		anim = prefix .. "Tear5"
	elseif scale <= 1.05 then
		anim = prefix .. "Tear6"
	elseif scale <= 1.175 then
		anim = prefix .. "Tear7"
	elseif scale <= 1.425 then
		anim = prefix .. "Tear8"
	elseif scale <= 1.675 then
		anim = prefix .. "Tear9"
	elseif scale <= 1.925 then
		anim = prefix .. "Tear10"
	elseif scale <= 2.175 then
		anim = prefix .. "Tear11"
	elseif scale <= 2.55 then
		anim = prefix .. "Tear12"
	else
		anim = prefix .. "Tear13"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.Rotation = adjustedVelocity:GetAngleDegrees() + 90
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:homingAmuletTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_SPLATTER, 1, 0, false, 1.0)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	if tear.Variant == TearVariant.HOMING_AMULET_BLOOD then
		local poof = Isaac.Spawn(1000, EffectVariant.BULLET_POOF, 0, tear.Position, nilvector, tear)
		poof:GetSprite().Color = color
		poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
		poof.PositionOffset = tear.PositionOffset
	else
		local poof = Isaac.Spawn(1000, getNormalTearPoofVariant(tear.Scale, tear.Height), 0, tear.Position, nilvector, tear)
		poof:GetSprite().Color = color
		if scale > 0.8 then
			poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
		end
		poof.PositionOffset = tear.PositionOffset
	end
end

-----------------------------------------------------------
-- Frog tear
-----------------------------------------------------------

function mod:frogTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		if tear.Variant == TearVariant.FROG_BLOOD then
			sprite:Load("gfx/projectiles/projectile_frog_blood.anm2", true)
		else
			sprite:Load("gfx/projectiles/projectile_frog.anm2", true)
		end
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local prefix = "Regular"
	if tear.Variant == TearVariant.FROG_BLOOD then
		prefix = "Blood"
	end
	
	local anim
	if scale <= 0.3 then
		anim = prefix .. "Tear1"
	elseif scale <= 0.55 then
		anim = prefix .. "Tear2"
	elseif scale <= 0.675 then
		anim = prefix .. "Tear3"
	elseif scale <= 0.8 then
		anim = prefix .. "Tear4"
	elseif scale <= 0.925 then
		anim = prefix .. "Tear5"
	elseif scale <= 1.05 then
		anim = prefix .. "Tear6"
	elseif scale <= 1.175 then
		anim = prefix .. "Tear7"
	elseif scale <= 1.425 then
		anim = prefix .. "Tear8"
	elseif scale <= 1.675 then
		anim = prefix .. "Tear9"
	elseif scale <= 1.925 then
		anim = prefix .. "Tear10"
	elseif scale <= 2.175 then
		anim = prefix .. "Tear11"
	elseif scale <= 2.55 then
		anim = prefix .. "Tear12"
	else
		anim = prefix .. "Tear13"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.Rotation = adjustedVelocity:GetAngleDegrees()
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:frogTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_SPLATTER, 1, 0, false, 1.0)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	if tear.Variant == TearVariant.FROG_BLOOD then
		local poof = Isaac.Spawn(1000, EffectVariant.BULLET_POOF, 0, tear.Position, nilvector, tear)
		poof:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/projectile_frog_blood_tearpoof.png")
		poof:GetSprite():LoadGraphics()
		
		poof:GetSprite().Color = color
		poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
		poof.PositionOffset = tear.PositionOffset
	else
		local poof = Isaac.Spawn(1000, EffectVariant.BULLET_POOF, 0, tear.Position, nilvector, tear)
		poof:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/projectile_frog_tearpoof.png")
		poof:GetSprite():LoadGraphics()
		
		poof:GetSprite().Color = color
		poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
		poof.PositionOffset = tear.PositionOffset
	end
end

-----------------------------------------------------------
-- Pin tear
-----------------------------------------------------------

function mod:pinTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		if tear.Variant == TearVariant.PIN_BLOOD then
			sprite:Load("gfx/projectiles/hp_pinhead_tear_blood.anm2", true)
		else
			sprite:Load("gfx/projectiles/hp_pinhead_tear.anm2", true)
		end
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.3 then
		anim = "RegularTear1"
	elseif scale <= 0.55 then
		anim = "RegularTear2"
	elseif scale <= 0.675 then
		anim = "RegularTear3"
	elseif scale <= 0.8 then
		anim = "RegularTear4"
	elseif scale <= 0.925 then
		anim = "RegularTear5"
	elseif scale <= 1.05 then
		anim = "RegularTear6"
	elseif scale <= 1.175 then
		anim = "RegularTear7"
	elseif scale <= 1.425 then
		anim = "RegularTear8"
	elseif scale <= 1.675 then
		anim = "RegularTear9"
	elseif scale <= 1.925 then
		anim = "RegularTear10"
	elseif scale <= 2.175 then
		anim = "RegularTear11"
	elseif scale <= 2.55 then
		anim = "RegularTear12"
	else
		anim = "RegularTear13"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.Rotation = adjustedVelocity:GetAngleDegrees()
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:pinTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 3)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.NAIL_PARTICLE, 0, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end

-----------------------------------------------------------
-- D10 tear
-----------------------------------------------------------

function mod:d10TearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/projectile_d10.anm2", true)
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.675 then
		anim = "Stone1Move"
	elseif scale <= 0.925 then
		anim = "Stone2Move"
	elseif scale <= 1.175 then
		anim = "Stone3Move"
	elseif scale <= 1.675 then
		anim = "Stone4Move"
	elseif scale <= 2.175 then
		anim = "Stone5Move"
	else
		anim = "Stone6Move"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale6(tear)
	sprite.Scale = spritescale
	
	if flags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
		sprite.Rotation = tearsprite.Rotation
		sprite.FlipX = tearsprite.FlipX
		sprite.FlipY = tearsprite.FlipY
	else
		sprite.Rotation = 0
		sprite.FlipX = false
		sprite.FlipY = false
	end
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:d10TearSplat(tear)
    if not tear:GetData().denySound then
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.3, 0, false, 2.5 - math.max(math.min(tear.Scale, 1.5), 0))
    end
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end
	
	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
    local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, tear.Position, tear.Velocity * 0.1, tear):ToEffect()
    smoke.Color = Color(1,1,1,1,0.7,0.4,0.3)
	smoke.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	smoke.PositionOffset = tear.PositionOffset
    smoke:Update()
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 920, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end

-----------------------------------------------------------
-- M90 Bullet tear
-----------------------------------------------------------

function mod:m90BulletTearRender(tear, offset, tvar)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		if tvar == TearVariant.GOLEMS_AR_BULLET then
			sprite:Load("gfx/projectiles/projectile_golem_ar_bullet.anm2", true)
		else
			sprite:Load("gfx/projectiles/projectile_m90.anm2", true)
		end
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.3 then
		anim = "RegularTear1"
	elseif scale <= 0.55 then
		anim = "RegularTear2"
	elseif scale <= 0.675 then
		anim = "RegularTear3"
	elseif scale <= 0.8 then
		anim = "RegularTear4"
	elseif scale <= 0.925 then
		anim = "RegularTear5"
	elseif scale <= 1.05 then
		anim = "RegularTear6"
	elseif scale <= 1.175 then
		anim = "RegularTear7"
	elseif scale <= 1.425 then
		anim = "RegularTear8"
	elseif scale <= 1.675 then
		anim = "RegularTear9"
	elseif scale <= 1.925 then
		anim = "RegularTear10"
	elseif scale <= 2.175 then
		anim = "RegularTear11"
	elseif scale <= 2.55 then
		anim = "RegularTear12"
	else
		anim = "RegularTear13"
	end

	if tvar == TearVariant.GOLEMS_AR_BULLET then
		if not data.GolemARBulletTrail then
			local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, tear.Position, nilvector, tear):ToEffect()
			trail.MinRadius = 0.2
			trail.SpriteScale = Vector(1.2,1)
			trail.Color = tear.Color
			trail:FollowParent(tear)
			data.GolemARBulletTrail = trail
		end
		if data.GolemARBulletTrail then
			data.GolemARBulletTrail.ParentOffset = Vector(0,tear.Height) + Vector(0,-tear.Scale * 3)
		end
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.Rotation = adjustedVelocity:GetAngleDegrees()
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:m90BulletTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 3)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.NAIL_PARTICLE, 0, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end

-----------------------------------------------------------
-- Prank Cookie tear
-----------------------------------------------------------

function mod:prankCookieTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/projectile_prank_cookie.anm2", true)
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.675 then
		anim = "Stone1Move"
	elseif scale <= 0.925 then
		anim = "Stone2Move"
	elseif scale <= 1.175 then
		anim = "Stone3Move"
	elseif scale <= 1.675 then
		anim = "Stone4Move"
	elseif scale <= 2.175 then
		anim = "Stone5Move"
	else
		anim = "Stone6Move"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale6(tear)
	sprite.Scale = spritescale
	
	if flags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
		sprite.Rotation = tearsprite.Rotation
		sprite.FlipX = tearsprite.FlipX
		sprite.FlipY = tearsprite.FlipY
	else
		sprite.Rotation = 0
		sprite.FlipX = false
		sprite.FlipY = false
	end
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:prankCookieTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.5, 0, false, math.random() + 2.0)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 920, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end

-----------------------------------------------------------
-- Boomerang Rib tear
-----------------------------------------------------------

function mod:boomerangRibTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/boomerang rib.anm2", true)
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local sizeMulti = tear.SizeMulti
	local flags = tear.TearFlags
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying("friendly") then
		local frame = sprite:GetFrame()
		sprite:Play("friendly", true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	sprite.Scale = Vector(1, 1)
	
	if flags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
		sprite.Rotation = tearsprite.Rotation
		sprite.FlipX = tearsprite.FlipX
		sprite.FlipY = tearsprite.FlipY
	else
		sprite.Rotation = 0
		sprite.FlipX = false
		sprite.FlipY = false
	end
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:boomerangRibTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_SCAMPER, 0.6, 0, false, 1)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	--[[local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.NAIL_PARTICLE, 0, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end]]--
end

-----------------------------------------------------------
-- Brick tear
-----------------------------------------------------------

function mod:brickTearRender(tear, offset)
	local data = tear:GetData()
	
	if not tear.Child then
		local brickGfx
		brickGfx = Isaac.Spawn(5, 350, TrinketType.TRINKET_BRICK_ROCK + tear.SubType, tear.Position, nilvector, player):ToPickup()
		brickGfx.Parent = tear
		brickGfx.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		brickGfx.Visible = false
		brickGfx:GetData().IsGfxBrick = true
		brickGfx:GetData().BrickFollowParent = true
        brickGfx:GetSprite():Load("gfx/projectiles/brick_rock.anm2", true)
        brickGfx:GetSprite():Play("Stone1Move", true)
		brickGfx.Touched = true
		tear.Child = brickGfx
	end
	local sprite = tear.Child:GetSprite()
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local sizeMulti = tear.SizeMulti
	local flags = tear.TearFlags
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying("Stone1Move") then
		local frame = sprite:GetFrame()
		sprite:Play("Stone1Move", true)
		sprite:SetFrame(frame)
	end

	sprite.Scale = Vector(1, 1)
	
	if flags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
		sprite.Rotation = tearsprite.Rotation
		sprite.FlipX = tearsprite.FlipX
		sprite.FlipY = tearsprite.FlipY
	else
		sprite.Rotation = 0
		sprite.FlipX = false
		sprite.FlipY = false
	end
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:brickTearSplat(tear)
	mod:spawnBrickTrinket(tear)
end

-----------------------------------------------------------
-- Model Rocket tear
-----------------------------------------------------------

function mod:rocketTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		if tear.Variant == TearVariant.MODEL_ROCKET then
			sprite:Load("gfx/projectiles/tears_modelrocket.anm2", true)
		end
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local animPrefix
	if scale <= 0.675 then
		animPrefix = "Rocket1"
	elseif scale <= 0.925 then
		animPrefix = "Rocket2"
	elseif scale <= 1.175 then
		animPrefix = "Rocket3"
	elseif scale <= 1.675 then
		animPrefix = "Rocket4"
	elseif scale <= 2.175 then
		animPrefix = "Rocket5"
	else
		animPrefix = "Rocket6"
	end

	local lastLength = data.RocketTearPreviousLength or 0
	local lastSuffix = data.RocketTearPreviousSuffix or "Idle"

	local velLength = tear.Velocity:Length()
	local animSuffix = ""

	if flags & TearFlags.TEAR_BOUNCE == TearFlags.TEAR_BOUNCE and tear:CollidesWithGrid() then
		animSuffix = lastSuffix
	elseif flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO and player:GetFireDirection() ~= Direction.NO_DIRECTION then
		animSuffix = "Move"
	elseif math.abs(velLength - lastLength) < 0.001 then
		animSuffix = lastSuffix
	elseif velLength < lastLength then
		animSuffix = "Idle"
	elseif velLength > lastLength then
		animSuffix = "Move"
	else
		animSuffix = lastSuffix
	end

	data.RocketTearPreviousLength = velLength
	data.RocketTearPreviousSuffix = animSuffix
	
	local anim = animPrefix .. animSuffix
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale6(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.Rotation = adjustedVelocity:GetAngleDegrees()
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0)
	sprite:RenderLayer(1, Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	sprite.Color = tearsprite.Color
	sprite:RenderLayer(2, Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:rocketTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 3)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 921, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end

-----------------------------------------------------------
-- Horncob Pill tear
-----------------------------------------------------------

local pillSheets = {
	"pt_blackyellow",
	"pt_blueblue",
	"pt_bluegreen",
	"pt_whiteblack",
	"pt_whiteblue",
	"pt_whitewhite",
	"pt_yelloworange",
	"pt_yellowyellow",
}

function mod:hornCobPillTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/pilltears/projectile_pilltear.anm2", true)
		sprite:ReplaceSpritesheet(0, "gfx/projectiles/pilltears/" .. pillSheets[math.random(#pillSheets)] .. ".png")
		sprite:LoadGraphics()
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.3 then
		anim = "RegularTear1"
	elseif scale <= 0.55 then
		anim = "RegularTear2"
	elseif scale <= 0.675 then
		anim = "RegularTear3"
	elseif scale <= 0.8 then
		anim = "RegularTear4"
	elseif scale <= 0.925 then
		anim = "RegularTear5"
	elseif scale <= 1.05 then
		anim = "RegularTear6"
	elseif scale <= 1.175 then
		anim = "RegularTear7"
	elseif scale <= 1.425 then
		anim = "RegularTear8"
	elseif scale <= 1.675 then
		anim = "RegularTear9"
	elseif scale <= 1.925 then
		anim = "RegularTear10"
	elseif scale <= 2.175 then
		anim = "RegularTear11"
	elseif scale <= 2.55 then
		anim = "RegularTear12"
	else
		anim = "RegularTear13"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	if flags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
		sprite.Rotation = tearsprite.Rotation
		sprite.FlipX = tearsprite.FlipX
		sprite.FlipY = tearsprite.FlipY
	else
		data.HornCobRotation = data.HornCobRotation or math.random(360)
		if not game:IsPaused() then
			if tear.Velocity.X > 0 then
				data.HornCobRotation = data.HornCobRotation + tear.Velocity:Length()
			else
				data.HornCobRotation = data.HornCobRotation - tear.Velocity:Length()
			end
		end
		sprite.Rotation = data.HornCobRotation
		sprite.FlipX = false
		sprite.FlipY = false
	end
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:hornCobPillTearSplat(tear)
	if not tear:GetData().denySound then
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.1, 0, false, 2.5 - math.max(math.min(tear.Scale, 1.5), 0))
    end
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end
	
	local scale = tear.Scale
	local color = tear:GetSprite().Color

	local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, tear.Position, tear.Velocity:Resized(3), npc)
	--smoke.SpriteScale = Vector(1,1)
	smoke:GetData().longonly = true
	smoke.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	smoke.PositionOffset = tear.PositionOffset
    smoke:Update()
end

-----------------------------------------------------------
-- Multi-Euclidean tear
-----------------------------------------------------------


function mod:multiEuclideanTearRender(tear, offset)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/multieuclidean_tears.anm2", true)
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local prefix = "Regular"
	
	local anim
	if scale <= 0.3 then
		anim = prefix .. "Tear1"
	elseif scale <= 0.55 then
		anim = prefix .. "Tear2"
	elseif scale <= 0.675 then
		anim = prefix .. "Tear3"
	elseif scale <= 0.8 then
		anim = prefix .. "Tear4"
	elseif scale <= 0.925 then
		anim = prefix .. "Tear5"
	elseif scale <= 1.05 then
		anim = prefix .. "Tear6"
	elseif scale <= 1.175 then
		anim = prefix .. "Tear7"
	elseif scale <= 1.425 then
		anim = prefix .. "Tear8"
	elseif scale <= 1.675 then
		anim = prefix .. "Tear9"
	elseif scale <= 1.925 then
		anim = prefix .. "Tear10"
	elseif scale <= 2.175 then
		anim = prefix .. "Tear11"
	elseif scale <= 2.55 then
		anim = prefix .. "Tear12"
	else
		anim = prefix .. "Tear13"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:multiEuclideanTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_SPLATTER, 1, 0, false, 1.0)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale

	local poof = Isaac.Spawn(1000, getNormalTearPoofVariant(tear.Scale, tear.Height), 0, tear.Position, nilvector, tear)	
	--poof:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/multieuclidean_tears_tearpoof.png")
	--poof:GetSprite():LoadGraphics()
	local s = math.sin(tear.FrameCount/24*math.pi)
    local multiEuclidColor = Color(-s*2, -s*2, -s*2, 1, (s+1)/2, (s+1)/2, (s+1)/2)
    multiEuclidColor:SetColorize(1, 1, 1, 1)
	poof:GetSprite().Color = multiEuclidColor
	if scale > 0.8 then
		poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	end
	poof.PositionOffset = tear.PositionOffset
end

-----------------------------------------------------------
-- M90 Bullet tear
-----------------------------------------------------------

function mod:lawnDartTearRender(tear, offset, tvar)
	local data = tear:GetData()
	
	local sprite = data.FFCustomTearSprite
	if not data.FFCustomTearSprite then
		sprite = Sprite()
		sprite:Load("gfx/projectiles/lawndart_tear.anm2", true)
		data.FFCustomTearSprite = sprite
	end
	
	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags
	
	local anim
	if scale <= 0.3 then
		anim = "RegularTear1"
	elseif scale <= 0.55 then
		anim = "RegularTear2"
	elseif scale <= 0.675 then
		anim = "RegularTear3"
	elseif scale <= 0.8 then
		anim = "RegularTear4"
	elseif scale <= 0.925 then
		anim = "RegularTear5"
	elseif scale <= 1.05 then
		anim = "RegularTear6"
	elseif scale <= 1.175 then
		anim = "RegularTear7"
	elseif scale <= 1.425 then
		anim = "RegularTear8"
	elseif scale <= 1.675 then
		anim = "RegularTear9"
	elseif scale <= 1.925 then
		anim = "RegularTear10"
	elseif scale <= 2.175 then
		anim = "RegularTear11"
	elseif scale <= 2.55 then
		anim = "RegularTear12"
	else
		anim = "RegularTear13"
	end
	
	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	
	local adjustedVelocity = tear.Velocity
	if (tear.FallingSpeed < 0 or 0.2 < tear.FallingSpeed) and 
	   flags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and
	   ((flags & TearFlags.TEAR_ABSORB ~= TearFlags.TEAR_ABSORB and flags & TearFlags.TEAR_POP ~= TearFlags.TEAR_POP) or tear.Velocity:Length() <= 0.1) 
	then
		adjustedVelocity = adjustedVelocity + Vector(0, tear.FallingSpeed)
	end
	
	sprite.Rotation = adjustedVelocity:GetAngleDegrees()
	sprite.FlipX = false
	sprite.FlipY = false
	
	sprite.Color = tearsprite.Color
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	
	data.LastRenderFrame = Isaac.GetFrameCount()
end

function mod:lawnDartTearSplat(tear)
	sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 3)
	
	if tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then return end

	local scale = tear.Scale
	local color = tear:GetSprite().Color
	
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, tear.Position, nilvector, tear)
	poof:GetSprite().Color = color
	poof.SpriteScale = Vector(scale * 0.8, scale * 0.8)
	poof.PositionOffset = tear.PositionOffset
	
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.NAIL_PARTICLE, 0, tear.Position, RandomVector()*2, tear):ToEffect()
		gib.m_Height = math.min(-5, tear.Height)
		gib:GetSprite().Color = color
		gib.State = 2
	end
end