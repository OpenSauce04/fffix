local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:drShambles(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		d.state = "idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		d.newhome = d.newhome or mod:FindRandomValidPathPosition(npc)
		local pdist = target.Position:Distance(npc.Position)
		if mod:isScare(npc) then
			npc.Velocity = (npc.Position - target.Position):Resized(math.max(1, 5 - pdist/50))
			d.newhome = nil
		elseif npc.Position:Distance(d.newhome) < 5 or npc.Velocity:Length() < 1 or (mod:isConfuse(npc) and npc.FrameCount % 30 == 1) then
			d.newhome = mod:FindRandomValidPathPosition(npc)
			path:FindGridPath(d.newhome, 0.6, 900, true)
		else
			path:FindGridPath(d.newhome, 0.6, 900, true)
		end


		if npc.Velocity:Length() > 0 then
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					d.dir = "Down"
				else
					d.dir = "Up"
				end
			else
				if npc.Velocity.X < 0 then
					d.dir = "HoriL"
				else
					d.dir = "HoriR"
				end

			end
			mod:spritePlay(sprite, "Walk" .. d.dir)
		end

		if not mod:isScareOrConfuse(npc) and npc.StateFrame % 10 == 1 then
			local distmax = 999999
			local currentTarg
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if not (entity.Type == npc.Type and entity.Variant == npc.Variant) then
					if entity:IsActiveEnemy() and entity.HitPoints < entity.MaxHitPoints and entity.InitSeed ~= npc.InitSeed and not (mod:isFriend(npc) or mod:isStatusCorpse(entity)) then
						if (not mod:isSegmented(entity)) or mod:isMainSegment(entity) then
							local dist = entity.Position:Distance(npc.Position)
							if dist < distmax then
								if (dist < 1200 and room:CheckLine(npc.Position, entity.Position,2,1100,true,true))
								or ((npc.Velocity:Normalized():Dot((entity.Position - npc.Position):Normalized()) > math.cos(0.3)) and dist < 300 and room:CheckLine(npc.Position, entity.Position,0,1,false,false))
								then
									distmax = dist
									currentTarg = entity
								end
							end
						end
					elseif entity.Type == target.Type and npc.StateFrame > 60 then
						local dist = entity.Position:Distance(npc.Position)
						if ((npc.Velocity:Normalized():Dot((entity.Position - npc.Position):Normalized()) > math.cos(0.3)) and dist < 300 and room:CheckLine(npc.Position, entity.Position,0,1,false,false)) then
							currentTarg = entity
							distmax = 1
						end
					end
				end
			end
			if currentTarg then
				if currentTarg.Type == target.Type then
					d.state = "attack"
					d.shootVec = (currentTarg.Position - npc.Position):Resized(12)
				else
					d.state = "heal"
				end
				d.targ = currentTarg
				local targVec = currentTarg.Position - npc.Position
				if math.abs(targVec.X) > math.abs(targVec.Y) then
					if targVec.X < 0 then
						d.adir = "HoriL"
					else
						d.adir = "HoriR"
					end
				else
					if targVec.Y > 0 then
						d.adir = "Down"
					else
						d.adir = "Up"
					end
				end
			end
		end
	elseif d.state == "heal" then
		npc.Velocity = npc.Velocity * 0.3
		if sprite:IsFinished("Attack" .. d.adir) then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			if d.targ then
				npc:PlaySound(mod.Sounds.DrShambleHeal,2,0,false,1)
				local boneProj = Isaac.Spawn(mod.FF.BoneCross.ID, mod.FF.BoneCross.Var, 0, npc.Position, nilvector, npc)
				boneProj:GetData().targ = d.targ
				boneProj:Update()
			end
		else
			mod:spritePlay(sprite, "Attack" .. d.adir)
		end
	elseif d.state == "attack" then
		npc.Velocity = npc.Velocity * 0.3
		if sprite:IsFinished("Attack" .. d.adir) then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
			local bombe = Isaac.Spawn(4, 0, 0, npc.Position, d.shootVec, npc):ToBomb()
			bombe.ExplosionDamage = 10
			bombe:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			local bsprite = bombe:GetSprite()
			bsprite:Load("gfx/enemies/drshambles/drsbomb.anm2",true)
			mod:spritePlay(bsprite, "Pulse")
			bombe:Update()
		else
			mod:spritePlay(sprite, "Attack" .. d.adir)
		end
	end
end

function mod:drsBone(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	if not d.init then
		if not d.targ or (d.targ and (mod:isStatusCorpse(d.targ) or not d.targ:Exists())) then
			npc:Remove()
		end
		npc.SpriteOffset = Vector(0, -15)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS)
	end

	if not d.targ then return end

	local targvec = (d.targ.Position - npc.Position):Resized(15)
	npc.Velocity = mod:Lerp(npc.Velocity, targvec, 0.3)
	mod:spritePlay(sprite, "Move")

	if npc.FrameCount % 3 == 0 then
		local sparkle = Isaac.Spawn(1000, 7003, 1, npc.Position, nilvector, npc):ToEffect()
		sparkle.RenderZOffset = -5
		sparkle.SpriteOffset = Vector(-10 + math.random(20), -30 + math.random(20))
		--sparkle.SpriteScale = Vector(0.3,0.3)
	end

	if npc.Position:Distance(d.targ.Position) < 10 then
		if mod:isSegmented(d.targ) and not mod:isReducedSyncSegment(npc) then
			local segments = mod:getSegments(d.targ)

			for _, segment in ipairs(segments) do
				segment.HitPoints = segment.MaxHitPoints
				segment:SetColor(Color(1,1,1,1,1,1,1),15,1,true,false)
			end
		else
			d.targ.HitPoints = d.targ.MaxHitPoints
			d.targ:SetColor(Color(1,1,1,1,1,1,1),15,1,true,false)
		end

		npc:Remove()
	end
end