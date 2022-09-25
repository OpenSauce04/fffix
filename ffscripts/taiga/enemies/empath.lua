-- Empath --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:isEmpathBlacklisted(entity)
	return mod.EmpathBlacklist[entity.Type] or
	       mod.EmpathBlacklist[entity.Type .. " " .. entity.Variant] or
	       mod.EmpathBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:empathAI(npc, sprite, npcdata)
	if not npcdata.init then
		npcdata.Home = npc.Position
		npcdata.IntendedVelocity = Vector(0,0)
		npcdata.ActualVelocity = Vector(0,0)
		npcdata.MovementFrame = 0
		npcdata.FramesOutsideHomeRadius = 0

		npcdata.EmpathRNG = RNG()
		npcdata.EmpathRNG:SetSeed(npc.InitSeed, 0)

		npc.SplatColor = FiendFolio.ColorPsy
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

		npcdata.init = true
	end

	if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") then
		sprite:Play("Idle")
	elseif sprite:IsFinished("Death") then
		npc.State = NpcState.STATE_DEATH
	end

	if sprite:IsPlaying("Death") or sprite:IsPlaying("Attack") then
		npc.Velocity = npc.Velocity * 0.60
		npcdata.IntendedVelocity = Vector(0,0)
		npcdata.ActualVelocity = Vector(0,0)
	else
		local intendedVelocity = npcdata.IntendedVelocity * 0.95
		local unintendedVelocity = (npc.Velocity - npcdata.ActualVelocity) * 0.60

		if mod:isScare(npc) then
			local target = npc:GetPlayerTarget()
			local fearVelocity = (target.Position - npc.Position):Resized(-2)
			
			local actualVelocity = mod:Lerp(npcdata.ActualVelocity, fearVelocity, 0.15)
			npc.Velocity = actualVelocity + unintendedVelocity
			npcdata.ActualVelocity = actualVelocity
			
			npcdata.IntendedVelocity = actualVelocity
		else
			local randAngle = npcdata.EmpathRNG:RandomFloat() * 360
			local intendedAngle = intendedVelocity:GetAngleDegrees()

			local offset = math.sin(npcdata.MovementFrame) * 0.125 + 0.125
			local addedAngle
			if intendedVelocity.X == 0.0 and intendedVelocity.Y == 0.0 then
				addedAngle = randAngle
			elseif math.abs(randAngle - intendedAngle) > math.abs((randAngle + 360) - intendedAngle) then
				addedAngle = (randAngle + 360) * (0.5 + offset)  + intendedAngle * (0.5 - offset)
			elseif math.abs(randAngle - intendedAngle) > math.abs((randAngle - 360) - intendedAngle) then
				addedAngle = (randAngle - 360) * (0.5 + offset) + intendedAngle * (0.5 - offset)
			else
				addedAngle = randAngle * (0.5 + offset) + intendedAngle * (0.5 - offset)
			end

			local desiredVelocity = intendedVelocity + Vector.FromAngle(addedAngle):Resized(1/3)
			if desiredVelocity:Length() > 1 then
				desiredVelocity = desiredVelocity:Resized(1)
			end
			local actualVelocity = desiredVelocity:Resized((desiredVelocity:Length() ^ 2) * 0.75)

			if not mod:isConfuse(npc) then
				if ((npc.Position + actualVelocity + unintendedVelocity) - npcdata.Home):Length() > math.max(10, npc.SubType) then
					local homeAngle = (npcdata.Home - (npc.Position + intendedVelocity + unintendedVelocity)):GetAngleDegrees()
					local homeVelocity = Vector.FromAngle(homeAngle):Resized(3)

					desiredVelocity = intendedVelocity + Vector.FromAngle(homeAngle):Resized(1/3)
					if desiredVelocity:Length() > 1 then
						desiredVelocity = desiredVelocity:Resized(1)
					end
					actualVelocity = desiredVelocity:Resized((desiredVelocity:Length() ^ 2) * 0.75)

					local lerpAmount = npcdata.FramesOutsideHomeRadius / 30
					actualVelocity = actualVelocity * (1 - lerpAmount) + homeVelocity * lerpAmount
					npcdata.FramesOutsideHomeRadius = math.min(30, npcdata.FramesOutsideHomeRadius + 1)
				else
					local homeAngle = (npcdata.Home - (npc.Position + actualVelocity + unintendedVelocity)):GetAngleDegrees()
					local homeVelocity = Vector.FromAngle(homeAngle):Resized(3)

					local lerpAmount = npcdata.FramesOutsideHomeRadius / 30
					actualVelocity = actualVelocity * (1 - lerpAmount) + homeVelocity * lerpAmount
					npcdata.FramesOutsideHomeRadius = math.max(0, npcdata.FramesOutsideHomeRadius - 3)
				end
			end

			npc.Velocity = actualVelocity + unintendedVelocity
			npcdata.IntendedVelocity = desiredVelocity
			npcdata.ActualVelocity = actualVelocity
		end

		npcdata.MovementFrame = npcdata.MovementFrame + 1
	end

	if sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
		local params = ProjectileParams()
		params.BulletFlags = ProjectileFlags.SMART
		npc:FireProjectiles(npc.Position, Vector(10,0), 7, params)

		npc:PlaySound(SoundEffect.SOUND_THE_FORSAKEN_SCREAM, 1.75, 0, false, 2.75 + 0.125 * math.random() - 0.0625)
	end

	if sprite:IsEventTriggered("DeathShoot") then
		local params = ProjectileParams()

		local enemies = Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)
		for _, enemy in ipairs(enemies) do
			if (enemy.InitSeed ~= npc.InitSeed or enemy.Index ~= npc.Index) and not mod:isEmpathBlacklisted(enemy) then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, enemy.Position, nilvector, npc)
				npc:FireProjectiles(enemy.Position, Vector(10,0), 6, params)
			end
		end

		npc:PlaySound(SoundEffect.SOUND_FLOATY_BABY_ROAR, 0.7, 0, false, 1.875 + 0.125 * math.random() - 0.0625)
	end

	if sprite:IsEventTriggered("Gasp") then
		npc:PlaySound(SoundEffect.SOUND_LOW_INHALE, 0.6, 0, false, 3.5 + 0.25 * math.random() - 0.125)
	end

	if sprite:IsEventTriggered("Struggle") then
		npc:PlaySound(SoundEffect.SOUND_MOUTH_FULL, 0.7, 0, false, 6)
	end
end

function mod:empathOnEnemyDeath(entity)
	if not mod:isEmpathBlacklisted(entity) then
		local empaths = Isaac.FindByType(mod.FF.Empath.ID, mod.FF.Empath.Var)
		for _, empath in ipairs(empaths) do
			local sprite = empath:GetSprite()
			if not (sprite:IsPlaying("Attack") or sprite:IsPlaying("Death")) and not empath:GetData().FFIsDeathAnimation then
				sprite:Play("Attack")
			end
		end
	end
end

function mod.empathDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		local npcData = npc:GetData()
		local deathAnimData = deathAnim:GetData()
		
		deathAnimData.Home = npcData.Home
		deathAnimData.IntendedVelocity = npcData.IntendedVelocity
		deathAnimData.ActualVelocity = npcData.ActualVelocity
		deathAnimData.MovementFrame = npcData.MovementFrame
		deathAnimData.FramesOutsideHomeRadius = npcData.FramesOutsideHomeRadius
		deathAnimData.EmpathRNG = npcData.EmpathRNG
		deathAnimData.init = true
		
		deathAnim.SplatColor = FiendFolio.ColorPsy
	end
	FiendFolio.genericCustomDeathAnim(npc, "Death", false, onCustomDeath, nil, nil, nil, true)
end

function mod.empathDeathEffect(npc)
	local params = ProjectileParams()

	local enemies = Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)
	for _, enemy in ipairs(enemies) do
		if (enemy.InitSeed ~= npc.InitSeed or enemy.Index ~= npc.Index) and not mod:isEmpathBlacklisted(enemy) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, enemy.Position, nilvector, npc)
			npc:FireProjectiles(enemy.Position, Vector(10,0), 6, params)
		end
	end
end