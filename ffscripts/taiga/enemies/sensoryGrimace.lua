-- Sensory Grimace --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:sensoryGrimaceAI(npc, sprite, npcdata)
	npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
	npc.Velocity = nilvector
	
	if not npcdata.init then
		npcdata.fireDirection = npc.SubType & 3
		npcdata.movementDirection = (npc.SubType >> 2) & 3
		npcdata.stayActive = (npc.SubType >> 4) & 1 == 1
		
		if npcdata.fireDirection == 0 then
			npcdata.AnimSuffix = "Up"
		elseif npcdata.fireDirection == 1 then
			npcdata.AnimSuffix = "Down"
		elseif npcdata.fireDirection == 2 then
			npcdata.AnimSuffix = "Left"
		elseif npcdata.fireDirection == 3 then
			npcdata.AnimSuffix = "Right"
		end
		
		if npcdata.movementDirection == 0 then
			--sprite:ReplaceSpritesheet(0, "gfx/enemies/sensory grimace/sensory_grimace_up.png")
			--sprite:LoadGraphics()
		elseif npcdata.movementDirection == 1 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/sensory grimace/sensory_grimace_down.png")
			sprite:LoadGraphics()
		elseif npcdata.movementDirection == 2 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/sensory grimace/sensory_grimace_left.png")
			sprite:LoadGraphics()
		elseif npcdata.movementDirection == 3 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/sensory grimace/sensory_grimace_right.png")
			sprite:LoadGraphics()
		end
		
		npcdata.FireCooldown = 0
		npcdata.wasIdle = true
		npcdata.init = true
	end

	if npc.State ~= 16 or npcdata.stayActive then
		npc.State = 0
		npcdata.started = true
		
		npcdata.FireCooldown = math.max((npcdata.FireCooldown or 0) - 1, 0)
		
		local reacting = false
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			local movement = player:GetMovementVector()
			
			if movement.X ~= 0.0 or movement.Y ~= 0.0 then
				local movementAngle = movement:GetAngleDegrees()
			
				local checkingForAngle
				if npcdata.movementDirection == 0 then
					checkingForAngle = 270
				elseif npcdata.movementDirection == 1 then
					checkingForAngle = 90
				elseif npcdata.movementDirection == 2 then
					checkingForAngle = 180
				elseif npcdata.movementDirection == 3 then
					checkingForAngle = 0
				end
				
				if math.abs(movementAngle - checkingForAngle) <= 45.0 or 
				   math.abs((movementAngle + 360) - checkingForAngle) <= 45.0 or
				   math.abs((movementAngle - 360) - checkingForAngle) <= 45.0
				then
					reacting = true
					break
				end
			end
		end
		
		if reacting then
			if not sprite:IsPlaying("Shoot" .. npcdata.AnimSuffix) then
				sprite:Play("Shoot" .. npcdata.AnimSuffix, true)
			end
			
			if npcdata.wasIdle then
				sfx:Play(SoundEffect.SOUND_STONESHOOT, 1, 0, false, 0.4)
			end
			
			if npcdata.FireCooldown == 0 then
				local params = ProjectileParams()
				params.Scale = math.random() * 0.15 + 0.45
				params.FallingAccelModifier = -0.2
				params.FallingSpeedModifier = 3
				params.HeightModifier = 17
				
				if npcdata.fireDirection == 0 then
					npc:FireProjectiles(npc.Position + Vector(0, 2), Vector(0, -8), 0, params)
				elseif npcdata.fireDirection == 1 then
					npc:FireProjectiles(npc.Position + Vector(0, 2), Vector(0, 8), 0, params)
				elseif npcdata.fireDirection == 2 then
					npc:FireProjectiles(npc.Position + Vector(0, 5), Vector(-8, 0), 0, params)
				elseif npcdata.fireDirection == 3 then
					npc:FireProjectiles(npc.Position + Vector(0, 5), Vector(8, 0), 0, params)
				end
				
				sfx:Play(SoundEffect.SOUND_TEARS_FIRE, 0.7, 0, false, 1)
				npcdata.FireCooldown = 5
			end
			
			npcdata.wasIdle = false
		else
			if not sprite:IsPlaying("Idle" .. npcdata.AnimSuffix) then
				sprite:Play("Idle" .. npcdata.AnimSuffix, true)
			end
			
			npcdata.wasIdle = true
		end
	elseif npc.State == 16 then
		if npcdata.started then
			sprite:Play("CloseEyes", true)
			npcdata.started = nil
		end
		
		if sprite:IsFinished("CloseEyes") then
			sprite:Play("ClosedEyes", true)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, projectile)
	if projectile.SpawnerEntity and projectile.SpawnerEntity.Type == mod.FF.SensoryGrimace.ID and projectile.SpawnerEntity.Variant == mod.FF.SensoryGrimace.Var then
		projectile:GetData().SensoryGrimaceProjectile = true
		projectile.Size = 10
	end
end)

function mod.sensoryGrimaceProjectiles(projectile, data)
	if data.SensoryGrimaceProjectile then
		local room = game:GetRoom()
		local gridIndex = room:GetGridIndex(projectile.Position)
		local gridPosition = room:GetGridPosition(gridIndex)
		
		local spawnerIndex = -1
		local spawnerInitSeed = -1
		if projectile.SpawnerEntity then
			spawnerIndex = projectile.SpawnerEntity.Index
			spawnerInitSeed = projectile.SpawnerEntity.InitSeed
		end
		
		local sensoryGrimaces = Isaac.FindByType(mod.FF.SensoryGrimace.ID, mod.FF.SensoryGrimace.Var, -1, true)
		for _, entity in ipairs(sensoryGrimaces) do
			if entity.Index ~= spawnerIndex and entity.InitSeed ~= spawnerInitSeed and (entity.Position - gridPosition):Length() < 5 then
				projectile:Die()
			end
		end
	end
end