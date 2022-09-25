local mod = FiendFolio

function mod:nematodeAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		data.init = true
		if data.dead then
			data.state = "Die"
		else
			data.state = "Hidle"
		end
		data.nematodeHidden = true
		data.attackCooldown = 0
		data.initPos = npc.Position
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.SplatColor = mod.ColorDullGray
	else
		npc.StateFrame = npc.StateFrame+1
		if data.attackCooldown > 0 then
			data.attackCooldown = data.attackCooldown-1
		end
	end
	
	if not data.isSpecturned then
		if not data.initPos then
			data.initPos = npc.Position
		end
		npc.Velocity = data.initPos-npc.Position
	else
		data.initPos = nil
	end
	
	if data.state == "Hidle" then
		if target.Position:Distance(npc.Position) > 100 then
			if npc.StateFrame > 30 and rng:RandomInt(30) == 0 then
				data.state = "PopUp"
			elseif npc.StateFrame > 65 then
				data.state = "PopUp"
			end
		else
			npc.StateFrame = npc.StateFrame-1
		end
		mod:spritePlay(sprite, "Pulse")
	elseif data.state == "Idle" then
		if npc.StateFrame > 75 then
			data.state = "Hide"
		end
		mod:spritePlay(sprite, "PulseOut")
	elseif data.state == "Retaliate" then
		if sprite:IsFinished("Retaliate") then
			data.state = "Hidle"
			npc.StateFrame = npc.StateFrame-10
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 0.7, 0, false, 1)
			for i=0,240,120 do
				local dir = (target.Position-npc.Position):Resized(8)
				local toma = Isaac.Spawn(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, npc.Position, dir:Rotated(i), npc):ToNPC()
				toma:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				toma.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				local customFunc = function(tom, tab)
					tab.height = tab.height or tom.PositionOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					tom.PositionOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					if tom.PositionOffset.Y < tab.collision then
						tom.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
						tom.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					else
						tom.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
						tom.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
					end
					if tom.PositionOffset.Y > 0 or tom:CollidesWithGrid() then
						tom:Kill()
					end
				end
				
				toma:GetData().launchedEnemyInfo = {pos = true, collision = -10, zVel = -6, custom = customFunc}
				--toma:GetData().nematodeLaunched = npc.Index
				toma:GetData().noSpiders = true
				toma:Update()
				--toma:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_REDUCE_GIBS | EntityFlag.FLAG_NO_BLOOD_SPLASH)
			end
		elseif sprite:IsEventTriggered("Shoot2") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 0.4, 0, false, 2)
			--[[for _,toma in ipairs(Isaac.FindByType(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, false, false)) do
				if toma:GetData().nematodeLaunched and toma:GetData().nematodeLaunched == npc.Index then
					toma:Kill()
				end
			end]]
			npc:FireProjectiles(npc.Position, Vector(7,0), 7, ProjectileParams())
		else
			mod:spritePlay(sprite, "Retaliate")
		end
	elseif data.state == "Attack" then
		if sprite:IsFinished("Attack") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
			local poof = Isaac.Spawn(1000, 2, 160, npc.Position+Vector(7,-39)+Vector(math.random(-10,10),math.random(-10,10)), Vector.Zero, npc):ToEffect()
			poof.DepthOffset = 55
			if not data.attack then
				local degrees = mod:GetAngleDegreesButGood(target.Position-npc.Position)
				local moveDegrees = mod:GetAngleDegreesButGood((target.Position+target.Velocity*5)-npc.Position)
				local rotDir = -1
				if degrees-moveDegrees < 0 then
					rotDir = 1
				end
				data.attack = {dir = (target.Position-npc.Position):Resized(12), num = rotDir, vel = target.Velocity:Length()*3, rot = rotDir}
			end
			local rotAmount = 12+data.attack.vel
			npc:FireProjectiles(npc.Position, data.attack.dir:Rotated(rotAmount*data.attack.num), 0, ProjectileParams())
			data.attack.num = data.attack.num+data.attack.rot
			if math.abs(data.attack.num) == 4 then
				data.attack = nil
			end
			npc:PlaySound(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "Attack")
		end
	elseif data.state == "Die" then
		if sprite:IsFinished("Death") or sprite:IsFinished("Death2") then
			for i=1,7 do
				local params = ProjectileParams()
				params.FallingSpeedModifier = -(6+rng:RandomInt(10))
				params.FallingAccelModifier = (rng:RandomInt(5)+5)/8
				params.Scale = (rng:RandomInt(30)+80)/100
				if rng:RandomInt(2) == 0 then
					params.Variant = 1
				end
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(mod:getRoll(4, 8, rng)):Rotated(mod:getRoll(-20, 20, rng)), 0, params)
			end
			for i=120,360,120 do
				local toma = Isaac.Spawn(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, npc.Position, (target.Position-npc.Position):Resized(6):Rotated(i+180), npc):ToNPC()
				toma:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				toma.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				toma:Update()
				mod.scheduleForUpdate(function()
					toma.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				end, 2)
			end
			if data.dead == 1 then
				local parabite = Isaac.Spawn(58, 0, 0, npc.Position, Vector.Zero, npc)
				parabite:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
			npc:Kill()
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
			npc:BloodExplode()
		elseif sprite:IsEventTriggered("Dig") then
			npc:PlaySound(SoundEffect.SOUND_FAT_GRUNT, 0.33, 0, false, 2.3)
		else
			if data.dead == 0 then
				mod:spritePlay(sprite, "Death")
			elseif data.dead == 1 then
				mod:spritePlay(sprite, "Death2")
			end
		end
	elseif data.state == "PopUp" then
		if sprite:IsFinished("DigOut") then
			data.state = "Attack"
		elseif sprite:IsEventTriggered("Dig") then
			npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 1, 0, false, 1)
			data.nematodeHidden = false 
		else
			mod:spritePlay(sprite, "DigOut")
		end
	elseif data.state == "Hide" then
		if sprite:IsFinished("DigIn") then
			data.state = "Hidle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Dig") then
			npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 1, 0, false, 1)
			data.nematodeHidden = true 
		else
			mod:spritePlay(sprite, "DigIn")
		end
	end
end

function mod:nematodeHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.nematodeHidden and flag ~= flag | DamageFlag.DAMAGE_CLONES then
		if data.state == "Hidle" and data.attackCooldown <= 0 then
			data.state = "Retaliate"
			data.attackCooldown = 80
		end
		npc:TakeDamage(damage*0.4, flag | DamageFlag.DAMAGE_CLONES, EntityRef(npc), 0)
		return false
	end
end

function mod.nematodeDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().dead = 0
		if npc:GetSprite():IsPlaying("Pulse") or npc:GetSprite():IsPlaying("Retaliate") then
			deathAnim:GetData().dead = 1
			deathAnim:GetSprite():Play("Death2", true)
		end
	end
	mod.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, true, false)
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	local data = eff:GetData()
	if eff.FrameCount == 1 then
		for _,toma in ipairs(Isaac.FindByType(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, false, false)) do
			if toma.Position:Distance(eff.Position) < 20 and toma:GetData().launchedEnemyInfo then
				eff.SpriteOffset = toma.PositionOffset
			end
		end
	end
end, 111)