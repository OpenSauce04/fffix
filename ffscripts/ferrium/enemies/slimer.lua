local mod = FiendFolio
local game = Game()

function mod:slimerAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		if npc.SubType > 0 and not data.waited then
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, 80, false)
		end
	
		if npc.SubType == 0 then
			data.state = "Idle"
		elseif data.waited then
			data.state = "Waiting"
			npc.Visible = false
		end
		npc.SplatColor = mod.ColorDankBlackReal
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Idle" then
		if npc.StateFrame > 35 and not mod:isScareOrConfuse(npc) then
			data.state = "JumpUp"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Idle")
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
	elseif data.state == "Idle2" then
		if npc.StateFrame > 24 then
			data.hopping = true
		end
		
		if data.hopping then
			if sprite:IsFinished("TarHop") then
				data.state = "Idle"
				npc.StateFrame = 10
				data.hopping = nil
			elseif sprite:IsEventTriggered("Jump") then
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
				npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Land") then
			else
				mod:spritePlay(sprite, "TarHop")
			end
		else
			mod:spritePlay(sprite, "TarIdle")
		end
		
		if npc.FrameCount % 10 == 0 then
			local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep:SetTimeout(60)
			creep:Update()
		end
		
		npc.Velocity = Vector.Zero
	elseif data.state == "InAir" then
		local vel = Vector.Zero
		local dist = (npc.Position - data.targetPos):Length()
		if dist < 20  then
			data.state = "JumpDown"
			local near
			for _,creep in ipairs(Isaac.FindByType(1000, EffectVariant.CREEP_BLACK, 0, false, false)) do
				if npc.Position:Distance(creep.Position) < creep.Size*creep.SpriteScale.X then
					if creep:ToEffect().Timeout > 25 then
						near = true
					end
				end
			end
			if near then
				data.landing = true
			else
				data.landing = false
			end
			npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.5)
		elseif dist < 40 then
			vel = (data.targetPos - npc.Position):Resized(2)
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity+vel, 0.3)
		else
			vel = vel + (data.targetPos-npc.Position):Resized(dist / 65)
			if vel:Length() >= dist then
				vel = vel:Resized(dist)
			end
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity+vel, 0.3)
		end
	elseif data.state == "Hidden" then
		if npc.StateFrame > 5 then
			local pos = npc.Position
			local validPoses = {}
			
			for _,creep in ipairs(Isaac.FindByType(1000, EffectVariant.CREEP_BLACK, 0, false, false)) do
				local playerPos = true
				local enemyPos = true
				for _,player in ipairs(Isaac.FindByType(1, -1, -1, false, false)) do
					if (player.Position+player.Velocity*3):Distance(creep.Position) < 60 then
						playerPos = false
					end
				end
				for _,entity in ipairs(Isaac.FindInRadius(creep.Position, 20, EntityPartition.ENEMY)) do
					enemyPos = false
				end
				if playerPos and enemyPos and room:GetGridCollisionAtPos(creep.Position) == GridCollisionClass.COLLISION_NONE then
					table.insert(validPoses, creep.Position)
				end
			end
			
			if #validPoses > 0 then
				npc.Position = validPoses[rng:RandomInt(#validPoses)+1]
			else
				npc.Position = mod:FindRandomFreePos(npc, 0, nil, true)
				local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
				creep.SpriteScale = Vector(1.5,1.5)
				creep:Update()
				local poof = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = Color(0,0,0,1,0,0,0)
				poof.SpriteScale = Vector(0.5,0.5)
			end
			data.state = "Emerge"
			npc.Visible = true
		end
	elseif data.state == "Emerge" then
		if sprite:IsFinished("Emerge") then
			data.state = "Idle2"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Emerge") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
			local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep.SpriteScale = Vector(1.5,1.5)
			creep:Update()
			
			local poof = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc):ToEffect()
			poof.Color = Color(0,0,0,1,0,0,0)
			poof.SpriteScale = Vector(0.5,0.5)
		else
			mod:spritePlay(sprite, "Emerge")
		end
		
		if npc.FrameCount % 10 == 0 then
			local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep:SetTimeout(60)
			creep:Update()
		end
		
		npc.Velocity = Vector.Zero
	elseif data.state == "JumpDown" then
		if data.landing == true then
			if sprite:IsFinished("JumpDownTar") then
				data.state = "Hidden"
				npc.StateFrame = 0
				npc.Visible = false
				npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 0.35, 0, false, 3)
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
				creep:SetTimeout(200)
				creep:Update()
				local poof = Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = Color(0,0,0,1,0,0,0)
				poof.SpriteScale = Vector(0.5,0.5)
				
				local params = ProjectileParams()
				params.FallingSpeedModifier = -15
				params.FallingAccelModifier = 1.2
				params.Color = mod.ColorDankBlackReal
				for i=60,360,60 do
					npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(4.5):Rotated(i), 0, params)
				end
				local poof = Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = mod.ColorDankBlackReal
				poof.SpriteScale = Vector(0.6,0.6)

				mod:SetGatheredProjectiles()
				params.FallingSpeedModifier = -20
				params.FallingAccelModifier = 1.35
				params.Scale = 1.7
				local slime = true
				if mod.GetEntityCount(mod.FF.TarBubble.ID) > 6 then
					slime = false
					params.Scale = 1
				end
				for i=120,360,120 do
					npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(7):Rotated(i), 0, params)
				end
				for _, proj in pairs(mod:GetGatheredProjectiles()) do
					if slime then
						proj:GetData().projType = "dank slime"
					else
						proj:GetData().projType = "Slimer"
					end
				end
			elseif sprite:IsEventTriggered("Hide") then
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				--[[local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
				poof.SpriteScale = Vector(0.5,0.6)
				poof.SpriteOffset = Vector(0,-10)
				poof.DepthOffset = 30]]
			else
				mod:spritePlay(sprite, "JumpDownTar")
			end
		else
			if sprite:IsFinished("JumpDownGround") then
				data.state = "Idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				
				local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
				creep.SpriteScale = Vector(2.3,2.3)
				creep:SetTimeout(425)
				creep:Update()
				
				mod:SetGatheredProjectiles()
				local params = ProjectileParams()
				params.FallingSpeedModifier = -18
				params.FallingAccelModifier = 1.2
				params.Color = mod.ColorDankBlackReal
				for i=120,360,120 do
					npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(4.5):Rotated(i+60), 0, params)
				end
				for _, proj in pairs(mod:GetGatheredProjectiles()) do
					proj:GetData().projType = "Slimer"
				end
				
			else
				mod:spritePlay(sprite, "JumpDownGround")
			end
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
	elseif data.state == "JumpUp" then
		if sprite:IsFinished("JumpUp") then
			data.state = "InAir"
		elseif sprite:IsEventTriggered("Jump") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1)
			
			local checkPos = (target.Position-npc.Position)
			if checkPos:Length() > 300 then
				checkPos = checkPos:Resized(300)
			end
			data.targetPos = room:FindFreeTilePosition(npc.Position+checkPos, 40) + (RandomVector())
		else
			mod:spritePlay(sprite, "JumpUp")
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
	elseif data.state == "Waiting" then
		npc.Velocity = Vector.Zero
		data.landing = false
		data.state = "WaitingLanding"
		data.noFire = true
		sprite:Play("JumpDownGround", true)
		npc.Visible = true
	elseif data.state == "WaitingLanding" then
		if sprite:IsFinished("JumpDownGround") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			
			local creep = Isaac.Spawn(1000, 26, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep.SpriteScale = Vector(2.3,2.3)
			creep:SetTimeout(500)
			creep:Update()
		else
			mod:spritePlay(sprite, "JumpDownGround")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
	end
end

function mod.slimerProj(v, d)
	if d.projType == "Slimer" then
		if v:IsDead() then
			local creep = Isaac.Spawn(1000, 26, 0, v.Position, Vector.Zero, v):ToEffect()
			creep.SpriteScale = Vector(1.5,1.5)
			creep:SetTimeout(425)
			creep:Update()
		end
	end
end