local mod = FiendFolio
local game = Game()

function mod:g_HostAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	local targetpos = mod:randomConfuse(npc, target.Position)
	
	if not data.init then
		data.init = true
		if npc.SubType == 0 then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
			data.state = "Idle"
		elseif npc.SubType == 1 then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
			data.state = "Attack"
			npc.SplatColor = mod.ColorGhostly
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			sprite:Play("Return")
			sprite:Play("Surprise")
		end
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if npc.SubType == 0 then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.25)
		
		if npc.Child and (npc.Child:IsDead() or mod:isLeavingStatusCorpse(npc.Child)) then
			npc:Kill()
		end
	
		if data.state == "Idle" then
			if npc.StateFrame > 50 and rng:RandomInt(20) == 0 then
				data.state = "Spawn"
				npc:PlaySound(SoundEffect.SOUND_BONE_HEART, 0.4, 0, false, math.random(150,165)/100)
			elseif npc.StateFrame > 90 then
				data.state = "Spawn"
				npc:PlaySound(SoundEffect.SOUND_BONE_HEART, 0.4, 0, false, math.random(150,165)/100)
			end
			
			mod:spritePlay(sprite, "Idle")
		elseif data.state == "Idle2" then
			mod:spritePlay(sprite, "Idle2")
		elseif data.state == "Spawn" then
			if sprite:IsFinished("Fade") then
				local pos = mod:FindRandomVisiblePosition(target, target.Position, 3, 80, 180)+Vector(mod:getRoll(-20,20,rng), mod:getRoll(-20,20,rng))
				for _,ghosts in ipairs(Isaac.FindByType(npc.Type, npc.Variant, 1, false, false)) do
					if ghosts.Position:Distance(pos) < 30 then
						pos = mod:FindRandomVisiblePosition(target, target.Position, 3, 80, 180)+Vector(mod:getRoll(-20,20,rng), mod:getRoll(-20,20,rng))
					end
				end
				local ghosty = Isaac.Spawn(npc.Type, npc.Variant, 1, pos, Vector.Zero, npc):ToNPC()
				ghosty.Parent = npc
				npc.Child = ghosty
				ghosty:Update()
				data.state = "Idle2"
			else
				mod:spritePlay(sprite, "Fade")
			end
		elseif data.state == "Return" then
			if sprite:IsFinished("Return") then
				data.state = "Idle"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "Return")
			end
		end
	elseif npc.SubType == 1 then
		if not npc.Parent then
			npc:Kill()
		elseif data.state == "Attack" then
			if sprite:IsFinished("Surprise") then
				data.state = "Idle"
			elseif sprite:IsEventTriggered("Emerge") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			elseif sprite:IsEventTriggered("Hide") then
				npc:PlaySound(SoundEffect.SOUND_SKIN_PULL, 0.6, 0, false, 1.3)
			elseif sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
				local dir = (target.Position-npc.Position)
				local params = ProjectileParams()
				params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
				params.Variant = 4
				params.FallingSpeedModifier = 0
				params.FallingAccelModifier = -0.04
				for i=-14,14,28 do
					npc:FireProjectiles(npc.Position, dir:Resized(8):Rotated(i), 0, params)
				end
				params.Scale = 1.6
				npc:FireProjectiles(npc.Position, dir:Resized(13), 0, params)
			end
			
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
		elseif data.state == "Idle" then
			if npc.Position:Distance(npc.Parent.Position) < 40 then
				data.state = "Return"
			end
			if mod:isScare(npc) then
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(-3), 0.15)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position-npc.Position):Resized(3), 0.15)
			end
			mod:spritePlay(sprite, "Idle")
		elseif data.state == "Return" then
			if sprite:IsFinished("Return") then
				npc.Parent.Child = nil
				npc.Parent:GetData().state = "Return"
				npc:Remove()
			elseif sprite:IsEventTriggered("Hide") then
				npc:PlaySound(SoundEffect.SOUND_SKIN_PULL, 0.5, 0, false, 1.5)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			else
				mod:spritePlay(sprite, "Return")
			end
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		end
	end
end

function mod:g_HostHurt(npc, damage, flag, source)
	if npc.SubType == 1 and npc.Parent and npc.Parent:GetData().eternalFlickerspirited then
		return false
	end
	if npc.SubType == 0 then
		if flag ~= flag | DamageFlag.DAMAGE_CLONES then
			return false
		end
	elseif npc.SubType == 1 then
		if npc.Parent then
			npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
		end
	end
end

function mod:g_HostColl(npc, coll, low)
	if npc.SubType == 1 then
		if coll:ToNPC() and coll.Type == npc.Type and coll.Variant == npc.Variant then
			return true
		end
	end
end
