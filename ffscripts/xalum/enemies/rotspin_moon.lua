local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if data.body and (data.body:IsDead() or FiendFolio:isStatusCorpse(data.body)) then
			sprite:Play("Death")
			data.body = nil
		elseif not data.body then
			npc.Velocity = npc.Velocity * 0.9
		end

		if sprite:IsFinished("Death") then npc:Die() end

		if npc.FrameCount > 15 and npc.FrameCount % 15 == 0 then
			local gas = Isaac.Spawn(1000, 141, 0, npc.Position, Vector.Zero, npc):ToEffect()
			gas:SetTimeout(270)
			gas.SpriteScale = Vector(0.8, 0.8)

			for i = 1, 10 do gas:Update() end
		end

		if npc.FrameCount % 5 == math.random(3) then npc:MakeSplat(0.5).Color = FiendFolio.ColorIpecacProper end

		if FiendFolio:isLeavingStatusCorpse(npc) then
			local off = math.random(360)
			for i = 1, 3 do
				local gas = Isaac.Spawn(1000, 141, 0, npc.Position + Vector(25, 0):Rotated(i * 120 + off), Vector.Zero, npc):ToEffect()
				gas:SetTimeout(270)

				for i = 1, 10 do gas:Update() end
			end
		elseif npc:IsDead() then
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)

			local off = math.random(360)
			for i = 1, 3 do
				local gas = Isaac.Spawn(1000, 141, 0, npc.Position + Vector(25, 0):Rotated(i * 120 + off), Vector.Zero, npc):ToEffect()
				gas:SetTimeout(270)

				for i = 1, 10 do gas:Update() end
			end

			for i = 1, 2 + math.random(2) do
				FiendFolio.ThrowMaggot(npc.Position, RandomVector():Resized(math.random(2, 5)), -14, math.random(-15, -10), npc)
			end
		end
	end,
	Collision = function(npc, collider)
		if collider:ToNPC() then
			return true
		end
	end
}