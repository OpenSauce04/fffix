local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		if not data.Init then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
			data.Init = true
		end
		if sprite:IsFinished("AttackHori") or sprite:IsFinished("WalkHori") then
			sprite:RemoveOverlay()
		elseif sprite:IsPlaying("WalkUp") or sprite:IsPlaying("WalkDown") or sprite:IsPlaying("AttackUp") or sprite:IsPlaying("AttackDown") then
			sprite:RemoveOverlay()
			sprite.FlipX = false
		end

		if sprite.FlipX then
			if sprite:IsPlaying("AttackHori") then
				sprite:PlayOverlay("AttackHeadLeft", false)
			elseif sprite:IsPlaying("WalkHori") then
				sprite:PlayOverlay("WalkHeadLeft", false)
			end
		else
			sprite:RemoveOverlay()
		end

		if npc:IsDead() then
			local corpse = Isaac.Spawn(750, 10, 0, npc.Position, Vector.Zero, npc)
			corpse:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			local moaner = Isaac.Spawn(750, 20, 0, npc.Position, (npc.Position - npc:GetPlayerTarget().Position):Resized(12), npc)
			moaner:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			
			local data_m = moaner:GetData()
			data_m.corpse = corpse
			data_m.target = npc:GetPlayerTarget()
			data_m.ChangedHP = true
			data_m.HPIncrease = 0.1

			if data.moanerhealth then
				moaner.HitPoints = data.moanerhealth
			end
		end
	end
}