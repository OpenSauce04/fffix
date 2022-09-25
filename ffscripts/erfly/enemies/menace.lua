local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:menaceAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	npc.SpriteOffset = Vector(0,-15)

	if not d.init then
		npc.SplatColor = mod.ColorGhostly
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		d.state = "idle"
		npc.Velocity = RandomVector()*7
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if sprite:IsEventTriggered("Shoot") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
		local params = ProjectileParams()
		params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
		params.Variant = 4
		--[[for i = -30, 30, 30 do
			npc:FireProjectiles(npc.Position, npc.Velocity:Resized(12):Rotated(i), 0, params)
		end]]

		--Making it more splashy
		for i = 1, 7 do
			params.FallingSpeedModifier = -10 - math.random(20)
			params.FallingAccelModifier = 1 + (math.random() * 0.5)
			npc:FireProjectiles(npc.Position, npc.Velocity:Resized(7) + (RandomVector() * math.random() * 3.5), 0, params)
		end
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		npc.Velocity = npc.Velocity * 0.95
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end

		if npc.StateFrame % 25 == 24 then
			if mod:isScare(npc) then
				npc.Velocity = npc.Velocity + (target.Position - npc.Position):Resized(-7)
			else
				npc.Velocity = npc.Velocity + RandomVector()*7
			end
		end

		if npc.StateFrame > 30 and math.random(25) == 1 and not mod:isScareOrConfuse(npc) then
			local newtarg = mod.FindRandomEntityDeadfly()
			if newtarg then
				d.state = "possessiontime"
				d.target = newtarg
				d.chargestate = 0
				d.possesscharging = false
			else
				d.state = "playercharge"
				d.chargestate = 0
			end
		end
	elseif d.state == "possessiontime" then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if d.chargestate == 0 then
			if sprite:IsFinished("PossessStart") then
				d.chargestate = 1
			elseif sprite:IsEventTriggered("CHAAARGE") then
				d.possesscharging = true
				d.chargetarget = target.Position
			else
				mod:spritePlay(sprite, "PossessStart")
			end
		elseif d.chargestate == 1 then
			mod:spritePlay(sprite, "PossessLoop")
			if npc.Position:Distance(d.target.Position) < 25 then
				d.state = "possess"
				mod:spritePlay(sprite, "Enter")
			end
		elseif d.chargestate == 2 then
			if sprite:IsFinished("Exit") then
				d.chargestate = 1
			else
				mod:spritePlay(sprite, "Exit")
			end
		end

		if d.possesscharging then
			if d.target and not (d.target:IsDead() or mod:isStatusCorpse(d.target)) then
				local targvel = (d.target.Position - npc.Position):Resized(9)
				npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
			else
				d.state = "idle"
				npc.StateFrame = 0
			end
		end

	elseif d.state == "possess" then
		if d.target and not (d.target:IsDead() or mod:isStatusCorpse(d.target)) then
			npc.Position = d.target.Position + Vector(0, 3)
			npc.Velocity = d.target.Velocity
			if sprite:IsFinished("Enter") then
				d.state = "insideman"
				npc.StateFrame = 0
				npc.Visible = false
			elseif sprite:IsEventTriggered("Gone") then
				npc:PlaySound(mod.Sounds.FishRoll,1.5,0,false,math.random(110,130)/100)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
			end
		else
			d.state = "idle"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
			npc.StateFrame = 0
		end


	elseif d.state == "insideman" then
		npc.Visible = false
		if (d.target and (d.target:IsDead() or mod:isStatusCorpse(d.target))) or (not d.target) then
			d.state = "escape"
			mod:spritePlay(sprite, "Exit")
			npc:PlaySound(mod.Sounds.FireballLaunch,0.6,0,false,math.random(90,110)/100)
			local Flash = Isaac.Spawn(1000, 1726, 0, npc.Position, nilvector, v):ToEffect()
			npc.Velocity = RandomVector()*7
			npc.StateFrame = 0
		else
			npc.Position = d.target.Position + Vector(0, 3)
			npc.Velocity = d.target.Velocity
			if npc.StateFrame > 45 then
				local randomval = math.max(10, math.ceil(30 - (npc.StateFrame/3)))
				if math.random(randomval) == 1 then
					local newtarg = mod.FindRandomEntityDeadfly(d.target.InitSeed)
					if newtarg and math.random(2) == 1 then
						d.state = "possessiontime"
						npc:PlaySound(mod.Sounds.FireballLaunch,0.6,0,false,math.random(90,110)/100)
						d.chargestate = 2
						local Flash = Isaac.Spawn(1000, 1726, 0, npc.Position, nilvector, v):ToEffect()
						Flash:FollowParent(d.target)
						Flash:Update()
						--Blow it up if too small
						--[[if d.target.Type == 960 and d.target.Variant == 50 then
							d.target:Kill()
						end]]
						d.target = newtarg
						npc.Visible = true
					else
						d.state = "escape"
						mod:spritePlay(sprite, "Exit")
						npc:PlaySound(mod.Sounds.FireballLaunch,0.6,0,false,math.random(90,110)/100)
						local Flash = Isaac.Spawn(1000, 1726, 0, npc.Position, nilvector, v):ToEffect()
						npc.Velocity = RandomVector()*7
						npc.StateFrame = 0
					end
				end
			end
		end
	elseif d.state == "escape" then
		npc.Visible = true
		npc.Velocity = npc.Velocity * 0.95
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if sprite:IsFinished("Exit") then
			mod:spritePlay(sprite, "PossessLoop")
		end
		if npc.StateFrame > 20 then
			d.state = "idle"
			npc.StateFrame = 0
		end

	elseif d.state == "playercharge" then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if d.chargestate == 0 then
			if sprite:IsFinished("ChargeStart") then
				d.chargestate = 1
			elseif sprite:IsEventTriggered("CHAAARGE") then
				d.playercharging = true
				d.chargetarget = target.Position
				npc:PlaySound(SoundEffect.SOUND_SPEWER, 1, 0, false, math.random(130,150)/100)
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		elseif d.chargestate == 1 then
			mod:spritePlay(sprite, "ChargeLoop")
			if npc.Position:Distance(d.chargetarget) < 50 then
				d.chargestate = 2
			end
		elseif d.chargestate == 2 then
			if sprite:IsFinished("ChargeEnd") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Chomp") then
				d.playercharging = false
				npc:PlaySound(mod.Sounds.GnawfulBite, 0.6, 0, false, math.random(130,150)/100)
			else
				mod:spritePlay(sprite, "ChargeEnd")
			end
			if not d.playercharging then
				npc.Velocity = npc.Velocity * 0.99
			end
		end
	end

	if d.playercharging then
		local targvel = (d.chargetarget - npc.Position):Resized(12)
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
	end
end

function mod:MenaceFlash(e)
	local sprite = e:GetSprite()
	e.SpriteOffset = Vector(0,-15)
	if sprite:IsFinished("Poof") then
		e:Remove()
	else
		mod:spritePlay(sprite, "Poof")
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.MenaceFlash, 1726)