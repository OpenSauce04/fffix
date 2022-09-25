local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		if npc.FrameCount % 12 == 0 and not game:GetRoom():HasWater() then
			local creep = Isaac.Spawn(1000, 23, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 30, 99999, true, false)
			creep:SetTimeout(math.floor(creep.Timeout * 0.75))
			creep:Update()
		end
	end
}