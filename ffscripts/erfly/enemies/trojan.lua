local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:trojanUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
    local room = game:GetRoom()

    if not d.init then
		d.state = "idle"
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
                d.dir = "Hori"
				if npc.Velocity.X < 0 then
					sprite.FlipX = true
                else
                    sprite.FlipX = false
				end

			end
			mod:spritePlay(sprite, d.dir)
            mod:spriteOverlayPlay(sprite, "Head" .. d.dir)
		end
    end
end

function mod:trojanHurt(npc, amount, damageFlags, source)
    if source.Type == 2 then

    end
end