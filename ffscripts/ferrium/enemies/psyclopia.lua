local mod = FiendFolio
local game = Game()

function mod:psyclopiaAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc.StateFrame = -20
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if data.state == "Idle" then
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			mod:spritePlay(sprite, "Idle")
		end
		mod:spriteOverlayPlay(sprite, "Head")
		
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-6)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			if npc.Pathfinder:HasPathToPos(target.Position, false) then
				npc.Pathfinder:FindGridPath(targetpos, 0.6, 900, true)
			else
				local findSpot = mod:antiGolemFindSpot(npc, target.Position, npc.Pathfinder, "Player")
				if findSpot ~= nil then
					if room:CheckLine(npc.Position, findSpot, 0, 1, false, false) then
						local targetvel = (findSpot - npc.Position):Resized(4)
						npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
					else
						npc.Pathfinder:FindGridPath(findSpot, 0.6, 900, true)
					end
				else
					npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
				end
			end
		end
		
		if not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
			if npc.StateFrame > 10 and rand:RandomInt(42) == 5 then
				data.state = "Shoot"
				sprite:PlayOverlay("Shoot")
				data.shot = nil
			elseif npc.StateFrame > 90 then
				data.state = "Shoot"
				sprite:PlayOverlay("Shoot")
				data.shot = nil
			end
		end
	elseif data.state == "Shoot" then
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			mod:spritePlay(sprite, "Idle")
		end
		
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-3)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(2)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.4, 900, true)
		end
		
		if sprite:IsOverlayFinished("Shoot") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.shot = nil
		elseif sprite:GetOverlayFrame() == 9 and not data.shot then
			data.shot = true
			local poof = Isaac.Spawn(1000, 2, 5, npc.Position, npc.Velocity, npc):ToEffect()
			poof.SpriteOffset = Vector(0, -14)
			poof.DepthOffset = 14
			poof.Color = mod.ColorTelePurple
			--poof.SpriteScale = Vector(0.4, 0.4)
			poof:Update()
			npc:PlaySound(SoundEffect.SOUND_WEIRD_WORM_SPIT, 0.55, 0, false, 1.2)
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position-npc.Position):Resized(8), npc):ToProjectile()
			local dist = target.Position:Distance(npc.Position)
			if dist < 120 then 
				dist = (120-dist)/240
			else
				dist = 0
			end
			
			proj.Scale = 1.7
			--proj.FallingAccel = -0.08
			proj.FallingAccel = 0+dist
			proj.FallingSpeed = 0
			local pSprite = proj:GetSprite()
      pSprite:Load("gfx/projectiles/projectile_psyclopia.anm2", true)
      for i=0, room:GetFrameCount() % 61 do
        pSprite:Update()
      end
      proj:GetData().customProjSplat = "gfx/projectiles/projectile_psyclopia_splat.png"
			--proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.SMART
			--proj.HomingStrength = 0.35
			proj.Parent = npc
			mod:makeCharmProj(npc, proj)
			proj:GetData().projType = "psyclopia"
			proj:GetData().target = target
			--proj:GetData().psyclopia = true
			proj:Update()
		end
	elseif data.state == "WarpOut" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("TeleportUp") then
			npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL2, 0.8, 0, false, 1.25)
			npc.Position = data.warpDest
			sprite:Play("TeleportDown")
			data.state = "WarpIn"
		end
	elseif data.state == "WarpIn" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
		if sprite:IsFinished("TeleportDown") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.warpDest = nil
		elseif sprite:IsEventTriggered("WarpIn") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
	end
	
	if data.warpTime ~= nil then
		if room:GetGridCollisionAtPos(data.warpTime) == GridCollisionClass.COLLISION_NONE then
			data.state = "WarpOut"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			sprite:Play("TeleportUp")
			sprite:RemoveOverlay()
			npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1, 0.8, 0, false, 1.25)
			data.warpDest = data.warpTime
			data.warpTime = nil
			data.warpVel = nil
		elseif room:GetGridCollisionAtPos(data.warpTime) ~= GridCollisionClass.COLLISION_PIT then
			--[[local gridPos = room:GetGridPosition(room:GetGridIndex(data.warpTime))
			local newTarg = (data.warpTime-gridPos):Resized(50)+gridPos
			if room:GetGridCollisionAtPos(newTarg) == GridCollisionClass.COLLISION_NONE then
				data.state = "WarpOut"
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				sprite:Play("TeleportUp")
				sprite:RemoveOverlay()
				npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1, 0.8, 0, false, 1.25)
				data.warpDest = newTarg
				data.warpTime = nil
			else
				data.warpTime = nil
			end]]
			if room:GetGridCollisionAtPos(data.warpTime-data.warpVel:Resized(40)) == GridCollisionClass.COLLISION_NONE then
				data.state = "WarpOut"
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				sprite:Play("TeleportUp")
				sprite:RemoveOverlay()
				npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL1, 0.8, 0, false, 1.25)
				data.warpDest = data.warpTime-data.warpVel:Resized(25)
				data.warpTime = nil
				data.warpVel = nil
			else
				data.warpTime = nil
				data.warpVel = nil
			end
		else
			data.warpTime = nil
			data.warpVel = nil
		end
	end
	
	if npc:IsDead() then
		for i=0,3 do
			local gibs = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(math.random(10,120)/30), npc):ToEffect()
			local gSprite = gibs:GetSprite()
			gibs:Update()
			gSprite:SetFrame("rubble_alt", math.random(4))
			gSprite:ReplaceSpritesheet(0, "gfx/grid/rocks_chest.png")
			gSprite.Rotation = math.random(360)
			gSprite:LoadGraphics()
			gibs:Update()
		end
		npc:PlaySound(SoundEffect.SOUND_ANGEL_WING, 0.7, 0, false, 0.9)
	end
end

function mod.psyclopiaProj(v, d)
	if d.projType == "psyclopia" or d.psyclopia then
		--v:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 999, 1, false, false)
		if d.alderman then
			v.Color = mod.ColorMausPurple
			if v.FrameCount % 3 == 0 then
				local trail = Isaac.Spawn(1000, 111, 0, v.Position-v.Velocity, RandomVector()*2, v):ToEffect()
				trail.Color = mod.ColorMausPurple
				local scaler = math.random(50,70)/100
				trail.SpriteScale = Vector(scaler, scaler)   
				trail.SpriteOffset = Vector(0, v.Height)
				trail.DepthOffset = -15
				trail:Update()
			end
		end
		--[[if d.target:Exists() then
			local tVel = (d.target.Position-v.Position)
			local difference = mod:GetAngleDifference(v.Velocity, tVel)
			if difference < 60 then
				v.Velocity = v.Velocity:Rotated(-4)
			elseif difference > 300 then
				v.Velocity = v.Velocity:Rotated(4)
			end
				
		end]]
		
		--[[if v.Parent and v.Parent:Exists() and not mod:isStatusCorpse(v.Parent) then
			if v:IsDead() then
				v.Parent:GetData().warpTime = v.Position
				v.Parent:GetData().warpVel = v.Velocity
			end
		end]]
	end
end

function mod.psyclopiaProjRemove(v, d)
	if d.projType == "psyclopia" or d.psyclopia then
		if v.Parent and v.Parent:Exists()then
			v.Parent:GetData().warpTime = v.Position
			v.Parent:GetData().warpVel = v.Velocity
		end
	end
end