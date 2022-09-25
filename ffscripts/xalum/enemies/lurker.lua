local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod.lurkerDamageColour 		= Color(0.5, 0.5, 0.5, 1, 0.4, 0, 0)

local lurkerCaches = {}
local lurkerIndexMap = {}

local lurkerAdjacentPositions = {Vector(40, -40), Vector(40, 0), Vector(40, 40), Vector(0, 40), Vector(-40, 40), Vector(-40, 0), Vector(-40, -40), Vector(0, -40)}

mod.LurkerSpawnFlag = {
	LEAVE_BRIDGE = 1 << 2,
}

mod.LurkerSpriteKey = {
	RIGHT_UP	= 1 << 0,
	RIGHT 		= 1 << 1,
	RIGHT_DOWN 	= 1 << 2,
	DOWN 		= 1 << 3,
	LEFT_DOWN	= 1 << 4,
	LEFT 		= 1 << 5,
	LEFT_UP		= 1 << 6,
	UP 			= 1 << 7,
}

mod.LurkerTestKey = {
	RIGHT_DOWN 	= mod.LurkerSpriteKey.RIGHT | mod.LurkerSpriteKey.DOWN,
	LEFT_DOWN 	= mod.LurkerSpriteKey.LEFT	| mod.LurkerSpriteKey.DOWN,
	LEFT_UP 	= mod.LurkerSpriteKey.LEFT 	| mod.LurkerSpriteKey.UP,
	RIGHT_UP 	= mod.LurkerSpriteKey.RIGHT | mod.LurkerSpriteKey.UP,
}

mod.LurkerPropChecks = {
	{mod.LurkerSpriteKey.DOWN, "Bottom"},
	{mod.LurkerSpriteKey.LEFT, "Left"},
	{mod.LurkerSpriteKey.RIGHT, "Right"},
	{mod.LurkerSpriteKey.UP, "Top"},
}

mod.LurkerAdjacentsKey = mod.LurkerTestKey.RIGHT_DOWN | mod.LurkerTestKey.LEFT_UP

mod.LurkerFrameReference = include("ffscripts.xalum.enemies.extras.lurker_frame_reference")

function mod.IsNpcLurker(npc)
	return npc.Type == mod.FF.Lurker.ID and npc.Variant >= mod.FF.Lurker.Var and npc.Variant <= mod.FF.LurkerPsuedoDefault.Var
end

function mod.IsLurkerStretch(npc)
	return (
		npc.Variant == mod.FF.LurkerStretch.Var or
		npc.Variant == mod.FF.LurkerStretchCollider.Var
	)
end

function mod.DoesLurkerVariantBlockTears(variant)
	return (
		variant == mod.FF.LurkerCore.Var or
		variant == mod.FF.LurkerTooth.Var
	)
end

function mod.ShouldTearPassThroughLurker(tear, collider)
	return (
		not mod.DoesLurkerVariantBlockTears(collider.Variant) or
		collider:GetData().animState == "EyeDie"
	)
end

function mod.GetLurkers(group)
	if not lurkerCaches[group] then
		lurkerCaches[group] = {}
		for _, entity in pairs(Isaac.FindByType(mod.FF.Lurker.ID, -1, group)) do
			if mod.IsNpcLurker(entity) then
				table.insert(lurkerCaches[group], entity)
			end
		end
	end

	return lurkerCaches[group]
end

function mod.CountCores(group)
	return Isaac.CountEntities(nil, mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var, group)
end

function mod.GetLurkerIndexMap(group)
	if not lurkerIndexMap[group] then
		lurkerIndexMap[group] = {}

		local room = game:GetRoom()
		local lurkers = mod.GetLurkers(group)

		for _, segment in pairs(lurkers) do
			local index = room:GetGridIndex(segment.Position)
			lurkerIndexMap[group][index] = true
		end
	end

	return lurkerIndexMap[group]
end

function mod.GetLurkerStretchMap(group)
	local map = {}
	local room = game:GetRoom()
	local lurkers = Isaac.FindByType(mod.FF.LurkerStretch.ID, mod.FF.LurkerStretch.Var, group)

	for _, segment in pairs(lurkers) do
		local index = room:GetGridIndex(segment.Position)
		map[index] = segment
	end

	return map
end

function mod.GetLurkerSpriteKey(npc)
	local indexMap = mod.GetLurkerIndexMap(npc.SubType)
	local room = game:GetRoom()

	local key = 0

	for i, offset in pairs(lurkerAdjacentPositions) do
		local testPosition = npc.Position + offset
		local index = room:GetGridIndex(testPosition)

		if indexMap[index] then
			key = key | 1 << (i - 1)
		end
	end

	local oldKey = key

	for keyName, testMask in pairs(mod.LurkerTestKey) do
		if key & testMask ~= testMask then
			key = key & ~ mod.LurkerSpriteKey[keyName]
		end
	end

	npc:GetData().lurkerSpriteKey = key
	return key
end

function mod.GetLurkerAnimationFrame(npc)
	local spriteKey = mod.GetLurkerSpriteKey(npc)
	if spriteKey == 0 and math.random() <= 0.5 then spriteKey = 256 end 

	local animationFrame = mod.LurkerFrameReference[spriteKey]
	return animationFrame or 0
end

function mod.IsLurkerDeepLurker(npc)
	local room = game:GetRoom()
	local belowGrid = room:GetGridEntityFromPos(npc.Position + Vector(0, 40))
	local belowIndex = room:GetGridIndex(npc.Position + Vector(0, 40))
	local belowLurker = false

	for i = 0, 3 do
		local indexMap = mod.GetLurkerIndexMap(i)
		if indexMap and indexMap[belowIndex] then
			belowLurker = true
		end
	end

	return (
		belowGrid and
		belowGrid:GetType() == GridEntityType.GRID_PIT and
		not belowLurker
	)
end

function mod.BreakLurkerTooth(npc)
	for i = 1, 4 do
		Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector() * 2, npc):Update()
	end

	npc:BloodExplode()
	sfx:Play(SoundEffect.SOUND_BONE_SNAP)

	npc.Variant = mod.FF.LurkerPsuedoDefault.Var
	npc:GetSprite():RemoveOverlay()
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	if mod.IsNpcLurker(npc) then
		if npc.Variant == mod.FF.LurkerBrain.Var then
			npc.EntityCollisionClass = 0
			npc.DepthOffset = -1000
			npc.Visible = false

			sfx:Play(mod.Sounds.LurkerIdle)
		elseif npc.Variant == mod.FF.LurkerCollider.Var or mod.IsLurkerStretch(npc) then
			npc.Visible = false
		elseif npc.Variant < mod.FF.LurkerBrain.Var then
			local room = game:GetRoom()
			local index = room:GetGridIndex(npc.Position)
			room:SpawnGridEntity(index, GridEntityType.GRID_PIT, 0, 0, 0)

			if npc.SubType & mod.LurkerSpawnFlag.LEAVE_BRIDGE > 0 then
				npc.SubType = npc.SubType - mod.LurkerSpawnFlag.LEAVE_BRIDGE
				npc:GetData().lurkerWantsToLeaveBridge = true
			end
		end

		npc.RenderZOffset = -10000

		if npc.Variant == mod.FF.LurkerStoma.Var then
			mod.XalumInitNpcRNG(npc)

			npc.RenderZOffset = -9980

			local data = npc:GetData()
			data.params = ProjectileParams()
			data.params.FallingAccelModifier = 1

			data.lastSpit = 0
		end

		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_STATUS_EFFECTS)

		if npc.Variant ~= mod.FF.LurkerCore.Var then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		end

		npc.SplatColor = mod.ColorDullGray
	end
end, mod.FF.LurkerBrain.ID)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	local data = npc:GetData()

	if mod.IsNpcLurker(npc) and not data.lurkerHasPseudoInitialised then -- Pseudo-initialisation
		data.homePosition = npc.Position
		data.lurkerHasPseudoInitialised = true

		local key = mod.GetLurkerAnimationFrame(npc)
		local sprite = npc:GetSprite()

		if mod.IsLurkerDeepLurker(npc) then
			sprite:SetFrame("DeepPit", key)
		else
			sprite:SetFrame("Pit", key)
		end

		if npc.Variant == mod.FF.LurkerBrain.Var then
			lurkerCaches[npc.SubType] = nil

			local room = game:GetRoom()
			local lurkers = mod.GetLurkers(npc.SubType)
			local stretchMap = mod.GetLurkerStretchMap(npc.SubType)

			data.lurkerRenderMap = {}
			data.lurkerBridgeIndexes = {}
			data.lurkerStretchCords = {}

			for _, piece in pairs(lurkers) do
				if piece:Exists() then
					local pieceData = piece:GetData()
					local pieceIndex = room:GetGridIndex(piece.Position)

					pieceData.myLurkerBrain = npc
					if pieceData.lurkerWantsToLeaveBridge then
						table.insert(data.lurkerBridgeIndexes, pieceIndex)
					end

					if piece.Variant == mod.FF.Lurker.Var then
						local pieceSprite = piece:GetSprite()
						local renderData = {piece.Position, pieceSprite:GetAnimation(), pieceSprite:GetFrame(), pieceSprite:GetOverlayAnimation(), pieceSprite:GetOverlayFrame()}
						table.insert(data.lurkerRenderMap, renderData)
					
						piece:Remove()
					elseif piece.Variant == mod.FF.LurkerStretch.Var then
						local collider = Isaac.Spawn(mod.FF.LurkerStretchCollider.ID, mod.FF.LurkerStretchCollider.Var, npc.SubType, piece.Position, Vector.Zero, npc)
						local firstSegmentPosition = piece.Position
						local lastSegmentPosition = firstSegmentPosition
						local counter = 0

						local cord = Isaac.Spawn(mod.FF.LurkerCord.ID, mod.FF.LurkerCord.Var, mod.FF.LurkerCord.Sub, firstSegmentPosition, Vector.Zero, npc):ToEffect()
						local cordSprite = cord:GetSprite()
						cordSprite:SetLastFrame()
						table.insert(data.lurkerStretchCords, cord)

						local finalFrame = cordSprite:GetFrame()

						if stretchMap[pieceIndex + 1] then
							repeat 
								local segment = stretchMap[pieceIndex + counter]
								lastSegmentPosition = segment.Position
								segment:Remove()

								counter = counter + 1
							until not stretchMap[pieceIndex + counter]

							cordSprite.Rotation = -90
						elseif stretchMap[room:GetGridIndex(piece.Position + Vector(0, 40))] then
							repeat 
								local segment = stretchMap[room:GetGridIndex(piece.Position + Vector(0, 40) * counter)]
								lastSegmentPosition = segment.Position
								segment:Remove()

								counter = counter + 1
							until not stretchMap[room:GetGridIndex(piece.Position + Vector(0, 40) * counter)]
						else
							local indexMap = mod.GetLurkerIndexMap(npc.SubType)
							if indexMap[pieceIndex + 1] then
								cordSprite.Rotation = -90
							end

							piece:Remove()
						end

						collider.Position = (firstSegmentPosition + lastSegmentPosition) / 2
						collider:SetSize(8, Vector.One + Vector(0, (firstSegmentPosition:Distance(lastSegmentPosition) + 40) / 16 -0.5):Rotated(cord.SpriteRotation), 0)

						cord.Position = cord.Position - Vector(0, 20):Rotated(cord.SpriteRotation) - Vector(52/40, 0):Rotated(-cord.SpriteRotation)
						
						local cordLength = firstSegmentPosition:Distance(lastSegmentPosition)
						local cordFrame = math.floor(cordLength / 40 + 0.5)

						if cordFrame > finalFrame then
							local spriteExtension = (cordFrame + 41/40) / (finalFrame + 1)
							cord.SpriteScale = Vector(1, spriteExtension)
							
							cordFrame = finalFrame
						end

						cordSprite:SetFrame("Idle", cordFrame)
						cord.RenderZOffset = -10000
					end
				end
			end

			lurkerCaches[npc.SubType] = nil
		elseif npc.Variant == mod.FF.LurkerCore.Var then
			sprite:SetOverlayFrame("EyeIdle", 0)
			data.animState = "Idle"

			mod.UpdatePits()
		elseif npc.Variant == mod.FF.Lurker.Var then
			local hasSideProp = false

			if data.lurkerSpriteKey & mod.LurkerAdjacentsKey ~= mod.LurkerAdjacentsKey then
				for _, checkData in pairs(mod.LurkerPropChecks) do
					if data.lurkerSpriteKey & checkData[1] == 0 then
						if math.random() < 1/3 then
							sprite:SetOverlayFrame("EdgeProps" .. checkData[2], math.random(10) - 1)
							hasSideProp = true
							break
						end
					end
				end
			end

			if not hasSideProp and math.random() < 1/3 then
				sprite:SetOverlayFrame("Prop", math.random(90) - 1)
			end
		elseif npc.Variant == mod.FF.LurkerTooth.Var then
			sprite:SetOverlayFrame("ToothIdle", math.random(4) - 1)
		elseif npc.Variant == mod.FF.LurkerStoma.Var then
			sprite:PlayOverlay("MouthIdle")
		end
	end
	
	if mod.IsNpcLurker(npc) then
		mod.NegateKnockoutDrops(npc)

		if npc.Variant ~= mod.FF.LurkerCollider.Var then
			npc.Position = data.homePosition or npc.Position
			npc.Velocity = Vector.Zero
		end
	end

	if npc.Variant == mod.FF.LurkerBrain.Var then -- Actual update nonsense
		npc.Position = npc:GetPlayerTarget().Position
		npc.HitPoints = npc.MaxHitPoints

		if Isaac.CountEntities(nil, mod.FF.Lurker.ID, mod.FF.Lurker.Var, npc.SubType) > 0 then
			if not data.lurkerColliders or #data.lurkerColliders ~= game:GetNumPlayers() then
				data.lurkerColliders = {}

				for _, oldCollider in pairs(Isaac.FindByType(mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, npc.SubType)) do
					oldCollider:Remove()
				end

				for i = 1, game:GetNumPlayers() do
					local collider = Isaac.Spawn(mod.FF.LurkerCollider.ID, mod.FF.LurkerCollider.Var, npc.SubType, Vector(-1000, -1000), Vector.Zero, npc)
					table.insert(data.lurkerColliders, collider)
				end
			end
		end

		if data.lurkerColliders then
			for i, collider in pairs(data.lurkerColliders) do
				local playerTarget = Isaac.GetPlayer(i - 1).Position
				local closestTile
				local secondTile
				local distance = 9e9
				local secondDistance = 9e9

				for _, renderData in pairs(data.lurkerRenderMap) do
					local playerDistance = renderData[1]:Distance(playerTarget)

					if playerDistance < distance then
						secondTile = closestTile
						closestTile = renderData[1]
						secondDistance = distance
						distance = playerDistance
					elseif playerDistance < secondDistance then
						secondTile = renderData[1]
						secondDistance = playerDistance
					end
				end

				collider.SizeMulti = Vector.One

				local targetPosition = closestTile
				if secondTile and secondTile:Distance(closestTile) < 45 then
					local stretchDirection = (closestTile - secondTile):Normalized()
					stretchDirection = Vector(math.abs(stretchDirection.X), math.abs(stretchDirection.Y))
					collider.SizeMulti = collider.SizeMulti + stretchDirection
					targetPosition = (closestTile + secondTile) / 2
				end

				collider.Position = targetPosition or collider.Position
				collider.Velocity = Vector.Zero
			end
		end

		if mod.CountCores(npc.SubType) == 0 then
			if data.lurkerBridgeIndexes then
				local room = game:GetRoom()
				for _, index in pairs(data.lurkerBridgeIndexes) do
					local position = room:GetGridPosition(index)
					local projectile = Isaac.Spawn(mod.FF.LurkerBridgeProj.ID, mod.FF.LurkerBridgeProj.Var, 0, position, Vector.Zero, npc):ToNPC()
					local projectileData = projectile:GetData()
					projectileData.FallingAccel = 1.5
					projectileData.FallingSpeed = -math.random(8, 15)
					projectile.SpriteRotation = math.random(60) - 30
					projectile.SplatColor = npc.SplatColor

					projectile:GetSprite().FlipX = math.random() > 0/5
					projectile:GetSprite():SetFrame("Idle", math.random(4) - 1)

					projectile:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
					projectile:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

					npc.Position = position
					npc:BloodExplode()
				end
			end

			if data.lurkerColliders then
				for _, collider in pairs(data.lurkerColliders) do
					collider:Remove()
				end
			end

			for _, cord in pairs(data.lurkerStretchCords) do
				for i = 0, cord:GetSprite():GetFrame() do
					npc.Position = cord.Position + Vector(0, 20):Rotated(cord.SpriteRotation) + i * Vector(0, 40):Rotated(cord.SpriteRotation)
					npc:BloodExplode()
				end

				cord:Remove()
			end

			sfx:Play(mod.Sounds.LurkerDie)
			npc:Remove()
		end
	elseif npc.Variant == mod.FF.LurkerCore.Var then
		local sprite = npc:GetSprite()

		if Isaac.CountEntities(nil, mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, npc.SubType) == 0 then
			Isaac.Spawn(mod.FF.LurkerBrain.ID, mod.FF.LurkerBrain.Var, npc.SubType, npc.Position, Vector.Zero, npc)
		end

		if data.animState == "Idle" then
			local overlayAnimation = sprite:GetOverlayAnimation()

			if npc.FrameCount % 3 == 2 then
				if overlayAnimation == "EyeIdle" then
					overlayAnimation = "EyeIdle2"
				elseif overlayAnimation == "EyeIdle2" then
					overlayAnimation = "EyeIdle"
				end
			end

			local lookAngle = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
			local lookFrame = math.floor(lookAngle / 45 + 0.5) + 5
			if lookFrame == 9 then lookFrame = 1 end

			sprite:SetOverlayFrame(overlayAnimation, lookFrame)

			if math.random() < 1/90 then
				data.animState = "EyeBlink"
				sprite:PlayOverlay("EyeBlink")
			end

			if math.random() < 1/600 and not sfx:IsPlaying(mod.Sounds.LurkerIdle) then
				sfx:Play(mod.Sounds.LurkerIdle, 0.5)
			end
		elseif data.animState == "EyeBlink" then
			if sprite:IsOverlayFinished("EyeBlink") then
				data.animState = "Idle"
				sprite:SetOverlayFrame("EyeIdle", 0)
			end
		elseif data.animState == "EyeDie" then
			npc.HitPoints = npc.MaxHitPoints

			if sprite:GetOverlayFrame() % 5 == 3 then
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0)
			end

			if sprite:GetOverlayFrame() % 3 == 2 and sprite:GetOverlayFrame() < 15 then
				local poof = Isaac.Spawn(1000, 2, 1, npc.Position + RandomVector() * math.random() * 20, Vector.Zero, npc)
				poof.Color = npc.SplatColor
			end

			if sprite:IsOverlayFinished("EyeDie") then
				npc.Variant = mod.FF.LurkerPsuedoDefault.Var
				npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)

				if mod.CountCores(npc.SubType) == 0 then
					npc:BloodExplode()
					npc:Die()
				end
			end
		end

		if npc:HasMortalDamage() then
			npc.HitPoints = npc.MaxHitPoints
			data.animState = "EyeDie"
			sprite:PlayOverlay("EyeDie")
		end
	elseif npc.Variant == mod.FF.LurkerStoma.Var then
		local sprite = npc:GetSprite()

		if sprite:IsOverlayPlaying("MouthIdle") and npc.FrameCount >= 45 and npc.FrameCount - data.lastSpit >= 60 then
			local numTomaChunks = Isaac.CountEntities(nil, mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub)

			if npc.FrameCount % 15 == 0 and data.rng:RandomFloat() < 1/(4 + 5 * numTomaChunks) and numTomaChunks < 4 then
				sprite:PlayOverlay("MouthSpit")
				sfx:Play(mod.Sounds.LurkerCharge)
			end
		end

		if sprite:IsOverlayPlaying("MouthSpit") and sprite:GetOverlayFrame() == 13 then
			Isaac.Spawn(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, npc.Position, Vector.Zero, npc):ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc)
			poof.Color = npc.SplatColor
			poof.SpriteScale = Vector(0.75, 0.75)

			local target = npc:GetPlayerTarget().Position
			local targetPosition = npc.Position + (target - npc.Position):Resized(60)

			for i = 0, 1 do
				data.params.Variant = i
				npc:FireBossProjectiles(4, targetPosition, 0, data.params)
			end

			sfx:Play(mod.Sounds.LurkerSpit)
			data.lastSpit = npc.FrameCount
		end

		if sprite:IsOverlayFinished("MouthSpit") then
			sprite:PlayOverlay("MouthIdle")
		end

		npc.HitPoints = npc.MaxHitPoints
		if mod.CountCores(npc.SubType) == 0 then
			npc:BloodExplode()
			npc:Die()
		end
	elseif npc.Variant == mod.FF.LurkerBridgeProj.Var then
		npc.EntityCollisionClass = 0
		npc.SpriteRotation = npc.SpriteRotation + 1
		npc.SpriteOffset = npc.SpriteOffset + Vector(0, data.FallingSpeed)
		data.FallingSpeed = data.FallingSpeed + data.FallingAccel

		if data.FallingSpeed > 0 and npc.SpriteOffset.Y > 0 then
			local room = game:GetRoom()
			local grid = room:GetGridEntityFromPos(npc.Position)

			if grid and grid:GetType() == GridEntityType.GRID_PIT then
				grid:ToPit():MakeBridge(grid)
			end

			local poof = Isaac.Spawn(1000, 2, 0, npc.Position, Vector.Zero, npc)
			poof.Color = npc.SplatColor
			poof.SpriteScale = Vector(0.75, 0.75)

			npc:BloodExplode()
			npc:Remove()
		end
	elseif mod.IsNpcLurker(npc) then
		npc.HitPoints = npc.MaxHitPoints
		if mod.CountCores(npc.SubType) == 0 then
			npc:BloodExplode()
			npc:Die()
		end
	end
end, mod.FF.Lurker.ID)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
	if npc.Variant == mod.FF.LurkerBrain.Var then
		local renderData = npc:GetData().lurkerRenderMap
		local sprite = npc:GetSprite()
		npc.Visible = true

		if renderData then
			for _, data in pairs(renderData) do
				sprite:RemoveOverlay()
				sprite:SetFrame(data[2], data[3])
				sprite:SetOverlayFrame(data[4], data[5])

				sprite:Render(Isaac.WorldToScreen(data[1]), Vector.Zero, Vector.Zero)
			end
		end

		npc.Visible = false
	end
end, mod.FF.LurkerBrain.ID)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider)
	if collider:ToNPC() and mod.IsNpcLurker(collider) then
		if mod.ShouldTearPassThroughLurker(tear, collider) then
			return true
		end

		if collider.Variant == mod.FF.LurkerTooth.Var then
			if mod.DoesTearHaveSpectralFlags(tear) then
				if tear.Variant == TearVariant.KEY or tear.Variant == TearVariant.KEY_BLOOD or mod.DoesTearHaveRockBreakingFlags(tear) then
					mod.BreakLurkerTooth(collider)
				end

				return true
			end

			if tear.Variant == TearVariant.KEY or tear.Variant == TearVariant.KEY_BLOOD or mod.DoesTearHaveRockBreakingFlags(tear) then
				mod.BreakLurkerTooth(collider)

				tear:Die()
				return false
			end

			if tear.Variant == TearVariant.CHAOS_CARD then
				return false
			end

			if mod.DoesTearHaveInstantKillFlags(tear) or mod.DoesTearHavePiercingFlags(tear) or mod.DoesTearHaveStickyFlags(tear) then
				tear:Die()
				return false
			end
		elseif collider.Variant == mod.FF.LurkerCore.Var then
			if tear.Variant == TearVariant.CHAOS_CARD then
				collider:TakeDamage(collider.MaxHitPoints, DamageFlag.DAMAGE_NOKILL, EntityRef(tear.SpawnerEntity), 60)
				return true
			elseif tear:HasTearFlags(TearFlags.TEAR_NEEDLE) then
				collider:TakeDamage(collider.MaxHitPoints, DamageFlag.DAMAGE_NOKILL, EntityRef(tear.SpawnerEntity), 60)
				
				if mod.DoesTearHavePiercingFlags(tear) then
					return true
				else
					tear:Die()
					return false
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider, low)
	if mod.IsNpcLurker(npc) then
		if collider:ToBomb() and collider:ToBomb().IsFetus then
			return true
		elseif collider:ToNPC() and (mod.IsNpcLurker(collider) or collider.GridCollisionClass <= EntityGridCollisionClass.GRIDCOLL_WALLS) then
			return true
		end
	end
end, mod.FF.Lurker.ID)

mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, function(_, bomb, collider)
	if bomb.IsFetus and mod.IsNpcLurker(collider) then
		return true
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	if mod.IsNpcLurker(entity) then
		if entity.Variant == mod.FF.LurkerTooth.Var then
			if flags & (DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_TNT | DamageFlag.DAMAGE_CRUSH) > 0 then
				mod.BreakLurkerTooth(entity)
			end

			return false
		elseif entity.Variant ~= mod.FF.LurkerCore.Var or entity:GetData().animState == "EyeDye" then
			return false
		end

		if flags & DamageFlag.DAMAGE_NOKILL == 0 then
			entity:TakeDamage(amount, flags | DamageFlag.DAMAGE_NOKILL, source, cooldown)
			return false
		end

		local myGroup = mod.GetLurkers(entity.SubType)
		for _, lurker in pairs(myGroup) do
			lurker:SetColor(mod.lurkerDamageColour, 2, 0, false, false)

			local data = lurker:GetData()
			if lurker.Variant == mod.FF.LurkerBrain.Var and data.lurkerStretchCords then
				for _, cord in pairs(data.lurkerStretchCords) do
					cord:SetColor(mod.lurkerDamageColour, 2, 0, false, false)
				end
			end
		end
	end
end, mod.FF.Lurker.ID)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.FrameCount == 1 and effect.SpawnerType == mod.FF.LurkerTooth.ID and effect.SpawnerVariant == mod.FF.LurkerTooth.Var then
		local sprite = effect:GetSprite()
		sprite:ReplaceSpritesheet(0, "gfx/grid/morbus/morbus_rocks.png")
		sprite:LoadGraphics()
		sprite:SetFrame("rubble_alt", math.random(4) - 1)
	end
end, 4)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function()
	for _, tooth in pairs(Isaac.FindByType(mod.FF.LurkerTooth.ID, mod.FF.LurkerTooth.Var, -1)) do
		mod.BreakLurkerTooth(tooth)
	end
end, Card.RUNE_HAGALAZ)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	lurkerIndexMap = {}
	lurkerCaches = {}
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	lurkerIndexMap = {}
	lurkerCaches = {}
end, CollectibleType.COLLECTIBLE_D7)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider)
	if mod.IsNpcLurker(collider) then
		if collider.Variant == mod.FF.LurkerTooth.Var or collider.Variant == mod.FF.LurkerCore.Var then
			return false
		else
			return true
		end
	end
end, TearVariant.ERASER)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
	for _, npc in pairs(Isaac.FindByType(mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var)) do
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end
end, CollectibleType.COLLECTIBLE_MEAT_CLEAVER)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	for _, npc in pairs(Isaac.FindByType(mod.FF.LurkerCore.ID, mod.FF.LurkerCore.Var)) do
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end
end, CollectibleType.COLLECTIBLE_MEAT_CLEAVER)