local mod = FiendFolio
local game = Game()

local itemID = Isaac.GetItemIdByName("Golden Plum Flute")
__eidItemDescriptions[itemID] = "Summons friendly Golden Plum in the current room for 10 seconds"

local goldenPlumColor = mod.ColorGolden
local shouldCheckForPlumFlute = false
local hookNewPlumFamiliar = false
local hookNewWisp = false

local function IsPlumUsingAttack3(plum)
	local sprite = plum:GetSprite()
	local animation = sprite:GetAnimation()

	return (
		(animation == "Attack3" and sprite:GetFrame() >= 22) or
		animation == "Attack3Loop" or
		animation == "Attack3BackLoop"
	)
end

local function EstimateTearSplatParent(splat)
	for _, plum in pairs(Isaac.FindByType(3, FamiliarVariant.BABY_PLUM)) do
		if plum.Position:Distance(splat.Position) < 50 and IsPlumUsingAttack3(plum) then
			return plum
		end
	end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, flags, slot, vardata)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_PLUM_FLUTE)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		hookNewWisp = true
	end

	if flags & UseFlag.USE_OWNED > 0 then
		hookNewPlumFamiliar = true
	end

	return true
end, itemID)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	if hookNewWisp and familiar.Player:HasCollectible(itemID) then
		hookNewWisp = false
		familiar.Player:AddWisp(CollectibleType.COLLECTIBLE_PLUM_FLUTE, familiar.Position)
		familiar:Remove()
	end
end, FamiliarVariant.WISP)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	if hookNewPlumFamiliar then
		hookNewPlumFamiliar = false

		local data = familiar:GetData()
		data.fiendfolio_championPlumAlt = "golden"
		data.fireAngle = 0

		local sprite = familiar:GetSprite()
		sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/babyplum/boss_babyplum_golden.png")
		sprite:LoadGraphics()
	end
end, FamiliarVariant.BABY_PLUM)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()

	if data.fiendfolio_championPlumAlt == "golden" then
		local sprite = familiar:GetSprite()

		if familiar.FrameCount >= 24 and familiar.FrameCount % 8 == 0 and not (sprite:IsPlaying("Leave") and sprite:WasEventTriggered("Shoot")) then
            local sparkle = Isaac.Spawn(1000, 7003, 0, familiar.Position + Vector(0, 5), Vector.Zero, familiar)
            sparkle.SpriteOffset = Vector(math.random(-20, 20), math.random(-40, -20))
        end

        if IsPlumUsingAttack3(familiar) and familiar.FrameCount % 6 == 0 then
        	local fireDirection = -(familiar.Velocity:Normalized() + Vector((math.random() - 0.5) / 2, (math.random() - 0.5) / 2)) * math.random(2, 4) -- This shit crazy

        	local tear = Isaac.Spawn(2, 1, 0, familiar.Position, fireDirection, familiar):ToTear()
        	tear.Scale = math.random(10, 14) / 10
        	tear.FallingAcceleration = -0.1
        	tear.Height = -10
        end

        if sprite:IsPlaying("Attack1") then
        	local frame = sprite:GetFrame()
        	if frame > 6 and frame < 31 then
        		for i = 0, 41, 41 do
        			local angle = data.fireAngle + i
        			if angle <= 360 then
        				local fireDirection = Vector.FromAngle(angle) * 7

        				local tear = Isaac.Spawn(2, 0, 0, familiar.Position, fireDirection, familiar):ToTear()
        				tear.Height = -30
        			end
        		end

        		data.fireAngle = data.fireAngle + 30
        	end
        end

        if sprite:IsPlaying("Attack2") and sprite:IsEventTriggered("Shoot") then
        	for i = 1, 10 do
        		local fireDirection = RandomVector() * math.random(4, 7)

        		local tear = Isaac.Spawn(2, TearVariant.COIN, 0, familiar.Position, fireDirection, familiar):ToTear()
        		tear:AddTearFlags(TearFlags.TEAR_COIN_DROP)
        		tear.FallingSpeed = math.random(-30, -10)
        		tear.FallingAcceleration = 1 + math.random() * 0.5
        	end
        end
	end
end, FamiliarVariant.BABY_PLUM)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity then
		if tear.SpawnerEntity.Type == 3 and tear.SpawnerEntity.Variant == FamiliarVariant.BABY_PLUM and tear.SpawnerEntity:GetData().fiendfolio_championPlumAlt then
			local spawnerSprite = tear.SpawnerEntity:GetSprite()

			if tear.Variant == 1 then
				if spawnerSprite:IsPlaying("Attack1") or spawnerSprite:IsPlaying("Attack2") then
					tear:Remove()
				else
					tear.Color = goldenPlumColor
				end
			elseif tear.Variant == 0 then
				tear:ChangeVariant(1)
				tear.Color = goldenPlumColor
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, sub, pos, vel, spawner, seed)
    if typ == 1000 and var == 46 and spawner then
    	local realSpawner = mod.XalumFindRealEntity(spawner)

        if realSpawner and spawner.Type == 3 and spawner.Variant == FamiliarVariant.BABY_PLUM and realSpawner:GetData().fiendfolio_championPlumAlt == "golden" then
            return {1000, 32, 0, seed}
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.FrameCount == 1 and not effect.SpawnerEntity then
		local estimatedSpawner = EstimateTearSplatParent(effect)

		if estimatedSpawner then
			if estimatedSpawner:GetData().fiendfolio_championPlumAlt == "golden" then
				effect.Color = mod.ColorPeepPiss
			end
		end
	end
end, 79)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if effect.SpawnerEntity then
		if effect.SpawnerEntity.Type == 3 and effect.SpawnerEntity.Variant == FamiliarVariant.BABY_PLUM and effect.SpawnerEntity:GetData().fiendfolio_championPlumAlt == "golden" then
			effect.Visible = false
			effect:GetData().fiendfolio_championPlumAlt = "golden"
		end
	end
end, 32)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect) -- Hate that this is necessary but idk what else to do about the creep looking fucked on init, calling :Update() didn't work
	if not effect.Visible and effect:GetData().fiendfolio_championPlumAlt == "golden" then
		effect.Visible = true
	end
end, 32)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup.SubType == CollectibleType.COLLECTIBLE_PLUM_FLUTE and shouldCheckForPlumFlute and game:GetRoom():GetType() == RoomType.ROOM_BOSS then
		shouldCheckForPlumFlute = false
		pickup:Morph(5, 100, itemID, true, true)
	end

	if pickup.SubType == itemID and pickup.FrameCount % 6 == 0 then
		local sparkle = Isaac.Spawn(1000, 7003, 0, pickup.Position + Vector(0, 5), Vector.Zero, pickup)
        sparkle.SpriteOffset = Vector(math.random(-15, 15), math.random(-40, -20))
	end
end, 100)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if Isaac.CountEntities(nil, EntityType.ENTITY_BABY_PLUM, 0, mod.FF.GoldenPlum.Sub) < 1 then
		shouldCheckForPlumFlute = false
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	if npc.Variant == 0 and npc.SubType == mod.FF.GoldenPlum.Sub and game:GetRoom():GetType() == RoomType.ROOM_BOSS and mod.ItemsEnabled then
		shouldCheckForPlumFlute = true
	end
end, EntityType.ENTITY_BABY_PLUM)

return itemID