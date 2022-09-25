local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc.Velocity = Vector.Zero

		if not data.init then
			local room = game:GetRoom()
			npc.StateFrame = 30
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			room:SpawnGridEntity(room:GetGridIndex(npc.Position), GridEntityType.GRID_PIT, 0, 1, 0)
			FiendFolio:UpdatePits()
			data.init = true
		else
			npc.StateFrame = npc.StateFrame - 1
			if not FiendFolio:IsCurrentPitSafe(npc) then
				npc:Kill()
			end
		end

		if data.rocket and not data.rocket:Exists() then
			data.rocket = nil
		end

		if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") then
			sprite:Play("Idle")
			npc.StateFrame = FiendFolio:RandomInt(40,80)
		end

		if not data.rocket and sprite:IsPlaying("Idle") and not (npc:HasEntityFlags(EntityFlag.FLAG_FEAR) or npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)) then
			if npc.StateFrame <= 0 then
				sprite:Play("Shoot")
			end
		end

		if sprite:IsEventTriggered("bappy") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_HISS, 1, 0, false, math.random(130,170)/100)
			local targetpos = npc:GetPlayerTarget().Position

			data.rocket = Isaac.Spawn(FiendFolio.FF.BoneRocket.ID, FiendFolio.FF.BoneRocket.Var, 0, npc.Position, (targetpos - npc.Position):Resized(3), npc)
			data.rocket:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			data.rocket.Parent = npc
			data.rocket:GetData().targetpos = targetpos
		end

		if npc:IsDead() then
			local nyan = Isaac.Spawn(750, 40, 0, npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(3), npc):ToNPC()
			nyan:Morph(750, 40, 0, npc:GetChampionColorIdx())
			nyan:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end

		if not sprite:IsPlaying() then
			sprite:Play("Idle")
		end
	end
}