local game = Game()
local sfx = SFXManager()

function FiendFolio.nuchalDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end
	
	FiendFolio.genericCustomDeathAnim(npc, "Release", nil, onCustomDeath)
end

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			sprite:Play("Appear")
			data.init = true
		end

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		end

		if sprite:IsPlaying("Idle") then
			npc.Velocity = npc.Velocity * 0.6 + FiendFolio:reverseIfFear(npc, (FiendFolio:confusePos(npc, npc:GetPlayerTarget().Position) - npc.Position):Resized(1))
			if npc.Velocity:Length() > 1.5 then
				npc.Velocity = npc.Velocity:Resized(1.5)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end

		if sprite:IsEventTriggered("Release") then
			local n = Isaac.Spawn(750, 151, 0, npc.Position, Vector.Zero, nil):ToNPC()
			n:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.7, 0, false, 1)
		end

		if npc.HitPoints < 1 or npc.State == 11 then
			sprite:Play("Release", false)
		end

		if sprite:IsFinished("Release") then
			local c = Isaac.Spawn(750, 152, 0, npc.Position, Vector.Zero, nil):ToNPC()
			c:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			c:GetSprite():Play("UmbilicalCord")
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1)
			npc:Die()
		end
	end,
	Damage = function(npc, amount)
		if npc.State == 11 then
			return false
		end
	end,
}