-- Psycho and Manic Flies --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:psychoFlyAI(npc)
	npc.SplatColor = FiendFolio.ColorPsy

	if npc.Velocity:Length() > 5 then
		npc.Velocity = npc.Velocity:Resized(5)
	end
	
	local npcdata = npc:GetData()
	if npcdata.FFIsDeathAnimation then
		npc.Velocity = npc.Velocity * 0.75
	end
	
	if npcdata.AttackSprite then
		if npcdata.AttackSprite:GetFrame() > 7 and not npcdata.HasShot then
			local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, nilvector, npc):ToEffect()
			blood.Color = FiendFolio.ColorPsy
			npc:BloodExplode()
			
			local target = npc:GetPlayerTarget()
			local targetpos = target.Position
			local psychoParams = ProjectileParams()
			psychoParams.BulletFlags = ProjectileFlags.SMART
			npc:FireProjectiles(npc.Position, Vector.FromAngle((targetpos - npc.Position):GetAngleDegrees()) * 10, 0, psychoParams)
			npcdata.HasShot = true
			
			if npcdata.FFIsDeathAnimation then
				npc:Kill()
			end
			
			npcdata.HasShot = true
		end
		
		if npcdata.AttackSprite:IsFinished("Attack") then
			npcdata.AttackSprite = nil
			npcdata.HasShot = nil
		else
			npc:GetSprite():Play("nil", true)
		end
	end
	
	if npc:IsDead() then
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_PROJECTILE
			and entity.Variant == 0
			and	entity.SpawnerType == npc.Type
			and	entity.SpawnerVariant == npc.Variant
			and entity.FrameCount < 2
			and not entity:ToProjectile():HasProjectileFlags(ProjectileFlags.SMART) then
				entity:Remove()
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	local data = npc:GetData()
	if npc.Variant == mod.FF.PsychoFly.Var and data.AttackSprite then
		local attacksprite = data.AttackSprite
		local actualsprite = npc:GetSprite()
		
		attacksprite.Color = actualsprite.Color
		attacksprite.FlipX = actualsprite.FlipX
		attacksprite.FlipY = actualsprite.FlipY
		attacksprite.PlaybackSpeed = actualsprite.PlaybackSpeed * mod:getBasegameVelocityMultiplier(npc)
		attacksprite.Rotation = actualsprite.Rotation
		attacksprite.Scale = actualsprite.Scale
		
		if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.LastRenderFrame ~= Isaac.GetFrameCount() then
			attacksprite:Update()
		end
		attacksprite:Render(Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset, nilvector, nilvector)
	
		data.LastRenderFrame = Isaac.GetFrameCount()
	end
end, 25)

function mod:manicFlyAI(npc, sprite, npcdata)
	if not npcdata.init then
		npcdata.MovementFrame = 0

		npcdata.PsychoFlyRNG = RNG()
		npcdata.PsychoFlyRNG:SetSeed(npc.InitSeed, 0)

		npcdata.init = true
	end

	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	if not (sprite:IsPlaying("Appear") or sprite:IsPlaying("Attack")) then
		mod:spritePlay(sprite, "Fly")
	end

	if sprite:IsEventTriggered("Shoot") then
		local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, nilvector, npc):ToEffect()
		npc:BloodExplode()
		npc:FireProjectiles(npc.Position, Vector(8,6), 9, ProjectileParams())
		if npcdata.FFIsDeathAnimation then
			npc:Kill()
		end
	end
	
	if npcdata.FFIsDeathAnimation then
		npc.Velocity = npc.Velocity * 0.75
		return
	end

	local originalVelocity = npc.Velocity * 0.75

	npc.Velocity = Vector.FromAngle(originalVelocity:GetAngleDegrees()) * 0.00000001
	npc.Pathfinder:MoveRandomly(false)
	local randVelocity = npc.Velocity * math.abs(math.sin(npcdata.MovementFrame / (3 + npcdata.PsychoFlyRNG:RandomFloat() * 0.2 - 0.1))) * 3.5

	local orbitVelocity = nilvector
	if not mod:isScareOrConfuse(npc) then
		orbitVelocity = Vector.FromAngle((Vector.FromAngle((npc.Position - targetpos):GetAngleDegrees()) * (130 + 30 * math.sin(npcdata.MovementFrame / (3 + npcdata.PsychoFlyRNG:RandomFloat() * 0.2 - 0.1)) - 15) + targetpos - npc.Position):GetAngleDegrees()) * 0.1
	end

	npc.Velocity = originalVelocity + randVelocity + orbitVelocity
	npcdata.MovementFrame = npcdata.MovementFrame + 1
end

function mod.triggerPsychoManicFlies(npc)
	if npc:GetData().FFIsDeathAnimation then
		return
	end
	
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	local psychoFlies = Isaac.FindByType(mod.FF.PsychoFly.ID, mod.FF.PsychoFly.Var)
	for _, psychoFly in ipairs(psychoFlies) do
		if not (psychoFly:HasEntityFlags(EntityFlag.FLAG_FREEZE) or psychoFly:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(psychoFly)) then
			local psychoData = psychoFly:GetData()
			if psychoData.AttackSprite == nil then
				psychoData.AttackSprite = Sprite()
				psychoData.AttackSprite:Load("gfx/enemies/psychofly/monster_psychofly.anm2", true)
				psychoData.AttackSprite:Play("Attack", true)
				psychoFly:GetSprite():Play("nil", true)
			end
		end
	end

	local manicFlies = Isaac.FindByType(mod.FF.ManicFly.ID, mod.FF.ManicFly.Var)
	for _, manicFly in ipairs(manicFlies) do
		if not (manicFly:HasEntityFlags(EntityFlag.FLAG_FREEZE) or manicFly:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(manicFly)) then
			local manicSprite = manicFly:GetSprite()
			if manicSprite:IsPlaying("Fly") then
				manicSprite:Play("Attack", true)
			end
		end
	end
end

function mod.psychoFlyDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
		deathAnim:GetData().AttackSprite = Sprite()
		deathAnim:GetData().AttackSprite:Load("gfx/enemies/psychofly/monster_psychofly.anm2", true)
		deathAnim:GetData().AttackSprite:Play("Attack", true)
	end
	FiendFolio.genericCustomDeathAnim(npc, "nil", nil, onCustomDeath)
end

function mod.manicFlyDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end
	FiendFolio.genericCustomDeathAnim(npc, "Attack", nil, onCustomDeath)
end
