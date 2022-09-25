local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local d = npc:GetData()
		local sprite = npc:GetSprite()

		npc.State = 0
		if not d.init then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
			if game:GetRoom():IsClear() then
				sprite:Play("ClosedEyes")
				d.cooking = false
			else
				sprite:Play("OpenEyes")
				d.cooking = true
			end
			d.cookstart = npc.FrameCount
			d.init = true
		end

		npc.Velocity = Vector.Zero

		if sprite:IsPlaying("StartCook") and sprite:GetFrame() == 10 then
			npc:PlaySound(FiendFolio.Sounds.FurnaceStart, 0.15, 0, false, 1.25)
		elseif sprite:IsPlaying("StartCook") and sprite:GetFrame() == 20 then
			sfx:Play(FiendFolio.Sounds.FurnaceLoop, 0.15, 0, true, 1.25)
		elseif sprite:IsPlaying("EndCook") and sprite:GetFrame() == 1 then
			sfx:Stop(FiendFolio.Sounds.FurnaceLoop)
			npc:PlaySound(FiendFolio.Sounds.FurnaceEnd, 0.15, 0, false, 1.25)
		end

		if d.cooking then
			if sprite:IsFinished("OpenEyes") then
				sprite:Play("StartCook")
			elseif sprite:IsFinished("StartCook") then
				sprite:Play("Cook")
				d.cookstart = npc.FrameCount
			end

			if game:GetRoom():IsClear() then
				sfx:Stop(FiendFolio.Sounds.FurnaceLoop)
				if sprite:IsFinished("CloseEyes") then
					FiendFolio:spritePlay(sprite, "ClosedEyes")
				else
					FiendFolio:spritePlay(sprite, "CloseEyes")
				end
			else
				if sprite:IsPlaying("Cook") then
					math.randomseed(npc.Index + npc.FrameCount)
					local creepMixed = Isaac.FindByType(1000, 26, -1, false, false)
					local creep = {}
					for i = 1, #creepMixed do
						if creepMixed[i].SubType ~= 7001 then -- ignore gunpowder
							table.insert(creep, creepMixed[i])
						end
					end
					if math.random(math.max(14-#creep, 6)) == 1 then
						if #creep > 0 then
							local c = creep[math.random(#creep)]
							local pos = c.Position + RandomVector() * (c.Size - math.max(4, math.log(math.random(math.floor(c.Size)))))
							local ents = {}
							for _, e in pairs(Isaac.GetRoomEntities()) do
								if e.Position:Distance(pos) - 7 - e.Size <= 1 and not (e.Type == 1000 and e.Variant == 26) then
									ents[#ents + 1] = e
								end
							end
							if game:GetRoom():GetGridEntityFromPos(pos) == nil and #ents == 0 then
								Isaac.Spawn(1000, 1723, 0, pos, Vector.Zero, nil)
							end
						end
					end
					if npc.FrameCount >= d.cookstart + 210 then
						sprite:Play("EndCook", true)
					end
				end

				if sprite:IsFinished("EndCook") then
					if math.random(120) == 1 then
						sprite:Play("StartCook")
					end
				end
			end
		end
	end,
}