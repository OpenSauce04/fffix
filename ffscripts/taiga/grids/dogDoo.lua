-- Dog Doo --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.DogDooGrid = StageAPI.CustomGrid("FFDogDoo", {
    BaseType = GridEntityType.GRID_POOP,
    BaseVariant = StageAPI.PoopVariant.Golden,
    Anm2 = "gfx/grid/grid_dog_doo_invis.anm2",
    RemoveOnAnm2Change = true,
    Animation = "State1",
    OverrideGridSpawns = true,
    CustomPoopGibs = true,
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1036}
})

local function spawnDogDooGFX(customGrid)
	if customGrid.GridIndex ~= nil and game:GetRoom():GetGridEntity(customGrid.GridIndex) ~= nil then
		local gridSprite = game:GetRoom():GetGridEntity(customGrid.GridIndex):GetSprite()

		local staticGfx = Isaac.Spawn(EntityType.ENTITY_DOGMA, 920, 0, game:GetRoom():GetGridPosition(customGrid.GridIndex), nilvector, nil):ToNPC()
		staticGfx.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		staticGfx:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		staticGfx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		staticGfx.CanShutDoors = false

		local staticSprite = staticGfx:GetSprite()
		staticSprite:SetFrame("State1", "999")

		staticGfx.DepthOffset = -9999
		customGrid.Data.StaticGfx = staticGfx
	end
end

local function spawnDogDooHelperGFX(projectileHelper)
	local gridSprite = projectileHelper:GetSprite()

	local staticGfx = Isaac.Spawn(EntityType.ENTITY_DOGMA, 920, 0, Vector(3000,3000), nilvector, nil):ToNPC()
	staticGfx.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	staticGfx:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
	staticGfx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	staticGfx.CanShutDoors = false
	staticGfx.Visible = false

	local staticSprite = staticGfx:GetSprite()
	staticSprite:SetFrame(gridSprite:GetAnimation(), gridSprite:GetFrame())
	if gridSprite:GetAnimation() == "State1" then
		staticSprite:SetFrame(gridSprite:GetAnimation(), 999)
	end

	projectileHelper:GetData().StaticGfx = staticGfx
	projectileHelper.Child = staticGfx
	staticGfx.Parent = projectileHelper
end

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
	spawnDogDooGFX(customGrid)
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
	sfx:Play(mod.Sounds.GodheadTearsCopy, 0.7, 0, false, 1.5)

    local player = Isaac.GetPlayer(0)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false, false, true, false)
	player:StopExtraAnimation()
	player:GetData().ReadyToPreventGlowingHourGlassAnim = true
	player.Visible = false
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
	if customGrid.GridIndex ~= nil and game:GetRoom():GetGridEntity(customGrid.GridIndex) ~= nil then
		local grid = game:GetRoom():GetGridEntity(customGrid.GridIndex)

		if not (customGrid.Data.StaticGfx and customGrid.Data.StaticGfx:Exists()) then
			spawnDogDooGFX(customGrid)
		end

		local gridSprite = grid:GetSprite()

		local staticGfx = customGrid.Data.StaticGfx
		local staticSprite = staticGfx:GetSprite()
		staticSprite:SetFrame(gridSprite:GetAnimation(), gridSprite:GetFrame())
		if gridSprite:GetAnimation() == "State1" then
			staticSprite:SetFrame(gridSprite:GetAnimation(), 999)
		end

		staticGfx.Position = game:GetRoom():GetGridPosition(customGrid.GridIndex)
		staticGfx.Velocity = nilvector
		staticGfx.DepthOffset = -9999
	elseif customGrid.Data.StaticGfx and customGrid.Data.StaticGfx:Exists() then
		customGrid.Data.StaticGfx:Remove()
		customGrid.Data.StaticGfx = nil
    end
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_REMOVE_CUSTOM_GRID", 1, function(customGrid, keepBaseGrid)
    if not keepBaseGrid and customGrid.Data.StaticGfx and customGrid.Data.StaticGfx:Exists() then
		customGrid.Data.StaticGfx:Remove()
		customGrid.Data.StaticGfx = nil
    end
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", 1, function(customGrid, projectileHelper, holdingEntity)
    projectileHelper:GetData().FFDogDooProj = true
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_PROJECTILE_UPDATE", 1, function(customGrid, projectile)
    projectile:GetData().FFDogDooProj = true
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_POOP_GIB_SPAWN", 1, function(customGrid, effect)
    local clone = Isaac.Spawn(effect.Type, effect.Variant, effect.SubType, effect.Position, effect.Velocity, nil)
	local rand = math.random(200) + 27
    if clone.Variant == EffectVariant.POOP_PARTICLE then
        clone:GetSprite().Color = Color(0.0, 0.0, 0.0, 1.0, rand / 255, rand / 255, rand / 255)
    else
        clone:GetSprite().Color = Color(0.0, 0.0, 0.0, 0.7, rand / 255, rand / 255, rand / 255)
    end

    effect.Visible = false
    effect:Remove()
end, "FFDogDoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    familiar.Visible = false
    familiar:Remove()
end, "FFDogDoo")

mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
	if npc.Variant == 920 then
		npc.Visible = false
		if not npc.Parent then
			npc:Remove()
		else
			npc.Position = Vector(3000,3000)
			npc.Velocity = nilvector
		end
		return true
	end
end, EntityType.ENTITY_DOGMA)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)

		if player:GetData().ReadyToPreventGlowingHourGlassAnim then
			player.Visible = true

			player:GetData().ReadyToPreventGlowingHourGlassAnim = nil
			player:GetData().PreventGlowingHourGlassAnim = true
		end
	end
end)

local emptySprite = Sprite()
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player:GetData().PreventGlowingHourGlassAnim then
		local holding = player:IsHoldingItem()

		player:AnimateLightTravel()
		player:StopExtraAnimation()

		player:GetData().PreventGlowingHourGlassAnim = nil
		player:Update()
		if not holding then
			player:GetData().PreventGlowingHourGlassAnim = true
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if tear:GetData().FFDogDooProj then
		if tear:IsDead() then
			sfx:Play(mod.Sounds.GodheadTearsCopy, 0.7, 0, false, 1.5)

			local player = Isaac.GetPlayer(0)
			player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false, false, true, false)
			player:StopExtraAnimation()
			player:GetData().ReadyToPreventGlowingHourGlassAnim = true
			player.Visible = false
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear)
	if tear:GetData().FFDogDooProj then
		sfx:Play(mod.Sounds.GodheadTearsCopy, 0.7, 0, false, 1.5)

		local player = Isaac.GetPlayer(0)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false, false, true, false)
		player:StopExtraAnimation()
		player:GetData().ReadyToPreventGlowingHourGlassAnim = true
		player.Visible = false
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect, offset)
	if effect:GetData().FFDogDooProj then
		local projData = effect:GetData()

		if not (projData.StaticGfx and projData.StaticGfx:Exists()) then
			spawnDogDooHelperGFX(effect)
		end

		projData.StaticGfx:GetSprite():Render(Isaac.WorldToRenderPosition(effect.Position + effect.PositionOffset) + offset, nilvector, nilvector)
	end
end, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, function(_, tear, offset)
	if tear:GetData().FFDogDooProj then
		local projData = tear:GetData()

		if not (projData.StaticGfx and projData.StaticGfx:Exists()) then
			spawnDogDooHelperGFX(tear)
		end

		tear:GetData().StaticGfx:GetSprite():Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, nilvector, nilvector)
	end
end, TearVariant.GRIDENT)
