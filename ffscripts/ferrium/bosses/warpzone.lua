local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

--These are Brisket Colors, not blood shots
local softPurple = Color(1.5, 0.75, 2, 1, 0, 0, 0)
local darkBlurple = Color(0.9, 0.55, 1.25, 1, 0, 0, 0)
local concordGrape = Color(1.4, 1, 2.21, 1, 0, 0, 0)
local wiltedLilac = Color(0.75, 0.56, 1.08, 1, 0, 0, 0)

local lightLavendery = Color(2.65, 1.28, 3.45, 1, 0, 0, 0)
local raspberryVanilla = Color(3.15, 1.15, 2.45, 1, 0, 0, 0)
local dingyPerfume = Color(2.35, 1.35, 2.2, 1, 0, 0, 0)

local smartMagenta = Color(1.2, 0.35, 1.7, 1, 0.27843, 0, 0.4549)


--These are Colors for Tears (Variant 4)
local darkBlurple2 = Color(0.28, 0.11, 0.32, 1, 0, 0, 0)
local concordGrape2 = Color(0.35, 0.18, 0.5, 1, 0, 0, 0)
local periwinkleBot = Color(0.65, 0.23, 1, 1, 0, 0, 0)

local lightLavendery2 = Color(0.84,0.36,0.78, 1, 0, 0, 0)
local raspberryVanilla2 = Color(0.95, 0.32, 0.47, 1, 0, 0, 0)
local dingyPerfume2 = Color(0.7, 0.36, 0.49, 1, 0, 0, 0)

local ripePlum = Color(0.6,0.2,0.6, 1, 0, 0, 0)


--Blood colors, for the poof effects
local smartMagenta2 = Color(0.4, 0.31, 1.9, 1, 0, 0, 0.4549)
local grapeSmoothie = Color(0.3, 0.55, 1, 1, 0, 0.1, 0.4)
local giantGrape = Color(0.56, 0.28, 2, 1, 0, 0, 0.4549)
local bigBerry = Color(0.8, 0.25, 2, 1, 0, 0, 0.4549)

local function warpzoneChooseNextAttack(npc, rng)
	local data = npc:GetData()
	local attacks = data.attackList
	local phase = data.boss
	
	if phase == 1 then
		if data.lastAttack == "Cluster" then
			data.lastAttack = "Rotate"
			return "Rotate"
		elseif data.lastAttack == "Rotate" then
			data.lastAttack = "Cluster"
			return "Cluster"
		end
	elseif phase == 2 then
		if data.lastAttack == "useBrain" then
			data.lastAttack = "Brain"
			return "Brain"
		elseif data.lastAttack == "Brain" then
			local attack = attacks[rng:RandomInt(2)+1]
			data.lastAttack = attack
			return attack
		elseif data.lastAttack == "Cluster" then
			local attack = rng:RandomInt(2)
			if attack == 0 then
				data.lastAttack = "Rotate"
				return "Rotate"
			else
				data.lastAttack = "Brain"
				return "Brain"
			end
		elseif data.lastAttack == "Rotate" then
			local attack = rng:RandomInt(2)
			if attack == 0 then
				data.lastAttack = "Cluster"
				return "Cluster"
			else
				data.lastAttack = "Brain"
				return "Brain"
			end
		end
	elseif phase == 3 then
		if data.lastAttack == "useSpin" then
			data.lastAttack = "Spin"
			return "Spin"
		elseif data.lastAttack == "Brain" then
			local attack = attacks[rng:RandomInt(2)+1]
			data.lastAttack = attack
			return attack
		else
			local attack = rng:RandomInt(4)+1
			if attack == 3 then
				attack = 4
			end
			data.lastAttack = attacks[attack]
			return data.lastAttack
		end
	end
end

--Table of possible attacks for Warp Zone's final "phase"
local spinAttacks = {
	[1] = function(params, npc, data, mode) --Straight Lines
		if npc.FrameCount % 4 == 0 then
			params.Color = concordGrape2
			local offset = 0
			if mode then
				data.spinOffset = data.spinOffset+27
				offset = data.spinOffset
			else
				data.spinOffset2 = data.spinOffset2-27
				offset = data.spinOffset2
			end
			for i=0,180,180 do
				for j=-27,27,27 do
					npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,6):Rotated(offset+i+j), 0, params)
				end
			end
		end
	end,
	[2] = function(params, npc, data, mode) --Rotating 6
		if npc.FrameCount % 4 == 0 then
			params.Color = ripePlum
			local offset = 0
			if mode then
				data.spinOffset = data.spinOffset-51
				offset = data.spinOffset
			else
				data.spinOffset2 = data.spinOffset2+51
				offset = data.spinOffset2
			end
			for i=0,360,120 do
				npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,6):Rotated(offset+i), 0, params)
			end
		end
	end,
	[3] = function(params, npc, data, mode) --Rotating 4
		if npc.FrameCount % 5 == 0 then
			params.Color = lightLavendery2
			local offset = 0
			if mode then
				data.spinOffset = data.spinOffset+16
				offset = data.spinOffset
			else
				data.spinOffset2 = data.spinOffset2-16
				offset = data.spinOffset2
			end
			for i=0,360,90 do
				npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,6):Rotated(offset+i), 0, params)
			end
		end
	end,
	[4] = function(params, npc, data, mode) --Alternating Circles
		if npc.FrameCount % 11 == 0 then
			params.Color = dingyPerfume2
			local offset = 0
			if mode then
				data.spinOffset = data.spinOffset+54
				offset = data.spinOffset
			else
				data.spinOffset2 = data.spinOffset2-54
				offset = data.spinOffset2
			end
			for i=0,360,36 do
				npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,6):Rotated(offset+i), 0, params)
			end
		end
	end,
	[5] = function(params, npc, data, mode) --Rotating spread
		if npc.FrameCount % 5 == 0 then
			params.Color = raspberryVanilla2
			local offset = 0
			if mode then
				data.spinOffset = data.spinOffset+60
				offset = data.spinOffset
			else
				data.spinOffset2 = data.spinOffset2-60
				offset = data.spinOffset2
			end
			for i=-30,30,20 do
				npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,5):Rotated(offset+i), 0, params)
			end
		end
	end,
	[6] = function(params, npc, data, mode) --Rotating line
		params.Color = darkBlurple2
		local offset = 0
		if mode then
			data.spinOffset = data.spinOffset+17
			offset = data.spinOffset
		else
			data.spinOffset2 = data.spinOffset2-17
			offset = data.spinOffset2
		end
		npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,7):Rotated(offset), 0, params)
	end,
	[7] = function(params, npc, data, mode) --Rotating triples
		if npc.FrameCount % 4 == 0 then
			params.Color = periwinkleBot
			local offset = 0
			if mode then
				data.spinOffset = data.spinOffset+36
				offset = data.spinOffset
			else
				data.spinOffset2 = data.spinOffset2-36
				offset = data.spinOffset2
			end
			for i=-42,42,42 do
				npc:FireProjectiles(npc.Position+Vector(0,-40), Vector(0,5.5):Rotated(offset+i), 0, params)
			end
		end
	end,
}


mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if npc.Variant == mod.FF.WarpZone.Var then
		mod:warpZoneAI(npc)
	elseif npc.Variant == mod.FF.CorruptedContusion.Var then
		mod:corruptedContusionAI(npc)
	elseif npc.Variant == mod.FF.CorruptedSuture.Var then
		mod:corruptedSutureAI(npc)
	elseif npc.Variant == mod.FF.CorruptedLarry.Var then
		mod:corruptedLarryAI(npc)
	elseif npc.Variant == mod.FF.PaleGusher.Var then
		mod:paleGusherAI(npc)
	elseif npc.Variant == mod.FF.CorruptedMonstro.Var then
		mod:corruptedMonstroAI(npc)
	end
end, mod.FFID.Boss)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, damage, flag, source)
	if npc.Variant == mod.FF.WarpZone.Var then
		local data = npc:GetData()
		if data.hiding == true then
			return false
		elseif data.resist == true and flag ~= flag | DamageFlag.DAMAGE_CLONES then
			npc:TakeDamage(damage*0.05, flag | DamageFlag.DAMAGE_CLONES, source, 0)
			return false
		end
	elseif npc.Variant == mod.FF.CorruptedSuture.Var then
		local data = npc:GetData()
		if not data.teleportCooldown and data.phase1 then
			data.teleport = true
		end
		if source.Type == 1000 and source.Variant == EffectVariant.FIRE_JET then
			return false
		end
	end
end, mod.FFID.Boss)

function mod:warpZoneAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		data.attackList = {
			"Rotate",
			"Cluster",
			--{"Brain", 0},
			--{"Spin", 0},
		}
		
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		data.boss = 1
		data.state = "Appear"
		sprite:Play("Particle", true)
		sprite:Play("Appear", true)
		data.idleCount = 0
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		data.zapCountdown = 60
		data.initPos = npc.Position
		data.chosenBosses = mod:getSeveralDifferentNumbers(2, 3, rng)
		data.lastAttack = "Cluster"
		data.loopedSound = 0
		
		local warpzoneData = StageAPI.GetBossData("Warp Zone")
		if game:GetRoom():GetType() == RoomType.ROOM_BOSS and (warpzoneData.BossName == "gfx/bosses/warp_zone/bossname_warpzone.png" or warpzoneData.BossName == "gfx/bosses/warp_zone/bossname_warpzooooone.png") then
			sfx:Play(mod.Sounds.WarpZoneMeatBoy, 0.7, 0, false, 1)
		end
		data.init = true
	else
		data.zapCountdown = data.zapCountdown-1
		npc.StateFrame = npc.StateFrame+1
	end
	
	if not data.isSpecturnInvuln then
		if not data.initPos then
			data.initPos = npc.Position
		end
		npc.Velocity = data.initPos-npc.Position
	else
		data.initPos = nil
	end
	
	if data.state ~= "Spawn" then
		if npc.HitPoints < 3*npc.MaxHitPoints/4 and data.boss == 1 then
			data.resist = true
			data.interrupt = "Spawn"
			data.lastAttack = "useBrain"
			if not data.addedBrain then
				table.insert(data.attackList, "Brain")
				data.addedBrain = true
			end
		elseif npc.HitPoints < 4*npc.MaxHitPoints/9 and data.boss == 2 then
			data.resist = true
			data.interrupt = "Spawn"
			data.lastAttack = "useSpin"
			if not data.addedSpin then
				table.insert(data.attackList, "Spin")
				data.addedSpin = true
			end
		end
	end
	
	--Cosmetic lightning
	if data.zapCountdown < 0 and math.random(30) == 1 and not sprite:IsOverlayPlaying("ChaosOverlay") then
		sprite:RemoveOverlay()
		sprite:PlayOverlay("Spark" .. math.random(3))
		data.zapCountdown = math.random(20,60)
	end
	
	if data.colorFade then
		if data.colorFade == 0 then
			npc.Color = Color.Lerp(npc.Color, Color(1,1,1,0.3,0,0,0), 0.3)
		elseif data.colorFade == 1 then
			npc.Color = Color.Lerp(npc.Color, Color(1,1,1,1,0,0,0), 0.3)
			if npc.Color.A >= 0.95 then
				npc.Color = Color(1,1,1,1,0,0,0)
				data.colorFade = nil
			end
		end
	end
	
	if data.laughCooldown then
		if data.laughCooldown > 0 then
			data.laughCooldown = data.laughCooldown-1
		else
			data.laughCooldown = nil
		end
	end
	
	--Color testing
	--[[if npc.FrameCount % 50 == 0 then
		for i=1,4 do
			if i % 2 == 0 then
				local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,6):Rotated(90*i), npc):ToProjectile()
				local pSprite = proj:GetSprite()
				pSprite:ReplaceSpritesheet(0, "gfx/projectiles/brisket_tear.png")
				pSprite:LoadGraphics()
				proj:GetData().customProjSplat = "gfx/projectiles/brisket_splat.png"
				proj.Color = lightLavendery
			else
				local proj = Isaac.Spawn(9, 4, 0, npc.Position, Vector(0,6):Rotated(90*i), npc):ToProjectile()
				local pSprite = proj:GetSprite()
				proj.Color = Color(0.65, 0.23, 1, 1, 0, 0, 0)
			end
		end
	end]]
	
	--The way Warp Zone's animations work, everything has to be cycle based to not look odd when switching animations.
	if sprite:IsFinished("Idle") or sprite:IsFinished("Laugh") then
		data.idleCount = data.idleCount+1
		if data.chaosCard then
			data.chaosCard = nil
			sfx:Play(mod.Sounds.WarpZoneChaosCardUnfall, 1, 0, false, 1)
			data.state = "Chaos"
		elseif data.interrupt then
			data.state = data.interrupt
			data.interrupt = nil
		elseif data.idleCount > 0 and not data.hiding then
			--local state = mod.ChooseNextAttack(data.attackList, rng)
			local state = warpzoneChooseNextAttack(npc, rng)
			if state == "Rotate" then
				data.rotationDir = rng:RandomInt(2)
				data.rotationVec = Vector(0,3.5):Rotated(rng:RandomInt(360))
			elseif state == "Cluster" then
				data.clustering = 0
			elseif state == "Brain" then
				data.volleyNum = 0
			end
			--state = "Spin"
			data.state = state
		end
		sprite:Play("Particle", true)
		sprite:Play("Idle", true)
	end
	
	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")
	elseif data.state == "Hiding" then
		if sprite:IsEventTriggered("Sound") and sprite:IsPlaying("Laugh") then
			npc:PlaySound(mod.Sounds.WarpZoneLaugh, 1, 0, false, 1, 0.75)
		end
		if data.laugh and not sprite:IsPlaying("Laugh") then
			data.laughCooldown = 300
			sprite:Play("Laugh", true)
		else
			data.laugh = nil
		end
		
		local dead = true
		for _,boss in ipairs(Isaac.FindByType(mod.FFID.Boss, -1, -1)) do
			if boss.Variant == mod.FF.CorruptedMonstro.Var or boss.Variant == mod.FF.CorruptedLarry.Var or boss.Variant == mod.FF.CorruptedSuture.Var or boss.Variant == mod.FF.CorruptedContusion.Var then
				dead = false
			end
		end
		
		if dead == true and npc.StateFrame > 10 then
			data.state = "Return"
		end
	elseif data.state == "Cluster" then
		--Lobs 3 large clusters of tears that track Isaac as they fall. On impact, they split into a circle of shots and an orbiting ring.
		if sprite:IsFinished("Cluster") then
			data.state = "Idle"
			data.idleCount = 0
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.WarpZonePrepare, 0.8, 0, false, 1)
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(mod.Sounds.WarpZoneBarf, 0.8, 0, false, 1)
			local vec = (target.Position-npc.Position)
			
			local poof = Isaac.Spawn(1000, 16, 5, npc.Position+Vector(0,-58), Vector.Zero, npc):ToEffect()
			poof.DepthOffset = 500
			poof.Color = giantGrape
			poof.SpriteScale = Vector(0.9,0.8)
			
			for j=1,3 do
				local bigProj = Isaac.Spawn(9, 0, 0, npc.Position, vec:Resized(8):Rotated(rng:RandomInt(50)-25), npc):ToProjectile()
				local bData = bigProj:GetData()
				bData.projType = "WarpZone"
				bData.detail = "ClusterCenter"
				bigProj.Scale = 2
				bigProj.FallingSpeed = -10*j
				bigProj.FallingAccel = 0.9+0.2*j
				mod:makeBrisketProjSprite(bigProj)
				bigProj.Color = smartMagenta
				mod:makeCharmProj(npc, bigProj)
				bData.shotNum = j
				bData.target = target
				bData.projTable = {}
				
				for i=1,9 do
					local proj = Isaac.Spawn(9, 4, 0, npc.Position+Vector(0,5):Rotated(10*i), vec:Resized(10), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "WarpZone"
					pData.detail = "Cluster"
					proj.Scale = 0.6+rng:RandomInt(40)/100
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.12
					local color = math.random(2)
					if color == 1 then
						proj.Color = lightLavendery2
					elseif color == 2 then
						proj.Color = ripePlum
					end
					proj.Parent = bigProj
					mod:makeCharmProj(npc, proj)
					proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
					bData.projTable[i] = proj
				end
			end
		else
			mod:spritePlay(sprite, "Cluster")
		end
	elseif data.state == "Rotate" then
		--Chooses a random direction, then spins that way while firing shots that orbit itself. At the end of the attack, fires an orbiting ring.
		if sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.WarpZoneGrunt, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, math.random(90,110)/100)
		elseif sprite:IsEventTriggered("EndSpin") then
			mod.scheduleForUpdate(function()
				Isaac.Spawn(306, 0, 150, npc.Position+Vector(0,-45), Vector.Zero, nil)
				sfx:Stop(SoundEffect.SOUND_DEATH_BURST_LARGE)
			end, 0)
			sfx:Play(SoundEffect.SOUND_HEARTOUT, 0.6, 0, false, 1)
		end
		if data.rotationDir == 0 then
			if sprite:IsFinished("RotateCW") then
				data.state = "Idle"
				data.idleCount = 0
			elseif sprite:IsEventTriggered("EndSpin") then
				for i=30,360,30 do
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, data.rotationVec:Rotated(i):Resized(2.5), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "WarpZone"
					pData.detail = "Rotate"
					pData.rotateDir = 1
					pData.originalDir = data.rotationVec:Rotated(i):Resized(2.5)
					pData.originalPos = npc.Position
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.12
					proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
					mod:makeCharmProj(npc, proj)
					mod:makeBrisketProjSprite(proj)
					if i % 60 == 0 then
						proj.Color = darkBlurple
					else
						proj.Color = softPurple
					end
				end
			elseif sprite:IsEventTriggered("Shoot") then
				for i=0,1 do
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, data.rotationVec:Rotated(180*i), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "WarpZone"
					pData.detail = "Rotate"
					pData.rotateDir = 1
					pData.originalDir = data.rotationVec:Rotated(180*i)
					pData.originalPos = npc.Position
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.12
					proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
					mod:makeCharmProj(npc, proj)
					mod:makeBrisketProjSprite(proj)
					if i == 0 then
						proj.Color = darkBlurple
					else
						proj.Color = softPurple
					end
				end
				data.rotationVec = data.rotationVec:Rotated(-100)
			else
				mod:spritePlay(sprite, "RotateCW")
			end
		else
			if sprite:IsFinished("RotateCCW") then
				data.state = "Idle"
				data.idleCount = 0
			elseif sprite:IsEventTriggered("EndSpin") then
				for i=30,360,30 do
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, data.rotationVec:Rotated(i):Resized(2.5), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "WarpZone"
					pData.detail = "Rotate"
					pData.rotateDir = -1
					pData.originalDir = data.rotationVec:Rotated(i):Resized(2.5)
					pData.originalPos = npc.Position
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.12
					proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
					mod:makeCharmProj(npc, proj)
					mod:makeBrisketProjSprite(proj)
					if i % 60 == 0 then
						proj.Color = darkBlurple
					else
						proj.Color = softPurple
					end
				end
			elseif sprite:IsEventTriggered("Shoot") then
				for i=0,1 do
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, data.rotationVec:Rotated(180*i), npc):ToProjectile()
					local pData = proj:GetData()
					pData.projType = "WarpZone"
					pData.detail = "Rotate"
					pData.rotateDir = -1
					pData.originalDir = data.rotationVec:Rotated(180*i)
					pData.originalPos = npc.Position
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.12
					proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
					mod:makeCharmProj(npc, proj)
					mod:makeBrisketProjSprite(proj)
					if i == 0 then
						proj.Color = darkBlurple
					else
						proj.Color = softPurple
					end
				end
				data.rotationVec = data.rotationVec:Rotated(100)
			else
				mod:spritePlay(sprite, "RotateCCW")
			end
		end
	elseif data.state == "Brain" then
		--Fires a string of brain worm shots, that turn 90 degrees if the player is at a right angle to its velocity. Only the leading shot changes paths.
		if sprite:IsFinished("Brain") then
			data.state = "Idle"
			data.brainDir = nil
			data.prevShot = nil
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.WarpZoneSpit, 1, 0, false, math.random(90,110)/100)
			
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position+Vector(0,-45)+Vector(math.random(-10,10),math.random(-10,10)), Vector.Zero, npc):ToEffect()
			poof.DepthOffset = 500
			poof.Color = grapeSmoothie
			poof.SpriteScale = Vector(0.25,0.35)
			
			if not data.brainDir then
				data.brainDir = (target.Position-npc.Position):Resized(7)
				local proj = Isaac.Spawn(9, 0, 0, npc.Position, data.brainDir, npc):ToProjectile()
				data.prevShot = proj
				proj:GetData().projType = "WarpZone"
				proj:GetData().detail = "Brain"
				proj:GetData().target = target
				proj.FallingSpeed = 0
				proj.FallingAccel = -0.105
				proj.Scale = 2
				mod:makeBrisketProjSprite(proj)
				proj.Color = softPurple
			else
				local proj = Isaac.Spawn(9, 0, 0, npc.Position, data.brainDir, npc):ToProjectile()
				proj:GetData().projType = "WarpZone"
				proj:GetData().detail = "Brain"
				proj:GetData().target = target
				if data.prevShot and data.prevShot:Exists() then
					proj.Parent = data.prevShot
				end
				data.prevShot = proj
				proj.FallingSpeed = 0
				proj.FallingAccel = -0.105
				proj.Scale = 2-math.min(1.6,data.volleyNum/2)
				mod:makeBrisketProjSprite(proj)
				proj.Color = softPurple
			end
			data.volleyNum = data.volleyNum+1
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.WarpZoneChew, 1, 0, false, math.random(90,110)/100)
		else
			mod:spritePlay(sprite, "Brain")
		end
	elseif data.state == "Spin" then
		--Takes 2 random attacks from the table at the top of the file, and smushes them together. One is clockwise, the other counterclockwise. 
		if sprite:IsFinished("Spin") then
			data.state = "Idle"
		elseif sprite:IsEventTriggered("StartSpin") then
			data.spinning = true
			data.chosenAttacks = mod:getSeveralDifferentNumbers(2, #spinAttacks, rng)
			data.spinOffset = rng:RandomInt(360)
			data.spinOffset2 = data.spinOffset-180
		elseif sprite:IsEventTriggered("EndSpin") then
			data.spinning = false
			sfx:Play(mod.Sounds.WarpZoneSpinEnd, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Sound2") then
			sfx:Play(mod.Sounds.WarpZoneSpinning, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.WarpZoneSpinStart, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "Spin")
		end
		
		if data.spinning then
			if npc.FrameCount % 3 == 0 then
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, math.random(90,110)/100)
			end
			local params = ProjectileParams()
			params.FallingSpeedModifier = -0.02
			params.FallingAccelModifier = -0.125
			params.DepthOffset = 100
			params.Variant = 4
			spinAttacks[data.chosenAttacks[1]](params, npc, data, true)
			spinAttacks[data.chosenAttacks[2]](params, npc, data, false)
			--spinAttacks[6](params, npc, data, true)
			--spinAttacks[7](params, npc, data, false)
		end
	elseif data.state == "Spawn" then
		--Spawning bosses and goes invulnerable.
		if sprite:IsFinished("SpawnGemini") or sprite:IsFinished("SpawnLarry") or sprite:IsFinished("SpawnMonstro") then
			data.state = "Hiding"
			sprite:Play("Idle")
			data.boss = data.boss+1
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Spawn") then
			local poof = Isaac.Spawn(1000, 16, 5, npc.Position+Vector(0,-58), Vector.Zero, npc):ToEffect()
			poof.DepthOffset = 500
			poof.Color = bigBerry
			poof.SpriteScale = Vector(0.9,0.8)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 1)
			data.hiding = true
			data.colorFade = 0
			if data.chosenBosses[data.boss] == 1 then
				local contusion = Isaac.Spawn(mod.FF.CorruptedContusion.ID, mod.FF.CorruptedContusion.Var, 0, npc.Position+Vector(20,0), Vector.Zero, npc):ToNPC()
				contusion:GetData().warpZoneSpawned = true
				contusion:Update()
				local suture = Isaac.Spawn(mod.FF.CorruptedSuture.ID, mod.FF.CorruptedSuture.Var, 0, npc.Position+Vector(-20,0), Vector(0,10), npc):ToNPC()
				suture:GetData().warpZoneSpawned = true
				suture:Update()
			elseif data.chosenBosses[data.boss] == 2 then
				for i=-1,1,2 do
					local larry1 = Isaac.Spawn(mod.FF.CorruptedLarry.ID, mod.FF.CorruptedLarry.Var, 0, npc.Position+Vector(i*20,4), Vector(i*5,4), npc):ToNPC()
					for i=0,3 do
						local larry2 = Isaac.Spawn(mod.FF.CorruptedLarry.ID, mod.FF.CorruptedLarry.Var, 0, npc.Position+Vector(i*20,4), Vector(i,1), npc):ToNPC()
						larry2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						larry2.Position = larry1.Position
					end
					larry1:GetData().warpzoneSpawned = true
					larry1:Update()
				end
			elseif data.chosenBosses[data.boss] == 3 then
				local monstro = Isaac.Spawn(mod.FF.CorruptedMonstro.ID, mod.FF.CorruptedMonstro.Var, 0, npc.Position, Vector(0,9), npc):ToNPC()
				monstro:GetData().warpzoneSpawned = true
				monstro:Update()
			end
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(mod.Sounds.WarpZoneGrunt, 1, 0, false, 0.8)
		else
			if data.chosenBosses[data.boss] == 1 then
				mod:spritePlay(sprite, "SpawnGemini")
			elseif data.chosenBosses[data.boss] == 2 then
				mod:spritePlay(sprite, "SpawnLarry")
			elseif data.chosenBosses[data.boss] == 3 then
				mod:spritePlay(sprite, "SpawnMonstro")
			end
		end
	elseif data.state == "Chaos" then
		--Fires a chaos card back at Isaac if hit by one.
		if sprite:IsFinished("ChaosSpit") then
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.WarpZoneSpit, 1, 0, false, 1)
			local proj = Isaac.Spawn(9, 8, 0, npc.Position, (target.Position-npc.Position):Resized(10), npc):ToProjectile()
			local pSprite = proj:GetSprite()
			pSprite:Load("gfx/002.009_chaos card tear.anm2", true)
			pSprite:Play("Rotate", true)
			proj:GetData().projType = "ChaosCard"
			proj.Scale = 1
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_1, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "ChaosSpit")
		end
	elseif data.state == "Return" then
		if sprite:IsFinished("Return") then
			data.state = "Idle"
			data.hurtSound = nil
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(mod.Sounds.WarpZoneSmile, 1, 0, false, 1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			data.hiding = false
			data.resist = false
			data.colorFade = 1
		else
			if not data.hurtSound then
				data.hurtSound = true
				npc:PlaySound(mod.Sounds.WarpZoneHurt, 1, 0, false, 1)
			end
			mod:spritePlay(sprite, "Return")
		end
	elseif data.state == "Appear" then
		if sprite:IsFinished("Appear") then
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.WarpZonePhase, 1.3, 0, false, 0.8)
			npc:PlaySound(mod.Sounds.WarpZoneRoar, 1, 0, false, 1)
			mod.scheduleForUpdate(function()
				Isaac.Spawn(20, 0, 150, npc.Position+Vector(0,-45), Vector.Zero, nil)
				sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			end, 0)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif sprite:IsEventTriggered("Sound2") then
			if not data.firstSound then
				sfx:Play(mod.Sounds.WarpZonePhase, 0.5, 0, false, 1.5)
				data.firstSound = true
			else
				sfx:Play(mod.Sounds.WarpZonePhase, 1, 0, false, 1.1)
				mod.scheduleForUpdate(function()
					Isaac.Spawn(306, 0, 150, npc.Position+Vector(0,-45), Vector.Zero, nil)
					sfx:Stop(SoundEffect.SOUND_DEATH_BURST_LARGE)
				end, 0)
			end
		end
		
		data.loopedSound = mod:Lerp(data.loopedSound, 0.6, 0.025)
	end
	
	--Cosmetic swirling particle.
	if npc.FrameCount % 380 == 0 and npc.FrameCount > 0 then
		local particle = Isaac.Spawn(1000, 1750, 11, npc.Position, Vector.Zero, npc):ToEffect()
		particle.Parent = npc
		particle:GetData().initialRot = math.random(360)
		particle:GetData().opacity = 128
		particle:Update()
		particle:Update()
	end

	if data.hiding then
		data.loopedSound = mod:Lerp(data.loopedSound, 0.35, 0.3)
	elseif data.state ~= "Appear" and data.loopedSound < 0.55 then
		data.loopedSound = mod:Lerp(data.loopedSound, 0.6, 0.3)
	end
	sfx:SetAmbientSound(mod.Sounds.WarpZoneBackground, data.loopedSound or 0, 1)
end

function mod.warpZoneProj(v, d)
	if d.projType == "WarpZone" then
		if d.detail == "Rotate" then
			local targetpos = d.originalPos+d.originalDir:Rotated(v.FrameCount*2.5*d.rotateDir):Resized(d.originalDir:Length()*v.FrameCount)
			v.Velocity = targetpos-v.Position
			
			if v.FrameCount > 200 then
				v:Die()
			end
		elseif d.detail == "ClusterCenter" then
			local rng = v:GetDropRNG()
			if d.shotNum == 2 then
				if v.FallingSpeed > 0 then
					v.FallingSpeed = v.FallingSpeed*0.75
				end
				v.Velocity = mod:Lerp(v.Velocity, (d.target.Position-v.Position):Resized(6), 0.1)
			elseif d.shotNum == 3 then
				if v.FallingSpeed > 0 then
					v.FallingSpeed = v.FallingSpeed*0.66
				end
				v.Velocity = mod:Lerp(v.Velocity, (d.target.Position-v.Position):Resized(10), 0.1)
			end
			
			if v:IsDead() then
				local poof = Isaac.Spawn(1000, 16, 0, v.Position, Vector.Zero, v):ToEffect()
				poof.SpriteOffset = Vector(0, v.Height)
				poof.Color = smartMagenta2
				poof.SpriteScale = Vector(0.5,0.5)
				sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
				for i=1,(#d.projTable or 0) do
					if d.projTable[i] and d.projTable[i]:Exists() then
						local proj = d.projTable[i]
						proj.Position = v.Position
						proj.Velocity = v.Velocity:Rotated(40*i):Resized(5)
						proj.FallingAccel = -0.05
						proj.Height = -10
						local data = proj:GetData()
						data.originalPos = v.Position
						data.originalDir = v.Velocity:Rotated(40*i):Resized(5)
						data.rotateDir = 1
						data.clusterRotate = true
						data.clusterFrames = 0
					end
				end
				
				for i=1,6+(d.shotNum or 0)*2 do
					local num = 4+d.shotNum*2
					local angleShift = 360/num
					local proj = Isaac.Spawn(9, 4, 0, v.Position, (d.target.Position-v.Position):Resized(10):Rotated(i*angleShift+angleShift/2), v):ToProjectile()
					proj.Scale = 0.6+rng:RandomInt(40)/100
					proj.FallingSpeed = 0
					proj.FallingAccel = -0.08
					proj.Color = concordGrape2
					if v:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
						proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
					end
					if v:HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) then
						proj:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
					end
				end
			end
		elseif d.detail == "Cluster" then
			local rng = v:GetDropRNG()
			if d.clusterRotate then
				local targetpos = d.originalPos+d.originalDir:Rotated(d.clusterFrames*10*d.rotateDir):Resized(d.originalDir:Length()*math.min(80, d.clusterFrames/2))
				v.Velocity = targetpos-v.Position
				d.clusterFrames = d.clusterFrames+1
				if d.clusterFrames < 40 then
					v.FallingAccel = 0
					v.Height = -10
				else
					v.FallingAccel = 1
				end
			elseif v.Parent and v.Parent:Exists() then
				v.Velocity = mod:Lerp(v.Velocity, ((v.Parent.Position+Vector(0,20):Rotated(rng:RandomInt(360)))-v.Position):Resized(25), 0.1)
				v.Height = v.Parent:ToProjectile().Height
				v.FallingAccel = 0
			end
		elseif d.detail == "Brain" then
			if v.FrameCount > 160 then
				v.FallingAccel = 1
			end
			if v.Parent and v.Parent:Exists() then
				if not d.recordParent then
					d.recordParent = {}
				end
				table.insert(d.recordParent, {position = v.Parent.Position, velocity = v.Parent.Velocity})
				if #d.recordParent > 5 then
					table.remove(d.recordParent, 1)
				end
				
				if #d.recordParent > 3 then
					--[[local targetpos = mod:Lerp(v.Position, d.recordParent[2].position, 0.2)
					v.Velocity = targetpos - v.Position]]
					v.Position = d.recordParent[1].position
					v.Velocity = d.recordParent[1].velocity
				end
			else
				local targAngle = mod:GetAngleDifference((d.target.Position-v.Position), v.Velocity)
				if math.abs(targAngle-270) < 20 then
					v.Velocity = v.Velocity:Rotated(-90)
				elseif math.abs(targAngle-90) < 20 then
					v.Velocity = v.Velocity:Rotated(90)
				end
			end
			
			if v.FrameCount % 60 == 0 then
				d.flash = true
				d.flashTimer = 15
			end
			
			if d.flash then
				if d.flashTimer > 0 then
					d.flashTimer = d.flashTimer-1
					if d.flashTimer > 10 then
						local color = Color.Lerp(v.Color, smartMagenta, 0.4)
						v.Color = color
					else
						local color = Color.Lerp(v.Color, softPurple, 0.1)
						v.Color = color
					end
				else
					d.flash = nil
					v.Color = softPurple
				end
			end
			
			if v.FrameCount % 3 == 0 then
				local trail = Isaac.Spawn(1000, 111, 0, v.Position+v.Velocity, RandomVector()*2, v):ToEffect()
				trail.Color = smartMagenta2
				local scaler = v.Scale*math.random(50,70)/100
				trail.SpriteScale = Vector(scaler, scaler)   
				trail.SpriteOffset = Vector(0, v.Height+7)
				trail.DepthOffset = -80
				trail:Update()
			end
		elseif d.detail == "MonstroSplit" then
			if v.FrameCount > 30 then
				v:Die()
				for i=0,360,90 do
					local proj = Isaac.Spawn(9, 0, 0, v.Position, Vector(0,8):Rotated(i), v):ToProjectile()
					proj.ProjectileFlags = v.ProjectileFlags
					mod:makeBrisketProjSprite(proj)
					proj.Color = softPurple
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, projectile)
	local proj = projectile:ToProjectile()
	local d = proj:GetData()
	
	if d.projType == "ChaosCard" then
		local e = Isaac.Spawn(1000, mod.FF.ChaosCardLeftover.Var, mod.FF.ChaosCardLeftover.Sub, proj.Position, Vector.Zero, proj):ToEffect()
		e:GetSprite():Play("Stuck", true)
		e:GetSprite().Rotation = 90+proj.Velocity:GetAngleDegrees()
		e.SpriteOffset = Vector(0,proj.Height)
	end
end, 9)

function mod.chaosCardProjColl(v, coll)
	local d = v:GetData()
	if d.projType == "ChaosCard" then
		if coll:ToPlayer() then
			local player = coll:ToPlayer()
			if not player:GetData().chaosCarded then
				player:UseCard(Card.CARD_SOUL_LOST, 257)
				player:GetData().chaosCarded = true
			end
			return true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, coll)
	if coll:ToNPC() then
		local npc = coll:ToNPC()
		if npc.Variant == mod.FF.WarpZone.Var then
			sfx:Play(mod.Sounds.WarpZoneChaosCardFall, 1, 0, false, 1)
			npc:GetData().chaosCard = true
			npc:GetSprite():PlayOverlay("ChaosOverlay", true)
			tear:Remove()
			return true
		end
	end
end, 9)

function mod:warpZoneParticleEffect(e)
	local sprite = e:GetSprite()
	local d = e:GetData()
	if d.particleTrail then
	elseif e.Parent then
		local centerpos = e.Parent.Position+Vector(0,-65)
		e.Color = Color(0.4,0.4,0.4,d.opacity/255,80 / 255,25 / 255,130 / 255)
		e.DepthOffset = 200
		local targetpos = centerpos+Vector(math.max(0,70-(e.FrameCount/5)),0):Rotated(d.initialRot+e.FrameCount*4)
		e.Velocity = targetpos-e.Position
		if e.FrameCount % 2 == 0 then
			local trail = Isaac.Spawn(1000,66,0,e.Position+Vector(math.random(-1,1),math.random(-1,1)), Vector.Zero,e)
			trail.DepthOffset = 200
			trail.Color = e.Color
		end
		if e.Position:Distance(centerpos) < 2 then
			e:Remove()
		elseif e.Position:Distance(centerpos) < 30 then
			d.opacity = d.opacity-1
		end
	else
		e:Remove()
	end
end

function mod:makeBrisketProjSprite(proj)
	local pSprite = proj:GetSprite()
	pSprite:ReplaceSpritesheet(0, "gfx/projectiles/brisket_tear.png")
	pSprite:LoadGraphics()
	proj:GetData().customProjSplat = "gfx/projectiles/brisket_splat.png"
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flag, source)
	local player = ent:ToPlayer()
	
	for _,warp in ipairs(Isaac.FindByType(180, 230, -1, false, true)) do
		if warp:GetData().hiding then
			if not warp:GetData().laughCooldown then
				warp:GetData().laugh = true
			end
		end
	end
end, 1)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, coll, low)
	--[[if coll:ToNPC() and coll.Type == mod.FFID.Boss then
		if npc.Variant == mod.FF.CorruptedContusion.Var and coll.Variant == mod.FF.CorruptedSuture.Var then
			if not mod:isCharm(npc) then
				return true
			end
		elseif npc.Variant == mod.FF.CorruptedSuture.Var and coll.Variant == mod.FF.CorruptedContusion.Var then
			if not mod:isCharm(npc) then
				return true
			end
		end
	end]]
	if npc.Variant == mod.FF.WarpZone.Var then
		if npc:GetData().hiding == true then
			return true
		end
	elseif npc.Variant == mod.FF.CorruptedLarry.Var then
		if coll:ToNPC() then
			if coll.Type == mod.FFID.Boss and coll.Variant == mod.FF.CorruptedLarry.Var then
				return true
			end
		end
	end
end, mod.FFID.Boss)

function mod:warpZoneRender(npc)
	local room = game:GetRoom()
	local isPaused = game:IsPaused()
	local isReflected = (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
	if not (isPaused or isReflected) then
		if npc.Variant == mod.FF.WarpZone.Var then
			local sprite = npc:GetSprite()
			if sprite:IsPlaying("Death") then
				local data = npc:GetData()
				if sprite:IsEventTriggered("Sound") then
					--npc:PlaySound(SoundEffect.SOUND_REDLIGHTNING_ZAP, 0.6, 0, false, math.random(70,110)/100)
					sfx:Play(mod.Sounds.WarpZoneHurt, 0.6, 0, false, math.random(70,110)/100)
					data.deathSoundCount = (data.deathSoundCount or 0)+1
					if data.deathSoundCount == 1 then --aaahh right, it's 60 fps
						sfx:Play(mod.Sounds.WarpZoneHurt, 0.8, 0, false, 1.1)
					elseif data.deathSoundCount == 7 then
						sfx:Play(mod.Sounds.WarpZoneGasp, 1, 0, false, 1)
					elseif data.deathSoundCount == 15 then
						sfx:Play(mod.Sounds.WarpZoneDeath, 1, 0, false, 1)
					end
				elseif sprite:IsEventTriggered("Sound2") then
					npc:PlaySound(mod.Sounds.WarpZonePhase, 1.3, 0, false, 0.8)
					sfx:SetAmbientSound(mod.Sounds.WarpZoneBackground, 0, 1)
				end
			end
		end
	end
end