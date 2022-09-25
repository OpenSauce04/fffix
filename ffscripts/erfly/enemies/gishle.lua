local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:gishleAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.tramp = mod.FindClosestEntityHasTarget(target.Position, 99999, mod.FF.TarBubble.ID, mod.FF.TarBubble.Var)
		d.init = true
	end

	if d.state == "idle" then
		if d.tramp then
			local targvel = (d.tramp.Position - npc.Position):Resized(3)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
		end
	end
end