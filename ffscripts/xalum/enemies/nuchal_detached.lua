local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			sprite:Play("BabyAppear", true)
			sfx:Play(SoundEffect.SOUND_MULTI_SCREAM, 0.7, 0, false, 1)
			data.init = true
		end

		if sprite:IsFinished("BabyAppear") then
			sprite:PlayOverlay("Head")
		end

		if sprite:IsOverlayPlaying("Head") then
			npc:AnimWalkFrame("WalkHori", "WalkVert", 0.3)
			
			local playerpos = FiendFolio:confusePos(npc, npc:GetPlayerTarget().Position)

			if not game:GetRoom():CheckLine(npc.Position,playerpos,0,1,false,false) then
				local npcVelBefore = npc.Velocity * 0.6
				npc.Pathfinder:FindGridPath(playerpos, 1, 900, true)

				local npcVelAfter = npc.Velocity:Resized(5)
				npc.Velocity = npcVelBefore + npcVelAfter
			else
				npc.Velocity = npc.Velocity * 0.6 + FiendFolio:reverseIfFear(npc, (playerpos - npc.Position):Resized(3))
			end
			
			if npc.Velocity:Length() > 5 then
				npc.Velocity = npc.Velocity:Resized(5)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end
	end
}