local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero
local rng = RNG()

function mod:FigureOutAquagobPos(npc)
	local d = npc:GetData()
	local room = game:GetRoom()
	local roomCent, topLeft, bottomRight = room:GetCenterPos(), room:GetTopLeftPos(), room:GetBottomRightPos()

    local TwoSquarePit = mod:FindRandomFreePosOfFourPits(npc, 80, false)
	if #d.AvailableCorners > 0 or d.evilMode then


		local corner = math.random(4)
		if d.evilMode then
			if d.lastcorner then
				while d.lastcorner == corner do
					corner = math.random(4)
				end
			end
		else
			local rand = math.random(#d.AvailableCorners)
			corner = d.AvailableCorners[rand]
			--table.remove(d.AvailableCorners, rand) 
		end

		local newpos = roomCent
		if corner == 1 then
			newpos = topLeft
		elseif corner == 2 then
			newpos = Vector(bottomRight.X, topLeft.Y)
		elseif corner == 3 then
			newpos = bottomRight
		elseif corner == 4 then
			newpos = Vector(topLeft.X, bottomRight.Y)
		end

		d.lastcorner = corner

		newpos = newpos + Vector(40, 40):Rotated(90 * (corner - 1))

		npc.Position = newpos
	else
		npc.Position = TwoSquarePit
	end

end

function mod:aquagobRenderAI(npc)
local sprite = npc:GetSprite()
	if sprite:IsPlaying("Death") and sprite:IsEventTriggered("Die") then
		if not npc:GetData().alreadyDead then
			npc:PlaySound(mod.Sounds.SplashLarge,1.5,0,false,1)
			local params = ProjectileParams()
			local r = npc:GetDropRNG()
			for i = 30, 360, 30 do
				local rand = r:RandomFloat()
				params.FallingSpeedModifier = -50 + math.random(10);
				params.FallingAccelModifier = 2
				params.VelocityMulti = math.random(13,19) / 10
				--params.Color = Color(0.4,0.4,0.4,1,0,0,0)
				params.Variant = 4
				npc:FireProjectiles(npc.Position, Vector(0,2):Rotated(i-40+rand*80) + nilvector, 0, params)
			end
			Isaac.Spawn(1000, 132, 0, npc.Position, nilvector, npc)
			npc:GetData().alreadyDead = true
		end
	end
end

--aquagobai,
function mod:bluehorfRealAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
		d.volleyCount = 0
		d.AvailableCorners = {1,2,3,4}
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.HitPoints < npc.MaxHitPoints / 2 then
		d.evilMode = true
	end

	if not d.diving then
		local targetedpos = target.Position
		if (npc.StateFrame % 60 == 0 and not d.targetrando) then
			if math.random(3) == 1 or mod:isConfuse(npc) then
				d.targetrando = mod:FindRandomValidPathPosition(npc, 2, 30)
			else
				d.targetrando = nil
			end
		end

		if d.targetrando then
			if npc.Position:Distance(d.targetrando) < 20 then
				d.targetrando = nil
			else
				targetedpos = d.targetrando
			end
		end

		local targvel = (targetedpos - npc.Position):Resized(2)
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.07):Rotated(math.sin((npc.InitSeed + npc.FrameCount) / 16) * 8)
	end

	if d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.93
		mod:spritePlay(sprite, "Idle")
		d.volleyCount = d.volleyCount or 0
        local room = game:GetRoom()
		if r:RandomInt(20)+1 == 1 and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			if not d.evilMode and d.volleyCount > 1 and #d.AvailableCorners > 0 then
				d.state = "DivingMode"
				d.sState = nil
				d.diving = true
				d.volleyCount = 0
			else
				d.state = "ShootVolley"
				d.volleyCount = d.volleyCount + 1
				d.sState = nil
			end
		end
	elseif d.state == "ShootVolley" then
		npc.Velocity = npc.Velocity * 0.93
		if not d.sState then
			if sprite:IsFinished("ShootStart") then
				d.shootChoice = math.random(3)
				d.sState = "goin"
				d.shootcount = 0
				d.shootmax = math.random(4,6)
			else
				mod:spritePlay(sprite, "ShootStart")
			end
		elseif d.sState == "goin" then
			if sprite:IsFinished("Shoot0" .. d.shootChoice) then
				d.shootmax = d.shootmax or math.random(4,6)
				if d.shootcount >= d.shootmax then
					d.sState = "closeup"
				else
					local prevchoice = d.shootChoice
					while prevchoice == d.shootChoice do
						d.shootChoice = math.random(3)
						if math.random(2) == 1 then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end
						mod:spritePlay(sprite, "Shoot0" .. d.shootChoice)
					end
				end
			elseif sprite:IsEventTriggered("Shoot") then
				d.shootcount = d.shootcount or 0
				d.shootcount = d.shootcount + 1
				npc:PlaySound(mod.Sounds.AGShoot,2,0,false,math.random(65,75)/100)
				local params = ProjectileParams()
				params.Variant = 4
				for i = -20, 20, 20 do
					npc:FireProjectiles(npc.Position, ((target.Position - npc.Position):Resized(10)):Rotated(i), 0, params)
				end
				local effect = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
				effect.SpriteOffset = Vector(0,-12)
				effect.DepthOffset = npc.Position.Y * 1.25
				effect.Color = mod.ColorLessSolidWater
				effect:FollowParent(npc)
			else
				mod:spritePlay(sprite, "Shoot0" .. d.shootChoice)
			end
		elseif d.sState == "closeup" then
			if sprite:IsFinished("ShootEnd") or d.evilRememberAttack2 then
				if d.evilMode and sprite:IsFinished("ShootEnd") then
					d.state = "DivingMode"
					d.sState = nil
					d.diving = true
					d.evilRememberAttack2 = true
				elseif mod.GetEntityCount(mod.FF.Aquabab.ID, mod.FF.Aquabab.Var) < 2 and d.lastAttack ~= "summon" then
					d.evilRememberAttack2 = nil
					d.diving = false
					d.state = "summon"
					d.lastAttack = "summon"
				else
					d.evilRememberAttack2 = nil
					d.diving = false
					d.state = "spray"
					d.lastAttack = "spray"
					if target.Position.X > npc.Position.X then
						d.sprayDir = "Right"
					else
						d.sprayDir = "Left"
					end
					d.savedVec = target.Position - npc.Position
				end
			else
				mod:spritePlay(sprite, "ShootEnd")
				sprite.FlipX = false
			end
		end
	elseif d.state == "summon" then
		npc.Velocity = npc.Velocity * 0.93
		if sprite:IsFinished("Summon") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Spawn") then
			npc:PlaySound(mod.Sounds.AGOugh,2,0,false,math.random(65,75)/100)
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND,0.3,1,false,1)
			local bab = Isaac.Spawn(mod.FF.Aquabab.ID, mod.FF.Aquabab.Var, 0, npc.Position + Vector(0, 40), nilvector, npc)
			bab.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			bab:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			bab:GetSprite():Play("Appear", true)
			bab:Update()
			bab:GetSprite():Play("Appear", true)
		else
			mod:spritePlay(sprite, "Summon")
		end
	elseif d.state == "spray" then
		npc.Velocity = npc.Velocity * 0.93
		if sprite:IsFinished("Bubbles" .. d.sprayDir) then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.AGWheeze,2,0,false,math.random(55,60)/100)
			local vec = d.savedVec:Normalized()
			local iter = 0
			if d.evilMode then
				iter = 1
			end
			for i = 1, 1 + iter do
				mod.ShootBubble(npc, mod:RandomInt(4,5), npc.Position+vec*5, vec*(math.random(55,75)/20))
			end
			for i = 1, 2 do
				mod.ShootBubble(npc, mod:RandomInt(8,9), npc.Position+vec*5, vec*(math.random(55,75)/20))
			end
			for i = 1, 4 - iter do
				mod.ShootBubble(npc, math.random(2)-1, npc.Position+vec:Rotated(-30+i*20)*5, vec:Rotated(-15+i*10)*(math.random(55,75)/20))
			end
			local effect = Isaac.Spawn(1000, 16, 5, npc.Position, Vector.Zero, npc):ToEffect()
			effect.SpriteOffset = Vector(0,-12)
			effect.DepthOffset = npc.Position.Y * 1.25
			effect.Color = mod.ColorLessSolidWater
			effect:GetSprite().Scale = effect:GetSprite().Scale * 0.6
			effect:FollowParent(npc)
		else
			mod:spritePlay(sprite, "Bubbles" .. d.sprayDir)
		end
	elseif d.state == "DivingMode" then
		npc.Velocity = npc.Velocity * 0.3

		if sprite:IsEventTriggered("Emerge") then
			npc:PlaySound(mod.Sounds.AGJump,2,0,false,math.random(65,75)/100)
			npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,0.8)
			Isaac.Spawn(1000, 132, 0, npc.Position, nilvector, npc)
			mod:DestroyNearbyGrid(npc, 50, true)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

			local params = ProjectileParams()
			params.FallingAccelModifier = -0.1
			params.Variant = 4
			--Doing the NNW offset as a direct result of the guy with 800 enemy ideas reminding me it exists
			for i = 22.5, 382.5, 45 do
				npc:FireProjectiles(npc.Position, Vector(0,9):Rotated(i), 0, params)
			end
		elseif sprite:IsEventTriggered("Submerge") then
			npc:PlaySound(mod.Sounds.SplashLarge,1,0,false,1)
			Isaac.Spawn(1000, 132, 0, npc.Position, nilvector, npc)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		end
		if not d.sState then
			d.sState = "DiveStart"
			d.timesDone = 0
		elseif d.sState == "DiveStart" then
			if sprite:IsFinished("DiveStart") then
				d.sState = "DiveEnd"
				if d.evilMode and math.random(4 - d.timesDone) ~= 1 then
					d.sState = "DiveContinue"
					d.timesDone = d.timesDone + 1
				end

				mod:FigureOutAquagobPos(npc)
			else
				mod:spritePlay(sprite, "DiveStart")
			end
		elseif d.sState == "DiveEnd" then
			if sprite:IsFinished("DiveEnd") then
				if d.evilRememberAttack2 then
					d.state = "ShootVolley"
					d.sState = "closeup"
				else
					d.state = "idle"
					d.diving = false
					npc.StateFrame = 0
				end
			else
				mod:spritePlay(sprite, "DiveEnd")
			end
		elseif d.sState == "DiveContinue" then
			if sprite:IsFinished("DiveContinue") then
				mod:FigureOutAquagobPos(npc)
				d.sState = "DiveEnd"
				if d.evilMode and math.random(4 - d.timesDone) ~= 1 then
					sprite:Play("DiveContinue", true)
					d.sState = "DiveContinue"
					d.timesDone = d.timesDone + 1
				end
			else
				mod:spritePlay(sprite, "DiveContinue")
			end
		end
	end
end

function mod:babybluehorfAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
		npc.StateFrame = 30
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.85
		if not sprite:IsPlaying("Appear") then
			mod:spritePlay(sprite, "Shake")
			local room = game:GetRoom()
			if npc.StateFrame > 40 and r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 200 and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
				d.state = "shoot"
				d.shootChoice = 1
			end
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.85
		if sprite:IsFinished("Attack0" .. d.shootChoice) then
			if d.shootChoice == 2 then
				d.state = "idle"
				npc.StateFrame = 0
			else
				d.shootChoice = 2
			end
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.AGShoot,2,0,false,math.random(120,140)/100)
			local params = ProjectileParams()
			params.Variant = 4
			for i = -17, 17, 32 do
				npc:FireProjectiles(npc.Position, ((target.Position - npc.Position):Resized(8)):Rotated(i), 0, params)
			end
			local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
			effect.SpriteOffset = Vector(0,-8)
			effect.DepthOffset = npc.Position.Y * 1.25
			effect.Color = mod.ColorLessSolidWater
		else
			mod:spritePlay(sprite, "Attack0" .. d.shootChoice)
		end
	end
end