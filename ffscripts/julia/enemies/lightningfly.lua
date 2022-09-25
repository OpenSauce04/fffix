local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--lightning flies
function mod:lightningFlyAI(npc, sprite, npcdata)
	npcdata.flies = {}

	local charged_duration = 60
	local fly_duration = 60
	local move_speed = 2
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)

	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		npc:Morph(13, 0, 0, -1)
	end

	if npcdata.state == "init" then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.StateFrame = 0
		npcdata.state = "fly"
	elseif npcdata.state == "fly" then
		if not sprite:IsPlaying("Fly") then
			sprite:Play("Fly",0)
			npc.StateFrame = 0
		end

		npc.StateFrame = npc.StateFrame + 1
		if npc.StateFrame >= fly_duration and not mod:isScareOrConfuse(npc) then
			npcdata.state = "charged"
			npc.StateFrame = 0
		end
	elseif npcdata.state == "charged" then
		if not sprite:IsPlaying("FlyCharged") then
			sprite:Play("FlyCharged",0)
			npc.StateFrame = 0
		end
		move_speed = 3;

		--Sort out later

		npc.StateFrame = npc.StateFrame + 1
		if npc.StateFrame >= charged_duration or mod:isScareOrConfuse(npc) then
			npcdata.state = "fly"
			sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
			npc.StateFrame = 0
		end
	else npcdata.state = "init" end

	if npcdata.state == "charged" and not sfx:IsPlaying(mod.Sounds.LightningFlyBuzzLoop) and not npc:HasMortalDamage() then
		sfx:Play(mod.Sounds.LightningFlyBuzzLoop, 0.5, 0, true, 1)
	end

	if npc:IsDead() then
		local burst = Isaac.Spawn(1000, 3, 0, npc.Position, nilvector, npc):ToEffect()
		burst.SpriteOffset = Vector(0,-14)
	end

	--[[if npc:HasMortalDamage() then
		sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
	end]]

	npcdata.targetvelocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(move_speed))
	npc.Velocity = mod:Lerp(npcdata.targetvelocity, npc.Velocity, 0.8)
end

function mod:lightningFlyHurt(npc)
	local npcdata = npc:GetData()
	if npcdata.state == "charged" then return false end
end
--mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.lightningFlyHurt, 710)