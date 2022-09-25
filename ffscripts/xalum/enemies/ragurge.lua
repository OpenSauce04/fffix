local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if sprite:IsFinished("Appear") then
			sprite:PlayOverlay("Head")
		end

		if sprite:IsOverlayFinished("Vomit") then
			sprite:PlayOverlay("SuckStart", false)

			local pitch = math.random(130,160)/100
			npc:PlaySound(FiendFolio.Sounds.MukCharge, 1, 0, false, pitch)
		end

		if sprite:IsOverlayFinished("SuckStart") then
			sprite:PlayOverlay("SuckLoop")
		elseif sprite:IsOverlayFinished("SuckEnd") then
			sprite:PlayOverlay("Head")
		end

		if not data.reds then data.reds = {} end
		npc:AnimWalkFrame("WalkHori", "WalkVert", 0.3)

		if sprite:IsOverlayPlaying("Head") then
			npc.Pathfinder:MoveRandomlyBoss()
			FiendFolio:runIfFearNearby(npc)

			npc.Velocity = npc.Velocity * 1.2
			npc.Velocity = npc.Velocity:Resized(math.min(npc.Velocity:Length(), 4))

			if npc.FrameCount % 15 == 0 and math.random(6) == math.random(6) and not FiendFolio:isScareOrConfuse(npc) then
				sprite:PlayOverlay("Vomit")
				sfx:Play(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR, 0.6, 0, false, 1)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end

		if sprite:IsOverlayPlaying("Vomit") then
			local f = sprite:GetOverlayFrame()
			if f >= 10 and f <= 30 then
				local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(math.random(-7, 7), math.random(-7, 7)):Rotated(math.random(360)), npc):ToProjectile()
				if math.random(2) == math.random(2) then
					proj:AddProjectileFlags(ProjectileFlags.CURVE_LEFT | ProjectileFlags.NO_WALL_COLLIDE)
					data.reds[#data.reds + 1] = proj
				else
					proj:AddProjectileFlags(ProjectileFlags.SMART)
				end
				proj.FallingSpeed = -30
				proj.FallingAccel = 2
			end
		end

		if #data.reds > 0 then
			local temp = data.reds
			data.reds = {}
			for _, p in pairs(temp) do
				if p:Exists() then
					data.reds[#data.reds + 1] = p
				end
			end
		end

		if #data.reds > 0 then
			for _, p in pairs(data.reds) do
				if p.FallingSpeed >= 0 and p.Height + p.FallingAccel >= -20 then
					p.FallingSpeed = 0
					p.FallingAccel = -0.1
					p.Height = -20
				end
				if sprite:IsOverlayPlaying("SuckLoop") then
					p:GetData().ShaggothMarkerOverride = true
					p.Velocity = p.Velocity * 0.6 + (npc.Position - p.Position) * 0.07
					if p.Position:Distance(npc.Position) - p.Size - npc.Size <= 0 then
						p:Remove()
					end
				end
			end

			if npc:HasMortalDamage() then
				for _, p in pairs(data.reds) do
					p.FallingAccel = 1
				end
			end
		end

		if sprite:IsOverlayPlaying("SuckLoop") and #data.reds == 0 then
			sprite:PlayOverlay("SuckEnd", false)
		end
	end,
}