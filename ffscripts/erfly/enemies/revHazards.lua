local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:checkIceHazards(npc)
    local sprite, d = npc:GetSprite(), npc:GetData()
    if not d.ffinitialized then
        --print(npc.Variant, npc.SubType)
        if npc.Variant == mod.FF.RevIceHazardMorsel.Var then
            local rng = npc:GetDropRNG()
            if npc.SubType < 2 or npc.SubType > 4 then
                npc.SubType = 2 + rng:RandomInt(3)
            end
            sprite:SetLayerFrame(1, npc.SubType - 2)
            d.isFFHazard = true
            d.ffinitialized = npc.SubType - 2
        elseif npc.Variant == mod.FF.RevIceHazardSlammer.Var then
            local rand = math.random(3) + 3
            sprite:SetLayerFrame(1, rand)
            d.isFFHazard = true
            d.ffinitialized = rand
        end
    end
    if d.ffinitialized then
        sprite:SetLayerFrame(1, d.ffinitialized)
    end

end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkIceHazards, 481)

function mod:postRemoveIceHazard(npc)
    local sprite, d = npc:GetSprite(), npc:GetData()
    if npc.FrameCount < 5 then
        return
    end
    if d.isFFHazard then
        if npc.Variant == mod.FF.RevIceHazardMorsel.Var then
            for i = 1, npc.SubType do
                local spawn = Isaac.Spawn(mod.FF.Morsel.ID, mod.FF.Morsel.Var, 0, npc.Position + RandomVector()*3, nilvector, npc.SpawnerEntity or npc):ToNPC()

                spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                spawn:Update()
                d.FromIceHazard = true
            end
        elseif npc.Variant == mod.FF.RevIceHazardSlammer.Var then
            local spawn = Isaac.Spawn(mod.FF.Slammer.ID, mod.FF.Slammer.Var, 0, npc.Position, nilvector, npc.SpawnerEntity or npc):ToNPC()

            spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            spawn:Update()
            d.FromIceHazard = true
        end

        if REVEL and REVEL.WasRoomClearFromStart() then
            npc:GetData().IceHazardKeepDoorsClosed = true
            if not REVEL.GlacierDoorCloseDoneThisRoom then
                REVEL.room:SetClear(false)
                REVEL.ShutDoors()
                REVEL.GlacierDoorCloseDoneThisRoom = true
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.postRemoveIceHazard, 481)
