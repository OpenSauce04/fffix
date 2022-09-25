local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()

		npc:GetSprite():Play("Idle")
		npc.Velocity = data.traj:Rotated(30*math.sin(7*math.rad(npc.FrameCount)))

		for _, e in pairs(Isaac.GetRoomEntities()) do
			if e.Position:Distance(npc.Position) - e.Size - npc.Size <= 0 then
				if e.Type == 1 then
					e:TakeDamage(1, 0, EntityRef(npc.Parent), 0)
					local p = Isaac.Spawn(1000, 7020, 0, npc.Position, Vector.Zero, nil)
					p:GetSprite().Offset = Vector(0, -14)
					npc:Remove()
				elseif e:IsEnemy() and e:IsVulnerableEnemy() and e:IsActiveEnemy() and e.Type ~= 302 then

				end
			end
		end

		if npc:CollidesWithGrid() then
			local p = Isaac.Spawn(1000, 7020, 0, npc.Position, Vector.Zero, nil)
			p:GetSprite().Offset = Vector(0, -14)
			npc:Remove()
		end
	end,
}