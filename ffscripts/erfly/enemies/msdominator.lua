local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:msDominatorAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		d.children = {}
		if d.waited then
			d.state = "teleportin"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif npc.SubType == 1 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 80)
		else
			d.state = "idle"
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.Velocity = nilvector

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if not mod:isScareOrConfuse(npc) then
			local foundDominateds = {}
			if #d.children <= 0 then
				for _,dominated in ipairs(Isaac.FindByType(mod.FF.Dominated.ID, mod.FF.Dominated.Var, 0, false, false)) do
					if (not dominated.Parent) or dominated:GetData().released then
						table.insert(foundDominateds, dominated)
					end
				end
			end
			if #foundDominateds > 0 then
				d.state = "recall"
				npc.StateFrame = 0
			elseif npc.StateFrame > 10 and #d.children < 1 and math.random(15) == 1 and mod.GetEntityCount(mod.FF.Dominated.ID, mod.FF.Dominated.Var) < 5 and not (mod:isFriend(npc) and game:GetRoom():IsClear()) then
				d.state = "spawn"
			elseif npc.StateFrame > 15 and mod.GetEntityCount(251, 0, 0) < 3 and math.random(15) == 1 and #d.children > 0 then
				if mod.GetEntityCount(mod.FF.ChainBall.ID, mod.FF.ChainBall.Var) < 1 and (not mod:isFriend(npc)) then
					d.state = "playball"
				else
					d.state = "unleash"
				end
			end
		end

	elseif d.state == "recall" then
		if npc.StateFrame > 30 then
			if sprite:IsFinished("Recall") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				d.children = {}
				local potentialChildren = {}
				for _,dominated in ipairs(Isaac.FindByType(mod.FF.Dominated.ID, mod.FF.Dominated.Var, 0, false, false)) do
					if (not dominated.Parent) or dominated:GetData().released then
						table.insert(potentialChildren, dominated)
					end
				end
				for i = 1, math.min(#potentialChildren, 3) do
					local rand = math.random(#potentialChildren)
					local dominated = potentialChildren[rand]
					table.insert(d.children, potentialChildren[rand])
					
					dominated:GetData().returning = true
					dominated:GetData().released = nil
					dominated:GetData().chainspawned = nil
					dominated.Parent = npc

					table.remove(potentialChildren, rand)
				end
				if #d.children > 0 then
					npc:PlaySound(SoundEffect.SOUND_SATAN_HURT, 0.5, 0, false, math.random(170,220)/100)
				end
			else
				mod:spritePlay(sprite, "Recall")
			end
		else
			mod:spritePlay(sprite, "Idle")
			local foundDominateds = {}
			if #d.children <= 0 then
				for _,dominated in ipairs(Isaac.FindByType(mod.FF.Dominated.ID, mod.FF.Dominated.Var, 0, false, false)) do
					if (not dominated.Parent) or dominated:GetData().released then
						table.insert(foundDominateds, dominated)
					end
				end
			end
			if #foundDominateds <= 0 then
				d.state = "idle"
			end
		end
	elseif d.state == "spawn" then
		if sprite:IsFinished("Spawn") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Spawn") then
				npc:PlaySound(SoundEffect.SOUND_SATAN_BLAST, 1, 0, false, math.random(12,15)/10)
				npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND,1,0,false,1)
				for i = 1, math.random(1,2) do
				--local begottenpal = Isaac.Spawn(251, 0, 960, npc.Position + RandomVector()*75, nilvector, npc):ToNPC()
				local begottenpal = Isaac.Spawn(mod.FF.Dominated.ID, mod.FF.Dominated.Var, 0, npc.Position + RandomVector()*75, nilvector, npc):ToNPC()
				begottenpal.Parent = npc
				begottenpal.State = 10
				begottenpal:GetData().dominated = true
				--begottenpal.HitPoints = begottenpal.MaxHitPoints * 0.6
				begottenpal:Update()

				table.insert(d.children, begottenpal)

				local smoke = Isaac.Spawn(1000,15,0, begottenpal.Position, nilvector, npc):ToEffect()
				smoke:Update()
			end
		else
			mod:spritePlay(sprite, "Spawn")
		end

	elseif d.state == "unleash" then
		if sprite:IsFinished("Unleash") then
			d.state = "teleportaway"
		elseif sprite:IsEventTriggered("Spawn") then
			npc:PlaySound(SoundEffect.SOUND_SATAN_SPIT, 1, 0, false, math.random(12,15)/10)
			npc:PlaySound(mod.Sounds.ChainSnap,1,0,false,0.7)
			npc:FireProjectiles(npc.Position, Vector(8,6), 9, ProjectileParams())
			for _, entity in pairs(d.children) do
				if entity and not (entity:IsDead() or mod:isStatusCorpse(entity)) then
					entity:GetData().released = true
					--npc:FireProjectiles(entity.Position, Vector(8,6), 9, ProjectileParams())
				end
			end
			d.children = {}
		else
			mod:spritePlay(sprite, "Unleash")
		end

	elseif d.state == "teleportaway" then
		if sprite:IsFinished("TeleportOut") then
			d.state = "teleportin"
			npc.Position = mod:FindRandomValidPathPosition(npc, 2, 60)
		else
			mod:spritePlay(sprite, "TeleportOut")
		end
	elseif d.state == "teleportin" then
		if sprite:IsFinished("TeleportIn") then
			d.state = "idle"
			npc.StateFrame = -20
		else
			mod:spritePlay(sprite, "TeleportIn")
		end
	elseif d.state == "playball" then
		if sprite:IsFinished("ThrowChain") then
			d.state = "unleash"
		elseif sprite:IsEventTriggered("LaughingSound") then
			npc:PlaySound(SoundEffect.SOUND_SATAN_STOMP, 1, 0, false, math.random(12,15)/10)
		elseif sprite:IsEventTriggered("Shoot") then
			if target.Position.X > npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			local targcoord = mod:intercept(npc, target, 15)
			local shootvec = targcoord:Resized(15)
			local chainchomp = Isaac.Spawn(mod.FF.ChainBall.ID, mod.FF.ChainBall.Var, 0, npc.Position, shootvec, npc):ToNPC()
			chainchomp:GetData().vec = shootvec
			chainchomp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			chainchomp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			chainchomp.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			chainchomp:GetSprite().FlipX = sprite.FlipX
			chainchomp:Update()

		elseif sprite:IsEventTriggered("Flip") then
			if target.Position.X > npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		else
			mod:spritePlay(sprite, "ThrowChain")
		end
	end
end

function mod:dominatorChain(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	if (d.Source and not (d.Source:IsDead() or mod:isStatusCorpse(d.Source))) and (d.Home and not (d.Home:IsDead() or mod:isStatusCorpse(d.Home))) then
		mod:spritePlay(sprite, "Chain")
		if d.Source:GetData().released then
			npc:Remove()
		end
		local dist = d.Source.Position:Distance(d.Home.Position)
		local vecfun = d.Home.Position - d.Source.Position
		local targpos
		if npc.SubType == 1 then
			targpos = d.Source.Position + vecfun:Resized(dist * ((d.Pos) / d.Num))
		else
			targpos = d.Source.Position + vecfun:Resized(dist * ((d.Pos + 0.7) / d.Num))
		end

		local targvel = (targpos - npc.Position):Resized(3)
		--npc.Velocity = targvel
		npc.Velocity = nilvector
		npc.Position = targpos

		if npc.SubType == 1 then
			npc.SpriteOffset = Vector(0, -5 - (5 * (d.Pos / d.Num) ))
		else
			npc.SpriteOffset = Vector(0, -10 - (22 * (d.Pos / d.Num) ))
		end
	else
		if sprite:IsFinished("BreakChain") then
			npc:Remove()
			--npv.Velocity = nilvector
		else
			mod:spritePlay(sprite, "BreakChain")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.dominatorChain, 1724)

local function getDominatorDir(vec)
	local anim = "Hori"
	local flip = false
	if math.abs(vec.X) > math.abs(vec.Y) then
		if vec.X < 0 then
			flip = true
		end
	else
		if vec.Y > 0 then
			anim = "Down"
		else
			anim = "Up"
		end
	end
	return anim, flip
end

function mod:dominatorBegottenAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local room = game:GetRoom()
	if not d.init then
		mod:spriteOverlayPlay(sprite, "Head02")
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local shouldGlow = (not npc.Parent) or d.released

	local walkHori = shouldGlow and "WalkHoriGlow" or "WalkHori"
	local walkVert = shouldGlow and "WalkVertGlow" or "WalkVert"

	if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
		local npcp = npc.Parent
		if not d.chainspawned then
			local vecfun = npcp.Position - npc.Position
			local vecdist = vecfun:Length()
			local numchains = 6
			for i = 1, numchains do
				local chain = Isaac.Spawn(1000, 1724, 0, npc.Position + vecfun:Resized(vecdist * (i / numchains+2)), nilvector, npc):ToEffect()
				local chaind = chain:GetData()
				chaind.Pos = i
				chaind.Num = numchains + 2
				chaind.Source = npc
				chaind.Home = npcp
				chain:SetColor(Color(1,1,1,1,1,1,1), 5, 10, true, false)
				chain:Update()
			end
			d.chainspawned = true
		end

		if d.returning then
			d.doingCharge = nil
			d.endingCharge = nil
			d.ChargeDir = nil
			sprite:RemoveOverlay()
			npc.State = 10
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			local pullpos = room:FindFreePickupSpawnPosition(npc.Parent.Position, 40)
			local targvec = pullpos - npc.Position
			if targvec:Length() > 30 then
				targvec = targvec / 15
			end
			if targvec.X > 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			npc.Velocity = mod:Lerp(npc.Velocity, targvec, 0.2)
			if sprite:IsFinished("ReturnStart") then
				mod:spritePlay(sprite, "ReturnLoop")
			elseif not (sprite:IsPlaying("ReturnLoop") or sprite:IsPlaying("ReturnStart")) then
				mod:spritePlay(sprite, "ReturnStart")
			end
			if npc.Position:Distance(pullpos) < 50 and room:GetGridCollisionAtPos(npc.Position) == 0 then
				d.returning = nil
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				mod:spritePlay(sprite, "Returned")
			end
		elseif d.released then
			npc.State = 8
		else
			npc.State = 10
			if npc.StateFrame > 15 then
				local target = npc:GetPlayerTarget()
				if npc.Position:Distance(npcp.Position) > 75 then
					npc.Velocity = npc.Velocity + (npcp.Position - npc.Position):Resized(5)
				end
				local targetpos = mod:confusePos(npc, target.Position)
				local targetvec = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(8))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvec, 0.1)
			else
				--mod:spriteOverlayPlay(sprite, "Awaken")
				npc.Velocity = nilvector
			end
			if not sprite:IsPlaying("Returned") then
				mod:spriteOverlayPlay(sprite, "Head02")
				if npc.Velocity:Length() > 0.1 then
					npc:AnimWalkFrame(walkHori,walkVert,0)
				else
					sprite:SetFrame(walkVert, 0)
				end
			end
		end
	else
		if d.returning then
			if room:GetGridCollisionAtPos(npc.Position) ~= 0 then
				npc:Kill()
			else
				d.returning = nil
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end
		end
		npc.State = 8
	end

	if npc.State == 8 then
		local target = npc:GetPlayerTarget()
		local targetpos = mod:confusePos(npc, target.Position)
		if d.endingCharge then
			npc.Velocity = npc.Velocity * 0.7
			if sprite:IsFinished("ChargeEnd") then
				d.doingCharge = nil
				d.endingCharge = nil
				npc.StateFrame = 0
				d.ChargeDir = nil
				mod:spriteOverlayPlay(sprite, "Head01")
				sprite:SetFrame(walkVert, 0)
			else
				mod:spritePlay(sprite, "ChargeEnd")
			end
		elseif d.doingCharge then
			sprite:RemoveOverlay()
			vec = d.ChargeDir or targetpos - npc.Position
			local dir
			dir, sprite.FlipX = getDominatorDir(vec)
			if npc.StateFrame <= 28 then 
				sprite:SetFrame("Charge" .. dir .. "Start", npc.StateFrame)
				if npc.StateFrame == 18 then
					npc:PlaySound(SoundEffect.SOUND_SATAN_SPIT, 0.5, 0, false, math.random(170,220)/100)
					local interVec = mod:intercept(npc, target, 20)
					if room:CheckLine(npc.Position,npc.Position + interVec,0,1,false,false) then
						d.ChargeDir = interVec
					else
						d.ChargeDir = vec
					end
				end
			else
				mod:spritePlay(sprite, "Charge" .. dir)
				if npc:CollidesWithGrid() then
					--npc:PlaySound(SoundEffect.SOUND_SATAN_APPEAR, 0.5, 0, false, math.random(170,220)/100)
					npc:PlaySound(mod.Sounds.FunnyBonk, 0.1, 0, false, 1.3)
					d.endingCharge = true
					npc.StateFrame = 0
					d.ChargeDir = nil
				end
			end
			if d.ChargeDir then
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(18), 0.2)
			else
				npc.Velocity = npc.Velocity * 0.7
			end
		else
			if sprite:IsOverlayFinished("Awaken") then
				mod:spriteOverlayPlay(sprite, "Head01")
			elseif not (sprite:IsOverlayPlaying("Head01") or sprite:IsOverlayPlaying("Awaken")) then
				mod:spriteOverlayPlay(sprite, "Awaken")
			end
			if npc.Velocity:Length() > 0.1 then
				npc:AnimWalkFrame(walkHori,walkVert,0)
			else
				sprite:SetFrame(walkVert, 0)
			end
			local path = npc.Pathfinder

			local facspeed = 8
			if target.Type == 1 then
				local playerhere = target:ToPlayer()
				if playerhere.MoveSpeed < 1 then
					facspeed = 8 * math.max(0.6, playerhere.MoveSpeed)
				end
			end

			if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
				local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(facspeed))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
				if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 20 and math.random(5) == 1 and room:GetFrameCount() > 90 then
					npc:PlaySound(SoundEffect.SOUND_SATAN_CHARGE_UP, 0.5, 0, false, math.random(170,220)/100)
					d.doingCharge = true
					npc.StateFrame = -1
				end
			else
				mod:CatheryPathFinding(npc, targetpos, {
					Speed = facspeed,
					Accel = 0.1,
					GiveUp = true
				})
			end
		end
	end

	if npc:IsDead() then
		npc:PlaySound(SoundEffect.SOUND_DEVILROOM_DEAL, 1, 0, false, math.random(12,15)/10)
		--[[local params = ProjectileParams()
		params.CircleAngle = 0
		npc:FireProjectiles(npc.Position, Vector(8,6), 9, params)]]
	end
end

function mod:dominatorChainBall(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		d.state = "inAir"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.SpriteOffset = Vector(0,-12)

	if d.state == "inAir" then
		mod:spritePlay(sprite, "Idle")
		if d.vec then
			npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(15), 0.05)
		end
		if npc:CollidesWithGrid() then
			npc:Kill()
		end
	elseif d.state == "control" then
		if d.regularSprite then
			mod:spritePlay(sprite, "Death")
		else
			if sprite:IsFinished("Hit") then
				d.regularSprite = true
			elseif not sprite:IsPlaying("Death") then
				mod:spritePlay(sprite, "Hit")
			end
		end

		if npc.Parent then

			if not d.connected then
				npc:PlaySound(SoundEffect.SOUND_ANIMA_TRAP, 0.7, 0, false, 1.5)
				local vecfun = npc.Parent.Position - npc.Position
				local vecdist = vecfun:Length()
				local numchains = 6
				for i = 1, numchains do
					local chain = Isaac.Spawn(1000, 1724, 1, npc.Position + vecfun:Resized(vecdist * (i / numchains+2)), nilvector, npc):ToEffect()
					local chaind = chain:GetData()
					chaind.Pos = i
					chaind.Num = numchains + 2
					chaind.Source = npc.Parent
					chaind.Home = npc
					chain:Update()
				end
				d.connected = true
			end

			local TrailDist = 100 + (((npc.MaxHitPoints - npc.HitPoints)/npc.MaxHitPoints) * 100)
			npc.Velocity = npc.Velocity * 0.3
			local pvec = (npc.Parent.Position - npc.Position)
			if pvec:Length() > TrailDist then
				npc.Velocity = mod:Lerp(npc.Velocity, pvec:Resized(pvec:Length() - TrailDist), 0.2)
				npc.Parent.Velocity = npc.Parent.Velocity * 0.8
			end
		else
			npc:Kill()
		end
	end
end