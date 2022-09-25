local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:bolaAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if target.Parent and target.Parent.InitSeed == npc.InitSeed then
		target = Isaac.GetPlayer(0)
	elseif npc.Parent and target.InitSeed == npc.Parent.InitSeed then
		target = Isaac.GetPlayer(0)
	end
	--Head
	if subt == 1 then
		if not d.init then
			d.init = true
			npc.CanShutDoors = false
			d.extraCount = 0
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			d.attackstate = 0
		else
			npc.StateFrame = npc.StateFrame + 1
			d.extraCount = d.extraCount + 1
		end
		local offset = math.min(npc.FrameCount / 2, 15)
		npc.SpriteOffset = Vector(0, 0 - offset)

		if sprite:IsEventTriggered("Swell") then
			local extra = 0
			if d.attackstate then
				extra = d.attackstate * 0.3
			end
			npc:PlaySound(mod.Sounds.BaloonShort, 0.5, 0, false, 1.5 + extra);
		end

		if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
			if npc.Parent:GetData().eternalFlickerspirited then
				npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),15,1,true,false)
			end
			if d.attackstate < 4 then
				local targvec = (target.Position - npc.Parent.Position)
				targvec = mod:reverseIfFear(npc, targvec:Resized(math.min(100, targvec:Length())))
				local targpos = npc.Parent.Position + mod:rotateIfConfuse(npc, targvec)
				local lerpness = math.min(0.3, d.extraCount / 50)
				npc.Velocity = mod:Lerp(npc.Velocity, (targpos - npc.Position):Resized(targpos:Distance(npc.Position) / 35), lerpness)

				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end

				if not d.charging and npc.StateFrame > 10 and not mod:isScareOrConfuse(npc) then
					d.charging = true
					d.attackstate = d.attackstate + 1
					if d.attackstate > 3 then
						sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 0.65, 0, false, 1.6);
						npc:PlaySound(SoundEffect.SOUND_HEARTIN, 1.5, 0, false, 1);
						for i = 1, 10 do
							local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(math.random(6,10)):Rotated(-20+math.random(40)), npc):ToProjectile()
							proj.Scale = math.random(8,10)/10
							proj.FallingSpeed = -15 - math.random(20)/10
							proj.FallingAccel = 0.9 + math.random(10)/10
						end
					end
				elseif d.charging then
					if sprite:IsFinished("SkullCharge" .. d.attackstate) then
						d.charging = false
						npc.StateFrame = 0
					else
						mod:spritePlay(sprite, "SkullCharge" .. d.attackstate)
					end
				else
					mod:spritePlay(sprite, "Skull" .. d.attackstate)
				end
			else
				if d.charging then
					npc.Velocity = npc.Velocity * 0.9
					if sprite:IsFinished("SkullShoot") then
						if target.Position:Distance(npc.Parent.Position) < 200 then
							d.attackstate = 0
							d.extraCount = 0
						end
						d.charging = false
					else
						mod:spritePlay(sprite, "SkullShoot")
					end
				else
					mod:spritePlay(sprite, "Skull0")
					local targpos = npc.Parent.Position
					npc.Velocity = mod:Lerp(npc.Velocity, (targpos - npc.Position):Resized(targpos:Distance(npc.Position) / 10), 0.3)

					if npc.Position:Distance(npc.Parent.Position) < 5 then
						npc.Parent:GetData().state = "Reconnect"
						sfx:Play(SoundEffect.SOUND_SCAMPER, 0.8, 0, false, 0.8)
						npc:Remove()
					end
				end
			end
		else
			npc:Kill()
		end
	--Neck
	elseif subt == 2 then
		if not d.init then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_REWARD)
			d.init = true
		end

		mod:spritePlay(sprite, "Cord")

		local offset = math.min(npc.FrameCount / 2, 15)

		if npc.Parent and npc.Parent:GetData().eternalFlickerspirited then
			npc:SetColor(Color(1.5,1.5,1.5,1,50 / 255,50 / 255,50 / 255),1,1,true,false)
		end

		if npc.Parent and (not mod:isStatusCorpse(npc.Parent)) and npc.Parent:GetData().state == "Reconnect" then
			npc:Remove()
		elseif npc.Child and (not mod:isStatusCorpse(npc.Child)) and npc.Parent and (not mod:isStatusCorpse(npc.Parent)) then
			local p1 = npc.Parent.Position
			local p2 = npc.Child.Position
			local vec = p1 - p2
			npc.Position = p1 - vec * d.PeckingOrder[1] / d.PeckingOrder[2]
			local var = d.PeckingOrder[1] / d.PeckingOrder[2] * (3 + offset)
			npc.SpriteOffset = Vector(0,-5-var)
		else
			npc:Kill()
		end
	--Meat
	else

		npc.Velocity = npc.Velocity * 0.4

		if not d.init then
			d.state = "idle"
			d.init = true
		else
			npc.StateFrame = npc.StateFrame + 1
		end

		if d.defenseless then
			if npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end
		else
			if not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
				npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end
		end

		local pdist = target.Position:Distance(npc.Position)

		if d.state == "idle" then
			mod:spritePlay(sprite, "Down")
			if pdist < 200 and npc.StateFrame > 10 then
				d.state = "popoff"
			end
		elseif d.state == "popoff" then
			if sprite:IsFinished("PopOff") then
				d.state = "waiting"
			elseif sprite:IsEventTriggered("PopOff") then
				npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,0.8)
				d.defenseless = true
				local head = Isaac.Spawn(mod.FF.Bola.ID, mod.FF.Bola.Var, mod.FF.BolaHead.Sub, npc.Position, nilvector, npc):ToNPC()
				head.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				head.Parent = npc
				npc.Child = head
				head.HitPoints = npc.HitPoints
				mod:spritePlay(head:GetSprite(), "Skull0")
				head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				head:Update()
				local vec = npc.Position - head.Position
				local numchains = 10
				for i = 1, numchains do
					local ball = Isaac.Spawn(mod.FF.Bola.ID, mod.FF.Bola.Var, mod.FF.BolaNeck.Sub, npc.Position + ((vec * i) / (numchains + 1)), nilvector, npc):ToNPC()
					ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					ball.GridCollisionClass = GridCollisionClass.COLLISION_NONE
					ball:GetData().PeckingOrder = {i, numchains + 1}
					ball.Parent = npc
					ball.Child = head
					ball:Update()
				end
			else
				mod:spritePlay(sprite, "PopOff")

			end
		elseif d.state == "waiting" then
			mod:spritePlay(sprite, "Meat")
			if (pdist < 200 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false)) then
				--npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(-1 - ((200 - pdist) / 100)), 0.15)
			end
		elseif d.state == "Reconnect" then
			d.defenseless = nil
			if sprite:IsFinished("BackOn") then
				d.state = "idle"
				npc.StateFrame = -50 + math.random(20)
			else
				mod:spritePlay(sprite, "BackOn")
			end

		end
	end
end

function mod:bolaColl(npc1, npc2)
    if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
        return true
    elseif npc1.Child and npc1.Child.InitSeed == npc2.InitSeed then
        return true
    end
end

function mod:bolaHurt(npc, damage, flag, source)
    local data = npc:GetData()

    if flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
        data.FFLastPoisonProc = data.FFLastPoisonProc or 0
        if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
            return false
        end
        data.FFLastPoisonProc = Isaac.GetFrameCount()

        if flag ~= flag | DamageFlag.DAMAGE_CLONES then
            if npc.SubType == 1 and npc.Parent then
                npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            elseif npc.SubType == 0 and npc.Child then
                npc.Child:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            end
        end
    elseif flag ~= flag | DamageFlag.DAMAGE_CLONES then -- Regular damage
        if npc.SubType == 1 then
            return false
        elseif npc.SubType == 0 then
            if not data.defenseless then
                return false
            elseif npc.Child then
                npc.Child:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            end
        end
    end
end