local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc) -- "Neck" but cord
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			sprite:Play("UmbilicalCord")
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
			data.init = true
		end

		if sprite:IsPlaying("UmbilicalCord") then
			npc.Velocity = npc.Velocity * 0.6 + FiendFolio:reverseIfFear(npc, (FiendFolio:confusePos(npc, npc:GetPlayerTarget().Position) - npc.Position):Resized(2))

			if npc.Velocity:Length() > 2.5 then
				npc.Velocity = npc.Velocity:Resized(2.5)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end

		if not sprite:IsPlaying("Death") then
			if npc.FrameCount % 9 == 0 then
				local p = Isaac.Spawn(9, 0, 0, npc.Position, Vector.Zero, npc):ToProjectile()
				p:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				p.Height = p.Height * 3.4
				p.FallingAccel = 3
				p:Update()
			end

			if npc.FrameCount % 7 == 0 then
				Isaac.Spawn(1000, 22, 0, npc.Position, Vector.Zero, nil)
			end
		end

		if game:GetRoom():IsClear() then
			npc.Velocity = Vector.Zero
			if sprite:IsFinished("Death") then
				npc:Die()
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1)
			else
				FiendFolio:spritePlay(sprite, "Death")
			end
		end
	end,
	Damage = function()
		return false
	end,
}