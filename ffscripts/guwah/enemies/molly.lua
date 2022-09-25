local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MollyInit(npc)
    npc:GetData().IsMolly = true
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local data = npc:GetData()
    if data.IsMolly then
        local championcolor = -1
        if npc:IsChampion() then
            championcolor = npc:GetChampionColorIdx()
        end
        npc:Morph(280,0,0,championcolor)
        data.IsMolly = false
    end
end, EntityType.ENTITY_GUSHER)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if npc.Variant == 1 and npc.SpawnerEntity and npc.SpawnerEntity:GetData().IsMolly then
        npc:Morph(mod.FF.TomaChunk.ID, mod.FF.TomaChunk.Var, mod.FF.TomaChunk.Sub, -1)
    end
end, EntityType.ENTITY_LEPER)