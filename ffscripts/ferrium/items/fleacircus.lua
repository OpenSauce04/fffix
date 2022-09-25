local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, source, countdown)
	ent:GetData().LastDamageWasFlea = source.Entity and source.Entity.Type == EntityType.ENTITY_FAMILIAR and source.Entity.Variant == FamiliarVariant.ATTACK_SKUZZ and source.Entity.SubType > 0
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if mod.anyPlayerHas(FiendFolio.ITEM.TRINKET.FLEA_CIRCUS, true) then
		local mult = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.TRINKET.FLEA_CIRCUS)
		local data = npc:GetData()
		if not data.LastDamageWasFlea and not (npc.Type == mod.FFID.Tech and npc.Variant > 999) then
			local room = game:GetRoom()
			local chance = mult*20
			if npc:GetDropRNG():RandomInt(100) < chance and room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
				local subt = npc:GetDropRNG():RandomInt(4) + 1
				local flea = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ATTACK_SKUZZ, subt, npc.Position, Vector.Zero, nil):ToFamiliar()
				flea:Update()
			end
		end
	end
end)