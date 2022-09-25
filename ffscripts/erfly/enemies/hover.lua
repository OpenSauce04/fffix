local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:hoverAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

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

		local targpos = mod:confusePos(npc, target.Position + (target.Velocity * 40))
		local targvel = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(4))
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)

		if npc.StateFrame > 6 then
			if npc.Position:Distance(target.Position) < 80 and not (mod:isScareOrConfuse(npc)) then
				d.state = "chargestart"
				npc:PlaySound(mod.Sounds.BeeBuzzPrep, 1, 0, false, math.random(140,160)/100)

				d.follow = true
				if npc.Position.Y > target.Position.Y then
					d.dirY = 1
					d.dirString = 2
				else
					d.dirY = -1
					d.dirString = 1
				end
				if sprite.FlipX then
					d.dirX = -1
				else
					d.dirX = 1
				end
			end
		end

	elseif d.state == "chargestart" then
		mod:spritePlay(sprite, "ChargeStart0" .. d.dirString)
		if d.follow then
		local targpos = target.Position + (Vector(d.dirX, d.dirY) * 80)
		local targvel = (targpos - npc.Position):Resized(8)
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)
		else
		npc.Velocity = npc.Velocity * 0.7
		end
		if sprite:IsEventTriggered("charge") then
			d.state = "charge"
			npc:PlaySound(mod.Sounds.BeeBuzz, 1, 0, false, math.random(140,160)/100)
			npc.StateFrame = 0
			d.vec = Vector(d.dirX * -1, d.dirY * -1)
			npc.Velocity = d.vec:Resized(6)
		elseif sprite:IsEventTriggered("stopfollow") then
			d.follow = false
		end
	elseif d.state == "charge" then
		mod:spritePlay(sprite, "Charge0" .. d.dirString)
		npc.Velocity = mod:Lerp(npc.Velocity, d.vec:Resized(12 + math.max(5, npc.StateFrame * 0.3)), 0.2)
		if npc.StateFrame > 20 and npc.Position:Distance(target.Position) > 120 then
			d.state = "stopcharge"
			npc.StateFrame = 0
		elseif npc.StateFrame > 5 and npc:CollidesWithGrid() then
			d.state = "idle"
			npc.StateFrame = 0
		end
	elseif d.state == "stopcharge" then
		mod:spritePlay(sprite, "Charge0" .. d.dirString)
		npc.Velocity = npc.Velocity * 0.8
		if npc.StateFrame > 5 or npc:CollidesWithGrid() then
			d.state = "idle"
			npc.StateFrame = 0
		end
	end
	npc.SpriteOffset = Vector(0,-15)
end