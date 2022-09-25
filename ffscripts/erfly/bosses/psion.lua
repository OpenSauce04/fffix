local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.PsionMinions = {
    --{53, 1}, 		-- Evil Twin
    {mod.FF.PsiKnight.ID, mod.FF.PsiKnight.Var},		--Psionic Knight
    --{251}, 		-- Begotten
    --{252},		-- Null
    --{259},		-- Imp
    --{283},		-- Bone Knight
    {mod.FF.Crosseyes.ID, mod.FF.Crosseyes.Var},		--Crosseye
    {mod.FF.Foreseer.ID, mod.FF.Foreseer.Var},		--Foreseer
    {mod.FF.PsionLeech.ID, mod.FF.PsionLeech.Var},		--Psionic Leech
}

function mod:psionAI(npc)
local d = npc:GetData()
local sprite = npc:GetSprite();
local target = npc:GetPlayerTarget()

	if not d.init then
		d.targetVelocity = Vector(1, 1):Resized(10)
		npc.Velocity = d.targetVelocity
		d.shielded = true
		d.npcstate = "idlemove"
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
		--Isaac.DebugString(npc.StateFrame)
	end

	if sprite:IsEventTriggered("ShieldOn") then
		d.shielded = true
	elseif sprite:IsEventTriggered("ShieldOff") then
		d.shielded = false
		npc:PlaySound(mod.Sounds.PsionBubbleBreak,1,0,false,1)
	end

	--------------------------------------------------------------------------------------

	if npc.State == 11 then
		if sprite:IsFinished("Death") then
			npc:Remove()
			sfx:Stop(mod.Sounds.PsionRedirectLoop)
		else
			mod:spritePlay(sprite, "Death")
		end
	else
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		if d.npcstate == "idlemove" then
			--[[if npc:CollidesWithGrid() == true then
				d.targetVelocity = mod.bounceOffWall(npc.Position, d.targetVelocity)
			end
			npc.Velocity = (d.targetVelocity * 0.3) + (npc.Velocity * 0.6)]]
			mod:diagonalMove(npc, 5)

			if not mod.AreThereEntitiesButNotThisOne(mod.FF.Psion.ID) then
				if npc.StateFrame > 30 then
					d.attacksdone = 0
					d.attackstate = 1
					d.npcstate = "attack" .. math.random(2)
				end
			else
				npc.StateFrame = 0
			end

			mod:spritePlay(sprite,"WalkShield")

		--------------------------------------------------------------------------------------

		elseif d.npcstate == "attack1" then --Redirecting shots
			npc.Velocity = npc.Velocity * 0.5
			--Attack Init
			if d.attackstate == 1 then
				npc.Velocity = npc.Velocity * 0.9
				if sprite:IsFinished("ShotRedirectStart") then
					d.attackstate = 2
				elseif sprite:IsEventTriggered("Shoot") then
					d.attacksdone = d.attacksdone + 1
					npc:PlaySound(mod.Sounds.PsionShoot,1.3,2,false,1)
					d.shootloop = true
					for i = 1, 4 do
						local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(-25+i*10,0):Rotated(i), npc):ToProjectile();
						projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						local projdata = projectile:GetData();
						projectile.FallingSpeed = 0
						projectile.FallingAccel = -0.1
						projectile.Color = mod.ColorPsy
						projectile.Scale = 2
						projdata.projType = "psionredirecter"
						projdata.target = target
						projdata.waitTime = -10 + 25*i
						projectile.Parent = npc
					end
					npc.StateFrame = 0
				else
					mod:spritePlay(sprite,"ShotRedirectStart")
				end

			elseif d.attackstate == 2 then
				if npc.StateFrame > 115 then
					if sprite:IsFinished("ShotRedirectEnd") then
						d.npcstate = "summon"
						sfx:Stop(mod.Sounds.PsionRedirectLoop)
						d.shootloop = false
					else
						mod:spritePlay(sprite, "ShotRedirectEnd")
					end
				else
					mod:spritePlay(sprite,"ShotRedirect")
				end
			end

		--------------------------------------------------------------------------------------

		elseif d.npcstate == "attack2" then --Laser
			npc.Velocity = npc.Velocity * 0.5
			--Attack Init
			if d.attackstate == 1 then
			npc.Velocity = npc.Velocity * 0.9
				if sprite:IsFinished("Shoot") or sprite:IsFinished("ShootShieldless") then
					d.attackstate = 2
					mod:spritePlay(sprite, "ShootLazerStart")
				elseif sprite:IsEventTriggered("Shoot") then
					d.attacksdone = d.attacksdone + 1
					npc:PlaySound(mod.Sounds.PsionShoot,1.3,0,false,1)
					for i = 90, 360, 90 do
						local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0, 10):Rotated(i), npc):ToProjectile();
						projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						local projdata = projectile:GetData();
						projectile.FallingSpeed = 0
						projectile.FallingAccel = -0.1
						projectile.Color = mod.ColorPsy
						projectile.Scale = 2
						projdata.projType = "psionlaseyes"
						projdata.target = target
						projectile.Parent = npc
					end
					npc.StateFrame = 0
				else
					if not (sprite:IsPlaying("Shoot") or sprite:IsPlaying("ShootShieldless")) then
						if d.attacksdone == 0 then
							mod:spritePlay(sprite,"Shoot")
						else
							mod:spritePlay(sprite,"ShootShieldless")
						end
					end
				end

			--Shoot Lasers
			elseif d.attackstate == 2 then
				npc.Velocity = npc.Velocity * 0.9
				if sprite:IsFinished("ShootLazerStart") or not sprite:IsPlaying("ShootLazerStart") then
					mod:spritePlay(sprite,"ShootLazer")
				end
				if npc.StateFrame > 29 then
				d.attackstate = 3
				end

			--Finish Shooting Lasers
			elseif d.attackstate == 3 then
				if sprite:IsFinished("LazerEnd") then
					if d.attacksdone > 1 then
						d.npcstate = "summon"
					else
						d.attackstate = 4
					end
					npc.StateFrame = 0
				else
					mod:spritePlay(sprite, "LazerEnd")
				end

			--Brief idle
			elseif d.attackstate == 4 then
				--[[if npc:CollidesWithGrid() == true then
					d.targetVelocity = mod.bounceOffWall(npc.Position, d.targetVelocity)
				end
				npc.Velocity = (d.targetVelocity * 0.3) + (npc.Velocity * 0.6)]]
				mod:diagonalMove(npc, 5)

				mod:spritePlay(sprite, "Walk")
				if npc.StateFrame > 20 then
					d.attackstate = 1
				end
			end

		--------------------------------------------------------------------------------------

		elseif d.npcstate == "summon" then	--Summon attack (Self explanatory)
			npc.Velocity = npc.Velocity * 0.5
			if sprite:IsFinished("Summon") then
				d.npcstate = "idlemove"
				npc.StateFrame = 0
				d.targetVelocity = d.targetVelocity:Resized(10)
			elseif sprite:GetFrame() == 11 and sprite:IsPlaying("Summon")then
				npc:PlaySound(mod.Sounds.PsionTaunt,1.3,0,false,1)
			elseif sprite:GetFrame() == 34 then
				npc:PlaySound(mod.Sounds.PsionBubble,1,0,false,1)
			elseif sprite:IsEventTriggered("Cloud") then
				npc:PlaySound(mod.Sounds.PsionSummon,1.5,0,false,1)
				local tpos = math.random(#mod.PsionMinions)
				local var = mod.PsionMinions[tpos][2] or 0
				local spawn = Isaac.Spawn(mod.PsionMinions[tpos][1], var, 0, npc.Position + Vector(0,3), Vector(0,10), npc)
				--spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				spawn:Update()
			else
				mod:spritePlay(sprite,"Summon")
			end
		end

		if d.shootloop then
			if not sfx:IsPlaying(mod.Sounds.PsionRedirectLoop) then
				sfx:Play(mod.Sounds.PsionRedirectLoop, 1, 0, true, 1)
			end
		end

		if npc:IsDead() then
			sfx:Stop(mod.Sounds.PsionRedirectLoop)
		end
	end
end

function mod:checkPsionHurt(npc, damage, flag, source, countdown)
	--Isaac.DebugString(source.Type)
	if npc:GetData().shielded or source.Type == mod.FF.Psion.ID then
		return false
	end
	if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
		if npc.HitPoints - damage <= 10 then
		npc.Velocity = nilvector
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.HitPoints = 0
		npc:ToNPC().State = 11
		npc:ToNPC():PlaySound(mod.Sounds.PsionDeath,1.3,0,false,1)
		sfx:Stop(mod.Sounds.PsionRedirectLoop)
		return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.checkPsionHurt, mod.FF.Psion.ID)

function mod.psionprojupdate(v,d)
	if d.projType == "psionredirecter" then
		if v.Parent then
			if v.Parent:IsDead() then
			d.mode = 2
			end
		end
		if not d.target then
			if v.Parent then
				d.target = v.Parent:GetPlayerTarget()
			else
				d.target = Isaac.GetPlayer(0)
			end
		end
		v.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		if not d.mode then
			if v.FrameCount > d.waitTime then
				if v.FrameCount == d.waitTime + 1 then
					v.Velocity = (d.target.Position - v.Position):Resized(16)
					sfx:Play(mod.Sounds.PsionShoot, 1, 0, false, math.random(130,160)/100)
				end
				if v.FrameCount == 20 + d.waitTime then
					v.Velocity = nilvector
					d.mode = 1
				end
			else
				v.Velocity = v.Velocity * 0.8
			end
		elseif d.mode == 1 then
			v.Velocity = nilvector
			if v.FrameCount == 25 + d.waitTime then
				v.Velocity = (d.target.Position - v.Position):Resized(16)
				sfx:Play(mod.Sounds.PsionShoot, 0.3, 0, false, math.random(130,160)/100)
				d.mode = 2
			end
		elseif d.mode == 2 then
			v.FallingSpeed = 0.5
			v.FallingAccel = 0
			d.mode = 0
		end
	elseif d.projType == "psionlaseyes" then
		if not d.target then
			if v.Parent then
				d.target = v.Parent:GetPlayerTarget()
			else
				d.target = Isaac.GetPlayer(0)
			end
		end
		if v.Parent then
			if v.Parent:IsDead() then
			d.mode = 2
			end
		end
		v.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		if not d.mode then
			if v.FrameCount == 10 then
				v.Velocity = nilvector
				d.mode = 1
				d.playerposition = d.target.Position
			end
		elseif d.mode == 1 then
			v.Velocity = nilvector
			if v.FrameCount == 20 then
				local vec1 = (d.playerposition - v.Position)
				local lazer = Isaac.Spawn(7,2,0,v.Position, nilvector, v.Parent):ToLaser()
				if v.Parent then
					lazer.SpawnerEntity = v.Parent
					lazer.Parent = v
				else
					lazer.SpawnerEntity = v
					lazer.Parent = v
				end
				lazer.PositionOffset = Vector(0, -20)
				lazer.Color = mod.ColorPsy
				lazer.Angle = vec1:GetAngleDegrees()
				lazer:SetTimeout(10)
				lazer.DepthOffset = 500
				lazer:Update()
			end
			if v.FrameCount > 28 then
				d.mode = 2
			end
		elseif d.mode == 2 then
			v.FallingSpeed = 1
			v.FallingAccel = 1
		end
	end
end