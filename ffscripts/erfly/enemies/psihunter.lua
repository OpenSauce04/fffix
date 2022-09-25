local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:psiHunterDir(vel)
	if math.abs(vel.X) > math.abs(vel.Y) then
		if vel.X > 0 then
			return "Right"
		else
			return "Left"
		end
	else
		if vel.Y < 0 then
			return "Up"
		else
			return "Down"
		end
	end

end

function mod:psihunterAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		if npc.SubType == 10 then
			if not mod:isFriend(npc) then
				npc:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
		end
		d.bigSwingCooldown = 0
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
		d.bigSwingCooldown = d.bigSwingCooldown or 0
		if d.bigSwingCooldown > 0 then
			d.bigSwingCooldown = d.bigSwingCooldown - 1
		end
	end

	if npc.SubType == 10 then
		npc.Color = Color(1,1,1,1)
		--[[if not room:IsClear() then
			if npc.FrameCount % 30 == 0 then
				npc:TakeDamage(npc.MaxHitPoints / 20, 0, EntityRef(nil), 0)
			end
		end]]
	end

	if npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
		npc:ClearEntityFlags(EntityFlag.FLAG_FEAR)
		npc.Color = mod.ColorNormal
	end

	mod.scheduleForUpdate(function()
		for _, laser in pairs(Isaac.FindByType(7, 1, -1, false, false)) do
			local dontBlock
			if mod:isFriend(npc) and laser.Parent and laser.Parent.Type == EntityType.ENTITY_PLAYER then
				dontBlock = true
			end

			laser = laser:ToLaser()
			local laserVec = laser:GetEndPoint() - (laser.Position + laser.PositionOffset)
			if (laser.Position + laserVec:Normalized()):Distance(npc.Position) < laser.Position:Distance(npc.Position) then
				local beingHit
				if math.abs(math.abs(laser.Position.X) - math.abs(npc.Position.X)) < 30 and math.abs(laserVec.Y) > math.abs(laserVec.X) then
					beingHit = true
				elseif math.abs(math.abs(laser.Position.Y) - math.abs(npc.Position.Y)) < 30 and math.abs(laserVec.X) > math.abs(laserVec.Y)then
					beingHit = true
				end
				if beingHit and not npc:IsDead() and not dontBlock then
					if not laser:GetData().hittingPsiHunter then
						laser:GetData().hittingPsiHunter = laser.MaxDistance
					end
					local lengthcalc = (npc.Position - laser.Position):Length() - 40
					if laser:GetData().annoyingAndStupidPsionicKnightThing and laser.Parent then
						lengthcalc = lengthcalc + 20 + laser.Parent.Velocity:Length()
					end
					--print(lengthcalc)
					if laser:GetData().hittingPsiHunter > 0 then
						laser:SetMaxDistance(math.min(lengthcalc, laser:GetData().hittingPsiHunter))
					else
						laser:SetMaxDistance(lengthcalc)
					end
					laser:Update()

					if laser:GetData().hittingPsiHunter and (lengthcalc < laser:GetData().hittingPsiHunter or laser:GetData().hittingPsiHunter == 0) then
						if sprite:IsFinished("Shield") then
							mod:spritePlay(sprite, "Shielded")
						elseif not sprite:IsPlaying("Shielded") then
							mod:spritePlay(sprite, "Shield")
						end
						if laser.Position.X < npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end
						npc.Velocity = npc.Velocity + laserVec:Resized(1)
						d.state = "laserBlock"
						npc.StateFrame = 0

						local vec = (laserVec * -1):Rotated(-90 + math.random(180)):Resized(math.random(10,15))
						local brimDrops = Isaac.Spawn(1000, 70, 0, laser:GetEndPoint(), vec, nil):ToEffect()
						brimDrops.FallingAcceleration = 1.3
						brimDrops.FallingSpeed = -3
						brimDrops.PositionOffset = Vector(vec.X, math.abs(vec.Y) * -1)
						brimDrops:Update()
					end
				else
					if laser:GetData().hittingPsiHunter then
						laser:SetMaxDistance(laser:GetData().hittingPsiHunter)
						laser:GetData().hittingPsiHunter = nil
						laser:Update()
					end
				end
			end
		end
	end, 1, ModCallbacks.MC_POST_UPDATE)

	if not npc.Child or npc.Child and not npc.Child:Exists() then
		local club = Isaac.Spawn(1000, 7011, 1, npc.Position, nilvector, npc):ToEffect()
		club.Parent = npc
		npc.Child = club
	end

	if d.state == "laserBlock" then
		d.newhome = nil
		npc.Velocity = npc.Velocity * 0.8
		sprite:RemoveOverlay()
		if npc.StateFrame > 10 then
			if sprite:IsFinished("ShieldEnd") then
				sprite.FlipX = false
				local target = mod.FindClosestEntityPsiHunter(npc) or npc:GetPlayerTarget()
				local targetpos = target.Position
				d.chargeVec = (targetpos - npc.Position):Resized(9)
				d.state = "idle"
				npc.StateFrame = 0
				d.state2 = nil
			else
				mod:spritePlay(sprite, "ShieldEnd")
			end
		else
			if sprite:IsFinished("Shield") then
				mod:spritePlay(sprite, "Shielded")
			elseif not sprite:IsPlaying("Shielded") then
				mod:spritePlay(sprite, "Shield")
			end
		end
	elseif d.state == "idle" then
		local target = npc:GetPlayerTarget()
		if npc.StateFrame > 10 or mod:isFriend(npc) then
			target = mod.FindClosestEntityPsiHunter(npc) or npc:GetPlayerTarget()
		end
		if npc.Velocity:Length() > 0.1 then
			local dir = mod:psiHunterDir(npc.Velocity)
			mod:spriteOverlayPlay(sprite, "Head" .. dir)
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				mod:spritePlay(sprite, "WalkVert")
			else
				mod:spritePlay(sprite, "Walk"  .. dir)
			end
		else
			sprite:SetFrame("WalkVert", 0)
			mod:spriteOverlayPlay(sprite, "HeadDown")
		end

		local targetpos = mod:confusePos(npc, target.Position)
		if room:CheckLine(npc.Position,targetpos,0,1,false,false) then
			if mod:isFriend(npc) and target.Type == 1 and target.Position:Distance(npc.Position) < 100 then
				npc.Velocity = npc.Velocity * 0.9
			else
				local targetvel = (targetpos - npc.Position):Resized(5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			end
			d.newhome = nil
		else
			if path:HasPathToPos(targetpos, false) then
				path:FindGridPath(targetpos, 0.8, 0, false)
				d.newhome = nil
			else
				d.newhome = d.newhome or mod:FindRandomValidPathPosition(npc)
				if npc.Position:Distance(d.newhome) < 5 or npc.Velocity:Length() < 1 or (mod:isConfuse(npc) and npc.FrameCount % 30 == 1) then
					d.newhome = mod:FindRandomValidPathPosition(npc)
					path:FindGridPath(d.newhome, 0.8, 900, true)
				else
					path:FindGridPath(d.newhome, 0.8, 900, true)
				end
			end
		end

		if (room:CheckLine(npc.Position,targetpos,0,1,false,false) or targetpos:Distance(npc.Position) < 100) and (npc.StateFrame > 10 or (target.Type > 1 and not mod:isFriend(npc))) then
			if not (mod:isFriend(npc) and target.Type == 1) then
				d.chargeVec = (targetpos - npc.Position):Resized(9)
				npc.Velocity = d.chargeVec
				d.state = "charge"
				if targetpos:Distance(npc.Position) < 100 then
					d.state2 = "swing"
					d.swingCounter = 0
				else
					d.state2 = nil
				end
				npc.StateFrame = -1
			end
		end
		if d.bigSwingCooldown == 0 and mod.CountCloseEnemiesPsiHunter(npc) > 2 then
			d.state = "bigswing"
			mod:spritePlay(sprite, "SpinStart")
			sprite:RemoveOverlay()
			d.state2 = nil
		end
	elseif d.state == "charge" then
		d.newhome = nil
		local target = mod.FindClosestEntityPsiHunter(npc) or npc:GetPlayerTarget()
		local dir = mod:psiHunterDir(npc.Velocity)
		if npc.StateFrame < 8 then
			sprite:SetOverlayFrame("Head" .. dir .. "ChargeStart", npc.StateFrame)
		else
			mod:spriteOverlayPlay(sprite, "Head" .. dir .. "Charge")
		end
		if not d.state2 then
			npc.Velocity = mod:Lerp(npc.Velocity, d.chargeVec, 0.55)
			local targetpos = mod:confusePos(npc, target.Position)
			d.chargeVec = mod:Lerp(d.chargeVec, (targetpos - npc.Position):Resized(9), 0.02)
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				mod:spritePlay(sprite, "WalkVert")
			else
				mod:spritePlay(sprite, "Walk"  .. dir)
			end
			if npc.StateFrame > 10 then
				if (npc:CollidesWithGrid() or npc.Velocity:Length() < 7) then
					d.state = "idle"
				end
				if d.bigSwingCooldown == 0 and mod.CountCloseEnemiesPsiHunter(npc) > 2 then
					d.state = "bigswing"
					mod:spritePlay(sprite, "SpinStart")
					sprite:RemoveOverlay()
					d.state2 = nil
				end
			end
			if targetpos:Distance(npc.Position) < 100 then
				d.state2 = "swing"
				d.swingCounter = 0
			end
		elseif d.state2 == "swing" then
			npc.Velocity = npc.Velocity * 0.85
			d.swingCounter = d.swingCounter or 0
			d.swingCounter = d.swingCounter + 1
			if d.swingCounter == 3 then
				local pos = npc.Position + npc.Velocity:Resized(20)
				local hurtSomething = false
				for _,entity in ipairs(Isaac.GetRoomEntities()) do
					if entity.Position:Distance(pos) < 60 and entity.EntityCollisionClass > 0 then
						if entity.Type == 1 then
							entity:TakeDamage(1, 0, EntityRef(npc), 0)
							hurtSomething = true
						end
						if entity.Type > 9 and entity.Type < 1000 and not (entity.Type == mod.FF.Psihunter.ID and entity.Variant == mod.FF.Psihunter.Var) then
							entity:TakeDamage(16, 0, EntityRef(npc), 0)
							hurtSomething = true
						end
					end
				end
				if hurtSomething then
					npc:PlaySound(mod.Sounds.PHSwordHit, 1, 0, false, math.random(90,110)/100)
				else
					npc:PlaySound(mod.Sounds.PHSwordSwing, 1, 0, false, math.random(90,110)/100)
				end
			elseif d.swingCounter > 10 then
				d.state = "idle"
				d.state2 = nil
				npc.StateFrame = 0
			end
		else
			d.state = "idle"
			d.state2 = nil
		end
	elseif d.state == "bigswing" then
		d.newhome = nil
		npc.Velocity = npc.Velocity * 0.85
		if not d.state2 then
			if not sprite:IsPlaying("SpinStart") then
				mod:spritePlay(sprite, "SpinLoop")
			elseif sprite:IsEventTriggered("SwordSpin") or sprite:IsPlaying("SpinLoop") then
				d.state2 = "bigswing"
				npc.StateFrame = 0
			end
		elseif d.state2 == "bigswing" then
			mod:spritePlay(sprite, "SpinLoop")
			if npc.Child then
				local pb = npc.Child
				local ps = pb:GetSprite()
				local pf = ps:GetFrame()

				local pos = npc.Position + Vector(0, -35):Rotated(45 + (45 * pf))
				local hurtSomething = false
				for _,entity in ipairs(Isaac.GetRoomEntities()) do
					if entity.Position:Distance(pos) < 60 and entity.EntityCollisionClass > 0 then
						if entity.Type == 1 then
							entity:TakeDamage(1, 0, EntityRef(npc), 0)
							hurtSomething = true
						end
						if entity.Type > 9 and entity.Type < 1000 and not (entity.Type == mod.FF.Psihunter.ID and entity.Variant == mod.FF.Psihunter.Var) then
							entity:TakeDamage(16, 0, EntityRef(npc), 0)
							hurtSomething = true
						end
					end
				end
				if hurtSomething then
					npc:PlaySound(mod.Sounds.PHSwordHit, 1, 0, false, math.random(90,110)/100)
				else
					npc:PlaySound(mod.Sounds.PHSwordSwing, 1, 0, false, math.random(90,110)/100)
				end
			end
			if npc.StateFrame > 9 then
				d.state2 = "stopit"
			end
		elseif d.state2 == "stopit" then
			if sprite:IsFinished("SpinEnd") then
				d.state = "idle"
				npc.StateFrame = 0
				d.bigSwingCooldown = 30
			else
				mod:spritePlay(sprite, "SpinEnd")
			end
		else
			d.state2 = nil
		end
	end
end

function mod:psihunterHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_LASER ~= 0 and source.Type ~= 1 and source.Type ~= 3 then
        return false
    end
end

function mod:psiHunterSwordAI(e)
	local sprite = e:GetSprite()
	e.SpriteOffset = Vector(0, -8)

	if e.Parent and not mod:isStatusCorpse(e.Parent) then
		local p = e.Parent:ToNPC()
		local ed = p:GetData()
		if ed.state2 == "swing" then
			e.RenderZOffset = 0
			mod:spritePlay(sprite, "Swing")
			e.Velocity = mod:Lerp(e.Velocity,(p.Position + p.Velocity:Resized(30))-e.Position, 0.6)
			e.SpriteRotation = mod:Lerp(e.SpriteRotation, (p.Position-e.Position):Rotated(110):GetAngleDegrees(), 0.4)
		elseif ed.state2 == "bigswing" then
			e.RenderZOffset = 10000
			mod:spritePlay(sprite, "Rotate")
			e.Velocity = mod:Lerp(e.Velocity,(p.Position + Vector(0, -10))-e.Position, 0.6)
			e.SpriteRotation = mod:Lerp(e.SpriteRotation, 0, 0.4)
			--e.SpriteOffset = Vector(0, -8) + Vector(0, 10):Rotated(225 + sprite:GetFrame() * 45)
		else
			e.RenderZOffset = 0
			e.Velocity = mod:Lerp(e.Velocity,(p.Position + p.Velocity:Resized(-10))-e.Position, 0.6)
			e.SpriteRotation = (p.Position-e.Position):Rotated(270):GetAngleDegrees()
			sprite:Play("Sword")
		end
	else
		e:Remove()
	end
end
