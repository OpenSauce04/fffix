local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			data.params = ProjectileParams()
			data.params.FallingAccelModifier = 2
			data.params.Variant = 1
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

		
		if sprite:IsEventTriggered("RegenSound") then
			FiendFolio:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 1)
		end

		if sprite:IsPlaying("ReGen") and sprite:GetFrame() == 58 then
			data.params.FallingSpeedModifier = math.random(-30, -10) * 1.5
			npc:FireProjectiles(npc.Position, Vector(30, 0):Rotated(math.random(360)):Resized(4 - math.random()*2), 0, data.params)
			npc.HitPoints = npc.MaxHitPoints /2
		end

		if data.globinwalk then
			npc:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
			FiendFolio.Xalum_globinpathfind(npc, 5, npc:GetPlayerTarget().Position)
		elseif data.globinslink then
			if #data.friends == 0 then
				sprite:Play("ReGen")
				data.globinslink = false
			else
				if not data.target or data.target:IsDead() or not data.target:Exists() then data.target = data.friends[math.random(#data.friends)] end
				sprite:Play("Move")

				if sprite:GetFrame() == 12 then
					if npc:CollidesWithGrid() then
						data.lastgridcollision = npc.FrameCount
					end

					if game:GetRoom():CheckLine(npc.Position, data.target.Position + (npc.Position - data.target.Position):Resized(5), 0, 1, false, false) and not (data.lastgridcollision and data.lastgridcollision + 15 > npc.FrameCount) then
						npc.Velocity = npc.Velocity * 0.8 + (data.target.Position - npc.Position):Resized(0.5)
					else
						npc.Pathfinder:FindGridPath(data.target.Position, npc.Velocity:Length() + 0.1, 2, false)
					end
					npc.Velocity = npc.Velocity:Resized(5)
				else
					npc.Velocity = npc.Velocity * 0.8
				end
			end
		else
			npc.Velocity = npc.Velocity * 0.8 
		end

		if npc.FrameCount % 45 == 2 and math.random(3) < 3 and not (data.globinslink or sprite:IsPlaying("ReGen")) then
			sfx:Play(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 0.8, 0, false, 1)
		end

		--[[if npc:HasMortalDamage() and data.globinwalk and not FiendFolio:isLeavingStatusCorpse(npc) then
			npc:BloodExplode()
			data.globinwalk = false
			data.globinslink = true
			npc.HitPoints = npc.MaxHitPoints /2
		end]]--
	end,
	Collision = function(npc, collider)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		local d = collider:GetData()
		if d.pairing and data.pairing and d.pairing == data.pairing and not data.nocollide and npc.FrameCount >= 5 and collider.FrameCount >= 5 then
			npc:Remove()
			collider:Remove()
			collider:GetData().nocollide = true
			
			local table = nil
			if collider.Variant == FiendFolio.FF.ConglobberateSmall.Var then
				table = FiendFolio.FF.ConglobberateMedium
			else
				table = FiendFolio.FF.ConglobberateLarge
			end

			local e = Isaac.Spawn(table.ID, table.Var, 0, npc.Position + (collider.Position - npc.Position)/2, npc.Velocity + collider.Velocity, nil)
			e:GetData().pairing = data.pairing
			e:GetData().appear2 = true
			e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			e.HitPoints = e.MaxHitPoints * (npc.HitPoints / npc.MaxHitPoints + collider.HitPoints / collider.MaxHitPoints) / 2
			e:Update()
		end
	end,
	Death = function(npc)
		local npcdata = npc:GetData()
		local sprite = npc:GetSprite()
		
		if (npcdata.globinwalk or sprite:IsPlaying("Appear")) and not FiendFolio:isLeavingStatusCorpse(npc) then
			local e = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, npc)
			e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				e:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
			
			local edata = e:GetData()
			edata.pairing = npcdata.pairing
			edata.globinwalk = false
			edata.globinslink = true
			e.HitPoints = e.MaxHitPoints / 2

			npc:Remove()
		end
	end,
}