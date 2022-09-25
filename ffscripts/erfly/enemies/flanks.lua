local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:flanksAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

	if not d.init then
		if d.waited then
			d.sstate = true
			d.state = "tele"
			npc:PlaySound(mod.Sounds.MarioWarp, 0.6, 0, false, math.random(90,110)/100)
			sfx:Play(SoundEffect.SOUND_HELL_PORTAL1, 0.6, 0, false, 0.8)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif npc.SubType == 1 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 60)
		else
			d.state = "chase"
		end
		d.init = true
	end

	if d.state == "chase" then
		local facspeed = 6.5
		if target.Type == 1 then
			local playerhere = target:ToPlayer()
			if playerhere.MoveSpeed < 1 then
				facspeed = 6.5 * math.max(0.6, playerhere.MoveSpeed)
			end
		end

		local targetpos = mod:confusePos(npc, target.Position)
		if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
			d.targetvelocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(facspeed))
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.2)
		else
			 mod:CatheryPathFinding(npc, targetpos, {
                Speed = facspeed,
                Accel = 0.2,
                GiveUp = true
             })
		end

		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end

		d.headstate = d.headstate or 1
		if d.headstate == 2 then
			npc.StateFrame = npc.StateFrame + 1
		elseif room:CheckLine(npc.Position,targetpos,2,1,false,false) then
			npc.StateFrame = npc.StateFrame + 1
		end
		if npc.StateFrame > 40 and d.headstate ~= 2 then
			d.headstate = 2
			npc:PlaySound(SoundEffect.SOUND_BOSS_BUG_HISS, 0.3, 0, false, math.random(130,150)/100)
		elseif npc.StateFrame > 60 and math.random(5) == 1 then
			local newpos = target.Position + target.Velocity * 50
			newpos = room:GetGridPosition(room:GetGridIndex(newpos)) + RandomVector()*math.random(15)
			if room:GetGridCollisionAtPos(newpos) == GridCollisionClass.COLLISION_NONE and not mod.FindClosestEntity(newpos, 60, 1) then
				npc:PlaySound(mod.Sounds.MarioWarp, 0.6, 0, false, math.random(90,110)/100)
				sfx:Play(SoundEffect.SOUND_HELL_PORTAL1, 0.6, 0, false, 0.8)
				d.state = "tele"
				d.pos = newpos
			end
		end
		mod:spriteOverlayPlay(sprite, "Head0" .. d.headstate)
	elseif d.state == "tele" then
		npc.StateFrame = npc.StateFrame + 1
		npc.Velocity = nilvector
		if not d.sstate then
			if sprite:IsFinished("TeleportUp") then
				d.sstate = true
				sfx:Play(SoundEffect.SOUND_HELL_PORTAL2, 0.3, 0, false, 0.8)
				local newpos = target.Position + target.Velocity * 25
				newpos = room:GetGridPosition(room:GetGridIndex(newpos)) + RandomVector()*math.random(15)
				if room:GetGridCollisionAtPos(newpos) == GridCollisionClass.COLLISION_NONE and not mod.FindClosestEntity(newpos, 60, 1) then
					d.pos = newpos
				end
				npc.Position = d.pos
			else
				mod:spritePlay(sprite, "TeleportUp")
				sprite:RemoveOverlay()
			end
		else
			if sprite:IsFinished("TeleportDown") then
				d.sstate = false
				d.state = "owie"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "TeleportDown")
			end
		end
	elseif d.state == "owie" then
		npc.StateFrame = npc.StateFrame + 1
		npc.Velocity = npc.Velocity * 0.9
		mod:spritePlay(sprite, "Stun")
		if npc.StateFrame > 30 then
			npc.StateFrame = 0
			d.state = "chase"
			d.headstate = 1
		end
	end
end