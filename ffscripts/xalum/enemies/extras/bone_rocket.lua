local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		local collideswithplayer = false

		sprite:Play("EXIST")

		if not data.targetpos then data.targetpos = npc:GetPlayerTarget().Position end
		if not data.target then
			data.target = Isaac.Spawn(1000, 7013, 1, data.targetpos, Vector.Zero, npc)
			data.target:Update()
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		end

		sprite.Rotation = (npc.Position - data.target.Position):GetAngleDegrees()
		sprite.Offset = Vector(0, -14)

		npc.Velocity = npc.Velocity * 0.9 + (data.targetpos - npc.Position):Resized(npc.Position:Distance(data.targetpos) > 20 and 0.9 or 10)
		npc.Velocity = npc.Velocity:Resized(math.min(npc.Velocity:Length(), 17))

		for _, p in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER, -1, -1, false, false)) do
			if p.Position:Distance(npc.Position) - p.Size - npc.Size <= 5 then collideswithplayer = true end
		end

		if npc.Position:Distance(data.targetpos) - npc.Size <= 0 or collideswithplayer then
			game:BombExplosionEffects(npc.Position, 2, 0, Color(0, 0, 0, 0, 0, 0, 0), npc, 0.5, false, true)
			Isaac.Spawn(1000, 1, 0, npc.Position, Vector.Zero, npc)
			data.target:Remove()
			npc:Remove()
		end
	end
}