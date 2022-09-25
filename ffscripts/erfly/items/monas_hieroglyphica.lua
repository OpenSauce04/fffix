local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local planetariumItems = {
    CollectibleType.COLLECTIBLE_SOL,
    CollectibleType.COLLECTIBLE_LUNA,
    CollectibleType.COLLECTIBLE_MERCURIUS,
    CollectibleType.COLLECTIBLE_VENUS,
    CollectibleType.COLLECTIBLE_TERRA,
    CollectibleType.COLLECTIBLE_MARS,
    CollectibleType.COLLECTIBLE_JUPITER,
    CollectibleType.COLLECTIBLE_SATURNUS,
    CollectibleType.COLLECTIBLE_URANUS,
    CollectibleType.COLLECTIBLE_NEPTUNUS,
    CollectibleType.COLLECTIBLE_PLUTO,
    mod.ITEM.COLLECTIBLE.DEIMOS,
    mod.ITEM.COLLECTIBLE.NYX,
}

function mod:monasHieroglyphicaUpdate(player, d)
    local savedata = d.ffsavedata
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.MONAS_HIEROGLYPHICA) and player.FrameCount >= 1 then
        d.monasHieroglyphPlanet = d.monasHieroglyphPlanet or planetariumItems[math.random(#planetariumItems)]
        if not d.MonasHieroglyphicaWisp then
            local foundWisp
            if savedata.MonasHieroglyphicaWisp then
                local wisps = Isaac.FindByType(3, 237, savedata.MonasHieroglyphicaWisp, false, false)
                if #wisps > 0 then
                    local wisp = wisps[1]:ToFamiliar()
                    d.MonasHieroglyphicaWisp = wisp
                    foundWisp = true
                    wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    wisp:GetData().preventWispFiring = true
                    wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    wisp:RemoveFromOrbit()
                    wisp:Update()
                end
            end
            if not foundWisp then
                local wisp = Isaac.Spawn(3, 237, planetariumItems[math.random(#planetariumItems)], Vector(-100, -50), nilvector, player):ToFamiliar()
                wisp.Parent = player
                wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                wisp:GetData().preventWispFiring = true
                wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                wisp:RemoveFromOrbit()
                wisp:Update()
                d.MonasHieroglyphicaWisp = wisp
                savedata.MonasHieroglyphicaWisp = wisp.SubType
            end
        end
    end
    if d.MonasHieroglyphicaWisp then
        d.MonasHieroglyphicaWisp.Position = Vector(-100, -50)
        d.MonasHieroglyphicaWisp.Visible = false
        if not player:HasCollectible(mod.ITEM.COLLECTIBLE.MONAS_HIEROGLYPHICA) then
            d.MonasHieroglyphicaWisp:Remove()
            d.MonasHieroglyphicaWisp:Kill()
            d.MonasHieroglyphicaWisp = nil
            savedata.MonasHieroglyphicaWisp = nil
            player:TryRemoveNullCostume(NullItemID.ID_MARS)
        end
    end
end
function mod:monasHieroglyphicaNewStage(player, d)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.MONAS_HIEROGLYPHICA) then
        local savedata = d.ffsavedata
        if d.MonasHieroglyphicaWisp then
            d.MonasHieroglyphicaWisp:Remove()
            d.MonasHieroglyphicaWisp:Kill()
            d.MonasHieroglyphicaWisp = nil
            savedata.MonasHieroglyphicaWisp = nil
            player:TryRemoveNullCostume(NullItemID.ID_MARS)
        end
    end
end