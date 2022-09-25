-- Martyr --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

-- NOTE: Needs special handling for Needle/Pasty sprites (sprite layers plssssssssss)

function mod:handleMartyr(entity, data, sprite)
	data.FFMartyrDuration = data.FFMartyrDuration - 1

	if data.FFMartyrDuration ~= nil then
		if data.FFMartyrIsSubstitute then
			if data.FFMartyrDuration == 0 then
				entity:Remove()
			else
				entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			end
		else
			-- morph the entity back to it's original state and make the game remove them so Cultists actually work and don't crash the game
			if data.FFMartyrDuration == 0 then
				entity:Morph(data.FFMartyrOriginalType, data.FFMartyrOriginalVariant, data.FFMartyrOriginalSubType, -1)
				entity.State = 17
				entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
				entity:Update()
				
				if entity:Exists() then
					sprite:SetFrame(999)
					entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
					entity:Update()
				end
			else
				entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			end
		end

		--entity:RemoveStatusEffects()
		mod:removeStatusEffects(entity, true)

		entity.Position = data.FFMartyrPosition
		entity.Velocity = nilvector

		entity:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR |
		                      EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_DEATH_TRIGGER |
		                      EntityFlag.FLAG_NO_SPIKE_DAMAGE | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE |
		                      EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

		entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		entity.CollisionDamage = 0
		entity:ToNPC().CanShutDoors = false

		local martyrColor = FiendFolio.StatusEffectColors.Martyr
		local color = Color(martyrColor.R, martyrColor.G, martyrColor.B, martyrColor.A, martyrColor.RO, martyrColor.GO, martyrColor.BO)
		if data.FFMartyrDuration > 0 then
			color.A = math.min(color.A, color.A * math.log(data.FFMartyrDuration) / math.log(120))
		else
			color.A = 0
		end

		data.FFMartyrFlashDuration = data.FFMartyrFlashDuration - 1
		if data.FFMartyrFlashDuration > 0 then
			color = Color.Lerp(color, FiendFolio.StatusEffectColors.MartyrFlash, math.log(data.FFMartyrFlashDuration) / math.log(data.FFMartyrFlashDurationMax))
		end

		entity:SetColor(color, 1, 0, false, false)

		if data.FFOriginalSpriteOffset == nil then
			data.FFOriginalSpriteOffset = Vector(entity.SpriteOffset.X, entity.SpriteOffset.Y)
		end
		entity.SpriteOffset = data.FFOriginalSpriteOffset + Vector(0, 2 * math.cos(math.rad((data.FFMartyrDurationMax - data.FFMartyrDuration) * 2)) - 2)

		if data.MartyrAura == nil then
			local source = Isaac.GetPlayer(0)
			if data.FFMartyrSource and data.FFMartyrSource:Exists() then
				source = data.FFMartyrSource
			end
			
			data.MartyrAura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, entity.Position, nilvector, source):ToEffect()
			data.MartyrAura.Parent = entity
			data.MartyrAura.DepthOffset = 1000
			data.MartyrAura:GetSprite().Scale = Vector(entity.Size * FiendFolio.StatusEffectVariables.MartyrAuraScalePerSize, entity.Size * FiendFolio.StatusEffectVariables.MartyrAuraScalePerSize)
			data.MartyrAura:Update()
		end

		sprite.Scale = data.FFMartyrScale or sprite.Scale
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	local data = entity:GetData()
	if data.FFMartyrDuration ~= nil then
		return false
	end
end)

function mod:martyrDeathEffects(entity)
	mod:empathOnEnemyDeath(entity)

	if entity.Type == mod.FF.PsychoFly.ID and entity.Variant == mod.FF.PsychoFly.Var then
		mod.triggerPsychoManicFlies(entity)
	elseif entity.Type == mod.FF.ManicFly.ID and entity.Variant == mod.FF.ManicFly.Var then
		mod.triggerPsychoManicFlies(entity)
	elseif entity.Type == mod.FF.Prick.ID and entity.Variant == mod.FF.Prick.Var then
		mod:prickOnStatusDeath(entity)
	end
end

function mod:spawnSubstituteMartyr(entity, data, sprite)
	if mod:isMartyrWhitelisted(entity) or not (mod:isMartyrBlacklisted(entity) or mod:isStatusBlacklisted(entity)) then
		local substitute = Isaac.Spawn(EntityType.ENTITY_FROZEN_ENEMY, 0, 0, entity.Position, nilvector, nil):ToNPC()
		substitute:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		substitute:PlaySound(SoundEffect.SOUND_DIVINE_INTERVENTION, 1, 0, false, 1 + (0.05 * math.random() - 0.025))
		
		local subdata = substitute:GetData()

		subdata.FFMartyrDuration = data.FFMartyrDurationToSet
		subdata.FFMartyrDurationMax = data.FFMartyrDurationToSet

		subdata.FFMartyrFlashDuration = 15
		subdata.FFMartyrFlashDurationMax = 15

		subdata.FFMartyrPosition = entity.Position
		subdata.FFMartyrSource = data.FFMartyrOnDeathSource

		subdata.FFMartyrOriginalType = entity.Type
		subdata.FFMartyrOriginalVariant = entity.Variant
		subdata.FFMartyrOriginalSubType = entity.SubType
		subdata.FFMartyrOriginalChampion = entity:GetChampionColorIdx()
		
		subdata.FFMartyrIsSubstitute = true

		local filename = sprite:GetFilename()
		local animation = sprite:GetAnimation()
		local frame = sprite:GetFrame()

		local overlayAnimation = sprite:GetOverlayAnimation()
		local overlayFrame = sprite:GetOverlayFrame()

		local flipX = sprite.FlipX
		local flipY = sprite.FlipY
		local offset = sprite.Offset
		local rotation = sprite.Rotation
		local scale = Vector(sprite.Scale.X, sprite.Scale.Y)
		
		local subsprite = substitute:GetSprite()
		subsprite:Load(filename, true)
		subsprite:SetFrame(animation, frame)
		subsprite:SetOverlayFrame(overlayAnimation, overlayFrame)

		subsprite.FlipX = flipX
		subsprite.FlipY = flipY
		subsprite.Offset = offset
		subsprite.Rotation = rotation
		subsprite.Scale = scale

		subdata.FFMartyrScale = scale

		mod:MartyrCompatibilities(substitute, subsprite, subdata, subdata.FFMartyrOriginalType, subdata.FFMartyrOriginalVariant, subdata.FFMartyrOriginalSubType)
		mod:handleMartyr(substitute, subdata, subsprite)
	end
end

function mod:handleMartyrOnDeath(entity, data, sprite)
	if not data.FFForceMartyrOnDeath then
		data.FFMartyrOnDeathDuration = data.FFMartyrOnDeathDuration - 1
	end

	if entity.HitPoints <= 0.0 and not (data.FFBerserkDuration ~= nil and data.FFBerserkDuration >= 0) then
		if mod:checkIfStatusLogicIsApplied(entity, false) then
			if entity:HasEntityFlags(EntityFlag.FLAG_ICE) then
				mod:spawnSubstituteMartyr(entity, data, sprite)
				
				local source = Isaac.GetPlayer(0)
				if data.FFMartyrOnDeathSource and data.FFMartyrOnDeathSource:Exists() then
					source = data.FFMartyrOnDeathSource
				end
				
				data.FFApplyMartyrOnDeath = nil
				data.FFForceMartyrOnDeath = nil
				data.FFMartyrDurationToSet = nil
				data.FFMartyrOnDeathSource = nil
				data.FFMartyrOnDeathDuration = nil
				
				data.FFMartyrUranusDamage = true
				entity:TakeDamage(0.0001, 0, EntityRef(source), 0)
				data.FFMartyrUranusDamage = nil
			else
				data.FFMartyrLastDamageFlag = data.FFMartyrLastDamageFlag or 0
				if data.FFMartyrLastDamageFlag & DamageFlag.DAMAGE_SPAWN_BLACK_HEART ~= 0 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, entity.Position, nilvector, nil)
				end
				if data.FFMartyrLastDamageFlag & DamageFlag.DAMAGE_SPAWN_RED_HEART ~= 0 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, entity.Position, nilvector, nil)
				end
				if data.FFMartyrLastDamageFlag & DamageFlag.DAMAGE_SPAWN_COIN ~= 0 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, entity.Position, nilvector, nil)
				end
				if data.FFMartyrLastDamageFlag & DamageFlag.DAMAGE_SPAWN_TEMP_HEART ~= 0 then
					local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, entity.Position, RandomVector() * (math.random() + 3), nil):ToPickup()
					heart.Timeout = 60
				end
				if data.FFMartyrLastDamageFlag & DamageFlag.DAMAGE_SPAWN_CARD ~= 0 then
					local card = Game():GetItemPool():GetCard(entity.InitSeed, true, false, false)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, entity.Position, nilvector, nil)
				end
				if data.FFMartyrLastDamageFlag & DamageFlag.DAMAGE_SPAWN_RUNE ~= 0 then
					local rune = Game():GetItemPool():GetCard(entity.InitSeed, false, true, true)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, rune, entity.Position, nilvector, nil)
				end

				mod:spawnBKeeperCoin(entity, true)

				mod:martyrDeathEffects(entity)
				FiendFolio.AddMartyr(entity, data.FFMartyrOnDeathSource, data.FFMartyrDurationToSet)
				entity:PlaySound(SoundEffect.SOUND_DIVINE_INTERVENTION, 1, 0, false, 1 + (0.05 * math.random() - 0.025))
				data.FFMartyrOnDeathDuration = 0
			end
		else
			entity:Kill()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	local data = player:GetData()
	
	local isInHallowAura = false
	for i = 0, game:GetRoom():GetGridSize() do
		local grid = game:GetRoom():GetGridEntity(i)
		if grid and grid:GetType() == GridEntityType.GRID_POOP and grid:GetVariant() == 6 and grid.State ~= 1000 then
			if player.Position:Distance(game:GetRoom():GetGridPosition(i)) <= 80.0 then
				isInHallowAura = true
			end
		end
	end
	
	if isInHallowAura then
		data.FFInHallowAura = 4
	elseif data.FFInHallowAura == 4 and Isaac.GetFrameCount() % 2 == 1 then
		data.FFInHallowAura = 3
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local data = player:GetData()
	
	data.FFInHallowAura = math.max((data.FFInHallowAura or 0) - 1, 0)
	
	local isInHallowDipAura = false
	if game:GetFrameCount() % 3 == 0 then
		local dips = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DIP, 6)
		for _, dip in ipairs(dips) do
			if player.Position:Distance(dip.Position) < 33.33 then
				isInHallowDipAura = true
			end
		end
	end
	
	if isInHallowDipAura then
		data.FFInHallowDipAura = 4
	else
		data.FFInHallowDipAura = math.max((data.FFInHallowDipAura or 0) - 1, 0)
	end
	
	local isInBethlehemAura = false
	local stars = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.STAR_OF_BETHLEHEM)
	for _, star in ipairs(stars) do
		if player.Position:Distance(star.Position) <= 80.0 then
			isInBethlehemAura = true
		end
	end
	
	if isInBethlehemAura then
		data.FFInBethlehemAura = 4
	else
		data.FFInBethlehemAura = math.max((data.FFInBethlehemAura or 0) - 1, 0)
	end
	
	local isInMartyrAura = false
	local martyrs = Isaac.FindByType(EntityType.ENTITY_FROZEN_ENEMY)
	for _, martyr in ipairs(martyrs) do
		local martyrdata = martyr:GetData()
		if martyrdata.FFMartyrDuration ~= nil and martyrdata.FFMartyrDuration > 0 then
			if player.Position:Distance(martyr.Position) <= 80.0 * martyr.Size * FiendFolio.StatusEffectVariables.MartyrAuraScalePerSize then
				isInMartyrAura = true
			end
		end
	end
	
	if isInMartyrAura then
		data.FFInMartyrAura = 4
	else
		data.FFInMartyrAura = math.max((data.FFInMartyrAura or 0) - 1, 0)
	end

	local hasBasegameAura = data.FFInHallowAura > 0 or data.FFInHallowDipAura > 0 or data.FFInBethlehemAura > 0
	local hasMartyrAura = data.FFInMartyrAura > 0
	
	if data.FFIsInMartyrAura == nil or data.FFIsInHallowAura == nil or
	   data.FFIsInMartyrAura ~= hasMartyrAura or
	   (data.FFIsInMartyrAura and data.FFIsInHallowAura ~= hasBasegameAura) 
	then
		data.FFIsInHallowAura = hasBasegameAura
		data.FFIsInMartyrAura = hasMartyrAura
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()
	else
		data.FFIsInHallowAura = hasBasegameAura
		data.FFIsInMartyrAura = hasMartyrAura
	end
end)

function mod:MartyrCompatibilities(entity, sprite, data, typ, var, subt)
	if mod.MartyrCompatibilityFunctions[typ .. " " .. var .. " " .. subt] ~= nil then
		mod.MartyrCompatibilityFunctions[typ .. " " .. var .. " " .. subt](entity, sprite, data, typ, var, subt)
	elseif mod.MartyrCompatibilityFunctions[typ .. " " .. var] ~= nil then
		mod.MartyrCompatibilityFunctions[typ .. " " .. var](entity, sprite, data, typ, var, subt)
	elseif mod.MartyrCompatibilityFunctions[typ] ~= nil then
		mod.MartyrCompatibilityFunctions[typ](entity, sprite, data, typ, var, subt)
	end

	local eternals = Isaac.FindByType(EntityType.ENTITY_ETERNALFLY)
	for _, eternal in ipairs(eternals) do
		if eternal.Parent ~= nil and eternal.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
			eternal.Parent = nil
		end
	end

	--[[local exorcists = Isaac.FindByType(EntityType.ENTITY_EXORCIST)
	if #exorcists ~= 0 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0, entity.Position, Vector(8,0):Rotated(math.random() * 360), exorcists[0])
	end]]--

	local minecarts = Isaac.FindByType(EntityType.ENTITY_MINECART)
	for _, minecart in ipairs(minecarts) do
		if minecart.Child ~= nil and minecart.Child.Type == EntityType.ENTITY_FROZEN_ENEMY then
			minecart.Child = nil
		end
	end
end

function mod:isMartyrBlacklisted(entity)
	return entity:IsBoss() or
	       entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or
	       FiendFolio.MartyrBlacklist[entity.Type] or
	       FiendFolio.MartyrBlacklist[entity.Type .. " " .. entity.Variant] or
	       FiendFolio.MartyrBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:isMartyrWhitelisted(entity)
	return FiendFolio.MartyrWhitelist[entity.Type] or
	       FiendFolio.MartyrWhitelist[entity.Type .. " " .. entity.Variant] or
	       FiendFolio.MartyrWhitelist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function FiendFolio.AddMartyr(entity, source, duration)
	local data = entity:GetData()

	if mod:isMartyrWhitelisted(entity) or not (mod:isMartyrBlacklisted(entity) or mod:isStatusBlacklisted(entity)) then
		data.FFMartyrDuration = duration
		data.FFMartyrDurationMax = duration

		data.FFMartyrFlashDuration = 15
		data.FFMartyrFlashDurationMax = 15

		data.FFMartyrPosition = entity.Position
		data.FFMartyrSource = source

		data.FFMartyrOriginalType = entity.Type
		data.FFMartyrOriginalVariant = entity.Variant
		data.FFMartyrOriginalSubType = entity.SubType
		data.FFMartyrOriginalChampion = entity:GetChampionColorIdx()

		local sprite = entity:GetSprite()
		local filename = sprite:GetFilename()
		local animation = sprite:GetAnimation()
		local frame = sprite:GetFrame()

		local overlayAnimation = sprite:GetOverlayAnimation()
		local overlayFrame = sprite:GetOverlayFrame()

		local flipX = sprite.FlipX
		local flipY = sprite.FlipY
		local offset = sprite.Offset
		local rotation = sprite.Rotation
		local scale = Vector(sprite.Scale.X, sprite.Scale.Y)

		entity:BloodExplode()
		entity:Morph(EntityType.ENTITY_FROZEN_ENEMY, 0, 0, -1)

		sprite:Load(filename, true)
		sprite:SetFrame(animation, frame)
		sprite:SetOverlayFrame(overlayAnimation, overlayFrame)

		sprite.FlipX = flipX
		sprite.FlipY = flipY
		sprite.Offset = offset
		sprite.Rotation = rotation
		sprite.Scale = scale

		data.FFMartyrScale = scale

		mod:MartyrCompatibilities(entity, sprite, data, data.FFMartyrOriginalType, data.FFMartyrOriginalVariant, data.FFMartyrOriginalSubType)

		data.GuwahFunctions = nil
	end
end

function FiendFolio.MarkForMartyrDeath(entity, source, duration, force, isCloned)
	local data = entity:GetData()

	if mod:isSegmented(entity) and not isCloned then
		local segments = mod:getSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.MarkForMartyrDeath(segment, source, duration, force, true)
			end
		end
	elseif mod:isBasegameSegmented(entity) and not isCloned then
		local segments = mod:getBasegameSegments(entity)

		for _,segment in ipairs(segments) do
			if segment.InitSeed ~= entity.InitSeed or segment.Index ~= entity.Index then
				FiendFolio.MarkForMartyrDeath(segment, source, duration, force, true)
			end
		end
	end

	if mod:isMartyrWhitelisted(entity) or not (mod:isMartyrBlacklisted(entity) or mod:isStatusBlacklisted(entity)) then
		data.FFApplyMartyrOnDeath = true
		data.FFForceMartyrOnDeath = force
		data.FFMartyrDurationToSet = duration

		data.FFMartyrOnDeathSource = source
		data.FFMartyrOnDeathDuration = 2
	end
end

function mod:martyrOnCheckKill(data, newFlags)
	local returndata = {}
	if data.FFMartyrDuration ~= nil or (data.FFMartyrOnDeathDuration ~= nil and data.FFMartyrOnDeathDuration > 0) then
		returndata.newFlags = newFlags | DamageFlag.DAMAGE_NOKILL
		data.FFMartyrLastDamageFlag = (data.FFMartyrLastDamageFlag or 0) | newFlags
		returndata.sendNewDamage = true
	end
	return returndata
end

function mod:martyrOnApply(entity, source, data)
	if data.ApplyMartyr then
		FiendFolio.MarkForMartyrDeath(entity, source.Entity.SpawnerEntity, data.ApplyMartyrDuration, false)
	end

	if data.ApplyMartyrConfuse then
		entity:AddConfusion(EntityRef(source.Entity.SpawnerEntity), data.ApplyMartyrConfuseDuration, false)
	end
end

function mod:martyrOnUpdate(npc, data, sprite)
	if data.FFMartyrOnDeathDuration ~= nil and data.FFMartyrOnDeathDuration > 0 then
		mod:handleMartyrOnDeath(npc, data, sprite)
	else
		data.FFApplyMartyrOnDeath = false
		data.FFMartyrOnDeathDuration = nil
	end

	if data.FFMartyrDuration ~= nil then
		mod:handleMartyr(npc, data, sprite)
		data.hasFFStatusIcon = false
	end

	data.FFMartyrLastDamageFlag = 0
end

function mod:copyMartyr(copy, copyData, sourceData)
	if mod:isMartyrWhitelisted(copy) or not (mod:isMartyrBlacklisted(copy) or mod:isStatusBlacklisted(copy)) then
		copyData.FFApplyMartyrOnDeath = sourceData.FFApplyMartyrOnDeath
		copyData.FFForceMartyrOnDeath = sourceData.FFForceMartyrOnDeath
		copyData.FFMartyrDurationToSet = sourceData.FFMartyrDurationToSet

		copyData.FFMartyrOnDeathSource = sourceData.FFMartyrOnDeathSource
		copyData.FFMartyrOnDeathDuration = sourceData.FFMartyrOnDeathDuration
	end
end

function mod:updateMartyrDamage(player)
	local data = player:GetData()
	if data.FFIsInMartyrAura and not data.FFIsInHallowAura then
		player.Damage = player.Damage * 1.1
	end
end

function mod:updateMartyrFireDelay(player)
	local data = player:GetData()
	if data.FFIsInMartyrAura and not data.FFIsInHallowAura then
		player.MaxFireDelay = math.max(1, math.floor(player.MaxFireDelay * 0.8))
	end
end

function mod:updateMartyrTearFlags(player)
	local data = player:GetData()
	if data.FFIsInMartyrAura and not data.FFIsInHallowAura then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	end
end

function mod:updateMartyrTearLaserColor(player)
	local data = player:GetData()
	if data.FFIsInMartyrAura and not data.FFIsInHallowAura then
		local tearcolor = Color(1.5, 2.0, 2.0, 1.0, 0/255, 0/255, 0/255)
		player.TearColor = tearcolor
		
		local lasercolor = Color(1.0, 1.0, 1.0, 1.0, 0/255, 0/255, 0/255)
		lasercolor:SetColorize(5.0, 6.0, 6.0, 1)
		player.LaserColor = lasercolor
	end
end
