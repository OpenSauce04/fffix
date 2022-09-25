local mod = FiendFolio
local game = Game()

function mod:skullcapAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()
	
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
		data.invuln = true
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Idle" then
		if npc.StateFrame > 52 then
			data.state = "JumpUp"
			npc.StateFrame = 0
			data.bombed = nil
		else
			if data.bombed then
				mod:spritePlay(sprite, "IdleBombed")
				if data.bombed > 0 then
					data.bombed = data.bombed-1
				else
					data.bombed = nil
				end
			else
				mod:spritePlay(sprite, "Idle")
			end
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "InAir" then
		local vel = Vector.Zero
		local dist = (npc.Position - data.targetPos):Length()
		if dist < 20 or npc.StateFrame > 120 then
			vel = Vector.Zero
			data.state = "JumpDown"
			data.anim = "Land"
		elseif dist < 40 then
			vel = (data.targetPos - npc.Position):Resized(2)
		else
			vel = vel + (data.targetPos-npc.Position):Resized(dist / 65)
			if vel:Length() >= dist then
				vel = vel:Resized(dist)
			end
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity+vel, 0.3)
	elseif data.state == "Attacked" then
		if sprite:IsFinished("Hide") then
			data.state = "Idle"
			npc.StateFrame = 25
		elseif sprite:IsEventTriggered("Sound") then
			data.invuln = true
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
		else
			if npc.StateFrame < 45 then
				mod:spritePlay(sprite, "Vulnerable")
			else
				mod:spritePlay(sprite, "Hide")
			end
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "JumpDown" then
		if sprite:IsFinished("LandNoFire") then
			data.state = "Idle"
			npc.StateFrame = 25
			data.anim = nil
		elseif sprite:IsFinished("Land") then
			data.state = "Attacked"
			npc.StateFrame = 0
			data.anim = nil
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 1, 0, false, 1)
			--npc:PlaySound(SoundEffect.SOUND_FETUS_LAND,1,0,false,1.6)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.CollisionDamage = 1
			mod.scheduleForUpdate(function()
				npc.CollisionDamage = 0
			end, 1)
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
			data.invuln = nil
		elseif sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
			poof.SpriteScale = Vector(0.5,0.6)
			poof.SpriteOffset = Vector(0,-10)
			poof.DepthOffset = 30
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
			local dir = (target.Position-npc.Position):Resized(9.5)
			for i=-21,21,21 do
				npc:FireProjectiles(npc.Position, dir:Rotated(i), 0, ProjectileParams())
			end
		else
			--[[if not data.anim then
				if room:CheckLine(npc.Position, target.Position, 3, 0, false, false) and not mod:isScareOrConfuse(npc) then
					data.anim = "Land"
				else
					data.anim = "LandNoFire"
				end
			end]]
			mod:spritePlay(sprite, data.anim)
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "JumpUp" then
		if sprite:IsFinished("Jump") then
			data.state = "InAir"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 0.7)
		elseif sprite:IsEventTriggered("Jump") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			
			local checkPos = (target.Position-npc.Position)
			if mod:isScare(npc) then
				checkPos = (npc.Position-target.Position)
			elseif mod:isConfuse(npc) then
				checkPos = (mod:FindRandomFreePos(npc, 200, nil, true)-npc.Position)
			end
			if checkPos:Length() > 300 then
				checkPos = checkPos:Resized(300)
			end
			data.targetPos = room:FindFreeTilePosition(npc.Position+checkPos, 40) + (RandomVector())
		else
			mod:spritePlay(sprite, "Jump")
		end
		
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif data.state == "Waiting" then
		npc.Velocity = Vector.Zero
		data.anim = "LandNoFire"
		data.state = "JumpDown"
		sprite:Play("LandNoFire", true)
		npc.Visible = true
	end
end

function mod:skullcapHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.invuln then
		if flag == flag | DamageFlag.DAMAGE_EXPLOSION then
			data.bombed = 70
		end
		return false
	end
end