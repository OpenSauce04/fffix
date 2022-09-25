-- Punted --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function puntedIsPlayerCollider(collider)
	if not collider then
		return false
	elseif collider:ToPlayer() then
		return true
	elseif collider:ToTear() then
		return true
	elseif collider.SpawnerType == EntityType.ENTITY_PLAYER or 
	       collider.SpawnerType == EntityType.ENTITY_TEAR or
	       collider.SpawnerType == EntityType.ENTITY_FAMILIAR
	then
		return true
	elseif collider.Type == mod.FFID.Taiga and collider.Variant == Isaac.GetEntityVariantByName("Punted") and collider:GetData().PuntedFlungByPlayer then
		return true
	else
		return false
	end
end

local function puntedIsEnemyCollider(collider)
	if not collider then
		return false
	elseif collider.Type == mod.FFID.Taiga and collider.Variant == Isaac.GetEntityVariantByName("Punted") and not collider:GetData().PuntedFlungByPlayer then
		return true
	elseif collider:ToNPC() then
		return true
	elseif collider:ToProjectile() then
		return true
	elseif collider.SpawnerType ~= EntityType.ENTITY_PLAYER and 
	       collider.SpawnerType ~= EntityType.ENTITY_TEAR and
	       collider.SpawnerType ~= EntityType.ENTITY_FAMILIAR
	then
		return true
	else
		return false
	end
end

function mod:flingPunted(npc, collider, data)
	if puntedIsPlayerCollider(collider) then
		data.PuntedFlungByPlayer = true
	elseif puntedIsEnemyCollider(collider) then
		data.PuntedFlungByPlayer = false
	else
		return nil
	end

	data.State = "Fling"
	data.PuntedFlungDuration = 10

	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

	npc.Velocity = (npc.Position - collider.Position):Resized(10)
	data.PuntedLastVelocity = npc.Velocity

	--if data.PuntedRNG:RandomInt(2) == 0 then
		data.VisualVariant = ""
	--[[else
		data.VisualVariant = " 2"
	end]]

	local sprite = npc:GetSprite()
	sprite:Play("Fling" .. data.VisualVariant, true)
	npc:PlaySound(SoundEffect.SOUND_PUNCH, 1, 0, false, 1 + (0.3 * data.PuntedRNG:RandomFloat() - 0.15))
	
	return false
end

function mod:puntedAI(npc, sprite, npcdata)
	local room = game:GetRoom()

	if npcdata.init == nil then
		npcdata.init = true

		npcdata.PuntedRNG = RNG()
		npcdata.PuntedRNG:SetSeed(npc.InitSeed, 0)

		local spawnString = "Spawn"
		npcdata.State = "Spawn"
		if npc.SubType == 1 then
			spawnString = "Breathing"
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npcdata.State = "Dead"
			npc.HitPoints = 0
			npcdata.PuntedIsDeathAnimation = true
			npc.CollisionDamage = 0
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		else
			npc.CanShutDoors = true
		end

		--if npcdata.PuntedRNG:RandomInt(2) == 0 then
			npcdata.VisualVariant = ""
		--[[else
			npcdata.VisualVariant = " 2"
		end]]
		sprite:Play(spawnString .. npcdata.VisualVariant, true)

		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
	
	local projectiles = Isaac.FindByType(EntityType.ENTITY_PROJECTILE)
	for _, projectile in ipairs(projectiles) do
		if npcdata.State == "Dead" and projectile.Velocity:Length() >= 1.0 and (npc.Position - projectile.Position):Length() <= npc.Size + projectile.Size then
			mod:flingPunted(npc, projectile, npcdata)
			projectile:Die()
		end
	end

	if sprite:IsFinished("Spawn" .. npcdata.VisualVariant) or sprite:IsFinished("Shoot" .. npcdata.VisualVariant) then
		--if npc.HitPoints / npc.MaxHitPoints > 0.50 then
			sprite:Play("Idle" .. npcdata.VisualVariant, true)
		--[[else
			sprite:Play("Idle Scared" .. npcdata.VisualVariant, true)
		end]]
		npcdata.State = "Idle"
		npcdata.FireCooldown = 75 + (npcdata.PuntedRNG:RandomInt(30) - 15)
	--[[elseif sprite:IsPlaying("Idle" .. npcdata.VisualVariant) and npc.HitPoints / npc.MaxHitPoints <= 0.50 then
		local frame = sprite:GetFrame()
		sprite:Play("Idle Scared" .. npcdata.VisualVariant, true)
		sprite:SetFrame(frame)]]
	--[[elseif npc.HitPoints <= 0.0 and (npcdata.State == "Idle" or npcdata.State == "Shoot") then
		sprite:Play("Fall" .. npcdata.VisualVariant, true)
		npc.CanShutDoors = false
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		npcdata.State = "Fall"]]--
	elseif sprite:IsFinished("Fall" .. npcdata.VisualVariant) then
		sprite:Play("Breathing" .. npcdata.VisualVariant, true)
	elseif sprite:IsFinished("Land" .. npcdata.VisualVariant) then
		sprite:Play("Dead" .. npcdata.VisualVariant, true)
	end

	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	
	local chaseVelMult = 0.1
	if mod:isScare(npc) then
		chaseVelMult = -0.1
	end
	
	if npcdata.State == "Idle" then
		npc.Velocity = npc.Velocity * 0.8 + (targetpos - npc.Position):Resized(chaseVelMult)

		if npcdata.FireCooldown == 0 then
			sprite:Play("Shoot" .. npcdata.VisualVariant)
			npcdata.State = "Shoot"
		else
			npcdata.FireCooldown = npcdata.FireCooldown - 1
		end
	elseif npcdata.State == "Shoot" then
		npc.Velocity = npc.Velocity * 0.8 + (targetpos - npc.Position):Resized(chaseVelMult)
	elseif npcdata.State == "Spawn" or npcdata.State == "Fall" then
		npc.Velocity = npc.Velocity * 0.8
	elseif npcdata.State == "Dead" then
		npc.Velocity = npc.Velocity * 0.8
		npc.CollisionDamage = 0
	elseif npcdata.State == "Fling" then
		npc.CollisionDamage = 1

		if npc:CollidesWithGrid() then
			npc.Velocity = mod.bounceOffWallLegacy(npc.Position, npcdata.PuntedLastVelocity)
		end

		if npc.Velocity:Length() > 10 then
			npc.Velocity = npc.Velocity:Resized(10)
		end

		npcdata.PuntedFlungDuration = npcdata.PuntedFlungDuration - 1
		npc.SpriteOffset = Vector(0, -15 * math.sin(npcdata.PuntedFlungDuration * math.pi / 10))
		if npcdata.PuntedFlungDuration <= 0 then
			if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_PIT then
				npc:Kill()
			else
				sprite:Play("Land" .. npcdata.VisualVariant, true)
			end
		end
	end
	npcdata.PuntedLastVelocity = npc.Velocity

	if sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
		local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, (targetpos - npc.Position):Resized(4), npc):ToProjectile()
		projectile.FallingSpeed = 0
		projectile.FallingAccel = -0.085
		projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
		--projectile.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

		projectile:GetData().PuntedWideWiggle = true
		projectile:GetData().PuntedWideWiggleTrueVelocity = projectile.Velocity
		projectile:GetData().PuntedWideWiggleLastVelocity = projectile.Velocity
		local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc):ToEffect()
		effect.SpriteOffset = Vector(0,-15)
		effect.DepthOffset = npc.Position.Y * 1.25
		effect:FollowParent(npc)
		npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
	elseif sprite:IsEventTriggered("Squish") then
		npc:PlaySound(SoundEffect.SOUND_BLOODBANK_TOUCHED, 1, 0, false, 4 + (0.5 * npcdata.PuntedRNG:RandomFloat() - 0.25))
		if sprite:IsPlaying("Fall" .. npcdata.VisualVariant) then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			if npcdata.State == "Fall" then
				npcdata.State = "Dead"
				if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_PIT then
					npc:Kill()
				end
			end
			npc.CollisionDamage = 0
		end
	elseif sprite:IsEventTriggered("Crunch") then
		npc:PlaySound(SoundEffect.SOUND_BONE_BREAK, 1, 0, false, 0.6 + (0.1 * npcdata.PuntedRNG:RandomFloat() - 0.05))
		if sprite:IsPlaying("Land" .. npcdata.VisualVariant) then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npcdata.State = "Dead"
			npc.CollisionDamage = 0
		end
	end
end

function mod.puntedProjectiles(projectile, data)
	if data.PuntedWideWiggle then
		data.PuntedWideWiggleTrueVelocity = data.PuntedWideWiggleTrueVelocity + (projectile.Velocity - data.PuntedWideWiggleLastVelocity)
		projectile.Velocity = data.PuntedWideWiggleTrueVelocity + data.PuntedWideWiggleTrueVelocity:Rotated(90):Resized(8) * math.cos(projectile.FrameCount * math.pi / 24)
		data.PuntedWideWiggleLastVelocity = projectile.Velocity

		--projectile.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
end

function mod.puntedDeathAnim(npc)
	if not npc:GetData().PuntedIsDeathAnimation then
		local onCustomDeath = function(npc, deathAnim)
			local npcData = npc:GetData()
			local deathAnimData = deathAnim:GetData()
			
			deathAnimData.init = true
			deathAnimData.PuntedIsDeathAnimation = true
			deathAnimData.PuntedRNG = npcData.PuntedRNG
			deathAnimData.VisualVariant = npcData.VisualVariant
			deathAnimData.State = "Fall"
			
			deathAnim.MaxHitPoints = npc.MaxHitPoints
			deathAnim.HitPoints = npc.MaxHitPoints
		end
		FiendFolio.genericCustomDeathAnim(npc, "Fall" .. npc:GetData().VisualVariant, false, onCustomDeath, true, true, false, true)
	end
end

function mod:puntedCollision(npc, collider, low)
	local data = npc:GetData()
	if data.State == "Dead" and (collider.Velocity:Length() >= 1.0 or (collider:ToKnife() and collider:ToKnife():IsFlying())) then
		return mod:flingPunted(npc, collider, data)
	elseif data.State == "Fling" then
		if data.PuntedFlungByPlayer then
			if collider.Type == EntityType.ENTITY_PLAYER then
				return false
			elseif collider:ToNPC() then
				collider:TakeDamage(5, 0, EntityRef(npc), 1)
			end
		end
	end
end

function mod:puntedTakeDmg(entity, damage, flags, source, countdown)
	--if flags & DamageFlag.DAMAGE_NOKILL == 0 then
	--	entity:TakeDamage(damage, flags | DamageFlag.DAMAGE_NOKILL, source, countdown)
	--	return false
	--end
	local data = entity:GetData()
	if data.State == "Dead" and 
	   (flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or 
	    flags & DamageFlag.DAMAGE_LASER) and 
	   source.Entity ~= nil 
	then
		mod:flingPunted(entity:ToNPC(), source.Entity, data)
	end
	
	if data.PuntedIsDeathAnimation then
		return false
	end
end
