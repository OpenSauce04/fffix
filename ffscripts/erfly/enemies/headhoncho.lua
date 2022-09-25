local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--Must admit I never expected head honcho would be an enemy name, makes the old weaver code annoying.
function mod:headHonchoAI(npc)
	local sprite = npc:GetSprite()
	local r = npc:GetDropRNG()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

	if not d.init then
		d.state = "idle"
		d.numblasts = 0
		d.init = true
		d.dir = 1
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.State == 11 then

		if d.bleeding then
				if npc.FrameCount % 4 == 0 then
				local blood = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				blood:Update()

				local bloo2 = Isaac.Spawn(1000, 2, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				bloo2.SpriteScale = Vector(1,1)
				bloo2.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
				bloo2:Update()

				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			end
		end

		if not d.fallmore then
			npc.Velocity = nilvector
			if sprite:IsFinished("FallTell") then
				d.fallmore = true
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				d.bleeding = true
			else
				mod:spritePlay(sprite, "FallTell")
			end
		else
			mod:spritePlay(sprite, "Fall")

			if npc.Velocity.X > 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end

			local targvel = (target.Position - npc.Position):Resized(2 + npc.StateFrame / 10)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.2)

			npc.SpriteScale = Vector(0,0 - (npc.StateFrame))
			if npc.StateFrame > 60 then
				target = mod:chooserandomlocationforskuzz(npc, 100, 75)
				mod:shootMaggot(npc, target, 2, 1)

				local params = ProjectileParams()
				for i = 30, 360, 30 do
					local rand = r:RandomFloat()
					params.FallingSpeedModifier = -30 + math.random(10);
					params.FallingAccelModifier = 2
					params.VelocityMulti = math.random(13,19) / 7
					--params.Color = 0.4,0.4,0.4,1,0,0,0)
					--params.Variant = 4
					npc:FireProjectiles(npc.Position, Vector(0,2):Rotated(i-40+rand*80) + nilvector, 0, params)
				end

				npc:Kill()
			end
		end

	else
		d.fallmore = false
		if d.charging then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			local speed = 16 * d.dir
			npc.Velocity = Vector(speed, 0)

			if d.dir == 1 then
				if npc.Position.X > room:GetGridWidth()*40+100 then
					local ypos = mod:congressionRandom()
					npc.Position = Vector(-100, ypos)
					d.chargecount = d.chargecount + 1
					d.opened = false
					d.closed = false
				end
				if d.chargecount > -1 then
					if npc.Position.X > room:GetGridWidth()*40-160 then
						if mod:isScareOrConfuse(npc) or not d.closed then
							d.chargestate = "chargeshootend"
							d.closed = true
						end
					end
					if npc.Position.X > 40 then
						if mod:isScareOrConfuse(npc) or d.chargecount > 2 then
							d.charging = false
							d.state = "idle"
						elseif not d.opened then
							d.chargestate = "chargeshoot"
							d.opened = true
						end
					end
				end
			else
				if npc.Position.X < -100 then
					local ypos = mod:congressionRandom()
					npc.Position = Vector(room:GetGridWidth()*40+100, ypos)
					d.chargecount = d.chargecount + 1
					d.opened = false
					d.closed = false
				end
				if d.chargecount > -1 then
					if npc.Position.X < 160 then
						if mod:isScareOrConfuse(npc) or not d.closed then
							d.chargestate = "chargeshootend"
							d.closed = true
						end
					end
					if npc.Position.X < room:GetGridWidth()*40-40 then
						if mod:isScareOrConfuse(npc) or d.chargecount > 2 then
							d.charging = false
							d.state = "idle"
						elseif not d.opened then
							d.chargestate = "chargeshoot"
							d.opened = true
						end
					end
				end
			end


		else
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end

		if d.state == "idle" then
			if mod:isScare(npc) then
				local targvel = (target.Position - npc.Position):Resized(-2)
				npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
			elseif (npc.Position:Distance(target.Position) > 120 or not room:CheckLine(npc.Position,target.Position,3,1,false,false)) and not mod:isScareOrConfuse(npc) then
				local targvel = (target.Position - npc.Position):Resized(2)
				npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
			else
				if mod:isConfuse(npc) then
					if math.random(10) == 1 then
						local targvel = RandomVector():Resized(5)
						npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
					end
				end
				npc.Velocity = npc.Velocity * 0.95
			end

			if npc.Velocity.X > 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end

			if npc.StateFrame > 5 and not mod:isScareOrConfuse(npc) then

				if math.abs(target.Position.Y - npc.Position.Y) < 50 then
					if d.numblasts > 1 or (d.numblasts == 1 and not room:CheckLine(npc.Position,target.Position,3,1,false,false)) then
						d.state = "charge"
						d.numblasts = 0
					end
				end

				if math.random(3) == 1 and room:CheckLine(npc.Position,target.Position,3,1,false,false) then
					if d.numblasts == 3 then
						d.state = "charge"
						d.numblasts = 0
					else
						d.attacking = true
						d.numblasts = d.numblasts + 1
						d.hasshot = false
					end
				end
			end

			if d.attacking then
				npc.StateFrame = 0
				if sprite:IsFinished("Shoot") then
					d.attacking = false
				elseif sprite:IsEventTriggered("Shoot") then
					if not d.hasshot then
						npc:PlaySound(SoundEffect.SOUND_SPIDER_SPIT_ROAR,1,0,false,1)
						d.vec = (target.Position - npc.Position)
						d.hasshot = true
					end

					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.ACCELERATE
					local vec = d.vec
					--for i = 1, 3 do
						npc:FireProjectiles(npc.Position + vec:Resized(3), vec:Resized(10), 0, params)
					--end
				else
					mod:spritePlay(sprite, "Shoot")
				end
			else
				mod:spritePlay(sprite, "Idle")
			end
		elseif d.state == "charge" then
			if not d.charging then
				npc.Velocity = npc.Velocity * 0.9
			end
			if sprite:IsFinished("Charge") then
				d.state = "charging"
				d.chargestate = "loop"
			elseif sprite:IsPlaying("Charge") and sprite:GetFrame() == 6 then
				npc:PlaySound(SoundEffect.SOUND_FRAIL_CHARGE,0.7,2,false,1.5)
			elseif sprite:IsEventTriggered("ChargeStart") then
				npc:PlaySound(SoundEffect.SOUND_GHOST_SHOOT,1.2,2,false,1.3)
				d.charging = true
				if sprite.FlipX then
					d.dir = -1
				else
					d.dir = 1
				end
				d.chargecount = -1
			else
				mod:spritePlay(sprite, "Charge")
			end
		elseif d.state == "charging" then
			if d.chargestate == "loop" then
				mod:spritePlay(sprite, "ChargeLoop")
			elseif d.chargestate == "chargeshoot" then
				if sprite:IsFinished("ChargeShoot") then
					d.chargestate = "chargeshootloop"
					npc.StateFrame = 0
				else
					mod:spritePlay(sprite, "ChargeShoot")
				end
			elseif d.chargestate == "chargeshootloop" then
				mod:spritePlay(sprite, "ChargeShootLoop")
				if npc.StateFrame % 4 == 0 then
					npc:PlaySound(SoundEffect.SOUND_KISS_LIPS1,1,0,false,math.random(70,100)/100)
					local params = ProjectileParams()
					params.BulletFlags = ProjectileFlags.ACCELERATE
					local vec = (target.Position - npc.Position)
					npc:FireProjectiles(npc.Position + vec:Resized(3), vec:Resized(10), 0, params)
				end
			elseif d.chargestate == "chargeshootend" then
				if sprite:IsFinished("ChargeShootEnd") then
					d.chargestate = "loop"
					npc.StateFrame = 0
				else
					mod:spritePlay(sprite, "ChargeShootEnd")
				end
			end
		end
	end
end

function mod:headHonchoHurt(npc, damage, flag, source)
    if npc:ToNPC().State == 11 then
        return false
    end
end

function mod.headHonchoDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end
	
	mod.genericCustomDeathAnim(npc, nil, nil, onCustomDeath, true, true)
end

function mod.headHonchoDeathEffect(npc)
	local target = mod:chooserandomlocationforskuzz(npc, 100, 75)
	mod:shootMaggot(npc, target, 2, 1)

	local params = ProjectileParams()
	for i = 30, 360, 30 do
		local rand = npc:GetDropRNG():RandomFloat()
		params.FallingSpeedModifier = -30 + math.random(10);
		params.FallingAccelModifier = 2
		params.VelocityMulti = math.random(13,19) / 7
		--params.Color = 0.4,0.4,0.4,1,0,0,0)
		--params.Variant = 4
		npc:FireProjectiles(npc.Position, Vector(0,2):Rotated(i-40+rand*80) + nilvector, 0, params)
	end
end