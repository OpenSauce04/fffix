local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:aldermanAI(npc) --Could've just made this a subtype of Psyclopia instead of copying everything over but whateverrrrr
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
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
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(2.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			if npc.Pathfinder:HasPathToPos(target.Position, false) then
				npc.Pathfinder:FindGridPath(targetpos, 0.35, 900, true)
			else
				local findSpot = mod:antiGolemFindSpot(npc, target.Position, npc.Pathfinder, "Player")
				if findSpot ~= nil then
					if room:CheckLine(npc.Position, findSpot, 0, 1, false, false) then
						local targetvel = (findSpot - npc.Position):Resized(2.5)
						npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
					else
						npc.Pathfinder:FindGridPath(findSpot, 0.35, 900, true)
					end
				else
					npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
				end
			end
		end
		
		if not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
			if npc.StateFrame > 55 and rand:RandomInt(40) == 5 then
				data.state = "Shoot"
				sprite:PlayOverlay("Shoot")
				data.shot = nil
			elseif npc.StateFrame > 100 then
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
			local targetvel = (targetpos - npc.Position):Resized(-4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(1.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.3, 900, true)
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
			poof.Color = mod.ColorMausPurple
			--poof.SpriteScale = Vector(0.4, 0.4)
			poof:Update()
			npc:PlaySound(SoundEffect.SOUND_WEIRD_WORM_SPIT, 0.45, 0, false, 1.05)
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position-npc.Position):Resized(6), npc):ToProjectile()
			proj.Scale = 1.7
			--proj.FallingAccel = -0.08
			proj.FallingAccel = -0.02
			proj.FallingSpeed = 0
			local pSprite = proj:GetSprite()
			--[[pSprite:Load("gfx/projectiles/projectile_psyclopia.anm2", true)
			for i=0, room:GetFrameCount() % 61 do
				pSprite:Update()
			end
			proj:GetData().customProjSplat = "gfx/projectiles/projectile_psyclopia_splat.png"]]
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.SMART
			proj.HomingStrength = 0.48
			proj.Parent = npc
			mod:makeCharmProj(npc, proj)
			proj:GetData().projType = "psyclopia"
			proj:GetData().alderman = true
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
			sfx:Play(SoundEffect.SOUND_FLAME_BURST, 0.72, 0, false, math.random(85,105)/100)
			for i = 1,4 do
				local fire = Isaac.Spawn(1000, 148, 1, npc.Position+Vector(5,0):Rotated(i*90), Vector.Zero, npc):ToEffect()
				fire.Rotation = i*90
				fire.SpawnerEntity = npc
				fire.CollisionDamage = 1
				fire:Update()
			end
		end
	elseif data.state == "WarpIn" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
		if sprite:IsFinished("TeleportDown") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.warpDest = nil
		elseif sprite:IsEventTriggered("WarpIn") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			local randRot = rand:RandomInt(360)
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

function mod:aldermanHurt(npc, damage, flag, source)
	if source.Type == 1000 and source.Variant == 147 then
		return false
	end
end