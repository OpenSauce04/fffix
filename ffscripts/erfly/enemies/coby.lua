local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:cobyAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local room = game:GetRoom()
	if not d.init then
		npc.SplatColor = mod.ColorPureWhite
		d.init = true
	end
	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	local targetpos = mod:confusePos(npc, target.Position)
	if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
		local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(3))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.4, 900, true)
	end

	if npc:IsDead() then
		local checkGrid = room:GetGridEntityFromPos(npc.Position)
		if not checkGrid or checkGrid:GetType() ~= 20 then
			Isaac.GridSpawn(10, 0, npc.Position, true)
		end
		for i = 90, 360, 90 do
			checkGrid = room:GetGridEntityFromPos(npc.Position + Vector(40, 0):Rotated(i))
			if not checkGrid or checkGrid:GetType() ~= 20 then
				Isaac.GridSpawn(10, 0, npc.Position + Vector(40, 0):Rotated(i), true)
			end
		end
		Isaac.Spawn(85, 962, 0, npc.Position, nilvector, npc)
	end
end