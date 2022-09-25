local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local paused
local pausedAt
local pauseDuration = 0
local forceUnpause
local justForcedUnpause

local projectileCache = {}

local function getScreenBottomRight()
    return game:GetRoom():GetRenderSurfaceTopLeft() * 2 + Vector(442,286)
end

local function getScreenCenterPosition()
    return getScreenBottomRight() / 2
end

function mod.PauseGame(frames, force)
	if game:GetRoom():GetBossID() ~= 54 or force then -- Intentionally fail achievement note pauses on Lamb, since it breaks the Victory Lap menu super hard
		for _, projectile in pairs(Isaac.FindByType(9)) do
			projectile:Remove()

			local poof = Isaac.Spawn(1000, 15, 0, projectile.Position, Vector.Zero, nil)
			poof.SpriteScale = Vector.One * 0.75
		end

		for _, pillar in pairs(Isaac.FindByType(951, 1)) do
			pillar:Kill()
			pillar:Remove()
		end

		pausedAt = pausedAt or game:GetFrameCount()
		pauseDuration = pauseDuration + frames
		paused = true

		Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
	end
end

function mod.IsForcingUnpause(hook, action)
	if hook and action then
		return hook == InputHook.GET_ACTION_VALUE and action == ButtonAction.ACTION_SHOOTDOWN and (forceUnpause or justForcedUnpause)
	else
		return forceUnpause or justForcedUnpause
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	justForcedUnpause = nil
	if pausedAt and pausedAt + pauseDuration < game:GetFrameCount() then
		paused = false
		pausedAt = nil
		pauseDuration = 0

		forceUnpause = true
	end
end)

for hook = InputHook.IS_ACTION_PRESSED, InputHook.IS_ACTION_TRIGGERED do
	mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
		if paused and action ~= ButtonAction.ACTION_CONSOLE then
			return false
		end
	end, hook)
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
	if paused and action ~= ButtonAction.ACTION_CONSOLE then
		return 0
	elseif forceUnpause and action == ButtonAction.ACTION_SHOOTDOWN then
		forceUnpause = false
		justForcedUnpause = true
		return 0.75
	end
end, InputHook.GET_ACTION_VALUE)

local giantbookSprite = Sprite()
local giantbookUpdate = false
local renderGiantbook = false

function mod.PlayGiantbook(gfx, animation, duration, anm2Override)
	if Options.DisplayPopups then
		animation = animation or "Appear"
		duration = duration or 33

		mod.PauseGame(duration, true)

		giantbookSprite:Load(anm2Override or "gfx/ui/giantbook/_ff_giantbook_generic.anm2", true)
		giantbookSprite:ReplaceSpritesheet(0, gfx)
		giantbookSprite:LoadGraphics()
		giantbookSprite:Play(animation, true)

		giantbookUpdate = false
		renderGiantbook = true
	end
end

local achievementSprite = Sprite()
local achievementUpdate = false
local renderAchievement = false

achievementSprite:Load("gfx/ui/achievement/_ff_achievement.anm2", true)

local achievementNoteQueue = {}
function mod.QueueAchievementNote(gfx)
	table.insert(achievementNoteQueue, gfx)
end

function mod.PlayAchievementNote(gfx)
	if Options.DisplayPopups then
		mod.PauseGame(41)

		achievementSprite:ReplaceSpritesheet(2, gfx)
		achievementSprite:LoadGraphics()
		achievementSprite:Play("Idle", true)

		achievementUpdate = false
		renderAchievement = true

		sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK)
	end
end

function mod.IsPlayingAchievementNote()
	return renderAchievement
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local player = Isaac.GetPlayer()
	if not renderAchievement and #achievementNoteQueue > 0 
	and (not DeadSeaScrollsMenu or (not DeadSeaScrollsMenu.IsOpen() and (not DeadSeaScrollsMenu.QueuedMenus or #DeadSeaScrollsMenu.QueuedMenus == 0))) 
	and player.ControlsEnabled and player.ControlsCooldown == 0 then
		mod.PlayAchievementNote(achievementNoteQueue[1])
		table.remove(achievementNoteQueue, 1)
	end
end)

local function doRender()
	if renderGiantbook then
		if giantbookUpdate then
			giantbookSprite:Update()
		end
		giantbookUpdate = not giantbookUpdate

		local position = getScreenCenterPosition()
		giantbookSprite:Render(position, Vector.Zero, Vector.Zero)

		if giantbookSprite:IsFinished() then
			renderGiantbook = false
		end
	end

	if renderAchievement then
		if achievementUpdate then
			achievementSprite:Update()
		end
		achievementUpdate = not achievementUpdate
	
		local position = getScreenCenterPosition()
		achievementSprite:Render(position, Vector.Zero, Vector.Zero)

		if achievementSprite:IsFinished() then
			renderAchievement = false
		end
	end
end

if StageAPI then
	mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName) -- Hijack the existance of the StageAPI shader to render over the hud
		if shaderName == "StageAPI-RenderAboveHUD" then
			doRender()
		end
	end)
else
	mod:AddCallback(ModCallbacks.MC_POST_RENDER, doRender)
end

-- Just in case
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
	paused = nil
	pausedAt = nil
	pauseDuration = 0
	forceUnpause = nil
	justForcedUnpause = nil
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	paused = nil
	pausedAt = nil
	pauseDuration = 0
	forceUnpause = nil
	justForcedUnpause = nil
end)