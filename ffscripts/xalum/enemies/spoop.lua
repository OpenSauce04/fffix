local game = Game()
local mod = FiendFolio

mod.NPC_SPOOP_SCARE_RANGE = 140

local spoopColour1 = Color(1, 1, 1, 1, 0, 0, 0)
spoopColour1:SetColorize(1, 1, 1, 1)

local spoopColour2 = Color(1.5, 1.5, 1.5, 0.7, 0, 0, 0)
spoopColour2:SetColorize(1, 1, 1, 1)

local pinch = {
	[0] = 2,
	[1] = 4,
	[2] = 7,
	[3] = 9,
}

local function spoopDie(npc)
	npc:PlaySound(SoundEffect.SOUND_DEMON_HIT, 1, 0, false, 1)

	local poof = Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
	local poofData = poof:GetData()
	local poofSprite = poof:GetSprite()

	poof.Color = spoopColour1

	poofSprite:Load("gfx/1000.144_enemy ghost.anm2", true)
	poofSprite:Play("Explosion")

	poofData.ff_isSpoopPoof = true

	mod.XalumDamageInArea(npc, 40)

	npc:Kill()
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.FrameCount == 4 and effect:GetData().ff_isSpoopPoof then
		local poof = Isaac.Spawn(1000, 15, 0, effect.Position, Vector.Zero, effect)
		local poofSprite = poof:GetSprite()

		poof.Color = spoopColour2

		poofSprite:Load("gfx/1000.034_Fart.anm2", true)
		poofSprite:Play("Explode")
	end
end, 15)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if effect.SubType == mod.FF.SpoopTrail.Sub then
		effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		local data = effect:GetData()
		local sprite = effect:GetSprite()

		if not effect.SpawnerEntity then
			effect:Remove()
		else
			data.ff_spoopFrame = effect.SpawnerEntity:GetData().ff_spoopFrame
			data.ff_spoopFrame = data.ff_spoopFrame and data.ff_spoopFrame - 1 or 3
		end

		sprite:SetFrame("Charge", data.ff_spoopFrame or 0)

		effect.DepthOffset = (data.ff_spoopFrame or 0) - 90

		if data.ff_spoopFrame and data.ff_spoopFrame > 0 then
			local segment = Isaac.Spawn(1000, mod.FF.SpoopTrail.Var, mod.FF.SpoopTrail.Sub, effect.Position - effect.Velocity * 0.3, effect.Velocity, effect)
			segment:Update()

			data.ff_spoopTrail = segment
		end 

		local outline = Isaac.Spawn(1000, mod.FF.SpoopOutline.Var, mod.FF.SpoopOutline.Sub, effect.Position, effect.Velocity, effect)
		outline:GetSprite():SetFrame("ChargeOutline", data.ff_spoopFrame or 0)
		data.ff_spoopOutline = outline

		outline:Update()
	elseif effect.SubType == mod.FF.SpoopOutline.Sub then
		effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		effect.DepthOffset = -100
	end
end, mod.FF.SpoopTrail.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	if effect.SubType == mod.FF.SpoopTrail.Sub or effect.SubType == mod.FF.SpoopOutline.Sub then
		if not (effect.SpawnerEntity and effect.SpawnerEntity:Exists()) then
			effect:Remove()
		end
	end
end, mod.FF.SpoopTrail.Var)

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.rng then
			data.rng = RNG()
			data.rng:SetSeed(npc.InitSeed, 42)

			sprite:Play("Idle")

			npc.SplatColor = mod.ColorGhostly
		end

		if sprite:IsFinished("Move") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("Prepare") then
			sprite:SetFrame("Charge", 4)

			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
			npc:PlaySound(SoundEffect.SOUND_FLOATY_BABY_ROAR, 1, 0, false, 2)

			data.playerTarget = npc:GetPlayerTarget()
			data.playerPosition = data.playerTarget.Position
			local fireDirection = (npc.Position - data.playerTarget.Position):Rotated(60 - 120 * data.rng:RandomInt(2))

			npc.Velocity = fireDirection:Resized(16)

			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

			local segment = Isaac.Spawn(1000, mod.FF.SpoopTrail.Var, mod.FF.SpoopTrail.Sub, npc.Position - npc.Velocity * 0.5, npc.Velocity, npc)
			segment:Update()

			data.ff_spoopTrail = segment

			local outline = Isaac.Spawn(1000, mod.FF.SpoopOutline.Var, mod.FF.SpoopOutline.Sub, npc.Position, npc.Velocity, npc)

			outline:GetSprite():SetFrame("ChargeOutline", 4)
			data.ff_spoopOutline = outline
		end

		if sprite:IsPlaying("Idle") then
			if npc.FrameCount % 60 == 0 or not data.direction or npc:CollidesWithGrid() then
				local room = game:GetRoom()

				local i = 0
				repeat
					data.direction = Vector.FromAngle(data.rng:RandomInt(360)):Resized(3)
					i = i + 1
				until room:IsPositionInRoom(npc.Position + data.direction:Resized(npc.Size * 2), 0) or i >= 32

				if i >= 32 then
					data.direction = (room:GetCenterPos() - npc.Position):Resized(3)
				end
			end

			local targetPosition = npc.Position + data.direction
			local targetVelocity = (targetPosition - npc.Position):Resized(4)

			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.025)

			local nearbyPlayers = Isaac.FindInRadius(npc.Position, mod.NPC_SPOOP_SCARE_RANGE, EntityPartition.PLAYER)
			if npc.FrameCount > 5 and #nearbyPlayers > 0 then
				sprite:Play("Move")
				npc:PlaySound(SoundEffect.SOUND_BABY_HURT, 1, 0, false, 1)

				data.playerTarget = nearbyPlayers[data.rng:RandomInt(#nearbyPlayers) + 1]
			end

			if npc.FrameCount >= npc.SubType * 30 then
				sprite:Play("Prepare")
				npc:PlaySound(SoundEffect.SOUND_BABY_HURT, 1, 0, false, 1.2)
			end
		elseif sprite:IsPlaying("Move") then
			if sprite:GetFrame() == 4 then
				local targetDirection = (npc.Position - data.playerTarget.Position):Resized(5) + (game:GetRoom():GetCenterPos() - npc.Position):Resized(5):Rotated(90 * data.rng:RandomInt(2))

				npc.Velocity = targetDirection:Resized(5)
			end
		elseif sprite:IsPlaying("Prepare") then
			npc.Velocity = npc.Velocity * 0.9
		elseif sprite:GetAnimation() == "Charge" then
			local targetVelocity = (data.playerPosition - npc.Position):Resized(16)
			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.1)

			data.ff_spoopOutline.Velocity = (npc.Position + npc.Velocity) - data.ff_spoopOutline.Position
			if data.ff_spoopOutline.FrameCount == 0 then
				data.ff_spoopOutline:Update()
			end

			if npc.Position:Distance(data.playerPosition) < 15 then
				spoopDie(npc)
			end
		end
	end,
	Collision = function(npc, collider)
		local familiar = collider:ToFamiliar()
		local player = collider:ToPlayer()

		if familiar or player then
			spoopDie(npc)
		end
	end,
	Render = function(npc)
		if npc:GetSprite():GetAnimation() == "Charge" and npc:Exists() then
			local current = npc
			local npcData = npc:GetData()
			local outline = npcData.ff_spoopOutline

			while current:GetData().ff_spoopTrail do
				local trail = current:GetData().ff_spoopTrail
				if trail and trail:Exists() then
					local data = trail:GetData()

					local offset = trail:GetData().ff_spoopFrame
					local maxDistance = pinch[offset] or 2

					trail.Velocity = (trail.SpawnerEntity.Position + trail.SpawnerEntity.Velocity - trail.SpawnerEntity.Velocity:Resized(maxDistance)) - trail.Position

					outline = data.ff_spoopOutline
					if outline and outline:Exists() then
						outline.Velocity = (trail.Position + trail.Velocity) - outline.Position
					end

					current = trail
				end
			end
		end
	end,
}