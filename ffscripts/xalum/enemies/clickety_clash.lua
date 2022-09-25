local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		npc.Velocity = npc.Velocity * 0.8

		if npc.State == 16 then
			npc:Die()

			local off = math.random(360)
			for i = 1, 2 do
				local clack = Isaac.Spawn(889, 0, 0, npc.Position, Vector(40, 0):Rotated(off + i * 180), npc)
				clack:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				clack:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
				clack:ToNPC().State = 16
			end
		end
	end,
}