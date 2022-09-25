local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:getCardinalCloseness(homePos, targetPos, axisLock)

	local horiDiff = math.abs(homePos.X - targetPos.X)
	local vertDiff = math.abs(homePos.Y - targetPos.Y)

	if axisLock then
		if axisLock == 1 or axisLock == "Vertical" then
			return vertDiff
		elseif axisLock == 2 or axisLock == "Horizontal" then
			return horiDiff
		else
			return math.min(vertDiff, horiDiff)
		end
	else
		return math.min(vertDiff, horiDiff)
	end

	--I certainly had an idea here but I've no clue quite what it was
	--[[local rota, rotb, rotc = 90, 360, 90
	if axisLock == 1 or axisLock == "Horizontal" then
		rota, rotb, rotc = 180, 360, 180
	elseif axisLock == 2 or "Vertical" then
		rota, rotb, rotc = 90, 270, 180
	end
	for i = rota, rotb, rotc do

	end]]
end

function mod:bullAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
    local room = game:GetRoom()

	mod.bullInRoom = true

	if not d.init then
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if ((not d.state) or (d.state and d.applicable)) and npc.SubType ~= 2 and ((mod.bullData and mod.bullData.doingFire) or sprite:IsPlaying("FireAttack") or sprite:IsFinished("FireAttack")) then
		npc.Velocity = npc.Velocity * 0.8
		d.active, d.state, d.sState, d.charging, d.applicable = nil, nil, nil, nil, nil
		if npc.SubType == 1 or sprite:IsPlaying("FireAttack") or sprite:IsFinished("FireAttack") then
			if sprite:IsFinished("FireAttack") then
				sprite:Play("Idle", true)
				if mod.bullData and mod.bullData.doingFire then
					npc.SubType = 2
				else
					npc.SubType = 0
				end
				d.active = nil
			elseif sprite:IsEventTriggered("Scream") then
				npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_B, 1, 0, false, math.random(800,1200)/1000)
			elseif sprite:IsEventTriggered("Shoot") then
				sfx:Play(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, math.random(90,110)/100)
				sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END, 1, 0, false, math.random(90,110)/100)
				--Currently using hacky method due to non hacky method having borked sounds
				local hackymethod = false
				if hackymethod == true then
					--Sorry
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, nilvector, npc):ToProjectile()
					proj:AddProjectileFlags(ProjectileFlags.FIRE_WAVE)
					proj.Color = mod.ColorInvisible
					proj:Die()
					proj:Update()
					sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)

				else
					--Oh in fact I am not sorry :)
					for i = 90, 360, 90 do
						local firewave = Isaac.Spawn(1000, 148, 0, npc.Position + Vector(10, 0):Rotated(i), nilvector, npc):ToEffect()
						firewave.Rotation = i
						firewave.Color = mod.ColorGehennaFire
						firewave.SpawnerEntity = npc
						firewave:Update()
					end
				end
			else
				mod:spritePlay(sprite, "FireAttack")
			end
		elseif npc.SubType == 0 then
			if sprite:IsFinished("FireStart") then
				mod:spritePlay(sprite, "FireLoop")
			elseif (not sprite:IsPlaying("FireStart")) and (not sprite:IsPlaying("FireLoop")) then
				mod:spritePlay(sprite,"FireStart")
				if not sfx:IsPlaying(SoundEffect.SOUND_MOUTH_FULL) then
					sfx:Play(SoundEffect.SOUND_MOUTH_FULL, 1, 0, false, math.random(60,80)/100)
				end
			end
		end
	else
		if npc.SubType ~= 0 and mod.bullData and (not mod.bullData.doingFire) then
			npc.SubType = 0
		end
		if (not mod:isScareOrConfuse(npc)) and mod.bullData and (not mod.bullData.doingFire) then
			if mod:getCardinalCloseness(npc.Position, target.Position) < 30 then
				if mod.bullData.cardinalCounter then
					mod.bullData.cardinalCounter = mod.bullData.cardinalCounter + (1 / (mod.GetEntityCount(mod.FF.Bull.ID, mod.FF.Bull.Var) + 1))
					local r = npc:GetDropRNG()
					if r:RandomInt(120) == 1 then
						mod.bullData.cardinalCounter = mod.bullData.cardinalCounter + 10
					end
				end
			end
		end
		local wanderAround
		if d.active or d.state then
			if d.state and mod.bullData and mod.bullData.doingFire then
				npc.SubType = 2
			end
			if not d.state then
				if room:CheckLine(npc.Position,target.Position,0,1,false,false) then
					local targetvel = (target.Position - npc.Position):Resized(4)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
					d.walktarg = nil
				else
					if path:HasPathToPos(target.Position, false) then
						path:FindGridPath(target.Position, 0.6, 900, true)
						d.walktarg = nil
					else
						wanderAround = true
					end
				end
				if npc.Velocity:Length() > 0.1 then
					npc:AnimWalkFrame("WalkHori","WalkVert",0)
				else
					mod:spritePlay(sprite, "Idle")
				end

				if d.active == "shoot" then
					local r = npc:GetDropRNG()
					if r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 80 and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
						d.state = "shoot"
						d.keepFlip = true
						local vec = target.Position - npc.Position
						if vec.X > vec.Y then
							sprite:Play("AttackHori")
						else
							sprite:Play("AttackVert")
						end
						if mod.bullData and mod.bullData.counter then
							mod.bullData.counter = 1
						end
					end
				elseif d.active == "charge" then
					if room:CheckLine(npc.Position,target.Position,0,1,false,false) then
						if mod:getCardinalCloseness(npc.Position, target.Position, "Vertical") < 40 then
							sprite:Play("DashBegin", true)
							if target.Position.X < npc.Position.X then
								sprite.FlipX = true
							else
								sprite.FlipX = false
							end
							d.state = "charge"
							d.sState = nil
							npc.StateFrame = 0
							if mod.bullData and mod.bullData.counter then
								mod.bullData.counter = 1
							end
						end
					end
				end
			elseif d.state == "shoot" then
				npc.Velocity = npc.Velocity * 0.7
				if d.keepFlip then
					if target.Position.X > npc.Position.X then
						sprite.FlipX = false
					else
						sprite.FlipX = true
					end
				end
				if sprite:IsFinished() then
					d.state = nil
					d.active = nil
					d.applicable = nil
					mod:spritePlay(sprite, "Idle")
				elseif sprite:IsEventTriggered("Shoot") then
					npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0, 1, 0, false, math.random(70,80)/100)
					local vec = target.Position - npc.Position
					for i = -30, 30, 30 do
						local usedVec = vec:Resized(7 - math.abs(i/15)):Rotated(i - 10 + math.random(20))
						local fire = Isaac.Spawn(33, 10, 0, npc.Position + usedVec, usedVec, npc)
						fire.HitPoints = fire.HitPoints / 1.5
						fire:Update()
					end
					local smokeVec = Vector(3,3)
					if sprite.FlipX then
						smokeVec = Vector(-3, 3)
					end
					for i = -30, 30, 30 do
						local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + smokeVec:Resized(8), smokeVec:Rotated(i), npc)
						smoke.Color = Color(1,1,1,0.3,1,0.5,0)
						smoke.SpriteOffset = Vector(0, -10)
						smoke:Update()
					end
					d.keepFlip = false
				end
			elseif d.state == "charge" then
				if not d.sState then
					if sprite:IsFinished("DashBegin") then
						mod:spritePlay(sprite, "DashLoop")
					elseif sprite:IsEventTriggered("Shoot") then
						d.charging = true
						npc.StateFrame = 0
						npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, 1, 0, false, math.random(70,80)/100)
					end
				elseif d.sState == "end" then
					if sprite:IsFinished("DashEnd") then
						d.active = nil
						d.state = nil
						d.sState = nil
						d.charging = nil
						d.applicable = nil
					else
						mod:spritePlay(sprite, "DashEnd")
					end
				end

				if d.charging then
					local chargeVec = Vector(25, 0)
					if sprite.FlipX then
						chargeVec = chargeVec * -1
					end
					if room:CheckLine(npc.Position,target.Position,0,1,false,false) then
						if target.Position.Y > npc.Position.Y then
							chargeVec = chargeVec + Vector(0, 2)
						else
							chargeVec = chargeVec + Vector(0, -2)
						end
					end
					if npc.FrameCount % 5 == 1 then
						local fire = Isaac.Spawn(1000,7005, 0, npc.Position, (chargeVec * -0.05):Rotated(-70 + math.random(140)), npc):ToEffect()
						fire.Parent = npc
						fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_red.png")
						fire:GetSprite():LoadGraphics()
						local fData = fire:GetData()
						fData.flamethrower = true
						fData.scale = 0.75
						fData.timer = 25
						fData.Friction = 0.9
						fire:Update()
					end
					npc.Velocity = mod:Lerp(npc.Velocity, chargeVec, 0.1)
					if room:GetGridCollisionAtPos(npc.Position + chargeVec) ~= GridCollisionClass.COLLISION_NONE or npc.StateFrame > 30 then
						d.sState = "end"
						sprite:Play("DashEnd", true)
						d.charging = nil
						d.applicable = true
					end
				else
					npc.Velocity = npc.Velocity * 0.8
				end
			end
		else
			if mod:isScare(npc) or (room:CheckLine(npc.Position,target.Position,3,1,false,false) and target.Position:Distance(npc.Position) < 60) then
				npc.StateFrame = 0
				local targetvel = (target.Position - npc.Position):Resized(-3.5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
				d.walktarg = nil
			else
				wanderAround = true
			end

			if npc.Velocity:Length() > 0.1 then
				npc:AnimWalkFrame("WalkHori","WalkVert",0)
			else
				mod:spritePlay(sprite, "Idle")
			end
		end

		if wanderAround then
			if npc.StateFrame > 160 or not d.walktarg then
				d.walktarg = mod:FindRandomValidPathPosition(npc)
				npc.StateFrame = 0
			end
			if npc.Position:Distance(d.walktarg) > 30 then
				if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) then
					local targetvel = (d.walktarg - npc.Position):Resized(3)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
				else
					path:FindGridPath(d.walktarg, 0.5, 900, true)
				end
			else
				npc.Velocity = npc.Velocity * 0.9
				npc.StateFrame = npc.StateFrame + 2
			end
		end
	end
end

function mod:bullHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        npc:GetData().flaming = true
        return false
    end
end

--BullControl, BullDirector, bullLogic
function mod.bullMatador()
	if mod.bullInRoom then
		mod.bullData = mod.bullData or {}
		mod.bullData.counter = mod.bullData.counter or 0
		mod.bullData.counter = mod.bullData.counter + 1
		mod.bullData.cardinalCounter = mod.bullData.cardinalCounter or 0
		mod.bullData.cardinalCounter = math.max(mod.bullData.cardinalCounter - 1/((mod.GetEntityCount(mod.FF.Bull.ID, mod.FF.Bull.Var) + 1)*2), 0)
		local bullFireDebug = false
		if (bullFireDebug and (not mod.bullData.doingFire) and mod.bullData.counter > 120) or (mod.bullData.cardinalCounter and mod.bullData.cardinalCounter > 50) then
			mod.bullData.doingFire = true
			mod.bullData.counter = 1
			mod.bullData.cardinalCounter = 0
		end
		--print(mod.bullData.cardinalCounter)
		if mod.bullData.doingFire then
			if mod.bullData.counter % 30 == 0 then
				local choice
				local closestDist = 999999
				for _, bull in pairs(Isaac.FindByType(mod.FF.Bull.ID, mod.FF.Bull.Var, 0, false, false)) do
					local target = bull:ToNPC():GetPlayerTarget()
					local targdist = mod:getCardinalCloseness(bull.Position, target.Position)
					if targdist < closestDist then
						choice = bull
						closestDist = targdist
					end
				end

				if choice then
					choice.SubType = 1
				else
					for _, bull in pairs(Isaac.FindByType(mod.FF.Bull.ID, mod.FF.Bull.Var, -1, false, false)) do
						if bull.SubType == 1 or bull.SubType == 2 then
							bull.SubType = 0
						end
					end
					mod.bullData.doingFire = false
					mod.bullData.counter = 0
				end
			end
		else
			if mod.bullData.counter and mod.bullData.counter % 60 == 0 then
				local choice1, choice2
				local closestDist = 999999
				for _, bull in pairs(Isaac.FindByType(mod.FF.Bull.ID, mod.FF.Bull.Var, -1, false, false)) do
					bull:GetData().active = nil
					local target = bull:ToNPC():GetPlayerTarget()
					local targdist = bull.Position:Distance(target.Position)
					if targdist < closestDist then
						choice2 = choice1
						choice1 = bull
						closestDist = targdist
					elseif (not choice2) or (choice2 and  targdist < choice2.Position:Distance(target.Position)) then
						choice2 = bull
					end
				end
				if choice1 then
					local r = choice1:GetDropRNG()
					choice1:GetData().applicable = false
					if r:RandomInt(2) == 1 then
						choice1:GetData().active = "charge"
					else
						choice1:GetData().active = "shoot"
					end
				end
				if choice2 then
					choice1:GetData().applicable = false
					if choice1:GetData().active == "charge" then
						choice2:GetData().active = "shoot"
					else
						choice2:GetData().active = "charge"
					end
				end
			end
		end
	else
		if mod.bullData then
			mod.bullData = nil
		end
	end
end