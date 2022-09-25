local mod = FiendFolio
local rng = RNG()

function mod:dreadMawAI(npc)
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()
	local rand = npc:GetDropRNG()
	local data = npc:GetData()
	
	if npc.I1 > 0 then
		npc.I1 = npc.I1-1
	end
	
	if not data.dying then
		if sprite:IsEventTriggered("shoot") then
			for i=90,360,90 do
				local params = ProjectileParams()
				params.Color = mod.ColorModeratelyRed
				npc:FireProjectiles(npc.Position, Vector(0,9):Rotated(i), 0, params)
			end
			npc:PlaySound(SoundEffect.SOUND_FAT_WIGGLE, 0.6, 0, false, math.random(70,80)/100)
			local effect = Isaac.Spawn(1000,2,2,npc.Position,npc.Velocity,npc):ToEffect()
			effect.SpriteOffset = Vector(0,-22)
			effect:FollowParent(npc)
			effect.DepthOffset = npc.DepthOffset * 1.25
		end
	
		if not data.lowered then
			if mod:isScare(npc) then
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(-8), 0.05)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(8), 0.05)
			end
			
			if npc.HitPoints > npc.MaxHitPoints/2 and not data.lowered then
				if not sprite:IsPlaying("Retaliate") or sprite:IsFinished("Retaliate") then
					mod:spritePlay(sprite, "Idle")
				end
			else
				if not data.lowered then
					data.lowered = true
				end
			end
		else
			if not sprite:IsPlaying("Retaliate") or sprite:IsFinished("Retaliate") then
				mod:spritePlay(sprite, "IdleLow")
			end
			if mod:isScare(npc) then
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(-12), 0.05)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(12), 0.05)
			end
		end
	else
		if sprite:IsFinished("Death") then
			mod.DreadMawDeathEffect(npc)
			npc:Kill()
		elseif sprite:IsEventTriggered("sound") then
			npc:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, 0.8, 0, false, 0.7)
		end
	end
end

function mod.DreadMawDeathEffect(npc)
	for i=90,360,90 do
		local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,1):Rotated(i), npc):ToProjectile()
		local pData = proj:GetData()
		pData.projType = "dreadMaw"
		pData.detail = "main"
		pData.rand = npc:GetDropRNG()
		pData.Parent = npc
		proj.Scale = 2
		proj.Color = mod.ColorDecentlyRed
		proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.ACCELERATE
		if mod:isFriend(npc) then
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
			pData.friend = 0
		elseif mod:isCharm(npc) then
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
			pData.friend = 1
		end
		proj.Acceleration = 1.1
		proj:Update()
		
		for j=1,2 do
			local params = ProjectileParams()
			params.Scale = 2-0.5*j
			if j == 2 then
				params.Color = mod.ColorCrackleOrange
			else
				params.Color = mod.ColorModeratelyRed
			end
			npc:FireProjectiles(npc.Position, Vector(0,11-2*j):Rotated(i+45), 0, params)
		end
	end
end

function mod.dreadMawProj(v, d)
	if d.projType == "dreadMaw" then
		local room = Game():GetRoom()
		v.FallingSpeed = 0
		v.FallingAccel = 0
		
		if d.detail == "main" then
			if v.FrameCount % 3 == 0 then
				local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, v.Position, v.Velocity:Resized(-2), v):ToEffect()
				trail:GetSprite().Scale = trail:GetSprite().Scale * 0.6
				trail:GetSprite().Offset = Vector(0, v.Height * 0.75)
				trail.Color = mod.ColorDecentlyRed
			end
			if v.Velocity:Length() > 15 then
				v.Acceleration = 1
			end
			if room:IsPositionInRoom(v.Position, 0) == false or v:IsDead() then
				v.Position = v.Position-v.Velocity:Resized(15)
				local poof = Isaac.Spawn(1000, 11, 0, v.Position, Vector.Zero, v):ToEffect()
				poof.Color = v.Color
				poof.Scale = v.Scale
				poof.SpriteOffset = Vector(0, v.Height)
				poof:Update()
				SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
				for j=0,1 do
					for i=0,12 do
						local proj = Isaac.Spawn(9, 0, 0, v.Position-v.Velocity:Resized(10)+Vector(-12+d.rand:RandomInt(24),-12+d.rand:RandomInt(24)), v.Velocity:Rotated(90-180*j):Resized(d.rand:RandomInt(12)+4), d.Parent):ToProjectile()
						proj:GetData().projType = "dreadMaw"
						--proj:GetData().delay = d.rand:RandomInt(35)
						proj.Scale = math.random(20,80)/100
						if rng:RandomFloat() <= 0.5 then
							proj.Color = mod.ColorCrackleOrange
						else
							proj.Color = mod.ColorModeratelyRed
						end
						--proj.Color = Color(1,1,1,1,1,(112-math.random(112))/255,0)
						proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.ACCELERATE
						if d.friend == 0 then
							proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
						elseif d.friend == 1 then
							proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
						end
						proj.Height = v.Height+2
						--[[local params = ProjectileParams()
						params.Scale = math.random(30,80)/100
						d.Parent:FireProjectiles(v.Position-v.Velocity:Resized(5)+Vector(-15+d.rand:RandomInt(30),-15+d.rand:RandomInt(30)), v.Velocity:Rotated(90-180*j):Resized(d.rand:RandomInt(10)+5), 0, params)]]
					end
				end
				v:Remove()
			end
		else
			--[[if d.delay > 0 then
				d.delay = d.delay-1
			elseif not d.accelerated then
				v.Acceleration = 1.11
				d.accelerated = true
			end
			if v.Velocity:Length() > 10 then
				v.Acceleration = 1
			end]]
			
			if room:IsPositionInRoom(v.Position, 0) == false then
				v.Position = v.Position-v.Velocity
				local poof = Isaac.Spawn(1000, 11, 0, v.Position, Vector.Zero, v):ToEffect()
				poof.Color = v.Color
				poof.Scale = v.Scale
				poof.SpriteOffset = Vector(0, v.Height)
				poof:Update()
				v:Remove()
			end
		end
	end
end

function mod:dreadMawHurt(npc, damage, source, flags)
	local npc = npc:ToNPC()
	if npc.I1 <= 0 and damage < npc.HitPoints and (npc:GetSprite():IsPlaying("Idle") or npc:GetSprite():IsPlaying("IdleLow")) and not mod:isScareOrConfuse(npc) then
		npc.I1 = 24
		npc:GetSprite():Play("Retaliate", true)
	end
end

function mod.dreadMawDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().dying = true
	end
	mod.genericCustomDeathAnim(npc, "Death", true, onCustomDeath)
end