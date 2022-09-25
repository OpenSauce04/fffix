local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

		if npc.SpawnerEntity:IsDead() then
			npc:Remove()
		else
			local data = npc:GetData()

			local offset = data.offset or Vector(0, -32)
			local anim = npc.SpawnerEntity:GetSprite():GetAnimation()

			if not data.offset then
				if anim == "WalkLeft" then
					offset = offset + Vector(-5, 0)
				elseif anim == "WalkRight" then
					offset = offset + Vector(5, 0)
				end
			end

			npc.Velocity = npc.SpawnerEntity.Position + offset - npc.Position
		end
	end,
	Damage = function(npc, amount, flags, source)
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
		else
			return false
		end
	end,
	Collision = function(npc, collider)
		if collider:ToNPC() then
			return true
		elseif collider:ToPlayer() then
			if npc:GetData().offset then
				npc.SpawnerEntity:GetData().toturn = true
			else
				return true
			end
		end
	end,
}