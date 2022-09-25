local mod = FiendFolio
local game = Game()

function mod:chummerAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		if data.dead == true then
			data.state = "Dying"
			npc.CollisionDamage = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		elseif npc.SubType == 1 then
			data.state = "Pile"
			data.movement = "Pile"
			npc.CollisionDamage = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.pile = true
		elseif npc.SubType == 0 then
			data.lastDir = "Down"
			data.movement = "Idle"
			data.state = "Idle"
			local path = Isaac.Spawn(mod.FF.ChummerPathfinder.ID, mod.FF.ChummerPathfinder.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
			path.Parent = npc
			npc.Child = path
			npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		if data.searching then
			if data.searching > 0 then
				data.searching = data.searching-1
			else
				data.searching = nil
			end
		end
	end
	
	if data.state == "Pile" then
		if mod.CanIComeOutYet() then
			npc:Kill()
		end
	
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)
		
		if (target.Position:Distance(npc.Position) < 150 and npc.StateFrame > 40) or (npc.StateFrame > 100 and target.Position:Distance(npc.Position) < 480) then
			data.state = "PileShoot"
		end
		
		mod:spritePlay(sprite, "PileIdle")
	elseif data.state == "PileShoot" then
		if mod.CanIComeOutYet() then
			npc:Kill()
		end
	
		if sprite:IsFinished("Shoot") then
			data.state = "Pile"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			for i=1,2 do
				local params = ProjectileParams()
				params.FallingSpeedModifier = mod:getRoll(-30,-20,rng)
				params.FallingAccelModifier = mod:getRoll(90,120,rng)/100
				params.Variant = 1
				npc:FireProjectiles(npc.Position, Vector(0,2+rng:RandomInt(4)):Rotated(rng:RandomInt(360)), 0, params)
			end
			local params = ProjectileParams()
			params.FallingSpeedModifier = mod:getRoll(-30,-20,rng)
			params.FallingAccelModifier = mod:getRoll(90,120,rng)/100
			params.Variant = 1
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(rng:RandomInt(3)+4):Rotated(mod:getRoll(-20,20,rng)), 0, params)
			
			local params = ProjectileParams()
			params.FallingSpeedModifier = -24
			params.FallingAccelModifier = 1.1
			params.Variant = 1
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position)*0.035, 0, params)
			npc:PlaySound(SoundEffect.SOUND_BONE_HEART, 1, 0, false, math.random(70,80)/100)
		else
			mod:spritePlay(sprite, "Shoot")
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)
	elseif data.state == "Dying" then
		npc.Velocity = Vector.Zero
		if sprite:IsEventTriggered("Explode") then
			npc:BloodExplode()
			for i=1,3 do
				local params = ProjectileParams()
				params.FallingSpeedModifier = mod:getRoll(-30,-12,rng)
				params.FallingAccelModifier = mod:getRoll(100,135,rng)/100
				params.Variant = 11
				params.BulletFlags = params.BulletFlags | ProjectileFlags.BOUNCE
				npc:FireProjectiles(npc.Position, Vector(0,2+rng:RandomInt(3)):Rotated(rng:RandomInt(360)), 0, params)
			end
			for i=1,2 do
				local params = ProjectileParams()
				params.FallingSpeedModifier = mod:getRoll(-40,-20,rng)
				params.FallingAccelModifier = mod:getRoll(90,120,rng)/100
				params.Variant = 1
				npc:FireProjectiles(npc.Position, Vector(0,2+rng:RandomInt(4)):Rotated(rng:RandomInt(360)), 0, params)
			end
		end
		if sprite:IsEventTriggered("BloodStart") then
			data.bleeding = true
		end
		if sprite:IsEventTriggered("BloodEnd") or sprite:IsEventTriggered("bloodend") then
			data.bleeding = false
		end
		if data.bleeding then
			if npc.FrameCount % 4 == 0 then
				local blood = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				blood.Color = npc.SplatColor
				blood.SplatColor = npc.SplatColor
				blood:Update()

				local bloo2 = Isaac.Spawn(1000, 2, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				bloo2.Color = npc.SplatColor
				bloo2.SplatColor = npc.SplatColor
				bloo2.SpriteScale = Vector(1,1)
				bloo2.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
				bloo2:Update()

				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			end
		end
		if sprite:IsFinished("BecomePile") then
			data.state = "Pile"
			data.pile = true
		else
			mod:spritePlay(sprite, "BecomePile")
		end
	else
		if not npc.Child then
			npc:Kill()
		end
	end
	
	if data.movement == "Idle" then
		mod:spritePlay(sprite, "Idle" .. data.lastDir)
	elseif data.movement == "Walk" or data.movement == "Run" then
		if npc.Velocity:Length() > 0.1 then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				if npc.Velocity.X > 0 then
					data.lastDir = "Right"
				else
					data.lastDir = "Left"
				end
			else
				if npc.Velocity.Y > 0 then
					data.lastDir = "Down"
				else
					data.lastDir = "Up"
				end
			end
		end
		if data.movement == "Walk" then
			mod:spritePlay(sprite, "Walk" .. data.lastDir)
		else
			mod:spritePlay(sprite, "Run" .. data.lastDir)
		end
	end
end

function mod:chummerHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.pile then
		return false
	end
end

function mod.chummerDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().dead = true
		if npc.Child then
			npc.Child:Remove()
		end
	end
	mod.genericCustomDeathAnim(npc, "BecomePile", true, onCustomDeath, false, false)
end

function mod:chummerPathfinderAI(npc1)
	local data1 = npc1:GetData()
	
	if not data1.init then
		npc1:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc1:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc1.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		data1.init = true
	end
	npc1.Visible = false
	
	if npc1.FrameCount > 30 then
		if npc1.Parent and npc1.Parent:Exists() and not mod:isStatusCorpse(npc1.Parent) and (mod:isAnimaChained(npc1.Parent) or npc1.Parent:ToNPC():HasEntityFlags(EntityFlag.FLAG_FREEZE)) then
			npc1.Velocity = Vector.Zero
		elseif npc1.SubType == 0 and npc1.Parent and npc1.Parent:Exists() and not mod:isStatusCorpse(npc1.Parent) then
			local npc = npc1.Parent:ToNPC()
			local data = npc:GetData()
			local target = npc:GetPlayerTarget()
			local targetpos = mod:randomConfuse(npc, target.Position)
			local sprite = npc:GetSprite()
			local room = game:GetRoom()
			
			mod:updateToNPCPosition(npc1, npc, nil, true)
			
			if npc1.FrameCount < 35 then
				npc1.Velocity = Vector.Zero
			elseif data.state == "Idle" then
				if mod:isScare(npc) then
					local targVel = (npc1.Position-targetpos):Resized(7)
					npc1.Velocity = mod:Lerp(npc1.Velocity, targVel, 0.3)
					data.movement = "Walk"
				elseif (math.abs(npc1.Position.X-target.Position.X) < 40 or math.abs(npc1.Position.Y-target.Position.Y) < 40) and room:CheckLine(npc1.Position, target.Position, 0, 0, false, false) and npc.StateFrame > 25 then
					data.state = "Charge"
					local angle = math.ceil((mod:GetAngleDegreesButGood(target.Position-npc1.Position)+45)/90)
					data.chargeDir = Vector(0,-9.5):Rotated(90*angle)
					data.movement = "Run"
				else
					data.movement = "Walk"
					if npc.StateFrame > 110 then
						data.targetPos = mod:FindClosestValidPosition(npc1, target, nil, 400, 0)
						npc.StateFrame = 0
						data.searching = 80
						data.pathType = "closest"
					elseif not data.targetPos or data.targetPos:Distance(npc1.Position) < 35 then
						data.targetPos = mod:FindRandomValidPathPosition(npc1, 3, nil, 50)
						data.pathType = "random"
					end
					
					if room:CheckLine(npc1.Position, targetpos, 0, 0, false, false) then
						local targetvel = (targetpos - npc1.Position):Resized(4.5)
						npc1.Velocity = mod:Lerp(npc1.Velocity, targetvel, 0.3)
					else
						npc1.Pathfinder:FindGridPath(targetpos, 0.52, 900, true)
					end
					
					if sprite:IsEventTriggered("Sound") then
						npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.24, 0, false, math.random(130,150)/100)
					end
				--[[else
					data.movement = "Idle"
					npc1.Velocity = mod:Lerp(npc1.Velocity, Vector.Zero, 0.4)]]
				end
			elseif data.state == "Charge" then
				data.movement = "Run"
				npc1.Velocity = mod:Lerp(npc1.Velocity, data.chargeDir, 0.3)

				if npc1:CollidesWithGrid() then
					data.state = "Idle"
					data.movement = "Idle"
					npc.StateFrame = 0
					data.searching = nil
				end
				
				if sprite:IsEventTriggered("Sound") then
					npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.24, 0, false, math.random(130,150)/100)
				end
			end
		elseif npc1.SubType == 1 and npc1.Parent and npc1.Parent:Exists() and not mod:isStatusCorpse(npc1.Parent) then --Whale
			local npc = npc1.Parent:ToNPC()
			local data = npc:GetData()
			local target = npc:GetPlayerTarget()
			local targetpos = mod:randomConfuse(npc, target.Position)
			local sprite = npc:GetSprite()
			local room = game:GetRoom()

			mod:updateToNPCPosition(npc1, npc, nil, true)

			if data.state == "Idle" then
				if npc.Velocity.X > -0.1 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end

				if mod:isScare(npc) then
					local targetvel = (targetpos - npc1.Position):Resized(-4)
					npc1.Velocity = mod:Lerp(npc1.Velocity, targetvel, 0.3)
				elseif room:CheckLine(npc1.Position, targetpos, 0, 1, false, false) then
					local targetvel = (targetpos - npc1.Position):Resized(1.4)
					npc1.Velocity = mod:Lerp(npc1.Velocity, targetvel, 0.3)
				else
					npc1.Pathfinder:FindGridPath(targetpos, 0.26, 900, true)
				end
			elseif data.state == "Bursting" then
				if mod:isScare(npc) then
					local targetvel = (targetpos - npc1.Position):Resized(-4)
					npc1.Velocity = mod:Lerp(npc1.Velocity, targetvel, 0.3)
				elseif room:CheckLine(npc1.Position, targetpos, 0, 1, false, false) then
					local targetvel = (targetpos - npc1.Position):Resized(0.8)
					npc1.Velocity = mod:Lerp(npc1.Velocity, targetvel, 0.3)
				else
					npc.Pathfinder:FindGridPath(targetpos, 0.15, 900, true)
				end
			end
		else
			npc1:Remove()
		end
	end
end

function mod:chummerPathfinderHurt(npc)
	return false
end