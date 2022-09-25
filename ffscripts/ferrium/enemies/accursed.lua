local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:accursedAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Idle"
		data.spawnCountdown = 8
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		if data.spawnCountdown > 0 then
			data.spawnCountdown = data.spawnCountdown-1
		end
	end
	
	if data.state == "Idle" then
		if npc.StateFrame > 100 and rand:RandomInt(60) == 26 then
			data.state = "Shoot"
			if sprite:IsPlaying("WalkHori") then
				data.anim = "ShootHori"
			else
				data.anim = "ShootVert"
			end
		elseif npc.StateFrame > 160 and not mod:isScareOrConfuse(npc) then
			data.state = "Shoot"
			if sprite:IsPlaying("WalkHori") then
				data.anim = "ShootHori"
			else
				data.anim = "ShootVert"
			end
		end
		
		if sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 0.25, 0, false, 2)
		end
	
		if npc.Velocity:Length() > 0.1 then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
				mod:spritePlay(sprite, "WalkHori")
			else
				mod:spritePlay(sprite, "WalkVert")
			end
		else
			mod:spritePlay(sprite, "Idle")
		end
	
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(2.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.35, 900, true)
		end
	elseif data.state == "Flinch" then
		if sprite:IsFinished(data.anim) then
			data.state = "Idle"
			data.spawnCountdown = 60
			npc.StateFrame = 10
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.FlashShakeyKidRoar, 1.2, 0, false, 1+math.random(20,40)/100)
			local ghost = Isaac.Spawn(mod.FF.Murmur.ID, mod.FF.Murmur.Var, 0, npc.Position, (target.Position-npc.Position):Resized(-10), npc)
			ghost:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			local poof = Isaac.Spawn(1000, 16, 2, npc.Position, Vector.Zero, npc)
			poof.Color = mod.ColorGhostly
			poof.SpriteScale = Vector(0.7, 1.1)
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.28, 0, false, 1.4)
		else
			mod:spritePlay(sprite, data.anim)
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Shoot" then
		if sprite:IsFinished(data.anim) then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_STONESHOOT, 0.75, 0, false, math.random(75,85)/100)
			for i=-26,26,52 do
				local params = ProjectileParams()
				params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
				params.Scale = 1.5
				params.FallingSpeedModifier = 0
				params.FallingAccelModifier = 0
				params.Variant = 4
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(9):Rotated(i), 0, params)
			end
			
			local proj = Isaac.Spawn(9, 4, 0, npc.Position, (target.Position-npc.Position):Resized(9), npc):ToProjectile()
			local pData = proj:GetData()
			pData.projType = "Accursed"
			proj:AddProjectileFlags(ProjectileFlags.GHOST)
			if mod:isFriend(npc) then
				pData.wasFriend = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
				proj.ProjectileFlags = proj.ProjectileFlags | pData.wasFriend
			elseif mod:isCharm(npc) then
				pData.wasFriend = ProjectileFlags.CANT_HIT_PLAYER
				proj.ProjectileFlags = proj.ProjectileFlags | pData.wasFriend
			end
			proj.FallingSpeed = 0
			proj.FallingAccel = 0
			proj.Height = -35
			proj.Scale = 2
			
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position+Vector(0,-35), Vector.Zero, npc):ToEffect()
			poof.Color = mod.ColorGhostly
			poof.SpriteScale = Vector(0.9,0.9)
			poof.DepthOffset = 40
			poof:Update()
		else
			mod:spritePlay(sprite, data.anim)
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	end
	
	if npc:IsDead() then
		local rangle = rand:RandomInt(360)
		for i=120,360,120 do
			local ghost = Isaac.Spawn(mod.FF.Murmur.ID, mod.FF.Murmur.Var, 0, npc.Position, Vector(0,6):Rotated(i+rangle), npc)
			ghost:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			ghost.HitPoints = 18
		end
		local poof = Isaac.Spawn(1000, 16, 2, npc.Position, Vector.Zero, npc)
		poof.Color = mod.ColorGhostly
		poof.SpriteScale = Vector(0.7, 1.1)
	end
end

function mod:accursedHurt(npc, damage, source, flags)
	local data = npc:GetData()
	if data.state == "Idle" and data.spawnCountdown < 1 and mod.GetEntityCount(114, 35, 0) < 4 then
		data.state = "Flinch"
		if npc:GetSprite():IsPlaying("WalkHori") then
			data.anim = "FlinchHori"
		else
			data.anim = "FlinchVert"
		end
	end
end

function mod.accursedProj(v, d)
	if d.projType == "Accursed" then
		if v.FrameCount > 10 then
			for i=-12,12,24 do
				local proj = Isaac.Spawn(9, 4, 0, v.Position, v.Velocity:Resized(12):Rotated(i), v):ToProjectile()
				proj:AddProjectileFlags(ProjectileFlags.GHOST)
				if d.wasFriend ~= nil then
					proj.ProjectileFlags = proj.ProjectileFlags | d.wasFriend
				end
				proj.FallingSpeed = 0
				proj.FallingAccel = 0
				proj.Height = v.Height
			end
			local effect = Isaac.Spawn(1000, 11, 0, v.Position, Vector.Zero, v):ToEffect()
			--effect.SpriteScale = effect.SpriteScale
			effect.Color = mod.ColorGhostly
			effect.SpriteOffset = Vector(0, v.Height)
			effect:Update()
			sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
			v:Remove()
		end
	end
end

function mod:murmurAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	
	if not data.init then
		data.state = "Idle"
		npc.SplatColor = mod.ColorGhostly
		npc.StateFrame = rand:RandomInt(70)
		data.jaunt = Vector.Zero
		data.murmurDir = Vector.Zero
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	local murmurCheck = false
	for _,murmur in ipairs(Isaac.FindInRadius(npc.Position, 60, EntityPartition.ENEMY)) do
		if rand ~= murmur:ToNPC():GetDropRNG() then
			data.murmurDir = (npc.Position-murmur.Position):Resized(5)
			murmurCheck = true
		end
	end
	
	if murmurCheck == false then
		data.murmurDir = Vector.Zero
	end
	
	data.sinValue = math.sin(npc.StateFrame/6)*18
	data.jaunt = data.jaunt*0.95
	if npc.FrameCount % 60 == 0 then
		data.jaunt = (target.Position-npc.Position):Resized(5)
	end
		
	if mod:isScare(npc) then
		mod:UnscareWhenOutOfRoom(npc)
		if npc.Position:Distance(target.Position) < 300 then
			local targetvel = (targetpos - npc.Position):Resized(-10)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel+targetvel:Rotated(90):Resized(data.sinValue), 0.05)
		else
			npc.Velocity = npc.Velocity * 0.9
		end
	else
		local targetvel = (targetpos - npc.Position):Resized(10)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel+targetvel:Rotated(90):Resized(data.sinValue)+data.jaunt+data.murmurDir, 0.05)
	end
	mod:spritePlay(sprite, "Idle")
end

function mod:murmurColl(npc, coll, bool)
	if npc.Variant == mod.FF.Murmur.Var then
		if (coll.Type == mod.FFID.Ferrium and coll.Variant == mod.FF.Accursed.Var) then
			return true
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.murmurColl, mod.FFID.Ferrium)