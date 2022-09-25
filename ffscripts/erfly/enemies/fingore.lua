local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:fingoreAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		npc.SplatColor = Color(0.1,0.4,0.2,1)
		local r = npc:GetDropRNG()
		if npc.SubType == 10 then
			d.state = "tele"
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		else
			d.state = "wander"
			local finger = Isaac.Spawn(mod.FF.FingoreHand.ID, mod.FF.FingoreHand.Var, npc.SubType, npc.Position, nilvector, npc):ToNPC()
			finger.SpawnerEntity = npc
			finger.Parent = npc
			finger.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			finger:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
			npc.Child = finger
		end
		d.init = true
	end

	if d.state == "wander" then
		if npc.Velocity:Length() > 0.1 and npc.SubType ~= 1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
			if npc.SubType == 1 then
				if target.Position.X > npc.Position.X then
					sprite.FlipX  = false
				else
					sprite.FlipX = true
				end
			end
		end
		mod:spriteOverlayPlay(sprite, "Head")

		if npc.SubType == 1 then
			npc.Velocity = npc.Velocity * 0.8
		else
			local targetpos = mod:confusePos(npc, target.Position)
			if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
				local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				path:FindGridPath(targetpos, 0.5, 900, true)
			end
		end
	elseif d.state == "tele" then
		sprite:RemoveOverlay()
		if npc.SubType == 1 then
			npc.Velocity = npc.Velocity * 0.8
			if npc.Child then
				npc.Child:Remove()
			end
		end
		if sprite:IsFinished("TeleportOut") then
			mod:spritePlay(sprite, "TeleportIn")
			if npc.SubType == 1 then
				npc:Remove()
			else
				d.state = "return"
				npc.Position = mod:FindRandomValidPathPosition(npc, 2, 80)
			end
		elseif sprite:IsEventTriggered("Tele") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			sfx:Play(SoundEffect.SOUND_HELL_PORTAL1,1,0,false,1.1)
		else
			mod:spritePlay(sprite, "TeleportOut")
		end
	elseif d.state == "return" then
		if sprite:IsFinished("TeleportIn") then
			d.state = "wander"
			local finger = Isaac.Spawn(mod.FF.FingoreHand.ID, mod.FF.FingoreHand.Var, npc.SubType, npc.Position, nilvector, npc):ToNPC()
			finger.SpawnerEntity = npc
			finger.Parent = npc
			finger.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			finger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			finger:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
			finger:Update()
		elseif sprite:IsEventTriggered("Tele") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		else
			mod:spritePlay(sprite, "TeleportIn")
		end
	end

	if npc:IsDead() then
		npc:PlaySound(mod.Sounds.MadnessDeath, 1, 0, false, math.random(90,110)/100)
	end
end

function mod:fingoreHurt(npc, damage, flag, source)
    if npc.SubType == 1 then
        npc:GetData().state = "tele"
    end
	if (not (damage > npc.HitPoints)) then
		npc:ToNPC():PlaySound(mod.Sounds.SourceMeatSoft, 0.3, 0, false, math.random(90,110)/100)
	end
end

function mod:fingoreScrupulatorAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	--local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		npc.SplatColor = Color(0.1,0.4,0.2,1)
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
		local target = npc.Parent:ToNPC():GetPlayerTarget()
		local pointOff = target.Position
		local lerpness = 0.4
		d.pointDist = d.pointDist or 30
		if d.state == "idle" then
			if npc.SubType ~= 1 and ((npc.StateFrame > 20 and math.random(10) == 1) or npc.StateFrame > 35) then
				npc.StateFrame = 0
				d.state = "firing"
				d.vec = (target.Position - npc.Parent.Position)
				d.waitTime = 15
				npc:PlaySound(mod.Sounds.CleaverThrow,0.3,2,false, math.random(110,150)/100)
				d.playedSound = nil
			elseif npc.StateFrame < 5 then
				lerpness = (npc.StateFrame + 5) / 20
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			else
				if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				end
			end
		elseif d.state == "firing" then
			d.waitTime = d.waitTime or 10
			pointOff = npc.Parent.Position + d.vec
			if npc.StateFrame > d.waitTime + 12 then
				d.state = "idle"
				npc.StateFrame = 0
				d.pointDist = 30
			elseif npc.StateFrame > d.waitTime then
				d.pointDist = d.pointDist - 10 - ((npc.StateFrame - d.waitTime) / 2)
				if npc.Position:Distance(npc.Parent.Position) < 40 then
					npc.StateFrame = d.waitTime + 12
				end
			elseif npc.StateFrame < 3 then
				d.pointDist = d.pointDist - 10
			else
				d.pointDist = d.pointDist + 8 + (npc.StateFrame / 4)
			end
			d.vec = mod:Lerp(d.vec, target.Position - npc.Parent.Position, 0.05)
		end

		local vec = (pointOff - npc.Parent.Position)
		vec = vec:Resized(d.pointDist)
		local targetpos = npc.Parent.Position + vec

		npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position), lerpness)

		sprite:SetFrame("Rotate", math.floor(vec:Rotated(-45):GetAngleDegrees() / 90) % 4 * 2)

		npc.SpriteOffset = mod:SnapVector(vec:Resized(-1 + ((npc.FrameCount % 2) * 2)):Rotated(90), 90) + Vector(0, -10)
	else
		npc:Kill()
	end
end

function mod:fingoreHandColl(npc1, npc2)
    if npc1.SubType == 1 then
        return true
    else
        if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
            return true
        end
        npc2:TakeDamage(1, 0, EntityRef(npc1), 0)
        if not npc1:GetData().playedSound then
            sfx:Play(mod.Sounds.MadnessPunch, 1, 0, false, math.random(90,110)/100)
            npc1:GetData().playedSound = true
        end
        return true
    end
end