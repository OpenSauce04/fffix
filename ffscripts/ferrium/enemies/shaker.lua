local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

function mod:shakerAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then 
		if npc.SubType > 0 and not data.waited then
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, 60, false)
		end
	
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		if npc.SubType == 0 then
			data.state = "Idle"
		elseif data.waited then
			data.state = "Waiting"
			npc.Visible = false
		end
		data.isJumping = false
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.isJumping == true then
		npc.Friction = 1
		local dist = (npc.Position-data.playerPos):Length()
		if dist < 20 then
			data.state = "JumpDown"
			data.isJumping = false
			data.targetVel = Vector.Zero
		elseif dist < 40 then
			data.targetVel = (data.playerPos-npc.Position):Resized(2)
		else
			data.targetVel = data.targetVel+ -(npc.Position-data.playerPos):Resized(dist/50)
			local arcVel = data.targetVel
			if arcVel:Length() >= dist then
				data.targetVel = arcVel:Resized(dist)
			end
		end
		
		if npc.FrameCount then
			local proj = Isaac.Spawn(9, 8, 0, npc.Position, RandomVector()*(rand:RandomInt(100,500)/100), npc):ToProjectile()
			proj:GetData().shakerSalt = true
			proj.Height = -350
			proj.FallingAccel = 0.2+rand:RandomInt(20)/100
			if mod:isFriend(npc) then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
			elseif mod:isCharm(npc) then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER
			end
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.ACCELERATE
			proj.Acceleration = 0.98
			proj.Scale = 0.6
			local pSprite = proj:GetSprite()
			pSprite:Load("gfx/009.009_Rock Projectile.anm2", true)
			pSprite:ReplaceSpritesheet(0, "gfx/projectiles/salt_projectile.png")
			pSprite:Play("Rotate1", true)
			pSprite:LoadGraphics()
			proj:Update()
			--[[local params = ProjectileParams()
			params.HeightModifier = -350
			params.BulletFlags = params.BulletFlags | ProjectileFlags.ACCELERATE
			params.Acceleration = 0.97
			params.FallingAccelModifier = 0.6
			params.Variant = 9
			npc:FireProjectiles(npc.Position, RandomVector(), 0, params)]]
			
			if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
				local salt = Isaac.Spawn(1000, 92, 115, npc.Position+RandomVector()*5, Vector.Zero, npc):ToEffect()
				salt.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
				salt:SetTimeout(15)
				--salt.Parent = v.SpawnerEntity
				salt.SpriteScale = Vector(0.4, 0.4)
				salt:Update()
			end
		end
	else
		data.targetVel = Vector.Zero
	end
	
	if data.state == "Idle" then
		if npc.StateFrame > 52 and not mod:isScareOrConfuse(npc) then
			data.state = "JumpUp"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Idle")
		end
	elseif data.state == "JumpUp" then
		if sprite:IsEventTriggered("GetPlayer") then
			local randtarg = mod:FindRandomFreePos(npc, 200, nil, true)
			local dist = (npc.Position - randtarg):Length()
			local fgkhj = (randtarg - npc.Position):Normalized() * math.min(300,dist)
			
			if mod:shakerProjectLine(npc, target) == nil then
				data.playerPos = room:FindFreeTilePosition(npc.Position + fgkhj, 40) + (RandomVector())
			else
				data.playerPos = mod:shakerProjectLine(npc, target)
			end
			
			data.isJumping = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME,1,2,false,0.7)
		else
			mod:spritePlay(sprite, "Jump")
		end
	elseif data.state == "JumpDown" then
		if sprite:IsFinished("Fall") then
			data.state = "Idle"
			npc.StateFrame = 8-rand:RandomInt(15)
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_FETUS_LAND,1,0,false,1.6)
			local poof = Isaac.Spawn(1000, 59, 0, npc.Position, Vector.Zero, npc):ToEffect()
			poof:SetTimeout(20)
			poof.SpriteScale = Vector(0.6, 0.6)
			poof:Update()
			
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		else
			mod:spritePlay(sprite, "Fall")
		end
	elseif data.state == "Waiting" then
		npc.Velocity = Vector.Zero
		sprite:Play("Fall", true)
		data.state = "JumpDown"
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.Visible = true
		npc.Position = npc.Position+RandomVector()*5
	end
	
	if data.state == "JumpUp" or data.state == "JumpDown" then
		npc.Velocity = (data.targetVel * 0.5) + (npc.Velocity * 0.4)
	else
		npc.Velocity = Vector.Zero
	end

	if npc:IsDead() then
		sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6, 0, false, 1.5)
		for i = 1, 6 do
			Isaac.Spawn(1000, 35, 0, npc.Position, Vector.One:Resized(rng:RandomFloat()*4):Rotated(mod:RandomAngle()), npc)
		end
	end
end

function mod:shakerProjectLine(npc, target)
	local room = game:GetRoom()
	local rand = npc:GetDropRNG()
	local size = room:GetGridSize()
	
	local targetTable = {}
	local fireTable = {}
	local playerDist = (target.Position-npc.Position):Length()
	
	for _,fire in ipairs(Isaac.FindByType(33, -1, -1)) do
		fireTable[room:GetGridIndex(fire.Position)] = true
	end
	
	for i=0,size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i) 
		
		if room:GetGridCollisionAtPos(gridpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(gridpos, 0) and fireTable[i] ~= true then
			local tVel = (target.Position-npc.Position)
			local difference = mod:GetAngleDifference((gridpos-npc.Position), tVel)
			
			if (difference < 5 or difference > 355) and playerDist < (gridpos-npc.Position):Length() and gridpos:Distance(target.Position) > 120 then
				if gridpos:Distance(target.Position) < 300 then
					for i=1,3 do
						table.insert(targetTable, gridpos)
					end
				else
					table.insert(targetTable, gridpos)
				end
			end
		end
	end
	
	if #targetTable > 0 then
		return targetTable[rand:RandomInt(#targetTable)+1]
	else
		return nil
	end
end

function mod.shakerProj(v, d)
	if d.shakerSalt == true then
		if v:IsDead() then
			if v.Height > -5 then
				local salt = Isaac.Spawn(1000, 92, 115, v.Position, Vector.Zero, v):ToEffect()
				salt.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
				salt:SetTimeout(20)
				--salt.Parent = v.SpawnerEntity
				salt.SpriteScale = Vector(0.8, 0.8)
				salt:Update()
			end
			local poof = Isaac.Spawn(1000, 59, 0, v.Position, Vector.Zero, v):ToEffect()
			poof:SetTimeout(10)
			poof.SpriteScale = Vector(0.2, 0.2)
			poof.SpriteOffset = Vector(0, v.Height)
			poof:Update()
			sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 0.3, 0, false, math.random(90,140)/100)
		end
	end
end