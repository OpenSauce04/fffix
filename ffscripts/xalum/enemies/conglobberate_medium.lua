local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			data.params = ProjectileParams()
			data.params.FallingAccelModifier = 2
			if not data.pairing then data.pairing = npc.Index end
			data.init = true
		end

		data.friends = {}
		local enemies = Isaac.FindByType(750)
		for _, e in pairs(enemies) do
			if e.Variant == FiendFolio.FF.ConglobberateSmall.Var or e.Variant == FiendFolio.FF.ConglobberateMedium.Var then
				local d = e:GetData()
				if e.Index ~= npc.Index and d.pairing and d.pairing == data.pairing and e:Exists() and not e:IsDead() then
					data.friends[#data.friends + 1] = e
				end
			end
		end

		if sprite:IsFinished("Appear") or sprite:IsFinished("ReGen") then
			data.globinwalk = true
		end

		if sprite:IsFinished("Appear2") then
			data.globinslink = true
		end

		if sprite:IsEventTriggered("RegenSound") then
			FiendFolio:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 0.8, 1)
		end

		if sprite:IsPlaying("ReGen") and sprite:GetFrame() == 58 then
			for i = 1, math.random(3, 6) do
				data.params.Variant = math.random(1, 2) - 1
				data.params.FallingSpeedModifier = math.random(-30, -10) * 1.5
				npc:FireProjectiles(npc.Position, Vector(30, 0):Rotated(math.random(360)):Resized(4 - math.random()*2), 0, data.params)
			end
		end

		if data.globinwalk then
			npc:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
			FiendFolio.Xalum_globinpathfind(npc, 3.5, npc:GetPlayerTarget().Position)
		elseif data.globinslink then
			if #data.friends == 0 then
				sprite:Play("ReGen")
				data.globinslink = false
			else
				if not data.target or data.target:IsDead() or not data.target:Exists() then data.target = data.friends[math.random(#data.friends)] end
				sprite:Play("Move")

				if sprite:GetFrame() == 20 then
					if npc:CollidesWithGrid() then
						data.lastgridcollision = npc.FrameCount
					end

					if game:GetRoom():CheckLine(npc.Position, data.target.Position + (npc.Position - data.target.Position):Resized(5), 0, 1, false, false) and not (data.lastgridcollision and data.lastgridcollision + 15 > npc.FrameCount) then
						npc.Velocity = npc.Velocity * 0.8 + (data.target.Position - npc.Position):Resized(0.5)
					else
						npc.Pathfinder:FindGridPath(data.target.Position, npc.Velocity:Length() + 0.1, 2, false)
					end
					npc.Velocity = npc.Velocity:Resized(3.5)
				else
					npc.Velocity = npc.Velocity * 0.8
				end
			end
		else
			npc.Velocity = npc.Velocity * 0.8
			if data.appear2 then
				sprite:Play("Appear2")
				data.appear2 = false
			end
		end

		if npc.FrameCount % 45 == 2 and math.random(3) < 3 and not (data.globinslink or sprite:IsPlaying("ReGen") or sprite:IsPlaying("Appear2")) then
			sfx:Play(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 0.8, 0, false, 0.8)
		end

		--[[if npc:HasMortalDamage() and data.globinwalk and not npc:IsDead() and npc:Exists() and not FiendFolio:isLeavingStatusCorpse(npc) then
			local offset = math.random(360)
			for i = 1, 2 do
				local e = Isaac.Spawn(FiendFolio.FF.ConglobberateSmall.ID, FiendFolio.FF.ConglobberateSmall.Var, 0, npc.Position, Vector(23, 0):Rotated(180*i + offset), npc)
				e:GetData().pairing = data.pairing
				e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				e:GetData().globinslink = true
				e:GetSprite():Play("Move")
				e.HitPoints = e.MaxHitPoints/2
			end
			local e = Isaac.Spawn(FiendFolio.FF.TomaChunk.ID, FiendFolio.FF.TomaChunk.Var, FiendFolio.FF.TomaChunk.Sub, npc.Position, npc.Velocity, npc)
			e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			for i = 1, 4 do
				npc:FireProjectiles(npc.Position, Vector(0, 6):Rotated(90*i), 0, ProjectileParams())
			end
		end]]--
	end,
	Death = function(npc)
		local npcdata = npc:GetData()
		local sprite = npc:GetSprite()
		
		if (npcdata.globinwalk or sprite:IsPlaying("Appear")) and not FiendFolio:isLeavingStatusCorpse(npc) then
			local offset = math.random(360)
			for i = 1, 2 do
				local e = Isaac.Spawn(FiendFolio.FF.ConglobberateSmall.ID, FiendFolio.FF.ConglobberateSmall.Var, 0, npc.Position, Vector(23, 0):Rotated(180*i + offset), npc)
				e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

				if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
					e:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
				end
				
				local edata = e:GetData()
				edata.pairing = npcdata.pairing
				edata.globinwalk = false
				edata.globinslink = true
				e:GetSprite():Play("Move")
				e.HitPoints = e.MaxHitPoints / 2
			end
			
			local e = Isaac.Spawn(FiendFolio.FF.TomaChunk.ID, FiendFolio.FF.TomaChunk.Var, FiendFolio.FF.TomaChunk.Sub, npc.Position, npc.Velocity, npc)
			e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				e:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
			
			for i = 1, 4 do
				npc:FireProjectiles(npc.Position, Vector(0, 6):Rotated(90*i), 0, ProjectileParams())
			end

			npc:Remove()
		end
	end,
}