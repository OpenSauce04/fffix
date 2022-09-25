local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect) -- Shhh, this is our little secret
	local data = effect:GetData()

	if (not data.head or data.head:IsDead() or mod:isStatusCorpse(data.head)) or (not data.tail or data.tail:IsDead() or mod:isStatusCorpse(data.tail)) then
		effect:Remove()
	end
end, mod.FF.RotspinChain.Var)

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)

		if not data.heads then
			data.heads = {}
			data.links = {}

			data.rotationoffset = math.random(360)
			data.rotationpartition = math.max(1, npc.SubType)
			data.headdistance = 0

			npc.SplatColor = mod.ColorIpecacProper

			for i = 1, data.rotationpartition do
				data.heads[i] = Isaac.Spawn(mod.FF.RotspinMoon.ID, mod.FF.RotspinMoon.Var, 0, npc.Position, Vector.Zero, npc)
				data.heads[i]:GetSprite():Play("Head")
				data.heads[i]:GetData().body = npc
				data.heads[i]:GetData().rotationframe = 0

				for j = 1, 10 do
					local n = 10 * (i - 1) + j
					data.links[n] = Isaac.Spawn(1000, mod.FF.RotspinChain.Var, 0, npc.Position, Vector.Zero, npc)
					data.links[n]:GetSprite():Play("Cord")

					local d2 = data.links[n]:GetData()
					d2.head = npc
					d2.tail = data.heads[i]

					data.links[n].SpriteOffset = Vector(0, -2 * ((j - 5) / 3) ^ 2 + 10)
					data.links[n].PositionOffset = Vector(0, -5)

					data.links[n].Velocity = Vector.Zero

					if j >= 9 then data.links[n].DepthOffset = -5 * j end
				end
			end
		else
			if npc.FrameCount % 5 == math.random(3) then npc:MakeSplat(0.5).Color = mod.ColorIpecacProper end
			sprite:Play("Body")

			local playerTarget = npc:GetPlayerTarget()

			if mod.IsPositionCloselyEncased(npc.Position) then
				npc.Velocity = npc.Velocity * 0.6
			elseif npc.Pathfinder:HasPathToPos(playerTarget.Position, false) then
				data.targetpos = data.targetpos or mod.GetNextOssularryTarget(npc)
				if npc.Position:Distance(data.targetpos) < 10 or not npc.Pathfinder:HasPathToPos(data.targetpos, false) then
					data.targetpos = mod.GetNextOssularryTarget(npc)
				end

				mod.XalumGridPathfind(npc, data.targetpos, 4/3)
			else
				mod.XalumLiteGridPathfind(npc, 4/3)
			end

			if data.headdistance < 100 then
				data.headdistance = data.headdistance + 1
			end

			local killedHeads = 0

			for i, head in pairs(data.heads) do
				if head and head:Exists() and not (head:IsDead() or mod:isStatusCorpse(head)) then
					local headdata = head:GetData()
					local targetpos = npc.Position + Vector(0, data.headdistance):Rotated(data.rotationoffset + i * 360 / data.rotationpartition + 1.5 * headdata.rotationframe)
					head.Velocity = (targetpos - head.Position) * 0.9

					local dir = head.Position + head.Velocity - npc.Position
					for j = 1, 10 do
						local n = 10 * (i - 1) + j
						local link = data.links[n]

						if link and link:Exists() then
							local dir2 = dir:Resized(dir:Length() * (j - 1) / 9)
							link.Position = link.Position + ((npc.Position + dir2 + Vector(0, 5)) - link.Position)
							link.Velocity = Vector.Zero
						end
					end

					headdata.rotationframe = headdata.rotationframe + 1
				else
					killedHeads = killedHeads + 1
				end
			end

			if killedHeads >= #data.heads then
				npc:Morph(mod.FF.Spoilie.ID, mod.FF.Spoilie.Var, 0, npc:GetChampionColorIdx())
				sprite:Play("RegenShort")
				mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 1)
			end
		end
	end,
	Collision = function(npc, collider)
		if collider.Type == npc.Type and (collider.Variant == npc.Variant or collider.Variant == mod.FF.RotspinMoon.Var) then
			return true
		end
	end
}