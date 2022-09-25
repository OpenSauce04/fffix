local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:corruptedContusionAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rng = npc:GetDropRNG()
	
	if not data.init then
		if HPBars then
			HPBars:createNewBossBar(npc)
		end
		if data.warpZoneSpawned then
			data.state = "Launched"
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.landingInfo = {"LandAnim", "ButIGetUpAgain", 1, 0, "Idle", 0}
			data.targetPos = target.Position
			--data.zVel = -10
			data.launchedEnemyInfo = {zVel = -5, accel = 0.25, height = -10}
			data.movement = -1
			npc.SpriteOffset = Vector(0,-10)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			local distance = npc.Position:Distance(target.Position)
			data.jumpVel = distance*0.05
		elseif data.dead then
			data.movement = 1
			data.state = "DeathAnim"
		else
			data.state = "Idle"
			data.movement = 0
		end
		if npc.SubType == 1 then
			data.void = true
		end
		data.speed = 6.2
		data.init = true
		npc.StateFrame = 50
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	--Timer so that Sutures won't try to immediately pick up Contusions after tossing them.
	if data.justThrown then
		if data.justThrown > 0 then
			data.justThrown = data.justThrown-1
		else
			data.justThrown = nil
		end
	end
	
	if data.movement == 0 then
		if mod:isScare(npc) then
			local targetDir = (targetpos-npc.Position):Resized(-6)
			npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
		elseif game:GetRoom():CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetDir = (targetpos-npc.Position):Resized(data.speed)
			npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, data.speed/6, 999, true)
		end
	elseif data.movement == 1 then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	end
	
	if npc.Velocity.X > 0 then
		sprite.FlipX = false
	else
		sprite.FlipX = true
	end
	
	if data.state == "Idle" then
		if npc.Velocity:Length() > 0.1 then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				mod:spritePlay(sprite, "WalkHori")
			else
				mod:spritePlay(sprite, "WalkVert")
			end
			mod:spriteOverlayPlay(sprite, "IdleHead")
		else
			sprite:RemoveOverlay()
			sprite:Play("Idle", true)
		end
		
		if npc.StateFrame > 160 and not mod:isScareOrConfuse(npc) then
			sfx:Play(mod.Sounds.CContusionYell, 0.7, 0, false, 0.88)
			data.state = "Chase"
			if target:ToPlayer() then
				local player = target:ToPlayer()
				if player.MoveSpeed < 1 then
					data.speed = math.max(8.2*player.MoveSpeed, 6.5)
				else
					data.speed = 8.2
				end
			else
				data.speed = 8.2
			end
			npc.StateFrame = 0
		end
	elseif data.state == "Chase" then
		--Begins chasing while firing shots behind and leaving creep. Trips at the end of the attack.
		--In Void, projectiles linger behind more than usual and have higher counts.
		if npc.Velocity:Length() > 0.1 then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				mod:spritePlay(sprite, "WalkHori")
			else
				mod:spritePlay(sprite, "WalkVert")
			end
			mod:spriteOverlayPlay(sprite, "RageBody")
		else
			mod:spriteOverlayPlay(sprite, "RageBody")
			sprite:SetFrame("WalkVert", 0)
		end
		
		if npc.FrameCount % 4 == 0 then
			local creep = Isaac.Spawn(1000, 22, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep:SetTimeout(145)
			creep:Update()
		end
		if npc.FrameCount % 6 == 0 then
			local params = ProjectileParams()
			if npc.FrameCount % 12 == 0 then
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
				params.Scale = 1.3
				params.FallingAccelModifier = -0.1
				params.FallingSpeedModifier = 0
				if data.void then
					for i=-80,80,40 do
						npc:FireProjectiles(npc.Position, npc.Velocity:Rotated(180+i):Resized(3), 0, params)
					end
				else
					for i=-50,50,50 do
						npc:FireProjectiles(npc.Position, npc.Velocity:Rotated(180+i):Resized(6), 0, params)
					end
				end
			end
			for i=1,2 do
				params.FallingSpeedModifier = -3-rng:RandomInt(10)
				params.FallingAccelModifier = 1
				params.Scale = 0.4+rng:RandomInt(30)/100
				npc:FireProjectiles(npc.Position, npc.Velocity:Rotated(100+rng:RandomInt(160)):Resized(rng:RandomInt(10)/3), 0, params)
			end
		end
		
		if npc.StateFrame > 80 then
			data.state = "Tripping"
			data.chargeKnocked = true
			data.movement = -1
			data.speed = 7
			npc.StateFrame = 0
			sprite:RemoveOverlay()
		end
	elseif data.state == "Chilling" then
		--Grounded state after tripping or being fired.
		if data.dead then 
			data.state = "Dead"
		elseif npc.StateFrame > ((data.landingInfo and data.landingInfo[4]) or 35) then
			data.state = "GetUp"
			data.landingInfo = {}
		else
			mod:spritePlay(sprite, "GroundIdle")
		end
	elseif data.state == "Tripping" then
		--Fires shots when knocked down after a chase. In Void, fires a more complex burst.
		if data.chargeKnocked then
			if sprite:IsEventTriggered("Shoot") then
				data.chargeKnocked = nil
				if data.void then
					local params = ProjectileParams()
					params.FallingSpeedModifier = 0
					params.FallingAccelModifier = -0.1
					for i=0,360,45 do
						npc:FireProjectiles(npc.Position, Vector(0,11):Rotated(i), 0, ProjectileParams())
					end
					for i=0,360,30 do
						npc:FireProjectiles(npc.Position, Vector(0,5):Rotated(i), 0, params)
					end
				else
					for i=0,360,45 do
						npc:FireProjectiles(npc.Position, Vector(0,10):Rotated(i), 0, ProjectileParams())
					end
				end
			end
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.06)
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		end
		
		if sprite:IsFinished("KnockedDown") then
			data.state = "Chilling"
			npc.StateFrame = 0
			data.movement = 1
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 0.75)
		else
			mod:spritePlay(sprite, "KnockedDown")
		end
	elseif data.state == "GetUp" then
		--Getting up from being knocked down. In Void, he does a jump towards the player.
		if sprite:IsFinished("ButIGetUpAgain") then
			npc.StateFrame = 0
			data.movement = 0
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.CContusionWakeUp, 0.67, 0, false, 1)
			if data.void then
				data.state = "Launched"
				data.targetPos = target.Position
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				local distance = npc.Position:Distance(target.Position)
				data.jumpVel = distance*0.05
				--data.zVel = -12
				data.launchedEnemyInfo = {zVel = -6}
				data.jumped = true
				data.movement = -1
				data.landingInfo = {"LandAnim", "ButIGetUpAgain", 1, 0, "Idle", 0}
			end
		else
			mod:spritePlay(sprite, "ButIGetUpAgain")
		end
	elseif data.state == "Launched" then
		--State for when he's been fired.
		--[[data.zVel = data.zVel+1
		npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y+data.zVel)]]
		if data.launchedEnemyLanded then
			data.launchedEnemyLanded = nil
			sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 0.75)
			npc.SpriteOffset = Vector.Zero
			data.state = data.landingInfo[1]
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			--In Void, when he jumps and lands he fires shots.
			if data.void and data.jumped then
				local poof = Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc):ToEffect()
				poof.DepthOffset = 50
				data.jumped = nil
				local params = ProjectileParams()
				params.FallingSpeedModifier = 0
				params.FallingAccelModifier = -0.1
				npc:FireProjectiles(npc.Position, Vector(11,0), 6, params)
				npc:FireProjectiles(npc.Position, Vector(5,0), 7, params)
				npc.Velocity = npc.Velocity*0.2
			end
		end
		if data.targetPos then
			if npc.Position:Distance(data.targetPos) > 20 then
				local targVel = (data.targetPos-npc.Position):Resized((data.jumpVel or 0))
				npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.2)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
			end
		end
		if npc:CollidesWithGrid() then
			npc.Velocity = npc.Velocity*0.6
		end
		mod:spritePlay(sprite, "Projectile")
	elseif data.state == "Claimed" then
		--Transitionatory state where it's being pulled/prepared to be pulled. So it doesn't get interrupted out of the animations or etc.
		if data.pullPrepared then
			if not data.pullingSuture or not data.pullingSuture:Exists() or data.pullingSuture:GetSprite():IsPlaying("Death") then
				data.pullingSuture = nil
				data.held = nil
				data.state = "Launched"
				--data.zVel = -2
				data.landingInfo = {"LandAnim", "ButIGetKnockedDownAgain", 1, 25, "Chilling", 1}
				data.targetPos = npc.Position
				data.launchedEnemyInfo = {zVel = -2, pos = true}
			end
			
			if sprite:IsPlaying("ButIGetKnockedDownAgain") then
			elseif data.held then
				mod:spritePlay(sprite, "GroundIdle")
			else
				if data.dead then
					mod:spritePlay(sprite, "GroundIdle")
				else
					mod:spritePlay(sprite, "Pulled")
				end
			end
		else
			if not data.pullingSuture or not data.pullingSuture:Exists() or data.pullingSuture:GetSprite():IsPlaying("Death") then
				data.pullingSuture = nil
				data.held = nil
				data.state = "Chilling"
			end
			mod:spritePlay(sprite, "GroundIdle")
		end
	elseif data.state == "LandAnim" then
		--Special state for custom animation on landing.
		--{What state it goes to when landing, what animation to play, movement on landing, downtime on landing, what state after playing anim, what movement after playing anim}
		data.movement = data.landingInfo[3]
		if sprite:IsFinished(data.landingInfo[2]) then
			data.state = data.landingInfo[5]
			data.movement = data.landingInfo[6]
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, data.landingInfo[2])
		end
	elseif data.state == "Dead" then
		--Lying dead on the ground.
		data.movement = 1
		mod:spritePlay(sprite, "GroundIdle")
		npc.CollisionDamage = 0
		npc.DepthOffset = 0
		
		local dead = true
		for _,suture in ipairs(Isaac.FindByType(180, 234, -1, EntityPartition.ENEMY, false)) do
			dead = false
		end
		if dead == true then
			sprite:Play("CorpseDeath", true)
			npc:BloodExplode()
			npc:Die()
		end
	elseif data.state == "DeathAnim" then
		--Animation for when it's dying.
		data.movement = 1
		if sprite:IsFinished("DeadAnim") then
			data.state = "Dead"
		end
		npc.CollisionDamage = 0
		
		if sprite:IsEventTriggered("Explosion") then
			npc:BloodExplode()
		end
		if sprite:IsEventTriggered("BloodStart") then
			data.bleeding = true
		end
		if sprite:IsEventTriggered("BloodEnd") then
			data.bleeding = false
		end
		if data.bleeding then
			if npc.FrameCount % 4 == 0 then
				local blood = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				blood.Color = npc.SplatColor
				blood.SplatColor = npc.SplatColor
				blood:Update()

				local bloo2 = Isaac.Spawn(1000, 2, 160, npc.Position, RandomVector()*3, npc):ToEffect();
				bloo2.Color = npc.SplatColor
				bloo2.SplatColor = npc.SplatColor
				bloo2.SpriteScale = Vector(1,1)
				bloo2.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
				bloo2:Update()

				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			end
		end
		if npc.SpriteOffset.Y < 0 and not data.launchedEnemyInfo then
			data.launchedEnemyInfo = {zVel = 0}
		end
	end
end

function mod.corruptedContusionDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().dead = true
		deathAnim.CollisionDamage = 0
	end
	mod.genericCustomDeathAnim(npc, "DeadAnim", false, onCustomDeath, true, true)
end