local mod = FiendFolio


----TAIGA STATUS LISTS----

-- Special routines that must be ran on enemy death for compatibility with FF's Martyr status
mod.MartyrCompatibilityFunctions = {
	[EntityType.ENTITY_VIS_FATTY] = function(entity, sprite, data, typ, var, subt) -- Vis Fatty / Fetal Demon
		if var == 0 then
			if entity.Child ~= nil then
				entity.Child.Parent = nil
			end
			entity.Child = nil
			sprite:RemoveOverlay()
		elseif var == 1 then
			if entity.Parent ~= nil then
				entity.Parent.Child = nil
			end
			entity.Parent = nil
		end
	end,
	[EntityType.ENTITY_PEEPER_FATTY] = function(entity, sprite, data, typ, var, subt) -- Peeping Fatty
		local eyes = Isaac.FindByType(EntityType.ENTITY_PEEPER_FATTY, 10)
		for _, eye in ipairs(eyes) do
			if eye.Parent ~= nil and eye.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				eye.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_GUTTED_FATTY] = function(entity, sprite, data, typ, var, subt) -- Gutted Fatty
		local eyes = Isaac.FindByType(EntityType.ENTITY_GUTTED_FATTY, 10)
		for _, eye in ipairs(eyes) do
			if eye.Parent ~= nil and eye.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				eye.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_ARMYFLY] = function(entity, sprite, data, typ, var, subt) -- Army Fly
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil

		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_MAZE_ROAMER] = function(entity, sprite, data, typ, var, subt) -- Maze Roamer
		if subt == 0 then
			if entity.Child ~= nil then
				entity.Child.Parent = nil
			end
			entity.Child = nil
		end

		if subt == 1 then
			if entity.Parent ~= nil then
				entity.Parent.Child = nil
			end
			entity.Parent = nil
		end
	end,
	[EntityType.ENTITY_PON] = function(entity, sprite, data, typ, var, subt) -- Pon
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil
	end,
	[EntityType.ENTITY_POLTY .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Polty
		local rocks = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER)
		for _, rock in ipairs(rocks) do
			if rock.Parent ~= nil and rock.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				rock.Parent = nil
			end
		end

		local chests = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HAUNTEDCHEST)
		for _, chest in ipairs(chests) do
			if chest.Parent ~= nil and chest.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				chest.Parent = nil
				chest.Child = nil
			end
		end
	end,
	[EntityType.ENTITY_POLTY .. " " .. 1] = function(entity, sprite, data, typ, var, subt) -- Kineti
		if entity.Child ~= nil then
			entity.Child:Kill()
		end
		entity.Child = nil

		local beams = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.KINETI_BEAM)
		for _, beam in ipairs(beams) do
			if beam.Parent ~= nil and beam.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				beam.Parent = nil
			end
		end

		local rocks = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER)
		for _, rock in ipairs(rocks) do
			if rock.Parent ~= nil and rock.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				rock.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_EVIS] = function(entity, sprite, data, typ, var, subt) -- Evis
		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_HEART .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Mask + Heart
		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_HEART .. " " .. 1] = function(entity, sprite, data, typ, var, subt) -- Mask II + 1/2 Heart
		local parent = entity.Parent
		local child = entity.Child

		if parent ~= nil then
			if parent.Type == EntityType.ENTITY_HEART then
				parent:ToNPC().EntityRef = nil
			end

			parent.Child = child
		end
		parent = nil

		if child ~= nil then
			if child.Type == EntityType.ENTITY_HEART then
				child:ToNPC().EntityRef = nil

				if child.Child ~= nil and child.Child.Type == EntityType.ENTITY_MASK then
					if child:ToNPC().State == 9 then
						child.Child:Kill()
					end
					child.Child:ToNPC().State = 9
				end
			elseif child.Type == EntityType.ENTITY_MASK then
				if child:ToNPC().State == 9 then
					child:Kill()
				end
				child:ToNPC().State = 9
			end

			child.Parent = parent
		end
		child = nil
	end,
	[EntityType.ENTITY_VIS .. " " .. 2] = function(entity, sprite, data, typ, var, subt) -- Chubber
		local projectiles = Isaac.FindByType(EntityType.ENTITY_VIS, 22)
		for _, projectile in ipairs(projectiles) do
			if projectile.Parent ~= nil and projectile.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				projectile.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_ATTACKFLY] = function(entity, sprite, data, typ, var, subt) -- Attack Fly (for Fly Trap)
		if entity.Parent ~= nil and entity.Parent.Type == EntityType.ENTITY_FLY_TRAP then
			entity.Parent = nil
		end
	end,
	[EntityType.ENTITY_FLY_TRAP] = function(entity, sprite, data, typ, var, subt) -- Fly Trap
		local flies = Isaac.FindByType(EntityType.ENTITY_ATTACKFLY)
		for _, fly in ipairs(flies) do
			if fly.Parent ~= nil and fly.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				fly.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_BUTTLICKER] = function(entity, sprite, data, typ, var, subt) -- Buttlicker
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil

		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_THE_HAUNT .. " " .. 10] = function(entity, sprite, data, typ, var, subt) -- Lil Haunt (for Exorcist)
		local exorcists = Isaac.FindByType(EntityType.ENTITY_EXORCIST)
		for _, exorcist in ipairs(exorcists) do
			if exorcist.Child ~= nil and exorcist.Child.Type == EntityType.ENTITY_FROZEN_ENEMY then
				exorcist.Child = nil
			end
		end
	end,
	[EntityType.ENTITY_RAG_MEGA .. " " .. 1] = function(entity, sprite, data, typ, var, subt) -- Purple Ball (for Cultist)
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil
	end,
	[EntityType.ENTITY_CULTIST .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Cultist
		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_HOMUNCULUS .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Homunculus
		local segments = Isaac.FindByType(EntityType.ENTITY_HOMUNCULUS, 10)
		for _, segment in ipairs(segments) do
			if segment.Parent ~= nil and segment.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				segment.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_BEGOTTEN .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Begotten
		local segments = Isaac.FindByType(EntityType.ENTITY_BEGOTTEN, 10)
		for _, segment in ipairs(segments) do
			if segment.Parent ~= nil and segment.Parent.Type == EntityType.ENTITY_FROZEN_ENEMY then
				segment.Parent = nil
			end
		end
	end,
	[EntityType.ENTITY_MRMAW .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Mr. Maw
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil
	end,
	[EntityType.ENTITY_MRMAW .. " " .. 1] = function(entity, sprite, data, typ, var, subt) -- Mr. Maw Head
		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_MRMAW .. " " .. 2] = function(entity, sprite, data, typ, var, subt) -- Mr. Red Maw
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil
	end,
	[EntityType.ENTITY_MRMAW .. " " .. 3] = function(entity, sprite, data, typ, var, subt) -- Mr. Red Maw Head
		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_SWINGER .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- Swinger
		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_SWINGER .. " " .. 1] = function(entity, sprite, data, typ, var, subt) -- Swinger Head
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil
	end,
	[EntityType.ENTITY_GRUB] = function(entity, sprite, data, typ, var, subt) -- Grub
		if entity.Parent ~= nil then
			entity.Parent.Child = nil
		end
		entity.Parent = nil

		if entity.Child ~= nil then
			entity.Child.Parent = nil
		end
		entity.Child = nil
	end,
	[EntityType.ENTITY_ROUND_WORM .. " " .. 2] = function(entity, sprite, data, typ, var, subt) -- Tainted Round Worm
		local parent = entity.Parent
		local child = entity.Child

		if entity.Parent ~= nil then
			entity.Parent.Child = child
		end
		entity.Parent = nil

		if entity.Child ~= nil then
			entity.Child.Parent = parent
		end
		entity.Child = nil
	end,
	[FiendFolio.FF.ErodedHost.ID .. " " .. FiendFolio.FF.ErodedHost.Var] = function(entity, sprite, data, typ, var, subt) -- Eroded Host
		if subt == 1 then
			mod:ReplaceEnemySpritesheet(entity, "gfx/enemies/erodedhost/eroded_host2", 0)
			sprite:LoadGraphics()
		elseif subt == 2 then
			mod:ReplaceEnemySpritesheet(entity, "gfx/enemies/erodedhost/eroded_host3", 0)
			sprite:LoadGraphics()
		end
	end,
	[FiendFolio.FF.ErodedSmidgen.ID .. " " .. FiendFolio.FF.ErodedSmidgen.Var] = function(entity, sprite, data, typ, var, subt) -- Eroded Smidgen
		if subt == 1 then
			mod:ReplaceEnemySpritesheet(entity, "gfx/enemies/baby host/tinyErodedBroken", 0)
			sprite:LoadGraphics()
		end
	end,
	[FiendFolio.FFID.Erfly .. " " .. FiendFolio.FF.Punk.Var] = function(entity, sprite, data, typ, var, subt) -- Punk
		mod:ReplaceEnemySpritesheet(entity, "gfx/enemies/gunk/punk", 0)
		sprite:LoadGraphics()
	end,
	[FiendFolio.FF.RiderScythe.ID .. " " .. FiendFolio.FF.RiderScythe.Var] = function(entity, sprite, data, typ, var, subt) -- Punk
		sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
	end,
	[FiendFolio.FF.HollowKnight.ID .. " " .. FiendFolio.FF.HollowKnight.Var] = function(entity, sprite, data, typ, var, subt) -- Hollow Knight (body)
		if data.brain and data.brain:Exists() then
			data.brain:Kill()
		end
	end,
	[FiendFolio.FF.Warble.ID .. " " .. FiendFolio.FF.Warble.Var] = function(entity, sprite, data, typ, var, subt) -- Warble (body)
		if entity.Child then
			entity.Child:Remove()
		end
	end,
	[FiendFolio.FF.PsiKnight.ID .. " " .. FiendFolio.FF.PsiKnight.Var] = function(entity, sprite, data, typ, var, subt) -- Psionic Knight (body)
		if entity.Child then
			entity.Child:Remove()
		end
	end,
	[FiendFolio.FF.ToxicKnight.ID .. " " .. FiendFolio.FF.ToxicKnight.Var] = function(entity, sprite, data, typ, var, subt) -- Toxic Knight (body)
		if entity.Child then
			entity.Child:Remove()
		end
	end,
	[FiendFolio.FF.LonelyKnight.ID .. " " .. FiendFolio.FF.LonelyKnight.Var] = function(entity, sprite, data, typ, var, subt) -- Lonely Knight (body)
		local brains = Isaac.FindByType(FiendFolio.FF.LonelyKnightBrain.ID, FiendFolio.FF.LonelyKnightBrain.Var)
		for _, brain in ipairs(brains) do
			if brain.SpawnerEntity and brain.SpawnerEntity.Index == entity.Index and brain.SpawnerEntity.InitSeed == entity.InitSeed then
				brain:Remove()
			end
		end
		
		local shells = Isaac.FindByType(FiendFolio.FF.LonelyKnightShell.ID, FiendFolio.FF.LonelyKnightShell.Var)
		for _, shell in ipairs(shells) do
			if shell.SpawnerEntity and shell.SpawnerEntity.Index == entity.Index and shell.SpawnerEntity.InitSeed == entity.InitSeed then
				shell:Remove()
			end
		end
	end,
	[EntityType.ENTITY_HOST .. " " .. 0] = function(entity, sprite, data, typ, var, subt) -- FF Grid Hosts
		if data.ffGridHost ~= nil then
			local spritesheet = data.ffGridHost
			if data.ffGridRedHost then
				sprite:ReplaceSpritesheet(1, "gfx/enemies/grid hosts/redhost_" .. spritesheet)
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(1, "gfx/enemies/grid hosts/host_" .. spritesheet)
				sprite:LoadGraphics()
			end
		end
	end,
}



----TAIGA TECHNICAL LISTS----

-- Special routines for obtaining all the segments of a custom enemy
FiendFolio.GetSegmentsFunctions = {
	[FiendFolio.FF.ToxicKnightHusk.ID .. " " .. FiendFolio.FF.ToxicKnightHusk.Var .. " " .. FiendFolio.FF.ToxicKnightHusk.Sub] = function(npc) -- Toxic Knight (body)
		local segments = {npc}
		if npc.Child then
			table.insert(segments, npc.Child)
		end
		return segments
	end,
	[FiendFolio.FF.ToxicKnightBrain.ID .. " " .. FiendFolio.FF.ToxicKnightBrain.Var .. " " .. FiendFolio.FF.ToxicKnightBrain.Sub] = function(npc) -- Toxic Knight (brain)
		local segments = {npc}
		if npc.Parent then
			table.insert(segments, npc.Parent)
		end
		return segments
	end,
	[FiendFolio.FF.PsiKnightHusk.ID .. " " .. FiendFolio.FF.PsiKnightHusk.Var .. " " .. FiendFolio.FF.PsiKnightHusk.Sub] = function(npc) -- Psionic Knight (body)
		local segments = {npc}
		if npc.Child then
			table.insert(segments, npc.Child)
		end
		return segments
	end,
	[FiendFolio.FF.PsiKnightBrain.ID .. " " .. FiendFolio.FF.PsiKnightBrain.Var .. " " .. FiendFolio.FF.PsiKnightBrain.Sub] = function(npc) -- Psi Knight (brain)
		local segments = {npc}
		if npc.Parent then
			table.insert(segments, npc.Parent)
		end
		return segments
	end,
	[FiendFolio.FF.Fingore.ID .. " " .. FiendFolio.FF.Fingore.Var] = function(npc) -- Fingore (body)
		local segments = {npc}
		if npc.Child then
			table.insert(segments, npc.Child)
		end
		return segments
	end,
	[FiendFolio.FF.FingoreHand.ID .. " " .. FiendFolio.FF.FingoreHand.Var] = function(npc) -- Fingore (hand)
		local segments = {npc}
		if npc.Parent then
			table.insert(segments, npc.Parent)
		end
		return segments
	end,
	[FiendFolio.FF.Centipede.ID .. " " .. FiendFolio.FF.Centipede.Var .. " " .. 0] = function(npc) -- Centipede (head)
		local centipedes = Isaac.FindByType(FiendFolio.FF.Centipede.ID, FiendFolio.FF.Centipede.Var)

		local segments = {}
		for _,entity in ipairs(centipedes) do
			if entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.Centipede.ID .. " " .. FiendFolio.FF.Centipede.Var] = function(npc) -- Centipede (body)
		if npc.Parent then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.CentipedeAngy.ID .. " " .. FiendFolio.FF.CentipedeAngy.Var .. " " .. 0] = function(npc) -- Angy Centipede (head)
		local centipedes = Isaac.FindByType(FiendFolio.FF.Centipede.ID, FiendFolio.FF.Centipede.Var)

		local segments = {npc}
		for _,entity in ipairs(centipedes) do
			if entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.Weaver.ID .. " " .. FiendFolio.FF.Weaver.Var .. " " .. 0] = function(npc) -- Weaver (head)
		local weavers = Isaac.FindByType(FiendFolio.FF.Weaver.ID, FiendFolio.FF.Weaver.Var)

		local segments = {}
		for _,entity in ipairs(weavers) do
			if entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.Weaver.ID .. " " .. FiendFolio.FF.Weaver.Var] = function(npc) -- Weaver (body)
		if npc.Parent then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.WeaverSr.ID .. " " .. FiendFolio.FF.WeaverSr.Var .. " " .. 0] = function(npc) -- Weaver Sr. (head)
		local weavers = Isaac.FindByType(FiendFolio.FF.WeaverSr.ID, FiendFolio.FF.WeaverSr.Var)

		local segments = {}
		for _,entity in ipairs(weavers) do
			if entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.WeaverSr.ID .. " " .. FiendFolio.FF.WeaverSr.Var] = function(npc) -- Weaver Sr. (body)
		if npc.Parent then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.DreadWeaver.ID .. " " .. FiendFolio.FF.DreadWeaver.Var .. " " .. 0] = function(npc) -- Dread Weaver (head)
		local weavers = Isaac.FindByType(FiendFolio.FF.DreadWeaver.ID, FiendFolio.FF.DreadWeaver.Var)

		local segments = {}
		for _,entity in ipairs(weavers) do
			if entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.DreadWeaver.ID .. " " .. FiendFolio.FF.DreadWeaver.Var] = function(npc) -- Dread Weaver (body)
		if npc.Parent then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.Thread.ID .. " " .. FiendFolio.FF.Thread.Var .. " " .. 0] = function(npc) -- Thread (head)
		local weavers = Isaac.FindByType(FiendFolio.FF.Thread.ID, FiendFolio.FF.Thread.Var)

		local segments = {}
		for _,entity in ipairs(weavers) do
			if entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.Thread.ID .. " " .. FiendFolio.FF.Thread.Var] = function(npc) -- Thread (body)
		if npc.Parent then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.Ossularry.ID .. " " .. FiendFolio.FF.Ossularry.Var] = function(npc) -- Ossularry (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[FiendFolio.FF.Gorger.ID .. " " .. FiendFolio.FF.Gorger.Var .. " " .. 0] = function(npc) -- Gorger (head)
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[FiendFolio.FF.GorgerAss.ID .. " " .. FiendFolio.FF.GorgerAss.Var .. " " .. FiendFolio.FF.GorgerAss.Sub] = function(npc) -- Gorger (ass)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[FiendFolio.FF.Kingpin.ID .. " " .. FiendFolio.FF.Kingpin.Var] = function(npc) -- Kingpin (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[FiendFolio.FF.Dusk.ID .. " " .. FiendFolio.FF.Dusk.Var] = function(npc) -- Dusk (head)
		local hands = Isaac.FindByType(FiendFolio.FF.DuskHand.ID, FiendFolio.FF.DuskHand.Var)

		local segments = {npc}
		for _,entity in ipairs(hands) do
			if entity.Parent and entity.Parent.InitSeed == npc.InitSeed then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.DuskHand.ID .. " " .. FiendFolio.FF.DuskHand.Var] = function(npc) -- Dusk (hand)
		if npc.Parent then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.Tapeworm.ID .. " " .. FiendFolio.FF.Tapeworm.Var] = function(npc) -- Tapeworm (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[FiendFolio.FF.RotspinCore.ID .. " " .. FiendFolio.FF.RotspinCore.Var] = function(npc) -- Rotspin (body)
		local heads = Isaac.FindByType(FiendFolio.FF.RotspinMoon.ID, FiendFolio.FF.RotspinMoon.Var)

		local segments = {npc}
		for _,entity in ipairs(heads) do
			local data = entity:GetData()
			if data.body ~= nil and data.body:Exists() and data.body.InitSeed == npc.InitSeed then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.RotspinMoon.ID .. " " .. FiendFolio.FF.RotspinMoon.Var] = function(npc) -- Rotspin (hand)
		local data = npc:GetData()
		if data.body ~= nil and data.body:Exists() then
			return mod:getSegments(data.body)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.HollowKnight.ID .. " " .. FiendFolio.FF.HollowKnight.Var] = function(npc) -- Hollow Knight (body)
		local segments = {npc}

		local data = npc:GetData()
		if data.brain and data.brain:Exists() then
			table.insert(segments, data.brain)
		end

		return segments
	end,
	[FiendFolio.FF.Cortex.ID .. " " .. FiendFolio.FF.Cortex.Var] = function(npc) -- Hollow Knight (brain)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[FiendFolio.FF.RollingHollowKnight.ID .. " " .. FiendFolio.FF.RollingHollowKnight.Var] = function(npc) -- Hollow Knight (sanic)
		local segments = {npc}

		local data = npc:GetData()
		if data.brain and data.brain:Exists() then
			table.insert(segments, data.brain)
		end

		return segments
	end,
	[FiendFolio.FF.Bola.ID .. " " .. FiendFolio.FF.Bola.Var .. " " .. 0] = function(npc) -- Bola (body)
		local heads = Isaac.FindByType(FiendFolio.FF.BolaHead.ID, FiendFolio.FF.BolaHead.Var, mod.FF.BolaHead.Sub)

		local segments = {npc}
		for _,entity in ipairs(heads) do
			if entity.Parent and entity.Parent.InitSeed == npc.InitSeed then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.BolaHead.ID .. " " .. FiendFolio.FF.BolaHead.Var .. " " .. FiendFolio.FF.BolaHead.Sub] = function(npc) -- Bola (head)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[FiendFolio.FF.MrBones.ID .. " " .. FiendFolio.FF.MrBones.Var] = function(npc) -- Mr. Bones
		local segments = {npc}

		local data = npc:GetData()
		if data.parent and data.parent:Exists() then
			table.insert(segments, data.parent)
		elseif data.head and data.head:Exists() then
			table.insert(segments, data.head)
		end

		return segments
	end,
	[FiendFolio.FF.MrGob.ID .. " " .. FiendFolio.FF.MrGob.Var] = function(npc) -- Mr. Gob
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		elseif npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[FiendFolio.FF.Prick.ID .. " " .. FiendFolio.FF.Prick.Var] = function(npc) -- Prick
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[FiendFolio.FF.Cordend.ID .. " " .. FiendFolio.FF.Cordend.Var .. " " .. 0] = function(npc) -- Cordend (main half)
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		local cords = Isaac.FindByType(FiendFolio.FF.CordendCord.ID, FiendFolio.FF.CordendCord.Var, mod.FF.CordendCord.Sub)
		for _,entity in ipairs(cords) do
			if entity.Parent and entity.Parent.InitSeed == npc.InitSeed then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[FiendFolio.FF.CordendHalf.ID .. " " .. FiendFolio.FF.CordendHalf.Var .. " " .. FiendFolio.FF.CordendHalf.Sub] = function(npc) -- Cordend (other half)
		if npc.Parent ~= nil and npc.Parent:Exists() then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.CordendCord.ID .. " " .. FiendFolio.FF.CordendCord.Var .. " " .. FiendFolio.FF.CordendCord.Sub] = function(npc) -- Cordend (cord)
		if npc.Parent ~= nil and npc.Parent:Exists() then
			return mod:getSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.Warble.ID .. " " .. FiendFolio.FF.Warble.Var] = function(npc) -- Warble (body)
		local segments = {npc}
		if npc.Child then
			table.insert(segments, npc.Child)
		end
		return segments
	end,
	[FiendFolio.FF.WarbleTail.ID .. " " .. FiendFolio.FF.WarbleTail.Var .. " " .. FiendFolio.FF.WarbleTail.Sub] = function(npc) -- Warble (tail)
		local segments = {npc}
		if npc.Parent then
			table.insert(segments, npc.Parent)
		end
		return segments
	end,
	[FiendFolio.FF.LonelyKnight.ID .. " " .. FiendFolio.FF.LonelyKnight.Var] = function(npc) -- Lonely Knight (body)
		local segments = {npc}

		local brains = Isaac.FindByType(FiendFolio.FF.LonelyKnightBrain.ID, FiendFolio.FF.LonelyKnightBrain.Var)
		for _, brain in ipairs(brains) do
			if brain.SpawnerEntity and brain.SpawnerEntity.Index == npc.Index and brain.SpawnerEntity.InitSeed == npc.InitSeed then
				table.insert(segments, brain)
			end
		end

		local shells = Isaac.FindByType(FiendFolio.FF.LonelyKnightShell.ID, FiendFolio.FF.LonelyKnightShell.Var)
		for _, shell in ipairs(shells) do
			if shell.SpawnerEntity and shell.SpawnerEntity.Index == npc.Index and shell.SpawnerEntity.InitSeed == npc.InitSeed then
				table.insert(segments, shell)
			end
		end

		return segments
	end,
	[FiendFolio.FF.LonelyKnightBrain.ID .. " " .. FiendFolio.FF.LonelyKnightBrain.Var] = function(npc) -- Lonely Knight (brain)
		if npc.SpawnerEntity then
			return mod:getSegments(npc.SpawnerEntity)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.LonelyKnightShell.ID .. " " .. FiendFolio.FF.LonelyKnightShell.Var] = function(npc) -- Lonely Knight (shell)
		if npc.SpawnerEntity then
			return mod:getSegments(npc.SpawnerEntity)
		else
			return {npc}
		end
	end,
	[FiendFolio.FF.Foetus.ID .. " " .. FiendFolio.FF.Foetus.Var .. " " .. FiendFolio.FF.Foetus.Sub] = function(npc) -- Foetus
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[FiendFolio.FF.FoetusBaby.ID .. " " .. FiendFolio.FF.FoetusBaby.Var .. " " .. FiendFolio.FF.FoetusBaby.Sub] = function(npc) -- Foetu
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
}

-- Special routines for obtaining all the segments of a basegame enemy
FiendFolio.GetBasegameSegmentsFunctions = {
	[19] = function(npc) -- Larry Jr., The Hollow, Tuff Twins, The Shell (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[28] = function(npc) -- Chub, C.H.A.D., The Carrion Queen (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[35 .. " " .. 0] = function(npc) -- Mr. Maw (body)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[35 .. " " .. 1] = function(npc) -- Mr. Maw (head)
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[35 .. " " .. 2] = function(npc) -- Mr. Red Maw (body)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[35 .. " " .. 3] = function(npc) -- Mr. Red Maw (head)
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[62] = function(npc) -- Pin, Scolex, The Frail, Wormwood (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[79 .. " " .. 0] = function(npc) -- Gemini
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[79 .. " " .. 1] = function(npc) -- Steven
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[79 .. " " .. 10] = function(npc) -- Gemini (baby)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[79 .. " " .. 11] = function(npc) -- Steven (baby)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[89] = function(npc) -- Buttlicker (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[92 .. " " .. 0] = function(npc) -- Heart
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[92 .. " " .. 1] = function(npc) -- 1/2 Heart
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[93 .. " " .. 0] = function(npc) -- Mask
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[93 .. " " .. 1] = function(npc) -- Mask II
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[97] = function(npc) -- Mask of Infamy
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[98] = function(npc) -- Heart of Infamy
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[216 .. " " .. 0] = function(npc) -- Swinger (body)
		local segments = {npc}

		if npc.Child then
			table.insert(segments, npc.Child)
		end

		return segments
	end,
	[216 .. " " .. 1] = function(npc) -- Swinger (head)
		local segments = {npc}

		if npc.Parent then
			table.insert(segments, npc.Parent)
		end

		return segments
	end,
	[239] = function(npc) -- Grub (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[244 .. " " .. 2] = function(npc) -- Tainted Round Worm
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
	[266 .. " " .. 0] = function(npc) -- Mama Gurdy (body)
		local parts = Isaac.FindByType(EntityType.ENTITY_MAMA_GURDY)

		local segments = {}
		for _,entity in ipairs(parts) do
			if entity.InitSeed == npc.InitSeed or (entity.SpawnerEntity and entity.SpawnerEntity.InitSeed == npc.InitSeed) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[266] = function(npc) -- Mama Gurdy (hands)
		if npc.SpawnerEntity then
			return mod:getBasegameSegments(npc.SpawnerEntity)
		else
			return {npc}
		end
	end,
	[912 .. " " .. 0 .. " " .. 0] = function(npc) -- Mother (phase one)
		local parts = Isaac.FindByType(EntityType.ENTITY_MOTHER)

		local segments = {}
		for _,entity in ipairs(parts) do
			if entity.SubType ~= 1 and (entity.InitSeed == npc.InitSeed or (entity.Parent and entity.Parent.InitSeed == npc.InitSeed)) then
				table.insert(segments, entity)
			end
		end

		return segments
	end,
	[912 .. " " .. 0 .. " " .. 2] = function(npc) -- Mother (left arm)
		if npc.Parent then
			return mod:getBasegameSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[912 .. " " .. 0 .. " " .. 3] = function(npc) -- Mother (right arm)
		if npc.Parent then
			return mod:getBasegameSegments(npc.Parent)
		else
			return {npc}
		end
	end,
	[918] = function(npc) -- Turdlet (any segment)
		local segments = {npc}

		if npc.Parent then
			local current = npc
			while current.Parent do
				local parent = current.Parent
				table.insert(segments, parent)
				current = parent
			end
		end

		if npc.Child then
			local current = npc
			while current.Child do
				local child = current.Child
				table.insert(segments, child)
				current = child
			end
		end

		return segments
	end,
}
