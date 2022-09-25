local mod = FiendFolio
local game = Game()

local HAEMO_RESPAWN_TIMER = 150

return {
	Init = function(npc)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		local room = game:GetRoom()

		if not data.fiendfolio_respawnData then
			npc:Die()
		end

		npc.Velocity = npc.Velocity * 0.7

		if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
			sprite:Play("Walk")

			if sprite:IsEventTriggered("Move") then
				if npc:CollidesWithGrid() then
					data.lastGridCollision = npc.FrameCount
				end

				if room:CheckLine(npc.Position, npc:GetPlayerTarget().Position + (npc.Position - npc:GetPlayerTarget().Position):Resized(5), 0, 1, false, false) and not (data.lastGridCollision and data.lastGridCollision + 15 > npc.FrameCount) then
					npc.Velocity = npc.Velocity * 0.8 + (npc.Position - npc:GetPlayerTarget().Position):Resized(0.5)
				else
					npc.Pathfinder:FindGridPath(npc.Position - npc:GetPlayerTarget().Position, npc.Velocity:Length() + 0.1, 2, false)
				end

				npc.Velocity = npc.Velocity:Resized(10)
			end
		else
			sprite:Play("Idle")
		end

		if npc.FrameCount >= HAEMO_RESPAWN_TIMER then
			Isaac.Spawn(1000, 16, 3, npc.Position, Vector.Zero, nil)
			Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, nil)

			local new = data.fiendfolio_respawnData
			new = Isaac.Spawn(new[1], new[2], new[3], npc.Position, Vector.Zero, nil)
			new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				new:AddCharmed(EntityRef(Isaac.GetPlayer()), -1)
			end

			new:GetData().fiendfolio_spawnedFromHaemoGlobin = true

			npc:BloodExplode()
			npc:Remove()
		end
	end,
}