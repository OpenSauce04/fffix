local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

		if not npc.SpawnerEntity or npc.SpawnerEntity:IsDead() then
			npc:Remove()
		else
			local offset = Vector(0, -38)
			local anim = npc.SpawnerEntity:GetSprite():GetAnimation()

			if anim == "WalkLeft" then
				offset = offset + Vector(-5, 0)
			elseif anim == "WalkRight" then
				offset = offset + Vector(5, 0)
			end

			npc.Velocity = npc.SpawnerEntity.Position + offset - npc.Position
		end
	end,
	Damage = function(npc, amount, flags, source, cooldown)
		local data = npc:GetData()

		if flags == flags | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
			data.FFLastPoisonProc = data.FFLastPoisonProc or 0
			if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
				return false
			end
			data.FFLastPoisonProc = Isaac.GetFrameCount()

			if flags ~= flags | DamageFlag.DAMAGE_CLONES then
				if npc.SpawnerEntity then
					npc.SpawnerEntity:TakeDamage(amount, flags | DamageFlag.DAMAGE_CLONES, source, 0)
				end
				return false
			end
		elseif flags ~= flags | DamageFlag.DAMAGE_CLONES then -- Regular damage
			if npc.SpawnerEntity then
				npc.SpawnerEntity:TakeDamage(amount, flags | DamageFlag.DAMAGE_CLONES, source, 0)
			end
			return false
		end
	end,
	Collision = function(npc, collider)
		if collider:ToNPC() or collider:ToPlayer() then
			return true
		end
	end,
}