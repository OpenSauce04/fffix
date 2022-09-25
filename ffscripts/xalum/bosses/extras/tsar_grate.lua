local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	Init = function(npc)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.RenderZOffset = -5000
	end,
	AI = function(npc)
		local data = npc:GetData()

		npc.State = 0
		npc.Velocity = Vector.Zero

		for _, creepVariant in pairs(mod.tsarCreeps) do
			for _, creep in pairs(Isaac.FindByType(1000, creepVariant)) do
				if creep.Position:Distance(creep.Position) < npc.Size + creep.Size then
					creep = creep:ToEffect()
					creep.Timeout = math.min(10, creep.Timeout)
				end
			end
		end
	end
}