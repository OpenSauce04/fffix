local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc) 
  local sprite = npc:GetSprite()
    if npc.Type == mod.FF.Cushion.ID and npc.Variant == mod.FF.Cushion.Var then
        if sprite:IsOverlayPlaying("HeadAttack") and sprite:GetOverlayFrame() < 1 then
			npc.V1 = Vector(math.random(130, 150), npc.V1.Y)
		end
    end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags)
    if entity.Variant == mod.FF.Cushion.Var then
		if entity.HitPoints - amount < -20 then
			entity:GetData().NoEnemySpawn = true
		else
			entity:GetData().NoEnemySpawn = false
		end
    end
end, mod.FF.Cushion.ID)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
    if ent.Variant == mod.FF.Cushion.Var then
        if math.random(1, 2) == 1 and not ent:GetData().NoEnemySpawn then
            Isaac.Spawn(170, 120, 0, ent.Position, Vector.Zero, ent)     
            ent:GetData().spawnedSkipper = true
        end
    end
end, mod.FF.Cushion.ID)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if npc.SpawnerType == mod.FF.Cushion.ID and npc.SpawnerVariant == mod.FF.Cushion.Var and npc.SpawnerEntity:IsDead() and npc.SpawnerEntity:GetData().spawnedSkipper then
        npc:Remove()
    end
end, 814)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, var, sub, pos, vel, spawner, seed) 
    if type == 810 and spawner then
        if spawner.Type == mod.FF.Cushion.ID and spawner.Variant == mod.FF.Cushion.Var then
            return {814, 0, 0, seed} --spawn only striders
        end
    end
end)
