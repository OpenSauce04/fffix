local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:ang360(val)
	if val < 0 then
		val = val + 360
	end
	return val
end

--saggingsuckerai
function mod:saggerAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	--local ang = mod:ang360((target.Position - npc.Position):GetAngleDegrees())
	--Isaac.ConsoleOutput(ang  .. "\n")

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		npc.CollisionDamage = 0
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if target.Position.X > npc.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		local targpos = mod:confusePos(npc, target.Position + (target.Velocity * 10))
		local targvel = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(4))
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)

		if npc.StateFrame > 6 and not mod:isScareOrConfuse(npc) and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
			if npc.Position:Distance(target.Position) < 80 then
				d.state = "chargestart"
				d.follow = true
				if sprite.FlipX then
					d.dirX = -1
				else
					d.dirX = 1
				end
				if npc.Position.Y > target.Position.Y then
					d.dirY = 1
					if sprite.FlipX then
						sprite.FlipX = false
					else
						sprite.FlipX = true
					end
				else
					d.dirY = -1
				end
			end
		end

	elseif d.state == "chargestart" then
		mod:spritePlay(sprite, "Shoot")
		if d.follow then
		local targpos = target.Position + (Vector(d.dirX, d.dirY) * 80)
		local targvel = (targpos - npc.Position):Resized(8)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)
		else
			npc.Velocity = npc.Velocity * 0.7
		end
		if sprite:IsEventTriggered("shoot") then
			d.state = "charge"
			d.movevec = Vector(d.dirX * d.dirY * -1, -1):Resized(10)
			npc.Velocity = d.movevec
			npc:PlaySound(mod.Sounds.ShotgunBlast,1,0,false,math.random(7,9)/10)
			npc:Update()
		end
	elseif d.state == "charge" then
		npc.Velocity = mod:Lerp(npc.Velocity, d.movevec, 0.3)
		local params = ProjectileParams()
		local shootvec = Vector(d.dirX * d.dirY, 1):Resized(10)
		for i = 1, math.random(3) do
			npc:FireProjectiles(npc.Position, shootvec:Rotated(-20 + math.random(40)), 0, params)
		end


		if sprite:IsEventTriggered("shootend") then
			d.state = "chargeend"
			npc.StateFrame = 0
		end

	elseif d.state == "chargeend" then
		if sprite:IsFinished("Shoot") then
			mod:spritePlay(sprite, "Idle")
		end
		npc.Velocity = npc.Velocity * 0.95

		if npc.StateFrame > 10 then
			d.state = "idle"
			npc.StateFrame = 0
		end

	end
	npc.SpriteOffset = Vector(0,-20)
end