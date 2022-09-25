local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--mullikaboomai, mulliboom2
function mod:smokingMulliganAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local path = npc.Pathfinder

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
		mod:spriteOverlayPlay(sprite, "Walk")
	else
		sprite:SetFrame("WalkVert", 0)
		sprite:SetOverlayFrame("Walk", 0)
	end

	local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4))
	if game:GetRoom():CheckLine(npc.Position,targetpos - targetvel:Resized(5),0,1,false,false) then
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end

	if npc:IsDead() then
		game:BombExplosionEffects(npc.Position, 15, 0, Color(0, 0, 0, 0, 0, 0, 0), npc, 0.5, false, true)
		Isaac.Spawn(1000, 1, 0, npc.Position, nilvector, npc)
		mod.smokingMulliganTicks = mod.smokingMulliganTicks or 0
		mod.smokingMulliganLocations = mod.smokingMulliganLocations or {}
		table.insert(mod.smokingMulliganLocations, {Vector(npc.Position.X, npc.Position.Y), mod.smokingMulliganTicks, nil})
	end

end

function mod.smokingMulliganExplosionHandling()
	if #mod.smokingMulliganLocations > 0 then
		if mod.smokingMulliganTicks then
			mod.smokingMulliganTicks = mod.smokingMulliganTicks + 1
		else
			mod.smokingMulliganTicks = 0
		end
		local alldone = true

		for k = 1, #mod.smokingMulliganLocations do
			local pos = mod.smokingMulliganLocations[k][1]
			local npc = mod.smokingMulliganLocations[k][3]
			if mod.smokingMulliganTicks < mod.smokingMulliganLocations[k][2] + 11 then
				alldone = false
			end
			if mod.smokingMulliganTicks == mod.smokingMulliganLocations[k][2] + 5 then
				for i = 1, 4 do
					game:BombExplosionEffects(pos + Vector(40, 0):Rotated(90*i), 10, 0, Color(0, 0, 0, 0, 0, 0, 0), npc, 0.5, false, true)
					Isaac.Spawn(1000, 1, 0, pos + Vector(40, 0):Rotated(90*i), nilvector, npc)
				end
			elseif mod.smokingMulliganTicks == mod.smokingMulliganLocations[k][2] + 10 then
				for i = 1, 2 do
					game:BombExplosionEffects(pos + Vector(80, 0):Rotated(180*i), 5, 0, Color(0, 0, 0, 0, 0, 0, 0), npc, 0.5, false, true)
					Isaac.Spawn(1000, 1, 0, pos + Vector(80, 0):Rotated(180*i), nilvector, npc)
				end
			end
		end
		if alldone then
			mod.smokingMulliganLocations = {}
			mod.smokingMulliganTicks = nil
		end
	end
end

function mod:mullikaboomColl(npc1, npc2)
    if npc2.Type == 1 then
        npc1:Kill()
    end
end