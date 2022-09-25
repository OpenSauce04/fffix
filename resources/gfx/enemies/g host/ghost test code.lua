function wre:ghostSkullUpdate(npc)
	if npc.Variant == 0 then
		local target = npc:GetPlayerTarget()
		local sprite = npc:GetSprite()
		local data = npc:GetData()
		
		npc.Velocity = npc.Velocity*0.7
		
		if not data.State then
			data.inv = true
			data.Timer = 100
			data.State = 0
		end
		
		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		end
		if sprite:IsPlaying("Idle") and data.Timer > 0 then
			data.Timer = data.Timer-1
		elseif sprite:IsPlaying("Idle") and data.Timer == 0 then
			sprite:Play("Fade")
		end
		if sprite:IsFinished("Fade") then
			local gRandom = math.rad(math.random(360))
			local ghost = Isaac.Spawn(803,1,0,Vector(target.Position.X+(100*math.cos(gRandom)),target.Position.Y+(100*math.sin(gRandom))),Vector(0,0),npc)
			ghost.Parent = npc
			data.ghost = ghost
			data.ghost:GetSprite():Play("Surprise", true)
			data.ghost.HitPoints = npc.HitPoints
			sprite:Play("Idle2")
			data.State = 1
		end
		if sprite:IsFinished("Return") then
			sprite:Play("Idle")
			data.Timer = 100
		end
		
		if data.ghost then
			if data.ghost:IsDead() and data.State == 1 then
				npc:Kill()
			end
			if data.ghost:GetSprite():IsFinished("Return") then
				data.State = 0
				sprite:Play("Return")
				data.ghost:Remove()
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, wre.ghostSkullUpdate, 803)

function wre:ghostUpdate(npc)
	if npc.Variant == 1 then
		local sprite = npc:GetSprite()
		local data = npc:GetData()
		local target = npc:GetPlayerTarget()
		local ptarget = npc.Parent.Position
		
		npc.Velocity = npc.Velocity*0.9
		
		if not data.State then
			data.inv = true
			data.State = 0
		end
		
		if sprite:IsFinished("Surprise") then
			sprite:Play("Idle")
		end
		if sprite:IsPlaying("Idle") and npc.Position:Distance(ptarget) >= 50 then
			data.targetVelocity = (ptarget - npc.Position):Resized(6)
			npc.Velocity = wre:lerp(npc.Velocity, data.targetVelocity, 0.1)
		elseif sprite:IsPlaying("Idle") and npc.Position:Distance(ptarget) < 50 then
			sprite:Play("Return")
		end
		
		if sprite:IsEventTriggered("Emerge") then
			data.inv = false
		end
		if sprite:IsEventTriggered("Hide") then
			data.inv = true
		end
		if sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
			for i=-1,1 do
				local targetFire = (target.Position-npc.Position):Resized(10)
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, targetFire:Rotated(20*i), npc):ToProjectile()
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
				projectile.FallingSpeed = -2
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, wre.ghostUpdate, 803)

function wre:ghostDamage(npc)
	local data = npc:GetData()
	
	if data.inv == true then
		return false
	end
	if npc.Variant == 1 then
		npc.Parent.HitPoints = npc.HitPoints
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, wre.ghostDamage, 803)