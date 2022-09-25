local mod = FiendFolio

local MAX_CHAIN_DISTANCE = 65

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		
		if data.altsprite then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/ripcord/monster_lead_beadfly.png")
			sprite:LoadGraphics()
		end
		
		if not data.outline or not data.outline:Exists() or data.outline:IsDead() then
			data.outline = Isaac.Spawn(mod.FF.BeadFlyOutline.ID, mod.FF.BeadFlyOutline.Var, mod.FF.BeadFlyOutline.Sub, Vector.Zero, Vector.Zero, npc)
			data.outline:GetData().beadfly = npc
			data.outline.DepthOffset = -6000
		end
		
		if not data.dir then
			if npc.SubType == 0 then
				data.dir = Vector(1, 1):Rotated(90 * math.random(4))
			else
				data.dir = Vector(1, 1):Rotated(90 * npc.SubType)
			end

			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			sprite:Play("Appear")

			if npc.SpawnerType == 0 and not npc.Parent then
				local current = npc
				local flies = Isaac.FindByType(mod.FF.BeadFly.ID, mod.FF.BeadFly.Var)

				while #flies > 1 and current do
					local closest
					local distance = MAX_CHAIN_DISTANCE

					for _, fly in pairs(flies) do
						if GetPtrHash(fly) ~= GetPtrHash(current) and not fly.Parent and not fly.Child and fly.Position:Distance(current.Position) < distance then
							closest = fly
							distance = fly.Position:Distance(current.Position)
						end
					end

					if closest then
						closest.Parent = current
						current.Child = closest

						local dat = closest:GetData()
						dat.chain = Isaac.Spawn(mod.FF.BeadFlyChain.ID, mod.FF.BeadFlyChain.Var, mod.FF.BeadFlyChain.Sub, closest.Position, Vector.Zero, closest)
						dat.chain:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						dat.chain.Visible = false
					end

					current = closest
				end
			end

			if npc.SubType & 8 > 0 then
				data.altsprite = true
			end
		end

		if sprite:IsFinished("Appear") then
			sprite:Play("Fly")
		end
		
		
		if (npc.Parent and npc.Parent:IsDead()) or npc:HasMortalDamage() or npc:IsDead() then
			if data.chain then
				data.chain:Remove()
				data.chain = nil
			end
			
			npc.Parent = nil
		end
		
		-- uranus/martyr
		if npc.Child then
			if (npc.Parent and mod:isLeavingStatusCorpse(npc.Parent)) or mod:isLeavingStatusCorpse(npc) then
				if npc.Child then
					local cdata = npc.Child:GetData()
					if cdata.chain then
						cdata.chain:Remove()
						cdata.chain = nil
					end
				
					npc.Child.Parent = nil
					npc.Child = nil
				end
				npc.Parent = nil 
			end
		end

		if data.chain and npc.Parent then
			data.chain.SpriteRotation = (npc.Parent.Position - npc.Position):GetAngleDegrees()
			if data.chain.SpriteRotation > 90 or data.chain.SpriteRotation < -90 then
				data.chain.SpriteRotation = data.chain.SpriteRotation - 180
			end
			
			data.chain.Velocity = 0.5 * (npc.Position + npc.Parent.Position) - data.chain.Position
			data.chain.SpriteOffset = Vector(0, -16)
			data.chain.DepthOffset = -5000
			data.chain.SpriteScale = Vector(npc.Position:Distance(npc.Parent.Position) / 24, 1)
			data.chain:GetSprite().Color = sprite.Color
			data.chain.Visible = true
		end

		if sprite:IsPlaying("Fly") then
			if npc.Parent then
				local targetpos = npc.Parent.Position + (npc.Position - npc.Parent.Position) / 2
				local targetvel = targetpos - npc.Position

				npc.Velocity = mod.Xalum_Lerp(npc.Velocity, targetvel:Resized(5), 0.5)
			else
				npc.Velocity = mod.Xalum_Lerp(npc.Velocity, data.dir:Resized(5), 0.3)

				if npc.FrameCount % 15 == 0 or npc:CollidesWithGrid() then
					local check = {
						data.dir,
						data.dir:Rotated(90),
						data.dir:Rotated(-90),
					}

					local target = npc:GetPlayerTarget()
					local chosen = 1

					for i = 2, 3 do
						if (npc.Position + check[i]):Distance(target.Position) < (npc.Position + check[chosen]):Distance(target.Position) then
							chosen = i
						end
					end

					data.dir = check[chosen]
				end
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end
	end,
}