local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		npc.SplatColor = FiendFolio.ColorCharred
		FiendFolio:UnscareWhenOutOfRoom(npc)

		if sprite:IsFinished("Appear") then
			sprite:Play("Move")
		end

		local target = npc:GetPlayerTarget()

		if npc.FrameCount >= 90  then
			if data.corpse then
				if not data.corpse:IsDead() then
					data.target = data.corpse
				else
					local newcorpse = FiendFolio.FindClosestEntity(npc.Position, 99999, 750, 10)
					if newcorpse then
						data.corpse = newcorpse
					else
						data.corpse = nil
						data.target = nil
					end
				end
			else
				local newcorpse = FiendFolio.FindClosestEntity(npc.Position, 99999, 750, 10)
				if newcorpse then
					data.corpse = newcorpse
				else
					data.corpse = nil
					data.target = nil
				end
			end
		end

		if data.target then
			target = data.target
		end

		if not (npc:HasEntityFlags(EntityFlag.FLAG_FEAR) or npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)) then
			if sprite:IsPlaying("Move") and npc.FrameCount >= 20 then
				npc.Velocity = npc.Velocity * 0.9 + (target.Position - npc.Position):Resized(npc.Position:Distance(target.Position) > 20 and 0.9 or 10)

				npc.Velocity = npc.Velocity:Resized(math.min(npc.Velocity:Length(), 7))

				if (target.Type == 750 and target.Variant == 10) and npc.Position:Distance(target.Position) - npc.Size - target.Size <= 5 then
					local possessed = Isaac.Spawn(227, 750, 0, target.Position, Vector.Zero, npc)
					possessed:GetData().moanerhealth = npc.HitPoints
					npc:PlaySound(SoundEffect.SOUND_SATAN_BLAST, 0.3, 0, false, 1.6)

					target:Remove()
					npc:Remove()
				end
			else
				npc.Velocity = npc.Velocity * 0.97
			end
		else
			npc.Pathfinder:MoveRandomly(false)
		end

		if npc:IsDead() and data.corpse then
			data.corpse:Kill()
		end
	end,
}