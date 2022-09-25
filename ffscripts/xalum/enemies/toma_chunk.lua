local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:TomaChunkDeathEffect(npc)
	local data = npc:GetData()
	if not mod:isLeavingStatusCorpse(npc) then
		for i = 1, math.random(2) do
			data.params.FallingSpeedModifier = math.random(-30, -25)
			if data.launchedEnemyInfo then
				data.params.HeightModifier = npc.PositionOffset.Y
			end
			npc:FireProjectiles(npc.Position, ((npc:GetPlayerTarget().Position - npc.Position) + Vector(30, 0):Rotated(math.random(360))):Resized(7 - math.random()*2), 0, data.params)
		end

		local room = game:GetRoom()
		if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE and Isaac.CountEntities(nil, 85, 0, 0) < 8 and not data.noSpiders then
			local spider = EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(15, 0):Rotated(math.random(360)), false, 0)
			if data.launchedEnemyInfo then
				spider.PositionOffset = npc.PositionOffset
			end
		end

		local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
		splash.SpriteOffset = Vector(0, -14)
		if data.launchedEnemyInfo then
			splash.PositionOffset = npc.PositionOffset
		end
	end

	for _, projectile in pairs(Isaac.FindByType(9, 0, 0)) do
		if projectile.FrameCount == 0 then
			if projectile.SpawnerEntity and mod.XalumGetEntityEquality(projectile.SpawnerEntity, npc) then
				projectile:Remove()
			end
		end
	end
end

return {
	Init = function(npc)
		local data = npc:GetData()

		data.animation = math.random(6)

		data.params = ProjectileParams()
		data.params.FallingAccelModifier = 2
		data.params.Variant = 1

	end,
	AI = function(npc)
		if npc.SubType == mod.FF.TomaChunk.Sub then
			local data = npc:GetData()
			local sprite = npc:GetSprite()

			sprite:SetFrame("Idle"..data.animation, npc.FrameCount % 24)

			if npc:IsDead() then
				mod:TomaChunkDeathEffect(npc)
			end

			if data.fiendfolio_chunkIsOrbiting then
				if data.fiendfolio_chunkIsOrbiting:IsDead() then
					data.fiendfolio_chunkIsOrbiting = nil
				else
					npc.State = 0
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				end
			end

			if data.fiendfolio_projVel then
				npc.Velocity = data.fiendfolio_projVel
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				if npc:CollidesWithGrid() then
					npc:Kill()
					mod:TomaChunkDeathEffect(npc)
				end
			end

			-- Orbiting and Launch code is for Bunker, who isn't current a fiend of folio
			-- Okay SOME of it is used for Mr. Dead, rewritten above

			--[[if data.orbiting and data.orbiting:Exists() and not data.orbiting:IsDead() then
				npc.State = 0
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			elseif data.launched then
				npc.State = 0
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				npc.Velocity = npc.Velocity:Resized(data.launched)

				if npc:CollidesWithGrid() and data.shot + 10 > npc.FrameCount then
					npc:Kill()

					local c = Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0, 0), npc):ToEffect()
					for i = 1, 4 do
						Isaac.Spawn(9, 0, 0, npc.Position, Vector(1, 1):Resized(9):Rotated(90 * i), npc)
					end
				end
			elseif npc.State == 0 then
				npc.State = 4
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end]]
		end
	end,
	Collision = function(npc, collider)
		if collider.Type == 85 then
			return true
		end
	end,
}