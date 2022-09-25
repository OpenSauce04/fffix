
local sewingMachineReady = {
    {FiendFolio.ITEM.FAMILIAR.DICE_BAG,         FiendFolio.ITEM.COLLECTIBLE.DICE_BAG,
        {Super = "Sooner payout",
         Ultra = "Sooner payout",}
    },
    {FiendFolio.ITEM.FAMILIAR.LIL_FIEND,        FiendFolio.ITEM.COLLECTIBLE.LIL_FIEND,
        {Super = "Two minions on spawn",
         Ultra = "Three minions on spawn",}
    },
    {FiendFolio.ITEM.FAMILIAR.BABY_CRATER,      FiendFolio.ITEM.COLLECTIBLE.BABY_CRATER,
        {Super = "Piercing tears",
         Ultra = "{{ArrowUp}} Damage Up",}
    },
    {FiendFolio.ITEM.FAMILIAR.MAMA_SPOOTER,     FiendFolio.ITEM.COLLECTIBLE.MAMA_SPOOTER,
        {Super = "Triple shot",
         Ultra = "Pentuple shot",}
    },
    {FiendFolio.ITEM.FAMILIAR.RANDY_THE_SNAIL,  FiendFolio.ITEM.COLLECTIBLE.RANDY_THE_SNAIL,
        {Super = "Triple shot splatter",
         Ultra = "Pentuple shot splatter",}
    },
    {FiendFolio.ITEM.FAMILIAR.GRABBER,          FiendFolio.ITEM.COLLECTIBLE.GRABBER,
        {Super = "Faster grabs",
         Ultra = "Ambidexterity",}
    },
    {FiendFolio.ITEM.FAMILIAR.PEACH_CREEP,      FiendFolio.ITEM.COLLECTIBLE.PEACH_CREEP,
        {Super = "Faster speed",
         Ultra = "Triple shot",}
    },
    {FiendFolio.ITEM.FAMILIAR.WIMPY_BRO,        FiendFolio.ITEM.COLLECTIBLE.WIMPY_BRO,
        {Super = "Fires tears on landing",
         Ultra = "I forgot to add anything",}
    },
    {FiendFolio.ITEM.FAMILIAR.PETROCK,          FiendFolio.ITEM.COLLECTIBLE.PET_ROCK,
        {Super = "Bigger rock",
         Ultra = "Bigger rock",}
    },
    {FiendFolio.ITEM.FAMILIAR.SACK_OF_SPICY,    FiendFolio.ITEM.COLLECTIBLE.SACK_OF_SPICY,
        {Super = "Sooner payout",
         Ultra = "Sooner payout",}
    },
    {FiendFolio.ITEM.FAMILIAR.CLUTCHS_CURSE,    FiendFolio.ITEM.COLLECTIBLE.CLUTCHS_CURSE,
        {Super = "Bursting shots!",
         Ultra = "Bouncing shots!",}
},
    {FiendFolio.ITEM.FAMILIAR.PET_PEEVE,        FiendFolio.ITEM.COLLECTIBLE.PET_PEEVE,
        {Super = "Two bobbies on spawn",
         Ultra = "Three bobbies on spawn",}
    },
    {FiendFolio.ITEM.FAMILIAR.BAG_OF_BOBBIES,   FiendFolio.ITEM.COLLECTIBLE.BAG_OF_BOBBIES,
        {Super = "Two bobbies on spawn",
         Ultra = "Three bobbies on spawn",}
    },
    {FiendFolio.ITEM.FAMILIAR.SIBLING_SYL,      FiendFolio.ITEM.COLLECTIBLE.SIBLING_SYL,
        {Super = "{{ArrowUp}} Tears Up#{{ArrowUp}} Damage Up",
         Ultra = "{{ArrowUp}} Tears Up#{{ArrowUp}} Damage Up"}
    },

    --[[{FiendFolio.ITEM.FAMILIAR.GORGON,           FiendFolio.ITEM.COLLECTIBLE.GORGON},
    {FiendFolio.ITEM.FAMILIAR.DEIMOS,           FiendFolio.ITEM.COLLECTIBLE.DEIMOS},
    {FiendFolio.ITEM.FAMILIAR.LIL_MINX,         FiendFolio.ITEM.COLLECTIBLE.LIL_MINX},
    {FiendFolio.ITEM.FAMILIAR.OPHIUCHUS,        FiendFolio.ITEM.COLLECTIBLE.OPHIUCHUS},
    {FiendFolio.ITEM.FAMILIAR.LIL_LAMB,         FiendFolio.ITEM.COLLECTIBLE.LIL_LAMB},
    {FiendFolio.ITEM.FAMILIAR.GREG,             FiendFolio.ITEM.COLLECTIBLE.GREG_THE_EGG},
    {FiendFolio.ITEM.FAMILIAR.ORANGE_BOOM_FLY,  FiendFolio.ITEM.COLLECTIBLE.FAMILIAR_FLY},
    {FiendFolio.ITEM.FAMILIAR.ROBOBABY3,        FiendFolio.ITEM.COLLECTIBLE.ROBOBABY3},
    {FiendFolio.ITEM.FAMILIAR.D3,               FiendFolio.ITEM.COLLECTIBLE.D3},]]
}

--Sewing machine mod, because why not
function FiendFolio:handleSewingMachineCompat()
    if Sewn_API and not FiendFolioSetUpSewingMachineFamiliars then
        FiendFolioSetUpSewingMachineFamiliars = true
        for i = 1, #sewingMachineReady do
            Sewn_API:MakeFamiliarAvailable(sewingMachineReady[i][1], sewingMachineReady[i][2])
            if sewingMachineReady[i][3] then
                local name = Isaac:GetItemConfig():GetCollectible(sewingMachineReady[i][2]).Name
                Sewn_API:AddFamiliarDescription(sewingMachineReady[i][1], sewingMachineReady[i][3].Super, sewingMachineReady[i][3].Ultra, nil, name)
            end
        end
    end
end