local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	PreUpdate = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if data.globinslink and not npc:HasMortalDamage() then
			if data.proj then
				for _, p in pairs(data.proj) do
					if p:Exists() and not p:IsDead() then
						p.Velocity = p.Velocity * 0.9
						if p.Velocity:Length() > 0.1 and p.FallingAccel then
							p.FallingAccel = -p.FallingSpeed
						else
							p.FallingAccel = 0
						end
					end
				end
			end
			
			npc.State = 0
			data.animframe = data.animframe and data.animframe + 1 or sprite:GetFrame()

			if data.regen then
				if data.animframe >= 24 then 
					npc.State = 4
					npc.HitPoints = npc.MaxHitPoints / 2
					data.globinslink = false
					data.regen = false
					return
				end
				sprite:SetFrame("ReGen", data.animframe)

				npc.Velocity = npc.Velocity * 0.8
			else
				if data.animframe >= 29 then data.animframe = 0 end
				sprite:SetFrame("WalkGuts", data.animframe)

				if data.animframe == 19 then
					if npc:CollidesWithGrid() then
						data.lastgridcollision = npc.FrameCount
					end

					if game:GetRoom():CheckLine(npc.Position, npc:GetPlayerTarget().Position + (npc.Position - npc:GetPlayerTarget().Position):Resized(5), 0, 1, false, false) and not (data.lastgridcollision and data.lastgridcollision + 15 > npc.FrameCount) then
						npc.Velocity = npc.Velocity * 0.8 + (npc.Position - npc:GetPlayerTarget().Position):Resized(0.5)
					else
						npc.Pathfinder:FindGridPath(npc.Position - npc:GetPlayerTarget().Position, npc.Velocity:Length() + 0.1, 2, false)
					end

					npc.Velocity = npc.Velocity:Resized(10)
				else
					npc.Velocity = npc.Velocity * 0.8
				end
			end

			if npc.FrameCount % 6 == 0 then
				Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0, 0), npc)
			end

			if data.death + 150 <= npc.FrameCount and not data.regen then
				data.regen = true
				data.animframe = 0
				sprite:SetFrame("ReGen", 0)
				FiendFolio:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 0.6, 1)
			end

			return true
		end
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)

		if not data.params then
			data.params = ProjectileParams()
			data.params.HeightModifier = -5
		end

		if sprite:IsEventTriggered("Shoot") then
			local c = Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0, 0), npc):ToEffect()
			c.SpriteScale = c.SpriteScale * 3
			c:Update()


			for i = 1, 7 + math.random(8) do
				data.params.Scale = math.random(10, 15)/10
				npc:FireProjectiles(npc.Position, RandomVector():Resized(12 - math.random()*2), 0, data.params)
			end

			data.proj = {}
			for _, p in pairs(Isaac.FindByType(9, 0, -1)) do
				if p.FrameCount <= 1 and p.SpawnerType == FiendFolio.FF.Globwad.ID then
					data.proj[#data.proj + 1] = p:ToProjectile()
				end
			end
		end

		if data.proj then
			for _, p in pairs(data.proj) do
				if p:Exists() and not p:IsDead() then
					p.Velocity = p.Velocity * 0.9
					if p.Velocity:Length() > 0.1 and p.FallingAccel then
						p.FallingAccel = -p.FallingSpeed
					else
						p.FallingAccel = 0
					end
				end
			end
		end

		if data.globinslink and npc:HasMortalDamage() and FiendFolio:isLeavingStatusCorpse(npc) then -- To make Uranus/Crucifix corpses display the correct anim
			if data.regen then
				sprite:SetFrame("ReGen", data.animframe or 0)
			else
				sprite:SetFrame("WalkGuts", data.animframe or 0)
			end
		end
		
		--[[if npc:HasMortalDamage() and npc:Exists() and not npc:IsDead() and not FiendFolio:isLeavingStatusCorpse(npc) then
			if not data.globinslink then
				npc.HitPoints = npc.MaxHitPoints / 2
				data.globinslink = true
				sprite:SetFrame("WalkGuts", 0)
				data.death = npc.FrameCount
				npc:BloodExplode()
			else
				local r = math.random(2, 3)
				local offset = math.random(360)

				for i = 1, r do
					local e = Isaac.Spawn(24, 0, 0, npc.Position, Vector(33, 0):Rotated(i*360/r + offset), npc):ToNPC()
					e.State = 3
					e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					e:GetSprite():Play("ReGen")
					e.HitPoints = e.MaxHitPoints / 2
				end

				for i = 1, 4 do
					npc:FireProjectiles(npc.Position, Vector(0, 6):Rotated(90*i), 0, ProjectileParams())
				end

				local c = Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0, 0), npc):ToEffect()
				c.Scale = 1.5
				c:Update()
				math.randomseed(c.InitSeed)
				c:GetSprite():Play("BigBlood0"..math.random(6))
			end
		end]]--
	end,
	Death = function(npc)
		local npcdata = npc:GetData()
		local sprite = npc:GetSprite()
		
		if not FiendFolio:isLeavingStatusCorpse(npc) then
			if not npcdata.globinslink then
				local e = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, npc)
				e:ToNPC():Morph(e.Type, e.Variant, e.SubType, npc:ToNPC():GetChampionColorIdx())
				e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

				if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
					e:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
				end
				
				local edata = e:GetData()
				edata.globinslink = true
				edata.death = e.FrameCount
				edata.proj = npcdata.proj
				e.HitPoints = math.min(e.MaxHitPoints / 2, 30)
				e:GetSprite():SetFrame("WalkGuts", 0)

				npc:Remove()
			else
				local r = math.random(2, 3)
				local offset = math.random(360)

				for i = 1, r do
					local e = Isaac.Spawn(24, 0, 0, npc.Position, Vector(33, 0):Rotated(i*360/r + offset), npc):ToNPC()
					e.State = 3
					e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					e:GetSprite():Play("ReGen")
					e.HitPoints = e.MaxHitPoints / 2
				end

				for i = 1, 4 do
					npc:FireProjectiles(npc.Position, Vector(0, 6):Rotated(90*i), 0, ProjectileParams())
				end

				local c = Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0, 0), npc):ToEffect()
				c.SpriteScale = c.SpriteScale * 3
				c:Update()
			end
		end
	end,
}