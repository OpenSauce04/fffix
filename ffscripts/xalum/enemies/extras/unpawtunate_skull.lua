local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc, data, sprite) -- This has definitely been redone by someone else but I don't know by who or when so idk who to credit :(
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.Init then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
			data.Init = true
		end

		npc.StateFrame = npc.StateFrame + 1
		sprite:Play("Chase", false)

		local funkycolor1 = Color(0.5, 0.5, 0.5, 1, math.floor(50 + npc.StateFrame * 2) / 255, 0, 0)
		local funkycolor2 = Color(1, 1, 1, 1, math.floor(50 + npc.StateFrame * 0.7) / 255, 0, 0)

		if npc.StateFrame > 100 then
			if npc.FrameCount % 2 < 1 then
				npc.Color = funkycolor2
				npc:PlaySound(SoundEffect.SOUND_BEEP, 1, 0, false, 0.7 + npc.StateFrame / 100)
				npc.Scale = 1.2
			else
				npc.Color = funkycolor1
				npc.Scale = FiendFolio:Lerp(npc.Scale, 1, 0.5)
			end
		elseif npc.StateFrame > 50 then
			if npc.FrameCount % 4 < 2 then
				npc.Color = funkycolor1
				npc:PlaySound(SoundEffect.SOUND_BEEP, 1, 0, false, 0.7 + npc.StateFrame / 100)
				npc.Scale = 1.2
			else
				npc.Color = funkycolor2
				npc.Scale = FiendFolio:Lerp(npc.Scale, 1, 0.4)
			end
		else
			if npc.FrameCount % 6 < 3 then
				npc.Color = funkycolor1
				npc:PlaySound(SoundEffect.SOUND_BEEP, 1, 0, false, 0.7 + npc.StateFrame / 100)
				npc.Scale = 1.15
			else
				npc.Color = funkycolor2
				npc.Scale = FiendFolio:Lerp(npc.Scale, 1, 0.4)
			end
		end

		npc.Velocity = npc.Velocity * 0.9 + FiendFolio:reverseIfFear(npc, (FiendFolio:confusePos(npc, npc:GetPlayerTarget().Position) - npc.Position):Resized(npc.Position:Distance(npc:GetPlayerTarget().Position) > 20 and 0.9 or 10))
		npc.Velocity = npc.Velocity:Resized(math.min(npc.Velocity:Length(), 15))
		
		if npc.StateFrame > 150 then
			game:BombExplosionEffects(npc.Position, 2, 0, FiendFolio.ColorInvisible, npc, 0.5, false, true)
			Isaac.Spawn(1000, 1, 0, npc.Position, Vector.Zero, npc)
			npc:BloodExplode()
			npc:Remove()
		end
	end,
	Damage = function(npc, amount)
		npc.StateFrame = npc.StateFrame + math.floor(math.min(amount * 2, 25))
		return false
	end,
}