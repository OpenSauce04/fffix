local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPathFlying(npc)

		if sprite:IsFinished("Appear") then
			data.fade = 1
			sprite:Play("Idle", false)
		elseif (sprite:IsFinished("BiteDown") or sprite:IsFinished("BiteUp")) and sprite:GetFrame() == 34 and data.bites >= 3 then
			sprite:Play("Idle", false)
			data.chomp = false
			data.bites = 0
			data.setpos = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 40)
		end

		if not data.init then
			npc.Mass = 40
			npc.SplatColor = FiendFolio.ColorGhostly
			data.lastchomp = npc.FrameCount
			data.init = true
			data.bites = 0
			data.setpos = npc.Position
		end

		if data.target then
			data.starget = data.target * 100
		end

		if data.chomp then
			if npc.Velocity.X >= 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end

			if data.starget.Y >= npc.Position.Y then
				sprite:SetFrame("BiteDown", data.chomp % 35)
			else
				sprite:SetFrame("BiteUp", data.chomp % 35)
			end

			if sprite:IsEventTriggered("Scream") then
				npc.Velocity = (data.target - npc.Position):Resized(12)
				npc:PlaySound(FiendFolio.Sounds.GnawfulNoises, 1.2, 0, false, math.random(90,120)/100)
			end

			if data.slowing then
				npc.Velocity = npc.Velocity * 0.8
				data.slowing = data.slowing + 1
				if data.slowing > 10 then
					data.slowing = nil
				end
			end

			if sprite:GetFrame() == 34 then
				data.target = npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Position - npc.Position)
			end
			data.chomp = data.chomp + 1
		else
			if sprite:IsPlaying("Idle") then
				npc.Velocity = npc.Velocity * 0.3 + (data.setpos - npc.Position):Resized(npc.Position:Distance(data.setpos) <= 5 and (data.setpos - npc.Position):Length() or 4)

				if npc.Velocity.X >= 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
				
				if data.lastchomp + 300 < npc.FrameCount and npc.FrameCount % 3 == 0 and math.random(10) == math.random(10) then
					data.chomp = 0
					data.target = npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Position - npc.Position)
				elseif npc:GetPlayerTarget().Position:Distance(npc.Position) <= 120 and npc.FrameCount % 3 == 0 and math.random(10) == math.random(10) then
					data.chomp = 0
					data.target = npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Position - npc.Position)
				end
			end
		end

		if npc.FrameCount >= 26 then
			if sprite:IsPlaying("Idle") then
				data.fade = data.fade - 0.05
				if data.fade < 0 then data.fade = 0 end
				npc:SetColor(Color(1, 1, 1, data.fade, 0, 0, 0), 0, 9999, false, false)
			else
				data.fade = data.fade + 0.1
				if data.fade > 1 then data.fade = 1 end
				npc:SetColor(Color(1, 1, 1, data.fade, 0, 0, 0), 0, 9999, false, false)
			end
		end

		if sprite:IsEventTriggered("Chomp") then
			data.slowing = 1
			data.bites = data.bites + 1
			npc:PlaySound(FiendFolio.Sounds.GnawfulBite, 1, 0, false, math.random(90,120)/100)
			data.lastchomp = npc.FrameCount
		end

		if sprite:IsPlaying("Idle") and npc.FrameCount % math.random(5, 10) == 0 and math.random(3) == math.random(3) then
			local creep = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
			creep:Update()

			local csprite = creep:GetSprite()
			csprite:ReplaceSpritesheet(0, "gfx/effects/effect_white_stains.png")
			csprite:LoadGraphics()
			csprite.Scale = csprite.Scale * 0.5
			creep:SetColor(Color(1, 1, 1, 0.5, 0, 0, 0), 900, 9999, false, false)
		end
	end,
	Damage = function(npc) -- Haha you have too many teeth
		local data = npc:GetData()
		npc = npc:ToNPC()
		if npc:GetSprite():IsPlaying("Idle") then
			data.chomp = 0
			data.target = npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Position - npc.Position)
		end
	end,
}