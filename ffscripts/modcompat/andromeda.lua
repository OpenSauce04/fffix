if ANDROMEDA then
    if FiendFolio.ItemsEnabled then
        if not FiendFolioAddedAndromedaItems then
            ANDROMEDA:AddToSpode(CollectibleType.COLLECTIBLE_OPHIUCHUS, true)
            ANDROMEDA:AddToSpode(CollectibleType.COLLECTIBLE_CETUS, true)
            ANDROMEDA:AddToSpode(CollectibleType.COLLECTIBLE_MUSCA, true)

            ANDROMEDA:AddToSpode(CollectibleType.COLLECTIBLE_DEIMOS, true)
            ANDROMEDA:AddToSpode(CollectibleType.COLLECTIBLE_NYX, true)


            ANDROMEDA:AddToAbandonedPlanetarium(CollectibleType.COLLECTIBLE_OPHIUCHUS)
            ANDROMEDA:AddToAbandonedPlanetarium(CollectibleType.COLLECTIBLE_CETUS)
            ANDROMEDA:AddToAbandonedPlanetarium(CollectibleType.COLLECTIBLE_MUSCA)
        end
    end
end