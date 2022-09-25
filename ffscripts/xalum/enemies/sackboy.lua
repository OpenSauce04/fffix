local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			npc.SplatColor = FiendFolio.ColorPureWhite
			data.init = true
			sprite:PlayOverlay("Head", false)
			--npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end

		npc:AnimWalkFrame("WalkHori", "WalkVert", 0.3)

		if sprite:IsOverlayFinished("Shoot") then
			sprite:PlayOverlay("Head")
		end

		if sprite:IsOverlayPlaying("Head") then
			if FiendFolio:isScareOrConfuse(npc) or (Game():GetRoom():CheckLine(npc.Position, npc:GetPlayerTarget().Position, 0, 1, false, false) and not npc:CollidesWithGrid()) then
				npc.Velocity = (npc.Velocity * 0.8) + FiendFolio:reverseIfFear(npc, (FiendFolio:confusePos(npc, npc:GetPlayerTarget().Position) - npc.Position):Resized(0.5))
			else
				npc.Pathfinder:FindGridPath(npc:GetPlayerTarget().Position, 3, 1, false)
				
				npc.Velocity = npc.Velocity * 1.2
				npc.Velocity = npc.Velocity:Resized(math.min(npc.Velocity:Length(), 4))
			end
			if npc.FrameCount % 8 == 0 and math.random(20) == math.random(20) and not FiendFolio:isScareOrConfuse(npc) then
				sprite:PlayOverlay("Shoot", false)
			end
		else
			npc.Velocity = npc.Velocity * 0.9
		end

		if sprite:IsOverlayPlaying("Shoot") then
			if sprite:GetOverlayFrame() == 18 then
				sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.85, 0, false, 1)
				sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 0.5, 1, false, 0.7)
				local sackboys = Isaac.CountEntities(nil, 750, 80, 0, false, false)
				local spiders = Isaac.CountEntities(nil, 85, 0, 0, false, false)
				data.babyreplace = false
				if spiders < 4 * sackboys then
					for i = 1, math.ceil(math.random()*2) do
						EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(math.random(-40, 40), math.random(-40, 40)), false, 0)
					end
				end
				data.babyreplace = true
				for i = 1, 4 + math.random(3) + (spiders < 4 * sackboys and 0 or 3) do
					EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(math.random(-40, 40), math.random(-40, 40)), false, 0)
				end
			end
		end

		if npc:IsDead() then
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.85, 0, false, 1)
			data.babyreplace = false
			for i = 1, math.floor(math.random()*3) do
				EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(math.random(-40, 40), math.random(-40, 40)), false, 0)
			end
			data.babyreplace = true
			for i = 1, 7 + math.random(5) do
				EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(math.random(-40, 40), math.random(-40, 40)), false, 0)
			end
		end
	end,
	Collision = function(npc, collider)
		if collider.Type == 85 then return true end
	end
}