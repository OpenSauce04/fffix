local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)

		if not data.init then
			if game:GetRoom():IsClear() then
				npc.SplatColor = FiendFolio.ColorGhostly
				npc:Remove()
				return
			end
			data.anim = "Appear"
			data.animstartframe = 0
			data.animlength = 16
			data.state = 0
			data.init = true
			data.timetochange = 99999
			data.params = ProjectileParams()
			data.params.Variant = 4
			data.params.BulletFlags = ProjectileFlags.GHOST
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			sprite.Offset = Vector(0, -14)
		end
		--To stop the Wall Hugger sfx, probably is a better solution but it works
		if npc.FrameCount < 60 then
			sfx:Stop(SoundEffect.SOUND_GOOATTACH0)
		end
		if sprite:IsFinished("Appear") then
			data.anim = "Idle01"
			data.animstartframe = npc.FrameCount
			data.animlength = 16
			data.state = 1
			data.timetochange = npc.FrameCount + 75
		end

		if sprite:GetFrame() == data.animlength - 1 then
			if data.anim == "StartScream" then
				data.anim = "Idle04"
				data.animstartframe = npc.FrameCount
				data.animlength = 16
			elseif data.anim == "Idle04Fin" then
				data.anim = "Idle03"
				data.animstartframe = npc.FrameCount
				data.animlength = 16
				data.state = 3
				data.timetochange = npc.FrameCount + 75
			end
		end

		if data.anim == "StartScream" and sprite:GetFrame() == 8 then
			sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT, 0.8, 0, false, 1)
			sfx:Play(SoundEffect.SOUND_LOW_INHALE, 0.65, 0, false, 1.6)
		end

		if data.state ~= 0 then
			sprite:SetFrame(data.anim, (npc.FrameCount - data.animstartframe) % data.animlength)
		end

		npc.Velocity = npc.Velocity * 3/4

		if data.timetochange <= npc.FrameCount and data.state < 4 then
			data.state = data.state + 1
			data.timetochange = npc.FrameCount + 75
			data.animstartframe = npc.FrameCount
			if data.state == 4 then
				data.anim = "StartScream"
				data.animlength = 22
			else
				data.anim = "Idle0"..data.state
				data.animlength = 16
			end
		end

		if data.anim == "Idle04" and npc.FrameCount % 5 == 0 then
			for i = 1, 3 do
				data.params.FallingSpeedModifier = 0 - math.random(20)
				data.params.FallingAccelModifier = 1 + (math.random() * 0.5)
				npc:FireProjectiles(npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(4) + (RandomVector() * math.random() * 3.5), 0, data.params)
			end

			sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.8, 0, false, 1)
		end

		if (game:GetRoom():IsClear() or FiendFolio:AreAllButtonsPressed()) and data.state < 5 then
			data.anim = "Death0"..data.state
			data.animstartframe = npc.FrameCount
			data.animlength = 16
			data.state = 5
		end

		if data.state == 5 and sprite:GetFrame() == 15 then
			npc:Remove()
		end
	end,
	Damage = function(npc)
		local data = npc:GetData()
		
		if data.state == 4 then
			data.state = 3
			data.anim = "Idle04Fin"
			data.animstartframe = npc.FrameCount
			data.animlength = 10
			data.timetochange = npc.FrameCount + 99999
		elseif data.state == 2 or data.state == 3 then
			data.state = data.state - 1
			data.anim = "Idle0"..data.state
			data.animstartframe = npc.FrameCount
			data.animlength = 15
			data.timetochange = npc.FrameCount + 75
		elseif data.state == 1 then
			data.timetochange = npc.FrameCount + 75
		end

		return false
	end,
}