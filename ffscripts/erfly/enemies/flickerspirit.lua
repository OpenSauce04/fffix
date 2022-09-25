local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:flickerspiritAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	mod.FlickerspiritInRoom = true

	mod:spritePlay(sprite, "Idle")
	if not mod:isLeavingStatusCorpse(npc) then
		mod:spriteOverlayPlay(sprite, "Indicator")
	else
		sprite:RemoveOverlay()
	end

	local targvel = (targetpos - npc.Position):Resized(2)
	if mod:isScare(npc) then
		targvel = (targetpos - npc.Position):Resized(-2)
	elseif mod:isConfuse(npc) then
		targvel = nilvector
	end
	npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.05)

	if targvel.X > 0 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	if mod:isFriend(npc) then
		npc:Kill()
	end
end

function mod:eternalFlickerspiritAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	mod.eternalFlickerspiritInRoom = true
	if npc.FrameCount > 1 then
		if not d.found then
			sprite:Play("Appear", true)
			local newparent = mod.FindClosestEnemyEffigy(npc.Position)
			if newparent then
				npc.Parent = newparent
				newparent:GetData().WasEternalFlickerspirited = true
				newparent:GetData().eternalFlickerspirited = true
				d.vec = (npc.Position - npc.Parent.Position):Resized(40)
				d.found = true
			else
				npc:Kill()
			end
		elseif npc.Parent and mod:isStatusCorpse(npc.Parent) then
			npc.Parent:GetData().eternalFlickerspirited = false
			npc:Kill()
		elseif npc.Parent then
			local targpos = npc.Parent.Position + d.vec
			local targvec = (targpos - npc.Position)
			local targvel = targvec:Resized(npc.Position:Distance(targpos))
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 1)

			d.vec = d.vec:Rotated(3)

			if npc.State == 10 then
				if sprite:IsFinished("FlickerOut") then
					mod:spritePlay(sprite, "FlyUnpowered")
				end
			else
				if mod.CanIComeOutYet() then
					mod:spritePlay(sprite, "FlickerOut")

					if sprite:IsEventTriggered("stopinvincibility") then
						npc.State = 10
						npc.Parent:GetData().eternalFlickerspirited = false
					end
				else
					if sprite:IsFinished("Appear") or not sprite:IsPlaying("Appear") then
						mod:spritePlay(sprite, "Fly")
					end
					npc.Parent:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
				end
			end
		else
			npc:Kill()
		end

		if mod:isFriend(npc) then
			npc:Kill()
		end

		if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
			if npc.Parent then
				npc.Parent:GetData().eternalFlickerspirited = false
			end
		end
	end
end

-- general fallback for weird damage e.g. forgotten bone, that can't be properly cancelled
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amt, flag, src, countdown)
    local data = ent:GetData()
    if data.flickerspirited or data.eternalFlickerspirited or data.isSpecturnInvuln then
        return false
    end
end)

function mod:eternalFlickerspiritHurt(npc, damage, flag, source)
	if npc:ToNPC().State ~= 10 then
        return false
    end
end

function mod:eternalFlickerspiritInit(npc)
	npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end