local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:peekabooAI(npc, subT)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)

	if not d.init then
		d.state = "eyedle"
		npc.SplatColor = mod.ColorGhostly
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.SpriteOffset = Vector(0, -23)

	if d.state == "eyedle" then
		mod:spritePlay(sprite, "an invisible man")
		local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(2))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if npc.StateFrame > 10 and npc.Pathfinder:HasPathToPos(target.Position, true) and not mod:isScareOrConfuse(npc) then
			d.state = "shoot"
			npc:PlaySound(mod.Sounds.StretchEye,0.3,0,false,1.3)
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.96
		if sprite:IsFinished("if you seeing things") then
			d.state = "dle"
		elseif sprite:IsEventTriggered("patoo") then
			npc:PlaySound(SoundEffect.SOUND_SKIN_PULL,1,0,false,1.6)
			sfx:Stop(mod.Sounds.StretchEye)

			local eye = Isaac.Spawn(mod.FF.PeekabooEye.ID, mod.FF.PeekabooEye.Var, 0, npc.Position + npc.Velocity:Resized(5), npc.Velocity:Resized(4), npc)
			eye:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			eye.Parent = npc
			eye:Update()
		else
			mod:spritePlay(sprite, "if you seeing things")
		end
	elseif d.state == "dle" then
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		mod:spritePlay(sprite, "sleeping in your bed")
		npc.Velocity = mod:Lerp(npc.Velocity,  mod:runIfFear(npc, npc.Velocity:Resized(2):Rotated(math.random(60) - 30), 2), 0.1)

		if targetpos:Distance(npc.Position) < 100 and not mod:isScareOrConfuse(npc) then
			d.state = "shootEyeless"
		end

	elseif d.state == "shootEyeless" then
		npc.Velocity = npc.Velocity * 0.96
		if sprite:IsFinished("lemme tell you somethin") then
			d.state = "dle"
		elseif sprite:IsEventTriggered("patoo") then
			npc:PlaySound(SoundEffect.SOUND_WORM_SPIT,1,0,false,0.9)
			mod:flipToTarget(npc, target, 0)
			local shootdir = (target.Position - npc.Position)
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
			params.Color = mod.ColorNormal
			for i = 1, 6 do
				params.FallingAccelModifier = 1.3
				params.FallingSpeedModifier = -15 + math.random(10);
				npc:FireProjectiles(npc.Position, shootdir:Resized(math.random(50,70)/10):Rotated(-20+math.random(40)), 0, params)
			end
		else
			mod:spritePlay(sprite, "lemme tell you somethin")
		end
	end
end

function mod:peekabooEyeAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	npc.SpriteOffset = Vector(0, -43)

	if (npc.Parent and (npc.Parent:IsDead() or mod:isStatusCorpse(npc.Parent))) or not npc.Parent then
		npc:Kill()
	end

	mod:spritePlay(sprite, "sleeping in your bed")
	if sprite:IsEventTriggered("hup") then
		npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.5,0,false,1.3)
		npc.Velocity = mod:Lerp(npc.Velocity, mod:runIfFear(npc, RandomVector()*9,9),	 0.5)
		local boingy = Isaac.Spawn(1000, 1735, 0, npc.Position, nilvector, npc):ToEffect()
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
		creep:SetTimeout(30)
		creep:Update()
	elseif sprite:IsEventTriggered("Hit") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	elseif sprite:IsEventTriggered("NoHit") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end
end

function mod:ballBlood(e)
	local sprite = e:GetSprite()
	--Animation funsies
	if sprite:IsFinished("sleeping in your bed") then
		e:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.ballBlood, 1735)