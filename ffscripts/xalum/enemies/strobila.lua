local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if npc.State == 4 then
			if npc.Velocity:Length() >= 4 then
				npc.Velocity = npc.Velocity:Resized(4)
			end

			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				sprite:SetOverlayFrame("HoriHead", 0)
			else
				if npc.Velocity.Y >= 0 then
					sprite:SetOverlayFrame("DownHead", 0)
				else
					sprite:SetOverlayFrame("UpHead", 0)
				end
			end

			data.frame = nil
			data.count = npc.FrameCount
			data.limit = 1
			data.projcounter = 0
			data.yabbadabbadoo = true
		elseif npc.State == 8 then
			if data.yabbadabbadoo then
				data.yabbadabbadoo = false
				sfx:Play(SoundEffect.SOUND_MAGGOTCHARGE, 1, 0, false, 1)
			end

			data.limit = data.limit * 1.3^(npc.FrameCount - data.count)
			if data.limit > 8 then data.limit = 8 end
			npc.Velocity = npc.Velocity * 1.3
			if npc.Velocity:Length() >= data.limit then
				npc.Velocity = npc.Velocity:Resized(data.limit)
			end

			local dir = nil
			if sprite:IsPlaying("Up") then
				dir = "Up"
			elseif sprite:IsPlaying("Down") then
				dir = "Down"
			elseif sprite:IsPlaying("Hori") then
				dir = "Hori"
			end

			if dir then
				data.frame = data.frame and data.frame + 1 or sprite:GetOverlayFrame()
				if data.frame > 21 then data.frame = 0 end

				data.projcounter = data.projcounter + 1

				if data.projcounter % 16 == 4 then
					npc:FireProjectiles(npc.Position + npc.Velocity, (npc.Velocity/4):Rotated(90), 0, ProjectileParams())
					npc:FireProjectiles(npc.Position + npc.Velocity, (npc.Velocity/4):Rotated(-90), 0, ProjectileParams())
				end

				sprite:SetOverlayFrame(dir.."Charge", data.frame)
			end
		end
	end
}