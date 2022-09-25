local mod = FiendFolio
local game = Game()

return {
	Init = function(npc)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

		local sprite = npc:GetSprite()
		sprite.Offset = Vector(0, -24)
		sprite:Play("HeadProjectile")

		if npc.SubType == mod.FF.SlingerBlack.Sub then
			sprite:ReplaceSpritesheet(2, "gfx/bosses/slinger/slinger_black.png")
			sprite:LoadGraphics()
		end

		local data = npc:GetData()
		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 42)
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		npc.Velocity = npc.Velocity:Resized(11)
		sprite.FlipX = npc.Velocity.X < 0

		local room = game:GetRoom()
		local grid = room:GetGridEntityFromPos(npc.Position + npc.Velocity:Resized(20))

		if npc:CollidesWithGrid() or (grid and grid.CollisionClass ~= GridCollisionClass.COLLISION_NONE) then
			npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, math.random(9, 10)/10)
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, math.random(9, 10)/10)

			local room = game:GetRoom()
			local index = room:GetGridIndex(npc.Position - npc.Velocity)
			if npc.SubType == mod.FF.Slinger.Sub then
				room:SpawnGridEntity(index, GridEntityType.GRID_SPIDERWEB, 0, 0, 0)
			elseif npc.SubType == mod.FF.SlingerBlack.Sub then
				mod.SootTagGrid:Spawn(index, true, false, nil)
			end

			if npc.SubType == mod.FF.Slinger.Sub then
				local spider = Isaac.Spawn(215, 0, 0, npc.Position, RandomVector(), npc)
				spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				spider.HitPoints = spider.MaxHitPoints * 0.75

				spider = Isaac.Spawn(85, 0, 0, npc.Position, RandomVector(), npc)
				spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			elseif npc.SubType == mod.FF.SlingerBlack.Sub then
				local skuzzball = Isaac.Spawn(mod.FF.SkuzzballSmall.ID, mod.FF.SkuzzballSmall.Var, 0, npc.Position, RandomVector(), npc)
				skuzzball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				skuzzball.HitPoints = skuzzball.MaxHitPoints * 0.66
				skuzzball:Update()

				for _, spider in pairs(Isaac.FindByType(85, 0)) do
					if spider.FrameCount == 0 then
						spider:Remove()
					end
				end

				local target = npc:GetPlayerTarget()
				mod.ThrowSkuzz(npc.Position, npc.Position + (target.Position - npc.Position):Resized(60), npc)
			end

			for i = 1, 3 + data.rng:RandomInt(5) do
				local spider = Isaac.Spawn(mod.FF.BabySpider.ID, mod.FF.BabySpider.Var, 0, npc.Position, RandomVector(), npc)
				spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end

			for i = 1, 2 + math.random(2) do
				local gib = Isaac.Spawn(1000, 58, 0, npc.Position - npc.Velocity * 2, RandomVector():Resized(math.random(20, 50)/10), npc)
				local gibSprite = gib:GetSprite()

				if npc.SubType == mod.FF.Slinger.Sub then
					gibSprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/head_gibs.png")
				elseif npc.SubType == mod.FF.SlingerBlack.Sub then
					gibSprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/head_gibs_black.png")
				end
				gibSprite:LoadGraphics()
			end

			game:ShakeScreen(5)
			npc:Die()
		end
	end
}